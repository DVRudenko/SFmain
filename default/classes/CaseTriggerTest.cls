@isTest
private class CaseTriggerTest {
    private static String SUPPORT_RECORD_TYPE = GlobalUtils.getRecordTypeId('Case', 'Support');
    private static String CCS_SUPPORT_RECORD_TYPE = GlobalUtils.getRecordTypeId('Case', 'Support_CCS');
    private static String SUPPORT_QUEUE_ID = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'Hungary_Hungarian_Support' AND Type = 'Queue'].Id;
    private static String SUPPORT_CCS_QUEUE_ID = [SELECT Id, Name, Email, DeveloperName FROM Group WHERE DeveloperName = 'Bonusky_CCS_Support' AND Type = 'Queue'].Id;

    @isTest
    private static void testCaseTopicAndSubtopicMapping1(){
        // We have Subject and Description in a Case, but we can't find keywords in them

        // Test for Support record type
        Case cSupport = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject'
        );
        insert cSupport;

        List<Case> newCasesSupport = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupport.Id];
        System.assertEquals(null, newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);

        // Test for CCS Support record type
        Case cSupportCCS = new Case(
                Country__c = 'Czech Republic',
                Language__c = 'Czech',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_CCS_QUEUE_ID,
                RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject'
        );
        insert cSupportCCS;

        List<Case> newCasesSupportCCS = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupportCCS.Id];
        System.assertEquals(null, newCasesSupportCCS.get(0).Topic__c);
        System.assertEquals(null, newCasesSupportCCS.get(0).Sub_topic__c);
    }

    @isTest
    private static void testCaseTopicAndSubtopicMapping2(){
        // We have Description in a Case. We can't find the keyword for Subtopic but we can find the keyword for Topic

        // Test for Support record type
        Case cSupport = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Test please do not delete, using for test', // keyword
                Description = 'Description'
        );
        insert cSupport;

        List<Case> newCasesSupport = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupport.Id];
        System.assertEquals('Products & Services', newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);

        // Test for CCS Support record type
        Case cSupportCCS = new Case(
                Country__c = 'Czech Republic',
                Language__c = 'Czech',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_CCS_QUEUE_ID,
                RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Test please do not delete, using for test',
                Description = 'Description'
        );
        insert cSupportCCS;

        List<Case> newCasesSupportCCS = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupportCCS.Id];
        System.assertEquals('My Card(s)', newCasesSupportCCS.get(0).Topic__c);
        System.assertEquals(null, newCasesSupportCCS.get(0).Sub_topic__c);
    }

    @isTest
    private static void testCaseTopicAndSubtopicMapping3(){
        // We haven't Description in a Case

        // Test for Support record type
        Case cSupport = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Subject'
        );
        insert cSupport;

        List<Case> newCasesSupport = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupport.Id];
        System.assertEquals(null, newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);

        // Test for CCS Support record type
        Case cSupportCCS = new Case(
                Country__c = 'Czech Republic',
                Language__c = 'Czech',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_CCS_QUEUE_ID,
                RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Subject'
        );
        insert cSupportCCS;

        List<Case> newCasesSupportCCS = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupportCCS.Id];
        System.assertEquals(null, newCasesSupportCCS.get(0).Topic__c);
        System.assertEquals(null, newCasesSupportCCS.get(0).Sub_topic__c);
    }

    @isTest
    private static void testCaseTopicAndSubtopicMapping4(){
        // We haven't a Description in a Case but we have a Subject and we can find Topic by keyword

        // Test for Support record type
        Case cSupport = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Test please do not delete, using for test' // keyword
        );
        insert cSupport;

        List<Case> newCasesSupport = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupport.Id];
        System.assertEquals('Products & Services', newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);

        // Test for CCS Support record type
        Case cSupportCCS = new Case(
                Country__c = 'Czech Republic',
                Language__c = 'Czech',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_CCS_QUEUE_ID,
                RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Test please do not delete, using for test' // keyword
        );
        insert cSupportCCS;

        List<Case> newCasesSupportCCS = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupportCCS.Id];
        System.assertEquals('Products & Services', newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);
    }

    @isTest
    private static void testCaseTopicAndSubtopicMapping5(){
        // We have Description in a Case. We can find the keyword for Subtopic but we can find the keyword for Topic

        // Test for Support record type
        Case cSupport = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Test Topic and Subtopic Hungary HU',
                Description = 'Test please do not delete, using for test' // keyword
        );
        insert cSupport;

        List<Case> newCasesSupport = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupport.Id];
        System.assertEquals('Products & Services', newCasesSupport.get(0).Topic__c);
        System.assertEquals('SME Products & Services', newCasesSupport.get(0).Sub_topic__c);

        // Test for CCS Support record type
        Case cSupportCCS = new Case(
                Country__c = 'Czech Republic',
                Language__c = 'Czech',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_CCS_QUEUE_ID,
                RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
                Status = 'Test Topic and Subtopic CCS CZ',
                Description = 'Test please do not delete, using for test' // keyword
        );
        insert cSupportCCS;

        List<Case> newCasesSupportCCS = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id =: cSupportCCS.Id];

        System.assertEquals('My Card(s)', newCasesSupportCCS.get(0).Topic__c);
        System.assertEquals('+/-', newCasesSupportCCS.get(0).Sub_topic__c);
    }

    @isTest
    private static void testCaseTopicAndSubtopicMapping6() {
        // We have Case with Description (no keyword) but without Subject.

        // Test for Support record type
        Case cSupport = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Description = 'Description' // no keyword
        );
        insert cSupport;

        List<Case> newCasesSupport = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id = :cSupport.Id];
        System.assertEquals(null, newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);

        // Test for CCS Support record type
        Case cSupportCCS = new Case(
                Country__c = 'Czech Republic',
                Language__c = 'Czech',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_CCS_QUEUE_ID,
                RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
                Status = 'New',
                Description = 'Description' // no keyword
        );
        insert cSupportCCS;

        List<Case> newCasesSupportCCS = [SELECT Id, CaseNumber, Topic__c, Sub_topic__c FROM Case WHERE Id = :cSupportCCS.Id];
        System.assertEquals(null, newCasesSupport.get(0).Topic__c);
        System.assertEquals(null, newCasesSupport.get(0).Sub_topic__c);
    }

    @IsTest
    public static void testTrimEmailAddressesInSupportCaseSubject() {

        Case newCase = new Case(
                RecordTypeId = SUPPORT_RECORD_TYPE,
                OwnerId = UserInfo.getUserId(),
                Subject = 'Subject text; (test-email-1@test.ru, test-email-2@test.ru)',
                Description = 'Description'
        );
        insert newCase;

        Case c = ([
                SELECT Id, Subject
                FROM Case
                WHERE Id = :newCase.Id
                AND RecordTypeId = :SUPPORT_RECORD_TYPE
                LIMIT 1
        ]);

        System.assertEquals('Subject text', c.Subject);
    }

    @isTest
    public static void testUpdateClonedCases(){
        Case c = new Case(
                Country__c = 'Hungary',
                Language__c = 'Hungarian',
                Origin = 'E-Mail',
                OwnerId = SUPPORT_QUEUE_ID,
                RecordTypeId = SUPPORT_RECORD_TYPE,
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject'
        );
        insert c;

        Case clonedCase = c.clone();
        insert clonedCase;

        System.assertEquals(clonedCase.isClone(), true);

        Case selectedCase = [
                SELECT  Subject,
                        ParentId
                FROM    Case
                WHERE   Id =: clonedCase.Id
        ];
        // System.assertEquals(null, clonedCase.Id);
        System.assertEquals('Subject CLONE', selectedCase.Subject);
        System.assertEquals(c.Id, selectedCase.ParentId);
    }

    @isTest
    public static void testUnassignFromInternalAccount(){
        Account internalTestAcc = new Account(
            RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
            Name = 'FLEETCOR INTERNAL USE ONLY',
            BillingCountry = 'Germany'
        );
        insert internalTestAcc;

        Case testCase = new Case(
            Country__c = 'Czech Republic',
            Language__c = 'Czech',
            Origin = 'Email',
            OwnerId = SUPPORT_CCS_QUEUE_ID,
            RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
            Status = 'New',
            Description = 'Description' // no keyword
        );
        insert testCase;

        User systemUser = [SELECT Id FROM User WHERE Name = 'System' LIMIT 1];

        System.runAs(systemUser){
            testCase.AccountId = internalTestAcc.id;
            update testCase;
        }

        Case updatedTestCase = [SELECT AccountId FROM Case WHERE Id =: testCase.Id];
        System.assertEquals(null, updatedTestCase.AccountId);
    }

    @isTest
    public static void testPreventCaseCreation() {
        Test.startTest();
        Case testCase = new Case(
            Country__c = 'Czech Republic',
            Language__c = 'Czech',
            Origin = 'Email',
            OwnerId = SUPPORT_CCS_QUEUE_ID,
            RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
            Status = 'New',
            Description = 'test description' //no ooo keyword
        );
        insert testCase;
        Test.stopTest();
        Case newCase = [SELECT Id, Status FROM Case WHERE Id =: testCase.Id];
        System.assertEquals('New', newCase.Status);
    }


    @isTest
    public static void testProcessOfflineChatCase() {
        Case cSupportCCS = new Case(
            Country__c = 'Czech Republic',
            Language__c = 'Czech',
            Origin = 'Chat',
            RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
            Status = 'New',
            Subject = 'test',
            Message__c = 'Description',
            Queue_Email__c = 'premiumservis@ccs.cz'
        );
        insert cSupportCCS;

        Case newCase = [
            SELECT  Id,
                    Description
            FROM    Case
            WHERE   Id =: cSupportCCS.Id
        ];
        System.assertEquals('Description', newCase.Description, 'Message is not copied to Description');
    }

    @isTest
    public static void testSetErpOnChatCaseByContact() {
        Account testAccount = new Account(
            RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
            BillingCountry = 'Germany',
            Name = 'test'
        );
        insert testAccount;

        ERP__c testERP = new ERP__c(
            Name = 'test',
            Account__c = testAccount.Id
        );
        insert testERP;

        Contact testContact = new Contact(
                FirstName = 'test',
                LastName = 'test',
                Email = 'test@test.com',
                AccountId = testAccount.Id,
                ERP__c = testERP.Id
        );
        insert testContact;

        Test.startTest();

        Case cSupportCCS = new Case(
            Country__c = 'Czech Republic',
            Language__c = 'Czech',
            Origin = 'Chat',
            RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
            Status = 'New',
            Subject = 'test',
            Message__c = 'Description',
            SuppliedEmail = 'test@test.com',
            ContactId = testContact.Id
        );
        insert cSupportCCS;

        Test.stopTest();

        Case newCase = [
            SELECT  ERP__c 
            FROM    Case
            WHERE   Id =: cSupportCCS.Id
        ];

        System.assertEquals(testErp.Id, newCase.ERP__c, 'Erp field on case wasnt set up(contact)');
    }

    
    @isTest
    public static void testSetErpOnChatCaseByAccount() {
        Account testAccount = new Account(
            RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
            BillingCountry = 'Germany',
            Name = 'test'
        );
        insert testAccount;

        ERP__c testERP = new ERP__c(
            Name = 'test',
            Account__c = testAccount.Id
        );
        insert testERP;

        Contact testContact = new Contact(
                FirstName = 'test',
                LastName = 'test',
                Email = 'test@test.com',
                AccountId = testAccount.Id
        );
        insert testContact;

        Test.startTest();

        Case cSupportCCS = new Case(
            Country__c = 'Czech Republic',
            Language__c = 'Czech',
            Origin = 'Chat',
            RecordTypeId = CCS_SUPPORT_RECORD_TYPE,
            Status = 'New',
            Subject = 'test',
            Message__c = 'Description',
            SuppliedEmail = 'test@test.com',
            ContactId = testContact.Id
        );
        insert cSupportCCS;

        Test.stopTest();

        Case newCase = [
            SELECT  ERP__c 
            FROM    Case
            WHERE   Id =: cSupportCCS.Id
        ];

        System.assertEquals(testErp.Id, newCase.ERP__c, 'Erp field on case wasnt set up(account)');
    }
}