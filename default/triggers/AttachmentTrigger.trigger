trigger AttachmentTrigger on Attachment(after delete, after insert, after undelete, after update, before delete,
        before insert, before update) {
    if (AttachmentTriggerHandler.enablesTrigger) {
        if (Trigger.isBefore && Trigger.isDelete) {
            // Access to delete report from Credit Reform
            AttachmentTriggerHandler.creditFactoryDeleteReport(Trigger.old);
        }

        //update field Task.Is_Exist_Attachment__c. "True" if exist any attachment
        if (Trigger.isAfter && Trigger.isInsert){
            AttachmentTriggerHandler.updateActivitiesWithAttachmentExist(null, Trigger.new);
            //Doesn't work for lightning file system anymore ;((
//            AttachmentTriggerHandler.processAttachmentToClosedCase(Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isUpdate){
            AttachmentTriggerHandler.updateActivitiesWithAttachmentExist(Trigger.old, Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isDelete){
            AttachmentTriggerHandler.updateActivitiesWithAttachmentExist(Trigger.old, null);
        }
        if (Trigger.isAfter && Trigger.isUndelete){
            AttachmentTriggerHandler.updateActivitiesWithAttachmentExist(null, Trigger.new);
        }
    }
}