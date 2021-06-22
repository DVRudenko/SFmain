/*******************************************************************************
*  ReportCofaceService 
*  
*  Implementation of CreditReport for Coface Webservice. Get company from webservice, validation, 
*  flows for Credit and Sales users.
*
******************************************************************************/
public class ReportCofaceService implements CreditReport {
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
    private Decimal creditLimitBiWeeklyPlus14;
    private Decimal maxCreditLimitBiWeeklyPlus14;
    private Decimal maxValueBiWeeklyPlus14;
    private Decimal depositBiWeeklyPlus14;
    private Decimal securityLevelBiWeeklyPlus14;
    private Integer billingPeriod;
    private Integer paymentTerms;
    private Decimal creditLimit;
    private Decimal maxCreditLimit;
    private Decimal maxValue;
    private Decimal deposit;
    private Decimal fuelPriceIndex;
    private CreditFactoryDecision decision;
    private transient String xmlResponseBody;
    private transient Blob attachmentBody;
    private transient String xmlResponseBodyLexisNexis;
    private String creditSystemCompanyNumber;
    private Set<String> errorsSet;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping; 
    private String COMPANY_FORM = CreditFactoryUtilities.returnLabelOfField('Account','Gesellschaftsform__c');
    private String TAX_ID = CreditFactoryUtilities.returnLabelOfField('Account','Steuernummer__c');
    private String VAT_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','Umsatzsteuer_ID__c');
    private String TRADE_REGISTER_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','HR_Abteilung_HRA_HRB_und_HR_Nummer__c');
    public final String ADDRESS_ERROR = 'Address';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String TRADE_REGISTER_NUMBER_ERROR = 'TradeRegisterNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public final String EMAIL_RISK_ERROR = 'EmailRisk';
    public Credit_Factory_Report__c existingCreditReport;
    private String errorToRequestOrder;
    public Boolean isReportExists;
    public Boolean isUpdateTooOld;
    public String userSource;
    public String internalId;



    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : set user source    
    *  CreatedDate     : 08/11/2018
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
    *  CreatedDate     : 08/11/2018
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
    *  CreatedDate     : 13/02/2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void setMapping() {
        try {
            accountMapping = Credit_Factory_Account__c.getInstance(CofaceWebservice.CREDIT_SYSTEM_NAME);
            if (accountMapping == null) {
                throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }

        try {
            opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CofaceWebservice.CREDIT_SYSTEM_NAME);
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
    *  CreatedDate     : 13/02/2018
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
                    ' Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, (SELECT Contact.Id, Contact.Email, Contact.Phone, ' + 
                    ' Contact.LastName, Contact.FirstName, Contact.Name, IsPrimary, Role FROM OpportunityContactRoles) ' +
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
    *  CreatedDate     : 13/02/2018
    *  Parameters      : 
    *  Returns         : sObject - Opportunity 
    ******************************************************************************/
    public sObject getSourceObject() {
        return this.sourceObject;
    }


    /*******************************************************************************
    *  Name            : setXmlResponse(CreditSystem creditSystem, String companyId)
    *  Summary         : Get data for company (no need to create XML body because of webservice class)
    *  CreatedDate     : 13/02/2018
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page,
    *  Returns         : 
    ******************************************************************************/
    public HttpResponse setXmlResponse(CreditSystem creditSystem, String companyId) {
        HttpRequest request = CofaceWebservice.generateReportRequest(
            creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), 
            companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
        this.xmlResponseBody = response.getBody();
        this.creditSystemCompanyNumber = companyId;
        return response;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get pdf report
    *  CreatedDate     : 13/04/2020
    *  Parameters      : creditSystem - credit system,
                         companyId - parameter value from search page
    *  Returns         : response
    ******************************************************************************/
    public HttpResponse setPdfResponse(CreditSystem creditSystem, String companyId) {
        HttpRequest requestPdf = CofaceWebservice.generatePdfReportRequest(
            creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), 
            companyId);
        Http h = new Http();
        HttpResponse response = h.send(requestPdf);
        this.attachmentBody = CofaceWebservice.getBinaryAttachment(response.getBody());
        return response;
    }


    /*******************************************************************************
    *  Name            : getXmlResponse()
    *  Summary         : Returns xml reponse after report request sending
    *  CreatedDate     : 13/02/2018
    *  Parameters      : String - xml 
    *  Returns         : sObject
    ******************************************************************************/
    public String getXmlResponse() {
        return this.xmlResponseBody;
    }


    /*******************************************************************************
    *  Summary         : Send request to LexisNexis to get risks and set response    
    *  CreatedDate     : 02/05/2019
    *  Parameters      : LexisNexis_Settings__c lexisNexisSettings - LexisNexis settings
    *  Returns         : void
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
        this.xmlResponseBodyLexisNexis = response.getBody();
        return response;
    }


    /*******************************************************************************
    *  Name            : setCompany()
    *  Summary         : Send request for Company details
    *  CreatedDate     : 13/02/2018
    *  ModifiedDate    : 06/08/2019
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : 
    ******************************************************************************/
    public void setCompany(CreditSystem creditSystem, String companyId) {
        if (this.existingCreditReport != null) {
            this.company = getExistingReportCompany();
        } else {
            String apiErrorMessage;
			String serviceName = 'Coface';
            try {
                HttpResponse cofaceAvailabilityResponse = isCreditReportAvailable(creditSystem, companyId);
                apiErrorMessage = CreditFactoryUtilities.checkCofaceAPIErrors(cofaceAvailabilityResponse);
				if (! String.isEmpty(apiErrorMessage)) {
					throw new CreditFactoryException(apiErrorMessage);
				}
                
                Dom.Document domDocAvailability = new Dom.Document();
                domDocAvailability.load(cofaceAvailabilityResponse.getBody());
                Dom.XmlNode xmlDomAvailability = domDocAvailability.getRootElement();
                Dom.XmlNode globalBodyAvailability = CofaceWebservice.returnGlobalBody(xmlDomAvailability);
                isReportExists = CofaceWebservice.isCofaceReportProductAvailable(globalBodyAvailability);
                if ( ! isReportExists ) {
                    this.internalId = CofaceWebservice.returnInternalId(globalBodyAvailability);
                    this.errorToRequestOrder = 'AUTOMATIC CREDIT REPORT is not available.';
                    return;
                }
    
                HttpResponse cofaceXmlReportResponse = setXmlResponse(creditSystem, companyId);
                apiErrorMessage = CreditFactoryUtilities.checkCofaceAPIErrors(cofaceXmlReportResponse);
				if (! String.isEmpty(apiErrorMessage)) {
					throw new CreditFactoryException(apiErrorMessage);
				}
                
                HttpResponse cofacePdfReportResponse = setPdfResponse(creditSystem, companyId);
                apiErrorMessage = CreditFactoryUtilities.checkCofaceAPIErrors(cofacePdfReportResponse);
				if (! String.isEmpty(apiErrorMessage)) {
					throw new CreditFactoryException(apiErrorMessage);
				}
                
                String xml = this.xmlResponseBody;
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xml);
                Dom.XmlNode xmlDom = domDoc.getRootElement();
                Dom.XmlNode globalBody = CofaceWebservice.returnGlobalBody(xmlDom);
                Dom.XmlNode xmlReport = CofaceWebservice.returnInnerXmlReport(globalBody);
                String dateOfLastMajorUpdateString = CofaceWebservice.returnDateOfLastMajorUpdate(xmlReport);
                if (dateOfLastMajorUpdateString != null) {
                    Date dateOfLastMajorUpdate = Date.newInstance(Integer.valueOf(dateOfLastMajorUpdateString.substring(0, 4)), 
                        Integer.valueOf(dateOfLastMajorUpdateString.substring(4, 6)), Integer.valueOf(dateOfLastMajorUpdateString.substring(6, 8)));
                    if (dateOfLastMajorUpdate.daysBetween(Date.today().addYears(-1)) > 0) {
                        this.isUpdateTooOld = true;
                        this.internalId = CofaceWebservice.returnInternalId(globalBody);
                        this.errorToRequestOrder = 'Date of Last Major Update is too old.';
                        return;
                    }
                } else {
                    this.isUpdateTooOld = true;
                    this.internalId = CofaceWebservice.returnInternalId(globalBody);
                    this.errorToRequestOrder = 'Date of Last Major Update is unknown.';
                    return;
                }

                this.company = CofaceWebservice.returnReportCompany(globalBody, this.creditSystemCompanyNumber);

                LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
                if (lexisNexisSettings.Active__c == true) {
                    serviceName = 'LexisNexis';
                    HttpResponse lexisNexisResponse = setXmlResponseLexisNexis(lexisNexisSettings);
                    apiErrorMessage = CreditFactoryUtilities.checkLexisNexisAPIErrors(lexisNexisResponse);
                    if (! String.isEmpty(apiErrorMessage)) {
                        throw new CreditFactoryException(apiErrorMessage);
                    }
                    
                    Dom.Document domDocLexisNexis = new Dom.Document();
                    domDocLexisNexis.load(this.xmlResponseBodyLexisNexis);
                    Dom.XmlNode xmldomLexisNexis = domDocLexisNexis.getRootElement();
                    Dom.XmlNode emailRiskBody = LexisNexisWebservice.returnEmailRiskBody(xmldomLexisNexis);
                    this.company = LexisNexisWebservice.returnReportCompany(emailRiskBody, this.company);
                }
            } catch (Exception e) {
                if (! String.isEmpty(apiErrorMessage)) {
					ExceptionLogger.sendException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
					throw new CreditFactoryException(apiErrorMessage);
				}
				else if (e.getMessage().contains('Read timed out')) {
					if (this.userSource != 'E2E Long Form') ExceptionLogger.sendException('<br/>Reason: ' + CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
						'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
					throw new CreditFactoryException(CreditFactoryUtilities.returnServiceError(serviceName) + ' ' + CreditFactoryUtilities.CONTACT_ADMIN + ' Read timed out.');
				}
				else {
					ExceptionLogger.sendException('<br/>Reason: ' + 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + ' ' + e.getMessage() + '. ' + 
						'<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
					throw new CreditFactoryException('Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
				}
            }
        }
    }


    /*******************************************************************************
    *  Name            : isCreditReportAvailable(CreditSystem creditSystem, String companyId)
    *  Summary         : API Call: Check availability of AUTOMATIC CREDIT REPORT report (Code: 761)
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 08/01/2019
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public HttpResponse isCreditReportAvailable(CreditSystem creditSystem, String companyId) {
        HttpRequest request = CofaceWebservice.generateRequestForCheckAvailability(creditSystem.getEndpointUrl(), 
            creditSystem.getUserName(), creditSystem.getUserPassword(), companyId);
        Http h = new Http();
        HttpResponse response = h.send(request);
        return response;
    }


    /*******************************************************************************
    *  Name            : getErrorToRequestOrder()
    *  Summary         : Return error for order request. 
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getErrorToOrderRequest() {
        return this.errorToRequestOrder;
    }  


    /*******************************************************************************
    *  Name            : getInternalId()
    *  Summary         : Returm Internal Id.    
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getInternalId() {
        return this.internalId;
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
    *  Name            : setEmployees()
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 23/02/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void setEmployees() {
        try {
            if (this.existingCreditReport != null) {
                this.companyEmployeesList = getExistingReportCompanyEmployees();
            } else {
                if (this.isReportExists == false || this.isUpdateTooOld == true) {
                    return;
                }

                String xml = this.xmlResponseBody;
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xml);
                Dom.XMLNode xmldom = domDoc.getRootElement();
                Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
                Dom.XMLNode xmlReport = CofaceWebservice.returnInnerXmlReport(globalBody);
                this.companyEmployeesList = CofaceWebservice.returnReportCompanyEmployees(xmlReport);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
			throw new CreditFactoryException('Set employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    public void updateEmployees(CreditSystem creditSystem, String companyId) {}


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


    public void setAdditionalCompany(String companyId) {}


    public CreditCompany getAdditionalCompany() {
        return null;
    }


    public void setAdditionalCompanyEmployees(String companyId) {}


    public List<CreditCompanyEmployee> getAdditionalCompanyEmployees() {
        return null;
    }


    /*******************************************************************************
    *  Name            : setExistingCreditReports()
    *  Summary         : Return company employees data.     
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 16/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, 
                        Turn_Over__c, Legal_Form__c, VAT_Number__c, Tax_Id__c, Trade_Register_Number__c, Date_Legal_Form__c, Register_Number__c,
                        Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, 
                        Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c,
                        Age_of_Company__c, First_Legal_Form__c, Company_Status__c, Name, Trade_Name__c, 
                        Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                        Email__c, Website__c, Date_Of_Last_Major_Update__c, Name__c, Profit_Loss_Last_Year__c, 
                        Profit_Loss_Year_Before_Last__c, Turn_Over_Last_Year__c, Email_Exists__c, Domain_Exists__c, 
                        Email_Date__c, Domain_Date__c, Email_Status__c, Email_Risk__c, Risk_Description__c, Risk_Advice__c, 
                        Fraud_Within_Industry__c, Fraud_Type__c, Total_Hits__c, Unique_Hits__c, Name_Match__c, Checked_Email__c,
                       (SELECT Type__c, Name, Date_of_Birth__c, Address__c, Participation_Date__c, 
                               Company_Id__c, Company_Type__c, Company_Role__c, Reported__c 
                        FROM Credit_Factory_Report_Employees__r)
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :this.sourceObject.Id AND 
                      CreatedDate > :Date.today().addMonths(-3)
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if ( ! creditReportsList.isEmpty() ) {
            this.existingCreditReport = creditReportsList.get(0);
        }
    }



    /*******************************************************************************
    *  Name            : getExistingReportCompany()
    *  Summary         : Return company from Credit Factory Report object.
    *  CreatedDate     : 23/10/2017
    *  ModifiedDate    : 16/05/2019
    *  Parameters      : -
    *  Returns         : CreditCompany
    ******************************************************************************/
    private CreditCompany getExistingReportCompany() {
        CreditCompany company = new CreditCompany();
        company.creditSystemCompanyNumber = this.existingCreditReport.Credit_System_Number__c;
        company.referencenumber = this.existingCreditReport.Reference_Number__c;
        company.classRating = this.existingCreditReport.Class_Rating__c;
        company.turnOver = this.existingCreditReport.Turn_Over__c;
        company.legalform = this.existingCreditReport.Legal_Form__c;
        company.vatid = this.existingCreditReport.VAT_Number__c;
        company.taxnumber = this.existingCreditReport.Tax_Id__c;
        company.tradeRegisterNumber = this.existingCreditReport.Trade_Register_Number__c;
        company.datelegalform = this.existingCreditReport.Date_Legal_Form__c;
        company.registerNumber = this.existingCreditReport.Register_Number__c;
        company.datelastregisterentry = this.existingCreditReport.Date_Last_Register_Entry__c;
        company.countyCourt = this.existingCreditReport.County_Court__c;
        company.paymentBehaviour = this.existingCreditReport.Payment_Behaviour__c;
        company.staffcompanyrange = this.existingCreditReport.Staff_Range__c;
        company.creditLimit = this.existingCreditReport.Credit_Limit__c;
        company.creditLimitCurrency = this.existingCreditReport.Credit_Limit_Currency__c;
        company.creditDecision = this.existingCreditReport.Credit_Decision__c;
        company.dateoffoundation = this.existingCreditReport.Date_of_Foundation__c;
        company.ageofcompany = this.existingCreditReport.Age_of_Company__c;
        company.firstlegalform = this.existingCreditReport.First_Legal_Form__c;
        company.status = this.existingCreditReport.Company_Status__c;
        company.name = this.existingCreditReport.Name__c;
        company.tradename = this.existingCreditReport.Trade_Name__c;
        company.street = this.existingCreditReport.Street__c;
        company.housenumber = this.existingCreditReport.Housenumber__c;
        company.postcode = this.existingCreditReport.Postcode__c;
        company.city = this.existingCreditReport.City__c;
        company.country = this.existingCreditReport.Country__c;
        company.phone = this.existingCreditReport.Phone__c;
        company.fax = this.existingCreditReport.Fax__c;
        company.mobile = this.existingCreditReport.Mobile__c;
        company.email = this.existingCreditReport.Email__c;
        company.website = this.existingCreditReport.Website__c;
        company.identificationnumber = this.existingCreditReport.Credit_System_Number__c;
        company.dateOfLastMajorUpdate = this.existingCreditReport.Date_Of_Last_Major_Update__c;
        company.profitLossLastYear = this.existingCreditReport.Profit_Loss_Last_Year__c;
        company.profitLossYearBeforeLast = this.existingCreditReport.Profit_Loss_Year_Before_Last__c;
        company.turnOverLastYear = this.existingCreditReport.Turn_Over_Last_Year__c;
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
        return company;
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompanyEmployees()
    *  Summary         : return company from Credit Factory Report Employee object      
    *  CreatedDate     : 23/09/2017
    *  ModifiedDate    : 20/04/2017
    *  Parameters      : -
    *  Returns         : List<CreditCompanyEmployee>
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
            employee.companyId = existingEmployee.Company_Id__c;
            employee.companyType = existingEmployee.Company_Type__c;
            employee.companyRole = existingEmployee.Company_Role__c;
            employee.Reported = existingEmployee.Reported__c;
            employeesList.add(employee);
        }
        return employeesList;
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
    *  Summary         : Compare information from Coface with Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 05/11/2019
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validate() {
        errorsSet = new Set<String>();
        Boolean isValid = true;
        if ( ! validateAddress()) isValid = false;
        if ( ! validateLegalForm()) isValid = false;
        if ( ! validateCompanyName()) isValid = false;
        if ( ! validateTaxId()) isValid = false;
        if ( ! validateVatNumber()) isValid = false;
        if ( ! validateTradeRegisterNumber()) isValid = false;
        if ( ! validateLostOpportunities()) isValid = false;
        if ( ! validateEmailRisk()) isValid = false;
        validateContact();

        return isValid;
    }


    /*******************************************************************************
    *  Name            : validateAddress()
    *  Summary         : Compare Address information from Coface with Salesforce
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
        String crefoStreetAndHouseNumber = (company.street != null ? company.street : '') + ' ' + (company.housenumber != null ? company.housenumber : '');
        crefoStreetAndHouseNumber = crefoStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        String crefoHouseNumberAndStreet = (company.housenumber != null ? company.housenumber : '') + ' ' + (company.street != null ? company.street : '');
        crefoHouseNumberAndStreet = crefoHouseNumberAndStreet.removeStart(' ').removeEnd(' ');
        
        String billingPostalCode = sourceObject.Account.BillingPostalCode;
        String shippingPostalCode = sourceObject.Account.ShippingPostalCode;
        String crefoPostalcode = company.postcode;

        String billingCity = sourceObject.Account.BillingCity;
        String shippingCity = sourceObject.Account.ShippingCity;
        String crefoCity = company.city;
        
        if (! ((validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, crefoStreetAndHouseNumber) ||
            validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, crefoHouseNumberAndStreet)) &&
            validateCity(billingCity, shippingCity, crefoCity) && 
            validatePostalCode(billingPostalCode, shippingPostalCode, crefoPostalCode))) {
            errorsSet.add(ADDRESS_ERROR);
            String errorMessage = 'Account Billing and Shipping Addresses should be the same as ' +
                CofaceWebservice.CREDIT_SYSTEM_NAME + ' address';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    public Boolean validateEmptyAddress() {
        return true;
    }


    public void doUpdateWithAdditionalAddress() {}


    /*******************************************************************************
    *  Name            : validateStreet(String billingStreet, String shippingStreet, String crefoStreet)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingStreet – Billing Street 
                         String shippingStreet – Shipping Street 
                         String crefoStreet – Street for Coface 
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
                         String crefoCity – City for Coface 
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
                         String crefoPostalCode – PostalCode for Coface 
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
    *  Name            : validateHousenumber(String billingHousenumber, String shippingHousenumber, String crefoHousenumber)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingHousenumber – Billing Housenumber 
                         String shippingHousenumber – Shipping Housenumber 
                         String crefoHousenumber – House number for Coface 
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validateHouseNumber(String billingHousenumber, String shippingHousenumber, String crefoHousenumber) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingHousenumber,shippingHousenumber) && 
            CreditFactoryUtilities.isStringsEquals(billingHousenumber,crefoHousenumber)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validateLegalForm()
    *  Summary         : Compare Legal Form information from Coface with Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateLegalForm() {
        return true;
    }


    /*******************************************************************************
    *  Name            : validateContact()
    *  Summary         : Check that contact from Coface exists in Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 29/04/2019
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
            if (contactRelation.Contact.FirstName != null) {
                firstName = CreditFactoryUtilities.replaceHungarianCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
            }

            String lastName = CreditFactoryUtilities.replaceHungarianCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
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
                    if (CreditFactoryUtilities.replaceHungarianCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ').contains(lastName)) {
                        isContactExists = true;
                    }
                }
            }
        }

        if (this.userSource == 'E2E Long Form') {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                if (firstAndLastName == CreditFactoryUtilities.replaceHungarianCharacters(this.company.Name).toUpperCase().replace('’', '\'')) {
                    isContactExists = true;
                }
            }
        } else if (validateCompanyName() == true) {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                if (firstAndLastName == CreditFactoryUtilities.replaceHungarianCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'')) {
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

        if (this.errorsSet == null) this.errorsSet = new Set<String>(); // in case of E2E execution
        if ( ! isContactExists && ! (contactsEmailsDomainsSet.contains(companyEmailDomain) || contactsPhonesSet.contains(companyPhone) || contactsPhonesSet.contains(companyMobile) ||
                (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') && this.sourceObject.Contact_Role_Confirmation_Call__c != null)) {
            if (this.companyEmployeesList.isEmpty()) {
                this.errorsSet.add(CONTACT_ERROR);
                if (this.userSource != 'E2E Long Form') {
                    String errorMessage = 'No directors information for this company';
                    CreditFactoryUtilities.displayMessage('error', errorMessage);
                    if ((primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative')) {
                        this.errorsSet.add(CONTACT_ROLE_ERROR);
                        CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
                    }
                }

                return false;
            } else {
                this.errorsSet.add(CONTACT_ERROR);
                if (this.userSource != 'E2E Long Form') {
                    String errorMessage = CofaceWebservice.CREDIT_SYSTEM_NAME + ' Contact person doesn\'t exist in Account\'s Contacts';
                    CreditFactoryUtilities.displayMessage('error', errorMessage);
                    if ((primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative')) {
                        this.errorsSet.add(CONTACT_ROLE_ERROR);
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
    *  Summary         : Compare Coface tax id with Salesforce    
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateTaxId() {
        if (company.taxnumber != '' && company.taxnumber != null && ! CreditFactoryUtilities.isStringsEquals(company.taxnumber, (String)sourceObject.getSobject('Account').get(this.accountMapping.Tax_Id__c))) {
            errorsSet.add(TAX_ID_ERROR);
            String errorMessage = 'Account Tax ID mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + TAX_ID + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateVatNumber()
    *  Summary         : Compare Coface tax id with Salesforce    
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateVatNumber() {
        if (company.vatid != null && ! CreditFactoryUtilities.isStringsEquals(company.vatid, (String)sourceObject.getSobject('Account').get(this.accountMapping.VAT_Number__c))) {
            errorsSet.add(VAT_NUMBER_ERROR);
            String errorMessage = 'Account VAT number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + VAT_NUMBER + ')';
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
            String errorMessage = 'Account Trade Register Number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + TRADE_REGISTER_NUMBER + ')';
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
    *  CreatedDate     : 08/11/2018
    *  Parameters      : 
    *  Returns         : validation result
    ******************************************************************************/
    public Boolean validateBlackList() {
        Map<String, Object> resultsMap = CreditFactoryUtilities.validateBlackList(this.sourceObject);
		return Boolean.valueOf(resultsMap.get('IsValid'));
    }


    public void setParentCompanyId() {}


    public String getParentCompanyId() {
        return null;
    }


    /*******************************************************************************
    *  Name            : validateCompanyName()
    *  Summary         : Check that Account Name is the same as Company Name from Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateCompanyName() {
        if ( ! CreditFactoryUtilities.isStringsEquals(sourceObject.Account.Name, company.tradename)) {
            errorsSet.add(COMPANY_NAME_ERROR);
            String errorMessage = 'Account Name and ' + CofaceWebservice.CREDIT_SYSTEM_NAME + ' Name mismatch';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
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
				this.company.dateoffoundation == null || Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) > 6)) {
    		errorsSet.add(EMAIL_RISK_ERROR);
			CreditFactoryUtilities.displayMessage('error', 'Contact Person has a high email risk. Please refer to Credit');
    		return false;
    	}

    	return true;
    }
    
    public Boolean validateSwiftBic() {
    	return true;
    }
    
    
    public Boolean validateBusinessCode() {
		return true;
	}


    /*******************************************************************************
    *  Name            : doUpdateAddress()
    *  Summary         : Update address information in Account based on address from Coface
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


    public void doUpdateWithPostalAddress() {}


    public void doUpdateWithRegisteredAddress() {}


    /*******************************************************************************
    *  Name            : doUpdateCompanyName(String nameType)
    *  Summary         : Update Account name with Coface Company Name
    *  CreatedDate     : 11/11/2016
    *  ModifiedDate    : 27/09/2019
	*  Parameters      : String nameType - type of company name (registered, trading)
	*  Returns         : void
	******************************************************************************/
    public void doUpdateCompanyName(String nameType) {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Name = company.tradename);

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


    /*******************************************************************************
    *  Name            : doUpdateTaxId()
    *  Summary         : Update Account Tax Id with Coface Tax Id
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
    *  Summary         : Update Account Vat Number with Coface Vat Number
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
    
    
    public void doUpdateSwiftBic() {}


    /*******************************************************************************
    *  Name            : updateDefaultFieldSetForValidRecord()
    *  Summary         : Update specific fields in Opportunity by Sales
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : void
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
                if (this.company.dateoffoundation.length() == 10) {
                    this.sourceObject.put(
                        this.opportunityMapping.Year_of_foundation__c,
                        this.company.dateoffoundation.substring(6, 10));
                } else if (this.company.dateoffoundation.length() == 4) {
                    this.sourceObject.put(
                        this.opportunityMapping.Year_of_foundation__c,
                        this.company.dateoffoundation.substring(0, 4));
                }
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
            this.sourceObject.put(
                this.opportunityMapping.Details_Correct__c,
                'Ja');
            if (this.sourceObject.CF_Stage__c != 'Pending Deposit') {
                this.sourceObject.CF_Stage__c = 'Report generated';
            }
            this.sourceObject.Last_CF_Errors__c = null;
            update this.sourceObject;
            update this.sourceObject.Account;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : updateDefaultFieldSetForInvalidRecord()
    *  Summary         : Update specific fields in Opportunity by Sales even with some validation errors    
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : 01/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateDefaultFieldSetForRecord() {
        if (this.company.profitLossLastYear != null && Decimal.valueOf(this.company.profitLossLastYear) != null) {
            this.sourceObject.Profit_loss_last_year__c = Decimal.valueOf(this.company.profitLossLastYear);
        }
        if (this.company.profitLossYearBeforeLast != null && Decimal.valueOf(this.company.profitLossYearBeforeLast) != null) {
            this.sourceObject.Profit_loss_year_before_last__c = Decimal.valueOf(this.company.profitLossYearBeforeLast);
        }
        if (this.company.turnOverLastYear != null && Decimal.valueOf(this.company.turnOverLastYear) != null) {
            this.sourceObject.Turnover_last_year__c = Decimal.valueOf(this.company.turnOverLastYear);
        }
        setRiskCategory(this.company.classRating);
        this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
        update this.sourceObject;
    }



     /*******************************************************************************
    *  Name            : setFuelPriceIndex()
    *  Summary         : Calculate fuel price
    *  CreatedDate     : 4/09/2020
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    public void setFuelPriceIndex() {
        Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance('Hungary');
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
    *  ModifiedDate    : 13/08/2019
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setBuffer(String classRating) {
        if (classRating != null) {
            if (classRating == '0' || classRating == '1' || classRating == '2' || classRating == '3') {
                this.buffer = 0;
            } 
            else if (classRating == '4'|| classRating == '5') {
                this.buffer = 0.1;
            } 
            else if (classRating == '6' || classRating == '7' || classRating == '8' || classRating == '9' || classRating == '10') {
                this.buffer = 0.2;
            }
            else if (classRating == '99') {
                this.buffer = 0.1;
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
    *  ModifiedDate    : 13/08/2019
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setRiskCategory(String classRating) {
        if (classRating != null) {
            if (classRating == '0' || classRating == '1' || classRating == '2' || classRating == '3') {
                this.riskCategory = 'Very';
            } 
            else if (classRating == '4'|| classRating == '5') {
                this.riskCategory = 'High';
            } 
            else if (classRating == '6' || classRating == '7' || classRating == '8' || classRating == '9' || classRating == '10') {
                this.riskCategory = 'Medium';
            }
            else if (classRating == '99') {
                this.riskCategory = 'High';
            }
        }   
    }


    /*******************************************************************************
    *  Name            : getSecurityLevel()
    *  Summary         : Return security level
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 22/03/2018
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
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : 
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimitWeeklyPlus7() {
        if (this.creditLimitWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.creditLimitWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setCreditLimitWeeklyPlus7(Decimal buffer)
    *  Summary         : Calculate Credit Limit Weekly Plus 7
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : void
    ******************************************************************************/
    public void setCreditLimitWeeklyPlus7(Decimal buffer) {
        try {
            this.creditLimitWeeklyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
                ((7.0 + 7.0)/30.0)*(1.0 + buffer));
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxCreditLimitWeeklyPlus7()
    *  Summary         : Return Max Credit Limit Weekly Plus 7
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxCreditLimitWeeklyPlus7() {
        if (this.maxCreditLimitWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.maxCreditLimitWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7    
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxCreditLimitWeeklyPlus7() {
        try {
            if (this.company.classRating == '0' || this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3') {
                setMaxCreditLimitWeeklyPlus7Rating0_3();
            } 
            else if (this.company.classRating == '4') {
                setMaxCreditLimitWeeklyPlus7Rating4();
            } 
            else if (this.company.classRating == '5') {
                setMaxCreditLimitWeeklyPlus7Rating5();
            } 
            else if (this.company.classRating == '6' || this.company.classRating == '7' || this.company.classRating == '8' || this.company.classRating == '9' || this.company.classRating == '10') {
                setMaxCreditLimitWeeklyPlus7Rating6_10();
            } 
            else if (this.company.classRating == '99') {
                setMaxCreditLimitWeeklyPlus7Rating99();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Ratings 0-3
    *  CreatedDate     : 08/11/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating0_3() {
        this.maxCreditLimitWeeklyPlus7 = 0;
    }



    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 13/03/2019
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
                this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else {
            if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 2500000;
            }

            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.maxCreditLimitWeeklyPlus7 > recommendedCreditLimit * 1.33) {
                this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit * 1.33;
            }

            if (this.maxCreditLimitWeeklyPlus7 > Decimal.valueOf(this.company.turnOverLastYear) * 0.1 &&
                    (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
                this.maxCreditLimitWeeklyPlus7 = Decimal.valueOf(this.company.turnOverLastYear) * 0.1;
            }

            Decimal nonFuelExposure = 0;
            if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
            Decimal creditLimit800WeeklyPlus7 = ((this.fuelPriceIndex * 800 + nonFuelExposure) * ((7.0 + 7.0) / 30.0) * (1.0 + this.buffer));

            if (this.maxCreditLimitWeeklyPlus7 > creditLimit800WeeklyPlus7 &&
                    (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 &&
                    this.company.legalform == 'Sole proprietorship')) {
                this.maxCreditLimitWeeklyPlus7 = creditLimit800WeeklyPlus7;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 5
    *  CreatedDate     : 13/03/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating5() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
                this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }

        else {
            if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 2500000;
            }

            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.maxCreditLimitWeeklyPlus7 > recommendedCreditLimit * 1.33) {
                this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit * 1.33;
            }

            if (this.maxCreditLimitWeeklyPlus7 > Decimal.valueOf(this.company.turnOverLastYear) * 0.1 &&
                    (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
                this.maxCreditLimitWeeklyPlus7 = Decimal.valueOf(this.company.turnOverLastYear) * 0.1;
            }

            Decimal nonFuelExposure = 0;
            if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
            Decimal creditLimit800WeeklyPlus7 = ((this.fuelPriceIndex * 800 + nonFuelExposure) * ((7.0 + 7.0) / 30.0) * (1.0 + this.buffer));

            if (this.maxCreditLimitWeeklyPlus7 > creditLimit800WeeklyPlus7 &&
                    (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 &&
                    this.company.legalform == 'Sole proprietorship')) {
                this.maxCreditLimitWeeklyPlus7 = creditLimit800WeeklyPlus7;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 6
    *  CreatedDate     : 08/11/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating6_10() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
                this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }
        else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        }

        else {
            if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            }
            else {
                this.maxCreditLimitWeeklyPlus7 = 2500000;
            }

            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.maxCreditLimitWeeklyPlus7 > recommendedCreditLimit * 1.33) {
                this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit * 1.33;
            }

            if (this.maxCreditLimitWeeklyPlus7 > Decimal.valueOf(this.company.turnOverLastYear) * 0.1 &&
                    (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
                this.maxCreditLimitWeeklyPlus7 = Decimal.valueOf(this.company.turnOverLastYear) * 0.1;
            }

            Decimal nonFuelExposure = 0;
            if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
            Decimal creditLimit800WeeklyPlus7 = ((this.fuelPriceIndex * 800 + nonFuelExposure) * ((7.0 + 7.0) / 30.0) * (1.0 + this.buffer));

            if (this.maxCreditLimitWeeklyPlus7 > creditLimit800WeeklyPlus7 &&
                    (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 &&
                    this.company.legalform == 'Sole proprietorship')) {
                this.maxCreditLimitWeeklyPlus7 = creditLimit800WeeklyPlus7;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 99
    *  CreatedDate     : 13/08/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating99() {
        this.maxCreditLimitWeeklyPlus7 = 0;
    }


    /*******************************************************************************
    *  Name            : getMaxValueWeeklyPlus7()
    *  Summary         : Return Max value of Credit Limit including deposit Weekly Plus 7    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValueWeeklyPlus7() {
        if (this.maxValueWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.maxValueWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setMaxValueWeeklyPlus7()
    *  Summary         : Calculate Max Value Weekly Plus 7    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxValueWeeklyPlus7() {
        try {
            if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxValueWeeklyPlus7 = 2500000;
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getDepositWeeklyPlus7()
    *  Summary         : Return Deposit Weekly Plus 7
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getDepositWeeklyPlus7() {
        if (this.depositWeeklyPlus7 > 0 && this.depositWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.depositWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7()
    *  Summary         : Calculate Deposit Weekly Plus 7    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDepositWeeklyPlus7() {
        try {
            if (this.company.classRating == '0' || this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3') {
                setDepositWeeklyPlus7Rating0_3();
            }
            else if (this.company.classRating == '4') {
                setDepositWeeklyPlus7Rating4();
            }
            else if (this.company.classRating == '5') {
                setDepositWeeklyPlus7Rating5();
            }
            else if (this.company.classRating == '6' || this.company.classRating == '7' || this.company.classRating == '8' || this.company.classRating == '9' || this.company.classRating == '10') {
                setDepositWeeklyPlus7Rating6_10();
            } else if (this.company.classRating == '99') {
                setDepositWeeklyPlus7Rating99();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Ratings 0-3
    *  CreatedDate     : 08/11/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating0_3() {
        this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * (7.0 + 7.0 + 10.0) / (7.0 + 7.0);
        this.securityLevelWeeklyPlus7 = 110;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }
        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            
            if (this.creditLimitWeeklyPlus7 >= this.maxCreditLimitWeeklyPlus7) {
                if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit * 1.33) {
                    this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                    this.securityLevelWeeklyPlus7 = 4;
                } else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
                    this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                    this.securityLevelWeeklyPlus7 = 100;
                } else {
                    this.depositWeeklyPlus7 = 0;
                }
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 5
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating5() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }

        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }

        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            
            if (this.creditLimitWeeklyPlus7 >= this.maxCreditLimitWeeklyPlus7) {
                if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit * 1.33) {
                    this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                    this.securityLevelWeeklyPlus7 = 4;
                } else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
                    this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                    this.securityLevelWeeklyPlus7 = 100;
                } else {
                    this.depositWeeklyPlus7 = 0;
                }
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Ratings 6-10
    *  CreatedDate     : 08/11/2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating6_10() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }

        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            this.securityLevelWeeklyPlus7 = 100;
        }

        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            
            if (this.creditLimitWeeklyPlus7 >= this.maxCreditLimitWeeklyPlus7) {
                if (this.creditLimitWeeklyPlus7 > recommendedCreditLimit * 1.33) {
                    this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
                    this.securityLevelWeeklyPlus7 = 4;
                } else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
                    this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
                    this.securityLevelWeeklyPlus7 = 100;
                } else {
                    this.depositWeeklyPlus7 = 0;
                }
            } else {
                this.depositWeeklyPlus7 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 0  
    *  CreatedDate     : 13/08/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating99() {
        this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
        this.securityLevelWeeklyPlus7 = 100;
    }
    
    
    public Decimal getCreditLimitBiWeeklyPlus7() {
        return null;
    }

    
    public void setCreditLimitBiWeeklyPlus7(Decimal buffer) {}


    public Decimal getMaxCreditLimitBiWeeklyPlus7() {
        return null;
    }


    public void setMaxCreditLimitBiWeeklyPlus7() {}

    
    public Decimal getDepositBiWeeklyPlus7() {
        return null;
    }

    
    public void setDepositBiWeeklyPlus7() {}

    
    public Decimal getMaxValueBiWeeklyPlus7() {
        return null;
    }

    
    public void setMaxValueBiWeeklyPlus7() {}

    
    /*******************************************************************************
    *  Summary         : Return Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 01/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : CL 15+14
    ******************************************************************************/
    public Decimal getCreditLimitBiWeeklyPlus14() {
        if (this.creditLimitBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.creditLimitBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }

    
    /*******************************************************************************
    *  Summary         : Calculate Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 01/04/2020 by Anton Buzak
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : -
    ******************************************************************************/
    public void setCreditLimitBiWeeklyPlus14(Decimal buffer) {
        try {
            this.creditLimitBiWeeklyPlus14 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
                ((15.0 + 14.0)/30.0) * (1.0 + buffer));
        } catch (Exception e) {
            throw new CreditFactoryException('Credit Limit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }

    
    /*******************************************************************************
    *  Summary         : Return Max Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 01/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : max CL 15+7
    ******************************************************************************/
    public Decimal getMaxCreditLimitBiWeeklyPlus14() {
        if (this.maxCreditLimitBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.maxCreditLimitBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }

    
    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14    
    *  CreatedDate     : 01/04/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxCreditLimitBiWeeklyPlus14() {
        try {
            if (this.company.classRating == '0' || this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3') {
                setMaxCreditLimitBiWeeklyPlus14Rating0_3();
            } 
            else if (this.company.classRating == '4') {
                setMaxCreditLimitBiWeeklyPlus14Rating4();
            } 
            else if (this.company.classRating == '5') {
                setMaxCreditLimitBiWeeklyPlus14Rating5();
            } 
            else if (this.company.classRating == '6' || this.company.classRating == '7' || this.company.classRating == '8' || this.company.classRating == '9' || this.company.classRating == '10') {
                setMaxCreditLimitBiWeeklyPlus14Rating6_10();
            }
            else if (this.company.classRating == '99') {
                setMaxCreditLimitBiWeeklyPlus14Rating99();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Credit Limit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Ratings 0-3
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating0_3() {
        this.maxCreditLimitBiWeeklyPlus14 = 0;
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 4
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitBiWeeklyPlus14) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }
        else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }

        else {
            if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
            }
            else {
                this.maxCreditLimitBiWeeklyPlus14 = 2500000;
            }

            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.maxCreditLimitBiWeeklyPlus14 > recommendedCreditLimit * 1.33) {
                this.maxCreditLimitBiWeeklyPlus14 = recommendedCreditLimit * 1.33;
            }

            if (this.maxCreditLimitBiWeeklyPlus14 > Decimal.valueOf(this.company.turnOverLastYear) * 0.1 &&
                    (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
                this.maxCreditLimitBiWeeklyPlus14 = Decimal.valueOf(this.company.turnOverLastYear) * 0.1;
            }

            Decimal nonFuelExposure = 0;
            if (this.sourceObject.Non_fuel_exposure__c != null) {
                nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
            }

            Decimal creditLimit800BiWeeklyPlus14 = (this.fuelPriceIndex * 800 + nonFuelExposure) * ((15.0 + 14.0) / 30.0 * (1.0 + this.buffer));
            if (this.maxCreditLimitBiWeeklyPlus14 > creditLimit800BiWeeklyPlus14 &&
                    (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 &&
                    this.company.legalform == 'Sole proprietorship')) {
                this.maxCreditLimitBiWeeklyPlus14 = creditLimit800BiWeeklyPlus14;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 5
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating5() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitBiWeeklyPlus14) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }
        else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }

        else {
            if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
            }
            else {
                this.maxCreditLimitBiWeeklyPlus14 = 2500000;
            }

            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.maxCreditLimitBiWeeklyPlus14 > recommendedCreditLimit * 1.33) {
                this.maxCreditLimitBiWeeklyPlus14 = recommendedCreditLimit * 1.33;
            }

            if (this.maxCreditLimitBiWeeklyPlus14 > Decimal.valueOf(this.company.turnOverLastYear) * 0.1 &&
                    (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
                this.maxCreditLimitBiWeeklyPlus14 = Decimal.valueOf(this.company.turnOverLastYear) * 0.1;
            }

            Decimal nonFuelExposure = 0;
            if (this.sourceObject.Non_fuel_exposure__c != null) {
                nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
            }

            Decimal creditLimit800BiWeeklyPlus14 = (this.fuelPriceIndex * 800 + nonFuelExposure) * ((15.0 + 14.0) / 30.0 * (1.0 + this.buffer));
            if (this.maxCreditLimitBiWeeklyPlus14 > creditLimit800BiWeeklyPlus14 &&
                    (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 &&
                    this.company.legalform == 'Sole proprietorship')) {
                this.maxCreditLimitBiWeeklyPlus14 = creditLimit800BiWeeklyPlus14;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 6
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating6_10() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }
        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitBiWeeklyPlus14) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }
        else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        }

        else {
            if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
            }
            else {
                this.maxCreditLimitBiWeeklyPlus14 = 2500000;
            }

            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }

            if (this.maxCreditLimitBiWeeklyPlus14 > recommendedCreditLimit * 1.33) {
                this.maxCreditLimitBiWeeklyPlus14 = recommendedCreditLimit * 1.33;
            }

            if (this.maxCreditLimitBiWeeklyPlus14 > Decimal.valueOf(this.company.turnOverLastYear) * 0.1 &&
                    (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
                this.maxCreditLimitBiWeeklyPlus14 = Decimal.valueOf(this.company.turnOverLastYear) * 0.1;
            }

            Decimal nonFuelExposure = 0;
            if (this.sourceObject.Non_fuel_exposure__c != null) {
                nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
            }

            Decimal creditLimit800BiWeeklyPlus14 = (this.fuelPriceIndex * 800 + nonFuelExposure) * ((15.0 + 14.0) / 30.0 * (1.0 + this.buffer));
            if (this.maxCreditLimitBiWeeklyPlus14 > creditLimit800BiWeeklyPlus14 &&
                    (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 &&
                    this.company.legalform == 'Sole proprietorship')) {
                this.maxCreditLimitBiWeeklyPlus14 = creditLimit800BiWeeklyPlus14;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 99
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating99() {
        this.maxCreditLimitBiWeeklyPlus14 = 0;
    }


    /*******************************************************************************
    *  Summary         : Return Max value of Credit Limit including deposit BiWeekly Plus 14  
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : max value 15+14
    ******************************************************************************/
    public Decimal getMaxValueBiWeeklyPlus14() {
        if (this.maxValueBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.maxValueBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }
    
    
    /*******************************************************************************
    *  Summary         : Calculate Max Value Weekly Plus 14
    *  CreatedDate     : 01/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setMaxValueBiWeeklyPlus14() {
        try {
            if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
            } else {
                this.maxValueBiWeeklyPlus14 = 2500000;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Max Value BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }

    
    /*******************************************************************************
    *  Summary         : Return Deposit BiWeekly Plus 14
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : deposit 15+14
    ******************************************************************************/
    public Decimal getDepositBiWeeklyPlus14() {
        if (this.depositBiWeeklyPlus14 > 0 && this.depositBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.depositBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }

    
    /*******************************************************************************
    *  Summary         : Calculate Deposit BiWeekly Plus 14   
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDepositBiWeeklyPlus14() {
        try {
            if (this.company.classRating == '0' || this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3') {
                setDepositBiWeeklyPlus14Rating0_3();
            }
            else if (this.company.classRating == '4') {
                setDepositBiWeeklyPlus14Rating4();
            }
            else if (this.company.classRating == '5') {
                setDepositBiWeeklyPlus14Rating5();
            }
            else if (this.company.classRating == '6' || this.company.classRating == '7' || this.company.classRating == '8' || this.company.classRating == '9' || this.company.classRating == '10') {
                setDepositBiWeeklyPlus14Rating6_10();
            } else if (this.company.classRating == '99') {
                setDepositBiWeeklyPlus14Rating99();
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Calculate Deposit BiWeekly Plus 14 for Ratings 0-3
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating0_3() {
        this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * (15.0 + 14.0 + 10.0) / (15.0 + 14.0);
        this.securityLevelBiWeeklyPlus14 = 110;
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 4
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            this.securityLevelBiWeeklyPlus14 = 100;
        }

        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                    Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitBiWeeklyPlus14) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            this.securityLevelBiWeeklyPlus14 = 100;
        }

        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            
            if (this.creditLimitBiWeeklyPlus14 >= this.maxCreditLimitBiWeeklyPlus14) {
                if (this.creditLimitBiWeeklyPlus14 > recommendedCreditLimit * 1.33) {
                    this.depositBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 - recommendedCreditLimit);
                    this.securityLevelBiWeeklyPlus14 = 4;
                } else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
                    this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
                    this.securityLevelBiWeeklyPlus14 = 100;
                } else {
                    this.depositBiWeeklyPlus14 = 0;
                }
            } else {
                this.depositBiWeeklyPlus14 = 0;
            }
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 5
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating5() {
       if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            this.securityLevelBiWeeklyPlus14 = 100;
        }

        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                    Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitBiWeeklyPlus14) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            this.securityLevelBiWeeklyPlus14 = 100;
        }

        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            
            if (this.creditLimitBiWeeklyPlus14 >= this.maxCreditLimitBiWeeklyPlus14) {
                if (this.creditLimitBiWeeklyPlus14 > recommendedCreditLimit * 1.33) {
                    this.depositBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 - recommendedCreditLimit);
                    this.securityLevelBiWeeklyPlus14 = 4;
                } else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
                    this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
                    this.securityLevelBiWeeklyPlus14 = 100;
                } else {
                    this.depositBiWeeklyPlus14 = 0;
                }
            } else {
                this.depositBiWeeklyPlus14 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit BiWeekly Plus 14 for Ratings 6-10
    *  CreatedDate     : 01/04/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating6_10() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            this.securityLevelBiWeeklyPlus14 = 100;
        }

        else if ((this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null ||
                    Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 ||
                    Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitBiWeeklyPlus14) &&
                (this.company.legalform != 'Sole proprietorship' || this.company.legalform == 'Sole proprietorship' && this.sourceObject.Total_consumption_l_month__c > 800)) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            this.securityLevelBiWeeklyPlus14 = 100;
        }

        else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            
            if (this.creditLimitBiWeeklyPlus14 >= this.maxCreditLimitBiWeeklyPlus14) {
                if (this.creditLimitBiWeeklyPlus14 > recommendedCreditLimit * 1.33) {
                    this.depositBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 - recommendedCreditLimit);
                    this.securityLevelBiWeeklyPlus14 = 4;
                } else if (this.errorsSet != null && this.errorsSet.contains(CONTACT_ERROR)) {
                    this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
                    this.securityLevelBiWeeklyPlus14 = 100;
                } else {
                    this.depositBiWeeklyPlus14 = 0;
                }
            } else {
                this.depositBiWeeklyPlus14 = 0;
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 0  
    *  CreatedDate     : 13/08/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating99() {
        this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
        this.securityLevelBiWeeklyPlus14 = 100;
    }


    public Decimal getCreditLimitMonthlyPlus7() {
        return null;
    }


    public void setCreditLimitMonthlyPlus7(Decimal buffer) {}


    public Decimal getMaxCreditLimitMonthlyPlus7() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus7() {}


    public Decimal getMaxValueMonthlyPlus7() {
        return null;
    }


    public void setMaxValueMonthlyPlus7() {}


    public Decimal getDepositMonthlyPlus7() {
        return null;
    }


    public void setDepositMonthlyPlus7() {}


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
    *  Name            : setPaymentDetails()
    *  Summary         : Calculate payment details such as billing period, payment terms and max credit limit  
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 12/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setPaymentDetails() {
        if (this.creditLimitBiWeeklyPlus14 < 2500000 && this.depositBiWeeklyPlus14 == 0) {
            if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            } else {
                this.billingPeriod = 15;
                this.paymentTerms = 14;
            }
        } else if (this.creditLimitWeeklyPlus7 < 2500000 && this.depositWeeklyPlus7 == 0) {
            this.billingPeriod = 7;
            this.paymentTerms = 7;
        } else if (this.creditLimitBiWeeklyPlus14 < 2500000) {
            if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            } else {
                this.billingPeriod = 15;
                this.paymentTerms = 14;
            }
        }
        else if (this.creditLimitWeeklyPlus7 < 2500000) {
            this.billingPeriod = 7;
            this.paymentTerms = 7;
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
    *  Name            : setCreditLimit()
    *  Summary         : Calculate Credit Limit    
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCreditLimit() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.creditLimit = getCreditLimitBiWeeklyPlus14();
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.creditLimit = getCreditLimitWeeklyPlus7();
            }
        } catch (Exception e) {
            System.debug('DEBUG: Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getCreditLimit()
    *  Summary         : Return Credit Limit    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimit() {
        return this.creditLimit;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimit()
    *  Summary         : Calculate max credit limit    
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxCreditLimit() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.maxCreditLimit = getMaxCreditLimitBiWeeklyPlus14();
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
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
    *  Name            : setMaxValue()
    *  Summary         : Calculate Max value of Credit Limit including deposit    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public void setMaxValue() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.maxValue = getMaxValueBiWeeklyPlus14();
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.maxValue = getMaxValueWeeklyPlus7();
            }
        } catch (Exception e) {
             System.debug('DEBUG: Credit Factory === ' + e.getMessage());
             throw new CreditFactoryException('Max value calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxValue()
    *  Summary         : Return Max value of Credit Limit including deposit
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValue() {
        return this.maxValue;
    }


    /*******************************************************************************
    *  Summary         : Calculate deposit   
    *  CreatedDate     : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDeposit() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.deposit = getDepositBiWeeklyPlus14();
                this.securityLevel = this.securityLevelBiWeeklyPlus14; 
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
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
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 20/09/2019
    *  Parameters      : CreditCompany company - company from Credit System, 
                         Integer billingPeriod - selected billing period, 
                         Integer paymentTerms - selected payment terms,
                         Decimal creditLimit - changed CL value,
                         Decimal maxCreditLimit - max Credit Limit for selected billing period,
                         Decimal monthlyVolume - currency based on total consumption of liters,
                         Decimal totalConsumption - total consumption of liters,
                         String opportunityId - id of related opportunity.
    *  Returns         : void
    ******************************************************************************/
    public void resetDeposit(CreditCompany company, Integer billingPeriod, Integer paymentTerms, Decimal creditLimit, 
                             Decimal maxCreditLimit, Decimal monthlyVolume, Decimal totalConsumption,
                             String opportunityId) {
        try {
            if (company.classRating == '0' || company.classRating == '1' || company.classRating == '2' || company.classRating == '3') {
                this.deposit = resetDepositRating0_3(creditLimit, billingPeriod, paymentTerms);
            } 
            else if (company.classRating == '4') {
                this.deposit = resetDepositRating4(creditLimit, company, company.errors, billingPeriod, paymentTerms);
            } 
            else if (company.classRating == '5') {
                this.deposit = resetDepositRating5(creditLimit, company, company.errors, billingPeriod, paymentTerms);
            } 
            else if (company.classRating == '6' || company.classRating == '7' || company.classRating == '8' || company.classRating == '9' || company.classRating == '10') {
                this.deposit = resetDepositRating6_10(creditLimit, company, company.errors, billingPeriod, paymentTerms);
            } 
            else if (company.classRating == '99') {
                this.deposit = resetDepositRating99(creditLimit, billingPeriod, paymentTerms);
            }

            if (billingPeriod == 15 && paymentTerms == 14 && creditLimit == company.creditLimitBiWeeklyPlus14) {
                this.deposit = company.depositBiWeeklyPlus14;
            } else if (billingPeriod == 7 && paymentTerms == 7 && creditLimit == company.creditLimitWeeklyPlus7) {
                this.deposit = company.depositWeeklyPlus7;
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Deposit recalculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 1
    *  CreatedDate     : 01/04/2020
    *  Parameters      : creditLimit - changed CL value, 
                         billingPeriod - selected Billing Period, 
                         paymentTerms - selected Payment Terms
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating0_3(Decimal creditLimit, Integer billingPeriod, Integer paymentTerms) {
        this.securityLevel = 110;
        return ((creditLimit * (billingPeriod + paymentTerms + 10.0) / (billingPeriod + paymentTerms)) / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 4
    *  CreatedDate     : 18/11/2018
    *  Parameters      : creditLimit - changed CL value,  
                         maxCreditLimit - max CL, 
                         company - company from Credit System, 
                         errors - set of errors
    *  Returns         : deposit 
    ******************************************************************************/
    private Decimal resetDepositRating4(Decimal creditLimit, CreditCompany company, String errors, Integer billingPeriod, Integer paymentTerms) {
        Decimal recommendedCreditLimit = 0;
        if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        }
        Decimal creditLimit800l = (this.fuelPriceIndex * 800) * ((billingPeriod + paymentTerms) / 30.0) * (1.0 + this.buffer);
        creditLimit800l = (creditLimit800l / 10000).round(System.RoundingMode.HALF_UP) * 10000;

        if (company.dateoffoundation != null && company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(company.dateoffoundation.substring(3, 5)), Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if ((company.legalform != 'Sole proprietorship' || company.legalform == 'Sole proprietorship' && creditLimit > creditLimit800l) &&
                (company.profitLossLastYear == null || company.profitLossYearBeforeLast == null || company.turnOverLastYear == null ||
                Decimal.valueOf(company.profitLossLastYear) < 0 || Decimal.valueOf(company.profitLossYearBeforeLast) < 0 ||
                creditLimit > Decimal.valueOf(company.turnOverLastYear) * 0.1)) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if (creditLimit > recommendedCreditLimit * 1.33) {
            this.securityLevel = 4;
            return ((creditLimit - recommendedCreditLimit) / 10000).round(System.RoundingMode.HALF_UP) * 10000;
        }
        else if (errors != null && errors.contains(CONTACT_ERROR)) {
                this.securityLevel = 100;
                return creditLimit;
        }
        else {
            this.securityLevel = null;
            return 0;
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 5
    *  CreatedDate     : 01/04/2020
    *  Parameters      : creditLimit - changed CL value,  
                         maxCreditLimit - max CL, 
                         company - company from Credit System, 
                         errors - set of errors
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating5(Decimal creditLimit, CreditCompany company, String errors, Integer billingPeriod, Integer paymentTerms) {
        Decimal recommendedCreditLimit = 0;
        if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        }
        Decimal creditLimit800l = (this.fuelPriceIndex * 800) * ((billingPeriod + paymentTerms) / 30.0) * (1.0 + this.buffer);
        creditLimit800l = (creditLimit800l / 10000).round(System.RoundingMode.HALF_UP) * 10000;

        if (company.dateoffoundation != null && company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(company.dateoffoundation.substring(3, 5)), Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if ((company.legalform != 'Sole proprietorship' || company.legalform == 'Sole proprietorship' && creditLimit > creditLimit800l) &&
                (company.profitLossLastYear == null || company.profitLossYearBeforeLast == null || company.turnOverLastYear == null ||
                Decimal.valueOf(company.profitLossLastYear) < 0 || Decimal.valueOf(company.profitLossYearBeforeLast) < 0 ||
                creditLimit > Decimal.valueOf(company.turnOverLastYear) * 0.1)) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if (creditLimit > recommendedCreditLimit * 1.33) {
            this.securityLevel = 4;
            return ((creditLimit - recommendedCreditLimit) / 10000).round(System.RoundingMode.HALF_UP) * 10000;
        }
        else if (errors != null && errors.contains(CONTACT_ERROR)) {
                this.securityLevel = 100;
                return creditLimit;
        }
        else {
            this.securityLevel = null;
            return 0;
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 6 and changed CL value. 
    *  CreatedDate     : 01/04/2020
    *  Parameters      : creditLimit - changed CL value, 
                         maxCreditLimit - max CL, 
                         company - company from Credit System,
                         errors - set of errors
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating6_10(Decimal creditLimit, CreditCompany company, String errors, Integer billingPeriod, Integer paymentTerms) {
        Decimal recommendedCreditLimit = 0;
        if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        }
        Decimal creditLimit800l = (this.fuelPriceIndex * 800) * ((billingPeriod + paymentTerms) / 30.0) * (1.0 + this.buffer);
        creditLimit800l = (creditLimit800l / 10000).round(System.RoundingMode.HALF_UP) * 10000;

        if (company.dateoffoundation != null && company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)),
                Integer.valueOf(company.dateoffoundation.substring(3, 5)), Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if ((company.legalform != 'Sole proprietorship' || company.legalform == 'Sole proprietorship' && creditLimit > creditLimit800l) &&
                (company.profitLossLastYear == null || company.profitLossYearBeforeLast == null || company.turnOverLastYear == null ||
                Decimal.valueOf(company.profitLossLastYear) < 0 || Decimal.valueOf(company.profitLossYearBeforeLast) < 0 ||
                creditLimit > Decimal.valueOf(company.turnOverLastYear) * 0.1)) {
            this.securityLevel = 100;
            return creditLimit;
        }
        else if (creditLimit > recommendedCreditLimit * 1.33) {
            this.securityLevel = 4;
            return ((creditLimit - recommendedCreditLimit) / 10000).round(System.RoundingMode.HALF_UP) * 10000;
        }
        else if (errors != null && errors.contains(CONTACT_ERROR)) {
                this.securityLevel = 100;
                return creditLimit;
        }
        else {
            this.securityLevel = null;
            return 0;
        }
    }


    /*******************************************************************************
    *  Summary         : Reset deposit value for rating 0 and changed CL value.     
    *  CreatedDate     : 13/08/2019
    *  Parameters      : creditLimit - changed CL value, 
                         billingPeriod - selected Billing Period, 
                         paymentTerms - selected Payment Terms
    *  Returns         : deposit
    ******************************************************************************/
    private Decimal resetDepositRating99(Decimal creditLimit, Integer billingPeriod, Integer paymentTerms) {
        this.securityLevel = 100;
        return creditLimit;
    }


    /*******************************************************************************
    *  Name            : getDeposit()
    *  Summary         : Return deposit.    
    *  CreatedDate     : 18/11/2018
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
    *  CreatedDate     : 18/11/2018
    *  ModifiedDate    : 11/06/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDecision() {
        try {
            this.decision = new CreditFactoryDecision();
            if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
                // Positive Decisions without deposit
                this.decision.verdict = 'Yes';
                this.decision.statusCode = '001'; // No Limits
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
                if (this.decision.statusCode == '001') {
                    CreditFactoryUtilities.displayMessage('info','Billing Period can be set to ' + this.billingPeriod);
                    CreditFactoryUtilities.displayMessage('info','Payment Terms can be set to ' + this.paymentTerms);
                } else if (this.decision.statusCode == '002') {
                    CreditFactoryUtilities.displayMessage('info','Billing Period can be set to ' + this.billingPeriod);
                    CreditFactoryUtilities.displayMessage('info','Payment Terms can be set to ' + this.paymentTerms + '</br></br>');
                    CreditFactoryUtilities.displayMessage('info','Deposit to pay: ' + this.deposit + ' HUF.</br></br>' + 
                            'You can update Desired Payment Terms and Desired Billing Period in the Opportunity and restart Credit Factory to recalculate the deposit amount.');
                } else if (this.decision.statusCode == '003') {
                    CreditFactoryUtilities.displayMessage('error','Requested limit too high. Please refer to credit.');
                }
            } 
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            if (e.getMessage().contains('Opportunity was submitted for Approval.')) {
                errorMessage = e.getMessage();
            } else {
                errorMessage = 'Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            }
            System.debug('Credit Factory === ' + errorMessage);
            throw new CreditFactoryException('Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : resetDecision()
    *  Summary         : Reset Company Decision
    *  CreatedDate     : 10/11/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : Integer billingPeriod - selected billing period, Integer paymentTerms - selected payment terms, Decimal deposit - selected deposit, 
                         String classRating - current company class rating, Integer numberOfCards - number of cards, CreditCompany company - company from Credit System
    *  Returns         : void
    ******************************************************************************/
    public void resetDecision(Integer billingPeriod, Integer paymentTerms, Decimal deposit, String classRating, Decimal numberOfCards, CreditCompany company) {
        try {
            this.decision = new CreditFactoryDecision();
            // Positive Decisions
            this.decision.verdict = 'Yes';
            if (deposit == 0) {
                // Decisions without deposit
                this.decision.statusCode = '001'; // No Limits
            } else {
                // Decisions with deposit
                this.decision.statusCode = '002'; // No Limit
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Reset Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getDecision()
    *  Summary         : Return decision.    
    *  CreatedDate     : 10/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditFactoryDecision
    ******************************************************************************/
    public CreditFactoryDecision getDecision() {
        return this.decision;
    }


    /*******************************************************************************
    *  Name            : checkWarnings()
    *  Summary         : check for warnings to display on page
    *  CreatedDate     : 22/02/2018
    *  ModifiedDate    : 06/06/2019
    *  Parameters      : -
    *  Returns         : void
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
    *  Name            : checkPaymentTerms()
    *  Summary         : compare calculated and desired payment terms
    *  CreatedDate     : 22/02/2018
    *  ModifiedDate    : 06/06/2019
    *  Parameters      : -
    *  Returns         : Boolean
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
    *  Name            : checkBillingPeriod()
    *  Summary         : compare calculated and desired billing period    
    *  CreatedDate     : 22/02/2018
    *  ModifiedDate    : 06/06/2019
    *  Parameters      : -
    *  Returns         : Boolean
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
    *  ModifiedDate    : 16/05/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveReports() {
        String errors = '';
        if (errorsSet != null) {
            for (String error : this.errorsSet) {
                errors += error + ', ';
            }
            errors = errors.removeEnd(', ');
        }
        if (this.existingCreditReport == null && this.companyEmployeesList != null && company != null) {
            String reportName = company.name;
            if (reportName.length() > 80) {
                reportName = reportName.substring(0,80);
            }
            Credit_Factory_Report__c newReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = company.creditSystemCompanyNumber,
                Age_of_Company__c = company.ageofcompany,
                City__c = company.city,
                Company_Status__c = company.status,
                Country__c = company.country,
                County_Court__c = company.countyCourt,
                Credit_Decision__c = company.creditDecision,
                Credit_Limit__c = company.creditLimit,
                Date_Last_Register_Entry__c = company.datelastregisterentry,
                Date_Legal_Form__c = company.datelegalform,
                Date_of_Foundation__c = company.dateoffoundation,
                Email__c = company.email,
                Fax__c = company.fax,
                First_Legal_Form__c = company.firstlegalform,
                Fiscal_Number__c = company.taxnumber,
                Tax_Id__c = company.taxnumber,
                Housenumber__c = company.housenumber,
                Legal_Form__c = company.legalform,
                Mobile__c = company.mobile,
                Opportunity__c = sourceObject.Id,
                Order_Situation__c = company.orderSituation,
                Payment_Behaviour__c = company.paymentBehaviour,
                Phone__c = company.phone,
                Postcode__c = company.postcode,
                Register_Number__c = company.registerNumber,
                Staff_Range__c = company.staffcompanyrange,
                Street__c = company.street,
                Trade_Name__c = company.tradename,
                Turn_Over__c = company.turnOver,
                VAT_Number__c = company.vatid,
                Trade_Register_Number__c = company.tradeRegisterNumber,
                Website__c = company.website,
                Name = reportName,
                Company_Id__c = company.identificationnumber,
                Date_Of_Last_Major_Update__c = company.dateOfLastMajorUpdate,
                Reference_Number__c = company.referencenumber,
                CurrencyIsoCode = 'HUF',
                Name__c = company.name,
                Profit_Loss_Last_Year__c = company.profitLossLastYear,
                Profit_Loss_Year_Before_Last__c = company.profitLossYearBeforeLast,
                Turn_Over_Last_Year__c = company.turnOverLastYear,
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
                Checked_Email__c = this.company.checkedEmail);
            
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
                newReport.Payment_Terms__c = this.paymentTerms;
                newReport.Security_Level__c = this.securityLevel;
                newReport.Credit_Limit_Default__c = getCreditLimit();
                newReport.Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7();
                newReport.Credit_Limit_Bi_Weekly_7__c = getCreditLimitBiWeeklyPlus7();
                newReport.Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7();
                newReport.Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitBiWeeklyPlus7();
                newReport.Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7();
                newReport.Max_Value_Bi_Weekly_7__c = getMaxValueBiWeeklyPlus7();
                newReport.Deposit_Weekly_7__c = getDepositWeeklyPlus7();
                newReport.Deposit_Bi_Weekly_7__c = getDepositBiWeeklyPlus7();
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
                    String employeeName = e.ename;
                    if (e.ename.length() > 80) {
                        employeeName = employeeName.substring(0,80);
                    }
                    employeesListToInsert.add(new Credit_Factory_Report_Employee__c(
                        Credit_Factory_Report__c = newReport.Id,
                        Address__c = e.address,
                        Date_of_Birth__c = e.dateofbirth,
                        Id__c = e.enumber,
                        Name = employeeName,
                        Participation_Date__c = e.participationdate,
                        Type__c = e.type,
                        Company_Id__c = e.companyId,
                        Company_Type__c = e.companyType,
                        Company_Role__c = e.companyRole));
                }
                insert employeesListToInsert;
            } catch (Exception e) {
                CreditFactoryUtilities.displayMessage('error','Error on saving Opportunity. Contact your administrator.');
                system.debug('Credit Factory === ' + e.getMessage());
                return;
            }
        } else {
            // update
            if (this.userSource == 'E2E Long Form') {
                Credit_Factory_Report__c existingReport = new Credit_Factory_Report__c(
                    Id = this.existingCreditReport.Id,
                    Billing_Period__c = this.billingPeriod,
                    Payment_Terms__c = this.paymentTerms,
                    Security_Level__c = this.securityLevel,
                    Credit_Limit_Default__c = getCreditLimit(),
                    Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7(),
                    Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7(),
                    Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7(),
                    Deposit_Weekly_7__c = getDepositWeeklyPlus7(),
                    Credit_Limit_Bi_Weekly_14__c = getCreditLimitBiWeeklyPlus14(),
                    Max_Credit_Limit_Bi_Weekly_14__c = getMaxCreditLimitBiWeeklyPlus14(),
                    Max_Value_Bi_Weekly_14__c = getMaxValueBiWeeklyPlus14(),
                    Deposit_Bi_Weekly_14__c = getDepositBiWeeklyPlus14(),
                    Decision_Verdict__c = this.decision.verdict,
                    Decision_Status_Code__c = this.decision.statusCode,
                    Errors__c = errors);
                try {
                    update existingReport;
                } catch (Exception e) {
                     CreditFactoryUtilities.displayMessage('error', 'Error on updating Credit Factory Report. Contact your administrator.');
                }
            }
        }
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
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c,String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);

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


    /*******************************************************************************
    *  Name            : updateOpportunityWithPDF()
    *  Summary         : Update Opportunity field "PDF created"
    *  CreatedDate     : 3/11/2016
    *  Parameters      : sourceObject - Opportunity object
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityWithPDF(sObject sourceObject) {
        try {
            Opportunity opportunityToUpdate = (Opportunity) this.sourceObject;
            opportunityToUpdate.Credit_Factory_PDF_Report_Created__c = true;
            update opportunityToUpdate;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            String errorMessage = 'Opportunity update failed. ';
            throw new CreditFactoryException(errorMessage + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : doCreateReportAttachment(String opportunityId)
    *  Summary         : Create Credit Company Report PDF Attachment in Salesforce and attach to Opportunity
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 03/05/2019
    *  Parameters      : opportunityId - source record Salesforce id
    *  Returns         : Boolean - true if report attached to opportunity
    ******************************************************************************/
    public Boolean doCreateReportAttachment(String opportunityId) {
        if (this.company != null && this.companyEmployeesList != null && this.attachmentBody != null) {
            try {
                Attachment creforeport = new Attachment(
                    ParentId = opportunityId,
                    Name = 'CofaceReport.pdf',
                    Body = this.attachmentBody);
                insert creforeport;
                return true;   
            } catch (Exception e) {
                System.debug('Credit Factory === ' + e.getMessage());
                String errorMessage = 'Error on creating PDF report. ';
                throw new CreditFactoryException(errorMessage + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        }
        return false;
    }


    public Boolean isPendingSEPAPossible() {
        return false;
    }


    /*******************************************************************************
    *  Name            : isAutoCWPossible()
    *  Summary         : Check availability of "Closed Won" button
    *  CreatedDate     : 11/09/2019
    *  ModifiedDate    : 09/10/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isAutoCWPossible() {
        if (this.sourceObject.DocuSign_Status__c == 'Completed' && this.sourceObject.Total_consumption_l_month__c <= 1500) {
            List<dsfs__DocuSign_Status__c> dsStatusesList = [
                    SELECT dsfs__Opportunity__c, (SELECT Name FROM R00NS0000000WUO2MAO__r)
                    FROM dsfs__DocuSign_Status__c
                    WHERE dsfs__Opportunity__c = :this.sourceObject.Id];

            Set<String> dsRecipientsNamesSet = new Set<String>();
            for (dsfs__DocuSign_Status__c status : dsStatusesList) {
                for (dsfs__DocuSign_Recipient_Status__c recipient : status.R00NS0000000WUO2MAO__r) {
                    dsRecipientsNamesSet.add(CreditFactoryUtilities.replaceHungarianCharacters(recipient.Name.toUpperCase().replace('’', '\'')));
                }
            }

            for (CreditCompanyEmployee employee : this.companyEmployeesList) {
                if (dsRecipientsNamesSet.contains(CreditFactoryUtilities.replaceHungarianCharacters(employee.ename.toUpperCase().replace('’', '\'')))) {
                    return true;
                }
            }
        }

        return false;
    }


    public PageReference changeToPendingSEPAConfirmation() {
        return null;
    }


    /*******************************************************************************
	*  Name 		   : changeToClosedWon()
	*  Summary         : Change opportunity StageName to Closed Won
	*  CreatedDate     : 16/09/2019
	*  ModifiedDate    : -
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
	*  Name            : prepareGeneralFieldsForAutoprocess()
	*  Summary         : Prepare fields for Closed Won or Contract Check    
	*  CreatedDate     : 16/09/2019
	*  ModifiedDate    : -
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
    	this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
        if (this.maxCreditLimit != null) {
            this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
	    }
		this.sourceObject.Last_CF_Errors__c = null;
		this.sourceObject.Security_To_Pay__c = null;
        this.sourceObject.Security_Amount_To_Pay__c = null;
        this.sourceObject.Pending_Deposit_by_CF__c = false;
        this.sourceObject.put(this.opportunityMapping.Security_Level__c, null);
		this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
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
        return relatedTankkartensList.size();
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
            submitForApproval('Duplicate');
            throw new CreditFactoryException(exceptionString + '<br/>' + 'Opportunity was submitted for Approval.');
        }
    }


    /*******************************************************************************
    *  Name            : changeToPendingDeposit()
    *  Summary         : change Opportunity Stage Name to Pending Sales - Deposit automatically
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 06/06/2019
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

            this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
            update this.sourceObject;
            update this.sourceObject.Account;
            CreditFactoryUtilities.displayMessage('error','Decision about deposit was accepted for your client.');
        } catch (Exception e) {
            throw new CreditFactoryException('Change to Pending Sales - Deposit failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
	*  Name            : changeToContractCheck()
	*  Summary         : change Opportunity StageName to Pending Credit - Contract Check    
	*  CreatedDate     : 01/03/2018
    *  ModifiedDate    : 11/06/2019
	*  Parameters      : -
	*  Returns         : PageReference
	******************************************************************************/
	public PageReference changeToContractCheck() {
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
	        this.sourceObject.StageName = 'Pending Credit - Contract Check';
	        this.sourceObject.CF_Stage__c = 'Pending Credit - Contract Check';
	        update this.sourceObject;
	        update this.sourceObject.Account;
	        submitForApproval('Contract Check');
	        return new PageReference('/' + this.sourceObject.Id);
		} catch (Exception e) {
        	throw new CreditFactoryException('Change to Contract check failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


    /*******************************************************************************
    *  Name            : submitForApproval()
    *  Summary         : submit opportunity for approval in case of too high monthly credit limit
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 11/04/2019
    *  Parameters      : String type - type of request
    *  Returns         : void
    ******************************************************************************/
    private void submitForApproval(String type) {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        if (type == 'Contract Check') request.setComments('Submitting request for Contract check.');
        request.setObjectId(this.sourceObject.Id);
        request.setSubmitterId(UserInfo.getUserId()); 
        request.setSkipEntryCriteria(false);
        Approval.process(request); 
    }
}