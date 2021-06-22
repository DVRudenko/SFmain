@IsTest private class EmarsysTypeReactionScheduleTest {

    @isTest
    static void launchScheduleTest() {

        List<RecordType> recordTypeLead = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND SobjectType = 'Lead'
                LIMIT 1
        ];

        Lead newlead = new Lead(
                LastName = 'Test Emarsys Lead',
                Company = 'Test Emarsys',
                Phone = '+72222223322',
                Emarsys_Contact_Id__c = '371354459',
                Country = 'Russia',
                CountryCode = 'RU',
                RecordTypeId = recordTypeLead.get(0).Id
        );
        insert newlead;

        Emarsys_Log__c logEmarsys1 = new Emarsys_Log__c(
                Type__c='Reaction Open or Click',
                email_id__c='384809',
                query_id__c='123712',
                Lead__c = newlead.id
        );
        insert logEmarsys1;

        Test.startTest();
        // Launch Multi Mock test
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        EmarsysTypeReactionSchedule logsTypeSchedule = new EmarsysTypeReactionSchedule();
        String sch = '0 0 23 * * ?';
        System.schedule('Emarsys Update Type', sch, logsTypeSchedule);

        Test.stopTest();
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock setResponseForTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"id":123712}}',
                headers);
        SingleRequestMock getResponseWithTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"contact_ids":["795275007","998081794","997043366"]}}',
                headers);
        // Collect multiple responses
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put('https://api.emarsys.net/api/v2/email/responses', setResponseForTypeClick);
        responses.put('https://api.emarsys.net/api/v2/email/123712/responses', getResponseWithTypeClick);

        return responses;
    }
}