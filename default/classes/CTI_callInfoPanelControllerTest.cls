@isTest
public class CTI_callInfoPanelControllerTest {

    @testSetup
    private static void createRecords(){
        Account acc = new Account(
            Name = 'test name',
            Phone = '+420123456789',
            BillingCountry = 'Czech Republic'
        );
        insert acc;

        Contact c = new Contact(
            Salutation = 'Mr',
            LastName = 'test',
            Phone = '+420123456789'
        );
        insert c;

        Task t = new Task(
            Account__c = acc.Id,
            Phone__c = '+420123456789',
            CallID__c = '1234'
        );
        insert t;
 
    }


    @isTest
    public static void testConstructor() {
        ApexPages.currentPage().getParameters().put('phone', '+420123456789');
        ApexPages.currentPage().getParameters().put('callid', '356873674563653');

        CTI_callInfoPanelController controller = new CTI_callInfoPanelController();
        System.assertEquals(1, controller.accounts.size());
        System.assertEquals(1, controller.contacts.size());
    }


    @isTest
    public static void testFetchUser() {
        User usr = CTI_callInfoPanelController.fetchUser();

        System.assert(String.isNotBlank(usr.Id));

    }


    @isTest
    public static void testGetAgentSetup(){
        OSAgentMapping__c mapping = new OSAgentMapping__c();
        mapping.Name = UserInfo.getUserName();
        mapping.Agent_ID__c = '777';
        mapping.Agent_Extension__c = '42000007777';
        mapping.Save_Debug_log__c = true;
        mapping.Show_Debug_log__c = true;
        insert mapping;
        
        Map<String, String> setup = CTI_callInfoPanelController.getAgentSetup();
        
        System.assertEquals(setup.get('AgentId'), '777');
        System.assertEquals(setup.get('Extension'),'42000007777');
        System.assertEquals(setup.get('ShowLogs'), 'true');
        System.assertEquals(setup.get('SaveLogs'), 'true');
    }



    @isTest
    public static void testCreateNewTask(){
        Account acc = [SELECT Id, Name, Phone FROM Account WHERE Phone = '+420123456789'];
        Contact ct = [SELECT Id, Name, Phone FROM Contact WHERE Phone = '+420123456789'];
        Id newTaskId = CTI_callInfoPanelController.createNewTask('+420123456789', '910111121314', acc.id, ct.id);
        System.assert(newTaskId!=null);
        Task newTask = [SELECT Type, Phone__c, CallID__c, Account__c, WhoId FROM Task WHERE Id =: newTaskId];
        System.assertEquals('Call', newTask.Type);
        System.assertEquals('+420123456789', newTask.Phone__c);
        System.assertEquals('910111121314', newTask.CallID__c);
        System.assertEquals(acc.id, newTask.Account__c);
        System.assertEquals(ct.id, newTask.WhoId);

        Id newTask2Id = CTI_callInfoPanelController.createNewTask('87654321', '910111121314', acc.id, ct.id);
        System.assertEquals(newTaskId, newTask2Id);
    }


    @isTest
    public static void testSearchAccountsAndContacts(){
        Map<String, List<SObject>> accountsAndContacts1 = CTI_callInfoPanelController.searchAccountAndContacts('420123456789');
        System.assertEquals(1, accountsAndContacts1.get('Account').size());
        System.assertEquals(1, accountsAndContacts1.get('Contact').size());

        Account acc = new Account(
            Name = 'test name 2',
            Phone = '+42087654321',
            BillingCountry = 'Czech Republic'
        );
        insert acc;

        CTI_callInfoPanelController.createNewTask('+42087654321', '75736534534323', acc.id, null);
        Map<String, List<SObject>> accountsAndContacts2 = CTI_callInfoPanelController.searchAccountAndContacts('+42087654321');
        System.assertEquals(1, accountsAndContacts2.get('Account').size());
    }


