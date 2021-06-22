public class OpportunityScoreProcess {
    /*******************************************************************************
    *  Name            : setScoreToRelatedcontacts
    *  Summary         : invoked from process builder on OpportunityScore object. Sets Opportunity Score value to related Opportunity Contacts
    *  CreatedDate     : 24/05/2021
    *  ModifiedDate    :
    *  Parameters      : List<Id> oppIds - list of opportunities on which the score was set/changed
    *  Returns         : void
    ******************************************************************************/
    @InvocableMethod(label='Set Score to Related Opportunity Contacts' description='When Einstein Opportunity Score is set on an Opportunity - set its value to contacts related to the Opportunity' category='OpportunityScore')
    public static void setScoreToRelatedContacts(List<Id> oppIds) {
        if (oppIds == null || oppIds.isEmpty()) return;
        // set opportunity score on related contacts (if there are a few oppties related to a contact then the highest score is set)
        setScoreToRelatedContacts_Future(oppIds);
    }
    @future
    private static void setScoreToRelatedContacts_Future (List<Id> oppIds) {
        Map <Id, Contact> contactsToUpdate = ContactScoreHandler.setOpportunityScoreOnContacts_OppsList(new Set<Id> (oppIds));
        if (!contactsToUpdate.isEmpty()) update contactsToUpdate.values(); 
    }
}