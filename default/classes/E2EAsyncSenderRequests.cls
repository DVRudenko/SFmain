public class E2EAsyncSenderRequests implements Queueable, DataBase.AllowsCallouts {
    private E2EFormRuService formService;
    private E2EFormRuDao e2eFormRuDao;
    private TransitWebService transitWebService;
    private MZKWebService mzkWebService;
    private ReportWebService reportWebService;

    private E2EFormParams formParams;
    private E2EFormData__c formDataRecord;
    private Map<String, LongFormPage> pagesContentMap;
    private GlobalUtils.BusinessProcessType businessProcessType;

    public E2EAsyncSenderRequests(Id formDataId, E2EFormParams formParamsValue, Map<String, LongFormPage> pagesContentMapValue, GlobalUtils.BusinessProcessType businessProcessType) {
        try {
            this.businessProcessType = businessProcessType;
            this.formService = new E2EFormRuServiceImpl();
            this.e2eFormRuDao = new E2EFormRuDaoImpl();
            this.transitWebService = new TransitWebServiceImpl();
            this.mzkWebService = new MZKWebServiceImpl();
            this.reportWebService = new reportWebServiceImpl();

            this.formDataRecord = e2eFormRuDao.getFormDataById(formDataId);
            this.formParams = formParamsValue;
            this.pagesContentMap = pagesContentMapValue;
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>E2EAsyncSenderRequests.execute : ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    public void execute(QueueableContext param1) {
        Opportunity opportunity = new Opportunity(Id = formDataRecord.E2E_Opportunity_Id__c, Business_process__c = this.businessProcessType.name());
        try {
            System.debug('**** E2E ASYNC REQUESTS BEGIN');
            System.debug('**** E2E ASYNC REQUESTS: sendToInbound = ' + this.formParams.sendToInbound);
            if (!formParams.sendToInbound) { // Standard E2E process
                // Generate Contract
                ReportResponseData reportResponseData = sendRequestForGenerateContract(false);
                this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
                System.debug('**** REPORT RESPONSE: ' + reportResponseData);
                System.debug('**** REPORT REQUEST FOR ' + this.businessProcessType.name() + ' process ENDED');

                formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{
                        formParams.contractPrefix, formParams.contractCounter
                })) : '';
                
                if (this.businessProcessType != GlobalUtils.BusinessProcessType.E2EZoho) {
                    // Create Transit Cont
                    TransitRequestData transitRequestData = formService.prepareTransitRequestData(this.formDataRecord.Id, this.formParams, this.pagesContentMap, this.businessProcessType);
                    if (!Test.isRunningTest()) {
                        TransitResponseData response = this.transitWebService.storeContData(transitRequestData);
                        this.formParams.transitContId = response.createdId;
                    }
                    this.formParams.createContInTransit = ' > ' + GlobalUtils.E2ERuProcessStatus.CreateContInTransit.name(); // log process
                    System.debug('this.formParams.transitContId: ' + this.formParams.transitContId);
                    System.debug('**** TRANSIT REQUEST FOR ' + this.businessProcessType.name() + ' process ENDED');

                    formDataRecord.E2E_Transit_Cont_Id__c = GlobalUtils.blankStringIfNull(formParams.transitContId);
                    opportunity.Transit_ID__c = formParams.transitContId;
                    
                    // Create MZK proposal
                    MZKRequest request = formService.prepareMzkRequest(this.formDataRecord.Id, this.formParams);
                    if (!Test.isRunningTest()) {
                        this.formParams.requestNumMZK = this.mzkWebService.getRequestNumber(request);
                    }
                    System.debug('MZK number: ' + this.formParams.requestNumMZK);
                    System.debug('**** MZK REQUEST FOR ' + this.businessProcessType.name() + ' process ENDED');

                    formDataRecord.E2E_Req_Num_MZK__c = GlobalUtils.blankStringIfNull(formParams.requestNumMZK);
                    opportunity.Req_Num_MZK__c = formParams.requestNumMZK;
                }
                // Create document links for client private office (для личного кабинета)
                sendRequestForCreateDocLinks(reportResponseData);

                // Update sObjects
                e2eFormRuDao.updateFormData(formDataRecord);

                opportunity.StageName = 'Awaiting payment';
                opportunity.e2e_payment_status__c = 'Ожидание платежа'; // Emarsys send email trigger
                e2eFormRuDao.updateOpportunity(opportunity);
            } else { // Send to Inbound
                //SF-637
                //opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
                //e2eFormRuDao.updateOpportunity(opportunity);

                // Generate Contract
                ReportResponseData reportResponseData = sendRequestForGenerateContract(false);
                this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
                System.debug('**** REPORT RESPONSE: ' + reportResponseData);

                // Update sObjects
                formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{
                        formParams.contractPrefix, formParams.contractCounter
                })) : '';
                e2eFormRuDao.updateFormData(formDataRecord);
            }
            System.debug('**** E2E ASYNC REQUESTS DONE');
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>E2EAsyncSenderRequests.execute : ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));

            if (formDataRecord.E2E_Contract_Number__c != null) e2eFormRuDao.updateFormData(formDataRecord);

            Id opptyId;

            opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
            try {
                opportunity.E2E_Errors__c = String.valueOf(e.getMessage());
                opptyId = e2eFormRuDao.updateOpportunity(opportunity);
            } catch (Exception ex) {
                opportunity.E2E_Errors__c = String.valueOf(e.getMessage()).substringBefore('requestBody');
                opptyId = e2eFormRuDao.updateOpportunity(opportunity);
            }
            //VS SF-674
            E2EErrorService.createNewErrorMessage(e, opportunity.Id);

            if (this.businessProcessType == GlobalUtils.BusinessProcessType.E2EBusiness || 
                this.businessProcessType == GlobalUtils.BusinessProcessType.E2EZoho) {
                // send notification to opportunity owner
                Opportunity oppty = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opptyId];
                try {
                    EmailGenerator.sendHtmlEmail(oppty.OwnerId, 'E2EForBusiness: Ошибка постановки на старт', '<br>Во время постановки на старт было полученно сообщение об ошибке: ' + String.valueOf(e.getMessage()) + ' ' + String.valueOf(e.getStackTraceString()) + '<br/><br>Возможность - ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppty.Id + '</br>');
                } catch (Exception emailException) {
                    ExceptionLogger.sendException('<br/>E2EAsyncSenderRequests.execute.EmailGenerator.sendHtmlEmail : ' + String.valueOf(emailException.getMessage()), String.valueOf(emailException.getStackTraceString()));
                }
            } else {
                // send notification to call center
                EmailTemplate emailMessage = EmailGenerator.getEmailTemplate(
                        GlobalUtils.EmailTemplateDevName.E2E_RU_Warning_Notification_Call_Center,
                        new Map<String, Object>{
                                '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                '/$opportunity.Id$/' => opportunity.Id,
                                '/$opportunity.Name$/' => 'New E2E Client'
                        }
                );
            }
        }
        //SF-1288 fix
        if (Boolean.valueOf(CFUtils.getScoringSettings('active')) && E2EFormRuServiceImpl.isScoringTrue) {
            CFServiceRuImpl service = new CFServiceRuImpl();
            OpportunityScoring scoring = service.processOpportunityScoring(formParams);
            System.debug('scoring ' + scoring);
            if (scoring != null) {
                service.createFRAUDScoringData(scoring);
            }
        }
    }

    private ReportResponseData sendRequestForGenerateContract(Boolean isDraft) {
        ReportRequestData requestData;
        if(this.businessProcessType != GlobalUtils.BusinessProcessType.E2EBusiness &&
           this.businessProcessType != GlobalUtils.BusinessProcessType.E2EZoho) {
            requestData = this.formService.prepareReportRequestData(this.formDataRecord.Id, this.formParams, this.pagesContentMap, isDraft, this.businessProcessType);
        } else {
            requestData = this.formService.prepareReportRequestData(this.formParams, isDraft, this.businessProcessType);
        }

        ReportResponseData response;
        if (Test.isRunningTest()) {
            response = E2EFormRuTestUtils.createDefaultReportResponse();
        } else {
            response = this.reportWebService.getReportIdsFromCreditFactory(requestData);
        }
        if (!isDraft) {
            saveContractNumber(response);
        }
        return response;
    }

    private void saveContractNumber(ReportResponseData response) {
        this.formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
        this.formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
        this.formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
        this.formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
    }

    private void sendRequestForCreateDocLinks(ReportResponseData responseData) {
        try {
            TransitDocLinkRequestData requestData = this.formService.prepareTransitDocLinkRequestData(responseData, this.formParams);
            System.debug('**** TRANSIT DOC LINK REQUEST DATA: ' + requestData);

            // send request to create document links
            if (!Test.isRunningTest()) {
                this.transitWebService.createDocumentLinks(requestData);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>E2EAsyncSenderRequests.sendRequestForCreateDocLinks : ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }
}
