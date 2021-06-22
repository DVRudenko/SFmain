@isTest
private class EmarsysReactionLogsCheckScheduleTest {


	@isTest
    static void checkErrorsTest() {
        Test.startTest();

        EmarsysReactionLogsCheckSchedule scheduledContactReaction = new EmarsysReactionLogsCheckSchedule();
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Job Reaction', sch, scheduledContactReaction); 

		Test.stopTest(); 
    }
}