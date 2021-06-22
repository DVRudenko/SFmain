@isTest
private class FlowBusinessDaysFromCloseDateTest {
    static testMethod void testFlow() {
        Date testDate = Date.newInstance(2016, 8, 19);
        Opportunity opp = new Opportunity(
            Name = 'Test',
            CloseDate = Date.today(),
            Home_Station__c = 'test',
            StageName = 'Closed Won',
            Angebotsdauer__c = 'test');
        insert opp;

        FlowBusinessDaysFromCloseDate.FlowBusinessDaysFromCloseDateRequest request = new FlowBusinessDaysFromCloseDate.FlowBusinessDaysFromCloseDateRequest();
        request.opportunityId = opp.Id;
        request.numberOfDays = 3;
        List<FlowBusinessDaysFromCloseDate.FlowBusinessDaysFromCloseDateRequest> testList = new List<FlowBusinessDaysFromCloseDate.FlowBusinessDaysFromCloseDateRequest>();
        testList.add(request);
        FlowBusinessDaysFromCloseDate.convertLeads(testList);

        Opportunity testUpdatedOpp = [
            SELECT Starts_Schedule__c
            FROM Opportunity
            WHERE Id = :opp.Id];
        Date testDate2 = Date.newInstance(2016, 8, 22); 
        //system.assertEquals(testDate2, testUpdatedOpp.Starts_Schedule__c);
    }
}