@isTest
public with sharing class PPR_API_CreateClient_Test {

    private static void initTestData() {
        E2EFormRuTestUtils.initCustomSettings();

        List<E2E_Promocodes__c> promocodes = new List<E2E_Promocodes__c>();
        promocodes.add(PPR_API_DataTestFactory.createPromocode('9Е06', '@159;', '159@19,9;'));
        promocodes.add(PPR_API_DataTestFactory.createPromocode('9Е07', '@160;', '160@19,17;'));
        insert promocodes;

        PPR_API_Settings__c settingEuroplan = PPR_API_DataTestFactory.createPPR_API_Settings();
        insert settingEuroplan;
    }
    
    @isTest
    public static void doPostCreateClientTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/PPR_API/v1/CreateClient';
        req.httpMethod = 'POST';

        initTestData();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Process_Status__c = 'New';
        insert formData;
        Map<String, Object> testRequest = PPR_API_DataTestFactory.generateTestRequest(formData.Id, '1234567890');

        req.requestBody = Blob.valueof(JSON.serialize(testRequest));
        RestContext.request = req;
        RestContext.response = res;
        LongForm_Tariff__c tarif = new LongForm_Tariff__c(Name = '2CHOOSEN_cards');
        insert tarif;
        LongForm_Offer__c offer = new LongForm_Offer__c();
        insert offer;
        LongForm_Fleetcor_Product__c product = new LongForm_Fleetcor_Product__c(Name = 'PetrolPlus_Rover', Long_Form_Offer__c = offer.Id);
        insert product;

        Custom_log__c newLog = PPR_API_DataTestFactory.createCustomLog(formData.Id, '1234567890');
        insert newLog;

        Test.startTest();
        PPR_API_CreateClient.doPost();
        Test.stopTest();

        String testBlob = RestContext.response.responseBody.toString();
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserializeStrict(testBlob, PPR_API_ResponseBody.class);

        System.assertNotEquals(null, responce);
        System.assertEquals(null, responce.message);
        System.assertEquals('Processing', responce.customerInfo.customerStatus);
    }

    @isTest
    public static void doPostSendToInboundTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/PPR_API/v1/CreateClient';
        req.httpMethod = 'POST';

        initTestData();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Manual_Entry__c = true;
        formData.E2E_Process_Status__c = 'New';
        insert formData;
        Map<String, Object> testRequest = PPR_API_DataTestFactory.generateTestRequest(formData.Id, '1234567891');

        req.requestBody = Blob.valueof(JSON.serialize(testRequest));
        RestContext.request = req;
        RestContext.response = res;
        LongForm_Tariff__c tarif = new LongForm_Tariff__c(Name = '2CHOOSEN_cards');
        insert tarif;
        LongForm_Offer__c offer = new LongForm_Offer__c();
        insert offer;
        LongForm_Fleetcor_Product__c product = new LongForm_Fleetcor_Product__c(Name = 'PetrolPlus_Rover', Long_Form_Offer__c = offer.Id);
        insert product;

        Custom_log__c newLog = PPR_API_DataTestFactory.createCustomLog(formData.Id, '1234567891');
        insert newLog;

        Test.startTest();
        PPR_API_CreateClient.doPost();
        Test.stopTest();

        String testBlob = RestContext.response.responseBody.toString();
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserializeStrict(testBlob, PPR_API_ResponseBody.class);

        System.assertNotEquals(null, responce);
        System.assertEquals(null, responce.message);
        System.assertEquals('Processing', responce.customerInfo.customerStatus);
    }

    @isTest
    public static void doPostErrorSourceTest() {
        initTestData();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/PPR_API/v1/CreateClient';
        req.httpMethod = 'POST';
        Map<String, Object> testRequest = PPR_API_DataTestFactory.generateTestRequest(null, '1234567892');
        req.requestBody = Blob.valueof(JSON.serialize(testRequest));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PPR_API_CreateClient.doPost();
        Test.stopTest();

        String testBlob = RestContext.response.responseBody.toString();
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserializeStrict(testBlob, PPR_API_ResponseBody.class);
        System.assertEquals('Validation error. Invalid product: PetrolPlus_Rover', responce.message);
    }

    @isTest
    public static void doPostErrorTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/PPR_API/v1/CreateClient';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        insert CFTestDataFactory.createCustomSettings();

        Test.startTest();
        PPR_API_CreateClient.doPost();
        Test.stopTest();

        String testBlob = RestContext.response.responseBody.toString();
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserializeStrict(testBlob, PPR_API_ResponseBody.class);
        System.assertEquals('System.NullPointerException: Argument cannot be null.', responce.message);
    }

    @isTest
    public static void createClientOnlyRequiredDataTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/DemoUrl/PPR_API/v1/CreateClient';
        req.httpMethod = 'POST';

        initTestData();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Process_Status__c = 'New';
        insert formData;
        Map<String, Object> testRequest = PPR_API_DataTestFactory.generateTestRequestMandatoryFields(formData.Id, '1234567893');

        req.requestBody = Blob.valueof(JSON.serialize(testRequest));
        RestContext.request = req;
        RestContext.response = res;
        LongForm_Tariff__c tarif = new LongForm_Tariff__c(Name = '2CHOOSEN_cards');
        insert tarif;
        LongForm_Offer__c offer = new LongForm_Offer__c();
        insert offer;
        LongForm_Fleetcor_Product__c product = new LongForm_Fleetcor_Product__c(Name = 'PetrolPlus_Rover', Long_Form_Offer__c = offer.Id);
        insert product;

        Custom_log__c newLog = PPR_API_DataTestFactory.createCustomLog(formData.Id, '1234567893');
        insert newLog;

        Test.startTest();
        PPR_API_CreateClient.doPost();
        Test.stopTest();

        String testBlob = RestContext.response.responseBody.toString();
        PPR_API_ResponseBody responce = (PPR_API_ResponseBody) JSON.deserializeStrict(testBlob, PPR_API_ResponseBody.class);

        System.assertNotEquals(null, responce);
        System.assertEquals(null, responce.message);
        System.assertEquals('Processing', responce.customerInfo.customerStatus);
    }
}
