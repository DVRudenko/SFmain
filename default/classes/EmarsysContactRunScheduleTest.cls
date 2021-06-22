/**
 * Created by Yury on 06.10.2020.
 */
@isTest
public with sharing class EmarsysContactRunScheduleTest {

    public static void initSettings() {

        Emarsys_Contact_Subscriptions__c customSetting = new Emarsys_Contact_Subscriptions__c(
                Last_Update_Segment_Date__c = Datetime.newInstanceGmt(Date.today(), Time.newInstance(18, 00, 0,0)),
                Segment_Id__c = null,
                Name = 'Test'
        );
        insert customSetting;

    }
    public static void StopJob() {

        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE '%RunScheduler%'

        ];
        if (! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }
    }
/*
    @isTest
    static void testScheduleMethod(){
        initSettings();
        list<Emarsys_Contact_Subscriptions__c> EmarsysContactSubscriptions = Emarsys_Contact_Subscriptions__c.getAll().values();

    System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new EmarsysRunIdMock());
        system.schedule('RunScheduler', '0 0 22 * * ?', new EmarsysContactRunSchedule());
        StopJob();
        system.schedule('RunScheduler', '0 0 23 * * ?', new EmarsysContactRunSchedule());
    System.Test.stopTest();
        System.assertEquals('Test', EmarsysContactSubscriptions[0].Name);

    }
    */
}