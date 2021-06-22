@isTest
private class ChangeOppStageByCreditCtrlTest {
	public Static User u;
	public Static Account newAccount;
	public Static Opportunity newOpp;
	public Static EmailTemplate newEmailTemplateDepositDE;
	public Static EmailTemplate newEmailTemplateInformDE;

	@isTest
    public static void testButtonForChangeStageOpp1() {    	
		Test.startTest();
			createCreditUser();
		Test.stopTest();

		System.runAs(u) {

			createEmailTemplate();
			createAccount();
			createOpp();
					

			ChangeOppStageByCreditCtrl controller = new ChangeOppStageByCreditCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingSales', 'deposit');
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Sales – Deposit', newOpp.StageName);
		}
    }


    @isTest
    public static void testButtonForChangeStageOpp2() {    	
		Test.startTest();
			createCreditUser();
		Test.stopTest();

		System.runAs(u) {

			createEmailTemplate();
			createAccount();
			createOpp();
					

			ChangeOppStageByCreditCtrl controller = new ChangeOppStageByCreditCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingSales', 'information');
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Sales – Information', newOpp.StageName);
		}
    }


    @isTest
    public static void testButtonForChangeStageOpp3() {    	
		Test.startTest();
			createCreditUser();
		Test.stopTest();

		System.runAs(u) {

			createEmailTemplate();
			createAccount();
			createOpp();
					

			ChangeOppStageByCreditCtrl controller = new ChangeOppStageByCreditCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingSales', 'amldoc');
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Sales – AML doc.', newOpp.StageName);
		}
    }


    @isTest
    public static void testButtonForChangeStageOpp4() {    	
		Test.startTest();
			createCreditUser();
		Test.stopTest();

		System.runAs(u) {

			createEmailTemplate();
			createAccount();
			createOpp();
					

			ChangeOppStageByCreditCtrl controller = new ChangeOppStageByCreditCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingSales', 'pitcit');
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Sales – PIT/CIT', newOpp.StageName);
		}
    }


    @isTest
    public static void testButtonForChangeStageOpp5() {    	
		Test.startTest();
			createCreditUser();
		Test.stopTest();

		System.runAs(u) {

			createEmailTemplate();
			createAccount();
			createOpp();
					

			ChangeOppStageByCreditCtrl controller = new ChangeOppStageByCreditCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingSales', 'tokpayment');
			newOpp.StageName = 'Pending Credit AML';
			update newOpp;
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Sales - Token payment', newOpp.StageName);
		}
    }


	/*******************************************************************************
	*  Name            : testProcessedByValidation()
	*  Summary         : test error in case of Credit didn't change bearbeitet_von__c field
	*  CreatedDate     : 03/09/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testProcessedByValidation() {    	
		Test.startTest();
			createCreditUser();
		Test.stopTest();

		System.runAs(u) {

			createAccount();
			createOpp();

			ChangeOppStageByCreditCtrl controller = new ChangeOppStageByCreditCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingSales', 'information');
			newOpp.bearbeitet_von__c = 'Autoprocessed by Sales';
			update newOpp;
			controller.init();

			System.assertEquals('Please update the field “Processed by” before returning the Opportunity to the Sales Team.', ApexPages.getMessages().get(0).getSummary());
		}
    }


	@future
	private static void createCreditUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Credit']; 
		
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

    	newAccount = new Account(
    		Name = 'test',
			Type = 'Retailer',
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
			StageName = 'Prospecting',
			Name = 'test opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Last_Owner_Change_Date__c = Date.newinstance(2016, 12, 21),
			CloseDate = Date.newinstance(2016, 12, 28)
		);
		insert newOpp;
	}


	private static void createEmailTemplate() {

		newEmailTemplateDepositDE = new EmailTemplate(
			Name = 'test name',
			Subject = 'Deposit Required',
			Body = 'test',
			TemplateType = 'Text',
			FolderId = u.Id,
			DeveloperName = 'Deposit_Required_sales_letter_DE'
		);
		insert newEmailTemplateDepositDE;

		newEmailTemplateInformDE = new EmailTemplate(
			Name = 'test name',
			Subject = 'Deposit Required',
			Body = 'test',
			TemplateType = 'Text',
			FolderId = u.Id,
			DeveloperName = 'Information_Required_sales_letter_DE'
		);
		insert newEmailTemplateInformDE;
	}
}