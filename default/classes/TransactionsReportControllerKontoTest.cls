@isTest
private class TransactionsReportControllerKontoTest {
	public static TransactionsReportController controller;


    /*******************************************************************************
    *  Name            : testInvalidInitializeData()
    *  Summary         : Test ivalid case of initilize data  
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidInitializeData() {
    	Account account = TransactionsUtils.createKontomatikAccount();
    	account.BillingCountry = 'Germany';
    	insert account;

    	Opportunity opportunity = TransactionsUtils.createKontomatikOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

    	Transactions_System__c transactionsSystem = TransactionsUtils.createKontomatikTransactionsSystem();
    	insert transactionsSystem; 

    	Test.startTest();
    		controller = new TransactionsReportController();
    		controller.init();
    	Test.stopTest();

    	System.assertEquals('Wystąpił błąd. Prosim o kontakt z obsługą klienta.', controller.errorMessage);
    }


    /*******************************************************************************
    *  Name            : testInvalidInitiateDataImport()
    *  Summary         : Test invalid case of initiate data import
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidInitiateDataImport() {
    	Account account = TransactionsUtils.createKontomatikAccount();
    	insert account;

    	Opportunity opportunity = TransactionsUtils.createKontomatikOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

    	Transactions_System__c transactionsSystem = TransactionsUtils.createKontomatikTransactionsSystem();
    	transactionsSystem.Name = 'test';
    	insert transactionsSystem; 

    	Test.startTest();
    		controller = new TransactionsReportController();
    		controller.init();
    		controller.initiateDefaultImport();
    	Test.stopTest();

    	System.assertEquals('Wystąpił błąd. Prosim o kontakt z obsługą klienta.', controller.errorMessage);
    }


    /*******************************************************************************
    *  Name            : testInvalidImportData()
    *  Summary         : Test invalid case of data import    
    *  CreatedDate     : 17/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidImportData() {
    	Account account = TransactionsUtils.createKontomatikAccount();
    	insert account;

    	Opportunity opportunity = TransactionsUtils.createKontomatikOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

    	Transactions_System__c transactionsSystem = TransactionsUtils.createKontomatikTransactionsSystem();
    	insert transactionsSystem; 

    	Test.startTest();
    		controller = new TransactionsReportController();
    		Test.setMock(HttpCalloutMock.class, new KontomatikImportAllDataMock());
    		controller.initiateDefaultImport();
    		controller.importData();
    	Test.stopTest();

    	System.assertEquals('Wystąpił błąd. Prosim o kontakt z obsługą klienta.', controller.errorMessage);
    }


    /*******************************************************************************
    *  Name            : testValidImportData()
    *  Summary         : Test valid case of import data
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidImportData() {
    	Account account = TransactionsUtils.createKontomatikAccount();
    	insert account;

    	Opportunity opportunity = TransactionsUtils.createKontomatikOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

    	Transactions_System__c transactionsSystem = TransactionsUtils.createKontomatikTransactionsSystem();
    	insert transactionsSystem; 

    	Test.startTest();
    		controller = new TransactionsReportController();
    		Test.setMock(HttpCalloutMock.class, new KontomatikImportAllDataMock());
    		controller.init();
    		controller.initiateDefaultImport();
    		controller.importData();
    	Test.stopTest();

    	List<Transactions_Report__c> transactionsReport = [
    	        SELECT Id, (SELECT Id FROM Bank_Accounts__r), (SELECT Id FROM Bank_Account_Owners__r)
    	        FROM Transactions_Report__c];

    	System.assertEquals(1, transactionsReport.size());
    	System.assertEquals(true, transactionsReport.get(0).Bank_Accounts__r.size() > 0);
    	System.assertEquals(true, transactionsReport.get(0).Bank_Account_Owners__r.size() > 0);
    }
}