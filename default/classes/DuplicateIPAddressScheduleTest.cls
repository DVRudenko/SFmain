@IsTest
private class DuplicateIPAddressScheduleTest {
    
    
    /*******************************************************************************
	*  Summary         : Test check of duplicate IP address
	*  CreatedDate     : 16/06/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
	@isTest
    static void testSchedule() {
        Test.startTest();
	        DuplicateIPAddressSchedule schedule = new DuplicateIPAddressSchedule();
			String sch = '00 00 6 ? * *'; 
			System.schedule('Test duplicate IP address job', sch, schedule); 
		Test.stopTest(); 
    }
}