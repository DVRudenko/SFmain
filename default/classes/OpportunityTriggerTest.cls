@isTest
private class OpportunityTriggerTest {

    public static final Profile SYS_ADMIN_PROFILE = ProfileManager.getProfileByName(System.Label.System_Administrator);
    public static final UserRole SYS_ADMIN_ROLE = UserRoleManager.getUserRoleByName(UserRoleManagerTest.PPR_FLEETCOR_ROLE_LABEL);
    public static final String TEST_USER_NAME = 'aaaa';

    @TestSetup
    private static void setup() {
        insert E2EMoveToStartDataTestFactory.createUser('aaaa', SYS_ADMIN_PROFILE.Id, SYS_ADMIN_ROLE.Id);
    }

    @IsTest
    private static void testChangeRussianCreditFactoryReportsOwner() {
        Id testUserId = ([
                SELECT Id
                FROM User
                WHERE Alias = :TEST_USER_NAME
        ]).get(0).Id;

        Account account = CFTestDataFactory.createAccount();
        Account account2 = CFTestDataFactory.createAccount();
        account2.INN__c = '6670429075';
        insert new List<Account> {account, account2};

        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        Opportunity opportunity2 = CFTestDataFactory.createOpportunity(account2);
        insert new List<Opportunity> {opportunity, opportunity2};

        List<Credit_Factory_Report__c> reports = new List<Credit_Factory_Report__c>();
        List<Credit_Factory_Report__c> reports2 = new List<Credit_Factory_Report__c>();

        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Credit_Factory_Report__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        for (String recordType : new CFRTriggerHandlerHelper().getRecordTypesSetting(CFRTriggerHandlerHelper.RT_FOR_CHANGE_OWNER)) {
            Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
            report.RU_scoring_type__c = null;
            report.RU_scoring_decision__c = null;
            report.RecordTypeId = recordTypeInfoMap.get(recordType).getRecordTypeId();
            reports.add(report);

            Credit_Factory_Report__c report2 = CFTestDataFactory.createCreditFactoryReport(account2, opportunity2);
            report2.RU_scoring_type__c = null;
            report2.RU_scoring_decision__c = null;
            report2.RecordTypeId = recordTypeInfoMap.get(recordType).getRecordTypeId();
            reports2.add(report2);
        }

        Credit_Factory_Report__c nonRuReport = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        nonRuReport.RU_scoring_type__c = null;
        nonRuReport.RU_scoring_decision__c = null;
        nonRuReport.RecordTypeId = CFUtils.CFR_RECORD_TYPES.get(GlobalUtils.CreditFactoryReportRecordTypes.Company_Info.name()).getRecordTypeId();
        insert reports;
        insert nonRuReport;

        opportunity.OwnerId = testUserId;
        opportunity2.Name = 'aaaaaa';
        update new List<Opportunity> {opportunity2, opportunity};

        Set<Id> ids = new Set<Id>();
        for (Credit_Factory_Report__c r : reports) {
            ids.add(r.Id);
        }
        reports = ([
                SELECT OwnerId
                FROM Credit_Factory_Report__c
                WHERE Id IN :ids
        ]);

        Set<Id> ids2 = new Set<Id>();
        for (Credit_Factory_Report__c r : reports2) {
            ids2.add(r.Id);
        }
        reports2 = ([
                SELECT OwnerId
                FROM Credit_Factory_Report__c
                WHERE Id IN :ids2
        ]);

        nonRuReport = ([
                SELECT OwnerId
                FROM Credit_Factory_Report__c
                WHERE Id = :nonRuReport.Id
        ]).get(0);

        for (Credit_Factory_Report__c r : reports) {
            System.assertEquals(testUserId, r.OwnerId);
        }
        for (Credit_Factory_Report__c r : reports2) {
            System.assertEquals(UserInfo.getUserId(), r.OwnerId);
        }
        System.assertEquals(UserInfo.getUserId(), nonRuReport.OwnerId);
    }

