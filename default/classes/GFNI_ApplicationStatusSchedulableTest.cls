/**
 * Created by Nikita.Milhailov on 26.02.2019.
 */

@IsTest
public with sharing class GFNI_ApplicationStatusSchedulableTest {

    @IsTest
    public static void testExecuteAT() {
        Id accAT = createAccount('AT');
        Id oppAT = createOpportunity(accAT, 'AT123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteBEFR() {
        Id accAT = createAccount('BEFR');
        Id oppAT = createOpportunity(accAT, 'BENL123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteBENL() {
        Id accAT = createAccount('BENL');
        Id oppAT = createOpportunity(accAT, 'BENL123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCHDE() {
        Id accAT = createAccount('CHDE');
        Id oppAT = createOpportunity(accAT, 'CHDE123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCHFR() {
        Id accAT = createAccount('CHFR');
        Id oppAT = createOpportunity(accAT, 'CHFR123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCHIT() {
        Id accAT = createAccount('CHIT');
        Id oppAT = createOpportunity(accAT, 'CHIT123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCZ() {
        Id accAT = createAccount('CZ');
        Id oppAT = createOpportunity(accAT, 'CZ123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteDE() {
        Id accAT = createAccount('DE');
        Id oppAT = createOpportunity(accAT, 'DE123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteFR() {
        Id accAT = createAccount('FR');
        Id oppAT = createOpportunity(accAT, 'FR123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteHU() {
        Id accAT = createAccount('HU');
        Id oppAT = createOpportunity(accAT, 'HU123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteLU() {
        Id accAT = createAccount('LU');
        Id oppAT = createOpportunity(accAT, 'LU123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteNL() {
        Id accAT = createAccount('NL');
        Id oppAT = createOpportunity(accAT, 'NL123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecutePL() {
        Id accAT = createAccount('PL');
        Id oppAT = createOpportunity(accAT, 'PL123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteSK() {
        Id accAT = createAccount('SK');
        Id oppAT = createOpportunity(accAT, 'SK123');
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    private static Id createAccount(String countryCode) {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountryCode = countryCode;

        insert acc;

        return acc.Id;
    }

    private static Id createOpportunity(Id accId, String gfnNumber) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.Name = 'TestName';
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.GFNI_ApplicationId__c = 'fdc9254d-17ba-4d7d-9858-e6376893e2a9';
        opp.GFN_number_for_starts__c = gfnNumber;
        opp.Custom_PIN__c = false;

        insert opp;

        return opp.Id;
    }

    private static Id createCard(Id oppId) {
        Tankkarten__c card = new Tankkarten__c();
        card.Opportunity__c = oppId;
        card.GFNI_Status__c = 'Pending';
        card.Driver_Name__c = 'Test name';

        insert card;

        return card.Id;
    }
}