@isTest
public class GFNI_DashboardCtrlTest {

    public static void initCustomSettings(Boolean isTestMode) {
        insert new GFNI_Settings__c(
                API_version__c = '1',
                Client_system__c = 'SME',
                Culture__c = 'en-GB',
                Name = 'GFN Integration Settings',
                Test_mode__c = isTestMode ? true : false,
                Prod_endpoint__c = 'https://api.prod.endpoint',
                Test_endpoint__c = 'https://api.test.endpoint'
        );
    }

    @testSetup
    static void createTestData() {
        Account acc = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
                Name = 'Test GFN Account',
                GFN_Nr__c = 'DE12478550',
                BillingCountry = 'Germany',
                ColCo__c = 'DE'
        );
        insert acc;

        Case c = new Case(
                Origin = 'E-Mail',
                RecordTypeId = GlobalUtils.getRecordTypeId('Case', 'Support'),
                Status = 'New',
                Subject = 'Subject',
                Description = 'Subject',
                AccountId = acc.Id
        );
        insert c;

        Task t = new Task(
            RecordTypeId = GlobalUtils.getRecordTypeId('Task', 'Call'),
            Account__c = acc.Id
        );
        insert t;

        Task t1 = new Task(
            RecordTypeId = GlobalUtils.getRecordTypeId('Task', 'Call'),
            WhatId = acc.Id
        );
        insert t1;

