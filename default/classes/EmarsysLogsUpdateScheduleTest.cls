@isTest
private class EmarsysLogsUpdateScheduleTest {

	/*******************************************************************************
	*  Name            : launchScheduleTest()
	*  Summary         : test launch Schedule Test
	*  CreatedDate     : 30/06/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void launchScheduleTest() {
    	Test.startTest();
	    	System.schedule('testSchedule', '20 0 8-18 ? * MON-FRI', new EmarsysLogsUpdateSchedule());
	    Test.stopTest();
    }
}