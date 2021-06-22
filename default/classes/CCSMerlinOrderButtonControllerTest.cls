@isTest
public with sharing class CCSMerlinOrderButtonControllerTest {

    @testSetup
    public static void createTestOpportunity() {
        Account acc = new Account(
            RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
            Name = 'Test GFN Account',
            GFN_Nr__c = 'DE12478550',
            BillingCountry = 'Germany',
            ColCo__c = 'DE',
            CCS_Company_ID__c = 'test'
        );
        insert acc;

        Opportunity testOppo = new Opportunity(
            Name = 'test',
            Number_of_CCS_Order__c = 0,
            CCS_GFN_number__c = '123456',
            Product_Solicited__c = '123412',
            Sec_Channel__c = 'Internet',
            StageName = 'Client Negotiations',
            CloseDate = Date.today() - 1,
            AccountId = acc.Id
        );
        insert testOppo;
    }

    @isTest
    public static void testGetOpportunityData(){
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
        Opportunity testOppo = CCSMerlinOrderButtonController.getOpportunityData(o.Id);
        System.assertEquals(0, testOppo.Number_of_CCS_Order__c);
        System.assertEquals('123456', testOppo.CCS_GFN_number__c);
        System.assertEquals('123412', testOppo.Product_Solicited__c);
        System.assertEquals('Internet', testOppo.Sec_Channel__c);
    }

    @isTest
    public static void testGetUserData(){
        User currentUser = CCSMerlinOrderButtonController.getUserData();
        System.assert(currentUser != null);
        System.assert(currentUser.Profile.Name != null);
    }
}
