@isTest
private class ScheduleCheckingAdoptionProcessTest {
    @isTest
	public static void checkingAdoptionProcessScheduleTest() {
		Test.startTest();
	        ScheduleCheckingAdoptionProcess scheduler = new ScheduleCheckingAdoptionProcess();
	        String sch = '0 0 23 * * ?';
	        System.schedule('Test Check', sch, scheduler);
        Test.stopTest();
	}
}