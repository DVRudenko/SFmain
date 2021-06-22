@isTest
private class ScheduleCheckingAdoptionJITBprocessTest {
    @isTest
	public static void checkingAdoptionJITBprocessScheduleTest() {
		Test.startTest();
	        ScheduleCheckingAdoptionJITBprocess scheduler = new ScheduleCheckingAdoptionJITBprocess();
	        String sch = '0 0 23 * * ?';
	        System.schedule('Test Check', sch, scheduler);
        Test.stopTest();
	}
}