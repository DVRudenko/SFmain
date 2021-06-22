@isTest
private class WeeklyPumpedVolumeControllerTest {
	@isTest
    static void testWeeklyPumpedVolume() {
        Account account = new Account(Name = 'test', BillingCountry = 'Germany');
        insert account;
        Starts__c starts = new Starts__c(Account__c = account.Id, client_week_number__c = 1, volume__c = 500);
        insert starts;
        Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = 'test', StageName = 'Prospecting', CloseDate = date.today(), 
        		Total_consumption_l_month__c = 2000);
        insert opportunity;

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', account.Id);
        WeeklyPumpedVolumeController controller = new WeeklyPumpedVolumeController(new ApexPages.StandardController(account));

	    Test.stopTest();

	    System.assertEquals(controller.weeklyPumpedVolume.values().get(0), starts.volume__c);
	    System.assertEquals(controller.delta.values().get(0), opportunity.Total_consumption_l_month__c / 4);

    }
}