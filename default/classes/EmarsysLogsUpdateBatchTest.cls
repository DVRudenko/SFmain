@isTest
private class EmarsysLogsUpdateBatchTest {


	/*******************************************************************************
	*  Name            : updateEmarsysLogsTest()
	*  Summary         : test update Emarsys Body field from Emarsys response
	*  CreatedDate     : 30/06/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void updateEmarsysLogsTest() {
 		Lead lead = new Lead(
        	LastName = 'test', 
        	Company = 'test',
        	Country = 'Germany',
        	Email = 'test@test.com');
       	insert lead;

       	Emarsys_Log__c log = new Emarsys_Log__c(
       		Email_Id__c = '297202',
       		Lead__c = lead.Id);
       	insert log;

       	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EmarsysEmailMock());
            EmarsysLogsUpdateBatch logsUpdateBatch = new EmarsysLogsUpdateBatch();
            Database.executeBatch(logsUpdateBatch);
        Test.stopTest();   

        Emarsys_Log__c testLeadLog = [
        		SELECT Is_Email_Body_Updated__c, Email_Body__c
        		FROM Emarsys_Log__c
        		LIMIT 1];
        System.assertEquals(testLeadLog.Is_Email_Body_Updated__c, true);
        System.assertEquals(testLeadLog.Email_Body__c, 'testBody');
    }
}