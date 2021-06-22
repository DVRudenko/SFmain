trigger TaskTrigger on Task(after delete, after insert, after undelete, after update, before delete,
        before insert, before update) {

    if (TaskTriggerHandler.enablesTrigger) {

        if (Trigger.isBefore && Trigger.isInsert) {
            // Set Russian Sales Record Type
            TaskTriggerHandler.setRecordType(Trigger.new);

            // Set Five9
            TaskTriggerHandler.setValidPhone(null, Trigger.new);

            //set duedate
            TaskTriggerHandler.setTodayDueDay(Trigger.new);
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            //Update Last_Task_Status_Change__c field if Task Status changed
            TaskTriggerHandler.updateLastTaskStatusChange(Trigger.oldMap, Trigger.newMap);

            // Set Five9
            TaskTriggerHandler.setValidPhone(Trigger.oldMap, Trigger.new);
        }

        if (Trigger.isBefore && Trigger.isDelete) {
            //Access to delete Tasks for sales
            TaskTriggerHandler.provideAccessToDeleteTasks(Trigger.old);
        }

        if (Trigger.isAfter && (Trigger.isInsert)) {
            // update field Is_Exist_Attachment__c. "True" if exist any attachment
            if (TaskTriggerHandler.enablesCheckAttachmentExist) {
                TaskTriggerHandler.checkAttachmentExist(Trigger.new);
            }

            // Set Primary Contact
            TaskTriggerHandler.sendToUpdatePrimaryContact(Trigger.new);

            // update field Number_of_open_tasks__c for Lead and Opportunity
            TaskTriggerHandler.updateNumberOfOpenTasksAndCheckbox(null, Trigger.newMap);
        }

        if (Trigger.isAfter && (Trigger.isUpdate)) {
            // update field Is_Exist_Attachment__c. "True" if exist any attachment
            if (TaskTriggerHandler.enablesCheckAttachmentExist) {
                TaskTriggerHandler.checkAttachmentExist(Trigger.new);
            }

            // update field Number_of_open_tasks__c for Lead and Opportunity
            TaskTriggerHandler.updateNumberOfOpenTasksAndCheckbox(Trigger.oldMap, Trigger.newMap);
        }

        if (Trigger.isAfter && (Trigger.isDelete)) {
            // update field Number_of_open_tasks__c for Lead and Opportunity
            TaskTriggerHandler.updateNumberOfOpenTasksAndCheckbox(Trigger.oldMap, null);
        }

        if (Trigger.isAfter && (Trigger.isUndelete)) {
            // update field Number_of_open_tasks__c for Lead and Opportunity
            TaskTriggerHandler.updateNumberOfOpenTasksAndCheckbox(null, Trigger.newMap);
        }
    }
}