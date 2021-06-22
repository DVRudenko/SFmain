@IsTest
private class QuotePdfViewerControllerTest {

    @TestSetup
    static void createTestData() {
        Account account = new Account(
                Name = 'Test Account',
                BillingCountry = 'Poland',
                BillingPostalCode = '123321',
                BillingCity = 'Test City',
                BillingStreet = 'Test Street 7',
                ShippingCountry = 'Poland',
                ShippingPostalCode = '123321',
                ShippingCity = 'Test City',
                ShippingStreet = 'Test Street 7'
        );
        insert account;


        Contact contact = new Contact(
                Salutation = 'Mr',
                FirstName = 'Test FirstName',
                LastName = 'Test LastName',
                Email = 'test@test.com',
                Phone = '+48127511725'
        );
        insert contact;


        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = account.Name,
                StageName = 'Prospecting',
                CloseDate = System.today(),
                CurrencyIsoCode = 'PLN'
        );
        insert opportunity;


        Product2 product = new Product2 (
                Name = 'pro01',
                Integration_Name__c = 'pro',
                ProductCode = 'pro',
                IsActive = true);
        insert product;


        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = product.Id,
                CurrencyIsoCode = opportunity.CurrencyIsoCode,
                IsActive = true,
                UnitPrice = 100,
                Vat_Rate__c = 23);
        insert pbe;


        OpportunityLineItem oli = new OpportunityLineItem (
                Quantity = 3,
                UnitPrice = pbe.UnitPrice,
                OpportunityId = opportunity.Id,
                PriceBookEntryId = pbe.Id);
        insert oli;


        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = opportunity.Id,
                ContactId = contact.Id
        );
        insert ocr;

        Quote quote = new Quote(
                Name = '12345',
                OpportunityId = opportunity.Id,
                ContactId = contact.Id,
                Email = contact.Email,
                Phone = contact.Phone,
                BillingCity = account.BillingCity,
                BillingCountry = account.BillingCountry,
                BillingStreet = account.BillingStreet,
                BillingPostalCode = account.BillingPostalCode,
                ShippingCity = account.ShippingCity,
                ShippingCountry = account.ShippingCountry,
                ShippingStreet = account.ShippingStreet,
                ShippingPostalCode = account.ShippingPostalCode,
                Pricebook2Id = Test.getStandardPricebookId()
        );
        insert quote;

        QuoteLineItem quoteLineItem = new QuoteLineItem(
                Product2Id = product.Id,
                QuoteId = quote.Id,
                PriceBookEntryID = pbe.Id,
                Quantity = 3,
                UnitPrice = pbe.UnitPrice);
        insert quoteLineItem;
    }


    @IsTest
    static void initPdfViewerTest() {
        Test.startTest();
            Quote quote = [SELECT Id FROM Quote];
            ApexPages.currentPage().getParameters().put('id', quote.Id);
            QuotePdfViewerController quotePdfViewerCtrl = new QuotePdfViewerController();
            quotePdfViewerCtrl.init();
        Test.stopTest();
    }


    @IsTest
    static void savePDFTest() {
        Test.startTest();
            Quote quote = [SELECT Id, OpportunityId FROM Quote];
            ApexPages.currentPage().getParameters().put('id', quote.Id);
            QuotePdfViewerController quotePdfViewerCtrl = new QuotePdfViewerController();
            quotePdfViewerCtrl.init();
            quotePdfViewerCtrl.savePDF();
            List<Attachment> attachList = [SELECT Id FROM Attachment WHERE ParentId = :quote.OpportunityId];
            System.assertEquals(1, attachList.size());
        Test.stopTest();
    }


    @IsTest
    static void backToQuoteTest() {
        Test.startTest();
            Quote quote = [SELECT Id, OpportunityId FROM Quote];
            ApexPages.currentPage().getParameters().put('id', quote.Id);
            QuotePdfViewerController quotePdfViewerCtrl = new QuotePdfViewerController();
            quotePdfViewerCtrl.init();
            quotePdfViewerCtrl.doCancel();
        Test.stopTest();
    }
}