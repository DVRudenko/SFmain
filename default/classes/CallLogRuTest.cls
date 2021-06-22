@IsTest
public  class CallLogRuTest {

    private static final Id RU_LEAD_RECORD_TYPE = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
    private static final Id RU_OPPORTUNITY_RECORD_TYPE = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
    private static final Id RU_CONTACT_RECORD_TYPE = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();
    private static final Id RU_ACCOUNT_RECORD_TYPE = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();


    @TestSetup
    private static void testSetup(){
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
        Naumen_Settings__c naumenSettings = new Naumen_Settings__c();
        naumenSettings.Admin_Emails__c = 'test@test.ru';
        naumenSettings.Supervisor_Emails__c = 'test1@test.ru';
        naumenSettings.UploadResultsRecievers_Emails__c = 'test2@test.ru';
        naumenSettings.REST_Passw__c = 'testpassw';
        naumenSettings.REST_URL__c = 'https://test.ru';
        naumenSettings.REST_Username__c = 'testusername';
        insert naumenSettings;
    }

    @isTest
    private static void testService_Success_Mixed_1(){
        String leadAdditionalPhone = '+70010010011';
        Lead lead = new Lead(
                LastName = 'test 1',
                Source_of_Lead__c = 'E2E Form RU',
                Country = 'Russia',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+79127193509',
                MobilePhone = '+79852769431',
                MobilePhone_Status__c = 'Dial out',
                PPR_Contact_Phone__c = '+79127193500',
                Additional_Phones__c = '+70010010022!New!0,2!2304202314.' + leadAdditionalPhone + '!New!!2304202336',
                Naumen_Autocall_Project_UUID__c = 'proj001',
                Naumen_Autocall_Case_UUID__c = 'case001',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        insert lead;

        Account account = new Account(Name = 'testt', INN__c = '1234567890', RecordTypeId = RU_ACCOUNT_RECORD_TYPE);
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Qualified Lead',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                RecordTypeId = RU_OPPORTUNITY_RECORD_TYPE,
                Business_process__c = GlobalUtils.BusinessProcessType.Standard.name(),
                Naumen_Autocall_Project_UUID__c = 'proj001',
                Naumen_Autocall_Case_UUID__c = 'case002',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        insert opportunity;

        String contactAdditionalPhone = '+70010010020';
        Contact contact = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '+79999999992',
                MobilePhone = '+79999999993',
                PPR_Contact_Phone__c = '+2 434434 3443#',
                HomePhone = '+12345678901#54',
                AssistantPhone = '+71112221112',
                OtherPhone = '+71112221113',
                Additional_Phones__c = '+12345678899#35!New!0,2!2304202314.+1231232222!New!!0104201015.' + contactAdditionalPhone + '!New!0,8!2304202336'
        );
        insert contact;

        String dtFinished = system.now().addMinutes(-2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        String jsonBody = '{"logs": [' +
                '{"recordId": "'+lead.Id+'","phoneNumber": "'+lead.Phone+'"'+',"finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:21:01.000Z"}, ' +
                '{"recordId": "'+lead.Id+'","phoneNumber": "'+lead.MobilePhone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "not_found","statusDate": "2099-03-13T17:24:01.000Z"}, ' +
                '{"recordId": "'+lead.Id+'","phoneNumber": "'+leadAdditionalPhone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "not_found","statusDate": "2099-03-13T18:24:01.000Z"}, ' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:23:01.000Z"},' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact.MobilePhone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "not_found","statusDate": "2099-03-13T17:20:01.000Z"},' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contactAdditionalPhone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "not_found","statusDate": "2099-03-13T18:20:01.000Z"}' +
                ']}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('token', '123');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();

        List<Lead> testLeads = [
                SELECT Id, Phone, Phone_Status__c, Phone_Rating__c, MobilePhone, MobilePhone_Status__c, MobilePhone_Rating__c, PPR_Contact_Phone__c, 
                       Additional_Phones__c, Irrelevant_Phones__c, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c
                FROM Lead
                WHERE Id = :lead.Id
        ];
        system.assertEquals(lead.Phone, testLeads.get(0).Phone);
        system.assertEquals('Dial out', testLeads.get(0).Phone_Status__c);
        system.assertEquals(0.8, testLeads.get(0).Phone_Rating__c);
        system.assertEquals(lead.MobilePhone, testLeads.get(0).MobilePhone);
        system.assertEquals('CTI Wrong number:0', testLeads.get(0).MobilePhone_Status__c);
        system.assertEquals(0.6, testLeads.get(0).MobilePhone_Rating__c);
        system.assertEquals('+70010010022!New!0,2!2304202314.' + leadAdditionalPhone + '!' + PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation('CTI Wrong number:0') + '!0,8!1303991824',
                            testLeads.get(0).Additional_Phones__c);
        system.assertEquals('Finished', testLeads.get(0).Naumen_Case_Status__c);
        system.assert(lead.Naumen_Case_Status_ModifiedTime__c < testLeads.get(0).Naumen_Case_Status_ModifiedTime__c);

        List<Opportunity> testOpportunities = [
                SELECT Id, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c,
                      (SELECT ContactId, Contact.Phone, Contact.Phone_Status__c, Contact.Phone_Rating__c, Contact.MobilePhone, Contact.MobilePhone_Status__c, Contact.MobilePhone_Rating__c, Contact.Additional_Phones__c FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE id = :opportunity.Id
        ];
        system.assertEquals('Finished', testOpportunities.get(0).Naumen_Case_Status__c);
        system.assert(opportunity.Naumen_Case_Status_ModifiedTime__c < testOpportunities.get(0).Naumen_Case_Status_ModifiedTime__c);
        
        system.assertEquals(contact.Phone, testOpportunities.get(0).OpportunityContactRoles.get(0).getSObject('Contact').get('Phone'));
        system.assertEquals('Dial out', testOpportunities.get(0).OpportunityContactRoles.get(0).getSObject('Contact').get('Phone_Status__c'));
        system.assertEquals(contact.MobilePhone, testOpportunities.get(0).OpportunityContactRoles.get(0).getSObject('Contact').get('MobilePhone'));
        system.assertEquals('CTI Wrong number:0', testOpportunities.get(0).OpportunityContactRoles.get(0).getSObject('Contact').get('MobilePhone_Status__c'));
        system.assertEquals('+12345678899#35!New!0,2!2304202314.+1231232222!New!!0104201015.' + contactAdditionalPhone + '!' + PhoneNumbersHandler.getPhoneStatusAbbreviationTranslation('CTI Wrong number:0') + '!0,6!1303991820',
                            testOpportunities.get(0).OpportunityContactRoles.get(0).getSObject('Contact').get('Additional_Phones__c'));
    }
    @isTest
    private static void testService_Success_Leads_1(){
        Lead lead1 = new Lead(
                LastName = 'test 1',
                Source_of_Lead__c = 'E2E Form RU',
                Country = 'Russia',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+79127193501',
                MobilePhone = '+79852769431',
                Naumen_Autocall_Project_UUID__c = 'proj001',
                Naumen_Autocall_Case_UUID__c = 'case001',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        Lead lead2 = new Lead(
                LastName = 'test 2',
                Source_of_Lead__c = 'E2E Form RU',
                Country = 'Russia',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+79127193502',
                MobilePhone = '+79852769432',
                Naumen_Autocall_Project_UUID__c = 'proj002',
                Naumen_Autocall_Case_UUID__c = 'case002',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        Lead lead3 = new Lead(
                LastName = 'test 3',
                Source_of_Lead__c = 'E2E Form RU',
                Country = 'Russia',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+79127193501',
                MobilePhone = '+79852769433',
                Naumen_Autocall_Project_UUID__c = 'proj002',
                Naumen_Autocall_Case_UUID__c = 'case003',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        Lead lead4 = new Lead(
                LastName = 'test 3',
                Source_of_Lead__c = 'E2E Form RU',
                Country = 'Russia',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+79127193501',
                MobilePhone = '+79852769433',
                Naumen_Autocall_Project_UUID__c = 'proj002',
                Naumen_Autocall_Case_UUID__c = 'case004',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        insert new List <Lead> {lead1, lead2, lead3, lead4};

        String dtFinished = system.now().addMinutes(-2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        String jsonBody = '{"logs": [' +
                '{"recordId": "'+lead1.Id+'","phoneNumber": "'+lead1.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:21:01.000Z"}, ' +
                '{"recordId": "'+lead1.Id+'","phoneNumber": "'+lead1.MobilePhone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "UNKNOWN_ERROR","statusDate": "2099-03-13T17:24:01.000Z"}, ' +
                '{"recordId": "'+lead2.Id+'","phoneNumber": "'+lead2.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "no_answer","statusDate": "2099-03-13T17:23:01.000Z"},' +
                '{"recordId": "'+lead3.Id+'","phoneNumber": "'+lead3.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "operator_busy","statusDate": "2099-03-13T17:20:01.000Z"},' +
                '{"recordId": "'+lead4.Id+'","phoneNumber": "'+lead4.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Отложенное","statusValue": "connected","statusDate": "2099-03-13T17:20:01.000Z", "statusDateTimeZone":"3"}' +
                ']}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('token', '123');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();

        List<Lead> testLead1 = [
                SELECT Id, Phone, Phone_Status__c,  MobilePhone, MobilePhone_Status__c, PPR_Contact_Phone__c,
                       Additional_Phones__c, Irrelevant_Phones__c, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c
                FROM Lead
                WHERE Id = :lead1.Id
        ];
        system.assertEquals(lead1.Phone, testLead1.get(0).Phone);
        system.assertEquals('Dial out', testLead1.get(0).Phone_Status__c);
        system.assertEquals(lead1.MobilePhone, testLead1.get(0).MobilePhone);
        system.assertEquals('CTI System Error', testLead1.get(0).MobilePhone_Status__c);
        system.assertEquals('Finished', testLead1.get(0).Naumen_Case_Status__c);
        system.assert(lead1.Naumen_Case_Status_ModifiedTime__c < testLead1.get(0).Naumen_Case_Status_ModifiedTime__c);

        List<Lead> testLead2 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c, PPR_Contact_Phone__c, 
                       Additional_Phones__c, Irrelevant_Phones__c, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c
                FROM Lead
                WHERE Id = :lead2.Id
        ];
        system.assertEquals(lead2.Phone, testLead2.get(0).Phone);
        system.assertEquals('Dial out', testLead2.get(0).Phone_Status__c);
        system.assertEquals(lead2.MobilePhone, testLead2.get(0).MobilePhone);
        system.assertEquals('New', testLead2.get(0).MobilePhone_Status__c);
        system.assertEquals('Finished', testLead2.get(0).Naumen_Case_Status__c);
        system.assert(lead2.Naumen_Case_Status_ModifiedTime__c < testLead2.get(0).Naumen_Case_Status_ModifiedTime__c);

        List<Lead> testLead3 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c, PPR_Contact_Phone__c, 
                       Additional_Phones__c, Irrelevant_Phones__c, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c
                FROM Lead
                WHERE Id = :lead3.Id
        ];
        system.assertEquals(lead3.Phone, testLead3.get(0).Phone);
        system.assertEquals('Successful dialing', testLead3.get(0).Phone_Status__c);
        system.assertEquals(lead3.MobilePhone, testLead3.get(0).MobilePhone);
        system.assertEquals('New', testLead3.get(0).MobilePhone_Status__c);
        system.assertEquals('Finished', testLead3.get(0).Naumen_Case_Status__c);
        system.assert(lead3.Naumen_Case_Status_ModifiedTime__c < testLead3.get(0).Naumen_Case_Status_ModifiedTime__c);

        // test 4 shouldn't be updated because it has status 'connected' (CallLogRuBatch only saves failed calls statuses on phone statuses fields)
        List<Lead> testLead4 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c, PPR_Contact_Phone__c, 
                       Additional_Phones__c, Irrelevant_Phones__c, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c
                FROM Lead
                WHERE Id = :lead4.Id
        ];
        system.assertEquals(lead4.Phone, testLead4.get(0).Phone);
        system.assertEquals('New', testLead4.get(0).Phone_Status__c);
        system.assertEquals(lead4.MobilePhone, testLead4.get(0).MobilePhone);
        system.assertEquals('New', testLead4.get(0).MobilePhone_Status__c);
        system.assertEquals('Created', testLead4.get(0).Naumen_Case_Status__c);
        system.assertEquals(lead4.Naumen_Case_Status_ModifiedTime__c, testLead4.get(0).Naumen_Case_Status_ModifiedTime__c);
    }

    @isTest
    private static void testService_Success_Contacts_1(){
        Account account = new Account(Name = 'testt', INN__c = '1234567890', RecordTypeId = RU_ACCOUNT_RECORD_TYPE);
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Qualified Lead',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                RecordTypeId = RU_OPPORTUNITY_RECORD_TYPE,
                Business_process__c = GlobalUtils.BusinessProcessType.Standard.name(),
                Naumen_Autocall_Project_UUID__c = 'proj001',
                Naumen_Autocall_Case_UUID__c = 'case001',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        insert opportunity;
        Contact contact1 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '+79999999991',
                MobilePhone = '+79999999992'
        );
        insert contact1;
        Contact contact2 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '+79999999993',
                MobilePhone = '+79999999992'
        );
        insert contact2;
        OpportunityContactRole opr = new OpportunityContactRole();
        opr.ContactId = contact2.Id;
        opr.OpportunityId = opportunity.Id;
        opr.Role = 'Ktoto';
        insert opr;

        String dtFinished = system.now().addMinutes(-2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        String jsonBody = '{"logs": [' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact1.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:21:01.000Z"}, ' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact1.MobilePhone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "operator_no_answer","statusDate": "2099-03-13T17:24:01.000Z"}, ' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact2.Phone+'","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:23:01.000Z"}' +
                ']}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('token', '123');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();

        Opportunity testOpportunity = [SELECT Id, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals('Finished', testOpportunity.Naumen_Case_Status__c);
        system.assert(opportunity.Naumen_Case_Status_ModifiedTime__c < testOpportunity.Naumen_Case_Status_ModifiedTime__c);

        Contact testContact1 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c
                FROM Contact WHERE Id = :contact1.Id
        ];
        system.assertEquals(contact1.Phone, testContact1.Phone);
        system.assertEquals('Dial out', testContact1.Phone_Status__c);
        system.assertEquals(contact1.MobilePhone, testContact1.MobilePhone);
        system.assertEquals('Successful dialing', testContact1.MobilePhone_Status__c);
        

        Contact testContact2 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c
                FROM Contact WHERE Id = :contact2.Id
        ];
        system.assertEquals(contact2.Phone, testContact2.Phone);
        system.assertEquals('Dial out', testContact2.Phone_Status__c);
        system.assertEquals(contact2.MobilePhone, testContact2.MobilePhone);
        system.assertEquals('Successful dialing', testContact2.MobilePhone_Status__c);
    }
    @isTest
    private static void testService_WithoutFinishedDate(){
        Account account = new Account(Name = 'testt', INN__c = '1234567890', RecordTypeId = RU_ACCOUNT_RECORD_TYPE);
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Qualified Lead',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                RecordTypeId = RU_OPPORTUNITY_RECORD_TYPE,
                Business_process__c = GlobalUtils.BusinessProcessType.Standard.name(),
                Naumen_Autocall_Project_UUID__c = 'proj001',
                Naumen_Autocall_Case_UUID__c = 'case001',
                Naumen_Case_Status__c = 'Created', 
                Naumen_Case_Status_ModifiedTime__c = system.now().addDays(-1)
        );
        insert opportunity;
        Contact contact1 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '+79999999991',
                MobilePhone = '+79999999992'
        );
        insert contact1;
        Contact contact2 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '+79999999993',
                MobilePhone = '+79999999992'
        );
        insert contact2;
        OpportunityContactRole opr = new OpportunityContactRole();
        opr.ContactId = contact2.Id;
        opr.OpportunityId = opportunity.Id;
        opr.Role = 'Ktoto';
        insert opr;

        String dtFinished = system.now().addMinutes(-2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        String jsonBody = '{"logs": [' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact1.Phone+'","finisheddate":null,"authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:21:01.000Z"}, ' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact1.MobilePhone+'","finisheddate":null,"authortitle":"system","caseStatus":"Недозвон","statusValue": "operator_no_answer","statusDate": "2099-03-13T17:24:01.000Z"}, ' +
                '{"recordId": "'+opportunity.Id+'","phoneNumber": "'+contact2.Phone+'","finisheddate":null,"authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2099-03-13T17:23:01.000Z"}' +
                ']}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('token', '123');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();

        Opportunity testOpportunity = [SELECT Id, Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals('Created', testOpportunity.Naumen_Case_Status__c);
        system.assertEquals(opportunity.Naumen_Case_Status_ModifiedTime__c, testOpportunity.Naumen_Case_Status_ModifiedTime__c);
        

        Contact testContact1 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c
                FROM Contact WHERE Id = :contact1.Id
        ];
        system.assertEquals(contact1.Phone, testContact1.Phone);
        system.assertEquals('Dial out', testContact1.Phone_Status__c);
        system.assertEquals(contact1.MobilePhone, testContact1.MobilePhone);
        system.assertEquals('Successful dialing', testContact1.MobilePhone_Status__c);

        Contact testContact2 = [
                SELECT Id, Phone, Phone_Status__c, MobilePhone, MobilePhone_Status__c
                FROM Contact WHERE Id = :contact2.Id
        ];
        system.assertEquals(contact2.Phone, testContact2.Phone);
        system.assertEquals('Dial out', testContact2.Phone_Status__c);
        system.assertEquals(contact2.MobilePhone, testContact2.MobilePhone);
        system.assertEquals('Successful dialing', testContact2.MobilePhone_Status__c);
    }

    @isTest
    private static void testService_WithoutToken(){
        String dtFinished = system.now().addMinutes(-2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        String jsonBody = '{"logs": [' +
                '{"recordId": "00Q0Q000002tzub","phoneNumber": "84950000067","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"}, ' +
                '{"recordId": "00Q0Q000002tzvS","phoneNumber": "84950000120","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"},' +
                '{"recordId": "0060Q00000914vZ","phoneNumber": "+78000000003","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"},' +
                '{"recordId": "0060Q00000914vZ","phoneNumber": "+78000000000","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"}' +
                ']}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();
    }

    @isTest
    private static void testService_InvalidToken(){
        String dtFinished = system.now().addMinutes(-2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        String jsonBody = '{"logs": [' +
                '{"recordId": "00Q0Q000002tzub","phoneNumber": "84950000067","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"}, ' +
                '{"recordId": "00Q0Q000002tzvS","phoneNumber": "84950000120","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"},' +
                '{"recordId": "0060Q00000914vZ","phoneNumber": "+78000000003","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"},' +
                '{"recordId": "0060Q00000914vZ","phoneNumber": "+78000000000","finisheddate":"'+dtFinished+'.000Z","authortitle":"system","caseStatus":"Недозвон","statusValue": "busy","statusDate": "2020-02-19"}' +
                ']}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('token', 'InvalidToken');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();
    }

    @isTest
    private static void testService_InvalidJSON(){
        String jsonBody = '{"logs": [InvalidJSON]}';

        RestRequest req = new RestRequest();
        req.requestURI = 'https://www.salesforce.com/services/apexrest/CallLogRuService';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('token', '123');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        CallLogRuService.receiveCallLogInformation();
        Test.stopTest();
    }

}