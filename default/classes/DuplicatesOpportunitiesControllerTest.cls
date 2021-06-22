@isTest
private class DuplicatesOpportunitiesControllerTest {
	
    @isTest
    public static void testFindDuplicates() {
    	List<Account> accountsList = new List<Account>();
    	Account currentAccount = new Account(
            Name = 'test account',
            BillingCountry = 'Germany',
            Steuernummer__c = 'test tax',
            Umsatzsteuer_ID__c = 'test VAT',
            BillingCity = 'test',
            BillingStreet = 'test');
        accountsList.add(currentAccount);

        Account duplicateAccount = new Account(
            Name = 'test account',
            BillingCountry = 'Germany',
            Steuernummer__c = 'test tax 2',
            Umsatzsteuer_ID__c = 'test VAT',
            BillingCity = 'test',
            BillingStreet = 'test');
        accountsList.add(duplicateAccount);

        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity currentOpportnunity = new Opportunity(
            Name = 'test opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = currentAccount.Id,
            IBAN__c = 'test IBAN');
        opportunitiesList.add(currentOpportnunity);

        Opportunity duplicateOpportnunity = new Opportunity(
            Name = 'test opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            IBAN__c = 'test IBAN',
            accountId = duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportnunity);

        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact currentContact = new Contact(
        	FirstName = 'test',
            LastName = 'test Contact',
            Phone = '+49123123123',
            Salutation = 'Herr',
            AccountId = currentAccount.Id,
            Email = 'test@test.com');
        contactsList.add(currentContact);

        Contact duplicateContact = new Contact(
        	FirstName = 'test',
            LastName = 'test Contact',
            Phone = '+49123123123',
            Salutation = 'Herr',
            Email = 'test@test.com',
            accountId = duplicateAccount.Id);
        contactsList.add(duplicateContact);

        insert contactsList;

        OpportunityContactRole contactRole = new OpportunityContactRole(
        	ContactId = currentContact.Id,
        	OpportunityId = currentOpportnunity.Id);
        insert contactRole;

		ApexPages.CurrentPage().getparameters().put('id', currentOpportnunity.Id);
		DuplicatesOpportunitiesController controller = new DuplicatesOpportunitiesController();

		Test.startTest();
			controller.init();
		Test.stopTest();

		System.assertEquals(1, controller.finalDuplicateAccountsList.size());
		System.assertEquals(1, controller.finalDuplicateOpportunitiesList.size());
		System.assertEquals(1, controller.finalDuplicatesContactsList.size());
	}
}