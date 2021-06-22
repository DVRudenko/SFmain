global class CreditFactoryReportBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String query;
    public List<Opportunity> opportunitiesToUpdateList;
    public List<Account> accountsToUpdateList;
    public transient List<Messaging.SingleEmailMessage> messages;
    public Map<Id, Credit_Factory_Report__c> creditReportsMap;
    public Map<Id, List<Credit_Factory_Report_Employee__c>> creditReportEmployeesMap;
    public List<Attachment> creditAttachmentsList;
    public transient HttpResponse responseBodyForAttachment;


    /*******************************************************************************
    *  Summary         : Constructor  
    *  CreatedDate     : 02/07/2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    global CreditFactoryReportBatch() {
        this.query = 'SELECT CF_Order_Reference_Number__c, CF_Stage__c, OwnerId, Name, Account.Gesellschaftsform__c, ' + 
                     'Account.BillingPostalCode, Account.BillingCity, Account.BillingStreet, Account.Steuernummer__c, ' +
                     'Account.Umsatzsteuer_ID__c, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Account.Gruendungsjahr__c, ' +
                     'Account.Branche_NACE__c, Account.Website, AccountId, Account.BillingCountryCode, Account.BillingCountry, ' +
                     'Account.Name, CF_Order_Party_Id__c, Owner.Email, Credit_Report_Id__c, Owner.Name, Credit_Report_Request_Date__c, ' +
                     'CF_Order_Date__c, E2E_Status__c, Credit_Factory_Errors__c, Last_CF_Errors__c, RecordType.Name, CF_Orders__c, ' +
                     'E2E_Finish_Details__c, ' +
                        '(SELECT Contact.FirstName, Contact.Lastname, Contact.Phone, Contact.Email, Contact.Birthdate, IsPrimary ' + 
                        'FROM OpportunityContactRoles), ' +
                        '(SELECT CreatedDate ' + 
                        'FROM Credit_Factory_Reports__r ' +
                        'WHERE CreatedDate > :threeMonthsAgoDate ' +
                        'ORDER BY CreatedDate DESC), ' +
                        '(SELECT CreatedDate, Field ' + 
                        'FROM Histories ' + 
                        'ORDER BY CreatedDate DESC) ' +
                     'FROM Opportunity ' +
                     'WHERE (StageName = \'Pending Credit Report\' AND CF_Stage__c != \'Manual Scoring\' AND CF_Stage__c != \'Pending Credit Report - Need information\' AND ' +
                     '(CF_Order_Reference_Number__c != null AND (Account.BillingCountry = \'Hungary\' OR Account.BillingCountry = \'Germany\'))) OR ' +
                     '(Credit_Report_Id__c != null AND Credit_Report_Request_Date__c = TODAY AND Account.BillingCountry = \'Poland\') OR ' +
                     'E2E_Status__c = \'Ordering Credit Report\' OR E2E_Finish_Details__c = \'Report Ordering\'';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date threeMonthsAgoDate = Date.today().addMonths(-3);
        return Database.getQueryLocator(query);
    }


    /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, List<Opportunity> opportunitiesList)
    *  Summary         : Call this method for each batch of records.
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job,
                         List<Opportunity> opportunitiesList - list of Opportunities to process
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunitiesList) {
        try {
            List<Opportunity> opportunitiesToCheckList = returnOpportunitiesToCheckList(opportunitiesList);
            if (! opportunitiesToCheckList.isEmpty()) {
                this.opportunitiesToUpdateList = new List<Opportunity>();
                this.accountsToUpdateList = new List<Account>();
                this.messages = new List<Messaging.SingleEmailMessage>();
                this.creditReportsMap = new Map<Id, Credit_Factory_Report__c>();
                this.creditReportEmployeesMap = new Map<Id, List<Credit_Factory_Report_Employee__c>>();
                this.creditAttachmentsList = new List<Attachment>();
                for (Opportunity opportunity : opportunitiesToCheckList) {
                    if (opportunity.Account.BillingCountry == 'Germany') {
                        processRecordDE(opportunity);
                    } else if (opportunity.Account.BillingCountry == 'Hungary') {
                        processRecordHU(opportunity);
                    } else if (opportunity.Account.BillingCountry == 'Poland') {
                        processRecordPL(opportunity);
                    }
                }

                doDMLOperations();
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Summary         : Send email to sales in 24 hours
    *  CreatedDate     : 16/03/2020
    *  Parameters      : opportunity - current Opportunity
    *  Returns         : void
    ******************************************************************************/
    public void processRecordDE(Opportunity opportunity) {
        if (! opportunity.Credit_Factory_Reports__r.isEmpty()) {
            if (returnElapsedHours(opportunity.Credit_Factory_Reports__r.get(0).CreatedDate) > 96) {
                if (opportunity.E2E_Finish_Details__c == 'Report Ordering') {
                    E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Germany');
                    if (settings != null && settings.Abandonment_User__c != null) {
                        opportunity.OwnerId = settings.Abandonment_User__c;
                        opportunity.E2E_Finish_Details__c = 'Order Submitted';
                        this.opportunitiesToUpdateList.add(opportunity);
                    }
                }
            }

            return;
        }
        
        if (opportunity.CF_Order_Date__c != null && returnElapsedHours(opportunity.CF_Order_Date__c) > 96) {
            processUnavailableReportDE(opportunity);
            return;
        }
        
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Schufa');
        SchufaEntity authEntity = getAuthEntityDE(creditSystem, opportunity.Id);
        Map<String, String> searchParametersMap = generateSearchParametersMapDE(opportunity);
        List<CreditFactoryCompany> companiesList = getCompaniesListDE(creditSystem, authEntity, searchParametersMap, opportunity.Id);
        String companyId;
        Boolean isReportAvailable = false;
        HttpResponse orderStatusResponse;
        for (CreditFactoryCompany company : companiesList) {
            if (company.identificationNumber == opportunity.CF_Order_Reference_Number__c) {
                companyId = company.identificationNumber;
                orderStatusResponse = getOrderStatusResponseDE(creditSystem, authEntity, companyId, opportunity.Id);
                break;
            }
        }
        
        if (orderStatusResponse != null) {
            if (orderStatusResponse.getStatusCode() == 404) {
                getOrderEconomyInfoResponseDE(creditSystem, authEntity, companyId, opportunity.Id);
                return;
            }
    
            SchufaEntity orderStatusEntity = SchufaEntity.parse(orderStatusResponse.getBody());
            for (SchufaEntity.Order order : orderStatusEntity.order) {
                if (order.name == 'FullEconomyInfo') {
                    if (! order.reason.contains('Es werden derzeit keine Auskünfte zu diesem Unternehmen erteilt.')) {
                        isReportAvailable = true;
                    }
            
                    break;
                }
            }
        }
        
        if (isReportAvailable) {
            processAvailableReportDE(creditSystem, authEntity, companyId, opportunity);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Send auth request
    *  CreatedDate     : 28/12/2020
    *  Parameters      : CreditSystem__c creditSystem, String opportunityId
    *  Returns         : SchufaEntity authEntity
    ******************************************************************************/
    private SchufaEntity getAuthEntityDE(CreditSystem__c creditSystem, String opportunityId) {
        String apiErrorMessage;
        try {
            Http http = new Http();
            HttpRequest authRequest = CreditFactoryWebSchufa2.generateAuthRequest(creditSystem.UserName__c, creditSystem.Password__c, creditSystem.Endpoint__c);
            HttpResponse authResponse = http.send(authRequest);
            apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(authResponse, 'auth');
			if (! String.isEmpty(apiErrorMessage)) {
				throw new CreditFactoryException(apiErrorMessage);
			}
            
            SchufaEntity authEntity = SchufaEntity.parse(authResponse.getBody());
            return authEntity;
        }
        catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
                throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Generate search parameters map
    *  CreatedDate     : 28/12/2020
    *  Parameters      : Opportunity opportunity
    *  Returns         : Map<String, String> searchParametersMap
    ******************************************************************************/
    private Map<String, String> generateSearchParametersMapDE(Opportunity opportunity) {
        Map<String, String> searchParametersMap = new Map<String, String>();
        searchParametersMap.put('companyId', opportunity.CF_Order_Reference_Number__c);
        return searchParametersMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get companies from search request
    *  CreatedDate     : 28/12/2020
    *  Parameters      : CreditSystem__c creditSystem, SchufaEntity authEntity,
                         Map<String, String> searchParametersMap, String opportunityId
    *  Returns         : List<CreditFactoryCompany> companiesList
    ******************************************************************************/
    private List<CreditFactoryCompany> getCompaniesListDE(CreditSystem__c creditSystem, SchufaEntity authEntity, Map<String, String> searchParametersMap, String opportunityId) {
        String apiErrorMessage;
        try {
            Http http = new Http();
            HttpRequest searchRequest = CreditFactoryWebSchufa2.generateSearchRequest(authEntity.accessToken, creditSystem.Endpoint__c, searchParametersMap);
            HttpResponse searchResponse = http.send(searchRequest);
            apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(searchResponse, 'search');
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            SchufaEntity searchEntity = SchufaEntity.parse(searchResponse.getBody());
            List<CreditFactoryCompany> companiesList = CreditFactoryWebSchufa2.returnSearchCompany(searchEntity);
            return companiesList;
        }
        catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
                throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Get order status response
    *  CreatedDate     : 28/12/2020
    *  Parameters      : CreditSystem__c creditSystem, SchufaEntity authEntity,
                         String companyId, String opportunityId
    *  Returns         : HttpResponse orderStatusResponse
    ******************************************************************************/
    private HttpResponse getOrderStatusResponseDE(CreditSystem__c creditSystem, SchufaEntity authEntity, String companyId, String opportunityId) {
        String apiErrorMessage;
        try {
            Http http = new Http();
            HttpRequest orderStatusRequest = CreditFactoryWebSchufa2.generateOrderStatusRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
            HttpResponse orderStatusResponse = http.send(orderStatusRequest);
            apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(orderStatusResponse, 'orderStatus');
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            return orderStatusResponse;
        }
        catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
                throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Get order status response
    *  CreatedDate     : 28/12/2020
    *  Parameters      : CreditSystem__c creditSystem, SchufaEntity authEntity,
                         String companyId, String opportunityId
    *  Returns         : HttpResponse orderStatusResponse
    ******************************************************************************/
    private void getOrderEconomyInfoResponseDE(CreditSystem__c creditSystem, SchufaEntity authEntity, String companyId, String opportunityId) {
        String apiErrorMessage;
        try {
            Http http = new Http();
            HttpRequest orderEconomyInfoRequest = CreditFactoryWebSchufa2.generateOrderEconomyInfoRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
			HttpResponse orderEconomyInfoResponse = http.send(orderEconomyInfoRequest);
            apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(orderEconomyInfoResponse, 'orderEconomyInfo');
            if (! String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }
        }
        catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
                throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Process logic if report is avalable
    *  CreatedDate     : 29/12/2020
    *  Parameters      : CreditSystem__c creditSystem, SchufaEntity authEntity,
                         String companyId, Opportunity opportunity
    *  Returns         : void
    ******************************************************************************/
    private void processAvailableReportDE(CreditSystem__c creditSystem, SchufaEntity authEntity, String companyId, Opportunity opportunity) {
        HttpResponse reportResponse = getReportReponseDE(creditSystem, authEntity, companyId, opportunity.Id);
        CreditFactoryCompany company = CreditFactoryWebSchufa2.returnReportCompany(reportResponse.getBody());
        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        if (lexisNexisSettings.Active__c == true) {
            Dom.XmlNode lexisNexisBody = sendLexisNexisRequest(opportunity, lexisNexisSettings);
            if (lexisNexisBody != null) {
                company = CreditFactoryWebLexisNexis.returnReportCompany(lexisNexisBody, company);
            }
        }
        
        this.creditReportsMap.put(opportunity.Id, prepareCreditReportDE(company, opportunity.Id));
        this.creditReportEmployeesMap.put(opportunity.Id, prepareCreditReportEmployeesDE(company.creditFactoryContacts));
        Blob blobBody = getPdfReportDE(creditSystem, authEntity, companyId, opportunity.Id);
        this.creditAttachmentsList.add(prepareCreditReportAttachmentDE(opportunity.Id, blobBody));
        opportunity.Credit_Factory_PDF_Report_Created__c = true;
        opportunity.StageName = 'Credit Report Generated';
        opportunity.CF_Stage__c = 'Credit Report Generated';
        if (opportunity.E2E_Finish_Details__c != 'Report Ordering') {
            messages.add(prepareAvailableReportEmail(opportunity));
        }
        
        this.opportunitiesToUpdateList.add(opportunity);
    }
    
    
    /*******************************************************************************
    *  Summary         : get report response
    *  CreatedDate     : 29/12/2020
    *  Parameters      : CreditSystem__c creditSystem, SchufaEntity authEntity,
                         String companyId, String opportunityId
    *  Returns         : HttpResponse reportResponse
    ******************************************************************************/
    private HttpResponse getReportReponseDE(CreditSystem__c creditSystem, SchufaEntity authEntity, String companyId, String opportunityId) {
        String apiErrorMessage;
        try {
            Http http = new Http();
            HttpRequest reportRequest = CreditFactoryWebSchufa2.generateReportRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
            HttpResponse reportResponse = http.send(reportRequest);
            apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(reportResponse, 'report');
            if (!String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            return reportResponse;
        }
        catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
                throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : prepare credit report to insert
    *  CreatedDate     : 29/12/2020
    *  Parameters      : CreditFactoryCompany company, String opportunityId
    *  Returns         : Credit_Factory_Report__c creditReport
    ******************************************************************************/
    private Credit_Factory_Report__c prepareCreditReportDE(CreditFactoryCompany company, String opportunityId) {
        String reportName = company.name;
        if (reportName.length() > 80) {
            reportName = reportName.substring(0,80);
        }
        
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
            Credit_System_Number__c = company.creditSystemCompanyNumber,
            Age_of_Company__c = company.ageOfCompany,
            City__c = company.city,
            Company_Status__c = company.status,
            Country__c = company.country,
            County_Court__c = company.countyCourt,
            Credit_Limit__c = company.creditLimit,
            Date_of_Foundation__c = company.dateOfFoundation,
            Principal_Activity_Code__c = company.principalActivityCode,
            Principal_Activity_Description__c = company.principalActivityDescription,
            Email__c = company.email,
            Fax__c = company.fax,
            Housenumber__c = company.houseNumber,
            Legal_Form__c = company.legalForm,
            Mobile__c = company.mobile,
            Opportunity__c = opportunityId,
            Phone__c = company.phone,
            Postcode__c = company.postCode,
            Register_Number__c = company.registerNumber,
            Staff_Range__c = company.staffCompanyRange,
            Street__c = company.street,
            Turn_Over__c = company.turnOver,
            VAT_Number__c = company.vatId,
            Website__c = company.website,
            Name = reportName,
            Company_Id__c = company.identificationNumber,
            Class_Rating__c = company.classRating,
            Reference_Number__c = company.referenceNumber,
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
            Name__c = company.name,
            Trade_Register_Number__c = company.tradeRegisterNumber,
            Tax_Id__c = company.taxId,
            CurrencyIsoCode = 'EUR');
        
        return creditReport;
    }
    
    
    /*******************************************************************************
    *  Summary         : prepare credit report employees to insert
    *  CreatedDate     : 29/12/2020
    *  Parameters      : List<CreditFactoryCompany.CreditFactoryContact> contactsList
    *  Returns         : List<Credit_Factory_Report_Employee__c> creditReportEmployeesList
    ******************************************************************************/
    private List<Credit_Factory_Report_Employee__c> prepareCreditReportEmployeesDE(List<CreditFactoryCompany.CreditFactoryContact> contactsList) {
        List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditFactoryCompany.CreditFactoryContact employee : contactsList) {
            String employeeName = employee.name;
            if (employee.name.length() > 80) {
                employeeName = employeeName.substring(0,80);
            }

            creditReportEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Address__c = employee.address,
                Date_of_Birth__c = employee.dateOfBirth,
                Id__c = employee.id,
                Name = employeeName,
                Participation_Date__c = employee.participationDate,
                Type__c = employee.type));
        }

        return creditReportEmployeesList;
    }
    
    
    /*******************************************************************************
    *  Summary         : get pdf report
    *  CreatedDate     : 29/12/2020
    *  Parameters      : CreditSystem__c creditSystem, SchufaEntity authEntity,
                         String companyId, String opportunityId
    *  Returns         : Blob pdfResponseBody
    ******************************************************************************/
    private Blob getPdfReportDE(CreditSystem__c creditSystem, SchufaEntity authEntity, String companyId, String opportunityId) {
        String apiErrorMessage;
        try {
            Http http = new Http();
            HttpRequest pdfReportRequest = CreditFactoryWebSchufa2.generatePdfReportRequest(authEntity.accessToken, creditSystem.Endpoint__c, companyId);
            HttpResponse pdfReportResponse = http.send(pdfReportRequest);
            apiErrorMessage = CreditFactoryGlobalUtils.checkSchufaAPIErrors(pdfReportResponse, 'attachment');
            if (!String.isEmpty(apiErrorMessage)) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            SchufaEntity pdfReportEntity = SchufaEntity.parse(pdfReportResponse.getBody());
            Blob pdfResponseBody = EncodingUtil.base64Decode(pdfReportEntity.documentBytes);
            return pdfResponseBody;
        }
        catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
                throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : prepare pdf report to insert
    *  CreatedDate     : 29/12/2020
    *  Parameters      : String opportunityId, Blob blobBody
    *  Returns         : Blob pdfResponseBody
    ******************************************************************************/
    private Attachment prepareCreditReportAttachmentDE(String opportunityId, Blob blobBody) {
        if (blobBody != null) {
            Attachment pdfReport = new Attachment();
            pdfReport.ParentId = opportunityId;
            pdfReport.Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap('Germany').get('Report');
            pdfReport.Body = blobBody;
            return pdfReport;
        }
        
        return null;
    }
    
    
    /*******************************************************************************
    *  Summary         : Process logic if report is avalable
    *  CreatedDate     : 29/12/2020
    *  Parameters      : Opportunity opportunity
    *  Returns         : void
    ******************************************************************************/
    private void processUnavailableReportDE(Opportunity opportunity) {
        String reportUnavailable = 'Credit Report not available';
        opportunity.StageName = reportUnavailable;
        opportunity.CF_Stage__c = reportUnavailable;
        if (opportunity.E2E_Finish_Details__c == 'Report Ordering') {
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Germany');
            if (settings != null && settings.Abandonment_User__c != null) {
                opportunity.OwnerId = settings.Abandonment_User__c;
                opportunity.E2E_Finish_Details__c = 'Order Submitted';
            }
        }
        
        if (opportunity.Credit_Factory_Errors__c == null) {
            opportunity.Credit_Factory_Errors__c = reportUnavailable;
        } else {
            opportunity.Credit_Factory_Errors__c += '\n' + reportUnavailable;
        }
        opportunity.Last_CF_Errors__c = reportUnavailable;
        this.opportunitiesToUpdateList.add(opportunity);
    }


    /*******************************************************************************
    *  Summary         : Process record to receive report from Coface (Hungary)
    *  CreatedDate     : 02/07/2019 by Anton Buzak
    *  Parameters      : opportunity - current Opportunity
    *  Returns         : -
    ******************************************************************************/
    public void processRecordHU(Opportunity opportunity) {
        if (! opportunity.Credit_Factory_Reports__r.isEmpty()) {
            if (returnElapsedHours(opportunity.Credit_Factory_Reports__r.get(0).CreatedDate) > 24) {
                if (opportunity.E2E_Status__c == 'Ordering Credit Report') { // 1.0
                    opportunity.E2E_Status__c = ''; // delete value to reassign on sales team
                    this.opportunitiesToUpdateList.add(opportunity);
                }
                else if (opportunity.E2E_Finish_Details__c == 'Report Ordering') { // 2.0
                    E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Hungary');
                    if (settings != null && settings.Abandonment_User__c != null) {
                        opportunity.OwnerId = settings.Abandonment_User__c;
                        opportunity.E2E_Finish_Details__c = 'Order Submitted';
                        this.opportunitiesToUpdateList.add(opportunity);
                    }
                }
            }

            return;
        }
        
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Coface');
        List<CreditFactoryCompany> companiesList = searchCompany(creditSystem, opportunity.CF_Order_Reference_Number__c, opportunity.Id);
        Boolean isReportAvailable;
        String id;
        for (CreditFactoryCompany company : companiesList) {
            if (company.nationalId == opportunity.CF_Order_Reference_Number__c) {
                id = company.identificationNumber;
                isReportAvailable = isCreditReportAvailable(creditSystem, id, opportunity.Id);
            }
        }
        
        if (isReportAvailable == true) {
            processAvailableReportHU(creditSystem, opportunity, id);
        }
        else if (opportunity.CF_Order_Date__c != null && returnElapsedHours(opportunity.CF_Order_Date__c) > 24) {
            processUnavailableReportHU(opportunity);
        } // else research is not finished
    }
    
    
    /*******************************************************************************
    *  Summary         : Search company
    *  Created         : 25/03/2020 by Anton Buzak
    *  Parameters      : creditSystem - credit system settings,
                         orderReferenceNumber - order reference number
                         opportunityId - opportunityId
    *  Returns         : companies list
    ******************************************************************************/
    private List<CreditFactoryCompany> searchCompany(CreditSystem__c creditSystem, String orderReferenceNumber, String opportunityId) {
        String apiErrorMessage;
        try {
            Map<String, String> searchParametersMap = new Map<String, String>();
            searchParametersMap.put('taxId', orderReferenceNumber);
            HttpRequest request = CreditFactoryWebCoface.generateSearchRequest(creditSystem.Endpoint__c, creditSystem.UserName__c,
                                                                               creditSystem.Password__c, searchParametersMap);
            Http h = new Http();
            HttpResponse response = h.send(request);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(response);
            if (apiErrorMessage != null) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            String xml = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xml);
            Dom.XmlNode xmldom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CreditFactoryWebCoface.returnGlobalBody(xmldom);
            return CreditFactoryWebCoface.returnSearchedCompanies(globalBody);
        } catch (Exception e) {
	    	if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
				 throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
	    }
    }
    
    
    /*******************************************************************************
    *  Summary         : API Call: Check availability of Automatic Credit report (Code: 761)
    *  CreatedDate     : 25/03/2020 by Anton Buzak
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page,
                         opportunityId - opportunityId
    *  Returns         : check result
    ******************************************************************************/
    public Boolean isCreditReportAvailable(CreditSystem__c creditSystem, String companyId, String opportunityId) {
        String apiErrorMessage;
        try {
            HttpRequest request = CreditFactoryWebCoface.generateRequestForCheckAvailability(creditSystem.Endpoint__c, creditSystem.UserName__c,
                                                                                             creditSystem.Password__c, companyId);
            Http h = new Http();
            HttpResponse response = h.send(request);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(response);
            if (apiErrorMessage != null) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(response.getBody());
            Dom.XmlNode xmldom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CreditFactoryWebCoface.returnGlobalBody(xmldom);
            Boolean isReportExists = CreditFactoryWebCoface.isCreditReportAvailable(globalBody);
            return isReportExists;
        } catch (Exception e) {
	    	if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
				 throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
	    }
    }


    /*******************************************************************************
    *  Summary         : Return hours between current date and report created date
    *  CreatedDate     : 24/07/2019
    *  Parameters      : startDate - start date
    *  Returns         : number of hours
    ******************************************************************************/
    public Integer returnElapsedHours(Datetime startDate) {
        Integer differenceHours;
        if (startDate != null) {
            Long nilHours = Datetime.newInstance(1900, 1, 1, 0, 0, 0).getTime() / 1000 / 60 / 60;
            Long startDateHours = startDate.getTime() / 1000 / 60 / 60;
            Long currentHours = Datetime.now().getTime() / 1000 / 60 / 60;
            differenceHours = (Integer) (currentHours - startDateHours);

            Integer hourOfWeek = (Integer) Math.mod(currentHours - nilHours, 168);
            for (Integer remainder = Math.mod(differenceHours, 168); remainder >= 0; remainder--) {
                if (hourOfWeek <= 167 && hourOfWeek >= 120) { // Saturday and Sunday hours
                    differenceHours --;
                }
                hourOfWeek--;
                if (hourOfWeek < 0) {
                    hourOfWeek = 167;
                }
            }
        }
        
        return differenceHours;
    }


    /*******************************************************************************
    *  Summary         : Process logic if report is available.    
    *  CreatedDate     : 02/07/2019 by Anton Buzak
    *  Parameters      : creditSystem - credit system object with Coface credentials,
                         opportunity - opportunity to check,
                         internalId - company id
    *  Returns         : -
    ******************************************************************************/
    public void processAvailableReportHU(CreditSystem__c creditSystem, Opportunity opportunity, String internalId) {
        Dom.XmlNode xmlReportResponse = getXMLReportResponseHU(creditSystem, opportunity.Id, internalId);
        CreditFactoryCompany company = CreditFactoryWebCoface.returnReportCompany(xmlReportResponse, internalId);
        LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
        if (lexisNexisSettings.Active__c == true) {
            Dom.XmlNode lexisNexisBody = sendLexisNexisRequest(opportunity, lexisNexisSettings);
            if (lexisNexisBody != null) {
                company = CreditFactoryWebLexisNexis.returnReportCompany(lexisNexisBody, company);
            }
        }

        creditReportsMap.put(opportunity.Id, prepareCreditReportHU(company, opportunity.Id));
        creditReportEmployeesMap.put(opportunity.Id, prepareCreditReportEmployeesHU(company.creditFactoryContacts));

        Dom.XmlNode binaryReportResponse = getReportBinaryResponseHU(creditSystem, opportunity, internalId);
        Blob blobBody = CreditFactoryWebCoface.getOrderedBinaryAttachment(binaryReportResponse);
        creditAttachmentsList.add(prepareCreditReportAttachmentHU(opportunity.Id, blobBody));
        opportunity.Credit_Factory_PDF_Report_Created__c = true;
        opportunity.StageName = 'Credit Report Generated';
        opportunity.CF_Stage__c = 'Credit Report Generated';
        opportunity.CF_Order_Received_Date__c = Datetime.now();
        if (opportunity.E2E_Status__c == 'Ordering Credit Report') {
            opportunity.E2E_Active_Substep__c = 'Set total consumption';
        } else if (opportunity.E2E_Finish_Details__c != 'Report Ordering') {
            messages.add(prepareAvailableReportEmail(opportunity));
        }
        this.opportunitiesToUpdateList.add(opportunity);
    }


    /*******************************************************************************
    *  Summary         : Send request to get ordered report.
    *  CreatedDate     : 02/07/2019 by Anton Buzak
    *  Parameters      : creditSystem - credit system object with Coface credentials,
                         opportunityId - opportunity Id,
                         internalId - company id
    *  Returns         : report node
    ******************************************************************************/
    public Dom.XmlNode getXMLReportResponseHU(CreditSystem__c creditSystem, String opportunityId, String internalId) {
        String apiErrorMessage;
        try {
            HttpRequest request = CreditFactoryWebCoface.generateReportRequest(creditSystem.Endpoint__c, creditSystem.UserName__c,
                                                                               creditSystem.Password__c, internalId);
            Http http = new Http();
            HttpResponse response = http.send(request);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(response);
            if (apiErrorMessage != null) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            String xmlResponse = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xmlResponse);
            Dom.XmlNode xmldom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CreditFactoryWebCoface.returnGlobalBody(xmldom);
            Boolean isValidReport = CreditFactoryWebCoface.checkResponseForFault(globalBody);
            if (!isValidReport) {
                String errorMessageResponse = CreditFactoryWebCoface.returnErrorMessage(globalBody);
                throw new CreditFactoryException('Ordered Report request failed. ' + errorMessageResponse);
            }

            return globalBody;
        } catch (Exception e) {
	    	if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
			else {
				 throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
			}
	    }
    }


    /*******************************************************************************
    *  Summary         : prepare credit report to insert     
    *  CreatedDate     : 02/07/2019 by Anton Buzak
    *  Parameters      : company - company from response,
                         opportunityId - Id of processed opportunity
    *  Returns         : report
    ******************************************************************************/
    public Credit_Factory_Report__c prepareCreditReportHU(CreditFactoryCompany company, String opportunityId) {
        String reportName = company.name;
        if (reportName.length() > 80) {
            reportName = reportName.substring(0,80);
        }

        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
            Credit_System_Number__c = company.creditSystemCompanyNumber,
            Age_of_Company__c = company.ageOfCompany,
            City__c = company.city,
            Company_Status__c = company.status,
            Country__c = company.country,
            County_Court__c = company.countyCourt,
            Credit_Decision__c = company.creditDecision,
            Credit_Limit__c = company.creditLimit,
            Date_Last_Register_Entry__c = company.dateLastRegisterEntry,
            Date_Legal_Form__c = company.dateLegalForm,
            Date_of_Foundation__c = company.dateOfFoundation,
            Email__c = company.email,
            Fax__c = company.fax,
            First_Legal_Form__c = company.firstLegalForm,
            Fiscal_Number__c = company.taxId,
            Housenumber__c = company.houseNumber,
            Legal_Form__c = company.legalForm,
            Mobile__c = company.mobile,
            Opportunity__c = opportunityId,
            Payment_Behaviour__c = company.paymentBehaviour,
            Phone__c = company.phone,
            Postcode__c = company.postCode,
            Register_Number__c = company.registerNumber,
            Staff_Range__c = company.staffCompanyRange,
            Street__c = company.street,
            Trade_Name__c = company.tradeName,
            Turn_Over__c = company.turnOver,
            VAT_Number__c = company.vatId,
            Website__c = company.website,
            Name = reportName,
            Company_Id__c = company.identificationNumber,
            Date_Of_Last_Major_Update__c = company.dateOfLastMajorUpdate,
            Class_Rating__c = company.classRating,
            Reference_Number__c = company.referenceNumber,
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
            Name__c = company.name,
            Trade_Register_Number__c = company.tradeRegisterNumber,
            Tax_Id__c = company.taxId,
            CurrencyIsoCode = 'HUF',
            Profit_Loss_Last_Year__c = company.profitLossLastYear,
            Profit_Loss_Year_Before_Last__c = company.profitLossYearBeforeLast,
            Turn_Over_Last_Year__c = company.turnOverLastYear);
        return creditReport;
    }


    /*******************************************************************************
    *  Summary         : prepare list of credit report employees to insert    
    *  CreatedDate     : 02/07/2019 by Anton Buzak
    *  Parameters      : contactsList - company employees from response
    *  Returns         : employees list
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> prepareCreditReportEmployeesHU(List<CreditFactoryCompany.CreditFactoryContact> contactsList) {
        List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditFactoryCompany.CreditFactoryContact employee : contactsList) {
            String employeeName = employee.name;
            if (employee.name.length() > 80) {
                employeeName = employeeName.substring(0,80);
            }

            creditReportEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Address__c = employee.address,
                Date_of_Birth__c = employee.dateOfBirth,
                Id__c = employee.id,
                Name = employeeName,
                Participation_Date__c = employee.participationDate,
                Type__c = employee.type,
                Company_Id__c = employee.companyId,
                Company_Type__c = employee.companyType,
                Company_Role__c = employee.companyRole));
        }

        return creditReportEmployeesList;
    }


    /*******************************************************************************
    *  Summary         : Send request to get ordered pdf report.
    *  CreatedDate     : 02/07/2019 by Anton Buzak
    *  Parameters      : CreditSystem - credit system object with Coface credentials,
                         Opportunity opportunity - ordered opportunity, String internalId - Coface company internal Id
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public Dom.XmlNode getReportBinaryResponseHU(CreditSystem__c creditSystem, Opportunity opportunity, String internalId) {
        String apiErrorMessage;
        try {
            HttpRequest request = CreditFactoryWebCoface.generatePdfReportRequest(creditSystem.Endpoint__c, creditSystem.UserName__c,
                                                                                  creditSystem.Password__c, internalId);
            Http http = new Http();
            HttpResponse response = http.send(request);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCofaceAPIErrors(response);
            if (apiErrorMessage != null) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            String xmlResponse = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xmlResponse);
            Dom.XmlNode xmldom = domDoc.getRootElement();
            Dom.XmlNode globalBody = CreditFactoryWebCoface.returnGlobalBody(xmldom);
            Boolean isValidReport = CreditFactoryWebCoface.checkResponseForFault(globalBody);
            if ( ! isValidReport ) {
                String errorMessageResponse = CreditFactoryWebCoface.returnErrorMessage(globalBody);
                throw new CreditFactoryException('Ordered Binary Report request failed. ' + errorMessageResponse);
            }
    
            return globalBody;
        } catch (Exception e) {
	    	if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunity.Id);
			}
			else {
				 throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunity.Id);
			}
	    }
    }


    /*******************************************************************************
    *  Name            : prepareCreditReportAttachmentHU(Opportunity opportunity)
    *  Summary         : Prepare Credit Company Report PDF Attachment to insert
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId - processed Opportunity, Blob blobBody - blob body for attachment
    *  Returns         : Attachment
    ******************************************************************************/
    public Attachment prepareCreditReportAttachmentHU(String opportunityId, Blob blobBody) {
        if (blobBody != null) {
            Attachment creforeport = new Attachment(
                ParentId = opportunityId,
                Name = CreditFactoryGlobalUtils.returnAttachmentNamesMap('Hungary').get('Report'),
                Body = blobBody);
            return creforeport; 
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : processUnavailableReportHU(Opportunity opportunity)
    *  Summary         : Process old opportunity.    
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : 27/11/2019
    *  Parameters      : Opportunity opportunity
    *  Returns         : void
    ******************************************************************************/
    public void processUnavailableReportHU(Opportunity opportunity) {
        String reportUnavailable = 'Credit Report not available';
        opportunity.StageName = reportUnavailable;
        opportunity.CF_Stage__c = reportUnavailable;
        if (opportunity.E2E_Status__c == 'Ordering Credit Report') { // 1.0
            opportunity.E2E_Status__c = '';
        }
        else if (opportunity.E2E_Finish_Details__c == 'Report Ordering') { // 2.0
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Hungary');
            if (settings != null && settings.Abandonment_User__c != null) {
                opportunity.OwnerId = settings.Abandonment_User__c;
                opportunity.E2E_Finish_Details__c = 'Order Submitted';
            }
        }
        else {
            this.messages.add(prepareUnavailableReportEmail(opportunity)); // CF
        }
        if (opportunity.Credit_Factory_Errors__c == null) {
            opportunity.Credit_Factory_Errors__c = reportUnavailable;
        } else {
            opportunity.Credit_Factory_Errors__c += '\n' + reportUnavailable;
        }
        opportunity.Last_CF_Errors__c = reportUnavailable;
        this.opportunitiesToUpdateList.add(opportunity);
    }


    /*******************************************************************************
    *  Summary         : Process record to receive report from Crif (PL)
    *  CreatedDate     : 04/07/2019
    *  Parameters      : opportunity - current Opportunity
    *  Returns         : -
    ******************************************************************************/
    public void processRecordPL(Opportunity opportunity) {
        CreditSystem__c creditSystem = CreditSystem__c.getInstance('Crif');
        Dom.XmlNode reportBody = getReportBodyPL(creditSystem, opportunity.Credit_Report_Id__c);
        CreditFactoryCompany company = CreditFactoryWebCrif.returnReportCompany(reportBody, opportunity.Credit_Report_Id__c);
        Date dateOfNextRun = Datetime.now().addHours(1).date();
        if (Test.isRunningTest()) {
            dateOfNextRun = Date.today().addDays(1);
        }

        if (company.requestStatus == 'OK' && company.identificationType != 'NOT_IDENTIFIED' && company.name != null || dateOfNextRun > opportunity.Credit_Report_Request_Date__c) {
            LexisNexis_Settings__c lexisNexisSettings = LexisNexis_Settings__c.getInstance('Production');
            if (lexisNexisSettings.Active__c == true) {
                Dom.XmlNode lexisNexisBody = sendLexisNexisRequest(opportunity, lexisNexisSettings);
                if (lexisNexisBody != null) {
                    company = CreditFactoryWebLexisNexis.returnReportCompany(lexisNexisBody, company);
                }
            }
            creditReportsMap.put(opportunity.Id, prepareCreditReportPL(company, opportunity.Id));
            creditReportEmployeesMap.put(opportunity.Id, prepareCreditReportEmployeesPL(company.creditFactoryContacts));
            scheduleJobForPDFReportPL(company.creditSystemCompanyNumber, opportunity.Id);
            
            if (opportunity.RecordType.Name == 'Lotos') {
                opportunity.Credit_Stage__c = 'Credit Report Generated';
            } else {
                opportunity.StageName = 'Credit Report Generated';
            }

            opportunity.CF_Order_Received_Date__c = Datetime.now();
            opportunity.CF_Stage__c = 'Credit Report Generated';
            if (opportunity.E2E_Finish_Details__c == 'Report Ordering') {
                opportunity.E2E_Finish_Details__c = 'Order Submitted';
            }
            
            opportunitiesToUpdateList.add(opportunity);

            if (company.requestStatus == 'OK' && company.identificationType != 'NOT_IDENTIFIED' && company.name != null) {
                messages.add(prepareCorrectReportEmailPL(opportunity));
            } else {
                messages.add(prepareWrongReportEmailPL(opportunity));
            }
        }
    }


    /*******************************************************************************
    *  Summary         : Send report request and get its body.
    *  CreatedDate     : 04/07/2019
    *  Parameters      : creditSystem - credit system object with Crif credentials,
                         reportId - internal Crif Id
    *  Returns         : report body node
    ******************************************************************************/
    public Dom.XmlNode getReportBodyPL(CreditSystem__c creditSystem, String reportId) {
        String apiErrorMessage;
        try {
            HttpRequest request = CreditFactoryWebCrif.generateReportRequest(
                creditSystem.Endpoint__c, creditSystem.UserName__c,
                creditSystem.Password__c, reportId);
            Http h = new Http();
            HttpResponse response = h.send(request);
            apiErrorMessage = CreditFactoryGlobalUtils.checkCrifAPIErrors(response);
            if (apiErrorMessage != null) {
                throw new CreditFactoryException(apiErrorMessage);
            }
            
            String xml = response.getBody();
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xml);
            Dom.XmlNode xmldom = domDoc.getRootElement();
            Dom.XmlNode reportDom = CreditFactoryWebCrif.returnReportBody(xmldom);
            return reportDom;
        } catch (Exception e) {
            if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunity.Id);
			}
			else {
				 throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunity.Id);
			}
        }
    }


    /*******************************************************************************
    *  Summary         : Prepare credit report to insert     
    *  CreatedDate     : 04/07/2019
    *  Parameters      : company - company from response,
                         opportunityId - Id of processed opportunity
    *  Returns         : company report
    ******************************************************************************/
    public Credit_Factory_Report__c prepareCreditReportPL(CreditFactoryCompany company, String opportunityId) {
        String reportName = company.name;
        if (reportName.length() > 80) {
            reportName = reportName.substring(0,80);
        }
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
            Credit_System_Number__c = company.creditSystemCompanyNumber,
            Age_of_Company__c = company.ageOfCompany,
            City__c = company.city,
            Company_Status__c = company.status,
            Country__c = company.country,
            Credit_Limit__c = company.creditLimit,
            Date_of_Foundation__c = company.dateOfFoundation,
            Email__c = company.email,
            Fax__c = company.fax,
            First_Legal_Form__c = company.firstLegalForm,
            Fiscal_Number__c = company.taxId,
            Housenumber__c = company.houseNumber,
            Legal_Form__c = company.legalForm,
            Mobile__c = company.mobile,
            Opportunity__c = opportunityId,
            Phone__c = company.phone,
            Postcode__c = company.postCode,
            Register_Number__c = company.registerNumber,
            Staff_Range__c = company.staffCompanyRange,
            Street__c = company.street,
            Trade_Name__c = company.tradeName,
            Turn_Over__c = company.turnOver,
            Trade_Register_Number__c = company.tradeRegisterNumber,
            Tax_Id__c = company.taxId,
            Website__c = company.website,
            Name = reportName,
            Company_Id__c = company.identificationNumber,
            Solvency_Index__c = company.solvencyIndex,
            Request_Status__c = company.requestStatus,
            Obligation_Overdue__c = company.obligationOverdue,
            Class_Rating__c = company.classRating,
            Number_Of_Hits__c = company.numberOfHits,
            Policy_Rules_Hits__c = String.join(company.policyRuleHitsList, '\r\n'),
            Name_Change_Decision__c = company.nameChangeDecision,
            Address_Change_Decision__c = company.addressChangeDecision,
            Postal_Street__c = company.postalStreet,
            Postal_Housenumber__c = company.postalHouseNumber,
            Postal_City__c = company.postalCity,
            Postal_Postcode__c = company.postalPostCode,
            Registered_Street__c = company.registeredStreet,
            Registered_Housenumber__c = company.registeredHouseNumber,
            Registered_City__c = company.registeredCity,
            Registered_Postcode__c = company.registeredPostCode,
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
            Checked_Email__c = company.checkedEmail);
        return creditReport;
    }


    /*******************************************************************************
    *  Summary         : Prepare list of credit report employees to insert    
    *  CreatedDate     : 04/07/2019
    *  Parameters      : contactsList - company employess from response
    *  Returns         : employees list
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> prepareCreditReportEmployeesPL(List<CreditFactoryCompany.CreditFactoryContact> contactsList) {
        List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditFactoryCompany.CreditFactoryContact employee : contactsList) {
            String employeeName = employee.name;
            if (employeeName != null && employeeName.length() > 80) {
                employeeName = employeeName.substring(0, 80);
            }
            creditReportEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Address__c = employee.address,
                Name = employeeName,
                Type__c = employee.type));
        }

        return creditReportEmployeesList;
    }


    /*******************************************************************************
    *  Summary         : schedule job for creating pdf attachment    
    *  CreatedDate     : 04/07/2019
    *  Parameters      : creditSystem - credit system object with Crif credentials,
                         creditReportId - internal Crif report Id,
                         opportunityId - Id of related Opportunity
    *  Returns         : -
    ******************************************************************************/
    public void scheduleJobForPDFReportPL(String creditReportId, String opportunityId) {
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' 
            + Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Crif Pdf attachment ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() + 
            Datetime.now().addSeconds(5).millisecond();
        CreditFactoryPdfSchedule pdfSchedule = new CreditFactoryPdfSchedule(creditReportId, null, opportunityId, null, 'Poland');
        System.schedule(scheduleName, schedule, pdfSchedule);
    }


    /*******************************************************************************
    *  Name            : prepareCorrectReportEmailPL(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is created without request status error
    *  CreatedDate     : 04/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareCorrectReportEmailPL(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Crif report is available for your Customer ' + opportunity.Name;
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Dear ' + opportunity.Owner.Name + ',<br/><br/>Crif report is available for your Customer ' + opportunity.Name + '.<br/>' + 
            'Please launch the Credit Factory once again.<br/><br/>Link to the Opportunity: <a href="' + 
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' +
            'This is an automatically generated email, please do not respond.';    
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : prepareWrongReportEmailPL(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is created with request status error
    *  CreatedDate     : 04/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareWrongReportEmailPL(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Crif report came with error for your Customer ' + opportunity.Name;
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Dear ' + opportunity.Owner.Name + ',<br/><br/>Crif report for your Customer ' + opportunity.Name + ' was received with an error.<br/>' + 
            'Please launch the Credit Factory once again to update the fields and submit your Opportunity for manual approval. ' + 
            'Link to the Opportunity: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' +
            'This is an automatically generated email, please do not respond.';    
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : returnOpportunitiesToCheckList(List<Opportunity> opportunitiesList)
    *  Summary         : Return list Opportunities without Credit Report
    *  CreatedDate     : 02/07/2019
    *  Parameters      : List<Opportunity> opportunitiesList
    *  Returns         : List<Opportunity>
    ******************************************************************************/
    public List<Opportunity> returnOpportunitiesToCheckList(List<Opportunity> opportunitiesList) {
        String opportunityId;
        try {
            List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
            for (Opportunity opportunity : opportunitiesList) {
                opportunityId = opportunity.Id;
                if (opportunity.Credit_Factory_Reports__r.size() == 0 || opportunity.E2E_Status__c == 'Ordering Credit Report' || opportunity.E2E_Finish_Details__c == 'Report Ordering') {
                    opportunitiesToCheckList.add(opportunity);
                }
            }
            
            return opportunitiesToCheckList;
        } catch (Exception e) {
            throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunityId);
        }
    }


    /*******************************************************************************
    *  Name            : isOpportuintyOld()
    *  Summary         : Check last change of Stage  
    *  CreatedDate     : 04/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - opportunity to check last change of Stage
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isOpportuintyOld(Opportunity opportunity) {
        for (OpportunityFieldHistory history : opportunity.Histories) {
            if (history.Field == 'StageName') {
                if (history.CreatedDate < Date.today().addDays(-28)) {
                    return true;
                } else {
                    return false;
                }
                
            }
        }

        return false;
    }


    /*******************************************************************************
    *  Name            : prepareUnavailableReportEmail(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is not available
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareUnavailableReportEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Credit Factory Report cannot be created.';
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Credit Factory Report can not be created.<br/><br/>Opportunity is closed as Lost: <a href="' + 
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' +
            'This is an automatically generated e-mail, please do not respond.';
        message.saveAsActivity = false;
        return message;
    }



    /*******************************************************************************
    *  Name            : prepareNeedInformationEmail(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales when researcher needs more information
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity, 
                         String additionalInformation - information from researcher
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareNeedInformationEmail(Opportunity opportunity, String additionalInformation) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Additional information for Credit Factory Report was sent.';
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Additional information for Credit Factory Report was sent:<br/><br/>' 
            + additionalInformation.replace('\n', '</br>').removeEnd('</br>') + 
            '<br/><br/>You will receive a notification when a new report is generated for your customer. ' + 
            'If it is not possible to generate a new report the Opportunity will be closed as Lost automatically.' +
            '<br/><br/>Opportunity: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' + 
            'This is an automatically generated e-mail, please do not respond.';
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : sendLexisNexisRequest(Opportunity opportunity, LexisNexis_Settings__c lexisNexisSettings)
    *  Summary         : Send request to LexisNexis and set response body
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - current Opportunity, 
                         LexisNexis_Settings__c lexisNexisSettings - LexisNexis settings
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public Dom.XMLNode sendLexisNexisRequest(Opportunity opportunity, LexisNexis_Settings__c lexisNexisSettings) {
        String apiErrorMessage;
        try {
            Contact primaryContact;
            for (OpportunityContactRole role : opportunity.OpportunityContactRoles) {
                if (role.isPrimary == true) {
                    primaryContact = role.Contact;
                    break;
                }
            }
            if (primaryContact != null) {
                HttpRequest request = CreditFactoryWebLexisNexis.generateIDURequest(
                    lexisNexisSettings.Endpoint__c, lexisNexisSettings.User_Name__c, lexisNexisSettings.Password__c, 
                    primaryContact.FirstName, primaryContact.LastName, primaryContact.Email, 
                    CreditFactoryGlobalUtils.returnReferenceForLexisNexis(opportunity.Account.BillingCountryCode));
                Http http = new Http();
                HttpResponse response = http.send(request);
                apiErrorMessage = CreditFactoryGlobalUtils.checkLexisNexisAPIErrors(response);
                if (apiErrorMessage != null) {
                    throw new CreditFactoryException(apiErrorMessage);
                }
                
                String xmlResponseBodyLexisNexis = response.getBody();
                Dom.Document domDocLexisNexis = new Dom.Document();
                domDocLexisNexis.load(xmlResponseBodyLexisNexis);
                Dom.XMLNode xmldomLexisNexis = domDocLexisNexis.getRootElement();
                Dom.XMLNode emailRiskBody = CreditFactoryWebLexisNexis.returnEmailRiskBody(xmldomLexisNexis);
                return emailRiskBody;
            } 
    
            return null;
        } catch (Exception e) {
	    	if (apiErrorMessage != null) {
				throw new CreditFactoryException('<br/>Reason: ' + apiErrorMessage + '. ' + '<br/>Opportunity Id: ' + opportunity.Id);
			}
			else {
				 throw new CreditFactoryException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + opportunity.Id);
			}
	    }
    }


    /*******************************************************************************
    *  Name            : prepareAvailableReportEmail(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is available
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareAvailableReportEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Credit Factory Report is created.';
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Credit Factory Report is created.<br/><br/>Please launch Credit Factory again: <a href="' + 
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' + 
            'This is an automatically generated e-mail, please do not respond.';
        message.saveAsActivity = false;
        return message;
    }



    /*******************************************************************************
    *  Name            : doDMLOperations()
    *  Summary         : Do bulk inserts, updates, send emails.    
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doDMLOperations() {
        if (! this.creditReportsMap.isEmpty()) {
            insert this.creditReportsMap.values();
            List<Credit_Factory_Report_Employee__c> creditReportEmployeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
            for (Id opportunityId : this.creditReportsMap.keySet()) {
                for (Credit_Factory_Report_Employee__c employee : this.creditReportEmployeesMap.get(opportunityId)) {
                    employee.Credit_Factory_Report__c = this.creditReportsMap.get(opportunityId).Id;
                    creditReportEmployeesListToInsert.add(employee);
                }
            }

            if (! creditReportEmployeesListToInsert.isEmpty()) {
                insert creditReportEmployeesListToInsert;
            }
        }

        if (! this.creditAttachmentsList.isEmpty()) {
            insert this.creditAttachmentsList;
        }

        if (! this.opportunitiesToUpdateList.isEmpty()) {
            update this.opportunitiesToUpdateList;
        }

        if (! this.messages.isEmpty()) {
            Messaging.sendEmail(this.messages);
        }
    }


    global void finish(Database.BatchableContext BC) {

    }
}