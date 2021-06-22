@IsTest
public class Naumen_UploadRecordsBatchTest {
    @testSetup
    private static void setupData() {
        Naumen_Settings__c naumenSettings = new Naumen_Settings__c();
        naumenSettings.Admin_Emails__c = 'test@test.ru';
        naumenSettings.Supervisor_Emails__c = 'test1@test.ru';
        naumenSettings.UploadResultsRecievers_Emails__c = 'test2@test.ru';
        naumenSettings.REST_Passw__c = 'testpassw';
        naumenSettings.REST_URL__c = 'https://test.ru';
        naumenSettings.REST_Username__c = 'testusername';
        insert naumenSettings;

        Id leadRTIdRu = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        Lead newLead = new Lead(
            RecordTypeId = leadRTIdRu,
            FirstName = 'test name',
            LastName = 'l',
            Description = 'text 1.',
            Country = 'Russia',
            CountryCode = 'RU',
            Company = 'TestCompany',
            Phone = '+78887770000'
        );
        insert newLead;
    }
    @IsTest
    private static void testBatch_CheckRecordsAccess() {
        Test.startTest();
        List <String> queryFields = Naumen_SupervisorPanelCtrl.getFieldsToQueryRecord (Schema.Lead.sObjectType); 
        String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM Lead';
        String projectUUID = '11111';
        DateTime scheduledTime = system.now().addDays(1);
        Naumen_UploadRecordsBatch batch = new Naumen_UploadRecordsBatch ('Lead', query, true, projectUUID);
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    @IsTest
    private static void testBatch_DontCheckRecordsAccess() {
        Test.startTest();
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
        Test.setMock(HttpCalloutMock.class, casesResultMock);
        List <String> queryFields = Naumen_SupervisorPanelCtrl.getFieldsToQueryRecord (Schema.Lead.sObjectType); 
        String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM Lead';
        String projectUUID = '11111';
        DateTime scheduledTime = system.now().addDays(1);
        system.debug(Database.query(query));
        Naumen_UploadRecordsBatch batch = new Naumen_UploadRecordsBatch ('Lead', query, false, projectUUID);
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}