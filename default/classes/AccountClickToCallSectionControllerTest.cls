@isTest
private class AccountClickToCallSectionControllerTest {
    @isTest
    private static void testSTD1() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Germany',
            BillingCountryCode = 'DE',
    		Phone = '049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD2() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Austria',
            BillingCountryCode = 'AT',
    		Phone = '049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD3() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Poland',
            BillingCountryCode = 'PL',
    		Phone = '049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD4() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Netherlands',
            BillingCountryCode = 'NL',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD5() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Belgium-FR',
            BillingCountryCode = 'BEFR',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD6() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'France',
            BillingCountryCode = 'FR',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD7() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Hungary',
            BillingCountryCode = 'HU',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD8() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Luxembourg',
            BillingCountryCode = 'LU',
            Phone = '+0352123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD9() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Czech Republic',
            BillingCountryCode = 'CZ',
            Phone = '04202123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD10() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Slovakia',
            BillingCountryCode = 'SK',
            Phone = '04212123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD11() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Switzerland-DE',
            BillingCountryCode = 'CHDE',
            Phone = '+04212123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }     
}