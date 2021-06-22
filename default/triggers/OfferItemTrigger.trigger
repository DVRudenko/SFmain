trigger OfferItemTrigger on Offer_Item__c (before insert, before update, before delete,
        after insert, after update, after delete) {
    if (OfferItemHandler.enablesTrigger) {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                OfferItemHandler.calculateOfferItems(Trigger.new, null);
                OfferItemHandler.syncQuoteData(Trigger.new);
                OfferItemHandler.updateOpptyTypesOfCards(Trigger.newMap);
            }
            if (Trigger.isDelete) {
                OfferItemHandler.calculateOfferItems(Trigger.old, null);
                OfferItemHandler.syncQuoteData(Trigger.old);
                OfferItemHandler.updateOpptyTypesOfCards(Trigger.oldMap);
            }
            if (Trigger.isUpdate) {
                OfferItemHandler.calculateOfferItems(Trigger.new, Trigger.oldMap);
                OfferItemHandler.syncQuoteData(Trigger.new);
                OfferItemHandler.updateOpptyTypesOfCards(Trigger.newMap);
            }
        }
    }
}