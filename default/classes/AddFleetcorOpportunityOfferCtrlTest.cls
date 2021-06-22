/**
 * Created by eugene on 9/30/19.
 */

@IsTest
private class AddFleetcorOpportunityOfferCtrlTest {
    @IsTest
    static void testOpportunityId() {
        Account account = new Account(Name = 'test account', BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                AccountId = account.Id
        );
        insert opportunity;

        Test.startTest();
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        ApexPages.currentPage().getParameters().put('opportunityId', testOpportunity.Id);
        AddFleetcorOpportunityOfferCtrl ctrl = new AddFleetcorOpportunityOfferCtrl();
        Test.stopTest();
    }
}