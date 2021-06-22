trigger CCSOrderTrigger on CCS_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

        if (Trigger.isBefore && Trigger.isInsert) {
            //check OZ number with oz_number_checker__c list
            CCSOrderTriggerHandler.CheckOzNumberUpdateOwner(null, Trigger.new);
            //update Lead__c on CCS Order before insert
            CCSOrderTriggerHandler.updateLeadId(Trigger.new);
        }

        if(Trigger.isAfter && Trigger.isInsert){
            //update Opportunity Stage + other related fields from CCS Order based on Custom Settings mapping
            CCSOrderTriggerHandler.updateOpportunityFromCCSOrder(Trigger.oldMap, Trigger.newMap, true);
            //send CCS Welcome Email for newly created CCS Orders
            CCSOrderTriggerHandler.sendCCSWelcomeEmail(Trigger.newMap);
            //update Opportunity Type based on custom logic and data from CCS Order
            CCSOrderTriggerHandler.updateOpportunityType(Trigger.oldMap, Trigger.newMap);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            //check OZ number with oz_number_checker__c list
            CCSOrderTriggerHandler.CheckOzNumberUpdateOwner(Trigger.oldMap, Trigger.new);
            //send Order Stage, Status and other fields to Merlin
            CCSOrderTriggerHandler.sendOrderStagesToMerlin(Trigger.oldMap, Trigger.new);
            //update Opportunity fields from CCS Order based on Custom Settings mapping
            CCSOrderTriggerHandler.updateOpportunityFromCCSOrder(Trigger.oldMap, Trigger.newMap, false);
            //update Opportunity Stage + other related fields from CCS Order based on Custom Settings mapping
            CCSOrderTriggerHandler.updateOpportunityStage(Trigger.oldMap, Trigger.newMap);
            //update Opportunity Type based on custom logic and data from CCS Order
            CCSOrderTriggerHandler.updateOpportunityType(Trigger.oldMap, Trigger.newMap);
        }
}