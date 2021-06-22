/**
 * Created by Nikita.Dayanov on 19.10.2018.
 */
@IsTest
private class EmarsysReactionQueryIdGetterTest {

    @IsTest
    static void queryForOpenedRequestCase() {

        Opportunity newOppty = new Opportunity(
                Name = 'AMBULANTER PFLEGEDIENST VITTAVIS GMBH',
                CloseDate = Date.newInstance(2018, 10, 15),
                StageName = 'Prospecting',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Fax',
                LeadSource = 'E2E Form',
                Emarsys_Contact_Id__c = '6656749'
        );
        insert newOppty;

        Emarsys_Log__c log = new Emarsys_Log__c(
                Type__c = null,
                Email_Id__c = '1107396',
                Opportunity__c = newOppty.Id,
                Business_Type__c = 'DE'
        );
        insert log;

        Test.startTest();

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock setResponseForTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"id":123712}}',
                headers);
        Test.setMock(HttpCalloutMock.class, setResponseForTypeClick);
        Database.BatchableContext bc;
        EmarsysReactionQueryIdGetter batch = new EmarsysReactionQueryIdGetter();

        List<Emarsys_Log__c> aScopeList = new List<Emarsys_Log__c> ();
        DataBase.QueryLocatorIterator locator = batch.start(bc).iterator();
        while (locator.hasNext()) {
            aScopeList.add((Emarsys_Log__c) locator.next());
        }
        batch.execute(bc, aScopeList);
        batch.finish(bc);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Opportunity__c = :newOppty.Id
                AND Email_Id__c = '1107396' AND Business_Type__c = 'DE'
                AND Query_Id__c = '123712'
        ];
        System.assertEquals(1, testLog.size());
    }

    @IsTest
    static void queryForClickedRequestCase() {

        Opportunity newOppty = new Opportunity(
                Name = 'AMBULANTER PFLEGEDIENST VITTAVIS GMBH',
                CloseDate = Date.newInstance(2018, 10, 15),
                StageName = 'Prospecting',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Fax',
                LeadSource = 'E2E Form',
                Emarsys_Contact_Id__c = '6656749'
        );
        insert newOppty;

        Emarsys_Log__c log = new Emarsys_Log__c(
                Type__c = 'Opened',
                Email_Id__c = '1107396',
                Opportunity__c = newOppty.Id,
                Business_Type__c = 'DE'
        );
        insert log;

        Test.startTest();

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock setResponseForTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"id":123712}}',
                headers);
        Test.setMock(HttpCalloutMock.class, setResponseForTypeClick);
        Database.BatchableContext bc;
        EmarsysReactionQueryIdGetter batch = new EmarsysReactionQueryIdGetter();

        List<Emarsys_Log__c> aScopeList = new List<Emarsys_Log__c> ();
        DataBase.QueryLocatorIterator locator = batch.start(bc).iterator();
        while (locator.hasNext()) {
            aScopeList.add((Emarsys_Log__c) locator.next());
        }
        batch.execute(bc, aScopeList);
        batch.finish(bc);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Opportunity__c = :newOppty.Id
                AND Email_Id__c = '1107396'
                AND Business_Type__c = 'DE'
                AND Query_Id__c = '123712'
        ];
        System.assertEquals(1, testLog.size());
    }

    @IsTest
    static void noLogsInDBCase() {

        Test.startTest();

        Database.BatchableContext bc;
        EmarsysReactionQueryIdGetter batch = new EmarsysReactionQueryIdGetter();
        List<Emarsys_Log__c> aScopeList = new List<Emarsys_Log__c> ();
        DataBase.QueryLocatorIterator locator = batch.start(bc).iterator();
        while (locator.hasNext()) {
            aScopeList.add((Emarsys_Log__c) locator.next());
        }
        batch.execute(bc, aScopeList);
        batch.finish(bc);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
        ];
        System.assertEquals(0, testLog.size());
    }

}