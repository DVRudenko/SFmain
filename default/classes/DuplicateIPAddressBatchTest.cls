@IsTest
private class DuplicateIPAddressBatchTest {
    
    
    /*******************************************************************************
    *  Summary         : Test Duplicate case
    *  CreatedDate     : 16/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDuplicateIPAddress() {
        Account account = new Account(
            Name = 'Test',
            BillingCountry = 'Germany'
        );
        
        insert account;
        
        RecordType recordType = [
                SELECT Id 
                FROM RecordType
                WHERE Name = 'Euroshell'
        ];
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Visitor_ID__c = '123412341234',
            RecordTypeId = recordType.Id
        );
        
        insert opportunity;
        
        Test.setCreatedDate(opportunity.Id, Date.today().addDays(-7));
        
        Opportunity duplicateOpportunity = new Opportunity(
            Name = 'Test',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Visitor_ID__c = '123412341234',
            RecordTypeId = recordType.Id
        );
        
        insert duplicateOpportunity;
        
        Test.setCreatedDate(duplicateOpportunity.Id, Date.today().addDays(-1));
        
        Test.startTest();
            DuplicateIPAddressBatch batch = new DuplicateIPAddressBatch();    
            Database.executeBatch(batch, 10);
        Test.stopTest();
        
        Opportunity testOpportunity = [
                SELECT Duplicate_Visitor_ID__c 
                FROM Opportunity
                WHERE Id = :duplicateOpportunity.Id
        ];
        
        System.assertEquals(true, testOpportunity.Duplicate_Visitor_ID__c);
    }
}