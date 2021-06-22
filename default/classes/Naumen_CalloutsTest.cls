@IsTest
public with sharing class Naumen_CalloutsTest {
    @TestSetup
    private static void testSetup(){
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Naumen_Settings__c naumenSettings = new Naumen_Settings__c();
        naumenSettings.Admin_Emails__c = 'test@test.ru';
        naumenSettings.Supervisor_Emails__c = 'test1@test.ru';
        naumenSettings.UploadResultsRecievers_Emails__c = 'test2@test.ru';
        naumenSettings.REST_Passw__c = 'testpassw';
        naumenSettings.REST_URL__c = 'https://test.ru';
        naumenSettings.REST_Username__c = 'testusername';
        insert naumenSettings;
// ---- create lead data----
        Lead lead0 = new Lead(
            LastName = 'test 0',
            Source_of_Lead__c = 'E2E Form RU',
            Country = 'Russia',
            Company = 'test acc',
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
            Phone = '+79291111111',
            MobilePhone = '+79292222222',
            ppr_contact_phone__c = '+79293333333',
            Additional_Phones__c = '+70932093208!New!!2307202304.+79320749387!New!!2307202305'
        );
        Lead lead1 = new Lead(
                LastName = 'test 1',
                Source_of_Lead__c = 'E2E Form RU',
                Country = 'Russia',
                Company = 'test acc',
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(),
                Phone = '+79291111111',
                MobilePhone = '+79292222222',
                ppr_contact_phone__c = '+79293333333',
                Additional_Phones__c = '+70932093208!New!!2307202304.+79320749387!New!!2307202305',
                Naumen_Autocall_Project_UUID__c = 'corebo00000000000mtu5ka4v3jcrj6c',
                Naumen_Autocall_Case_UUID__c = 'hdh6786aadhkjadhksd7s78'
        );
        insert new List <Lead> {lead0, lead1};

// ---- create opportunity data----
        Account newAccount = new Account(
                Name = 'test1',
                BillingCountry = 'Russia');
        insert newAccount;

        Opportunity newOpp = new Opportunity(
                StageName = 'Qualify',
                Name = 'test opp1',
                CloseDate = Date.today(),
                AccountId = newAccount.Id);
        insert newOpp;

        Contact conWithOppRole = new Contact(
                FirstName = 'Test2',
                LastName = 'Testov',
                Email = 'test@example.com',
                Phone = '+75554445551',
                AccountId = newAccount.Id);


        Contact con = new Contact(
                FirstName = 'Test1',
                LastName = 'Testov',
                Email = 'test@example.com',
                Phone = '+75554445552',
                AccountId = newAccount.Id);

        insert new List <Contact> {conWithOppRole, con};

        OpportunityContactRole testRole = new OpportunityContactRole(
                ContactId = conWithOppRole.Id,
                OpportunityId = newOpp.Id,
                isPrimary = true);
        insert testRole;
    }
    
    @isTest
    private static void test_sendrequest_createCasesList_leads(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                             phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                             from Lead where LastName = 'test 0' limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendrequest_createCasesList (projectUUID, leads);
        Test.stopTest();

        Lead updatedRecord = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Status from Lead where LastName = 'test 0' limit 1][0];
        
        System.assertEquals(projectUUID, updatedRecord.Naumen_Autocall_Project_UUID__c);
        System.assertEquals(resultCaseUUID, updatedRecord.Naumen_Autocall_Case_UUID__c);
        System.assertEquals('Prequal', updatedRecord.Status);
    }
    @isTest
    private static void test_sendrequest_createCasesList_opps(){
        List <Opportunity> opps = [select id, ContactId, AccountId, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, Account.Name, Account.Region__c 
                                   from Opportunity limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendrequest_createCasesList (projectUUID, opps);
        Test.stopTest();

        Opportunity updatedRecord = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, StageName from Opportunity limit 1][0];
        
        System.assertEquals(projectUUID, updatedRecord.Naumen_Autocall_Project_UUID__c);
        System.assertEquals(resultCaseUUID, updatedRecord.Naumen_Autocall_Case_UUID__c);
        System.assertEquals('Prequal', updatedRecord.StageName);
    }
    @isTest
    private static void test_sendrequest_updateCasesList(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c 
                            from lead where LastName = 'test 0' limit 1];
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendrequest_updateCasesList (leads);
        Test.stopTest();
    }
    /* not used now (was used in upload records script before)
    * this method updates Call Cases list in Naumen setting call on certain scheduled time
    @isTest
    private static void test_sendrequest_updateCasesList_setAdjourned(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                            from lead where LastName = 'test 0' limit 1];
        DateTime scheduledTime = system.now().addMinutes(20);
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendrequest_updateCasesList_setAdjourned (leads, scheduledTime);
        Test.stopTest();
    }
    */
    @isTest
    private static void test_sendrequest_updateCasesList_setFinished_NotDone(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                            from lead where LastName = 'test 0' limit 1];
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendrequest_updateCasesList_setFinished_NotDone (leads);
        Test.stopTest();
    }
    /* not used for now
    @isTest
    private static void test_sendRequest_updateCase(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c 
                            from lead where LastName = 'test 0' limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendrequest_updateCase (projectUUID, leads[0]);
        Test.stopTest();
    }
    */
    @isTest
    private static void test_sendRequest_setCallbackToOperator(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                            from lead limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        String caseUUID = leads[0].Naumen_Autocall_Case_UUID__c;
        DateTime scheduledTime = system.now().addMinutes(20);
        Boolean setCallBackToQueue = false;
        String currentCallPhoneNumber = '+79898978001';
        String callBackPhone = '+79898978867';
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Map <String, String> callFormMap = new Map <String, String> {
            'answer' => 'да',
            'clanswer' => 'Обработан успешно',
            'meet' => 'да',
            'ext' => 'КП'
        };
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendRequest_setCallbackToOperator (leads[0].Id, projectUUID, caseUUID, 
                                                               currentCallPhoneNumber, currentCallPhoneNumber, callBackPhone, scheduledTime, setCallBackToQueue, 
                                                               callFormMap);
        Test.stopTest();
    }
    @isTest
    private static void test_sendRequest_setCallbackToOperator_returnToAutocall(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company,
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                            from lead limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        String caseUUID = leads[0].Naumen_Autocall_Case_UUID__c;
        DateTime scheduledTime = system.now().addMinutes(20);
        Boolean setCallBackToQueue = false;
        String currentCallPhoneNumber = '+79898978001';
        String callBackPhone = null;
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Map <String, String> callFormMap = new Map <String, String> {
            'answer' => 'да',
            'clanswer' => 'Обработан успешно',
            'meet' => 'да',
            'ext' => 'КП'
        };
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendRequest_setCallbackToOperator (leads[0].Id, projectUUID, caseUUID, 
                                                              currentCallPhoneNumber, currentCallPhoneNumber, callBackPhone, scheduledTime, setCallBackToQueue,
                                                              callFormMap);
        Test.stopTest();
    }
    @isTest
    private static void test_sendRequest_setCallFormFields(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company, 
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                            from lead limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        String caseUUID = leads[0].Naumen_Autocall_Case_UUID__c;
        DateTime scheduledTime = system.now().addMinutes(20);
        Boolean setCallBackToQueue = false;
        String currentCallPhoneNumber = '+79898978001';
        String callBackPhone = null;
        String resultCaseUUID = 'ocpcas00000000000n7iar4b75sm4v7o';
        Map <String, String> callFormMap = new Map <String, String> {
            'answer' => 'да',
            'clanswer' => 'Обработан успешно',
            'meet' => 'да',
            'ext' => 'КП'
        };
        Boolean isNaumenCaseFinished = true;
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"result":[{"code":"SUCCESS","value":"' + resultCaseUUID + '"}]}', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendRequest_setCallFormFields (leads[0].Id, projectUUID, caseUUID,
                                                           callFormMap, isNaumenCaseFinished);
            Test.stopTest();
    }
    /* not used now
    @isTest
    private static void test_sendRequest_deleteCase(){
        List <Lead> leads = [select id, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c, Name, FirstName, LastName, Company, 
                            phone, phone_status__c, mobilephone, mobilephone_status__c,  ppr_contact_phone__c, ppr_contact_phone_status__c, Additional_Phones__c, Irrelevant_Phones__c, Region__c
                            from lead limit 1];
        String projectUUID = 'corebo00000000000mtu5ka4v3jcrj6c';
        Test.startTest();
            SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '', null);
            Test.setMock(HttpCalloutMock.class, casesResultMock);
            Naumen_Callouts.sendRequest_deleteCase (projectUUID, leads[0].Id);
        Test.stopTest();
    }
    */
    @isTest
    private static void test_sendrequest_getCallCase() {
        String caseUUID = 'ocpcas00000000000n6d00h07h6a6j5k';
        String sfId = '0061j000009lo1xAAA';
        Test.startTest();
        SingleRequestMock casesResultMock = new SingleRequestMock(200, null, '{"uuid":{"value":"' + caseUUID + '"},"id":"' + sfId + '","title":"ЗАО ВЕЛ","parent":{"uuid":{"value":"corebo00000000000mtu5ka4v3jcrj6c"},"title":"Тестирование SF - Naumen"},"creationDate":"2020-07-27T19:42:39+03:00","completionDate":"2020-07-30T18:46:56+03:00","lastModified":"2020-07-30T18:46:56+03:00","state":{"id":"new","title":"Новое"},"priority":1,"phoneNumbers":{"phoneNumber":[]},"callForm":{"group":[{"id":"group001","title":"Форма №1"},{"id":"group002","title":"Форма №2"},{"id":"group003","title":"Форма №3"}],"attribute":[{"id":"selectmanager","title":"Менеджер","group":"group001"},{"id":"jump","title":"Далее","group":"group001"},{"id":"datetime","title":"Дата и время","group":"group001"},{"id":"email2","title":"Адрес электронной почты","group":"group001"},{"id":"plnabuy","title":"Характер автопарка","group":"group001"},{"id":"ext","title":"Тип встречи","group":"group001"},{"id":"autoparksort","title":"Тип автопарка","group":"group001"},{"id":"meet","title":"Выбрать","group":"group001"},{"id":"view_fuel","title":"Виды топлива","group":"group001"},{"id":"clanswer","title":"Выбрать нужный статус","group":"group001"},{"id":"answer","title":"Ответ абонента","group":"group001"},{"id":"is_callback","title":"Назначен перезвон","group":"group001","value":[{"value":"false"}]},{"id":"meet","title":"Статус звонка","group":"group002"},{"id":"datetime","title":"Дата и время","group":"group002"},{"id":"ext","title":"Тип встречи","group":"group002"},{"id":"manager","title":"Менеджер","group":"group002"},{"id":"called","title":"called","group":"group002"},{"id":"autoparksort","title":"Тип автопарка","group":"group002"},{"id":"surname3","title":"Характер автопарка","group":"group002"}]}}', null);
        Test.setMock(HttpCalloutMock.class, casesResultMock);
        Naumen_Callouts.CallCase res = Naumen_Callouts.sendrequest_getCallCase(caseUUID);
        System.assertEquals(sfId, res.id);
        Test.stopTest();
    }
    @isTest
    private static void test_sendRequest_GET(){
        String caseUUID = 'ocpcas00000000000n6d00h07h6a6j5k';
        Test.startTest();
        Naumen_Callouts.sendRequest_GET ('callcases/' + caseUUID);
        Test.stopTest();
    }
}