@isTest
private class DuplicatesLeadsControllerTest {
    @isTest
    public static void testFindDuplicates() {
    	List<Lead> leadsList = new List<Lead>();
        Lead currentLead = new Lead(
            LastName = 'Test',
            Company = 'Test',
            Country = 'Germany',
            CountryCode = 'DE',
            Anzahl_der_Fahrzeuge__c = 2,
            Beschaeftigte__c = '1-4',
            Salutation = 'Herr',
            Branche_NACE__c = 'Apotheken - 4773',
            IBAN__c = 'test IBAN',
            Steuernummer__c = 'test tax',
            Umsatzsteuer_ID__c = 'test VAT',
            Email = 'test@test.com',
            Phone = '123123123',
            City = 'test',
            Street = 'test');
        leadsList.add(currentLead);

        Lead duplicateLead = new Lead(
            LastName = 'Test',
            Company = 'Test',
            Country = 'Germany',
            CountryCode = 'DE',
            Anzahl_der_Fahrzeuge__c = 2,
            Beschaeftigte__c = '1-4',
            Salutation = 'Herr',
            Branche_NACE__c = 'Apotheken - 4773',
            IBAN__c = 'test IBAN',
            Steuernummer__c = 'test tax',
            Umsatzsteuer_ID__c = 'test VAT',
            Email = 'test@test.com',
            Phone = '123123123');
        leadsList.add(duplicateLead);
        insert leadsList;

        Account duplicateAccount = new Account(
            Name = 'test account',
            BillingCountry = 'Germany',
            Steuernummer__c = 'test tax',
            Umsatzsteuer_ID__c = 'test VAT',
            BillingCity = 'test',
            BillingStreet = 'test');
        insert duplicateAccount;

        Opportunity duplicateOpportnunity = new Opportunity(
            Name = 'test opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = duplicateAccount.Id,
            IBAN__c = 'test IBAN');
        insert duplicateOpportnunity;

        Contact duplicateContact = new Contact(
            LastName = 'test Contact',
            Phone = '123123123',
            MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
            Salutation = 'Herr',
            Email = 'test@test.com',
            AccountId = duplicateAccount.Id);
        insert duplicateContact;

		ApexPages.CurrentPage().getparameters().put('id', currentLead.Id);
		DuplicatesLeadsController controller = new DuplicatesLeadsController();

		Test.startTest();
			controller.init();
		Test.stopTest();

		System.assertEquals(1, controller.finalDuplicateLeadsList.size());
		System.assertEquals(1, controller.finalDuplicateAccountsList.size());
		System.assertEquals(1, controller.finalDuplicateOpportunitiesList.size());
		System.assertEquals(1, controller.finalDuplicateContactsList.size());
	}
}