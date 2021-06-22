@isTest
private class FlowBusinessDaysFromTodayTest {
    static testMethod void testFlow() {
    	Date testDate = Date.newInstance(2016, 8, 19);
        Opportunity opp = new Opportunity(
        	Name = 'Test',
        	CloseDate = Date.today(),
            Home_Station__c = 'test',
        	StageName = 'Closed Won',
        	Angebotsdauer__c = 'test');
        insert opp;

        FlowBusinessDaysFromToday.FlowBusinessDaysFromTodayRequest request = new FlowBusinessDaysFromToday.FlowBusinessDaysFromTodayRequest();
        request.opportunityId = opp.Id;
        request.numberOfDays = 5;
        List<FlowBusinessDaysFromToday.FlowBusinessDaysFromTodayRequest> testList = new List<FlowBusinessDaysFromToday.FlowBusinessDaysFromTodayRequest>();
        testList.add(request);
        FlowBusinessDaysFromToday.convertLeads(testList);
    }
}