    @isTest
    public static void testSearchAccountsAndContactsByContact(){
        
        Account acc = new Account(
            Name = 'test name 2',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc;

        Contact c1 = new Contact(
            Salutation = 'Her',
            LastName = 'C1',
            AccountId = acc.Id,
            Phone = '+42087654321'
        );
        insert c1;

        Contact c2 = new Contact(
            Salutation = 'Her',
            LastName = 'C2',
            AccountId = acc.Id,
            MobilePhone = '42087654321'
        );
        insert c2;
        
        Map<String, List<SObject>> accountsAndContacts = CTI_callInfoPanelController.searchAccountAndContacts('42087654321');
        //System.debug(accountsAndContacts);
        System.assertEquals(1, accountsAndContacts.get('Account').size());
        System.assertEquals(2, accountsAndContacts.get('Contact').size());
    }


    @isTest
    public static void testSearchAccountsAndContactsByAccsAndContacts(){
        
        Account acc1 = new Account(
            Name = 'test acc 1',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc1;

        Account acc2 = new Account(
            Name = 'test acc 2',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc2;

        Contact c1 = new Contact(
            Salutation = 'Her',
            LastName = 'C1',
            AccountId = acc1.Id,
            Phone = '+42087654321'
        );
        insert c1;

        Contact c2 = new Contact(
            Salutation = 'Her',
            LastName = 'C2',
            AccountId = acc2.Id,
            MobilePhone = '42087654321'
        );
        insert c2;
        
        Map<String, List<SObject>> accountsAndContacts = CTI_callInfoPanelController.searchAccountAndContacts('42087654321');
        System.debug(accountsAndContacts);
        System.assertEquals(2, accountsAndContacts.get('Account').size());
        System.assertEquals(2, accountsAndContacts.get('Contact').size());
    }


    @isTest
    public static void testSearchAccountsAndContactsByAccContactRelation(){
        
        Account acc1 = new Account(
            Name = 'test acc 1',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc1;

        Account acc2 = new Account(
            Name = 'test acc 2',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc2;

        Contact c1 = new Contact(
            Salutation = 'Her',
            LastName = 'C1',
            AccountId = acc1.Id,
            Phone = '+42087654321'
        );
        insert c1;

        Contact c2 = new Contact(
            Salutation = 'Her',
            LastName = 'C2',
            AccountId = acc2.Id,
            MobilePhone = '42087654321'
        );
        insert c2;

        AccountContactRelation relC1Acc2 = new AccountContactRelation(
            AccountId = acc2.Id, 
            ContactId = c1.Id
            );
        insert relC1Acc2;

        AccountContactRelation relC2Acc1 = new AccountContactRelation(
            AccountId = acc1.Id, 
            ContactId = c2.Id
            );
        insert relC2Acc1;
        
        
        Map<String, List<SObject>> accountsAndContacts = CTI_callInfoPanelController.searchAccountAndContacts('42087654321');
        System.debug(accountsAndContacts);
        System.assertEquals(2, accountsAndContacts.get('Account').size());
        System.assertEquals(2, accountsAndContacts.get('Contact').size());
    }


    @isTest
    public static void testSearchAccountsAndContactsByTask(){
        
        Account acc = new Account(
            Name = 'test name 2',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc;

        Task t = new Task(
            Account__c = acc.Id,
            Phone__c = '+42087654321'
        );
        insert t;
        
        Map<String, List<SObject>> accountsAndContacts1 = CTI_callInfoPanelController.searchAccountAndContacts('42087654321');
        System.assertEquals(1, accountsAndContacts1.get('Account').size());
    }


    @isTest
    public static void testSearchAccountsAndContactsByTaskMulti(){
        
        Account acc = new Account(
            Name = 'test name 1',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc;

        Task t1 = new Task(
            Account__c = acc.Id,
            Phone__c = '+42087654321'
        );
        insert t1;

        Task t2 = new Task(
            Account__c = acc.Id,
            Phone__c = '+42087654321'
        );
        insert t2;
        
        Map<String, List<SObject>> accountsAndContacts1 = CTI_callInfoPanelController.searchAccountAndContacts('42087654321');
        System.assertEquals(1, accountsAndContacts1.get('Account').size());
    }


    @isTest
    public static void testCreateC2DTask(){

        Account acc1 = new Account(
            Name = 'test acc 1',
            Phone = '+420333555444',
            BillingCountry = 'Czech Republic'
        );
        insert acc1;

        Contact c1 = new Contact(
            Salutation = 'Her',
            LastName = 'C1',
            AccountId = acc1.Id,
            Phone = '+42087654321'
        );
        insert c1;

        Contact c2 = new Contact(
            Salutation = 'Her',
            LastName = 'C2',
            AccountId = acc1.Id,
            MobilePhone = '42087654321'
        );
        insert c2;

        AccountContactRelation rel = [ SELECT  Id,
                    AccountId,
                    ContactId
                    FROM    AccountContactRelation
                    WHERE   AccountId =: acc1.Id
                    AND ContactId =: c1.Id ];

        String phone = '42012344321';
        
        // Test for Account
        String callId = '98732146798793';
        String objectType = 'Account';
        Id taskId = CTI_callInfoPanelController.createC2DTask(acc1.Phone, callId, objectType, acc1.Id);
        Task t = [SELECT Id, CallId__c, Account__c, WhoId FROM Task WHERE Id =: taskId];

        System.assertEquals(t.CallId__c, callId);
        System.assertEquals(t.Account__c, acc1.Id);
        System.assertEquals(t.WhoId, null);

        // Test for Contact
        callId = '98732146798793123';
        objectType = 'Contact';
        taskId = CTI_callInfoPanelController.createC2DTask(c1.Phone, callId, objectType, c1.Id);
        t = [SELECT Id, CallId__c, Account__c, WhoId, Phone__c FROM Task WHERE Id =: taskId];

        System.assertEquals(t.CallId__c, callId);
        System.assertEquals(t.Account__c, acc1.Id);
        System.assertEquals(t.WhoId, c1.Id);

        // Test for Task
        callId = '98732146798793987';
        objectType = 'Task';
        taskId = CTI_callInfoPanelController.createC2DTask(t.Phone__c, callId, objectType, t.Id);
        Task t2 = [SELECT Id, CallId__c, Account__c, WhoId FROM Task WHERE Id =: taskId];


        System.assertEquals(t2.CallId__c, callId);
        System.assertEquals(t2.Account__c, t.Account__c);
        System.assertEquals(t2.WhoId, t.WhoId);

        // Test for Relation
        callId = '98732146798793222';
        objectType = 'AccountContactRelation';
        taskId = CTI_callInfoPanelController.createC2DTask(c1.Phone, callId, objectType, rel.Id);
        Task t3 = [SELECT Id, CallId__c, Account__c, WhoId FROM Task WHERE Id =: taskId];

        System.debug(t3);
        System.assertEquals(t3.CallId__c, callId);
        System.assertEquals(t3.Account__c, rel.AccountId);
        System.assertEquals(t3.WhoId, rel.ContactId);
    }


    @isTest
    public static void testGetAccountsaAndContacts(){
        Map<String, List<SObject>> accountsAndContacts = CTI_callInfoPanelController.getAccountsAndContacts('420123456789');
        System.assertEquals(1, accountsAndContacts.get('Account').size());
        System.assertEquals(1, accountsAndContacts.get('Contact').size());
    }


    @isTest
    public static void testGetTask(){
        List<Task> taskList = CTI_callInfoPanelController.getTasksByPhone('420123456789');
        System.assertEquals(1, taskList.size());
    }

    @isTest
    public static void testEventDataChanges() {
        Map<String, String> eventData = new Map<String, String>{
            'eventType' => 'assignEvent',
            'callId' => '1234',
            'action' => '',
            'extension' => '88005552535',
            'phoneNumber' =>'7788',
            'time' => '2020-03-17T16:05:27.6683023+01:00',
            'state' => '0',
            'status' => '0',
            'callType' => 'Inbound'
        };

        CTI_callInfoPanelController.saveEventData(eventData);

        Call_History_Item__c item = [
            SELECT  Name,
                    Extension__c,
                    Action__c,
                    Phone_Number__c,
                    Start_Time__c,
                    Call_Type__c
            FROM    Call_History_Item__c
            WHERE   Name = '1234'
            LIMIT   1
        ];

        System.assertEquals('7788', item.Phone_Number__c);
        System.assertEquals('88005552535', item.Extension__c);
        System.assertEquals('Inbound', item.Call_Type__c);
        System.assertEquals('2020-03-17T16:05:27.6683023+01:00', item.Start_Time__c);

        eventData.put('action', 'disconnected');
        eventData.put('startTime', '2020-03-17T16:15:27.6683023+01:00');

        CTI_callInfoPanelController.updateEventData(eventData);

        item = [
            SELECT  Name,
                    Extension__c,
                    Action__c,
                    Phone_Number__c,
                    Start_Time__c,
                    Call_Type__c
            FROM    Call_History_Item__c
            WHERE   Name = '1234'
            LIMIT   1
        ];

        System.assertEquals('Missed', item.Call_Type__c);
        System.assertEquals('2020-03-17T16:15:27.6683023+01:00', item.Start_Time__c);

        Account testAcc = [SELECT Id FROM Account LIMIT 1];

        CTI_callInfoPanelController.linkHistoryItemToAccount(testAcc.Id, '1234');

        // item = [
        //     SELECT  Account__c
        //     FROM    Call_History_Item__c
        //     WHERE   Name = '1234'
        //     LIMIT   1
        // ];

        // System.assertEquals(testAcc.Id, item.Account__c);

        List<CTI_callInfoPanelController.CallHistoryWrapper> callHistory = CTI_callInfoPanelController.getCallHistory();
        System.assertEquals(1, callHistory.size());
        System.assertEquals(testAcc.Id, callHistory[0].accountParams.Id);
        System.assertEquals('1234', callHistory[0].historyItem.Name);

    }

    @isTest
    public static void testWriteDebugLog() {
        List<String> logs = new List<String>{'Log1', 'Log2', 'Log3'};
        CTI_callInfoPanelController.writeDebugLog(logs);
    }

    @isTest
    public static void testSaveCallDuration() {
        Call_History_Item__c historyItem = new Call_History_Item__c(
            Event_Type__c = 'assignEvent',
            Name = '1234',
            Action__c = '',
            Extension__c = '88005552535',
            Phone_Number__c = '7788',
            Start_Time__c = '2020-03-17T16:05:27.6683023+01:00',
            State__c = 0,
            Status__c = 0,
            Call_Type__c = 'Inbound'
        );
        insert historyItem;
        Task newTask = [SELECT Id FROM Task WHERE Phone__c = '+420123456789'];
        Map<String, String> eventData = new Map<String, String> {
            'endTime' => '2020-03-17T16:06:27.6683023+01:00',
            'callId' => '1234'
        };

        Test.startTest();
        CTI_CallInfoPanelController.saveCallDuration(newTask.Id, eventData);
        Test.stopTest();
        Task updatedTask = [SELECT Id, CallDurationInSeconds FROM Task WHERE Phone__c = '+420123456789'];
        System.assertEquals(60, updatedTask.CallDurationInSeconds);
    }
}