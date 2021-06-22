@isTest
public class EmarsysJobCheckerSchedulerTest {

    @isTest
    static void testSchedule_executeWithoutDataFirstRun() {
        setMock();
        
        Test.startTest();
        EmarsysContactsJobService.scheduleJob(EmarsysJobCheckerScheduler.JOB_NAME, 0, 0, EmarsysContactsJobService.JobTypes.JOB_CHECK);
        Test.stopTest();

        List<CronTrigger> jobsList = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysJobCheckerScheduler.JOB_NAME LIMIT 1];
        System.assert(!jobsList.isEmpty());
        System.assertEquals('0 30 1 ? * MON-FRI', jobsList[0].CronExpression);
    }

    @isTest
    static void testSchedule_executeWithoutDataSecondRun() {
        setMock();
        
        Test.startTest();
        EmarsysContactsJobService.scheduleJob(EmarsysJobCheckerScheduler.JOB_NAME, 30, 1, EmarsysContactsJobService.JobTypes.JOB_CHECK);
        Test.stopTest();

        List<CronTrigger> jobsList = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysJobCheckerScheduler.JOB_NAME LIMIT 1];
        System.assert(!jobsList.isEmpty());
        System.assertEquals('0 0 0 ? * MON-FRI', jobsList[0].CronExpression);
    }

    @isTest
    static void testSchedule_executeWithData() {
        Emarsys_Contact_Subscriptions__c segmentRecord = new Emarsys_Contact_Subscriptions__c();
        segmentRecord.Run_id__c = 'test-run-id-111';
        segmentRecord.Name = 'Test segment for test';
        insert segmentRecord;
        setMock();
        
        Test.startTest();
        EmarsysContactsJobService.scheduleJob(EmarsysJobCheckerScheduler.JOB_NAME, 30, 1, EmarsysContactsJobService.JobTypes.JOB_CHECK);
        Test.stopTest();

        List<CronTrigger> jobsList = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysJobCheckerScheduler.JOB_NAME LIMIT 1];
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
