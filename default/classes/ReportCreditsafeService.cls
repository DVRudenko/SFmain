/*******************************************************************************
*  ReportCreditsafeService 
*  
*  Implementation of CreditReport for Creditsafe Webservice. Get company from webservice, validation, 
*  flows for Credit and Sales users.
*  added comment for commit
******************************************************************************/
public class ReportCreditsafeService implements CreditReport {
    private Opportunity sourceObject;
    private CreditCompany company;
    private CreditCompany additionalCompany;
    private List<CreditCompanyEmployee> companyEmployeesList;
    private List<CreditCompanyEmployee> additionalCompanyEmployeesList;
    private Decimal buffer;
    private String riskCategory;
    private Decimal securityLevel;
    private Decimal creditLimitWeeklyPlus7;
    private Decimal maxCreditLimitWeeklyPlus7;
    private Decimal maxValueWeeklyPlus7;
    private Decimal depositWeeklyPlus7;
    private Decimal securityLevelWeeklyPlus7;
    private Decimal creditLimitBiWeeklyPlus7;
    private Decimal maxCreditLimitBiWeeklyPlus7;
    private Decimal maxValueBiWeeklyPlus7;
    private Decimal depositBiWeeklyPlus7;
    private Decimal securityLevelBiWeeklyPlus7;
    private Decimal creditLimitMonthlyPlus7;
    private Decimal maxCreditLimitMonthlyPlus7;
    private Decimal maxValueMonthlyPlus7;
    private Decimal depositMonthlyPlus7;
    private Decimal securityLevelMonthlyPlus7;
    private Integer billingPeriod;
    private Integer paymentTerms;
    private Decimal creditLimit;
    private Decimal maxCreditLimit;
    private Decimal maxValue;
    private Decimal deposit;
    private CreditFactoryDecision decision;
    private transient String jsonResponseBody;
    private transient String parentJsonResponseBody;
    private transient String additionalCompanyXml;
    private transient String additionalCompanyEmployeesXml;
    private transient String xmlResponseBodyLexisNexis;
    private Set<String> errorsSet;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping; 
    private String TAX_ID = CreditFactoryUtilities.returnLabelOfField('Account','Steuernummer__c');
    private String VAT_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','Umsatzsteuer_ID__c');
    private String TRADE_REGISTER_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','HR_Abteilung_HRA_HRB_und_HR_Nummer__c');
    public final String LEGAL_FORM_ERROR = 'LegalForm';
    public final String ADDRESS_ERROR = 'Address';
    public final String EMPTY_ADDRESS_ERROR = 'EmptyAddress';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String TRADE_REGISTER_NUMBER_ERROR = 'TradeRegisterNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public final String PAYMENT_METHOD_ERROR = 'PaymentMethod';
    public final String EMAIL_RISK_ERROR = 'EmailRisk';
    public final String SWIFT_BIC_ERROR = 'SwiftBic';
    public List<Credit_Factory_Report__c> existingCreditReportsList;
    public String parentCompanyId;
    public String userSource;
    private String exceptionCode;
    private final String STATEMENT_403 = 'no rating - 403 statement filed, check parent company.';
    private final String BRANCH = 'no rating - branch, refer to head office report.';
    private String authToken;
    private String apiErrorMessage;
    private Decimal fuelPriceIndex;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : set user source    
    *  CreatedDate     : 30/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String userSource - user source to set
    *  Returns         : void
    ******************************************************************************/
    public void setUserSource(String userSource) {
        this.userSource = userSource;
    }

    /*******************************************************************************
    *  Name            : getUserSource()
    *  Summary         : return user source     
    *  CreatedDate     : 30/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getUserSource() {
        return this.userSource;
    }


    /*******************************************************************************
    *  Name            : setMapping()
    *  Summary         : Set custom settings for Opportunity and Account
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void setMapping() {
        try {
            accountMapping = Credit_Factory_Account__c.getInstance(CreditsafeWebservice.CREDIT_SYSTEM_NAME);
            if (accountMapping == null) {
                throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }

        try {
            opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CreditsafeWebservice.CREDIT_SYSTEM_NAME);
            if (opportunityMapping == null) {
                throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setSourceObject(String sfdcRecordId)
    *  Summary         : Get required information from object
    *  CreatedDate     : 2/11/2016
    *  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
    *  Returns         : void
    ******************************************************************************/
    public void setSourceObject(String sfdcRecordId) {
        try {
            String fieldsStringForSQOL = '';
            Map<String, CreditFactory_Opportunity_SOQL__c> soqlFieldsMap = CreditFactory_Opportunity_SOQL__c.getAll();
            for (CreditFactory_Opportunity_SOQL__c field : soqlFieldsMap.values()) {
                fieldsStringForSQOL += field.Field_Name__c + ',';
            }

            String soql = '' +
                    ' SELECT ' + fieldsStringForSQOL;
            List<Schema.SObjectField> accountFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Account__c');
            for (Schema.SObjectField field : accountFieldsList) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.isCustom()) {
                    soql += 'Account.' + accountMapping.get(fieldDescribe.getName()) + ',';
                }
            }
            
            soql += ' Account.ShippingCountry, Account.ShippingStreet, Account.ShippingState, Account.ShippingPostalCode, ' +
                    ' Account.ShippingCity, RecordType.Name, Account.Name, Account.GFN_Nr__c, Account.BillingCountryCode, ' +
                    ' Account.Phone, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, ' + 
                            ' (SELECT Contact.Id, Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name, ' + 
                            ' IsPrimary, Role FROM OpportunityContactRoles) ' +
                    ' FROM Opportunity' + 
                    ' WHERE Id = :sfdcRecordId';
            sourceObject = Database.query(soql);    
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getSourceObject()
    *  Summary         : Returns sObject that we need to use for credit request
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : sObject - Opportunity 
    ******************************************************************************/
    public sObject getSourceObject() {
        return this.sourceObject;
    }


    /*******************************************************************************
    *  Summary         : Send report request to Creditsafe 
    *  CreatedDate     : 30/07/2019
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : -
    ******************************************************************************/
    public void setCreditsafeResponse(CreditSystem creditSystem, String companyId) {
        Http http = new Http();
        if (this.authToken == null) {
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getEndpointUrl());
            HttpResponse authResponse = http.send(authRequest);
            this.apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(authResponse, 'auth');
            if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
            
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(authResponse.getBody());
            this.authToken = authEntity.token;
        }

        HttpRequest jsonReportRequest = CreditSafeWebservice.generateJSONReportRequest(this.authToken, creditSystem.getEndpointUrl(), companyId);
        HttpResponse jsonResponse = http.send(jsonReportRequest);
        this.apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(jsonResponse, 'report');
		if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
        
