@isTest
private class CallChoiseControllerTest {


	/*******************************************************************************
	*  Name            : testInitializeData()
	*  Summary         : Test select current Opportunity tasks    
	*  CreatedDate     : 07/06/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testInitializeData() {
        Account account = new Account(
    		Name = 'test',
            BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
		    Name = 'test',
		    StageName = 'Prospecting',
		    CloseDate = Date.today(),
		    AccountId = account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

        Task task = new Task(
        	WhatId = opportunity.Id,
            CallObject = '01618e17-ef3d-2b60-8a82-afc62f1d1687');
        insert task;

        Test.startTest();
        	CallChoiseController controller = new CallChoiseController();
        	controller.init();
        Test.stopTest();

        System.assertEquals(1, controller.tasksList.size());
    }
}