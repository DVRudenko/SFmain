@IsTest
public class ETEDocumentsCtrlTest {
    @TestSetup
    static void makeData(){
        E2E_Data_Object__c dataObj = new E2E_Data_Object__c();
        dataObj.Name = 'Test';
        dataObj.First_Name__c = 'Paul';
        dataObj.Last_Name__c = 'Test';
        dataObj.Security_Amount_To_Pay__c = 123;
        insert dataObj;

        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'Germany';
        insert acc;

        Contact c = new Contact();
		c.FirstName = 'Paul';
		c.LastName  = 'Test';
		c.AccountId = acc.Id;
		c.MailingStreet = '298 S. Ringo Street';
		c.MailingCity = 'Little Rock';
		c.MailingPostalCode = '72201';
		insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TEST';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Qualify';
        opp.E2E_Data_Object__c = dataObj.Id;
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = opp.Id;
		ocr.IsPrimary = true;
		ocr.Role = 'Decision Maker';
		insert ocr;

        E2EKeysAPI__c keysAPI = new E2EKeysAPI__c();
        keysAPI.Name = 'E2EFormPL';
        keysAPI.AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=';
        insert keysAPI;
    }

    @IsTest
    static void method1 () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');
        
        PageReference pageRef = new PageReference('ETEDocuments');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('doc', 'tariffPolicy');
        ApexPages.currentPage().getParameters().put('countryCode', 'pl');
        ApexPages.currentPage().getParameters().put('implKey', 'Poland');
        ApexPages.currentPage().getParameters().put('language', 'pl');
        ApexPages.currentPage().getParameters().put('iban', 'iban');
        ApexPages.currentPage().getParameters().put('swift', 'null');
        ApexPages.currentPage().getParameters().put('accountHolder', 'accountHolder');
        ApexPages.currentPage().getParameters().put('source', source);

