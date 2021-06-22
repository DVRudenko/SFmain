@isTest
private class ConvertToE2ECtrlTest {
	public Static Opportunity opportunity;

	@isTest
    static void testConvertToE2EButton() {
        createE2ERecords();
        createCustomSettings();

        ConvertToE2ECtrl controller = new ConvertToE2ECtrl();
		ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
		controller.init();

		List<Opportunity> oppList = [SELECT E2E_Status__c, E2E_Sales_Type__c, E2E__c FROM Opportunity WHERE Id = :opportunity.Id];
		System.assert(oppList.get(0).E2E__c);
		System.assertEquals('In progress', oppList.get(0).E2E_Status__c);
		System.assertEquals('Manual upgraded to E2E', oppList.get(0).E2E_Sales_Type__c);
    }

    @isTest
    static void alreadyE2ETest() {
        createE2ERecords();
        opportunity.E2e__c = true;
        update opportunity;
        createCustomSettings();

        ConvertToE2ECtrl controller = new ConvertToE2ECtrl();
        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
        controller.init();

        List<Opportunity> oppList = [SELECT LeadSource, E2E_Status__c, E2E_Sales_Type__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertNotEquals('Manual upgraded to E2E', oppList.get(0).E2E_Sales_Type__c);
    }

    @isTest
    static void actionIsNotAvailableTest() {
        createE2ERecords();
        opportunity.StageName = 'Closed Won';
        update opportunity;
        createCustomSettings();

        ConvertToE2ECtrl controller = new ConvertToE2ECtrl();
        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
        controller.init();

        List<Opportunity> oppList = [SELECT LeadSource, E2E_Status__c, E2E_Sales_Type__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertNotEquals('Manual upgraded to E2E', oppList.get(0).E2E_Sales_Type__c);
    }

    @isTest
    static void testConvertToE2EButtonJITB() {
        createE2ERecords();
        opportunity.Sec_Channel__c = 'JITB';
        opportunity.Channel__c = 'Fax';
        update opportunity;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url+'/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url+'/e2eform?country=Germany';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url+'/e2ejitbde';
        insert settingsE2EShortUrl;

        Account retailerAccount = new Account(
                OBN__c = '1233',
                Name = 'ValidOBN',
                BillingCountry = 'Germany',
                BillingStreet = 'test',
                BillingCity = 'test',
                Type = 'Customer',
                Strasse_E__c = 'Strasse',
                Ort_E__c = 'Ort',
                Land_E__c = 'Land',
                E2E__c = true);
        insert retailerAccount;

        Partner newPartner = new Partner();
        newPartner.AccountToId = retailerAccount.Id;
        newPartner.OpportunityId = opportunity.Id;
        newPartner.Role = 'Multiplier';
        insert newPartner;

        createCustomSettings();

        ConvertToE2ECtrl controller = new ConvertToE2ECtrl();
        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
        controller.init();
    }


    private static void createE2ERecords() {
    	Account account = new Account(
            Name = 'TEST',
            BillingCountry = 'Germany',
            ShippingCountry = 'Germany',
            Type = 'Customer'
        );
        insert account;

        opportunity = new Opportunity(
        	Name = 'TEST',
            StageName = 'Prospecting',
            Product__c = '',
            AccountId = account.Id,
            CloseDate = Date.today(),
            Sec_Channel__c = 'Inbound'
        );
        insert opportunity;

        Contact contact = new Contact(
            Salutation = 'Mr',
            FirstName = 'JOHN',
            LastName = 'WICK',
            AccountId = account.Id,
            Email = 'test@test.com',
            E2E__c = true,
            MailingCountry = 'Germany'
        );
        insert contact;

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = opportunity.Id,
            ContactId = contact.Id,
            IsPrimary = true
        );
        insert oppContactRole;
    }

    private static void createCustomSettings() {
    	E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
        	Name = 'E2EForm',
        	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
        	paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
        	PSPID__c = 'fleetcorTEST',
        	SHA_KeyIn__c = 'FleetcorTest!12@',
        	SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;
    }
}