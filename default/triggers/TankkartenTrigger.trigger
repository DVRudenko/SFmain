trigger TankkartenTrigger on Tankkarten__c(after delete, after insert, after undelete, after update, before delete, 
		before insert, before update) {
	if (TankkartenHandler.enablesTrigger) {
		if (Trigger.isBefore && Trigger.isUpdate) {
			//Capitilize fields
			TankkartenHandler.maketouppercase(Trigger.new);
		}

		if (Trigger.isBefore && Trigger.isInsert) {
			//Capitilize fields
			TankkartenHandler.maketouppercase(Trigger.new);
		}
	}
}