@isTest
private class DublicateLeadsForSalesControllerTest {
	@isTest
    public static void searchDublicatesTest() {
    	Lead lead = new Lead(Country = 'Germany', FirstName = 'firstName', LastName = 'test', Company = 'test', Email = 'test@test.com', PostalCode = '123');
    	insert lead;
    	ApexPages.currentPage().getParameters().put('id', lead.Id);
    	Contact contact = new Contact(Salutation = 'Herr', LastName = 'test', MailingPostalCode = '123');
    	insert contact;
    	Account account = new Account(Name = 'test', BillingPostalCode = '123', BillingCountry = 'Germany');
    	insert account;
    	Opportunity opportunity = new Opportunity(Name = 'test', StageName = 'Prospecting', CloseDate = date.today());
    	insert opportunity;
    	DublicateLeadsForSalesController controller = new DublicateLeadsForSalesController();
    	controller.isLeadLastNameSelected = true;
    	controller.isLeadEmailDomainSelected = true;
        controller.isZipCodeSelected = true;
    	controller.init();
    	controller.searchDublicates();
    	System.assertEquals(controller.matchingLeads.size(), 0);
    	System.assertEquals(controller.matchingContacts.size(), 1);
    	System.assertEquals(controller.matchingAccounts.size(), 1);
    	System.assertEquals(controller.matchingOpportunities.size(), 1);
    }
}