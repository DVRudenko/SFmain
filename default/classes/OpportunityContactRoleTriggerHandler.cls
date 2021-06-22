public class OpportunityContactRoleTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        // copy scoring from the the scored opp to related contacts
        setOpportunityScoreOnContact(trigger.new); 
    }
     /*******************************************************************************
    *  Name            : setOpportunityScoreOnContact
    *  Summary         : for list of OpportunityContactRole contacts: set the highest open opportunity score
    *  CreatedDate     : 02.04.2021
    *  Parameters      : List <OpportunityContactRole> newOppContactRoles - contact roles for which the oppportunity score will be set 
                         score is set on contact if any open opportunty related to the contact has a score value
    *  Returns         : -
    ******************************************************************************/
    private void setOpportunityScoreOnContact (List <OpportunityContactRole> newOppContactRoles) {
        try {
            // get contacts related to the opportunity contact roles (with record type 'Contact_layout')
            Set <Id> contactIds = new Set <Id> ();
            for (OpportunityContactRole ocr : newOppContactRoles) {
                contactIds.add(ocr.ContactId);
            }
            Id conRTId_contactLayout = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId();
            List <Contact> contacts = [SELECT Id, Opportunity_Scoring__c 
                                       FROM Contact 
                                       WHERE Id IN :contactIds
                                       AND Contact.RecordTypeId = :conRTId_contactLayout];
            if (contacts.isEmpty()) return; // set Opportunity Scores from contacts on contacts with "Contact_Layout" record type only 
            // create a map contact id => current score value on the contact
            Map <Id, Integer> contactsMapWithCurrentScore = new Map <Id, Integer> ();
            for (Contact con : contacts) {
                contactsMapWithCurrentScore.put(con.Id, (Integer)con.Opportunity_Scoring__c);
            }
            // set score on contacts: set score from related oppties (if a few oppties related then the highest of the scores is set)
            Map <Id, Contact> contactsWithUpdatedScores = ContactScoreHandler.setOpportunityScoreOnContacts_ContactRoles(contactsMapWithCurrentScore);
            if (!contactsWithUpdatedScores.isEmpty()) update contactsWithUpdatedScores.values();
        } catch(Exception e){
            ExceptionLogger.sendException(
                'OpportunityContactRoleTriggerHandler setOpportunityScoreOnContact:: errMsg: ' + e.getMessage() + '; List <OpportunityContactRole> newOppContactRoles: ' + newOppContactRoles,
                e.getStackTraceString()
            );
        }
    }
}