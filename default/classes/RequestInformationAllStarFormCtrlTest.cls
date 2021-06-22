@isTest
private class RequestInformationAllStarFormCtrlTest {
	public Static Account newAccount;

    @isTest
    public static void testRequestInformation() { 
        createAccount();

        RequestInformationAllStarFormCtrl controller = new RequestInformationAllStarFormCtrl();
        ApexPages.currentPage().getParameters().put('id', newAccount.Id);
        controller.init();
        controller.prefillingEmail();
        controller.sendEmail();
     
    }

    private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
			Type = 'AllStar',
			Bundesland__c = 'Austria',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		Hausnummer_E__c = 'test',
            Allstar_Email__c = 'test@test.com',
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
}