global class CallLogRuBatch implements Database.Batchable<CallLogRu.Log>, Database.Stateful, Database.AllowsCallouts{

    private CallLogRu callLogRu;
    private Map<Id, Lead> leadsForUpdate;
    private Map<Id, Opportunity> oppsForUpdate;
    private Map<Id, Contact> contactsForUpdate;
    global Map<Id, sobject> sObjListWithFinishedCallCases;

    global CallLogRuBatch(Object log){
        callLogRu = (CallLogRu)log;
        leadsForUpdate = new Map<Id, Lead>();
        oppsForUpdate = new Map<Id, Opportunity>();
        contactsForUpdate = new Map<Id, Contact>();
        sObjListWithFinishedCallCases = new Map<Id, sObject> ();
    }

    global Iterable<CallLogRu.Log> start(Database.BatchableContext context){
        List<CallLogRu.Log> finalList = new List<CallLogRu.Log>();
        finalList.addAll(callLogRu.logs);
        finalList.sort(); // sort logs by statusDate asc
        return finalList;
    }

    global void execute(Database.BatchableContext context, List<Object> scope){
        try {
            List<CallLogRu.Log> logs = (List<CallLogRu.Log>)scope;
            Set<Id> leadsIds = new Set<Id>();
            Set<Id> accIds = new Set<Id>();
            Set<Id> oppIds = new Set<Id>();
            for (CallLogRu.Log log : logs) {
                if(log.recordId != null && log.recordId != ''){
                    if (log.recordId.startsWith('00Q')) {
                        leadsIds.add(log.recordId);
                    } else if (log.recordId.startsWith('006')) {
                        oppIds.add(log.recordId);
                    }
                }
            }

            Map<Id, Opportunity>  opportunities = new Map<Id, Opportunity> (
                [SELECT Id, AccountId, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Naumen_Case_Status__c 
                FROM Opportunity WHERE Id in : oppIds]
            );
            if (!opportunities.isEmpty()) {
                for(Opportunity opp : opportunities.values()){
                    accIds.add(opp.AccountId);
                }
            }

            List<String> leadFields = new List<String>();
            for (String phoneField : GlobalUtils.getFieldSetMembersAPIs(Schema.Lead.sObjectType, 'All_Phone_Fields')) {
                leadFields.add(phoneField);
                if (phoneField != 'Additional_Phones__c') {
                    leadFields.add(PhoneNumbersHandler.getPhoneStatusField(phoneField));
                    leadFields.add(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField));
                    leadFields.add(PhoneNumbersHandler.getPhoneRatingField(phoneField));
                }
            }
            leadFields.add('Lead.Irrelevant_Phones__c');
            leadFields.add('Lead.Irrelevant_Phones_ModifiedDate__c');
            leadFields.add('Naumen_Autocall_Project_UUID__c');
            leadFields.add('Naumen_Autocall_Case_UUID__c');
            leadFields.add('Naumen_Case_Status__c');
            String queryLeads = 'SELECT ' + String.join(leadFields, ',') + ' FROM Lead WHERE Id in :leadsIds';
            Map<Id, sObject> leads = new Map<Id, SObject>(Database.query(queryLeads));

            List<String> contactFields = new List<String>();
            for (String phoneField : GlobalUtils.getFieldSetMembersAPIs(Schema.Contact.sObjectType, 'All_Phone_Fields')) {
                contactFields.add('Contact.' + phoneField);
                if (phoneField != 'Additional_Phones__c') {
                    contactFields.add('Contact.' + PhoneNumbersHandler.getPhoneStatusField(phoneField));
                    contactFields.add('Contact.' + PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField));
                    contactFields.add('Contact.' + PhoneNumbersHandler.getPhoneRatingField(phoneField));
                }
            }
            contactFields.add('Contact.Irrelevant_Phones__c');
            contactFields.add('Contact.Irrelevant_Phones_ModifiedDate__c');

            Map<Id, List<Contact>> resultList = new Map<Id,List<Contact>>();
            String queryAccountContacts = 'SELECT Id, (SELECT Id,' + String.join(contactFields, ',') + ' FROM Contacts) FROM Account WHERE Account.Id in :accIds';
            Map<Id, Account> accountsContacts = new Map<Id, Account>((List<Account>)Database.query(queryAccountContacts));
            if (!opportunities.isEmpty()) {
                for(Opportunity opp : opportunities.values()){
                    if(resultList.get(opp.Id) == null){
                        List<Contact> contacts = accountsContacts.get(opp.AccountId).Contacts;
                        resultList.put(opp.Id, contacts);
                    } else {
                        List<Contact> contacts = resultList.get(opp.Id);
                        contacts.addAll(accountsContacts.get(opp.AccountId).Contacts);
                        resultList.put(opp.Id, contacts);
                    }
                }
            }

            for (CallLogRu.Log log : logs) {
                if(log.recordId != null && log.recordId != ''){
                    if (log.statusValue == 'connected') continue; // don't process connected with operator calls: they are being processed in softphone while saving record
                    if(getValidPhoneStatus(log.statusValue) != null){
                        if (log.recordId.startsWith('00Q')) {
                            if(leads.containsKey(log.recordId)){
                                prepareRecordsForUpdate(leads.get(log.recordId), log);
                            }
                        } else if (log.recordId.startsWith('006')) {
                            prepareRecordsForUpdate(opportunities.get(log.recordId), log);
                            if(resultList.containsKey(log.recordId)){
                                for (Contact contact : resultList.get(log.recordId)) {
                                    prepareRecordsForUpdate(contact, log);
                                }
                            }
                        }
                    }
                }
            }
            if(leadsForUpdate.size() != 0) {
                update leadsForUpdate.values();
            }
            if(oppsForUpdate.size() != 0) {
                update oppsForUpdate.values();
            }
            if(contactsForUpdate.size() != 0) {
                update contactsForUpdate.values();
            }
        } catch (Exception e){
            String errMsg = 'PhoneLogServiceBatch Exception ' + String.valueOf(e.getMessage()) + ' ||| Stack Trace: ' +  String.valueOf(e.getStackTraceString()) + '||| JSON=' + JSON.serialize(callLogRu);
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
        }
    }

    private void prepareRecordsForUpdate(SObject record, CallLogRu.Log log){
        String statusValue = getValidPhoneStatus(log.statusValue);
        //String caseStatusValue = getValidCaseStatus(log.caseStatus);
        Datetime statusDate = getValidDate(log.statusDate, log.statusDateTimeZone);
        Boolean isFinished = isStatusFinished(log.caseStatus, log.finisheddateFormatted, log.authortitle);
// ------ prepare lead ---------------------------------
        if(record.getSObjectType() == Schema.Lead.sObjectType) {
            for (String phoneField : GlobalUtils.getFieldSetMembersAPIs(Schema.Lead.SObjectType, 'All_Phone_Fields')) {
                Lead lead;
                if(leadsForUpdate.containsKey(String.valueOf(record.get('Id')))) {
                    lead = leadsForUpdate.get(String.valueOf(record.get('Id')));
                } else {
                    lead = new Lead(Id = String.valueOf(record.get('Id')));
                }
                if (isFinished) {
                    String naumenCaseStatus = record.get('Naumen_Case_Status__c') == null ? null : String.valueOf(record.get('Naumen_Case_Status__c'));
                    if (naumenCaseStatus != 'Finished') {
                        // update naumen case status in sf
                        lead.put('Naumen_Case_Status__c', 'Finished');
                        lead.put('Naumen_Case_Status_ModifiedTime__c', log.finisheddateFormatted);
                        leadsForUpdate.put(lead.Id, lead);
                        // set naumen case as finished in Naumen
                        String projectUUID = record.get('Naumen_Autocall_Project_UUID__c') == null ? null : String.valueOf(record.get('Naumen_Autocall_Project_UUID__c'));
                        String caseUUID = record.get('Naumen_Autocall_Case_UUID__c') == null ? null : String.valueOf(record.get('Naumen_Autocall_Case_UUID__c'));
                        lead.put('Naumen_Autocall_Project_UUID__c', projectUUID);
                        lead.put('Naumen_Autocall_Case_UUID__c', caseUUID);
                        sObjListWithFinishedCallCases.put(lead.Id, lead);
                    }
                }
                if (phoneField != 'Additional_Phones__c') {
                // phone fields 
                    if (ArePhonesIdentical(String.valueOf(record.get(phoneField)), log.phoneNumber)){
                        if (record.get(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField)) == null ||
                                getValidDate(String.valueOf(record.get(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField))), log.statusDateTimeZone) < statusDate) {
                            // set phone status   
                            lead.put(PhoneNumbersHandler.getPhoneStatusField(phoneField), statusValue);
                            lead.put(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField), statusDate);
                            // *phone rating for phone fields is set in trigger
                            leadsForUpdate.put(String.valueOf(lead.get('Id')), lead);
                        }
                    }
                } else {
                // additional phones
                    Boolean additionalPhonesChanged = checkAdditionalFieldsAndUpdate(record, lead, log.phoneNumber, statusValue, statusDate);
                    if (additionalPhonesChanged) leadsForUpdate.put(String.valueOf(lead.get('Id')), lead);
                }
            }
        }
    // ------ prepare opportunity ---------------------------------
        else if( record.getSObjectType() == Schema.Opportunity.sObjectType) {
            if (isFinished) {
                Opportunity opp;
                if(oppsForUpdate.containsKey(String.valueOf(record.get('Id')))) {
                    opp = oppsForUpdate.get(String.valueOf(record.get('Id')));
                } else {
                    opp = new Opportunity(Id = String.valueOf(record.get('Id')));
                }
                String naumenCaseStatus = record.get('Naumen_Case_Status__c') == null ? null : String.valueOf(record.get('Naumen_Case_Status__c'));
                if (naumenCaseStatus != 'Finished') {
                    // update naumen case status in sf
                    opp.put('Naumen_Case_Status__c', 'Finished');
                    opp.put('Naumen_Case_Status_ModifiedTime__c', log.finisheddateFormatted);
                    oppsForUpdate.put(opp.Id, opp);
                    // set naumen case as finished in Naumen
                    String projectUUID = record.get('Naumen_Autocall_Project_UUID__c') == null ? null : String.valueOf(record.get('Naumen_Autocall_Project_UUID__c'));
                    String caseUUID = record.get('Naumen_Autocall_Case_UUID__c') == null ? null : String.valueOf(record.get('Naumen_Autocall_Case_UUID__c'));                  
                    opp.put('Naumen_Autocall_Project_UUID__c', projectUUID);
                    opp.put('Naumen_Autocall_Case_UUID__c', caseUUID);
                    sObjListWithFinishedCallCases.put(opp.Id, opp);
                }
            }
        }
    // ------ prepare contact ---------------------------------
        else if( record.getSObjectType() == Schema.Contact.sObjectType) {
            for (String phoneField : GlobalUtils.getFieldSetMembersAPIs(Schema.Contact.SObjectType, 'All_Phone_Fields')) {
                
                Contact contact;
                if(contactsForUpdate.containsKey(String.valueOf(record.get('Id')))){
                    contact = contactsForUpdate.get(String.valueOf(record.get('Id')));
                } else {
                    contact = new Contact(Id = String.valueOf(record.get('Id')));
                }
                if (phoneField != 'Additional_Phones__c') {
                // phone fields 
                    if(ArePhonesIdentical(String.valueOf(record.get(phoneField)), log.phoneNumber)){
                        if(record.get(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField)) == null ||
                                getValidDate(String.valueOf(record.get(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField))), log.statusDateTimeZone) < statusDate){
                            // set phone status        
                            contact.put(PhoneNumbersHandler.getPhoneStatusField(phoneField), statusValue);
                            contact.put(PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneField), statusDate);
                            // *phone rating for phone fields is set in trigger
                            contactsForUpdate.put(String.valueOf(contact.get('Id')), contact);
                        }
                    }
                } else {
                // additional phones
                    Boolean additionalPhonesChanged = checkAdditionalFieldsAndUpdate(record, contact, log.phoneNumber, statusValue, statusDate);
                    if (additionalPhonesChanged) contactsForUpdate.put(String.valueOf(contact.get('Id')), contact);
                }
            }
        }
    }

    public static Boolean checkAdditionalFieldsAndUpdate (sObject record, sObject recordToUpdate, String phoneNumber, String statusValue, DateTime statusDate){   
        Map <String, String> additionalPhonesMap = PhoneNumbersHandler.getAdditionalPhonesMap (record);
        Boolean additionalPhonesChanged = false;
        DateTime gmtStatusDate = statusDate == null ? null : DateTime.newInstanceGMT(statusDate.dateGmt(), statusDate.timeGmt());
        if (!additionalPhonesMap.isEmpty()) {
            for (String additionalPhoneNumber : additionalPhonesMap.keySet()) {
                if (ArePhonesIdentical(additionalPhoneNumber, phoneNumber)) {
                    String additionalItem = additionalPhonesMap.get(additionalPhoneNumber);
                    DateTime additionalPhoneModifiedDate = PhoneNumbersHandler.additionaPhonelItem_getModifiedDate_DateTime (additionalItem);
                    if(additionalPhoneModifiedDate == null ||
                    additionalPhoneModifiedDate < gmtStatusDate){
                        String currentAdditionalPhoneItem = additionalPhonesMap.get(additionalPhoneNumber);
                        Double currentRatingVal = PhoneNumbersHandler.additionalPhonelItem_getRating_Number (currentAdditionalPhoneItem);
                        Double newRatingVal = PhoneNumbersHandler.getNewPhoneRatingVal (currentRatingVal, statusValue);
                        String newRatingStringVal = PhoneNumbersHandler.rating_formatToString (newRatingVal);
                        String phoneModifiedDate = PhoneNumbersHandler.getModifiedDate_Formatted (gmtStatusDate);
                        String newAdditionalPhoneItem = PhoneNumbersHandler.createAdditionalPhoneItemString (additionalPhoneNumber, statusValue, newRatingStringVal, phoneModifiedDate);
                        additionalPhonesMap.put(additionalPhoneNumber, newAdditionalPhoneItem);
                        additionalPhonesChanged = true;
                    }
                }
            }
            if (additionalPhonesChanged) {
                // put new additional phones string to the object which will be updated
                String newAdditionalPhonesStr = PhoneNumbersHandler.createAdditionalPhoneString (additionalPhonesMap.values());
                recordToUpdate.put('Additional_Phones__c', newAdditionalPhonesStr == '' ? null : newAdditionalPhonesStr);
            }
        }
        return additionalPhonesChanged;
    }
    public static DateTime getValidDate(String statusDate, String statusDateTimeZone){
        if(statusDate != null) {
            Integer year = Integer.valueOf(statusDate.substring(0, 4));
            Integer month = Integer.valueOf(statusDate.substring(5, 7));
            Integer day = Integer.valueOf(statusDate.substring(8, 10));
            Integer hour = Integer.valueOf(statusDate.substring(11, 13));
            Integer minute = Integer.valueOf(statusDate.substring(14, 16));
            Integer second = Integer.valueOf(statusDate.substring(17, 19));

            DateTime result = Datetime.newInstanceGMT(Date.newInstance(year, month, day), Time.newInstance(hour, minute, second, 0));
            result = result.addHours( - GlobalUtils.blankIntegerIfNull(statusDateTimeZone));
            return result;
        } else {
            return Datetime.newInstance(2000,01,01,0,0,0);
        }
    }

    private static String getValidPhoneStatus(String statusValue){
        return phoneStatusValueMapping.get(statusValue);
    }

    private static Map<String, String> phoneStatusValueMapping = new Map<String, String>{
            'busy' => 'Dial out', //Занято
            'no_answer' => 'Dial out', //Нет ответа
            'rejected' => 'Dial out', //Отклонен
            'operator_busy' => 'Successful dialing', //Оператор занят
            'operator_no_answer' => 'Successful dialing', //Оператор не принял вызов
            'operator_rejected' => 'Successful dialing', //Оператор отклонил вызов
            'not_found' => 'CTI Wrong number:0', //Несуществующий номер
            'UNKNOWN_ERROR' => 'CTI System Error', //Ошибка. Неизвестный код отбоя
            'SYSTEM_ERROR' => 'CTI System Error', //Системная ошибка
            'abandoned' => 'Successful dialing', //Потерян. Потерянный вызов
            'amd' => 'Dial out', //Вызов завершен при обнаружении автоответчика
            'connected' => 'Successful dialing', //Соединен
            'message_not_played' => 'Successful dialing', //Сообщение проиграно не полностью
            'CRR_DISCONNECT' => 'CTI System Error', //Обрыв связи
            'CRR_INVALID' => 'CTI Wrong number:0', //Неправильный номер
            'CRR_UNAVAILABLE' => 'Dial out', //Не берёт трубку
            'NEED_TO_BLOCK_CLIENT' => 'Successful dialing', //Отложен
            'NEED_TO_WAIT' => null, //Повторный вызов
            'Отсутствует' => 'CTI System Error' //Не указан
    };


    /* we only need to know when case is finished
    private static String getValidCaseStatus(String statusValue){
        return caseStatusValueMapping.get(statusValue);
    }
    private static Map<String, String> caseStatusValueMapping = new Map<String, String>{     
            'Выполнено/реализовано'  => 'Closed – Available',
            'Отказ' => 'Closed – Unavailable',
            'Успешный дозвон' => 'Closed – Available',
            'Отложенное' => 'Open - AutoCall',
            'Выполнено' => 'Closed – Available',
            'Недозвон' => 'Closed – Unavailable',
            'Новое' => 'Open - AutoCall'
    };
    */
    private static Boolean isStatusFinished (String statusValue, DateTime finishedDateTime, String authortitle) {
        Boolean finishedByNaumen = finishedDateTime != null && authortitle == 'system';
        Set <String> finishedStatuses = new Set <String> {'Недозвон', 'Успешный дозвон'};
        return finishedByNaumen && finishedStatuses.contains(statusValue);
    }

    public static boolean ArePhonesIdentical(String phoneOne, String phoneTwo){
        if(phoneOne == null || phoneTwo == null){
            return false;
        }

        if(phoneOne.startsWith('8')){
            phoneOne = '+7' + phoneOne.removeStart('8');
        } else if(phoneOne.startsWith('7')){
            phoneOne = '+' + phoneOne;
        }
        if (phoneTwo.startsWith('8')){
            phoneTwo = '+7' + phoneTwo.removeStart('8');
        } else if(phoneTwo.startsWith('7')){
            phoneTwo = '+' + phoneTwo;
        }

        if(phoneOne == phoneTwo){
            return true;
        } else {
            return false;
        }
    }

    global void finish(Database.BatchableContext context){
        system.debug('>> CallLogRuBatch >> finish ');
        if(sObjListWithFinishedCallCases.size() != 0) {
            system.debug('send records to Naumen : ' + sObjListWithFinishedCallCases.size());
            if (!Test.isRunningTest()) Naumen_Callouts.sendrequest_updateCasesList_setFinished_Successful(sObjListWithFinishedCallCases.values());
        }
    }

}