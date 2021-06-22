@isTest
public with sharing class RecordAssignCheckRuTest {

    private static String recordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
    private static String recordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
    private static String recordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
    private static String recordTypeContact = [select id from recordtype where name = 'Russian' and SobjectType = 'Contact'].id;
    private static User rootUser {
        get {
            try {
                return [SELECT Id FROM User WHERE Username = 'rootUser@fleetcor.ru'];
            } catch (Exception e) {
                return null;
            }
        }
        set;
    }

    private static FS_Tree_Province__mdt fieldRegion {
        get {
            if (fieldRegion == null) {
                List<FS_Tree_Province__mdt> listProvinces = [
                        SELECT Id, Label, Assigned_Team_Lead__c
                        FROM FS_Tree_Province__mdt
                        WHERE Assigned_Team_Lead__c != null
                        ORDER BY Label ASC
                ];
                if (listProvinces.size() != 0) {
                    return listProvinces.get(0);
                } else {
                    return null;
                }
            } else {
                return fieldRegion;
            }
        }
        private set;
    }

    private static String userId {
        get {
            if (userId == null) {
                List<User> userList = [
                        SELECT id
                        FROM User
                        WHERE Profile.Name = 'Russian Sales Manager'
                        AND IsActive = true
                        AND UserRole.Name != 'PPR Key Accounts Manager' AND UserRole.Name != 'PPR Teamleader KAM'
                        ORDER BY Name ASC
                        LIMIT 1
                ];
                return userList.get(0).Id;
            } else {
                return userId;
            }
        }
        private set;
    }

    @TestSetup
    public static void testSetupMethod() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'API Only'];
        User rootUser = new User(Username = 'rootUser@fleetcor.ru',
                ProfileId = p.Id,
                Alias = 'rt@fl',
                Email = 'rootUser@fleetcor.ru',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'rootUser',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert rootUser;

        List<User> teamLeadCC = [SELECT Id FROM User WHERE UserRole.Name = 'PPR Call Center Team Leader' and IsActive = true LIMIT 1];
        Call_Center_Speed_Up__c callCenterSetting = new Call_Center_Speed_Up__c(
                Name = 'RU',
                CC_Team_Leader__c = teamLeadCC.get(0).Id,
                BigClient_cars__c = 7,
                BigClient_liters__c = 2000,
                BigClient_rubles__c = 150000,
                BigClient_trucks__c = 1,
                User_for_Reassignment__c = rootUser.Id
        );
        insert callCenterSetting;

        List<User> systemAdmin = [
                SELECT id
                FROM User
                WHERE Profile.Name IN ('API Only', 'System Administrator')
                LIMIT 1
        ];

        Email_Notifications__c notification = new Email_Notifications__c(
                Name = 'RU CC Speed Up - Admin',
                ListIDs__c = systemAdmin.get(0).id);
        insert notification;
        Email_Notifications__c notification2 = new Email_Notifications__c(
                Name = 'RU CC Speed Up - Director Key Clients',
                ListIDs__c = systemAdmin.get(0).id);
        insert notification2;

        User excludeUser = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert excludeUser;

        FieldSalesTerritory_General_Settings__c fieldSalesTerritorySettings = new FieldSalesTerritory_General_Settings__c();
        fieldSalesTerritorySettings.Name = 'RU';
        fieldSalesTerritorySettings.exludeOppOwnersId__c = excludeUser.Id;
        fieldSalesTerritorySettings.FS_Admins_Ids__c = userId;
        insert fieldSalesTerritorySettings;
    }

    ///--------------------------------------------------TESTS FO LEAD ----------------------------------------------------------------//

    @isTest
    static void testLead1() {
        String queueId = [SELECT id, name FROM Group WHERE Name LIKE '%PPR Queue Stock%' OR Name LIKE '%PPR Queue Call Center%' LIMIT 1].id;
        Lead lead = new Lead(Phone = '+79122769431',
                LastName = 'testLastName', FirstName = 'testFirstName', MiddleName = 'testMiddleName',
                OwnerId = queueId, Region__c = fieldRegion.Label,
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567891',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = recordTypeLead);
        insert lead;

        PD_Setting__c sett = new PD_Setting__c(
                URL__c = 'https://df-maxy-aflex.enterprise.dreamfactory.com/api/v2',
                Token__c = 'asdsdfsdfeferwertwer',
                Name = 'testsetting',
                AdminEmails__c = 'test@test.ru',
                IsActive__c = true
        );
        PD_Callouts.pd_settings = sett;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        controller.inputRecordId = lead.Id;
        controller.getRecordAccess();

        controller.recordId = lead.Id;
        controller.record = lead;
        controller.params = new RecordAssignCheckParams();
        controller.params.currentRegion = lead.Region__c;
        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '1';
        controller.params.expectedVolume.potential_Rub = '0';
        controller.params.expectedVolume.potential_Cars = '0';
        controller.params.expectedVolume.potential_Trucks = '0';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.params.activity.type = controller.resultTypes.get('Post').getValue();
        controller.changeCurrentGroup();
        controller.refreshForm();

        String pdId = '539d7263-1bdc-4093-a025-b09c60c6102b';
        String responseBody = '{"status":"ok", "error": null, "result": {"id": "' + pdId + '"}}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'Complete', responseBody, null));

        Test.startTest();
        controller.savePhonesData();
        controller.submitForm();
        Test.stopTest();

        List<Lead> resultList = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        Map<String, Call_Center_Speed_Up__c> settings = Call_Center_Speed_Up__c.getAll();
        system.assertEquals(resultList.get(0).OwnerId, settings.get('RU').CC_Team_Leader__c);
    }

    @isTest
    static void testLead2() {
        String queueId = [SELECT id, name FROM Group WHERE Name LIKE '%PPR Queue Stock%' OR Name LIKE '%PPR Queue Call Center%' LIMIT 1].id;
        Lead lead = new Lead(Phone = '+79122769431',
                LastName = 'testLastName', FirstName = 'testFirstName', MiddleName = 'testMiddleName',
                OwnerId = queueId, Region__c = fieldRegion.Label,
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567891',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = recordTypeLead);
        insert lead;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        controller.inputRecordId = lead.Id;
        controller.getRecordAccess();

        controller.params = new RecordAssignCheckParams();
        controller.params.currentRegion = lead.Region__c;
        controller.params.contact.lastName = 'testLastName';
        controller.params.contact.firstName = 'testFirstName';
        controller.params.contact.middleName = 'testMiddleName';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.params.activity.type = controller.resultTypes.get('Post').getValue();
        controller.changeCurrentGroup();
        controller.refreshForm();

        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Lead> resultList = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
        system.assertEquals(resultList.get(0).OwnerId, rootUser.Id);
    }

    ///--------------------------------------------------TESTS FO OPPORTUNITY ----------------------------------------------------------------//

    @isTest
    static void testOpportunity1() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        Account account = new Account(Name = 'test1234578910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = userId,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Contact contact = new Contact(Salutation = 'Herr', FirstName = 'testFirstName', MiddleName = 'testMiddleName', LastName = 'testLastName', AccountId = account.Id, Email = 'test1@test.com', RecordTypeId = recordTypeContact);
        insert contact;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';
        controller.params.hasVehicleFleet = 'No';
        
        controller.params.activity.type = controller.resultTypes.get('Meeting').getValue();
        controller.refreshForm();

        Test.startTest();
        controller.savePhonesData();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, fieldRegion.Assigned_Team_Lead__c);
    }

    @isTest
    static void testOpportunity_CallBack() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        List<User> keyUser = [SELECT Id, Name FROM User WHERE UserRole.Name in ('PPR Key Accounts Manager', 'PPR Teamleader KAM') AND IsActive = true LIMIT 1];
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = keyUser.get(0).Id,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = keyUser.get(0).Id,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Contact contact = new Contact(Salutation = 'Herr', LastName = 'Test3', AccountId = account.Id, Email = 'test3@test.com', RecordTypeId = recordTypeContact);
        insert contact;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();

        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        system.debug(controller.params.recordStatus);

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.params.activity.type = controller.resultTypes.get('Callback').getValue();
        controller.params.activity.description = 'test11';
        controller.changeCurrentGroup();
        controller.refreshForm();

        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId, Description FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, opportunity.OwnerId);
        system.assert(resultList.get(0).Description != null && resultList.get(0).Description.indexOf('test11') != -1);
    }

    @isTest
    static void testOpportunityInProgressWithProbability() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        Account account = new Account(Name = 'test1234578910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = userId,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Qualified Lead', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now(), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Opportunity opportunity2 = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity2;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        String startedOwnerId = opportunity.OwnerId;
        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.changeCurrentGroup();
        controller.refreshForm();

        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, startedOwnerId);
    }

    @isTest
    static void testOpportunityInProgressZeroProbability() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        Account account = new Account(Name = 'test1234578910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = userId,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now(), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Opportunity opportunity2 = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity2;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        String startedOwnerId = opportunity.OwnerId;
        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.changeCurrentGroup();
        controller.refreshForm();

        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, startedOwnerId);
    }

    @isTest
    static void testOpportunityMulti() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = userId,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Opportunity opportunity2 = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity2;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.params.activity.type = controller.resultTypes.get('Online transfer call').getValue();
        controller.changeCurrentGroup();
        controller.refreshForm();

        String ownerId = controller.params.currentMember;
        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, ownerId);
    }

    @isTest
    static void testOpportunityOfKeyUser() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        List<User> keyUser = [SELECT Id, Name FROM User WHERE UserRole.Name in ('PPR Key Accounts Manager', 'PPR Teamleader KAM') AND IsActive = true LIMIT 1];
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = keyUser.get(0).Id,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = keyUser.get(0).Id,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Contact contact = new Contact(Salutation = 'Herr', LastName = 'Test3', AccountId = account.Id, Email = 'test3@test.com', RecordTypeId = recordTypeContact);
        insert contact;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();

        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        system.debug(controller.params.recordStatus);

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.params.activity.type = controller.resultTypes.get('Online transfer call').getValue();
        controller.changeCurrentGroup();
        controller.refreshForm();

        String ownerId = controller.params.currentMember;
        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, ownerId);
    }

    @isTest
    static void testOpportunityMovedToStart() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = userId,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Moved to Start', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Contact contact = new Contact(Salutation = 'Herr', LastName = 'Test2', AccountId = account.Id, Email = 'test2@test.com', RecordTypeId = recordTypeContact);
        insert contact;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        String startedOwnerId = opportunity.OwnerId;
        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        controller.params.contact.lastName = 'aa';
        controller.params.contact.firstName = 'test';
        controller.params.contact.middleName = 'ff';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.currentGroup = 'PPR_Bryansk_Partner_Sales_1';
        controller.changeCurrentGroup();
        controller.refreshForm();

        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, startedOwnerId);
    }

    @isTest
    static void testOpportunityWithExistingContact() {
        AccountTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        OpportunityTriggerHandler.enablesTrigger = false; // needs to create correct opportunity/account for tests
        Account account = new Account(Name = 'test1234578910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                Phone = '+79122769431', Region__c = fieldRegion.Label, INN__C = '1234567891', OwnerId = userId,
                RecordTypeId = recordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), OwnerId = userId,
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Contact contact = new Contact(Salutation = 'Herr', FirstName = 'testFirstName', MiddleName = 'testMiddleName', LastName = 'testLastName', AccountId = account.Id, Email = 'test1@test.com', RecordTypeId = recordTypeContact);
        insert contact;

        RecordAssignCheckRuCtrl controller = new RecordAssignCheckRuCtrl();
        controller.init();
        controller.inputRecordId = opportunity.Id;
        controller.getRecordAccess();

        controller.params.contact.lastName = 'testLastName';
        controller.params.contact.firstName = 'testFirstName';
        controller.params.contact.middleName = 'testMiddleName';
        controller.params.contact.position = 'title';
        controller.params.contact.phone = '+79852769431';
        controller.params.contact.phoneSecond = '+79852769432';
        controller.params.contact.email = 'test1@gmail.com';
        controller.params.contact.emailSecond = 'test2@gmail.com';
        controller.params.expectedVolume.potential_Liters = '4000';
        controller.params.expectedVolume.potential_Rub = '2';
        controller.params.expectedVolume.potential_Cars = '3';
        controller.params.expectedVolume.potential_Trucks = '4';

        controller.params.activity.type = controller.resultTypes.get('Meeting').getValue();
        controller.refreshForm();

        Test.startTest();
        controller.submitForm();
        Test.stopTest();

        List<Opportunity> resultList = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity.Id];
        system.assertEquals(resultList.get(0).OwnerId, fieldRegion.Assigned_Team_Lead__c);
    }

}