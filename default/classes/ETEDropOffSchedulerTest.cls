@IsTest
private class ETEDropOffSchedulerTest {
    @IsTest
    private static void eteDropOffBatchTest() {
        Test.startTest();
            Set<String> jobIdsSet = new Set<String>();
            jobIdsSet.add(System.schedule('E2E Drop Off Job 0 ' + System.now(), '0 0 * * * ?', new ETEDropOffScheduler()));
            jobIdsSet.add(System.schedule('E2E Drop Off Job 15 ' + System.now(), '0 15 * * * ?', new ETEDropOffScheduler()));
            jobIdsSet.add(System.schedule('E2E Drop Off Job 30 ' + System.now(), '0 30 * * * ?', new ETEDropOffScheduler()));
            jobIdsSet.add(System.schedule('E2E Drop Off Job 45 ' + System.now(), '0 45 * * * ?', new ETEDropOffScheduler()));
            List<CronTrigger> cronTriggers = [
                    SELECT CronExpression
                    FROM CronTrigger
                    WHERE Id IN :jobIdsSet
            ];
            System.assertEquals(4, cronTriggers.size());
        Test.stopTest();
    }
}