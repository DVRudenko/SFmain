@isTest
public with sharing class DirectumContractRestControllerTest {

    @isTest
    public static void updateContractTest() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/sf-ru-conrtact-proccessing/v1/contract-status';
        req.httpMethod = HttpUtils.Method.POST;
        Map<String, Object> testRequest = DirectumDataTestFactory.generateContractTestRequest();
        req.requestBody = Blob.valueof(JSON.serialize(testRequest));
        RestContext.request = req;
        RestContext.response = res;

        DirectumContractRestController.updateContract();

        String jsonStr = RestContext.response.responseBody.toString();
        DirectumResponseBody response = (DirectumResponseBody) JSON.deserialize(jsonStr, DirectumResponseBody.class);

        System.assertNotEquals(null, response);
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('Contract updated successfully', response.message);
    }

    @isTest
    public static void updateContractErrorTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/sf-ru-conrtact-proccessing/v1/contract-status';
        req.httpMethod = HttpUtils.Method.POST;
        RestContext.request = req;
        RestContext.response = res;

        DirectumContractRestController.updateContract();

        String jsonStr = RestContext.response.responseBody.toString();
        DirectumResponseBody response = (DirectumResponseBody) JSON.deserialize(jsonStr, DirectumResponseBody.class);

        System.assertEquals(500, RestContext.response.statusCode);
        System.assertEquals('System.NullPointerException: Argument cannot be null.', response.message);
    }
}