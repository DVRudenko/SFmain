@isTest
private class FlowBusinessDaysFromStartsStatusDateTest {
    static testMethod void testFlow() {
        Date testDate = Date.newInstance(2016, 8, 19);
        Opportunity opp = new Opportunity(
            Name = 'Test',
            CloseDate = Date.today(),
            Home_Station__c = 'test',
            StageName = 'Closed Won',
            Angebotsdauer__c = 'test');
        insert opp;

        FlowBusinessDaysFromStartsStatusDate.FlowBusinessDaysFromStartsStatusDateRequest request = new FlowBusinessDaysFromStartsStatusDate.FlowBusinessDaysFromStartsStatusDateRequest();
        request.opportunityId = opp.Id;
        request.numberOfDays = 3;
        List<FlowBusinessDaysFromStartsStatusDate.FlowBusinessDaysFromStartsStatusDateRequest> testList = new List<FlowBusinessDaysFromStartsStatusDate.FlowBusinessDaysFromStartsStatusDateRequest>();
        testList.add(request);
        FlowBusinessDaysFromStartsStatusDate.convertLeads(testList);

        Opportunity testUpdatedOpp = [
            SELECT Starts_Schedule__c
            FROM Opportunity
            WHERE Id = :opp.Id];
        Date testDate2 = Date.newInstance(2016, 8, 22); 
    }
}