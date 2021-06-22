@IsTest
private class CreateCSVBatchTest {
    @TestSetup
    private static void testSetup(){
// ---- settings----
        // cf settings
        insert CFUtilsTest.createCFSettingsForRussia(false);
        // naumen settings
        Naumen_Settings__c naumenSettings = new Naumen_Settings__c();
        naumenSettings.Admin_Emails__c = 'test@test.ru';
        naumenSettings.Supervisor_Emails__c = 'test1@test.ru';
        naumenSettings.UploadResultsRecievers_Emails__c = 'test2@test.ru';
        naumenSettings.REST_Passw__c = 'testpassw';
        naumenSettings.REST_URL__c = 'https://test.ru';
        naumenSettings.REST_Username__c = 'testusername';
        insert naumenSettings;
        // cc speed up settings
        RecordAssignCheckRuTest.testSetupMethod();
// ---- create lead data----
        Id rtLeadRU = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        Id rtOppRU = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        Id rtConRU = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();
        Id rtAccRU = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();
        Lead lead0 = new Lead(
            LastName = 'test 0',
            Source_of_Lead__c = 'E2E Form RU',
            Country = 'Russia',
            Company = 'test acc',
            RecordTypeId = rtLeadRU,
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
                RecordTypeId = rtLeadRU,
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
                BillingCountry = 'Russia',
                RecordTypeId = rtAccRU);
        insert newAccount;

        Opportunity newOpp = new Opportunity(
                StageName = 'Qualify',
                Name = 'test opp1',
                CloseDate = Date.today(),
                RecordTypeId = rtOppRU,
                AccountId = newAccount.Id);
        insert newOpp;

        Contact conWithOppRole = new Contact(
                FirstName = 'Test2',
                LastName = 'Testov',
                Email = 'test@example.com',
                Phone = '+75554445551',
                RecordTypeId = rtConRU,
                AccountId = newAccount.Id);
        Contact con = new Contact(
                FirstName = 'Test1',
                LastName = 'Testov',
                Email = 'test@example.com',
                Phone = '+75554445552',
                RecordTypeId = rtConRU,
                AccountId = newAccount.Id);
        insert new List <Contact> {conWithOppRole, con};

        OpportunityContactRole testRole = new OpportunityContactRole(
                ContactId = conWithOppRole.Id,
                OpportunityId = newOpp.Id,
                isPrimary = true);
        insert testRole;
    }
    @IsTest
    private static void testBatch_Leads() {
        String endQuery = ' ORDER BY LastModifiedDate desc limit 2';
        List <String> emailRecievers = new List <String> {'test@example.com'};
        String emailSubject = 'Email subject';
        String emailBody = 'Email body';
        String fileName = 'test.csv';
        Test.startTest();
            Naumen_RecordsHelper.RecordsTableParams recordsTableParams = Naumen_SupervisorPanelCtrl.createTableRecordsParams('Lead');
            CreateCSVBatch  batch = new CreateCSVBatch (recordsTableParams, endQuery, false, true, emailRecievers, emailSubject, emailBody, fileName);
            Database.executeBatch(batch, 100);
        Test.stopTest(); 
        system.assertEquals(2, CreateCSVBatch.csvRowsCount); // 2 leads
    }
    @IsTest
    private static void testBatch_Opportunities() {
        String endQuery = ' ORDER BY LastModifiedDate desc limit 2';
        List <String> emailRecievers = new List <String> {'test@example.com'};
        String emailSubject = 'Email subject';
        String emailBody = 'Email body';
        String fileName = 'test.csv';
        Test.startTest();
            Naumen_RecordsHelper.RecordsTableParams recordsTableParams = Naumen_SupervisorPanelCtrl.createTableRecordsParams('Opportunity');
            system.debug('fieldsList : ' + recordsTableParams.fieldsList);
            CreateCSVBatch  batch = new CreateCSVBatch (recordsTableParams, endQuery, false, true, emailRecievers, emailSubject, emailBody, fileName);
            Database.executeBatch(batch, 100);
        Test.stopTest(); 
        system.assertEquals(1, CreateCSVBatch.csvRowsCount); // 1 opp
    }
    @IsTest
    private static void testBatch_CCSpeedUpCheck() {
        String endQuery = ' ORDER BY LastModifiedDate desc limit 2';
        List <String> emailRecievers = new List <String> {'test@example.com'};
        String emailSubject = 'Email subject';
        String emailBody = 'Email body';
        String fileName = 'test.csv';
        Test.startTest();
            Naumen_RecordsHelper.RecordsTableParams recordsTableParams = Naumen_SupervisorPanelCtrl.createTableRecordsParams('Opportunity');
            system.debug('fieldsList : ' + recordsTableParams.fieldsList);
            CreateCSVBatch  batch = new CreateCSVBatch (recordsTableParams, endQuery, true, true, emailRecievers, emailSubject, emailBody, fileName);
            Database.executeBatch(batch, 100);
        Test.stopTest(); 
        system.assertEquals(0, CreateCSVBatch.csvRowsCount); // 0 free opps
    }
}