@isTest
private class DuplicatesAccountsControllerTest {
    /*valid case: There are duplicate field (newAccount.Umsatzsteuer_ID__c = newAccount2.Umsatzsteuer_ID__c)
    										newAccount.Steuernummer__c = NULL, newAccount2.Steuernummer__c = NULL*/
	@isTest
    public static void dupsAccTest1() {
        Account newAccount = new Account(
    		Name = 'test',
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
    		BillingStreet = 'test str.',
    		Umsatzsteuer_ID__c = '7654321',
    		BillingPostalCode = '212231',
    		BillingCity = 'test city',
    		BillingCountry = 'Austria',
    		Kraftstoffverbrauch_Liter_Monat__c = 2
		);
    	insert newAccount;

    	Account newAccount2 = new Account(
    		Name = 'test2',
			Bundesland__c = 'Germany',
			Beschaeftigte__c = '2-7',
    		Strasse_E__c = 'test2',
    		Hausnummer_E__c = 'test2',
    		PLZ_E__c = 'test2',
    		Ort_E__c = 'test',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test2',
    		Strasse_und_Hausnummer__c = 'tes2',
    		PLZ_und_Ort__c = 'test2',
    		IBAN_des_Zahlungspflichtigen__c = 'tes2',
    		SWIFT_BIC__c = 'test2',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		BillingStreet = 'test street',
    		Umsatzsteuer_ID__c = '7654321',
    		BillingPostalCode = '12343',
    		BillingCity = 'test',
    		BillingCountry = 'Germany',
    		Kraftstoffverbrauch_Liter_Monat__c = 7
		);
    	insert newAccount2;

    	ApexPages.CurrentPage().getparameters().put('id', newAccount.id);
    	ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		DuplicatesAccountsController dupAccController = new DuplicatesAccountsController(sc);
		dupAccController.init();
		System.assertEquals(1, dupAccController.finalDupesAccountsList.size());
    }

    /*invalid case: There are duplicate field (newAccount.Name = newAccount2.Name) */

	@isTest
    public static void dupsAccTest2() {
        Account newAccount = new Account(
    		Name = 'test',
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
    		Steuernummer__c = '321',
    		Umsatzsteuer_ID__c = '7654321',
    		BillingPostalCode = '212231',
    		BillingCity = 'test city',
    		BillingCountry = 'Austria',
    		Kraftstoffverbrauch_Liter_Monat__c = 2
		);
    	insert newAccount;

    	Account newAccount2 = new Account(
    		Name = 'test',
			Bundesland__c = 'Germany',
			Beschaeftigte__c = '2-7',
    		Strasse_E__c = 'test2',
    		Hausnummer_E__c = 'test2',
    		PLZ_E__c = 'test2',
    		Ort_E__c = 'test',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test2',
    		Strasse_und_Hausnummer__c = 'tes2',
    		PLZ_und_Ort__c = 'test2',
    		IBAN_des_Zahlungspflichtigen__c = 'tes2',
    		SWIFT_BIC__c = 'test2',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		BillingStreet = 'test str.',
    		Steuernummer__c = '123',
    		Umsatzsteuer_ID__c = '1234567',
    		BillingPostalCode = '12343',
    		BillingCity = 'test',
    		BillingCountry = 'Germany',
    		Kraftstoffverbrauch_Liter_Monat__c = 7
		);
    	insert newAccount2;

    	ApexPages.CurrentPage().getparameters().put('id', newAccount.id);
    	ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		DuplicatesAccountsController dupAccController = new DuplicatesAccountsController(sc);
		dupAccController.init();
		System.assertEquals(1, dupAccController.finalDupesAccountsList.size());
    }
}