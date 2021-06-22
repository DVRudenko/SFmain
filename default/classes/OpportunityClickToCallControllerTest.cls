@isTest
private class OpportunityClickToCallControllerTest {
    @isTest
    private static void testDialoga() {
    	Test.setMock(HttpCalloutMock.class, new DialogaCalloutMock());
    	
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

    	Contact contact = new Contact(
    		Salutation = 'Mr.',
    		LastName = 'test',
    		Phone = '+1231231231',
    		AccountId = newAccount.Id);
    	insert contact;

    	Opportunity opportunity = new Opportunity(
    		Name = 'test',
    		StageName = 'Prospecting',
    		CloseDate = Date.today());
    	insert opportunity;

    	OpportunityContactRole role = new OpportunityContactRole(
    		OpportunityId = opportunity.Id,
    		ContactId = contact.Id,
    		IsPrimary = true);
    	insert role;

		ApexPages.CurrentPage().getparameters().put('id', opportunity.id);

		ApexPages.StandardController sc = new ApexPages.standardController(opportunity);
		OpportunityClickToCallController sic = new OpportunityClickToCallController(sc);
		sic.init();
		Test.startTest();
			sic.doDialogaCall();
		Test.stopTest();
    }

}