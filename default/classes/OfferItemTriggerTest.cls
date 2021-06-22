@IsTest
private class OfferItemTriggerTest {
    @IsTest
    static void testCardsAndGpsUnit() {
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
        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = offerItemTypesToInsertMap.get('Shell Fuel Card').Id,
                Opportunity_Product_Id__c = opportunityLineItemsMap.get('Shell OLI').Id
        );
        Offer_item__c offerItem2 = new Offer_Item__c(
                Offer_Item_Type__c = offerItemTypesToInsertMap.get('Shell Fuel Card').Id,
                Opportunity_Product_Id__c = opportunityLineItemsMap.get('Shell OLI').Id
        );
        Offer_item__c offerItem3 = new Offer_Item__c(
                Offer_Item_Type__c = offerItemTypesToInsertMap.get('Carnet OBD').Id,
                Opportunity_Product_Id__c = opportunityLineItemsMap.get('Carnet OLI').Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem, offerItem2, offerItem3};
        insert items;

        Opportunity testOpp = [SELECT Anzahl_der_Karten__c, Number_of_GPS_units__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Anzahl_der_Karten__c == 2);
        System.assert(testOpp.Number_of_GPS_units__c == 2);
        Test.stopTest();
    }


    @IsTest
    static void testEvFobs() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'EV Fob'
        );
        insert type;

        Test.startTest();
        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        Offer_item__c offerItem2 = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem, offerItem2};
        insert items;

        Opportunity testOpp = [SELECT Non_fuel_exposure__c, Number_of_electric_vehicles__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Non_fuel_exposure__c == 200);
        System.assert(testOpp.Number_of_electric_vehicles__c == 2);
        Test.stopTest();
    }


    @IsTest
    static void testCardsEvFobs() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'EV Fob'
        );
        Offer_Item_Type__c type2 = new Offer_Item_Type__c(
                Name = 'Shell Fuel Card'
        );
        List<Offer_Item_Type__c> typesToInsert = new List<Offer_Item_Type__c>{type, type2};
        insert typesToInsert;

        Test.startTest();
        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        Offer_item__c offerItem2 = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        Offer_item__c offerItem3 = new Offer_Item__c(
                Offer_Item_Type__c = type2.Id,
                Opportunity_Product_Id__c = li.Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem, offerItem2, offerItem3};
        insert items;

        Opportunity testOpp = [SELECT Non_fuel_exposure__c, Number_of_electric_vehicles__c, Anzahl_der_Karten__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Non_fuel_exposure__c == 200);
        System.assert(testOpp.Number_of_electric_vehicles__c == 2);
        System.assert(testOpp.Anzahl_der_Karten__c == 1);
        Test.stopTest();
    }


    @IsTest
    static void testDeleteCards() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'Shell Fuel Card'
        );
        insert type;

        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        Offer_item__c offerItem2 = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem, offerItem2};
        insert items;

        Test.startTest();
        delete offerItem2;
        Opportunity testOpp = [SELECT Anzahl_der_Karten__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Anzahl_der_Karten__c == 1);
        Test.stopTest();
    }


    @IsTest
    static void testDeleteCards2() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'Shell Fuel Card'
        );
        insert type;

        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem};
        insert items;

        Test.startTest();
        delete items;
        Test.stopTest();

        Opportunity testOpp = [SELECT Anzahl_der_Karten__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Anzahl_der_Karten__c == 0);
    }


    @IsTest
    static void testDeleteEvFobs1() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'EV Fob'
        );
        insert type;

        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        Offer_item__c offerItem2 = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem, offerItem2};
        insert items;

        Test.startTest();
        delete offerItem2;
        Opportunity testOpp = [SELECT Number_of_electric_vehicles__c, Non_fuel_exposure__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Number_of_electric_vehicles__c == 1);
        System.assert(testOpp.Non_fuel_exposure__c == 100);
        Test.stopTest();
    }


    @IsTest
    static void testDeleteEvFobs2() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'EV Fob'
        );
        insert type;

        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem};
        insert items;

        Test.startTest();
        delete items;
        Test.stopTest();

        Opportunity testOpp = [SELECT Number_of_electric_vehicles__c, Non_fuel_exposure__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Number_of_electric_vehicles__c == 0);
        System.assert(testOpp.Non_fuel_exposure__c == 0);
    }


    @IsTest
    static void testCardsLotos() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true
        );
        insert opp;

        Product2 prod = new Product2(Name = 'test', Integration_Name__c = 'testpl', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 0,
                IsActive = true
        );
        insert pbe;

        OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 0
        );
        insert li;

        Offer_Item_Type__c type = new Offer_Item_Type__c(
                Name = 'Lotos Fuel Card'
        );
        insert type;

        Offer_item__c offerItem = new Offer_Item__c(
                Offer_Item_Type__c = type.Id,
                Opportunity_Product_Id__c = li.Id,
                Fuel_card_consumption_monthly__c = 2000
        );
        List<Offer_Item__c> items = new List<Offer_Item__c>{offerItem};

        Test.startTest();
            insert items;
        Test.stopTest();
        Opportunity testOpp = [SELECT Total_cards_consumption_monthly__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.Total_cards_consumption_monthly__c == 2000);
    }
}