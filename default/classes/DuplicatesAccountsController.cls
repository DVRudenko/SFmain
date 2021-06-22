public with sharing class DuplicatesAccountsController {
	private ApexPages.StandardController controller {get; set;}
	public Account currentAccount {get; set;}
    public List<Account> finalDupesAccountsList {get; set;}


    public DuplicatesAccountsController (ApexPages.StandardController controller) {
        this.currentAccount = new Account();
        this.finalDupesAccountsList = new List<Account>();
    }


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : check for duplicates in the Account field values: Name, Steuernummer__c and Umsatzsteuer_ID__c
    *  CreatedDate     : 26/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
    	String accountId = ApexPages.currentPage().getParameters().get('id');

    	List<Account> currentAccountsList = [
            SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1];

        if (! currentAccountsList.isEmpty()) {
            this.currentAccount = currentAccountsList.get(0);
            List<Account> duplicateAccountsList = [
                SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c
                FROM Account
                WHERE ((Steuernummer__c != null AND Steuernummer__c = :this.currentAccount.Steuernummer__c) OR 
                    (Umsatzsteuer_ID__c != null AND Umsatzsteuer_ID__c = :this.currentAccount.Umsatzsteuer_ID__c) OR 
                    Name = :this.currentAccount.Name) AND
                    RecordType.Name != 'Flexcard' AND 
                    Id != :this.currentAccount.Id
                ORDER BY CreatedDate DESC
                LIMIT 1001];

            Integer counter = 0;
            for (Account acc : duplicateAccountsList) { 
                if (counter == 1000) break;   
                this.finalDupesAccountsList.add(acc); 
                counter++;
            }
            if (duplicateAccountsList.size() >= 1000) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
            }
        }
    }
}