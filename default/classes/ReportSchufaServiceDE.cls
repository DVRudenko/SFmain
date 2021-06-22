public class ReportSchufaServiceDE implements CreditReport {
    private Opportunity sourceObject;
    private CreditCompany company;
    private List<CreditCompanyEmployee> companyEmployeesList;
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
    private transient String responseBodySchufa;
    private transient String responseBodyLexisNexis;
    private String creditSystemCompanyNumber;
    private Set<String> errorsSet;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    private String VAT_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','Umsatzsteuer_ID__c');
    public final String ADDRESS_ERROR = 'Address';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public final String PAYMENT_METHOD_ERROR = 'PaymentMethod';
    public final String PUBLIC_ENTITY_ERROR = 'PublicEntity';
    public final String EMAIL_RISK_ERROR = 'EmailRisk';
    public final String SWIFT_BIC_ERROR = 'SwiftBic';
    private Credit_Factory_Report__c existingCreditReport;
    public String userSource;
    private Decimal fuelPriceIndex;
    private String apiErrorMessage;
    private Boolean isWaitingReport = false;
    private Integer orderStatusCounter;
    private String errorToRequestOrder;


    /*******************************************************************************
    *  Summary         : set user source
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : userSource - user source to set
    *  Returns         : -
    ******************************************************************************/
    public void setUserSource(String userSource) {
        this.userSource = userSource;
    }


    /*******************************************************************************
    *  Summary         : return user source
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : user source
    ******************************************************************************/
    public String getUserSource() {
        return this.userSource;
    }


    /*******************************************************************************
    *  Summary         : Set custom settings for Opportunity and Account
    *  CreatedDate     : 06/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMapping() {
        try {
            accountMapping = Credit_Factory_Account__c.getInstance(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME);
            if (accountMapping == null) {
                throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }

        try {
            opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME);
            if (opportunityMapping == null) {
                throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Get required information from object
    *  CreatedDate     : 06/03/2020
    *  Parameters      : sfdcRecordId - id of Salesforce record.
    *  Returns         : -
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
                            ' (SELECT Contact.Id, Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name, Contact.Birthdate, ' +
                            ' IsPrimary, Role FROM OpportunityContactRoles), ' +
                            ' (SELECT Id FROM OpportunityLineItems WHERE Product2.Name = \'Inbound Type C\') ' +
                    ' FROM Opportunity' +
                    ' WHERE Id = :sfdcRecordId';
            sourceObject = Database.query(soql);
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Returns sObject that we need to use for credit request
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : sObject - Opportunity
    ******************************************************************************/
    public SObject getSourceObject() {
        return this.sourceObject;
    }


    /*******************************************************************************
    *  Summary         : Send request to Credit System to get company, employees and pdf report
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : response
    ******************************************************************************/
    public HttpResponse setXmlResponse(CreditSystem creditSystem, String companyId) {
        HttpRequest authRequest = CreditFactoryWebSchufa.generateAuthRequest(creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getEndpointUrl());
        Http http = new Http();
        HttpResponse authResponse = http.send(authRequest);
        this.apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(authResponse, 'auth');
        if (! String.isEmpty(this.apiErrorMessage)) {
            throw new CreditFactoryException(this.apiErrorMessage);
        }

        SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());

        if (this.isWaitingReport == false) {
            HttpRequest orderEconomyInfoRequest = CreditFactoryWebSchufa.generateOrderEconomyInfoRequest(authEntity.accessToken, creditSystem.getEndpointUrl(), companyId);
            HttpResponse orderEconomyInfoResponse = http.send(orderEconomyInfoRequest);
            Long timeOfOrder = Datetime.now().getTime();
            this.apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(orderEconomyInfoResponse, 'orderEconomyInfo');
            if (!String.isEmpty(this.apiErrorMessage)) {
                throw new CreditFactoryException(this.apiErrorMessage);
            }

            this.isWaitingReport = true;
        }

        Boolean completed = false;
        if (this.orderStatusCounter == null) {
            this.orderStatusCounter = 0;
        }

        if (this.isWaitingReport == true) {
            this.orderStatusCounter ++;
            HttpRequest orderStatusRequest = CreditFactoryWebSchufa.generateOrderStatusRequest(authEntity.accessToken, creditSystem.getEndpointUrl(), companyId);
            HttpResponse orderStatusResponse = http.send(orderStatusRequest);
            this.apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(orderStatusResponse, 'orderStatus');
            if (!String.isEmpty(this.apiErrorMessage)) {
                throw new CreditFactoryException(this.apiErrorMessage);
            }

            SchufaEntity orderStatusEntity = SchufaEntity.parse(orderStatusResponse.getBody());
            for (SchufaEntity.Order order : orderStatusEntity.order) {
                if (order.name == 'FullEconomyInfo') {
                    if (! order.reason.contains('Es werden derzeit keine Auskünfte zu diesem Unternehmen erteilt.')) {
                        completed = order.completed;
                    }
                    else {
                        this.errorToRequestOrder = CreditFactoryUtilities.SCHUFA_REPORT_NOT_AVAILABLE;
                        return null;
                    }

                    break;
                }
            }
        }

        HttpResponse reportResponse;
        if (completed == true || this.orderStatusCounter == 11) { // 10 times for 2 seconds
            this.isWaitingReport = false;
            HttpRequest reportRequest = CreditFactoryWebSchufa.generateReportRequest(authEntity.accessToken, creditSystem.getEndpointUrl(), companyId);
            reportResponse = http.send(reportRequest);
            this.apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(reportResponse, 'report');
            if (!String.isEmpty(this.apiErrorMessage)) {
                throw new CreditFactoryException(this.apiErrorMessage);
            }

            this.responseBodySchufa = reportResponse.getBody();
            this.creditSystemCompanyNumber = companyId;
        }

        return reportResponse;
    }


    /*******************************************************************************
    *  Summary         : Send request to LexisNexis to get risks and set response
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : lexisNexisSettings - LexisNexis settings
    *  Returns         : response
    ******************************************************************************/
    private HttpResponse setXmlResponseLexisNexis(LexisNexis_Settings__c lexisNexisSettings) {
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
        this.responseBodyLexisNexis = response.getBody();
        return response;
    }


    /*******************************************************************************
    *  Summary         : Set Company information from xml response body
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : -
    ******************************************************************************/
    public void setCompany(CreditSystem creditSystem, String companyId) {
        if (this.existingCreditReport != null) {
            this.company = getExistingReportCompany();
        } else {
            String serviceName = 'Schufa';
            try {
                setXmlResponse(creditSystem, companyId);
                if (this.errorToRequestOrder == CreditFactoryUtilities.SCHUFA_REPORT_NOT_AVAILABLE) {
                    this.company = new CreditCompany();
                    this.company.isWaitingReport = false;
                    return;
                }

                if (this.isWaitingReport == false) {
                    this.company = CreditFactoryWebSchufa.returnReportCompany(this.responseBodySchufa);
                    LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
                    if (lexisNexisSettings.Active__c == true) {
                        serviceName = 'LexisNexis';
                        HttpResponse lexisNexisResponse = setXmlResponseLexisNexis(lexisNexisSettings);
                        this.apiErrorMessage = CreditFactoryUtilities.checkLexisNexisAPIErrors(lexisNexisResponse);
                        if (!String.isEmpty(this.apiErrorMessage)) {
                            throw new CreditFactoryException(this.apiErrorMessage);
                        }

                        Dom.Document domDocLexisNexis = new Dom.Document();
                        domDocLexisNexis.load(this.responseBodyLexisNexis);
                        Dom.XmlNode xmlDomLexisNexis = domDocLexisNexis.getRootElement();
                        Dom.XmlNode emailRiskBody = LexisNexisWebservice.returnEmailRiskBody(xmlDomLexisNexis);
                        this.company = LexisNexisWebservice.returnReportCompany(emailRiskBody, this.company);
                    }
                }
                else {
                    this.company = new CreditCompany();
                    this.company.isWaitingReport = true;
                }
            } catch (Exception e) {
                if (this.company == null) {
                    this.company = new CreditCompany();
                }

                this.company.isWaitingReport = false;
                if (! String.isEmpty(this.apiErrorMessage)) {
                    this.apiErrorMessage += '<br/>Company Id: ' + companyId;
                    if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                    throw new CreditFactoryException(this.apiErrorMessage);
                }
                else if (e.getMessage().contains('Read timed out')) {
                    if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.SCHUFA_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                        '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                    throw new CreditFactoryException(CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
                }
                else {
                    if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                        '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                    throw new CreditFactoryException('Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : return unavailable report error
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : error
    ******************************************************************************/
    public String getErrorToOrderRequest() {
        return this.errorToRequestOrder;
    }


    public String getInternalId() {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Returns Company with Credit information
    *  CreatedDate     : 06/03/2020
    *  Parameters      : -
    *  Returns         : company
    ******************************************************************************/
    public CreditCompany getCompany() {
        return this.company;
    }


    /*******************************************************************************
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setEmployees() {
        try {
            if (this.existingCreditReport != null) {
                this.companyEmployeesList = getExistingReportCompanyEmployees();
            } else {
                if (this.errorToRequestOrder != CreditFactoryUtilities.SCHUFA_REPORT_NOT_AVAILABLE) {
                    this.companyEmployeesList = CreditFactoryWebSchufa.returnReportCompanyEmployees(this.responseBodySchufa);
                }
            }
        } catch (Exception e) {
            if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException('Set employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    public void updateEmployees(CreditSystem creditSystem, String companyId) {}


    /*******************************************************************************
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : employees
    ******************************************************************************/
    public List<Object> getEmployees() {
        return this.companyEmployeesList;
    }


    public void setAdditionalScoringData(String signerName) {}


    public void setAdditionalCompany(String companyId) {}


    public CreditCompany getAdditionalCompany() {
        return null;
    }


    public void setAdditionalCompanyEmployees(String companyId) {}


    public List<CreditCompanyEmployee> getAdditionalCompanyEmployees() {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Set existing in database credit reports
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        List<Credit_Factory_Report__c> creditReportsList = [
            SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, Turn_Over__c, Legal_Form__c, VAT_Number__c, Register_Number__c,
                Staff_Range__c, Credit_Limit__c, Credit_Limit_Currency__c, Date_of_Foundation__c, Age_of_Company__c, First_Legal_Form__c, Company_Status__c,
                Name, Street__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Email__c, Website__c, Solvency_Index__c, Company_Id__c, Name__c,
                Email_Exists__c, Domain_Exists__c, Email_Date__c, Domain_Date__c, Email_Status__c, Email_Risk__c, County_Court__c,
                Risk_Description__c, Risk_Advice__c, Fraud_Within_Industry__c, Fraud_Type__c, Total_Hits__c, Unique_Hits__c, Name_Match__c, Checked_Email__c,
                Principal_Activity_Code__c, Principal_Activity_Description__c,
                    (SELECT Type__c, Name, Date_of_Birth__c, Address__c, Participation_Date__c
                    FROM Credit_Factory_Report_Employees__r)
            FROM Credit_Factory_Report__c
            WHERE Opportunity__c = :this.sourceObject.Id AND CreatedDate > :Date.today().addMonths(-3)
            ORDER BY CreatedDate DESC
            LIMIT 1];
        if (! creditReportsList.isEmpty()) {
            this.existingCreditReport = creditReportsList.get(0);
        }
    }


    /*******************************************************************************
    *  Summary         : return company from Credit Factory Report object
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : company
    ******************************************************************************/
    private CreditCompany getExistingReportCompany() {
        CreditCompany company = new CreditCompany();
        company.creditSystemCompanyNumber = this.existingCreditReport.Credit_System_Number__c;
        company.referencenumber = this.existingCreditReport.Reference_Number__c;
        company.classRating = this.existingCreditReport.Class_Rating__c;
        company.turnOver = this.existingCreditReport.Turn_Over__c;
        company.legalform = this.existingCreditReport.Legal_Form__c;
        company.vatid = this.existingCreditReport.VAT_Number__c;
        company.registerNumber = this.existingCreditReport.Register_Number__c;
        company.countyCourt = this.existingCreditReport.County_Court__c;
        company.staffcompanyrange = this.existingCreditReport.Staff_Range__c;
        company.creditLimit = this.existingCreditReport.Credit_Limit__c;
        company.creditLimitCurrency = this.existingCreditReport.Credit_Limit_Currency__c;
        company.dateoffoundation = this.existingCreditReport.Date_of_Foundation__c;
        company.ageofcompany = this.existingCreditReport.Age_of_Company__c;
        company.status = this.existingCreditReport.Company_Status__c;
        company.name = this.existingCreditReport.Name;
        company.street = this.existingCreditReport.Street__c;
        company.postcode = this.existingCreditReport.Postcode__c;
        company.city = this.existingCreditReport.City__c;
        company.country = this.existingCreditReport.Country__c;
        company.phone = this.existingCreditReport.Phone__c;
        company.fax = this.existingCreditReport.Fax__c;
        company.email = this.existingCreditReport.Email__c;
        company.website = this.existingCreditReport.Website__c;
        company.identificationnumber = this.existingCreditReport.Company_Id__c;
        company.solvencyIndex = this.existingCreditReport.Solvency_Index__c;
        company.name = this.existingCreditReport.Name__c;
        company.emailExists = this.existingCreditReport.Email_Exists__c;
        company.domainExists = this.existingCreditReport.Domain_Exists__c;
        company.emailDate = this.existingCreditReport.Email_Date__c;
        company.domainDate = this.existingCreditReport.Domain_Date__c;
        company.emailStatus = this.existingCreditReport.Email_Status__c;
        company.emailRisk = this.existingCreditReport.Email_Risk__c;
        company.riskDescription = this.existingCreditReport.Risk_Description__c;
        company.riskAdvice = this.existingCreditReport.Risk_Advice__c;
        company.fraudWithinIndustry = this.existingCreditReport.Fraud_Within_Industry__c;
        company.fraudType = this.existingCreditReport.Fraud_Type__c;
        company.totalHits = this.existingCreditReport.Total_Hits__c;
        company.uniqueHits = this.existingCreditReport.Unique_Hits__c;
        company.nameMatch = this.existingCreditReport.Name_Match__c;
        company.checkedEmail = this.existingCreditReport.Checked_Email__c;
        company.principalActivityCode = this.existingCreditReport.Principal_Activity_Code__c;
        company.principalActivityDescription = this.existingCreditReport.Principal_Activity_Description__c;

        return company;
    }


    /*******************************************************************************
    *  Summary         : return company from Credit Factory Report Employee object
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : employees list
    ******************************************************************************/
    private List<CreditCompanyEmployee> getExistingReportCompanyEmployees() {
        List<CreditCompanyEmployee> employeesList = new List<CreditCompanyEmployee>();
        for (Credit_Factory_Report_Employee__c existingEmployee : this.existingCreditReport.Credit_Factory_Report_Employees__r) {
            CreditCompanyEmployee employee = new CreditCompanyEmployee();
            employee.type = existingEmployee.Type__c;
            employee.enumber = existingEmployee.Id;
            employee.ename = existingEmployee.Name;
            employee.dateofbirth = existingEmployee.Date_of_Birth__c;
            employee.address = existingEmployee.Address__c;
            employee.participationdate = existingEmployee.Participation_Date__c;
            employeesList.add(employee);
        }
        return employeesList;
    }


    /*******************************************************************************
    *  Summary         : Returns set of errors and display section to fix error on page
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : errors
    ******************************************************************************/
    public Set<String> getErrorsSet() {
        return this.errorsSet;
    }


    /*******************************************************************************
    *  Summary         : Compare information from Schufa with Salesforce
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validate() {
        errorsSet = new Set<String>();
        Boolean isValid = true;
        if ( ! validateAddress()) isValid = false;
        if ( ! validateCompanyName()) isValid = false;
        if ( ! validateVatNumber()) isValid = false;
        if ( ! validateLostOpportunities()) isValid = false;
        if ( ! validatePaymentMethod()) isValid = false;
        if ( ! validateEmailRisk()) isValid = false;
        if ( ! validateSwiftBic()) isValid = false;
        if ( ! validateBusinessCode()) isValid = false;
        validateContact();

        return isValid;
    }


    /*******************************************************************************
    *  Summary         : Compare Address information from Schufa with Salesforce
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns TRUE if no errors
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
        String schufaStreetAndHouseNumber = (company.street != null ? company.street : '') + ' ' + (company.housenumber != null ? company.housenumber : '');
        schufaStreetAndHouseNumber = schufaStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        String schufaHouseNumberAndStreet = (company.housenumber != null ? company.housenumber : '') + ' ' + (company.street != null ? company.street : '');
        schufaHouseNumberAndStreet = schufaHouseNumberAndStreet.removeStart(' ').removeEnd(' ');

        String billingPostalCode = sourceObject.Account.BillingPostalCode;
        String shippingPostalCode = sourceObject.Account.ShippingPostalCode;
        String schufaPostalcode = company.postcode;

        String billingCity = sourceObject.Account.BillingCity;
        String shippingCity = sourceObject.Account.ShippingCity;
        String schufaCity = company.city;

        if (! ((validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, schufaStreetAndHouseNumber) ||
            validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, schufaHouseNumberAndStreet)) &&
            validateCity(billingCity, shippingCity, schufaCity) &&
            validatePostalCode(billingPostalCode, shippingPostalCode, schufaPostalCode))) {
            errorsSet.add(ADDRESS_ERROR);
            String errorMessage = 'Account Billing and Shipping Addresses should be the same as Schufa address';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    public Boolean validateEmptyAddress() {
        return true;
    }


    /*******************************************************************************
    *  Summary         : Utility method for validateAddress();
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : billingStreet – Billing Street
                         shippingStreet – Shipping Street
                         schufaStreet – Street for Schufa
    *  Returns         : Boolean – returns TRUE if all streets are the same
    ******************************************************************************/
    public Boolean validateStreet(String billingStreet, String shippingStreet, String schufaStreet) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingStreet, shippingStreet) &&
                CreditFactoryUtilities.isStringsEquals(billingStreet, schufaStreet)) {
            isValid = true;
        }
        return isValid;
    }


    /*******************************************************************************
    *  Summary         : Utility method for validateAddress();
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : billingCity – Billing City
                         shippingCity – Shipping City
                         schufaCity – City for Schufa
    *  Returns         : returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validateCity(String billingCity, String shippingCity, String schufaCity) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingCity, shippingCity) &&
                CreditFactoryUtilities.isStringsEquals(billingCity, schufaCity)) {
            isValid = true;
        }
        return isValid;
    }


    /*******************************************************************************
    *  Name            : validatePostalCode(String billingPostalCode,
                                            String shippingPostalCode, String schufaPostalCode)
    *  Summary         : Utility method for validateAddress();
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingPostalCode – Billing PostalCode
                         String shippingPostalCode – Shipping PostalCode
                         String schufaPostalCode – PostalCode for Schufa
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validatePostalCode(String billingPostalCode,
                                      String shippingPostalCode, String schufaPostalCode) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingPostalCode, shippingPostalCode) &&
            CreditFactoryUtilities.isStringsEquals(billingPostalCode, schufaPostalCode)) {
            isValid = true;
        }
        return isValid;
    }


    public Boolean validateLegalForm() {
        return true;
    }



    /*******************************************************************************
    *  Summary         : Check that contact from Schufa exists in Salesforce
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
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
            if (contactRelation.Contact.FirstName != null) {
                firstName = CreditFactoryUtilities.replaceGermanCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
            }

            String lastName = CreditFactoryUtilities.replaceGermanCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
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
        for (CreditCompanyEmployee emp : this.companyEmployeesList) {
            if (emp.ename != null) {
                for (String lastName : contactsLastNamesSet) {
                    if (CreditFactoryUtilities.replaceGermanCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ').contains(lastName)) {
                        isContactExists = true;
                    }
                }
            }
        }

        if (this.userSource == 'E2E Long Form') {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                if (firstAndLastName == CreditFactoryUtilities.replaceGermanCharacters(this.company.Name).toUpperCase().replace('’', '\'')) {
                    isContactExists = true;
                }
            }
        } else if (validateCompanyName() == true) {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                if (firstAndLastName == CreditFactoryUtilities.replaceGermanCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'')) {
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

        if (errorsSet == null) errorsSet = new Set<String>(); // in case of E2E execution
        if ( ! isContactExists && ! (contactsEmailsDomainsSet.contains(companyEmailDomain) || contactsPhonesSet.contains(companyPhone) || contactsPhonesSet.contains(companyMobile) ||
                (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') && this.sourceObject.Contact_Role_Confirmation_Call__c != null)) {
            if (this.companyEmployeesList.isEmpty()) {
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
                    String errorMessage = 'Schufa Contact person doesn\'t exist in Account\'s Contacts';
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


    public void setParentCompanyId() {}

    public String getParentCompanyId() {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Check that Account Name is the same as Schufa Company Name
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
    ******************************************************************************/
    public Boolean validateCompanyName() {
        if ( ! CreditFactoryUtilities.isStringsEquals(sourceObject.Account.Name, company.name)) {
            errorsSet.add(COMPANY_NAME_ERROR);
            String errorMessage = 'Account Name and Schufa Name mismatch';
            CreditFactoryUtilities.displayMessage('error',errorMessage);

            return false;
        }

        return true;
    }

    public Boolean validateTaxId() {
        return true;
    }


    /*******************************************************************************
    *  Summary         : Compare Schufa vat number with Salesforce
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
    ******************************************************************************/
    public Boolean validateVatNumber() {
        if (company.vatid != null && company.vatid != '0' && company.vatid != 'nicht bekannt' && company.vatid != 'unbekannt' &&
                ! CreditFactoryUtilities.isStringsEquals(company.vatid, (String)sourceObject.getSobject('Account').get(this.accountMapping.VAT_Number__c))) {
            errorsSet.add(VAT_NUMBER_ERROR);
            String errorMessage = 'Account VAT number mismatch (' + CreditFactoryWebSchufa.CREDIT_SYSTEM_NAME +
                ' to Account ' + VAT_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : Check for Lost Opportunities relates to current Opportunity's
                         Account or its Contacts
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
    ******************************************************************************/
    private Boolean validateLostOpportunities() {
        List<Opportunity> relatedOpportunitiesList = [
                SELECT StageName, Gruende_verloren__c
                FROM Opportunity
                WHERE AccountId = :this.sourceObject.AccountId];
        List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
        for (Opportunity opportunity : relatedOpportunitiesList) {
            opportunitiesToCheckList.add(opportunity);
        }

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
    *  Summary         : Check available for autoprocess payment method.
    *  CreatedDate     : 27/03/2020 by Anton Buzak
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
    *  Summary         : Check if Company is in black list.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
    ******************************************************************************/
    public Boolean validateBlackList() {
        Map<String, Object> resultsMap = CreditFactoryUtilities.validateBlackList(this.sourceObject);
        return Boolean.valueOf(resultsMap.get('IsValid'));
    }


    /*******************************************************************************
    *  Summary         : Check fround risk by Email
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
    ******************************************************************************/
    public Boolean validateEmailRisk() {
        if ((this.company.emailRisk == 'Review' || this.company.emailRisk == 'High' || this.company.emailRisk == 'Very High') &&
                (this.company.emailExists == 'No' || this.company.domainExists == 'No' || this.company.uniqueHits != null &&
                Decimal.valueOf(this.company.uniqueHits) > 1 || String.isEmpty(this.company.domainDate) || Date.valueOf(this.company.domainDate).monthsBetween(Date.today()) > 6 ||
                this.company.dateOfFoundation == null || this.company.dateOfFoundation.length() != 10 || Date.newInstance(Integer.valueOf(this.company.dateOfFoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateOfFoundation.substring(3, 5)), Integer.valueOf(this.company.dateOfFoundation.substring(0, 2))).monthsBetween(Date.today()) > 6)) {
            errorsSet.add(EMAIL_RISK_ERROR);
            CreditFactoryUtilities.displayMessage('error', 'Contact Person has a high email risk. Please refer to Credit');
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Summary         : Compare Swift Bic from sales and from web service
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : returns true if no errors
    ******************************************************************************/
    public Boolean validateSwiftBic() {
        if (this.sourceObject.SWIFT_BIC__c != this.sourceObject.Requested_SWIFT_BIC__c && this.sourceObject.Zahlungsart__c == 'Lastschrift') {
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
    *  Summary         : Update address information in Account based on address from Schufa
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      :
    *  Returns         : -
    ******************************************************************************/
    public void doUpdateAddress() {
        String schufaStreetAndHouseNumber = (this.company.street != null ? this.company.street : '') + ' ' + (this.company.housenumber != null ? this.company.housenumber : '');
        schufaStreetAndHouseNumber = schufaStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = sourceObject.AccountId,
            ShippingStreet = schufaStreetAndHouseNumber,
            ShippingPostalCode = this.company.postcode,
            ShippingCity = this.company.city,
            BillingStreet = schufaStreetAndHouseNumber,
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


    public void doUpdateWithAdditionalAddress() {}


    public void doUpdateWithPostalAddress() {}


    public void doUpdateWithRegisteredAddress() {}


    /*******************************************************************************
    *  Summary         : Update Account name with Schufa Company Name
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : nameType - type of company name (registered, trading)
    *  Returns         : -
    ******************************************************************************/
    public void doUpdateCompanyName(String nameType) {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Name = company.name);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Name has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Account Name update failed.');
        }


        setSourceObject(sourceObject.Id);
    }


    public void doUpdateWithAdditionalCompanyName() {}


    public void doUpdateTaxId() {}


    /*******************************************************************************
    *  Summary         : Update Account Vat Number with Schufa Vat Number
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
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


    public void doUpdateTradeRegisterNumber() {}


    /*******************************************************************************
    *  Summary         : Update Opportunity SWIFT BIC with web service one
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
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
    *  Summary         : Update specific fields in Opportunity by Sales when all validations passed
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void updateDefaultFieldSetForValidRecord() {
        try {
            this.sourceObject.Updated_From_Credit_Factory__c = true;
            if (this.company.classRating != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Rating__c,
                    this.company.classRating);
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
                    this.company.dateoffoundation.substring(6, 10));
            }
            if (this.company.creditSystemCompanyNumber != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Number__c,
                    this.company.creditSystemCompanyNumber);
            }
            if (this.company.staffcompanyrange != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Number_of_employees__c,
                    this.company.staffcompanyrange);
            }
            if (this.company.solvencyIndex != null) {
                this.sourceObject.Bonitaetsindex__c = this.company.solvencyIndex;
            }
            this.sourceObject.put(
                this.opportunityMapping.Details_Correct__c,
                'Ja');
            if (this.sourceObject.CF_Stage__c != 'Pending Deposit') {
                this.sourceObject.CF_Stage__c = 'Report generated';
            }
            this.sourceObject.Last_CF_Errors__c = null;
            update this.sourceObject;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Update specific fields in Opportunity by Sales even with some validation errors
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  ModifiedDate    : -
    *  Returns         : -
    ******************************************************************************/
    public void updateDefaultFieldSetForRecord() {
        try {
            List<sObject> sOjObjectsListToUpdate = new List<sObject>();
            setRiskCategory(this.company.classRating);
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
            sOjObjectsListToUpdate.add(this.sourceObject);

            Contact primaryContact;
            for (OpportunityContactRole role : this.sourceObject.OpportunityContactRoles) {
                if (role.isPrimary == true) {
                    primaryContact = role.Contact;
                    break;
                }
            }

            if (primaryContact != null) {
                Date initialBirthdate = primaryContact.BirthDate;
                primaryContact.Birthdate = returnCfContactBirthdate(primaryContact);
                if (primaryContact.Birthdate != null && primaryContact.Birthdate != initialBirthdate) {
                    sOjObjectsListToUpdate.add(primaryContact);
                }
            }

            if (this.company.principalActivityCode != null) {
                this.sourceObject.Account.Branchencode__c = this.company.principalActivityCode;
            }
            if (this.company.principalActivityDescription != null) {
                this.sourceObject.Account.Branchentext__c = this.company.principalActivityDescription;
            }

            sOjObjectsListToUpdate.add(this.sourceObject.Account);
            update sOjObjectsListToUpdate;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : returns birth date
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : sfContact - primary contact in Salesforce
    *  Returns         : date of birth
    ******************************************************************************/
    private Date returnCfContactBirthdate(Contact sfContact) {
        Set<String> contactsFirstAndLastNamesSet = new Set<String>();
        String firstName = '';
        if (sfContact.FirstName != null) {
            firstName = CreditFactoryUtilities.replaceGermanCharacters(sfContact.FirstName).toUpperCase().replace('’', '\'');
        }

        String lastName = CreditFactoryUtilities.replaceGermanCharacters(sfContact.LastName).toUpperCase().replace('’', '\'');
        contactsFirstAndLastNamesSet.add((firstName + ' ' + lastName).removeStart(' '));
        contactsFirstAndLastNamesSet.add((lastName + ' ' + firstName).removeEnd(' '));
        Date cfContactDateOfBirth;
        for (CreditCompanyEmployee employee : this.companyEmployeesList) {
            if (employee.ename != null && contactsFirstAndLastNamesSet.contains(CreditFactoryUtilities.replaceGermanCharacters(employee.ename.toUpperCase().replace('’', '\''))) &&
                    employee.dateofbirth != null && employee.dateofbirth.length() == 10) {
                cfContactDateOfBirth = Date.newInstance(Integer.valueOf(employee.dateofbirth.substring(6, 10)), Integer.valueOf(employee.dateofbirth.substring(3, 5)),
                    Integer.valueOf(employee.dateofbirth.substring(0, 2)));
                break;
            }
        }

        return cfContactDateOfBirth;
    }


    /*******************************************************************************
    *  Summary         : Set fuel price index for Germany
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setFuelPriceIndex() {
        Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Germany');
        this.fuelPriceIndex = fuelPrice.Index__c;
    }


    /*******************************************************************************
    *  Summary         : Return buffer value
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : buffer
    ******************************************************************************/
    public Decimal getBuffer() {
        return this.buffer;
    }


    /*******************************************************************************
    *  Summary         : Calculate buffer
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : -
    ******************************************************************************/
    public void setBuffer(String classRating) {
        if (classRating != null) {
            if (classRating == '1' || classRating == '2') {
                this.buffer = 0.3;
            } else if (classRating == '3') {
                this.buffer = 0.2;
            } else if (classRating == '4' || classRating == '5') {
                this.buffer = 0.1;
            } else if (classRating == '6') {
                this.buffer = 0;
            }
        } else {
            this.buffer = 0.1;
        }
    }


    /*******************************************************************************
    *  Summary         : Return Risk Category
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : risk category
    ******************************************************************************/
    public String getRiskCategory() {
        return this.riskCategory;
    }


    /*******************************************************************************
    *  Summary         : Calculate Risk Category
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : -
    ******************************************************************************/
    public void setRiskCategory(String classRating) {
        if (classRating != null) {
            if (classRating == '1' || classRating == '2') {
                this.riskCategory = 'Low';
            } else if (classRating == '3') {
                this.riskCategory = 'Medium';
            } else if (classRating == '4' || classRating == '5') {
                this.riskCategory = 'High';
            } else if (classRating == '6') {
                this.riskCategory = 'Very';
            }
        } else {
            this.riskCategory = 'High';
        }
    }


    /*******************************************************************************
    *  Summary         : Return security level
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : security level
    ******************************************************************************/
    public Decimal getSecurityLevel() {
        return this.securityLevel;
    }


    public void setSecurityLevel(String classRating) {}


    /*******************************************************************************
    *  Summary         : Return Credit Limit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : CL 7+7
    ******************************************************************************/
    public Decimal getCreditLimitWeeklyPlus7() {
        if (this.creditLimitWeeklyPlus7 < 50) {
            this.creditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 + 50;
        }

        return (this.creditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Credit Limit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : -
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
    *  Summary         : Return Max Credit Limit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : maxCL 7+7
    ******************************************************************************/
    public Decimal getMaxCreditLimitWeeklyPlus7() {
        return (this.maxCreditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimitWeeklyPlus7() {
        try {
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
            } else if (this.company.classRating == '6') {
                setMaxCreditLimitWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 1
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating1() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
                }
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
                if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            } else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 2
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating2() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
                }
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
                if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            } else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 3
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating3() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
                }
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
                if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            } else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
                }
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
                if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            } else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 5
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating5() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                Decimal creditLimit600WeeklyPlus7 = (600 * this.fuelPriceIndex * ((7.0 + 7.0) / 30.0) * (1.0 + buffer)).setScale(2);
                if (this.creditLimitWeeklyPlus7 * 2 < creditLimit600WeeklyPlus7) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitWeeklyPlus7 = creditLimit600WeeklyPlus7;
                }
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 0;
            }
        }
        else {
            if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxCreditLimitWeeklyPlus7 = 8000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 6
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating6() {
        if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
            this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
        } else {
            this.maxCreditLimitWeeklyPlus7 = 8000;
        }
    }


    /*******************************************************************************
    *  Summary         : Return Max value of Credit Limit including deposit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max values 7+7
    ******************************************************************************/
    public Decimal getMaxValueWeeklyPlus7() {
        return (this.maxValueWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit including deposit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValueWeeklyPlus7() {
        try {
            if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
                this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxValueWeeklyPlus7 = 8000;
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Deposit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : deposit 7+7
    ******************************************************************************/
    public Decimal getDepositWeeklyPlus7() {
        if (this.depositWeeklyPlus7 > 0 && this.depositWeeklyPlus7 < 50) {
            this.depositWeeklyPlus7 = this.depositWeeklyPlus7 + 50;
        }

        return (this.depositWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDepositWeeklyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setDepositWeeklyPlus7Rating1();
            } else if (this.company.classRating == '2') {
                setDepositWeeklyPlus7Rating2();
            } else if (this.company.classRating == '3') {
                setDepositWeeklyPlus7Rating3();
            } else if (this.company.classRating == '4') {
                setDepositWeeklyPlus7Rating4();
            } else if (this.company.classRating == '5') {
                setDepositWeeklyPlus7Rating5();
            } else if (this.company.classRating == '6') {
                setDepositWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 1
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating1() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                this.depositWeeklyPlus7 = 0;
            }
            else {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 4;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 2
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating2() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                this.depositWeeklyPlus7 = 0;
            }
            else {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 4;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 3
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating3() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                this.depositWeeklyPlus7 = 0;
            }
            else {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 4;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
					! (errorsSet != null && errorsSet.contains(CONTACT_ERROR))) {
                this.depositWeeklyPlus7 = 0;
            }
            else {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            }
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelWeeklyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                this.securityLevelWeeklyPlus7 = 100;
            }
            else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 5
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating5() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (this.sourceObject.Total_consumption_l_month__c <= 600 && this.sourceObject.Anzahl_der_Karten__c <= 1 &&
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
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 6
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating6() {
        this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * (7.0 + 7.0 + 10.0) / (7.0 + 7.0);
        this.securityLevelWeeklyPlus7 = 110;
    }


    /*******************************************************************************
    *  Summary         : Return Credit Limit Bi-Weekly Plus 7
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : CL 7+7
    ******************************************************************************/
    public Decimal getCreditLimitBiWeeklyPlus7() {
        if (this.creditLimitBiWeeklyPlus7 < 50) {
            this.creditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 + 50;
        }

        return (this.creditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Credit Bi-Limit Weekly Plus 7
    *  CreatedDate     : 03/06/2020 by Anton Buzak
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
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : maxCL 15+7
    ******************************************************************************/
    public Decimal getMaxCreditLimitBiWeeklyPlus7() {
        return (this.maxCreditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimitBiWeeklyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setMaxCreditLimitBiWeeklyPlus7Rating1();
            }
            else if (this.company.classRating == '2') {
                setMaxCreditLimitBiWeeklyPlus7Rating2();
            }
            else if (this.company.classRating == '3') {
                setMaxCreditLimitBiWeeklyPlus7Rating3();
            }
            else if (this.company.classRating == '4') {
                setMaxCreditLimitBiWeeklyPlus7Rating4();
            }
            else if (this.company.classRating == '5') {
                setMaxCreditLimitBiWeeklyPlus7Rating5();
            }
            else if (this.company.classRating == '6') {
                setMaxCreditLimitBiWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Credit Limit Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 1
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating1() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
                if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 2
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating2() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
                if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 3
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating3() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
                if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 4
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
                if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitBiWeeklyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 5
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating5() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitBiWeeklyPlus7 = 0;
        }
        else {
            if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
                this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
            }
            else {
                this.maxCreditLimitBiWeeklyPlus7 = 8000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Bi-Weekly Plus 7 for Rating 6
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus7Rating6() {
        if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
            this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
        }
        else {
            this.maxCreditLimitBiWeeklyPlus7 = 8000;
        }
    }


    /*******************************************************************************
    *  Summary         : Return Max value of Credit Limit Bi-Weekly Plus 7 (slider)
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max value 15+7
    ******************************************************************************/
    public Decimal getMaxValueBiWeeklyPlus7() {
        return (this.maxValueBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit Bi-Weekly Plus 7 (slider)
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValueBiWeeklyPlus7() {
        try {
            if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
                this.maxValueBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
            }
            else {
                this.maxValueBiWeeklyPlus7 = 8000;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Value Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Deposit Bi-Weekly Plus 7
    *  CreatedDate     : 03/06/2020 by Anton Buzak
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
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDepositBiWeeklyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setDepositBiWeeklyPlus7Rating1();
            } else if (this.company.classRating == '2') {
                setDepositBiWeeklyPlus7Rating2();
            } else if (this.company.classRating == '3') {
                setDepositBiWeeklyPlus7Rating3();
            } else if (this.company.classRating == '4') {
                setDepositBiWeeklyPlus7Rating4();
            } else if (this.company.classRating == '5') {
                setDepositBiWeeklyPlus7Rating5();
            } else if (this.company.classRating == '6') {
                setDepositBiWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 1
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating1() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            }
            else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 2
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating2() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            }
            else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 3
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating3() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 4;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            } else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 4
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
            this.securityLevelBiWeeklyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitBiWeeklyPlus7 > recommendedCreditLimit + 500) {
                this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
                this.securityLevelBiWeeklyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
                this.securityLevelBiWeeklyPlus7 = 100;
            }
            else {
                this.depositBiWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 5
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating5() {
        this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
        this.securityLevelBiWeeklyPlus7 = 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Bi-Weekly Plus 7 for Rating 6
    *  CreatedDate     : 03/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus7Rating6() {
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
    *  CreatedDate     : 31/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : CL 30+7
    ******************************************************************************/
    public Decimal getCreditLimitMonthlyPlus7() {
        if (this.creditLimitMonthlyPlus7 < 50) {
            this.creditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 + 50;
        }

        return (this.creditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Credit Monthly Plus 7
    *  CreatedDate     : 31/07/2020 by Anton Buzak
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : -
    ******************************************************************************/
    public void setCreditLimitMonthlyPlus7(Decimal buffer) {
        try {
            this.creditLimitMonthlyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) *
                ((30.0 + 7.0)/30.0) * (1.0 + buffer)).setScale(2);
        }
        catch (Exception e) {
            throw new CreditFactoryException('Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Max Credit Limit Monthly Plus 7
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : maxCL 30+7
    ******************************************************************************/
    public Decimal getMaxCreditLimitMonthlyPlus7() {
        return (this.maxCreditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimitMonthlyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setMaxCreditLimitMonthlyPlus7Rating1();
            }
            else if (this.company.classRating == '2') {
                setMaxCreditLimitMonthlyPlus7Rating2();
            }
            else if (this.company.classRating == '3') {
                setMaxCreditLimitMonthlyPlus7Rating3();
            }
            else if (this.company.classRating == '4') {
                setMaxCreditLimitMonthlyPlus7Rating4();
            }
            else if (this.company.classRating == '5') {
                setMaxCreditLimitMonthlyPlus7Rating5();
            }
            else if (this.company.classRating == '6') {
                setMaxCreditLimitMonthlyPlus7Rating6();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 1
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating1() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
                if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 2
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating2() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
                if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 3
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating3() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
                if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 4
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating4() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
                if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
            else {
                if (recommendedCreditLimit + 500 < 8000) {
                    this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
                }
                else {
                    this.maxCreditLimitMonthlyPlus7 = 8000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 5
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating5() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.maxCreditLimitMonthlyPlus7 = 0;
        }
        else {
            if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
                this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
            }
            else {
                this.maxCreditLimitMonthlyPlus7 = 8000;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 6
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitMonthlyPlus7Rating6() {
        if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
            this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
        } else {
            this.maxCreditLimitMonthlyPlus7 = 8000;
        }
    }


    /*******************************************************************************
    *  Summary         : Return Max value of Credit Limit Monthly Plus 7 (slider)
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max value 30+7
    ******************************************************************************/
    public Decimal getMaxValueMonthlyPlus7() {
        return (this.maxValueMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit Monthly Plus 7 (slider)
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValueMonthlyPlus7() {
        try {
            if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
                this.maxValueMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
            }
            else {
                this.maxValueMonthlyPlus7 = 8000;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Value Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Return Deposit Monthly Plus 7
    *  CreatedDate     : 30/07/2020 by Anton Buzak
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
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDepositMonthlyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setDepositMonthlyPlus7Rating1();
            } else if (this.company.classRating == '2') {
                setDepositMonthlyPlus7Rating2();
            } else if (this.company.classRating == '3') {
                setDepositMonthlyPlus7Rating3();
            } else if (this.company.classRating == '4') {
                setDepositMonthlyPlus7Rating4();
            } else if (this.company.classRating == '5') {
                setDepositMonthlyPlus7Rating5();
            } else if (this.company.classRating == '6') {
                setDepositMonthlyPlus7Rating6();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit Bi-Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 1
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating1() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            }
            else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 2
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating2() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            }
            else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 3
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating3() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 4;
            } else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            } else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 4
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating4() {
        if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
            this.securityLevelMonthlyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.creditLimitMonthlyPlus7 > recommendedCreditLimit + 500) {
                this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
                this.securityLevelMonthlyPlus7 = 4;
            }
            else if (errorsSet != null && errorsSet.contains(CONTACT_ERROR)) {
                this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
                this.securityLevelMonthlyPlus7 = 100;
            }
            else {
                this.depositMonthlyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 5
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating5() {
        this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
        this.securityLevelMonthlyPlus7 = 100;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Monthly Plus 7 for Rating 6
    *  CreatedDate     : 30/07/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositMonthlyPlus7Rating6() {
        this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7 * (15.0 + 7.0 + 10.0) / (15.0 + 7.0);
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
    *  Summary         : Calculate payment details such as billing period, payment terms, max credit limit and deposit
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setPaymentDetails() {
        try {
            if ((this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3') &&
                    this.creditLimitMonthlyPlus7 < 8000 && this.depositMonthlyPlus7 == 0) {
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
            else if (this.creditLimitBiWeeklyPlus7 < 8000 && this.depositBiWeeklyPlus7 == 0) {
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
            else if ((this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3') &&
                    this.creditLimitMonthlyPlus7 < 8000) {
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
            else if (this.creditLimitBiWeeklyPlus7 < 8000) {
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
    *  Summary         : Return billing period
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : billing period
    ******************************************************************************/
    public Integer getBillingPeriod() {
        return this.billingPeriod;
    }


    /*******************************************************************************
    *  Summary         : Return payment terms.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : payment terms
    ******************************************************************************/
    public Integer getPaymentTerms() {
        return this.paymentTerms;
    }


    /*******************************************************************************
    *  Summary         : Calculate Credit Limit
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setCreditLimit() {
        try {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
                this.creditLimit = this.creditLimitMonthlyPlus7;
                if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitMonthlyPlus7 && this.depositMonthlyPlus7 == 0) {
                    this.creditLimit = this.creditLimit * 1.5;
                }
            }
            else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
                this.creditLimit = this.creditLimitBiWeeklyPlus7;
                if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitBiWeeklyPlus7 && this.depositBiWeeklyPlus7 == 0) {
                    this.creditLimit = this.creditLimit * 1.5;
                }
            }
            else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.creditLimit = this.creditLimitWeeklyPlus7;
                if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitWeeklyPlus7 && this.depositWeeklyPlus7 == 0) {
                    this.creditLimit = this.creditLimit * 1.5;
                }
            }

            if (this.creditLimit != null) {
                if (this.creditLimit < 50) {
                    this.creditLimit = this.creditLimit + 50;
                }

                this.creditLimit = (this.creditLimit / 100).round(System.RoundingMode.HALF_UP) * 100;
            }
        } catch (Exception e) {
            System.debug('DEBUG: Credit Factory === ' + e.getMessage());
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
    *  CreatedDate     : 06/03/2020 by Anton Buzak
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
    *  Summary         : Return max credit limit.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : get max CL
    ******************************************************************************/
    public Decimal getMaxCreditLimit() {
        return this.maxCreditLimit;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max value of Credit Limit including deposit
    *  CreatedDate     : 06/03/2020 by Anton Buzak
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
    *  Summary         : Return Max value of Credit Limit including deposit
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max value
    ******************************************************************************/
    public Decimal getMaxValue() {
        return this.maxValue;
    }


    /*******************************************************************************
    *  Summary         : Calculate deposit
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDeposit() {
        try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
                this.deposit = getDepositMonthlyPlus7();
                this.securityLevel = this.securityLevelBiWeeklyPlus7;
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
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : company - company from Credit System,
                         billingPeriod - selected billing period,
                         paymentTerms - selected payment terms,
                         creditLimit - changed CL value,
                         maxCreditLimit - max Credit Limit for selected billing period,
                         monthlyVolume - currency based on total consumption of liters,
                         totalConsumption - total consumption of liters,
                         opportunityId - id of related opportunity.
    *  Returns         : -
    ******************************************************************************/
    public void resetDeposit(CreditCompany company, Integer billingPeriod, Integer paymentTerms, Decimal creditLimit,
                             Decimal maxCreditLimit, Decimal monthlyVolume, Decimal totalConsumption,
                             String opportunityId) {
        try {
            if (company.classRating == '1') {
                this.deposit = resetDepositRating1(company, creditLimit, maxCreditLimit, company.errors);
            } else if (company.classRating == '2') {
                this.deposit = resetDepositRating2(company, creditLimit, maxCreditLimit, company.errors);
            } else if (company.classRating == '3') {
                this.deposit = resetDepositRating3(company, creditLimit, maxCreditLimit, company.errors);
            } else if (company.classRating == '4') {
                this.deposit = resetDepositRating4(company, creditLimit, maxCreditLimit, company.errors);
            } else if (company.classRating == '5') {
                this.deposit = resetDepositRating5(company, creditLimit, maxCreditLimit);
            } else if (company.classRating == '6') {
                this.deposit = resetDepositRating6(billingPeriod, creditLimit);
            }

            if (billingPeriod == 30 && creditLimit == company.creditLimitMonthlyPlus7) {
                this.deposit = company.depositMonthlyPlus7;
            }
            else if (billingPeriod == 15 && creditLimit == company.creditLimitBiWeeklyPlus7) {
                this.deposit = company.depositBiWeeklyPlus7;
            }
            else if (billingPeriod == 7 && creditLimit == company.creditLimitWeeklyPlus7) {
                this.deposit = company.depositWeeklyPlus7;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit recalculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }

    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 1 and changed CL value.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : company - company from Credit System,
                         creditLimit - changed CL value,
                         maxCreditLimit - max CL,
                         errors - set of errors
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating1(CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit, String errors) {
        if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), Integer.valueOf(company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
                return 0;
            }
            else {
                this.securityLevel = 100;
                return creditLimit;
            }
        }
        else {
            Decimal recommendedCreditLimit;
            if (company.creditLimit != null && company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
            } else {
                recommendedCreditLimit = 0;
            }

            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 4;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } else if (errors != null && errors.contains('Contact')) {
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
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : company - company from Credit System,
                         creditLimit - changed CL value,
                         maxCreditLimit - max CL,
                         errors - set of errors
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating2(CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit, String errors) {
        if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), Integer.valueOf(company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
                return 0;
            }
            else {
                this.securityLevel = 100;
                return creditLimit;
            }
        }
        else {
            Decimal recommendedCreditLimit;
            if (company.creditLimit != null && company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
            } else {
                recommendedCreditLimit = 0;
            }

            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 4;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } else if (errors != null && errors.contains('Contact')) {
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
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : company - company from Credit System,
                         creditLimit - changed CL value,
                         maxCreditLimit - max CL,
                         errors - set of errors
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating3(CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit, String errors) {
        if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), Integer.valueOf(company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
                return 0;
            }
            else {
                this.securityLevel = 100;
                return creditLimit;
            }
        }
        else {
            Decimal recommendedCreditLimit;
            if (company.creditLimit != null && company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
            } else {
                recommendedCreditLimit = 0;
            }

            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 4;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } else if (errors != null && errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } else {
                this.securityLevel = null;
                return 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 4 and changed CL value.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : company - company from Credit System,
                         creditLimit - current Credit Limit,
                         maxCreditLimit - max CL,
                         errors - set of errors
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating4(CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit, String errors) {
        if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), Integer.valueOf(company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (creditLimit <= maxCreditLimit) {
                this.securityLevel = null;
                return 0;
            }
            else {
                this.securityLevel = 100;
                return creditLimit;
            }
        }
        else {
            Decimal recommendedCreditLimit;
            if (company.creditLimit != null && company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
            } else {
                recommendedCreditLimit = 0;
            }

            if (creditLimit > recommendedCreditLimit + 500) {
                this.securityLevel = 4;
                return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
            } else if (errors != null && errors.contains('Contact')) {
                this.securityLevel = 100;
                return creditLimit;
            } else {
                this.securityLevel = null;
                return 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 5 and changed CL value.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : creditLimit - current Credit Limit,
                         maxCreditLimit - max CL
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating5(CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit) {
        if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), Integer.valueOf(company.dateoffoundation.substring(3, 5)),
                Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
            if (creditLimit <= maxCreditLimit) {
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
    *  Summary         : Reset deposit value for rating 6 and changed CL value
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : billingPeriod - selected billing period,
                         creditLimit - changed CL value,
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating6(Integer billingPeriod, Decimal creditLimit) {
        this.securityLevel = 110;
        return ((creditLimit * (billingPeriod + 7.0 + 10.0) / (billingPeriod + 7.0)) / 100).round(System.RoundingMode.HALF_UP) * 100;
    }


    /*******************************************************************************
    *  Summary         : Return deposit.
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : deposit
    ******************************************************************************/
    public Decimal getDeposit() {
        return this.deposit;
    }


    /*******************************************************************************
    *  Summary         : Set company decision
    *  CreatedDate     : 06/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDecision() {
        try {
            this.decision = new CreditFactoryDecision();
            if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
                // Positive Decisions without deposit
                this.decision.verdict = 'Yes';
                if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), Integer.valueOf(this.company.dateoffoundation.substring(3, 5)),
                        Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
                    this.decision.statusCode = '004'; // more than 1 card is no available
                }
                else {
                    this.decision.statusCode = '001'; // No Limits
                }
            } else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
                // Positive Decisions with deposit
                this.decision.verdict = 'Yes';
                this.decision.statusCode = '002'; // No Limits
            } else {
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
                        CreditFactoryUtilities.displayMessage('info', 'Billing Period can be set to ' + this.billingPeriod);
                        CreditFactoryUtilities.displayMessage('info', 'Payment Terms can be set to ' + this.paymentTerms);
                    }
                } else if (this.decision.statusCode == '002') {
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
            if (e.getMessage().contains('Opportunity was submitted for Approval.')) {
                throw new CreditFactoryException(e.getMessage());
            }
            else if (! String.isEmpty(this.apiErrorMessage)) {
                if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + this.apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                throw new CreditFactoryException(this.apiErrorMessage);
            }
            else if (e.getMessage().contains('Read timed out')) {
                if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.SCHUFA_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                    '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                throw new CreditFactoryException(CreditFactoryUtilities.SCHUFA_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
            }
            else {
                if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + 'Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                    '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
                throw new CreditFactoryException('Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Reset Company Decision
    *  CreatedDate     : 09/03/2020
    *  Parameters      : billingPeriod - selected billing period,
                         paymentTerms - selected payment terms,
                         deposit - selected deposit,
                         classRating - current company class rating,
                         numberOfCards - number of cards,
                         company - company from Credit System
    *  Returns         : void
    ******************************************************************************/
    public void resetDecision(Integer billingPeriod, Integer paymentTerms, Decimal deposit, String classRating, Decimal numberOfCards, CreditCompany company) {
        try {
            this.decision = new CreditFactoryDecision();
            // Positive Decisions
            this.decision.verdict = 'Yes';
            if (deposit == 0) {
                // Decisions without deposit
                if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), Integer.valueOf(company.dateoffoundation.substring(3, 5)),
                        Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) <= 18) {
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
    *  Summary         : Return decision.
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : decision
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
        if (this.userSource != 'E2E Long Form') {
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
    *  Summary         : Save information from Credit system to Salesforce
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void saveReports() {
        String errors = '';
        if (errorsSet != null) {
            for (String error : errorsSet) {
                errors += error + ', ';
            }
            errors = errors.removeEnd(', ');
        }
        if (this.company != null && this.companyEmployeesList != null && this.existingCreditReport == null) {
            String reportName = company.name;
            if (reportName.length() > 80) {
                reportName = reportName.substring(0,80);
            }
            // insert
            Credit_Factory_Report__c newReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = company.creditSystemCompanyNumber,
                Age_of_Company__c = company.ageofcompany,
                City__c = company.city,
                Company_Status__c = company.status,
                Country__c = company.country,
                County_Court__c = company.countyCourt,
                Credit_Limit__c = company.creditLimit,
                Credit_Limit_Currency__c = company.creditLimitCurrency,
                Date_of_Foundation__c = company.dateoffoundation,
                Email__c = company.email,
                Fax__c = company.fax,
                Legal_Form__c = company.legalform,
                Opportunity__c = sourceObject.Id,
                Phone__c = company.phone,
                Postcode__c = company.postcode,
                Register_Number__c = company.registerNumber,
                Staff_Range__c = company.staffcompanyrange,
                Street__c = company.street,
                Turn_Over__c = company.turnOver,
                VAT_Number__c = company.vatid,
                Website__c = company.website,
                Name = reportName,
                Company_Id__c = company.identificationnumber,
                Solvency_Index__c = company.solvencyIndex,
                Name__c = company.name,
                Email_Exists__c = company.emailExists,
                Domain_Exists__c = company.domainExists,
                Email_Date__c = company.emailDate,
                Domain_Date__c = company.domainDate,
                Email_Status__c = company.emailStatus,
                Email_Risk__c = company.emailRisk,
                Risk_Description__c = company.riskDescription,
                Risk_Advice__c = company.riskAdvice,
                Fraud_Within_Industry__c = company.fraudWithinIndustry,
                Fraud_Type__c = company.fraudType,
                Total_Hits__c = company.totalHits,
                Unique_Hits__c = company.uniqueHits,
                Name_Match__c = company.nameMatch,
                Checked_Email__c = company.checkedEmail,
                Principal_Activity_Code__c = this.company.principalActivityCode,
                Principal_Activity_Description__c = this.company.principalActivityDescription
            );

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
                    newReport.Credit_Limit_Bi_Weekly_7__c = getCreditLimitBiWeeklyPlus7();
                    newReport.Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitBiWeeklyPlus7();
                    newReport.Max_Value_Bi_Weekly_7__c = getMaxValueBiWeeklyPlus7();
                    newReport.Deposit_Bi_Weekly_7__c = getDepositBiWeeklyPlus7();
                    newReport.Credit_Limit_Bi_Weekly_7__c = getCreditLimitMonthlyPlus7();
                    newReport.Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitMonthlyPlus7();
                    newReport.Max_Value_Bi_Weekly_7__c = getMaxValueMonthlyPlus7();
                    newReport.Deposit_Bi_Weekly_7__c = getDepositMonthlyPlus7();
                    newReport.Decision_Verdict__c = this.decision.verdict;
                    newReport.Decision_Status_Code__c = this.decision.statusCode;
                    newReport.Errors__c = errors;
                }

            if (company.classRating != null) {
                newReport.Class_Rating__c = company.classRating;
            }

            try {
                insert newReport;
                List<Credit_Factory_Report_Employee__c> employeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
                for (CreditCompanyEmployee e : companyEmployeesList) {
                    employeesListToInsert.add(new Credit_Factory_Report_Employee__c(
                        Credit_Factory_Report__c = newReport.Id,
                        Address__c = e.address,
                        Date_of_Birth__c = e.dateofbirth,
                        Id__c = e.enumber,
                        Name = e.ename,
                        Type__c = e.type));
                }
                insert employeesListToInsert;
            } catch (Exception e) {
                CreditFactoryUtilities.displayMessage('error','Error on saving Credit Factory Report and Credit Factory Report Employees. Contact your administrator.');
                system.debug('Credit Factory === ' + e.getMessage());
                return;
            }
        } else {
            // update
            if (this.userSource == 'E2E Long Form') {
                Credit_Factory_Report__c existingReport = new Credit_Factory_Report__c(
                    Id = this.existingCreditReport.Id,
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
                    Errors__c = errors);
                try {
                    update existingReport;
                } catch (Exception e) {
                     System.debug('Credit Factory === ' + e.getMessage());
                     CreditFactoryUtilities.displayMessage('error', 'Error on updating Credit Factory Report. Contact your administrator.');
                }
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Change Billing Period and update fields in Opportunity
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public PageReference changeBillingPeriodBySales() {
        try {
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);

            if (this.maxCreditLimit != null) {
                this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
            }

            if (this.company.classRating == null) {
                this.sourceObject.put(this.opportunityMapping.Credit_System_Rating__c, '0-EX');
            }

            update this.sourceObject;
            return new PageReference('/' + this.sourceObject.Id);
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error','Change Billing Period failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            system.debug('Credit Factory === ' + e.getMessage());
            return null;
        }
    }


    public void updateOpportunityWithPDF(sObject sourceObject) {}


    /*******************************************************************************
    *  Summary         : Create Credit Company Report PDF Attachment in Salesforce and attach to Opportunity
    *  CreatedDate     : 09/03/2020
    *  Parameters      : opportunityId - source record Salesforce id
    *  Returns         : true if report attached to opportunity
    ******************************************************************************/
    public Boolean doCreateReportAttachment(String opportunityId) {
        // create pdf asynchronously
        if (! Test.isRunningTest()) { // uncommitted work pending
            if (this.existingCreditReport == null && this.companyEmployeesList != null && this.company != null) {
                System.enqueueJob(new PDFReportCreation(this.company.identificationnumber, this.sourceObject.Id));
            }
        }
        return false;
    }


    /*******************************************************************************
    *  Summary         : check possibility to automatically change Stage to Pending Sales - SEPA Confirmation
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : boolean
    ******************************************************************************/
    public Boolean isPendingSEPAPossible() {
        if ((this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && this.sourceObject.Einwilligung_Lastschriftverfahren__c == false) && validateMandateType()) {
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Summary         : check possibility to automatically change Stage to Closed Won
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : boolean
    ******************************************************************************/
    public Boolean isAutoCWPossible() {
        if ((this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Banküberweisung' || (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' &&
                this.sourceObject.Einwilligung_Lastschriftverfahren__c == true)) && validateMandateType()) {
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Summary         : Change Opportunity StageName to Pending Sales - SEPA Confirmation
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : opportunity url
    ******************************************************************************/
    public PageReference changeToPendingSEPAConfirmation() {
        checkDuplicates();
        Integer numberOfRelatedTankkartens = countNumberOfRelatedCards();
        Integer numberOfCardsField = 0;
        if (this.sourceObject.Anzahl_der_Karten__c != null) {
            numberOfCardsField = (Integer) this.sourceObject.Anzahl_der_Karten__c;
        }

        if (numberOfRelatedTankkartens != numberOfCardsField && this.sourceObject.Custom_PIN__c != true) {
            throw new CreditFactoryException('"Number of cards" field in the Opportunity is different from number of cards linked to the Opportunity.');
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
    *  Summary         : Change opportunity StageName to Closed Won
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : opportunity url
    ******************************************************************************/
    public PageReference changeToClosedWon() {
        checkDuplicates();
        Integer numberOfRelatedTankkartens = countNumberOfRelatedCards();
        Integer numberOfCardsField = 0;
        if (this.sourceObject.Anzahl_der_Karten__c != null) {
            numberOfCardsField = (Integer) this.sourceObject.Anzahl_der_Karten__c;
        }

        if (numberOfRelatedTankkartens != numberOfCardsField && this.sourceObject.Custom_PIN__c != true) {
            throw new CreditFactoryException('"Number of cards" field in the Opportunity is different from number of cards linked to the Opportunity.');
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
    *  Summary         : count number of cards related to the current Opportunity
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : number of cards objects
    ******************************************************************************/
    private Integer countNumberOfRelatedCards() {
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
    *  Summary         : prepare fields for Closed Won or Pending Sales
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : –
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
        this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
        if (this.maxCreditLimit != null) {
            this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
        }
        if (this.company.classRating == null) {
            this.sourceObject.put(this.opportunityMapping.Credit_System_Rating__c, '0-EX');
        }
        this.sourceObject.Last_CF_Errors__c = null;
        this.sourceObject.Security_To_Pay__c = null;
        this.sourceObject.Security_Amount_To_Pay__c = null;
        this.sourceObject.Pending_Deposit_by_CF__c = false;
        this.sourceObject.put(this.opportunityMapping.Security_Level__c, null);
        this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
    }


    /*******************************************************************************
    *  Summary         : if duplicates is existed then stop credit process
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : -
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
    *  Summary         : submit opportunity for approval in case of too high monthly credit limit
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void submitForApproval() {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(this.sourceObject.Id);
        request.setSubmitterId(UserInfo.getUserId());
        request.setSkipEntryCriteria(false);
        Approval.process(request);
    }


    /*******************************************************************************
    *  Summary         : change Opportunity Stage Name to Pending Sales - Deposit automatically
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : -
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
            if (this.company.classRating == null) {
                this.sourceObject.put(this.opportunityMapping.Credit_System_Rating__c, 'Keine Bonität');
            }
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.creditLimit);
            this.sourceObject.Security_To_Pay__c = 'Kaution';
            this.sourceObject.Security_Amount_To_Pay__c = this.deposit;

            this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
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
    *  Summary         : Check that mandate type is set correctly
    *  CreatedDate     : 09/03/2020
    *  Parameters      : -
    *  Returns         : boolean
    ******************************************************************************/
    public Boolean validateMandateType() {
        if (this.riskCategory == null) setRiskCategory(this.company.classRating);
        if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && this.sourceObject.Direct_Debit_Mandate_Type__c == 'Core' &&
                (this.riskCategory == 'Medium' && this.sourceObject.Total_consumption_l_month__c > 2500 ||
                (this.riskCategory == 'High' || this.riskCategory == 'Very') && this.sourceObject.Total_consumption_l_month__c > 1500)) {
            return false;
        } else {
            return true;
        }
    }
    
    
    public class PDFReportCreation implements Queueable, Database.AllowsCallouts {
        String companyId;
        String opportunityId;



        /*******************************************************************************
        *  Summary         : Constructor
        *  CreatedDate     : 10/03/2020
        *  Parameters      : companyId - schufa Id, 
                             opportunity - current Opportunity, 
                             parentCompanyId - Id of parent company
        *  Returns         : -
        ******************************************************************************/
        public PDFReportCreation(String companyId, String opportunityId) {
            this.companyId = companyId;
            this.opportunityId = opportunityId;
        }


        /*******************************************************************************
        *  Summary         : update create pdf report
        *  CreatedDate     : 10/03/2020
        *  Parameters      : context - context that contains the job ID
        *  Returns         : -
        ******************************************************************************/
        public void execute(QueueableContext context) {
            Attachment pdfAttachment = new Attachment();
            Opportunity opportunity;
            List<Opportunity> opportunitiesList = [
                SELECT Id
                FROM Opportunity
                WHERE Id = :this.opportunityId];
            if (! opportunitiesList.isEmpty()) {
                opportunity = opportunitiesList.get(0);
                String apiErrorMessage;
                try {
                    CreditSystem__c creditSystem = CreditSystem__c.getInstance('Schufa');
                    Http http = new Http();
                    HttpRequest authRequest = CreditFactoryWebSchufa.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
                    HttpResponse authResponse = http.send(authRequest);
                    String apiError = CreditFactoryUtilities.checkSchufaAPIErrors(authResponse, 'auth');
                    if (! String.isEmpty(apiError)) {
                        throw new CreditFactoryException(apiError);
                    }
                    
                    SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
                    HttpRequest pdfReportRequest = CreditFactoryWebSchufa.generatePdfReportRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
                    HttpResponse pdfReportResponse = http.send(pdfReportRequest);
                    apiErrorMessage = CreditFactoryUtilities.checkSchufaAPIErrors(pdfReportResponse, 'pdfReport');
                    if (! String.isEmpty(apiError)) {
                        throw new CreditFactoryException(apiError);
                    }

                    SchufaEntity pdfReportEntity = SchufaEntity.parse(pdfReportResponse.getBody());
                    Blob pdfResponseBody = EncodingUtil.base64Decode(pdfReportEntity.documentBytes);
                    if (pdfResponseBody != null) {
                        Attachment pdfReport = new Attachment();
                        pdfReport.ParentId = opportunity.Id;
                        pdfReport.Name = 'SchufaReport.pdf';
                        pdfReport.Body = pdfResponseBody;
                        insert pdfReport;
                    }
                } catch (Exception e) {
                    if (! String.isEmpty(apiErrorMessage)) {
                        ExceptionLogger.sendException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                    } else if (e.getMessage() == 'Read timed out') {
                        ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.SCHUFA_API_ERROR + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' +
                                '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                    } else {
                        ExceptionLogger.sendException('<br/>Reason: Error on creating PDF report. ' + e.getMessage() + '<br/>Opportunity Id: ' + opportunity.Id, String.valueOf(e.getStackTraceString()));
                    }
                }

                try {
                    if (pdfAttachment != null && pdfAttachment.Id != null) {
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