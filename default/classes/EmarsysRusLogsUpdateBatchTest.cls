@isTest
private class EmarsysRusLogsUpdateBatchTest {
    /*******************************************************************************
	*  Name            : updateEmarsysRusLogsTest()
	*  Summary         : test update Emarsys Body field from Emarsys response
	*  CreatedDate     : 20/10/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @isTest
    static void updateEmarsysLogsTest() {
        List<RecordType> recordTypeList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Lead'
                LIMIT 1
        ];

        Lead lead = new Lead(
                LastName = 'Test Emarsys Logs Update',
                Company = 'Test Emarsys',
                Country = 'Russia',
                Email = 'test@test.com',
                RecordTypeId = recordTypeList.get(0).Id);
        insert lead;

        Emarsys_Log__c log = new Emarsys_Log__c(
                Email_Name__c = 'Кейс №1',
                Email_Id__c = '297202',
                Lead__c = lead.Id,
                Business_Type__c = 'RU'
        );
        insert log;

        Test.startTest();
            Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            EmarsysRusLogsUpdateBatch logsUpdateBatch = new EmarsysRusLogsUpdateBatch();
            Database.executeBatch(logsUpdateBatch);
        Test.stopTest();

        Emarsys_Log__c testLeadLog = [
                SELECT Is_Email_Body_Updated__c, Email_Body__c
                FROM Emarsys_Log__c
                LIMIT 1];
        System.assertEquals(true, testLeadLog.Is_Email_Body_Updated__c);
        System.assertEquals('testBody', testLeadLog.Email_Body__c);
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        SingleRequestMock getLaunchedEmailCampaignUrlResponse = new SingleRequestMock(
                0, 'OK',
                '{"replyCode":0,"replyText":"OK","data":{"url":"https://api.emarsys.net/u/gm.php?prm=i5txRheNRF_765355226_297202_1"}}',
                headers);

        SingleRequestMock getEmailTemplateResponse = new SingleRequestMock(
                0, 'OK',
                '<html><head></head><body style="visibility: visible;">testBody</body></html>',
                headers);

        // Collect multiple responses
        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put('https://api.emarsys.net/api/v2/email/297202/url', getLaunchedEmailCampaignUrlResponse);
        responses.put('https://api.emarsys.net/u/gm.php?prm=i5txRheNRF_765355226_297202_1', getEmailTemplateResponse);

        return responses;
    }
}