public class OfferItemHandler {
    public static Boolean enablesTrigger = true;

    public static void calculateOfferItems(List<Offer_Item__c> offerItemsList, Map<Id, Offer_Item__c> offerItemsMap) {
        Set<String> opptyLineItemIdsSet = new Set<String>();
        Set<String> typeIdsOfChangedOfferItemsSet = new Set<String>();
        Set<String> oliToRecalculationSet = new Set<String>();
        Map<String, List<Offer_Item__c>> existingOfferItemsMap = new Map<String, List<Offer_Item__c>>();
        if (Trigger.isDelete || Trigger.isInsert) {
            for (Offer_Item__c offerItem : offerItemsList) {
                opptyLineItemIdsSet.add(offerItem.Opportunity_Product_Id__c);
                typeIdsOfChangedOfferItemsSet.add(offerItem.Offer_Item_Type__c);
                oliToRecalculationSet.add(offerItem.Opportunity_Product_Id__c);
            }
            for (Offer_Item__c offerItem : [SELECT Opportunity_Product_Id__c FROM Offer_Item__c WHERE Opportunity_Product_Id__c IN :oliToRecalculationSet LIMIT 100]) {
                if (! existingOfferItemsMap.containsKey(offerItem.Opportunity_Product_Id__c)) {
                    existingOfferItemsMap.put(offerItem.Opportunity_Product_Id__c, new List<Offer_Item__c>());
                }
                existingOfferItemsMap.get(offerItem.Opportunity_Product_Id__c).add(offerItem);
            }
        } else if (Trigger.isUpdate) {
            for (Offer_Item__c offerItem : offerItemsList) {
                if (offerItemsMap.get(offerItem.Id).Fuel_card_consumption_monthly__c != offerItem.Fuel_card_consumption_monthly__c &&
                    offerItemsMap.get(offerItem.Id).Fuel_card_consumption_monthly__c != null) {
                    opptyLineItemIdsSet.add(offerItem.Opportunity_Product_Id__c);
                    typeIdsOfChangedOfferItemsSet.add(offerItem.Offer_Item_Type__c);
                }
            }
        }
        if (! opptyLineItemIdsSet.isEmpty()) {
            Set<String> changedProductNamesSet = new Set<String>();
            for (Offer_Item_Type__c offerItemType : [SELECT Name FROM Offer_Item_Type__c WHERE Id IN :typeIdsOfChangedOfferItemsSet LIMIT 100]) {
                changedProductNamesSet.add(offerItemType.Name);
            }
            List<OpportunityLineItem> opptyLineItemsList = [
                    SELECT OpportunityId, Quantity, UnitPrice
                    FROM OpportunityLineItem
                    WHERE Id IN :opptyLineItemIdsSet
                    LIMIT 100
            ];
            Set<String> opptyIdsSet = new Set<String>();
            List<OpportunityLineItem> opptyLineItemsToUpdateList = new List<OpportunityLineItem>();
            for (OpportunityLineItem lineitem : opptyLineItemsList) {
                opptyIdsSet.add(lineitem.OpportunityId);
                if (oliToRecalculationSet.contains(lineitem.Id) &&
                    existingOfferItemsMap.containsKey(lineitem.Id)) {
                    lineitem.Quantity = existingOfferItemsMap.get(lineitem.Id).size();
                    lineitem.UnitPrice = lineitem.UnitPrice;
                }
                opptyLineItemsToUpdateList.add(lineitem);
            }
            Map<String, Opportunity> opportunitiesMap = new Map<String, Opportunity>([
                    SELECT Id, E2E__c, E2E_2__c, Anzahl_der_Karten__c, Number_of_electric_vehicles__c, Non_fuel_exposure__c,
                            Total_consumption_l_month__c, Total_cards_consumption_monthly__c, Diesel_consumption_l_month__c,
                    (SELECT OpportunityId FROM OpportunityLineItems LIMIT 100)
                    FROM Opportunity
                    WHERE Id IN :opptyIdsSet
                    LIMIT 10000
            ]);
            List<String> availableOfferTypes = new List<String> {'Shell Fuel Card',
                                                                'EV Fob',
                                                                'Lotos Fuel Card',
                                                                'Carnet OBD',
                                                                'CCS Fuel Card Limit',
                                                                'CCS Fuel Card Limit Plus'};
            Map<String, String> opptyIdsByLineItemIdsMap = new Map<String, String>();
            Map<String, Map<String, List<Offer_Item__c>>> offerItemsByOpptyIdsMap = new Map<String, Map<String, List<Offer_Item__c>>>();
            for (Opportunity oppty : opportunitiesMap.values()) {
                if (! offerItemsByOpptyIdsMap.containsKey(oppty.Id)) {
                    offerItemsByOpptyIdsMap.put(oppty.Id, new Map<String, List<Offer_Item__c>>());
                }
                for (String availableOfferItemType : availableOfferTypes) {
                    offerItemsByOpptyIdsMap.get(oppty.Id).put(availableOfferItemType, new List<Offer_Item__c>());
                }
                for (OpportunityLineItem opptyLineItem : oppty.OpportunityLineItems) {
                    opptyIdsByLineItemIdsMap.put(opptyLineItem.Id, oppty.Id);
                }
            }
            List<Offer_Item__c> finalOfferItemsList = [
                    SELECT Opportunity_Product_Id__c, Offer_Item_Type__c, Offer_Item_Type__r.Name, Fuel_card_consumption_monthly__c
                    FROM Offer_Item__c
                    WHERE Opportunity_Product_Id__c IN :opptyIdsByLineItemIdsMap.keySet()
            ];
            for (Offer_Item__c offerItem : finalOfferItemsList) {
                String opptyId = opptyIdsByLineItemIdsMap.get(offerItem.Opportunity_Product_Id__c);
                if (offerItemsByOpptyIdsMap.get(opptyId).containsKey(offerItem.Offer_Item_Type__r.Name)) {
                    offerItemsByOpptyIdsMap.get(opptyId).get(offerItem.Offer_Item_Type__r.Name).add(offerItem);
                }
            }
            List<Opportunity> opptiesToUpdateList = new List<Opportunity>();
            for (Opportunity oppty : opportunitiesMap.values()) {
                if (!(UserInfo.getName() == 'E2E Site Guest User' && oppty.E2E__c == true)) {
                    Decimal totalConsumption = 0;
                    Decimal numberOfCards = 0;
                    Decimal numberOfElectricVehicles = 0;
                    Decimal numberOfGpsUnits = 0;
                    for (String offerItemTypeName : offerItemsByOpptyIdsMap.get(oppty.Id).keySet()) {
                        if (offerItemTypeName == 'EV Fob') {
                            numberOfElectricVehicles = offerItemsByOpptyIdsMap.get(oppty.Id).get(offerItemTypeName).size();
                        } else if (offerItemTypeName == 'Shell Fuel Card' ||
                                    offerItemTypeName == 'Lotos Fuel Card' ||
                                    offerItemTypeName == 'CCS Fuel Card Limit' ||
                                    offerItemTypeName == 'CCS Fuel Card Limit Plus') {
                            for (Offer_Item__c offerItem : offerItemsByOpptyIdsMap.get(oppty.Id).get(offerItemTypeName)) {
                                if (offerItem.Fuel_card_consumption_monthly__c == null) {
                                    offerItem.Fuel_card_consumption_monthly__c = 0;
                                }
                                if (UserInfo.getName() == 'E2E Site Guest User') {
                                    totalConsumption += offerItem.Fuel_card_consumption_monthly__c;
                                } else {
                                    if (offerItemTypeName == 'Lotos Fuel Card') {
                                        totalConsumption += offerItem.Fuel_card_consumption_monthly__c;
                                    }
                                }
                                numberOfCards += 1;
                            }
                        } else if (offerItemTypeName == 'Carnet OBD') {
                            numberOfGpsUnits = offerItemsByOpptyIdsMap.get(oppty.Id).get(offerItemTypeName).size();
                        }
                    }
                    if (UserInfo.getName() == 'E2E Site Guest User') {
                        oppty.Diesel_consumption_l_month__c = totalConsumption;
                        oppty.Total_consumption_l_month__c = totalConsumption;
                    }
                    if (changedProductNamesSet.contains('Lotos Fuel Card')) {
                        oppty.Total_cards_consumption_monthly__c = totalConsumption;
                    }
                    oppty.Anzahl_der_Karten__c = numberOfCards;
                    oppty.Number_of_electric_vehicles__c = numberOfElectricVehicles;
                    oppty.Non_fuel_exposure__c = 100 * numberOfElectricVehicles;
                    oppty.Number_of_GPS_units__c = numberOfGpsUnits;
                    opptiesToUpdateList.add(oppty);
                }
            }
            if (! opptiesToUpdateList.isEmpty()) { update opptiesToUpdateList; }
            if (! opptyLineItemsToUpdateList.isEmpty()) { update opptyLineItemsToUpdateList; }
        }
    }


