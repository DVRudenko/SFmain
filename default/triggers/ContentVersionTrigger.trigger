trigger ContentVersionTrigger on ContentVersion (before insert, after insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        ContentVersionTriggerHandler.setupEmptyName(Trigger.new);
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        ContentVersionTriggerHandler.preventSignatureInsert(Trigger.new);
    }

}