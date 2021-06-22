/**
 * Created by Nikita.Mikhailov on 27.02.2019.
 */

@IsTest
public with sharing class GFNI_LogReportAPITest {
    @IsTest
    public static void testLogDAO() {
        GFNI_LogDAO logDAO = new GFNI_LogDAO();
        logDAO.queryLog(Date.today() - 1, Date.today() + 1);
    }

    @IsTest
    public static void testReportAPI() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAOMock = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));
        GFNI_LogReportAPI logReportAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today() + 1, logDAOMock);
        logReportAPI.setFilteringValues(oppId, 'Germany', null);
        Integer reportSize = logReportAPI.createReportRecords().size();
        Test.stopTest();

        System.assertEquals(1, reportSize);
    }

    @IsTest
    public static void testReportAPIWithBadSearchValues1() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAOMock = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));
        GFNI_LogReportAPI logReportAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today() + 1, logDAOMock);
        logReportAPI.setFilteringValues('0069E00000ABJWeQAP', 'Germany', null);
        Integer reportSize = logReportAPI.createReportRecords().size();
        Test.stopTest();

        System.assertEquals(0, reportSize);
    }

    @IsTest
    public static void testReportAPIWithBadSearchValues2() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAOMock = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));
        GFNI_LogReportAPI logReportAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today() + 1, logDAOMock);
        logReportAPI.setFilteringValues(oppId, 'Another Country', null);
        Integer reportSize = logReportAPI.createReportRecords().size();
        Test.stopTest();

        System.assertEquals(0, reportSize);
    }

    @IsTest
    public static void testReportAPIWithBadSearchValues3() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAOMock = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));
        GFNI_LogReportAPI logReportAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today() + 1, logDAOMock);
        logReportAPI.setFilteringValues(null, null, true);
        Integer reportSize = logReportAPI.createReportRecords().size();
        Test.stopTest();

        System.assertEquals(0, reportSize);
    }

    @IsTest
    public static void testReportAPIWithBadSearchValues4() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAOMock = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 1));
        GFNI_LogReportAPI logReportAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today() + 1, logDAOMock);
        logReportAPI.setFilteringValues(null, null, false);
        Integer reportSize = logReportAPI.createReportRecords().size();
        Test.stopTest();

        System.assertEquals(1, reportSize);
    }

    @IsTest
    public static void testReportAPIWithSeveralLogs() {
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogDAO logDAOMock = (GFNI_LogDAO) Test.createStub(GFNI_LogDAO.class, new GFNI_MockOpportunityLogQuery(oppId, false, 2));
        GFNI_LogReportAPI logReportAPI = new GFNI_LogReportAPI(Date.today() - 1, Date.today() + 1, logDAOMock);
        logReportAPI.setFilteringValues(oppId, 'Germany', null);
        Integer reportSize = logReportAPI.createReportRecords().size();
        Test.stopTest();

        System.assertEquals(1, reportSize);
    }

    @IsTest
    public static void testCompareToGNIF_LogReportRecord() {
        GFNI_LogReportRecord record1 = new GFNI_LogReportRecord();
        record1.recordDate = System.now();

        GFNI_LogReportRecord record2 = new GFNI_LogReportRecord();
        record2.recordDate = System.now().addDays(1);

        System.assertEquals(1, record1.compareTo(record2));
    }


    private static Id createAccount() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingStreet = 'Test street';
        acc.BillingCity = 'Test city';
        acc.BillingState = 'Berlin';
        acc.BillingPostalCode = 'TESTPOST';
        acc.BillingCountry = 'Germany';
        acc.BillingCountryCode = 'DE';
        acc.ShippingStreet = 'Test street';
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
        opp.StageName = 'Closed Won';
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
        opp.Papierrechnung__c = true;
        opp.Sec_Channel__c = 'Inbound';
        opp.Zahlungsziel_Credit__c = '7';
        opp.Angebotsdauer__c = '4 months';
        opp.Total_number_of_vehicles__c = 1.0;
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
        opp.e_Invoicing_PDF__c = false;
        opp.Direct_Debit_Mandate_Type__c = 'Core';
        opp.VAT_Recovery__c = true;
        opp.Custom_PIN__c = true;
        opp.Starts_Status__c = '0.9 Ready for GFN';
        opp.Product__c = 'Inbound Typ C';

        insert opp;

        return opp.Id;
    }
}