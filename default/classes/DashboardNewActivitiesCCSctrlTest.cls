@isTest
private class DashboardNewActivitiesCCSctrlTest {
	public static User teamlead;
	public static User saleRep;
	public static Event newEvent;
	public static Task newTask;

    static testMethod void testNewActivitiesTeamLead() {  
    	Test.startTest();
			createTeamLeadCCSUser();
			createSaleCCSUser();
		Test.stopTest();

		System.runAs(teamlead) {
			createTask();
			createEvent();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'October',
				Month_Number__c = 10, 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(4),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardNewActivitiesCCSctrl controller = new DashboardNewActivitiesCCSctrl();
			controller.init();
			controller.getPeriodsList();
			controller.getYearsList();		
			controller.selectedPeriod = month.Id;
			controller.init();
			controller.changeYear();
		}
    }


    static testMethod void testNewActivitiesSaleRep() {  
    	Test.startTest();
			createSaleCCSUser();
		Test.stopTest();

		System.runAs(saleRep) {
			createTask();
			createEvent();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'October',
				Month_Number__c = 10, 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(4),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardNewActivitiesCCSctrl controller = new DashboardNewActivitiesCCSctrl();
			controller.init();
		}
    }


    @future
	private static void createTeamLeadCCSUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Salesteamleiter Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
		
		teamlead = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_23423_test@test.com',
		   	Alias = 'teamlead',
			Email = 'will.smith_1233@willenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Will',
			Lastname = 'Smith',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(teamlead);
	}

	@future
	private static void createSaleCCSUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ Telesales'];
		
		saleRep = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_32432_test@test.com',
		   	Alias = 'saleCCS',
			Email = 'tommy.li_jones@tommyenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Tommy',
			Lastname = 'Li Jones',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(saleRep);
	}

	public static void createTask() {
		newTask = new Task(
			Subject = 'Other',
			Priority= 'Normal',
			Status = 'In Progress',
			Type = 'Anruf',
			ActivityDate = Date.today().addDays(-2));
		insert newTask;
	}

	private static void createEvent() {
		newEvent = new Event(
			Subject = 'Test Event',
			OwnerId = saleRep.Id,
			Type = 'První schůzka',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		insert newEvent;
	}
}