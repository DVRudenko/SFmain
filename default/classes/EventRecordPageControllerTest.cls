@isTest
public with sharing class EventRecordPageControllerTest {

    @testSetup
    private static void createTestData() {
        Account testAcc = new Account(
            Name = 'test',
            BillingCountry = 'Germany'
        );

        Account test2Acc = new Account(
            Name = 'test2',
            BillingCountry = 'Austria'
        );
        insert new List<Account>{testAcc, test2Acc};


        DateTime now = DateTime.now();
        Event testEvent = new Event(
            WhatId = testAcc.Id,
            Subject = 'Call',
            Type = 'Call',
            Description = 'test',
            StartDateTime = now,
            ActivityDateTime = now,
            EndDateTime = now.addHours(1),
            DurationInMinutes = 60
        );
        insert testEvent;
    }


    @isTest
    private static void testSearch() {
        List<LookupSearchResult> searchlist = EventRecordPageController.search('2', null, 'Account');
        System.assertEquals(1, searchList.size());
        System.assertEquals('TEST2', searchList[0].getTitle());

        List<LookupSearchResult> caseSearchlist = EventRecordPageController.search('test', null, 'Case');
        System.assertEquals(0, caseSearchlist.size());
    }


    @isTest
    private static void testGetEventData() {
        Account testAcc = [SELECT Id FROM Account WHERE Name = 'test'];
        Event testEvent = [SELECT Id FROM Event WHERE Type = 'Call'];
        
        Event insertedEvent = EventRecordPageController.getEventData(testEvent.Id);

        System.assertEquals('test', insertedEvent.Description);
        System.assertEquals('Call', insertedEvent.Subject);
    }


    @isTest
    private static void testGetSObjectData() {
        Account testAcc = [SELECT Id FROM Account WHERE BillingCountry = 'Germany'];
        Map<String, String> sobjectData = EventRecordPageController.getSObjectData(testAcc.Id);
        System.assertEquals('TEST', sobjectData.get('Name'));
        System.assertEquals('Account', sobjectData.get('SObjectName'));
    }


    @isTest
    private static void testGetPicklistValues() {
        Account testAcc = [SELECT Id FROM Account WHERE BillingCountry = 'Germany'];
        Map<String, Map<String, String>> picklistValues = EventRecordPageController.getPickListValues();
        System.assertNotEquals(0, picklistValues.keySet().size());
        System.assertEquals(picklistValues.get('RelatedTo').get('Account'), 'Account');
        System.assertEquals(picklistValues.get('Name').get('Contact'), 'Contact');
    }
}
