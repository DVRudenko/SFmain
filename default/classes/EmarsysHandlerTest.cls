@isTest
private class EmarsysHandlerTest {

    @testsetup static void setup() {
        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];
        User ownerUser = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert ownerUser;
        List<Group> l1 = [SELECT id From Group Where NAme = 'Emarsys CHDE-DE-AT'];
        GroupMember newGroupMember = new GroupMember();
        newGroupMember.GroupId = l1.get(0).id;
        newGroupMember.UserOrGroupId = ownerUser.id;
        insert newGroupMember;
    }


    /*******************************************************************************
    *  Name            : sendLeadsToEuropeanEmarsysTest()
    *  Summary         : test sending Leads with Record Type = "Endkunde" to Emarsys before update
    *  CreatedDate     : 17/08/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void sendLeadsToEuropeanEmarsysTest() {

        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys EU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_fields_sync_lead__c> euFieldsList = new List<Emarsys_fields_sync_lead__c>();
        Emarsys_fields_sync_lead__c field1 = new Emarsys_fields_sync_lead__c(
                Name = 'Channel__c',
                Emarsys_field_Id__c = '10924');
        euFieldsList.add(field1);

        Emarsys_fields_sync_lead__c field2 = new Emarsys_fields_sync_lead__c(
                Name = 'Owner.Email',
                Emarsys_field_Id__c = '10532');
        euFieldsList.add(field2);
        insert euFieldsList;

        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Endkunde' AND SobjectType = 'Lead'
                LIMIT 1
        ];

        Lead lead1 = new Lead(
                Status = 'Contacted',
                LastName = 'test',
                Company = 'test',
                Phone = '1234567890',
                Country = 'Germany',
                CountryCode = 'DE',
                State = 'Bavaria',
                Email = 'test@test.com',
                OwnerId = user.Id,
                Channel__c = 'Fax',
                RecordTypeId = rtList.get(0).Id,
                Sec_Channel__c = 'Fax');
        insert lead1;

        Lead lead2 = new Lead(Id = lead1.id,
                Status = 'Contacted',
                LastName = 'testNEXT',
                Company = 'test',
                Phone = '1234567890',
                Country = 'Germany',
                CountryCode = 'DE',
                State = 'Bavaria',
                Email = 'test@test.com',
                OwnerId = user.Id,
                Channel__c = 'Inbound',
                RecordTypeId = rtList.get(0).Id,
                Sec_Channel__c = 'Fax');

        Task task = new Task(
                WhoId = lead1.Id,
                Subject = 'Call');
        insert task;

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(lead1.id, lead1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(lead2.id, lead2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToEuropeanEmarsys(oldMap, newMap);
        Test.stopTest();


        List<Lead> leadsList = [
                SELECT Id, Emarsys_Contact_Id__c, RecordType.Name
                FROM Lead
                WHERE Emarsys_Contact_Id__c != null
        ];
        System.assertEquals(leadsList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : sendOpportunitiesToEuropeanEmarsysTest()
    *  Summary         : test sending Opportunities with Record Type = "Euroshell" or "Euroshell Starts" to Emarsys before update
    *  CreatedDate     : 17/08/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void sendOpportunitiesToEuropeanEmarsysTest() {
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys EU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_fields_sync_opportunity__c> euFieldsList = new List<Emarsys_fields_sync_opportunity__c>();
        Emarsys_fields_sync_opportunity__c field1 = new Emarsys_fields_sync_opportunity__c(
                Name = 'StageName',
                Emarsys_field_Id__c = '9665');
        euFieldsList.add(field1);

        Emarsys_fields_sync_opportunity__c field2 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Contact.Email',
                Emarsys_field_Id__c = '3');
        euFieldsList.add(field2);

        Emarsys_fields_sync_opportunity__c field3 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Owner.Email',
                Emarsys_field_Id__c = '10535');
        euFieldsList.add(field3);

        Emarsys_fields_sync_opportunity__c field4 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        euFieldsList.add(field4);

        Emarsys_fields_sync_opportunity__c field5 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Custom_pin__c',
                Emarsys_field_Id__c = '10536');
        euFieldsList.add(field5);

        Emarsys_fields_sync_opportunity__c field6 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Account.BillingCountry',
                Emarsys_field_Id__c = '50539');
        euFieldsList.add(field6);

        Emarsys_fields_sync_opportunity__c field7 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Contact.Phone',
                Emarsys_field_Id__c = '3423');
        euFieldsList.add(field7);

        Emarsys_fields_sync_opportunity__c field8 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Contact.MobilePhone',
                Emarsys_field_Id__c = '34235');
        euFieldsList.add(field8);
        insert euFieldsList;

        User ownerUser = [SELECT Id From User where email = 'test@fleetcor.de' limit 1].get(0); //from testsetup

        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Germany',
                BillingCountryCode = 'DE');
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                MailingCountry = 'Germany',
                MailingCountryCode = 'DE',
                Phone = '123123456',
                MobilePhone = '456123456',
                Email = 'test123123@test.com');
        insert contact;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity'
                LIMIT 1
        ];

        Opportunity opportunity1 = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                OwnerId = ownerUser.Id);
        insert opportunity1;

        Tankkarten__c tankkarten = new Tankkarten__c(
                Opportunity__c = opportunity1.Id,
                Gewuenschter_Kartentyp__c = 'Single Network Card -- National',
                Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren',
                KFZ_Kennzeichen_oder_Fahrername__c = 'test');
        insert tankkarten;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity1.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        Opportunity opportunity2 = new Opportunity(
                Id = opportunity1.id,
                Name = 'Testxc',
                StageName = 'Pending Sales – Deposit',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                Custom_pin__c = True,
                OwnerId = ownerUser.Id);

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(opportunity1.id, opportunity1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(opportunity2.id, opportunity2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToEuropeanEmarsys(oldMap, newMap);
        Test.stopTest();


        List<Opportunity> leadsList = [
                SELECT Id, Emarsys_Contact_Id__c
                FROM Opportunity
                WHERE Emarsys_Contact_Id__c != null
        ];

        System.assertEquals(leadsList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : sendLeadsToRussianEmarsysTest()
    *  Summary         : test sending Leads with Record Type = "Russian Sales" to Emarsys after update
    *  CreatedDate     : 26/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void sendLeadsToRussianEmarsysTest() {
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys RU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_RU_fields_sync_lead__c> ruFieldsList = new List<Emarsys_RU_fields_sync_lead__c>();
        Emarsys_RU_fields_sync_lead__c field1 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Status',
                Emarsys_field_Id__c = '3289');
        ruFieldsList.add(field1);

        Emarsys_RU_fields_sync_lead__c field2 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        ruFieldsList.add(field2);

        Emarsys_RU_fields_sync_lead__c field3 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Lead_Status_Specific__c',
                Emarsys_field_Id__c = '3290');
        ruFieldsList.add(field3);

        Emarsys_RU_fields_sync_lead__c field4 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Email',
                Emarsys_field_Id__c = '3');
        ruFieldsList.add(field4);

        Emarsys_RU_fields_sync_lead__c field5 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'UTM_Source__c',
                Emarsys_field_Id__c = '3295');
        ruFieldsList.add(field5);
        insert ruFieldsList;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
        ];

        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test3@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Lead lead1 = new Lead(
                OwnerId = user.Id,
                Status = 'NEW - Not Yet Contacted',
                LastName = 'test',
                Company = 'test',
                Email = 'test@test.com',
                Country = 'Russia',
                RecordTypeId = rtList.get(0).Id);
        insert lead1;

        Lead lead2 = new Lead(
                Id = lead1.id,
                OwnerId = user.Id,
                Status = 'Disqualified',
                Lead_Status_Specific__c = 'Потерян в конкуренции/Цена',
                LastName = 'test',
                Company = 'test',
                Email = 'test@test.com',
                Country = 'Russia',
                RecordTypeId = rtList.get(0).Id);


        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(lead1.id, lead1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(lead2.id, lead2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToRussianEmarsys(oldMap, newMap);
        Test.stopTest();

        List<Lead> testLeadsList = [
                SELECT Name
                FROM Lead
                WHERE Emarsys_Contact_Id__c != null
        ];
        System.assertEquals(testLeadsList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : sendNewLeadsToRussianEmarsysTest()
    *  Summary         : test sending Leads with Record Type = "Russian Sales" to Emarsys after update
    *  CreatedDate     : 26/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void sendNewLeadsToRussianEmarsysTest() {
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys RU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_RU_fields_sync_lead__c> ruFieldsList = new List<Emarsys_RU_fields_sync_lead__c>();
        Emarsys_RU_fields_sync_lead__c field1 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Status',
                Emarsys_field_Id__c = '3289');
        ruFieldsList.add(field1);

        Emarsys_RU_fields_sync_lead__c field2 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        ruFieldsList.add(field2);

        Emarsys_RU_fields_sync_lead__c field3 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Lead_Status_Specific__c',
                Emarsys_field_Id__c = '3290');
        ruFieldsList.add(field3);

        Emarsys_RU_fields_sync_lead__c field4 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'Email',
                Emarsys_field_Id__c = '3');
        ruFieldsList.add(field4);

        Emarsys_RU_fields_sync_lead__c field5 = new Emarsys_RU_fields_sync_lead__c(
                Name = 'UTM_Source__c',
                Emarsys_field_Id__c = '3295');
        ruFieldsList.add(field5);
        insert ruFieldsList;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales'
        ];

        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test3@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        LeadHandler.enablesTrigger = false;
        Lead lead1 = new Lead(
                OwnerId = user.Id,
                Status = 'NEW - Not Yet Contacted',
                LastName = 'test',
                Company = 'test',
                Email = 'test@test.com',
                Country = 'Russia',
                RecordTypeId = rtList.get(0).Id,
                UTM_Source__c = 'email_trigger');
        insert lead1;

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(lead1.id, lead1);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToRussianEmarsys(null, newMap);
        Test.stopTest();

        List<Lead> testLeadsList = [
                SELECT Name
                FROM Lead
                WHERE Emarsys_Contact_Id__c != null
        ];
        System.assertEquals(testLeadsList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : sendOpportunitiesToRussianEmarsys()
    *  Summary         : test sending Opportunities with Record Type = "Euroshell" or "Euroshell Starts" to Emarsys after update
    *  CreatedDate     : 26/07/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void sendOpportunitiesToRussianEmarsys() {
        createCustomSettings();
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys RU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_RU_fields_sync_opportunity__c> ruFieldsList = new List<Emarsys_RU_fields_sync_opportunity__c>();
        Emarsys_RU_fields_sync_opportunity__c field1 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'StageName',
                Emarsys_field_Id__c = '9665');
        ruFieldsList.add(field1);

        Emarsys_RU_fields_sync_opportunity__c field2 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'Contact.Email',
                Emarsys_field_Id__c = '3');
        ruFieldsList.add(field2);

        Emarsys_RU_fields_sync_opportunity__c field3 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'Owner.Email',
                Emarsys_field_Id__c = '10535');
        ruFieldsList.add(field3);

        Emarsys_RU_fields_sync_opportunity__c field4 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        ruFieldsList.add(field4);
        insert ruFieldsList;

        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Germany');
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Opportunity'
        ];

        Opportunity opportunity1 = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                OwnerId = user.Id);
        insert opportunity1;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity1.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        Opportunity opportunity2 = new Opportunity(
                Id = opportunity1.id,
                Name = 'Test',
                StageName = 'Client Negotiations',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                OwnerId = user.Id);

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(opportunity1.id, opportunity1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(opportunity2.id, opportunity2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToRussianEmarsys(oldMap, newMap);
        Test.stopTest();


        List<Opportunity> opportunitiesList = [
                SELECT Id, Emarsys_Contact_Id__c
                FROM Opportunity
                WHERE Emarsys_Contact_Id__c != null
        ];

        System.assertEquals(opportunitiesList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : sendContactsToRussianEmarsysTest()
    *  Summary         : test sending Contacts with Record Type = "Russian Sales" to Emarsys after update
    *  CreatedDate     : 26/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void sendContactsToRussianEmarsysTest() {
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys RU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_RU_fields_sync_contact__c> ruFieldsList = new List<Emarsys_RU_fields_sync_contact__c>();
        Emarsys_RU_fields_sync_contact__c field1 = new Emarsys_RU_fields_sync_contact__c(
                Name = 'Opportunity.UTM_Source_Medium__c',
                Emarsys_field_Id__c = '3289');
        ruFieldsList.add(field1);

        Emarsys_RU_fields_sync_contact__c field2 = new Emarsys_RU_fields_sync_contact__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        ruFieldsList.add(field2);

        Emarsys_RU_fields_sync_contact__c field3 = new Emarsys_RU_fields_sync_contact__c(
                Name = 'Emarsys_Contact_Id__c',
                Emarsys_field_Id__c = '12332');

        Emarsys_RU_fields_sync_contact__c field4 = new Emarsys_RU_fields_sync_contact__c(
                Name = 'Contact.LastName',
                Emarsys_field_Id__c = '1889');
        ruFieldsList.add(field4);
        insert ruFieldsList;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian' AND SobjectType = 'Contact'
        ];

        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test3@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Germany');
        insert account;

        Contact contact1 = new Contact(
                LastName = 'test',
                Salutation = 'Herr',
                AccountId = account.Id,
                RecordTypeId = rtList.get(0).Id);
        insert contact1;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                UTM_Source_Medium__c = 'email_trigger',
                OwnerId = user.Id);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact1.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        Contact contact2 = new Contact(
                Id = contact1.id,
                LastName = 'testt',
                Salutation = 'Herrr',
                AccountId = account.Id,
                Email = 'test@test.com',
                RecordTypeId = rtList.get(0).Id);

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(contact1.id, contact1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(contact2.id, contact2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToRussianEmarsys(oldMap, newMap);
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT Id, Emarsys_Contact_Id__c
                FROM Opportunity
                WHERE Emarsys_Contact_Id__c != null
        ];

        System.assertEquals(opportunitiesList.size(), 1);
    }

    @isTest
    static void TestremoveExtraCharacters() {
        String test1 = EmarsysSenderEuropeanService.removeExtraCharacters('123 -,.');
        System.assertEquals(test1, '123');
    }

    @isTest
    public static void testSendContactsToEmarsys() {
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys EU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_fields_sync_opportunity__c> euFieldsList = new List<Emarsys_fields_sync_opportunity__c>();
        Emarsys_fields_sync_opportunity__c field1 = new Emarsys_fields_sync_opportunity__c(
                Name = 'StageName',
                Emarsys_field_Id__c = '9665');
        euFieldsList.add(field1);

        Emarsys_fields_sync_opportunity__c field2 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Contact.Email',
                Emarsys_field_Id__c = '3');
        euFieldsList.add(field2);

        Emarsys_fields_sync_opportunity__c field3 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Owner.Email',
                Emarsys_field_Id__c = '10535');
        euFieldsList.add(field3);

        Emarsys_fields_sync_opportunity__c field4 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        euFieldsList.add(field4);

        Emarsys_fields_sync_opportunity__c field5 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Custom_pin__c',
                Emarsys_field_Id__c = '10536');
        euFieldsList.add(field5);

        Emarsys_fields_sync_opportunity__c field6 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Account.BillingCountry',
                Emarsys_field_Id__c = '50539');
        euFieldsList.add(field6);

        Emarsys_fields_sync_opportunity__c field7 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Contact.Phone',
                Emarsys_field_Id__c = '3423');
        euFieldsList.add(field7);

        Emarsys_fields_sync_opportunity__c field8 = new Emarsys_fields_sync_opportunity__c(
                Name = 'Contact.MobilePhone',
                Emarsys_field_Id__c = '34235');
        euFieldsList.add(field8);
        insert euFieldsList;

        User ownerUser = [SELECT Id From User where email = 'test@fleetcor.de' limit 1].get(0); //from testsetup

        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Germany');
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Phone = '123123456',
                MobilePhone = '456123456',
                MailingCountry = 'Germany',
                MailingCountryCode = 'DE',
                Email = 'test123123@test.com');
        insert contact;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity'
                LIMIT 1
        ];

        Opportunity opportunity1 = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                OwnerId = ownerUser.Id);
        insert opportunity1;

        Tankkarten__c tankkarten = new Tankkarten__c(
                Opportunity__c = opportunity1.Id,
                Gewuenschter_Kartentyp__c = 'Single Network Card -- National',
                Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren',
                KFZ_Kennzeichen_oder_Fahrername__c = 'test');
        insert tankkarten;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity1.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        Opportunity opportunity2 = new Opportunity(
                Id = opportunity1.id,
                Name = 'Testxc',
                StageName = 'Pending Sales – Deposit',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                Custom_pin__c = True,
                OwnerId = ownerUser.Id);

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(opportunity1.id, opportunity1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(opportunity2.id, opportunity2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToEmarsys(oldMap, newMap, 'RU&EU');
        Test.stopTest();
    }

    @isTest
    public static void testSendContactsToEmarsys2() {
        createCustomSettings();
        Integration_Settings__c emarsysSetting = new Integration_Settings__c(
                Name = 'Emarsys RU', Enabled__c = true);
        insert emarsysSetting;

        List<Emarsys_RU_fields_sync_opportunity__c> ruFieldsList = new List<Emarsys_RU_fields_sync_opportunity__c>();
        Emarsys_RU_fields_sync_opportunity__c field1 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'StageName',
                Emarsys_field_Id__c = '9665');
        ruFieldsList.add(field1);

        Emarsys_RU_fields_sync_opportunity__c field2 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'Contact.Email',
                Emarsys_field_Id__c = '3');
        ruFieldsList.add(field2);

        Emarsys_RU_fields_sync_opportunity__c field3 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'Owner.Email',
                Emarsys_field_Id__c = '10535');
        ruFieldsList.add(field3);

        Emarsys_RU_fields_sync_opportunity__c field4 = new Emarsys_RU_fields_sync_opportunity__c(
                Name = 'Owner.Name',
                Emarsys_field_Id__c = '10532');
        ruFieldsList.add(field4);
        insert ruFieldsList;

        Profile p = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Germany');
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Opportunity'
        ];

        Opportunity opportunity1 = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                OwnerId = user.Id);
        insert opportunity1;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity1.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        Opportunity opportunity2 = new Opportunity(
                Id = opportunity1.id,
                Name = 'Test',
                StageName = 'Client Negotiations',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                OwnerId = user.Id);

        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(opportunity1.id, opportunity1);

        Map<Id, SObject> newMap = new Map<Id, SObject>();
        newMap.put(opportunity2.id, opportunity2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateContactsHttpResponseGenerator());
        EmarsysHandler.sendContactsToEmarsys(oldMap, newMap, 'RU&EU');
        Test.stopTest();
    }

    @isTest
    public static void testGetStatusOfNeedToSend_MoveToStart() {
        Profile randomProfile = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ];

        User user = new User(
                ProfileId = randomProfile.Id,
                Username = System.now().millisecond() + '_233121_test2@test.com',
                Alias = 'kam',
                Email = 'test@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Germany');
        insert account;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Opportunity'
        ];

        Opportunity oldRecord = new Opportunity(
            Name = 'Test',
            StageName = 'Prospecting',
            AccountID = account.Id,
            CloseDate = date.today().addMonths(1),
            Product__c = 'Home Station offer (v.1)',
            Angebotsdauer__c = '3 Monate',
            RecordTypeId = rtList.get(0).Id,
            OwnerId = user.Id
        );

        Opportunity newRecord = new Opportunity(
            Name = 'Test',
            StageName = EmarsysSenderRussianService.MOVED_TO_START,
            AccountID = account.Id,
            CloseDate = date.today().addMonths(1),
            Product__c = 'Home Station offer (v.1)',
            Angebotsdauer__c = '3 Monate',
            RecordTypeId = rtList.get(0).Id,
            OwnerId = user.Id
        );

        Boolean result = EmarsysSenderRussianService.getStatusOfNeedToSend(oldRecord, newRecord);
        System.assertEquals(true, result);

        oldRecord.StageName = EmarsysSenderRussianService.MOVED_TO_START;
        result = EmarsysSenderRussianService.getStatusOfNeedToSend(oldRecord, newRecord);
        System.assertEquals(false, result);
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}