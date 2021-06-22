public class SystemTransactionTriggerHandler {


	/*******************************************************************************
	*  Name            : updateOpportunity(List<System_Transaction__c> newTransactions)
	*  Summary         : Update field Updated_from_site__c in Opportunity before insert 
						System_Transaction__c from FleetcorEmea site   
	*  CreatedDate     : 27/12/2016
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
    public static void updateOpportunity(List<System_Transaction__c> newTransactions) {
    	List<String> opportunityIdList = new List<String>();
    	for (System_Transaction__c systemTransaction : newTransactions) {
    		if (systemTransaction.New_value__c == true) {
    			opportunityIdList.add(systemTransaction.Record_Id__c);
    		}
    	}

    	List<Opportunity> opportunitiesToUpdate = [
    			SELECT Name 
    			FROM Opportunity 
    			WHERE Id IN :opportunityIdList AND StageName != 'Closed Won' AND StageName != 'Closed Lost'
    			LIMIT 1];
    	if ( ! opportunitiesToUpdate.isEmpty() ) {
    		opportunitiesToUpdate.get(0).Bevollmaechtigung__c = true;
    		opportunitiesToUpdate.get(0).AGB_Datenschutzhinweise_Richtigkeit__c = true;
    	}
    	update opportunitiesToUpdate;
    }
}