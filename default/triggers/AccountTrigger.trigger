trigger AccountTrigger on Account(after delete, after insert, after undelete, after update, before delete,
        before insert, before update) {
    if(AccountTriggerHandler.isE2EForm){
        if (Trigger.isBefore && Trigger.isUpdate) {
            // process field values
            AccountTriggerHandler.setFields(Trigger.oldMap, Trigger.new);
        }
        if (Trigger.isBefore && Trigger.isInsert) {
            // process field values
            AccountTriggerHandler.setFields(null, Trigger.new);
        }
    }
    if (AccountTriggerHandler.enablesTrigger) {
        if(Trigger.isAfter && Trigger.isDelete){
            AccountTriggerHandler.removeBizMachineTag(Trigger.old);
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            //Capitilize fields
            AccountTriggerHandler.sendRussianRequestForChangeAccountOwner(Trigger.oldMap, Trigger.newMap);
            AccountTriggerHandler.maketouppercase(Trigger.new);
            AccountTriggerHandler.updateBeforeLastOwnerChangeDateRUS(Trigger.oldMap, Trigger.newMap);

            // process field values
            AccountTriggerHandler.setFields(Trigger.oldMap, Trigger.new);

            // Find duplicate Tax ID and add error message if it's true
            AccountTriggerHandler.findDuplicateTaxId(Trigger.oldMap, Trigger.new);

            //set Region__c and Area__c based on OKATO__c
            AccountTriggerHandler.setRecordAddressFromOKATO(Trigger.oldMap, Trigger.new);
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            //Capitilize fields
            AccountTriggerHandler.maketouppercase(Trigger.new);

            // set AllStar record type
            AccountTriggerHandler.setRecordType(Trigger.new);

            // process field values
            AccountTriggerHandler.setFields(null, Trigger.new);

            // Find duplicate Tax ID and add error message if it's true
            AccountTriggerHandler.findDuplicateTaxId(Trigger.oldMap, Trigger.new);

            //Copy Billing Address to Shipping Address for CCS
            AccountTriggerHandler.setShippingAddressCCS(Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isInsert){
            AccountTriggerHandler.getAccountDataFromBizmachine(Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            AccountTriggerHandler.parentChildDefinition(Trigger.new);
            if (AccountTriggerHandler.isChild) {
                AccountTriggerHandler.updateChild(Trigger.oldMap, Trigger.newMap);
            }
            if (AccountTriggerHandler.isParent) {
                AccountTriggerHandler.updateParent(Trigger.oldMap, Trigger.newMap);
            }

            /*add Ilya Garin 13.10.2017 set Last Date Change Owner RUS and Open_Task__c checkbox in Opportunity*/
            AccountTriggerHandler.updateLastDateChangeOwnerRUSOpportunityAndOpenTaskCheckBox(Trigger.oldMap, Trigger.newMap);

            //Update the CurrencyIsoCode in Opportunity
            AccountTriggerHandler.updateCurrencyIsoCode(Trigger.oldMap, Trigger.new);

            //CCS BizMachine Edit ICO
            AccountTriggerHandler.changedICOBizMachine(Trigger.oldMap, Trigger.new);
        }
    }
}