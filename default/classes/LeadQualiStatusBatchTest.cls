@isTest
private class LeadQualiStatusBatchTest {

    /*******************************************************************************
    *  Name            : testBatchAfter25Days()
    *  Summary         : Testing batch after 25 days createddate
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
	@isTest
    static void testBatchAfter25Days() {
        Lead test1 = new Lead(
            LastName = 'test1', Company = 'test', Country = 'Poland', Status = 'Quick Process', CCS_number_of_cards__c = 1,
            Quali_Status__c = 'Offer sent', Sec_Channel__c = 'JITB', CreatedDate = Datetime.now().addDays(-30));
        insert test1;

        Test.startTest();
	        LeadQualiStatusBatch batch = new LeadQualiStatusBatch();
	    	Database.executeBatch(batch, 1);
    	Test.stopTest();

        List<Lead> leadsList = [
                SELECT LastName, Status, Quali_Status__c
                FROM Lead
                WHERE LastName = 'test1'];

		System.assertEquals('Disqualified', leadsList.get(0).Status);
		System.assertEquals('No reply – Quick Process', leadsList.get(0).Quali_Status__c);
    }


    /*******************************************************************************
    *  Name            : testBatchBefore25Days()
    *  Summary         : Testing batch before 25 days createddate
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
	@isTest
    static void testBatchBefore25Days() {
        Lead test2 = new Lead(
            LastName = 'test2', Company = 'test', Country = 'Poland', Status = 'Quick Process', CCS_number_of_cards__c = 1,
            Quali_Status__c = 'Offer sent', Sec_Channel__c = 'JITB', CreatedDate = Datetime.now().addDays(-10));
        insert test2;

        Test.startTest();
	        LeadQualiStatusBatch batch = new LeadQualiStatusBatch();
	    	Database.executeBatch(batch, 1);
    	Test.stopTest();

		List<Lead> leadsList = [
                SELECT LastName, Status, Quali_Status__c
                FROM Lead
                WHERE LastName = 'test2'];

		System.assertEquals('Quick Process', leadsList.get(0).Status);
		System.assertEquals('Offer sent', leadsList.get(0).Quali_Status__c);
    }
}