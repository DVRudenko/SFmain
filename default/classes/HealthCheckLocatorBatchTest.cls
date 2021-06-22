@isTest
private class HealthCheckLocatorBatchTest {
    static testMethod void testMethod1() {
        Health_Check_Locator__c hcl = new Health_Check_Locator__c(
        	Name = 'DE',
        	Url__c = 'https://eurolocator.fleetcor.de/?product=4&locationRequest=0&lang=de&mode=choose-station&address=%20Johann-Sebastian-Bach-Str.%2C+Weimar%2C+DE%20&zoom=12');
        insert hcl;

        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StationLocatorMock());			
			Database.executeBatch(new HealthCheckLocatorBatch(), 1);
		Test.stopTest();   
    }
}