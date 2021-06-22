@isTest
private class DashboardFieldMeetingsPlanCCSctrlTest {
	public static User teamlead;
	public static User saleRep;
	public static Event newEvent1;
	public static Event newEvent2;
	public static Event newEvent3;
	public static Event newEvent4;
	public static Event newEvent5;
	public static Event newEvent6;
	public static Event newEvent7;

    @isTest
    public static void testFieldMeetingsPlanTeamLead() {
    	Test.startTest();
			createTeamLeadCCSUser();
			createSaleCCSUser();
		Test.stopTest();

		System.runAs(teamlead) {
			createEvents();

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

			DashboardFieldMeetingsPlanCCSctrl controller = new DashboardFieldMeetingsPlanCCSctrl();
			controller.init();
			controller.getPeriodsList();
			controller.getYearsList();		
			controller.selectedPeriod = month.Id;
			controller.init();
			controller.changeYear();

			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).firstMeetingType, 1);
			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).nextMeetingType, 1);
			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).retentionType, 1);
			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).developmentType, 1);
			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).careType, 1);
			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).trainingType, 1);
			System.assertEquals(controller.finalEventTypesMap.get(saleRep.Id).acquisitionType, 1);
		}
    }

    @isTest
    public static void testTopDealsSaleRep() {
    	Test.startTest();
			createSaleCCSUser();
		Test.stopTest();

		System.runAs(saleRep) {
			createEvents();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'October',
				Month_Number__c = 10, 
				Start_Date__c = Date.today().addDays(-11),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(4),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardFieldMeetingsPlanCCSctrl controller = new DashboardFieldMeetingsPlanCCSctrl();
			controller.init();
		}
    }

    @future
	private static void createTeamLeadCCSUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'CCS SME Team Lead']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS SME Team Lead'];
		
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
		Profile p = [SELECT Id FROM Profile WHERE Name = 'CCS Service Manager'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ SME'];
		
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

    private static void createEvents() {
    	List<Event> eventsToInsertList = new List<Event>();
		newEvent1 = new Event(
			Subject = 'Test Event1',
			OwnerId = saleRep.Id,
			Type = 'První schůzka',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent1);

		newEvent2 = new Event(
			Subject = 'Test Event2',
			OwnerId = saleRep.Id,
			Type = 'Následná schůzka',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent2);

		newEvent3 = new Event(
			Subject = 'Test Event3',
			OwnerId = saleRep.Id,
			Type = 'Retence',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent3);

		newEvent4 = new Event(
			Subject = 'Test Event4',
			OwnerId = saleRep.Id,
			Type = 'Rozvoj',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent4);

		newEvent5 = new Event(
			Subject = 'Test Event5',
			OwnerId = saleRep.Id,
			Type = 'Péče',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent5);

		newEvent6 = new Event(
			Subject = 'Test Event6',
			OwnerId = saleRep.Id,
			Type = 'Trénink',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent6);

		newEvent7 = new Event(
			Subject = 'Test Event7',
			OwnerId = saleRep.Id,
			Type = 'Akvizice',
			DurationInMinutes = System.now().millisecond() + 1,
			ActivityDateTime = Datetime.now()
		);
		eventsToInsertList.add(newEvent7);
		insert eventsToInsertList;
	}
}