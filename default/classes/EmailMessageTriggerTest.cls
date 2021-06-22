@IsTest
public with sharing class EmailMessageTriggerTest {

    private static String SUPPORT_RECORD_TYPE = GlobalUtils.getRecordTypeId(Case.class.getName(), GlobalUtils.CaseRecordTypes.Support.name());
    private static String SUPPORT_CCS_RECORD_TYPE = GlobalUtils.getRecordTypeId(Case.class.getName(), GlobalUtils.CaseRecordTypes.Support_CCS.name());
    private static final Group SUPPORT_QUEUE = ([
            SELECT Id, Email
            FROM Group
            WHERE DeveloperName LIKE '%_Support%'
            AND Type = 'Queue'
            LIMIT 1
    ]);

    @IsTest
    private static void test() {
        Case originalCase = createCase();
        insert originalCase;
        EmailMessage originalMessage = createEmailMessage(originalCase.Id);
        insert originalMessage;
        Case newCase = getOriginalCaseWithNewChildCases(originalCase.Id).Cases.get(0);
        System.assertNotEquals(null, newCase);
        System.assertEquals(originalMessage.TextBody, newCase.Description);
        EmailMessage newMessage = getNewMessage(newCase.Id, originalMessage.FromName, originalMessage.ToAddress, originalMessage.FromAddress);
        System.assertNotEquals(null, newMessage);
        System.assertEquals(originalMessage.TextBody, newMessage.TextBody);
        System.assertEquals(originalMessage.HtmlBody, newMessage.HtmlBody);
    }

    private static Case getOriginalCaseWithNewChildCases(Id parentCaseId) {
        return ([
                SELECT Id, Description, (
                        SELECT Id, Description, ParentId
                        FROM Cases
                        WHERE RecordTypeId = :SUPPORT_RECORD_TYPE
                        AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new)
                )
                FROM Case
                WHERE Id = :parentCaseId
                AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed)
        ]);
    }

    private static EmailMessage getNewMessage(Id newCaseId, String fromName, String toAddress, String fromAddress) {
        return ([
                SELECT Id, TextBody, HtmlBody
                FROM EmailMessage
                WHERE ParentId = :newCaseId
                AND FromName = :fromName
                AND ToAddress = :toAddress
                AND FromAddress = :fromAddress
        ]);
    }

    private static Case createCase() {
        return new Case(
                RecordTypeId = SUPPORT_RECORD_TYPE,
                OwnerId = UserInfo.getUserId(),
                Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.closed),
                Description = 'another'
        );
    }

    private static EmailMessage createEmailMessage(Id caseId) {
        return new EmailMessage(
                ParentId = caseId,
                FromName = 'dfgdfgd',
                FromAddress = 'test@test.com',
                ToAddress = SUPPORT_QUEUE.Email,
                TextBody = 'hello',
                HtmlBody = 'hello',
                Incoming = true
        );
    }

    @IsTest
    public static void testRecipientsForIncomingEmailMessage() {

        Case newCase = new Case(
                RecordTypeId = SUPPORT_RECORD_TYPE,
                OwnerId = UserInfo.getUserId(),
                Subject = 'Subject text; (test-email-1@test.ru, test-email-2@test.ru)',
                Description = 'Description'
        );
        insert newCase;

        Test.startTest();

        EmailMessage newMessage = new EmailMessage(
                ParentId = newCase.Id,
                FromName = 'Test External Customer',
                FromAddress = 'test@test.com',
                ToAddress = 'kundenservice@fleetcor.at',
                Subject = 'Subject text; (test-email-1@test.ru, test-email-2@test.ru)',
                TextBody = 'Test text message',
                HtmlBody = 'Test text message',
                Incoming = true
        );
        insert newMessage;

        EmailMessage insertedMessage = [
                SELECT Id, ParentId, Subject, ToAddress
                FROM EmailMessage
                WHERE Id = :newMessage.Id
        ];

        System.assertEquals(true, insertedMessage.Subject == 'Subject text');
        System.assertEquals(true, insertedMessage.ToAddress == 'kundenservice@fleetcor.at; test-email-1@test.ru; test-email-2@test.ru');
        Test.stopTest();

        Case updatedCase = [SELECT Id, Subject FROM Case WHERE Id = :newMessage.ParentId];
        System.assertEquals('Subject text', updatedCase.Subject);
    }

    @isTest
    public static void testSetOwnerByEmailBody() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                LIMIT 1
        ];

        User testUser = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'test',
                Email = 'test@test.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'Růžičková',
                FirstName = 'Hana',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert testUser;

        System.runAs(testUser) {
            Group serviceQueue = new Group(
                    Name = 'test',
                    Type = 'Queue',
                    Email = 'kredit@ccs.sk'
            );
            insert serviceQueue;

            QueuesObject testQueue = new QueueSObject(QueueID = serviceQueue.id, SObjectType = 'Case');
            insert testQueue;

            Case testCase = new Case(
                    OwnerId = serviceQueue.Id,
                    RecordTypeId = SUPPORT_CCS_RECORD_TYPE,
                    Status = GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new)
            );
            insert testCase;

            Test.startTest();
            EmailMessage message = new EmailMessage(
                    Subject = 'anon test',
                    ParentId = testCase.Id,
                    HtmlBody = '<p>Ruzickova</p>',
                    Incoming = true,
                    FromAddress = 'test.test@test.test'
            );
            insert message;
            test.stopTest();
            Case updatedCase = [
                    SELECT OwnerId
                    FROM Case
                    WHERE Id = :testCase.Id
            ];
            Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE LastName = 'Růžičková']).keySet();
            System.debug(userIds);
            System.debug(updatedCase.OwnerId);
            System.assert(userIds.contains(updatedCase.OwnerId));
        }

    }

    @isTest
    public static void testSetRelatedAccountAndERP() {
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

        Case originalCase = new Case(
                RecordTypeId = SUPPORT_CCS_RECORD_TYPE,
                OwnerId = UserInfo.getUserId(),
                Subject = 'Subject',
                Description = 'Description'
        );
        insert originalCase;

        EmailMessage originalMessage = createEmailMessage(originalCase.Id);
        insert originalMessage;

        Test.stopTest();
        Case newCase = [SELECT AccountId, ERP__c FROM Case WHERE Id = :originalCase.Id];

        System.assertEquals(testAccount.Id, newCase.AccountId);
        System.assertEquals(testERP.Id, newCase.ERP__c);
    }
}