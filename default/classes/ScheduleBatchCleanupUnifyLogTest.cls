@isTest
public class ScheduleBatchCleanupUnifyLogTest {
    @isTest
    public static void test_schedule(){
        String CRON_EXP = '0 0 0 3 9 ? 2032';
      
        Test.startTest();
        String jobId = System.schedule('UnifyCCTest', CRON_EXP, new ScheduleBatchCleanupUnifyLog());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2032-09-03 00:00:00', String.valueOf(ct.NextFireTime));   

        Test.stopTest();       
    }

    @isTest
    public static void test_delete(){
        Test.startTest();
            ScheduleBatchCleanupUnifyLog.deleteLogs();
        Test.stopTest();
        system.debug([SELECT Entity_ID__c, Message__c, RecordDateTime__c FROM Unify_CC_LogStorage__b]);

    }
}