@IsTest
public class ETEPDFViewCtrlTest {

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
        acc.BillingCountry = 'Poland';
        insert acc;

        Contact c = new Contact();
		c.FirstName = 'Sehr geehrter';
		c.LastName  = 'Test';
		c.AccountId = acc.Id;
        c.Salutation = 'Herr';
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
    static void ete_step_documents_contract_TEST () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');
        
        PageReference pageRef = new PageReference('ETEPDFView');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'ete_step_documents_contract');
        ApexPages.currentPage().getParameters().put('country_code', 'pl');
        ApexPages.currentPage().getParameters().put('impl', 'Poland');
        ApexPages.currentPage().getParameters().put('source', source);


        ETEPDFViewCtrl ctrl = new ETEPDFViewCtrl();
        ctrl.main();
        String content = ctrl.content;
        System.assert(content != null);
    }

    @IsTest
    static void ete_step_documents_tabel_price_TEST () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');
        
        PageReference pageRef = new PageReference('ETEPDFView');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'ete_step_documents_tabel_price');
        ApexPages.currentPage().getParameters().put('country_code', 'de');
        ApexPages.currentPage().getParameters().put('impl', 'Poland');
        ApexPages.currentPage().getParameters().put('source', source);


        ETEPDFViewCtrl ctrl = new ETEPDFViewCtrl();
        ctrl.main();
        String content = ctrl.content;
        System.assert(content != null);
    }

    @IsTest
    static void ete_step_documents_tabel_price_by_product_type_TEST () {
        E2E_Data_Object__c dataObj = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObj.Id, 'pl');
        
        PageReference pageRef = new PageReference('ETEPDFView');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'ete_step_documents_tabel_price');
        ApexPages.currentPage().getParameters().put('country_code', 'de');
        ApexPages.currentPage().getParameters().put('impl', 'Poland');
        ApexPages.currentPage().getParameters().put('productType', 'fuel');
        ApexPages.currentPage().getParameters().put('source', source);


        ETEPDFViewCtrl ctrl = new ETEPDFViewCtrl();
        ctrl.main();
        String content = ctrl.content;
        System.assert(content != null);
    }
}
