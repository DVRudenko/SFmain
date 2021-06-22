@isTest
private class EmarsysTypeSetQueryTest {

    @isTest static void launchTest() {
        List<RecordType> recordTypeLead = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND SobjectType = 'Lead'
                LIMIT 1
        ];

        Lead newLead = new Lead(
                LastName = 'Test Emarsys Lead',
                Company = 'Test Emarsys',
                Phone = '+72223322222',
                Emarsys_Contact_Id__c = '371354459',
                Country = 'Russia',
                CountryCode = 'RU',
                RecordTypeId = recordTypeLead.get(0).Id
        );
        insert newLead;

        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());

        Emarsys_Log__c log = new Emarsys_Log__c(
                Type__c = reactionType,
                Email_Id__c = '376422',
                Lead__c = newLead.id,
                Business_Type__c = 'RU'
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

        EmarsysTypeSetQuery batch = new EmarsysTypeSetQuery();
        Database.executeBatch(batch);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Lead__c = :newLead.Id
                AND Business_Type__c = 'RU'
                AND Email_Id__c = '376422'
                AND Query_Id__c = '123712'
        ];
        System.assertEquals(1, testLog.size());
    }

    @isTest static void launchTest2() {
        List<RecordType> recordTypeLead = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND SobjectType = 'Lead'
                LIMIT 1
        ];

        Lead newLead = new Lead(
                LastName = 'Test Emarsys Lead',
                Company = 'Test Emarsys',
                Phone = '+72223322222',
                Emarsys_Contact_Id__c = '371354459',
                Country = 'Russia',
                CountryCode = 'RU',
                RecordTypeId = recordTypeLead.get(0).Id
        );
        insert newLead;

        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());

        Emarsys_Log__c log = new Emarsys_Log__c(
                Type__c = reactionType,
                Email_Id__c = '376422',
                Lead__c = newLead.id,
                Business_Type__c = 'RU'
        );
        insert log;

        Test.startTest();

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock setResponseForTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":6028,"replyText":"Cannot run filters that often","data":""}',
                headers);
        Test.setMock(HttpCalloutMock.class, setResponseForTypeClick);

        EmarsysTypeSetQuery batch = new EmarsysTypeSetQuery();
        Database.executeBatch(batch);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Lead__c = :newLead.Id
                AND Business_Type__c = 'RU'
                AND Email_Id__c = '376422'
                AND Query_Id__c = '123712'
        ];
        System.assertEquals(0, testLog.size());
    }
}