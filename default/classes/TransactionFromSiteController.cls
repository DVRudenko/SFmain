public class TransactionFromSiteController {

	
	/*******************************************************************************
	*  Name            : init()
	*  Summary         : Create System_Transaction__c record and fill Record_Id__c 
						field with Id of Opportunity from email
	*  CreatedDate     : 27/12/2016
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	public void init() {
    	String opportunityId = ApexPages.currentPage().getParameters().get('id');
    	System_Transaction__c st = new System_Transaction__c(Record_Id__c = opportunityId, New_value__c = true);
    	insert st;
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Thanks, information has been sent'));
    }
}