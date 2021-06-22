@isTest
private class HealthCheckSchedulerTest {
	@testSetup
	static void createTestData() {
    	E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
        	Name = 'E2EForm',
        	AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
        	paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
        	PSPID__c = 'fleetcorTEST',
        	SHA_KeyIn__c = 'FleetcorTest!12@',
        	SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;
	}

    static testMethod void testIngenico() {
        Test.startTest();
	        HealthCheckScheduler schedule = new HealthCheckScheduler();
			String sch = '0 59 7-23 ? * MON-FRI'; 
			Test.setMock(HttpCalloutMock.class, new IngenicoMock());			
			System.schedule('Test Job123', sch, schedule); 
		Test.stopTest();         
    }

    static testMethod void testDocusign() {
        Test.startTest();
	        HealthCheckScheduler schedule = new HealthCheckScheduler();
			String sch = '0 59 7-23 ? * MON-FRI'; 
			Test.setMock(HttpCalloutMock.class, new DocusignPLMock());			
			System.schedule('Test Job1234', sch, schedule); 
		Test.stopTest();         
    }    
}