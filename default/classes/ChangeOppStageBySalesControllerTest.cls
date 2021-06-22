@isTest
private class ChangeOppStageBySalesControllerTest {
	public Static User u;
	public Static Account newAccount;
	public Static Opportunity newOpp;
	public Static EmailTemplate newEmailTemplate;


	@isTest
    public static void testButtonForPendingCredit1() {    	
		Test.startTest();
			createSalesUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
					
			ChangeOppStageBySalesController controller = new ChangeOppStageBySalesController();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingCredit', 'pencredit');
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Credit', newOpp.StageName);
		}
    }

	@isTest
    public static void testButtonForPendingCredit2() {    	
		Test.startTest();
			createSalesUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createEmailTemplate();
					
			ChangeOppStageBySalesController controller = new ChangeOppStageBySalesController();
			ApexPages.currentPage().getParameters().put('id', newOpp.Id);
			ApexPages.currentPage().getParameters().put('pendingCredit', 'pencreditTokpayment');
			newOpp.StageName = 'Pending Sales - Token payment';
			update newOpp;
			controller.init();
			newOpp = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
		    System.assertEquals('Pending Credit - Token payment', newOpp.StageName);
		}
    }

   @future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='API Only'];
		
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
            Total_consumption_l_month__c = 75,
            Name_of_the_payer_Account_holder__c = 'name test',
            IBAN__c = '321',
            SWIFT_BIC__c = '312',
            Kraftstoffverbrauch_Liter_Monat__c = 2,
            Anzahl_der_Karten__c = 5,
            Derzeitige_Zahlungsmethode__c = 'Bank',
            Kundensegment__c = 'Campaign_1',
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Angebotsdauer__c = 'test',
            StageName = 'Pending Sales – Deposit',
            Name = 'test opp',
            Product__c = 'None',
            Disable_for_KPI__c = FALSE,
            Last_Owner_Change_Date__c = Date.newinstance(2016, 12, 21),
            CloseDate = Date.newinstance(2016, 12, 28)
        );
        insert newOpp;
    }

	private static void createEmailTemplate() {
		newEmailTemplate = new EmailTemplate(
			Name = 'test name',
			Subject = 'Token payment',
			Body = 'test',
			TemplateType = 'Text',
			FolderId = u.Id,
			DeveloperName = 'Waiting_for_token_payment_credit_letters'
		);
		insert newEmailTemplate;
	}
}