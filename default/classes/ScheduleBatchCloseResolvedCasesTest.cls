@IsTest
public class ScheduleBatchCloseResolvedCasesTest {

    @IsTest
    private static void test() {
        Test.startTest();

        String cronExp = '0 0 0 ? * MON-FRI *';
        String id = System.schedule('ScheduleBatchCloseResolvedCasesTest', cronExp, new ScheduleBatchCloseResolvedCases());

        CronTrigger cronTrigger = [
                SELECT CronExpression
                FROM CronTrigger
                WHERE Id = :id
        ];
        System.assertEquals(cronExp, cronTrigger.CronExpression);

        Test.stopTest();
    }

}