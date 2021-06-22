@isTest
public with sharing class EmarsysContactIdsGathererScheduleTest {
    private static String jobName = EmarsysContactIdsGathererSchedule.JOB_NAME;

    @isTest
    static void testExecute_directCall() {
        Test.startTest();
        abortJobBeforeTest();

        EmarsysContactIdsGathererSchedule scheduledContactReaction = new EmarsysContactIdsGathererSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule(jobName, sch, scheduledContactReaction);

        Test.stopTest();

        List<CronTrigger> jobsList = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        System.assertEquals('0 0 2 ? * MON-FRI', jobsList[0].CronExpression);
    }

    @isTest
    static void testExecute_FirstRunCall() {
        Test.startTest();
        abortJobBeforeTest();

        EmarsysContactIdsGathererSchedule scheduledContactReaction = new EmarsysContactIdsGathererSchedule();
        String sch = '0 0 2 ? * MON-FRI';
        system.schedule(jobName, sch, scheduledContactReaction);

        Test.stopTest();

        List<CronTrigger> jobsList = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        System.assertEquals('0 0 3 ? * MON-FRI', jobsList[0].CronExpression);
    }

    @isTest
    static void testExecute_CallWithCont() {
        List<Emarsys_Contact_Subscriptions__c> conSubList = new List<Emarsys_Contact_Subscriptions__c>();
        conSubList.add(
            new Emarsys_Contact_Subscriptions__c(
                Name = 'firstConSub',
                Last_Update_Segment_Date__c = Datetime.now().addDays(-2),
                Segment_Id__c = '12345',
                Subscription_Name__c = 'Subscription_Name 1',
                Type__c = 'Lead',
                Email_Name__c = 'Email_Name 1',
                Contact_list_id__c = '12345',
                Run_id__c = '12345'
            )
        );
        insert conSubList;

        setMock();

        Test.startTest();

        EmarsysContactIdsGathererSchedule scheduledContactReaction = new EmarsysContactIdsGathererSchedule();
        String sch = '0 0 2 ? * MON-FRI';
        system.schedule('Test Job Reaction', sch, scheduledContactReaction);

        Test.stopTest();
    }

    public static void setMock() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock contactListResponse = new SingleRequestMock(
            200,
            'Complete',
            '{"replyCode": 0, "replyText": "OK", "data": ["385885793", "393615693", "371354459"]}',
            headers
        );

        Test.setMock(HttpCalloutMock.class, contactListResponse);
    }
    
    private static void abortJobBeforeTest() {
        List<CronTrigger> jobsList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        if (!jobsList.isEmpty()) {
            System.abortJob(jobsList[0].Id);
        }
    }
}