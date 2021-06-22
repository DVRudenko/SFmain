@isTest
public class TaskControllerTest {

    @isTest
    public static void testCreateRelatedCase() {
        Task testTask = new Task(
            RecordTypeId = GlobalUtils.returnRecordTypeId('Task', 'Call'),
            Phone__c = '123',
            Topic__c = 'My Card(s)',
            Sub_topic__c = '+/-'
        );
        insert testTask;

        Id caseId = TaskController.createRelatedCase(testTask.Id);

        System.assert(String.isNotEmpty(caseId));

        Case newCase = [
            SELECT  Phone_Number__c,
                    Topic__c,
                    Sub_topic__c
            FROM    Case
            WHERE   Id =: caseId
        ];

        System.assertEquals('123', newCase.Phone_Number__c);
        System.assertEquals('My Card(s)', newCase.Topic__c);
        System.assertEquals('+/-', newCase.Sub_topic__c);
    }
}
