@IsTest
private class GoogleSpeedAnalystBatchScheduleTest {
    @IsTest
    static void googleSpeedScheduleTest() {
        Test.startTest();
            String cronExp = '0 0 12 * * ?';
            String id = System.schedule('GoogleSpeedAnalystBatchScheduleTest', cronExp, new GoogleSpeedAnalystBatchSchedule());

            CronTrigger cronTrigger = [
                    SELECT CronExpression
                    FROM CronTrigger
                    WHERE Id = :id
            ];
            System.assertEquals(cronExp, cronTrigger.CronExpression);
        Test.stopTest();
    }
}