        ETEDocumentsCtrl.init();
        System.assert(ETEDocumentsCtrl.content == '<!-- image -->TEST Paul');
        System.assert(ETEDocumentsCtrl.style == '.testClass{color:red;}');
        System.assert(ETEDocumentsCtrl.showHeader == false);
        System.assert(ETEDocumentsCtrl.pageMargin == '0cm 0cm 0cm 0cm');
    }

    @IsTest
    static void method2 () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');

        PageReference pageRef = new PageReference('ETEDocuments');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('doc', 'documentsAgreement');
        ApexPages.currentPage().getParameters().put('countryCode', 'pl');
        ApexPages.currentPage().getParameters().put('implKey', 'Poland');
        ApexPages.currentPage().getParameters().put('language', 'pl');
        ApexPages.currentPage().getParameters().put('source', source);

        ETEDocumentsCtrl.init();
        System.assert(ETEDocumentsCtrl.content == '<!-- productLogo <img/> productLogo --><!-- pdf -->Hello<!-- depositAgreement -->World');
        System.assert(ETEDocumentsCtrl.style == null);
        System.assert(ETEDocumentsCtrl.showHeader == true);
        System.assert(ETEDocumentsCtrl.pageMargin == '1.5cm 1cm 1cm 1cm');
        System.assert(ETEDocumentsCtrl.productLogo == '<img/>');
    }

    @IsTest
    static void method3 () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');
        
        PageReference pageRef = new PageReference('ETEDocuments');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('doc', 'documentsAgreement');
        ApexPages.currentPage().getParameters().put('countryCode', 'de');
        ApexPages.currentPage().getParameters().put('implKey', 'Germany');
        ApexPages.currentPage().getParameters().put('language', 'de');
        ApexPages.currentPage().getParameters().put('source', source);

        ETEDocumentsCtrl.init();
        System.assert(ETEDocumentsCtrl.content == '');
    }

    @IsTest
    static void method4 () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');
        
        PageReference pageRef = new PageReference('ETEDocuments');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('doc', 'documentsAgreement');
        ApexPages.currentPage().getParameters().put('countryCode', 'pl');
        ApexPages.currentPage().getParameters().put('implKey', 'Poland');
        ApexPages.currentPage().getParameters().put('language', 'pl');
        ApexPages.currentPage().getParameters().put('productType', 'fuel');
        ApexPages.currentPage().getParameters().put('source', source);

        ETEDocumentsCtrl.init();
        System.assert(ETEDocumentsCtrl.content == '');
    }

    public static List<StaticResource> getStaticResources (String resourcesName) {
        List<StaticResource> resultList = new List<StaticResource>();
        if (staticResources.containsKey(resourcesName)) {
            resultList.add(staticResources.get(resourcesName));
        }
        return resultList;
    }


    public static Map<String, StaticResource> staticResources = new Map<String, StaticResource>{
        'ETE_DOC_tariffPolicyPl' => new StaticResource(
            Name = 'ETE_DOC_tariffPolicyPl',
            Body = Blob.valueOf('<!-- image --><style>.testClass{color:red;}</style>{!currentOpportunity.Name} {!dataContactPrimary.First_Name__c}')
        ),
        'ETE_DOC_agreeToTelephoneContactPL_PL' => new StaticResource(
            Name = 'ETE_DOC_agreeToTelephoneContactPL_PL',
            Body = Blob.valueOf('<h1>Hello World</h1>')
        ),
        'ETE_DOC_agreementPrivacyPolicyDE_DE' => new StaticResource(
            Name = 'ETE_DOC_agreementPrivacyPolicyDE_DE',
            Body = Blob.valueOf('<h1>DE Hello World</h1>')
        ),
        'ETE_DOC_documentsTermsAndConditionsDE'=> new StaticResource(
            Name = 'ETE_DOC_documentsTermsAndConditionsDE',
            Body = Blob.valueOf('<h1>Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreementPL'=> new StaticResource(
            Name = 'ETE_DOC_documentsAgreement_PL',
            Body = Blob.valueOf('<!-- productLogo <img/> productLogo --><!-- pdf -->Hello<!-- depositAgreement -->World')
        ),
        'ETE_DOC_documentsAgreement_DE'=> new StaticResource(
            Name = 'ETE_DOC_documentsAgreement_DE',
            Body = Blob.valueOf('<h1>Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreement_NL'=> new StaticResource(
            Name = 'ETE_DOC_documentsAgreement_NL',
            Body = Blob.valueOf('<h1>NL Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreement_BE_NL'=> new StaticResource(
                Name = 'ETE_DOC_documentsAgreement_BE_NL',
                Body = Blob.valueOf('<h1>BENL Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreement_BE_FR'=> new StaticResource(
                Name = 'ETE_DOC_documentsAgreement_BE_FR',
                Body = Blob.valueOf('<h1>BEFR Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactHU_HU'=> new StaticResource(
                Name = 'ETE_DOC_agreeToTelephoneContactHU_HU',
                Body = Blob.valueOf('<h1>HU Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactCZ_CS'=> new StaticResource(
            Name = 'ETE_DOC_agreeToTelephoneContactCZ_CS',
            Body = Blob.valueOf('<h1>CZ Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactSK_SK'=> new StaticResource(
            Name = 'ETE_DOC_agreeToTelephoneContactSK_SK',
            Body = Blob.valueOf('<h1>SK Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreement_FR'=> new StaticResource(
        Name = 'ETE_DOC_documentsAgreement_FR',
            Body = Blob.valueOf('<h1>FR Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactCHDE_DE'=> new StaticResource(
        Name = 'ETE_DOC_agreeToTelephoneContactCHDE_DE',
            Body = Blob.valueOf('<h1>CHDE Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactCHFR_FR'=> new StaticResource(
        Name = 'ETE_DOC_agreeToTelephoneContactCHFR_FR',
            Body = Blob.valueOf('<h1>CHFR Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreementAT'=> new StaticResource(
        Name = 'ETE_DOC_documentsAgreementAT',
            Body = Blob.valueOf('<h1>AT Hello World</h1>')
        ),
        'ETE_DOC_documentsAgreement_LU'=> new StaticResource(
                Name = 'ETE_DOC_documentsAgreement_LU',
                Body = Blob.valueOf('<h1>LU Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactCCS_CZ_CS'=> new StaticResource(
            Name = 'ETE_DOC_documentsAgreement_CCS_CZ',
            Body = Blob.valueOf('<h1>CCS CZ Hello World</h1>')
        ),
        'ETE_DOC_agreeToTelephoneContactCCS_SK_SK'=> new StaticResource(
                Name = 'ETE_DOC_documentsAgreement_CCS_SK',
                Body = Blob.valueOf('<h1>CCS SK Hello World</h1>')
        )
    };
}
