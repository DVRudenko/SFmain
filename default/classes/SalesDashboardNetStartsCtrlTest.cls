@isTest
private class SalesDashboardNetStartsCtrlTest {
    public Static User u;
    public Static User u2;
    public Static Account newAccount;
    public Static Opportunity newOpp;
    public Static Starts__c newStarts;

    @isTest
    public static void testSalesDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createStarts();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'January', 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today(),
				Fleetcor_Calendar_Year__c = year.Id,
				Month_Number__c = 1);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          Start_Date__c = Date.today().addDays(-7), 
	          End_Date__c = Date.today(),
	          Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

			Sales_Plan__c plan = new Sales_Plan__c(User__c = u.Id, Fleetcor_Calendar_Month__c = month.Id);
			insert plan;
		    
		    SalesDashboardNetStartsCtrl controller = new SalesDashboardNetStartsCtrl();
		    controller.init();
			controller.getYears();
			controller.getcurrentWeeks();
			controller.changeYear();
			controller.returnFleetCorLastDayMonth(Date.today());
		}
    }


    @isTest
    public static void testLeadDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u2) {
			createAccount();
			createOpp();
			newOpp.StageName = 'Closed Won';
			newOpp.Closed_Won_by_CF__c = true;
			newOpp.OwnerId = u.Id;
			update newOpp;
			createStarts();
			// newOpp.OwnerId = u.Id;
			// update newOpp;
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'January', 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today(),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          Start_Date__c = Date.today().addDays(-7), 
	          End_Date__c = Date.today(),
	          Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

			Sales_Plan__c plan = new Sales_Plan__c(User__c = u.Id, Fleetcor_Calendar_Month__c = month.Id);
			insert plan;
		    
		    SalesDashboardNetStartsCtrl controller = new SalesDashboardNetStartsCtrl();
		    controller.init();
		}
    }

	@future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Outbound 2'];
		Integer rand = Math.round(Math.random()*100000);
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_'+rand+'@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}

	@future
	private static void createLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Outbound 2'];
		Integer rand = Math.round(Math.random()*100000);
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_'+rand+'@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u2);	   
	}

	private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
			Type = 'Customer',
			Bundesland__c = 'Austria',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		First_Pump_Date__c = Date.today().addDays(-1),
    		Hausnummer_E__c = 'test',
    		PLZ_E__c = 'test',
    		Ort_E__c = 'tet',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
    		Strasse_und_Hausnummer__c = 'tes',
    		PLZ_und_Ort__c = 'test',
    		IBAN_des_Zahlungspflichtigen__c = 'tes',
    		SWIFT_BIC__c = 'test',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		BillingStreet = 'test street',
    		BillingPostalCode = '212231',
    		BillingCity = 'test city',
    		BillingCountry = 'Austria',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);
    	insert newAccount;
	}


    private static void createOpp() {
        newOpp = new Opportunity(
            AccountId = newAccount.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Total_consumption_l_month__c = 21,
            Product__c = 'test',
            Name_of_the_payer_Account_holder__c = 'test',
            IBAN__c = 'test',
            SWIFT_BIC__c = 'test',
            Anzahl_der_Karten__c = 5,
            Angebotsdauer__c = '3 monate',
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Herkunft_Land__c = 'DE',
            StageName = 'Prospecting',
            Name = 'test opp',
            CloseDate = Date.newinstance(2017, 1, 3));
        insert newOpp;
    }


	private static void createStarts() {
		newStarts = new Starts__c(
			Account__c = newAccount.Id,
			starts__c = 71,
			client_week_number__c = 1);

		insert newStarts;
	}   
}