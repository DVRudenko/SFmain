@isTest
private class PayUOrderGenerationTest {

	@testSetup
    static void createDataForTest() {
    	E2E_PayU_Settings__c payUSettings = new E2E_PayU_Settings__c(
    		Name = 'Poland',
    		API_Endpoint__c = 'https://secure.snd.payu.com',
    		Client_Id__c = '356975',
    		Client_Secret__c = '8d2da48cbb22b1a0b9dac3dc62262987',
    		Company_Id__c = 236039,
    		IsActive__c = true,
    		notifyUrl__c = 'https://e2e-e2efleetcor.cs101.force.com',
    		Pos_Id__c = '356975',
    		Second_key_MD5__c = 'a85b502dfbc3c010b1746ed8cb2a2b6f',
    		Shop_Id__c = 'Fa1uzXfU');
    	insert payUSettings;

    	E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
        	Name = 'E2EFormPL',
        	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
        	paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
        	PSPID__c = 'fleetcorTEST',
        	SHA_KeyIn__c = 'FleetcorTest!12@',
        	SHA_KeyOut__c = 'IngenFleetTest1!');
    	insert e2eKeysApi;

    	Account account = new Account(
			Name = 'Test',
            BillingCountry = 'Poland',
            ShippingCountry = 'Poland',
            Type = 'Customer',
            E2E__c = true);
    	insert account;

    	Opportunity opportunity = new Opportunity(
    		Name = 'Test',
    		StageName = 'Pending Sales – Deposit',
    		CurrencyIsoCode = 'PLN',
    		Security_Amount_To_Pay__c = 1700,
    		E2E_Active_Step__c = 5,
    		E2E_Active_Substep__c = 'Congratulations',
    		E2E_payment_status__c = 'CANCEL',
    		Device_Type__c = 'Desktop',
    		CloseDate = Date.today(),
    		AccountId = account.Id);
    	insert opportunity;

    	Contact contact = new Contact(
    		Email = 'john@wick.com',
    		Phone = '123123123',
			MailingCountry = 'Poland',
			MailingCountryCode = 'PL',
    		FirstName = 'John',
    		LastName = 'Wick',
    		AccountId = account.Id);
    	insert contact;

    	OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = opportunity.Id,
            ContactId = contact.Id,
            IsPrimary = true);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
    	update opportunity;

    	Payment_Transaction__c newTransaction = new Payment_Transaction__c(
    		Currency__c = 'PLN',
    		Amount__c = 1700,
    		OpportunityId__c = opportunity.Id);
        insert newTransaction;
    }

	@isTest
    static void testPaymentPl() {
    	List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        ApexPages.currentPage().getparameters().put('id', oppList.get(0).Id);

        PayUOrderGeneration payUController = new PayUOrderGeneration();
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2EPayUMock());
            payUController.redirectURL();
        Test.stopTest();
    }
}