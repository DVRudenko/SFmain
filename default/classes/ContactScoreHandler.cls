public without sharing class ContactScoreHandler {
    @testVisible private static Integer theHighestScoreForTesting; // set score on existing related oppties to prevent the tests failing since there are no opportunity scores on sandboxes (we use Einstein Opportunity Scoring for Everyone)
    
    /*******************************************************************************
    *  Name            : setOpportunityScoreOnContacts_OppsList
    *  Summary         : for list of opportunities : set the highest open opportunity score on related contacts
    *  CreatedDate     : 02.04.2021
    *  Parameters      : Set <Id> oppIds - list of opportunity ids on which related contacts the score will be set
    *  Returns         : Map <Id, Contact> -  map of contacts to update scores : contact id > contact record with the new score set (not updated in the database yet)
    ******************************************************************************/
    public static Map <Id, Contact> setOpportunityScoreOnContacts_OppsList(Set <Id> oppIds) {
        Map <Id, Contact> ret = new Map <Id, Contact> ();
        try {
            if (oppIds == null || oppIds.isEmpty()) return ret;
            // create a map contact id => current score value on the contact
            Map <Id, Integer> currentContactScoresMap = new Map <Id, Integer> ();
            // get opportunity contact roles for oppties on which the score was updated
            List <OpportunityContactRole> ocrs = [
                SELECT ContactId, Contact.Opportunity_Scoring__c
                FROM OpportunityContactRole 
                WHERE OpportunityId IN :oppIds
            ];
            if (ocrs.isEmpty()) return ret; // no contacts to update 
            for (OpportunityContactRole ocr : ocrs) {
                currentContactScoresMap.put(ocr.ContactId, (Integer)ocr.Contact.Opportunity_Scoring__c);
            }
            // set score on contacts: set score from related oppties (if a few oppties related then the highest of the scores is set)
            Set <Id> contactIds = currentContactScoresMap.keySet();
            Map <Id, Integer> contactsWithTheHighesOppScore = getTheHighestOppScores (contactIds);
            ret = setTheHighestOppScores (contactsWithTheHighesOppScore, currentContactScoresMap);

        } catch(Exception e){
            ExceptionLogger.sendException(
                'ContactScoreHandler setOpportunityScoreOnContacts_OppsList:: errMsg: ' + e.getMessage(),
                e.getStackTraceString()
            );
        }
        return ret;
    }

    /*******************************************************************************
    *  Name            : setOpportunityScoreOnContacts_ContactRoles
    *  Summary         : for list of opportunity contact roles: set the highest open opportunity score on the contact
    *  CreatedDate     : 02.04.2021
    *  Parameters      : Map <Id, Integer> currentContactScoresMap - map of contact id > current contact score value - for the contacts on which the score will be set
    *  Returns         : Map <Id, Contact> - map of contacts to update scores : contact id > contact record with the new score set (not updated in the database yet)
    ******************************************************************************/
    public static Map <Id, Contact> setOpportunityScoreOnContacts_ContactRoles(Map <Id, Integer> currentContactScoresMap) {
        Map <Id, Contact> ret = new Map <Id, Contact> ();
        try {
            if (currentContactScoresMap == null || currentContactScoresMap.isEmpty()) return ret;
            // set score on contacts: set score from related oppties (if a few oppties related then the highest of the scores is set)
            Set <Id> contactIds = currentContactScoresMap.keySet();
            Map <Id, Integer> contactsWithTheHighestOppScore = getTheHighestOppScores (contactIds);
            ret = setTheHighestOppScores (contactsWithTheHighestOppScore, currentContactScoresMap);
        } catch(Exception e){
            ExceptionLogger.sendException(
                'ContactScoreHandler setOpportunityScoreOnContacts_ContactRoles:: errMsg: ' + e.getMessage() + '; Map <Id, Integer> currentContactScoresMap: ' + currentContactScoresMap,
                e.getStackTraceString()
            );
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getTheHighestOppScores
    *  Summary         : get the highest score from all opportunities related to the contacts
    *  CreatedDate     : 02.04.2021
    *  Parameters      : Set <Id> contactIds - set of contact ids - for these contacts the existing scored open oppties will be searched
    *  Returns         : Map <Id, Integer> - map of contact id : contact id > the highest score on existing open oppties
    ******************************************************************************/
    private static Map <Id, Integer> getTheHighestOppScores (Set <Id> contactIds) {
        Map <Id, Integer> ret = new Map <Id, Integer> ();
        try {
            // get all oppties with score set related to the contacts
            String queryStr = 'SELECT ContactId, Opportunity.IqScore FROM OpportunityContactRole ';
            queryStr += ' WHERE ContactId IN :contactIds ';
            if (!Test.isRunningTest()) {
                queryStr +=' AND Opportunity.IqScore != null '; 
                queryStr += ' AND Opportunity.IqScore != -1 '; // -1 is set for oppties "that don’t have scores because of limited access to opportunity scores"
            }
            List <OpportunityContactRole> ocrs = (List <OpportunityContactRole>) Database.query(queryStr);
            if (ocrs.isEmpty()) return ret; // no score oppties; return empty map
            // get the highest score on the opportunities
            for (OpportunityContactRole ocr : ocrs) {
                // in unit tests on sandboxes we can't get iqScore value due to te free licence. a separated variable is created for tests
                Integer scoreForTests;
                if (Test.isRunningTest()) {
                    scoreForTests = theHighestScoreForTesting; // ContactScoreHandler, OpportunityScoreProcess tests
                }                                                                      
                Integer oppScore = Test.isRunningTest() ? scoreForTests 
                                                        : Integer.valueOf(ocr.Opportunity.get('IqScore'));
                Integer theHighestScore = ret.containsKey(ocr.ContactId) ? ret.get(ocr.ContactId) : 0;
                if (oppScore > theHighestScore) {
                    ret.put(ocr.ContactId, oppScore);
                } 
            }
        } catch (Exception e) { // IqScore field is only available on prod due to the free Einstein license
            system.debug(e.getMessage() + ' ' + e.getStackTraceString());
        } 
        return ret;
    }
     /*******************************************************************************
    *  Name            : setTheHighestOppScores
    *  Summary         : set the highest score on contacts
    *  CreatedDate     : 02.04.2021
    *  Parameters      : Map <Id, Integer> contactsWithTheHighestOppScore - map of contact id : contact id > the highest score on existing open oppties
                         Map <Id, Integer> currentContactScoresMap - map of contact id > current contact score value
    *  Returns         : Map <Id, Contact> - map of contact id : contact record with new score value set (not updated in the database yet)
    ******************************************************************************/
    private static Map <Id, Contact> setTheHighestOppScores (Map <Id, Integer> contactsWithTheHighestOppScore, Map <Id, Integer> currentContactScoresMap) {
        Map <Id, Contact> ret = new Map <Id, Contact> ();
        if (contactsWithTheHighestOppScore == null || contactsWithTheHighestOppScore.isEmpty()) return ret;
        try {
            for (Id conId : contactsWithTheHighestOppScore.keySet()) {
                Integer theHighestOppScore = contactsWithTheHighestOppScore.containsKey(conId) ? contactsWithTheHighestOppScore.get(conId) : null;
                if (theHighestOppScore == null) continue;
                // check if the new score is different from the current score
                Integer currentContactScore = (Integer) currentContactScoresMap.get(conId);
                if (currentContactScore != theHighestOppScore) {
                    Contact conToUpdate = new Contact(
                        Id = conId,
                        Opportunity_Scoring__c = theHighestOppScore
                    );
                    ret.put(conId, conToUpdate);
                }
            }
         } catch(Exception e){
            ExceptionLogger.sendException(
                'ContactScoreHandler setTheHighestOppScores:: errMsg: ' + e.getMessage() + '; contactsWithTheHighestOppScore: ' + contactsWithTheHighestOppScore,
                e.getStackTraceString()
            );
        }
        return ret;
    }
}