@isTest
private class UpdateLeadsTempBatchTest {
    static testMethod void testMethod1() {
        Lead lead = new Lead(
        	LastName = 'test',
        	Company = 'Test',
        	Country = 'Germany',
        	E2E_Adoption_Status__c = null);
        insert lead;
        Test.setCreatedDate(lead.Id, Datetime.newInstance(Date.newInstance(2018, 12, 5), Time.newInstance(0, 0, 0, 0)));

        Test.startTest();
        	Database.executeBatch(new UpdateLeadsTempBatch(), 1);
        Test.stopTest();
    }


    static testMethod void testMethod2() {
        Lead lead2 = new Lead(
        	LastName = 'test',
        	Company = 'Test',
        	Country = 'Germany',
        	Quali_Status__c = 'Switched to E2E',
        	E2E_Adoption_Status__c = null);        
        insert lead2;
        Test.setCreatedDate(lead2.Id, Datetime.newInstance(Date.newInstance(2018, 12, 5), Time.newInstance(0, 0, 0, 0)));

        Test.startTest();
        	Database.executeBatch(new UpdateLeadsTempBatch(), 1);
        Test.stopTest();
    }
}