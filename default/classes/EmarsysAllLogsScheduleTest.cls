@isTest
private class EmarsysAllLogsScheduleTest {


    /*******************************************************************************
	*  Name            : testScheduleLead()
	*  Summary         : test running scheduled job
	*  CreatedDate     : 21/08/2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testScheduleLead() {
        Test.startTest();

        EmarsysAllLogsSchedule allLogsSchedule = new EmarsysAllLogsSchedule('test email', 'test campaign', 'Lead');
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Job Reaction', sch, allLogsSchedule); 

		Test.stopTest(); 
    }


    /*******************************************************************************
	*  Name            : testScheduleOpportunity()
	*  Summary         : test running scheduled job
	*  CreatedDate     : 21/08/2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testScheduleOpportunity() {
        Test.startTest();

        EmarsysAllLogsSchedule allLogsSchedule = new EmarsysAllLogsSchedule('test email', 'test campaign', 'Opportunity');
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Job Reaction', sch, allLogsSchedule); 

		Test.stopTest(); 
    }
}