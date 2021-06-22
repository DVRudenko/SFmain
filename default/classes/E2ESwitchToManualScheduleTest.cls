@isTest
private class E2ESwitchToManualScheduleTest {
	@isTest
    static void testSwitchToManualSchedule() {
        Test.startTest();
        	System.schedule('testSchedule', '0 0 * ? * *', new E2ESwitchToManualSchedule());
        Test.stopTest();
    }
}