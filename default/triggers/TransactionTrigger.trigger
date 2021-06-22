trigger TransactionTrigger on Transaction__c(after delete, after insert, after undelete, after update, before delete, 
    													  before insert, before update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
    	TransactionTriggerHandler.distributionProcess(Trigger.new);
    }
}