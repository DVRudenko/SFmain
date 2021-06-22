@IsTest
public with sharing class PPR_API_LogService_Test {

    @IsTest
    public static void createLogTest() {
        try {
            String s;
            s.contains('ds');
        } catch (Exception e) {
            Custom_log__c log = PPR_API_LogService.createLog('1234567890', 'test', e);
            log = ([
                    SELECT Id
                    FROM Custom_log__c
                    WHERE Id = :log.Id
                    LIMIT 1
            ]);
        }
    }

    @IsTest
    public static void testCreatingLog() {
        E2EFormData__c testFormData = new E2EFormData__c();
        insert testFormData;
        E2EFormParams formparams = new E2EFormParams();
        formparams.formDataId = testFormData.Id;
        formparams.errors = 'error text';
        formparams.externalUser = 'externalUser';
        formparams.companyInn = '1234567890';
        formparams.source = 'test source';
        
        Test.startTest();
        Custom_log__c testLog = PPR_API_LogService.createLog(formparams);
        Test.stopTest();

        List<Custom_log__c> logs = [SELECT id, Name, Errors__c, External_user__c, INN__c, E2E_Form_Ru_Data__c, Source__c FROM Custom_log__c WHERE id = :testLog.Id];
        System.assertEquals(1, logs.size());
        System.assertEquals(testFormData.Id, logs[0].E2E_Form_Ru_Data__c);
        System.assertEquals(testLog.E2E_Form_Ru_Data__c, logs[0].E2E_Form_Ru_Data__c);
    }

    @IsTest
    public static void testUpdatingLog() {
        E2EFormData__c testFormData = new E2EFormData__c();
        insert testFormData;
        E2EFormParams formparams = new E2EFormParams();
        formparams.formDataId = testFormData.Id;
        formparams.errors = 'error text';
        formparams.externalUser = 'externalUser';
        formparams.companyInn = '1234567890';
        formparams.source = 'test source';
        Custom_log__c testLog = PPR_API_LogService.createLog(formparams);
        
        Test.startTest();
        formparams.formDataId = null;
        formparams.errors = 'new error text';
        formparams.externalUser = null;
        formparams.source = null;
        PPR_API_LogService.updateLog(testLog.Id, formparams);
        Test.stopTest();

        List<Custom_log__c> logs = [SELECT id, Name, Errors__c, External_user__c, INN__c, E2E_Form_Ru_Data__c, Source__c FROM Custom_log__c WHERE id = :testLog.Id];
        System.assertEquals(1, logs.size());
        System.assertNotEquals(testLog.Errors__c, logs[0].Errors__c);
        System.assertEquals(testLog.External_user__c, logs[0].External_user__c);
        System.assertEquals(testLog.INN__c, logs[0].INN__c);
    }

    @IsTest
    public static void testGetLogByInnAndSource() {
        E2EFormData__c testFormData = new E2EFormData__c();
        insert testFormData;
        E2EFormParams formparams = new E2EFormParams();
        formparams.formDataId = testFormData.Id;
        formparams.errors = 'error text';
        formparams.externalUser = 'externalUser';
        formparams.companyInn = '1234567890';
        formparams.source = 'test source';
        Custom_log__c testLog = PPR_API_LogService.createLog(formparams);
        
        Test.startTest();
        Custom_log__c firstLog = PPR_API_LogService.getLogByInnAndSource('1234567890', 'test source');
        Custom_log__c secondLog = PPR_API_LogService.getLogByInnAndSource('not inn', 'test source');
        Custom_log__c thirdLog = PPR_API_LogService.getLogByInnAndSource('1234567890', 'not source');
        Test.stopTest();

        System.assertNotEquals(null, firstLog);
        System.assertEquals(testLog.External_user__c, firstLog.External_user__c);
        System.assertEquals(null, secondLog);
        System.assertEquals(null, thirdLog);
    }

    @IsTest
    public static void testUpdateLog() {
        E2EFormData__c testFormData = new E2EFormData__c();
        insert testFormData;
        Custom_log__c log = PPR_API_DataTestFactory.createCustomLog(testFormData.Id, '123456789012');
        insert log;

        E2EFormParams formparams = new E2EFormParams();
        formparams.formDataId = testFormData.Id;
        formparams.errors = 'test error';
        formparams.externalUser = 'external id';
        formparams.companyInn = '123456789012';
        formparams.source = 'source';

        PPR_API_LogService.updateLog(log.Id, formparams);

        Custom_log__c updatedLog = [
            SELECT E2E_Form_Ru_Data__c, Errors__c, External_user__c, INN__c, Source__c 
            FROM Custom_log__c 
            WHERE id =: log.Id
        ];

       System.assertEquals(testFormData.Id, updatedLog.E2E_Form_Ru_Data__c);
       System.assertEquals('test error', updatedLog.Errors__c);
       System.assertEquals('external id', updatedLog.External_user__c);
       System.assertEquals('123456789012', updatedLog.INN__c);
       System.assertEquals('source', updatedLog.Source__c);
    }
}