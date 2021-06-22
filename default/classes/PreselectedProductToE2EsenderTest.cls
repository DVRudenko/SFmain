@isTest
private class PreselectedProductToE2EsenderTest  {
    private static User salesUser;
    private static Lead lead;
    
    @isTest
    public static void testSendingEmail() {
        Test.startTest();
            createSalesUser('Sales Inbound', 'Salesteam Inbound'); 
        Test.stopTest();    
        System.runAs(salesUser) {
            createEmailTemplates();
            createCustomSettings();
            createLead();

            ApexPages.currentPage().getparameters().put('id', String.valueOf(lead.Id));
            PreselectedProductToE2EsenderCtrl senderToE2Ectrl = new PreselectedProductToE2EsenderCtrl();
            senderToE2Ectrl.init();
            senderToE2Ectrl.sendEmail();
            senderToE2Ectrl.backToLead();
        }
    }


    @future
	private static void createSalesUser(String profileName, String userRoleName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = :userRoleName];
        salesUser = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_233121_test2@test.com',
            Alias = 'batman',
            Email = 'bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Bruce',
            Lastname = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        insert salesUser;
    }

    private static void createLead() {
        lead = new Lead(
            Salutation = 'Herr',
            FirstName = 'Test',
            LastName = 'Lead for sending pre-selected product to E2E',
            Company = 'Test company',
            Country = 'Germany',
            OwnerId = salesUser.Id, 
            Email = 'test@test.com',
            Sec_Channel__c = 'Inbound'
        );
        insert lead;
    }

    private static void createEmailTemplates() {
        EmailTemplate emailTemplate = new EmailTemplate (
            Name = 'Inbound Typ B Germany',
            DeveloperName = 'Inbound_Typ_B_Germany',
            Subject = 'Test subject', 
            HtmlValue = 'test',
            FolderId = UserInfo.getUserId(),
            TemplateType = 'Custom'
        ); 
        insert emailTemplate;

        Attachment attach = new Attachment(Name = 'Test', ParentId = emailTemplate.Id, Body = Blob.valueOf('Test'));
        insert attach;
    }

    private static void createCustomSettings() {
        List<SObject> settingsToInsertList = new List<SObject>();
        E2E_Preselected_Products_Settings__c productSetting = new E2E_Preselected_Products_Settings__c(
            Name = 'Test settings for Germany',
            Product_Name__c = 'Inbound Typ B',
            Sec_Channel__c = 'Inbound',
            Country__c = 'Germany',
            Email_Template_DeveloperName__c = 'Inbound_Typ_B_Germany'
        );
        settingsToInsertList.add(productSetting);

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
        	Name = 'E2EForm',
        	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
        	paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
        	PSPID__c = 'fleetcorTEST',
        	SHA_KeyIn__c = 'FleetcorTest!12@',
        	SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        settingsToInsertList.add(e2eKeysApi);

        insert settingsToInsertList;
    }
}