@IsTest
private class OpportunityLineItemsTriggerTest {

    @TestSetup
    static void makeData () {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Poland'
        );
        insert account;

        Opportunity opp = new Opportunity(
                AccountId = account.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                CurrencyIsoCode = 'PLN'
        );
        insert opp;

        Contact contact = new Contact(
                Salutation = 'Mr.',
                LastName = 'test'
        );
        insert contact;

        OpportunityContactRole oppConRole = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = opp.Id,
                ContactId = contact.Id
        );
        insert oppConRole;
    }

    @IsTest
    static void testSyncQuoteData() {
        Opportunity opp = [SELECT Id FROM Opportunity];
        Map<String, Product2> productsMap = new Map<String, Product2>();
        productsMap.put('Shell Basic 2020', new Product2(Name = 'Shell Basic 2020', Integration_Name__c = 'shellpl', IsActive = true, Family = 'Shell'));
        productsMap.put('Carnet', new Product2(Name = 'Carnet', Integration_Name__c = 'carnetpl', IsActive = true, Family = 'Carnet'));
        insert productsMap.values();

        Map<String, PricebookEntry> priceBookEntryMap = new Map<String, PricebookEntry>();
        priceBookEntryMap.put('Shell PBE', new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productsMap.get('Shell Basic 2020').Id,
                UnitPrice = 0,
                CurrencyIsoCode = 'PLN',
                IsActive = true));
        priceBookEntryMap.put('Carnet PBE', new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productsMap.get('Carnet').Id,
                UnitPrice = 0,
                CurrencyIsoCode = 'PLN',
                IsActive = true));
        insert priceBookEntryMap.values();

        Map<String, OpportunityLineItem> opportunityLineItemsMap = new Map<String, OpportunityLineItem>();
        opportunityLineItemsMap.put('Shell OLI', new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = productsMap.get('Shell Basic 2020').Id,
                PricebookEntryId = priceBookEntryMap.get('Shell PBE').Id,
                Quantity = 2,
                UnitPrice = 0));
        opportunityLineItemsMap.put('Carnet OLI', new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = productsMap.get('Carnet').Id,
                PricebookEntryId = priceBookEntryMap.get('Carnet PBE').Id,
                Quantity = 1,
                UnitPrice = 0));
        insert opportunityLineItemsMap.values();

        Map<String, Offer_Item_Type__c> offerItemTypesToInsertMap = new Map<String, Offer_Item_Type__c>();
        Offer_Item_Type__c shellType = new Offer_Item_Type__c(
                Name = 'Shell Fuel Card'
        );
        offerItemTypesToInsertMap.put(shellType.Name, shellType);
        Offer_Item_Type__c carnetType = new Offer_Item_Type__c(
                Name = 'Carnet OBD'
        );
        offerItemTypesToInsertMap.put(carnetType.Name, carnetType);
        insert offerItemTypesToInsertMap.values();

        Quote quote = new Quote(
                OpportunityId = opp.Id,
                Name = 'quote'
        );
        insert quote;

        QuoteLineItem quoteLineItem = new QuoteLineItem(
                Quote = quote,
                QuoteId = quote.Id,
                PricebookEntryId = priceBookEntryMap.get('Carnet PBE').Id,
                Quantity = 1,
                Product2Id = productsMap.get('Carnet').Id,
                UnitPrice = 0
        );
        insert quoteLineItem;

        OpportunityLineItem carnetLineItem = new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = priceBookEntryMap.get('Carnet PBE').Id,
                Product2Id = productsMap.get('Carnet').Id,
                Quantity = 1,
                TotalPrice = 0
        );
        insert carnetLineItem;

        Offer_Item__c carnetOfferItem = new Offer_Item__c(
                Opportunity_Product_Id__c = carnetLineItem.Id,
                Offer_Item_Type__c = offerItemTypesToInsertMap.get('Carnet OBD').Id,
                Driver_Name__c = 'Carnet Unit'
        );
        insert carnetOfferItem;

        Test.startTest();

        delete opportunityLineItemsMap.get('Carnet OLI');

        List<Quote> quotes = [SELECT Id FROM Quote];
        System.assert( ! quotes.isEmpty() );

        Test.stopTest();
    }

    @IsTest
    static void testPrefillAccountLookup () {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity];
        Product2 product = new Product2(
                Name = 'Shell Basic 2020',
                Integration_Name__c = 'shellpl',
                IsActive = true,
                Family = 'Shell'
        );
        insert product;
        PricebookEntry pricebookEntryObject = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = product.Id,
                UnitPrice = 0,
                CurrencyIsoCode = 'PLN',
                IsActive = true
        );
        insert pricebookEntryObject;
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = product.Id,
                PricebookEntryId = pricebookEntryObject.Id,
                Quantity = 2,
                UnitPrice = 0
        );
        OpportunityLineItem lineItem2 = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = product.Id,
                PricebookEntryId = pricebookEntryObject.Id,
                Quantity = 3,
                UnitPrice = 0
        );
        opportunityLineItems.add(lineItem1);
        opportunityLineItems.add(lineItem2);
        insert opportunityLineItems;

        Test.startTest();
        {
            opportunityLineItems = [SELECT Account__c, OpportunityId, Quantity FROM OpportunityLineItem];
            System.assertEquals(2, opportunityLineItems.size());

            for (OpportunityLineItem nextOpportunityLineItem : opportunityLineItems) {
                System.assertEquals(opp.AccountId, nextOpportunityLineItem.Account__c);
            }
        }
        Test.stopTest();
    }
}