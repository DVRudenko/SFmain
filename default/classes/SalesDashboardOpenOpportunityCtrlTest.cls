// Case1 - Case4 for Sale //
// case1 - Opportunity has overdue task, owner Opportunity = owner task
// case2 - Opportunity has NOT overdue task, owner Opportunity = owner task
// case3 - Opportunity has NOT task
// Case4 - Case5 the same only for the team leader //

@isTest
private class SalesDashboardOpenOpportunityCtrlTest {
	public Static User u1;
	public Static User u2;
	public Static Account newAccount;
	public Static Opportunity newOpp;
	public Static Task newTask;


	@isTest
    public static void testOpenOpportunutiesDashboardCase1() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u1) {
			createAccount();
			createOpp();
			createTask();

			newOpp.OwnerId = u1.Id;
			update newOpp;
			newTask.WhatId = newOpp.Id;
			newTask.OwnerId = newOpp.OwnerId;
			update newTask;

			SalesDashboardOpenOpportunityCtrl controller = new SalesDashboardOpenOpportunityCtrl();
		    controller.init();
		    System.assertEquals(1, controller.oppWithTasksForSales);
		    System.assertEquals(0, controller.oppWithoutTasksForSales);
		}
	}


	@isTest
    public static void testOpenOpportunutiesDashboardCase2() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u1) {
			createAccount();
			createOpp();
			createTask();

			newOpp.OwnerId = u1.Id;
			update newOpp;
			newTask.WhatId = newOpp.Id;
			newTask.OwnerId = newOpp.OwnerId;
			newTask.ActivityDate = Date.today().addDays(2);
			update newTask;

			SalesDashboardOpenOpportunityCtrl controller = new SalesDashboardOpenOpportunityCtrl();
		    controller.init();
		    System.assertEquals(0, controller.oppWithTasksForSales);
		    System.assertEquals(0, controller.oppWithoutTasksForSales);
		}
	}

	@isTest
    public static void testOpenOpportunutiesDashboardCase3() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u1) {
			createAccount();
			createOpp();

			newOpp.OwnerId = u1.Id;
			update newOpp;

			SalesDashboardOpenOpportunityCtrl controller = new SalesDashboardOpenOpportunityCtrl();
		    controller.init();
		    System.assertEquals(0, controller.oppWithTasksForSales);
		    System.assertEquals(1, controller.oppWithoutTasksForSales);
		}
	}

	@isTest
    public static void testOpenOpportunutiesDashboardCase4() {
        Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

	    System.runAs(u2) {
			createAccount();
			createOpp();

			newOpp.OwnerId = u1.Id;
			update newOpp;

			SalesDashboardOpenOpportunityCtrl controller = new SalesDashboardOpenOpportunityCtrl();
		    controller.init();
		    System.assertEquals(0, controller.quantityOppWithTasksForTeamlead.get(u1.Id));
		    System.assertEquals(1, controller.quantityOppWithoutTasksForTeamlead.get(u1.Id));
		}
	}


	@isTest
    public static void testOpenOpportunutiesDashboardCase5() {
        Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

	    System.runAs(u2) {
			createAccount();
			createOpp();
			createTask();

			newOpp.OwnerId = u1.Id;
			update newOpp;
			newTask.WhatId = newOpp.Id;
			newTask.OwnerId = u2.Id;
			update newTask;

			SalesDashboardOpenOpportunityCtrl controller = new SalesDashboardOpenOpportunityCtrl();
		    controller.init();
		    System.assertEquals(0, controller.quantityOppWithTasksForTeamlead.get(u1.Id));
		    System.assertEquals(1, controller.quantityOppWithoutTasksForTeamlead.get(u1.Id));
		}
	}


    @future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];
		
		u1 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_123_test1@test.com',
		   	Alias = 'tnu',
			Email='test_sales@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='testFirstName',
			Lastname='testLastName',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u1);	   
	}


	@future
	private static void createLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_45_test2@test.com',
		   	Alias = 'tntl',
			Email='test_teamlead@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='John',
			Lastname='Johnson',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
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


    private static void createOpp() {
        newOpp = new Opportunity(
            AccountId = newAccount.Id,
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Anzahl_der_Karten__c = 5,
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            Herkunft_Land__c = 'DE',
            StageName = 'Prospecting',
            Name = 'test opp',
            Product__c = 'test product',
            Disable_for_KPI__c = FALSE,
            Last_Owner_Change_Date__c = Datetime.now().addDays(-10),
            CloseDate = Date.today().addDays(-5)
        );
        insert newOpp;
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
}