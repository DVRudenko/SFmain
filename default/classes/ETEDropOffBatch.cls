global class ETEDropOffBatch implements Database.Batchable<SObject> {
    public String query;

    global ETEDropOffBatch () {
        this.query = 'SELECT Name, RecordTypeId, RecordType.Name, Salutation__c, First_Name__c, Last_Name__c, Phone__c, Email__c, Agreement_To_Phone_Contact__c, ' +
                    'Agreement_To_Receive_Info_By_Email__c, Agreement_Privacy_Policy__c, Country_Code__c, E2E_Last_Activity__c, ' +
                    'Current_Step__c, Selected_Company_Name__c, Selected_Company_Id__c, StageName__c, E2E_Status__c, ' +
                    'Terms_And_Conditions_Agreement__c, Authorized_Signatory_Confirmed__c, Customer_IP_Address__c, Bank_Code__c, Bank_Name__c, ' +
                    'Security_Amount_To_Pay__c, Payment_Status__c, Deposit_Agreement__c, Company_Short_Name__c, Bank_Account_Prefix__c, Bank_Account_Number__c, ' +
                    'Device_Type__c, Payment_Method__c, Credit_Limit__c, Max_Credit_Limit__c, Billing_Period__c, Client_Id__c, ' +
                    'Payment_Terms__c, E_Invoice__c, Paper_Invoice__c, Security_Level__c, Current_Language__c, Trade_Register_Number__c, ' +
                    'Registered_Postal_Code__c, Registered_Country__c, Registered_City__c, Registered_Street__c, ' +
                    'Utm_Campaign__c, Utm_Content__c, Utm_Medium__c, Utm_Placement__c, Utm_Source__c, Utm_Term__c, Utm_Url__c, ' +
                    'Birthdate__c, Company_Form__c, E2E_Finish_Details__c, Tax_ID__c, Agree_to_process_pers_data_for_marketing__c, ' +
                    'Accept_Sepa__c, Account_Holder__c, IBAN__c, SWIFT__c, Risk_Category__c, Direct_Debit_Mandate_Type__c, ' +
                    'ESI__c, Home_Station__c, PM__c, Brand__c, Available_Min_Deposit__c, Vat_ID__c, Deposit_Reason__c, Credit_System_Rating__c, ' +
                    '(SELECT Name, RecordType.Name, E2E_Step__c, Form_Identification__c, Rating__c, Feedback_Local__c, ' +
                        'Feedback_English__c, Exception_Type__c, Exception_Description__c FROM E2E_Data_Logs__r), ' +
                    '(SELECT Name, First_Name__c, Last_Name__c, Salutation__c, Email__c, Phone__c, Birthdate__c, Fleetcor_Contact__c, ' +
                        'isPrimary__c, Role__c, Index__c FROM E2E_Data_Contacts__r) ' +
                    'FROM E2E_Data_Object__c ' +
                    'WHERE E2E_Status__c = \'In progress\' AND E2E_Last_Activity__c <= LAST_N_DAYS:2';
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc, List<E2E_Data_Object__c> scope) {
        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        String linkToDataObject;
        Map<String, E2E_Data_Object__c> e2eDataToUpdate = new Map<String, E2E_Data_Object__c>();
        try {
            Map<String, E2E_Data_Object__c> e2eDataToDelete = new Map<String, E2E_Data_Object__c>();
            Map<String, List<E2E_Data_Log__c>> customerFeedbackMap = new Map<String, List<E2E_Data_Log__c>>();
            String finalExceptionMessages = null;
            for (E2E_Data_Object__c e2eData : scope) {
                if (System.now() > e2eData.E2E_Last_Activity__c.addMinutes(30)) {
                    if (e2eData.E2E_Data_Contacts__r.isEmpty()) {
                        e2eDataToDelete.put(e2eData.Id, e2eData);
                    } else {
                        e2eData.E2E_Status__c = 'Drop off';
                        e2eDataToUpdate.put(e2eData.Id, e2eData);
                    }
                    linkToDataObject = 'E2E Data Object: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + e2eData.Id + '" target="_blank">' + e2eData.Name + '</a>';
                    Integer errorCounter = 1;
                    String dataObjectExceptions = null;
                    for (E2E_Data_Log__c dataLog : e2eData.E2E_Data_Logs__r) {
                        if (dataLog.RecordType.Name == 'Customer Feedback') {
                            if (! customerFeedbackMap.containsKey(e2eData.Id)) {
                                customerFeedbackMap.put(e2eData.Id, new List<E2E_Data_Log__c>());
                            }
                            customerFeedbackMap.get(e2eData.Id).add(dataLog);
                        } else if (dataLog.Exception_Type__c == 'System Error' ||
                                ((dataLog.Exception_Type__c == 'CF System Error' || dataLog.Exception_Type__c == 'Company search') &&
                                        dataLog.Exception_Description__c != 'Company is not in the list' &&
                                        dataLog.Exception_Description__c != 'Report does not exist')) {
                            String msg = '<b>' + errorCounter + '</b>)' + ' Error message: ' + dataLog.Exception_Description__c;
                            if (dataObjectExceptions != null) {
                                dataObjectExceptions += ';' + '<br/>' + msg;
                            } else {
                                if (e2eDataToDelete.containsKey(e2eData.Id)) {
                                    dataObjectExceptions = linkToDataObject + ' (DELETED)<br/>' + msg;
                                } else {
                                    dataObjectExceptions = linkToDataObject + '<br/>' + msg;
                                }
                            }
                            dataObjectExceptions += '<hr>';
                            errorCounter++;
                        }
                    }
                    if (dataObjectExceptions != null) {
                        if (finalExceptionMessages != null) {
                            finalExceptionMessages += '\n' + '\n' + dataObjectExceptions;
                        } else {
                            finalExceptionMessages = dataObjectExceptions;
                        }
                    }
                }
            }
            if (! customerFeedbackMap.isEmpty()) {
                syncCustomerFeedbacks(customerFeedbackMap);
            }
            if ( !e2eDataToUpdate.isEmpty() ) {
                setDropOffStatus(e2eDataToUpdate);
            }
            if ( !e2eDataToDelete.isEmpty() ) {
                clearE2EData(e2eDataToDelete);
            }
            if (finalExceptionMessages != null) {
                if (org.IsSandbox == false) {
                    ExceptionLogger.sendException(finalExceptionMessages, '<b>E2E 2.0 process</b><hr>');
                }
            }
        } catch (Exception e) {
            if (org.IsSandbox == false) {
                if ( ! e2eDataToUpdate.isEmpty()) {
                    update e2eDataToUpdate.values();
                }
                ExceptionLogger.sendException(e.getMessage(), linkToDataObject + ' ' + e.getStackTraceString());
            }
        }
    }

    private void syncCustomerFeedbacks(Map<String, List<E2E_Data_Log__c>> customerFeedbackMap) {
        List<Opportunity> oppsList = [
                SELECT Id, E2E_Data_Object__c, (SELECT E2E_Data_Log__c FROM Customer_Feedbacks__r)
                FROM Opportunity
                WHERE E2E_Data_Object__c IN :customerFeedbackMap.keySet()
        ];
        Map<String, String> relatedDataObjectWithOppty = new Map<String, String>();
        Map<String, Customer_Feedback__c> dataLogFeedbackToOpptyFeedbacksMap = new Map<String, Customer_Feedback__c>();
        for (Opportunity opp : oppsList) {
            relatedDataObjectWithOppty.put(opp.E2E_Data_Object__c, opp.Id);
            for (Customer_Feedback__c customerFeedback : opp.Customer_Feedbacks__r) {
                dataLogFeedbackToOpptyFeedbacksMap.put(customerFeedback.E2E_Data_Log__c, customerFeedback);
            }
        }
        List<Customer_Feedback__c> customerFeedbacksToInsert = new List<Customer_Feedback__c>();
        String recordTypeId = Schema.SObjectType.Customer_Feedback__c.getRecordTypeInfosByName().get('E2E Feedback').getRecordTypeId();
        for (String dataObjectId : customerFeedbackMap.keySet()) {
            for (E2E_Data_Log__c dataLog : customerFeedbackMap.get(dataObjectId)) {
                if (! relatedDataObjectWithOppty.containsKey(dataObjectId)) {
                    customerFeedbacksToInsert.add(
                            new Customer_Feedback__c(
                                    RecordTypeId = recordTypeId,
                                    E2E_Data_Log__c = dataLog.Id,
                                    E2E_Step__c = dataLog.E2E_Step__c,
                                    Form_Identification__c = dataLog.Form_Identification__c,
                                    Rating__c = dataLog.Rating__c,
                                    Feedback_Local__c = dataLog.Feedback_Local__c,
                                    Feedback_English__c = dataLog.Feedback_English__c
                            )
                    );
                } else {
                    if (!dataLogFeedbackToOpptyFeedbacksMap.containsKey(dataLog.Id)) {
                        customerFeedbacksToInsert.add(
                                new Customer_Feedback__c(
                                    RecordTypeId = recordTypeId,
                                    E2E_Data_Log__c = dataLog.Id,
                                    Opportunity__c = relatedDataObjectWithOppty.get(dataObjectId),
                                    E2E_Step__c = dataLog.E2E_Step__c,
                                    Form_Identification__c = dataLog.Form_Identification__c,
                                    Rating__c = dataLog.Rating__c,
                                    Feedback_Local__c = dataLog.Feedback_Local__c,
                                    Feedback_English__c = dataLog.Feedback_English__c
                                )
                        );
                    }
                }
            }
        }
        insert customerFeedbacksToInsert;
    }

    private void setDropOffStatus(Map<String, E2E_Data_Object__c> e2eDataToUpdate) {
        List<Opportunity> oppsToUpdate = [
                SELECT  Name, E2E_CF_Reports_Counter__c, AccountId, AGB_Datenschutzhinweise_Richtigkeit__c, Agree_To_Deposit_Agreement__c,
                        CF_Credit_Limit__c, Zahlungsart__c, Rechnungsperiode__c, Zahlungsziel_Credit__c, Max_Credit_Limit__c, E2E_2__c,
                        E2E_Step__c, E2E_Data_Object__c, Security_Amount_To_Pay__c, Security_To_Pay__c, CF_Search_Parameters__c, Credit_Stage__c,
                        Einwilligung_Lastschriftverfahren__c, ESI__c, LeadSource, Retailer_OBN__c, E2E_System_Error_Description__c, E2E_Errors__c,
                        Registered_Country__c, Direct_Debit_Mandate_Type__c, Credit_System_Rating__c, Bank_Account_Prefix__c, Bank_Account_Number__c, Bank_Code__c, Bank_Name__c, Bank_Country__c,
                (SELECT Id, OpportunityId, ContactId FROM OpportunityContactRoles  WHERE ContactId != NULL)
                FROM    Opportunity
                WHERE   E2E_Data_Object__c IN : e2eDataToUpdate.keySet()
        ];
        Map<String, Opportunity> opptiesByDataObjectIdMap = new Map<String, Opportunity>();
        Map<String, Account> accountsByDataObjectIdMap = new Map<String, Account>();
        for (Opportunity opp : oppsToUpdate) {
            E2E_Data_Object__c dataObject = e2eDataToUpdate.get(opp.E2E_Data_Object__c);
            String country = ETEGlobalUtils.returnCountry(dataObject.Country_Code__c);
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);
            if (settings != null && settings.Abandonment_User__c != null) {
                opp.OwnerId = settings.Abandonment_User__c;
            }
            opp.E2E_Status__c = 'Drop off';
            opptiesByDataObjectIdMap.put(dataObject.Id, opp);
        }
        Map<String, Map<String, OpportunityContactRole>> opptyContactRolesByContactIdMap = new Map<String, Map<String, OpportunityContactRole>>();
        Map<String, Map<String, E2E_Data_Contact__c>> eteContactsMap = new Map<String, Map<String, E2E_Data_Contact__c>>();
        Map<String, Map<String, Contact>> sfContactsToSync = new Map<String, Map<String, Contact>>();
        Map<String, Map<String, OpportunityContactRole>> opptyContactRolesToSync = new Map<String, Map<String, OpportunityContactRole>>();
        for (String dataObjectId : e2eDataToUpdate.keySet()) {
            E2E_Data_Object__c dataObject = e2eDataToUpdate.get(dataObjectId);
            String implKey = Schema.getGlobalDescribe().get('E2E_Data_Object__c').getDescribe().getRecordTypeInfosById().get(dataObject.RecordTypeId).getName();
            ETEJobExecutor jobExecutor = ETEGlobalUtils.getJobExecutor(new List<String>(), dataObjectId, dataObject.Country_Code__c, implKey);
            Opportunity opportunity = opptiesByDataObjectIdMap.get(dataObjectId);
            opportunity = jobExecutor.mapOpportunityFieldsWithDataObjectFields(opportunity, dataObject);
            opportunity = jobExecutor.setExceptionParams(opportunity, dataObject, dataObject.E2E_Data_Logs__r);
            ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(implKey);
            String country = ETEGlobalUtils.returnCountry(dataObject.Country_Code__c);
            if (opportunity.AccountId == null) {
                Account acc = businessObjectsHandler.initAccount(country, dataObject);
                accountsByDataObjectIdMap.put(dataObject.Id, acc);
            }
            for (OpportunityContactRole ocr : opportunity.OpportunityContactRoles) {
                if (! opptyContactRolesByContactIdMap.containsKey(dataObject.Id)) {
                    opptyContactRolesByContactIdMap.put(dataObject.Id, new Map<String, OpportunityContactRole>());
                }
                opptyContactRolesByContactIdMap.get(dataObject.Id).put(ocr.ContactId, ocr);
            }
            for (E2E_Data_Contact__c dataContact : dataObject.E2E_Data_Contacts__r) {
                if (! opptyContactRolesByContactIdMap.containsKey(dataObject.Id) ||
                    ! opptyContactRolesByContactIdMap.get(dataObject.Id).containsKey(dataContact.Fleetcor_Contact__c)) {
                    Contact contact = businessObjectsHandler.initContact();
                    OpportunityContactRole ocr = businessObjectsHandler.initOpportunityContactRole();
                    if (! sfContactsToSync.containsKey(dataObject.Id)) {
                        eteContactsMap.put(dataObject.Id, new Map<String, E2E_Data_Contact__c>());
                        sfContactsToSync.put(dataObject.Id, new Map<String, Contact>());
                        opptyContactRolesToSync.put(dataObject.Id, new Map<String, OpportunityContactRole>());
                    }
                    eteContactsMap.get(dataObject.Id).put(dataContact.Id, dataContact);
                    sfContactsToSync.get(dataObject.Id).put(dataContact.Id, contact);
                    opptyContactRolesToSync.get(dataObject.Id).put(dataContact.Id, ocr);
                }
            }
            if (! sfContactsToSync.isEmpty()) {
                jobExecutor.mapSFcontactFieldsWithETEcontactFields(dataObject.E2E_Data_Contacts__r,
                                                                    sfContactsToSync.get(dataObject.Id),
                                                                    opptyContactRolesToSync.get(dataObject.Id));
            }
        }
        if (! accountsByDataObjectIdMap.isEmpty()) {
            insert accountsByDataObjectIdMap.values();
            for (String dataObjectId : accountsByDataObjectIdMap.keySet()) {
                opptiesByDataObjectIdMap.get(dataObjectId).AccountId = accountsByDataObjectIdMap.get(dataObjectId).Id;
                if (sfContactsToSync.containsKey(dataObjectId)) {
                    for (Contact con : sfContactsToSync.get(dataObjectId).values()) {
                        con.AccountId = accountsByDataObjectIdMap.get(dataObjectId).Id;
                    }
                }
            }
        }
        if (! sfContactsToSync.isEmpty()) {
            List<Contact> contactsToInsertList = new List<Contact>();
            for (String dataObjectId : sfContactsToSync.keySet()) {
                contactsToInsertList.addAll(sfContactsToSync.get(dataObjectId).values());
            }
            insert contactsToInsertList;
            List<OpportunityContactRole> contactRolesToInsertList = new List<OpportunityContactRole>();
            List<E2E_Data_Contact__c> eteDataContactsToUpdate = new List<E2E_Data_Contact__c>();
            for (String dataObjectId : opptyContactRolesToSync.keySet()) {
                for (String dataContactId : opptyContactRolesToSync.get(dataObjectId).keySet()) {
                    opptyContactRolesToSync.get(dataObjectId).get(dataContactId).ContactId = sfContactsToSync.get(dataObjectId).get(dataContactId).Id;
                    opptyContactRolesToSync.get(dataObjectId).get(dataContactId).OpportunityId = opptiesByDataObjectIdMap.get(dataObjectId).Id;
                    contactRolesToInsertList.add(opptyContactRolesToSync.get(dataObjectId).get(dataContactId));

                    E2E_Data_Contact__c dataContact = eteContactsMap.get(dataObjectId).get(dataContactId);
                    dataContact.Fleetcor_Contact__c = sfContactsToSync.get(dataObjectId).get(dataContactId).Id;
                    eteDataContactsToUpdate.add(dataContact);
                }
            }
            insert contactRolesToInsertList;
            update eteDataContactsToUpdate;
        }
        update e2eDataToUpdate.values();
        update opptiesByDataObjectIdMap.values();
    }


    private void clearE2EData(Map<String, E2E_Data_Object__c> e2eDataToDelete) {
        Map<String, Opportunity> oppsToDelete = new Map<String, Opportunity>([
                SELECT  Id
                FROM    Opportunity
                WHERE   E2E_Data_Object__c IN : e2eDataToDelete.keySet()
        ]);

        Map<String, OpportunityLineItem> oppLineItemsToDelete = new Map<String, OpportunityLineItem>([
                SELECT  Id
                FROM    OpportunityLineItem
                WHERE   OpportunityId IN : oppsToDelete.keySet()
        ]);

        List<Offer_Item__c> offerItemListToDelete = [
                SELECT  Id
                FROM    Offer_Item__c
                WHERE   Opportunity_Product_Id__c IN : oppLineItemsToDelete.keySet()
        ];

        List<E2E_Data_Log__c> dataLogListToDelete = [
                SELECT  Id
                FROM    E2E_Data_Log__c
                WHERE   E2E_Data_Object__c IN : e2eDataToDelete.keySet()
        ];

        List<E2E_Data_Offer_Item__c> dataOfferItemListToDelete = [
                SELECT  Id
                FROM    E2E_Data_Offer_Item__c
                WHERE   E2E_Data_Object__c IN : e2eDataToDelete.keySet()
        ];

        List<Sobject> objectsToDeleteList = new List<Sobject>();
        objectsToDeleteList.addAll(offerItemListToDelete);
        objectsToDeleteList.addAll(oppLineItemsToDelete.values());
        objectsToDeleteList.addAll(oppsToDelete.values());
        objectsToDeleteList.addAll(dataLogListToDelete);
        objectsToDeleteList.addAll(dataOfferItemListToDelete);
        objectsToDeleteList.addAll(e2eDataToDelete.values());
        delete objectsToDeleteList;
    }

    global void finish(Database.BatchableContext bc) {}
}