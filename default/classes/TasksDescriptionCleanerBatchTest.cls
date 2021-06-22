@isTest
public with sharing class TasksDescriptionCleanerBatchTest {
    @isTest
    public static void testTaskBatch() {
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        Task testTask1 = new Task(Description = '| +7 (800) 555 35 35 | test@te.st | 1234567890 |', 
                                  Status = 'In Progress', 
                                  ActivityDate = Date.today() - 20,
                                  RecordTypeId = recordTypeId);
        insert testTask1;
        Task testTask2 = new Task(Status = 'In Progress', 
                                  ActivityDate = Date.today() - 20,
                                  RecordTypeId = recordTypeId);
        insert testTask2;

        Test.startTest();
        Database.executeBatch(new TasksDescriptionCleanerBatch());
        Test.stopTest();

        testTask1 = [SELECT Id, Description FROM Task WHERE Id = :testTask1.Id];
        System.assertEquals('| X|X| X|', testTask1.Description);
    }

    @isTest
    public static void testRecurrenceTaskBatch() {
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        Task testTask1 = new Task(Description = '| +7 (800) 555 35 35 | test@te.st | 1234567890 |', 
                                  Status = 'In Progress', 
                                  isRecurrence = true,
                                  RecurrenceStartDateOnly = System.today(),
                                  RecurrenceInterval = 1,
                                  RecurrenceEndDateOnly =  System.today().addMonths(1),
                                  RecurrenceType = 'RecursDaily',
                                  RecordTypeId = recordTypeId);
        insert testTask1;

        Test.startTest();
        Database.executeBatch(new TasksRecurrenceDescriptionCleanerBatch(), 1);
        Test.stopTest();

        testTask1 = [SELECT Id, Description FROM Task WHERE Id = :testTask1.Id];
        System.assertEquals('| X|X| X|', testTask1.Description);
    }
}