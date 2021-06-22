trigger WorkThanksTrigger on WorkThanks (before insert, before update, after insert, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
		WorkThanksHandler.parserWorkThanksMessage(Trigger.new);
    }
}