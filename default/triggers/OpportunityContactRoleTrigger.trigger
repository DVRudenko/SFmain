trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert) {
    OpportunityContactRoleTriggerHandler handler = new OpportunityContactRoleTriggerHandler();
    /* After Insert */
    if (trigger.isInsert && trigger.isAfter) {
        handler.afterInsert();
    }
}