        ERP__c erp = new ERP__c (
            RecordTypeId = GlobalUtils.getRecordTypeId('ERP__c', 'SME'),
            GFN_Nr__c = 'DE12478550',
            ColCo__c = 'DE'
        );
        insert erp;
    }

    static String colCoID = '1';
    static String customerERP = 'DE12478550';
    static String recordType = 'SME';
    static String userName = 'TEST_USER';

    @isTest
    public static void testDashboardFormAccountPage() {
        initCustomSettings(true);

        Account acc = [
                SELECT Id, Name, GFN_Nr__c, ColCo__c, OwnerId
                FROM Account
                WHERE GFN_Nr__c = 'DE12478550'
                LIMIT 1
        ];

        GFNI_DashboardCtrl controller = new GFNI_DashboardCtrl();
        GFNI_DashboardCtrl.Params params = GFNI_DashboardCtrl.init(acc.Id, 'Account');
        System.assertEquals(true, params.colCoId == colCoID);
        System.assertEquals(true, params.customerGfnNumber == customerERP);
        System.assertEquals(true, params.objId == acc.Id);
        System.assertEquals(true, params.objType == 'Account');
    }

    @isTest
    public static void testDashboardFromCasePage() {
        initCustomSettings(true);

        Case c = [
                SELECT Id, CaseNumber, Account.GFN_Nr__c, Account.ColCo__c
                FROM Case
                LIMIT 1
        ];

        GFNI_DashboardCtrl controller = new GFNI_DashboardCtrl();
        GFNI_DashboardCtrl.Params params = GFNI_DashboardCtrl.init(c.Id, 'Case');
        System.assertEquals(colCoID, params.colCoId);
        System.assertEquals(customerERP, params.customerGfnNumber);
        System.assertEquals(c.Id, params.objId);
        System.assertEquals('Case', params.objType);
    }

    @isTest
    public static void testDashboardFromTaskPage() {
        initCustomSettings(true);

        Task t = [
                SELECT Id, Account__c
                FROM Task
                WHERE Account__c != NULL
                LIMIT 1
        ];

        GFNI_DashboardCtrl controller = new GFNI_DashboardCtrl();
        GFNI_DashboardCtrl.Params params = GFNI_DashboardCtrl.init(t.Id, 'Task');
        System.assertEquals(true, params.colCoId == colCoID);
        System.assertEquals(true, params.customerGfnNumber == customerERP);
        System.assertEquals(true, params.objId == t.Id);
        System.assertEquals(true, params.objType == 'Task');
    }

    @isTest
    public static void testDashboardFromTaskWithWhatIdPage() {
        initCustomSettings(true);

        Task t = [
                SELECT Id, Account__c
                FROM Task
                WHERE Account__c = NULL
                LIMIT 1
        ];

        GFNI_DashboardCtrl controller = new GFNI_DashboardCtrl();
        GFNI_DashboardCtrl.Params params = GFNI_DashboardCtrl.init(t.Id, 'Task');
        System.assertEquals(true, params.colCoId == colCoID);
        System.assertEquals(true, params.customerGfnNumber == customerERP);
        System.assertEquals(true, params.objId == t.Id);
        System.assertEquals(true, params.objType == 'Task');
    }

    @isTest
    public static void test200() {
        initCustomSettings(true);

        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, String> accountDetailsMap = GFNI_DashboardCtrl.getAccountDetailsGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountDetailsMap.get('FullName') == 'KEP SOLUTION GMBH');
        System.assertEquals(true, accountDetailsMap.get('RelatedAccounts') != null);

        Map<String, String> accountContactsMap = GFNI_DashboardCtrl.getAccountContactsGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountContactsMap.get('AccountContacts') != null);

        Map<String, String> accountAddressesMap = GFNI_DashboardCtrl.getAccountAddressesGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountAddressesMap.get('AccountAddresses') != null);

        Map<String, String> accountServicesMap = GFNI_DashboardCtrl.getAccountServicesGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountServicesMap.get('AccountServices') != null);

        Map<String, String> accountSelfServeUsersMap = GFNI_DashboardCtrl.getAccountSelfServeUsersGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountSelfServeUsersMap.get('AccountSelfServeUsers') != null);

        Map<String, String> accountCardsInfoMap = GFNI_DashboardCtrl.getAccountCardsInfoGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountCardsInfoMap.get('AccountCardsInfo') != null);

        Map<String, String> accountUnbilledProductsMap = GFNI_DashboardCtrl.getAccountUnbilledProductsGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountUnbilledProductsMap.get('UnbilledProducts') != null);

        Map<String, String> accountUnbilledTransactionsMap = GFNI_DashboardCtrl.getAccountUnbilledTransactionsGfn(colCoID, customerERP, null, null, null, null, recordType);
        System.assertEquals(true, accountUnbilledTransactionsMap.get('UnbilledTransactions') != null);

        Map<String, String> accountPaymentDetailsMap = GFNI_DashboardCtrl.getAccountPaymentDetailsGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountPaymentDetailsMap.get('CreditLimit') != null);

        Map<String, String> accountInfoSubscriptionsMap = GFNI_DashboardCtrl.getAccountInformationSubscriptionsGfn(colCoID, customerERP, recordType);
        System.assertEquals(true, accountInfoSubscriptionsMap.get('InfoSubscriptions') != null);

        String cardIdsList = '70929, 583557, 606978, 456838';
        Map<String, String> accountBlockedCardRequestsMap = GFNI_DashboardCtrl.blockAccountCardsGfn(colCoID, customerERP, cardIdsList, recordType);
        System.assertEquals(true, accountBlockedCardRequestsMap.get('BlockCardRequests') != null);

        Map<String, String> accountHomeSitesMap = GFNI_DashboardCtrl.getHomeSitesGFN(colCoID, customerERP, recordType);
        System.assertEquals(true, accountHomeSitesMap.get('HomeSites') != null);

        Map<String, String> accountFeeRulesMap = GFNI_DashboardCtrl.getFeeRules(colCoID, customerERP, recordType);
        System.assertEquals(true, accountFeeRulesMap.get('FeeRules') != null);

        Map<String, String> accountPriceRulesMap = GFNI_DashboardCtrl.getPriceRules(colCoID, customerERP, recordType);
        System.assertEquals(true, accountPriceRulesMap.get('PriceRules') != null);

        Map<String, String> accountCreditData = GFNI_DashboardCtrl.getCreditData(colCoID, customerERP, recordType);
        System.assertEquals(true, accountCreditData.get('CreditData') != null);

        Map<String, String> accountBillingDocuments = GFNI_DashboardCtrl.getBillingDocuments(colCoID, customerERP, recordType);
        System.assertEquals(true, accountBillingDocuments.get('BillingDocuments') != null);

        String resetPasswordResponse = GFNI_DashboardCtrl.resetPassword(colCoID, customerERP, userName, recordType);
        System.assertEquals(true, resetPasswordResponse == 'The password reset request submitted successfully!');

        Test.stopTest();
    }

    @isTest
    public static void test500() {
        initCustomSettings(true);

        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        try{
            Map<String, String> accountDetailsMap = GFNI_DashboardCtrl.getAccountDetailsGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountContactsMap = GFNI_DashboardCtrl.getAccountContactsGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountAddressesMap = GFNI_DashboardCtrl.getAccountAddressesGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountServicesMap = GFNI_DashboardCtrl.getAccountServicesGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountSelfServeUsersMap = GFNI_DashboardCtrl.getAccountSelfServeUsersGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountCardsInfoMap = GFNI_DashboardCtrl.getAccountCardsInfoGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountUnbilledProductsMap = GFNI_DashboardCtrl.getAccountUnbilledProductsGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountUnbilledTransactionsMap = GFNI_DashboardCtrl.getAccountUnbilledTransactionsGfn(colCoID, customerERP, null, null, null, null, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountPaymentDetailsMap = GFNI_DashboardCtrl.getAccountPaymentDetailsGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountInfoSubscriptionsMap = GFNI_DashboardCtrl.getAccountInformationSubscriptionsGfn(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        String cardIdsList = '70929, 583557, 606978, 456838';
        try {
            Map<String, String> accountBlockedCardRequestsMap = GFNI_DashboardCtrl.blockAccountCardsGfn(colCoID, customerERP, cardIdsList, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountHomeSitesMap = GFNI_DashboardCtrl.getHomeSitesGFN(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
        Map<String, String> accountFeeRulesMap = GFNI_DashboardCtrl.getFeeRules(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountPriceRulesMap = GFNI_DashboardCtrl.getPriceRules(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            Map<String, String> accountBillingDocuments = GFNI_DashboardCtrl.getBillingDocuments(colCoID, customerERP, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        try {
            String resetPasswordResponse = GFNI_DashboardCtrl.resetPassword(colCoID, customerERP, userName, recordType);
        } catch (Exception e){
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }

        Test.stopTest();
    }

    @isTest
    public static void testGetUserOfset(){
        initCustomSettings(true);
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'
        ];

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT');
        insert user;
        
        System.runAs(user){
            Integer offset = GFNI_DashboardCtrl.getCurrentUserOffset();
            System.assertEquals(0, offset);
        }
    }

    @isTest
    public static void testGetDocumentLinkWithVersion(){
        initCustomSettings(true);
        ContentVersion newVersion = new ContentVersion();
        Blob pdf = EncodingUtil.base64Decode('dGVzdA==');
        newVersion.VersionData = pdf;
        newVersion.Title = 'test.pdf';
        newVersion.PathOnClient = 'test.pdf';
        insert newVersion;
        String link = GFNI_DashboardCtrl.getDocumentLink(colCoId, customerERP, 'test', recordType);
        System.assert(link!=null);
    }

    @isTest
    public static void testGetDocumentLinkWithoutVersion(){
        initCustomSettings(true);
        
        Test.startTest();

        Map<String, HttpCalloutMock> responses = GFNI_DashboardServiceImplTest.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        String link = GFNI_DashboardCtrl.getDocumentLink(colCoId, customerERP, 'test', recordType);
        System.assert(link!=null);
        Test.stopTest();
    }

    @isTest
    public static void testGetRelatedAccountId() {
        initCustomSettings(true);
        
        Account testAccount = [
            SELECT  Id,
                    GFN_Nr__c
            FROM    Account
            LIMIT   1
        ];
        Id accId = GFNI_DashboardCtrl.getRelatedAccountId(testAccount.GFN_Nr__c);
        System.assertEquals(testAccount.Id, accId);
    }

    @isTest
    public static void testGetRelatedERPId() {
        initCustomSettings(true);
        
        Id nullErp = GFNI_DashboardCtrl.getRelatedERPId('123');
        System.assertEquals(null, nullErp);
        
        List<ERP__c> erpList = [
            SELECT  Id
            FROM    ERP__c
            WHERE   GFN_Nr__c =: 'DE12478550'
            OR     GFN_Number__c =: 'DE12478550'
            LIMIT   1
        ];
        Id erpId = GFNI_DashboardCtrl.getRelatedERPId('DE12478550');
        System.assertEquals(erpList[0].Id, erpId);

    }

    @isTest
    public static void testGetResetHistory() {
        initCustomSettings(true);

        ERP__c testErp = new ERP__c(
            Name = 'test',
            GFN_Number__c = 'D0123456',
            ColCo__c = 'CZ'
        );
        insert testErp;

        GFNI_DashboardCtrl.saveResetPasswortLog('D0123456', 'Success', 'testUserName');

        String historyLog = GFNI_DashboardCtrl.getResetPasswordHistory('D0123456');
        System.assert(historyLog != null);
    }
}