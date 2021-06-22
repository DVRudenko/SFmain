@isTest
public class EmarsysQueueJobCheckerTest {
    @TestSetup
    static void makeData() {
        Emarsys_Contact_Subscriptions__c segmentRecord = new Emarsys_Contact_Subscriptions__c();
        segmentRecord.Run_id__c = 'test-run-id-111';
        segmentRecord.Name = 'Test segment for test';
        insert segmentRecord;
    }

    @isTest
    static void testExecute_checkExceptionBehaviour() {
        EmarsysQueueJobChecker job = new EmarsysQueueJobChecker(null, null);
        
        setMock();
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();

        Emarsys_Contact_Subscriptions__c selectedSegment = [
            SELECT Run_id__c, Contact_List_Id__c
            FROM Emarsys_Contact_Subscriptions__c
            WHERE Run_id__c = 'test-run-id-111'
        ];

        System.assertEquals(null, selectedSegment.Contact_List_Id__c);

        List<CronTrigger> jobsList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysJobCheckerScheduler.JOB_NAME LIMIT 1];
        System.assert(!jobsList.isEmpty());
    }

    @isTest
    static void testExecute_setContactListId() {
        Emarsys_Contact_Subscriptions__c selectedSegment = [
            SELECT Run_id__c, Contact_List_Id__c
            FROM Emarsys_Contact_Subscriptions__c
            WHERE Run_id__c = 'test-run-id-111'
        ];
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());

        EmarsysQueueJobChecker job = new EmarsysQueueJobChecker(new List<Emarsys_Contact_Subscriptions__c>{selectedSegment}, emarsysAccount);

        setMock();        
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();

        selectedSegment = [
            SELECT Run_id__c, Contact_List_Id__c
            FROM Emarsys_Contact_Subscriptions__c
            WHERE Run_id__c = 'test-run-id-111'
        ];

        System.assertEquals('81666672', selectedSegment.Contact_List_Id__c);
        List<CronTrigger> jobsList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysJobCheckerScheduler.JOB_NAME LIMIT 1];
        System.assert(!jobsList.isEmpty());
    }

    @isTest
    static void testExecute_errorResponse() {
        Emarsys_Contact_Subscriptions__c selectedSegment = [
            SELECT Run_id__c, Contact_List_Id__c
            FROM Emarsys_Contact_Subscriptions__c
            WHERE Run_id__c = 'test-run-id-111'
        ];
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());

        EmarsysQueueJobChecker job = new EmarsysQueueJobChecker(new List<Emarsys_Contact_Subscriptions__c>{selectedSegment}, emarsysAccount);

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock mockedResponse = new SingleRequestMock(
            200,
            'Complete',
            '{"replyCode": 1008, "replyText": "bad","data": {}}',
            headers
        );
        Test.setMock(HttpCalloutMock.class, mockedResponse);

        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();

        selectedSegment = [
            SELECT Run_id__c, Contact_List_Id__c
            FROM Emarsys_Contact_Subscriptions__c
            WHERE Run_id__c = 'test-run-id-111'
        ];

        System.assertEquals(null, selectedSegment.Contact_List_Id__c);
        List<CronTrigger> jobsList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysJobCheckerScheduler.JOB_NAME LIMIT 1];
        System.assert(!jobsList.isEmpty());
    }

    private static void setMock() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock mockedResponse = new SingleRequestMock(
            200,
            'Complete',
            '{"replyCode": 0, "replyText": "OK","data":' +
            ' {"status": "done","result": ' +
            '{"contact_list_id": 81666672,"user_count": 8690,"opt_in_count": 7789,"duration": 13},' +
            '"run_id": "test-run-id-111"}}',
            headers
        );
        Test.setMock(HttpCalloutMock.class, mockedResponse);
    }
}