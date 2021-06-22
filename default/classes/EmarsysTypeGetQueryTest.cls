@isTest
private class EmarsysTypeGetQueryTest {

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
                Email_Id__c = '384809',
                Query_Id__c = '123712',
                Lead__c = newLead.id,
                Business_Type__c = 'RU'
        );
        insert log;

        Test.startTest();
        String schedule = datetime.now().addMinutes(1).second() + ' ' + datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?' + ' *' + ' MON-FRI';
        EmarsysTypeReactionSchedule emarsysUpdateType = new EmarsysTypeReactionSchedule();
        System.schedule('EmarsysLog Update Reaction Type ' +
                datetime.now().addMinutes(1).hour() + ':' + datetime.now().addMinutes(1).minute() + ':' + datetime.now().addMinutes(1).second(),
                schedule,
                emarsysUpdateType);

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock getResponseWithTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":0,"replyText":"OK","data":{"contact_ids":["795275007","998081794","371354459"]}}',
                headers);
        Test.setMock(HttpCalloutMock.class, getResponseWithTypeClick);

        EmarsysTypeGetQuery batch = new EmarsysTypeGetQuery();
        Database.executeBatch(batch);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Lead__c = :newLead.Id
                AND Query_Id__c = '123712'
                AND Business_Type__c = 'RU'
                AND Type__c = 'Clicked'
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
                Email_Id__c = '384809',
                Query_Id__c = '123712',
                Lead__c = newLead.id,
                Business_Type__c = 'RU'
        );
        insert log;

        Test.startTest();
        String schedule = datetime.now().addMinutes(1).second() + ' ' + datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?' + ' *' + ' MON-FRI';
        EmarsysTypeReactionSchedule emarsysUpdateType = new EmarsysTypeReactionSchedule();
        System.schedule('EmarsysLog Update Reaction Type ' +
                datetime.now().addMinutes(1).hour() + ':' + datetime.now().addMinutes(1).minute() + ':' + datetime.now().addMinutes(1).second(),
                schedule,
                emarsysUpdateType);

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock getResponseWithTypeClick = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode":6029,"replyText":"There is no job with the provided id","data":""}',
                headers);
        Test.setMock(HttpCalloutMock.class, getResponseWithTypeClick);

        EmarsysTypeGetQuery batch = new EmarsysTypeGetQuery();
        Database.executeBatch(batch);

        Test.stopTest();

        List<Emarsys_Log__c> testLog = [
                SELECT Email_Name__c
                FROM Emarsys_Log__c
                WHERE Lead__c = :newLead.Id
                AND Query_Id__c = '123712'
                AND Business_Type__c = 'RU'
                AND Type__c = 'Clicked'
        ];
        System.assertEquals(0, testLog.size());
    }
}