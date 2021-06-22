@IsTest
public class BatchCloseOpportunitiesTest {

     /*******************************************************************************
     *  Summary         : test close inactive opportunities
     *  Created         : 02/11/2020
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    static void testCloseOpportunities() {
        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Poland'
        );
        insert account;

        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'Test',
                RecordTypeId = recordType.Id,
                StageName = 'Prospecting',
                Language_preference__c = 'Polish',
                Total_consumption_l_month__c = 100,
                Zahlungsart__c = 'Lastschrift',
                CloseDate = Date.today().addDays(14)
        );
        insert opportunity;
        Test.setCreatedDate(opportunity.Id, Date.today().addMonths(-5));


        OpportunityFieldHistory fieldHistory = new OpportunityFieldHistory(
                OpportunityId = opportunity.Id,
                Field = 'StageName'
        );
        insert fieldHistory;

        Test.startTest();
            BatchCloseOpportunities batchCloseOpportunities = new BatchCloseOpportunities();
            Database.executeBatch(batchCloseOpportunities);
        Test.stopTest();

        Opportunity opp = [SELECT StageName, Gruende_verloren__c from Opportunity where Id = :opportunity.Id];
        System.assertEquals('Closed Lost', opp.StageName);
        System.assertEquals('No activity', opp.Gruende_verloren__c);
    }
}