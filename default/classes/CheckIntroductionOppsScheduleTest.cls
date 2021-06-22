@isTest
private class CheckIntroductionOppsScheduleTest {
    @isTest
	public static void checkIntroductionOppsScheduleTest() {
		Test.startTest();
	        CheckIntroductionOppsSchedule scheduler = new CheckIntroductionOppsSchedule();
	        String sch = '0 0 23 * * ?';
	        System.schedule('Test Check', sch, scheduler);
        Test.stopTest();
	}
}