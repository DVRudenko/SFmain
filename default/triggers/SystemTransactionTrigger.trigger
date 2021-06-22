trigger SystemTransactionTrigger on System_Transaction__c(after delete, after insert, after undelete, after update, before delete, 
        before insert, before update) {
        if (Trigger.isBefore && Trigger.isInsert) {
        	SystemTransactionTriggerHandler.updateOpportunity(Trigger.new);
        }
}