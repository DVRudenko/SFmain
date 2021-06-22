@isTest
public with sharing class SiteDuplicatesReportRuCtrlTest {

    @TestSetup
    public static void init() {
        createCustomSettings();
//        String RecordTypeLead = [SELECT Id FROM recordType WHERE Name = 'Russian Sales' AND SobjectType = 'Lead'].Id;
//        String RecordTypeOpp = [SELECT id FROM recordtype WHERE Name = 'Russian Sales' AND SobjectType = 'Opportunity'].id;
//        String RecordTypeAcc = [SELECT id FROM recordtype WHERE Name = 'Russian' AND SobjectType = 'Account'].id;
        String RecordTypeLead = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        String RecordTypeOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        String RecordTypeAcc = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();

        Account accountt = new Account(
                Name = 'pro567vAA567',
                BillingPostalCode = '123',
                Phone = '+71098765432',
                INN__C = '1234567888888',
                RecordTypeiD = RecordTypeAcc);
        insert accountt;

        Opportunity opportunity = new Opportunity(
                Name = 'pro567ve567',
                StageName = 'Prospecting',
                CloseDate = date.today(),
                AccountId = accountt.id,
                Recordtypeid = RecordTypeOpp);
        insert opportunity;

        Lead lead_1 = new Lead(
                Phone = '+71098765432',
                LastName = 'AAAA',
                Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com',
                Salutation = 'Herr',
                INN__C = '1234567338888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(),
                Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call',
                Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead);
        insert lead_1;

        Lead lead_2 = new Lead(
                Phone = '+71098765432',
                LastName = 'BBBB',
                Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com',
                Salutation = 'Herr',
                INN__C = '12345673238',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(),
                Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call',
                Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead,
                Master_Record_ID__c = lead_1.Id);

        Lead lead_3 = new Lead(
                Phone = '+71098765432',
                LastName = 'pro567verkaAAAA',
                Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com',
                Salutation = 'Herr',
                INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(),
                Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call',
                Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead,
                Master_Record_ID__c = opportunity.Id);
        
        insert new List<Lead> {
                lead_2, lead_3
        };
    }

    @isTest
    public static void testSelectDuplicateRecord() {
        Test.startTest();
        SiteDuplicatesReportRuCtrl siteDuplicatesReportRuCtrl = new SiteDuplicatesReportRuCtrl();
        siteDuplicatesReportRuCtrl.createdDateFrom = System.Today().addDays(-1);
        siteDuplicatesReportRuCtrl.createdDateTo = System.Today().addDays(1);
        siteDuplicatesReportRuCtrl.applyFilter();
        Test.stopTest();

        System.assertEquals(1, siteDuplicatesReportRuCtrl.bundleLeadToLeadMap.size());
        System.assertEquals(1, siteDuplicatesReportRuCtrl.bundleLeadToOpportunityMap.size());
    }

    @isTest
    public static void testSendReport() {
        Test.startTest();
        SiteDuplicatesReportRuCtrl siteDuplicatesReportRuCtrl = new SiteDuplicatesReportRuCtrl();
        PageReference pageRef = Page.SiteDuplicatesReportRu;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('htmlBody', '<html><head><meta charset="utf-8"></head><body></body></html>');
        siteDuplicatesReportRuCtrl.sendReport();
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations());
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}