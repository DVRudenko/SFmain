public with sharing class CTI_callInfoPanelController {

    public List<Account> accounts {get; private set;}
    public List<Contact> contacts {get; private set;}
    public List<AccountContactRelation> relations {get; private set;}

    public String phone {get; set;}
    public String callid {get; set;}
    public Id AccountId {get; set;}
    public String ContactId {get; set;}



    public CTI_callInfoPanelController(){
        phone = ApexPages.currentPage().getParameters().get('phone');
        System.debug('phone = ' + phone);

        callid = ApexPages.currentPage().getParameters().get('callid');
        System.debug('callid = ' + callid);

        Map<String, List<SObject>> result = searchAccountAndContacts(phone);
        
        this.accounts = result.get('Account');
        this.contacts = result.get('Contact');
        this.relations = result.get('AccountContactRelation');

    }


    
    @AuraEnabled 
    public static User fetchUser() {
        User u = [Select Id, Name FROM User WHERE id =: UserInfo.getUserId()];
        return u;
    }


    @AuraEnabled 
    public static Map<String, String> getAgentSetup() {
        OSCallCenter_URL__c CC_URL = OSCallCenter_URL__c.getValues('Backoffice');
        List<OSAgentMapping__c> mapping = [SELECT Agent_ID__c, Agent_Extension__c, Show_Debug_Log__c, Save_Debug_Log__c FROM OSAgentMapping__c WHERE Name =: UserInfo.getUserName()];
    
        Map<String, String> setup = new Map<String, String>();
            
        setup.put('Username', UserInfo.getUserName());
        
        if(CC_URL != null)
        {
            setup.put('URL', CC_URL.URL__c);
        }

        if(mapping != null && mapping.size() > 0)
        {
            setup.put('AgentId', mapping[0].Agent_ID__c);
            setup.put('Extension', mapping[0].Agent_Extension__c);
        }

        setup.put('ShowLogs', String.valueOf(mapping[0].Show_Debug_Log__c));
        setup.put('SaveLogs', String.valueOf(mapping[0].Save_Debug_Log__c));

        return setup;
    }

    @RemoteAction
    @AuraEnabled
    public static Id createNewTask(String phoneNumber, String callID, Id AccountId, Id ContactId){
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();

        List<Task> t = [SELECT Id, Phone__c, CallID__c, Account__c, WhoId FROM Task WHERE CallID__c =: callID];
        System.Debug('createNewTask found Tasks: '+t);
        
        Task newTask;
        if( t.size() == 0 ){
            newTask = new Task(
            RecordTypeId = taskRecordTypeId,
            Type = 'Call',
            Status = 'In Progress',
            Priority = 'Normal',
            Phone__c = phoneNumber,
            CallID__c = callID,
            Account__c = AccountId,
            WhoId = ContactId,
            ActivityDate = Date.today(),
            CallDurationInSeconds = getCallDuration(callID)
            );
            insert newTask;
        }else{
            newTask = t.get(0);
        }

        return newTask.Id;

    }


    @AuraEnabled
    public static Id createC2DTask(String phone, String callId, String objectType, Id recordId){
        System.Debug('createC2DTask: '+phone+' '+callId+' '+objectType+' '+recordId);
        Map<String, List<SObject>> records = getRelatedAccountsAndContacts(objectType, recordId);
        List<SObject> accl = records.get('Account');
        List<SObject> conl = records.get('Contact');

        Id AccountId = null;
        if(accl != null && accl.size()>0){
            AccountId = accl.get(0).Id;
        }

        Id ContactId = null;
        if(conl != null && conl.size()>0){
            ContactId = conl.get(0).Id;
        }

        System.debug('AccountId: '+AccountId);
        System.debug('ContactId: '+ContactId);


        return createNewTask(phone, callId, AccountId, ContactId);
    }


    @AuraEnabled
    public static Map<String, List<SObject>> searchAccountAndContacts(String phoneNumber){
        Map<String, String> localPhoneMap = detectCountryPhone(phoneNumber);
        String localPhone = localPhoneMap.get('LocalPhone');
        Map<String, List<SObject>> accountsAndContacts = getAccountsAndContacts(localPhone);
        List<Account> accs = accountsAndContacts.get('Account');
        List<Contact> cnts = accountsAndContacts.get('Contact');
        List<AccountContactRelation> rels = accountsAndContacts.get('AccountContactRelation');

        if(accs.isEmpty() && cnts.isEmpty()){
            List<Task> tasks = getTasksByPhone(localPhone);

            Set<Id> accIds = new Set<Id>();
            for(Task t : tasks){
                if(String.isNotBlank(t.Account__c)){
                    accIds.add(t.Account__c);
                }
            }

            accs = [
            SELECT  Id,
                    Name,
                    GFN_Customer_Status__c,
                    Subaccount__c,
                    GFN_Nr__c,
                    Phone
            FROM    Account
            WHERE   Id IN: accIds ];

        }

        Map<String, List<SObject>> result = new Map<String, List<SObject>>{
            'Account'=> accs,
            'Contact'=> cnts,
            'AccountContactRelation'=> rels
        };

        System.debug('Found objects:'+result);

        return result;

    }
    
    
    @AuraEnabled
    public static Map<String, List<SObject>> getAccountsAndContacts(String phoneNumber){
        Map<Id, Account> accountMap = new Map<Id, Account>([
                                                            SELECT  Id,
                                                                    Name,
                                                                    GFN_Customer_Status__c,
                                                                    Subaccount__c,
                                                                    GFN_Nr__c
                                                            FROM    Account
                                                            WHERE   Phone LIKE: ('%' + phoneNumber)
                                                            LIMIT 100 ]);

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                                                            SELECT  Id,
                                                                    Name,
                                                                    AccountId,
                                                                    Email,
                                                                    Phone,
                                                                    MobilePhone
                                                            FROM    Contact
                                                            WHERE   Phone LIKE: ('%' + phoneNumber)
                                                            OR MobilePhone LIKE: ('%' + phoneNumber)
                                                            LIMIT 100 ]);

        
        Set<Id> accIds = new Set<Id>();

        // Search through AccountContactRelation
        List<AccountContactRelation> rel = [Select id, AccountId, ContactId from AccountContactRelation where ContactId IN: contactMap.keyset()];
        for( AccountContactRelation r : rel )
        {
            accIds.add(r.AccountId);
        }

        accIds.addAll(accountMap.keySet());


        List<SObject> finalAccountList = [
            SELECT  Id,
                    Name,
                    GFN_Customer_Status__c,
                    Subaccount__c,
                    GFN_Nr__c,
                    Phone
            FROM    Account
            WHERE   Id IN: accIds
            LIMIT 200
        ];

        //System.debug('phoneNumber:' + phoneNumber);
        //System.debug('contl: ' + contactList);
        //System.debug('accl: ' + accountList);

        Map<String, List<SObject>> accountsAndContacts = new Map<String, List<SObject>>{
            'Account'=> finalAccountList,
            'Contact'=> contactMap.values(),
            'AccountContactRelation'=> rel
        };

        return accountsAndContacts;
    }


    public static Map<String,String> detectCountryPhone(String phoneNumber){
        Map<String, String> codes = new Map<String, String>{
            '49' => 'DE',
            '43' => 'AT',
            '48' => 'PL',
            '31' => 'NL',
            '32' => 'BE' ,
            '33' => 'FR',
            '36' => 'HU',
            '41' => 'CH',
            '352' => 'LU',
            '420' => 'CZ',
            '421' => 'SK'
        };

        phoneNumber = phoneNumber.replaceAll('\\D','');

        String country = 'UNDEF';
        String localPhone = phoneNumber;

        for(String code : codes.keySet()){
            if(phoneNumber.startsWithIgnoreCase(code)){
                country = codes.get(code);

                if(country == 'FR' || country == 'DE'){
                    localPhone = phoneNumber.removeStart(code).right(10);
                }else{
                    localPhone = phoneNumber.removeStart(code).right(9);
                }
            }    
        }
           
        return new Map<String,String> {'Country'=>country, 'LocalPhone'=>localPhone};
    }


    @AuraEnabled
    public static List<Task> getTasksByPhone(String phoneNumber){

        List<Task> taskList = [
            SELECT  Id,
                    WhoId,
                    Account__c,
                    Account__r.Name,
                    WhatId
            FROM    Task
            WHERE   Phone__c LIKE: ('%' + phoneNumber)
            AND     Account__c != NULL
            LIMIT 100
        ];

        return taskList;
    }


    @AuraEnabled
    public static Map<String, List<SObject>> getRelatedAccountsAndContacts(String objectType, String recordId){

        List<Account> accl;
        List<Contact> conl;

        if(objectType == 'Account'){
            accl = [ SELECT  Id,
                    Name,
                    GFN_Customer_Status__c,
                    Subaccount__c,
                    GFN_Nr__c
                    FROM    Account
                    WHERE   Id =: recordId ];

        }
        
        if(objectType == 'Contact'){
            conl = [ SELECT  Id,
                    Name,
                    AccountId,
                    Email,
                    Phone,
                    MobilePhone
                    FROM    Contact
                    WHERE   Id =: recordId ];

            if(conl.size()>0){
                accl = [ SELECT  Id,
                        Name,
                        GFN_Customer_Status__c,
                        Subaccount__c,
                        GFN_Nr__c
                        FROM    Account
                        WHERE   Id =: conl[0].AccountId ];
            }

        }
        
        if(objectType == 'AccountContactRelation'){
            AccountContactRelation rel = [ SELECT  Id,
                    AccountId,
                    ContactId
                    FROM    AccountContactRelation
                    WHERE   Id =: recordId ];

            conl = [ SELECT  Id,
                    Name,
                    AccountId,
                    Email,
                    Phone,
                    MobilePhone
                    FROM    Contact
                    WHERE   Id =: rel.ContactId ];

            accl = [ SELECT  Id,
                    Name,
                    GFN_Customer_Status__c,
                    Subaccount__c,
                    GFN_Nr__c
                    FROM    Account
                    WHERE   Id =: rel.AccountId ];

        }
        
        if(objectType == 'Task'){
            Task t = [ SELECT  Id,
                    Account__c,
                    WhoId
                    FROM    Task
                    WHERE   Id =: recordId ];

            conl = [ SELECT  Id,
                    Name,
                    AccountId,
                    Email,
                    Phone,
                    MobilePhone
                    FROM    Contact
                    WHERE   Id =: t.WhoId ];

            accl = [ SELECT  Id,
                    Name,
                    GFN_Customer_Status__c,
                    Subaccount__c,
                    GFN_Nr__c
                    FROM    Account
                    WHERE   Id =: t.Account__c ];

        }
        // Todo: Search for accountId for other objects
        Map<String, List<SObject>> accountsAndContacts = new Map<String, List<SObject>>{
            'Account'=> accl,
            'Contact'=> conl
        };

        return accountsAndContacts;
    }


    @AuraEnabled
    public static void saveEventData(Map<String, String> eventData) {
        List<Call_History_Item__c> historyItems = getCallHistoryItems(eventData.get('callId'));
        if(historyItems.size() == 0) {
            Call_History_Item__c historyItem = new Call_History_Item__c(
                Event_Type__c = eventData.get('eventType'),
                Name = eventData.get('callId'),
                Action__c = eventData.get('action'),
                Extension__c = eventData.get('extension'),
                Phone_Number__c = eventData.get('phoneNumber'),
                Start_Time__c = eventData.get('time'),
                State__c = eventData.get('state') == null ? 0 : Decimal.valueOf(eventData.get('state')),
                Status__c = eventData.get('status') == null ? 0 : Decimal.valueOf(eventData.get('status')),
                Call_Type__c = eventData.get('callType'),
                Account__c = eventData.get('accountId'),
                OwnerId = UserInfo.getUserId()
            );
            insert historyItem;
        }
    }

    @AuraEnabled
    public static void updateEventData(Map<String, String> eventData) {
        List<Call_History_Item__c> historyItems = getCallHistoryItems(eventData.get('callId'));
        if(historyItems.size() > 0) {
            Call_History_Item__c newHistoryItem = historyItems[0];
            if(newHistoryItem.Action__c != eventData.get('eventType')) {
                newHistoryItem.Event_Type__c = eventData.get('eventType');
                newHistoryItem.End_Time__c = eventData.get('endTime');
                newHistoryItem.Start_Time__c = String.isEmpty(eventData.get('startTime')) ? newHistoryItem.Start_Time__c : eventData.get('startTime');
                if(newHistoryItem.Action__c != 'established' && eventData.get('eventType') != 'established'){
                    newHistoryItem.Call_Type__c = 'Missed';
                }
                if(eventData.get('eventType') == 'callback') {
                    newHistoryItem.Call_Type__c = 'Call back';
                }
                newHistoryItem.Action__c = eventData.get('action');
                update newHistoryItem;
            }
        }
    }

    private static List<Call_History_Item__c> getCallHistoryItems(String callId) {
        List<Call_History_Item__c> historyItems = [
            SELECT  Name,
                    Event_Type__c,
                    Action__c,
                    Extension__c,
                    Phone_Number__c,
                    State__c,
                    Status__c,
                    Start_Time__c,
                    End_Time__c
            FROM    Call_History_Item__c
            WHERE   Name =: callId
        ];
        return historyItems;
    }

    @AuraEnabled
    public static List<CallHistoryWrapper> getCallHistory(){
        List<CallHistoryWrapper> callHistoryInfoList = new List<CallHistoryWrapper>();
        List<Call_History_Item__c> callHistoryItems = [
            SELECT  Name,
                    Start_Time__c,
                    End_Time__c,
                    Call_Type__c,
                    Phone_Number__c,
                    Action__c,
                    Account__c,
                    Account__r.Name,
                    Account__r.GFN_Nr__c
            FROM    Call_History_Item__c
            WHERE   CreatedDate = TODAY
            AND     OwnerId =: UserInfo.getUserId()
        ];
        for(Call_History_Item__c item : callHistoryItems) {
            callHistoryInfoList.add(new CallHistoryWrapper(item, item.Account__r));
        }
        return callHistoryInfoList;
    }

    @RemoteAction
    @AuraEnabled
    public static void linkHistoryItemToAccount(String accountId, String callId){
        List<Call_History_Item__c> historyItem = [
            SELECT  Name,
                    Account__c
            FROM    Call_History_Item__c
            WHERE   Name =: callId
        ];
        if(historyItem.size() == 1){
            historyItem[0].Account__c = accountId;
            update historyItem;
        }
    }

    @AuraEnabled
    public static void writeDebugLog(List<String> logsList){

       List<Unify_CC_LogStorage__b> logs = new List<Unify_CC_LogStorage__b>();
        Unify_CC_LogStorage__b log = new Unify_CC_LogStorage__b(
            Message__c = JSON.serialize(logsList),
            RecordDateTime__c = String.valueOf(System.now().getTime()) + '_' + ((Math.random() * 1000) + 1000).round(),
            Entity_Id__c = UserInfo.getUserId());

        logs.add(log);

        if (!Test.isRunningTest()){
            List<Database.SaveResult> srList = Database.insertImmediate(logs);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted log. ID: ' + sr.getId());
                }
                else {               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Log fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    
    }


    @AuraEnabled
    public static void saveCallDuration(String taskId, Map<String, String> eventData) {
        if(String.isNotEmpty(taskId)) {
            Task callTask = [
                SELECT  CallDurationInSeconds
                FROM    Task
                WHERE Id =: taskId
            ];
            List<Call_History_Item__c> historyItems = getCallHistoryItems(eventData.get('callId'));
            if(historyItems.size() > 0) {
                Call_History_Item__c newHistoryItem = historyItems[0];
                Long startTime = DateTime.valueOf(newHistoryItem.Start_Time__c.replace('T', ' ')).getTime();
                Long endTime = DateTime.valueOf(eventData.get('endTime').replace('T', ' ')).getTime();
                Long durationInSeconds = (endTime - startTime)/1000;
                callTask.CallDurationInSeconds = Integer.valueOf(durationInSeconds);
                update callTask;
            }
        }
    }


    private static Integer getCallDuration(String callId) {
        Integer duration;
        List<Call_History_Item__c> historyItems = getCallHistoryItems(callId);
        if(historyItems.size() > 0) {
            Call_History_Item__c newHistoryItem = historyItems[0];
            if(newHistoryItem.End_Time__c != null) {
                Long startTime = DateTime.valueOf(newHistoryItem.Start_Time__c.replace('T', ' ')).getTime();
                Long endTime = DateTime.valueOf(newHistoryItem.End_Time__c.replace('T', ' ')).getTime();
                Long durationInSeconds = (endTime - startTime)/1000;
                duration = Integer.valueOf(durationInSeconds);
            }
        }
        return duration;
    }



    public class CallHistoryWrapper {

        @AuraEnabled
        public Call_History_Item__c historyItem;

        @AuraEnabled
        public Account accountParams;
        
        public CallHistoryWrapper(Call_History_Item__c historyItem, Account accountParams){
            this.historyItem = historyItem;
            this.accountParams = accountParams;
        }
    }

}