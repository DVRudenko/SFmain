@isTest
private class SepaDataApprovalRequestCtrlTest {
	public static User u;
	public static Account newAccount;
	public static Opportunity newOpportunity;
	public static Contact newContact;
	public static OpportunityContactRole oppConRole;
	public static EmailTemplate newEmailTeamplte;

    static testMethod void testSendSEPADataApprovalRequest() {
    	Test.startTest();
			createSaleUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpportunity();
			createContact();
			createOpptyContactRole();
			createEmailTemplate();

			SepaDataApprovalRequestCtrl controller = new SepaDataApprovalRequestCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
		    controller.init();
		}    
    }

    static testMethod void testRequestErrors() {
    	Test.startTest();
			createSaleUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpportunity();
			createContact();
			createOpptyContactRole();
			createEmailTemplate();

			SepaDataApprovalRequestCtrl controller = new SepaDataApprovalRequestCtrl();
			ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
			newOpportunity.Direct_Debit_Mandate_Type__c = 'B2B';
			update newOpportunity;
		    controller.init();
		}    
    }
	
	
	/*******************************************************************************
	*  Name            : testInvalidMandateType()
	*  Summary         : Test case with invalid mandate type
	*  CreatedDate     : 28/11/2019
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testInvalidMandateType() {
		Account account = new Account(
			Name = 'Test',
			BillingCountry = 'Germany'
		);
		insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test',
            AccountId = account.Id,
            StageName = 'Prospecting',
            Send_SEPA_approval_link__c = false,
            CloseDate = Date.today(),
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Risk_Category__c = 'Medium',
            Total_consumption_l_month__c = 3000
        );
        insert opportunity;

		SepaDataApprovalRequestCtrl controller = new SepaDataApprovalRequestCtrl();
		ApexPages.currentPage().getParameters().put('id', opportunity.Id);
		
		Test.startTest();
			controller.init();
		Test.stopTest();
		
		Opportunity testOpportunity = [
				SELECT Send_SEPA_approval_link__c 
				FROM Opportunity
				WHERE Id = :opportunity.Id
		];
		
		System.assertEquals(false, testOpportunity.Send_SEPA_approval_link__c);
    }


	/*******************************************************************************
	*  Summary         : test Twikey request
	*  CreatedDate     : 05/10/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testTwikeyRequest() {
		Twikey__c twikeySettings = new Twikey__c(
			Name = 'Test',
			Active__c = true,
			Token__c = '4AF3EAB7D47D13C9CF708C73AB4F9129C224E78B',
			Endpoint__c = 'https://api.beta.twikey.com',
			B2B_Template_Id__c = '1896',
			Core_Template_Id__c = '1897');

		insert twikeySettings;

		newAccount = new Account(
			Name = 'test',
			BillingCountry = 'Belgium-NL'
		);

		insert newAccount;

		newOpportunity = new Opportunity(
            Name = 'Converted opportunity',
            AccountId = newAccount.Id,
            StageName = 'Prospecting',
            Send_SEPA_approval_link__c = false,
			SEPA_Request_Approved__c = false,
			Angebotsdauer__c = 'test',
            CloseDate = Date.today().addDays(14),
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'B2B',
            Risk_Category__c = 'Low',
            Total_consumption_l_month__c = 100,
            Name_of_the_payer_Account_holder__c = 'test name holder',
			IBAN__c = 'DE30160400000577000300',
			SWIFT_BIC__c = '7654321'
        );
        insert newOpportunity;

		createContact();
		createOpptyContactRole();

		SepaDataApprovalRequestCtrl controller = new SepaDataApprovalRequestCtrl();
		ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);

		Test.startTest();
			Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock loginMock = new SingleRequestMock(200, 'Complete', '{"Authorization": "d78bb8a4-483e-4140-8967-748ca8794020"}', new Map<String, String> {'Authorization' => '47de7c97-da18-42dc-a8bd-3864410cd02a'});
            mocksMap.put('https://api.beta.twikey.com/creditor', loginMock);
            SingleRequestMock inviteMock = new SingleRequestMock(200, 'Complete', '{"mndtId": "FLEETCORB2BTEST17","url": "https://fleetcorbelgiumtest.beta.twikey.com/short/a675","key": "a675"}', null);
            mocksMap.put('https://api.beta.twikey.com/creditor/invite', inviteMock);
			HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			controller.init();
		Test.stopTest();

		Opportunity testOpportunity = [
				SELECT Send_SEPA_approval_link__c
				FROM Opportunity
				WHERE Id = :newOpportunity.Id
		];

		System.assertEquals(true, testOpportunity.Send_SEPA_approval_link__c);
    }


    @future
	private static void createSaleUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
		Integer rand = Math.round(Math.random()*100000);
		u = new User(
			ProfileId = p.Id,
			Username = rand + 'test@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_11@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}


	private static void createAccount() {
		newAccount = new Account(
			Name = 'test',
			BillingCountry = 'Germany'
		);
		insert newAccount;
	}


    private static void createOpportunity() {
    	RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            Name = 'Converted opportunity',
            RecordTypeId = rt.Id,
            AccountId = newAccount.Id,
            StageName = 'Prospecting',
            Send_SEPA_approval_link__c = false,
			SEPA_Request_Approved__c = false,
			Angebotsdauer__c = 'test',
            CloseDate = Date.today().addDays(14),
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
            Risk_Category__c = 'Low',
            Total_consumption_l_month__c = 1000,
            Name_of_the_payer_Account_holder__c = 'test name holder',
			IBAN__c = 'DE30160400000577000300',
			SWIFT_BIC__c = '7654321'
        );
        insert newOpportunity;
    }

    private static void createContact() {
    	newContact = new Contact(
    		Salutation = 'Herr',
    		FirstName = 'Bob',
			LastName  = 'Test',
			Email = 'test@test.com',
			MailingCountry = 'Germany',
			MailingStreet = '298 S. Ringo Street',
			MailingCity = 'Little Rock',
			MailingState = 'Berlin',
			MailingPostalCode = '72201' 	
		);
		insert newContact;	
    }

    private static void createOpptyContactRole() {
    	oppConRole = new OpportunityContactRole(
			ContactId = newContact.Id,
			OpportunityId = newOpportunity.Id,
			IsPrimary = TRUE,
			Role = 'Decision Maker'
		);
		insert oppConRole;	
	}

    private static void createEmailTemplate() {
		newEmailTeamplte = new EmailTemplate(
			Name = 'SEPA Approval Link for contact [DE]',
            DeveloperName = 'SEPA_Approval_Link_for_contact_DE',
            Subject = 'SEPA Data approval',
            Body = 'test',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
		);
		insert newEmailTeamplte;
	}
}