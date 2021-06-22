@isTest
private class LeadClickToCallSectionControllerTest {
    @isTest
    private static void testDialoga() {
    	Test.setMock(HttpCalloutMock.class, new DialogaCalloutMock());
    	
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+049123123',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
		sic.doDialogaCall();
    }

    @isTest
    private static void testSTD1() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+049123123',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
		sic.makeacall();
    }

    @isTest
    private static void testSTD_Nederland() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Netherlands');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+031(0)123123',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_France() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'France');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+033(0)123123',
			Country = 'France',
			CountryCode = 'FR',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_Osterreich() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Austria');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+043(0)123123',
			Country = 'Austria',
			CountryCode = 'AT',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_Polska() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Poland');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+048(0)123123',
			Country = 'Poland',
			CountryCode = 'PL',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_LU() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Luxembourg');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0352(0)123123',
			Country = 'Luxembourg',
			CountryCode = 'LU',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_CH() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Switzerland-DE');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+041(0)123123',
			Country = 'Switzerland-DE',
			CountryCode = 'CHDE',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_CZ() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Czech Republic');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0420(0)123123',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_SK() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Slovakia');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0421(0)123123',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_BEFR() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Belgium-FR');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0421(0)123123',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_HU() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Hungary');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0421(0)123123',
			Country = 'Hungary',
			CountryCode = 'HU',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }
}