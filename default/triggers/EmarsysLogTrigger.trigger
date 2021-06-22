trigger EmarsysLogTrigger on Emarsys_Log__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        EmarsysLogTriggerHandler.updateLeadStatus(Trigger.New);
    }
}