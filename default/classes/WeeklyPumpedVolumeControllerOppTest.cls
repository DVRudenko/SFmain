@isTest
private class WeeklyPumpedVolumeControllerOppTest {
    @isTest
    static void testWeeklyPumpedVolumeOpp() {
        Account account = new Account(Name = 'TEST', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = 'test', StageName = 'Prospecting', CloseDate = date.today(),
                Total_consumption_l_month__c = 2000);
        insert opportunity;
        Starts__c starts = new Starts__c(Account__c = account.Id, Opportunity__c = opportunity.Id, client_week_number__c = 1, volume__c = 500);
        insert starts;

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        WeeklyPumpedVolumeControllerOpp controller = new WeeklyPumpedVolumeControllerOpp(new ApexPages.StandardController(opportunity));

        Test.stopTest();

        System.assertEquals(controller.weeklyPumpedVolume.values().get(0), starts.volume__c);
    }
}