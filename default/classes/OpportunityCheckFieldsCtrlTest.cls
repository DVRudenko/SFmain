@isTest
public class OpportunityCheckFieldsCtrlTest {
    static String RecordTypeAcc = GlobalUtils.returnRecordTypeId('Account', 'Russian');
    static String RecordTypeOpp = GlobalUtils.returnRecordTypeId('Opportunity', 'Russian Sales');
    static OpportunityCheckFieldsCtrl controller;
    static PageReference page;
    static Opportunity testOpportunity;

    private static void init() {

        createCustomSettings();

        Account testAccount = new Account(
                Name = 'testacc',
                INN__c = '7700011001',
                RecordTypeId = RecordTypeAcc);
        insert testAccount;

        testOpportunity = new Opportunity(
                Name = 'TESTOPPORTUNITIES',
                AccountId = testAccount.Id,
                StageName = 'Qualified Lead',
                CloseDate = Date.newInstance(2018, 03, 25),
                Most_Important_Feature__c = 'Controls',
                PPR_First_Contact_Inbound_Outbound__c = 'Inbound call',
                Source_of_Lead_o__c = 'Выставка',
                RecordTypeId = RecordTypeOpp,
                Industry__c = 'Apparel',
                Fleet_Type__c = 'Легковой',
                Number_of_Vehicles__c = 1,
                Number_of_Vehicles_in_Leasing__c = '1',
                Area_Traveled__c = 'Regional',
                The_region__c = 'г. Санкт-Петербург',
                Projected_Liters_weekly__c = 1,
                General_Projected_Liters_w__c = 2,
                Travel_Pattern__c = 'Regular Route',
                Primary_Fueling_Method__c = 'Coupons',
                Additional_Fueling_Methods__c = 'Cash',
                PPR_Electronic_document_management__c = 'diadoc',
                PPR_EDM_No__c = 'Не использует ЭДО',
                PPR_Operator__c = 'Контур',
                Traffic_tickets_monitoring_service__c = 'ДА',
                UPD__c = 'ДА',
                High_season__c = 'ДА',
                High_season_months__c = 'ЯНВАРЬ',
                Extra_terms__c = '--',
                Product_PPR__c = 'Талоны (GPC)');
        insert testOpportunity;

        page = new PageReference('/apex/OpportunityCheckFields');
        page.getParameters().put('Id', testOpportunity.Id);
        Test.setCurrentPage(page);
        ApexPages.StandardController sc = new ApexPages.standardController(testOpportunity);
        controller = new OpportunityCheckFieldsCtrl(sc);
    }

    @isTest
    public static void saveSuccessfullyTest() {
        init();

        Test.startTest();
        controller.init();
        System.assert(true, controller.currentOpportunity != null);
        controller.currentOpportunity.Industry__c = 'Agriculture';
        controller.save();
        System.assertEquals('Agriculture', controller.currentOpportunity.Industry__c);
        System.assert(true, controller.base64Value != null);
        Test.stopTest();
    }

    @isTest
    public static void showInfoErrorTest() {
        init();

        Test.startTest();
        page = new PageReference('/apex/OpportunityCheckFields');
        page.getParameters().put('Id', null);
        Test.setCurrentPage(page);
        ApexPages.StandardController sc = new ApexPages.standardController(testOpportunity);
        controller = new OpportunityCheckFieldsCtrl(sc);
        controller.init();
        System.assert(ApexPages.hasMessages(ApexPages.Severity.INFO));
        Test.stopTest();
    }

    @isTest
    public static void cancelButtonTest() {
        init();

        Test.startTest();
        controller.back();
        System.assert(true, controller.currentOpportunity == testOpportunity);
        Test.stopTest();
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}