trigger ClientOfferAddServiceTrigger on Client_Offer_Additional_Service__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    if (ClientOfferAddServiceHandler.enablesTrigger) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                ClientOfferAddServiceHandler.prefillAccountLookup(Trigger.new, null);
            }
            if (Trigger.isUpdate) {
                ClientOfferAddServiceHandler.prefillAccountLookup(Trigger.new, Trigger.oldMap);
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                ClientOfferAddServiceHandler.addAdditionalServicesToOpp(Trigger.newMap);
                ClientOfferAddServiceHandler.updateOpptyAdditionalServicesNames(Trigger.newMap);
            }
            if (Trigger.isUpdate) {
                ClientOfferAddServiceHandler.addAdditionalServicesToOpp(Trigger.newMap);
                ClientOfferAddServiceHandler.updateOpptyAdditionalServicesNames(Trigger.newMap);
            }
            if (Trigger.isDelete) {
                ClientOfferAddServiceHandler.removeAdditionalServicesToOpp(Trigger.old);
                ClientOfferAddServiceHandler.updateOpptyAdditionalServicesNames(Trigger.oldMap);
            }
        }

    }
}