    public static void syncQuoteData(List<Offer_Item__c> offerItemsList) {
        Set<String> productIdsSet = new Set<String>();
        for (Offer_Item__c offerItem : offerItemsList) {
            productIdsSet.add(offerItem.Opportunity_Product_Id__c);
        }
        Set<String> opptyIdsSet = new Set<String>();
        for (OpportunityLineItem opportunityLineItem : [SELECT OpportunityId FROM OpportunityLineItem WHERE Id IN :productIdsSet]) {
            opptyIdsSet.add(opportunityLineItem.OpportunityId);
        }
        Map<String, Opportunity> opportunitiesMap = new Map<String, Opportunity>([
                SELECT AccountId, Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity,
                        Account.BillingCountry, Account.ShippingCountry, Account.ShippingStreet, Account.ShippingPostalCode,
                        Account.ShippingCity, E2E_Data_Object__c,
                        (SELECT Name, UnitPrice, Description, Product2Id, Product2.Family, PriceBookEntry.Id, Quantity
                        FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Id IN :opptyIdsSet
        ]);
        Map<String, Map<String, OpportunityLineItem>> existingOpptyLineItemsByOppId = new Map<String, Map<String, OpportunityLineItem>>();
        Map<String, Set<String>> productFamiliesByOppId = new Map<String, Set<String>>();
        for (Opportunity oppty : opportunitiesMap.values()) {
            existingOpptyLineItemsByOppId.put(oppty.Id, new Map<String, OpportunityLineItem>());
            productFamiliesByOppId.put(oppty.Id, new Set<String>());
            for (OpportunityLineItem oli : oppty.OpportunityLineItems) {
                existingOpptyLineItemsByOppId.get(oppty.Id).put(oli.Product2Id, oli);
                productFamiliesByOppId.get(oppty.Id).add(oli.Product2.Family);
            }
        }
        if (! opportunitiesMap.isEmpty()) {
            Map<String, Quote> quotesToUpsertMap = new Map<String, Quote>();
            List<Quote> quotesToDeleteList = new List<Quote>();
            Map<String, Quote> finalQuotesByOpptyIdMap = new Map<String, Quote>();
            Map<String, Map<String, QuoteLineItem>> quoteLineItemsByOpptyIdMap = new Map<String, Map<String, QuoteLineItem>>();
            for (Quote quote : [SELECT AccountId, OpportunityId, BillingName, BillingStreet, BillingPostalCode, BillingCity,
                                    BillingCountry, ShippingName, ShippingCountry, ShippingStreet, ShippingPostalCode,
                                    ShippingCity, ContactId, Email, Discount,
                                    (SELECT Product2Id, QuoteId, UnitPrice, PricebookEntryId, Quantity, Description, Discount
                                    FROM QuoteLineItems)
                                FROM Quote
                                WHERE OpportunityId IN :opportunitiesMap.keySet()
                                ORDER BY CreatedDate DESC]) {
                if (! finalQuotesByOpptyIdMap.containsKey(quote.OpportunityId) &&
                    productFamiliesByOppId.get(quote.OpportunityId).contains('Carnet')) {
                    finalQuotesByOpptyIdMap.put(quote.OpportunityId, quote);
                    if (opportunitiesMap.get(quote.OpportunityId).AccountId != null && quote.ContactId == null) {
                        quotesToUpsertMap.put(quote.OpportunityId, quote);
                    }
                    quoteLineItemsByOpptyIdMap.put(quote.OpportunityId, new Map<String, QuoteLineItem>());
                    for (QuoteLineItem qli : quote.QuoteLineItems) {
                        quoteLineItemsByOpptyIdMap.get(quote.OpportunityId).put(qli.Product2Id, qli);
                    }
                } else {
                    quotesToDeleteList.add(quote);
                }
            }

            if (! quotesToDeleteList.isEmpty()) delete quotesToDeleteList;

            for (String opptyId : existingOpptyLineItemsByOppId.keySet()) {
                if (productFamiliesByOppId.get(opptyId).contains('Carnet') &&
                    ! finalQuotesByOpptyIdMap.containsKey(opptyId)) {
                    String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('SHELL / Carnet OBD').getRecordTypeId();
                    Quote quote = new Quote();
                    quote.RecordTypeId = recordTypeId;
                    quote.Name = 'Quote ' + Datetime.now();
                    quote.OpportunityId = opptyId;
                    quote.E2E_Data_Object__c = opportunitiesMap.get(opptyId).E2E_Data_Object__c;
                    finalQuotesByOpptyIdMap.put(opptyId, quote);
                    quoteLineItemsByOpptyIdMap.put(opptyId, new Map<String, QuoteLineItem>());
                    quotesToUpsertMap.put(opptyId, quote);
                }
            }
            if (! quotesToUpsertMap.isEmpty()) {
                Map<String, OpportunityContactRole> contactRolesByOpptyIdMap = new Map<String, OpportunityContactRole>();
                for (OpportunityContactRole ocr : [SELECT Id, OpportunityId, Contact.Email, Contact.Phone
                                                    FROM OpportunityContactRole
                                                    WHERE OpportunityId = :quotesToUpsertMap.keySet() AND ContactId != NULL AND
                                                    IsPrimary = true]) {
                    contactRolesByOpptyIdMap.put(ocr.OpportunityId, ocr);
                }
                for (String opptyId : quotesToUpsertMap.keySet()) {
                    mapQuoteFields(quotesToUpsertMap.get(opptyId), opportunitiesMap.get(opptyId), contactRolesByOpptyIdMap);
                }
                upsert quotesToUpsertMap.values();
            }

            List<QuoteLineItem> quoteLineItemsToUpsertList = new List<QuoteLineItem>();
            List<QuoteLineItem> quoteLineItemsToDeleteList = new List<QuoteLineItem>();
            for (String opptyId : quoteLineItemsByOpptyIdMap.keySet()) {
                for (String existProductId : existingOpptyLineItemsByOppId.get(opptyId).keySet()) {
                    OpportunityLineItem existOpportunityLineItem = existingOpptyLineItemsByOppId.get(opptyId).get(existProductId);
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.QuoteId = finalQuotesByOpptyIdMap.get(opptyId).Id;
                    qli.UnitPrice = existOpportunityLineItem.UnitPrice;
                    qli.Product2Id = existOpportunityLineItem.Product2Id;
                    qli.PricebookEntryId = existOpportunityLineItem.PriceBookEntry.Id;
                    qli.Quantity = existOpportunityLineItem.Quantity;
                    qli.Description = existOpportunityLineItem.Description;
                    if (! quoteLineItemsByOpptyIdMap.get(opptyId).containsKey(existProductId)) {
                        quoteLineItemsToUpsertList.add(qli);
                    } else {
                        QuoteLineItem existQli = quoteLineItemsByOpptyIdMap.get(opptyId).get(existProductId);
                        if (existQli.Quantity != existOpportunityLineItem.Quantity) {
                            qli.Discount = existQli.Discount;
                            qli.Description = existQli.Description;
                            quoteLineItemsToUpsertList.add(qli);
                            quoteLineItemsToDeleteList.add(existQli);
                        }
                        quoteLineItemsByOpptyIdMap.get(opptyId).remove(existProductId);
                    }
                }
                if (! quoteLineItemsByOpptyIdMap.get(opptyId).isEmpty()) {
                    quoteLineItemsToDeleteList.addAll(quoteLineItemsByOpptyIdMap.get(opptyId).values());
                }
            }
            if (! quoteLineItemsToUpsertList.isEmpty()) {
                upsert quoteLineItemsToUpsertList;
            }
            if (! quoteLineItemsToDeleteList.isEmpty()) {
                delete quoteLineItemsToDeleteList;
            }
        }
    }


    private static void mapQuoteFields(Quote quote, Opportunity oppty, Map<String, OpportunityContactRole> contactRolesByOpptyIdMap) {
        if (oppty.AccountId != null) {
            quote.BillingName = oppty.Account.Name;
            quote.BillingStreet = oppty.Account.BillingStreet;
            quote.BillingPostalCode = oppty.Account.BillingPostalCode;
            quote.BillingCity = oppty.Account.BillingCity;
            quote.BillingCountry = oppty.Account.BillingCountry;
            quote.ShippingName = oppty.Account.Name;
            quote.ShippingCountry = oppty.Account.ShippingCountry;
            quote.ShippingStreet = oppty.Account.ShippingStreet;
            quote.ShippingPostalCode = oppty.Account.ShippingPostalCode;
            quote.ShippingCity = oppty.Account.ShippingCity;
        }
        if (contactRolesByOpptyIdMap.containsKey(oppty.Id)) {
            OpportunityContactRole ocr = contactRolesByOpptyIdMap.get(oppty.Id);
            quote.ContactId = ocr.ContactId;
            quote.Phone = ocr.Contact.Phone;
            quote.Email = ocr.Contact.Email;
        }
    }


    public static void updateOpptyTypesOfCards(Map<Id, Offer_Item__c> offerItemsMap) {
        Set<String> lineItemIds = new Set<String>();
        for (Offer_Item__c offerItem : offerItemsMap.values()) {
            if (offerItem.Opportunity_Product_Id__c != null) {
                lineItemIds.add(offerItem.Opportunity_Product_Id__c);
            }
        }
        if ( ! lineItemIds.isEmpty() ) {
            Map<String, OpportunityLineItem> opportunityLineItemMap = new Map<String, OpportunityLineItem>([SELECT OpportunityId FROM OpportunityLineItem WHERE Id IN :lineItemIds]);

            Set<String> oppIdsSet = new Set<String>();
            for (OpportunityLineItem lineItem : opportunityLineItemMap.values()) {
                oppIdsSet.add(lineItem.OpportunityId);
            }
            Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>([SELECT Id, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :oppIdsSet]);
            if ( ! opportunityMap.isEmpty()) {
                Set<String> opptyLineItemIds = new Set<String>();
                for (Opportunity opportunity : opportunityMap.values()) {
                    for (OpportunityLineItem lineItem : opportunity.OpportunityLineItems) {
                        opptyLineItemIds.add(lineItem.Id);
                    }
                }
                Map<String, OpportunityLineItem> allOpportunityLineItemMap = new Map<String, OpportunityLineItem>([SELECT OpportunityId FROM OpportunityLineItem WHERE Id IN :opptyLineItemIds]);
                Map<String, Offer_Item__c> allOfferItemsMap = new Map<String, Offer_Item__c>([SELECT Type_of_Card__c, Opportunity_Product_Id__c FROM Offer_Item__c WHERE Opportunity_Product_Id__c IN :opptyLineItemIds]);
                Map<String, List<Offer_Item__c>> lineItemToOfferItemsMap = new Map<String, List<Offer_Item__c>>();
                for (Offer_Item__c offerItem : allOfferItemsMap.values()) {
                    if (offerItem.Opportunity_Product_Id__c != null) {
                        if ( ! lineItemToOfferItemsMap.containsKey(offerItem.Opportunity_Product_Id__c)) {
                            lineItemToOfferItemsMap.put(offerItem.Opportunity_Product_Id__c, new List<Offer_Item__c>());
                        }
                        lineItemToOfferItemsMap.get(offerItem.Opportunity_Product_Id__c).add(offerItem);
                    }
                }

                Map<String, List<OpportunityLineItem>> oppIdToLineItemsMap = new Map<String, List<OpportunityLineItem>>();
                for (OpportunityLineItem lineItem : allOpportunityLineItemMap.values()) {
                    if ( ! oppIdToLineItemsMap.containsKey(lineItem.OpportunityId)) {
                        oppIdToLineItemsMap.put(lineItem.OpportunityId, new List<OpportunityLineItem>());
                    }
                    oppIdToLineItemsMap.get(lineItem.OpportunityId).add(lineItem);
                }

                String typesOfCards;
                for (Opportunity opportunity : opportunityMap.values()) {
                    typesOfCards = null;
                    for (OpportunityLineItem lineItem : oppIdToLineItemsMap.get(opportunity.Id)) {
                        if (lineItemToOfferItemsMap.containsKey(lineItem.Id)) {
                            for (Offer_Item__c offerItem : lineItemToOfferItemsMap.get(lineItem.Id)) {
                                if (typesOfCards == null) {
                                    typesOfCards = offerItem.Type_of_Card__c;
                                } else if (offerItem.Type_of_Card__c != null && ! typesOfCards.contains(offerItem.Type_of_Card__c)) {
                                    typesOfCards = typesOfCards + '&'  + offerItem.Type_of_Card__c;
                                }
                            }
                        }
                    }
                    opportunity.Types_Of_Cards__c = typesOfCards;
                }

                OpportunityTriggerHandler.enablesTrigger = false;
                update opportunityMap.values();
                OpportunityTriggerHandler.enablesTrigger = true;
            }
        }
    }
}