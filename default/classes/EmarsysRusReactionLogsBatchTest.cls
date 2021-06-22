@isTest
private class EmarsysRusReactionLogsBatchTest {

    private static final String USER_ID = UserInfo.getUserId();

    /*******************************************************************************
    *  Name            : creatingLeadLogsTest()
    *  Summary         : test creating Emarsys Russian logs
    *  CreatedDate     : 13/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void creatingLeadLogsTest() {
        List<RecordType> recordTypeList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Lead'
                LIMIT 1
        ];

        User user = [
                SELECT id
                FROM User
                WHERE IsActive = true AND Profile.Name IN ('API Only', 'System Administrator')
                LIMIT 1
        ];

        Lead lead = new Lead(
                LastName = 'Test Emarsys Lead',
                Company = 'Test Emarsys',
                Phone = '+79992223322',
                OwnerId = user.Id,
                Emarsys_Contact_Id__c = '371354459',
                Country = 'Russia',
                CountryCode = 'RU',
                RecordTypeId = recordTypeList.get(0).Id
        );
        insert lead;

        Emarsys_Contact_Subscriptions__c contactSubscriptions = new Emarsys_Contact_Subscriptions__c(
                Name = 'LeadSegment1',
                Segment_Id__c = '17564',
                Subscription_Name__c = 'Кейс №1: Не проданы карты, не устроила цена. Промо',
                Email_Name__c = 'Боевое Промо. Кейс №1',
                Last_Update_Segment_Date__c = Datetime.now().addDays(-10),
                Type__c = 'Lead'
        );
        insert contactSubscriptions;


        // Test Emarsys contact validation
        Lead leadWithContact = [
                SELECT Emarsys_Contact_Id__c
                FROM Lead
                WHERE Name = 'Test Emarsys Lead'
                LIMIT 1
        ];

        Test.startTest();
        // Launch Multi Mock test
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Launch Batch test
        EmarsysRusReactionLogsBatch leadLogsBatch = new EmarsysRusReactionLogsBatch(
                new List<String>{'385885793', '393615693', '371354459'},
                '17564'
        );
        Database.executeBatch(leadLogsBatch);
        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Lead__c = :lead.Id
        ];
        System.assertEquals(1, testLog.size());
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock getContactHistoryResponse = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":[{"emailId":120302,"contactId":"371354459",' +
                        '"launch_date":"2017-02-15 08:15:00","delivery_status":"launched","bounce_status":"",' +
                        '"launchListId":"1"}]}',
                headers);

        SingleRequestMock updateContactResponse = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"ids":["371354459"]}}',
                headers);

        SingleRequestMock campaignDetailsResponse = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode": 0,"replyText": "OK","data": {"id": "12345","root_campaign_id": "12345",' +
                        '"language": "ru","name": "20170816_0900_Боевое Промо. Кейс №1",' +
                        '"deleted": "","fromemail_host": "emarsys","fromemail": "test@example.com",' +
                        '"fromname": "Test name","subject": "I\'m alive","email_category": "111111111",' +
                        '"filter": "333333333","exclude_filter": 0,"contactlist": "0","exclude_contactlist": 0,' +
                        '"additional_linktracking_parameters": "","cc_list": 564365356,' +
                        '"html_source": "<html>Hello $First Name$...</html>","text_source": "Hello $First Name$...",' +
                        '"template": "0","unsubscribe": "y","browse": "y","status": "3","api_status": "2",' +
                        '"api_error": "0","external_event_id": null,"text_only": "n","source": "api","version_name": "Version A"}}',
                headers);

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
        responses.put('https://api.emarsys.net/api/v2/contact/getcontacthistory', getContactHistoryResponse);
        responses.put('https://api.emarsys.net/api/v2/contact/?create_if_not_exists=1', updateContactResponse);
        responses.put('https://api.emarsys.net/api/v2/email/120302', campaignDetailsResponse);
        responses.put('https://api.emarsys.net/api/v2/email/responses', setResponseForTypeClick);
        responses.put('https://api.emarsys.net/api/v2/email/123712/responses', getResponseWithTypeClick);

        return responses;
    }
}