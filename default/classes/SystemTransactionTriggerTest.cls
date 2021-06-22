@isTest
private class SystemTransactionTriggerTest {


	/*******************************************************************************
	*  Name            : testUpdateOpportunity()
	*  Summary         : test update field Updated_from_site__c in Opportunity
	*  CreatedDate     : 27/12/2016
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testUpdateOpportunity() {
    	Account account = new Account(Name = 'test', BillingCountry = 'Germany');
    	insert account;
    	Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = 'test', StageName = 'Prospecting', Home_Station__c = 'test', CloseDate = date.today());
    	insert opportunity;
        System_Transaction__c systemTransaction = new System_Transaction__c(New_value__c = true, Record_Id__c = opportunity.Id);
        insert systemTransaction;

        Opportunity testOpportunity = [
        		SELECT Bevollmaechtigung__c, AGB_Datenschutzhinweise_Richtigkeit__c
        		FROM Opportunity
        		WHERE Name = 'test'];
        System.assertEquals(testOpportunity.Bevollmaechtigung__c, true);
        System.assertEquals(testOpportunity.AGB_Datenschutzhinweise_Richtigkeit__c, true);
    }
}