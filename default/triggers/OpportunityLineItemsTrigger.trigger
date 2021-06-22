trigger OpportunityLineItemsTrigger on OpportunityLineItem (before insert, after insert, after update, after delete) {
    new OpportunityLineItemsTriggerHandler().run();
}