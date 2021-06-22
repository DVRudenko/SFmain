@isTest
public class TransactionsCredentialsRequestCtrlTest {


	/*******************************************************************************
    *  Name            : testInvalidRecordId()
    *  Summary         : Test case with invalid Opportunity Id.    
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidRecordId() {
    	Test.startTest();
	    	TransactionsCredentialsRequestCtrl controller = new TransactionsCredentialsRequestCtrl();
	    	controller.init();
	    Test.stopTest();
    }


   	/*******************************************************************************
    *  Name            : testInvalidRequest()
    *  Summary         : Test case with invalid data for request.  
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testInvalidRequest() {
    	Account account = TransactionsUtils.createKontomatikAccount();
    	insert account;

    	Opportunity opportunity = TransactionsUtils.createKontomatikOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

    	Test.startTest();
	    	TransactionsCredentialsRequestCtrl controller = new TransactionsCredentialsRequestCtrl();
	    	controller.init();
	    Test.stopTest();
    }


    /*******************************************************************************
    *  Name            : testTransactionsCredentialsRequestSend()
    *  Summary         : Test sending request for client for his bank data.
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testTransactionsCredentialsRequestSend() {
    	Account account = TransactionsUtils.createKontomatikAccount();
    	insert account;

    	Opportunity opportunity = TransactionsUtils.createKontomatikOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

    	Contact contact = TransactionsUtils.createKontomatikContact(account.Id);
    	insert contact;

    	OpportunityContactRole opportunityContactRole = TransactionsUtils.createKontomatikOpportunityContactRole(contact.Id, opportunity.Id);
    	insert opportunityContactRole;

    	Test.startTest();
	    	TransactionsCredentialsRequestCtrl controller = new TransactionsCredentialsRequestCtrl();
	    	controller.init();
	    Test.stopTest();
    }
}