public with sharing class PPR_API_AsyncRequests implements Queueable, DataBase.AllowsCallouts {
    private E2EFormParams formParams;
    private GlobalUtils.BusinessProcessType businessProcessType;
    private E2EFormRuService formService;
    private E2EFormRuDao e2eFormRuDao;
    private ReportWebService reportWebService;
    private TransitWebService transitWebService;
    private MZKWebService mzkWebService;
    private CardsRangeWebService cardsRangeWebService;
    private CFServiceRuImpl cfService;
    private E2EFormData__c formDataRecord;
    private PPR_API_Settings__c settings;
    @TestVisible
    private Map<String, String> cardIdNumberMap = new Map<String, String>();

    public PPR_API_AsyncRequests(E2EFormParams params, E2EFormData__c formData) {
        this.formParams = params;
        this.businessProcessType = GlobalUtils.BusinessProcessType.PPR_API;
        this.cardsRangeWebService = new CardsRangeWebServiceImpl();
        this.reportWebService = new ReportWebServiceImpl();
        this.transitWebService = new TransitWebServiceImpl();
        this.mzkWebService = new MZKWebServiceImpl();
        this.formService = new E2EFormRuServiceImpl();
        this.e2eFormRuDao = new E2EFormRuDaoImpl();
        this.cfService = new CFServiceRuImpl();
        this.formDataRecord = formData;
        this.settings = PPR_API_Settings__c.getValues(this.formDataRecord.E2E_Source__c);
    }

    @TestVisible
    private void issueCards(List<String> cardNumbers, String source) {
        // build request
        List<String> queryOptions = new List<String>();
        if (cardNumbers == null || cardNumbers.isEmpty()) {
            throw new GlobalException('You must specify cards.');
        } else if (String.isBlank(source)) {
            throw new GlobalException('You must specify source.');
        } else {
            if (cardNumbers.size() == 1) {
                queryOptions.add('$filter=number eq \'' + cardNumbers.get(0) + '\' and is_active eq true');
            } else {
                queryOptions.add('$filter=number in (\'' + String.join(cardNumbers, '\', \'') + '\') and is_active eq true');
            }
            queryOptions.add('$expand=CardPartners($expand=Partner($filter=alias eq \'' + source + '\'))');

            // get cards
            List<Map<String, Object>> cards;
            if (Test.isRunningTest()) {
                cards = PPR_API_DataTestFactory.setCardsData();
            } else {
                cards = this.cardsRangeWebService.getEntities('Cards', queryOptions);
            }

            // validate cards
            List<String> errorMessages = new List<String>();
            List<String> foundNumbers = new List<String>();
            for (Map<String, Object> card : cards) {
                foundNumbers.add(String.valueOf(card.get('number')));
            }
            for (String cardNumber : cardNumbers) {
                if (!foundNumbers.contains(cardNumber)) {
                    errorMessages.add('Card with number ' + cardNumber + ' for source "' + source +  '" is not found');
                }
            }
            for (Map<String, Object> card : cards) {
                if ((Boolean) card.get('is_issued')) {
                    errorMessages.add('Card with number ' + card.get('number') + ' has already been issued');
                }
            }
            if (!errorMessages.isEmpty()) {
                String fullErrorMessage = String.join(errorMessages, '; ');
                throw new GlobalException(fullErrorMessage);
            }

            // issue cards
            for (Map<String, Object> card : cards) {
                Map<String, Object> requestData = new Map<String, Object>();
                requestData.put('is_issued', true);
                requestData.put('timestamp_issued', System.now().addHours(3));
                String cardId = String.valueOf(card.get('id'));
                String cardNumber = String.valueOf(card.get('number'));
                System.debug('Issue card '+ cardNumber);

                if (!Test.isRunningTest()) {
                    this.cardsRangeWebService.updateEntity('Cards', cardId, requestData);
                }

                System.debug('Card ' + cardNumber + ' has been issued');
                this.cardIdNumberMap.put(cardId, cardNumber);
            }
        }
    }

    public void execute(QueueableContext param1) {
        Opportunity opportunity = new Opportunity(Id = formDataRecord.E2E_Opportunity_Id__c, Business_process__c = this.businessProcessType.name());
        try {
            if (!formParams.sendToInbound) { // Standard E2E process

                // issue cards in Cards service
                System.debug('******* CARDS ISSUE START *********');
                if (!Test.isRunningTest()) issueCards(this.formParams.cards, this.formDataRecord.E2E_Source__c);
                System.debug('******* CARDS ISSUE COMPLETE *********');

                // Generate Contract
                ReportResponseData reportResponseData = sendRequestForGenerateContract(false);
                formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name();
                System.debug('**** REPORT RESPONSE: ' + reportResponseData);
                System.debug('**** REPORT REQUEST FOR ' + this.businessProcessType.name() + ' process ENDED');

                formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{
                        formParams.contractPrefix, formParams.contractCounter
                })) : '';
                opportunity.Agreement_Date__c = Date.today();

                // Create Transit Cont
                Opportunity oppty = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :formParams.opportunityId];
                formParams.transitManagerId = GlobalUtils.getTransitIdByUserId(oppty.OwnerId);
                if (!Test.isRunningTest()) {
                    TransitRequestData transitRequestData = formService.prepareTransitRequestData(formDataRecord.Id, formParams, null, businessProcessType);
                    System.debug('transitRequestData.Cont.promoCode = ' + transitRequestData.Cont.promoCode);
                    System.debug('transitRequestData.Cont.p_standart_promos = ' + transitRequestData.Cont.p_standart_promos);
                    System.debug('transitRequestData.idEqv - ' + transitRequestData.Cont.eqv);
                    TransitResponseData response = this.transitWebService.storeContData(transitRequestData);
                    formParams.transitContId = response.createdId;
                }
                this.formParams.createContInTransit = ' > ' + GlobalUtils.E2ERuProcessStatus.CreateContInTransit.name(); // log process
                System.debug('this.formParams.transitContId: ' + this.formParams.transitContId);
                System.debug('**** TRANSIT REQUEST FOR ' + this.businessProcessType.name() + ' process ENDED');

                formDataRecord.E2E_Transit_Cont_Id__c = GlobalUtils.blankStringIfNull(formParams.transitContId);
                opportunity.Transit_ID__c = formParams.transitContId;

                // Create MZK proposal
                if (!Test.isRunningTest()) {
                    MZKRequest request = formService.prepareMzkRequest(this.formDataRecord.Id, this.formParams);
                    formParams.requestNumMZK = this.mzkWebService.getRequestNumber(request);
                }
                System.debug('MZK number: ' + formParams.requestNumMZK);
                System.debug('**** MZK REQUEST FOR ' + businessProcessType.name() + ' process ENDED');

                formDataRecord.E2E_Req_Num_MZK__c = GlobalUtils.blankStringIfNull(formParams.requestNumMZK);
                opportunity.Req_Num_MZK__c = formParams.requestNumMZK;

                // Create document links for client private office (для личного кабинета)
                sendRequestForCreateDocLinks(reportResponseData);

                // Update sObjects
                formDataRecord.E2E_Process_Status__c = 'Created';
                e2eFormRuDao.updateFormData(formDataRecord);

                opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.AwaitingPayment);
                opportunity.e2e_payment_status__c = 'Ожидание платежа'; // Emarsys send email trigger
                // SF-1049 
                opportunity.PreScoring_Overdraft__c = formParams.prepayAmount;
                opportunity.Credit_days_ppr__c = settings.Credit_days_ppr__c;

                e2eFormRuDao.updateOpportunity(opportunity);
            } else { // Send to Inbound
                System.debug('Send to Inbound');

                // Generate Contract
                ReportResponseData reportResponseData = sendRequestForGenerateContract(false);
                this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
                System.debug('**** REPORT RESPONSE: ' + reportResponseData);

                // Update sObjects
                formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{
                        formParams.contractPrefix, formParams.contractCounter
                })) : '';
                formDataRecord.E2E_Process_Status__c = 'Hand processing';
                e2eFormRuDao.updateFormData(formDataRecord);
                System.debug('Send to Inbound end');
            }

            System.debug('**** E2E ASYNC REQUESTS DONE');
            PPR_API_ResponseBody response = new PPR_API_ResponseBody();
            response.metadata = new PPR_API_ResponseBody.Metadata();
            response.metadata.id = formParams.formDataId;
            response.metadata.user = formParams.externalUser;
            response.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
            response.customerInfo.inn = formParams.companyInn;
            response.customerInfo.customerStatus = this.formDataRecord.E2E_Process_Status__c;
            response.customerInfo.customerStatusId = (String) PPR_Mapping_Utils.customerStatusMap.get(this.formDataRecord.E2E_Process_Status__c);
            if (settings != null && String.isNotBlank(settings.Callback_URI__c)) {
                sendCallback(
                        JSON.serialize(
                                response,
                                true
                        ),
                        settings.Callback_URI__c
                );
            }
        } catch (Exception e) {
            if ( !this.cardIdNumberMap.isEmpty()) {
                System.debug('ROLLING BACK ISSUED CARDS: ' + String.join(this.cardIdNumberMap.values(), ', '));
                rollbackCards(this.cardIdNumberMap.keySet());
            }
            System.debug('E2EAsyncSenderRequests Exception = ' + e.getStackTraceString()+' , ' + e.getMessage());

            formDataRecord.E2E_Process_Status__c = 'Hand processing';
            e2eFormRuDao.updateFormData(formDataRecord);

            opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
            try {
                opportunity.E2E_Errors__c = String.valueOf(e.getMessage());
                e2eFormRuDao.updateOpportunity(opportunity);
            } catch (Exception ex) {
                System.debug('e2eFormRuDao.updateOpportunity Exception ' + e.getStackTraceString()+' , ' + e.getMessage());
                opportunity.E2E_Errors__c = String.valueOf(e.getMessage()).substringBefore('requestBody');
                e2eFormRuDao.updateOpportunity(opportunity);
            }
            if (settings != null && String.isNotBlank(settings.Callback_URI__c)) {
                PPR_API_ResponseBody response = ResponseBodyBuilder.constructPPR_API_ResponseBodyError('Error with Async Requests: ' + e.getMessage());
                response.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
                response.customerInfo.inn = formParams.companyInn;

                sendCallback(JSON.serialize(response, true), settings.Callback_URI__c);
            }
        }
    }

    private ReportResponseData sendRequestForGenerateContract(Boolean isDraft) {
        ReportRequestData requestData = this.formService.prepareReportRequestData(formParams, isDraft, businessProcessType);
        
        System.debug('requestData.reportParams.PROMOCODE = ' + requestData.reportParams.PROMOCODE);
        System.debug('requestData.reportParams.SUPPLIER = ' + requestData.reportParams.SUPPLIER);
        System.debug('requestData.reportParams.SPECIAL_OFFER_NAME = ' + requestData.reportParams.SPECIAL_OFFER_NAME);
        System.debug('requestData.specialOfferId = ' + requestData.specialOfferId);

        System.debug('requestData.businessType - ' + requestData.businessType);
        System.debug('requestData.idEqv - ' + requestData.idEqv);
        System.debug('requestData.companyName - ' + requestData.companyName);
        System.debug('requestData.reportParams.CLIENT_NAME - ' + requestData.reportParams.CLIENT_NAME);
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
        formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
        formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
        formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
        formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
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

    @Future(Callout = true)
    public static void sendCallback(String body, String uri) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(uri);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        if (!Test.isRunningTest()) {
            HttpResponse response = http.send(request);
            System.debug('response.getStatusCode() = ' + response.getStatusCode());
            System.debug('response.getStatus() = ' + response.getStatus());
            System.debug('response.getBody() = ' + response.getBody());
        }
    }

    @Future(Callout = true)
    public static void rollbackCards(Set<String> cardIds) {
        Map<String, Object> requestData = new Map<String, Object>();
        requestData.put('is_issued', false);
        CardsRangeWebService cardsRangeWebService = new CardsRangeWebServiceImpl();
        for (String id : cardIds) {
            cardsRangeWebService.updateEntity('Cards', id, requestData);
        }
    }
}