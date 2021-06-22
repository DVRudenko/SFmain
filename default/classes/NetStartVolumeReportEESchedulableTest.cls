/**
 * Created by Andrei.Moiseev on 11.04.2018.
 */

@IsTest
private class NetStartVolumeReportEESchedulableTest {

    private static void initPeriods() {
        Date now = System.Today();

        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(now.year()));
        insert year;

        Fleetcor_Calendar_Month__c month_1 = new Fleetcor_Calendar_Month__c(
                Name = 'October',
                Month_Number__c = 10,
                Start_Date__c = now.addDays(-20),
                End_Date__c = now.addDays(-1),
                Fleetcor_Calendar_Year__c = year.Id);
        insert month_1;

        Fleetcor_Calendar_Month__c month_2 = new Fleetcor_Calendar_Month__c(
                Name = 'November',
                Month_Number__c = 11,
                Start_Date__c = now.addDays(-40),
                End_Date__c = now.addDays(-21),
                Fleetcor_Calendar_Year__c = year.Id);
        insert month_2;

        Fleetcor_Calendar_Month__c month_3 = new Fleetcor_Calendar_Month__c(
                Name = 'Dec',
                Month_Number__c = 12,
                Start_Date__c = now,
                End_Date__c = now.addDays(20),
                Fleetcor_Calendar_Year__c = year.Id);
        insert month_3;

        RU_Onboarding_Report_EE_Emails__c email = new RU_Onboarding_Report_EE_Emails__c(
                Name = 'test@test.com'
        );
        insert email;
    }

    @isTest
    public static void testScheduledJob() {
        initPeriods();
        Test.startTest();
        String jobId = System.schedule(
                'Onboarding report',
                NetStartVolumeReportEESchedulable.CRON_EXP,
                new NetStartVolumeReportEESchedulable()
        );

        CronTrigger ct = ([
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE id = :jobId
        ]);

        System.assertEquals(NetStartVolumeReportEESchedulable.CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}