@isTest
private class ConversionRateReportTest {
	public static User u;
    public static Account newAccount;
    public static Opportunity newOpp;
    public static Lead newLead;
    public static Email_Notifications__c notification;

    @isTest
    public static void testSalesDashboard() {
		Test.startTest();
			createSalesUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createLead();
			createNotification();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
				insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'July', 
				Start_Date__c = Date.today().addDays(-15),
				End_Date__c = Date.today().addDays(15),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(4),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			Sales_Plan__c plan = new Sales_Plan__c(User__c = u.Id, Fleetcor_Calendar_Month__c = month.Id);
			insert plan;

			Lead testlead = [SELECT OwnerId FROM Lead WHERE Id = :newlead.Id LIMIT 1];
			system.assertEquals(testlead.OwnerId, u.Id);

			Datetime mydatetime = Date.today();
			Test.setCreatedDate(newlead.Id, mydatetime);

		    ConversionRateReport controller = new ConversionRateReport();
		    ApexPages.currentPage().getParameters().put('year', '2017');
		    ApexPages.currentPage().getParameters().put('period', week.Id);
		    controller.selectedUserId = u.Id;
		    controller.init();
		    controller.getuserOptions();
		    controller.getCurrentWeeks();
		    controller.fixCreditCheck();
		}
    }

    @future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}

	private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
    		GFN_Nr__c  = '123',
			Type = 'Customer',
			Bundesland__c = 'Germany',
			BillingStreet = 'test street',
			BillingPostalCode = '1231',
			BillingCity = 'Berlin',
			BillingCountry = 'Germany',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		Hausnummer_E__c = 'test',
    		PLZ_E__c = 'test',
    		Ort_E__c = 'tet',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
    		Strasse_und_Hausnummer__c = 'tes',
    		PLZ_und_Ort__c = 'test',
    		IBAN_des_Zahlungspflichtigen__c = 'tes',					
    		SWIFT_BIC__c = 'test',
    		Land__c = 'test land',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);
    	insert newAccount;
	}

    private static void createOpp() {
        newOpp = new Opportunity(
            OwnerId = u.Id,
            AccountId = newAccount.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Sec_Channel__c = 'Inbound',
            Anzahl_der_Karten__c = 5,
            Gruende_verloren__c = 'test',
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Total_consumption_l_month__c = 123,
            Name_of_the_payer_Account_holder__c = 'test',
            Last_Owner_Change_Date__c = Date.today(),
            Angebotsdauer__c = '3 Monate',
            IBAN__c = '2131',
            SWIFT_BIC__c = '1234124',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            StageName = 'Prospecting',
            Product__c = 'None',
            Name = 'test opp',
            Disable_for_KPI__c = FALSE,
            CloseDate = Date.today());
        insert newOpp;
    }

	private static void createLead() {
		newLead = new Lead(
			OwnerId = u.Id,
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test company',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = 'test',
			Anzahl_der_Fahrzeuge__c = 2, 
			FirstName = 'testName', 
			LastName = 'testFam',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Last_Owner_Change_Date__c = Date.today(),
            Quali_Status__c = 'Refused to talk',
            Branche_NACE__c = 'Apotheken - 4773',
            Beschaeftigte__c = '1-4',
            Disable_for_KPI__c = FALSE           
            );
		insert newLead;
	} 

	private static void createNotification() {
		notification = new Email_Notifications__c(
			Name = 'Closed Won Opportunity Send to Zoho',
    		Email__c = 'test@test.com'          
            );
		insert notification;
	}     
}