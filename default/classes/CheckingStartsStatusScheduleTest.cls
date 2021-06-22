@isTest
private class CheckingStartsStatusScheduleTest {
    @isTest
	public static void checkingStartsStatusTest() {
        Test.startTest();
	        BatchCheckingStartsStatusSchedule scheduler = new BatchCheckingStartsStatusSchedule();
	        String sch = '0 0 23 * * ?';
	        System.schedule('Test Check', sch, scheduler);
        Test.stopTest();
    }
}