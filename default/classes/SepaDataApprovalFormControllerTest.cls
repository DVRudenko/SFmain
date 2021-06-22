@isTest
private class SepaDataApprovalFormControllerTest {
	public static User u;
	public static EmailTemplate newEmailTeamplte1;
	public static EmailTemplate newEmailTeamplte2;

	@testSetup
	static void createContentData() {
		E2ELongFormUtilsTest.createLongForm('Germany');
		E2ELongFormUtilsTest.createLongFormMenu();
		E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
		E2ELongFormUtilsTest.createHeader('Desktop');
		E2ELongFormUtilsTest.createPaymentOptions('Desktop');
		E2ELongFormUtilsTest.createCustomSettings('Germany', 'E2EForm', 'Creditreform', null);
	}

    @isTest
    public static void testApproveDataForm() {
    	Test.startTest();
			createSaleUser();
		Test.stopTest();

		System.runAs(u) {
			Account account = E2ELongFormUtilsTest.createAccountDE();
	        insert account;

	        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
	        insert opportunity;

	        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
	        insert contact;

	        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
	        insert oppContactRole;

			createEmailTemplates();
			
			SepaDataApprovalFormController controller = new SepaDataApprovalFormController();
			ApexPages.currentPage().getParameters().put('id', opportunity.Id);
		    controller.init();
		    controller.accountHolderName = 'test holder';
		    controller.swift = 'AARBDE5W100';
		    controller.iban = 'DE89370400440532013000';
		    controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').value = 'true';
            controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').value = 'true';
            controller.updateSepaDownloadURL();
		    controller.doDataApproval();
		}
    }

    @future
	private static void createSaleUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
		Integer rand = Math.round(Math.random()*100000);
		u = new User(
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_1231231233@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}

    private static void createEmailTemplates() {
    	List<EmailTemplate> templatesForInsertList = new List<EmailTemplate>();
		newEmailTeamplte1 = new EmailTemplate(
			Name = 'Notification of data approval to sales',
			DeveloperName = 'Notification_of_data_approval_to_sales',
			Subject = 'Data is approved',
			Body = 'test',
			HtmlValue = '<p>test</p>',
			TemplateType = 'Text',
			FolderId = UserInfo.getUserId()
		);
		templatesForInsertList.add(newEmailTeamplte1);

		newEmailTeamplte2 = new EmailTemplate(
			Name = 'SEPA Approval Data notify Backoffice',
			DeveloperName = 'SEPA_Approval_Data_notify_Backoffice',
			Subject = 'Approved SEPA form',
			Body = 'test',
			HtmlValue = '<p>test</p>',
			TemplateType = 'Text',
			FolderId = UserInfo.getUserId()
		);
		templatesForInsertList.add(newEmailTeamplte2);

		insert templatesForInsertList;
	}
}