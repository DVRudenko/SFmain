public without sharing class PaymentTransactionHandler {

    /*******************************************************************************
    *  Name            : updateTransactionConfiramtion
    *  Summary         : update parent opportunity field after payment transaction are confirmed
    *  CreatedDate     : 28.02.2018
    *  ModifiedDate    : 05.08.2020
    *  Parameters      : --
    *  Returns         : --
    ******************************************************************************/
    public static void updateTransactionConfirmation(Map<Id, Payment_Transaction__c> oldMap, Map<Id, Payment_Transaction__c> newMap){
        try {
            Set<Id> relatedOpportunitiesIds = new Set<Id>();
            for (Payment_Transaction__c newPaymentTransaction : newMap.values()) {
                if (oldMap.get(newPaymentTransaction.Id).Status__c != newPaymentTransaction.Status__c) {
                    relatedOpportunitiesIds.add(newPaymentTransaction.OpportunityId__c);
                }
            }
            if (! relatedOpportunitiesIds.isEmpty()) {
                Map<Id, Opportunity> relatedOpportunities = new Map<Id, Opportunity>([
                    SELECT Id, Security_Amount_To_Pay__c, Security_To_Pay__c, Garantie__c, Garantie_other__c,
                            E2E_payment_status__c, StageName, Starts_Status__c, Registered_Country__c, E2E_Data_Object__c
                    FROM Opportunity
                    WHERE Id IN :relatedOpportunitiesIds
                ]);
                Map<String, String> opptyIdToDataObjectIdMap = new Map<String, String>();
                for (Opportunity oppty : relatedOpportunities.values()) {
                    if (oppty.E2E_Data_Object__c != null) {
                        opptyIdToDataObjectIdMap.put(oppty.Id, oppty.E2E_Data_Object__c);
                    }
                }

                if (! opptyIdToDataObjectIdMap.isEmpty()) {
                    Map<String, E2E_Data_Object__c> dataObjectsMap = new Map<String, E2E_Data_Object__c>([
                            SELECT RecordType.Name, Country_Code__c, Security_Amount_To_Pay__c, Payment_Status__c, Deposit_Agreement__c,
                                (SELECT Id FROM E2E_Data_Logs__r WHERE Error_Code__c = 100 AND RecordType.Name = 'Exception' LIMIT 1)
                            FROM E2E_Data_Object__c
                            WHERE Id IN :opptyIdToDataObjectIdMap.values()
                    ]);
                    List<E2E_Data_Object__c> dataObjectsToUpdateList = new List<E2E_Data_Object__c>();
                    for (Payment_Transaction__c newPaymentTransaction : newMap.values()) {
                        Opportunity currentOpportunity = relatedOpportunities.get(newPaymentTransaction.OpportunityId__c);
                        E2E_Data_Object__c currentDataObject = dataObjectsMap.get(opptyIdToDataObjectIdMap.get(currentOpportunity.Id));

                        if ((newPaymentTransaction.Status__c == 'COMPLETED' || newPaymentTransaction.Status__c == '9')) {
                            currentDataObject.Payment_Status__c = 'COMPLETED';
                            currentDataObject.E2E_Status__c = 'Finished';
                            if (! currentDataObject.E2E_Data_Logs__r.isEmpty()) {
                                currentDataObject.StageName__c = 'Pending Credit - E2E Check';
                                currentDataObject.E2E_Finish_Details__c = 'Order Submitted';
                            } else {
                                currentDataObject.StageName__c = 'Closed Won';
                                currentDataObject.E2E_Finish_Details__c = 'Order Completed';
                            }
                        }
                        else if (newPaymentTransaction.Status__c == '5') {
                            currentDataObject.Payment_Status__c = 'COMPLETED';
                        }
                        else if (newPaymentTransaction.Status__c == 'CANCELED' || newPaymentTransaction.Status__c == '1') {
                            currentDataObject.Payment_Status__c = 'CANCELED';
                        }
                        else if((newPaymentTransaction.Status__c == 'REJECTED' ||
                                newPaymentTransaction.Status__c == '2') ||
                                newPaymentTransaction.Status__c == '93' ||
                                (newPaymentTransaction.Status__c.length() == 2 && newPaymentTransaction.Status__c.substring(1,2) == '2')) {
                            currentDataObject.Payment_Status__c = 'REJECTED';
                            currentDataObject.E2E_Status__c = 'Finished';
                            currentDataObject.E2E_Finish_Details__c = 'Awaiting Payment';
                        }
                        else if (newPaymentTransaction.Status__c == 'WAITING_FOR_CONFIRMATION' ||
                                newPaymentTransaction.Status__c == 'PENDING') {
                            currentDataObject.Payment_Status__c = 'PENDING'; // need to change in future
                        }
                        dataObjectsToUpdateList.add(currentDataObject);
                    }
                    update dataObjectsToUpdateList;
                    for (E2E_Data_Object__c dataObject : dataObjectsToUpdateList) {
                        if (dataObject.Payment_Status__c != 'PENDING') {
                            ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(dataObject.RecordType.Name);
                            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(dataObject.Country_Code__c);
                            e2eStep.setExistingDataObject(dataObject);
                            e2eStep.runJobs(e2eDatabase, new List<String>{'syncFinishedDeal'});
                        }
                    }
                } else {
                    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
                    for (Payment_Transaction__c newPaymentTransaction : newMap.values()) {
                        Opportunity currentOpportunity = relatedOpportunities.get(newPaymentTransaction.OpportunityId__c);
                        if (currentOpportunity != null){
                            if ((currentOpportunity.Security_Amount_To_Pay__c == newPaymentTransaction.Amount__c) &&
                                    (newPaymentTransaction.Status__c == 'COMPLETED' || newPaymentTransaction.Status__c == '9')) {
                                E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(currentOpportunity.Registered_Country__c);
                                if (settings.Enable_authorization_non_granted_check__c) {
                                    currentOpportunity.Starts_Status__c = '0.9 Ready for GFN';
                                }
                                currentOpportunity.Garantie_other__c = currentOpportunity.Security_Amount_To_Pay__c;
                                currentOpportunity.Garantie__c = currentOpportunity.Security_To_Pay__c;
                                currentOpportunity.StageName = 'Closed Won';
                                currentOpportunity.E2E_payment_status__c = 'ACCEPT';
                            }
                            if(newPaymentTransaction.Status__c == '5'){
                                currentOpportunity.E2E_payment_status__c = 'ACCEPT';
                            }
                            else if(newPaymentTransaction.Status__c == 'CANCELED' || newPaymentTransaction.Status__c == '1'){
                                currentOpportunity.E2E_payment_status__c = 'CANCEL';
                            }
                            else if((newPaymentTransaction.Status__c == '2') || (newPaymentTransaction.Status__c == '93')) {
                                currentOpportunity.E2E_payment_status__c = 'DECLINE';
                            }
                            else if(newPaymentTransaction.Status__c == 'REJECTED' ||
                                    newPaymentTransaction.Status__c == '0' ||
                                    (newPaymentTransaction.Status__c.length() == 2 && newPaymentTransaction.Status__c.substring(1,2) == '2')) {
                                currentOpportunity.E2E_payment_status__c = 'REJECTED';
                            }
                            else if (newPaymentTransaction.Status__c == 'WAITING_FOR_CONFIRMATION' || newPaymentTransaction.Status__c == 'PENDING') {
                                currentOpportunity.E2E_payment_status__c = 'PENDING'; // need to change in future
                            }
                            opportunitiesToUpdate.add(currentOpportunity);
                        }
                        else {
                            ExceptionLogger.sendException('PaymentTransactionHandler Exception: Payment_Transaction__c ID=' + newPaymentTransaction.id,
                                    ' Update transaction with Opportunity = "null"');
                        }
                    }
                    if (opportunitiesToUpdate.size() != 0) {
                        update opportunitiesToUpdate;
                    }
                }
            }
        }
        catch (Exception e){
            ExceptionLogger.sendException('PaymentTransactionHandler ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }
}
