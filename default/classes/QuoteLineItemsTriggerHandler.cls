public class QuoteLineItemsTriggerHandler extends TriggerHandler {
    private List<QuoteLineItem> newQuoteLineItemsList;
    private Map<Id, QuoteLineItem> oldQuoteLineItemsMap;
    private Map<String, List<QuoteLineItem>> targetQuoteLineItemsMap;

    public QuoteLineItemsTriggerHandler() {
        this.newQuoteLineItemsList = (List<QuoteLineItem>) Trigger.new;
        this.oldQuoteLineItemsMap = (Map<Id, QuoteLineItem>) Trigger.oldMap;
        this.targetQuoteLineItemsMap = new Map<String, List<QuoteLineItem>>();
    }


    public override void beforeInsert() {
        for (QuoteLineItem quoteLineItem : this.newQuoteLineItemsList) {
            if (quoteLineItem.Discount > 0) {
                if (! this.targetQuoteLineItemsMap.containsKey('checkDiscountValue')) {
                    this.targetQuoteLineItemsMap.put('checkDiscountValue', new List<QuoteLineItem>());
                }
                this.targetQuoteLineItemsMap.get('checkDiscountValue').add(quoteLineItem);
            }
        }
        defineRequiredEvent();
    }


    public override void beforeUpdate() {
        for (QuoteLineItem quoteLineItem : this.newQuoteLineItemsList) {
            if (quoteLineItem.Discount != this.oldQuoteLineItemsMap.get(quoteLineItem.Id).Discount &&
                    quoteLineItem.Discount > 0) {
                if (! this.targetQuoteLineItemsMap.containsKey('checkDiscountValue')) {
                    this.targetQuoteLineItemsMap.put('checkDiscountValue', new List<QuoteLineItem>());
                }
                this.targetQuoteLineItemsMap.get('checkDiscountValue').add(quoteLineItem);
            }
        }
        defineRequiredEvent();
    }


    private void defineRequiredEvent() {
        if (this.targetQuoteLineItemsMap.containsKey('checkDiscountValue')) {
            checkDiscountValue();
        }
    }


    private void checkDiscountValue() {
        Map<String, Map<String, QuoteLineItem>> quoteWithQuoteLineItemsMap = new Map<String, Map<String, QuoteLineItem>>();
        Set<String> productIdsSet = new Set<String>();
        for (QuoteLineItem quoteLineItem : this.targetQuoteLineItemsMap.get('checkDiscountValue')) {
            if (! quoteWithQuoteLineItemsMap.containsKey(quoteLineItem.QuoteId)) {
                quoteWithQuoteLineItemsMap.put(quoteLineItem.QuoteId, new Map<String, QuoteLineItem>());
            }
            quoteWithQuoteLineItemsMap.get(quoteLineItem.QuoteId).put(quoteLineItem.Product2Id, quoteLineItem);
            productIdsSet.add(quoteLineItem.Product2Id);
        }
        Map<String, List<QuoteLineItem>> additionalQuoteLineItemsMap = new Map<String, List<QuoteLineItem>>();
        for (QuoteLineItem qli : [SELECT QuoteId, Product2Id FROM QuoteLineItem WHERE QuoteId IN : quoteWithQuoteLineItemsMap.keySet() LIMIT 1000]) {
            if (! additionalQuoteLineItemsMap.containsKey(qli.QuoteId)) {
                additionalQuoteLineItemsMap.put(qli.QuoteId, new List<QuoteLineItem>());
            }
            if (! quoteWithQuoteLineItemsMap.get(qli.QuoteId).containsKey(qli.Product2Id)) {
                additionalQuoteLineItemsMap.get(qli.QuoteId).add(qli);
                productIdsSet.add(qli.Product2Id);
            }
        }
        Map<String, Product2> shellProductsMap = new Map<String, Product2>([
            SELECT Id FROM Product2 WHERE Family = 'SHELL' AND Id IN :productIdsSet LIMIT 1000
        ]);

        for (String quoteId : quoteWithQuoteLineItemsMap.keySet()) {
            for (String productId : quoteWithQuoteLineItemsMap.get(quoteId).keySet()) {
                if (! shellProductsMap.containsKey(productId)) {
                    Boolean hasShellProduct = false;
                    if (additionalQuoteLineItemsMap.containsKey(quoteId)) {
                        for (QuoteLineItem additionalQuoteLineItem : additionalQuoteLineItemsMap.get(quoteId)) {
                            if (shellProductsMap.containsKey(additionalQuoteLineItem.Product2Id)) {
                                hasShellProduct = true;
                                break;
                            }
                        }
                    }
                    if (hasShellProduct == false) {
                        quoteWithQuoteLineItemsMap.get(quoteId).get(productId).addError('You can not provide discount on the product without a "SHELL" product');
                    }
                    if (quoteWithQuoteLineItemsMap.get(quoteId).get(productId).Discount > 30) {
                        quoteWithQuoteLineItemsMap.get(quoteId).get(productId).addError('You can provide discount of up to 30%');
                    }
                } else {
                    quoteWithQuoteLineItemsMap.get(quoteId).get(productId).addError('You can not provide discount on a "SHELL" product');
                }
            }
        }
    }
}