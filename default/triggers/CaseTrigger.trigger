trigger CaseTrigger on Case (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        CaseTriggerHandler.processOfflineChatCase(Trigger.new);
        CaseTriggerHandler.preventCaseCreationForAutoReplyMessage(Trigger.new);
        CaseTriggerHandler.trimEmailAddressesInSupportCaseSubject(Trigger.new);
        CaseTriggerHandler.defineCaseTopicAndSubtopic(Trigger.new);
        CaseTriggerHandler.updateFieldsForClonedCases(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        CaseTriggerHandler.unassignFromInternalAccount(Trigger.new);
    }
}