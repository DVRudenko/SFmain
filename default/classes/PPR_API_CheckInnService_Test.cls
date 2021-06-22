@IsTest
public with sharing class PPR_API_CheckInnService_Test {
    @IsTest
    public static void testDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/CheckInnService';
        req.httpMethod = 'GET';
        req.addParameter('inn', '7734558610');
        req.addParameter('user', 'Dobrynia Nikitich');
        req.addParameter('source', 'testSource');
        RestContext.request = req;
        RestContext.response = res;

        PPR_API_Settings__c setting = new PPR_API_Settings__c();
        setting.Name = 'testSource';
        setting.Block_API_Actions__c = false;
        insert setting;

        Test.startTest();
        PPR_API_CheckInnService.doGet();
        Test.stopTest();
        String testBlob = RestContext.response.responseBody.toString();
        
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserialize(testBlob, PPR_API_ResponseBody.class);
        System.assertNotEquals(null, responce);
        System.assertNotEquals(null, responce.metadata);
        System.assertEquals('a5H1x0000000jA6', responce.metadata.id);
        System.assertEquals('Dobrynia Nikitich', responce.metadata.user);
        System.assertNotEquals(null, responce.customerInfo);
        System.assertEquals('7734558610', responce.customerInfo.inn);
        System.assertEquals('New', responce.customerInfo.customerStatus);
        System.assertEquals(PPR_Mapping_Utils.customerStatusMap.get('New'), responce.customerInfo.customerStatusId);
        System.assertEquals(Datetime.now().format('dd.MM.yyyy'), responce.customerInfo.checkDate);
    }

    @IsTest
    public static void testErrorDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/CheckInnService';
        req.httpMethod = 'GET';
        req.addParameter('inn', '7734558610');
        req.addParameter('user', 'error');
        req.addParameter('source', 'testSource');
        RestContext.request = req;
        RestContext.response = res;

        PPR_API_Settings__c setting = new PPR_API_Settings__c();
        setting.Name = 'testSource';
        setting.Block_API_Actions__c = false;
        insert setting;

        Test.startTest();
        PPR_API_CheckInnService.doGet();
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
        req.requestURI = '/services/apexrest/DemoUrl/CheckInnService';
        req.httpMethod = 'GET';
        req.addParameter('inn', '7734558610');
        req.addParameter('user', 'blocked');
        req.addParameter('source', 'testSource');
        RestContext.request = req;
        RestContext.response = res;

        PPR_API_Settings__c setting = new PPR_API_Settings__c();
        setting.Name = 'testSource';
        setting.Block_API_Actions__c = true;
        insert setting;

        Test.startTest();
        PPR_API_CheckInnService.doGet();
        Test.stopTest();
        String testBlob = RestContext.response.responseBody.toString();

        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserialize(testBlob, PPR_API_ResponseBody.class);
        System.assertNotEquals(null, responce);
        System.assertEquals('API Service disabled', responce.message);
    }

    @IsTest
    public static void testNullSettingsDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/CheckInnService';
        req.httpMethod = 'GET';
        req.addParameter('inn', '7734558610');
        req.addParameter('user', 'error');
        req.addParameter('source', 'testSource');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PPR_API_CheckInnService.doGet();
        Test.stopTest();
        String testBlob = RestContext.response.responseBody.toString();

        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserialize(testBlob, PPR_API_ResponseBody.class);
        System.assertNotEquals(null, responce);
        System.assertEquals('Invalid source parameter', responce.message);
    }

}