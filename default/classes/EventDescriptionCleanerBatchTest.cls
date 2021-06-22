@isTest
public with sharing class EventDescriptionCleanerBatchTest {
    @isTest
    public static void testEventBatch() {
        Id recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Russian_Sales_Event').getRecordTypeId();
        Event testEvent1 = new Event(DurationInMinutes = 10, 
                                     ActivityDateTime = Datetime.now() - 20, 
                                     Description = '| +7 (800) 555 35 35 | test@te.st | 1234567890 |', 
                                     Event_Status__c = 'In Progress',
                                     RecordTypeId = recordTypeId);
        insert testEvent1;
        Event testEvent2 = new Event(DurationInMinutes = 10, 
                                     ActivityDateTime = Datetime.now() - 20, 
                                     Event_Status__c = 'In Progress',
                                     RecordTypeId = recordTypeId);
        insert testEvent2;

        Test.startTest();
        Database.executeBatch(new EventDescriptionCleanerBatch());
        Test.stopTest();

        testEvent1 = [SELECT Id, Description FROM Event WHERE Id = :testEvent1.Id];
        System.assertEquals('| X|X| X|', testEvent1.Description);
    }
}