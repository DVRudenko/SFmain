@isTest
private class SalesDashboardApprovalRateCtrlTest {
	public Static User u;
	public Static User u2;
    public Static Account newAccount;
    public Static Opportunity newOpp;
    public Static Opportunity convOpp;
    public Static Opportunity convOpp2;
    public Static Lead newLead;
    public Static Lead newLead2;

    @isTest
    public static void testSalesDashboard() {    	
		Test.startTest();
			createSalesUser('Sales Inbound', 'Salesteam Inbound');
		Test.stopTest();

		System.runAs(u) {
			OpportunityTriggerHandler.enablesTrigger = false;
			ContactTriggerHandler.enablesTrigger = false;
			AccountTriggerHandler.enablesTrigger = false;
	    	Email_Notifications__c notification = new Email_Notifications__c(
	    		Name = 'Closed Won Opportunity Send to Zoho',
	    		Email__c = 'test@test.com');
	    	insert notification;

			createAccount();
			createLead();
			createOpp('Prospecting');
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
	            Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
	            Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;
    	
		    SalesDashboardApprovalRateCtrl controller = new SalesDashboardApprovalRateCtrl();
		    controller.selectedPeriod = week.Id;
		    controller.getCurrentWeeks();
		    controller.init();
		    controller.getIndividualARButtons();
		    controller.getYears();
		    controller.changeYear();
		}
    }

    @isTest
    public static void testLeadDashboard() {
		Test.startTest();
			createSalesUser('Sales Inbound', 'Salesteam Inbound');
			createLeadUser('Salesteamleiter Inbound', 'Teamleiter Inbound');
		Test.stopTest();

		System.runAs(u2) {
			OpportunityTriggerHandler.enablesTrigger = false;
			ContactTriggerHandler.enablesTrigger = false;
			AccountTriggerHandler.enablesTrigger = false;
			createAccount();
			createOpp('Prospecting');
			createLead();
			convOpp.Home_Station__c = 'test';
			convOpp.OwnerId = u.Id;
			convOpp.Last_Owner_Change_Date__c = Date.newinstance(2016, 12, 27);
			convOpp.Disable_for_KPI__c = FALSE;
			update convOpp;
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
	            Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
	            Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;
		    
		    SalesDashboardApprovalRateCtrl controller = new SalesDashboardApprovalRateCtrl();
		    controller.selectedPeriod = week.Id;
		    controller.init();
		    controller.getCurrentWeeks();
		}
    }

    @future
	private static void createSalesUser(String profileName, String userRoleName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = :userRoleName];
		
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'batman',
			Email = 'bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Bruce',
			Lastname = 'Wayne',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(u);	   
	}

	@future
	private static void createLeadUser(String profileName, String userRoleName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = :userRoleName];
		
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_23423_test2@test.com',
		   	Alias = 'batman',
			Email = 'bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Bruce',
			Lastname = 'Wayne',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(u2);
	}

	private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
    		GFN_Nr__c  = '123',
			Type = 'Customer',
			BillingCountry = 'Austria',
			Bundesland__c = 'Austria',
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

    private static void createOpp(String stageName) {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpp = new Opportunity(
            RecordTypeId = rt.Id,
            AccountId = newAccount.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Anzahl_der_Karten__c = 5,
            Sec_Channel__c = 'Inbound',
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            StageName = stageName,
            Name = 'test opp',
            Product__c = 'None',
            Disable_for_KPI__c = FALSE,
            Last_Owner_Change_Date__c = Date.newinstance(2016, 12, 27),
            CloseDate = Date.newinstance(2016, 12, 28)
        );
        insert newOpp;
    }

    private static void createLead() {
        newLead = new Lead(
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
            Quali_Status__c = 'Refused to talk',
            Branche_NACE__c = 'Apotheken - 4773',
            Beschaeftigte__c = '1-4',
            Disable_for_KPI__c = FALSE           
            );
		insert newLead;
	
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(newLead.id);

		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		lc.setConvertedStatus(convertStatus.MasterLabel); 
		Database.LeadConvertResult lcr = Database.convertLead(lc);

		String newOppId = [SELECT ConvertedOpportunityId FROM Lead WHERE Id = :newLead.Id].ConvertedOpportunityId; 

		convOpp = [
			SELECT Name, StageName, Herkunft_Land__c, Angebotsdauer__c, Kraftstoffverbrauch_Liter_Monat__c, Anzahl_der_Karten__c, Derzeitige_Zahlungsmethode__c,
			Kundensegment__c, Zahlungsart__c, Zahlungsziel__c, CloseDate, Last_Owner_Change_Date__c, Home_Station__c 
			FROM Opportunity
			WHERE Id = :newOppId];
	}
}