@IsTest
public class ContentDocumentLinkHandlerTest {

    //STCP1-434
    private static final String SUPPORT_RECORD_TYPE = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    private static final Group SUPPORT_QUEUE = ([
            SELECT Id, Email
            FROM Group
            WHERE DeveloperName LIKE '%_Support%'
            AND Type = 'Queue'
            LIMIT 1
    ]);

    @IsTest
    private static void testProcessAttachmentToClosedCase() {
        Case originalCase = createCase();
        insert originalCase;

        EmailMessage originalMessage = createEmailMessage(originalCase.Id);
        insert originalMessage;

        ContentVersion originalContentVersion = createContentVersion();
        insert originalContentVersion;

        originalContentVersion = getContentVersion();
        ContentDocument originalContentDocument = getContentDocument();

        ContentDocumentLink originalDocumentLink = createDocumentLink(originalMessage.Id, originalContentDocument.Id);
        insert originalDocumentLink;

        Case newCase = getNewChildCases(originalCase.Id);
        System.assertNotEquals(null, newCase);
        System.assertEquals(originalMessage.TextBody, newCase.Description);

        EmailMessage newMessage = getEmailMessage(newCase.Id, originalMessage.FromName, originalMessage.ToAddress, originalMessage.FromAddress);
        System.assertNotEquals(null, newMessage);

        ContentDocumentLink newDocumentLink = getContentDocumentLink(newCase.Id);
        System.assertNotEquals(null, newDocumentLink);
        System.assertEquals(originalDocumentLink.ContentDocumentId, newDocumentLink.ContentDocumentId);
    }

    private static Case getNewChildCases(Id parentCaseId) {
        return ([
                SELECT Id, Description, ParentId
                FROM Case
                WHERE RecordTypeId = :SUPPORT_RECORD_TYPE
                AND Status = :GlobalUtils.getSupportCaseStatus(GlobalUtils.SupportCaseStatus.status_new)
                AND ParentId = :parentCaseId
        ]);
    }

    private static EmailMessage getEmailMessage(Id newCaseId, String fromName, String toAddress, String fromAddress) {
        return ([
                SELECT Id, TextBody, HtmlBody
                FROM EmailMessage
                WHERE ParentId = :newCaseId
                AND FromName = :fromName
                AND ToAddress = :toAddress
                AND FromAddress = :fromAddress
        ]);
    }

    private static ContentDocumentLink getContentDocumentLink(Id parentId) {
        return ([
                SELECT Id, ContentDocumentId, ShareType
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId
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

    private static ContentDocumentLink createDocumentLink(Id parentId, Id id) {
        return new ContentDocumentLink(
                LinkedEntityId = parentId,
                ContentDocumentId = id,
                ShareType = 'V'
        );
    }

    private static ContentVersion createContentVersion() {
        return new ContentVersion(
                Title = 'test',
                PathOnClient = 'test.txt',
                VersionData = Blob.valueOf('test content'),
                IsMajorVersion = true
        );
    }

    private static ContentVersion getContentVersion() {
        return ([
                SELECT Id, ContentDocumentId, IsMajorVersion, Title, PathOnClient
                FROM ContentVersion
                LIMIT 1
        ]);
    }

    private static ContentDocument getContentDocument() {
        return ([
                SELECT Id, LatestPublishedVersionId, Title, FileType, FileExtension
                FROM ContentDocument
                LIMIT 1
        ]);
    }

    @IsTest
    private static void testCarnetDeleteContentDocumentLink(){
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS System Administrator' AND UserRole.Name = 'Role Up' AND IsActive = true LIMIT 1];

        List<Profile> AdminUser = [SELECT Id, Name FROM Profile WHERE Name = 'API Only' LIMIT 1];

        Carnet_Profiles_Approval__c carnetSettings = new Carnet_Profiles_Approval__c(
                Name = AdminUser.get(0).Name,
                Field_Name__c = AdminUser.get(0).Name);
        insert carnetSettings;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings2 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Account_Status__c');
        insert carnetSettings2;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings3 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Number_of_open_tasks__c');
        insert carnetSettings3;

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Poland',
                Account_Status__c = 'Prospect',
                OwnerId= User.get(0).Id,
                RecordTypeId = endkundeAccRecId);
        insert account;

        Pricebook2 pcb = new Pricebook2(
                Name = 'test',
                IsActive = true,
                Standard_Unit_Package__c = 289);
        insert pcb;

        Account_Price_Book__c apb = new Account_Price_Book__c(
                Name = 'test',
                Account__c = account.Id,
                Price_Book__c = pcb.Id);
        insert apb;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com',
                OwnerId= User.get(0).Id);
        insert contact;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Carnet_podsumowanie_zamowienia',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                PathOnClient = 'Test.pdf'
        );
        insert contentVersion;

        Opportunity opportunity = new Opportunity(
                Name = 'CarnetTest',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = carnetOppoRecId,
                CloseDate = date.today(),
                Form_of_Payment__c = 'Advanced payment',
                Account_Price_Book__c = apb.Id,
                DocuSign_Status__c = 'Completed',
                Deposit_Amount__c = true);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = opportunity.Id;
        cdl.ShareType = 'I';
        insert cdl;

        System.runAs(User.get(0)) {
            opportunity.StageName = 'Closed Lost';
            update opportunity;
        }

        ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );
        insert cv;

        Id CdId = [SELECT Id FROM ContentDocument WHERE ContentDocument.LatestPublishedVersionId = :cv.Id].Id;

        ContentDocumentLink cdl2 = new ContentDocumentLink(
                ContentDocumentId = CdId,
                LinkedEntityId = opportunity.Id,
                ShareType = 'I'
        );
        insert cdl2;

        /*Carnet_Closed_Won_Files_Allowed_Profiles__c ap = new Carnet_Closed_Won_Files_Allowed_Profiles__c(
                Name = 'Admin',
                Profile_Id__c = User.get(0).ProfileId
        );*/
        //insert ap;

        System.runAs(User.get(0)){
            try{
                delete cdl2;
            }
            catch(Exception e){
                System.debug(e.getMessage());
                Boolean expectedExceptionThrown = e.getMessage().contains('allowed') ? true : false;
                system.assertEquals(expectedExceptionThrown,true);
            }
        }


    }
}