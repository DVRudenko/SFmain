@IsTest
private class E2EAdditionalDocumentsCtrlTest {

    static testMethod void testDepositAgreement() {
        createData();
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', Billingcountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id ,
                Angebotsdauer__c ='123');
        insert opportunity;

        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);

        String hash = E2EFormEncryption.getHashAlgorithAES256(key256AES,
                'documentName=DepositAgreement&' + 'opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');

        Test.setCurrentPageReference(new PageReference('E2EAdditionalDocuments.page'));
        System.currentPageReference().getParameters().put('hash', hash);

        E2EAdditionalDocumentsCtrl controller = new E2EAdditionalDocumentsCtrl();
    }

    static testMethod void testSepaMandate() {
        createData();
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', Billingcountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id ,
                Angebotsdauer__c ='123');
        insert opportunity;

        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);

        String hash = E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(opportunity.ID) + '&pdfDownload=TRUE&' +
                'dynamicIBAN=123&' +  'dynamicSWIFT=123'  );
        Test.setCurrentPageReference(new PageReference('E2EAdditionalDocuments.page'));
        System.currentPageReference().getParameters().put('hash', hash);

        E2EAdditionalDocumentsCtrl controller = new E2EAdditionalDocumentsCtrl();
    }

    static testMethod void testPaymentInformation() {
        createData();
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', Billingcountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id ,
                Angebotsdauer__c ='123');
        insert opportunity;

        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);

        String hash = E2EFormEncryption.getHashAlgorithAES256(key256AES,
                'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');
        Test.setCurrentPageReference(new PageReference('E2EAdditionalDocuments.page'));
        System.currentPageReference().getParameters().put('hash', hash);

        E2EAdditionalDocumentsCtrl controller = new E2EAdditionalDocumentsCtrl();
    }

    public static testMethod void createData() {
        insert new E2E_Form_General_Settings__c(Name = 'Germany',Test_Mode__c = false);

        insert new E2EKeysAPI__c(Name ='E2EForm',   AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c='https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c='fleetcorTEST', SHA_KeyIn__c='FleetcorTest!12@', SHA_KeyOut__c='IngenFleetTest1!');

        LongForm__c longForm = new LongForm__c(
                Country__c = 'Germany',
                Title__c = 'test',
                Test_mode__c = false
        );
        insert longForm;

        LongForm_Page__c longFormPage = new LongForm_Page__c(
                Name = 'CONGRATULATIONS',
                Title__c = 'CHAT',
                System_Error__c = 'error',
                Type__c = 'Basic',
                Long_Form__c = longForm.Id
        );
        insert longFormPage;

        LongForm_Element__c longFormElement = new LongForm_Element__c(
                Name = 'SALUTATION',
                Type__c = 'Radio-button Field',
                Long_Form_Page__c = longFormPage.Id
        );
        insert longFormElement;

        LongForm_Element_Item__c longFormElementItem = new LongForm_Element_Item__c(
                Name = 'test',
                Active__c = true,
                Type__c = 'Options',
                Long_Form_Element__c = longFormElement.Id,
                Value__c = 'test'
        );
        insert longFormElementItem;
    }

}