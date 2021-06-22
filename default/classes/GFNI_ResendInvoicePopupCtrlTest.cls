@isTest
public with sharing class GFNI_ResendInvoicePopupCtrlTest {

    @testSetup
    static void createTestAccountAndCase() {
        Account acc = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
                Name = 'Test GFN Account',
                GFN_Nr__c = 'DE12478550',
                ColCo__c = 'DE',
                BillingCountry = 'Germany'
        );
        insert acc;


        ERP__c erp = new ERP__c (
            Name = 'test',
            Gfn_Number__c = 'D0123456',
            ColCo__c = 'CZ'
        );
        insert erp;


        Case c = new Case(
                Origin = 'E-Mail',
                RecordTypeId = GlobalUtils.getRecordTypeId('Case', 'Support'),
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject',
                AccountId = acc.Id
        );
        insert c;


        Contact newContact = new Contact(
                AccountId = acc.Id,
                LastName = 'TEST',
                ERP__c = erp.Id
        );
        insert newContact;


        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                LIMIT 1
        ];
        User ownerUser = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'test',
                Email = 'test.gfnpopup.test@test.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert ownerUser;

    }


    @isTest
    public static void getRelatedCasesTest() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        Case c = [SELECT Id, Status FROM Case LIMIT 1];
        List<Case> caseList = GFNI_ResendInvoicePopupController.getRelatedCases(c.Id, 'Case');
        System.assertEquals(1, caseList.size());
        System.assertEquals(c.Status, caseList[0].Status);

        Account acc = [SELECT Id FROM Account LIMIT 1];
        caseList = GFNI_ResendInvoicePopupController.getRelatedCases(acc.Id, 'Account');
        System.assertEquals(1, caseList.size());
        System.assertEquals(c.Status, caseList[0].Status);
        System.assertEquals(c.Id, caseList[0].Id);
    }

    @isTest
    public static void testGetContacList() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        Contact c = [SELECT LastName, AccountId FROM Contact LIMIT 1];
        List<Contact> contactList = GFNI_ResendInvoicePopupController.getContactList(c.AccountId);
        System.assertEquals(1, contactList.size());
        System.assertEquals('TEST', contactList[0].LastName);
    }

    @isTest
    public static void testGetQueueEmailList() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);

        User currentUser = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];

        Test.startTest();

        System.runAs(currentUser) {

            List<String> emailList = GFNI_ResendInvoicePopupController.getQueueEmailList('German,1');
            System.assert(emailList.size() > 0);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseAndSendEmail() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);

        Account acc = [SELECT ID FROM Account LIMIT 1];
        Case newCase = new Case(
                Origin = 'Phone',
                Status = 'New',
                Subject = 'Subject',
                Description = 'Description',
                Topic__c = 'Invoices & Payments',
                Queue_Email__c = 'test@test.test',
                AccountId = acc.Id
        );
        Map<String, String> emailContent = new Map<String, String>{
                'from' => 'test@test.test',
                'to' => 'totest@test.test',
                'subject' => 'test subject',
                'body' => 'test body',
                'invoices' => '{"12345":"GVzdA=="}',
                'cc' => ''
        };
        Test.startTest();
        GFNI_ResendInvoicePopupController.createCaseAndSendEmail(true, newCase, emailContent, 'SME', new List<String>());
        Test.stopTest();
        List<EmailMessage> messageList = [SELECT Id FROM EmailMessage];
        System.assertEquals(1, messageList.size());
        List<Case> newCases = [SELECT Id, Description FROM Case WHERE Queue_Email__c = 'test@test.test'];
        System.assertEquals(1, newCases.size());
        System.assertEquals('Description', newCases[0].Description);

    }

    @isTest
    public static void testGetEmailTemplate() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        User currentUser = [SELECT Id FROM User WHERE Email = 'test.gfnpopup.test@test.de'];
        Test.startTest();
        EmailTemplate newTemplate = GFNI_ResendInvoicePopupController.getEmailTemplate('German,1');
        Test.stopTest();
        System.assert(newTemplate != null);
        System.assert(!String.isEmpty(newTemplate.Subject));
        System.assert(!String.isEmpty(newTemplate.HtmlValue));

    }

    @isTest
    public static void testGetDataFromGFN() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        String pdf = GFNI_ResendInvoicePopupController.getPDFInvoice('test', '1', '12345', 'SME');
        String accountParams = GFNI_ResendInvoicePopupController.getAccParams('1', 'DE12478550', 'SME');
        String addresses = GFNI_ResendInvoicePopupController.getAddressFromGFN('1', 'DE12478550', 'SME');
        Test.stopTest();
        System.assertEquals('GVzdA==', pdf);
        System.assert(accountParams != null);
        System.assert(addresses != null);
    }

    @isTest
    public static void testGetCasesByERP() {
        GFNI_DashboardCtrlTest.initCustomSettings(true);
        Test.startTest();
        List<Case> caseList = GFNI_ResendInvoicePopupController.getCasesByERP('DE12478550');
        Test.stopTest();
        System.assertEquals(1, caseList.size());
    }

    @isTest
    public static void testGetAccountByERP(){
        ERP__c erp = [
            SELECT  Id
            FROM ERP__c
            LIMIT 1
        ];
        List<Contact> contactList  = GFNI_ResendInvoicePopupController.getContactsByERP(erp.Id);
        System.assertEquals(1, contactList.size());
    }

    @isTest
    public static void testGetMyDocs() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];

        System.runAs(currentUser) {
            ContentVersion newDoc = new ContentVersion(
                Title = 'test doc',
                VersionData = Blob.valueOf('test'),
                PathOnClient = 'test doc'
            );
            insert newDoc;
            List<ContentDocument> insertedDocs = GFNI_ResendInvoicePopupController.getUsersDocuments();
            System.assertEquals(1, insertedDocs.size());
            System.assertEquals('test doc', insertedDocs[0].Title);
        }
    }


    @isTest
    public static void testDeleteNewDocument() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];

        System.runAs(currentUser) {
            ContentVersion newDoc = new ContentVersion(
                Title = 'test doc',
                VersionData = Blob.valueOf('test'),
                PathOnClient = 'test doc'
            );
            insert newDoc;
            List<ContentDocument> insertedDocs = GFNI_ResendInvoicePopupController.getUsersDocuments();
            System.assertEquals(1, insertedDocs.size());

            GFNI_ResendInvoicePopupController.deleteNewDocument(insertedDocs[0].Id);

            List<ContentDocument> newDocs = [SELECT Id FROM ContentDocument WHERE Id =: insertedDocs[0].Id];

            System.assertEquals(0, newDocs.size());

        }
    }
}