    @IsTest
    private static void testProcessOpportunityScoringWrongRecordType() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'ОАО ТУПАК ЖИВ';
        opportunity.Business_process__c = GlobalUtils.BusinessProcessType.Standard.name();
        opportunity.RecordTypeId = GlobalUtils.getRecordTypeId(Opportunity.class.getName(), GlobalUtils.OpportunityRecordTypes.CCS_Opportunity.name());
        opportunity.Type = 'New GFN';
        opportunity.StageName = 'Qualify';
        opportunity.Product_Solicited__c = 'CCS Limit';
        opportunity.Sec_Channel__c = 'Inbound';
        opportunity.AccountId = account.Id;
        opportunity.CloseDate = Date.today();
        Test.startTest();
        insert opportunity;
        Test.stopTest();

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFR(
                opportunity.Id,
                CFUtils.FRAUD_SCORING_TYPE,
                CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
        );
        System.assert(report2 == null);

    }

    @IsTest
    private static void testProcessOpportunityScoringWrongStage() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractChecking);
        Test.startTest();
        insert opportunity;
        Test.stopTest();

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFR(
                opportunity.Id,
                CFUtils.FRAUD_SCORING_TYPE,
                CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
        );
        System.assert(report2 == null);

    }

    @IsTest
    private static void testProcessOpportunityScoringOnInsert() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        Test.startTest();
        insert opportunity;
        Test.stopTest();

        Map<String, Object> settings = CFUtils.getScoringSettings();
        Boolean active = (Boolean) settings.get('active');

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFR(
                opportunity.Id,
                CFUtils.FRAUD_SCORING_TYPE,
                CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
		);

        if (active) {
		 	System.assert(report2 != null);
        } else {
			System.assert(report2 == null);
		}
    }

    @IsTest
    public static void testProcessOpportunityScoringOnUpdate() {
        E2EFormRuTestUtils.initCustomSettings();
        CF_Settings__c cfSettings = CFUtilsTest.createCFSettingsForRussia(true);
        cfSettings.Check_on_opportunity_create__c = false;
        insert cfSettings;
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.ContractChecking);
        insert opportunity;
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead);
        Test.startTest();
        update opportunity;
		Test.stopTest();

		Map<String, Object> settings = CFUtils.getScoringSettings();
        Boolean active = (Boolean) settings.get('active');

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFR(
                opportunity.Id,
                CFUtils.FRAUD_SCORING_TYPE,
                CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
		);
		if (active) {
			System.assert(report2 != null);
		} else {
			System.assert(report2 == null);
		}
    }

    @IsTest
    private static void testE2E20SwitchedToManual() {
        Account acc = new Account(Name = 'test acc', BillingCountry = 'Poland');
        insert acc;

        Contact con = new Contact(Salutation = 'Herr', LastName = 'test', AccountId = acc.Id);
        insert con;

        E2E_Data_Object__c dataObject = new E2E_Data_Object__c(Name = 'test name', E2E_Status__c = 'In progress');
        insert dataObject;

        User u = [SELECT Id FROM User WHERE Profile.Name = 'Sales Inbound' AND IsActive = TRUE LIMIT 1];

        Opportunity opp = new Opportunity(
                OwnerId = u.Id,
                E2E_2__c = true,
                E2E_Status__c = 'In progress',
                Name = 'test',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                AccountId = acc.Id,
                E2E_Data_Object__c = dataObject.Id);
        insert opp;

        System.runAs(u) {
            Test.startTest();
                opp.Total_number_of_vehicles__c = 2;
                update opp;
            Test.stopTest();
        }

        Opportunity testopp = [SELECT E2E_Status__c, E2E_Sales_Type__c FROM Opportunity WHERE Id = :opp.Id];
        E2E_Data_Object__c testdo = [SELECT E2E_Status__c FROM E2E_Data_Object__c WHERE Id = :dataObject.Id];

        System.assert(testopp.E2E_Status__c == 'Finished');
        System.assert(testopp.E2E_Sales_Type__c == 'E2E downgraded to manual');
        System.assert(testdo.E2E_Status__c == 'Finished');
    }

    @IsTest
    private static void setOpportunityStandardBusinessProcessTestNotRussianRecordType() {
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.RecordTypeId = GlobalUtils.getRecordTypeId(Opportunity.class.getName(), GlobalUtils.OpportunityRecordTypes.CCS_Opportunity.name());
        opportunity.Type = 'New GFN';
        opportunity.StageName = 'Qualify';
        opportunity.Product_Solicited__c = 'CCS Limit';
        opportunity.Sec_Channel__c = 'Inbound';
        opportunity.Business_process__c = null;

        OpportunityTriggerHandler.setOpportunityStandardBusinessProcess(new List<Opportunity> {opportunity});
        System.assertEquals(null, opportunity.Business_process__c);
    }

    @IsTest
    private static void setOpportunityStandardBusinessProcessTestE2EOpportunityCase1() {
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Business_process__c = null;
        opportunity.Source_of_Lead_o__c = 'E2E Form RU';

        OpportunityTriggerHandler.setOpportunityStandardBusinessProcess(new List<Opportunity> {opportunity});
        System.assertEquals(null, opportunity.Business_process__c);
    }

    @IsTest
    private static void setOpportunityStandardBusinessProcessTestE2EOpportunityCase2() {
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Business_process__c = null;
        opportunity.LeadSource = 'E2E Form RU';

        OpportunityTriggerHandler.setOpportunityStandardBusinessProcess(new List<Opportunity> {opportunity});
        System.assertEquals(null, opportunity.Business_process__c);
    }

    @IsTest
    private static void setOpportunityStandardBusinessProcessTestBusinessProcessNotEmpty() {
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Business_process__c = GlobalUtils.BusinessProcessType.E2EBusiness.name();

        OpportunityTriggerHandler.setOpportunityStandardBusinessProcess(new List<Opportunity> {opportunity});
        System.assertEquals(GlobalUtils.BusinessProcessType.E2EBusiness.name(), opportunity.Business_process__c);
    }

    @IsTest
    private static void setOpportunityStandardBusinessProcessTest() {
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Business_process__c = null;

        OpportunityTriggerHandler.setOpportunityStandardBusinessProcess(new List<Opportunity> {opportunity});
        System.assertEquals(GlobalUtils.BusinessProcessType.Standard.name(), opportunity.Business_process__c);
    }

    @IsTest
    private static void verifyCompanyTestNotStandardBusinessProcess() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(true);
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Business_process__c = GlobalUtils.BusinessProcessType.E2EClassic.name();
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestNotRussianOpportunity() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(true);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.RecordTypeId = GlobalUtils.getRecordTypeId(Opportunity.class.getName(), GlobalUtils.OpportunityRecordTypes.CCS_Opportunity.name());
        opportunity.Type = 'New GFN';
        opportunity.StageName = 'Qualify';
        opportunity.Product_Solicited__c = 'CCS Limit';
        opportunity.Sec_Channel__c = 'Inbound';
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestNotValidOpportunityStage() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(true);
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations);
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestOpportunityAlreadyBeingChecked() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(true);
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.CF_checking__c = true;
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestNoCustomSettingsExist() {
        insert CFTestDataFactory.createCustomSettings();
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestOpportunityStageNotChanged() {
        insert CFTestDataFactory.createCustomSettings();
        CF_Settings__c cfSettings = CFUtilsTest.createCFSettingsForRussia(true);
        cfSettings.Check_on_opportunity_create__c = false;
        insert cfSettings;
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead);
        update opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestOnInsert() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(true);
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Business_process__c = null;
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(!jobs.isEmpty());

    }

    @IsTest
    private static void verifyCompanyTestSkipOnInsert() {
        insert CFTestDataFactory.createCustomSettings();
        CF_Settings__c cfSettings = CFUtilsTest.createCFSettingsForRussia(true);
        cfSettings.Check_on_opportunity_create__c = false;
        insert cfSettings;
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());

    }

    @IsTest
    private static void verifyCompanyTestOnUpdate() {
        insert CFTestDataFactory.createCustomSettings();
        CF_Settings__c cfSettings = CFUtilsTest.createCFSettingsForRussia(true);
        cfSettings.Check_on_opportunity_create__c = false;
        insert cfSettings;
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations);
        insert opportunity;
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead);
        update opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(!jobs.isEmpty());
    }

    @IsTest
    private static void verifyCompanyTestSkipOnUpdate() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations);
        insert opportunity;
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead);
        update opportunity;

        ApexClass apexClass = ([
                SELECT Id, Name
                FROM ApexClass
                WHERE Name = :CFCheckCompanyQueueableRu.class.getName()
                LIMIT 1
        ]);
        List<AsyncApexJob> jobs = ([
                SELECT Id, ApexClassId
                FROM AsyncApexJob
                WHERE ApexClassId =: apexClass.Id
                AND JobType = 'Queueable'
        ]);
        System.assert(jobs.isEmpty());
    }

    @isTest
    private static void sendNotificationEmail() {
        Account newAccount = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert newAccount;

        Email_Notifications__c notification = new Email_Notifications__c(
                Name = 'Opportunity Welcome Letters',
                Email__c = 'test@test.com',
                Enabled__c = true);
        insert notification;

        BackOffice_Notifications__c customSettings = new BackOffice_Notifications__c(
                Name = 'Germany',
                Email__c = 'test@test.com',
                Active__c = true);
        insert customSettings;

        String recId = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1].Id;

        Opportunity newOpp = new Opportunity(
                RecordTypeId = recId,
                Anzahl_der_Karten__c = 5,
                Zahlungsart__c = 'Lastschrift',
                Zahlungsziel__c = '7',
                Product__c = 'None',
                StageName = 'CreditCheck',
                Name = 'test opp',
                Angebotsdauer__c = '3 Monate',
                CloseDate = Date.today(),
                AccountId = newAccount.Id);
        insert newOpp;

        Contact con = new Contact(
                FirstName = 'conName',
                LastName = 'conFamily',
                Email = 'test@example.com',
                Salutation = 'Herr',
                AccountId = newAccount.Id);
        insert con;

        OpportunityContactRole testRole = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = newOpp.Id,
                isPrimary = true);
        insert testRole;

        newOpp.StageName = 'Closed Won';
        update newOpp;

        List<Task> testTaskList = [
                SELECT Subject
                FROM Task
                WHERE (Subject = 'Email: Welcome Email Sent' OR Subject = 'SENT: Email about new Customer was sent to Back Office') AND WhatId = :newOpp.Id];
        system.assertEquals(2, testTaskList.size());
    }


    @isTest
    private static void sendNotificationShellUniversalCardEmail() {
        Account newAccount = new Account(
                Name = 'test',
                BillingCountry = 'Poland');
        insert newAccount;

        BackOffice_Notifications__c customSettings = new BackOffice_Notifications__c(
                Name = 'Poland_Shell Universal Card',
                Email__c = 'test@test.com',
                Active__c = true);
        insert customSettings;

        String recId = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Shell Universal Card' AND SobjectType = 'Opportunity' LIMIT 1].Id;

        Opportunity newOpp = new Opportunity(
                RecordTypeId = recId,
                Anzahl_der_Karten__c = 5,
                Zahlungsart__c = 'Lastschrift',
                Zahlungsziel__c = '7',
                Product__c = 'None',
                StageName = 'CreditCheck',
                Name = 'test opp',
                Angebotsdauer__c = '3 Monate',
                CloseDate = Date.today(),
                AccountId = newAccount.Id);
        insert newOpp;

        Contact con = new Contact(
                FirstName = 'conName',
                LastName = 'conFamily',
                Email = 'test@example.com',
                Salutation = 'Herr',
                AccountId = newAccount.Id);
        insert con;

        OpportunityContactRole testRole = new OpportunityContactRole(
                ContactId = con.Id,
                OpportunityId = newOpp.Id,
                isPrimary = true);
        insert testRole;

        newOpp.StageName = 'Closed Won';
        update newOpp;

        List<Task> testTaskList = [
                SELECT Subject
                FROM Task
                WHERE Subject = 'SENT: Email about new Customer was sent to Back Office' AND WhatId = :newOpp.Id];
        System.assertEquals(1, testTaskList.size());
    }


    /*******************************************************************************
    *  Name            : updateVouchersSentFieldTest()
    *  Summary         : after Opportunity StageName changes to "Closed Won" of update Vouchers Sent Field (increased by 1) in partner Account
    *  CreatedDate     : 18/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void updateVouchersSentFieldTest() {

        Test.startTest();
        RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Retailer'];
        Account partnerAccount = new Account(
                Name = 'test',
                GFN_Nr__c  = '123',
                RecordTypeId = rt.Id,
                Type = 'Customer',
                BillingCountry = 'Austria',
                Bundesland__c = 'Austria',
                Beschaeftigte__c = '1-4',
                Strasse_E__c = 'test',
                Hausnummer_E__c = 'test',
                PLZ_E__c = 'test',
                Ort_E__c = 'tet',
                Land_E__c = 'DE',
                OBN__c = 'test',
                Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'tes',
                PLZ_und_Ort__c = 'test',
                IBAN_des_Zahlungspflichtigen__c = 'tes',
                SWIFT_BIC__c = 'test',
                Land__c = 'test land',
                Vouchers_Sent__c = 0,
                Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
                Kraftstoffverbrauch_Liter_Monat__c = 2);
        insert partnerAccount;


        Lead newLead = new Lead(
                Country = 'Germany',
                CountryCode = 'DE',
                Company = 'test company',
                Salutation = 'Herr',
                Anzahl_der_Karten_Euroshell__c = 'test',
                Anzahl_der_Fahrzeuge__c = 2,
                FirstName = 'testName',
                LastName = 'testFam',
                Sec_Channel__c = 'Inbound',
                Phone = '3333333',
                LeadSource = 'Internet',
                Quali_Status__c = 'Refused to talk',
                Branche_NACE__c = 'Apotheken - 4773',
                Beschaeftigte__c = '1-4',
                Partner__c = partnerAccount.Id,
                Partner_OBN__c = 'test',
                Disable_for_KPI__c = FALSE
        );
        insert newLead;

        Email_Notifications__c notification = new Email_Notifications__c(
                Name = 'Opportunity Welcome Letters',
                Email__c = 'test@test.com',
                Enabled__c = true);
        insert notification;

        BackOffice_Notifications__c customSettings = new BackOffice_Notifications__c(
                Name = 'Germany',
                Email__c = 'test@test.com',
                Active__c = true);
        insert customSettings;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(newLead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();

        String newOppId = [SELECT ConvertedOpportunityId FROM Lead WHERE Id = :newLead.Id].ConvertedOpportunityId;

        Opportunity convOpp = [
                SELECT Name, StageName, Herkunft_Land__c, Angebotsdauer__c, Kraftstoffverbrauch_Liter_Monat__c, Anzahl_der_Karten__c, Derzeitige_Zahlungsmethode__c,
                        Kundensegment__c, Zahlungsart__c, Zahlungsziel__c, CloseDate, Last_Owner_Change_Date__c
                FROM Opportunity
                WHERE Id = :newOppId];

        convOpp.StageName = 'Closed Won';
        convOpp.Angebotsdauer__c = '3 Monate';
        convOpp.CloseDate = Date.today();
        update convOpp;

        List<Account> testAccountsList = [
                SELECT Name
                FROM Account
                WHERE Vouchers_Sent__c != 0];
        System.assertEquals(testAccountsList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : testSendToFleetmatics()
    *  Summary         : test send email to addresses from custom setting when fleetmatics lead is closed and won
    *  CreatedDate     : 12/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testSendToFleetmatics() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                LeadSource = 'Fleetmatics_new');
        insert opportunity;
        Fleetmatics_Notifications__c notification = new Fleetmatics_Notifications__c(
                Name = 'test',
                Email__c = 'test@test.com',
                Active__c = true);
        insert notification;
        opportunity.StageName = 'Closed Won';
        update opportunity;
        System.assertEquals(1, Limits.getEmailInvocations());
    }


    /*******************************************************************************
    *  Name            : changeToClosedWonAfterPendingSepaTest()
    *  Summary         : test change opportunity stage name from Pending Sales - SEPA Confirmation(exposed by Credit Factory) to Closed Won
    *  CreatedDate     : 14/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void changeToClosedWonAfterPendingSepaTest() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Pending Sales - SEPA Confirmation',
                Zahlungsart__c = 'Lastschrift',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Send_SEPA_approval_link__c = true);
        insert opportunity;

        opportunity.SEPA_Request_Approved__c = true;
        Test.startTest();
        update opportunity;
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(opportunitiesList.get(0).StageName, 'Closed Won');
    }


    /*******************************************************************************
    *  Name            : updatePaymentMethodSEPAApprovedTest()
    *  Summary         : test update Payment method when SEPA request approved
    *  CreatedDate     : 19/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void updatePaymentMethodSEPAApprovedTest() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Send_SEPA_approval_link__c = true);
        insert opportunity;

        opportunity.SEPA_Request_Approved__c = true;
        Test.startTest();
        update opportunity;
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT Zahlungsart__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(opportunitiesList.get(0).Zahlungsart__c, 'Lastschrift');
    }


    /*******************************************************************************
    *  Name            : updateStartsPaymentMethodSEPAApprovedTest()
    *  Summary         : test update Starts: Payment method when SEPA request approved
    *  CreatedDate     : 14/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void updateStartsPaymentMethodSEPAApprovedTest() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Send_SEPA_approval_link__c = true);
        insert opportunity;

        opportunity.SEPA_Request_Approved__c = true;
        Test.startTest();
        update opportunity;
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT Starts_Payment_method__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(opportunitiesList.get(0).Starts_Payment_method__c, 'Direct debit');
    }


    /*******************************************************************************
    *  Name            : updateCFStageClosedWonTest()
    *  Summary         : test setting CF Stage to Auto CW when Stage is set to Closed Won
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : 31/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void updateCFStageClosedWonTest() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Pending Credit - Contract Check',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Send_SEPA_approval_link__c = true);
        insert opportunity;

        opportunity.StageName = 'Closed Won';

        Test.startTest();
        update opportunity;
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Stage__c, Closed_Won_by_CF__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Auto CW', opportunitiesList.get(0).CF_Stage__c);
        System.assertEquals(true, opportunitiesList.get(0).Closed_Won_by_CF__c);
    }


    /*******************************************************************************
    *  Name            : updateStartsFieldsAfterClosedWonTest()
    *  Summary         : check fields update when opportunity is Closed to Won
    *  CreatedDate     : 3/09/2017
    *  ModifiedDate    : 3/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void updateStartsFieldsAfterClosedWonTest() {
        RecordType recordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Euroshell' AND SObjectType = 'Opportunity'];

        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                RecordTypeId = recordType.Id,
                Name = 'test',
                StageName = 'Prospecting',
                Angebotsdauer__c = '3 Monate',
                Anzahl_der_Karten__c = 3,
                CloseDate = Date.newInstance(2017, 03, 09));
        insert opportunity;

        opportunity.StageName = 'Closed Won';
        Test.startTest();
        update opportunity;
        Test.stopTest();

        Opportunity testOpportunity = [
                SELECT Starts_Schedule__c, Starts_Status_Delay__c, Starts_Number_of_Cards_Target__c, Starts_Status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(testOpportunity.Starts_Schedule__c, Date.newInstance(2017, 03, 10));
        System.assertEquals(testOpportunity.Starts_Status_Delay__c, false);
        System.assertEquals(testOpportunity.Starts_Number_of_Cards_Target__c, 3);
        System.assertEquals(testOpportunity.Starts_Status__c, '0. Request received');
    }


    /*******************************************************************************
    *  Name            : startsSLAcalculateTest()
    *  Summary         : check fields update when opportunity is Closed to Won
    *  CreatedDate     : 16/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void startsSLAcalculateTest() {
        Opportunity opportunity = new Opportunity(
                Name = 'test',
                StageName = 'Closed Won',
                Angebotsdauer__c = '3 Monate',
                Anzahl_der_Karten__c = 3,
                Starts_Overdue_days__c = 2,
                Starts_Sales_Completed_Update__c = true,
                CloseDate = Date.today());
        insert opportunity;

        Test.startTest();
        opportunity.Starts_Status__c = '0.5 Missing information';
        update opportunity;
        Test.stopTest();
    }

    /*******************************************************************************
    *  Name            : testLastDateChangeOwnerRUS()
    *  Summary         : check for change of field Last_Owner_Change_Date_RUS__c when changing owner
    *  CreatedDate     : 20/11/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testLastDateChangeOwnerRUS() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'];

        Fleetcor_Profile_Info_Settings__c e2esSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'API Only',
                ProfileId__c = p.Id);
        insert e2esSettings;

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;
        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;

        System.runAs(user) {
            Account account = new Account(Name = 'testt', BillingCountry = 'Germany');
            insert account;

            Id recordTypeId;
            if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
                recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                        'Российские продажи').getRecordTypeId();
            } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
                recordTypeId =
                        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
            }

            Opportunity opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Closed Won',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeId
            );
            insert opportunity;
            Opportunity testOpportunity = [
                    SELECT Last_Owner_Change_Date_RUS__c
                    FROM Opportunity
                    WHERE Name = 'testt'
            ];
            System.assertEquals(testOpportunity.Last_Owner_Change_Date_RUS__c.date(), Datetime.now().date());
        }
    }


    /*******************************************************************************
    *  Name            : testSendingReportToGfnAfterStartsStatusChanged()
    *  Summary         : check for change of field Starts_Status__c and send report to GFN
    *  CreatedDate     : 30/11/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testSendingReportToGfnAfterStartsStatusChanged() {
        Profile profile = [
                SELECT Id
                FROM Profile
                WHERE name = 'E2E Profile'
                LIMIT 1];

        List<Profile> e2eAdminUser = [SELECT Id FROM Profile WHERE Name = 'API Only' LIMIT 1];
        List<Fleetcor_Profile_Info_Settings__c> profilesSettings = new List<Fleetcor_Profile_Info_Settings__c>();
        Fleetcor_Profile_Info_Settings__c e2esSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'E2E Profile',
                ProfileId__c = profile.Id);
        profilesSettings.add(e2esSettings);

        Fleetcor_Profile_Info_Settings__c adminSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'API Only',
                ProfileId__c = e2eAdminUser.get(0).Id);
        profilesSettings.add(adminSettings);
        insert profilesSettings;

        User user = new User(
                ProfileId = profile.Id,
                Username = 'usertest' + System.now().millisecond() + '@fleetcor.de',
                Alias = 'test',
                Email = 'test@fleetcor.de',
                Country = 'Germany',
                CountryCode = 'DE',
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        GFNI_General_Settings__c customSetting = new GFNI_General_Settings__c();
        customSetting.Name = 'DE';
        customSetting.Application_Status__c = '/applicationstatus';
        customSetting.Create_Customer_and_Cards__c = '/customer';
        customSetting.Get_Customer_Id__c = '/customerId';
        customSetting.IsForRobot__c = true;
        customSetting.Number_Of_Send_Tries__c = 3;
        customSetting.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        customSetting.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        customSetting.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        customSetting.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        customSetting.Support_email__c = 'test@email.com';
        customSetting.Test_support_email__c = 'test@test.com';
        customSetting.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        customSetting.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        customSetting.Test_mode__c = true;
        insert customSetting;

        System.runAs(user){
            Account_GFN_Report_Email_Params__c customSettings = new Account_GFN_Report_Email_Params__c(
                    Name = 'Excel',
                    Attach_format__c = '.xls',
                    Email__c = 'test_robot_email@test.ru',
                    Email_body__c = 'Attached file is generated using Salesforce for a robot processing',
                    Test_mode__c = true,
                    Test_mode_email__c = 'test_robot@test.ru');
            insert customSettings;

            Account account = new Account(
                    Type = 'Customer',
                    Name = 'Test Account for GFN Report',
                    Gesellschaftsform__c = 'Gewerbebetrieb', // company form
                    Steuernummer__c = '3222831067', // tax id
                    HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '1111.222.333', // trade Register Number
                    Umsatzsteuer_ID__c = 'DE299022282',
                    BillingCountry = 'Germany',
                    BillingState = 'Rhineland-Palatinate',
                    BillingCity = 'LUDWIGSHAFEN',
                    BillingPostalCode = '66666',
                    BillingStreet = 'KASTANIENSTR. 12',
                    ShippingCountry = 'Germany',
                    ShippingState = 'Rhineland-Palatinate',
                    ShippingCity = 'LUDWIGSHAFEN',
                    ShippingPostalCode = '66666',
                    ShippingStreet = 'KASTANIENSTR. 12');
            insert account;

            Opportunity opportunity = new Opportunity(
                    AccountId = account.Id,
                    Name = 'Test Opportunity for GFN Report',
                    Sec_Channel__c = 'Inbound',
                    Language_Preference__c = 'German',
                    SWIFT_BIC__c = 'AABBCCFFXXX',
                    IBAN__c = 'DE28200444000612222222',
                    Credit_System_Number__c = '2155548666',
                    Product__c = 'Home Station offer (v.1)',
                    Angebotsdauer__c = '6 Monate',
                    ESI__c = '0233',
                    Total_number_of_vehicles__c = 12,
                    Total_consumption_l_month__c = 1200,
                    Zahlungsart__c = 'Lastschrift',
                    CurrencyIsoCode = 'EUR',
                    Zahlungsziel_Credit__c = '7',
                    Risk_Category__c = 'Low',
                    Rechnungsperiode__c = '30',
                    e_Invoicing_PDF__c = false,
                    Papierrechnung__c = false,
                    bearbeitet_von__c = 'Somebody Else',
                    Credit_System_Rating__c = '1',
                    Garantie__c = 'keine',
                    Garantie_other__c = 2000,
                    Eco_Fee__c = false,
                    StageName = 'Prospecting',
                    CloseDate = date.today().addMonths(1),
                    Starts_Status__c = '0. Request received');
            insert opportunity;

            List<Contact> contacts = new List<Contact>();
            for (Integer i = 0; i < 5; i++) {
                Contact contact = new Contact(
                        Salutation = 'Herr',
                        FirstName = 'Test Contact First Name ' + i,
                        LastName = 'Test Contact Last Name ' + i,
                        MiddleName = '',
                        AccountId = account.Id,
                        Phone = '+7992223344' + i,
                        MobilePhone = '',
                        Fax = '',
                        Email = i + '_test_contac@test.com');
                contacts.add(contact);
            }
            insert contacts;

            List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>();
            for (Contact contact : contacts) {
                Integer count = 1;
                OpportunityContactRole role = new OpportunityContactRole(
                        ContactId = contact.Id,
                        IsPrimary = (count == 1) ? true : false,
                        OpportunityId = opportunity.Id,
                        Role = 'Decision Maker');
                contactRoles.add(role);
                count++;
            }
            insert contactRoles;

            List<Tankkarten__c> cards = new List<Tankkarten__c>();
            for (Integer i = 0; i < 5; i++) {
                Tankkarten__c card = new Tankkarten__c(
                        Account__c = account.Id,
                        Opportunity__c =  opportunity.Id,
                        Gewuenschter_Kartentyp__c = 'Multi Network Card -- National',
                        Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)',
                        Fahrzeugtyp__c = 'PKW',
                        Firmenname_auf_der_Karte__c = 'FIRMENNAME AUF DER KARTE',
                        KFZ_Kennzeichen_oder_Fahrername__c = 'AA-AA 111' + i,
                        Driver_Name__c = 'DRIVER NAME ' + i,
                        Kilometerstand_Abfrage__c = true);
                cards.add(card);
            }
            insert cards;

            opportunity.Starts_Status__c = '0.9 Ready for GFN';
            Test.startTest();
            update opportunity;
            Test.stopTest();

            List<Mailing_Account_GFN_Report_Log__c> logs = [
                    SELECT Id, Account__c, Address__c, File_Name__c, Name, Opportunity__c, OwnerId, Sending_Status__c, Starts_Status_Changed_By__c
                    FROM Mailing_Account_GFN_Report_Log__c
                    WHERE Account__c = :account.Id
                    AND Opportunity__c = :opportunity.Id];

//            System.assertEquals(1, logs.size());
        }
    }


    /******************************************************************************
    *  Name            :
    *  Summary         :
    *  CreatedDate     :
    *  ModifiedDate    :
    *  Parameters      :
    *  Returns         :
    ******************************************************************************/
    @isTest
    private static void sendTotalConsumptionChangeAlertTest() {
        Test.startTest();
        Profile saleRepProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
        UserRole saleRepUsrRole = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];

        User saleRep = new User(
                ProfileId = saleRepProfile.Id,
                UserRoleId = saleRepUsrRole.Id,
                Username = 'SaleRep' + System.now().millisecond() + '@fleetcor.de',
                Alias = 'sr',
                Email = 'test@fleetcor.de',
                Country = 'Germany',
                CountryCode = 'DE',
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert saleRep;

        Profile teamleadProfile = [SELECT Id FROM Profile WHERE Name = 'Salesteamleiter Inbound'];
        UserRole teamleadUsrRole = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];

        User teamleader = new User(
                ProfileId = teamleadProfile.Id,
                UserRoleId = teamleadUsrRole.Id,
                Username = 'Teamlead' + System.now().millisecond() + '@fleetcor.de',
                Alias = 'tl',
                Email = 'test2@fleetcor.de',
                Country = 'Germany',
                CountryCode = 'DE',
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert teamleader;

        System.runAs(saleRep) {
            Account account = new Account(Name = 'TEST', BillingCountry = 'Germany');
            insert account;

            Id recordTypeId;
            if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Euroshell') != null) {
                recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Euroshell').getRecordTypeId();
            }
            Opportunity opportunity = new Opportunity(
                    Name = 'TEST',
                    AccountId = account.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    Total_consumption_l_month__c = 123,
                    OwnerId = saleRep.Id,
                    RecordTypeId = recordTypeId
            );
            insert opportunity;

            opportunity.Total_consumption_l_month__c = 321;
            update opportunity;

            opportunity.Total_consumption_l_month__c = 213;
            update opportunity;

            opportunity.Total_consumption_l_month__c = 312;
            update opportunity;
        }
        Test.stopTest();
    }

    /*******************************************************************************
   *  Name            : testsendRequestForChangeOwnerRu()
   *  Summary         : test testsendRequestForChangeOwnerRu
   *  CreatedDate     : 20/11/2017
   *  Parameters      : -
   *  Returns         : void
   ******************************************************************************/
    @isTest
    private static void testsendRequestForChangeOwnerRu() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Russian Sales Manager'];

        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ManagerId = user2.id);
        insert user;

        User user3 = new User(
                Username = 'usertest3@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user3;

        system.runAs(user) {
            Account account = new Account(Name = 'testt',INN__c='1235312151', BillingCountry = 'Russia');
            insert account;

            Id recordTypeId;
            if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
                recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
            } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
                recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
            }

            Opportunity opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Qualified Lead',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeId,
                    Source_of_Lead_o__c = 'Сайт petrolplus.ru',
                    Primary_Fueling_Method__c = 'Cash',
                    Projected_Liters_weekly__c = 20,
                    Projected_amount_in_rub_month__c = 700,
                    Number_of_cars__c = 1,
                    Number_of_trucks__c = 1
            );
            insert opportunity;

            opportunity.ownerid = user3.id;
            update opportunity;

            Opportunity testOpportunity = [
                    SELECT OwnerId
                    FROM Opportunity
                    WHERE Name = 'testt'
            ];

            System.assertEquals(testOpportunity.OwnerId, user.id);
        }
    }

    /*******************************************************************************
   *  Name            : testsendRequestForCreateSecondOpportunity()
   *  Summary         : test sendRequestForCreateSecondOpportunity
   *  CreatedDate     : 20/11/2017
   *  Parameters      : -
   *  Returns         : void
   ******************************************************************************/
    @isTest
    private static void testsendRequestForCreateSecondOpportunity() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Russian Sales Manager'];

        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ManagerId = user2.id);
        insert user;

        system.runAs(user) {
            Account account = new Account(Name = 'testt',INN__c='1235312155', BillingCountry = 'Russia');
            insert account;

            Id recordTypeId;
            if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
                recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                        'Российские продажи').getRecordTypeId();
            } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
                recordTypeId =
                        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
            }

            Opportunity opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Qualified Lead',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeId,
                    Source_of_Lead_o__c = 'Сайт petrolplus.ru',
                    Primary_Fueling_Method__c = 'Cash',
                    Projected_Liters_weekly__c = 20,
                    Projected_amount_in_rub_month__c = 700,
                    Number_of_cars__c = 1,
                    Number_of_trucks__c = 1
            );
            insert opportunity;

            Opportunity opportunity2 = new Opportunity(
                    Name = 'testt2',
                    AccountId = account.Id,
                    StageName = 'Qualified Lead',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeId,
                    Source_of_Lead_o__c = 'Сайт petrolplus.ru',
                    Primary_Fueling_Method__c = 'Cash',
                    Projected_Liters_weekly__c = 20,
                    Projected_amount_in_rub_month__c = 700,
                    Number_of_cars__c = 1,
                    Number_of_trucks__c = 1
            );
            insert opportunity2;
        }

        Opportunity testOpportunity = [
                SELECT OwnerId
                FROM Opportunity
                WHERE Name = 'testt2'];

        System.assertEquals(testOpportunity.OwnerId, user2.id);
    }

    /*****************************************************************************************
   *  Name            : testCloseTasksAfterOpportunityClosed()
   *  Summary         : tests if Task's Status changes to 'Completed' after Opportunity's Status is changed to 'Closed Lost'
   *  CreatedDate     : 20/02/2018
   *  Parameters      : -
   *  Returns         : void
   *******************************************************************************************/
    @isTest
    private static void testCloseTasksAfterOpportunityClosed() {
        String accRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');
        String euroshellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        String taskRecId = GlobalUtils.returnRecordTypeId('Task', 'Layout Tasks');

        Account account = new Account(
                Name = 'TEST',
                AccountSource = 'ABVP',
                Type = 'Customer',
                BillingCountry = 'Germany',
                Gesellschaftsform__c = 'AG',
                Beschaeftigte__c = '1-4',
                RecordTypeId = accRecId);
        insert account;

        Opportunity testOppo = new Opportunity(
                Name = 'TEST',
                AccountId = account.Id,
                Sec_Channel__c = 'JITB',
                LeadSource = 'ABVP',
                Type = 'Existing Business',
                StageName = 'Prospecting',
                Number_of_cars__c = 1,
                Number_of_trucks__c = 1,
                Total_number_of_vehicles__c = 2,
                Gasoline_consumption_l_month__c = 10,
                Diesel_consumption_l_month__c = 10,
                Total_consumption_l_month__c = 20,
                Number_of_Cards__c = 1,
                Derzeitige_Zahlungsmethode__c = 'Stationskarte',
                CloseDate = Date.today() - 1,
                RecordTypeId = euroshellRecId);
        insert testOppo;

        Task testTask = new Task(
                Status = 'In Bearbeitung',
                Type = 'Anruf',
                ActivityDate = Date.today(),
                Subject = 'test',
                WhatId = testOppo.Id,
                RecordTypeId = taskRecId);
        insert testTask;

        Test.startTest();
        testOppo.StageName = 'Closed Lost';
        OpportunityTriggerHandler.isOpportunityClosed = true;
        update testOppo;
        Test.stopTest();

        List<Task> testTasks = [SELECT Id FROM Task WHERE WhatId =: testOppo.Id AND Status = 'Completed'];
        System.assertEquals(1, testTasks.size());
    }


    /*******************************************************************************
    *  Name            : testAddSubjectsToCloneOpportunity()
    *  Summary         : test testAddSubjectsToCloneOpportunity()
    *  CreatedDate     : 23/02/2018
    *  ModifiedDate    : 16/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testAddSubjectsToCloneOpportunity() {
        Account account = new Account(Name ='Test', BillingCountry = 'Germany');
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com'
        );
        insert contact;

        List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity'
                LIMIT 1];

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Follow up',
                AccountID = account.Id,
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id,
                Credit_check_date__c = date.today().addMonths(-4)
        );
        insert opportunity;

        Tankkarten__c tankkarten = new Tankkarten__c(
                Opportunity__c = opportunity.Id,
                Gewuenschter_Kartentyp__c = 'Single Network Card -- National',
                Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren',
                KFZ_Kennzeichen_oder_Fahrername__c = 'test'
        );
        insert tankkarten;

        Attachment attachment = new Attachment(
                Name = 'CrefoReport.pdf',
                ParentId = opportunity.Id,
                Body = Blob.valueOf('test')
        );
        insert attachment;

        Attachment attachment2 = new Attachment(
                Name = 'test.pdf',
                ParentId = opportunity.Id,
                Body = Blob.valueOf('test')
        );
        insert attachment2;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User'
        );
        insert ocr;

        Opportunity cloneOpp = opportunity.clone();
        insert cloneOpp;

        List<Attachment> attachList = [SELECT Id FROM Attachment WHERE ParentId = :cloneOpp.Id];
        List<Tankkarten__c> tankkartenList = [SELECT Id FROM Tankkarten__c WHERE Opportunity__c = :cloneOpp.Id];
        List<OpportunityContactRole> oppConRoleLost = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :cloneOpp.Id];

        System.assertEquals(attachList.size(), 1);
        System.assertEquals(tankkartenList.size(), 1);
        System.assertEquals(oppConRoleLost.size(), 1);
    }

    /*******************************************************************************
    *  Name            : testupdateCurrencyIsoCode()
    *  Summary         : test updating CurrencyIsoCode
    *  CreatedDate     : 03.03.2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testupdateCurrencyIsoCode() {
        Lead testLead = new Lead(
                Salutation = 'Herr',
                LastName = 'test lead',
                Company = 'test company',
                Status = 'Open',
                Quali_Status__c = '',
                Country = 'Germany',
                CountryCode = 'DE',
                Disable_for_Processing_Time__c = FALSE,
                Branche_NACE__c = 'Bauinstallation - 4320',
                INN__c = '12345',
                Anzahl_der_Fahrzeuge__c = 2,
                Phone = '7777777',
                Email = 'test@test.com'
        );
        insert testLead;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        List<Opportunity> opptyList = [SELECT CurrencyIsoCode, Name FROM Opportunity WHERE Name = 'test company' LIMIT 1];
        System.assertEquals('EUR', opptyList.get(0).CurrencyIsoCode);
    }

    /*******************************************************************************
  *  Name            : testupdateCurrencyIsoCode()
  *  Summary         : test updating CurrencyIsoCode
  *  CreatedDate     : 03.03.2018
  *  ModifiedDate    : -
  *  Parameters      : -
  *  Returns         : void
  ******************************************************************************/
    @isTest
    private static void testupdateCurrencyIsoCode2() {
        Account account = new Account(
                Name = 'testt',
                BillingCountry = 'Germany'
        );
        insert account;

        Opportunity newOpp = new Opportunity(
                Anzahl_der_Karten__c = 5,
                Zahlungsart__c = 'Lastschrift',
                Zahlungsziel__c = '7',
                Product__c = 'None',
                StageName = 'CreditCheck',
                Name = 'test opp',
                Angebotsdauer__c = '3 Monate',
                CloseDate = Date.today(),
                AccountId = account.Id);
        insert newOpp;

        Account account2 = new Account(
                Name = 'testt',
                BillingCountry = 'Poland'
        );
        insert account2;

        newOpp.AccountId = account2.id;
        update newOpp;

        List<Opportunity> opptyUpdateList = [SELECT CurrencyIsoCode, Name FROM Opportunity WHERE Name = 'test opp' LIMIT 1];
        System.assertEquals('PLN', opptyUpdateList.get(0).CurrencyIsoCode);
    }

    /*******************************************************************************
    *  Name            : testupdateOppShellAZSone()
    *  Summary         : test updating AZS shell
    *  CreatedDate     : 05.03.2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testupdateOppShellAZSone() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        ShellTerminalAZS__c shellTerminal = new ShellTerminalAZS__c(Name = '11002', TerminalList__c = '2005/1805');
        insert shellTerminal;

        Account account = new Account(Name = 'testt',INN__c='123531215', BillingCountry = 'Russia');
        insert account;

        Id recordTypeId;
        if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                    'Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordTypeId =
                    Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        Opportunity opp = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Qualified Lead',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                RecordTypeId = recordTypeId,
                Source_of_Lead_o__c = 'Сайт petrolplus.ru',
                PPR_AZS_Retailer__c =  shellTerminal.name
        );
        insert opp;

        List<Opportunity> testList = [
                SELECT id, AZS_with_Discount_1_address__c,PPR_AZS_Retailer__c
                FROM Opportunity
                WHERE Id = :opp.Id];

        system.debug(testList.get(0).AZS_with_Discount_1_address__c +' '+ testList.get(0).PPR_AZS_Retailer__c );
        system.assert(testList.get(0).AZS_with_Discount_1_address__c != null);
    }

    /*******************************************************************************
    *  Name            : testAddErrorForCredit()
    *  Summary         : test work of the method
    *  CreatedDate     : 05.03.2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testAddErrorForCredit() {
        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Credit'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Credit'];
        User u = new User (
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_233121_test1@test.com',
                Alias = 'teamlead',
                Email = 'test_1233@test.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'testName',
                Lastname = 'testFamily',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);

        System.runAs(u) {
            Account account = new Account(Name ='Test', BillingCountry = 'Germany');
            insert account;

            Contact contact = new Contact(
                    Salutation = 'Herr',
                    LastName = 'Test',
                    AccountId = account.Id,
                    Email = 'test123123@gmail.com'
            );
            insert contact;

            List<RecordType> rtList = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];

            Opportunity opportunity = new Opportunity(
                    Name = 'Test',
                    StageName = 'Prospecting',
                    AccountID = account.Id,
                    Kredit_Entscheidung__c = 'Abgelehnt',
                    Angaben_korrekt__c = 'BIC stimmt nicht',
                    CloseDate = date.today().addMonths(1),
                    Product__c = 'Home Station offer (v.1)',
                    Angebotsdauer__c = '3 Monate',
                    RecordTypeId = rtList.get(0).Id
            );
            insert opportunity;

            OpportunityContactRole ocr = new OpportunityContactRole(
                    ContactId = contact.Id,
                    OpportunityId = opportunity.Id,
                    IsPrimary = true,
                    Role = 'Business User'
            );
            insert ocr;

            opportunity.Kredit_Entscheidung__c = 'Genehmigt';
            opportunity.Angaben_korrekt__c = 'Ja';
            opportunity.StageName = 'Closed Won';
            update opportunity;
        }
        Test.stopTest();

        List<Opportunity> oppList = [SELECT StageName FROM Opportunity LIMIT 1];
        System.assertEquals('Closed Won', oppList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetCloseDate()
    *  Summary         : Test update Closed Date when Stage is changed to "Closed Won" or "Closed Lost"
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetCloseDate() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(-1),
                Angebotsdauer__c = '3 Monate',
                Send_SEPA_approval_link__c = true);
        insert opportunity;

        opportunity.StageName = 'Closed Won';

        Test.startTest();
        update opportunity;
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CloseDate
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(opportunitiesList.get(0).CloseDate, Date.today());
    }


    /*******************************************************************************
    *  Name            : testUpdateOpenTaskCheckbox()
    *  Summary         : test updateOpenTaskCheckbox method
    *  CreatedDate     : 07/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testUpdateOpenTaskCheckbox() {
        Account account = new Account(Name = 'testt', INN__c = '123531215', BillingCountry = 'Germany');
        insert account;

        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];
        String taskRecId = GlobalUtils.returnRecordTypeId('Task', 'Layout Tasks');

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                Kredit_Entscheidung__c = 'Abgelehnt',
                Angaben_korrekt__c = 'BIC stimmt nicht',
                CloseDate = date.today().addMonths(1),
                Product__c = 'Home Station offer (v.1)',
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = rtList.get(0).Id
        );
        insert opportunity;

        User user = [SELECT Id FROM User WHERE Id != :opportunity.OwnerId LIMIT 1];

        Task testTask = new Task(
                Status = 'In Bearbeitung',
                Type = 'Anruf',
                ActivityDate = Date.today(),
                Subject = 'test',
                WhatId = opportunity.Id,
                OwnerId = user.Id,
                RecordTypeId = taskRecId);
        insert testTask;

        opportunity.OwnerId = user.Id;

        update opportunity;

        Opportunity resOpportunity = [SELECT Id, Open_Task__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(true, resOpportunity.Open_Task__c);
    }


    /*******************************************************************************
    *  Name            : testClosingSignedOpportunity()
    *  Summary         : Test closing of Opportunity when DocuSign_Status__c is set to completed
    *  CreatedDate     : 31/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testClosingSignedOpportunity() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Pending Credit - Contract Check',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate');
        insert opportunity;

        opportunity.DocuSign_Status__c = 'Completed';

        Test.startTest();
        update opportunity;
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT StageName, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
        System.assertEquals('Auto CW', opportunitiesList.get(0).CF_Stage__c);
    }

    /*******************************************************************************
    *  Name            : updateOpportunityAZSShellOneTwo()
    *  Summary         : test updating AZS shell address and terminal
    *  CreatedDate     : 05.06.2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void updateOpportunityAZSShellOneTwo() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        ShellTerminalAZS__c shellTerminal_1 = new ShellTerminalAZS__c(Name = '11002',   TerminalList__c = '2005/1805');
        insert shellTerminal_1;

        ShellTerminalAZS__c shellTerminal_2 = new ShellTerminalAZS__c(Name = '11003',   TerminalList__c = '2006/1806');
        insert shellTerminal_2;

        Account account = new Account(Name = 'testt',INN__c='123531215', BillingCountry = 'Russia');
        insert account;

        Id recordTypeId;
        if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                    'Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordTypeId =
                    Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        Opportunity opp = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Qualified Lead',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                RecordTypeId = recordTypeId,
                Source_of_Lead_o__c = 'Сайт petrolplus.ru',
                PPR_AZS_Retailer__c =  shellTerminal_1.name,
                AZS_with_Discount_2_address__c = shellTerminal_1.name
        );
        insert opp;

        opp.AZS_with_Discount_1_address__c = shellTerminal_2.name;
        opp.AZS_with_Discount_2_address__c = shellTerminal_2.name;
        update opp;

        List<Opportunity> testList = ([
                SELECT id, AZS_with_Discount_1__c, AZS_with_Discount_2__c
                FROM Opportunity
                WHERE Id = :opp.Id
        ]);

        List<ShellTerminalAZS__c> newShellTerminalAZS = ([
                SELECT name, TerminalList__c
                FROM  ShellTerminalAZS__c
                WHERE name = :shellTerminal_2.name
        ]);

        system.assertEquals(testList.get(0).AZS_with_Discount_1__c, newShellTerminalAZS.get(0).TerminalList__c );
        system.assertEquals(testList.get(0).AZS_with_Discount_2__c, newShellTerminalAZS.get(0).TerminalList__c );
    }


    /*******************************************************************************
    *  Name            : updateE2EFieldsTest()
    *  Summary         : test updateE2EFields method
    *  CreatedDate     : 17/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateE2EFieldsTest() {
        Account account = new Account(Name = 'test', BillingCountry = 'Germany');
        insert account;

        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                LeadSource = 'ABVP',
                RecordTypeId = recordTypeList.get(0).Id,
                CloseDate = date.today()
        );
        insert opportunity;

        Opportunity opportunity2 = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountID = account.Id,
                RecordTypeId = recordTypeList.get(0).Id,
                CloseDate = date.today(),
                E2E__c = true,
                E2E_Sales_Type__c = 'E2E downgraded to manual'
        );
        insert opportunity2;

        List<Opportunity> opportunityList = [SELECT E2E_Status__c, E2E_Sales_Type__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Not started', opportunityList.get(0).E2E_Status__c);
        System.assertEquals('Fully manual', opportunityList.get(0).E2E_Sales_Type__c);

        opportunity.StageName = 'Closed Lost';
        update opportunity;

        List<Opportunity> opportunityBeforeUpdateList = [SELECT E2E_Status__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Finished', opportunityBeforeUpdateList.get(0).E2E_Status__c);

        opportunity2.StageName = 'Closed Lost';
        update opportunity2;

        List<Opportunity> opportunityBeforeUpdateList2 = [SELECT E2E_Status__c, E2E_Sales_Type__c FROM Opportunity WHERE Id = :opportunity2.Id];
        System.assertEquals('Finished', opportunityBeforeUpdateList2.get(0).E2E_Status__c);
        System.assertEquals('E2E downgraded to manual', opportunityBeforeUpdateList2.get(0).E2E_Sales_Type__c);
    }


    /*******************************************************************************
    *  Name            : testUpdateFieldsForVatRecovery()
    *  Summary         : test Update required for vat recovery fields or display an error if they are empty
    *  CreatedDate     : 25/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testUpdateFieldsForVatRecovery() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Poland',
                Gesellschaftsform__c = 'Einzelfirma');
        insert account;

        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountId = account.Id,
                RecordTypeId = recordTypeList.get(0).Id,
                CloseDate = date.today(),
                VAT_Recovery__c = true
        );
        insert opportunity;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                Birthdate = Date.newInstance(1986, 21, 10));
        insert contact;

        OpportunityContactRole role = new OpportunityContactRole(
                OpportunityId = opportunity.Id,
                ContactId = contact.Id,
                IsPrimary = true);
        insert role;

        List<Tankkarten__c> cardsList = new List<Tankkarten__c>();
        Tankkarten__c card1 = new Tankkarten__c(
                Opportunity__c = opportunity.Id,
                KFZ_Kennzeichen_oder_Fahrername__c = 'test',
                Fahrzeugtyp__c = 'LKW');
        cardsList.add(card1);
        Tankkarten__c card2 = new Tankkarten__c(
                Opportunity__c = opportunity.Id,
                KFZ_Kennzeichen_oder_Fahrername__c = 'test',
                Fahrzeugtyp__c = 'LKW');
        cardsList.add(card2);
        insert cardsList;

        Test.startTest();
        opportunity.StageName = 'Closed Won';
        update opportunity;
        Test.stopTest();

        List<Opportunity> testOpportunitiesList = [
                SELECT Primary_Contact_Birthdate__c, Fleet_type_VAT_recovery__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(Date.newInstance(1986, 21, 10), testOpportunitiesList.get(0).Primary_Contact_Birthdate__c);
        System.assertEquals('CRT', testOpportunitiesList.get(0).Fleet_type_VAT_recovery__c);
    }


    /*******************************************************************************
    *  Name            : updateAccountGFNNumberTest()
    *  Summary         : Test how updating GFN Number after updating opportunity
    *  CreatedDate     : 14/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateAccountGFNNumberTest() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Prospecting',
                AccountId = account.Id,
                CloseDate = date.today());
        insert opportunity;

        opportunity.GFN_number_for_starts__c = 'DE12345';
        update opportunity;

        List<Account> accList = [SELECT GFN_Nr__c FROM Account WHERE Id = :account.Id];
        System.assertEquals('DE12345', accList.get(0).GFN_Nr__c);
    }


    /*******************************************************************************
    *  Name            : checkAccountOpportunities()
    *  Summary         : Test for check that Account doesn't already have Opportunity created in the last 31 days with the same record type
    *  CreatedDate     : 15/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void checkAccountOpportunities() {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        String euroshellRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1].Id;

        Opportunity opportunity1 = new Opportunity(
                AccountId = account.Id,
                Name = 'test1',
                RecordTypeId = euroshellRecordTypeId,
                StageName = 'Prospecting',
                CloseDate = Date.today());
        insert opportunity1;

        String salesProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound' LIMIT 1].Id;

        Create_Opportunities_Admin_Profiles__c adminProfile = new Create_Opportunities_Admin_Profiles__c(
                Name = 'API Only');
        insert adminProfile;

        User salesUser = new User(
                ProfileId = salesProfileId,
                Username = 'testactiveopportunity' + System.now().millisecond() + '@fleetcor.test',
                Alias = 'test',
                Email = 'test@fleetcor.test',
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        insert salesUser;

        System.runAs(salesUser) {
            Opportunity opportunity2 = new Opportunity(
                    AccountId = account.Id,
                    Name = 'test2',
                    RecordTypeId = euroshellRecordTypeId,
                    StageName = 'Prospecting',
                    CloseDate = Date.today());

            String exceptionMessage = '';
            try {
                insert opportunity2;
            } catch (Exception e) {
                exceptionMessage = e.getMessage();
            }

            System.assert(exceptionMessage.contains('You are not allowed to create a new Opportunity for the Account that already has an active ' +
                    'Opportunity (<31 days from Opportunity creation). If the active Opportunity is Closed Won or Closed Lost, please use "Reopen" ' +
                    'button to continue working with the existing Opportunity.'));
        }
    }

    @isTest
    static void testsetPenaltyRating_fs(){
        insert CFUtilsTest.createCFSettingsForRussia(false);
        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;

        List<PermissionSetAssignment> permissionSetAssignments = [
                SELECT Id, AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'FieldSalesTerritory_Field_Manager' AND Assignee.IsActive = true LIMIT 1
        ];

        User fieldManager = [SELECT Id FROM  User WHERE Id = :permissionSetAssignments.get(0).AssigneeId];

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Account account = new Account(
                Name = 'test12345678910987654321',
                BillingPostalCode = '123',
                Rating_FS__c = 20,
                Phone = '+71234567891',
                BillingCountry = 'Russia',
                BillingStreet = 'САНКТ-ПЕТЕРБУРГ',
                INN__C = '1234567890',
                OwnerId= fieldManager.Id,
                RecordTypeId = RecordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(
                Name = 'test12345678910987654321',
                StageName = 'Qualified Lead',
                Probability = 20,
                CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),
                OwnerId= fieldManager.Id,
                AccountId = account.id,
                RecordTypeId = RecordTypeOpp);
        insert opportunity;

        system.runAs(fieldManager){
            opportunity.StageName = 'Отказ';
            update opportunity;
        }

        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity> (
        [SELECT Id, Account.SummaryScoringRu__c, Account.Territory__c
        FROM Opportunity
        WHERE Id = :opportunity.Id]
        );
        system.assertEquals(oppsMap.get(opportunity.Id).Account.SummaryScoringRu__c, -18230);
    }

    @isTest
    static void testsetPenaltyRating_buddy(){
        insert CFUtilsTest.createCFSettingsForRussia(false);
        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;

        User buddy = [SELECT Id FROM  User
        WHERE Id IN (SELECT AssigneeId
        FROM PermissionSetAssignment
        WHERE PermissionSet.Name = 'FieldSalesTerritory_buddy')
        LIMIT 1];

        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Account account = new Account(
                Name = 'test22345678910987654321',
                BillingPostalCode = '223',
                Rating_FS__c = 20,
                Phone = '+72234567891',
                BillingCountry = 'Russia',
                BillingStreet = 'САНКТ-ПЕТЕРБУРГ',
                INN__C = '2234567890',
                OwnerId= buddy.Id,
                RecordTypeId = RecordTypeAcc);
        insert account;

        Opportunity opportunity = new Opportunity(
                Name = 'test22345678910987654321',
                StageName = 'Qualified Lead',
                Probability = 20,
                CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),
                OwnerId= buddy.Id,
                AccountId = account.id,
                RecordTypeId = RecordTypeOpp);
        insert opportunity;

        system.runAs(buddy){
            opportunity.StageName = 'Отказ';
            update opportunity;
        }

        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity> (
        [SELECT Id, Account.SummaryScoringRu__c, Account.Territory__c
        FROM Opportunity
        WHERE Id = :opportunity.Id]
        );
        system.assertEquals(oppsMap.get(opportunity.Id).Account.SummaryScoringRu__c, -18230);
    }

    @isTest
    static void testsetPenaltyRating_telesalesQueue(){
        FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365,
                Penalty_for_refusal_Telesales__c = 60
        );
        insert fieldSalesSettings;

        User telesale;

        List <Group> queues = [SELECT Id, Type, Name, DeveloperName FROM Group WHERE DeveloperName = 'PPR_Queue_Stock_DISQUALIFIED'];

        if (!queues.isEmpty()) {
            List <User> telesalesUsers =
            [SELECT Id FROM User
            WHERE Id IN (SELECT UserOrGroupId
            FROM GroupMember
            WHERE Group.Id = :queues[0].Id)];
            if (!telesalesUsers.isEmpty()) telesale = telesalesUsers[0];
        } else {
            List <User> telesalesUsers =
            [SELECT Id FROM  User
            WHERE Profile.Name = 'Russian Call Center'];
            if (!telesalesUsers.isEmpty()) telesale = telesalesUsers[0];
        }

        if (telesale != null) {
            String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
            String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

            Account account = new Account(
                    Name = 'test22345678910987654321',
                    BillingPostalCode = '223',
                    Rating_FS__c = 20,
                    Phone = '+72234567891',
                    BillingCountry = 'Russia',
                    BillingStreet = 'САНКТ-ПЕТЕРБУРГ',
                    INN__C = '2234567890',
                    OwnerId= telesale.Id,
                    RecordTypeId = RecordTypeAcc);
            insert account;

            Opportunity opportunity = new Opportunity(
                    Name = 'test22345678910987654321',
                    StageName = 'Qualified Lead',
                    Probability = 0,
                    CloseDate = date.today(),
                    Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),
                    OwnerId= telesale.Id,
                    AccountId = account.id,
                    RecordTypeId = RecordTypeOpp);
            insert opportunity;

            system.runAs(telesale){
                opportunity.StageName = 'Отказ';
                update opportunity;
            }

            Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity> (
            [SELECT Id, Account.SummaryScoringRu__c, Account.Territory__c
            FROM Opportunity
            WHERE Id = :opportunity.Id]
            );
            system.assertEquals(oppsMap.get(opportunity.Id).Account.SummaryScoringRu__c, -2980);
        }
    }


    /*******************************************************************************
    *  Name            : testValidateCarnetOpportunity()
    *  Summary         : test Validate Carnet Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateCarnetOpportunity() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<Profile> AdminUser = [SELECT Id, Name FROM Profile WHERE Name = 'API Only' LIMIT 1];

        Carnet_Profiles_Approval__c carnetSettings = new Carnet_Profiles_Approval__c(
                Name = AdminUser.get(0).Name,
                Field_Name__c = AdminUser.get(0).Name);
        insert carnetSettings;

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];
        try{

            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    BillingCountry = 'Poland',
                    Account_Status__c = 'Customer',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Contact contact = new Contact(
                    Salutation = 'Herr',
                    LastName = 'Test',
                    AccountId = account.Id,
                    Email = 'test123123@test.com');
            insert contact;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    Probability = 0,
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today());
            insert opportunity;

            OpportunityContactRole ocr = new OpportunityContactRole(
                    ContactId = contact.Id,
                    OpportunityId = opportunity.Id,
                    IsPrimary = true,
                    Role = 'Business User');
            insert ocr;

            System.runAs(User.get(0)) {
                opportunity.StageName = 'Closed Won';
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.FilesOpportunityCarnet) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        /*try{
            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    Account_Status__c = 'Customer',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    AccountId = account.id,
                    Form_of_Payment__c = 'Bank transfer - after delivery',
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today());
            insert opportunity;

            System.runAs(User.get(0)) {
                opportunity.Form_of_Payment__c = 'Advanced payment';
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CarnetAccountStatusProspect) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }*/

        try{
            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    BillingCountry = 'Poland',
                    Account_Status__c = 'Prospect',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    AccountId = account.id,
                    Form_of_Payment__c = 'Advanced payment',
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today());
            insert opportunity;

            System.runAs(User.get(0)) {
                opportunity.Form_of_Payment__c = 'Bank transfer - after delivery';
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CarnetAccountStatusProspect) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    /*******************************************************************************
    *  Name            : testCarnetOpportunityTypeStatus()
    *  Summary         : test Validate Carnet type status of Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCarnetOpportunityTypeStatus() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        try{
            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    BillingCountry = 'Poland',
                    Account_Status__c = 'Prospect',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    AccountId = account.id,
                    Probability = 0,
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today(),
                    Type = 'New GFN');
            insert opportunity;

            System.runAs(User.get(0)) {
                opportunity.Type = 'Existing GFN';
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CarnetAccountStatusGFNProspect) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    /*******************************************************************************
    *  Name            : testCarnetOpportunityDepositAmountCheck()
    *  Summary         : test Validate Carnet deposit of Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCarnetOpportunityDepositAmountCheck() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        try{
            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    BillingCountry = 'Poland',
                    Account_Status__c = 'Customer',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Contact contact = new Contact(
                    Salutation = 'Herr',
                    LastName = 'Test',
                    AccountId = account.Id,
                    Email = 'test123123@test.com');
            insert contact;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    AccountId = account.id,
                    Probability = 0,
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today(),
                    Form_of_Payment__c = 'Bank Transfer - after delivery',
                    Deposit_Amount__c = false);
            insert opportunity;

            OpportunityContactRole ocr = new OpportunityContactRole(
                    ContactId = contact.Id,
                    OpportunityId = opportunity.Id,
                    IsPrimary = true,
                    Role = 'Business User');
            insert ocr;

            System.runAs(User.get(0)) {
                opportunity.Deposit_Amount__c = true;
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CarnetOpportunityDepositAmountPayment) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    /*******************************************************************************
    *  Name            : testCarnetOpportunitySaveClosedWonPayment()
    *  Summary         : test Validate Carnet closing of Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCarnetOpportunitySaveClosedWonPayment() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        try{
            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    BillingCountry = 'Poland',
                    Account_Status__c = 'Prospect',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Contact contact = new Contact(
                    Salutation = 'Herr',
                    LastName = 'Test',
                    AccountId = account.Id,
                    Email = 'test123123@test.com');
            insert contact;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    AccountId = account.id,
                    Probability = 0,
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today(),
                    Form_of_Payment__c = 'Advanced payment',
                    Deposit_Amount__c = false);
            insert opportunity;

            OpportunityContactRole ocr = new OpportunityContactRole(
                    ContactId = contact.Id,
                    OpportunityId = opportunity.Id,
                    IsPrimary = true,
                    Role = 'Business User');
            insert ocr;

            System.runAs(User.get(0)) {
                opportunity.StageName = 'Closed Won';
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CarnetOpportunityClosedWonCheck) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    /*******************************************************************************
    *  Name            : testcarnetStatusClosed()
    *  Summary         : test Validate Carnet closing of Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testcarnetStatusClosed() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        List<Profile> AdminUser = [SELECT Id, Name FROM Profile WHERE Name = 'API Only' LIMIT 1];

        Carnet_Profiles_Approval__c carnetSettings = new Carnet_Profiles_Approval__c(
                Name = AdminUser.get(0).Name,
                Field_Name__c = AdminUser.get(0).Name);
        insert carnetSettings;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings2 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Account_Status__c');
        insert carnetSettings2;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings3 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Number_of_open_tasks__c');
        insert carnetSettings3;

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Poland',
                Account_Status__c = 'Prospect',
                OwnerId= User.get(0).Id,
                RecordTypeId = endkundeAccRecId);
        insert account;

        Pricebook2 pcb = new Pricebook2(
                Name = 'test',
                IsActive = true,
                Standard_Unit_Package__c = 289);
        insert pcb;

        Account_Price_Book__c apb = new Account_Price_Book__c(
                Name = 'test',
                Account__c = account.Id,
                Price_Book__c = pcb.Id);
        insert apb;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Carnet_podsumowanie_zamowienia',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                PathOnClient = 'Test.pdf'
        );
        insert contentVersion;

        Opportunity opportunity = new Opportunity(
                Name = 'CarnetTest',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = carnetOppoRecId,
                CloseDate = date.today(),
                Form_of_Payment__c = 'Advanced payment',
                Account_Price_Book__c = apb.Id,
                GFN_number_for_starts__c = '12345',
                Deposit_Amount__c = true);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = opportunity.Id;
        cdl.ShareType = 'V';
        insert cdl;

        System.runAs(User.get(0)) {
            opportunity.StageName = 'Closed Won';
            update opportunity;
        }

        Map<Id, Account> accMap = new Map<Id, Account> (
        [SELECT Id, Account_Status__c
        FROM Account
        WHERE Id = :account.Id]
        );
        system.assertEquals(accMap.get(account.Id).Account_Status__c, 'Customer');

    }

    /*******************************************************************************
    *  Name            : testCarnetDepositReceived()
    *  Summary         : test Validate Carnet closing of Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/

    @isTest
    public static void testCarnetDepositReceived() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        List<Profile> AdminUser = [SELECT Id, Name FROM Profile WHERE Name = 'API Only' LIMIT 1];

        Carnet_Profiles_Approval__c carnetSettings = new Carnet_Profiles_Approval__c(
                Name = AdminUser.get(0).Name,
                Field_Name__c = AdminUser.get(0).Name);
        insert carnetSettings;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings2 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Account_Status__c');
        insert carnetSettings2;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings3 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Number_of_open_tasks__c');
        insert carnetSettings3;

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Poland',
                Account_Status__c = 'Prospect',
                OwnerId= User.get(0).Id,
                RecordTypeId = endkundeAccRecId);
        insert account;

        Pricebook2 pcb = new Pricebook2(
                Name = 'test',
                IsActive = true,
                Standard_Unit_Package__c = 289);
        insert pcb;

        Account_Price_Book__c apb = new Account_Price_Book__c(
                Name = 'test',
                Account__c = account.Id,
                Price_Book__c = pcb.Id);
        insert apb;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Carnet_podsumowanie_zamowienia',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                PathOnClient = 'Test.pdf'
        );
        insert contentVersion;

        Opportunity opportunity = new Opportunity(
                Name = 'CarnetTest',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = carnetOppoRecId,
                CloseDate = date.today(),
                Form_of_Payment__c = 'Advanced payment',
                Account_Price_Book__c = apb.Id,
                Deposit_Amount__c = false);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = opportunity.Id;
        cdl.ShareType = 'V';
        insert cdl;

        Test.startTest();
            System.runAs(User.get(0)) {
                opportunity.Deposit_Amount__c = true;
                update opportunity;
            }

            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
                    [SELECT Id, StageName
                     FROM Opportunity
                     WHERE Id = :opportunity.Id]
            );
            system.assertEquals(oppMap.get(opportunity.Id).StageName, 'Closed Won');
        Test.stopTest();
        /*
        System.runAs(User.get(0)) {
            account.Account_Status__c = 'Prospect';
            update account;
        }

        Opportunity opportunityNoDepo = new Opportunity(
                Name = 'CarnetTest',
                StageName = 'Propose',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = carnetOppoRecId,
                CloseDate = date.today(),
                Form_of_Payment__c = 'Advanced payment',
                Deposit_Amount__c = true);
        insert opportunityNoDepo;

        ContentDocumentLink cdlNoDepo = new ContentDocumentLink();
        cdlNoDepo.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdlNoDepo.LinkedEntityId = opportunityNoDepo.Id;
        cdlNoDepo.ShareType = 'V';
        insert cdlNoDepo;

        System.runAs(User.get(0)) {
            opportunityNoDepo.Deposit_Amount__c = false;
            update opportunityNoDepo;
        }
        Map<Id, Opportunity> oppMapNoDepo = new Map<Id, Opportunity> (
        [SELECT Id, Deposit_received_confirmed_by__c
        FROM Opportunity
        WHERE Id = :opportunityNoDepo.Id]
        );
        system.assertEquals(oppMapNoDepo.get(opportunityNoDepo.Id).Deposit_received_confirmed_by__c, '');
        */
    }
    /*******************************************************************************
    *  Name            : testCarnetOpportunityProfileRolesClosing()
    *  Summary         : test Validate Carnet closing of Opportunity
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCarnetOpportunityProfileRolesClosing() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        try{
            Account account = new Account(
                    Name = 'TESTCARNET',
                    BillingPostalCode = '12345',
                    Phone = '+72234567891',
                    BillingStreet = 'TEST',
                    BillingCountry = 'Poland',
                    Account_Status__c = 'Prospect',
                    OwnerId= User.get(0).Id,
                    RecordTypeId = endkundeAccRecId);
            insert account;

            Contact contact = new Contact(
                    Salutation = 'Herr',
                    LastName = 'Test',
                    AccountId = account.Id,
                    Email = 'test123123@test.com');
            insert contact;

            ContentVersion contentVersion = new ContentVersion(
                    Title = 'Carnet_podsumowanie_zamowienia',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true,
                    PathOnClient = 'Test.pdf'
            );
            insert contentVersion;

            Opportunity opportunity = new Opportunity(
                    Name = 'CarnetTest',
                    StageName = 'Qualify',
                    AccountId = account.id,
                    Probability = 0,
                    OwnerId = User.get(0).Id,
                    RecordTypeId = carnetOppoRecId,
                    CloseDate = date.today(),
                    Form_of_Payment__c = 'Advanced payment',
                    Deposit_Amount__c = true);
            insert opportunity;

            OpportunityContactRole ocr = new OpportunityContactRole(
                    ContactId = contact.Id,
                    OpportunityId = opportunity.Id,
                    IsPrimary = true,
                    Role = 'Business User');
            insert ocr;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
            cdl.LinkedEntityId = opportunity.Id;
            cdl.ShareType = 'V';
            insert cdl;

            System.runAs(User.get(0)) {
                opportunity.StageName = 'Closed Won';
                opportunity.Name = 'TEST2';
                update opportunity;
            }
        }
        catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CarnetOpportunityAdminClosing) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }

    /*******************************************************************************
    *  Name            : testCarnetOpportunityClosedWon()
    *  Summary         : test Validate Carnet closing of Opportunity
    *  CreatedDate     : 07/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCarnetOpportunityClosedWon() {
        String carnetOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Carnet');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        List<Profile> AdminUser = [SELECT Id, Name FROM Profile WHERE Name = 'API Only' LIMIT 1];

        Carnet_Profiles_Approval__c carnetSettings = new Carnet_Profiles_Approval__c(
                Name = AdminUser.get(0).Name,
                Field_Name__c = AdminUser.get(0).Name);
        insert carnetSettings;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings2 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Account_Status__c');
        insert carnetSettings2;

        Carnet_Opportunity_Fields_after_Closed__c carnetSettings3 = new Carnet_Opportunity_Fields_after_Closed__c(
                Name = 'Number_of_open_tasks__c');
        insert carnetSettings3;

        Carnet_BO_Emails__c BOe = new Carnet_BO_Emails__c(
                Name = 'Poland',
                Email__c = 'info@intercodec.cz');
        insert BOe;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Poland',
                Account_Status__c = 'Prospect',
                OwnerId= User.get(0).Id,
                RecordTypeId = endkundeAccRecId);
        insert account;

        Pricebook2 pcb = new Pricebook2(
                Name = 'test',
                IsActive = true,
                Standard_Unit_Package__c = 289);
        insert pcb;

        Account_Price_Book__c apb = new Account_Price_Book__c(
                Name = 'test',
                Account__c = account.Id,
                Price_Book__c = pcb.Id);
        insert apb;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Carnet_podsumowanie_zamowienia',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                PathOnClient = 'Test.pdf'
        );
        insert contentVersion;

        Opportunity opportunity = new Opportunity(
                Name = 'CarnetTest',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = carnetOppoRecId,
                CloseDate = date.today(),
                Form_of_Payment__c = 'Advanced payment',
                Account_Price_Book__c = apb.Id,
                Deposit_Amount__c = true);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = opportunity.Id;
        cdl.ShareType = 'V';
        insert cdl;

        System.runAs(User.get(0)) {
            opportunity.StageName = 'Closed Won';
            update opportunity;
        }

        List<Opportunity> opportunitiesList = [
                SELECT Account_Status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(opportunitiesList.get(0).Account_Status__c, 'Customer');

    }

    /*******************************************************************************
   *  Name            : testCalculateProcessingTime()
   *  CreatedDate     : 20/11/2019
   *  Parameters      : -
   *  Returns         : void
   ******************************************************************************/
    @isTest
    private static void testCalculateProcessingTime() {
        insert CFUtilsTest.createCFSettingsForRussia(false);

        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'API Only'];

        Fleetcor_Profile_Info_Settings__c e2esSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'API Only',
                ProfileId__c = p.Id);
        insert e2esSettings;

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        System.runAs(user) {
            Account account = new Account(Name = 'testt', BillingCountry = 'Russia');
            insert account;

            Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
            Opportunity opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Unprocessed',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeId
            );
            insert opportunity;

            opportunity.StageName = 'Qualified Lead';
            update opportunity;

            Opportunity testOpportunity = [
                    SELECT Opportunity_Processing_Time__c
                    FROM Opportunity
                    WHERE Name = 'testt'
            ];
            System.assertNotEquals(testOpportunity.Opportunity_Processing_Time__c, null);
        }
    }

    @isTest
    private static void testStartFieldsCheck(){
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Sales Inbound'];

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Opportunity opportunity;
        System.runAs(user){
            Account account = new Account(Name = 'testt', BillingCountry = 'Poland');
            insert account;

            Id recordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Lotos').getRecordTypeId();
            opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Closed Won',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    RecordTypeId = recordTypeId
            );
            insert opportunity;

            try{
                opportunity.IBAN__c = '1';
                update opportunity;
            } catch(Exception e){

            }
        }


        List<Opportunity> result = [SELECT Id, IBAN__c FROM Opportunity WHERE id= :opportunity.Id];
        system.assertNotEquals('1', String.valueOf(result.get(0).IBAN__c));
    }

    /*******************************************************************************
    *  Name            : testSendCCSBOClosedWonNotification()
    *  Summary         : test sending CCS BO notification on Closed Won of Merlin Oppties
    *  CreatedDate     : 13/1/2020
    *  ModifiedDate    : 8/6/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSendCCSBOClosedWonNotification() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> User = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1];

        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Closed_Won_BO_notification' LIMIT 1][0].Id;

        CCS_Back_Office_Custom_Settings__c BO = new CCS_Back_Office_Custom_Settings__c(
                Name = 'CCS Limit+ CZ',
                Product__c = 'CCS Limit+',
                Country__c = 'CZ',
                Email__c = 'info@intercodec.cz');
        insert BO;

        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Order entered',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Product_Solicited__c = 'CCS Limit+',
                LeadSource = 'Web CCS');
        insert opportunity;

        Opportunity opportunity2 = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Order entered',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Product_Solicited__c = 'CCS Limit+',
                Merlin_Last_Modified_By__c = 'fleetcor@intercodec.cz',
                LeadSource = 'Web CCS');
        insert opportunity2;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity.id,
                Product_Country__c = 'CZ',
                Product__c = 'CCS Limit+',
                RecordTypeId = LimitRecId);
        insert ccsOrder;

        CCS_Order__c ccsOrder2 = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity2.id,
                Product_Country__c = 'CZ',
                Product__c = 'CCS Limit+',
                RecordTypeId = LimitRecId);
        insert ccsOrder2;

        Test.startTest();
        System.runAs(User.get(0)) {
            opportunity.StageName = 'Closed Won';
            update opportunity;
            opportunity2.StageName = 'Closed Won';
            update opportunity2;

            List<Opportunity> opportunitiesList = [
                    SELECT Starts_Status__c
                    FROM Opportunity
                    WHERE Id = :opportunity.Id];

            System.assertEquals(opportunitiesList.get(0).Starts_Status__c, '0. Request received');
        Test.stopTest();
        }
    }

    @isTest
    public static void testSendCCSBOClosedWonNotificationOMV() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        List<User> User = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1];

        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Closed_Won_OMV_BO_notification' LIMIT 1][0].Id;

        CCS_Back_Office_Custom_Settings__c BO = new CCS_Back_Office_Custom_Settings__c(
                Name = 'test OMV',
                Product__c = 'OMV',
                Country__c = '-',
                Email__c = 'info@intercodec.cz');
        insert BO;

        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Order entered',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Product_Solicited__c = 'OMV',
                LeadSource = 'Web CCS');
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Decision Maker');
        insert ocr;

        Test.startTest();
        System.runAs(User.get(0)) {
            opportunity.StageName = 'Closed Won';
            update opportunity;

            List<Opportunity> opportunitiesList = [
                    SELECT Starts_Status__c
                    FROM Opportunity
                    WHERE Id = :opportunity.Id];

            System.assertEquals(opportunitiesList.get(0).Starts_Status__c, '0. Request received');
        Test.stopTest();
        }
    }

    /*******************************************************************************
    *  Name            : testSendExcelRobotCCS()
    *  Summary         : test sending Email with Excel Attachment to CCS Robot after Closed Won Oppties
    *  CreatedDate     : 14/1/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSendExcelRobotCCS() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        //List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<User> User = [SELECT Id FROM User WHERE Alias = 'hševč' LIMIT 1];

        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Closed_Won_Robot' LIMIT 1][0].Id;


        CCS_Robot_Emails__c reCS = new CCS_Robot_Emails__c(
                Name = 'CZ',
                Email__c = 'info@intercodec.cz');
        insert reCS;

        Account acc = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert acc;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = acc.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opp = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Order entered',
                Type = 'New GFN',
                AccountId = acc.Id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Product_Solicited__c = 'CCS Limit',
                LeadSource = 'Web CCS');
        insert opp;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = acc.Id,
                Opportunity__c = opp.Id,
                CurrencyIsoCode = 'CZK',
                Product_Country__c = 'CZ',
                RecordTypeId = LimitRecId);
        insert ccsOrder;

        System.runAs(User.get(0)) {
            opp.StageName = 'Closed Won';
            opp.Starts_Status__c = '0.9b Ready for Robot Setup';
            update opp;
        }
    }

    /*******************************************************************************
    *  Name            : testSendWelcomeEmailLotos()
    *  Summary         : test sending email to Client for Lotos product
    *  CreatedDate     : 20/1/2020
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSendWelcomeEmailLotos() {
        String lotosOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Lotos');
        String endkundeAccRecId = GlobalUtils.returnRecordTypeId('Account', 'Endkunde');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lotos_Welcome_Email' LIMIT 1][0].Id;

        General_Integration_Settings__c gISettings = new General_Integration_Settings__c(
                Name = 'General',
                System_Administrator_Profile_Id__c = User.get(0).ProfileId);
        insert gISettings;

        Account acc = new Account(
                Name = 'TestLotos',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Poland',
                OwnerId= User.get(0).Id,
                RecordTypeId = endkundeAccRecId);
        insert acc;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = acc.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opp = new Opportunity(
                Name = 'Lotos',
                StageName = 'Qualify',
                AccountId = acc.Id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = lotosOppoRecId,
                CloseDate = date.today());
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opp.Id,
                IsPrimary = true,
                Role = 'Decision Maker');
        insert ocr;

        System.runAs(User.get(0)) {
            opp.StageName = 'Closed Won';
            update opp;
        }
    }

    /*******************************************************************************
    *  Name            : testCheckOzNumberUpdateOwner()
    *  Summary         : test Check OZ number with data in custom settings Oz_number_checker__c .
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckOzNumberUpdateOwner() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        Oz_number_checker__c OZ = new Oz_number_checker__c(
                Name = 'TEST',
                OZ_Number__c = '123456789',
                UserId__c = User.get(0).Id);
        insert OZ;

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                OZ_Number__c = '');
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        System.runAs(User.get(0)) {
            opportunity.OZ_Number__c = '123456789';
            update opportunity;
        }
    }


    /*******************************************************************************
    *  Summary         : Test check changes of non-fuel exposure in processed opportunity.
    *  Created         : 05/05/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testCheckNonFuelExposureChanges() {
        CF_Non_fuel_Exposure_Profile__c profile = new CF_Non_fuel_Exposure_Profile__c(
            Name = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name);
        insert profile;

        Account account = new Account(
            Name = 'test',
            BillingCountry = 'Germany');
        insert account;

        List<Opportunity> opportunititesList = new List<Opportunity>();
        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            Name = 'test',
            StageName = 'Pending Sales – Deposit',
            Zahlungsart__c = 'Lastschrift',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            bearbeitet_von__c = 'Autoprocessed by Sales');
        opportunititesList.add(opportunity);

        Opportunity opportunity2 = new Opportunity(
            AccountId = account.Id,
            Name = 'test',
            StageName = 'Pending Sales - SEPA Confirmation',
            Zahlungsart__c = 'Lastschrift',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            bearbeitet_von__c = 'Autoprocessed by Sales');
        opportunititesList.add(opportunity2);
        insert opportunititesList;

        Test.startTest();
            opportunity.Non_fuel_exposure__c = 100;
            update opportunity;

            String exceptionMessage;
            try {
                opportunity2.Non_fuel_exposure__c = 100;
                update opportunity2;
            } catch (Exception e) {
                exceptionMessage = e.getMessage();
            }
        Test.stopTest();

        List<Opportunity> testOpportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(testOpportunitiesList.get(0).StageName, 'Prospecting');
        System.assert(exceptionMessage.contains('Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.'));
    }

    /*******************************************************************************
    *  Name            : testSetCloseDateCCS()
    *  Summary         : Test for setting Close Date to Today for CCS Record Type if CloseDate > TODAY.
    *  CreatedDate     : 03/07/2020
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetCloseDateCCS() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        List<User> User = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1];

        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Closed Lost',
                AccountId = account.id,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today() + 30,
                Product_Solicited__c = 'CCS Limit+',
                LeadSource = 'Web CCS');
        insert opportunity;

        List<Opportunity> opportunitiesList = [
                SELECT CloseDate
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(opportunitiesList.get(0).CloseDate, date.today());
    }

    @isTest
    static void testSetAccountHomeStation() {
        String accountRecordTypeId = GlobalUtils.returnRecordTypeId('Account', 'Retailer');
        Account account = new Account(
                Name = 'test',
                RecordTypeId = accountRecordTypeId,
                ESI__c = '12345',
                BillingCountry = 'Germany');
        insert account;

        String opportunityRecordType = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        Opportunity opportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'test',
                StageName = 'Pending Sales – Deposit',
                Zahlungsart__c = 'Lastschrift',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                RecordTypeId = opportunityRecordType,
                bearbeitet_von__c = 'Autoprocessed by Sales');
        insert opportunity;

        Test.startTest();
        opportunity.Account_Home_Station__c = account.Id;
        update opportunity;
        Test.stopTest();

        List<Opportunity> result = [SELECT Id, ESI__c, Home_Station__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(account.ESI__c, result.get(0).ESI__c);
        System.assertNotEquals('', result.get(0).Home_Station__c);
    }


   /*******************************************************************************
     *  Summary         : test if credit can approve opportunity
     *  Created         : 28/10/2020
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    static void testCheckCreditToApproveOpportunity() {
        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Switzerland-DE',
                Beschaeftigte__c = '1-4'
        );
        insert account;

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                RecordTypeId = rt.Id,
                AccountId = account.Id,
                StageName = 'Prospecting',
                CurrencyIsoCode = 'CHF',
                Anzahl_der_Karten__c = 123,
                Language_preference__c = 'Polish',
                IBAN__c = '1234567789',
                SWIFT_BIC__c = '987654321',
                Direct_Debit_Mandate_Type__c = 'Core',
                Total_consumption_l_month__c = 123,
                Derzeitige_Zahlungsmethode__c = 'Bankkarte',
                Garantie__c = 'Deposit',
                Zahlungssystem__c = 'Visa',
                Bank__c = 'bank',
                Zahlungsart__c = 'Lastschrift',
                CF_Stage__c = 'Launched',
                Last_CF_Errors__c = 'error',
                bearbeitet_von__c = 'Autoprocessed by Sales',
                Garantie_other__c = 3000,
                CloseDate = Date.today().addDays(14),
                CF_Credit_Limit__c = 40000
        );
        insert opportunity;

        Approval_Process_Users__c approvalProcessUser = new Approval_Process_Users__c(
                SetupOwnerId = UserInfo.getUserId(),
                CHF__c = 80000
        );
        insert approvalProcessUser;

        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(opportunity.Id);
        app.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result = Approval.process(app);

        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest processWorkitemRequest = new Approval.ProcessWorkitemRequest();
        processWorkitemRequest.setAction('Approve');
        processWorkitemRequest.setNextApproverIds(new Id[]{UserInfo.getUserId()});
        processWorkitemRequest.setWorkitemId(newWorkItemIds.get(0));

        Approval.ProcessResult result2 = Approval.process(processWorkitemRequest);

        Opportunity opp = [SELECT bearbeitet_von__c FROM Opportunity LIMIT 1];

        System.assertEquals('Approved', result2.getInstanceStatus());
        System.assertEquals(opp.bearbeitet_von__c, UserInfo.getName());
    }

    /*******************************************************************************
    *  Name            : tesUpdateCCSOpportunity()
    *  Summary         : Test for setting CCS Opportunity fields before insert and before update. Re-usable/expandable method.
    *  CreatedDate     : 14/12/2020
    *  ModifiedDate    : 15/03/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void tesUpdateCCSOpportunity() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today());
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        List<Opportunity> testOpportunitiesList = [
                SELECT Eco_Fee__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(testOpportunitiesList.get(0).Eco_Fee__c, false);

        opportunity.Product_Solicited__c = 'OMV';
        update opportunity;

        List<Opportunity> testOpportunitiesList2 = [
                SELECT Eco_Fee__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(testOpportunitiesList2.get(0).Eco_Fee__c, true);

        opportunity.Product_Solicited__c = 'CCS Limit';
        update opportunity;

        List<Opportunity> testOpportunitiesList3 = [
                SELECT Eco_Fee__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(testOpportunitiesList3.get(0).Eco_Fee__c, false);
    }

    /*******************************************************************************
    *  Name            : testCheckCCSOpportunityOwner()
    *  Summary         : Test Check if Opportunity Owner has changed and then modify related CCS Order.
    *  CreatedDate     : 03/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckCCSOpportunityOwner() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String accRecordType = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        List<User> UserOwner = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];
        List<User> UserOwnerNew = [SELECT Id, ProfileId FROM User WHERE UserRole.Name = 'Altevida CCS Telesales' AND IsActive = true LIMIT 1];

        Account account = new Account(
                Name = 'TESTCARNET',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= UserOwner.get(0).Id,
                RecordTypeId = accRecordType);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                StageName = 'Qualify',
                AccountId = account.id,
                Probability = 0,
                OwnerId = UserOwner.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Number_of_CCS_Order__c = 1);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true,
                Role = 'Business User');
        insert ocr;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = opportunity.id,
                Product_Country__c = 'CZ',
                Product__c = 'CCS Limit+',
                OwnerId = UserOwner.get(0).Id,
                RecordTypeId = LimitRecId);
        insert ccsOrder;

        System.runAs(UserOwner.get(0)) {
            opportunity.OwnerId = UserOwnerNew.get(0).Id;
            update opportunity;
        }
    }


    /*******************************************************************************
     *  Summary         : test calculate Total Consumption or Amount fields according to fuel prices
     *  Created         : 01/02/2020
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    public static void testCalculateTotalConsumptionBasedOnAmount() {
        Account account = new Account(
                Name = 'Test',
                BillingCountry = 'Austria',
                Beschaeftigte__c = '1-4'
        );
        insert account;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(
                Name = 'Austria',
                Index__c = 1
        );
        insert fuelPrice;

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1];

        Opportunity opportunity = new Opportunity(
                Name = 'Test',
                RecordTypeId = rt.Id,
                AccountId = account.Id,
                StageName = 'Prospecting',
                CurrencyIsoCode = 'EUR',
                Amount__c = 100,
                CloseDate = Date.today()
        );
        insert opportunity;

        opportunity = [SELECT Total_consumption_l_month__c FROM Opportunity LIMIT 1];

        System.assertEquals(100, opportunity.Total_consumption_l_month__c);

        opportunity.Total_consumption_l_month__c = 300;
        update opportunity;

        opportunity = [SELECT Amount__c FROM Opportunity LIMIT 1];

        System.assertEquals(300, opportunity.Amount__C);

        opportunity.Amount__c = 500;
        update opportunity;

        opportunity = [SELECT Total_consumption_l_month__c FROM Opportunity LIMIT 1];

        System.assertEquals(500, opportunity.Total_consumption_l_month__c);
    }

    /*******************************************************************************
     *  Summary         : test locking closed opportunities
     *  Created         : 24/03/2021
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    public static void testLockingClosedOpportunities() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        List<User> User = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1];

        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity o = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Closed Lost',
                AccountId = account.id,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today() + 30,
                Product_Solicited__c = 'CCS Limit+',
                LeadSource = 'Web CCS');
        insert o;

        try {
            o.Product_Solicited__c = 'EDITED TEXT';
            update o;
        } catch(Exception error) {

        }
    }

    @IsTest
    public static void testLockingClosedOpportunities2() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        User u = [SELECT Id, ProfileId, UserName, UserRoleId FROM User WHERE CompanyName = 'INTERCODEC' AND IsActive = true LIMIT 1];

        ClosedOpportunityManagement__c com = new ClosedOpportunityManagement__c(
                Name = 'Rule',
                Active__c = true,
                Opportunity_Record_Type_Develop_Name__c = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(ccsOppoRecId).getDeveloperName(),
                Exception_URP_Developer_Name__c = 'Role'
        );
        insert com;

        ClosedOpportunityManagement__c com1 = new ClosedOpportunityManagement__c(
                Name = 'CloseDateExclude',
                Active__c = true,
                Opportunity_Record_Type_Develop_Name__c = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(ccsOppoRecId).getDeveloperName(),
                Exception_Field_API_Name__c = 'CloseDate',
                Excluded_Field__c = true
        );
        insert com1;

        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= u.Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity o = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Closed Lost',
                AccountId = account.id,
                OwnerId = u.Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today() + 30,
                Product_Solicited__c = 'CCS Limit+',
                LeadSource = 'Web CCS');
        insert o;

        System.runAs(u) {
            try {
                o.Product_Solicited__c = 'EDITED TEXT';
                update o;
            } catch(Exception error) {

            }
        }
    }

    @IsTest
    public static void testLockingClosedOpportunities3() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        User u = [SELECT Id, ProfileId, UserName, UserRoleId FROM User WHERE CompanyName = 'INTERCODEC' AND IsActive = true LIMIT 1];

        ClosedOpportunityManagement__c com = new ClosedOpportunityManagement__c(
                Name = 'Rule',
                Active__c = true,
                Opportunity_Record_Type_Develop_Name__c = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(ccsOppoRecId).getDeveloperName(),
                Exception_URP_Developer_Name__c = 'Role',
                Exception_Field_API_Name__c = 'Name'
        );
        insert com;


        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= u.Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity o = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Qualify',
                AccountId = account.id,
                OwnerId = u.Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today() + 30,
                Product_Solicited__c = 'CCS Limit+',
                LeadSource = 'Web CCS');
        insert o;

        System.runAs(u) {
            try {
                o.StageName = 'Closed Lost';
                update o;

            } catch(Exception error) {

            }
        }
    }

    @IsTest
    public static void testLockingClosedOpportunities4() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        User u = [SELECT Id, ProfileId, UserName, UserRoleId FROM User WHERE CompanyName = 'INTERCODEC' AND IsActive = true LIMIT 1];

        ClosedOpportunityManagement__c com = new ClosedOpportunityManagement__c(
                Name = 'Rule',
                Active__c = true,
                Opportunity_Record_Type_Develop_Name__c = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(ccsOppoRecId).getDeveloperName()+';test',
                Exception_URP_Developer_Name__c = 'Role',
                Exception_Field_API_Name__c = 'Product_Solicited__c'
        );
        insert com;


        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= u.Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity o = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Qualify',
                AccountId = account.id,
                OwnerId = u.Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today() + 30,
                Product_Solicited__c = 'CCS Limit+',
                LeadSource = 'Web CCS');
        insert o;

        System.runAs(u) {
            try {
                o.StageName = 'Closed Lost';
                update o;

                o.Product_Solicited__c = 'CCS Bonus';
                update o;

            } catch(Exception error) {

            }
        }
    }

    /*******************************************************************************
     *  Summary         : Test locking CCS Opportunities with CCS Order under them
     *  Created         : 07/06/2021
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    @IsTest
    public static void testCCSOpportunityLockOrder() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');

        User u = [SELECT Id FROM User WHERE Profile.Name = 'CCS SME' AND IsActive = true LIMIT 1];

        Merlin_Salesforce_Settings__c merlinCST = new Merlin_Salesforce_Settings__c(
                Name = 'Connection Settings',
                Hash__c = 'LNFCwoPtJXDmjKs0P%^Q!XsyohXJKVAScz7',
                Sandbox_Endpoint__c = 'https://develop-ccs.pixman.cz/sfApi/update',
                Production_Endpoint__c = 'https://ccs.cz/sfApi/update'
        );
        insert merlinCST;

        Account account = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId= u.Id,
                RecordTypeId = ccsAccRecId);
        insert account;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = account.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity o = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Qualify',
                AccountId = account.id,
                OwnerId = u.Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today() + 30,
                Product_Solicited__c = 'CCS Limit+',
                Number_of_CCS_Order__c = 1,
                LeadSource = 'Web CCS');
        insert o;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = account.id,
                Opportunity__c = o.id,
                Product_Country__c = 'CZ',
                Product__c = 'CCS Limit+',
                RecordTypeId = LimitRecId);
        insert ccsOrder;

        Test.startTest();
        MerlinOrderStageHttpMockImpl mock = new MerlinOrderStageHttpMockImpl(200, 'Success', 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
                o.Name = 'CCSTest2';
                update o;
            } catch (Exception error) {

            }

            try {
                o.StageName = 'Closed Lost';
                update o;
            } catch (Exception error) {

            }
        }
        CCSOrderTriggerHandler.sendDataToMerlin('endpoint', 'merlinId', 'stage', 'status', 'email', 'datetime', 'digest');
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateAccountLookup () {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Poland'
        );
        insert account;

        Account account2 = new Account(
                Name = 'test2',
                BillingCountry = 'Poland'
        );
        insert account2;

        Opportunity opp = new Opportunity(
                AccountId = account.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_2__c = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                CurrencyIsoCode = 'PLN'
        );
        insert opp;

        Product2 product = new Product2(
                Name = 'Shell Basic 2020',
                Integration_Name__c = 'shellpl',
                IsActive = true,
                Family = 'Shell'
        );
        insert product;
        PricebookEntry pricebookEntryObject = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = product.Id,
                UnitPrice = 0,
                CurrencyIsoCode = 'PLN',
                IsActive = true
        );
        insert pricebookEntryObject;
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = product.Id,
                PricebookEntryId = pricebookEntryObject.Id,
                Quantity = 2,
                UnitPrice = 0
        );
        OpportunityLineItem lineItem2 = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = product.Id,
                PricebookEntryId = pricebookEntryObject.Id,
                Quantity = 3,
                UnitPrice = 0
        );
        opportunityLineItems.add(lineItem1);
        opportunityLineItems.add(lineItem2);
        insert opportunityLineItems;

        List<Additional_Service__c> addservices = new List<Additional_Service__c>();
        Additional_Service__c addService = new Additional_Service__c(
                Type__c = 'Eco Fee',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'ecofeepl'
        );
        Additional_Service__c addService2 = new Additional_Service__c(
                Type__c = 'Paper Invoice',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'pipl'
        );
        Additional_Service__c addService3 = new Additional_Service__c(
                Type__c = 'VAT Refund',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'vatpl'
        );
        addservices.add(addService);
        addservices.add(addService2);
        addservices.add(addService3);
        insert addservices;

        List<Client_Offer_Additional_Service__c> oasList = new List<Client_Offer_Additional_Service__c>();
        Client_Offer_Additional_Service__c oas = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService.Id,
                Selected__c = true
        );
        Client_Offer_Additional_Service__c oas2 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService2.Id
        );
        Client_Offer_Additional_Service__c oas3 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService3.Id
        );
        oasList.add(oas);
        oasList.add(oas2);
        oasList.add(oas3);
        insert oasList;

        for (OpportunityLineItem nextOpportunityLineItem : [SELECT Account__c, OpportunityId, Quantity FROM OpportunityLineItem]) {
            System.assertEquals(account.Id, nextOpportunityLineItem.Account__c);
        }
        for (Client_Offer_Additional_Service__c nextClientOfferAdditionalService : [SELECT Account__c FROM Client_Offer_Additional_Service__c]) {
            System.assertEquals(account.Id, nextClientOfferAdditionalService.Account__c);
        }

        opp.AccountId = account2.Id;
        update opp;
        for (OpportunityLineItem nextOpportunityLineItem : [SELECT Account__c, OpportunityId, Quantity FROM OpportunityLineItem]) {
            System.assertEquals(account2.Id, nextOpportunityLineItem.Account__c);
        }
        for (Client_Offer_Additional_Service__c nextClientOfferAdditionalService : [SELECT Account__c FROM Client_Offer_Additional_Service__c]) {
            System.assertEquals(account2.Id, nextClientOfferAdditionalService.Account__c);
        }
    }

    /*******************************************************************************
    *  Name            : testSendWelcomeEmailOMV()
    *  Summary         : Test sending email to Client for OMV product.
    *  CreatedDate     : 06/04/2021
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testSendWelcomeEmailOMV() {
        String ccsOppRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');

        List<User> User = [SELECT Id, ProfileId FROM User WHERE Profile.Name = 'CCS API System Admin' AND UserRole.Name = 'CCS Administrator' AND IsActive = true LIMIT 1];

        String templateId = [SELECT Id,Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName LIKE 'CCS_Welcome_Email_OMV_CZ_LEX%'][0].Id;

        Account acc = new Account(
                Name = 'TestLotos',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Poland',
                OwnerId= User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert acc;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = acc.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opp = new Opportunity(
                Name = 'Lotos',
                StageName = 'Qualify',
                AccountId = acc.Id,
                Product_Solicited__c = 'OMV',
                Type = 'New GFN',
                CCS_priobjednavka__c = false,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppRecId,
                CloseDate = date.today());
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opp.Id,
                IsPrimary = true,
                Role = 'Decision Maker');
        insert ocr;

        System.runAs(User.get(0)) {
            opp.StageName = 'Closed Won';
            update opp;
        }
    }
}