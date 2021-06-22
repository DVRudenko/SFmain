@IsTest
public with sharing class CFDAORuImplTest {
    private static final Id USER_ID = UserInfo.getUserId();

    static {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
    }

    @IsTest
    private static void testUpdateSObjects() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        account.OKPO_ppr__c = 'updated';
        opportunity.E2E_Errors__c = 'updated';
        CFDAO cfRuDao = new CFDAORuImpl();
        cfRuDao.updateSObjects(new List<SObject>{ account, opportunity });
        System.assertEquals('updated', [SELECT OKPO_ppr__c FROM Account WHERE Id = :account.Id].OKPO_ppr__c);
        System.assertEquals('updated', [SELECT E2E_Errors__c FROM Opportunity WHERE Id = :opportunity.Id].E2E_Errors__c);
    }

    @IsTest
    private static void testAccountDao() {
        CFDAO cfRuDao = new CFDAORuImpl();
        Account account = CFTestDataFactory.createAccount();
        insert account;

        account.OGRN_ppr__c = '234234';
        account.OwnerId = USER_ID;
        account.Black_list_check_code__c = '0';
        account.Black_list_check_decision__c = ScoringWebServiceImpl.blackListDecisionMapping.get(0);
        cfRuDao.updateAccounts(new List<Account>{ account });

        account = cfRuDao.getAccountById(account.Id);

        System.assertEquals(account.Spark_ID__c, '3534');
        System.assertEquals(account.OKPO_ppr__c, '2353435');
        System.assertEquals(account.INN__c, '667042907512');
        System.assertEquals(account.Company_Legal_Name1__c, 'legal name');
        System.assertEquals(account.KPP__c, 12345);
        System.assertEquals(account.OKVED__c, 'okved');
        System.assertEquals(account.BillingCity, 'CITY');
        System.assertEquals(account.BillingStreet, 'STREET');
        System.assertEquals(account.BillingPostalCode, 'code');
        System.assertEquals(account.Organization_Type__c, 'ОАО');
        System.assertEquals(account.Name, 'TEST');
        System.assertEquals(account.OGRN_ppr__c, '234234');
        System.assertEquals(account.OwnerId, USER_ID);
        System.assertEquals(account.Black_list_check_code__c, '0');
        System.assertEquals(account.Black_list_check_decision__c, ScoringWebServiceImpl.blackListDecisionMapping.get(0));
    }

    @IsTest
    private static void testOpportunityDao() {
        CFDAORuImpl cfRuDao = new CFDAORuImpl();
        Account account = CFTestDataFactory.createAccount();
        insert account;

        Opportunity opportunity1 = new Opportunity(
            Name = 'refused',
            AccountId = account.Id,
            Business_process__c = GlobalUtils.BusinessProcessType.Standard.name(),
            PPR_Lost_Reasons__c = CFUtils.OPPORTUNITY_LOST_REASON,
            RecordTypeId = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID,
            StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused),
            OwnerId = USER_ID,
            CloseDate = Date.today()
        );
        Opportunity opportunity2 = CFTestDataFactory.createOpportunity(account);
        Opportunity opportunity3 = new Opportunity(
            Name = 'moved to start',
            AccountId = account.Id,
            RecordTypeId = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID,
            Business_process__c = GlobalUtils.BusinessProcessType.Standard.name(),
            StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.MovedToStart),
            OwnerId = USER_ID,
            CloseDate = Date.today()
        );
        insert new List<Opportunity>{ opportunity1, opportunity2, opportunity3 };

        opportunity2.CF_checking__c = true;
        cfRuDao.updateOpportunities(new List<Opportunity>{ opportunity2 });

        opportunity2 = cfRuDao.getOpportunities(new List<Id>{ opportunity2.Id }, new List<Id>{ OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID })
            .get(0);
        System.assertEquals(true, opportunity2.CF_checking__c);
        System.assertEquals(GlobalUtils.BusinessProcessType.Standard.name(), opportunity2.Business_process__c);
        System.assertEquals(account.Id, opportunity2.AccountId);

        List<Opportunity> opportunitiesInWork = cfRuDao.getOpportunitiesByAccountIdAndStages(
            account.Id,
            new List<String>{
                GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.MovedToStart),
                GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused)
            }
        );
        System.assert(opportunitiesInWork.size() == 1);
        System.assertEquals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead), opportunitiesInWork.get(0).StageName);
        System.assertEquals(USER_ID, opportunitiesInWork.get(0).OwnerId);
    }

    @IsTest
    private static void testCreditFactoryReportDao() {
        CFDAORuImpl cfRuDao = new CFDAORuImpl();
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);

        List<Credit_Factory_Report__c> reports = cfRuDao.insertCreditFactoryReports(new List<Credit_Factory_Report__c>{ report });
        System.assertNotEquals(null, report.Id);
        System.assertEquals('Free', [SELECT Id, RU_credit_type__c FROM Credit_Factory_Report__c WHERE Id = :report.Id].RU_credit_type__c);

        report.RU_credit_type__c = 'Paid';
        cfRuDao.updateCreditFactoryReports(new List<Credit_Factory_Report__c>{ report });
        System.assertEquals('Paid', [SELECT Id, RU_credit_type__c FROM Credit_Factory_Report__c WHERE Id = :report.Id].RU_credit_type__c);

        List<Credit_Factory_Report__c> reports1 = cfRuDao.getCFR(new Set<Id>{ reports.get(0).Id });
        System.assertEquals('Paid', reports1.get(0).RU_credit_type__c);

        List<Credit_Factory_Report__c> reports2 = cfRuDao.getCFR(
            new Set<Id>{ opportunity.Id },
            CFUtils.PRESCORING,
            CFUtils.RUSSIAN_CREDIT_RECORD_TYPE
        );
        System.assertEquals('Paid', reports2.get(0).RU_credit_type__c);

        Credit_Factory_Report__c report2 = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report2.RU_Scoring_date__c = report.RU_Scoring_date__c.addDays(5);
        report2.RU_scoring_decision__c = CFUtils.ScoringDecision.Denied.name();
        Credit_Factory_Report__c report3 = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report3.RU_Scoring_date__c = null;
        report3.RU_scoring_decision__c = CFUtils.ScoringDecision.Prepay.name();
        cfRuDao.insertCreditFactoryReports(new List<Credit_Factory_Report__c>{ report2, report3 });

        List<Credit_Factory_Report__c> reports3 = cfRuDao.getCreditFactoryReports(
            new List<Id>{ opportunity.Id },
            CFUtils.RUSSIAN_CREDIT_RECORD_TYPE,
            new List<String>{ CFUtils.ScoringType.Prescoring.name() }
        );
        System.assertEquals(report2.RU_scoring_decision__c, reports3.get(0).RU_scoring_decision__c);
    }

    @IsTest
    private static void testFormDataDAO() {
        CFDAO cfRuDao = new CFDAORuImpl();
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        E2EFormData__c formData = new E2EFormData__c(E2E_Source__c = 'test', E2E_Opportunity_Id__c = opportunity.Id);
        insert formData;

        List<E2EFormData__c> data = cfRuDao.getByOpportunityId(new Set<Id>{ opportunity.Id });
        System.assertEquals('test', data.get(0).E2E_Source__c);
        System.assertEquals(opportunity.Id, data.get(0).E2E_Opportunity_Id__c);
    }

    @IsTest
    private static void testGetActualCFRs_NullParams() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        insert report;

        CFDAO cfRuDao = new CFDAORuImpl();
        List<Credit_Factory_Report__c> cfrRecords = cfRuDao.getActualCFRs(null, null);

        System.assertEquals(new List<Credit_Factory_Report__c>(), cfrRecords);

        cfrRecords = cfRuDao.getActualCFRs(opportunity.Id, null);
        System.assertEquals(new List<Credit_Factory_Report__c>(), cfrRecords);

        cfrRecords = cfRuDao.getActualCFRs(null, new List<Id>());
        System.assertEquals(new List<Credit_Factory_Report__c>(), cfrRecords);

        cfrRecords = cfRuDao.getActualCFRs(null, new List<Id>{ CFUtils.RUSSIAN_CREDIT_RECORD_TYPE });
        System.assertEquals(new List<Credit_Factory_Report__c>(), cfrRecords);
    }

    @IsTest
    private static void testGetActualCFRs_PositiveScenario() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        Opportunity opportunity2 = CFTestDataFactory.createOpportunity(account);
        insert new List<Opportunity>{ opportunity, opportunity2};

        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        Credit_Factory_Report__c reportSecondOpp = CFTestDataFactory.createCreditFactoryReport(account, opportunity2);
        insert new List<Credit_Factory_Report__c>{ report, reportSecondOpp};

        CFDAO cfRuDao = new CFDAORuImpl();
        List<Credit_Factory_Report__c> cfrRecords = cfRuDao.getActualCFRs(opportunity.Id, new List<Id>{ CFUtils.RUSSIAN_CREDIT_RECORD_TYPE });

        System.assertEquals(1, cfrRecords.size());
        System.assertEquals(report.Id, cfrRecords.get(0).Id);

        cfrRecords = cfRuDao.getActualCFRs(opportunity.Id, new List<Id>());

        System.assertEquals(0, cfrRecords.size());
    }

    @IsTest
    private static void getCfrForUpdate() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        insert report;

        CFDAO cfRuDao = new CFDAORuImpl();
        List<Credit_Factory_Report__c> cfrRecords = cfRuDao.getCfrForUpdate(opportunity.id);

        System.assertEquals(report.Id, cfrRecords.get(0).Id);
        System.assertEquals(1, cfrRecords.size());

        cfrRecords = cfRuDao.getCfrForUpdate(null);
        System.assertEquals(0, cfrRecords.size());

    }
}
