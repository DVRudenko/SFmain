/**
 * Created by Nikita.Mikhailov on 22.03.2019.
 */

@IsTest
public with sharing class GFNI_ControlPanelCtrlTest {

    @IsTest
    public static void testIsForRobotTable() {
        createCustomSetting(false, false);

        GFNI_ControlPanelCtrl controlPanelCtrl = new GFNI_ControlPanelCtrl();
        controlPanelCtrl.init();
        String response = controlPanelCtrl.response;
        String idValue = controlPanelCtrl.idValue;

        for (String key : controlPanelCtrl.countryIsForRobotMap.keySet()) {
            controlPanelCtrl.countryIsForRobotMap.put(key, true);
        }

        controlPanelCtrl.onApplyButtonClick();
    }

    @IsTest
    public static void testApplicationStatusCheckOKResponse() {
        createCustomSetting(false, false);

        GFNI_ControlPanelCtrl controlPanelCtrl = new GFNI_ControlPanelCtrl();
        controlPanelCtrl.init();

        controlPanelCtrl.idValue = createOpportunity(createAccount());

        Test.setMock(HttpCalloutMock.class, createOKApplicationStatusRequestMock());
        Test.startTest();
        controlPanelCtrl.onCheckButtonClick();
        Test.stopTest();
    }

    @IsTest
    public static void testApplicationStatusCheckNotOKResponse() {
        createCustomSetting(false, false);

        GFNI_ControlPanelCtrl controlPanelCtrl = new GFNI_ControlPanelCtrl();
        controlPanelCtrl.init();

        controlPanelCtrl.idValue = createOpportunity(createAccount());

        Test.setMock(HttpCalloutMock.class, createNotOKApplicationStatusRequestMock());
        Test.startTest();
        controlPanelCtrl.onCheckButtonClick();
        Test.stopTest();
    }

    @IsTest
    public static void testApplicationStatusCheckEmptyIdValue() {
        createCustomSetting(false, false);

        GFNI_ControlPanelCtrl controlPanelCtrl = new GFNI_ControlPanelCtrl();
        controlPanelCtrl.init();

        controlPanelCtrl.onCheckButtonClick();
    }

    @IsTest
    public static void testApplicationStatusCheckIdValueNotId() {
        createCustomSetting(false, false);

        GFNI_ControlPanelCtrl controlPanelCtrl = new GFNI_ControlPanelCtrl();
        controlPanelCtrl.init();

        controlPanelCtrl.idValue = '123';

        controlPanelCtrl.onCheckButtonClick();
    }

    private static SingleRequestMock createOKApplicationStatusRequestMock() {
        Map<String, String> responseHeaders = new Map<String, String>();
        String body = '[ { "ApplicationStatus": "**Customer and all cards created successfully**", "CustomerId": "13165", "CustomerName": "MHS HOLDING GMBH", "CustomerServiceReferenceId": "AT12499590", "CardsStatus": [ { "CardApplicationStatusId": "1", "CardId": "76062", "CardType": "8", "CardPAN": "7002080000131100010", "CardDriverName": "MHS 1", "CardRefId": "6b4d7d13-4d34-d34f-4800-42500387df7d" }, { "CardApplicationStatusId": "1", "CardId": "76063", "CardType": "8", "CardPAN": "7002080000131100028", "CardDriverName": "MHS 2", "CardRefId": "6b4d7d13-4d34-d34f-4800-42900387df7d" } ] } ]';

        return new SingleRequestMock(200, 'OK', body, responseHeaders);
    }

    private static SingleRequestMock createNotOKApplicationStatusRequestMock() {
        Map<String, String> responseHeaders = new Map<String, String>();
        String body = ' {"code": 404, "message": "Not Found", "moreInformation": "Application doesn\'t exist in backend. Please verify the Application Id and try again"}';

        return new SingleRequestMock(404, 'Not Found', body, responseHeaders);
    }

    private static void createCustomSetting(Boolean isForRobotValue, Boolean isTestMode) {
        Map<String, GFNI_General_Settings__c> gfni_general_settings = GFNI_General_Settings__c.getAll();
        if (gfni_general_settings.containsKey('DE')) {
            gfni_general_settings.get('DE').IsForRobot__c = isForRobotValue;
            update gfni_general_settings.get('DE');
        } else {
            GFNI_General_Settings__c customSetting = new GFNI_General_Settings__c();
            customSetting.Name = 'DE';
            customSetting.Application_Status__c = '/applicationstatus';
            customSetting.Create_Customer_and_Cards__c = '/customer';
            customSetting.Get_Customer_Id__c = '/customerId';
            customSetting.IsForRobot__c = isForRobotValue;
            customSetting.Number_Of_Send_Tries__c = 3;
            customSetting.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
            customSetting.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
            customSetting.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
            customSetting.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
            customSetting.Support_email__c = 'test@email.com';
            customSetting.Test_support_email__c = 'test@test.com';
            customSetting.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
            customSetting.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
            customSetting.Test_mode__c = isTestMode;
            insert customSetting;
        }
    }

    private static Id createAccount() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Test city';
        acc.BillingState = 'Berlin';
        acc.BillingPostalCode = 'TESTPOST';
        acc.BillingCountry = 'Germany';
        acc.BillingStreet = 'Test street';
        acc.ShippingStreet = 'Test street';
        acc.BillingStreet = 'Address line';
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
        opp.Papierrechnung__c = false;
        opp.e_Invoicing_PDF__c = false;
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