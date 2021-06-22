@IsTest
public with sharing class EESBControllerLightningTest {
    @TestSetup
    public static void initCreateDirectumContractData() {
        insert new GATEWAY__c(
                Name = 'directumCredentials',
                CLIENT_ID__c = '005056bd4e10',
                CLIENT_SECRET__c = '628c49df',
                URL__c = 'https://api.eu-de.apiconnect.appdomain.cloud'
        );
    }

    @IsTest
    public static void testCreateDirectumContract_positive() {

        DirectumContractRequestBody requestBody = new DirectumContractRequestBody();
        requestBody.DocumentKind ='mpd';
        requestBody.BusinessUnit = 'PPR';
        requestBody.Subject = 'Test contract';
        requestBody.Counterparty = 'Софтлайн Трейд|7736227885|770401001|119270, МОСКВА ГОРОД, НАБЕРЕЖНАЯ\n' +
                'ЛУЖНЕЦКАЯ, 2/4, СТР.3А, ОФИС 304|Г МОСКВА,УЛ ГУБКИНА, Д\n' +
                '8|7555555|softline@softline.ru|1027736009333||ОКПО|2782534392520000066';
        requestBody.ResponsibleEmployee='test@test.ru';
        requestBody.RequestID='0063N00000CUobGQAT';
        requestBody.Note='Important notes';

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', '', null));

        Test.startTest();
        Boolean result = EESBControllerLightning.createDirectumContract(requestBody);
        Test.stopTest();

        system.assertEquals(true, result);
    }

    @IsTest
    public static void testCreateDirectumContract_error() {

        DirectumContractRequestBody requestBody = new DirectumContractRequestBody();

        Test.startTest();
        Boolean result = EESBControllerLightning.createDirectumContract(requestBody);
        Test.stopTest();

        system.assertEquals(false, result);
    }

}