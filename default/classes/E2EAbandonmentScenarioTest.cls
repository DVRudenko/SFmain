@IsTest
private class E2EAbandonmentScenarioTest {

    private static final String BUSINESS_PROCESS = GlobalUtils.BusinessProcessType.E2EClassic.name();

    static {
        CFUtilsTest.createCFSettingsForRussia(true);
    }

    /*******************************************************************************
    *  Name            : creatingOpportunityTest()
    *  Summary         : test update  e2eAbandonment status on Opportunity
    *  CreatedDate     : 24/04/2018
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void creatingOpportunityTest1() {
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

        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Belgium-FR', user.id);
        insert e2eGeneralSettings;

        List<RecordType> euroshellRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE Name = 'Euroshell'
                AND SobjectType = 'Opportunity'
        ];

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Belgium-FR');
        insert account;

        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Prospecting', CloseDate = system.today(), Angebotsdauer__c = '3 Monate',
                Accountid = account.Id, E2E_Last_Activity__c = system.now().addMinutes(-40), E2E__c = true,
                RecordTypeId = euroshellRecordType.get(0).Id,
                E2E_Active_Step__c = 1, E2E_Active_Substep__c = 'Search company');
        insert opportunity;
        Integer rand = Math.round(Math.random() * 100000);

        Test.startTest();
        E2EAbandonmentScenarioBatch e2eAbandonmentBatch = new E2EAbandonmentScenarioBatch();
        Database.executeBatch(e2eAbandonmentBatch);
        Test.stopTest();

        List<Opportunity> testList = [
                SELECT Id, E2E_Last_Activity__c, E2E_Status__c, E2E_Sub_Status__c, Owner.Name
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assertEquals(testList.get(0).E2E_Status__c, 'Abandoned (hard)');
        System.assertEquals(testList.get(0).E2E_Sub_Status__c, 'Marketing automation');
        System.assertEquals('test', testList.get(0).Owner.Name);
    }

    @isTest
    public static void creatingOpportunityTest2() {
        // 00520000005vYf3 - Y. Aden-Farah user ID
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Germany', '00520000005vYf3');
        insert e2eGeneralSettings;

        List<RecordType> euroshellRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE Name = 'Euroshell'
                AND SobjectType = 'Opportunity'
        ];

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Prospecting', CloseDate = system.today(), Angebotsdauer__c = '3 Monate',
                Accountid = account.Id, E2E_Last_Activity__c = system.now().addMinutes(-40), E2E__c = true,
                RecordTypeId = euroshellRecordType.get(0).Id,
                E2E_Active_Step__c = 1, E2E_Active_Substep__c = 'Search company');
        insert opportunity;

        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;

        LiveChatTranscript newChat = new LiveChatTranscript();
        newChat.LiveChatVisitorId = newVisitor.Id;
        newChat.Body = 'test123';
        newChat.RequestTime = system.now();
        newChat.StartTime = system.now();
        newChat.E2E_Step__c = '1';
        newChat.opportunity__c = opportunity.Id;
        newChat.Type__c = 'offline';
        newChat.Mode_of_initialization__c = 'manual';
        insert newchat;

        LiveChatTranscript newChat2 = new LiveChatTranscript();
        newChat2.LiveChatVisitorId = newVisitor.Id;
        newChat2.Body = 'test123';
        newChat2.RequestTime = system.now();
        newChat2.StartTime = system.now();
        newChat2.E2E_Step__c = '1';
        newChat2.opportunity__c = opportunity.Id;
        newChat2.Type__c = 'offline';
        newChat2.Mode_of_initialization__c = 'manual';
        newChat2.Result__c = 'Problem solved';
        insert newChat2;

        Test.startTest();
        E2EAbandonmentScenarioBatch e2eAbandonmentBatch = new E2EAbandonmentScenarioBatch();
        Database.executeBatch(e2eAbandonmentBatch);
        Test.stopTest();

        List<Opportunity> testList = [
                SELECT Id, E2E_Last_Activity__c, E2E_Status__c, E2E_Sub_Status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assertEquals(testList.get(0).E2E_Status__c, 'Abandoned (hard)');
        System.assertEquals(testList.get(0).E2E_Sub_Status__c, 'Marketing automation');
    }

    @isTest
    public static void creatingOpportunityTest3() {
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Russia');
        insert account;

        E2E_Abandonment_Scenario_Settings__c settings = generateAbandonmentScenarioSettings();
        insert settings;

        List<RecordType> russiaRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND SobjectType = 'Opportunity'
        ];

        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Prospecting', CloseDate = system.today(), Angebotsdauer__c = '3 Monate',
                Accountid = account.Id, E2E_Last_Activity__c = system.now().addMinutes(-Integer.valueOf(settings.TimeToAbandonAndEmail__c + 10)), LeadSource = 'E2E Form RU',
                E2E_Status__c = 'Клиент Активен', E2E_Active_Step__c = 1, E2E_Active_Substep__c = 'Информация о заказе', RecordTypeId = russiaRecordType.get(0).Id, Business_process__c = BUSINESS_PROCESS);
        insert opportunity;

        Test.startTest();
        E2EAbandonmentScenarioBatch e2eAbandonmentBatch = new E2EAbandonmentScenarioBatch();
        Database.executeBatch(e2eAbandonmentBatch);
        Test.stopTest();

        List<Opportunity> testList = [
                SELECT Id, E2E_Last_Activity__c, E2E_Status__c, E2E_Sub_Status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assertEquals(testList.get(0).E2E_Status__c, 'Клиент не активен');
        System.assertEquals(testList.get(0).E2E_Sub_Status__c, 'Автоматическое письмо');
    }

    @isTest
    public static void creatingOpportunityTest4() {
        insert new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Call_Center_Managers__c = 'custom@custom.ru;',
                Domain_Url__c = 'https://cs85.salesforce.com',
                Inbound_Managers__c = 'custom@custom.ru;',
                Locator_Gaz_url__c = 'https://locator.transitcard.ru/?product=180',
                Locator_Rover_url__c = 'https://locator.transitcard.ru/?product=170',
                Locator_Shell_url__c = 'https://locator.transitcard.ru/?product=190',
                Main_Managers__c = 'custom@custom.ru;',
                Middleware_Url__c = 'http://91.240.172.56/PPRMiddleware-1',
                Middleware_Token__c = 'token',
                Number_Of_Cards__c = 10,
                Number_of_Cards_Card__c = 6,
                Prepay_Amount__c = 2000,
                Service_Managers__c = 'custom@custom.ru;'
        );

        E2E_Abandonment_Scenario_Settings__c settings = generateAbandonmentScenarioSettings();
        insert settings;

        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Russia');
        insert account;

        List<RecordType> russiaRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE Name = 'Russian Sales'
                AND SobjectType = 'Opportunity'
        ];

        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Prospecting', CloseDate = system.today(), Angebotsdauer__c = '3 Monate',
                Accountid = account.Id, E2E_Last_Activity__c = system.now().addMinutes(-Integer.valueOf(settings.TimeToManual__c + 61)), LeadSource = 'E2E Form RU',
                E2E_Status__c = 'Клиент не активен', E2E_Sub_Status__c = 'Автоматическое письмо', E2E_Sales_Type__c = 'Чистый e2e',
                E2E_Active_Step__c = 1, E2E_Active_Substep__c = 'Информация о заказе', RecordTypeId = russiaRecordType.get(0).Id, Business_process__c = BUSINESS_PROCESS);
        insert opportunity;

        Test.startTest();
        E2EAbandonmentScenarioBatch e2eAbandonmentBatch = new E2EAbandonmentScenarioBatch();
        Database.executeBatch(e2eAbandonmentBatch);
        Test.stopTest();

        List<Opportunity> testList = [
                SELECT Id, E2E_Last_Activity__c, E2E_Status__c, E2E_Sub_Status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assertEquals(testList.get(0).E2E_Status__c, 'Клиент не активен');
        System.assertEquals(testList.get(0).E2E_Sub_Status__c, 'Автоматическое письмо');  //SF-783
    }

    @isTest
    public static void creatingOpportunityTest5() {
        insert new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Call_Center_Managers__c = 'custom@custom.ru;',
                Domain_Url__c = 'https://cs85.salesforce.com',
                Inbound_Managers__c = 'custom@custom.ru;',
                Locator_Gaz_url__c = 'https://locator.transitcard.ru/?product=180',
                Locator_Rover_url__c = 'https://locator.transitcard.ru/?product=170',
                Locator_Shell_url__c = 'https://locator.transitcard.ru/?product=190',
                Main_Managers__c = 'custom@custom.ru;',
                Middleware_Url__c = 'http://91.240.172.56/PPRMiddleware-1',
                Middleware_Token__c = 'token',
                Number_Of_Cards__c = 10,
                Number_of_Cards_Card__c = 6,
                Prepay_Amount__c = 2000,
                Service_Managers__c = 'custom@custom.ru;'
        );

        E2E_Abandonment_Scenario_Settings__c settings = generateAbandonmentScenarioSettings();
        insert settings;

        User user = [
                SELECT id
                FROM User
                WHERE Name = 'Integration Administrator RU'
                LIMIT 1
        ].get(0);

        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'];

        Fleetcor_Profile_Info_Settings__c e2esSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'API Only',
                ProfileId__c = p.Id);
        insert e2esSettings;

        System.runAs(user) {
            Account account = new Account(Name = 'test1', BillingPostalCode = '1231', OwnerId = user.id, BillingCountry = 'Russia');
            insert account;

            List<RecordType> russiaRecordType = [
                    SELECT id, name
                    FROM RecordType
                    WHERE Name = 'Russian Sales'
                    AND SobjectType = 'Opportunity'
            ];

            Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Prospecting', CloseDate = system.today(),
                    Angebotsdauer__c = '3 Monate', Accountid = account.Id, E2E_Last_Activity__c = system.now().addMinutes(-Integer.valueOf(settings.TimeToManual__c + 61)),
                    LeadSource = 'E2E Form RU', E2E_Status__c = 'Клиент не активен', E2E_Sub_Status__c = 'Автоматическое письмо',
                    E2E_Active_Step__c = 1, E2E_Active_Substep__c = 'Информация о заказе',
                    RecordTypeId = russiaRecordType.get(0).Id, OwnerId = user.id, Business_process__c = BUSINESS_PROCESS);
            insert opportunity;


            Test.startTest();
            E2EAbandonmentScenarioBatch e2eAbandonmentBatch = new E2EAbandonmentScenarioBatch();
            Database.executeBatch(e2eAbandonmentBatch);
            Test.stopTest();

            List<Opportunity> testList = [
                    SELECT Id, E2E_Last_Activity__c, E2E_Status__c, E2E_Sub_Status__c
                    FROM Opportunity
                    WHERE Id = :opportunity.Id
            ];

            System.assertEquals(testList.get(0).E2E_Status__c, 'Клиент не активен');
            System.assertEquals(testList.get(0).E2E_Sub_Status__c, 'Автоматическое письмо'); //SF-783
        }
    }

    
    @isTest
    public static void creatingOpportunityTest6() {
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];
        User user = [
                SELECT Id, Name 
                FROM User
                WHERE UserRoleId = :ur.Id AND isActive = true
                LIMIT 1
        ].get(0);

        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Germany', user.Id);
        insert e2eGeneralSettings;

        List<RecordType> euroshellRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE Name = 'Euroshell'
                AND SobjectType = 'Opportunity'
        ];

        Account account = new Account(Name = 'test6', BillingPostalCode = '23123', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'test1', StageName = 'Prospecting', CloseDate = system.today(), Angebotsdauer__c = '3 Monate',
                E2E_Manual_Adoption_Date__c = Datetime.now(), E2E_Assistant__c = user.Name,
                Accountid = account.Id, E2E_Last_Activity__c = system.now().addMinutes(-40), E2E__c = true,
                RecordTypeId = euroshellRecordType.get(0).Id,
                E2E_Active_Step__c = 1, E2E_Active_Substep__c = 'Search company');
        insert opportunity;

        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;

        LiveChatTranscript newChat = new LiveChatTranscript();
        newChat.LiveChatVisitorId = newVisitor.Id;
        newChat.Body = 'test123';
        newChat.RequestTime = system.now();
        newChat.StartTime = system.now();
        newChat.E2E_Step__c = '1';
        newChat.opportunity__c = opportunity.Id;
        newChat.Type__c = 'offline';
        newChat.Mode_of_initialization__c = 'manual';
        insert newchat;

        LiveChatTranscript newChat2 = new LiveChatTranscript();
        newChat2.LiveChatVisitorId = newVisitor.Id;
        newChat2.Body = 'test123';
        newChat2.RequestTime = system.now();
        newChat2.StartTime = system.now();
        newChat2.E2E_Step__c = '1';
        newChat2.opportunity__c = opportunity.Id;
        newChat2.Type__c = 'offline';
        newChat2.Mode_of_initialization__c = 'manual';
        newChat2.Result__c = 'Problem solved';
        insert newChat2;

        Test.startTest();
        E2EAbandonmentScenarioBatch e2eAbandonmentBatch = new E2EAbandonmentScenarioBatch();
        Database.executeBatch(e2eAbandonmentBatch);
        Test.stopTest();

        List<Opportunity> testList = [
                SELECT Id, E2E_Last_Activity__c, E2E_Status__c, E2E_Sub_Status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assertEquals(testList.get(0).E2E_Status__c, 'Abandoned (hard)');
        System.assertEquals(testList.get(0).E2E_Sub_Status__c, 'Marketing automation');
    }

    public static E2E_Form_General_Settings__c generateE2EGeneralSettings(String country, String userId) {
        E2E_Form_General_Settings__c e2eGeneralSettings = new E2E_Form_General_Settings__c(
                Name = country,
                Abandonment_User__c = userId,
                Enable_authorization_non_granted_check__c = false,
                Files_Generator_Url__c = 'http://e2e-e2efleetcor.cs108.force.com',
                Payment_URL__c = 'https://e2e-e2efleetcor.cs108.force.com',
                Set_GFN_Status__c = false,
                Test_Mode__c = false
        );
        return e2eGeneralSettings;
    }

    public static E2E_Abandonment_Scenario_Settings__c generateAbandonmentScenarioSettings() {
        E2E_Abandonment_Scenario_Settings__c scenario_settings = new E2E_Abandonment_Scenario_Settings__c(
                Name = 'RuAbandonScenario',
                TimeToAbandonAndEmail__c = 60,
                TimeToManual__c = 5
        );
        return scenario_settings;
    }
}