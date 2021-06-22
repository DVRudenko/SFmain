@isTest
private class EmarsysAllLogsBatchTest {


    /*******************************************************************************
    *  Name            : creatingLeadLogsTest()
    *  Summary         : test creating logs   
    *  CreatedDate     : 21/08/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void creatingLeadLogsTest() {
    	List<Lead> leadsListToInsert = new List<Lead>();
        Lead lead = new Lead(
            LastName = 'test', 
            Company = 'test', 
            Phone = '1234567890', 
            Emarsys_Contact_Id__c = '371354459', 
            PostalCode = '223141',
    		Country = 'Germany', 
            CountryCode = 'DE', 
            State = 'Bavaria');
        insert lead;
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ContactEmailHistoryHttpResponseGenerator());
        EmarsysAllLogsBatch leadLogsBatch = new EmarsysAllLogsBatch('funny_email', 'Test Campaign', 'Lead');
		Database.executeBatch(leadLogsBatch);

		Test.stopTest();

		List<Emarsys_Log__c> testLog = [
				SELECT Email_Name__c
				FROM Emarsys_Log__c 
				WHERE Lead__c = :lead.Id];
		System.assertEquals(testLog.size(), 1);
    }
}