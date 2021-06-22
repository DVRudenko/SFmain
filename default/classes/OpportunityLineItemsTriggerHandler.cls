public class OpportunityLineItemsTriggerHandler extends TriggerHandler {
    private List<OpportunityLineItem> newOpptyLineItemsList;
    private Map<Id, OpportunityLineItem> oldOpptyLineItemsMap;
    private Map<String, List<OpportunityLineItem>> targetOpptyLineItemsMap;

    public OpportunityLineItemsTriggerHandler() {
        this.newOpptyLineItemsList = (List<OpportunityLineItem>) Trigger.new;
        this.oldOpptyLineItemsMap = (Map<Id, OpportunityLineItem>) Trigger.oldMap;
        this.targetOpptyLineItemsMap = new Map<String, List<OpportunityLineItem>>();
    }

    public override void beforeInsert () {
        for (OpportunityLineItem opptyLineItem : this.newOpptyLineItemsList) {
            if (! this.targetOpptyLineItemsMap.containsKey('prefillAccountLookup')) {
                this.targetOpptyLineItemsMap.put('prefillAccountLookup', new List<OpportunityLineItem>());
            }
            this.targetOpptyLineItemsMap.get('prefillAccountLookup').add(opptyLineItem);
        }
        defineRequiredEvent();
    }


    public override void afterInsert() {
        for (OpportunityLineItem opptyLineItem : this.newOpptyLineItemsList) {
            if (! this.targetOpptyLineItemsMap.containsKey('updateOpptyOffersNames')) {
                this.targetOpptyLineItemsMap.put('updateOpptyOffersNames', new List<OpportunityLineItem>());
            }
            this.targetOpptyLineItemsMap.get('updateOpptyOffersNames').add(opptyLineItem);
        }
        defineRequiredEvent();
    }


    public override void afterDelete() {
        for (OpportunityLineItem opptyLineItem : this.oldOpptyLineItemsMap.values()) {
            if (! this.targetOpptyLineItemsMap.containsKey('syncQuoteData')) {
                this.targetOpptyLineItemsMap.put('syncQuoteData', new List<OpportunityLineItem>());
            }
            this.targetOpptyLineItemsMap.get('syncQuoteData').add(opptyLineItem);

            if (! this.targetOpptyLineItemsMap.containsKey('updateOpptyOffersNames')) {
                this.targetOpptyLineItemsMap.put('updateOpptyOffersNames', new List<OpportunityLineItem>());
            }
            this.targetOpptyLineItemsMap.get('updateOpptyOffersNames').add(opptyLineItem);
        }
        defineRequiredEvent();
    }


    private void defineRequiredEvent() {
        if (this.targetOpptyLineItemsMap.containsKey('syncQuoteData')) {
            syncQuoteData();
        }
        if (this.targetOpptyLineItemsMap.containsKey('updateOpptyOffersNames')) {
            updateOpptyOffersNames();
        }
        if (this.targetOpptyLineItemsMap.containsKey('prefillAccountLookup')) {
            prefillAccountLookup();
        }
    }


    private void updateOpptyOffersNames() {
        Set<String> opptyIdsSet = new Set<String>();
        for (OpportunityLineItem opptyLineItem : this.targetOpptyLineItemsMap.get('updateOpptyOffersNames')) {
            opptyIdsSet.add(opptyLineItem.OpportunityId);
        }

        String offersNames;
        Map<String, Opportunity> opportunitiesMap = new Map<String, Opportunity>([
                SELECT Id,
                       (SELECT Product2.Name FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Id IN :opptyIdsSet
        ]);

        if ( ! opportunitiesMap.isEmpty() ) {
            for (Opportunity oppty : opportunitiesMap.values()) {
                offersNames = null;
                for (OpportunityLineItem opptyLineItem : oppty.OpportunityLineItems) {
                    if (offersNames == null) {
                        offersNames = opptyLineItem.Product2.Name;
                    } else {
                        offersNames = offersNames + '&' + opptyLineItem.Product2.Name;
                    }
                }
                oppty.Offers_Names__c = offersNames;
            }

            OpportunityTriggerHandler.enablesTrigger = false;
            update opportunitiesMap.values();
            OpportunityTriggerHandler.enablesTrigger = true;
        }
    }


    private void syncQuoteData() {
        Set<String> opptyIdsSet = new Set<String>();
        for (OpportunityLineItem oli : this.targetOpptyLineItemsMap.get('syncQuoteData')) {
            opptyIdsSet.add(oli.OpportunityId);
        }
        Map<String, Opportunity> opportunitiesMap = new Map<String, Opportunity>([
                SELECT AccountId, Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity,
                        Account.BillingCountry, Account.ShippingCountry, Account.ShippingStreet, Account.ShippingPostalCode,
                        Account.ShippingCity, E2E_Data_Object__c,
                        (SELECT Name, UnitPrice, Description, Product2Id, Product2.Family, PricebookEntry.Id, Quantity
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
        Map<String, Quote> quotesByOpptyIdMap = new Map<String, Quote>();
        for (Quote quote : [SELECT AccountId, OpportunityId, BillingName, BillingStreet, BillingPostalCode, BillingCity,
                                    BillingCountry, ShippingName, ShippingCountry, ShippingStreet, ShippingPostalCode,
                                    ShippingCity, ContactId, Email, Discount,
                                    (SELECT Product2Id FROM QuoteLineItems)
                            FROM Quote
                            WHERE OpportunityId IN :opportunitiesMap.keySet()
                            ORDER BY CreatedDate DESC]) {
            if (! quotesByOpptyIdMap.containsKey(quote.OpportunityId)) {
                quotesByOpptyIdMap.put(quote.OpportunityId, quote);
            }
        }
        List<Quote> quotesToDeleteList = new List<Quote>();
        List<QuoteLineItem> quoteLineItemsToDeleteList = new List<QuoteLineItem>();
        for (String opptyId : existingOpptyLineItemsByOppId.keySet()) {
            if (quotesByOpptyIdMap.containsKey(opptyId)) {
                if (! productFamiliesByOppId.get(opptyId).contains('Carnet')) {
                    quotesToDeleteList.add(quotesByOpptyIdMap.get(opptyId));
                } else {
                    for (OpportunityLineItem oli : this.targetOpptyLineItemsMap.get('syncQuoteData')) {
                        for (QuoteLineItem qli : quotesByOpptyIdMap.get(opptyId).QuoteLineItems) {
                            if (qli.Product2Id == oli.Product2Id) {
                                quoteLineItemsToDeleteList.add(qli);
                            }
                        }
                    }
                }
            }
        }
        if (! quoteLineItemsToDeleteList.isEmpty()) delete quoteLineItemsToDeleteList;
        if (! quotesToDeleteList.isEmpty()) delete quotesToDeleteList;
    }

    private void prefillAccountLookup() {
        Set<String> opportunitiesIds = new Set<String>();
        for (OpportunityLineItem nextOpportunityLineItem : this.targetOpptyLineItemsMap.get('prefillAccountLookup')) {
            opportunitiesIds.add(nextOpportunityLineItem.OpportunityId);
        }
        Map<String, Opportunity> opportunitiesByIds = new Map<String, Opportunity>([
                SELECT  AccountId
                FROM    Opportunity
                WHERE   Id IN : opportunitiesIds
        ]);
        for (OpportunityLineItem nextOpportunityLineItem : this.targetOpptyLineItemsMap.get('prefillAccountLookup')) {
            nextOpportunityLineItem.Account__c = opportunitiesByIds.get(nextOpportunityLineItem.OpportunityId).AccountId;
        }
    }
}