@isTest
private class WeeklyNetstartsControllerOppTest {
    @isTest
    static void testWeeklyNetstartsOpp() {
        Account account = new Account(Name = 'TEST', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = 'test', StageName = 'Prospecting', CloseDate = date.today(),
                Total_consumption_l_month__c = 2000);
        insert opportunity;
        Starts__c starts1 = new Starts__c(Account__c = account.Id, Opportunity__c = opportunity.Id, client_week_number__c = 1, starts__c = 24000);
        insert starts1;
        Starts__c starts2 = new Starts__c(Account__c = account.Id, Opportunity__c = opportunity.Id, client_week_number__c = 2, starts__c = 25000);
        insert starts2;

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        WeeklyNetstartsControllerOpp controller = new WeeklyNetstartsControllerOpp(new ApexPages.StandardController(opportunity));

        Test.stopTest();

        System.assertEquals(controller.weeklyNetstarts.values().get(1), starts2.starts__c);

    }
}