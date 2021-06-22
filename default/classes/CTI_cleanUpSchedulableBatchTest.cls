@isTest
public class CTI_cleanUpSchedulableBatchTest{

    @isTest
    public static void testBatch(){
        Call_History_Item__c item = new Call_History_Item__c(Name = 'Test');
        insert item;

        Datetime longTimeAgo = Datetime.now().addDays(-160);
        Test.setCreatedDate(item.Id, longTimeAgo);

        Test.startTest();
        Database.ExecuteBatch(new CTI_cleanUpSchedulableBatch());
        Test.stopTest();

    }

    @isTest
    public static void testSchedule(){
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2042';

        String jobId = System.schedule('cleanUpSchedulableBatchTest', CRON_EXP, new CTI_cleanUpSchedulableBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered); 
        System.assertEquals('2042-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
        Test.stopTest();        
    }
    

}