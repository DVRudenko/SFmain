@IsTest
private class QuoteLineItemsTriggerTest {

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

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = account.Name,
                StageName = 'Prospecting',
                CloseDate = System.today(),
                CurrencyIsoCode = 'PLN'
        );
        insert opportunity;

        List<Product2> productsToInsertList = new List<Product2>();
        Product2 productShell = new Product2 (
                Name = 'pro01',
                Integration_Name__c = 'pro',
                Family = 'SHELL',
                ProductCode = 'pro',
                IsActive = true);
        productsToInsertList.add(productShell);

        Product2 productCarnet = new Product2 (
                Name = 'pro02',
                Integration_Name__c = 'pro2',
                Family = 'CARNET',
                ProductCode = 'pro2',
                IsActive = true);
        productsToInsertList.add(productCarnet);
        insert productsToInsertList;

        List<PricebookEntry> pricebookEntriesToInsertList = new List<PricebookEntry>();
        PricebookEntry pbeShell = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productShell.Id,
                CurrencyIsoCode = opportunity.CurrencyIsoCode,
                IsActive = true,
                UnitPrice = 0,
                Vat_Rate__c = 0);
        pricebookEntriesToInsertList.add(pbeShell);

        PricebookEntry pbeCarnet = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productCarnet.Id,
                CurrencyIsoCode = opportunity.CurrencyIsoCode,
                IsActive = true,
                UnitPrice = 199,
                Vat_Rate__c = 23);
        pricebookEntriesToInsertList.add(pbeCarnet);
        insert pricebookEntriesToInsertList;

        Quote quote = new Quote(
                Name = '12345',
                OpportunityId = opportunity.Id,
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
    }


    @IsTest
    static void createQuoteDiscountInvalidCase1() {
        Test.startTest();
            try {
                Quote quote = [SELECT Id FROM Quote];
                Product2 product = [SELECT Id FROM Product2 WHERE Family = 'CARNET' LIMIT 1];
                PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];
                QuoteLineItem quoteLineItem = new QuoteLineItem(
                    Product2Id = product.Id,
                    QuoteId = quote.Id,
                    PriceBookEntryID = pbe.Id,
                    Quantity = 3,
                    Discount = 30,
                    UnitPrice = pbe.UnitPrice
                );
                insert quoteLineItem;
                List<QuoteLineItem> qlItems = [SELECT Id FROM QuoteLineItem];
                System.assertEquals(0, qlItems.size());
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You can not provide discount on the product without a "SHELL" product'));
            }
        Test.stopTest();
    }


    @IsTest
    static void createQuoteDiscountInvalidCase2() {
        Test.startTest();
        try {
            Quote quote = [SELECT Id FROM Quote];
            Map<String, Product2> products = new Map<String, Product2>([SELECT Id, Family FROM Product2 WHERE Family = 'CARNET' OR Family = 'SHELL' LIMIT 2]);
            Map<String, PricebookEntry> pricebookEntriesByProductFamilyMap = new Map<String, PricebookEntry>();
            for (PricebookEntry pbe : [SELECT Id, Product2.Family, UnitPrice FROM PricebookEntry WHERE Product2Id = :products.keySet() LIMIT 2]) {
                pricebookEntriesByProductFamilyMap.put(pbe.Product2.Family, pbe);
            }
            List<QuoteLineItem> qlitemsToInsert = new List<QuoteLineItem>();
            for (Product2 product : products.values()) {
                QuoteLineItem quoteLineItem = new QuoteLineItem();
                quoteLineItem.Product2Id = product.Id;
                quoteLineItem.QuoteId = quote.Id;
                quoteLineItem.PriceBookEntryID = pricebookEntriesByProductFamilyMap.get(product.Family).Id;
                quoteLineItem.Quantity = 1;
                if (product.Family == 'CARNET') {
                    quoteLineItem.Discount = 35;
                } else {
                    quoteLineItem.Discount = null;
                }
                quoteLineItem.UnitPrice = pricebookEntriesByProductFamilyMap.get(product.Family).UnitPrice;
                qlitemsToInsert.add(quoteLineItem);
            }
            insert qlitemsToInsert;
            List<QuoteLineItem> qlItems = [SELECT Id FROM QuoteLineItem];
            System.assertEquals(0, qlItems.size());
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You can provide discount of up to 30%'));
        }
        Test.stopTest();
    }


    @IsTest
    static void createQuoteDiscountInvalidCase3() {
        Test.startTest();
        try {
            Quote quote = [SELECT Id FROM Quote];
            Map<String, Product2> products = new Map<String, Product2>([SELECT Id, Family FROM Product2 WHERE Family = 'CARNET' OR Family = 'SHELL' LIMIT 2]);
            Map<String, PricebookEntry> pricebookEntriesByProductFamilyMap = new Map<String, PricebookEntry>();
            for (PricebookEntry pbe : [SELECT Id, Product2.Family, UnitPrice FROM PricebookEntry WHERE Product2Id = :products.keySet() LIMIT 2]) {
                pricebookEntriesByProductFamilyMap.put(pbe.Product2.Family, pbe);
            }
            List<QuoteLineItem> qlitemsToInsert = new List<QuoteLineItem>();
            for (Product2 product : products.values()) {
                QuoteLineItem quoteLineItem = new QuoteLineItem();
                quoteLineItem.Product2Id = product.Id;
                quoteLineItem.QuoteId = quote.Id;
                quoteLineItem.PriceBookEntryID = pricebookEntriesByProductFamilyMap.get(product.Family).Id;
                quoteLineItem.Quantity = 1;
                quoteLineItem.Discount = null;
                quoteLineItem.UnitPrice = pricebookEntriesByProductFamilyMap.get(product.Family).UnitPrice;
                qlitemsToInsert.add(quoteLineItem);
            }
            insert qlitemsToInsert;
            QuoteLineItem existingQuoteLineItem = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Product2.Family = 'SHELL' LIMIT 1];
            existingQuoteLineItem.Discount = 15;
            update existingQuoteLineItem;

            QuoteLineItem qli = [SELECT Discount FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Product2.Family = 'SHELL' LIMIT 1];
            System.assertEquals(null, qli.Discount);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You can not provide discount on a "SHELL" product'));
        }
        Test.stopTest();
    }
}