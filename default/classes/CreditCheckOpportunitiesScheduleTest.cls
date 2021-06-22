@isTest
private class CreditCheckOpportunitiesScheduleTest {


	/*******************************************************************************
	*  Name            : testSchedule()
	*  Summary         : test scheduled job
	*  CreatedDate     : 11/04/2017
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testSchedule() {
		Credit_Check_Notifications__c notification = new Credit_Check_Notifications__c(
			Name = 'Test',
			Email__c = 'testmail@test.com',
			Active__c = true);
		insert notification;

		Test.startTest();

			String sch = '0 0 23 * * ?'; 
			system.schedule('Test Job Reaction', sch, new CreditCheckOpportunitiesSchedule()); 

		Test.stopTest(); 
	}
}