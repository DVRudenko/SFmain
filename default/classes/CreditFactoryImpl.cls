public virtual class CreditFactoryImpl implements CreditFactory {
    protected CreditFactoryCompany internalCFCompany;
    protected CreditFactoryCompany externalCFCompany;
    protected CreditFactoryCompany externalAdditionalCFCompany;
    protected Decimal fuelPriceIndex;
    protected Decimal buffer;
    protected String riskCategory;
    protected Date dateOfFoundation;
    protected String billingPeriod;
    protected String paymentTerms;
    protected Decimal creditLimit;
    protected Decimal securityLevel;
    protected Decimal deposit;
    protected Decimal maxCreditLimit;
    protected String verdict;
    protected String statusCode;
    protected String depositReason;
    protected String depositReason7Plus2;
    protected String depositReason7plus7;
    protected String depositReason15Plus2;
    protected String depositReason15plus7;
    protected String depositReason15plus10;
    protected String depositReason15plus14;
    protected String depositReason30Plus2;
    protected String depositReason30plus7;
    protected String depositReason30plus10;
    protected String depositReason30plus14;
    protected String depositReason30plus27;
    protected List<CreditFactoryResult.Message> messagesList;
    protected List<String> availableButtonsList;
    protected String apiErrorMessage;
	protected Decimal recommendedCreditLimit;
	protected Date dateOfLastChangeOfDirector;
	protected Date dateOfLastChangeOfAddress;
	protected Map<String, CreditFactoryValidationItem> validationItemsMap;
	protected Decimal creditLimit7Plus7;
    protected Decimal securityLevel7Plus7;
    protected Decimal deposit7Plus7;
    protected Decimal maxCreditLimit7Plus7;
    protected Decimal creditLimit15Plus7;
    protected Decimal securityLevel15Plus7;
    protected Decimal deposit15Plus7;
    protected Decimal maxCreditLimit15Plus7;
    protected Decimal creditLimit15Plus14;
    protected Decimal securityLevel15Plus14;
    protected Decimal deposit15Plus14;
    protected Decimal maxCreditLimit15Plus14;
	protected Decimal creditLimit30Plus7;
    protected Decimal securityLevel30Plus7;
    protected Decimal deposit30Plus7;
    protected Decimal maxCreditLimit30Plus7;
    protected Decimal creditLimit30Plus14;
    protected Decimal securityLevel30Plus14;
    protected Decimal deposit30Plus14;
    protected Decimal maxCreditLimit30Plus14;
    protected Decimal creditLimit30Plus27;
    protected Decimal securityLevel30Plus27;
    protected Decimal deposit30Plus27;
    protected Decimal maxCreditLimit30Plus27;
    protected Decimal creditLimit7Plus2;
    protected Decimal securityLevel7Plus2;
    protected Decimal deposit7Plus2;
    protected Decimal maxCreditLimit7Plus2;
    protected Decimal creditLimit15Plus2;
    protected Decimal securityLevel15Plus2;
    protected Decimal deposit15Plus2;
    protected Decimal maxCreditLimit15Plus2;
    protected Decimal creditLimit30Plus2;
    protected Decimal securityLevel30Plus2;
    protected Decimal deposit30Plus2;
    protected Decimal maxCreditLimit30Plus2;
    protected Decimal creditLimit30Plus10;
    protected Decimal securityLevel30Plus10;
    protected Decimal deposit30Plus10;
    protected Decimal maxCreditLimit30Plus10;
    protected Boolean isNewBusinessException;
    protected Boolean isNewBusinessException7plus7;
    protected Boolean isNewBusinessException15plus7;
    protected Boolean isNewBusinessException30plus7;
	protected List<CreditFactoryResult> resultsList;
    protected Map<String, CreditFactoryCompany.CreditFactoryCalculation> calculationsMap;

    
    /*******************************************************************************
    *  Summary         : Set Credit Factory Company object.
    *  CreatedDate     : 01/08/2019 by Anton Buzak
    *  Parameters      : creditFactoryDataMap - full data structure
    *  Returns         : -
    ******************************************************************************/
    public void setInternalCFCompany(Map<String, Object> creditFactoryDataMap) {
        try {
            this.internalCFCompany = new CreditFactoryCompany();
            String creditFactoryJsonData = JSON.serialize(creditFactoryDataMap);
            this.internalCFCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);
            if (this.internalCFCompany.nonFuelExposure == null) {
                this.internalCFCompany.nonFuelExposure = 0;
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '.', String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException('Set Credit Factory Company failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Get Credit Factory Company   
    *  Created         : 19/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public CreditFactoryCompany getInternalCFCompany() {
        return this.internalCFCompany;
    }
    
    /*******************************************************************************
    *  Summary         : Check if reports exist in database or not
    *  CreatedDate     : 23/12/2019 by Anton Buzak
    *  Parameters      : opportunityId - Id of related Opportunity
    *  Returns         : marker of report existence
    ******************************************************************************/
    public Boolean areReportsExist(String opportunityId) {

        List<Opportunity> opportunityList = [
                SELECT Account.Id
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
        ];

        Id accountId = opportunityList.get(0).Account.Id;

        List<Credit_Factory_Report__c> reportsList = [
                SELECT Id
                FROM Credit_Factory_Report__c
                WHERE (Opportunity__c = :opportunityId
                OR (Account__c = :accountId AND Account__c != null))
                AND CreatedDate > :Date.today().addMonths(-3)
        ];

        Boolean areReportsExist;
        if (!reportsList.isEmpty()) {
            areReportsExist = true;
        } else {
            areReportsExist = false;
        }

        return areReportsExist;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select company reports from database
    *  CreatedDate     : 23/12/2019 by Anton Buzak
    *  Parameters      : opportunityId - Id of related Opportunity
    *  Returns         : reports data
    ******************************************************************************/
    public CreditFactoryReportsItem selectCompanyReports(String opportunityId) {
        CreditFactoryReportsItem reportsItem = new CreditFactoryReportsItem();
        reportsItem.companiesList = new List<CreditFactoryCompany>();

        List<Opportunity> opportunityList = [
                SELECT Account.Id
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
        ];

        Id accountId = opportunityList.get(0).Account.Id;

        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, Turn_Over__c, Legal_Form__c, Trade_Register_Number__c, Tax_Id__c, 
                    Date_Legal_Form__c, Register_Number__c, Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, 
                    Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c, Age_of_Company__c, First_Legal_Form__c, 
                    Company_Status__c, Name, Trade_Name__c, Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                    Email__c, Website__c, Solvency_Index__c, Request_Status__c, Obligation_Overdue__c, Number_Of_Hits__c, Policy_Rules_Hits__c, 
                    Name_Change_Decision__c, Address_Change_Decision__c, Postal_City__c, Postal_Housenumber__c, Postal_Postcode__c, Postal_Street__c,
                    Registered_City__c, Registered_Housenumber__c, Registered_Postcode__c, Registered_Street__c, Profit_Loss_Last_Year__c, 
                    Profit_Loss_Year_Before_Last__c, Turn_Over_Last_Year__c, PIT_Currency__c, Name__c, Email_Exists__c, Domain_Exists__c, 
                    Email_Date__c, Domain_Date__c, Email_Status__c, Email_Risk__c, Risk_Description__c, Risk_Advice__c, Fraud_Within_Industry__c, 
                    Fraud_Type__c, Total_Hits__c, Unique_Hits__c, Name_Match__c, Checked_Email__c, Creditors_Count__c, Economic_Informations_Count__c,
                    Liabilities_Count__c, Total_Amount__c, Total_Overdue_Amount__c, BIG_Requested__c, RecordType.Name, Principal_Activity_Code__c, 
                    Principal_Activity_Description__c, VAT_Number__c, Company_Id__c, Indication_Main_Establishment__c, Rsin_Number__c, Indication_Organisation__c,
                    Primary_Sbi_Code__c, Primary_Sbi_Code_Text__c, Indication_Economically_Active__c, Indication_Non_Mailing__c, Indication_Bankruptcy__c, Date_of_Last_Request__c,
                    Indication_Dip__c, Authorized_Share_Capital__c, Authorized_Share_Capital_Currency__c, Paid_Up_Share_Capital__c, Paid_Up_Share_Capital_Currency__c, Year_of_Last_Financial_Information__c,
                    Issued_Share_Capital__c, Issued_Share_Capital_Currency__c, Continuation_Date__c, Establishment_Date__c, Payment_History_Requested__c, Number_of_executions__c, Negative_Information__c,
                    Financial_Evaluation__c, Date_Of_Last_Major_Update__c, Date_Of_Last_Change_Of_Director__c, Date_Of_Last_Change_Of_Address__c, Date_Of_Last_Change_Of_Name__c, Financial_Situation__c,
                            (SELECT Type__c, Name, Date_of_Birth__c, Address__c, Participation_Date__c, Name__c, Company_Role__c, Company_Id__c,
                                    Company_Type__c, RecordType.Name, Id__c
                            FROM Credit_Factory_Report_Employees__r)
                FROM Credit_Factory_Report__c
                WHERE (Opportunity__c = :opportunityId
                OR (Account__c = :accountId AND Account__c != null))
                AND CreatedDate > :Date.today().addMonths(-3)
                ORDER BY CreatedDate DESC
                LIMIT 2];
        if (! creditReportsList.isEmpty()) {
            this.externalCFCompany = new CreditFactoryCompany();
            this.externalCFCompany.recordType = 'Default';
            this.externalCFCompany.creditFactoryContacts = new List<CreditFactoryCompany.CreditFactoryContact>();
            for (Credit_Factory_Report__c report : creditReportsList) {
                if (report.RecordType.Name == 'Default') {
                    this.externalCFCompany = returnCompany(report);
                    this.externalCFCompany.creditFactoryContacts = returnCompanyEmployees(report.Credit_Factory_Report_Employees__r);
                }
                else {
                    this.externalAdditionalCFCompany = returnAdditionalCompany(report);
                    this.externalAdditionalCFCompany.creditFactoryContacts = returnAdditionalCompanyEmployees(report.Credit_Factory_Report_Employees__r);
                    reportsItem.companiesList.add(this.externalAdditionalCFCompany);
                }
            }

            reportsItem.companiesList.add(this.externalCFCompany);
        }

        return reportsItem;
    }
    
    
    /*******************************************************************************
    *  Summary         : return company based on report from database
    *  CreatedDate     : 23/12/2019 by Anton Buzak
    *  Parameters      : creditFactoryReport - report from database
    *  Returns         : company
    ******************************************************************************/
    public CreditFactoryCompany returnCompany(Credit_Factory_Report__c report) {
        CreditFactoryCompany company = new CreditFactoryCompany();
    	company.creditSystemCompanyNumber = report.Credit_System_Number__c;
        company.classRating = report.Class_Rating__c;
        company.turnOver = report.Turn_Over__c;
        company.legalForm = report.Legal_Form__c;
        company.tradeRegisterNumber = report.Trade_Register_Number__c;
        company.taxId = report.Tax_Id__c;
        company.registerNumber = report.Register_Number__c;
        company.staffCompanyRange = report.Staff_Range__c;
        company.creditLimit = report.Credit_Limit__c;
        company.creditLimitCurrency = report.Credit_Limit_Currency__c;
        company.dateOfFoundation = report.Date_of_Foundation__c;
        company.ageOfCompany = report.Age_of_Company__c;
        company.status = report.Company_Status__c;
        company.name = report.Name__c;
        company.tradeName = report.Trade_Name__c;
        company.street = report.Street__c;
        company.houseNumber = report.Housenumber__c;
        company.postCode = report.Postcode__c;
        company.city = report.City__c;
        company.postalStreet = report.Postal_Street__c;
        company.postalHouseNumber = report.Postal_Housenumber__c;
        company.postalPostCode = report.Postal_Postcode__c;
        company.postalCity = report.Postal_City__c;
        company.registeredStreet = report.Registered_Street__c;
        company.registeredHouseNumber = report.Registered_Housenumber__c;
        company.registeredPostCode = report.Registered_Postcode__c;
        company.registeredCity = report.Registered_City__c;
        company.country = report.Country__c;
        company.phone = report.Phone__c;
        company.fax = report.Fax__c;
        company.mobile = report.Mobile__c;
        company.email = report.Email__c;
        company.website = report.Website__c;
        company.identificationNumber = report.Company_Id__c;
        company.solvencyIndex = report.Solvency_Index__c;
        company.requestStatus = report.Request_Status__c;
        company.obligationOverdue = report.Obligation_Overdue__c;
        company.paymentHistoryRequested = report.Payment_History_Requested__c;
        company.numberOfHits = report.Number_Of_Hits__c;
        company.nameChangeDecision = report.Name_Change_Decision__c;
        company.addressChangeDecision = report.Address_Change_Decision__c;
        company.profitLossLastYear = report.Profit_Loss_Last_Year__c;
        company.profitLossYearBeforeLast = report.Profit_Loss_Year_Before_Last__c;
        company.turnOverLastYear = report.Turn_Over_Last_Year__c;
        company.pitCurrency = report.PIT_Currency__c;
        company.emailExists = report.Email_Exists__c;
        company.domainExists = report.Domain_Exists__c;
        company.emailDate = report.Email_Date__c;
        company.domainDate = report.Domain_Date__c;
        company.emailStatus = report.Email_Status__c;
        company.emailRisk = report.Email_Risk__c;
        company.riskDescription = report.Risk_Description__c;
        company.riskAdvice = report.Risk_Advice__c;
        company.fraudWithinIndustry = report.Fraud_Within_Industry__c;
        company.fraudType = report.Fraud_Type__c;
        company.totalHits = report.Total_Hits__c;
        company.uniqueHits = report.Unique_Hits__c;
        company.nameMatch = report.Name_Match__c;
        company.checkedEmail = report.Checked_Email__c;
		company.creditorsCount = report.Creditors_Count__c;
		company.economicInformationsCount = report.Economic_Informations_Count__c;
		company.liabilitiesCount = report.Liabilities_Count__c;
		company.totalAmount = report.Total_Amount__c;
		company.totalOverdueAmount = report.Total_Overdue_Amount__c;
		company.bigRequested = report.BIG_Requested__c;
        company.recordType = report.RecordType.Name;
        company.principalActivityCode = report.Principal_Activity_Code__c;
        company.principalActivityDescription = report.Principal_Activity_Description__c;
        company.id = report.Id;
        company.referenceNumber = report.Reference_Number__c;
        company.vatNumber = report.VAT_Number__c;
        company.countyCourt = report.County_Court__c;
        company.solvencyIndex = report.Solvency_Index__c;
        company.numberOfExecutions = report.Number_of_executions__c;
        company.negativeInformation = report.Negative_Information__c;
        company.financialEvaluation = report.Financial_Evaluation__c;
        company.dateLastRegisterEntry = report.Date_Last_Register_Entry__c;
        company.dateLegalForm = report.Date_Legal_Form__c;
        company.dateOfLastMajorUpdate = report.Date_Of_Last_Major_Update__c;
        company.dateOfLastChangeOfDirector = report.Date_Of_Last_Change_Of_Director__c;
        company.dateOfLastChangeOfAddress = report.Date_Of_Last_Change_Of_Address__c;
        company.dateOfLastChangeOfName = report.Date_Of_Last_Change_Of_Name__c;
        company.firstLegalForm = report.First_Legal_Form__c;
        company.creditDecision = report.Credit_Decision__c;
        company.paymentBehaviour = report.Payment_Behaviour__c;
        company.yearOfLastFinancialInformation = report.Year_of_Last_Financial_Information__c;
        company.financialSituation = report.Financial_Situation__c;
        company.dateOfLastRequest = report.Date_of_Last_Request__c;
        if (report.Policy_Rules_Hits__c != null) {
        	company.policyRuleHitsList = report.Policy_Rules_Hits__c.split('\r\n');
        }

        return company;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return company employees based on report from database.   
    *  Created         : 05/03/2020
    *  Parameters      : -
    *  Returns         : contacts list
    ******************************************************************************/
    private List<CreditFactoryCompany.CreditFactoryContact> returnCompanyEmployees(List<Credit_Factory_Report_Employee__c> employeesList) {
        List<CreditFactoryCompany.CreditFactoryContact> contactsList = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (Credit_Factory_Report_Employee__c employee : employeesList) {
            CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
            contact.type = employee.Type__c;
    		contact.name = employee.Name__c;
    		if (contact.name == null) contact.name = employee.Name;
    		contact.address = employee.Address__c;
            contact.sfId = employee.Id;
            contact.id = employee.Id__c;
            contact.dateOfBirth = employee.Date_of_Birth__c;
            contact.participationDate = employee.Participation_Date__c;
            contact.companyId = employee.Company_Id__c;
            contact.companyType = employee.Company_Type__c;
            contact.companyRole = employee.Company_Role__c;
            contact.recordType = employee.RecordType.Name;
    		contactsList.add(contact);
        }
        
        return contactsList;
    }


    /*******************************************************************************
    *  Summary         : return company based on report from database
    *  CreatedDate     : 10/09/2020 by Anton Buzak
    *  Parameters      : creditFactoryReport - report from database
    *  Returns         : company
    ******************************************************************************/
    public CreditFactoryCompany returnAdditionalCompany(Credit_Factory_Report__c report) {
        CreditFactoryCompany additionalCompany = new CreditFactoryCompany();
    	additionalCompany.name = report.Name;
        additionalCompany.indicationMainEstablishment = report.Indication_Main_Establishment__c;
        additionalCompany.rsinNumber = report.Rsin_Number__c;
        additionalCompany.legalForm = report.Legal_Form__c;
        additionalCompany.indicationOrganisation = report.Indication_Organisation__c;
        additionalCompany.tradeName = report.Trade_Name__c;
        additionalCompany.postCode = report.Postcode__c;
        additionalCompany.city = report.City__c;
        additionalCompany.street = report.Street__c;
        additionalCompany.houseNumber = report.Housenumber__c;
        additionalCompany.country = report.Country__c;
        additionalCompany.phone = report.Phone__c;
        additionalCompany.mobile = report.Mobile__c;
        additionalCompany.website = report.Website__c;
        additionalCompany.primarySbiCode = report.Primary_Sbi_Code__c;
        additionalCompany.primarySbiCodeText = report.Primary_Sbi_Code_Text__c;
        additionalCompany.staffCompanyRange = report.Staff_Range__c;
        additionalCompany.indicationEconomicallyActive = report.Indication_Economically_Active__c;
        additionalCompany.indicationNonMailing = report.Indication_Non_Mailing__c;
        additionalCompany.indicationBankruptcy = report.Indication_Bankruptcy__c;
        additionalCompany.indicationDip = report.Indication_Dip__c;
        additionalCompany.authorizedShareCapital = report.Authorized_Share_Capital__c;
        additionalCompany.authorizedShareCapitalCurrency = report.Authorized_Share_Capital_Currency__c;
        additionalCompany.paidUpShareCapital = report.Paid_Up_Share_Capital__c;
        additionalCompany.paidUpShareCapitalCurrency = report.Paid_Up_Share_Capital_Currency__c;
        additionalCompany.issuedShareCapital = report.Issued_Share_Capital__c;
        additionalCompany.issuedShareCapitalCurrency = report.Issued_Share_Capital_Currency__c;
        additionalCompany.continuationDate = report.Continuation_Date__c;
        additionalCompany.establishmentDate = report.Establishment_Date__c;
        additionalCompany.dateOfFoundation  = report.Date_of_Foundation__c;
        additionalCompany.recordType = report.RecordType.Name;
        additionalCompany.identificationNumber = report.Company_Id__c;

        return additionalCompany;
    }


    /*******************************************************************************
    *  Summary         : Return company employees based on report from database.
    *  Created         : 10/09/2020 by Anton Buzak
    *  Parameters      : employeesList
    *  Returns         : contacts list
    ******************************************************************************/
    private List<CreditFactoryCompany.CreditFactoryContact> returnAdditionalCompanyEmployees(List<Credit_Factory_Report_Employee__c> employeesList) {
        List<CreditFactoryCompany.CreditFactoryContact> contactsList = new List<CreditFactoryCompany.CreditFactoryContact>();
        for (Credit_Factory_Report_Employee__c employee : employeesList) {
            CreditFactoryCompany.CreditFactoryContact contact = new CreditFactoryCompany.CreditFactoryContact();
    		contact.name = employee.Name__c;
            contact.dateOfBirth = employee.Date_of_Birth__c;
            contact.companyRole = employee.Company_Role__c;
            contact.recordType = employee.RecordType.Name;
    		contactsList.add(contact);
        }

        return contactsList;
    }
    
    
    public virtual List<CreditFactoryCompany> requestSearchCompanies(Set<String> searchParametersSet) {
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return the list of fields to update after search
    *  Created         : 31/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : list of fields
    ******************************************************************************/
    public virtual Map<String, Object> returnSearchFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        if (this.internalCFCompany.cfStage != null && this.internalCFCompany.cfStage != 'Auto CW' && this.internalCFCompany.cfStage != 'Manual scoring' &&
                this.internalCFCompany.cfStage != 'Pending deposit' && this.internalCFCompany.cfStage != 'Pending Credit - Contract Check' &&
                ! this.internalCFCompany.cfStage.contains('Pending Credit Report')) {
            opportunityFieldsMap.put('CF_Stage__c', 'Launched');
        }
        
		fieldsMap.put('Opportunity', opportunityFieldsMap);
        return fieldsMap;
    }


    public virtual void requestStartReportsCheck(String selectedCompanyId) {}


    public virtual CreditFactoryReportsItem requestCompanyReports(String selectedCompanyId) {
        return null;
    }


    /*******************************************************************************
    *  Summary         : Get xml node from response
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : body - body from response
    *  Returns         : body xml node
    ******************************************************************************/
    protected virtual Dom.XmlNode getXmlNode(String body) {
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(body);
        Dom.XmlNode XmlNode = domDoc.getRootElement();
        return XmlNode;
    }


	/*******************************************************************************
    *  Summary         : Send request to LexisNexis to get risks and set response
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : lexisNexisSettings - LexisNexis settings
    *  Returns         : LexisNexis report request
    ******************************************************************************/
    protected virtual HttpResponse requestLexisNexisReport(LexisNexis_Settings__c lexisNexisSettings) {
        CreditFactoryCompany.CreditFactoryContact primaryContact;
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.isPrimary == true) {
                primaryContact = contact;
                break;
            }
        }

        HttpRequest request = CreditFactoryWebLexisNexis.generateIDURequest(
            lexisNexisSettings.Endpoint__c, lexisNexisSettings.User_Name__c, lexisNexisSettings.Password__c,
            primaryContact.firstName, primaryContact.lastName, primaryContact.email,
            CreditFactoryGlobalUtils.returnReferenceForLexisNexis(this.internalCFCompany.countryCode));
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    
    public virtual CreditFactoryOrderItem requestOrder(String internalId) {
        return null;
    }
    
    public virtual Map<String, Object> returnOrderFieldsToUpdate(String orderReferenceNumber) {
        return null;
    }
    
    
    public virtual CreditFactoryResult doCreditScoring(Set<String> paymentDetailsSet,  Map<String, CreditFactoryValidationItem> validationItemsMap) {
        return null;
    }
    
    
    public virtual CreditFactoryReportsItem requestAdditionalCreditScoringData(Map<String, CreditFactoryValidationItem> validationItemsMap) {
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Create instance of Credit Factory Report object
    *  CreatedDate     : 13/11/2019
    *  Parameters      : -
    *  Returns         : list of reports 
    ******************************************************************************/
    public List<Credit_Factory_Report__c> createCFReportsInstances() {
        List<Credit_Factory_Report__c> reportsList = new List<Credit_Factory_Report__c>();
        if (this.externalCFCompany.name != null) {
            Credit_Factory_Report__c defaultCfReport = createDefaultCFReportInstance();
            reportsList.add(defaultCfReport);
        }

        if (this.externalAdditionalCFCompany != null) {
            Credit_Factory_Report__c additionalCfReport = createAdditionalCFReportInstance();
            reportsList.add(additionalCfReport);
        }

        return reportsList;
    }


    /*******************************************************************************
    *  Summary         : Create instance of default Credit Factory Report object
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : default report
    ******************************************************************************/
    private Credit_Factory_Report__c createDefaultCFReportInstance() {
        String reportName = this.externalCFCompany.name;
        if (reportName != null && reportName.length() > 80) {
            reportName = reportName.substring(0, 80);
        }

        Credit_Factory_Report__c cfReport = new Credit_Factory_Report__c(
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', this.externalCFCompany.recordType),
            Credit_System_Number__c = this.externalCFCompany.creditSystemCompanyNumber,
            Age_of_Company__c = this.externalCFCompany.ageOfCompany,
            City__c = this.externalCFCompany.city,
            Company_Status__c = this.externalCFCompany.status,
            Country__c = this.externalCFCompany.country,
            County_Court__c = this.externalCFCompany.countyCourt,
            Credit_Limit__c = this.externalCFCompany.creditLimit,
            Credit_Limit_Currency__c = this.externalCFCompany.creditLimitCurrency,
            Date_of_Foundation__c = this.externalCFCompany.dateOfFoundation,
            Email__c = this.externalCFCompany.email,
            Fax__c = this.externalCFCompany.fax,
            First_Legal_Form__c = this.externalCFCompany.firstLegalForm,
            Fiscal_Number__c = this.externalCFCompany.taxId,
            Housenumber__c = this.externalCFCompany.houseNumber,
            Legal_Form__c = this.externalCFCompany.legalForm,
            Mobile__c = this.externalCFCompany.mobile,
            Phone__c = this.externalCFCompany.phone,
            Postcode__c = this.externalCFCompany.postCode,
            Register_Number__c = this.externalCFCompany.registerNumber,
            Staff_Range__c = this.externalCFCompany.staffCompanyRange,
            Street__c = this.externalCFCompany.street,
            Trade_Name__c = this.externalCFCompany.tradeName,
            Turn_Over__c = this.externalCFCompany.turnOver,
            VAT_Number__c = this.externalCFCompany.vatNumber,
            Trade_Register_Number__c = this.externalCFCompany.tradeRegisterNumber,
            Tax_Id__c = this.externalCFCompany.taxId,
            Website__c = this.externalCFCompany.website,
            Name = reportName,
            Company_Id__c = this.externalCFCompany.identificationNumber,
            Solvency_Index__c = this.externalCFCompany.solvencyIndex,
            Request_Status__c = this.externalCFCompany.requestStatus,
            Obligation_Overdue__c = (this.externalCFCompany.obligationOverdue != null ? this.externalCFCompany.obligationOverdue : false),
            Payment_History_Requested__c = (this.externalCFCompany.paymentHistoryRequested != null ? this.externalCFCompany.paymentHistoryRequested : false),
            Class_Rating__c = this.externalCFCompany.classRating,
            Number_Of_Hits__c = this.externalCFCompany.numberOfHits,
            Policy_Rules_Hits__c = (this.externalCFCompany.policyRuleHitsList != null ? String.join(this.externalCFCompany.policyRuleHitsList, '\r\n') : null),
            Name_Change_Decision__c = this.externalCFCompany.nameChangeDecision,
            Address_Change_Decision__c = this.externalCFCompany.addressChangeDecision,
            Postal_Street__c = this.externalCFCompany.postalStreet,
            Postal_Housenumber__c = this.externalCFCompany.postalHouseNumber,
            Postal_City__c = this.externalCFCompany.postalCity,
            Postal_Postcode__c = this.externalCFCompany.postalPostCode,
            Registered_Street__c = this.externalCFCompany.registeredStreet,
            Registered_Housenumber__c = this.externalCFCompany.registeredHouseNumber,
            Registered_City__c = this.externalCFCompany.registeredCity,
            Registered_Postcode__c = this.externalCFCompany.registeredPostCode,
            Profit_Loss_Last_Year__c = this.externalCFCompany.profitLossLastYear,
            Profit_Loss_Year_Before_Last__c = this.externalCFCompany.profitLossYearBeforeLast,
            Turn_Over_Last_Year__c = this.externalCFCompany.turnOverLastYear,
            PIT_Currency__c = this.externalCFCompany.pitCurrency,
            CurrencyIsoCode = returnCurrencyIsoCode(this.internalCFCompany.countryCode),
            Name__c = this.externalCFCompany.name,
            Email_Exists__c = this.externalCFCompany.emailExists,
            Domain_Exists__c = this.externalCFCompany.domainExists,
            Email_Date__c = this.externalCFCompany.emailDate,
            Domain_Date__c = this.externalCFCompany.domainDate,
            Email_Status__c = this.externalCFCompany.emailStatus,
            Email_Risk__c = this.externalCFCompany.emailRisk,
            Risk_Description__c = this.externalCFCompany.riskDescription,
            Risk_Advice__c = this.externalCFCompany.riskAdvice,
            Fraud_Within_Industry__c = this.externalCFCompany.fraudWithinIndustry,
            Fraud_Type__c = this.externalCFCompany.fraudType,
            Total_Hits__c = this.externalCFCompany.totalHits,
            Unique_Hits__c = this.externalCFCompany.uniqueHits,
            Name_Match__c = this.externalCFCompany.nameMatch,
            Checked_Email__c = this.externalCFCompany.checkedEmail,
            Creditors_Count__c = this.externalCFCompany.creditorsCount,
            Economic_Informations_Count__c = this.externalCFCompany.economicInformationsCount,
            Liabilities_Count__c = this.externalCFCompany.liabilitiesCount,
            Total_Amount__c = this.externalCFCompany.totalAmount,
            Total_Overdue_Amount__c = this.externalCFCompany.totalOverdueAmount,
            BIG_Requested__c = (this.externalCFCompany.bigRequested != null ? this.externalCFCompany.bigRequested : false),
            Principal_Activity_Code__c = this.externalCFCompany.principalActivityCode,
            Principal_Activity_Description__c = this.externalCFCompany.principalActivityDescription,
            Number_of_executions__c = this.externalCFCompany.numberOfExecutions,
            Negative_Information__c = this.externalCFCompany.negativeInformation,
            Financial_Evaluation__c = (this.externalCFCompany.financialEvaluation != null ? this.externalCFCompany.financialEvaluation : false),
            Date_Last_Register_Entry__c = this.externalCFCompany.dateLastRegisterEntry,
            Date_Legal_Form__c = this.externalCFCompany.dateLegalForm,
            Date_Of_Last_Major_Update__c = this.externalCFCompany.dateOfLastMajorUpdate,
            Paid_Up_Share_Capital__c = this.externalCFCompany.paidUpShareCapital,
            Paid_Up_Share_Capital_Currency__c = this.externalCFCompany.paidUpShareCapitalCurrency,
            Date_Of_Last_Change_Of_Director__c = this.externalCFCompany.dateOfLastChangeOfDirector,
            Date_Of_Last_Change_Of_Address__c = this.externalCFCompany.dateOfLastChangeOfAddress,
            Date_Of_Last_Change_Of_Name__c = this.externalCFCompany.dateOfLastChangeOfName,
            Credit_Decision__c = this.externalCFCompany.creditDecision,
            Payment_Behaviour__c = this.externalCFCompany.paymentBehaviour,
            Reference_Number__c = this.externalCFCompany.referenceNumber,
            Year_of_Last_Financial_Information__c = this.externalCFCompany.yearOfLastFinancialInformation,
            Financial_Situation__c = this.externalCFCompany.financialSituation,
            Date_of_Last_Request__c = this.externalCFCompany.dateOfLastRequest);

        if (this.externalCFCompany.email != null && this.externalCFCompany.checkedEmail != null) {
            String companyEmailDomain = this.externalCFCompany.email.substringAfter('@').toUpperCase();
            String primaryContactEMailDomain = this.externalCFCompany.checkedEmail.substringAfter('@').toUpperCase();
            if (companyEmailDomain != primaryContactEMailDomain) {
                cfReport.Emails_Mismatch__c = true;
            }
            else {
                cfReport.Emails_Mismatch__c = false;
            }
        }

        return cfReport;
    }


    /*******************************************************************************
    *  Summary         : Create instance of additional Credit Factory Report object
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : default report
    ******************************************************************************/
    private Credit_Factory_Report__c createAdditionalCFReportInstance() {
        String reportName = this.externalAdditionalCFCompany.tradeName;
        if (reportName != null && reportName.length() > 80) {
            reportName = reportName.substring(0, 80);
        }

        Credit_Factory_Report__c cfReport = new Credit_Factory_Report__c(
            Name = reportName,
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', this.externalAdditionalCFCompany.recordType),
            Indication_Main_Establishment__c = this.externalAdditionalCFCompany.indicationMainEstablishment,
            Rsin_Number__c = this.externalAdditionalCFCompany.rsinNumber,
            Legal_Form__c = this.externalAdditionalCFCompany.legalForm,
            Indication_Organisation__c = this.externalAdditionalCFCompany.indicationOrganisation,
            Trade_Name__c = this.externalAdditionalCFCompany.tradeName,
            Postcode__c = this.externalAdditionalCFCompany.postCode,
            City__c = this.externalAdditionalCFCompany.city,
            Street__c = this.externalAdditionalCFCompany.street,
            Housenumber__c = this.externalAdditionalCFCompany.houseNumber,
            Country__c = this.externalAdditionalCFCompany.country,
            Phone__c = this.externalAdditionalCFCompany.phone,
            Mobile__c = this.externalAdditionalCFCompany.mobile,
            Website__c = this.externalAdditionalCFCompany.website,
            Primary_Sbi_Code__c = this.externalAdditionalCFCompany.primarySbiCode,
            Primary_Sbi_Code_Text__c = this.externalAdditionalCFCompany.primarySbiCodeText,
            Staff_Range__c = this.externalAdditionalCFCompany.staffCompanyRange,
            Indication_Economically_Active__c = this.externalAdditionalCFCompany.indicationEconomicallyActive,
            Indication_Non_Mailing__c = this.externalAdditionalCFCompany.indicationNonMailing,
            Indication_Bankruptcy__c = this.externalAdditionalCFCompany.indicationBankruptcy,
            Indication_Dip__c = this.externalAdditionalCFCompany.indicationDip,
            Authorized_Share_Capital__c = this.externalAdditionalCFCompany.authorizedShareCapital,
            Authorized_Share_Capital_Currency__c = this.externalAdditionalCFCompany.authorizedShareCapitalCurrency,
            Paid_Up_Share_Capital__c = this.externalAdditionalCFCompany.paidUpShareCapital,
            Paid_Up_Share_Capital_Currency__c = this.externalAdditionalCFCompany.paidUpShareCapitalCurrency,
            Issued_Share_Capital__c = this.externalAdditionalCFCompany.issuedShareCapital,
            Issued_Share_Capital_Currency__c = this.externalAdditionalCFCompany.issuedShareCapitalCurrency,
            Continuation_Date__c = this.externalAdditionalCFCompany.continuationDate,
            Establishment_Date__c = this.externalAdditionalCFCompany.establishmentDate,
            Company_Id__c = this.externalAdditionalCFCompany.identificationNumber,
            Date_of_Foundation__c = this.externalAdditionalCFCompany.dateOfFoundation,
            Name__c = this.externalAdditionalCFCompany.tradeName);

        return cfReport;
    }


    protected virtual String returnCurrencyIsoCode(String countryCode) {
        return 'EUR';
    }


    /*******************************************************************************
    *  Summary         : Create instance of Credit Factory Report Employee object
    *  CreatedDate     : 24/12/2019 by Anton Buzak
    *  Parameters      : -
    *  Returns         : list of report employees
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> createCFReportEmployeesInstances() {
        List<Credit_Factory_Report_Employee__c> employeesList = new List<Credit_Factory_Report_Employee__c>();
        employeesList = createDefaultCFReportEmployeesInstances();
        if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.creditFactoryContacts != null) {
            employeesList.addAll(createAdditionalCFReportEmployeesInstances());
        }

        return employeesList;
    }


    /*******************************************************************************
    *  Summary         : Create default instances of Credit Factory Report Employee object
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : list of default report employees
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> createDefaultCFReportEmployeesInstances() {
        List<Credit_Factory_Report_Employee__c> employeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditFactoryCompany.CreditFactoryContact contact : this.externalCFCompany.creditFactoryContacts) {
            String contactName = contact.name;
            if (contactName != null && contactName.length() > 80) {
                contactName = contactName.substring(0, 80);
            }

            employeesList.add(new Credit_Factory_Report_Employee__c(
                RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', contact.recordType),
                Address__c = contact.address,
                Date_of_Birth__c = contact.dateOfBirth,
                Id__c = contact.id,
                Participation_Date__c = contact.participationDate,
                Name = contactName,
                Name__c = contactName,
                Type__c = contact.type,
                Company_Id__c = contact.companyId,
                Company_Type__c = contact.companyType,
                Company_Role__c = contact.companyRole,
                Id = contact.sfId));
        }

        return employeesList;
    }


    /*******************************************************************************
    *  Summary         : Create additional instances of Credit Factory Report Employee object
    *  CreatedDate     : 09/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : list of additional report employees
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> createAdditionalCFReportEmployeesInstances() {
        List<Credit_Factory_Report_Employee__c> employeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditFactoryCompany.CreditFactoryContact contact : this.externalAdditionalCFCompany.creditFactoryContacts) {
            String contactName = contact.name;
            if (contactName != null && contactName.length() > 80) {
                contactName = contactName.substring(0, 80);
            }

            employeesList.add(new Credit_Factory_Report_Employee__c(
                RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', contact.recordType),
                Date_of_Birth__c = contact.dateOfBirth,
                Name = contactName,
                Name__c = contactName,
                Company_Role__c = contact.companyRole));
        }

        return employeesList;
    }


    /*******************************************************************************
    *  Summary         : Create instance for Black List
    *  CreatedDate     : 10/06/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : black list company
    ******************************************************************************/
    public Credit_Black_List_Company__c createBlackListInstance() {
        Credit_Black_List_Company__c blackListCompany = new Credit_Black_List_Company__c();
        blackListCompany.Name = this.externalCFCompany.name;
        blackListCompany.Customer_Full_Name__c = this.externalCFCompany.name;
        blackListCompany.TAX_ID__c = this.externalCFCompany.taxId;
        blackListCompany.Customer_Id__c = this.internalCFCompany.countryCode;
        for (CreditFactoryCompany.CreditFactoryContact contact : this.internalCFCompany.creditFactoryContacts) {
            if (contact.isPrimary == true) {
                blackListCompany.Primary_Email__c = contact.email;
                blackListCompany.Primary_Phone__c = contact.phone;
                break;
            }
        }

        return blackListCompany;
    }
    
    
    protected virtual void setRiskCategory() {}
    
    
    /*******************************************************************************
    *  Summary         : Return fields to update
    *  CreatedDate     : 20/02/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnReportFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();

        Map<String, Object> opportunityFieldsMap = returnOpportunityFieldsToUpdate();
        fieldsMap.put('Opportunity', opportunityFieldsMap);

        Map<String, Object> accountFieldsMap = returnAccountFieldsToUpdate();
		fieldsMap.put('Account', accountFieldsMap);

        Date birthDate = returnCfContactBirthdate();
        if (birthDate != null) {
            Map<String, Object> contactFieldsMap = returnContactFieldsToUpdate(birthDate);
            fieldsMap.put('Contact', contactFieldsMap);
        }

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields to update in Opportunity
    *  CreatedDate     : 25/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnOpportunityFieldsToUpdate() {
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        opportunityFieldsMap.put('Updated_From_Credit_Factory__c', true);
        if (this.isNewBusinessException == true) {
            opportunityFieldsMap.put('Credit_System_Rating__c', '0-EX');
        }
        else if (this.externalCFCompany.classRating != null) {
            opportunityFieldsMap.put('Credit_System_Rating__c', this.externalCFCompany.classRating);
        }

        if (this.externalCFCompany.creditLimit != null && this.externalCFCompany.creditLimit.isNumeric()) {
            opportunityFieldsMap.put('Credit_System_Recommended_Limit__c', Decimal.valueOf(this.externalCFCompany.creditLimit));
        } else {
            opportunityFieldsMap.put('Credit_System_Recommended_Limit__c', 0);
        }

        if (this.externalCFCompany.turnOver != null) {
            opportunityFieldsMap.put('Umsatz__c', this.externalCFCompany.turnOver);
        }

        if (this.externalCFCompany.dateOfFoundation != null && this.externalCFCompany.dateOfFoundation.length() >= 4) {
            if (! this.externalCFCompany.dateOfFoundation.substring(0, 4).contains('.')) {
                opportunityFieldsMap.put('Gruendungsjahr__c', this.externalCFCompany.dateOfFoundation.substring(0, 4));
            }
            else if (! this.externalCFCompany.dateOfFoundation.substring(6, 10).contains('.')) {
                opportunityFieldsMap.put('Gruendungsjahr__c', this.externalCFCompany.dateOfFoundation.substring(6, 10));
            }
        }
        else if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.dateOfFoundation != null) {
            opportunityFieldsMap.put('Gruendungsjahr__c', this.externalAdditionalCFCompany.dateOfFoundation.substring(0, 4));
        }

        if (this.externalCFCompany.creditSystemCompanyNumber != null) {
            opportunityFieldsMap.put('Credit_System_Number__c', this.externalCFCompany.creditSystemCompanyNumber);
        }
        else if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.creditSystemCompanyNumber != null) {
            opportunityFieldsMap.put('Credit_System_Number__c', this.externalAdditionalCFCompany.creditSystemCompanyNumber);
        }

        if (this.externalCFCompany.staffCompanyRange != null) {
            opportunityFieldsMap.put('Zahl_der_Mitarbeiter__c', this.externalCFCompany.staffCompanyRange);
        }
        else if (this.externalAdditionalCFCompany != null && this.externalAdditionalCFCompany.staffCompanyRange != null) {
            opportunityFieldsMap.put('Zahl_der_Mitarbeiter__c', this.externalAdditionalCFCompany.staffCompanyRange);
        }

        if (this.externalCFCompany.solvencyIndex != null && this.externalCFCompany.solvencyIndex.length() <= 3) {
            opportunityFieldsMap.put('Bonitaetsindex__c', this.externalCFCompany.solvencyIndex);
        }

        if (this.externalCFCompany.profitLossLastYear != null && Decimal.valueOf(this.externalCFCompany.profitLossLastYear) != null) {
            opportunityFieldsMap.put('Profit_loss_last_year__c', Decimal.valueOf(this.externalCFCompany.profitLossLastYear));
		}

		if (this.externalCFCompany.profitLossYearBeforeLast != null && Decimal.valueOf(this.externalCFCompany.profitLossYearBeforeLast) != null) {
            opportunityFieldsMap.put('Profit_loss_year_before_last__c', Decimal.valueOf(this.externalCFCompany.profitLossYearBeforeLast));
		}

		if (this.externalCFCompany.turnOverLastYear != null && Decimal.valueOf(this.externalCFCompany.turnOverLastYear) != null) {
            opportunityFieldsMap.put('Turnover_last_year__c', Decimal.valueOf(this.externalCFCompany.turnOverLastYear));
		}

        setRiskCategory();
        opportunityFieldsMap.put('Risk_Category__c', this.riskCategory);
        opportunityFieldsMap.put('Angaben_korrekt__c', 'Ja');
        opportunityFieldsMap.put('CF_Stage__c', 'Report generated');
        opportunityFieldsMap.put('Last_CF_Errors__c', null);
        opportunityFieldsMap.put('Credit_Factory_PDF_Report_Created__c', true);

        if (this.externalCFCompany.parentCompanyId != null) {
            String riskCategoryJustification = 'Parent company used for the scoring based on ' +
                (this.externalCFCompany.providerDescription == CreditFactoryGlobalUtils.BRANCH ? 'branch' : '') + (this.externalCFCompany.providerDescription == CreditFactoryGlobalUtils.STATEMENT_403 ? '403 statement' : '');
            opportunityFieldsMap.put('Risk_Category_Begruendung__c', riskCategoryJustification);
        }

        return opportunityFieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields to update in Account
    *  CreatedDate     : 25/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnAccountFieldsToUpdate() {
        Map<String, Object> accountFieldsMap = new Map<String, Object>();

        if (this.externalCFCompany.legalForm != null) {
            accountFieldsMap.put('Gesellschaftsform__c', this.externalCFCompany.legalForm);
        }

        if (this.externalCFCompany.principalActivityCode != null) {
            accountFieldsMap.put('Branchencode__c', this.externalCFCompany.principalActivityCode);
        }

        if (this.externalCFCompany.principalActivityDescription != null) {
            accountFieldsMap.put('Branchentext__c', this.externalCFCompany.principalActivityDescription);
        }

        return accountFieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields to update in Contact
    *  CreatedDate     : 25/09/2020 by Ivan Kulinkovich
    *  Parameters      : birthDate - Contact's Birthday
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnContactFieldsToUpdate(Date birthDate) {
        Map<String, Object> contactFieldsMap = new Map<String, Object>();
        contactFieldsMap.put('Birthdate', birthDate);
        return contactFieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields to update in Report after additional scoring
    *  CreatedDate     : 21/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnReportAdditionalScoringFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> reportFieldsMap = new Map<String, Object>();

        reportFieldsMap.put('Creditors_Count__c', this.externalCFCompany.creditorsCount);
        reportFieldsMap.put('Economic_Informations_Count__c', this.externalCFCompany.economicInformationsCount);
        reportFieldsMap.put('Liabilities_Count__c', this.externalCFCompany.liabilitiesCount);
        reportFieldsMap.put('Total_Amount__c', this.externalCFCompany.totalAmount);
        reportFieldsMap.put('Total_Overdue_Amount__c', this.externalCFCompany.totalOverdueAmount);
        reportFieldsMap.put('BIG_Requested__c', this.externalCFCompany.bigRequested);

        fieldsMap.put('Credit_Factory_Report__c', reportFieldsMap);

        return fieldsMap;
    }


    public virtual Map<String, Object> returnPaymentHistoryFieldsToUpdate() {
        return null;
    }


    /*******************************************************************************
    *  Summary         : returns birth date
    *  CreatedDate     : 11/08/2020 by Anton Buzak
    *  Parameters      : sfContact - primary contact in Salesforce
    *  Returns         : date of birth
    ******************************************************************************/
    protected virtual Date returnCfContactBirthdate() {
        return null;
    }


    protected virtual String replaceSpecificCharacters(String stringToReplace) {
        return null;
    }
    
    
    public virtual void createPdfReports(String opportunityId) {}

    public virtual void createPaymentHistoryAttachment(String opportunityId) {}

    
    /*******************************************************************************
    *  Summary         : Return address fields to update in Account
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnAddressFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        String streetAndHouseNumber = ((this.externalCFCompany.street != null ? this.externalCFCompany.street : '') + ' ' + 
            (this.externalCFCompany.houseNumber != null ? this.externalCFCompany.houseNumber : '')).removeStart(' ').removeEnd(' ');
        accountFieldsMap.put('BillingStreet', streetAndHouseNumber);
        accountFieldsMap.put('BillingPostalCode', this.externalCFCompany.postCode);
        accountFieldsMap.put('BillingCity', this.externalCFCompany.city);
        accountFieldsMap.put('ShippingStreet', streetAndHouseNumber);
        accountFieldsMap.put('ShippingPostalCode', this.externalCFCompany.postCode);
        accountFieldsMap.put('ShippingCity', this.externalCFCompany.city);
		fieldsMap.put('Account', accountFieldsMap);
                    
        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return additional address fields to update in Account
    *  CreatedDate     : 10/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnAdditionalAddressFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        String streetAndHouseNumber = ((this.externalAdditionalCFCompany.street != null ? this.externalAdditionalCFCompany.street : '') + ' ' +
            (this.externalAdditionalCFCompany.houseNumber != null ? this.externalAdditionalCFCompany.houseNumber : '')).removeStart(' ').removeEnd(' ');
        accountFieldsMap.put('BillingStreet', streetAndHouseNumber);
        accountFieldsMap.put('BillingPostalCode', this.externalAdditionalCFCompany.postCode);
        accountFieldsMap.put('BillingCity', this.externalAdditionalCFCompany.city);
        accountFieldsMap.put('ShippingStreet', streetAndHouseNumber);
        accountFieldsMap.put('ShippingPostalCode', this.externalAdditionalCFCompany.postCode);
        accountFieldsMap.put('ShippingCity', this.externalAdditionalCFCompany.city);
		fieldsMap.put('Account', accountFieldsMap);

        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return postal address fields to update in Account
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnPostalAddressFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        String streetAndHouseNumber = ((this.externalCFCompany.postalStreet != null ? this.externalCFCompany.postalStreet : '') + ' ' + 
            (this.externalCFCompany.postalHouseNumber != null ? this.externalCFCompany.postalHouseNumber : '')).removeStart(' ').removeEnd(' ');
        accountFieldsMap.put('BillingStreet', streetAndHouseNumber);
        accountFieldsMap.put('BillingPostalCode', this.externalCFCompany.postalPostCode);
        accountFieldsMap.put('BillingCity', this.externalCFCompany.postalCity);
        accountFieldsMap.put('ShippingStreet', streetAndHouseNumber);
        accountFieldsMap.put('ShippingPostalCode', this.externalCFCompany.postalPostCode);
        accountFieldsMap.put('ShippingCity', this.externalCFCompany.postalCity);
		fieldsMap.put('Account', accountFieldsMap);
                    
        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return registered address fields to update in Account
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnRegisteredAddressFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        String streetAndHouseNumber = ((this.externalCFCompany.registeredStreet != null ? this.externalCFCompany.registeredStreet : '') + ' ' + 
            (this.externalCFCompany.registeredHouseNumber != null ? this.externalCFCompany.registeredHouseNumber : '')).removeStart(' ').removeEnd(' ');
        accountFieldsMap.put('BillingStreet', streetAndHouseNumber);
        accountFieldsMap.put('BillingPostalCode', this.externalCFCompany.registeredPostCode);
        accountFieldsMap.put('BillingCity', this.externalCFCompany.registeredCity);
        accountFieldsMap.put('ShippingStreet', streetAndHouseNumber);
        accountFieldsMap.put('ShippingPostalCode', this.externalCFCompany.registeredPostCode);
        accountFieldsMap.put('ShippingCity', this.externalCFCompany.registeredCity);
		fieldsMap.put('Account', accountFieldsMap);
                    
        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return company name fields to update in Account
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public virtual Map<String, Object> returnNameFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Name', this.externalCFCompany.name);
		fieldsMap.put('Account', accountFieldsMap);
                    
        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return trade name fields to update in Account
    *  CreatedDate     : 30/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnTradeNameFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Name', this.externalCFCompany.tradeName);
        fieldsMap.put('Account', accountFieldsMap);

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return company name fields to update in Account
    *  CreatedDate     : 10/09/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnAdditionalNameFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Name', this.externalAdditionalCFCompany.name);
		fieldsMap.put('Account', accountFieldsMap);

        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return tax id fields to update in Account
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnTaxIdFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Steuernummer__c', this.externalCFCompany.taxId);
		fieldsMap.put('Account', accountFieldsMap);
                    
        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return trade register number fields to update in Account
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public virtual Map<String, Object> returnTradeRegisterNumberFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('HR_Abteilung_HRA_HRB_und_HR_Nummer__c', this.externalCFCompany.tradeRegisterNumber);
		fieldsMap.put('Account', accountFieldsMap);
                    
        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return vat number fields to update in Account
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnVatNumberFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Umsatzsteuer_ID__c', this.externalCFCompany.vatNumber);
		fieldsMap.put('Account', accountFieldsMap);

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return swift bic fields to update in Account
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnSwiftBicFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        opportunityFieldsMap.put('SWIFT_BIC__c', this.internalCFCompany.requestedSwiftBic);
		fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }

    
    /*******************************************************************************
    *  Summary         : Return call confirmation fields to update
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnCallFieldsToUpdate(String callId) {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> accountFieldsMap = new Map<String, Object>();
        accountFieldsMap.put('Contact_Role_Confirmation_Call__c', System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + callId);
		fieldsMap.put('Opportunity', accountFieldsMap);
                    
        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return fields for "Closed Lost" decision
    *  CreatedDate     : 10/06/2020 by Anton Buzak
    *  Parameters      : reasonLost - reason of lost
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnClosedLostFieldsToUpdate(String reasonLost) {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        opportunityFieldsMap.put('StageName', 'Closed Lost');
        if (reasonLost == 'Not a legal entity') {
            opportunityFieldsMap.put('Gruende_verloren__c', 'Not a Lead/Opportunity');
        }
        else if (reasonLost == 'Refused Credit') {
            opportunityFieldsMap.put('Gruende_verloren__c', 'Financial/Credit');
        }
        
        opportunityFieldsMap.put('Sub_stage_detail__c', reasonLost);
        opportunityFieldsMap.put('Kredit_Entscheidung__c', 'Abgelehnt');
        fieldsMap.put('Opportunity', opportunityFieldsMap);
        
        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields for "Update Opportunity" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnUpdateOpportunityFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        opportunityFieldsMap.put('Zahlungsziel_Credit__c', this.paymentTerms);
        opportunityFieldsMap.put('Rechnungsperiode__c', this.billingPeriod);
        opportunityFieldsMap.put('CF_Credit_Limit__c', this.creditLimit);
        opportunityFieldsMap.put('Credit_check_date__c', Date.today());
        opportunityFieldsMap.put('Billing_Period_by_Sales__c',true);
        opportunityFieldsMap.put('Max_Credit_Limit__c', this.maxCreditLimit);
		fieldsMap.put('Opportunity', opportunityFieldsMap);
        return fieldsMap;
    }
    
    /*******************************************************************************
    *  Summary         : Return fields for "Contract Check" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnContractCheckFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        if (this.internalCFCompany.recordType == 'Lotos') {
            opportunityFieldsMap.put('Credit_Stage__c', 'Pending Credit - Contract Check');
        }
        else {
            opportunityFieldsMap.put('StageName', 'Pending Credit - Contract Check');
        }
        
        opportunityFieldsMap.put('Zahlungsziel_Credit__c', this.paymentTerms);
        opportunityFieldsMap.put('Rechnungsperiode__c', this.billingPeriod);
        opportunityFieldsMap.put('CF_Credit_Limit__c', this.creditLimit);
        opportunityFieldsMap.put('Credit_check_date__c', Date.today());
        opportunityFieldsMap.put('bearbeitet_von__c', 'Autoprocessed by Sales');
        opportunityFieldsMap.put('Kredit_Entscheidung__c', 'Genehmigt');
        opportunityFieldsMap.put('CloseDate', Date.today());
        opportunityFieldsMap.put('Billing_Period_by_Sales__c', true);
        opportunityFieldsMap.put('Max_Credit_Limit__c', this.maxCreditLimit);
        opportunityFieldsMap.put('Last_CF_Errors__c', null);
        opportunityFieldsMap.put('Security_To_Pay__c', null);
        opportunityFieldsMap.put('Security_Amount_To_Pay__c', null);
        opportunityFieldsMap.put('Pending_Deposit_by_CF__c', false);
        opportunityFieldsMap.put('Security_level_H_he_der_Sicherheit__c', null);
        opportunityFieldsMap.put('CF_Stage__c', 'Pending Credit - Contract Check');
        fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }
    
    /*******************************************************************************
    *  Summary         : Return fields for "Closed Won" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnClosedWonFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        opportunityFieldsMap.put('StageName', 'Closed Won');
        opportunityFieldsMap.put('Zahlungsziel_Credit__c', this.paymentTerms);
        opportunityFieldsMap.put('Rechnungsperiode__c', this.billingPeriod);
        opportunityFieldsMap.put('CF_Credit_Limit__c', this.creditLimit);
        opportunityFieldsMap.put('Credit_check_date__c', Date.today());
        opportunityFieldsMap.put('bearbeitet_von__c', 'Autoprocessed by Sales');
        opportunityFieldsMap.put('Kredit_Entscheidung__c', 'Genehmigt');
        opportunityFieldsMap.put('CloseDate', Date.today());
        opportunityFieldsMap.put('Billing_Period_by_Sales__c', true);
        opportunityFieldsMap.put('Max_Credit_Limit__c', this.maxCreditLimit);
        opportunityFieldsMap.put('Last_CF_Errors__c', null);
        opportunityFieldsMap.put('Security_To_Pay__c', null);
        opportunityFieldsMap.put('Security_Amount_To_Pay__c', null);
        opportunityFieldsMap.put('Pending_Deposit_by_CF__c', false);
        opportunityFieldsMap.put('Security_level_H_he_der_Sicherheit__c', null);
        opportunityFieldsMap.put('ForecastCategoryName', 'Closed');
        opportunityFieldsMap.put('Probability', 100);
        opportunityFieldsMap.put('Closed_Won_by_CF__c', true);
        opportunityFieldsMap.put('CF_Stage__c', 'Auto CW');
        fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields for "Pending SEPA" decision
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnPendingSepaFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        opportunityFieldsMap.put('StageName', 'Pending Sales - SEPA Confirmation');
        opportunityFieldsMap.put('Zahlungsziel_Credit__c', this.paymentTerms);
        opportunityFieldsMap.put('Rechnungsperiode__c', this.billingPeriod);
        opportunityFieldsMap.put('CF_Credit_Limit__c', this.creditLimit);
        opportunityFieldsMap.put('Credit_check_date__c', Date.today());
        opportunityFieldsMap.put('bearbeitet_von__c', 'Autoprocessed by Sales');
        opportunityFieldsMap.put('Kredit_Entscheidung__c', 'Genehmigt');
        opportunityFieldsMap.put('CloseDate', Date.today());
        opportunityFieldsMap.put('Billing_Period_by_Sales__c', true);
        opportunityFieldsMap.put('Max_Credit_Limit__c', this.maxCreditLimit);
        opportunityFieldsMap.put('Last_CF_Errors__c', null);
        opportunityFieldsMap.put('Security_To_Pay__c', null);
        opportunityFieldsMap.put('Security_Amount_To_Pay__c', null);
        opportunityFieldsMap.put('Pending_Deposit_by_CF__c', false);
        opportunityFieldsMap.put('Security_level_H_he_der_Sicherheit__c', null);
        opportunityFieldsMap.put('CF_Stage__c', 'SEPA Confirmation');
        fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }
    
    /*******************************************************************************
    *  Summary         : Return fields for "Pending Deposit" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnPendingDepositFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        if (this.internalCFCompany.recordType == 'Lotos') {
            opportunityFieldsMap.put('Credit_Stage__c', 'Pending Sales – Deposit');
        }
        else {
            opportunityFieldsMap.put('StageName', 'Pending Sales – Deposit');
        }
        
        opportunityFieldsMap.put('Kredit_Entscheidung__c', 'Sicherheit verlangt');
        opportunityFieldsMap.put('Credit_check_date__c', Date.today());
        opportunityFieldsMap.put('bearbeitet_von__c', 'Autoprocessed by Sales');
        opportunityFieldsMap.put('Billing_Period_by_Sales__c', true);
        opportunityFieldsMap.put('Pending_Deposit_by_CF__c', true);
        opportunityFieldsMap.put('CF_Stage__c', 'Pending deposit');
        opportunityFieldsMap.put('Security_level_H_he_der_Sicherheit__c', this.securityLevel);
        opportunityFieldsMap.put('Zahlungsziel_Credit__c', this.paymentTerms);
        opportunityFieldsMap.put('Rechnungsperiode__c', this.billingPeriod);
        opportunityFieldsMap.put('CF_Credit_Limit__c', this.creditLimit);
        opportunityFieldsMap.put('Max_Credit_Limit__c', this.maxCreditLimit);
        opportunityFieldsMap.put('Security_To_Pay__c', 'Kaution');
        opportunityFieldsMap.put('Security_Amount_To_Pay__c', this.deposit);
        opportunityFieldsMap.put('Deposit_reason__c', this.depositReason);
		fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }


    /*******************************************************************************
    *  Summary         : Return fields for "Pending Advance Payment" decision
    *  CreatedDate     : 26/02/2021 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnPendingAdvancePaymentFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        if (this.billingPeriod != null) {
            opportunityFieldsMap.put('Billing_Period_by_Sales__c', true);
        }

        opportunityFieldsMap.put('StageName', 'Pending Sales - Advance payment');
        opportunityFieldsMap.put('CF_Stage__c', 'Pending Advance Payment');
        opportunityFieldsMap.put('bearbeitet_von__c', 'Autoprocessed by Sales');
        opportunityFieldsMap.put('Zahlungsziel_Credit__c', this.paymentTerms);
        opportunityFieldsMap.put('Rechnungsperiode__c', this.billingPeriod);
        opportunityFieldsMap.put('CF_Credit_Limit__c', this.creditLimit);
        opportunityFieldsMap.put('Max_Credit_Limit__c', this.maxCreditLimit);
        opportunityFieldsMap.put('Kredit_Entscheidung__c', 'Genehmigt');
        fieldsMap.put('Opportunity', opportunityFieldsMap);

        return fieldsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return fields is case of duplicates
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : map of fields
    ******************************************************************************/
    public Map<String, Object> returnDuplicateFieldsToUpdate() {
        Map<String, Object> fieldsMap = new Map<String, Object>();
        Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
        if (this.internalCFCompany.recordType == 'Lotos') {
            opportunityFieldsMap.put('Credit_Stage__c', 'CreditCheck');
        }
        else {
            opportunityFieldsMap.put('StageName', 'CreditCheck');
        }
        
        opportunityFieldsMap.put('CF_Stage__c', 'Manual Scoring');
		fieldsMap.put('Opportunity', opportunityFieldsMap);
        
        return fieldsMap;
    }


    public virtual List<Credit_Factory_Report_Employee__c> requestParentCompanyContacts(String companyId) {
        return new List<Credit_Factory_Report_Employee__c>();
    }
}