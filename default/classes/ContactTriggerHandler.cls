public class ContactTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean isExecuting = false;
    public static Boolean isE2EForm = false;
    public static Boolean disableContactRolesInsertion = false;

    public static Map<String, RecordTypeInfo> contactRecordTypes{
        get{
            if(contactRecordTypes == null){
                contactRecordTypes = Schema.getGlobalDescribe().get(Contact.class.getName()).getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return contactRecordTypes;
        }
        private set;
    }

    private static Map<String, RecordTypeInfo> oppRecordTypes{
        get{
            if(oppRecordTypes == null){
                oppRecordTypes = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return oppRecordTypes;
        }
        private set;
    }

    private static final String RU_CONTACT_RECORD_TYPE = contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId();


    /*******************************************************************************
    *  Name            : unifyPhoneNumbers(List<Contact> contacts)
    *  Summary         : unify phone numbers
    *  CreatedDate     : 02.12.2019
    *  Parameters      : List<Contact> contacts - new Contact values
    *  Returns         : void
    ******************************************************************************/
    public static void unifyPhoneNumbers(List<Contact> contacts) {
        try {
            for (Contact contact : contacts) {
                if (RU_CONTACT_RECORD_TYPE.equals(contact.RecordTypeId)) {
                    unifyPhoneNumbers(contact);
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : unifyPhoneNumbers(Contact contact)
    *  Summary         : unify phone numbers in Contact record
    *  CreatedDate     : 02.12.2019
    *  Parameters      : Contact contact - Contact to process
    *  Returns         : void
    ******************************************************************************/
    public static void unifyPhoneNumbers(Contact contact) {
        PhoneNumberUtils.ListBuilder listBuilder = new PhoneNumberUtils.ListBuilder();
        listBuilder
                .addUnifiedPhoneNumber(contact.Phone)
                .addUnifiedPhoneNumber(contact.MobilePhone)
                .addUnifiedPhoneNumber(contact.PPR_Contact_Phone__c)
                .addUnifiedPhoneNumber(contact.HomePhone)
                .addUnifiedPhoneNumber(contact.AssistantPhone)
                .addUnifiedPhoneNumber(contact.OtherPhone);
        contact.Formatted_phones__c = listBuilder.getPhoneNumbersString();
        //if Additional_Phones__c is not empty, transfer values
        if (String.isNotBlank(contact.Additional_Phones__c)) {
            listBuilder.refresh();
            if (contact.Additional_Phones__c.contains('.')) {
                for (String phoneNumber : contact.Additional_Phones__c.split('[.]')) {
                    listBuilder.addUnifiedPhoneNumber(phoneNumber);
                }
            } else if (contact.Additional_Phones__c.contains(':')) {
                for (String phoneNumber : contact.Additional_Phones__c.split('[:]')) {
                    listBuilder.addUnifiedPhoneNumber(phoneNumber);
                }
            } else {
                //if no separators found, transfer single value
                listBuilder.addUnifiedPhoneNumber(contact.Additional_Phones__c);
            }
            contact.Formatted_phones_additional__c = listBuilder.getPhoneNumbersString();
        }
    }

    public static void setRecordType(List<Contact> newList) {
        for (Contact contact : newList) {
            if (contact.Lead_Record_Type__c == 'AllStar') {
                contact.RecordTypeId = contactRecordTypes.get('AllStar').getRecordTypeId();
            } else if (contact.Lead_Record_Type__c == 'Russian Sales') {
                contact.RecordTypeId = contactRecordTypes.get('Russian').getRecordTypeId();
            } else if (contact.Lead_Record_Type__c == 'Lotos') {
                contact.RecordTypeId = contactRecordTypes.get('Contact_layout').getRecordTypeId();
            }
        }
    }


    /*******************************************************************************
    *  Name            : updatePrimaryContactPhone(Map<Id, Contact> oldMap, Map<Id, Contact> newMap)
    *  Summary         : update Primary_Contact_Phone__c and Contact_Salutation__c in Opportunity if phone is changed and
                         this contact is used as primary contact role in opportunity
    *  CreatedDate     : 11/12/2017
    *  ModifiedDate    : 15/02/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void updatePrimaryContactPhone(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        Map<String, Contact> changedContactsMap = new Map<String, Contact>();
        for (Contact contact : newMap.values()) {
            if (contact.Phone != oldMap.get(contact.Id).Phone ||
                contact.Salutation != oldMap.get(contact.Id).Salutation) {
                changedContactsMap.put(contact.Id, contact);
            }

        }

        if (! changedContactsMap.isEmpty()) {
            List<OpportunityContactRole> primaryContactRolesList = [
                SELECT OpportunityId, ContactId, IsPrimary
                FROM OpportunityContactRole
                WHERE ContactId IN :changedContactsMap.keySet() AND
                    IsPrimary = TRUE AND
                    OpportunityId != null
                LIMIT 50000
            ];

            if (! primaryContactRolesList.isEmpty()) {
                Set<String> opptyIdsSet = new Set<String>();
                for (OpportunityContactRole ocr : primaryContactRolesList) {
                    opptyIdsSet.add(ocr.OpportunityId);
                }

                Map<String, Opportunity> opptiesToUpdateMap = new Map<String, Opportunity>([
                    SELECT Primary_Contact_Phone__c, Contact_Salutation__c, RecordTypeId, IsClosed
                    FROM Opportunity
                    WHERE Id IN :opptyIdsSet
                    LIMIT 50000
                ]);

                for (OpportunityContactRole ocr : primaryContactRolesList) {
                    //do not run for Russian_Sales IsClosed = true
                    if(opptiesToUpdateMap.get(ocr.OpportunityId).RecordTypeId == oppRecordTypes.get('Russian_Sales').getRecordTypeId() && opptiesToUpdateMap.get(ocr.OpportunityId).IsClosed){
                        //do not run
                    } else{
                        opptiesToUpdateMap.get(ocr.OpportunityId).Primary_Contact_Phone__c = changedContactsMap.get(ocr.ContactId).Phone;
                        opptiesToUpdateMap.get(ocr.OpportunityId).Contact_Salutation__c = changedContactsMap.get(ocr.ContactId).Salutation;
                    }
                    /*if(oppRecordTypes.get('Russian_Sales').getRecordTypeId() != opptiesToUpdateMap.get(ocr.OpportunityId).RecordTypeId && opptiesToUpdateMap.get(ocr.OpportunityId).IsClosed == false){
                        opptiesToUpdateMap.get(ocr.OpportunityId).Primary_Contact_Phone__c = changedContactsMap.get(ocr.ContactId).Phone;
                        opptiesToUpdateMap.get(ocr.OpportunityId).Contact_Salutation__c = changedContactsMap.get(ocr.ContactId).Salutation;
                    }*/
                }
                update opptiesToUpdateMap.values();
            }
        }
    }

    /*******************************************************************************
    *  Name            : createContactRoleInOpportunities()
    *  Summary         : create OpportunityContactRole after new Contact created for Account
    *  CreatedDate     : 18.01.2018
    *  Parameters      : List<Contact> newContactsList
    *  Returns         : void
    ******************************************************************************/
    public static void createContactRoleInOpportunities(List<Contact> newContactsList){       
        String recordContactTypeId = [
                SELECT Id
                From RecordType
                Where Name = 'Russian'
                AND SobjectType = 'Contact'].Id;

        if(ContactTriggerHandler.isExecuting || ContactTriggerHandler.disableContactRolesInsertion) {
            return;
        }

        ContactTriggerHandler.isExecuting = true;

        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContactsList){
            if(con.AccountId != null){      //Condition which provides checking of empty ID
                accountIds.add(con.AccountId);
            }
        }

        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN: accountIds ORDER BY CreatedDate LIMIT 5000];

        Map<Id,List<Opportunity>> opportunitiesByAccount = new Map<ID,List<Opportunity>>();
        for(Opportunity o : opportunities){
            if(!opportunitiesByAccount.containsKey(o.AccountId)){
                opportunitiesByAccount.put(o.AccountId,new List<Opportunity>());
            }
            opportunitiesByAccount.get(o.AccountId).add(o);
        }

        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        for(Contact con : newContactsList){
            if(opportunitiesByAccount.containsKey(con.AccountId) && con.RecordTypeId == recordContactTypeId){
                for(Opportunity opt : opportunitiesByAccount.get(con.AccountId)){
                    OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opt.Id, ContactId = con.Id);
                    opportunityContactRoles.add(ocr);
                }
            }
        }
        insert opportunityContactRoles;
    }

    /*******************************************************************************
    *  Name            : setFields(Map<Id, Account> oldMap, List<Account> newList)
    *  Summary         : process fields on new records
    *  CreatedDate     : 30/10/2019
    *  Parameters      : oldMap, newMap – maps from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void setFields(Map<Id, Contact> oldMap, List<Contact> newList) {
        PhoneNumbersHandler.sObjWrapperList recordsToProcessRU = new PhoneNumbersHandler.sObjWrapperList ();
        Set <Id> accIds = new Set <Id> ();
        Map <Id, List<Contact>> emptyCountryCode_contactsMap= new Map <Id, List<Contact>> ();
        for (Contact contact : newList) {
            Contact oldContact = oldMap == null ? null : oldMap.get(contact.Id);
            if (contact.RecordtypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()) {
        // ---- for Russia ----
                // process phones
                recordsToProcessRU.addSObj(Schema.Contact.sObjectType, contact, oldContact);
            } else {
        // ---- for EU ------
                // process country code
                accIds.add(contact.AccountId);
                if (contact.MailingCountryCode == null) {
                    if (!emptyCountryCode_contactsMap.containsKey(contact.AccountId)) emptyCountryCode_contactsMap.put(contact.AccountId, new List <Contact> ());
                    emptyCountryCode_contactsMap.get(contact.AccountId).add(contact);
                }
                // process phones
                ClickToCallHandler.checkPhonesOnRecordAndProcess (Schema.Contact.sObjectType, contact.MailingCountryCode, contact.MailingCountry, contact, oldContact);
            }
        }
        //process RU records
        recordsToProcessRU.processSObjects();

        //process EU records
        Map <Id, Account> parentAccsMap = getParentAccounts(accIds);
        setCountryCodesIfEmpty(emptyCountryCode_contactsMap, parentAccsMap);
    }

    /*******************************************************************************
    *  Name            : checkPhonesAfterUpdate(Map<Id, Account> oldMap, List<Account> newList)
    *  Summary         : if contact was moved to another account then check if we need to delete irrelevant phones on the account
    *  CreatedDate     : 17/12/2019
    *  Parameters      : oldMap, newMap – maps from the trigger (after update)
    *  Returns         : void
    ******************************************************************************/
    public static void checkPhonesAfterUpdate(Map<Id, Contact> oldMap, List<Contact> newList) {
        PhoneNumbersHandler.sObjWrapperList recordsToProcessRU = new PhoneNumbersHandler.sObjWrapperList ();
        for (Contact contact : newList) {
            Contact oldContact = oldMap == null ? null : oldMap.get(contact.Id);
            if (contact.RecordtypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()) {
        // ---- for Russia ----
                // process after update
                PhoneNumbersHandler.sObjWrapper sobjWrap = PhoneNumbersHandler.checkAccountIrrelevantPhonesAfterUpdate (Schema.Contact.sObjectType, contact, oldContact);
                if (sobjWrap != null) recordsToProcessRU.sObjList.add(sObjWrap);
            }
        }
        //process RU records
        recordsToProcessRU.processAfterUpdate();
    }

    /*******************************************************************************
    *  Name            : setCountryCodesIfEmpty(Map <Id, Contact> contactsWithParentAccsMap)
    *  Summary         : set country code on contacts: if it's empty then set it from the parent account
    *  CreatedDate     : 30/10/2019
    *  Parameters      : Map <Id, Contact> contactsWithParentAccsMap - map of account id => contact record
    *  Returns         : void
    ******************************************************************************/
    public static void setCountryCodesIfEmpty(Map <Id, List<Contact>> emptyCountryCode_contactsMap, Map <Id, Account> parentAccsMap) {
        if (emptyCountryCode_contactsMap == null || emptyCountryCode_contactsMap.isEmpty()) return;
        if (parentAccsMap == null || parentAccsMap.isEmpty()) return;
        for (Id accId : emptyCountryCode_contactsMap.keySet()) {
            for (Contact contact : emptyCountryCode_contactsMap.get(accId)) {
                Account parentAcc = parentAccsMap.get(accId);
                setCountryCode(parentAcc, contact);
            }
        }
    }
    /*******************************************************************************
    *  Name            : setCountryCode(Account parentAcc, Contact contact)
    *  Summary         : if country code on a contact is empty then set country code of the parent account
    *  CreatedDate     : 30/10/2019
    *  Parameters      : Account parentAcc of the contact, Contact contact - contact which is being processed by trigger
    *  Returns         : void
    ******************************************************************************/
    public static void setCountryCode(Account parentAcc, Contact contact) {
        if (parentAcc == null) return;
        system.debug('>>> in >>> setCountryCode ');
        if (contact.MailingCountryCode == null && parentAcc.BillingCountryCode != null) { // set country code
            contact.MailingCountryCode = parentAcc.BillingCountryCode;
            if (parentAcc.BillingCountry != null) { // set country
                contact.MailingCountry = parentAcc.BillingCountry;
            }
        }
    }
    /*******************************************************************************
    *  Name            : getParentAccounts(Set<Id> accIds)
    *  Summary         : get list of parent accounts for the contacts in the trigger
    *  CreatedDate     : 30/10/2019
    *  Parameters      : accIds - set of AccountId from contact records
    *  Returns         : Map <Id, Account> - map of account id => account record
    ******************************************************************************/
    public static Map <Id, Account> getParentAccounts(Set<Id> accIds) {
        Map <Id, Account> ret = new Map <Id, Account> ();
        if (accIds == null || accIds.isEmpty()) return ret;
        ret = new Map <Id, Account> ([SELECT Id, BillingCountry, BillingCountryCode FROM Account WHERE Id IN: accIds]);
        return ret;
    }

    public static void setMarketoSyncFlag(Map<Id, Contact> oldLeadMap, List<Contact> newContact){
        if( ! System.isBatch()){
            Map<String, Marketo_Integration__c> marketoSettings = Marketo_Integration__c.getAll();
            if(marketoSettings.get('General') != null && marketoSettings.get('General').Enabled__c){
                for(Contact contact : newContact){
                    if((oldLeadMap == null && contact.Email != null && contact.Lead_Record_Type__c == null) ||  // before insert (not convert)                                // before insert
                            (oldLeadMap != null && contact.Email != oldLeadMap.get(contact.Id).Email)){         // before update
                        contact.Marketo_Sync__c = false;
                        if (contact.RecordTypeId == contactRecordTypes.get('Contact_layout').getRecordTypeId() ||
                                contact.RecordTypeId == contactRecordTypes.get('CCS_Contact_layout').getRecordTypeId()) {
                            CustomDeduplicationAPI.executeActionsThroughEvents(contact, 'EU_Marketo_Contact_All');
                        }
                    }
                }
            }
        }
    }

}