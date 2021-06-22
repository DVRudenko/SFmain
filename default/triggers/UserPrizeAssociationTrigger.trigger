trigger UserPrizeAssociationTrigger on UserPrizeAssociation__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert) {
        UserPrizeAssociationHandler.updateAssociationUser(Trigger.new);
    }
}