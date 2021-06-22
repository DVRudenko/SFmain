@isTest
private class SepaDataApprovalControllerTest {
	public Static User u;
	public Static Opportunity newOpportunity;
	public Static Opportunity closedWonOppty;
	public Static EmailTemplate newEmailTeamplte1;
	public Static EmailTemplate newEmailTeamplte2;

    @isTest
    public static void testApproveDataForm() {
    	Test.startTest();
			createSaleUser();
		Test.stopTest();

		createOpps();
		System.runAs(u) {
			createEmailTemplates();

			SepaDataApprovalController controller = new SepaDataApprovalController();
			ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
		    controller.init();
		    controller.doDataApproval();
		}
    }

    @isTest
    public static void testApproveDataFormClosedWonOppty() {
    	Test.startTest();
			createSaleUser();
		Test.stopTest();

		createOpps();
		System.runAs(u) {
			createEmailTemplates();

			SepaDataApprovalController controller = new SepaDataApprovalController();
			ApexPages.currentPage().getParameters().put('id', closedWonOppty.Id);
		    controller.init();
		    controller.doDataApproval();
		}
    }


    @future
	private static void createSaleUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound'];
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


    private static void createOpps() {
    	List<Opportunity> oppsToInsertList = new List<Opportunity>();
    	RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            Name = 'Converted opportunity',
            RecordTypeId = rt.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(14),
            Name_of_the_payer_Account_holder__c = 'test name holder',
			IBAN__c = 'DE30160400000577000300',
			SWIFT_BIC__c = '7654321',
			OwnerId = u.Id
        );
        oppsToInsertList.add(newOpportunity);

        closedWonOppty = new Opportunity(
            Name = 'Closed Won opportunity',
            RecordTypeId = rt.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Name_of_the_payer_Account_holder__c = 'test name holder',
			IBAN__c = 'DE30160400000577000300',
			SWIFT_BIC__c = '7654321',
			OwnerId = u.Id
        );
        oppsToInsertList.add(closedWonOppty);

        insert oppsToInsertList;
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