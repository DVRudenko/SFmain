@isTest
private class TransactionFromSiteControllerTest {


	/*******************************************************************************
	*  Name            : testCreateSystemTransaction()
	*  Summary         : test creating System_Transaction__c  
	*  CreatedDate     : 27/12/2016
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	@isTest
    public static void testCreateSystemTransaction() {
		Account account = new Account(Name = 'test', BillingCountry = 'Germany');
    	insert account;
    	Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = 'test', StageName = 'Prospecting', Home_Station__c = 'test', CloseDate = date.today());
    	insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        TransactionFromSiteController controller = new TransactionFromSiteController();
        controller.init();

        List<System_Transaction__c> systemTransactionList = [
        		SELECT Name 
        		FROM System_Transaction__c];
        System.assertEquals(systemTransactionList.size(), 1);
    }
}