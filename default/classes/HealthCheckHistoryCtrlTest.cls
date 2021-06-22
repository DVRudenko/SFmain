@isTest
private class HealthCheckHistoryCtrlTest {
	private static Opportunity newOpp;

    @isTest
    public static void testHealthCheckHistory() {
        createOppty();
        createHealthChecks();
        ApexPages.currentPage().getParameters().put('oppid', newOpp.Id);
        HealthCheckHistoryCtrl healthCheckCtrl = new HealthCheckHistoryCtrl();
        healthCheckCtrl.init();
    }

	private static void createOppty() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
	    newOpp = new Opportunity(
	        RecordTypeId = rt.Id,
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        Zahlungsziel__c = '7',
	        Product__c = 'None',
	        StageName = 'Prospecting',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today());
	    insert newOpp;
	}

	private static void createHealthChecks() {
		Health_Check__c healthCheck = new Health_Check__c(
			Name = 'E2E Load Time Tracking',
			Country__c = 'Germany',
			Description__c = 'test description',
			Device__c = 'Mobile',
			From_Step__c = 'step 1',
			Opportunity__c = newOpp.Id,
			Start_Action__c = Datetime.now(),
			Time_execution__c = 1000,
			To_Step__c = 'step 2'
		);
		insert healthCheck;
	}
}