@isTest
private class UpdateOpportunityOwnerCtrlTest {

	/*******************************************************************************
	*  Name            : updateOppOwnerTest()
	*  Summary         : Simulate data transfer and check updateOppOwner function    
	*  CreatedDate     : 04/06/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void updateOppOwnerTest() {
        List<Opportunity> testList = [SELECT Id FROM Opportunity LIMIT 1];

    	ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testList);
        stdSetController.setSelected(testList);
        
        UpdateOpportunityOwnerCtrl ctrl = new UpdateOpportunityOwnerCtrl(stdSetController);
        ctrl.init();
        ctrl.opportunity.OwnerId = '0052000000437Kv';
        ctrl.updateOppOwner();

        List<Opportunity> opportunityList = [SELECT Owner.Name, Account.Owner.Name FROM Opportunity LIMIT 1];
        System.assertEquals('Ines Sinko', opportunityList.get(0).Owner.Name);
        System.assertEquals('Ines Sinko', opportunityList.get(0).Account.Owner.Name);

        List<Contact> contactList = [SELECT Owner.Name FROM Contact];
        System.assertEquals('Ines Sinko', contactList.get(0).Owner.Name);
    }

    /*******************************************************************************
	*  Name            : createOpportunities()
	*  Summary         : Create list with two Opportunities
	*  CreatedDate     : 04.06.2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @testSetup 
    static void createRecords() {
        Account account = new Account(Name = 'test', BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
        	Name = 'Test Opportunity',
            AccountId = account.Id,
        	StageName = 'Prospecting',
        	Angebotsdauer__c = '3 Monate',
        	CloseDate = Date.today());
        insert opportunity;

        Contact contact = new Contact(
            Phone = '0049 111 22 33',
            AccountId = account.Id,
            MobilePhone = '0112/33(0)2',
            Fax = '282245167',
            MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
            LastName = 'test', 
            Salutation = 'Herr');
        insert contact;
    }
}