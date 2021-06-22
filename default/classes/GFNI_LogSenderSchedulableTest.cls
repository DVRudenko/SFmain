/**
 * Created by Nikita.Mikhailov on 26.02.2019.
 */

@IsTest
public with sharing class GFNI_LogSenderSchedulableTest {

    @IsTest
    public static void testExecute1() {
        createCustomSetting();
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogReportAPI logMock = (GFNI_LogReportAPI) Test.createStub(GFNI_LogReportAPI.class, new GFNI_MockOpportunityLogAPI(oppId, accId, true, 1));
        GFNI_LogSenderSchedulable app = new GFNI_LogSenderSchedulable(logMock);
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecute2() {
        createCustomSetting();
        Id accId = createAccount();
        Id oppId = createOpportunity(accId);

        Test.startTest();
        GFNI_LogReportAPI logMock = (GFNI_LogReportAPI) Test.createStub(GFNI_LogReportAPI.class, new GFNI_MockOpportunityLogAPI(oppId, accId, false, 1));
        GFNI_LogSenderSchedulable app = new GFNI_LogSenderSchedulable(logMock);
        app.execute(null);
        Test.stopTest();
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

        insert opp;

        return opp.Id;
    }

    private static void createCustomSetting() {
        GFNI_General_Settings__c customSetting = new GFNI_General_Settings__c();
        customSetting.Name = 'DE';
        customSetting.Application_Status__c = '/applicationstatus';
        customSetting.Create_Customer_and_Cards__c = '/customer';
        customSetting.Get_Customer_Id__c = '/customerId';
        customSetting.IsForRobot__c = true;
        customSetting.Number_Of_Send_Tries__c = 3;
        customSetting.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        customSetting.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        customSetting.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        customSetting.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        customSetting.Support_email__c = 'test@email.com';
        customSetting.Test_support_email__c = 'test@test.com';
        customSetting.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        customSetting.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        customSetting.Test_mode__c = true;

        insert customSetting;
    }
}