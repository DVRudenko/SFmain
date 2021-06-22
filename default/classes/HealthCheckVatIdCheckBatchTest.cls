@isTest
private class HealthCheckVatIdCheckBatchTest {
    static testMethod void testMethod1() {
        Health_Check_Vat__c hc = new Health_Check_Vat__c(
        	Name = 'DE',
        	Vat_Id__c = '1231233',
        	Country__c = 'Germany');
        insert hc;

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new VatIdValidateMock());
    		Database.executeBatch(new HealthCheckVatIdCheckBatch(), 1);
    	Test.stopTest();        
    }
}