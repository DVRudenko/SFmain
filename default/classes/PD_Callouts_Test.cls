@IsTest
public with sharing class PD_Callouts_Test {

    @TestSetup
    static void initTestData() {
        PD_Setting__c sett = new PD_Setting__c(
            URL__c = 'https://df-maxy-aflex.enterprise.dreamfactory.com/api/v2',
            Token__c = 'asdsdfsdfeferwertwer',
            Name = 'testsetting',
            AdminEmails__c = 'test@test.ru',
            IsActive__c = true
        );
        insert sett;
    }

    @IsTest
    private static void testAddIrrelevantNumber() {
        Contact con = createContact();
        insert con;
        
        Test.startTest();
        PD_Callouts.sendReq_saveData(con);
        PD_Callouts.sendErrorEmail('test@test.ry', 'body');
        PD_Callouts.disablePDService ();
        Test.stopTest();
    }

    @IsTest
    private static void testSendSuccessfullRequest() {
        Contact con = createContact();
        insert con;

        String pdId = '539d7263-1bdc-4093-a025-b09c60c6102b';
        String responseBody = '{"status":"ok", "error": null, "result": {"id": "' + pdId + '"}}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));

        Test.startTest();
        PD_Callouts.sendReq_saveData(con);
        Test.stopTest();

        Contact cont = [SELECT PD_ExternalId__c FROM Contact WHERE id =: con.Id];
        
        System.assertEquals(pdId, cont.PD_ExternalId__c);
    }

    @IsTest
    private static void testSendSuccessfullRequestNullIdCont() {
        Contact con = createContact();

        String pdId = '539d7263-1bdc-4093-a025-b09c60c6102b';
        String responseBody = '{"status":"ok", "error": null, "result": {"id": "' + pdId + '"}}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));

        Test.startTest();
        PD_Callouts.sendReq_saveData(con);
        Test.stopTest();
    }

    @IsTest
    private static void testSendSuccessfullRequestNullIdPd() {
        Contact con = createContact();
        insert con;

        String pdId = null;
        String responseBody = '{"status":"ok", "error": null, "result": {"id": ' + pdId + '}}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));

        Test.startTest();
        PD_Callouts.sendReq_saveData(con);
        Test.stopTest();

        Contact cont = [SELECT PD_ExternalId__c FROM Contact WHERE id =: con.Id];

        System.assert(String.isBlank(cont.PD_ExternalId__c));
    }

    @IsTest
    private static void testErrorResponce() {
        Contact con = createContact();
        insert con;

        String responseBody = '{"status":"error", "error": {"code": "InvalidToken","message": "Invalid token"}, "result": null}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));
        
        Test.startTest();
        PD_Callouts.sendReq_saveData(con);
        Test.stopTest();

        System.assertEquals(false, PD_Callouts.pd_settings.IsActive__c);
    }

    private static Contact createContact() {
        return new Contact(
            Salutation = 'Herr',
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7955 622 5334',
            MobilePhone = '+7955 02 55334',
            PD_Avaliable_LastName_Update__c = true
        );
    }
}