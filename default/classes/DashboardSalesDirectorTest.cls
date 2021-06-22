@isTest
private class DashboardSalesDirectorTest {
	public Static User u;

	@isTest
    public static void testSalesDashboard() {   

		Test.startTest();
			createSalesTeamleader();			
		Test.stopTest();

		System.runAs(u) {
		    DashboardSalesDirectorCtrl controller = new DashboardSalesDirectorCtrl();
		    controller.selectTeamType();
		    controller.getTeamTypes();
		    controller.init();
		}
    }

	@future
    private static void createSalesTeamleader() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		u = new User (
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_233121_test1@test.com',
		   	Alias = 'teamlead',
			Email='test_1233@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='testName',
			Lastname='testFamily',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}
}