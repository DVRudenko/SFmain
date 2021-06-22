@IsTest
public with sharing class ArchiveCustomLogBatchTest {

    @IsTest
    private static void test() {
        insert new Custom_log__c(
                Source__c = 'EUP',
                External_user__c = 'test',
                INN__c = '12354',
                Errors__c = '1'
        );
        Long startTime = Datetime.now().getTime();
        Long finishTime = Datetime.now().getTime();
        while ((finishTime - startTime) < 2000) {
            //sleep for 2s
            finishTime = Datetime.now().getTime();
        }
        insert new Custom_log_archivation_settings__c(
                Name = 'PPR_API',
                Days_logs_to_archive__c = 0,
                Sources__c = 'EUP; test;',
                Notification_recipients__c = 'test@fsdf.rg'
        );
        insert new List<Custom_log__c>{
                new Custom_log__c(
                        Source__c = 'EUP',
                        External_user__c = 'test',
                        INN__c = '12354',
                        Errors__c = '2'
                ),
                new Custom_log__c(
                        Source__c = 'test',
                        External_user__c = 'test',
                        INN__c = '12354',
                        Errors__c = '3'
                ),
                new Custom_log__c(
                        Source__c = 'sdfdf',
                        External_user__c = 'test',
                        INN__c = '12354',
                        Errors__c = '4'
                )
        };

        Test.startTest();
        Database.executeBatch(new ArchiveCustomLogBatch(Custom_log_archivation_settings__c.getValues('PPR_API')));
        Test.stopTest();

        List<Custom_log__c> logs = ([
                SELECT Id, Source__c, CreatedDate, Errors__c, External_user__c, E2E_Form_Ru_Data__c, INN__c
                FROM Custom_log__c
        ]);
        for (Custom_log__c log : logs) {
            System.debug(log.CreatedDate.getTime());
        }
        System.assertEquals(3, logs.size());
        Boolean flag = false;
        for (Custom_log__c log : logs) {
            flag = log.Errors__c.equals('1');
        }
        System.assertEquals(false, flag);
    }

    @IsTest
    private static void testException() {
        try {
            insert new Custom_log_archivation_settings__c(
                    Name = 'PPR_API'
            );

            Test.startTest();
            Database.executeBatch(new ArchiveCustomLogBatch(Custom_log_archivation_settings__c.getValues('PPR_API')));
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e != null);
        }

    }



}