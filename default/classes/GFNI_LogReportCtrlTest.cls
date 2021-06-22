/**
 * Created by Nikita.Mikhailov on 27.02.2019.
 */

@IsTest
public with sharing class GFNI_LogReportCtrlTest {

    @IsTest
    public static void testCtrlConstructor() {
        GFNI_LogReportCtrl logReportCtrl = new GFNI_LogReportCtrl();
        System.assertEquals(logReportCtrl.startDate, Date.today() - 1);
        System.assertEquals(logReportCtrl.endDate, Date.today());
    }

    @IsTest
    public static void testCtrl() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);
        Id cardId = createCard(oppId);

        Account acc = [SELECT Id, Account_Nr__c FROM Account WHERE Id = :accId];

        Test.startTest();
        GFNI_LogReportAPI logAPI = (GFNI_LogReportAPI) Test.createStub(GFNI_LogReportAPI.class, new GFNI_MockOpportunityLogAPI(oppId, accId, false, 1));
        GFNI_LogReportCtrl logReportCtrl = new GFNI_LogReportCtrl(logAPI);
        logReportCtrl.init();
        logReportCtrl.onApplyButtonClick();
        logReportCtrl.idValue = 'Not an Id';
        logReportCtrl.onApplyButtonClick();
        List<SelectOption> countries = logReportCtrl.countries;
        GFNI_LogReportCtrl.onIdValueChange(oppId);
        GFNI_LogReportCtrl.onIdValueChange('DE12490330');
        GFNI_LogReportCtrl.onIdValueChange('DE00000000');
        GFNI_LogReportCtrl.onIdValueChange('FC-001320685');
        GFNI_LogReportCtrl.onIdValueChange(acc.Account_Nr__c);
        GFNI_LogReportCtrl.onIdValueChange('0069E00000ABWPvQAP');
        GFNI_LogReportCtrl.onIdValueChange('Not an id');
        logReportCtrl.startDate = Date.today() - 1;
        logReportCtrl.endDate = Date.today() + 1;
        logReportCtrl.onExportToExcelButtonClick();
        Test.stopTest();

        System.assertEquals(false, logReportCtrl.isExportDisabled);
    }

    @IsTest
    public static void testPagination() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);
        Id cardId = createCard(oppId);

        Test.startTest();
        GFNI_LogReportAPI logAPI = (GFNI_LogReportAPI) Test.createStub(GFNI_LogReportAPI.class, new GFNI_MockOpportunityLogAPI(oppId, accId, false, 100));
        GFNI_LogReportCtrl logReportCtrl = new GFNI_LogReportCtrl(logAPI);
        logAPI.totalSize = 100;
        logReportCtrl.init();
        logReportCtrl.lastPage();
        logReportCtrl.nextPage();
        logReportCtrl.previousPage();
        Test.stopTest();
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

    private static Id createCard(Id oppId) {
        Tankkarten__c card = new Tankkarten__c();
        card.Opportunity__c = oppId;
        card.Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
        card.Produktbezugskategorie__c = '2 Category 1 plus vehicle-related goods and services (oils, car wash)';
        card.GFNI_Status__c = 'Pending';
        card.Fahrzeugtyp__c = 'PKW';
        card.Firmenname_auf_der_Karte__c = 'TEST';
        card.Driver_Name__c = 'TEST';
        card.Kilometerstand_Abfrage__c = true;

        insert card;

        return card.Id;
    }
}