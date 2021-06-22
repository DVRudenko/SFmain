@IsTest
public with sharing class PPR_API_ArchiveCustomLogScheduleTest {

    @IsTest
    private static void test() {
        insert new Custom_log_archivation_settings__c(
                Name = 'PPR_API',
                Days_logs_to_archive__c = 0,
                Sources__c = 'EUP; test;'
        );

        Test.startTest();

        String cronExp = '0 0 0 ? * MON-FRI *';
        String id = System.schedule('PPR_API_ArchiveCustomLogSchedule unit test', cronExp, new PPR_API_ArchiveCustomLogSchedule());

        CronTrigger cronTrigger = [
                SELECT CronExpression
                FROM CronTrigger
                WHERE Id = :id
        ];
        System.assertEquals(cronExp, cronTrigger.CronExpression);

        Test.stopTest();
    }

}