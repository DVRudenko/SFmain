public without sharing class DeduplicationServiceHelper {
    /*******************************************************************************
     *  Name            : exculeObjectsFromList(List<sObject> sourceList, List<sObject> exclusionList)
     *  Summary         : e2e business, exclude opportunity linked account contacts from process
     *  CreatedDate     : 05/05/2020
     *  ModifiedDate    : -
     *  Parameters      : List<sObject> sourceList, List<sObject> exclusionList
     *  Returns         : List<sObject> - source list without excluded values
     ******************************************************************************/
    public static List<SObject> exculeObjectsFromList(List<SObject> sourceList, List<SObject> exclusionList) {
        if (sourceList != null && !sourceList.isEmpty() && exclusionList != null && !exclusionList.isEmpty()) {
            List<SObject> cleanedObjects = new List<SObject>();
            Map<Id, SObject> uniqueObjectForExcludeMap = new Map<Id, SObject>(exclusionList);
            for (SObject currentRecord : sourceList) {
                if (!uniqueObjectForExcludeMap.containsKey(currentRecord.Id)) {
                    cleanedObjects.add(currentRecord);
                }
            }
            return cleanedObjects;
        } else {
            return sourceList;
        }
    }

    /*******************************************************************************
     *  Name            : matchAdditionalEmails(List<Contact> contacts, String email)
     *  Summary         : processes a full email match for Additional_Emails__c field in Contact
     *  CreatedDate     : 30/06/2020
     *  ModifiedDate    : -
     *  Parameters      : List<Contact> contacts - contacts to be matched, String email - email to be found
     *  Returns         : List<Contact> - contacts with full match by email
     ******************************************************************************/
    public static List<Contact> matchAdditionalEmails(List<Contact> contacts, String email) {
        List<Contact> matchedContacts = new List<Contact>();
        for (Contact contact : contacts) {
            if (contact.Email != null && contact.Email.equals(email)) {
                matchedContacts.add(contact);
            } else if (contact.Additional_Emails__c != null && email != null && contact.Additional_Emails__c.split(':').contains(email)) {
                matchedContacts.add(contact);
            }
        }
        return matchedContacts;
    }

    /*******************************************************************************
     *  Name            : checkingOwnerForOpportunities(List<Opportunity> listOpportunity, E2EFormRuDeduplicationResult deduplicationResult)
     *  Summary         : e2e business, checking that all opportunities are with the same owner
     *  CreatedDate     : 24/02/2021
     *  ModifiedDate    : -
     *  Parameters      : List<Opportunity> listOpportunity, E2EFormRuDeduplicationResult deduplicationResult
     *  Returns         : -
     ******************************************************************************/
    public static Boolean checkingOwnerForOpportunities(List<Opportunity> foundOpportunities, Opportunity e2eOpportunity) {
        for (Opportunity opportunity : foundOpportunities) {
            if (opportunity.OwnerId != e2eOpportunity.OwnerId) {
                return true;
            }
        }
        return false;
    }
}