        if (this.jsonResponseBody == null) {
            this.jsonResponseBody = jsonResponse.getBody();
        } else {
            this.parentJsonResponseBody = jsonResponse.getBody();
        }
    }


    /*******************************************************************************-
    *  Summary         : Send request to LexisNexis to get risks and set response    
    *  CreatedDate     : 03/05/2019
    *  Parameters      : lexisNexisSettings - LexisNexis settings
    *  Returns         : -
    ******************************************************************************/
    private void setLexisNexisResponse(LexisNexis_Settings__c lexisNexisSettings) {
        Contact primaryContact;
        for (OpportunityContactRole role : this.sourceObject.OpportunityContactRoles) {
            if (role.isPrimary == true) {
                primaryContact = role.Contact;
                break;
            }
        }
        HttpRequest request = LexisNexisWebservice.generateIDURequest(
            lexisNexisSettings.Endpoint__c, lexisNexisSettings.User_Name__c, lexisNexisSettings.Password__c, 
            primaryContact.FirstName, primaryContact.LastName, primaryContact.Email, 
            CreditFactoryUtilities.returnReferenceForLexisNexis(this.sourceObject.Account.BillingCountryCode));
        Http http = new Http();
        HttpResponse response = http.send(request);
        this.apiErrorMessage = CreditFactoryUtilities.checkLexisNexisAPIErrors(response);
        if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
        
        this.xmlResponseBodyLexisNexis = response.getBody();
    }


    /*******************************************************************************
    *  Name            : setCompany()
    *  Summary         : Set Company information from response
    *  CreatedDate     : 18/11/2016
    *  ModifiedDate    : 30/07/2019
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : 
    ******************************************************************************/
    public void setCompany(CreditSystem creditSystem, String companyId) {
        if (! this.existingCreditReportsList.isEmpty()) {
            this.company = getExistingReportCompany();
        } else {
            String isCompanyAdditional = Apexpages.currentPage().getParameters().get('isCompanyAdditional');
            if (isCompanyAdditional != 'true') {
                String serviceName = 'Creditsafe';
                try {
                    setCreditsafeResponse(creditSystem, companyId);
                    this.company = CreditsafeWebservice.returnReportCompany(this.jsonResponseBody, this.sourceObject.Account.BillingCountryCode);
                    this.company.identificationnumber = companyId;
                    if (this.sourceObject.Account.BillingCountryCode == 'NL') {
                        if (this.company.providerDescription == STATEMENT_403) {
                            setCreditsafeResponse(creditSystem, this.company.parentCompanyId);
                            CreditCompany parentCompany = CreditsafeWebservice.returnReportCompany(this.parentJsonResponseBody, this.sourceObject.Account.BillingCountryCode);
                            setParentCompanyData(parentCompany);
                        } else if (this.company.providerDescription == BRANCH) {
                            List<CreditCompany> creditCompaniesList = searchHeadOffice(creditSystem);
                            if (!creditCompaniesList.isEmpty()) this.company.parentCompanyId = creditCompaniesList.get(0).identificationnumber;
                            setCreditsafeResponse(creditSystem, this.company.parentCompanyId);
                            CreditCompany parentCompany = CreditsafeWebservice.returnReportCompany(this.parentJsonResponseBody, this.sourceObject.Account.BillingCountryCode);
                            setParentCompanyData(parentCompany);
                        } else {
                            this.company.parentCompanyId = null;
                        }
                    }
                    LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
                    if (lexisNexisSettings.Active__c == true) {
                        serviceName = 'LexisNexis';
                        setLexisNexisResponse(lexisNexisSettings);
                        Dom.Document domDocLexisNexis = new Dom.Document();
                        domDocLexisNexis.load(this.xmlResponseBodyLexisNexis);
                        Dom.XmlNode xmldomLexisNexis = domDocLexisNexis.getRootElement();
                        Dom.XmlNode emailRiskBody = LexisNexisWebservice.returnEmailRiskBody(xmldomLexisNexis);
                        this.company = LexisNexisWebservice.returnReportCompany(emailRiskBody, this.company);
                    }
                } catch (Exception e) {
                    if (! String.isEmpty(this.apiErrorMessage)) {
                        this.apiErrorMessage += '<br/>Company Id: ' + companyId;
                        if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException(this.apiErrorMessage);
                    } else if (e.getMessage() == 'Read timed out') {
                        if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                                '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException(CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
                    } else {
                        if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                                '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException('Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
                    }
                }
            } else {
                this.company = new CreditCompany();
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Search head office of current company.
    *  CreatedDate     : 22/08/2019
    *  Parameters      : CreditSystem creditSystem - Creditsafe credentials
    *  Returns         : companies list
    ******************************************************************************/
    private List<CreditCompany> searchHeadOffice(CreditSystem creditSystem) {
        Http http = new Http();
        HttpRequest searchRequest = CreditSafeWebservice.generateSearchRequest(this.authToken, creditSystem.getEndpointUrl(), this.sourceObject.Account.BillingCountryCode, 
            this.company.taxnumber, null, null, null, 'headOffice');
        HttpResponse searchResponse = http.send(searchRequest);
        CreditsafeSearchEntity searchEntity = CreditsafeSearchEntity.parse(searchResponse.getBody());
        List<CreditCompany> creditCompaniesList = CreditSafeWebservice.returnSearchCompany(searchEntity, this.sourceObject.Account.BillingCountryCode);
        return creditCompaniesList;
    }


    /*******************************************************************************
    *  Name            : setParentCompanyData(CreditCompany parentCompany)
    *  Summary         : Set data from parent company to original company.
    *  CreatedDate     : 22/08/2019
    *  ModifiedDate    : 28/08/2019
    *  Parameters      : CreditCompany parentCompany - parent company
    *  Returns         : CreditCompany
    ******************************************************************************/
    private void setParentCompanyData(CreditCompany parentCompany) {
        this.company.classRating = parentCompany.classRating;
        this.company.creditLimit = parentCompany.creditLimit;
        this.company.turnOver = parentCompany.turnOver;
        this.company.dateoffoundation = parentCompany.dateoffoundation;
        this.company.staffcompanyrange = parentCompany.staffcompanyrange;
        this.company.creditSystemCompanyNumber = parentCompany.creditSystemCompanyNumber;
        this.company.creditDecision = parentCompany.creditDecision;
        this.company.solvencyIndex = parentCompany.solvencyIndex;
    }


    public String getErrorToOrderRequest() {
        return null;
    }         


    public String getInternalId() {
        return null;
    }   


    /*******************************************************************************
    *  Name            : getCompany()
    *  Summary         : Returns Company with Credit information
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : CreditCompany
    ******************************************************************************/
    public CreditCompany getCompany() {
        return this.company;
    }


    /*******************************************************************************
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 2/11/2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setEmployees() {
        try {
            if (! this.existingCreditReportsList.isEmpty()) {
                this.companyEmployeesList = getExistingReportCompanyEmployees();
            } else {
                String isCompanyAdditional = Apexpages.currentPage().getParameters().get('isCompanyAdditional');
                if (isCompanyAdditional != 'true') {
                    this.companyEmployeesList = CreditsafeWebservice.returnReportCompanyEmployees(this.jsonResponseBody);
                } else {
                    this.companyEmployeesList = new List<CreditCompanyEmployee>();
                }
            }
        } catch (Exception e) {
            if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                    '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException('Set employees error.' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : update employees list with contacts from parent company    
    *  CreatedDate     : 4/12/2017
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : -
    ******************************************************************************/
    public void updateEmployees(CreditSystem creditSystem, String companyId) {
        try {
            Http http = new Http();
            HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getEndpointUrl());
            HttpResponse authResponse = http.send(authRequest);
            this.apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(authResponse, 'auth');
            if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
            
            CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(authResponse.getBody());
            HttpRequest jsonReportRequest = CreditSafeWebservice.generateJSONReportRequest(authEntity.token, creditSystem.getEndpointUrl(), companyId);
            HttpResponse jsonResponse = http.send(jsonReportRequest);
            this.apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(jsonResponse, 'report');
            if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
            
            this.jsonResponseBody = jsonResponse.getBody();
            Set<String> currentEmployeesNamesSet = new Set<String>();
            for (CreditCompanyEmployee employee : this.companyEmployeesList) {
                if (employee.companyId == companyId) {
                    employee.Reported = true;
                }
                currentEmployeesNamesSet.add(employee.ename);
            }
            setExistingCreditReports();
            List<CreditCompanyEmployee> additionalEmployees = CreditsafeWebservice.returnReportCompanyEmployees(this.jsonResponseBody);
            List<Credit_Factory_Report_Employee__c> employeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
            List<Credit_Factory_Report_Employee__c> employeesToUpdateList = new List<Credit_Factory_Report_Employee__c>();
            CreditCompany company = new CreditCompany();
            for (Credit_Factory_Report__c creditReport : this.existingCreditReportsList) {
                if (creditReport.RecordType.Name == 'Default') {
                    for (CreditCompanyEmployee additionalEmployee : additionalEmployees) {
                        if (! currentEmployeesNamesSet.contains(additionalEmployee.ename)) {
                            this.companyEmployeesList.add(additionalEmployee);
                            employeesListToInsert.add(new Credit_Factory_Report_Employee__c(
                                Credit_Factory_Report__c = creditReport.Id,
                                Address__c = additionalEmployee.address,
                                Date_of_Birth__c = additionalEmployee.dateofbirth,
                                Id__c = additionalEmployee.enumber,
                                Name = additionalEmployee.ename,
                                Participation_Date__c = additionalEmployee.participationdate,
                                Type__c = additionalEmployee.type,
                                Company_Id__c = additionalEmployee.companyId,
                                Company_Type__c = additionalEmployee.companyType,
                                Company_Role__c = additionalEmployee.companyRole));
                        }
                    }

                    for (Credit_Factory_Report_Employee__c employee : creditReport.Credit_Factory_Report_Employees__r) {
                        if (employee.Company_Id__c == this.parentCompanyId) {
                            employee.Reported__c = true;
                            employeesToUpdateList.add(employee);
                        }
                    }
                }
            }

            insert employeesListToInsert;
            update employeesToUpdateList;
        } catch (Exception e) {
            if (!String.isEmpty(this.apiErrorMessage)) {
                if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                throw new CreditFactoryException(this.apiErrorMessage);
            } else if (e.getMessage() == 'Read timed out') {
                if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.CREDITSAFE_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                        '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                throw new CreditFactoryException(CreditFactoryUtilities.CREDITSAFE_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
            } else {
                if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Update employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                        '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                throw new CreditFactoryException('Update employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        }
    }


    /*******************************************************************************
    *  Name            : setEmployee(Object employeeFromWSDL)
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 2/11/2016
    *  Parameters      : employeeFromWSDL company employee of credit company
    *  Returns         : void
    ******************************************************************************/
    public List<Object> getEmployees() {
        return this.companyEmployeesList;
    }
    
    
    public void setAdditionalScoringData(String signerName) {}


    /*******************************************************************************
    *  Name            : sendAdditionalReportRequest()
    *  Summary         : Send additional request for report     
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 23/05/2018
    *  Parameters      : String companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public void sendAdditionalReportRequest(String companyId) {
        CreditSystem__c companyInfoSettings = CreditSystem__c.getInstance('CompanyInfo');

        if (this.sourceObject.Account.BillingCountryCode != 'NL') return;
        if (companyInfoSettings == null) return;
        if (this.company.registerNumber != null) companyId = this.company.registerNumber;
        if (companyId == null || companyId == '') return;

        Http http = new Http();
        HttpRequest request = CompanyInfoWebservice.generateDutchBusinessGetDossierV3Request(
            companyInfoSettings.Endpoint__c, 
            companyInfoSettings.UserName__c, 
            companyInfoSettings.Password__c, 
            companyId);
        HttpResponse response = http.send(request);
        this.apiErrorMessage = CreditFactoryUtilities.checkCompanyInfoAPIErrors(response);
        if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
        this.additionalCompanyXml = response.getBody();
    }


    /*******************************************************************************
    *  Name            : setAdditionalCompany()
    *  Summary         : Set company with data from additional request. 
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 23/05/2018
    *  Parameters      : String companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public void setAdditionalCompany(String companyId) {
        this.additionalCompany = new CreditCompany();
        if (! this.existingCreditReportsList.isEmpty()) {
            this.additionalCompany = getExistingAdditionalReportCompany();
        } else {
            try {
                sendAdditionalReportRequest(companyId);
                if (this.additionalCompanyXml != null) {
                    String xml = this.additionalCompanyXml;
                    Dom.Document domDoc = new Dom.Document();
                    domDoc.load(xml);
                    Dom.XMLNode xmldom = domDoc.getRootElement();
                    this.additionalCompany = CompanyInfoWebservice.returnReportCompany(xmldom);
                }
            } catch (Exception e) {
                if (Apexpages.currentPage().getParameters().get('isCompanyAdditional') == 'true') {
                    if (!String.isEmpty(this.apiErrorMessage)) {
                        ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException(this.apiErrorMessage);
                    } else if (e.getMessage() == 'Read timed out') {
                        ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.COMPANY_INFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException(CreditFactoryUtilities.COMPANY_INFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
                    } else {
                        ExceptionLogger.sendException('<br/>Reason: ' + 'Set additional company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException('Set additional company error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getAdditionalCompany()
    *  Summary         : Return additional company data.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditCompany
    ******************************************************************************/
    public CreditCompany getAdditionalCompany() {
        return this.additionalCompany;
    }


    /*******************************************************************************
    *  Name            : sendAdditionalReportEmployeesRequest()
    *  Summary         : Send additional request for report employees.   
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 23/05/2018
    *  Parameters      : String companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public void sendAdditionalReportEmployeesRequest(String companyId) {
        CreditSystem__c companyInfoSettings = CreditSystem__c.getInstance('CompanyInfo');

        if (this.sourceObject.Account.BillingCountryCode != 'NL') return;
        if (companyInfoSettings == null) return;
        if (this.company.registerNumber != null) companyId = this.company.registerNumber;
        if (companyId == null || companyId == '') return;
        
        Http http = new Http();
        HttpRequest request = CompanyInfoWebservice.dutchBusinessGetPositions(
            companyInfoSettings.Endpoint__c, 
            companyInfoSettings.UserName__c, 
            companyInfoSettings.Password__c, 
            companyId);
        HttpResponse response = http.send(request);
        this.apiErrorMessage = CreditFactoryUtilities.checkCompanyInfoAPIErrors(response);
        if (! String.isEmpty(this.apiErrorMessage)) throw new CreditFactoryException(this.apiErrorMessage);
        this.additionalCompanyEmployeesXml = response.getBody();
    }


    /*******************************************************************************
    *  Name            : setAdditionalCompanyEmployees()
    *  Summary         : Set company employees with data from additional request.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : 23/05/2018
    *  Parameters      : String companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public void setAdditionalCompanyEmployees(String companyId) {
        this.additionalCompanyEmployeesList = new List<CreditCompanyEmployee>();
        if (! this.existingCreditReportsList.isEmpty()) {
            this.additionalCompanyEmployeesList = getExistingAdditionalReportCompanyEmployees();
        } else {
            try {
                sendAdditionalReportEmployeesRequest(companyId);
                if (this.additionalCompanyEmployeesXml != null) {
                    String xml = this.additionalCompanyEmployeesXml;
                    Dom.Document domDoc = new Dom.Document();
                    domDoc.load(xml);
                    Dom.XMLNode xmldom = domDoc.getRootElement();
                    this.additionalCompanyEmployeesList = CompanyInfoWebservice.returnCompanyInfoEmployees(xmldom);
                }
            } catch (Exception e) {
                if (Apexpages.currentPage().getParameters().get('isCompanyAdditional') == 'true') {
                    if (!String.isEmpty(this.apiErrorMessage)) {
                        ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException(this.apiErrorMessage);
                    } else if (e.getMessage() == 'Read timed out') {
                        ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.COMPANY_INFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException(CreditFactoryUtilities.COMPANY_INFO_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
                    } else {
                        ExceptionLogger.sendException('<br/>Reason: ' + 'Set additional company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                        throw new CreditFactoryException('Set additional company error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getAdditionalCompanyEmployees()
    *  Summary         : Return company employees data.    
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : List<CreditCompanyEmployees>
    ******************************************************************************/
    public List<CreditCompanyEmployee> getAdditionalCompanyEmployees() {
        return this.additionalCompanyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : setExistingCreditReports()
    *  Summary         : Set existing in database credit reports
    *  CreatedDate     : 20/10/2017
    *  ModifiedDate    : 17/09/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        this.existingCreditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, Turn_Over__c, Legal_Form__c, VAT_Number__c, Tax_Id__c, Trade_Register_Number__c,
                    Date_Legal_Form__c, Register_Number__c, Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, 
                    Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c, Age_of_Company__c, First_Legal_Form__c, 
                    Company_Status__c, Name, Trade_Name__c, Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                    Email__c, Website__c, RecordType.Name, Indication_Main_Establishment__c, Rsin_Number__c, Indication_Organisation__c, 
                    Authorized_Share_Capital_Currency__c, Primary_Sbi_Code__c, Primary_Sbi_Code_Text__c, Indication_Economically_Active__c, 
                    Indication_Non_Mailing__c, Indication_Bankruptcy__c, Indication_Dip__c, Authorized_Share_Capital__c, Paid_Up_Share_Capital__c, 
                    Paid_Up_Share_Capital_Currency__c, Issued_Share_Capital__c, Issued_Share_Capital_Currency__c, Continuation_Date__c, Establishment_Date__c,
                    Name__c, Date_Of_Last_Change_Of_Director__c, Principal_Activity_Code__c, Principal_Activity_Description__c, Email_Exists__c, Domain_Exists__c, 
                    Email_Date__c, Domain_Date__c, Email_Status__c, Email_Risk__c, Risk_Description__c, Risk_Advice__c, Fraud_Within_Industry__c, Fraud_Type__c, 
                    Total_Hits__c, Unique_Hits__c, Name_Match__c, Checked_Email__c, Solvency_Index__c, Parent_Company_Id__c, Provider_Description__c,
                    Date_Of_Last_Change_Of_Address__c, Address_Change_Decision__c,
                            (SELECT Type__c, Name, Date_of_Birth__c, Address__c, Participation_Date__c, Company_Id__c, Company_Type__c, 
                                Company_Role__c, Reported__c 
                                FROM Credit_Factory_Report_Employees__r)
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :this.sourceObject.Id AND CreatedDate > :Date.today().addMonths(-3)
                ORDER BY CreatedDate DESC
                LIMIT 2];
    }

    
    /*******************************************************************************
    *  Name            : getExistingReportCompany()
    *  Summary         : Return company from existing Credit Factory Report object.
    *  CreatedDate     : 23/10/2017
    *  ModifiedDate    : 21/08/2019
    *  Parameters      : -
    *  Returns         : CreditCompany
    ******************************************************************************/
    private CreditCompany getExistingReportCompany() {
        CreditCompany company = new CreditCompany();
        for (Credit_Factory_Report__c creditReport : this.existingCreditReportsList) {
            if (creditReport.RecordType.Name == 'Default') {
                company.creditSystemCompanyNumber = creditReport.Credit_System_Number__c;
                company.referencenumber = creditReport.Reference_Number__c;
                company.classRating = creditReport.Class_Rating__c;
                company.turnOver = creditReport.Turn_Over__c;
                company.legalform = creditReport.Legal_Form__c;
                company.vatid = creditReport.VAT_Number__c;
                company.taxnumber = creditReport.Tax_Id__c;
                company.tradeRegisterNumber = creditReport.Trade_Register_Number__c;
                company.datelegalform = creditReport.Date_Legal_Form__c;
                company.registerNumber = creditReport.Register_Number__c;
                company.datelastregisterentry = creditReport.Date_Last_Register_Entry__c;
                company.countyCourt = creditReport.County_Court__c;
                company.paymentBehaviour = creditReport.Payment_Behaviour__c;
                company.staffcompanyrange = creditReport.Staff_Range__c;
                company.creditLimit = creditReport.Credit_Limit__c;
                company.creditLimitCurrency = creditReport.Credit_Limit_Currency__c;
                company.creditDecision = creditReport.Credit_Decision__c;
                company.dateoffoundation = creditReport.Date_of_Foundation__c;
                company.ageofcompany = creditReport.Age_of_Company__c;
                company.firstlegalform = creditReport.First_Legal_Form__c;
                company.status = creditReport.Company_Status__c;
                company.name = creditReport.Name__c;
                company.tradename = creditReport.Trade_Name__c;
                company.street = creditReport.Street__c;
                company.housenumber = creditReport.Housenumber__c;
                company.postcode = creditReport.Postcode__c;
                company.city = creditReport.City__c;
                company.country = creditReport.Country__c;
                company.phone = creditReport.Phone__c;
                company.fax = creditReport.Fax__c;
                company.mobile = creditReport.Mobile__c;
                company.email = creditReport.Email__c;
                company.website = creditReport.Website__c;
                company.identificationnumber = creditReport.Credit_System_Number__c;
                company.dateOfLastChangeOfDirector = creditReport.Date_Of_Last_Change_Of_Director__c;
                company.dateOfLastChangeOfAddress = creditReport.Date_Of_Last_Change_Of_Address__c;
                company.addressChangeDecision = creditReport.Address_Change_Decision__c;
                company.principalActivityCode = creditReport.Principal_Activity_Code__c;
                company.principalACtivityDescription = creditReport.Principal_Activity_Description__c;
                company.emailExists = creditReport.Email_Exists__c;
                company.domainExists = creditReport.Domain_Exists__c;
                company.emailDate = creditReport.Email_Date__c;
                company.domainDate = creditReport.Domain_Date__c;
                company.emailStatus = creditReport.Email_Status__c;
                company.emailRisk = creditReport.Email_Risk__c;
                company.riskDescription = creditReport.Risk_Description__c;
                company.riskAdvice = creditReport.Risk_Advice__c;
                company.fraudWithinIndustry = creditReport.Fraud_Within_Industry__c;
                company.fraudType = creditReport.Fraud_Type__c;
                company.totalHits = creditReport.Total_Hits__c;
                company.uniqueHits = creditReport.Unique_Hits__c;
                company.nameMatch = creditReport.Name_Match__c;
                company.checkedEmail = creditReport.Checked_Email__c;
                company.solvencyIndex = creditReport.Solvency_Index__c;
                company.parentCompanyId = creditReport.Parent_Company_Id__c;
                company.providerDescription = creditReport.Provider_Description__c;
            }
        }

        return company;
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompanyEmployees()
    *  Summary         : Get company employees from Credit Factory Report Employee objects.      
    *  CreatedDate     : 23/09/2017
    *  ModifiedDate    : 20/04/2018
    *  Parameters      : -
    *  Returns         : List<CreditCompanyEmployee>()
    ******************************************************************************/
    private List<CreditCompanyEmployee> getExistingReportCompanyEmployees() {
        List<CreditCompanyEmployee> companyEmployeesList = new List<CreditCompanyEmployee>();
        for (Credit_Factory_Report__c creditReport : this.existingCreditReportsList) {
            if (creditReport.RecordType.Name == 'Default') {
                for (Credit_Factory_Report_Employee__c existingEmployee : creditReport.Credit_Factory_Report_Employees__r) {
                    CreditCompanyEmployee employee = new CreditCompanyEmployee();
                    employee.type = existingEmployee.Type__c;
                    employee.enumber = existingEmployee.Id;
                    employee.ename = existingEmployee.Name;
                    employee.dateofbirth = existingEmployee.Date_of_Birth__c;
                    employee.address = existingEmployee.Address__c;
                    employee.participationdate = existingEmployee.Participation_Date__c;
                    employee.companyId = existingEmployee.Company_Id__c;
                    employee.companyType = existingEmployee.Company_Type__c;
                    employee.companyRole = existingEmployee.Company_Role__c;
                    employee.Reported = existingEmployee.Reported__c;
                    companyEmployeesList.add(employee);
                }
            }
        }

        return companyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : getExistingAdditionalReportCompany()
    *  Summary         : Get additonal company from existing additional Credit Factory Report object.
    *  CreatedDate     : 20/04/2018
    *  ModifiedDate    : 20/04/2018
    *  Parameters      : 
    *  Returns         : CreditCompany
    ******************************************************************************/
    private CreditCompany getExistingAdditionalReportCompany() {
        CreditCompany additionalCompany = new CreditCompany();
        for (Credit_Factory_Report__c creditReport : this.existingCreditReportsList) {
            if (creditReport.RecordType.Name == 'Company Info') {
                additionalCompany.name = creditReport.Name;
                additionalCompany.indicationMainEstablishment = creditReport.Indication_Main_Establishment__c;
                additionalCompany.rsinNumber = creditReport.Rsin_Number__c;
                additionalCompany.legalform = creditReport.Legal_Form__c;
                additionalCompany.indicationOrganisation = creditReport.Indication_Organisation__c;
                additionalCompany.tradename = creditReport.Trade_Name__c;
                additionalCompany.postcode = creditReport.Postcode__c;
                additionalCompany.city = creditReport.City__c;
                additionalCompany.street = creditReport.Street__c;
                additionalCompany.housenumber = creditReport.Housenumber__c;
                additionalCompany.country = creditReport.Country__c;
                additionalCompany.phone = creditReport.Phone__c;
                additionalCompany.mobile = creditReport.Mobile__c;
                additionalCompany.website = creditReport.Website__c;
                additionalCompany.primarySbiCode = creditReport.Primary_Sbi_Code__c;
                additionalCompany.primarySbiCodeText = creditReport.Primary_Sbi_Code_Text__c;
                additionalCompany.staffcompanyrange = creditReport.Staff_Range__c;
                additionalCompany.indicationEconomicallyActive = creditReport.Indication_Economically_Active__c;
                additionalCompany.indicationNonMailing = creditReport.Indication_Non_Mailing__c;
                additionalCompany.indicationBankruptcy = creditReport.Indication_Bankruptcy__c;
                additionalCompany.indicationDip = creditReport.Indication_Dip__c;
                additionalCompany.authorizedShareCapital = creditReport.Authorized_Share_Capital__c;
                additionalCompany.authorizedShareCapitalCurrency = creditReport.Authorized_Share_Capital_Currency__c;
                additionalCompany.paidUpShareCapital = creditReport.Paid_Up_Share_Capital__c;
                additionalCompany.paidUpShareCapitalCurrency = creditReport.Paid_Up_Share_Capital_Currency__c;
                additionalCompany.issuedShareCapital = creditReport.Issued_Share_Capital__c;
                additionalCompany.issuedShareCapitalCurrency = creditReport.Issued_Share_Capital_Currency__c;
                additionalCompany.continuationDate = creditReport.Continuation_Date__c;
                additionalCompany.establishmentDate = creditReport.Establishment_Date__c;
                additionalCompany.dateoffoundation  = creditReport.Date_of_Foundation__c;
            }
        }

        return additionalCompany;
    }


    /*******************************************************************************
    *  Name            : getExistingAdditionalReportCompanyEmployees()
    *  Summary         : Get additional company employees from existing additional Credit Factory Report Employee objects.      
    *  CreatedDate     : 20/04/2018
    *  ModifiedDate    : 20/04/2018
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Report_Employee__c>
    ******************************************************************************/
    private List<CreditCompanyEmployee> getExistingAdditionalReportCompanyEmployees() {
        List<CreditCompanyEmployee> companyEmployeesList = new List<CreditCompanyEmployee>();
        for (Credit_Factory_Report__c creditReport : this.existingCreditReportsList) {
            if (creditReport.RecordType.Name == 'Company Info') {
                for (Credit_Factory_Report_Employee__c existingEmployee : creditReport.Credit_Factory_Report_Employees__r) {
                    CreditCompanyEmployee employee = new CreditCompanyEmployee();
                    employee.type = existingEmployee.Type__c;
                    employee.ename = existingEmployee.Name;
                    employee.dateofbirth = existingEmployee.Date_of_Birth__c;
                    employee.companyRole = existingEmployee.Company_Role__c;
                    companyEmployeesList.add(employee);
                }
            }
        }

        return companyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : getErrorsSet()
    *  Summary         : Returns set of errors and display section to fix error on page
    *  CreatedDate     : 07/11/2016
    *  Parameters      : 
    *  Returns         : Set<String>
    ******************************************************************************/
    public Set<String> getErrorsSet() {
        return this.errorsSet;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : Compare information from CreditReform with Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 05/11/2019
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validate() {
        errorsSet = new Set<String>();
        Boolean isValid = true;
        validateDateOfFoundation();
        if ( ! validateEmptyAddress()) isValid = false;
        if ( ! validateAddress()) isValid = false;
        if ( ! validateLegalForm()) isValid = false;
        if ( ! validateCompanyName()) isValid = false;
        if ( ! validateTaxId()) isValid = false;
        if ( ! validateVatNumber()) isValid = false;
        if ( ! validateTradeRegisterNumber()) isValid = false;
        if ( ! validateLostOpportunities()) isValid = false;
        if ( ! validatePaymentMethod()) isValid = false;
        if ( ! validateEmailRisk()) isValid = false;
        if ( ! validateSwiftBic()) isValid = false;
        if ( ! validateBusinessCode()) isValid = false;
        validateContact();

        return isValid;
    }


    /*******************************************************************************
    *  Summary         : Check date of foundation    
    *  CreatedDate     : 21/06/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void validateDateOfFoundation() {
        if (this.company.dateoffoundation == null) {
            if (this.company.legalform == 'Physical person') {
                this.sourceObject.StageName = 'Closed Lost';
                this.sourceObject.Gruende_verloren__c = 'Not a legal entity';
                this.sourceObject.Kredit_Entscheidung__c = 'Abgelehnt';
                update this.sourceObject;
                throw new CreditFactoryException('Opportunity is Closed as lost. Requester is a physical person, not a company.');
            }
        }
    }


    /*******************************************************************************
    *  Name            : validateEmptyAddress()
    *  Summary         : Check if address contains full information
    *  CreatedDate     : 02/10/2020 by Ivan Kulinkovich
    *  Parameters      :
    *  Returns         : Boolean - returns TRUE if no errors
    ******************************************************************************/
    public Boolean validateEmptyAddress() {
        if (this.company.name != null && (company.city == null || company.street == null || company.postcode == null || company.housenumber == null && company.country != 'FR')) {
            CreditFactoryUtilities.displayMessage('error', 'Company has no known address.');
            errorsSet.add(EMPTY_ADDRESS_ERROR);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateAddress()
    *  Summary         : Compare Address information from CreditReform with Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns TRUE if no errors
    ******************************************************************************/
    public Boolean validateAddress() {
        String billingStreetAndHouseNumber = '';
        if (sourceObject.Account.BillingStreet != null) {
            billingStreetAndHouseNumber = sourceObject.Account.BillingStreet;
        }
        String shippingStreetAndHouseNumber = '';
        if (sourceObject.Account.ShippingStreet != null) {
            shippingStreetAndHouseNumber = sourceObject.Account.ShippingStreet;
        }

        String creditCompanyStreetAndHouseNumber = (company.street != null ? company.street : '') + ' ' + (company.housenumber != null ? company.housenumber : '');
        creditCompanyStreetAndHouseNumber = creditCompanyStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        String creditCompanyHouseNumberAndStreet = (company.housenumber != null ? company.housenumber : '') + ' ' + (company.street != null ? company.street : '');
        creditCompanyHouseNumberAndStreet = creditCompanyHouseNumberAndStreet.removeStart(' ').removeEnd(' ');

        String additionalCreditCompanyStreetAndHouseNumber = '';
        String additionalCreditCompanyHouseNumberAndStreet = '';
        String additionalCreditCompanyPostalcode = '';
        String additionalCreditCompanyCity = '';

        if (this.additionalCompany != null) {
            additionalCreditCompanyStreetAndHouseNumber = (this.additionalCompany.street != null ? this.additionalCompany.street : '') + ' ' + 
                (this.additionalCompany.housenumber != null ? this.additionalCompany.housenumber : '');
            additionalCreditCompanyStreetAndHouseNumber = additionalCreditCompanyStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
            additionalCreditCompanyHouseNumberAndStreet = (this.additionalCompany.housenumber != null ? this.additionalCompany.housenumber : '') + ' ' + 
                (this.additionalCompany.street != null ? this.additionalCompany.street : '');
            additionalCreditCompanyHouseNumberAndStreet = additionalCreditCompanyHouseNumberAndStreet.removeStart(' ').removeEnd(' ');
            additionalCreditCompanyPostalcode = (this.additionalCompany.postcode != null ? this.additionalCompany.postcode : '');
            additionalCreditCompanyCity = (this.additionalCompany.city != null ? this.additionalCompany.city : '');
        }

        String billingPostalCode = sourceObject.Account.BillingPostalCode;
        String shippingPostalCode = sourceObject.Account.ShippingPostalCode;
        String creditCompanyPostalcode = company.postcode;

        String billingCity = sourceObject.Account.BillingCity;
        String shippingCity = sourceObject.Account.ShippingCity;
        String creditCompanyCity = company.city;
        
        if (! ((validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, creditCompanyStreetAndHouseNumber) ||
            validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, creditCompanyHouseNumberAndStreet) ||
            validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, additionalCreditCompanyStreetAndHouseNumber) ||
            validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, additionalCreditCompanyHouseNumberAndStreet)) &&
            (validateCity(billingCity, shippingCity, creditCompanyCity) ||
            validateCity(billingCity, shippingCity, additionalCreditCompanyCity)) && 
            (validatePostalCode(billingPostalCode, shippingPostalCode, creditCompanyPostalcode) || 
            validatePostalCode(billingPostalCode, shippingPostalCode, additionalCreditCompanyPostalcode)))) {
            errorsSet.add(ADDRESS_ERROR);
            if (! errorsSet.contains(EMPTY_ADDRESS_ERROR)) {
                String errorMessage = 'Account Billing and Shipping Addresses should be the same as ' +
                        CreditSafeWebservice.CREDIT_SYSTEM_NAME + ' address';
                CreditFactoryUtilities.displayMessage('error', errorMessage);
            }
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateStreet(String billingStreet, String shippingStreet, String crefoStreet)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingStreet – Billing Street 
                         String shippingStreet – Shipping Street 
                         String crefoStreet – Street for Creditreform 
    *  Returns         : Boolean – returns TRUE if all streets are the same
    ******************************************************************************/
    public Boolean validateStreet(String billingStreet, String shippingStreet, String crefoStreet) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingStreet,shippingStreet) && 
                          CreditFactoryUtilities.isStringsEquals(billingStreet,crefoStreet)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validateCity(String billingCity, String shippingCity, String crefoCity)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingCity – Billing City 
                         String shippingCity – Shipping City 
                         String crefoCity – City for Creditreform 
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validateCity(String billingCity, String shippingCity, String crefoCity) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingCity,shippingCity) && 
            CreditFactoryUtilities.isStringsEquals(billingCity,crefoCity)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validatePostalCode(String billingPostalCode, String shippingPostalCode, String crefoPostalCode)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingPostalCode – Billing PostalCode 
                         String shippingPostalCode – Shipping PostalCode 
                         String crefoPostalCode – PostalCode for Creditreform 
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validatePostalCode(String billingPostalCode, String shippingPostalCode, String crefoPostalCode) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingPostalCode,shippingPostalCode) && 
            CreditFactoryUtilities.isStringsEquals(billingPostalCode,crefoPostalCode)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validateLegalForm()
    *  Summary         : Compare Legal Form information from CreditReform with Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateLegalForm() {
        return true;
    }


    /*******************************************************************************
    *  Name            : validateContact()
    *  Summary         : Check that contact from CreditSafe exists in Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 22/04/2019
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateContact() {
        List<AccountContactRelation> relationsList = [
                SELECT Account.Name, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone
                FROM AccountContactRelation
                WHERE AccountId = :this.sourceObject.AccountId];
        Set<String> contactsLastNamesSet = new Set<String>();
        Set<String> contactsFirstAndLastNamesSet = new Set<String>();
        Set<String> contactsEmailsDomainsSet = new Set<String>();
        Set<String> contactsPhonesSet = new Set<String>();
        for (AccountContactRelation contactRelation : relationsList) {
            String firstName = '';
            String lastName;
            if (this.sourceObject.Account.BillingCountryCode == 'NL') {
                if (contactRelation.Contact.FirstName != null) {
                    firstName = CreditFactoryUtilities.replaceDutchCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
                }
                lastName = CreditFactoryUtilities.replaceDutchCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
            } else if (this.sourceObject.Account.BillingCountryCode == 'FR') {
                if (contactRelation.Contact.FirstName != null) {
                    firstName = CreditFactoryUtilities.replaceFrenchCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
                }
                lastName = CreditFactoryUtilities.replaceFrenchCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
            } else {
                if (contactRelation.Contact.FirstName != null) {
                    firstName = contactRelation.Contact.FirstName.toUpperCase().replace('’', '\'');
                }
                lastName = contactRelation.Contact.LastName.toUpperCase().replace('’', '\'');
            }

            contactsLastNamesSet.add(lastName);
            contactsFirstAndLastNamesSet.add((firstName + ' ' + lastName).removeStart(' '));
            contactsFirstAndLastNamesSet.add((lastName + ' ' + firstName).removeEnd(' '));

            if (contactRelation.Contact.Email != null) {
                contactsEmailsDomainsSet.add(contactRelation.Contact.Email.substringAfterLast('@').toUpperCase());
            }
            
            if (contactRelation.Contact.Phone != null && contactRelation.Contact.Phone.length() >= 6) {
                String phone = contactRelation.Contact.Phone;
                contactsPhonesSet.add(phone.substring(phone.length() - 6, phone.length()));
            }
        }

        String primaryContactRole = '';
        for (OpportunityContactRole contactRole : this.sourceObject.OpportunityContactRoles) {
            if (contactrole.IsPrimary == true) {
                primaryContactRole = contactRole.Role;
            }
        }

        Boolean isContactExists = false;
        List<CreditCompanyEmployee> employeesToCheckList = new List<CreditCompanyEmployee>();
        employeesToCheckList.addAll(companyEmployeesList);
        employeesToCheckList.addAll(additionalCompanyEmployeesList);
        for (CreditCompanyEmployee emp : employeesToCheckList) {
            if (emp.ename != null) {
                String empName;
                if (this.sourceObject.Account.BillingCountryCode == 'NL') {
                    empName = CreditFactoryUtilities.replaceDutchCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ');
                } else if (this.sourceObject.Account.BillingCountryCode == 'FR') {
                    empName = CreditFactoryUtilities.replaceFrenchCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ');
                } else {
                    empName = emp.ename.toUpperCase().replace('\u00a0', ' ');
                }

                for (String lastName : contactsLastNamesSet) {
                    if (empName.contains(lastName)) {
                        isContactExists = true;
                    }
                }
            }
        }

        if (this.userSource == 'E2E Long Form') {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                String firstAndLastNameClear;
                if (this.sourceObject.Account.BillingCountryCode == 'NL') {
                    firstAndLastNameClear = CreditFactoryUtilities.replaceDutchCharacters(this.company.Name).toUpperCase().replace('’', '\'');
                } else if (this.sourceObject.Account.BillingCountryCode == 'FR') {
                    firstAndLastNameClear = CreditFactoryUtilities.replaceFrenchCharacters(this.company.Name).toUpperCase().replace('’', '\'');
                } else {
                    firstAndLastNameClear = this.company.Name.toUpperCase().replace('’', '\'');
                }
                if (firstAndLastName == firstAndLastNameClear) {
                    isContactExists = true;
                }
            }
        } else if (validateCompanyName() == true) {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                String firstAndLastNameClear;
                if (this.sourceObject.Account.BillingCountryCode == 'NL') {
                    firstAndLastNameClear = CreditFactoryUtilities.replaceDutchCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'');
                } else if (this.sourceObject.Account.BillingCountryCode == 'FR') {
                    firstAndLastNameClear = CreditFactoryUtilities.replaceFrenchCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'');
                } else {
                    firstAndLastNameClear = this.company.Name.toUpperCase().replace('’', '\'');
                }
                if (firstAndLastName == firstAndLastNameClear) {
                    isContactExists = true;
                }
            }
        }

        String companyEmailDomain = '';
        if (this.company.email != null) {
            companyEmailDomain = this.company.email.substringAfterLast('@').toUpperCase();
        }

        String companyPhone = '';
        if (this.company.Phone != null && this.company.phone.length() >= 6) {
            companyPhone = this.company.phone.substring(this.company.phone.length() - 6, this.company.phone.length());
        }

        String companyMobile = '';
        if (this.company.mobile != null && this.company.mobile.length() >= 6) {
            companyMobile = this.company.mobile.substring(this.company.mobile.length() - 6, this.company.mobile.length());
        }

        String additionalCompanyPhone = '';
        if (this.additionalCompany != null && this.additionalCompany.Phone != null && this.additionalCompany.phone.length() >= 6) {
            additionalCompanyPhone = this.additionalCompany.phone.substring(this.additionalCompany.phone.length() - 6, this.additionalCompany.phone.length());
        }

        String additionalCompanyMobile = '';
        if (this.additionalCompany != null && this.additionalCompany.mobile != null && this.additionalCompany.mobile.length() >= 6) {
            additionalCompanyMobile = this.additionalCompany.mobile.substring(this.additionalCompany.mobile.length() - 6, this.additionalCompany.mobile.length());
        }

        if (errorsSet == null) errorsSet = new Set<String>(); // in case of E2E execution
        if ( ! isContactExists && ! (contactsEmailsDomainsSet.contains(companyEmailDomain) || contactsPhonesSet.contains(companyPhone) || contactsPhonesSet.contains(companyMobile) || 
                contactsPhonesSet.contains(additionalCompanyPhone) || contactsPhonesSet.contains(additionalCompanyMobile) ||
                (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') && this.sourceObject.Contact_Role_Confirmation_Call__c != null)) {
            if (this.companyEmployeesList.isEmpty() && this.additionalCompanyEmployeesList.isEmpty()) {
                errorsSet.add(CONTACT_ERROR);
                if (this.userSource != 'E2E Long Form') {
                    String errorMessage = 'No directors information for this company';
                    CreditFactoryUtilities.displayMessage('error', errorMessage);
                    if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
                        errorsSet.add(CONTACT_ROLE_ERROR);
                        CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
                    }
                }

                return false;
            } else {
                errorsSet.add(CONTACT_ERROR);
                if (this.userSource != 'E2E Long Form') {
                    String errorMessage = CreditSafeWebservice.CREDIT_SYSTEM_NAME + ' Contact person doesn\'t exist in Account\'s Contacts';
                    CreditFactoryUtilities.displayMessage('error', errorMessage);
                    if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
                        errorsSet.add(CONTACT_ROLE_ERROR);
                        CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
                    }
                }

                return false;
            }
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateTaxId()
    *  Summary         : Compare Creditsafe tax id with Salesforce    
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateTaxId() {
        if (company.taxnumber != null && ! CreditFactoryUtilities.isStringsEquals(company.taxnumber, (String)sourceObject.getSobject('Account').get(this.accountMapping.Tax_Id__c))) {
            errorsSet.add(TAX_ID_ERROR);
            String errorMessage = 'Account Tax ID mismatch (' + CreditsafeWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + TAX_ID + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateTradeRegisterNumber()
    *  Summary         : Compare Creditsafe trade register number with Salesforce    
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateTradeRegisterNumber() {
        if (company.tradeRegisterNumber != null && ! CreditFactoryUtilities.isStringsEquals(company.tradeRegisterNumber, this.sourceObject.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c)) {
            errorsSet.add(TRADE_REGISTER_NUMBER_ERROR);
            String errorMessage = 'Account Trade Register Number mismatch (' + CreditSafeWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + TRADE_REGISTER_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateVatNumber()
    *  Summary         : Compare Creditsafe tax id with Salesforce    
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateVatNumber() {
        if (company.vatid != null && ! CreditFactoryUtilities.isStringsEquals(company.vatid, (String)sourceObject.getSobject('Account').get(this.accountMapping.VAT_Number__c))) {
            errorsSet.add(VAT_NUMBER_ERROR);
            String errorMessage = 'Account VAT number mismatch (' + CreditsafeWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + VAT_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateLostOpportunities()
    *  Summary         : Check for Lost Opportunities relates to current Opportunity's 
                         Account or its Contacts    
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean validateLostOpportunities() {
        // Collect Opportunities related to Account of current opportunity
        List<Opportunity> relatedOpportunitiesList = [
                SELECT StageName, Gruende_verloren__c
                FROM Opportunity
                WHERE AccountId = :this.sourceObject.AccountId];
        List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
        for (Opportunity opportunity : relatedOpportunitiesList) {
            opportunitiesToCheckList.add(opportunity);
        }

        // Collect Opportunities related with Contacts of current Opportunity's Account
        List<AccountContactRelation> contactRelationsList = [
                SELECT ContactId
                FROM AccountContactRelation
                WHERE AccountId = :this.sourceObject.AccountId];
        Set<Id> relatedContactsIdsSet = new Set<Id>();
        for (AccountContactRelation relation : contactRelationsList) {
            relatedContactsIdsSet.add(relation.ContactId);
        }

        if (! relatedContactsIdsSet.isEmpty()) {
            List<OpportunityContactRole> contactRolesList = [
                    SELECT Opportunity.StageName, Opportunity.Gruende_verloren__c
                    FROM OpportunityContactRole
                    WHERE ContactId IN :relatedContactsIdsSet];
            for (OpportunityContactRole contactRole : contactRolesList) {
                opportunitiesToCheckList.add(contactRole.Opportunity);
            }
        }

        // Check Opportunity stage
        for (Opportunity opportunity : opportunitiesToCheckList) {
            if (opportunity.StageName == 'CreditCheck abgelehnt' || (opportunity.StageName == 'Closed Lost' && 
                opportunity.Gruende_verloren__c == 'Refused Credit')) {
                errorsSet.add(LOST_OPPORTUNITY_ERROR);
                CreditFactoryUtilities.displayMessage('error', 'Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.');
                return false;
            }
        }

        return true;
    }

    /*******************************************************************************
    *  Summary         : Check if Company is in black list.
    *  CreatedDate     : 08/06/2018
    *  Parameters      : 
    *  Returns         : validation result
    ******************************************************************************/
    public Boolean validateBlackList() {
        Map<String, Object> resultsMap = CreditFactoryUtilities.validateBlackList(this.sourceObject);
		return Boolean.valueOf(resultsMap.get('IsValid'));
    }


    /*******************************************************************************
    *  Name            : setParentCompanyId()
    *  Summary         : if only companies are the owners of current company, then set id of parent company to do new report 
    *  CreatedDate     : 3/12/2017
    *  ModifiedDate    : 24/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setParentCompanyId() {
        this.parentCompanyId = null;
        if (! this.companyEmployeesList.isEmpty()) {
            List<CreditCompanyEmployee> affiliatedCompaniesList = new List<CreditCompanyEmployee>();
            CreditCompanyEmployee ultimateParentCompany = new CreditCompanyEmployee();
            for (CreditCompanyEmployee employee : this.companyEmployeesList) {
                if (! (employee.ename.contains('B.V.') || employee.ename.contains('N.V.'))) {
                    return;
                }

                if (employee.companyType == 'Affiliated Company') {
                    affiliatedCompaniesList.add(employee);
                } else if (employee.companyType == 'Ultimate Parent') {
                    ultimateParentCompany = employee;
                }
            }

            for (CreditCompanyEmployee affiliatedCompany : affiliatedCompaniesList) {
                if (affiliatedCompany.companyId != null && affiliatedCompany.Reported != true) {
                    this.parentCompanyId = affiliatedCompany.companyId;
                    break;
                }
            }

            if (this.parentCompanyId == null) {
                if (ultimateParentCompany.companyId != null && ultimateParentCompany.Reported != true) {
                    this.parentCompanyId = ultimateParentCompany.companyId;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getParentCompanyId()
    *  Summary         : get id of parent company   
    *  CreatedDate     : 3/12/2017
    *  ModifiedDate    : 3/12/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getParentCompanyId() {
        return this.parentCompanyId;
    }


    /*******************************************************************************
    *  Name            : validateCompanyName()
    *  Summary         : Check that Account Name is the same as Company Name from Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateCompanyName() {
        if ( ! (CreditFactoryUtilities.isStringsEquals(sourceObject.Account.Name, company.Name) || 
                (this.additionalCompany != null && CreditFactoryUtilities.isStringsEquals(this.sourceObject.Account.Name, this.additionalCompany.Name)))) {
            errorsSet.add(COMPANY_NAME_ERROR);
            String errorMessage = 'Account Name and ' + CreditSafeWebservice.CREDIT_SYSTEM_NAME + ' Name mismatch';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }
        return true;
    }


    /*******************************************************************************
    *  Name            : validatePaymentMethod()
    *  Summary         : Check available for autoprocess payment method. 
    *  CreatedDate     : 25/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean validatePaymentMethod() {
        if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Banküberweisung') {
            errorsSet.add(PAYMENT_METHOD_ERROR);
            String errorMessage = 'Opportunity cannot be closed automatically with Payment Method Bank Transfer.';
            CreditFactoryUtilities.displayMessage('error', errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateEmailRisk()
    *  Summary         : Check fround risk by Email
    *  CreatedDate     : 02/05/2019
    *  ModifiedDate    : 21/11/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateEmailRisk() {
    	if ((this.company.emailRisk == 'Review' || this.company.emailRisk == 'High' || this.company.emailRisk == 'Very High') &&
				(this.company.emailExists == 'No' || this.company.domainExists == 'No' || this.company.uniqueHits != null && 
				Decimal.valueOf(this.company.uniqueHits) > 1 || String.isEmpty(this.company.domainDate) || Date.valueOf(this.company.domainDate).monthsBetween(Date.today()) > 6 ||
				this.company.dateOfFoundation == null || Date.valueOf(this.company.dateOfFoundation).monthsBetween(Date.today()) > 6)) {
    		errorsSet.add(EMAIL_RISK_ERROR);
			CreditFactoryUtilities.displayMessage('error', 'Contact Person has a high email risk. Please refer to Credit');
    		return false;
    	}

    	return true;
    }
    
    
    /*******************************************************************************
    *  Name            : validateSwiftBic()
    *  Summary         : Compare Swift Bic from sales and from web service
    *  CreatedDate     : 31/10/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateSwiftBic() {
    	if (this.sourceObject.SWIFT_BIC__c != this.sourceObject.Requested_SWIFT_BIC__c) {
    		errorsSet.add(SWIFT_BIC_ERROR);
			CreditFactoryUtilities.displayMessage('error', 'Entered BIC is invalid. Please note that your Customer will need to re- confirm SEPA form with correct bank details');
    		return false;
    	}

    	return true;
    }
    
    
    /*******************************************************************************
	*  Summary         : Check if business code is risky or not   
	*  Created         : 21/04/2020
	*  Parameters      : -
	*  Returns         : validation result
	******************************************************************************/
	public Boolean validateBusinessCode() {
		Map<String, CF_Risky_Business_Code__c> riskyCodesMap = CF_Risky_Business_Code__c.getAll();
		if (this.company.principalActivityCode != null && riskyCodesMap.containsKey(this.company.principalActivityCode.replaceAll('[^0-9]', '')) && 
				riskyCodesMap.get(this.company.principalActivityCode.replaceAll('[^0-9]', '')).Countries__c.contains(this.sourceObject.Account.BillingCountryCode)) {
			CreditFactoryUtilities.displayMessage('error', 'High risk industry. Please refer to Credit');
			return false;
		}
		
		return true;
	}


    /*******************************************************************************
    *  Name            : doUpdateAddress()
    *  Summary         : Update address information in Account based on address from CreditReform
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateAddress() {
        String crefoStreetAndHouseNumber = (this.company.street != null ? this.company.street : '') + ' ' + (this.company.housenumber != null ? this.company.housenumber : '');
        crefoStreetAndHouseNumber = crefoStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = sourceObject.AccountId,
            ShippingStreet = crefoStreetAndHouseNumber,
            ShippingPostalCode = this.company.postcode,
            ShippingCity = this.company.city,
            BillingStreet = crefoStreetAndHouseNumber,
            BillingPostalCode = this.company.postcode,
            BillingCity = this.company.city);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Address has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Address update failed.'); 
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateWithAdditionalAddress()
    *  Summary         : Update address information in Account based on address from additional report    
    *  CreatedDate     : 20/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithAdditionalAddress() {
        String creditCompanyAdditionalStreetAndHouseNumber = (this.additionalCompany.street != null ? this.additionalCompany.street : '') + ' ' + 
            (this.additionalCompany.housenumber != null ? this.additionalCompany.housenumber : '');
        creditCompanyAdditionalStreetAndHouseNumber = creditCompanyAdditionalStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = this.sourceObject.AccountId,
            ShippingStreet = creditCompanyAdditionalStreetAndHouseNumber,
            ShippingPostalCode = this.additionalCompany.postcode,
            ShippingCity = this.additionalCompany.city,
            BillingStreet = creditCompanyAdditionalStreetAndHouseNumber,
            BillingPostalCode = this.additionalCompany.postcode,
            BillingCity = this.additionalCompany.city);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Address has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Address update failed.'); 
        }

        setSourceObject(this.sourceObject.Id);
    }


    public void doUpdateWithPostalAddress() {}


    public void doUpdateWithRegisteredAddress() {}


    /*******************************************************************************
    *  Name            : doUpdateCompanyName(String nameType)
    *  Summary         : Update Account name with Creditsafe Company Name
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 27/09/2019
	*  Parameters      : String nameType - type of company name (registered, trading)
    *  Returns         : voiddoUpdateCompanyName
    ******************************************************************************/
    public void doUpdateCompanyName(String nameType) {
        String nameToUpdate;
        if (nameType == 'Registered Name') {
            nameToUpdate = company.name;
        }
        else if (nameType == 'Trade Name') {
            nameToUpdate = company.tradename;
        }

        Account account = new Account(
            Id = sourceObject.AccountId,
            Name = nameToUpdate);

        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Name has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Account Name update failed.');    
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateWithAdditionalCompanyName()
    *  Summary         : Update Account name with Credireform Company Name
    *  CreatedDate     : 23/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithAdditionalCompanyName() {
        Account account = new Account(
            Id = this.sourceObject.AccountId,
            Name = this.additionalCompany.name);

        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Name has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Account Name update failed.');    
        }

        setSourceObject(this.sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateTaxId()
    *  Summary         : Update Account Tax Id with Creditsafe Tax Id
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTaxId() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Steuernummer__c = this.company.taxnumber);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Tax ID has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            if (e.getMessage().contains('duplicate value found: ')) {
                String duplicateValueError = e.getMessage().substringAfter('duplicate value found: ').substringBeforeLast(':');
                CreditFactoryUtilities.displayMessage('error', duplicateValueError);
            }
            throw new CreditFactoryException('Account Tax ID update failed.');  
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateVatNumber()
    *  Summary         : Update Account Vat Number with Creditsafe Vat Number
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateVatNumber() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Umsatzsteuer_ID__c = this.company.vatid);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account VAT number has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            if (e.getMessage().contains('duplicate value found: ')) {
                String duplicateValueError = e.getMessage().substringAfter('duplicate value found: ').substringBeforeLast(':');
                CreditFactoryUtilities.displayMessage('error', duplicateValueError);
            }
            throw new CreditFactoryException('Account VAT number update failed.');  
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateTradeRegisterNumber()
    *  Summary         : Update Account Trade Register Number with Creditsafe Trade Register Number
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTradeRegisterNumber() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = this.company.tradeRegisterNumber);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Trade Register Number has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Account Trade Register Number update failed.');   
        }

        setSourceObject(sourceObject.Id);
    }
    
    
    /*******************************************************************************
	*  Name            : doUpdateSwiftBic()
	*  Summary         : Update Opportunity SWIFT BIC with web service one
	*  CreatedDate     : 31/10/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public void doUpdateSwiftBic() {
		Opportunity opportunity = new Opportunity(
			Id = this.sourceObject.Id,
			SWIFT_BIC__c = this.sourceObject.Requested_SWIFT_BIC__c 
		);
    	try {
    		update opportunity;
    		CreditFactoryUtilities.displayMessage('confirm','Opportunity SWIFT BIC has been updated.');
    	} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Opportunity SWIFT BIC update failed.');	
    	}

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : updateDefaultFieldSetForRecord()
    *  Summary         : Update specific fields in Opportunity by Sales when all validations passed
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 15/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateDefaultFieldSetForValidRecord() {
        try {
            this.sourceObject.Updated_From_Credit_Factory__c = true;
            if (this.company.classRating != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Rating__c,
                    CreditFactoryUtilities.returnArabic(this.company.classRating));
            }
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Limit__c,
                    Decimal.valueOf(this.company.creditLimit));
            } else {
                this.sourceObject.put(this.opportunityMapping.Credit_System_Limit__c, 0);
            }
            if (this.company.turnOver != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Turn_Over__c, 
                    this.company.turnOver);
            }
            if (this.company.dateoffoundation != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Year_of_foundation__c,
                    this.company.dateoffoundation.substring(0, 4));
            } else if (this.additionalCompany.dateoffoundation != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Year_of_foundation__c,
                    this.additionalCompany.dateoffoundation.substring(0, 4));
            } 
            if (this.company.creditSystemCompanyNumber != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Number__c,
                    this.company.creditSystemCompanyNumber);
            } else if (this.additionalCompany.creditSystemCompanyNumber != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Number__c,
                    this.additionalCompany.creditSystemCompanyNumber);
            }
            if (this.company.staffcompanyrange != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Number_of_employees__c,
                    this.company.staffcompanyrange);
            } else if (this.additionalCompany.staffcompanyrange != null) {
                this.sourceobject.put(
                    this.opportunityMapping.Number_of_employees__c,
                    this.additionalCompany.staffcompanyrange);
            }
            this.sourceObject.put(
                this.opportunityMapping.Details_Correct__c,
                'Ja');
            if (this.sourceObject.CF_Stage__c != 'Pending Deposit') {
                this.sourceObject.CF_Stage__c = 'Report generated';
            }
            if (this.company.solvencyIndex != null && this.company.solvencyIndex.length() <= 3) {
                this.sourceObject.Bonitaetsindex__c = this.company.solvencyIndex;
            }
            this.sourceObject.Last_CF_Errors__c = null;
            if (! Test.isRunningTest()) {
                update this.sourceObject;
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : updateDefaultFieldSetForRecord()
    *  Summary         : Update specific fields in SF with or without validation errors
    *  CreatedDate     : 30/01/2019
    *  ModifiedDate    : 01/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateDefaultFieldSetForRecord() {
        try {
            setRiskCategory(this.company.classRating);
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
            if (this.company.parentCompanyId != null) this.sourceObject.Risk_Category_Begruendung__c = 'Parent company used for the scoring based on ' + 
                (this.company.providerDescription == BRANCH ? 'branch' : '') + (this.company.providerDescription == STATEMENT_403 ? '403 statement' : '');
            if (! Test.isRunningTest()) {
                update this.sourceObject;
            }

            if (this.company.principalActivityCode != null) {
                this.sourceObject.Account.Branchencode__c = this.company.principalActivityCode;
            } 
            if (this.company.principalACtivityDescription != null) {
                this.sourceObject.Account.Branchentext__c = this.company.principalACtivityDescription;
            }

            if (! Test.isRunningTest()) {
                update this.sourceObject.Account;
            }
        } catch (Exception e) {
             System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
	*  Summary         : Set fuel price index for Germany
	*  CreatedDate     : 24/02/2020
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
	public void setFuelPriceIndex() {
        Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(this.sourceObject.Account.BillingCountry);
		this.fuelPriceIndex = fuelPrice.Index__c;
	}


    /*******************************************************************************
    *  Name            : getBuffer()
    *  Summary         : Return buffer value
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : String
    ******************************************************************************/
    public Decimal getBuffer() {
        return this.buffer;
    }


    /*******************************************************************************
    *  Name            : setBuffer(String classRating)
    *  Summary         : Calculate buffer
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 03/06/2019
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setBuffer(String classRating) {
        if (this.company.name == null) {
            this.buffer = 0.1;
        } else if (classRating != null) {
            if (classRating == '1') {
                this.buffer = 0.3;
            } else if (classRating == '2') {
                this.buffer = 0.2;
            } else if (classRating == '3' || classRating == '4') {
                this.buffer = 0.1;
            } else if (classRating == '5') {
                this.buffer = 0;
            }
        }
    }


    /*******************************************************************************
    *  Name            : getRiskCategory()
    *  Summary         : Return Risk Category
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : String
    ******************************************************************************/
    public String getRiskCategory() {
        return this.riskCategory;
    }


    /*******************************************************************************
    *  Name            : setRiskCategory(String classRating)
    *  Summary         : Calculate Risk Category
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 03/06/2019
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setRiskCategory(String classRating) {
        if (this.company.name == null) {
            this.riskCategory = 'High';
        } else if (classRating != null) {
            if (classRating == '1') {
                this.riskCategory = 'Low';
            } else if (classRating == '2') {
                this.riskCategory = 'Medium';
            } else if (classRating == '3' || classRating == '4') {
                this.riskCategory = 'High';
            } else if (classRating == '5') {
                this.riskCategory = 'Very';
            }
        }   
    }


    /*******************************************************************************
    *  Name            : getSecurityLevel()
    *  Summary         : Return security level
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 28/03/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public Decimal getSecurityLevel() {
        return this.securityLevel;
    }


    public void setSecurityLevel(String classRating) {}


    /*******************************************************************************
    *  Name            : getCreditLimitWeeklyPlus7()
    *  Summary         : Return Credit Limit Weekly Plus 7
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimitWeeklyPlus7() {
        if (this.creditLimitWeeklyPlus7 < 50) {
            this.creditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 + 50;
        }

        return (this.creditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Name            : setCreditLimitWeeklyPlus7(Decimal buffer)
    *  Summary         : Calculate Credit Limit Weekly Plus 7
    *  CreatedDate     : 2/11/2016
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : void
    ******************************************************************************/
    public void setCreditLimitWeeklyPlus7(Decimal buffer) {
        try {
            this.creditLimitWeeklyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
                ((7.0 + 7.0)/30.0)*(1.0 + buffer)).setScale(2);
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxCreditLimitWeeklyPlus7()
    *  Summary         : Return Max Credit Limit Weekly Plus 7
    *  CreatedDate     : 14/03/2018
    *  ModifiedDate    : 03/06/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxCreditLimitWeeklyPlus7() {
        if (this.maxCreditLimitWeeklyPlus7 != null) {
            this.maxCreditLimitWeeklyPlus7 = (this.maxCreditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
        }
        return this.maxCreditLimitWeeklyPlus7;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7    
    *  CreatedDate     : 14/03/2018
    *  ModifiedDate    : 03/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxCreditLimitWeeklyPlus7() {
        try {
            if (this.company.name != null) {
                if (this.company.classRating == '1') {
                    setMaxCreditLimitWeeklyPlus7Rating1();
                } else if (this.company.classRating == '2') {
                    setMaxCreditLimitWeeklyPlus7Rating2();
                } else if (this.company.classRating == '3') {
                    setMaxCreditLimitWeeklyPlus7Rating3();
                } else if (this.company.classRating == '4') {
                    setMaxCreditLimitWeeklyPlus7Rating4();
                } else if (this.company.classRating == '5') {
                    setMaxCreditLimitWeeklyPlus7Rating5();
                } 
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 1  
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating1() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
				}
            }
            else if (this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit450WeeklyPlus7 = (450 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit450WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit450WeeklyPlus7;
				}
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else if (this.creditLimitWeeklyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
        } else if (this.creditLimitWeeklyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitWeeklyPlus7 = fixedMaxCreditLimit;
        } else if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
            if (this.creditLimitWeeklyPlus7 * 2 < 6000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxCreditLimitWeeklyPlus7 = 6000;
            }
        } else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
            } else {
                this.maxCreditLimitWeeklyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 2 
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating2() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }


        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
				}
            }
            else if (this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit450WeeklyPlus7 = (450 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit450WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit450WeeklyPlus7;
				}
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else if (this.creditLimitWeeklyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
        } else if (this.creditLimitWeeklyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitWeeklyPlus7 = fixedMaxCreditLimit;
        } else if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
            if (this.creditLimitWeeklyPlus7 * 2 < 6000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxCreditLimitWeeklyPlus7 = 6000;
            }
        } else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
            } else {
                this.maxCreditLimitWeeklyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 3  
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating3() {
        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } 
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Decimal fixedMaxCreditLimist = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimist = 1000;
        }

        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
        
        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        } 
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
				}
            }
            else if (this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit450WeeklyPlus7 = (450 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit450WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit450WeeklyPlus7;
				}
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        } 
        else if (this.creditLimitWeeklyPlus7 * 2 <= fixedMaxCreditLimist) {
            this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
        } 
        else if (this.creditLimitWeeklyPlus7 <= fixedMaxCreditLimist) {
            this.maxCreditLimitWeeklyPlus7 = fixedMaxCreditLimist;
        } 
        else if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
            if (this.creditLimitWeeklyPlus7 * 2 < 6000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } 
            else {
                this.maxCreditLimitWeeklyPlus7 = 6000;
            }
        } 
        else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
            } 
            else {
                this.maxCreditLimitWeeklyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 4  
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating4() {
        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        }
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
				}
            }
            else if (this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit450WeeklyPlus7 = (450 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit450WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				}
				else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit450WeeklyPlus7;
				}
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7Rating5()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 5
    *  CreatedDate     : 30/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating5() {
        this.maxCreditLimitWeeklyPlus7 = 0;
    }


    /*******************************************************************************
    *  Name            : getMaxValueWeeklyPlus7()
    *  Summary         : Return Max value of Credit Limit including deposit Weekly Plus 7    
    *  CreatedDate     : 31/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValueWeeklyPlus7() {
        return (this.maxValueWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Name            : setMaxValueWeeklyPlus7()
    *  Summary         : Calculate Max value of Credit Limit including deposit Weekly Plus 7    
    *  CreatedDate     : 31/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxValueWeeklyPlus7() {
        try {
            if (this.creditLimitWeeklyPlus7 * 2 < 6000) {
                this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxValueWeeklyPlus7 = 6000;
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getDepositWeeklyPlus7()
    *  Summary         : Return Deposit Weekly Plus 7
    *  CreatedDate     : 31/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getDepositWeeklyPlus7() {
        if (this.depositWeeklyPlus7 > 0 && this.depositWeeklyPlus7 < 50) {
            this.depositWeeklyPlus7 = this.depositWeeklyPlus7 + 50;
        }

        return (this.depositWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7()
    *  Summary         : Calculate Deposit Weekly Plus 7    
    *  CreatedDate     : 31/05/2018
    *  ModifiedDate    : 03/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDepositWeeklyPlus7() {
        try {
            if (this.company.name == null) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else if (this.company.classRating == '1') {
                setDepositWeeklyPlus7Rating1();
            } else if (this.company.classRating == '2') {
                setDepositWeeklyPlus7Rating2();
            } else if (this.company.classRating == '3') {
                setDepositWeeklyPlus7Rating3();
            } else if (this.company.classRating == '4') {
                setDepositWeeklyPlus7Rating4();
            } else if (this.company.classRating == '5') {
                setDepositWeeklyPlus7Rating5();
            } 
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 1    
    *  CreatedDate     : 31/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating1() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600) || this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450) && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
				this.depositWeeklyPlus7 = 0;
			}
			else {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			}
        }
        else if (this.creditLimitWeeklyPlus7 > this.maxCreditLimitWeeklyPlus7) {
            if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 3;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        } else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 2
    *  CreatedDate     : 31/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating2() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600) || this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450) && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
				this.depositWeeklyPlus7 = 0;
			}
			else {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			}
        }
        else if (soleTradersSet.contains(this.company.legalform) && this.sourceObject.Account.BillingCountry == 'France' &&
                (this.company.dateoffoundation == null || Integer.valueOf(this.company.dateoffoundation.substring(0, 4)) > Date.today().year() - 2)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
            this.securityLevelWeeklyPlus7 = 50;
        } else if (this.creditLimitWeeklyPlus7 > this.maxCreditLimitWeeklyPlus7) {
            if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 3;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
               this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
               this.securityLevelWeeklyPlus7 = 100;
            } else {
               this.depositWeeklyPlus7 = 0;
            }
        } else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 3
    *  CreatedDate     : 31/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating3() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } 
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600) || this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450) && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
				this.depositWeeklyPlus7 = 0;
			}
			else {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			}
        }
        else if (soleTradersSet.contains(this.company.legalform) && this.sourceObject.Account.BillingCountry == 'France') {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.7;
            this.securityLevelWeeklyPlus7 = 70;
        }
        else if (this.creditLimitWeeklyPlus7 > this.maxCreditLimitWeeklyPlus7) {
           if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 3;
           } 
           else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
               this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
               this.securityLevelWeeklyPlus7 = 100;
           } 
           else {
               this.depositWeeklyPlus7 = 0;
           }
       } 
        else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } 
            else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 31/05/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating4() {
        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        }
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((((this.sourceObject.Account.BillingCountry == 'Belgium-NL' || this.sourceObject.Account.BillingCountry == 'Belgium-FR') &&
                    this.sourceObject.Total_consumption_l_month__c <= 600) || this.sourceObject.Account.BillingCountry == 'Netherlands' &&
                    this.sourceObject.Total_consumption_l_month__c <= 450) && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
				this.depositWeeklyPlus7 = 0;
			}
			else {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			}
        }
        else {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7Rating5()
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 5
    *  CreatedDate     : 31/05/2018
    *  ModifiedDate    : 16/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating5() {
        this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * (7.0 + 7.0 + 10.0) / (7.0 + 7.0);
        this.securityLevelWeeklyPlus7 = 110;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Credit Limit Bi-Weekly Plus 7
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : CL 15+7
    ******************************************************************************/
    public Decimal getCreditLimitBiWeeklyPlus7() {
        if (this.creditLimitBiWeeklyPlus7 < 50) {
            this.creditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 + 50;
        }

        return (this.creditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Credit Limit Bi-Weekly Plus 7
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : -
    ******************************************************************************/
    public void setCreditLimitBiWeeklyPlus7(Decimal buffer) {
        try {
            this.creditLimitBiWeeklyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
                ((15.0 + 7.0)/30.0) * (1.0 + buffer)).setScale(2);
        } 
        catch (Exception e) {
            throw new CreditFactoryException('Credit Limit Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Max Credit Limit Bi-Weekly Plus 7
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max CL 15+7
    ******************************************************************************/
    public Decimal getMaxCreditLimitBiWeeklyPlus7() {
        if (this.maxCreditLimitBiWeeklyPlus7 != null) {
            this.maxCreditLimitBiWeeklyPlus7 = (this.maxCreditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
        }
        return this.maxCreditLimitBiWeeklyPlus7;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7    
    *  CreatedDate     : 04/06/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimitBiWeeklyPlus7() {
        try {
            if (this.company.name != null) {
                if (this.company.classRating == '1') {
                    setMaxCreditLimitBiWeeklyPlus7Rating1();
                } else if (this.company.classRating == '2') {
                    setMaxCreditLimitBiWeeklyPlus7Rating2();
                } else if (this.company.classRating == '3') {
                    setMaxCreditLimitBiWeeklyPlus7Rating3();
                } else if (this.company.classRating == '4') {
                    setMaxCreditLimitBiWeeklyPlus7Rating4();
                } else if (this.company.classRating == '5') {
                    setMaxCreditLimitBiWeeklyPlus7Rating5();
                } 
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Credit Limit Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 1  
    *  CreatedDate     : 04/06/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating1() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        } else if (this.creditLimitBiWeeklyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
        } else if (this.creditLimitBiWeeklyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitBiWeeklyPlus7 = fixedMaxCreditLimit;
        } else if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
            if (this.creditLimitBiWeeklyPlus7 * 2 < 6000) {
                this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
            } else {
                this.maxCreditLimitBiWeeklyPlus7 = 6000;
            }
        } else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
            } else {
                this.maxCreditLimitBiWeeklyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 2 
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating2() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }


        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        } else if (this.creditLimitBiWeeklyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
        } else if (this.creditLimitBiWeeklyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitBiWeeklyPlus7 = fixedMaxCreditLimit;
        } else if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
            if (this.creditLimitBiWeeklyPlus7 * 2 < 6000) {
                this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
            } else {
                this.maxCreditLimitBiWeeklyPlus7 = 6000;
            }
        } else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
            } else {
                this.maxCreditLimitBiWeeklyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 3  
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating3() {
        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } 
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Decimal fixedMaxCreditLimist = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimist = 1000;
        }

        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
        
        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        } 
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        } 
        else if (this.creditLimitBiWeeklyPlus7 * 2 <= fixedMaxCreditLimist) {
            this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
        } 
        else if (this.creditLimitBiWeeklyPlus7 <= fixedMaxCreditLimist) {
            this.maxCreditLimitBiWeeklyPlus7 = fixedMaxCreditLimist;
        } 
        else if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
            if (this.creditLimitBiWeeklyPlus7 * 2 < 6000) {
                this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
            } 
            else {
                this.maxCreditLimitBiWeeklyPlus7 = 6000;
            }
        } 
        else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
            } 
            else {
                this.maxCreditLimitBiWeeklyPlus7 = 6000;
            }
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 4  
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating4() {
        this.maxCreditLimitBiWeeklyPlus7 = 0;
    }


    /******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 5
    *  CreatedDate     : 04/06/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating5() {
        this.maxCreditLimitBiWeeklyPlus7 = 0;
    }



    /*******************************************************************************
    *  Summary         : Return Max value of Credit Limit Bi-Weekly Plus 7 (slider)    
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max CL 7+7
    ******************************************************************************/
    public Decimal getMaxValueBiWeeklyPlus7() {
        return (this.maxValueBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit including deposit Bi-Weekly Plus 7    
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValueBiWeeklyPlus7() {
        try {
            if (this.creditLimitBiWeeklyPlus7 * 2 < 6000) {
                this.maxValueBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
            } else {
                this.maxValueBiWeeklyPlus7 = 6000;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Value Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Deposit Bi-Weekly Plus 7
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : deposit 7+7
    ******************************************************************************/
    public Decimal getDepositBiWeeklyPlus7() {
        if (this.depositBiWeeklyPlus7 > 0 && this.depositBiWeeklyPlus7 < 50) {
            this.depositBiWeeklyPlus7 = this.depositBiWeeklyPlus7 + 50;
        }

        return (this.depositBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7    
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDepositBiWeeklyPlus7() {
        try {
            if (this.company.name == null) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            } else if (this.company.classRating == '1') {
                setDepositBiWeeklyPlus7Rating1();
            } else if (this.company.classRating == '2') {
                setDepositBiWeeklyPlus7Rating2();
            } else if (this.company.classRating == '3') {
                setDepositBiWeeklyPlus7Rating3();
            } else if (this.company.classRating == '4') {
                setDepositBiWeeklyPlus7Rating4();
            } else if (this.company.classRating == '5') {
                setDepositBiWeeklyPlus7Rating5();
            } 
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 1    
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating1() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)), 
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        } else if (this.creditLimitBiWeeklyPlus7 > this.maxCreditLimitBiWeeklyPlus7) {
            if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 3;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            } else {
                this.depositBiWeeklyPlus7 = 0;
            }
        } else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            } else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 2
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating2() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

       if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
       } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
           this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
           this.securityLevelBiWeeklyPlus7 = 100;
       } else if (soleTradersSet.contains(this.company.legalform) && this.sourceObject.Account.BillingCountry == 'France' &&
                (this.company.dateoffoundation == null || Integer.valueOf(this.company.dateoffoundation.substring(0, 4)) > Date.today().year() - 2)) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
            this.securityLevelBiWeeklyPlus7 = 50;
       } else if (this.creditLimitBiWeeklyPlus7 > this.maxCreditLimitBiWeeklyPlus7) {
           if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 3;
           } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
               this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
               this.securityLevelBiWeeklyPlus7 = 100;
           } else {
               this.depositBiWeeklyPlus7 = 0;
           }
       } else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            } else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 3
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating3() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } 
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        }
        else if (soleTradersSet.contains(this.company.legalform) && this.sourceObject.Account.BillingCountry == 'France') {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.7;
            this.securityLevelBiWeeklyPlus7 = 70;
        }
        else if (this.creditLimitBiWeeklyPlus7 > this.maxCreditLimitWeeklyPlus7) {
           if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 3;
           } 
           else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
               this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
               this.securityLevelBiWeeklyPlus7 = 100;
           } 
           else {
               this.depositBiWeeklyPlus7 = 0;
           }
       } 
        else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            } 
            else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 4
    *  CreatedDate     : 04/06/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating4() {
        this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
        this.securityLevelBiWeeklyPlus7 = 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 5
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating5() {
        this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * (15.0 + 7.0 + 10.0) / (15.0 + 7.0);
        this.securityLevelBiWeeklyPlus7 = 110;
    }


    public Decimal getCreditLimitBiWeeklyPlus14() {
        return null;
    }

    public void setCreditLimitBiWeeklyPlus14(Decimal buffer) {}


    public Decimal getMaxCreditLimitBiWeeklyPlus14() {
        return null;
    }


    public void setMaxCreditLimitBiWeeklyPlus14() {}


    public Decimal getDepositBiWeeklyPlus14() {
        return null;
    }


    public void setDepositBiWeeklyPlus14() {}


    public Decimal getMaxValueBiWeeklyPlus14() {
        return null;
    }


    public void setMaxValueBiWeeklyPlus14() {}


    /*******************************************************************************
    *  Summary         : Return Credit Limit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      :
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimitMonthlyPlus7() {
        if (this.creditLimitMonthlyPlus7 < 50) {
            this.creditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 + 50;
        }

        return (this.creditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    * Summary         : Return Credit Limit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : -
    ******************************************************************************/
    public void setCreditLimitMonthlyPlus7(Decimal buffer) {
        try {
            this.creditLimitMonthlyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) *
                ((30.0 + 7.0)/30.0)*(1.0 + buffer)).setScale(2);
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Max Credit Limit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max CL 30+7
    ******************************************************************************/
    public Decimal getMaxCreditLimitMonthlyPlus7() {
        if (this.maxCreditLimitMonthlyPlus7 != null) {
            this.maxCreditLimitMonthlyPlus7 = (this.maxCreditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
        }

        return this.maxCreditLimitMonthlyPlus7;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimitMonthlyPlus7() {
        try {
            if (this.company.name != null) {
                if (this.company.classRating == '1') {
                    setMaxCreditLimitMonthlyPlus7Rating1();
                } else if (this.company.classRating == '2') {
                    setMaxCreditLimitMonthlyPlus7Rating2();
                } else if (this.company.classRating == '3') {
                    setMaxCreditLimitMonthlyPlus7Rating3();
                } else if (this.company.classRating == '4') {
                    setMaxCreditLimitMonthlyPlus7Rating4();
                } else if (this.company.classRating == '5') {
                    setMaxCreditLimitMonthlyPlus7Rating5();
                }
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 1
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating1() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        } else if (this.creditLimitMonthlyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
        } else if (this.creditLimitMonthlyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitMonthlyPlus7 = fixedMaxCreditLimit;
        } else if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
            if (this.creditLimitMonthlyPlus7 * 2 < 6000) {
                this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
            } else {
                this.maxCreditLimitMonthlyPlus7 = 6000;
            }
        } else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
            } else {
                this.maxCreditLimitMonthlyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 2
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating2() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }


        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        } else if (this.creditLimitMonthlyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
        } else if (this.creditLimitMonthlyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitMonthlyPlus7 = fixedMaxCreditLimit;
        } else if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
            if (this.creditLimitMonthlyPlus7 * 2 < 6000) {
                this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
            } else {
                this.maxCreditLimitMonthlyPlus7 = 6000;
            }
        } else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
            } else {
                this.maxCreditLimitMonthlyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 3
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating3() {
        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        }
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Decimal fixedMaxCreditLimit = 0;
        if (this.sourceObject.Account.BillingCountryCode == 'FR') {
            fixedMaxCreditLimit = 1000;
        }

        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else if (this.creditLimitMonthlyPlus7 * 2 <= fixedMaxCreditLimit) {
            this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
        }
        else if (this.creditLimitMonthlyPlus7 <= fixedMaxCreditLimit) {
            this.maxCreditLimitMonthlyPlus7 = fixedMaxCreditLimit;
        }
        else if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
            if (this.creditLimitMonthlyPlus7 * 2 < 6000) {
                this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
            }
            else {
                this.maxCreditLimitMonthlyPlus7 = 6000;
            }
        }
        else {
            if (recommendedCreditLimit + 500 < 6000) {
                this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
            }
            else {
                this.maxCreditLimitMonthlyPlus7 = 6000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 4
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating4() {
        this.maxCreditLimitMonthlyPlus7 = 0;
    }


    /******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 5
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating5() {
        this.maxCreditLimitMonthlyPlus7 = 0;
    }


    /*******************************************************************************
    *  Summary         : Return Max value of Credit Limit Monthly Plus 7 (slider)
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max CL 30+7
    ******************************************************************************/
    public Decimal getMaxValueMonthlyPlus7() {
        return (this.maxValueMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit including deposit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValueMonthlyPlus7() {
        try {
            if (this.creditLimitMonthlyPlus7 * 2 < 6000) {
                this.maxValueMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
            } else {
                this.maxValueMonthlyPlus7 = 6000;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Value Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Deposit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : deposit 30+7
    ******************************************************************************/
    public Decimal getDepositMonthlyPlus7() {
        if (this.depositMonthlyPlus7 > 0 && this.depositMonthlyPlus7 < 50) {
            this.depositMonthlyPlus7 = this.depositMonthlyPlus7 + 50;
        }

        return (this.depositMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDepositMonthlyPlus7() {
        try {
            if (this.company.name == null) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            } else if (this.company.classRating == '1') {
                setDepositMonthlyPlus7Rating1();
            } else if (this.company.classRating == '2') {
                setDepositMonthlyPlus7Rating2();
            } else if (this.company.classRating == '3') {
                setDepositMonthlyPlus7Rating3();
            } else if (this.company.classRating == '4') {
                setDepositMonthlyPlus7Rating4();
            } else if (this.company.classRating == '5') {
                setDepositMonthlyPlus7Rating5();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 1
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating1() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        } else if (this.creditLimitMonthlyPlus7 > this.maxCreditLimitMonthlyPlus7) {
            if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 3;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            } else {
                this.depositMonthlyPlus7 = 0;
            }
        } else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            } else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 2
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating2() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        } else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

       if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
       } else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
           this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
           this.securityLevelMonthlyPlus7 = 100;
       } else if (soleTradersSet.contains(this.company.legalform) && this.sourceObject.Account.BillingCountry == 'France' &&
                (this.company.dateoffoundation == null || Integer.valueOf(this.company.dateoffoundation.substring(0, 4)) > Date.today().year() - 2)) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 0.5;
            this.securityLevelMonthlyPlus7 = 50;
       } else if (this.creditLimitMonthlyPlus7 > this.maxCreditLimitMonthlyPlus7) {
           if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 3;
           } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
               this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
               this.securityLevelMonthlyPlus7 = 100;
           } else {
               this.depositMonthlyPlus7 = 0;
           }
       } else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            } else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 3
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating3() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }

        Date dateOfFoundation;
        if (this.company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
        }
        else if (this.additionalCompany.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(this.company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(this.company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                this.company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        }
        else if (soleTradersSet.contains(this.company.legalform) && this.sourceObject.Account.BillingCountry == 'France') {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 0.7;
            this.securityLevelMonthlyPlus7 = 70;
        }
        else if (this.creditLimitMonthlyPlus7 > this.maxCreditLimitMonthlyPlus7) {
           if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 3;
           }
           else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
               this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
               this.securityLevelMonthlyPlus7 = 100;
           }
           else {
               this.depositMonthlyPlus7 = 0;
           }
       }
        else {
            if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            }
            else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 4
    *  CreatedDate     : 24/08/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating4() {
        this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
        this.securityLevelMonthlyPlus7 = 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 5
    *  CreatedDate     : 24/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating5() {
        this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7 * (30.0 + 7.0 + 10.0) / (30.0 + 7.0);
        this.securityLevelMonthlyPlus7 = 110;
    }


    public Decimal getCreditLimitMonthlyPlus14() {
        return null;
    }


    public void setCreditLimitMonthlyPlus14(Decimal buffer) {}
    

    public Decimal getMaxCreditLimitMonthlyPlus14() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus14() {}


    public Decimal getMaxValueMonthlyPlus14() {
		return null;
	}


	public void setMaxValueMonthlyPlus14() {}


    public Decimal getDepositMonthlyPlus14() {
        return null;
    }


    public void setDepositMonthlyPlus14() {}


    public Decimal getCreditLimitMonthlyPlus21() {
        return null;
    }


    public void setCreditLimitMonthlyPlus21(Decimal buffer) {}


    public Decimal getMaxCreditLimitMonthlyPlus21() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus21() {}


    public Decimal getDepositMonthlyPlus21() {
        return null;
    }


    public void setDepositMonthlyPlus21() {}


    public Decimal getCreditLimitMonthlyPlus27() {
        return null;
    }


    public void setCreditLimitMonthlyPlus27(Decimal buffer) {}


    public Decimal getMaxCreditLimitMonthlyPlus27() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus27() {}


    public Decimal getMaxValueMonthlyPlus27() {
        return null;
    }


    public void setMaxValueMonthlyPlus27() {}


    public Decimal getDepositMonthlyPlus27() {
        return null;
    }


    public void setDepositMonthlyPlus27() {}


    /*******************************************************************************
    *  Summary         : Calculate payment details such as billing period, payment terms and max credit limit  
    *  CreatedDate     : 16/03/2018 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setPaymentDetails() {
        try {
            if ((this.sourceObject.Account.BillingCountry == 'Belgium-FR' || this.sourceObject.Account.BillingCountry == 'Belgium-NL') &&
                    this.company.classRating == '1' && this.creditLimitMonthlyPlus7 < 8000 && this.depositMonthlyPlus7 == 0) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                }
                else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 15;
                    this.paymentTerms = 7;
                }
                else {
                    this.billingPeriod = 30;
                    this.paymentTerms = 7;
                }
            }
            else if ((this.sourceObject.Account.BillingCountry == 'Belgium-FR' || this.sourceObject.Account.BillingCountry == 'Belgium-NL') &&
                    this.creditLimitBiWeeklyPlus7 < 8000 && this.depositBiWeeklyPlus7 == 0) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
					this.billingPeriod = 7;
					this.paymentTerms = 7;
				} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	}
            } 
			else if (this.creditLimitWeeklyPlus7 < 8000 && this.depositWeeklyPlus7 == 0) {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            }
            else if ((this.sourceObject.Account.BillingCountry == 'Belgium-FR' || this.sourceObject.Account.BillingCountry == 'Belgium-NL') &&
                    this.company.classRating == '1' && this.creditLimitMonthlyPlus7 < 8000) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                }
                else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 15;
                    this.paymentTerms = 7;
                }
                else {
                    this.billingPeriod = 30;
                    this.paymentTerms = 7;
                }
            }
			else if ((this.sourceObject.Account.BillingCountry == 'Belgium-FR' || this.sourceObject.Account.BillingCountry == 'Belgium-NL') && 
                    this.creditLimitBiWeeklyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
					this.billingPeriod = 7;
					this.paymentTerms = 7;
				} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	}
            } 
			else if (this.creditLimitWeeklyPlus7 < 8000) {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            }
		} catch (Exception e) {
            throw new CreditFactoryException('Payment Details calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
    }


    /*******************************************************************************
    *  Name            : getBillingPeriod
    *  Summary         : Return billing period
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Integer
    ******************************************************************************/
    public Integer getBillingPeriod() {
        return this.billingPeriod;
    }


    /*******************************************************************************
    *  Name            : getPaymentTerms()
    *  Summary         : Return payment terms.  
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 22/03/2018
    *  Parameters      : -
    *  Returns         : Integer
    ******************************************************************************/
    public Integer getPaymentTerms() {
        return this.paymentTerms;
    }


    /*******************************************************************************
    *  Summary         : Calculate Credit Limit    
    *  CreatedDate     : 03/04/2018 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setCreditLimit() {
        try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
                this.creditLimit = getCreditLimitMonthlyPlus7();
            }
            else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
                this.creditLimit = getCreditLimitBiWeeklyPlus7();
            }
            else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.creditLimit = getCreditLimitWeeklyPlus7();
            }


            if (this.creditLimit != null) {
                Decimal recommendedCreditLimit = 0;
                if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                    recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
                }
                if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimit) {
                    this.creditLimit = (this.creditLimit * 1.5 / 100).round(System.RoundingMode.HALF_UP) * 100;
                }
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getCreditLimit()
    *  Summary         : Return Credit Limit    
    *  CreatedDate     : 03/04/2018
    *  ModifiedDate    : 03/04/2018
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimit() {
        return this.creditLimit;
    }


    /*******************************************************************************
    *  Summary         : Calculate max credit limit    
    *  CreatedDate     : 07/03/2018 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimit() {
        try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
                this.maxCreditLimit = getMaxCreditLimitMonthlyPlus7();
            }
            else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
                this.maxCreditLimit = getMaxCreditLimitBiWeeklyPlus7();
            } 
            else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.maxCreditLimit = getMaxCreditLimitWeeklyPlus7();
            }

        } catch (Exception e) {
            throw new CreditFactoryException('Max Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxCreditLimit()
    *  Summary         : Return max credit limit.
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 22/03/2018 
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxCreditLimit() {
        return this.maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit including deposit    
    *  CreatedDate     : 04/06/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValue() {
        try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
                this.maxValue = getMaxValueMonthlyPlus7();
            }
            else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
                this.maxValue = getMaxValueBiWeeklyPlus7();
            } 
            else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.maxValue = getMaxValueWeeklyPlus7();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max value calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN); 
        }
    }


    /*******************************************************************************
    *  Name            : getMaxValue()
    *  Summary         : Return Max value of Credit Limit including deposit
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValue() {
        return this.maxValue;
    }


    /*******************************************************************************
    *  Summary         : Calculate deposit   
    *  CreatedDate     : 11/06/2018 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDeposit() {
        try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
                this.deposit = getDepositMonthlyPlus7();
                this.securityLevel = this.securityLevelMonthlyPlus7;
            }
            else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
                this.deposit = getDepositBiWeeklyPlus7();
                this.securityLevel = this.securityLevelBiWeeklyPlus7;
            } 
            else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.deposit = getDepositWeeklyPlus7();
                this.securityLevel = this.securityLevelWeeklyPlus7;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : resetDeposit(CreditCompany company, Integer billingPeriod, Decimal creditLimit, 
                             Decimal maxCreditLimit, Decimal monthlyVolume, Decimal totalConsumption,
                             String opportunityId)
    *  Summary         : recalculate deposit value for changed CL value    
    *  CreatedDate     : 11/06/2018 by Anton Buzak
    *  Parameters      : CreditCompany company - company from Credit System, 
                         Integer billingPeriod - selected billing period, 
                         Integer paymentTerms - selected payment terms,
                         Decimal creditLimit - changed CL value,
                         Decimal maxCreditLimit - max Credit Limit for selected billing period,
                         Decimal monthlyVolume - currency based on total consumption of liters,
                         Decimal totalConsumption - total consumption of liters,
                         String opportunityId - id of related opportunity.
    *  Returns         : -
    ******************************************************************************/
    public void resetDeposit(CreditCompany company, Integer billingPeriod, Integer paymentTerms, Decimal creditLimit, 
                             Decimal maxCreditLimit, Decimal monthlyVolume, Decimal totalConsumption,
                             String opportunityId) {
        try {
            if (company.classRating == '1') {
                this.deposit = resetDepositRating1(totalConsumption, creditLimit, maxCreditLimit, company);
            } else if (company.classRating == '2') {
                this.deposit = resetDepositRating2(totalConsumption, creditLimit, maxCreditLimit, company);
            } else if (company.classRating == '3') {
                this.deposit = resetDepositRating3(totalConsumption, creditLimit, maxCreditLimit, company);
            } else if (company.classRating == '4') {
                this.deposit = resetDepositRating4(totalConsumption, creditLimit, maxCreditLimit, company);
            } else if (company.classRating == '5') {
                this.deposit = resetDepositRating5(billingPeriod, creditLimit);
            }

            if (billingPeriod == 15 && creditLimit == company.creditLimitBiWeeklyPlus7) {
                this.deposit = company.depositBiWeeklyPlus7;
            } else if (billingPeriod == 7 && creditLimit == company.creditLimitWeeklyPlus7) {
                this.deposit = company.depositWeeklyPlus7;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit recalculation failed. ' + e.getMessage());
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 1 and changed CL value.     
    *  CreatedDate     : 11/06/2018
    *  Parameters      : totalConsumption - total consumption of liters, 
                         creditLimit - changed CL value, 
                         maxCreditLimit - max Credit Limit for selected billing period, 
                         company - company from Credit System
    *  Returns         : deposit value
    ******************************************************************************/
    private Decimal resetDepositRating1(Decimal totalConsumption, Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
        Date dateOfFoundation;
        if (company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)),
                    Integer.valueOf(company.dateoffoundation.substring(8, 10)));
        } else if (company.additionalDateOfFoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.additionalDateOfFoundation.substring(0, 4)), Integer.valueOf(company.additionalDateOfFoundation.substring(5, 7)),
                    Integer.valueOf(company.additionalDateOfFoundation.substring(8, 10)));
        }

        Decimal recommendedCreditLimit;
        if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        } else {
            recommendedCreditLimit = 0;
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((company.country == 'BE' || company.country == 'NL') && creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
				return 0;
            }
            else {
                this.securityLevel = 100;
				return creditLimit;
            }
        }
        else if (creditLimit > maxCreditLimit) {
            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 3;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } else if (company.errors != null && company.errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } else {
                this.securityLevel = null;
                return 0;
            }
        } else {
            if (company.errors != null && company.errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } else {
                this.securityLevel = null;
                return 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 2 and changed CL value.
    *  CreatedDate     : 11/06/2018
    *  Parameters      : totalConsumption - total consumption of liters, 
                         creditLimit - changed CL value, 
                         maxCreditLimit - max Credit Limit for selected billing period, 
                         company - company from Credit System
    *  Returns         : deposit value
    ******************************************************************************/
    private Decimal resetDepositRating2(Decimal totalConsumption, Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
        Date dateOfFoundation;
        if (company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)),
                    Integer.valueOf(company.dateoffoundation.substring(8, 10)));
        } else if (company.additionalDateOfFoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.additionalDateOfFoundation.substring(0, 4)), Integer.valueOf(company.additionalDateOfFoundation.substring(5, 7)),
                    Integer.valueOf(company.additionalDateOfFoundation.substring(8, 10)));
        }

        Decimal recommendedCreditLimit;
        if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        } else {
            recommendedCreditLimit = 0;
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((company.country == 'BE' || company.country == 'NL') && creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
				return 0;
            }
            else {
                this.securityLevel = 100;
				return creditLimit;
            }
        }
        else if (soleTradersSet.contains(company.legalform) && company.country == 'FR' &&
                (company.dateoffoundation == null || Integer.valueOf(company.dateoffoundation.substring(0, 4)) > Date.today().year() - 2)) {
            this.securityLevel = 50;
            return (creditLimit * 0.5 / 100).round(System.RoundingMode.HALF_UP) * 100;
        } else if (creditLimit > maxCreditLimit) {
            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 3;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } else if (company.errors != null && company.errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } else {
                this.securityLevel = null;
                return 0;
            }
        } else {
            if (company.errors != null && company.errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } else {
                this.securityLevel = null;
                return 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 3 and changed CL value. 
    *  CreatedDate     : 11/06/2018
    *  Parameters      : totalConsumption - total consumption of liters, 
                         creditLimit - changed CL value, 
                         maxCreditLimit - max Credit Limit for selected billing period, 
                         company - company from Credit System
    *  Returns         : deposit value
    ******************************************************************************/
    private Decimal resetDepositRating3(Decimal totalConsumption, Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
        Date dateOfFoundation;
        if (company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)),
                    Integer.valueOf(company.dateoffoundation.substring(8, 10)));
        } 
        else if (company.additionalDateOfFoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.additionalDateOfFoundation.substring(0, 4)), Integer.valueOf(company.additionalDateOfFoundation.substring(5, 7)),
                    Integer.valueOf(company.additionalDateOfFoundation.substring(8, 10)));
        }

        Decimal recommendedCreditLimit;
        if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        } 
        else {
            recommendedCreditLimit = 0;
        }

        Date dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(company.dateOfLastChangeOfDirector);
        Date dateOfLastChangeOfAddress = returnDateOfLastChangeOfAddress(company.dateOfLastChangeOfAddress);

        if (dateOfLastChangeOfDirector != null && dateOfLastChangeOfDirector.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfDirector, dateOfFoundation) ||
                dateOfLastChangeOfAddress != null && dateOfLastChangeOfAddress.monthsBetween(Date.today()) <= 6 &&
                ! CreditFactoryUtilities.areDatesEqual(dateOfLastChangeOfAddress, dateOfFoundation) ||
                company.addressChangeDecision == 'The business has been at the address for less than 6 months.' &&
                dateOfFoundation != null && ! (dateOfFoundation.monthsBetween(Date.today()) <= 6)) {
            this.securityLevel = 100;
            return creditLimit;
        } 
        else if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((company.country == 'BE' || company.country == 'NL') && creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
				return 0;
            }
            else {
                this.securityLevel = 100;
				return creditLimit;
            }
        } 
        else if (soleTradersSet.contains(company.legalform) && company.country == 'FR') {
            this.securityLevel = 70;
            return (creditLimit * 0.7 / 100).round(System.RoundingMode.HALF_UP) * 100;
        } 
        else if (creditLimit > maxCreditLimit) {
            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 3;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } 
            else if (company.errors != null && company.errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } 
            else {
                this.securityLevel = null;
                return 0;
            }
        } 
        else {
            this.securityLevel = null;
            return 0;
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 4 and changed CL value.
    *  CreatedDate     : 11/06/2018
    *  Parameters      : totalConsumption - total consumption of liters, 
                         creditLimit - changed CL value,
                         maxCreditLimit - max Credit Limit for selected billing period, 
                         company - company from Credit System,
                         errors - set of errors
    *  Returns         : deposit value
    ******************************************************************************/
    private Decimal resetDepositRating4(Decimal totalConsumption, Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company)  {
        Date dateOfFoundation;
        if (company.dateoffoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)),
                    Integer.valueOf(company.dateoffoundation.substring(8, 10)));
        }
        else if (company.additionalDateOfFoundation != null) {
            dateOfFoundation = Date.newInstance(Integer.valueOf(company.additionalDateOfFoundation.substring(0, 4)), Integer.valueOf(company.additionalDateOfFoundation.substring(5, 7)),
                    Integer.valueOf(company.additionalDateOfFoundation.substring(8, 10)));
        }

        if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
            if ((company.country == 'BE' || company.country == 'NL') && creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
				return 0;
            }
            else {
                this.securityLevel = 100;
				return creditLimit;
            }
        }
        else {
            this.securityLevel = 100;
            return creditLimit;
        }
    }


    /*******************************************************************************
    *  Name            : resetDepositRating5(CreditCompany company, Decimal creditLimit)
    *  Summary         : Reset deposit value for rating 5 and changed CL value.   
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer billingPeriod - selected billing period,  
                         Decimal creditLimit - changed CL value,
    *  Returns         : Decimal
    ******************************************************************************/
    private Decimal resetDepositRating5(Integer billingPeriod, Decimal creditLimit) {
        this.securityLevel = 110;
        return ((creditLimit * (billingPeriod + 7.0 + 10.0) / (billingPeriod + 7.0)) / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Name            : getDeposit()
    *  Summary         : Return deposit.    
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getDeposit() {
        return this.deposit;
    }


    /*******************************************************************************
    *  Name            : setDecision()
    *  Summary         : Set company decision   
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : 28/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDecision() {
        try {
            this.decision = new CreditFactoryDecision();
            if (this.company.name == null && this.userSource != 'E2E Long Form') {
                this.decision.verdict = 'No';
                this.decision.statusCode = '005';
            } else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
                // Positive Decisions without deposit
                this.decision.verdict = 'Yes';
                Date dateOfFoundation;
                if (this.company.dateoffoundation != null) {
                    dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)),
                        Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10)));
                } else if (this.additionalCompany.dateoffoundation != null) {
                    dateOfFoundation = Date.newInstance(Integer.valueOf(this.additionalCompany.dateoffoundation.substring(0, 4)), Integer.valueOf(this.additionalCompany.dateoffoundation.substring(5, 7)),
                        Integer.valueOf(this.additionalCompany.dateoffoundation.substring(8, 10)));
                }

                if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
					this.decision.statusCode = '004'; // more than 1 card is no available
				}
                else {
                    this.decision.statusCode = '001'; // No Limits
                }
            }
            else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
                // Positive Decisions with deposit
                this.decision.verdict = 'Yes';
                this.decision.statusCode = '002'; // No Limits
            }
            else {
                // Negative Decisions
                this.decision.verdict = 'No';
                this.decision.statusCode = '003';
            }

            if (this.userSource != 'E2E Long Form') {
                if (this.decision.statusCode == '001' || this.decision.statusCode == '004') {
                    // validate mandate type before final decision
                    if (! validateMandateType()) {
			            CreditFactoryUtilities.displayMessage('error', CreditFactoryUtilities.UNAVAILABLE_MANDATE_TYPE);
			        } else {
						CreditFactoryUtilities.displayMessage('info','Billing Period can be set to ' + this.billingPeriod);
                        CreditFactoryUtilities.displayMessage('info','Payment Terms can be set to ' + this.paymentTerms);
					}
                }
                else if (this.parentCompanyId == null && (this.decision.statusCode == '002' || this.decision.statusCode == '005')) {
                    if (this.decision.statusCode == '005') {
                        CreditFactoryUtilities.displayMessage('error', 'Credit Report for your Company is not available in Creditsafe. You can close the customer with Deposit decision or refer to Credit.');
                    }
                    // validate mandate type before final decision
                    if (! validateMandateType()) {
			            CreditFactoryUtilities.displayMessage('error', CreditFactoryUtilities.UNAVAILABLE_MANDATE_TYPE);
			        } else {
						CreditFactoryUtilities.displayMessage('info','Billing Period can be set to ' + this.billingPeriod);
                        CreditFactoryUtilities.displayMessage('info','Payment Terms can be set to ' + this.paymentTerms + '</br></br>');
                        CreditFactoryUtilities.displayMessage('info','Deposit to pay: ' + this.deposit + ' EUR.</br></br>' + 
                            'You can update Desired Payment Terms and Desired Billing Period in the Opportunity and restart Credit Factory to recalculate the deposit amount.');	
					}
                } else if (this.decision.statusCode == '003') {
                    CreditFactoryUtilities.displayMessage('error','Requested limit too high. Please refer to credit.');
                }
            } 
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            if (e.getMessage() == CreditFactoryUtilities.UNAVAILABLE_MANDATE_TYPE) {
                errorMessage = CreditFactoryUtilities.UNAVAILABLE_MANDATE_TYPE;
            } else if (e.getMessage().contains('Opportunity was submitted for Approval.')) {
                errorMessage = e.getMessage();
            } else {
                errorMessage = 'Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            }
            System.debug('Credit Factory === ' + errorMessage);
            throw new CreditFactoryException(errorMessage);
        }
    }


    /*******************************************************************************
    *  Name            : resetDecision()
    *  Summary         : Reset Company Decision
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : 18/03/2019
    *  Parameters      : Integer billingPeriod - selected billing period, Integer paymentTerms - selected payment terms, 
                         Decimal deposit - selected deposit, String classRating - current company class rating, 
                         CreditCompany company - company from Credit System
    *  Returns         : void
    ******************************************************************************/
    public void resetDecision(Integer billingPeriod, Integer paymentTerms, Decimal deposit, String classRating, Decimal numberOfCards, CreditCompany company) {
        try {
            this.decision = new CreditFactoryDecision();
            // Positive Decisions
            this.decision.verdict = 'Yes';
            if (deposit == 0) {
                // Decisions without deposit
                Date dateOfFoundation;
                if (company.dateoffoundation != null) {
                    dateOfFoundation = Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)),
                        Integer.valueOf(company.dateoffoundation.substring(5, 7)), Integer.valueOf(company.dateoffoundation.substring(8, 10)));
                }

                if (dateOfFoundation == null || dateOfFoundation.monthsBetween(Date.today()) <= 18) {
					this.decision.statusCode = '004'; // more than 1 card is no available
				}
                else {
                    this.decision.statusCode = '001'; // No Limits, Max Value should be updated
                }
            } else {
                // Decisions with deposit
                this.decision.statusCode = '002'; // No Limits, Max Value should be set
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Reset Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfDirector(String dateOfLastChangeOfDirectorString)
    *  Summary         : Return Date of Last Change Of Director base on string
    *  CreatedDate     : 18/09/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Date
    ******************************************************************************/
    private Date returnDateOfLastChangeOfDirector(String dateOfLastChangeOfDirectorString) {
        Date dateOfLastChangeOfDirector;
        if (dateOfLastChangeOfDirectorString != null) {
            dateOfLastChangeOfDirector = Date.newInstance(Integer.valueOf(dateOfLastChangeOfDirectorString.substring(0, 4)),
                Integer.valueOf(dateOfLastChangeOfDirectorString.substring(5, 7)), Integer.valueOf(dateOfLastChangeOfDirectorString.substring(8, 10)));
        }

        return dateOfLastChangeOfDirector;
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfAddress(String dateOfLastChangeOfAddressString)
    *  Summary         : Return Date of Last Change Of Address base on string
    *  CreatedDate     : 18/09/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Date
    ******************************************************************************/
    private Date returnDateOfLastChangeOfAddress(String dateOfLastChangeOfAddressString) {
        Date dateOfLastChangeOfAddress;
        if (dateOfLastChangeOfAddressString != null) {
            dateOfLastChangeOfAddress = Date.newInstance(Integer.valueOf(dateOfLastChangeOfAddressString.substring(0, 4)),
                Integer.valueOf(dateOfLastChangeOfAddressString.substring(5, 7)), Integer.valueOf(dateOfLastChangeOfAddressString.substring(8, 10)));
        }

        return dateOfLastChangeOfAddress;
    }


    /*******************************************************************************
    *  Name            : getDecision()
    *  Summary         : Return decision.    
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditFactoryDecision
    ******************************************************************************/
    public CreditFactoryDecision getDecision() {
        return this.decision;
    }


    /*******************************************************************************
    *  Summary         : check for warnings
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void checkWarnings() {
        if (this.userSource != 'E2E Long Form' && 
                (this.sourceObject.Account.BillingCountry == 'Belgium-FR' || this.sourceObject.Account.BillingCountry == 'Belgium-NL')) {
            Boolean isPaymentTermsValid = checkPaymentTerms();
            Boolean isBillingPeriodValid = checkBillingPeriod();
            if (isPaymentTermsValid == false || isBillingPeriodValid == false) {
               CreditFactoryUtilities.displayMessage('warning', 'If you want to close your Opportunity with desired billing period and desired payment terms, please refer to Credit.');
            }
        }
    }


    /*******************************************************************************
    *  Summary         : compare calculated and desired payment terms
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : check result
    ******************************************************************************/
    private Boolean checkPaymentTerms() {
        if (this.sourceObject.Rechnungsperiode_2__c != null && this.paymentTerms != null && this.sourceObject.Rechnungsperiode_2__c != String.valueOf(this.paymentTerms)) {
            CreditFactoryUtilities.displayMessage('warning', 'Desired payment terms (' + this.sourceObject.Rechnungsperiode_2__c + 
                ') cannot be provided.');
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : compare calculated and desired billing period    
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : check result
    ******************************************************************************/
    private Boolean checkBillingPeriod() {
        if (this.sourceObject.Zahlungsziel_2__c != null && this.billingPeriod != null && this.sourceObject.Zahlungsziel_2__c != String.valueOf(this.billingPeriod)) {
            CreditFactoryUtilities.displayMessage('warning', 'Desired billing period (' + this.sourceObject.Zahlungsziel_2__c + 
                ') cannot be provided.');
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : saveReports()
    *  Summary         : Save information from Credit system to Salesforce     
    *  CreatedDate     : 19/10/2017
    *  ModifiedDate    : 03/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveReports() {
        if (this.existingCreditReportsList != null && this.existingCreditReportsList.isEmpty() && this.companyEmployeesList != null && this.company != null) {
            List<Credit_Factory_Report__c> newReportsList = new List<Credit_Factory_Report__c>();
            Credit_Factory_Report__c newReport = new Credit_Factory_Report__c();
            if (this.company.Name != null) {
                newReport = returnNewReport();
                newReportsList.add(newReport);
            }

            Credit_Factory_Report__c newAdditionalReport = new Credit_Factory_Report__c();
            if (this.additionalCompany.name != null) {
                newAdditionalReport = returnNewAdditionalReport();
                newReportsList.add(newAdditionalReport);
            }

            try {
                insert newReportsList;
                List<Credit_Factory_Report_Employee__c> employeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
                if (! this.companyEmployeesList.isEmpty()) {
                    employeesListToInsert.addAll(returnNewReportEmployees(newReport.Id));
                }

                if (! this.additionalCompanyEmployeesList.isEmpty()) {
                    employeesListToInsert.addAll(returnNewAdditionalReportEmployees(newAdditionalReport.Id));
                }

                insert employeesListToInsert;
            } catch (Exception e) {
                CreditFactoryUtilities.displayMessage('error','Error on saving Opportunity Reports. Contact your administrator.');
                system.debug('Credit Factory === ' + e.getMessage());
                return;
            }
        } else {
            // return existing report
            if (this.userSource == 'E2E Long Form') {
                Credit_Factory_Report__c reportToUpdate = returnExistingReport();
                try {
                    update reportToUpdate;
                } catch (Exception e) {
                     System.debug('Credit Factory === ' + e.getMessage());
                     CreditFactoryUtilities.displayMessage('error', 'Error on updating Credit Factory Report. Contact your administrator.');
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : returnNewReport()
    *  Summary         : Return Credit Factory Report.
    *  CreatedDate     : 19/04/2018
    *  ModifiedDate    : 17/09/2019
    *  Parameters      : -
    *  Returns         : Credit_Factory_Report__c
    ******************************************************************************/
    private Credit_Factory_Report__c returnNewReport() {
        String reportName = this.company.name;
        if (reportName.length() > 80) {
            reportName = reportName.substring(0,80);
        }
        String errors = '';
        if (errorsSet != null) {
            for (String error : errorsSet) {
                errors += error + ', ';
            }
            errors = errors.removeEnd(', ');
        }
        Credit_Factory_Report__c newReport = new Credit_Factory_Report__c(
            Credit_System_Number__c = this.company.creditSystemCompanyNumber,
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Default'),
            Age_of_Company__c = this.company.ageofcompany,
            City__c = this.company.city,
            Company_Status__c = this.company.status,
            Country__c = this.company.country,
            County_Court__c = this.company.countyCourt,
            Credit_Decision__c = this.company.creditDecision,
            Credit_Limit__c = this.company.creditLimit,
            Date_Last_Register_Entry__c = this.company.datelastregisterentry,
            Date_Legal_Form__c = this.company.datelegalform,
            Date_of_Foundation__c = this.company.dateoffoundation,
            Email__c = this.company.email,
            Fax__c = this.company.fax,
            First_Legal_Form__c = this.company.firstlegalform,
            Fiscal_Number__c = this.company.taxnumber,
            Housenumber__c = this.company.housenumber,
            Legal_Form__c = this.company.legalform,
            Mobile__c = this.company.mobile,
            Opportunity__c = this.sourceObject.Id,
            Order_Situation__c = this.company.orderSituation,
            Payment_Behaviour__c = this.company.paymentBehaviour,
            Phone__c = this.company.phone,
            Postcode__c = this.company.postcode,
            Register_Number__c = this.company.registerNumber,
            Staff_Range__c = this.company.staffcompanyrange,
            Street__c = this.company.street,
            Trade_Name__c = this.company.tradename,
            Turn_Over__c = this.company.turnOver,
            VAT_Number__c = this.company.vatid,
            Tax_Id__c = this.company.taxnumber,
            Trade_Register_Number__c = this.company.tradeRegisterNumber,
            Website__c = this.company.website,
            Name = reportName,
            Company_Id__c = this.company.identificationnumber,
            Name__c = this.company.name,
            Date_Of_Last_Change_Of_Director__c = this.company.dateOfLastChangeOfDirector,
            Date_Of_Last_Change_Of_Address__c = this.company.dateOfLastChangeOfAddress,
            Address_Change_Decision__c = this.company.addressChangeDecision,
            Principal_Activity_Code__c = this.company.principalActivityCode,
            Principal_Activity_Description__c = this.company.principalActivityDescription,
            Email_Exists__c = this.company.emailExists,
            Domain_Exists__c = this.company.domainExists,
            Email_Date__c = this.company.emailDate,
            Domain_Date__c = this.company.domainDate,
            Email_Status__c = this.company.emailStatus,
            Email_Risk__c = this.company.emailRisk,
            Risk_Description__c = this.company.riskDescription,
            Risk_Advice__c = this.company.riskAdvice,
            Fraud_Within_Industry__c = this.company.fraudWithinIndustry,
            Fraud_Type__c = this.company.fraudType,
            Total_Hits__c = this.company.totalHits,
            Unique_Hits__c = this.company.uniqueHits,
            Name_Match__c = this.company.nameMatch,
            Checked_Email__c = this.company.checkedEmail,
            Solvency_Index__c = this.company.solvencyIndex,
            Parent_Company_Id__c = this.company.parentCompanyId,
            Provider_Description__c = this.company.providerDescription);
        
            if (this.company.email != null && this.company.checkedEmail != null) {
                String companyEmailDomain = this.company.email.substringAfter('@').toUpperCase();
                String primaryContactEmailDomain = this.company.checkedEmail.substringAfter('@').toUpperCase();
                if (companyEmailDomain != primaryContactEmailDomain) {
                    newReport.Emails_Mismatch__c = true;
                }
                else {
                    newReport.Emails_Mismatch__c = false;
                }
            }


            if (this.userSource == 'E2E Long Form') {
                newReport.Billing_Period__c = this.billingPeriod;
                newReport.Security_Level__c = this.securityLevel;
                newReport.Credit_Limit_Default__c = getCreditLimit();
                newReport.Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7();
                newReport.Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7();
                newReport.Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7();
                newReport.Deposit_Weekly_7__c = getDepositWeeklyPlus7();
                newReport.Credit_Limit_Weekly_7__c = getCreditLimitBiWeeklyPlus7();
                newReport.Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitBiWeeklyPlus7();
                newReport.Max_Value_Bi_Weekly_7__c = getMaxValueBiWeeklyPlus7();
                newReport.Deposit_Bi_Weekly_7__c = getDepositBiWeeklyPlus7();
                newReport.Credit_Limit_Monthly_7__c = getCreditLimitMonthlyPlus7();
                newReport.Max_Credit_Limit_Monthly_7__c = getMaxCreditLimitMonthlyPlus7();
                newReport.Max_Value_Monthly_7__c = getMaxValueMonthlyPlus7();
                newReport.Deposit_Monthly_7__c = getDepositMonthlyPlus7();
                newReport.Decision_Verdict__c = this.decision.verdict;
                newReport.Decision_Status_Code__c = this.decision.statusCode;
                newReport.Exception_Code__c = this.exceptionCode;
                newReport.Errors__c = errors;
            }

        if (company.classRating != null) {
            newReport.Class_Rating__c = CreditFactoryUtilities.returnArabic(company.classRating);
        }

        return newReport;
    }


    /*******************************************************************************
    *  Name            : returnNewAdditionalReport()
    *  Summary         : Return New Additional Credit Factory Report.    
    *  CreatedDate     : 19/04/2018
    *  ModifiedDate    : 08/01/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Report
    ******************************************************************************/
    private Credit_Factory_Report__c returnNewAdditionalReport() {
        String reportName = this.additionalCompany.tradename;
        if (reportName.length() > 80) {
            reportName = reportName.substring(0,80);
        }
        Credit_Factory_Report__c newAdditionalReport = new Credit_Factory_Report__c(
            Name = reportName,
            Opportunity__c = this.sourceObject.Id,
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Company Info'),
            Indication_Main_Establishment__c = this.additionalCompany.indicationMainEstablishment,
            Rsin_Number__c = this.additionalCompany.rsinNumber,
            Legal_Form__c = this.additionalCompany.legalform,
            Indication_Organisation__c = this.additionalCompany.indicationOrganisation,
            Trade_Name__c = this.additionalCompany.tradename,
            Postcode__c = this.additionalCompany.postcode,
            City__c = this.additionalCompany.city,
            Street__c = this.additionalCompany.street,
            Housenumber__c = this.additionalCompany.housenumber,
            Country__c = this.additionalCompany.country,
            Phone__c = this.additionalCompany.phone,
            Mobile__c = this.additionalCompany.mobile,
            Website__c = this.additionalCompany.website,
            Primary_Sbi_Code__c = this.additionalCompany.primarySbiCode,
            Primary_Sbi_Code_Text__c = this.additionalCompany.primarySbiCodeText,
            Staff_Range__c = this.additionalCompany.staffcompanyrange,
            Indication_Economically_Active__c = this.additionalCompany.indicationEconomicallyActive,
            Indication_Non_Mailing__c = this.additionalCompany.indicationNonMailing,
            Indication_Bankruptcy__c = this.additionalCompany.indicationBankruptcy,
            Indication_Dip__c = this.additionalCompany.indicationDip, 
            Authorized_Share_Capital__c = this.additionalCompany.authorizedShareCapital,
            Authorized_Share_Capital_Currency__c = this.additionalCompany.authorizedShareCapitalCurrency,
            Paid_Up_Share_Capital__c = this.additionalCompany.paidUpShareCapital,
            Paid_Up_Share_Capital_Currency__c = this.additionalCompany.paidUpShareCapitalCurrency,
            Issued_Share_Capital__c = this.additionalCompany.issuedShareCapital,
            Issued_Share_Capital_Currency__c = this.additionalCompany.issuedShareCapitalCurrency,
            Continuation_Date__c = this.additionalCompany.continuationDate,
            Establishment_Date__c = this.additionalCompany.establishmentDate,
            Company_Id__c = this.additionalCompany.identificationnumber,
            Date_of_Foundation__c = this.additionalCompany.dateoffoundation,
            Name__c = this.additionalCompany.tradename);
        return newAdditionalReport;
    }


    /*******************************************************************************
    *  Name            : returnNewReportEmployees()
    *  Summary         : Return New Additional Credit Factory Report Employees.    
    *  CreatedDate     : 19/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Report_Employee__c>
    ******************************************************************************/
    private List<Credit_Factory_Report_Employee__c> returnNewReportEmployees(String newReportId) {
        List<Credit_Factory_Report_Employee__c> newCompanyEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditCompanyEmployee newEmployee : this.companyEmployeesList) {
            newCompanyEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Credit_Factory_Report__c = newReportId,
                RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default'),
                Address__c = newEmployee.address,
                Date_of_Birth__c = newEmployee.dateofbirth,
                Id__c = newEmployee.enumber,
                Name = newEmployee.ename,
                Participation_Date__c = newEmployee.participationdate,
                Type__c = newEmployee.type,
                Company_Id__c = newEmployee.companyId,
                Company_Type__c = newEmployee.companyType,
                Company_Role__c = newEmployee.companyRole));
        }

        return newCompanyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : returnNewAdditionalReportEmployees()
    *  Summary         : Return New Additional Credit Factory Report Employees.    
    *  CreatedDate     : 19/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : List<Credit_Factory_Report_Employee__c>
    ******************************************************************************/
    private List<Credit_Factory_Report_Employee__c> returnNewAdditionalReportEmployees(String newAdditionalReportId) {
        List<Credit_Factory_Report_Employee__c> newAdditionalCompanyEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditCompanyEmployee newAdditionalEmployee : this.additionalCompanyEmployeesList) {
            newAdditionalCompanyEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Credit_Factory_Report__c = newAdditionalReportId,
                RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Company Info'),
                Date_of_Birth__c = newAdditionalEmployee.dateofbirth,
                Name = newAdditionalEmployee.ename,
                Type__c = newAdditionalEmployee.type,
                Company_Role__c = newAdditionalEmployee.companyRole));
        }

        return newAdditionalCompanyEmployeesList;
    }


    /*******************************************************************************
    *  Name            : returnExistingReport()
    *  Summary         : Return Existing Credit Factory Report to update
    *  CreatedDate     : 12/06/2018
    *  ModifiedDate    : 17/04/2019
    *  Parameters      : 
    *  Returns         : Credit_Factory_Report__c
    ******************************************************************************/
    private Credit_Factory_Report__c returnExistingReport() {
        Credit_Factory_Report__c creditReportToUpdate = new Credit_Factory_Report__c();
        String errors = '';
        if (errorsSet != null) {
            for (String error : errorsSet) {
                errors += error + ', ';
            }
            errors = errors.removeEnd(', ');
        }
        for (Credit_Factory_Report__c existingCreditReport : this.existingCreditReportsList) {
            if (existingCreditReport.RecordType.Name == 'Default') {
                creditReportToUpdate = new Credit_Factory_Report__c(
                    Id = existingCreditReport.Id,
                    Billing_Period__c = this.billingPeriod,
                    Security_Level__c = this.securityLevel,
                    Credit_Limit_Default__c = getCreditLimit(),
                    Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7(),
                    Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7(),
                    Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7(),
                    Deposit_Weekly_7__c = getDepositWeeklyPlus7(),
                    Credit_Limit_Bi_Weekly_7__c = getCreditLimitBiWeeklyPlus7(),
                    Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitBiWeeklyPlus7(),
                    Max_Value_Bi_Weekly_7__c = getMaxValueBiWeeklyPlus7(),
                    Deposit_Bi_Weekly_7__c = getDepositBiWeeklyPlus7(),
                    Credit_Limit_Monthly_7__c = getCreditLimitMonthlyPlus7(),
                    Max_Credit_Limit_Monthly_7__c = getMaxCreditLimitMonthlyPlus7(),
                    Max_Value_Monthly_7__c = getMaxValueMonthlyPlus7(),
                    Deposit_Monthly_7__c = getDepositMonthlyPlus7(),
                    Decision_Verdict__c = this.decision.verdict,
                    Decision_Status_Code__c = this.decision.statusCode,
                    Exception_Code__c = this.exceptionCode,
                    Errors__c = errors);
            }
        }

        return creditReportToUpdate;
    }


    /*******************************************************************************
    *  Name            : changeBillingPeriodBySales()
    *  Summary         : Change Billing Period and update fields in Opportunity
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public PageReference changeBillingPeriodBySales() {
        try {
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);

            if (this.maxCreditLimit != null) {
                this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
            }

            update this.sourceObject;
            return new PageReference('/' + this.sourceObject.Id);
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error','Change Billing Period failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            system.debug('Credit Factory === ' + e.getMessage());
            return null;
        }
    }


    public void updateOpportunityWithPDF(sObject sourceObject) {
    }


    /*******************************************************************************
    *  Name            : doCreateReportAttachment(String opportunityId)
    *  Summary         : Create Credit Company Report PDF Attachment in Salesforce and attach to Opportunity
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 19/09/2019
    *  Parameters      : opportunityId - source record Salesforce id
    *  Returns         : Boolean - true if report attached to opportunity
    ******************************************************************************/
    public Boolean doCreateReportAttachment(String opportunityId) {
        // create pdf asynchronously
        if (! Test.isRunningTest()) { // uncommitted work pending
            if (this.existingCreditReportsList.isEmpty() && this.companyEmployeesList != null && this.company != null && this.sourceObject.Id != null) {
                Set<String> companiesIdsSet = new Set<String>();
                companiesIdsSet.add(this.company.identificationnumber);
                if (this.company.parentCompanyId != null) companiesIdsSet.add(this.company.parentCompanyId);
                System.enqueueJob(new PDFReportCreation(companiesIdsSet, this.sourceObject, this.company.parentCompanyId));
            }
        }
        return false;
    }


    /*******************************************************************************
    *  Name            : isPendingSEPAPossible()
    *  Summary         : check possibility to automatically change Stage to Pending SEPA Confirmation     
    *  CreatedDate     : 29/09/2017
    *  ModifiedDate    : 03/04/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isPendingSEPAPossible() {
        if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && (this.sourceObject.Einwilligung_Lastschriftverfahren__c == false || String.isEmpty(this.sourceObject.IBAN__c)) && validateMandateType()) {
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Name            : isAutoCWPossible()
    *  Summary         : check possibility to automatically change Stage to Closed Won     
    *  CreatedDate     : 29/09/2017
    *  ModifiedDate    : 03/04/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isAutoCWPossible() {
        if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && this.sourceObject.Einwilligung_Lastschriftverfahren__c == true &&
               ! String.isEmpty(this.sourceObject.IBAN__c) && validateMandateType()) {
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Name            : changeToPendingSEPAConfirmation()
    *  Summary         : Change Opportunity StageName to Pending Sales - SEPA Confirmation
    *  CreatedDate     : 11/08/2017
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToPendingSEPAConfirmation() {
        checkDuplicates();
        Integer numberOfRelatedTankkartens = countNumberOfRelatedTankkartens();
        Integer numberOfCardsField = 0;
        if (this.sourceObject.Anzahl_der_Karten__c != null) {
            numberOfCardsField = (Integer) this.sourceObject.Anzahl_der_Karten__c;
        }
        if (numberOfRelatedTankkartens != numberOfCardsField && this.sourceObject.Custom_PIN__c != true) {
            throw new CreditFactoryException('Number of cards in the Opportunity is different from number of Tankkarten objects linked to the Opportunity.');
        }

        try {
            prepareGeneralFieldsForAutoprocess();
            this.sourceObject.StageName = 'Pending Sales - SEPA Confirmation';
            this.sourceObject.CF_Stage__c = 'SEPA Confirmation';
            update this.sourceObject;
            update this.sourceObject.Account;
            return new PageReference('/' + this.sourceObject.Id);
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error','Change to Pending Sales - SEPA Confirmation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : changeToClosedWon()
    *  Summary         : Change opportunity StageName to Closed Won
    *  CreatedDate     : 20/06/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToClosedWon() {
        checkDuplicates();
        Integer numberOfRelatedTankkartens = countNumberOfRelatedTankkartens();
        Integer numberOfCardsField = 0;
        if (this.sourceObject.Anzahl_der_Karten__c != null) {
            numberOfCardsField = (Integer) this.sourceObject.Anzahl_der_Karten__c;
        }
        if (numberOfRelatedTankkartens != numberOfCardsField && this.sourceObject.Custom_PIN__c != true) {
            throw new CreditFactoryException('Number of cards in the Opportunity is different from number of Tankkarten objects linked to the Opportunity.');
        }

        try {
            prepareGeneralFieldsForAutoprocess();
            this.sourceObject.StageName = 'Closed Won';
            this.sourceObject.ForecastCategoryName = 'Closed';
            this.sourceObject.Probability = 100;
            this.sourceObject.Closed_Won_by_CF__c = true;
            this.sourceObject.CF_Stage__c = 'Auto CW';
            update this.sourceObject.Account;
            update this.sourceObject;
            return new PageReference('/' + this.sourceObject.Id);
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException('Change to Closed Won failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);   
        }
    }


    /*******************************************************************************
    *  Name            : countNumberOfRelatedTankkartens()
    *  Summary         : count number of Tankkarten__c objects related to the current Opportunity    
    *  CreatedDate     : 24/11/2017
    *  ModifiedDate    : 24/11/2017
    *  Parameters      : -
    *  Returns         : Integer
    ******************************************************************************/
    private Integer countNumberOfRelatedTankkartens() {
        List<Tankkarten__c> relatedTankkartensList = [
		        SELECT Id
		        FROM Tankkarten__c
		        WHERE Opportunity__c = :this.sourceObject.Id];
		if (relatedTankkartensList.size() != 0) {
			return relatedTankkartensList.size();
		} else {
			List<Offer_Item__c> offerItemsList = new List<Offer_Item__c>();
			Map<Id, OpportunityLineItem> lineItemsMap = new Map<Id, OpportunityLineItem>([
                    SELECT Id
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :this.sourceObject.Id AND Product2.Family = 'SHELL']);
			if (! lineItemsMap.isEmpty()) {
				offerItemsList = [
						SELECT Type_of_Card__c
						FROM Offer_Item__c
						WHERE Opportunity_Product_Id__c IN :lineItemsMap.keySet()
				];
			}
			return offerItemsList.size();
		}
    }


    /*******************************************************************************
    *  Name            : prepareGeneralFieldsForAutoprocess()
    *  Summary         : prepare fields for Closed Won or Pending Sales    
    *  CreatedDate     : 11/08/2017
    *  ModifiedDate    : 11/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void prepareGeneralFieldsForAutoprocess() {
        this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
        this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
        this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
        this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
        this.sourceObject.put(this.opportunityMapping.Processed_by__c, 'Autoprocessed by Sales');
        this.sourceObject.put(this.opportunityMapping.Credit_Decision__c, 'Genehmigt');
        this.sourceObject.CloseDate = Date.today();
        this.sourceObject.Billing_Period_by_Sales__c = true;
        this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);
        if (this.maxCreditLimit != null) {
            this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
        }
        this.sourceObject.Last_CF_Errors__c = null;
        this.sourceObject.Security_To_Pay__c = null;
        this.sourceObject.Security_Amount_To_Pay__c = null;
        this.sourceObject.Pending_Deposit_by_CF__c = false;
        this.sourceObject.put(this.opportunityMapping.Security_Level__c, null);
        if (this.company.legalform != null) {
            this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
        } else {
            this.sourceObject.Account.Gesellschaftsform__c = this.additionalCompany.legalform;
        }
    }


    /*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 06/01/2018
    *  ModifedDate     : 05/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkDuplicates() {
        String exceptionString = CreditFactoryUtilities.checkDuplicates(this.sourceObject);
        if (String.isNotEmpty(exceptionString)) {
            this.sourceObject.StageName = 'CreditCheck';
            this.sourceObject.CF_Stage__c = 'Manual Scoring';
            update this.sourceObject;
            submitForApproval();
            throw new CreditFactoryException(exceptionString + '<br/>' + 'Opportunity was submitted for Approval.');
        }
    }


    /*******************************************************************************
    *  Name            : submitForApproval()
    *  Summary         : submit opportunity for approval in case of too high monthly credit limit
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void submitForApproval() {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(this.sourceObject.Id);
        request.setSubmitterId(UserInfo.getUserId()); 
        request.setSkipEntryCriteria(false);
        Approval.process(request); 
    }


    /*******************************************************************************
    *  Name            : changeToPendingDeposit()
    *  Summary         : change Opportunity Stage Name to Pending Sales - Deposit auto
    *  CreatedDate     : 10/11/2017
    *  ModifiedDate    : 03/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeToPendingDeposit() {
        checkDuplicates();
        try {
            this.sourceObject.StageName = 'Pending Sales – Deposit';
            this.sourceObject.put(this.opportunityMapping.Credit_Decision__c, 'Sicherheit verlangt');
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.put(this.opportunityMapping.Processed_by__c, 'Autoprocessed by Sales');
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.Pending_Deposit_by_CF__c = true;
            this.sourceObject.CF_Stage__c = 'Pending deposit';
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);
            this.sourceObject.put(this.opportunityMapping.Security_Level__c, this.securityLevel);
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.creditLimit);
            this.sourceObject.Security_To_Pay__c = 'Kaution';
            this.sourceObject.Security_Amount_To_Pay__c = this.deposit;
            
            if (this.company.legalform != null) {
                this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
            } else {
                this.sourceObject.Account.Gesellschaftsform__c = this.additionalCompany.legalform;
            }
            update this.sourceObject;
            update this.sourceObject.Account;
            CreditFactoryUtilities.displayMessage('error','Decision about deposit was accepted for your client.');
        } catch (Exception e) {
            throw new CreditFactoryException('Change to Pending Sales - Deposit failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    public PageReference changeToContractCheck() {
        return null;
    }


    /*******************************************************************************
    *  Name            : validateMandateType()
    *  Summary         : Check that mandate type is set correctly   
    *  CreatedDate     : 03/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateMandateType() {
        if (this.riskCategory == null) setRiskCategory(this.company.classRating);
        if ((this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && 
                this.sourceObject.Total_consumption_l_month__c > 1500 && this.riskCategory != 'Low' && this.sourceObject.Direct_Debit_Mandate_Type__c == 'Core')) {
            return false;
        }

        return true;
    }


    public static Set<String> soleTradersSet = new Set<String>{
        'Personal business- liberal profession',
        'Personal business- Natural person',
        'INDIVIDUAL ENTREPRISE',
        'Personal business- craftsman',
        'Personal business- commercial craftsman',
        'Personal business- commercial',
        'Artisans',
        'Single company',
        'Sole Proprietorship',
        'Freelance',
        'Auto entrepreneur',
        'Personal business- farmer',
        'Sole Proprietor'
    };

    public class PDFReportCreation implements Queueable, Database.AllowsCallouts {
        Set<String> companiesIdsSet;
        String opportunityId;
        String parentCompanyId;



        /*******************************************************************************
        *  Name            : PDFReportCreation(String companyId, String opportunityId)
        *  Summary         : Constructor
        *  CreatedDate     : 07/08/2019
        *  ModifiedDate    : 19/09/2019
        *  Parameters      : Set<String> companiesIdsSet - ids of Creditsafe companies, 
                             Opportunity opportunity - current Opportunity, String parentCompanyId - Id of parent company
        *  Returns         : -
        ******************************************************************************/
        public PDFReportCreation(Set<String> companiesIdsSet, Opportunity opportunity, String parentCompanyId) {
            this.companiesIdsSet = companiesIdsSet;
            this.opportunityId = opportunity.Id;
            this.parentCompanyId = parentCompanyId;
        }


        /*******************************************************************************
        *  Name            : execute(QueueableContext context)
        *  Summary         : update create pdf report
        *  CreatedDate     : 07/08/2019
        *  ModifiedDate    : 19/09/2019
        *  Parameters      : QueueableContext context - context that contains the job ID
        *  Returns         : void
        ******************************************************************************/
        public void execute(QueueableContext context) {
            List<Attachment> pdfAttachmentsList = new List<Attachment>();
            Opportunity opportunity;
            List<Opportunity> opportunitiesList = [
                SELECT Id
                FROM Opportunity
                WHERE Id = :this.opportunityId];
            if (! opportunitiesList.isEmpty()) {
                opportunity = opportunitiesList.get(0);
                String apiErrorMessage;
                try {
                    for (String companyId : this.companiesIdsSet) {
                        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Creditsafe');
                        Http http = new Http();
                        HttpRequest authRequest = CreditSafeWebservice.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
                        HttpResponse authResponse = http.send(authRequest);
                        apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(authResponse, 'auth');
                        if (! String.isEmpty(apiErrorMessage)) throw new CreditFactoryException(apiErrorMessage);
                        
                        CreditSafeAuthEntity authEntity = CreditSafeAuthEntity.parse(authResponse.getBody());
                        HttpRequest pdfReportRequest = CreditSafeWebservice.generatePDFReportRequest(authEntity.token, creditSystem.Endpoint__c, companyId);
                        HttpResponse pdfReportResponse = http.send(pdfReportRequest);
                        apiErrorMessage = CreditFactoryUtilities.checkCreditsafeAPIErrors(pdfReportResponse, 'report');
                        if (! String.isEmpty(apiErrorMessage)) throw new CreditFactoryException(apiErrorMessage);
                        
                        Blob pdfResponseBody = pdfReportResponse.getBodyAsBlob();
                        Attachment pdfReport = new Attachment();
                        pdfReport.ParentId = opportunity.Id;
                        if (companyId == this.parentCompanyId) {
                            pdfReport.Name = 'CreditsafeReportParent.pdf';
                        } else {
                            pdfReport.Name = 'CreditsafeReport.pdf';
                        }

                        pdfReport.Body = pdfResponseBody;
                        pdfAttachmentsList.add(pdfReport);

                        if (pdfAttachmentsList.size() == 2) break;
                    }

                    if (! pdfAttachmentsList.isEmpty()) insert pdfAttachmentsList;
                } catch (Exception e) {
                    if (! String.isEmpty(apiErrorMessage)) {
                        ExceptionLogger.sendException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                    } else if (e.getMessage() == 'Read timed out') {
                        ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.CREDITSAFE_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                                '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                    } else {
                        ExceptionLogger.sendException('<br/>Reason: Error on creating PDF report. ' + e.getMessage() + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                    }
                }

                try {
                    if (! pdfAttachmentsList.isEmpty() && pdfAttachmentsList.get(0).Id != null) {
                        opportunity.Credit_Factory_PDF_Report_Created__c = true;
                        update opportunity;
                    }
                } catch (Exception e) {
                    ExceptionLogger.sendException('<br/>Reason: Error on updating Opportunity with PDF. ' + e.getMessage() + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                }
            }
        }
    }
}