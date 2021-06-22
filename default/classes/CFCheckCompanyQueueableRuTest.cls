@IsTest
public with sharing class CFCheckCompanyQueueableRuTest {

    @TestSetup
    public static void setup() {
        insert CFTestDataFactory.createCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
    }

    @IsTest
    private static void testCatchException() {
        Test.startTest();
        new CFCheckCompanyQueueableRu(new Set<Id> {null}).processCreditCheck();
        Test.stopTest();

        List<Custom_log__c> logs = ([
                SELECT Id, Errors__c
                FROM Custom_log__c
                WHERE Source__c = :CFUtils.PRESCORING
        ]);
        System.assertEquals(false, logs.isEmpty());
    }

    @IsTest
    private static void testFinallyException() {
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Projected_Liters_weekly__c = null;
        insert opportunity;
        Test.startTest();
        new CFCheckCompanyQueueableRu(new Set<Id> {opportunity.Id}).processCreditCheck();
        Test.stopTest();

        List<Custom_log__c> logs = ([
                SELECT Id, Errors__c
                FROM Custom_log__c
                WHERE Source__c = :CFUtils.PRESCORING
                AND INN__c = :account.INN__c
        ]);
        System.assertEquals(false, logs.isEmpty());

        Opportunity updatedOpportunity = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ]);
        System.assertEquals(false, updatedOpportunity.CF_checking__c);
    }

    @IsTest
    private static void testCheckCompanyCreateReport() {
        Account newAccount = CFTestDataFactory.createLegalAccount();
        insert newAccount;
        Opportunity newOpportunity = CFTestDataFactory.createOpportunity(newAccount);
        insert newOpportunity;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock,
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.companyListMock,
                SparkTestDataFactory.entrepreneurReportURI => SparkTestDataFactory.entrepreneurReportMock,
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.prescoringDecisionMock,
                CFTestDataFactory.blackListURI.replace(CFTestDataFactory.OPPORTUNITY_ID, newOpportunity.Id) => CFTestDataFactory.blackListMock
        }));
        new CFCheckCompanyQueueableRu(new Set<Id> {newOpportunity.Id}).processCreditCheck();
        Test.stopTest();

        Account updatedAccount = ([
                SELECT Id, Spark_ID__c, Black_list_check_decision__c
                FROM Account
                WHERE Id = :newAccount.Id
                LIMIT 1
        ]);
        Opportunity updatedOpportunity = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :newOpportunity.Id
        ]);
        Credit_Factory_Report__c report = ([
                SELECT Id, Account__c, Opportunity__c, RU_scoring_decision__c
                FROM Credit_Factory_Report__c
                WHERE Account__c = :updatedAccount.Id
                AND Opportunity__c = :updatedOpportunity.Id
                AND RU_scoring_type__c = :CFUtils.PRESCORING
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ]);
        System.assertEquals(CFTestDataFactory.SPARK_ID, updatedAccount.Spark_ID__c);
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(0), updatedAccount.Black_list_check_decision__c);
        System.assertEquals(CFUtils.ScoringDecision.Credit_approved.name(), report.RU_scoring_decision__c);
        System.assertEquals(false, updatedOpportunity.CF_checking__c);
    }

    @IsTest
    private static void testCheckCompanyUpdateReport() {
        Account newAccount = CFTestDataFactory.createLegalAccount();
        insert newAccount;
        Opportunity newOpportunity = CFTestDataFactory.createOpportunity(newAccount);
        insert newOpportunity;
        insert CFTestDataFactory.createCreditFactoryReport(newAccount, newOpportunity);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock,
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.companyListMock,
                SparkTestDataFactory.entrepreneurReportURI => SparkTestDataFactory.entrepreneurReportMock,
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.prescoringDecisionMock,
                CFTestDataFactory.blackListURI.replace(CFTestDataFactory.OPPORTUNITY_ID, newOpportunity.Id) => CFTestDataFactory.blackListMock
        }));
        new CFCheckCompanyQueueableRu(new Set<Id> {newOpportunity.Id}).processCreditCheck();
        Test.stopTest();

        Account updatedAccount = ([
                SELECT Id, Spark_ID__c, Black_list_check_decision__c
                FROM Account
                WHERE Id = :newAccount.Id
                LIMIT 1
        ]);
        Opportunity updatedOpportunity = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :newOpportunity.Id
        ]);
        Credit_Factory_Report__c report = ([
                SELECT Id, Account__c, Opportunity__c, RU_scoring_decision__c
                FROM Credit_Factory_Report__c
                WHERE Account__c = :updatedAccount.Id
                AND Opportunity__c = :updatedOpportunity.Id
                AND RU_scoring_type__c = :CFUtils.PRESCORING
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ]);
        System.assertEquals(CFTestDataFactory.SPARK_ID, updatedAccount.Spark_ID__c);
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(0), updatedAccount.Black_list_check_decision__c);
        System.assertEquals(CFUtils.ScoringDecision.Credit_approved.name(), report.RU_scoring_decision__c);
        System.assertEquals(false, updatedOpportunity.CF_checking__c);
    }

    @IsTest
    private static void testSoleProprietor() {
        Account account = CFTestDataFactory.createSoleAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock,
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.companyListMock,
                SparkTestDataFactory.entrepreneurReportURI => SparkTestDataFactory.entrepreneurReportMock,
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.prescoringDecisionMock,
                CFTestDataFactory.blackListSoleURI.replace(CFTestDataFactory.OPPORTUNITY_ID, opportunity.Id) => CFTestDataFactory.blackListMock
        }));
        new CFCheckCompanyQueueableRu(new Set<Id> {opportunity.Id}).processCreditCheck();
        Test.stopTest();

        Account updatedAccount = ([
                SELECT Id, Spark_ID__c, Black_list_check_decision__c
                FROM Account
                WHERE Id = :account.Id
                LIMIT 1
        ]);
        Opportunity updatedOpportunity = ([
                SELECT Id, CF_checking__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ]);
        System.assertEquals(CFTestDataFactory.SPARK_ID, updatedAccount.Spark_ID__c);
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(0), updatedAccount.Black_list_check_decision__c);
        System.assertEquals(false, updatedOpportunity.CF_checking__c);
    }

    @IsTest
    private static void testCompanyBlocked() {
        Account account = CFTestDataFactory.createLegalAccount();
        account.Spark_ID__c = CFTestDataFactory.SPARK_ID;
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock,
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.companyListMock,
                SparkTestDataFactory.entrepreneurReportURI => SparkTestDataFactory.entrepreneurReportMock,
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.prescoringDecisionMock,
                CFTestDataFactory.blackListURI.replace(CFTestDataFactory.OPPORTUNITY_ID, opportunity.Id) => CFTestDataFactory.blackListMockDenial
        }));
        new CFCheckCompanyQueueableRu(new Set<Id> {opportunity.Id}).processCreditCheck();
        Test.stopTest();

        Account updatedAccount = ([
                SELECT Id, Spark_ID__c, Black_list_check_decision__c, Type
                FROM Account
                WHERE Id = :account.Id
                LIMIT 1
        ]);
        Opportunity updatedOpportunity = ([
                SELECT Id, CF_checking__c, StageName, PPR_Lost_Reasons__c
                FROM Opportunity
                WHERE AccountId = :updatedAccount.Id
        ]);
        System.assertEquals(null, new CFServiceRuImpl().getCreditFactoryReportRU(opportunity.Id, CFUtils.ScoringType.Prescoring));
        System.assertEquals(CFTestDataFactory.SPARK_ID, updatedAccount.Spark_ID__c);
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(3), updatedAccount.Black_list_check_decision__c);
        System.assertEquals(false, updatedOpportunity.CF_checking__c);
        System.assertEquals(CFUtils.COMPANY_DENIAL, updatedAccount.Type);
        System.assertEquals(GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused), updatedOpportunity.StageName);
        System.assertEquals(CFUtils.OPPORTUNITY_LOST_REASON, updatedOpportunity.PPR_Lost_Reasons__c);
    }

    @IsTest
    private static void startProcessCreditCheckTest() {
        Account account = CFTestDataFactory.createLegalAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        List<Id> oppId = new List<Id>();
        oppId.add(opportunity.Id);

        Test.startTest();
        CFCheckCompanyQueueableRu.startProcessCreditCheck(oppId);
        Id jobID = System.enqueueJob(new CFCheckCompanyQueueableRu(new Set<Id>(oppId)));
        Test.stopTest();

        List<AsyncApexJob> jobInfo = [SELECT Id FROM AsyncApexJob WHERE Id = :jobID];

        System.assertEquals(1, jobInfo.size());
    }
}