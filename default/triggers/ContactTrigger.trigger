trigger ContactTrigger on Contact(after delete, after insert, after undelete, after update, before delete,
        before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        //save formatted phone numbers
        ContactTriggerHandler.unifyPhoneNumbers(Trigger.new);
    }

    //isE2EForm
    if(ContactTriggerHandler.isE2EForm){
        if (Trigger.isBefore && Trigger.isUpdate) {
            // process field values
            ContactTriggerHandler.setFields(Trigger.oldMap, Trigger.new);

            ContactTriggerHandler.isE2EForm = false;
            //send request to Emarsys
            EmarsysHandler.sendContactsToEmarsys(Trigger.oldMap, Trigger.newMap, 'RU');
        }
        if (Trigger.isBefore && Trigger.isInsert) {
            // process field values
            ContactTriggerHandler.setFields(null, Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isInsert) {
            ContactTriggerHandler.isE2EForm = false;
            //create OpportunityContactRole after new Contact created for an Account
            ContactTriggerHandler.createContactRoleInOpportunities(Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            ContactTriggerHandler.checkPhonesAfterUpdate(Trigger.oldMap, Trigger.new);
        }
    }

    if (ContactTriggerHandler.enablesTrigger) {
        if (Trigger.isBefore && Trigger.isUpdate) {
            //send request to Emarsys
            EmarsysHandler.sendContactsToEmarsys(Trigger.oldMap, Trigger.newMap, 'RU');

            ContactTriggerHandler.setRecordType(Trigger.new);

            // process field values
            ContactTriggerHandler.setFields(Trigger.oldMap, Trigger.new);

            ContactTriggerHandler.setMarketoSyncFlag(Trigger.oldMap, Trigger.new);
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            // Set AllStar record type
            ContactTriggerHandler.setRecordType(Trigger.new);

            // process field values
            ContactTriggerHandler.setFields(null, Trigger.new);

            ContactTriggerHandler.setMarketoSyncFlag(null, Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            /*update Primary_Contact_Phone__c in Opportunity if phone is changed and
            this contact is used as primary contact role in opportunity*/
            ContactTriggerHandler.updatePrimaryContactPhone(Trigger.oldMap, Trigger.newMap);
            ContactTriggerHandler.checkPhonesAfterUpdate(Trigger.oldMap, Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            //create OpportunityContactRole after new Contact created for an Account
            ContactTriggerHandler.createContactRoleInOpportunities(Trigger.new);
        }
    }
}