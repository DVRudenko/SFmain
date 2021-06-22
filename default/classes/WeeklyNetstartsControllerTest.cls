@isTest
private class WeeklyNetstartsControllerTest {
	@isTest
    static void testWeeklyNetstarts() {
        Account account = new Account(Name = 'test', BillingCountry = 'Germany');
        insert account;
        Starts__c starts1 = new Starts__c(Account__c = account.Id, client_week_number__c = 1, starts__c = 24000);
        insert starts1;
        Starts__c starts2 = new Starts__c(Account__c = account.Id, client_week_number__c = 2, starts__c = 25000);
        insert starts2;
        Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = 'test', StageName = 'Prospecting', CloseDate = date.today(), 
        		Total_consumption_l_month__c = 2000);
        insert opportunity;

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', account.Id);
        WeeklyNetstartsController controller = new WeeklyNetstartsController(new ApexPages.StandardController(account));

	    Test.stopTest();

	    System.assertEquals(controller.weeklyNetstarts.values().get(1), starts2.starts__c - starts1.starts__c);

    }
}