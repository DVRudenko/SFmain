@IsTest
private class TemporaryBatchTest {
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

        Map<String, Product2> productsMap = new Map<String, Product2>();
        productsMap.put('Shell Basic 2020', new Product2(
                Name = 'Shell Basic 2020',
                Integration_Name__c = 'shellpl',
                IsActive = true,
                Family = 'Shell'
        ));
        insert productsMap.values();

        Map<String, PricebookEntry> priceBookEntryMap = new Map<String, PricebookEntry>();
        priceBookEntryMap.put('Shell PBE', new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productsMap.get('Shell Basic 2020').Id,
                UnitPrice = 0,
                CurrencyIsoCode = 'PLN',
                IsActive = true
        ));
        insert priceBookEntryMap.values();

        Map<String, OpportunityLineItem> opportunityLineItemsMap = new Map<String, OpportunityLineItem>();
        opportunityLineItemsMap.put('Shell OLI', new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = productsMap.get('Shell Basic 2020').Id,
                PricebookEntryId = priceBookEntryMap.get('Shell PBE').Id,
                Quantity = 2,
                UnitPrice = 0
        ));
        insert opportunityLineItemsMap.values();

        Additional_Service__c addService = new Additional_Service__c(
                Type__c = 'Eco Fee',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'ecofeepl'
        );
        insert addService;

        Client_Offer_Additional_Service__c oas = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Selected__c = true,
                Additional_Service__c = addService.Id
        );
        insert oas;
    }

    @IsTest
    static void testTemporaryBatchToUpdateOppLineItems () {
        OpportunityLineItem lineItem = [SELECT Account__c FROM OpportunityLineItem];
        Account acc = [SELECT Id FROM Account];
        System.assertEquals(acc.Id, lineItem.Account__c);

        lineItem.Account__c = null;
        update lineItem;
        System.assertEquals(null, [SELECT Account__c FROM OpportunityLineItem].Account__c);

        Test.startTest();
        Database.executeBatch(new TemporaryBatchToUpdateOppLineItems(), 1);
        Test.stopTest();

        System.assertEquals(acc.Id, [SELECT Account__c FROM OpportunityLineItem].Account__c);
    }

    @IsTest
    static void testTemporaryBatchToUpdateClientOfferAS () {
        Client_Offer_Additional_Service__c addService = [SELECT Account__c FROM Client_Offer_Additional_Service__c];
        Account acc = [SELECT Id FROM Account];
        System.assertEquals(acc.Id, addService.Account__c);

        ClientOfferAddServiceHandler.enablesTrigger = false;
        addService.Account__c = null;
        update addService;
        ClientOfferAddServiceHandler.enablesTrigger = true;
        System.assertEquals(null, [SELECT Account__c FROM Client_Offer_Additional_Service__c].Account__c);

        Test.startTest();
        Database.executeBatch(new TemporaryBatchToUpdateClientOfferAS(), 1);
        Test.stopTest();

        System.assertEquals(acc.Id, [SELECT Account__c FROM Client_Offer_Additional_Service__c].Account__c);
    }
}
