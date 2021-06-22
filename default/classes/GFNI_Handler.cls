/**
 * Created by Nikita.Mikhailov on 28.11.2018.
 * Class with future method to create new customer via REST or e-mail
 * Future method calls from OpportunityTrigger
 */
global class GFNI_Handler {

    /*******************************************************************************
    *  Name            : createFullGFNCustomer
    *  Summary         : future method for opportunity sorting and calling creation by REST or e-mail
    *  CreatedDate     : 28/11/2018
    *  Parameters      : Id opptyToUpdate
    *  Returns         : void
    ******************************************************************************/
    @Future(Callout=true)
    public static void createFullGFNCustomer(Id opptyToUpdate) {
        System.debug('In future method');

        Set<Id> euroShellRecordTypesIds = new Set<Id>();
        Set<String> recordTypesNamesSet = ((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'LineOfBusinessId')).keySet();
        for (String recordTypeName : recordTypesNamesSet) {
            if (GlobalUtils.returnRecordTypeId('Opportunity', recordTypeName) != null) {
                euroShellRecordTypesIds.add(GlobalUtils.returnRecordTypeId('Opportunity', recordTypeName));
            }
        }

        List<Messaging.Email> mailsList = new List<Messaging.Email>();
        List<AccountGfnReportSendingLog> accountGfnReportSendingLogs = new List<AccountGfnReportSendingLog>();
        System.debug(opptyToUpdate);

        Opportunity opportunity = [
                SELECT  Id, Name, RecordTypeId, Starts_Status__c, RecordType.Name,
                        Account.BillingCountry, Account.BillingCity, Account.BillingStreet, Account.BillingPostalCode, Account.BillingState,
                        Account.ShippingCountry, Account.ShippingCity, Account.ShippingStreet, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingAddress,
                        AccountId, LastModifiedById, Account.BillingCountryCode,
                        GFNI_ApplicationId__c, Custom_PIN__c, GFN_number_for_starts__c, Account.Account_Nr__c,
                        Account.Name, Account.ColCo__c, (SELECT Id, Product2.Family FROM OpportunityLineItems), (SELECT Id, GFNI_Status__c FROM Tankkarten__r)
                FROM    Opportunity
                WHERE   Id =: opptyToUpdate
        ];

        GFNI_General_Settings__c gfniSettings = GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode);
        if (euroShellRecordTypesIds.contains(opportunity.RecordTypeId)) {
            //skip if this is test customer
            //for sandbox, skip if only Test_Mode is inactive
            if (!GFNI_Utils.isSandbox || (GFNI_Utils.isSandbox && !gfniSettings.Test_mode__c)) {
                if (GFNI_Utils.testCompaniesMapByCountry.containsKey(opportunity.Account.BillingCountryCode.substring(0, 2))) {
                    if (GFNI_Utils.testCompaniesMapByCountry.get(opportunity.Account.BillingCountryCode.substring(0, 2)) instanceof List<Object>) {
                        List<Object> listOfCustomers = (List<Object>) GFNI_Utils.testCompaniesMapByCountry.get(opportunity.Account.BillingCountryCode.substring(0, 2));
                        for (Object customer : listOfCustomers) {
                            if (opportunity.Name == (String) customer) {
                                System.debug(opportunity.Name + ' is test customer and will be skipped.');
                                return ;
                            }
                        }
                    }
                }
            }

            if (gfniSettings.IsForRobot__c) {
                //DEPRECATED
                System.debug('Create by email');
                createByEmail(opportunity, mailsList, accountGfnReportSendingLogs);
            } else {
                System.debug('Create by request');
                if (Test.isRunningTest() || GFNI_Utils.isProductionOrg() || gfniSettings.Test_mode__c) {
                    createByRequest(opportunity);
                } else {
                    System.debug('WARNING!!! GFNI: You are running this code in sandbox. Please make sure that Test_mode is switched on for every country in GFNI_General_Settings__c!');
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : createByEmail
    *  Summary         : create by email
    *  CreatedDate     : 28.11.2018
    *  Parameters      : Opportunity opportunity, List<Messaging.Email> mailsList, List<AccountGfnReportSendingLog> accountGfnReportSendingLogs
    *  Returns         : void
    *  DEPRECATED
    ******************************************************************************/
    public static void createByEmail(Opportunity opportunity, List<Messaging.Email> mailsList, List<AccountGfnReportSendingLog> accountGfnReportSendingLogs) {
        System.debug('*** PREPARE ACCOUNT REPORT FOR GFN ***');
        Account account = opportunity.Account;

        Account_GFN_Report_Email_Params__c emailParams = Account_GFN_Report_Email_Params__c.getInstance('Excel');
        String address = emailParams.Email__c;
        String emailBody = emailParams.Email_body__c;
        String format = emailParams.Attach_format__c;
        String subject = account.Name + ', ' + account.BillingCountry + ', ' + account.Account_Nr__c;
        String fileName = subject + format; // ex. Customer Account name, country, SFDC order number

        AccountGfnReportTemplate reportTemplate =
                new AccountGfnReportTemplate(opportunity.Id, opportunity.RecordTypeId, opportunity.AccountId);

        String htmlTemplate = reportTemplate.generateReportHtmlTemplate();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        Blob excel = Blob.valueOf(htmlTemplate);
        attach.setBody(excel);
        attach.setFileName(fileName);

        System.debug('*** SENDING GFN REPORT ***');

        // add address for debug
        Boolean debugMode = emailParams.Test_mode__c;
        String debugEmail = '';
        if (debugMode) {
            debugEmail = (emailParams.Test_mode_email__c != null) ? emailParams.Test_mode_email__c : '';
        }

        System.debug(subject);
        System.debug(emailBody);
        System.debug(address + ';' + debugEmail);

        GFNI_Utils.sendEmail(subject, emailBody, (address + ';' + debugEmail).split(';'), attach, new AccountGfnReportSendingLog(opportunity.AccountId, opportunity.Id, address, fileName, opportunity.LastModifiedById));
    }

    /*******************************************************************************
    *  Name            : createByRequest
    *  Summary         : create request, send it, receive response, consolidate results, save logs
    *  CreatedDate     : 28.11.2018
    *  Parameters      : Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static void createByRequest(Opportunity opportunity) {
        System.debug('GFNI_Handler: In create by request method');

        GFNI_Logger logger = String.isEmpty(opportunity.GFNI_ApplicationId__c) ? new GFNI_Logger(opportunity.Id, true) : new GFNI_Logger(opportunity.Id, false);

        System.debug('GFNI_Handler: *** PREPARE REQUEST FOR GFN ***');
        String body = '';
        try {
            body = GFNI_RequestBuilder.buildJSONCreateCustomerAndCards(opportunity);
        } catch (Exception e) {
            System.debug('GFNI_Handler: exception on buildJSONCreateCustomerAndCards');
            GFNI_ExceptionHandler.handleCreateByRequestExceptions(e, opportunity, 'N/A', 'N/A', logger, null);

            return;
        }
        System.debug(body);
        String requestId = GFNI_Utils.getStringValue(body, 'RequestID');
        System.debug('GFNI_Handler: *** SENDING GFN REQUEST ***');

        logger.addLog('Request', body, requestId);

        HttpResponse response;

        try {
            response = GFNI_RequestHandler.sendRequest(body, GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).Create_Customer_and_Cards__c, opportunity.Account.BillingCountryCode);
        } catch (Exception e) {
            //if there was a problem with request, update log with error and close session
            System.debug('GFNI_Handler: exception on sendRequest');
            GFNI_ExceptionHandler.handleCreateByRequestExceptions(e, opportunity, GFNI_Utils.getStringValue(body, 'ApplicationId'), requestId, logger, null);

            return;
        }

        //if everything is fine, save response and update opportunity.GFNI_ApplicationId__c, opportunity.GFN_number_for_starts__c and card status for every card to Pending
        logger.addLog('Response', response.getBody(), requestId);

        opportunity.GFNI_ApplicationId__c = GFNI_Utils.getStringValue(body, 'ApplicationId');
        try {
            checkAddressLengthAndSendEmail(opportunity);
            System.debug('GFNI_Handler: *** UPDATING OPPORTUNITY ***');
            opportunity.Starts_Status__c = String.valueOf(GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'ResultingStatus'));
            opportunity.GFN_number_for_starts__c = GFNI_Utils.getStringValue(response.getBody(), 'CustomerServiceReferenceId');
            update opportunity;

            System.debug('GFNI_Handler: *** UPDATING ACCOUNT ***');
            Account acc = opportunity.Account;
            //acc.GFN_Nr__c = GFNI_Utils.getStringValue(response.getBody(), 'CustomerServiceReferenceId');
            if (!String.isNotBlank(acc.ColCo__c) && String.isNotBlank(acc.BillingCountry))
                acc.ColCo__c = GFNI_Utils.getStringValue(acc.BillingCountry.split('-').get(0), Schema.Account.BillingCountry.getDescribe(), 'CountryCode');

            update acc;

            //статус поставится только тем картам, которые ожидают статус обратно
            //status applied only to cards which were sent
            if (!opportunity.Custom_PIN__c) {
                System.debug('GFNI_Handler: *** UPDATING CARDS ***');
                List<Tankkarten__c> cards = new List<Tankkarten__c>();
                for (Tankkarten__c card : opportunity.Tankkarten__r) {
                    card.GFNI_Status__c = 'Pending';
                    cards.add(card);
                }
                update cards;
            }

            System.debug('GFNI_Handler: *** UPDATING OPPORTUNITY ITEM ***');
            List<Offer_Item__c> offerItems = new List<Offer_Item__c>();
            Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunity.OpportunityLineItems);
            for (Offer_Item__c offerItem : [SELECT Id, Opportunity_Product_Id__c FROM Offer_Item__c WHERE Opportunity_Product_Id__c IN :opportunityLineItemsMap.keySet()]) {
                //update line item
                if (opportunity.Custom_PIN__c) {
                    if (!opportunityLineItemsMap.get(offerItem.Opportunity_Product_Id__c).Product2.Family.equals('EV'))
                        continue;
                }

                offerItem.GFNI_Status__c = 'Pending';
                offerItems.add(offerItem);
            }
            update offerItems;

        } catch (Exception e) {
            //if there was a problem with update, update log with error and close session
            System.debug('GFNI_Handler: exception on update opp-ty or account or cards');
            GFNI_ExceptionHandler.handleCreateByRequestExceptions(e, opportunity, GFNI_Utils.getStringValue(body, 'ApplicationId'), requestId, logger, 'GFN Number: ' + GFNI_Utils.getStringValue(response.getBody(), 'CustomerServiceReferenceId'));
            return;
        }

        System.debug('GFNI_Handler: *** UPDATING LOG ***');
        logger.saveLogs();
    }

    /*******************************************************************************
    *  Name            : checkCardStatus
    *  Summary         : future method for calling application status (cards creation status). Updates cards status. NOTE: this request is country specific, and must be called for opportunities with same country.
    *  CreatedDate     : 23.01.2019
    *  Parameters      : Set<Id>
    *  Returns         : void
    ******************************************************************************/
    @Future(Callout=true)
    public static void checkCardStatus(Set<Id> opportunitiesIds) {

        List<Opportunity> opportunities = [
                SELECT Id, Name, Account.Id, Account.BillingCountry,
                        Account.BillingCountryCode, CreatedDate, Account.Owner.Name, GFNI_ApplicationId__c,
                        GFN_number_for_starts__c
                FROM Opportunity
                WHERE Id IN :opportunitiesIds
        ];

        Map<String, GFNI_Logger> logs = new Map<String, GFNI_Logger>();

        for (Opportunity opportunity : opportunities) {
            GFNI_Logger log = new GFNI_Logger(opportunity.Id, false);
            logs.put(opportunity.Id, log);
        }

        Map<String, Opportunity> opportunityMapByGFN = new Map<String, Opportunity>();

        System.debug('*** BUILDING REQUEST FOR: ' + opportunities.get(0).Account.BillingCountryCode + '***');

        String body;

        try {
            body = GFNI_RequestBuilder.buildJSONApplicationStatus(opportunities);
        } catch (Exception e) {
            System.debug('GFNI_ApplicationStatusSchedulable: exception on buildRequest');

            GFNI_ExceptionHandler.handleCheckCardStatusExceptions(e, opportunities, 'N/A', logs);

            return;
        }

        System.debug(body);

        String requestId = GFNI_Utils.getStringValue(body, 'RequestID');

        //this code is needed for smooth logs. Using this logic, log will contain request for each opportunity individually. If not do it, log will contain all application info in every opp-ty log
        GFNI_ApplicationStatusRequest applicationApplicationStatusRequest = (GFNI_ApplicationStatusRequest) JSON.deserialize(body, GFNI_ApplicationStatusRequest.class);
        for (Opportunity opportunity : opportunities) {

            opportunityMapByGFN.put(opportunity.GFN_number_for_starts__c, opportunity);

            GFNI_Logger log = logs.get(opportunity.Id);

            GFNI_ApplicationStatusRequest buffer = new GFNI_ApplicationStatusRequest();

            for (GFNI_Application application : applicationApplicationStatusRequest.Applications) {
                if (opportunity.GFNI_ApplicationId__c == application.ApplicationId) {
                    buffer.Metadata = applicationApplicationStatusRequest.Metadata;
                    buffer.addApplication(application);
                }
            }

            log.addLog('Request', JSON.serialize(buffer), requestId);
            System.debug(log);
        }

        System.debug('*** SENDING REQUEST FOR: ' + opportunities.get(0).Account.BillingCountryCode + '***');

        HttpResponse response;

        try {
            response = GFNI_RequestHandler.sendRequest(body, GFNI_Utils.getGeneralSettings(opportunities.get(0).Account.BillingCountryCode).Application_Status__c, opportunities.get(0).Account.BillingCountryCode);
        } catch (Exception e) {
            System.debug('GFNI_ApplicationStatusSchedulable: exception on sendRequest');

            GFNI_ExceptionHandler.handleCheckCardStatusExceptions(e, opportunities, requestId, logs);

            return;
        }

        System.debug(response);
        System.debug(response.getBody());

        System.debug('*** CREATING CARDS TO UPDATE LIST ***');

        List<Object> responseObject = (List<Object>) JSON.deserializeUntyped(response.getBody());

        List<SObject> itemsToUpdate = new List<SObject>();
        Map<Id, String> failedItems = new Map<Id, String>();
        Map<Id, String> warningItems = new Map<Id, String>();

        Boolean isIdCorrupted = false;

        //два объекта - жизнь боль
        for (Object application : responseObject) {
            for (Object itemStatus : (List<Object>) ((Map<String, Object>) application).get('CardsStatus')) {
                Tankkarten__c card = new Tankkarten__c();
                Offer_Item__c item = new Offer_Item__c();

                Id itemId;
                if (((Map<String, Object>) itemStatus).containsKey('CardRefId')) {
                    itemId = GlobalUtils.retrieveIdFromGUID(String.valueOf(((Map<String, Object>) itemStatus).get('CardRefId')));
                } else {
                    isIdCorrupted = true;
                    continue;
                }

                if (itemId.getSobjectType() == Tankkarten__c.getSObjectType()) {
                    card.Id = itemId;
                } else {
                    item.Id = itemId;
                }

                //TODO: remove switch constants (to GFNI_Mapping)
                if (((Map<String, Object>) itemStatus).containsKey('CardApplicationStatusId')) {
                    switch on String.valueOf(((Map<String, Object>) itemStatus).get('CardApplicationStatusId')) {
                        when '1' {
                            if (itemId.getSobjectType() == Tankkarten__c.getSObjectType()) {
                                card.GFNI_Status__c = 'Success';
                            } else {
                                item.GFNI_Status__c = 'Success';
                            }
                        }
                        when '2' {
                            if (itemId.getSobjectType() == Tankkarten__c.getSObjectType()) {
                                card.GFNI_Status__c = 'Warning';
                            } else {
                                item.GFNI_Status__c = 'Warning';
                            }

                            //there is no functionality for warning cards in GFN, but Id 2 exists
                            warningItems.put(itemId, 'Failed to retrieve warning message');
                        }
                        when else {
                            if (itemId.getSobjectType() == Tankkarten__c.getSObjectType()) {
                                card.GFNI_Status__c = 'Failed';
                            } else {
                                item.GFNI_Status__c = 'Failed';
                            }

                            failedItems.put(itemId, 'Failed to retrieve failed message');
                            if (((Map<String, Object>) itemStatus).containsKey('CardProcessingError')) {
                                Map<String, Object> itemProcessingErrorObject = (Map<String, Object>) ((Map<String, Object>) itemStatus).get('CardProcessingError');
                                if (itemProcessingErrorObject.containsKey('ErrorMessage')) {
                                    failedItems.put(itemId, String.valueOf(itemProcessingErrorObject.get('ErrorMessage')));
                                }
                            }
                        }
                    }
                }

                if (itemId.getSobjectType() == Tankkarten__c.getSObjectType()) {
                    //code to avoid Cannot have more than 10 chunks in a single operation
                    if (itemsToUpdate.isEmpty()) {
                        itemsToUpdate.add(card);
                    } else {
                        itemsToUpdate.add(0, card);
                    }
                } else {
                    itemsToUpdate.add(item);
                }
            }
        }

        //if there was cards with warnings or failed send e-mail
        if (!warningItems.isEmpty() || !failedItems.isEmpty() || isIdCorrupted) {
            String emailBody = 'There are some cards failed to be created or created with warnings!<br/><br/>';
            if (!warningItems.isEmpty()) {
                emailBody += 'Cards created with warning:<br/>';
                for (Id key : warningItems.keySet()) {
                    emailBody +=  Url.getSalesforceBaseUrl().toExternalForm() + '/' + key + ' : ' + warningItems.get(key) + '<br/>';
                }
            }

            if (!failedItems.isEmpty()) {
                emailBody += 'Cards failed to be created:<br/>';
                for (Id key : failedItems.keySet()) {
                    emailBody += Url.getSalesforceBaseUrl().toExternalForm() + '/' + key + ' : ' + failedItems.get(key) + '<br/>';
                }
            }

            if (isIdCorrupted) {
                emailBody += 'One of the card Ids is corrupted. More info in log or request from GFN Integration control panel.<br/>';
            }

            emailBody += '<br/>Have a nice day!';

            GFNI_Utils.sendHtmlEmail('NCC_' + opportunities.get(0).Account.BillingCountryCode + '_Failure_', emailBody, opportunities.get(0).Account.BillingCountryCode);
        }

        for (Opportunity opportunity : opportunityMapByGFN.values()) {

            //this code is needed for smooth logs. Using this logic, log will contain response for each opportunity individually. If not do it, log will contain all application info in every opp-ty log
            GFNI_Logger log = logs.get(opportunity.Id);

            String responseSmoothBody = '[';

            for (Object application : responseObject) {
                if (((Map<String, Object>) application).get('CustomerServiceReferenceId') == opportunity.GFN_number_for_starts__c)
                    responseSmoothBody += JSON.serialize(application);
            }

            responseSmoothBody += ']';

            log.addLog('Response', responseSmoothBody, requestId);
        }

        System.debug('*** UPDATING CARDS ***');

        try {
            if (!itemsToUpdate.isEmpty())
                update itemsToUpdate;
        } catch (Exception e) {
            System.debug('GFNI_ApplicationStatusSchedulable: exception on update itemsToUpdate');

            GFNI_ExceptionHandler.handleCheckCardStatusExceptions(e, opportunities, requestId, logs);

            return;
        }

        GFNI_Logger.saveLogsList(logs.values());
    }


    private static void checkAddressLengthAndSendEmail(Opportunity opp) {

        if(opp.RecordType.Name == 'Lotos') {
            Account acc = opp.Account;
            String errorMessage = 'The address is too long to be shipped to the customer. Please correct it.' + '\n\nOpportunity: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '\n\nHave a nice day!';
            GFNI_General_Settings__c gfniSettings = GFNI_General_Settings__c.getInstance(acc.BillingCountryCode);
            if(String.isNotEmpty(gfniSettings.Business_email__c)) {
                List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'backoffice@fleetcor.pl'];
                List<String> addresses = gfniSettings.Business_email__c.split(';');
                if(!addresses.isEmpty()) {
                    if(acc.ShippingStreet.length() > 30 || (acc.BillingStreet.length() > 30 && String.isEmpty(acc.ShippingStreet))) {
                        Messaging.SingleEmailMessage message = EmailGenerator.sendHtmlEmailWithoutAttachment(addresses, owea, 'Too long shipping address', errorMessage);
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
                    }
                }
            }            
        }
    }
}