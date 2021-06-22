trigger QuoteLineItemsTrigger on QuoteLineItem (before insert, before update) {
    new QuoteLineItemsTriggerHandler().run();
}