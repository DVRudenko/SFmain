trigger EventTrigger on Event(after delete, after insert, after undelete, after update, before delete,
		before insert, before update) {
    if (EventTriggerHandler.enablesTrigger == true) {
    	if (Trigger.isBefore && Trigger.isInsert) {
			EventTriggerHandler.connectEventsWithContacts(null, Trigger.new);
			EventTriggerHandler.setNowOnEventDate(Trigger.new);
    	}

    	if (Trigger.isBefore && Trigger.isUpdate) {
    		EventTriggerHandler.connectEventsWithContacts(Trigger.oldMap, Trigger.new);

			EventTriggerHandler.updateLastEventStatusChange(Trigger.oldMap, Trigger.newMap);
    	}

		if (Trigger.isAfter && Trigger.isInsert){
			if (EventTriggerHandler.enablesCheckAttachmentExist) {
				EventTriggerHandler.checkAttachmentExist(Trigger.new);
			}
		}

		if (Trigger.isAfter && Trigger.isUpdate){
			if (EventTriggerHandler.enablesCheckAttachmentExist) {
				EventTriggerHandler.checkAttachmentExist(Trigger.new);
			}
		}
    }
}