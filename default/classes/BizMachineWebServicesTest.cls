/**
 * Created by marekhaken on 26/08/2020.
 */

@IsTest
private class BizMachineWebServicesTest {

    @testSetup static void setup() {
        BizMachine_Settings__c bs = new BizMachine_Settings__c();
        bs.Name = 'Credentials';
        bs.API_Key__c = '1234';
        bs.Sandbox_Dataset__c = 'asd';
        bs.Production_Dataset__c = 'asd';
        bs.Production_Endpoint__c = 'http://asd.com';
        bs.Sandbox_Endpoint__c = 'http://asd.com';
        insert bs;

        BizMachine_Data_Settings__c bizData = new BizMachine_Data_Settings__c();
        bizData.BizMachine_Tag_UID__c = 'UID';
        bizData.Name = 'Updated';
        bizData.BizMachine_Tag_Name__c = 'Tag Name';
        bizData.BizMachine_Updated_Tag__c = true;
        insert bizData;
    }

    @IsTest
    static void testGetTagCompanies() {
        Test.startTest();
        BizMachineWebServices.getApiKey();
        BizMachineWebServices.getEndpoint();

        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        BizMachineWebServices.getTagCompanies('UID');
        Test.stopTest();
    }

    @IsTest
    static void testRemoveTagCompanyRelation() {
        Test.startTest();
        BizMachineWebServices.getApiKey();
        BizMachineWebServices.getEndpoint();

        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        BizMachineWebServices.removeTagCompanyRelation('02582589', 'UID');
        Test.stopTest();
    }

    @IsTest
    static void testSetTagCompanyRelation() {
        Test.startTest();
        BizMachineWebServices.getApiKey();
        BizMachineWebServices.getEndpoint();

        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        BizMachineWebServices.setTagCompanyRelation('02582589', 'UID');
        Test.stopTest();
    }

    @IsTest
    static void testGetCompanyTags() {
        Test.startTest();
        BizMachineWebServices.getApiKey();
        BizMachineWebServices.getEndpoint();

        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        BizMachineWebServices.getCompanyTags('02582589');
        Test.stopTest();
    }

    @IsTest
    static void testGetCompanyDetail() {
        Test.startTest();
        BizMachineWebServices.getApiKey();
        BizMachineWebServices.getEndpoint();

        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        BizMachineWebServices.getCompanyDetailHttpResponse('02582589');
        Test.stopTest();
    }

    @IsTest
    static void testAccountCreate() {
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;

        Test.startTest();
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        insert acc;

        Test.stopTest();
    }

    @IsTest
    static void testBizmachineBatch() {
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;

        Test.startTest();
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        insert acc;

        BizMachineMonitoringBatch ws = new BizMachineMonitoringBatch();
        Database.executeBatch(ws, 1);


        Test.stopTest();
    }

    @IsTest
    static void testBizmachineSchedule() {
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;

        Test.startTest();
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        insert acc;

        String CRON_EXP = '0 0 0 3 9 ? 2028';
        BizMachineMonitoringSchedule bizsche = new BizMachineMonitoringSchedule();
        String jobID = System.schedule('BizMachine monitoring', CRON_EXP, bizsche);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2028-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();

    }

    @IsTest
    static void testBizmachineEditICO() {
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        Account acc2 = [SELECT Id FROM Account WHERE Id = :acc.Id];
        acc2.CCS_Company_ID__c = '27916693';
        Test.startTest();
        update acc2;
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineRemoveTag() {
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());

        AccountTriggerHandler.removeBizMachineTagFuture('ic','uid');
    }

    @IsTest
    static void testBizmachineRemoveBizTags() {
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        List<Account> accs = new List<Account>();
        accs.add(acc);
        Test.startTest();
        AccountTriggerHandler.removeBizMachineTag(accs);
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineRemoveBizTags2() {
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        BizMachine_Data_Settings__c bData = new BizMachine_Data_Settings__c();
        bData.BizMachine_Tag_UID__c = 'UID';
        bData.BizMachine_Monitoring_Tag__c = true;
        bData.Name = 'Name2';
        insert bData;

        List<Account> accs = new List<Account>();
        accs.add(acc);
        Test.startTest();
        AccountTriggerHandler.removeBizMachineTag(accs);
        Test.stopTest();
    }

    @IsTest
    static void testBizmachineGetData() {
        AccountTriggerHandler.makeCallout = false;
        Test.setMock(HttpCalloutMock.class, new BizMachineMockImpl());
        Id recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CCS' AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account();
        acc.Name = 'Intercodec';
        acc.CCS_Company_ID__c = '02582589';
        acc.Phone = '777890890';
        acc.BillingCountryCode = 'CZ';
        acc.RecordTypeId = recTypeId;
        acc.BizMachine_Monitoring__c = true;
        insert acc;

        BizMachine_Data_Settings__c bData = new BizMachine_Data_Settings__c();
        bData.BizMachine_Tag_UID__c = 'UID';
        bData.BizMachine_Monitoring_Tag__c = true;
        bData.Name = 'Name2';
        insert bData;

        Set<Id> setIds = new Set<Id>();
        setIds.add(acc.Id);
        Test.startTest();
        AccountTriggerHandler.getAccountDataFromBizmachineFutureCall(setIds);
        Test.stopTest();
    }
}