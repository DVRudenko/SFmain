@isTest
private class ClosedLostE2EOpportunityCtrlTest {
    static testMethod void testClosedOpportunity() {
        Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            E2E__c = true,
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Gruende_verloren__c = 'Other',
            E2E_Customer_Feedback__c = 'test feedback',
            CCS_Reason_Lost_Other__c = 'test reason');
        insert opp;

        ClosedLostE2EOpportunityCtrl controller = new ClosedLostE2EOpportunityCtrl();
        ApexPages.CurrentPage().getparameters().put('id', opp.Id);
        controller.init();

        Opportunity testOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.StageName == 'Closed Lost');
    }

    // 1. is not E2E
    static testMethod void invalidTestClosedOpportunity() {
        Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            CloseDate = Date.today(),
            StageName = 'Prospecting');
        insert opp;

        ClosedLostE2EOpportunityCtrl controller = new ClosedLostE2EOpportunityCtrl();
        ApexPages.CurrentPage().getparameters().put('id', opp.Id);
        controller.init();
        controller.doCancel();

        Opportunity testOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.StageName != 'Closed Lost');
    }   

    // 2. Gruende_verloren__c = null && CCS_Reason_Lost_Other__c = null
    static testMethod void invalidTest2ClosedOpportunity() {
        Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            E2E__c = true,
            CloseDate = Date.today(),
            StageName = 'Prospecting');
        insert opp;

        ClosedLostE2EOpportunityCtrl controller = new ClosedLostE2EOpportunityCtrl();
        ApexPages.CurrentPage().getparameters().put('id', opp.Id);
        controller.init();

        Opportunity testOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.StageName != 'Closed Lost');
    }


    // 3. CCS_Reason_Lost_Other__c = null
    static testMethod void invalidTest3ClosedOpportunity() {
        Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            E2E__c = true,
            CloseDate = Date.today(),
            Gruende_verloren__c = 'Sonstige',
            StageName = 'Prospecting');
        insert opp;

        ClosedLostE2EOpportunityCtrl controller = new ClosedLostE2EOpportunityCtrl();
        ApexPages.CurrentPage().getparameters().put('id', opp.Id);
        controller.init();

        Opportunity testOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.StageName != 'Closed Lost');
    } 


    // 4. Invalid Id
    static testMethod void invalidTest4ClosedOpportunity() {
        Account acc = new Account(Name = 'test', BillingCountry = 'Germany');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            E2E__c = true,
            CloseDate = Date.today(),
            StageName = 'Prospecting');
        insert opp;

        ClosedLostE2EOpportunityCtrl controller = new ClosedLostE2EOpportunityCtrl();
        controller.init();

        Opportunity testOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assert(testOpp.StageName != 'Closed Lost');
    }     
}