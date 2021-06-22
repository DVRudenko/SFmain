@isTest
private class ContactClickToCallSectionControllerTest {
    @isTest
    private static void testSTD1() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD2() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Austria',
            MailingCountryCode = 'AT',
    		Salutation = 'Herr',
    		Phone = '049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD3() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Poland',
            MailingCountryCode = 'PL',
    		Salutation = 'Herr',
    		Phone = '049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD4() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Netherlands',
            MailingCountryCode = 'NL',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD5() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Belgium-FR',
            MailingCountryCode = 'BEFR',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD6() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'France',
            MailingCountryCode = 'FR',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD7() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Hungary',
            MailingCountryCode = 'HU',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD8() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Luxembourg',
            MailingCountryCode = 'LU',
            Salutation = 'Herr',
            Phone = '+0352123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD9() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Czech Republic',
            MailingCountryCode = 'CZ',
            Salutation = 'Herr',
            Phone = '04202123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD10() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Slovakia',
            MailingCountryCode = 'SK',
            Salutation = 'Herr',
            Phone = '04212123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD11() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Switzerland-DE',
            MailingCountryCode = 'CHDE',
            Salutation = 'Herr',
            Phone = '+04212123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }
}