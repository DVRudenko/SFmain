@isTest
private class CreditFactoryReportScheduleTest {


	/*******************************************************************************
	*  Name            : testSchedule()
	*  Summary         : Test check mailbox directory and entry    
	*  CreatedDate     : 05/07/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testSchedule() {
        Test.startTest();
	        CreditFactoryReportSchedule schedule = new CreditFactoryReportSchedule();
			String sch = '00 00 8,10,12,14,16,18,20,22,00 ? * MON-FRI'; 
			System.schedule('Test mailbox Job', sch, schedule); 
		Test.stopTest(); 
    }
}