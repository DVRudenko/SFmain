/**
 * Created by Nikita.Mikhailov on 28.02.2019.
 */
@IsTest
public with sharing class GFNI_OpportunityLogReportCtrlTest {
    @IsTest
    public static void testCtrlWithData() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAO = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));

        PageReference pageRef = Page.GFNI_LogReportExtended; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(oppId));
        Test.setCurrentPage(pageRef);

        GFNI_OpportunityLogReportCtrl logReportCtrl = new GFNI_OpportunityLogReportCtrl(logDAO);
        Test.stopTest();
    }

    @IsTest
    public static void testCtrlWithoutData() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];

        Test.StartTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);

        PageReference pageRef = Page.GFNI_LogReportExtended; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);

        GFNI_OpportunityLogReportCtrl logReportCtrl = new GFNI_OpportunityLogReportCtrl(sc);

        //testAccPlan.save(); call all your function here

        pageRef.getParameters().put('id', null);
        Test.setCurrentPage(pageRef);

        logReportCtrl.init();

        Test.StopTest();


//        GFNI_LogDAO logDAO = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));
//        GFNI_OpportunityLogReportCtrl logReportCtrl = new GFNI_OpportunityLogReportCtrl(logDAO);
    }

    private static Id createAccount() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Test city';
        acc.BillingState = 'Berlin';
        acc.BillingPostalCode = 'TESTPOST';
        acc.BillingCountry = 'Germany';
        acc.BillingCountryCode = 'DE';
        acc.ShippingCity = 'Test city';
        acc.ShippingState = 'Berlin';
        acc.ShippingPostalCode = 'TESTPOST';
        acc.ShippingCountry = 'Germany';
        acc.ShippingCountryCode = 'DE';
        acc.Gesellschaftsform__c = 'Limited partnership';
        acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '712627722';
        acc.Umsatzsteuer_ID__c = 'DE141908329';
        acc.Steuernummer__c = '2210583106';

        insert acc;

        return acc.Id;
    }

    private static Id createOpportunity(Id accId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.Name = 'TestName';
        opp.StageName = 'ClosedWon';
        opp.CloseDate = System.today();
        opp.LeadSource = 'E2E Form';
        opp.CurrencyIsoCode = 'EUR';
        opp.CF_Credit_Limit__c = 1500.0;
        opp.Risk_Category__c = 'High';
        opp.Anzahl_der_Karten__c = 1.0;
        opp.bearbeitet_von__c = 'Autoprocessed by E2E';
        opp.Zahlungsart__c = 'Direct debit';
        opp.Garantie__c = 'Deposit';
        opp.Rechnungsperiode__c = '7 days';
        opp.ESI__c = 'eSI: 1654';
        opp.Sec_Channel__c = 'Inbound';
        opp.Zahlungsziel_Credit__c = '7';
        opp.Angebotsdauer__c = '4 months';
        opp.Total_number_of_vehicles__c = 1.0;
        opp.Product__c = 'Inbound Typ B';
        opp.GFNI_ApplicationId__c = 'fdc9254d-17ba-4d7d-9858-e6376893e2a9';
        opp.Language_preference__c = 'German';
        opp.Next_Review_Date__c = System.today();
        opp.Garantie_other__c = 1100.0;
        opp.Credit_System_Number__c = '420896214';
        opp.Credit_System_Rating__c = '4';
        opp.SWIFT_BIC__c = 'BBRUBEBB';
        opp.IBAN__c = 'DE63265501051551881590';
        opp.Total_consumption_l_month__c = 100.0;
        opp.Eco_Fee__c = true;
        opp.Direct_Debit_Mandate_Type__c = 'Core';
        opp.VAT_Recovery__c = true;
        opp.Starts_Status__c = '0.9 Ready for GFN';
        opp.GFN_number_for_starts__c = 'DE12490330';

        insert opp;

        return opp.Id;
    }
}