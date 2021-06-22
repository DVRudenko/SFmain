trigger LiveChatTranscriptTrigger on LiveChatTranscript ( before insert, before update, after update ) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        LiveChatTranscriptTriggerHandler.setLookupFields(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        LiveChatTranscriptTriggerHandler.updateE2EChatFieldsInOpportunity(Trigger.new);
    }

}