@IsTest
public with sharing class EmarsysContactIdsGathererTest {
    @IsTest
    private static void testContactIdsGatherer_NullParams() {
        Test.startTest();
        EmarsysContactIdsGatherer conIdGatherer = new EmarsysContactIdsGatherer(null, null);
        System.enqueueJob(conIdGatherer);
        Test.stopTest();

        List<CronTrigger> jobsList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: EmarsysContactIdsGathererSchedule.JOB_NAME LIMIT 1];
        System.assert(!jobsList.isEmpty());
    }

    @IsTest
    private static void testContactIdsGatherer() {
        List<Emarsys_Contact_Subscriptions__c> conSubList = new List<Emarsys_Contact_Subscriptions__c>();
        conSubList.add(new Emarsys_Contact_Subscriptions__c(
            Name = 'firstConSub',
            Last_Update_Segment_Date__c = Datetime.now(),
            Segment_Id__c = '12345',
            Subscription_Name__c = 'Subscription_Name 1',
            Type__c = 'Lead', 
            Email_Name__c = 'Email_Name 1',
            Contact_list_id__c = '12345',
            Run_id__c = '12345'
        ));
        insert conSubList;

        setMock();

        Test.startTest();
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        EmarsysContactIdsGatherer conIdGatherer = new EmarsysContactIdsGatherer(conSubList, emarsysAccount);
        System.enqueueJob(conIdGatherer);
        Test.stopTest();

        conSubList = [
            SELECT Id, Contact_list_id__c, Run_id__c, Last_Update_Segment_Date__c 
            FROM Emarsys_Contact_Subscriptions__c];
        System.assert(conSubList.size() > 0);
        for (Emarsys_Contact_Subscriptions__c conSub :conSubList) {
            System.assertEquals(null, conSub.Contact_list_id__c);
            System.assertEquals(null, conSub.Run_id__c);
        }
    }

    public static void setMock() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock contactListResponse = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode": 0, "replyText": "OK", "data": ["385885793", "393615693", "371354459"]}',
                headers);

        Test.setMock(HttpCalloutMock.class, contactListResponse);
    }
}