@isTest
private class DownloadE2EAttachmentControllerTest {
    static testMethod void testUmowa1() {
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
        	Name = 'E2EForm',
        	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
        	paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
        	PSPID__c = 'fleetcorTEST',
        	SHA_KeyIn__c = 'FleetcorTest!12@',
        	SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Attachment att = new Attachment(
        	Name = 'Umowa Karty euroShell (DocuSign).pdf',
        	Body = Blob.valueOf('test'),
        	ParentId = opportunity.Id);
        insert att;

        ApexPages.currentPage().getParameters().put('source',opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('doc','umowa1');
        DownloadE2EAttachmentController controller = new DownloadE2EAttachmentController();
        controller.init();
        System.assert(controller.attachmentId != null);
    }

    static testMethod void testHUDoc() {
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Folder f = [SELECT Id FROM Folder WHERE Name = 'E2E HU'];

        Document document = new Document(
            Name = 'HU_dd.pdf',
            Body = Blob.valueOf('test'),
            FolderId = f.Id);
        insert document;

        ApexPages.currentPage().getParameters().put('source',opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('doc','hudd');
        DownloadE2EAttachmentController controller = new DownloadE2EAttachmentController();
        controller.init();
        System.assert(controller.docId != null);
    }

    static testMethod void testUmowa2() {
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ContentVersion conVer = new ContentVersion(
                Title = 'Umowa_o_kaucji (DocuSign).pdf',
                PathOnClient = 'test',
                VersionData = Blob.valueof('Umowa_o_kaucji (DocuSign).pdf')
        );
        insert conVer;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;

        ContentDocumentLink conDocLink = new ContentDocumentLink(
                LinkedEntityId = opportunity.Id,
                ContentDocumentId = conDoc,
                ShareType = 'I'
        );
        insert conDocLink;

        ContentDistribution conDis = new ContentDistribution(
            ContentVersionId = conVer.Id,
            Name = 'Umowa_o_kaucji (DocuSign).pdf'
        );
        insert conDis;

        ApexPages.currentPage().getParameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('doc', 'umowa2');
        DownloadE2EAttachmentController controller = new DownloadE2EAttachmentController();
        controller.init();
        System.assert(controller.fileUrl != null);
    }


    static testMethod void testAgreementDocSK() {
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ContentVersion conVer = new ContentVersion(
                Title = 'E2E SK Deposit Agreement.pdf',
                PathOnClient = 'test',
                VersionData = Blob.valueof('E2E SK Deposit Agreement.pdf')
        );
        insert conVer;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;

        ContentDocumentLink conDocLink = new ContentDocumentLink(
                LinkedEntityId = opportunity.Id,
                ContentDocumentId = conDoc,
                ShareType = 'I'
        );
        insert conDocLink;

        ContentDistribution conDis = new ContentDistribution(
            ContentVersionId = conVer.Id,
            Name = 'E2E SK Deposit Agreement.pdf'
        );
        insert conDis;

        ApexPages.currentPage().getParameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('doc', 'agreementsk');
        DownloadE2EAttachmentController controller = new DownloadE2EAttachmentController();
        controller.init();
        System.assert(controller.fileUrl != null);
    }
}