@isTest
private class OpportunityStageStatusScheduleTest {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	@isTest
    static void startSchedule() {
        Test.startTest();
        	String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new OpportunityStageStatusSchedule());
        Test.stopTest();
    }
}