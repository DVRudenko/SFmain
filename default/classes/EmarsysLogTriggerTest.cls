@isTest
public class EmarsysLogTriggerTest {

    @isTest
    private static void testUpdateLeadStaus() {
        Lead lead = new Lead(
                LastName = 'test name',
                Company = 'test company',
                Sec_Channel__c = 'Inbound',
                Number_of_Cards_facebook__c = '1',
                Country='Germany',
                CountryCode='DE',
                Channel__c = 'Internet',
                Email='test@test.com',
                Phone ='111111111111');
        insert lead;
        Test.startTest();
        Emarsys_Log__c log = new Emarsys_Log__c(
            Lead__c = lead.Id
        );
        insert log;
        Test.stopTest();
        Lead updatedLead = [SELECT E2E_Adoption_Status__c FROM Lead WHERE Id =: lead.Id];
        System.assertEquals('Adoption Email Sent', updatedLead.E2E_Adoption_Status__c);
    }
}