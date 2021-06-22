@isTest
public with sharing class UnlockRecordButtonControllerTest {

    @isTest
    private static void testIsButtonVisible() {
        Account account = new Account(
            Name = 'test name',
            BillingCountry = 'Germany'
        );
        insert account;
        Profile p = [SELECT Id FROM Profile WHERE Name='Credit'];

        User u = new User(
            Alias = 'cred',
            Email = 'credit@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName= 'credit_username_test@fleetcor.com.test'
        );
        
        Opportunity opp = new Opportunity(
            Name = 'TEST',
            StageName = 'Prospecting',
            Sec_Channel__c = 'JITB',
            Channel__c = 'Fax',
            CloseDate = Date.today(),
            Anzahl_der_Karten__c = 1,
            RecordTypeId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'),
            AccountId = account.Id,
            Language_preference__c = 'German',
            Total_consumption_l_month__c = 14,
            Derzeitige_Zahlungsmethode__c = 'Tankkarte',
            Tankkarte_Emittent__c = 'DKV',
            Zahlungsart__c = 'Banküberweisung'
        );
        insert opp;
        
        Approval.LockResult result = Approval.lock(opp.Id);

        System.runAs(u) {
            Boolean buttonVisibility = UnlockRecordButtonController.isButtonVisible(opp.Id);
            System.assert(buttonVisibility);
        }
    }

    @isTest
    private static void testUnlockRecord() {
        Account account = new Account(
            Name = 'test name',
            BillingCountry = 'Germany'
        );
        insert account;

        Opportunity opp = new Opportunity(
            Name = 'TEST',
            StageName = 'Prospecting',
            Sec_Channel__c = 'JITB',
            Channel__c = 'Fax',
            CloseDate = Date.today(),
            Anzahl_der_Karten__c = 1,
            RecordTypeId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'),
            AccountId = account.Id,
            Language_preference__c = 'German',
            Total_consumption_l_month__c = 14,
            Derzeitige_Zahlungsmethode__c = 'Tankkarte',
            Tankkarte_Emittent__c = 'DKV',
            Zahlungsart__c = 'Banküberweisung'
        );
        insert opp;
        
        Approval.LockResult result = Approval.lock(opp.Id);
        
        UnlockRecordButtonController.unlockRecord(opp.Id);

        System.assert(!Approval.isLocked(opp.Id));
    }
}
