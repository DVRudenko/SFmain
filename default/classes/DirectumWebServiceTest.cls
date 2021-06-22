@IsTest
public with sharing class DirectumWebServiceTest {

    @TestSetup
    public static void initCustomSettings() {
        insert new GATEWAY__c(
                Name = 'directumCredentials',
                CLIENT_ID__c = '005056bd4e10',
                CLIENT_SECRET__c = '628c49df',
                URL__c = 'https://api.eu-de.apiconnect.appdomain.cloud'
        );
    }

    @IsTest
    public static void sendPostRequestTest() {
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', '', null));

        Test.startTest();
        DirectumContractRequestBody body = new DirectumContractRequestBody();
        DirectumWebService data = new DirectumWebService();
        HttpResponse result = data.sendPostRequest(GATEWAY__c.getValues('directumCredentials').URL__c, JSON.serialize(body));
        Test.stopTest();

        String actualValue = result.getBody();

        System.assertNotEquals(null, actualValue);
        System.assertEquals(200, result.getStatusCode());
    }

    @IsTest
    public static void createContract200() {

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', '', null));
        Boolean hasException = false;
        try {
            DirectumWebService service = new DirectumWebService();
            Test.startTest();
            service.createContract(new DirectumContractRequestBody());
            Test.stopTest();
        } catch (Exception e) {
            hasException = true;
        }
        System.assertEquals(false, hasException);
    }

    @IsTest
    public static void createContractErrorTest() {

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(400, 'Complete', '', null));

        try {
            Test.startTest();
            DirectumContractRequestBody body = new DirectumContractRequestBody();
            DirectumWebService data = new DirectumWebService();
            data.createContract(body);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Status code - 400.'));
            System.assertEquals('HttpResponseException', e.getTypeName());
        }
    }
}