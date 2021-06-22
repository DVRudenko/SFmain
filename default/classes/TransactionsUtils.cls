public class TransactionsUtils {

    
    /*******************************************************************************
    *  Name            : createKontomatikAccount()
    *  Summary         : Create test Account for Kontomatik
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createKontomatikAccount() {
    	Account account = new Account(
    		Name = 'test',
            BillingCountry = 'Poland');
    	return account;
    }


    /*******************************************************************************
    *  Name            : createKontomatikOpportunity(String accountId)
    *  Summary         : Create test Opportunity for Kontomatik    
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountId
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createKontomatikOpportunity(String accountId) {
    	Opportunity opportunity = new Opportunity(
		    Name = 'Kundentestsystem',
		    StageName = 'Prospecting',
		    CloseDate = Date.today(),
		    AccountId = accountId);
		return opportunity;
    }


    /*******************************************************************************
    *  Name            : createKontomatikTransactionsSystem()
    *  Summary         : Create Transactions System for Kontomatik    
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Transactions_System__c
    ******************************************************************************/
    public static Transactions_System__c createKontomatikTransactionsSystem() {
    	Transactions_System__c creditSystem = new Transactions_System__c(
            Name = 'Kontomatik',
            Endpoint__c = 'https://test.api.kontomatik.com', 
            Username__c = 'fleetcore-test', 
            Supported_Countries__c = 'Poland',
            API_Key__c = '5c07590c6f880624d8288bb2d917b476699943f46a43d8c1b670fb15912d046d');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createKontomatikContact(String accountId)
    *  Summary         : Create test Contact for Kontomatik    
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createKontomatikContact(String accountId) {
        Contact contact = new Contact(
            LastName = 'test',
            AccountId = accountId,
            Salutation = 'Herr',
            Email = 'test@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createKontomatikOpportunityContactRole(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role for Kontomatik   
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String contactId - id of contact, String opportunityId - id of opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createKontomatikOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            isPrimary = true);
        return opportunityContactRole;
    }
}