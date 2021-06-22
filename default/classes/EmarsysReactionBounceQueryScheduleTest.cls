/**
 * Created by Nikita.Dayanov on 01.11.2018.
 */
@IsTest
private class EmarsysReactionBounceQueryScheduleTest {

    @IsTest
    static void launchScheduleTest() {

        Opportunity newOppty = new Opportunity(
                Name = 'AMBULANTER PFLEGEDIENST VITTAVIS GMBH',
                CloseDate = Date.newInstance(2018, 10, 15),
                StageName = 'Prospecting',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Fax',
                LeadSource = 'E2E Form',
                Emarsys_Contact_Id__c = '6656749'

        );
//        insert newOppty;

        Emarsys_Log__c logEmarsys1 = new Emarsys_Log__c(
                Type__c='Received',
                Email_Id__c='1107396',
                Opportunity__c = newOppty.Id,
                Business_Type__c = 'Germany'
        );
//        insert logEmarsys1;

        Test.startTest();
        // Launch Multi Mock test//
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        EmarsysReactionBounceQuerySchedule logsTypeSchedule = new EmarsysReactionBounceQuerySchedule();
        String sch = '0 0 23 * * ?';
        System.schedule('Emarsys Emails Update Reaction', sch, logsTypeSchedule);

        Test.stopTest();
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock setResponseForTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"id":123712}}',
                headers);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put('https://api.emarsys.net/api/v2/email/responses', setResponseForTypeClick);
        return responses;
    }
}