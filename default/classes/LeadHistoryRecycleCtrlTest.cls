@isTest (SeeAllData = true)
private class LeadHistoryRecycleCtrlTest {
	public static User usr;
	public static Lead testlead;

    @isTest
    private static void testLeadHistoryRecycle() {       
    	Test.startTest();
			createSalesUser();
		Test.stopTest();

		System.runAs(usr) {
			List<Lead> leadsList = [
				SELECT Id, Name, Status
				FROM Lead
				WHERE Id = '00Q2000000tfNkN' 
				LIMIT 1
			];

			if (! leadsList.isEmpty()) {
				testlead = leadsList.get(0);

				ApexPages.CurrentPage().getparameters().put('id', testlead.Id);
		    	LeadHistoryRecycleCtrl controller = new LeadHistoryRecycleCtrl();   	
		    	controller.init();
			}
		}	
    }

    @future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];
		
		usr = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'batman',
			Email ='bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Bruce',
			Lastname = 'Wayne',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(usr);	   
	}
}