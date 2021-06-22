@isTest
private class OpportunityStageStatusBatchTest {
    public static Opportunity oppTest1;
    public static Opportunity oppTest2;

	@isTest
    public static void testBatch() {
        createOpportunities();
    	
        Test.startTest();
	        OpportunityStageStatusBatch batch = new OpportunityStageStatusBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

        List<Opportunity> opp = [
                SELECT Id, StageName, Gruende_verloren__c 
                FROM Opportunity];

        System.assertEquals('Closed Lost', opp.get(1).StageName);
        System.assertEquals('Refused Credit', opp.get(1).Gruende_verloren__c);
    }


    @isTest
    public static void createOpportunities() {
        String recId = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1].Id;

        Opportunity oppTest1 = new Opportunity(
            RecordTypeId = recId,
            Anzahl_der_Karten__c = 5,
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Product__c = 'None',
            StageName = 'CreditCheck abgelehnt',
            Name = 'test1',
            Angebotsdauer__c = '3 Monate',
            CloseDate = Date.today()
        );
        insert oppTest1;

        Opportunity oppTest2 = new Opportunity(
            RecordTypeId = recId,
            Anzahl_der_Karten__c = 5,
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Product__c = 'None',
            StageName = 'CreditCheck abgelehnt',
            Name = 'test2',
            Angebotsdauer__c = '3 Monate',
            CloseDate = Date.today()
        );
        insert oppTest2;
    }
}