// case1 - Opportunity has overdue task, owner Opportunity = owner task
// case2 - Opportunity has NOT overdue task, owner Opportunity = owner task
// case3 - Opportunity has NOT task
// case4 - Opportunity has overdue task, owner Opportunity != owner task

@isTest
private class OpenOpportunityReportTest {
	public Static Account newAccount;
    public Static Opportunity newOpp;
	public Static Task newTask;


	@isTest
    public static void testOpenOpportunityReportCase1() {
    	createAccount();
    	createOpp();
    	createTask();

        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
        newOpp.OwnerId = userId;
		update newOpp;
		newTask.WhatId = newOpp.Id;
		newTask.OwnerId = newOpp.OwnerId;
		update newTask;

		OpenOpportunityReport controller = new OpenOpportunityReport();
		controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(1, controller.numberOfOppWithTasks);
	    System.assertEquals(0, controller.numberOfOppWithoutTasks);
    }


    @isTest
    public static void testOpenOpportunityReportCase2() {
    	createAccount();
    	createOpp();
    	createTask();

        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
        newOpp.OwnerId = userId;
		update newOpp;
		newTask.WhatId = newOpp.Id;
		newTask.OwnerId = newOpp.OwnerId;
		newTask.ActivityDate = Date.today().addDays(2);
		update newTask;

		OpenOpportunityReport controller = new OpenOpportunityReport();
		controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(0, controller.numberOfOppWithTasks);
	    System.assertEquals(0, controller.numberOfOppWithoutTasks);
    }


    @isTest
    public static void testOpenOpportunityReportCase3() {
    	createAccount();
    	createOpp();

        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
        newOpp.OwnerId = userId;
		update newOpp;

		OpenOpportunityReport controller = new OpenOpportunityReport();
		controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(0, controller.numberOfOppWithTasks);
	    System.assertEquals(1, controller.numberOfOppWithoutTasks);
    }


    @isTest
    public static void testOpenOpportunityReportCase4() {
    	createAccount();
    	createOpp();
    	createTask();

        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
		newOpp.OwnerId = userId;
		update newOpp;
		newTask.WhatId = newOpp.Id;
		update newTask;

		OpenOpportunityReport controller = new OpenOpportunityReport();
		controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(0, controller.numberOfOppWithTasks);
	    System.assertEquals(1, controller.numberOfOppWithoutTasks);
    }


    private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
    		GFN_Nr__c  = '123',
			Type = 'Customer',
			Bundesland__c = 'Austria',
			BillingCountry = 'Austria',
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