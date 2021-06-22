@isTest
private class AccountKamReportCtrlTest {
    public Static User u;
    public Static Account newAccount;
    public Static Task newTask;


    //valid case: No meeting tasks.
    @isTest
    public static void kamAccReportTest1 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {

			createAccount();

			AccountKamReportCtrl controller = new AccountKamReportCtrl();
			Apexpages.currentPage().getParameters().put('userid', u.Id);
			controller.init();

		    System.assertEquals(1, controller.quantityAllAccounts);
		    System.assertEquals(1, controller.quantityAccountsGermany);
		    System.assertEquals(0, controller.quantityAccountsAustria);
		    System.assertEquals(0, controller.quantityAccountsSwitzerlandDE);
		}
    }


    //valid case: The last task of the meeting is NOT in a given period.
    @isTest
    public static void kamAccReportTest2 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {

			createAccount();
			createTask();
			newTask.ActivityDate = Date.today().addDays(-100);
			update newTask;

			AccountKamReportCtrl controller = new AccountKamReportCtrl();
			Apexpages.currentPage().getParameters().put('userid', u.Id);
			controller.init();

		    System.assertEquals(1, controller.quantityAllAccounts);
		    System.assertEquals(1, controller.quantityAccountsGermany);
		    System.assertEquals(0, controller.quantityAccountsAustria);
		    System.assertEquals(0, controller.quantityAccountsSwitzerlandDE);
		}
    }


    //invalid case: The last task of the meeting in a given period.
    @isTest
    public static void kamAccReportTest3 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {

			createAccount();
			createTask();

			AccountKamReportCtrl controller = new AccountKamReportCtrl();
			Apexpages.currentPage().getParameters().put('userid', u.Id);
			controller.init();

		    System.assertEquals(0, controller.quantityAllAccounts);
		    System.assertEquals(0, controller.quantityAccountsGermany);
		    System.assertEquals(0, controller.quantityAccountsAustria);
		    System.assertEquals(0, controller.quantityAccountsSwitzerlandDE);
		}
    }


    //invalid case: BilingCountry != Germany, Austria or Switzerland-DE.
    @isTest
    public static void kamAccReportTest4 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {

			createAccount();
			createTask();
			newTask.ActivityDate = Date.today().addDays(-100);
			update newTask;
			newAccount.BillingCountry = 'Poland';
			update newAccount;

			AccountKamReportCtrl controller = new AccountKamReportCtrl();
			Apexpages.currentPage().getParameters().put('userid', u.Id);
			controller.init();

		    System.assertEquals(0, controller.quantityAllAccounts);
		    System.assertEquals(0, controller.quantityAccountsGermany);
		    System.assertEquals(0, controller.quantityAccountsAustria);
		    System.assertEquals(0, controller.quantityAccountsSwitzerlandDE);
		}
    }


    @future
	private static void createKAM () {
		Profile p = [SELECT Id FROM Profile WHERE Name='Key Account Manager']; 
		
		u = new User(
			ProfileId = p.Id,
			isActive = TRUE,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'kam',
			Email='manager.test@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='test',
			Lastname='test',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago');

		Database.insert(u);	   
	}


	private static void createAccount() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Retailer'];

    	newAccount = new Account(
    		Name = 'test',
			Type = 'Retailer',
			RecordTypeId = rt.Id,
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
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		BillingStreet = 'test street',
    		BillingPostalCode = '212231',
    		BillingCity = 'test city',
    		BillingCountry = 'Germany',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);

    	insert newAccount;
    	Datetime createdDate = Date.newinstance( 2016, 12, 27 );
		Test.setCreatedDate(newAccount.Id, createdDate);
	}


	private static void createTask() {
		RecordType rtTask = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Task' AND Name = 'CCS Tasks'];

		newTask = new Task(
			RecordTypeId = rtTask.Id,
			OwnerId = u.Id,		
			Subject = 'Meeting',
			Type = 'Call',
			Status = 'Completed',
			Priority = 'Normal',
			WhatId = newAccount.Id,
			ActivityDate = Date.today().addDays(-10));

		insert newTask;
    	Datetime createdDate = Date.today().addDays(-150);
		Test.setCreatedDate(newTask.Id, createdDate);
	}
}