trigger PaymentTransactionTrigger on Payment_Transaction__c (after update) {

    if ((Trigger.isAfter) && (Trigger.isUpdate)) {
        //update parent opportunity field after payment transaction are confirmed
        PaymentTransactionHandler.updateTransactionConfirmation(Trigger.oldMap, Trigger.newMap);
    }
}