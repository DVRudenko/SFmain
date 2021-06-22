/**
 * Created by eugene on 10/2/19.
 */

@IsTest
private class CarnetE2EServiceTest {
    @IsTest
    static void testOpportunityCreation() {
        Account newAccount = new Account(
                Name = 'test account',
                BillingCountry = 'Poland'
        );
        insert newAccount;

        Contact newContact = new Contact(
                FirstName = 'test',
                LastName = 'test2',
                Phone = '+1112223333',
                AccountId = newAccount.Id
        );
        insert newContact;

        Opportunity newOpportunity = new Opportunity(
                Name = 'test opp',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Number_of_cars__c = 1,
                Anzahl_der_Karten__c = 3,
                AccountId = newAccount.Id
        );
        insert newOpportunity;

        OpportunityContactRole role = new OpportunityContactRole(
                ContactId = newContact.Id,
                OpportunityId = newOpportunity.Id,
                IsPrimary = true
        );
        insert role;

        Test.startTest();
        CarnetE2EService.createCarnetOpportunity(newOpportunity.Id);
        Test.stopTest();
        List<Opportunity> testOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'TEST ACCOUNT-CARNET'];
        System.assert( ! testOpportunity.isEmpty() );
    }
}