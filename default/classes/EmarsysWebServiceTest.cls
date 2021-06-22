@isTest
public with sharing class EmarsysWebServiceTest {
    @IsTest
    private static void testGenerateContactListRequest() {
        String endPoint = 'https://api.emarsys.net/api/v2/contactlist/12345/?offset=0&limit=1000000',
            emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());

        Test.startTest();
        HttpRequest createdRequest = EmarsysWebService.generateContactListRequest(endPoint, emarsysAccount);
        Test.stopTest();

        System.assertEquals('application/json', createdRequest.getHeader('Content-Type'));
        System.assertEquals('GET', createdRequest.getMethod());
        System.assertEquals(endPoint, createdRequest.getEndpoint());
    }

    @IsTest
    private static void testGetContactList() {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name()), 
            firstContactListId = '12345', 
            secondContactListId = '23456',
            firstResponseBody,
            secondResponseBody;

        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        firstResponseBody = EmarsysWebService.getContactList(firstContactListId, emarsysAccount);
        secondResponseBody = EmarsysWebService.getContactList(secondContactListId, emarsysAccount);
        Test.stopTest();

        System.assert(firstResponseBody.contains('"replyCode": 0'));
        System.assert(!secondResponseBody.contains('"replyCode": 0'));
        EmarsysListingContactsEntity emarsysResponse = (EmarsysListingContactsEntity) JSON.deserialize(firstResponseBody, EmarsysListingContactsEntity.class);
        System.assertEquals('OK', emarsysResponse.replyText);
        System.assertEquals(0, emarsysResponse.replyCode);
        System.assertEquals(3, emarsysResponse.data.size());
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock contactListResponse = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode": 0, "replyText": "OK", "data": ["385885793", "393615693", "371354459"]}',
                headers);
        SingleRequestMock contactListErrorResponse = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode": 404, "replyText": "error", "data": []}',
                headers);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put('https://api.emarsys.net/api/v2/contactlist/12345/?offset=0&limit=1000000', contactListResponse);
        responses.put('https://api.emarsys.net/api/v2/contactlist/23456/?offset=0&limit=1000000', contactListErrorResponse);

        return responses;
    }
}