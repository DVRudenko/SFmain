@IsTest
public with sharing class PPR_API_CheckStatusService_Test {
    static final String testUser = 'Dobrynia Nikitich';
    static final String testId = 'a5H1x0000000jefEAA';
    static final String testSource = 'testSource';
    static final String testDate = Datetime.now().format('dd.MM.yyyy');

    @IsTest
    public static void testDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/checkStatus';
        req.httpMethod = 'GET';
        req.addParameter('id', testId);
        req.addParameter('user', testUser);
        req.addParameter('source', testSource);
        RestContext.request = req;
        RestContext.response = res;

        PPR_API_Settings__c setting = new PPR_API_Settings__c();
        setting.Name = testSource;
        setting.Block_API_Actions__c = false;
        insert setting;

        insert CFTestDataFactory.createCustomSettings();

        Test.startTest();
        PPR_API_CheckStatusService.doGet();
        Test.stopTest();
        String testBlob = RestContext.response.responseBody.toString();
        
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserialize(testBlob, PPR_API_ResponseBody.class);
        System.assertNotEquals(null, responce);
        System.assertNotEquals(null, responce.metadata);
        System.assertEquals(testId, responce.metadata.id);
        System.assertEquals(testUser, responce.metadata.user);
        System.assertNotEquals(null, responce.customerInfo);
        System.assertEquals('7777777777', responce.customerInfo.inn);
        System.assertEquals('New', responce.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get('New'), responce.customerInfo.customerStatusId);
        System.assertEquals(testDate, responce.customerInfo.checkDate);
    }

    @IsTest
    public static void testErrorDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/checkStatus';
        req.httpMethod = 'GET';
        req.addParameter('id', testId);
        req.addParameter('user', 'error');
        req.addParameter('source', testSource);
        RestContext.request = req;
        RestContext.response = res;

        PPR_API_Settings__c setting = new PPR_API_Settings__c();
        setting.Name = testSource;
        setting.Block_API_Actions__c = false;
        insert setting;

        insert CFTestDataFactory.createCustomSettings();

        Test.startTest();
        PPR_API_CheckStatusService.doGet();
        Test.stopTest();
        String testBlob = RestContext.response.responseBody.toString();

        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserialize(testBlob, PPR_API_ResponseBody.class);
        System.assertNotEquals(null, responce);
        System.assertEquals('test error', responce.message);
    }

    @IsTest
    public static void testBlockedDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/checkStatus';
        req.httpMethod = 'GET';
        req.addParameter('id', testId);
        req.addParameter('user', 'blocked');
        req.addParameter('source', testSource);
        RestContext.request = req;
        RestContext.response = res;

        PPR_API_Settings__c setting = new PPR_API_Settings__c();
        setting.Name = testSource;
        setting.Block_API_Actions__c = true;
        insert setting;

        insert CFTestDataFactory.createCustomSettings();

        Test.startTest();
        PPR_API_CheckStatusService.doGet();
        Test.stopTest();
        String testBlob = RestContext.response.responseBody.toString();

        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserialize(testBlob, PPR_API_ResponseBody.class);
        System.assertNotEquals(null, responce);
        System.assertEquals('API Service disabled', responce.message);
    }
}
