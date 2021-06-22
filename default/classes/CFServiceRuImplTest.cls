@IsTest
public class CFServiceRuImplTest {

    private static final String INN = CFTestDataFactory.INN;
    static String sparkId = CFTestDataFactory.SPARK_ID;
    static String opportunityId = CFTestDataFactory.OPPORTUNITY_ID;
    static Map<String, HttpCalloutMock> responsesSpark = SparkTestDataFactory.getMultiResponsesForMock();
    static Map<String, HttpCalloutMock> responsesScoring = CFTestDataFactory.getMultiResponsesForMock();
    static Map<String, HttpCalloutMock> responsesSparkEmpty = SparkTestDataFactory.getMultiResponsesForMockEmpty();
    static Map<String, HttpCalloutMock> responsesScoringEmpty = CFTestDataFactory.getMultiResponsesForMockEmptyDecision();

    @TestSetup
    public static void setup() {
        insert CFTestDataFactory.createCustomSettings();
    }

    // ****** prescoring Service Tests ******* //

    @IsTest
    private static void testGetSparkDataForPrescoringExtendedReportNoData() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.emptyBodyMock
        }));
        CFServiceRuImpl service = new CFServiceRuImpl();
        SparkDataForPrescoring data = service.getSparkDataForPrescoring(SparkTestDataFactory.sparkId, SparkTestDataFactory.inn);
        Test.stopTest();

        System.assertEquals(null, data);

    }

    @IsTest
    private static void testGetSparkDataForPrescoringRiskReportNoData() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.emptyBodyMock
        }));
        CFServiceRuImpl service = new CFServiceRuImpl();
        SparkDataForPrescoring data = service.getSparkDataForPrescoring(SparkTestDataFactory.sparkId, SparkTestDataFactory.inn);
        Test.stopTest();

        System.assertEquals(null, data);

    }

    @IsTest
    private static void testGetSparkDataForPrescoringSuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock
        }));
        CFServiceRuImpl service = new CFServiceRuImpl();
        SparkDataForPrescoring data = service.getSparkDataForPrescoring(SparkTestDataFactory.sparkId, SparkTestDataFactory.inn);
        Test.stopTest();

        System.assertNotEquals(null, data);

    }

    @IsTest
    private static void testProcessPrescoringSuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock,
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.prescoringDecisionMock
        }));
        CFServiceRuImpl service = new CFServiceRuImpl();
        E2EFormParams formParams = CFTestDataFactory.createFormParams(null, null, null);
        DecisionPrescoring decisionPrescoring = service.processPrescoring(SparkTestDataFactory.sparkId, SparkTestDataFactory.inn, 1000, formParams);
        Test.stopTest();

        System.assertEquals('Розничная торговля компьютерами, программным обеспечением и периферийными устройствами', formParams.okvedSpark);
        System.assertEquals('771301001', formParams.kppSpark);
        System.assertEquals('г. Москва', formParams.citySpark);
        System.assertEquals('ул. Хуторская 2-Я', formParams.streetSpark);
        System.assertEquals('127287', formParams.postCodeSpark);
        System.assertEquals('НКТ СОФТВЭР, ООО', formParams.normName);
        System.assertNotEquals(null, decisionPrescoring);
        System.assertEquals(true, decisionPrescoring.decision);
        System.assertEquals('01.01.2020', decisionPrescoring.dateRequest);
        System.assertEquals('01.04.2020', decisionPrescoring.expireDate);
        System.assertEquals(5, decisionPrescoring.creditPeriod);
        System.assertEquals(10, decisionPrescoring.paymentTimeLimit);
        System.assertEquals(5000, decisionPrescoring.overdraft);
        System.assertEquals(false, decisionPrescoring.blocked);
    }

    @IsTest
    private static void testBuildPrescoringRequestBodySuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock,
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock,
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock,
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock,
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock
        }));
        CFServiceRuImpl service = new CFServiceRuImpl();
        SparkDataForPrescoring data = service.getSparkDataForPrescoring(SparkTestDataFactory.sparkId, SparkTestDataFactory.inn);
        Test.stopTest();

        System.assertNotEquals(null, data);
        System.debug(data);

        RequestPrescoring requestPrescoring = service.buildPrescoringRequestBody(data, 10000);
        System.assertEquals('7743676000', requestPrescoring.inn);
        System.assertEquals(true, requestPrescoring.companyStatusIsActing);
        System.assertEquals(true, requestPrescoring.frozenAccounts);
        System.assertEquals(true, requestPrescoring.bankruptcyMessage);
        System.assertNotEquals(null, requestPrescoring.trialsAsPlaintiffLastYear);
        System.assertNotEquals(null, requestPrescoring.trialsAsPlaintiffCurrentYear);
        System.assertNotEquals(null, requestPrescoring.trialsAsDefendantLastYear);
        System.assertNotEquals(null, requestPrescoring.trialsAsDefendantCurrentYear);
        System.assertEquals('Low', requestPrescoring.consolidatedIndicator);
        System.assertEquals(0, requestPrescoring.fixedAssets1150);
        System.assertEquals(0, requestPrescoring.currentAssets1200);
        System.assertEquals(0, requestPrescoring.shortTermLiabilities1500);
        System.assertEquals(0, requestPrescoring.capitalAndReserves1300);
        System.assertEquals(58467000, requestPrescoring.revenue2110);
        System.assertEquals(10000, requestPrescoring.turnover);
        System.assertEquals(0, requestPrescoring.sumExecutionProceedings);
        System.assertEquals(false, requestPrescoring.simultaneousChangeFounderAndCEO);
        System.assertEquals(null, requestPrescoring.prescoringDataId);
        System.assertEquals(null, requestPrescoring.creditApplicationId);
    }

    // ****** E2EFormParams Service Tests ******* //

    @IsTest
    private static void testGetSoleProprietorSparkDataSuccess() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(SparkTestDataFactory.entrepreneurInn, null, opportunityId);
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesSpark));
        cfRuService.setTestSparkWebService(new SparkWebServiceImpl());

        System.assertEquals(true, cfRuService.getSoleProprietorSparkData(formParams));
        Test.stopTest();
        System.assertEquals(SparkTestDataFactory.sparkId, String.valueOf(formParams.sparkId));
        System.assertEquals('Иванов Иван Иванович', formParams.soleProprietorFio);
        System.assertEquals('ИП Иванов Иван Иванович', formParams.mainCompanyFullNameSpark);
        System.assertEquals('309774623800678', formParams.ogrnipSpark);
        System.assertEquals('0116896779', formParams.okpoSpark);
        System.assertEquals(true, formParams.isActing);
        System.assertEquals('Консультирование по вопросам коммерческой деятельности и управления', formParams.okvedSpark);
        System.assertEquals(true, formParams.isSoleProprietor);
    }

    @IsTest
    private static void testGetSoleProprietorSparkDataNoData() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(SparkTestDataFactory.entrepreneurInn, null, opportunityId);
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesSparkEmpty));
        cfRuService.setTestSparkWebService(new SparkWebServiceImpl());

        System.assertEquals(false, cfRuService.getSoleProprietorSparkData(formParams));
        Test.stopTest();
        System.assertEquals(null, formParams.sparkId);
        System.assertEquals(ScoringWebServiceImpl.scoringDecisionMapping.get(1), formParams.scoringDecision);
    }

    @IsTest
    private static void testGetCompanySparkShortDataSuccess() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(SparkTestDataFactory.inn, null, opportunityId);
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesSpark));
        cfRuService.setTestSparkWebService(new SparkWebServiceImpl());

        System.assertEquals(true, cfRuService.getCompanySparkShortData(formParams));
        Test.stopTest();
        System.assertEquals('6329708', String.valueOf(formParams.sparkId));
        System.assertEquals('ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \"НКТ СОФТВЭР\"', formParams.mainCompanyFullNameSpark);
        System.assertEquals('84763430', formParams.okpoSpark);
        System.assertEquals('1087746118162', formParams.ogrnSpark);
        System.assertEquals('г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15', formParams.legalAddressSpark);
        System.assertEquals(false, formParams.isSoleProprietor);
    }

    @IsTest
    private static void testGetCompanySparkShortDataNoData() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(SparkTestDataFactory.inn, null, opportunityId);
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesSparkEmpty));
        cfRuService.setTestSparkWebService(new SparkWebServiceImpl());

        System.assertEquals(false, cfRuService.getCompanySparkShortData(formParams));
        Test.stopTest();
        System.assertEquals(null, formParams.sparkId);
        System.assertEquals(ScoringWebServiceImpl.scoringDecisionMapping.get(1), formParams.scoringDecision);
    }

    @IsTest
    private static void testGetCompanySparkExtendedDataSuccess() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                SparkTestDataFactory.inn,
                Decimal.valueOf(SparkTestDataFactory.sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesSpark));
        cfRuService.setTestSparkWebService(new SparkWebServiceImpl());

        System.assertEquals(true, cfRuService.getCompanySparkExtendedData(formParams));
        Test.stopTest();
        System.assertEquals('6329708', String.valueOf(formParams.sparkId));
        System.assertEquals(true,  formParams.isActing);
        System.assertEquals(String.valueOf(((DateTime) Json.deserialize('"2008-01-28"', DateTime.class)).format('dd.MM.yyyy')),  formParams.registrationDateSpark);
        System.assertEquals('84763430',  formParams.okpoSpark);
        System.assertEquals('1087746118162',  formParams.ogrnSpark);
        System.assertEquals('771301001',  formParams.kppSpark);
        System.assertEquals(false,  formParams.isSoleProprietor);
        System.assertEquals('Розничная торговля компьютерами, программным обеспечением и периферийными устройствами',  formParams.okvedSpark);
        System.assertEquals('127287',  formParams.postCodeSpark);
        System.assertEquals('г. Москва',  formParams.regionSpark);
        System.assertEquals('г. Москва',  formParams.citySpark);
        System.assertEquals('ул. Хуторская 2-Я',  formParams.streetSpark);
        System.assertEquals('дом 38А',  formParams.buildingSpark);
        System.assertEquals('г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15',  formParams.legalAddressSpark);
        System.assertEquals('НКТ СОФТВЭР, ООО', formParams.normName);
    }

    @IsTest
    private static void testGetCompanySparkExtendedDataNoData() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                SparkTestDataFactory.inn,
                Decimal.valueOf(SparkTestDataFactory.sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesSparkEmpty));
        cfRuService.setTestSparkWebService(new SparkWebServiceImpl());

        System.assertEquals(false, cfRuService.getCompanySparkExtendedData(formParams));
        Test.stopTest();
        System.assertEquals(ScoringWebServiceImpl.scoringDecisionMapping.get(1), formParams.scoringDecision);
    }

    @IsTest
    private static void testGetBlackListDecisionDataBlackListDenied() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                INN,
                Decimal.valueOf(sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesScoring));
        cfRuService.setTestScoringWebService(new ScoringWebServiceImpl());

        System.assertEquals(false, cfRuService.getBlackListDecisionData(formParams, CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Black_list_check_when_scoring_expired__c));
        Test.stopTest();
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(3), formParams.verifiedDecision);
        System.assertEquals('3', formParams.verifiedDecisionCode);
        System.assertEquals('0', formParams.verifiedLimitation);
        System.assertEquals(true, cfRuService.isBlackListDataUpdated());
    }

    @IsTest
    private static void testGetBlackListDecisionDataScoringNotExpired() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                INN,
                Decimal.valueOf(sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        formParams.scoringExpirationDate = Date.today().addDays(1);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesScoring));
        cfRuService.setTestScoringWebService(new ScoringWebServiceImpl());

        System.assertEquals(true, cfRuService.getBlackListDecisionData(formParams, CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Black_list_check_when_scoring_expired__c));
        Test.stopTest();
        System.assert(String.isEmpty(formParams.verifiedDecision));
        System.assertEquals(false, cfRuService.isBlackListDataUpdated());
    }

    @IsTest
    private static void testGetBlackListDecisionDataNoData() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                INN,
                Decimal.valueOf(sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesScoringEmpty));
        cfRuService.setTestScoringWebService(new ScoringWebServiceImpl());

        System.assertEquals(false, cfRuService.getBlackListDecisionData(formParams, CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Black_list_check_when_scoring_expired__c));
        Test.stopTest();
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(-1), formParams.verifiedDecision);
        System.assertEquals(true, cfRuService.isBlackListDataUpdated());
    }

    @IsTest
    private static void testGetScoringDecisionDataSuccess() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                INN,
                Decimal.valueOf(sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesScoring));
        cfRuService.setTestScoringWebService(new ScoringWebServiceImpl());

        System.assertEquals(true, cfRuService.getScoringDecisionData(formParams));
        Test.stopTest();
        System.assertEquals(ScoringWebServiceImpl.scoringDecisionMapping.get(1), formParams.scoringDecision);
        System.assertEquals('3', formParams.scoringDecisionCode);
        System.assert(String.isNotEmpty(formParams.scoringDateString));
        System.assertNotEquals(null, formParams.scoringDate);
        System.assertEquals(true, cfRuService.isScoringDataUpdated());
    }

    @IsTest
    private static void testGetScoringDecisionDataNoData() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                INN,
                Decimal.valueOf(sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesScoringEmpty));
        cfRuService.setTestScoringWebService(new ScoringWebServiceImpl());

        System.assertEquals(false, cfRuService.getScoringDecisionData(formParams));
        Test.stopTest();
        System.assertEquals(ScoringWebServiceImpl.scoringDecisionMapping.get(1), formParams.scoringDecision);
        System.assert(String.isEmpty(formParams.scoringDecisionCode));
        System.assertEquals(true, cfRuService.isScoringDataUpdated());
    }

    @IsTest
    private static void testGetScoringDecisionDataScoringNotExpired() {
        insert CFUtilsTest.createCFSettingsForRussia(true);
        E2EFormParams formParams = CFTestDataFactory.createFormParams(
                INN,
                Decimal.valueOf(sparkId),
                opportunityId
        );
        CFServiceRuImpl cfRuService = new CFServiceRuImpl();
        formParams.scoringExpirationDate = Date.today().addDays(1);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(responsesScoring));
        cfRuService.setTestScoringWebService(new ScoringWebServiceImpl());

        System.assertEquals(true, cfRuService.getScoringDecisionData(formParams));
        Test.stopTest();
        System.assert(String.isEmpty(formParams.scoringDecision));
        System.assertEquals(false, cfRuService.isScoringDataUpdated());
    }

    // ****** Account Service Tests ******* //

    @IsTest
    private static void testAccountService() {
//        User user = E2EFormRuTestUtils.createUser();
//        insert user;
        CF_Settings__c settings = CFUtilsTest.createCFSettingsForRussia(true);
//        settings.Blocked_companies_owner_ID__c = UserInfo.getUserId();
//        System.runAs(user) {
            insert settings;
            String refused = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Refused);
            String ownerId = CFUtils.getCFSettingsFor(GlobalUtils.FleetcorCountries.Russia.name()).Blocked_companies_owner_ID__c;
            System.assertNotEquals(ownerId, UserInfo.getUserId());
            CFServiceRuImpl cfRuServiceImpl = new CFServiceRuImpl();
            Account account = CFTestDataFactory.createAccount();
            insert account;
            insert new List<Opportunity> {
                    new Opportunity(
                            Name = 'Client_Negotiations',
                            AccountId = account.Id,
                            OwnerId = UserInfo.getUserId(),
                            RecordTypeId = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID,
                            StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations),
                            CloseDate = Date.today()
                    ),
                    CFTestDataFactory.createOpportunity(account),
                    new Opportunity(
                            Name = 'Check_Credit_History',
                            AccountId = account.Id,
                            OwnerId = UserInfo.getUserId(),
                            RecordTypeId = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID,
                            StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Check_Credit_History),
                            CloseDate = Date.today()
                    )
            };
            E2EFormParams formParams = CFTestDataFactory.createFormParams('12423', Decimal.valueOf('12443'), opportunityId);
            CFTestDataFactory.populateDataForCF(formParams);
            formParams.isSoleProprietor = true;

            // **** TESTS ****//
            //sole proprietor and black list test
            cfRuServiceImpl.updateAccountSparkData(account, formParams);
            cfRuServiceImpl.updateAccountBlackListData(account, formParams);
            Account updatedAccount = cfRuServiceImpl.getAccountById(account.Id);
            System.assertEquals(formParams.verifiedDecision, updatedAccount.Black_list_check_decision__c);
            System.assertEquals(formParams.verifiedDecisionCode, updatedAccount.Black_list_check_code__c);
            System.assertEquals('12345', updatedAccount.Spark_ID__c);
            System.assertEquals('okved', updatedAccount.OKVED__c);
            System.assertEquals('7564564', updatedAccount.OKPO_ppr__c);
            System.assertEquals('12423', updatedAccount.INN__c);
            System.assertEquals('Company', updatedAccount.Company_Legal_Name1__c);
            System.assertEquals(Decimal.valueOf('9087070'), updatedAccount.KPP__c);
            System.assertEquals('127287', updatedAccount.BillingPostalCode);
            System.assertEquals('ул. Хуторская 2-Я'.toUpperCase(), updatedAccount.BillingStreet);
            System.assertEquals('г. Москва'.toUpperCase(), updatedAccount.BillingCity);
            System.assertEquals('123456', updatedAccount.OGRN_ppr__c);
            System.assertEquals('FIO', updatedAccount.Name);
            System.assertEquals('ИП', updatedAccount.Organization_Type__c);

            //company test
            formParams.isSoleProprietor = false;
            formParams.companyInn = '';
            formParams.okvedSpark = '';
            cfRuServiceImpl.updateAccountSparkData(account, formParams);
            updatedAccount = cfRuServiceImpl.getAccountById(account.Id);
            //INN and OKVED must be a prior one, other changed
            System.assertEquals('12423', updatedAccount.INN__c);
            System.assertEquals('okved', updatedAccount.OKVED__c);
            System.assertEquals('ООО', updatedAccount.Organization_Type__c);
            System.assertEquals('НКТ СОФТВЭР', updatedAccount.Name);
            System.assertEquals('4576756756', updatedAccount.OGRN_ppr__c);

            //block test
            //because of SPARK
            cfRuServiceImpl.blockReason = CFUtils.CompanyBlockReason.SPARK;
            cfRuServiceImpl.blockCompany(updatedAccount);
            Account blockedAccount = ([
                    SELECT Id, Organization_Type__c, OwnerId, (
                            SELECT Id, StageName, PPR_Lost_Reasons__c, OwnerId
                            FROM Opportunities
                    )
                    FROM Account
                    WHERE Id = :account.Id
                    LIMIT 1
            ]);
            System.assertEquals(CFUtils.COMPANY_NON_ACTIVE, blockedAccount.Organization_Type__c);
//            System.assertEquals(ownerId, blockedAccount.OwnerId);
            for (Opportunity blockedOpportunity : blockedAccount.Opportunities) {
//                System.assertEquals(ownerId, blockedOpportunity.OwnerId);
                System.assertEquals(refused, blockedOpportunity.StageName);
                System.assertEquals(CFUtils.OPPORTUNITY_LOST_REASON, blockedOpportunity.PPR_Lost_Reasons__c);
            }
            //because of Scoring or BB
            cfRuServiceImpl.blockReason = CFUtils.CompanyBlockReason.BlackList;
            cfRuServiceImpl.blockCompany(updatedAccount);
            blockedAccount = ([
                    SELECT Id, Type, OwnerId, (
                            SELECT Id, StageName, PPR_Lost_Reasons__c, OwnerId
                            FROM Opportunities
                    )
                    FROM Account
                    WHERE Id = :account.Id
                    LIMIT 1
            ]);
            System.assertEquals(CFUtils.COMPANY_DENIAL, blockedAccount.Type);
//        }

    }

    // **** Credit factory report service Tests **** //

    @IsTest
    private static void testCreditFactoryReportService() {
        E2EFormParams formParams = CFTestDataFactory.createFormParams('14234', null, opportunityId);
        formParams.opportunityId = null;
        CFTestDataFactory.populateDataForCF(formParams);
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations);
        insert opportunity;
        CFServiceRuImpl cfRuServiceImpl = new CFServiceRuImpl();

        Credit_Factory_Report__c report = cfRuServiceImpl.createCFRuPrescoringData(formParams, true);
        Credit_Factory_Report__c toUpdate = ([
                SELECT Id, Name, RU_scoring_type__c, RecordTypeId, RU_scoring_decision_code__c, RU_Scoring_date__c,
                        RU_Scoring_expiration_date__c, RU_scoring_decision__c, Opportunity__c, Account__c
                FROM Credit_Factory_Report__c
                WHERE Id = :report.Id
                LIMIT 1
        ]);
        System.assertEquals(CFUtils.PRESCORING_RU, toUpdate.Name);
        System.assertEquals(CFUtils.PRESCORING, toUpdate.RU_scoring_type__c);
        System.assertEquals(CFUtils.RUSSIAN_CREDIT_RECORD_TYPE, toUpdate.RecordTypeId);
        System.assertEquals(formParams.scoringDecision, toUpdate.RU_scoring_decision__c);
        System.assertEquals(formParams.scoringExpirationDate, toUpdate.RU_Scoring_expiration_date__c);
        System.assertEquals(formParams.scoringDecisionCode, toUpdate.RU_scoring_decision_code__c);
        System.assertEquals(formParams.scoringDate, toUpdate.RU_Scoring_date__c);

        formParams.accountId = account.Id;
        formParams.opportunityId = opportunity.Id;
        formParams.scoringDecision = ScoringWebServiceImpl.scoringDecisionMapping.get(1);
        formParams.scoringDecisionCode = '1';
        cfRuServiceImpl.updateCFRuPrescoringData(toUpdate, formParams);
        Credit_Factory_Report__c updated = ([
                SELECT Id, Opportunity__c, Account__c, RU_scoring_decision_code__c, RU_scoring_decision__c
                FROM Credit_Factory_Report__c
                WHERE Id = :toUpdate.Id
                LIMIT 1
        ]);
        System.assertEquals(formParams.opportunityId, updated.Opportunity__c);
        System.assertEquals(formParams.accountId, updated.Account__c);
        System.assertEquals(formParams.scoringDecision, updated.RU_scoring_decision__c);
        System.assertEquals(formParams.scoringDecisionCode, updated.RU_scoring_decision_code__c);

        OpportunityScoring scoring = new OpportunityScoring();
        scoring.opportunityId = opportunity.Id;
        scoring.notificationSent = false;
        scoring.accountId = account.Id;
        scoring.sourceOfLead = false;
        scoring.newLegal = false;
        scoring.differentPostAddress = false;
        scoring.firstBill = false;
        cfRuServiceImpl.createFRAUDScoringData(scoring);
        Credit_Factory_Report__c report2 = cfRuServiceImpl.getCFR(scoring.opportunityId, CFUtils.FRAUD_SCORING_TYPE, CFUtils.RUSSIAN_FRAUD_RECORD_TYPE);
        System.assertEquals(scoring.opportunityId, report2.Opportunity__c);
        System.assertEquals(scoring.notificationSent, report2.Scoring_notification_sent__c);
        System.assertEquals(scoring.accountId, report2.Account__c);
        System.assertEquals(scoring.sourceOfLead, report2.Source_of_lead_matched__c);
        System.assertEquals(scoring.newLegal, report2.New_legal__c);
        System.assertEquals(scoring.differentPostAddress, report2.Different_post_address__c);
        System.assertEquals(scoring.firstBill, report2.First_bill__c);

        scoring.notificationSent = true;
        scoring.sourceOfLead = true;
        scoring.newLegal = true;
        scoring.differentPostAddress = true;
        scoring.firstBill = true;
        cfRuServiceImpl.updateFRAUDScoringData(report2, scoring);
        report2 = cfRuServiceImpl.getCFRById(report2.Id);
        System.assertEquals(scoring.opportunityId, report2.Opportunity__c);
        System.assertEquals(scoring.notificationSent, report2.Scoring_notification_sent__c);
        System.assertEquals(scoring.accountId, report2.Account__c);
        System.assertEquals(scoring.sourceOfLead, report2.Source_of_lead_matched__c);
        System.assertEquals(scoring.newLegal, report2.New_legal__c);
        System.assertEquals(scoring.differentPostAddress, report2.Different_post_address__c);
        System.assertEquals(scoring.firstBill, report2.First_bill__c);

        // test new prescoring
        DecisionPrescoring testData = CFTestDataFactory.createPrescoringResponseBody(true, false);
        Credit_Factory_Report__c decisionTrueBlockedFalse = cfRuServiceImpl.createPrescoringData(testData, opportunity);
        decisionTrueBlockedFalse = cfRuServiceImpl.getCFRById(decisionTrueBlockedFalse.Id);
        System.assertEquals(opportunity.Id, decisionTrueBlockedFalse.Opportunity__c);
        System.assertEquals(opportunity.AccountId, decisionTrueBlockedFalse.Account__c);
        System.assertEquals(CFUtils.PRESCORING_RU, decisionTrueBlockedFalse.Name);
        System.assertEquals(CFUtils.PRESCORING, decisionTrueBlockedFalse.RU_scoring_type__c);
        System.assertEquals(CFUtils.RUSSIAN_CREDIT_RECORD_TYPE, decisionTrueBlockedFalse.RecordTypeId);
        System.assertEquals(testData.blocked, decisionTrueBlockedFalse.RU_Application_Blocked__c);
        System.assertEquals(CFUtils.ScoringDecision.Credit_approved.name(), decisionTrueBlockedFalse.RU_scoring_decision__c);
        System.assertEquals(testData.creditPeriod, decisionTrueBlockedFalse.RU_Scoring_Credit_Period__c);
        System.assertEquals(testData.paymentTimeLimit, decisionTrueBlockedFalse.RU_Scoring_Payment_Time_Limit__c);
        System.assertEquals(String.valueOf(testData.overdraft), decisionTrueBlockedFalse.Credit_Limit__c);
        System.assertEquals(CFUtils.parsePrescoringDate(testData.expireDate), decisionTrueBlockedFalse.RU_Scoring_expiration_date__c);
        System.assertEquals(CFUtils.parsePrescoringDate(testData.dateRequest), decisionTrueBlockedFalse.RU_Scoring_date__c);

        testData = CFTestDataFactory.createPrescoringResponseBody(false, true);
        Credit_Factory_Report__c decisionFalseBlockedTrue = cfRuServiceImpl.updatePrescoringData(testData, decisionTrueBlockedFalse.Id);
        decisionFalseBlockedTrue = cfRuServiceImpl.getCFRById(decisionFalseBlockedTrue.Id);
        System.assertEquals(CFUtils.ScoringDecision.Denied.name(), decisionFalseBlockedTrue.RU_scoring_decision__c);

        testData = CFTestDataFactory.createPrescoringResponseBody(false, false);
        Credit_Factory_Report__c decisionFalseBlockedFalse = cfRuServiceImpl.updatePrescoringData(testData, decisionFalseBlockedTrue.Id);
        decisionFalseBlockedFalse = cfRuServiceImpl.getCFRById(decisionFalseBlockedFalse.Id);
        System.assertEquals(CFUtils.ScoringDecision.Prepay.name(), decisionFalseBlockedFalse.RU_scoring_decision__c);

        testData = CFTestDataFactory.createPrescoringResponseBody(true, true);
        Credit_Factory_Report__c decisionTrueBlockedTrue = cfRuServiceImpl.updatePrescoringData(testData, decisionFalseBlockedFalse.Id);
        decisionTrueBlockedTrue = cfRuServiceImpl.getCFRById(decisionTrueBlockedTrue.Id);
        System.assertEquals(CFUtils.ScoringDecision.Denied.name(), decisionTrueBlockedTrue.RU_scoring_decision__c);

        testData = CFTestDataFactory.createPrescoringResponseBody(null, null);
        Credit_Factory_Report__c nullDecisionNullBlocked = cfRuServiceImpl.updatePrescoringData(testData, decisionTrueBlockedTrue.Id);
        nullDecisionNullBlocked = cfRuServiceImpl.getCFRById(nullDecisionNullBlocked.Id);
        System.assertEquals(CFUtils.ScoringDecision.No_data.name(), nullDecisionNullBlocked.RU_scoring_decision__c);
        System.assertEquals(true, nullDecisionNullBlocked.RU_Application_Blocked__c);

        Credit_Factory_Report__c report3 = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report3.RU_Scoring_date__c = Date.today().addYears(10);
        report3.RU_scoring_decision__c = CFUtils.ScoringDecision.No_data.name();
        insert report3;

        Credit_Factory_Report__c report4 = cfRuServiceImpl.getCreditFactoryReportRU(opportunity.Id, CFUtils.ScoringType.Prescoring);
        System.assertEquals(report3.RU_scoring_decision__c, report4.RU_scoring_decision__c);
        System.assertEquals(report3.RU_Scoring_date__c, report4.RU_Scoring_date__c);
    }

    @IsTest
    private static void testOpportunityService() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations);
        insert opportunity;
        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        insert report;
        System.assertEquals(false, opportunity.CF_checking__c);

        CFServiceRuImpl cfRuServiceImpl = new CFServiceRuImpl();
        opportunity.CF_checking__c = true;
        cfRuServiceImpl.updateOpportunity(opportunity);
        Opportunity createdOpportunity = cfRuServiceImpl.getRussianOpportunity(opportunity.Id);
        System.assertEquals(true, createdOpportunity.CF_checking__c);
    }

    @IsTest
    private static void testFormDataService() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Client_Negotiations);
        insert opportunity;
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Source__c = 'test',
                E2E_Opportunity_Id__c = opportunity.Id
        );
        insert formData;
        CFServiceRuImpl cfRuServiceImpl = new CFServiceRuImpl();

        formData = cfRuServiceImpl.getByOpportunityId(opportunity.Id);
        System.assertEquals('test', formData.E2E_Source__c);
        System.assertEquals(opportunity.Id, formData.E2E_Opportunity_Id__c);
    }

    @IsTest
    private static void processOpportunityScoringTestAllCriteriaMet() {
        E2EFormParams params = new E2EFormParams();
        params.source = 'petrolplus.ru';
        params.prepayAmount = '1000000';
        params.companyLegalAddress = 'test';
        params.postalAddress = 'test1';
        params.registrationDateSpark = Date.today().format();
        CFServiceRuImpl service = new CFServiceRuImpl();
        OpportunityScoring scoring = service.processOpportunityScoring(params);

        System.assert(scoring.sourceOfLead);
        System.assert(scoring.differentPostAddress);
        System.assert(scoring.firstBill);
        // uncommit after fixing problem with formatting
        // System.assert(scoring.newLegal);
        System.assert(scoring.totalPoints > 0);
    }

    @IsTest
    private static void processOpportunityScoringTestNoCriteriaMet() {
        E2EFormParams params = new E2EFormParams();
        params.source = 'sdf';
        params.prepayAmount = '545';
        params.companyLegalAddress = 'test';
        params.postalAddress = 'test';
        params.registrationDateSpark = Date.today().addYears(-2).format();
        CFServiceRuImpl service = new CFServiceRuImpl();
        OpportunityScoring scoring = service.processOpportunityScoring(params);

        System.assert(!scoring.sourceOfLead);
        System.assert(!scoring.differentPostAddress);
        System.assert(!scoring.firstBill);
        System.assert(!scoring.newLegal);
        System.assertEquals(0, scoring.totalPoints);
    }

    @IsTest
    private static void sendFRAUDNotificationTest() {
        List<E2EFormParams> data = new List<E2EFormParams>();
        for (Integer i = 0; i < 2; i++) {
            E2EFormParams params = new E2EFormParams();
            params.source = 'sdf';
            params.prepayAmount = '545';
            params.companyLegalAddress = 'test';
            params.postalAddress = 'test';
            params.registrationDateSpark = Date.today().addYears(-2).format();
            params.transitContId = 'test';
            params.companyName = 'test';
            params.companyInn = 'test';
            data.add(params);
        }
        CFServiceRuImpl service = new CFServiceRuImpl();
        service.sendFRAUDNotification(data);
    }

    @IsTest
    private static void prepareScoringDataForTransitTest() {
        CFServiceRuImpl service = new CFServiceRuImpl();
        TransitRequestData.ContMonitoring monitoring = service.prepareScoringDataForTransit(
                CFTestDataFactory.createDefaultOpportunityScoring(true)
        );
        System.assertEquals(1, monitoring.differentPostAddress);
        System.assertEquals(1, monitoring.firstBill);
        System.assertEquals(1, monitoring.newLegal);
        System.assertEquals(1, monitoring.sourceOfLead);
        System.assertEquals(1, monitoring.notificationSent);

        monitoring = service.prepareScoringDataForTransit(
                CFTestDataFactory.createFRAUDReport(false)
        );
        System.assertEquals(0, monitoring.differentPostAddress);
        System.assertEquals(0, monitoring.firstBill);
        System.assertEquals(0, monitoring.newLegal);
        System.assertEquals(0, monitoring.sourceOfLead);
        System.assertEquals(0, monitoring.notificationSent);
    }

    @IsTest
    private static void testCheckBBLApprovalProcess_WrongValues() {
        E2EFormParams formParams = null;
        CFServiceRuImpl service = new CFServiceRuImpl();
        Boolean approvalResult = service.checkBBLApprovalProcess(formParams);

        System.assert(!approvalResult, 'Should be false, because no data for detecting record');

        formParams = new E2EFormParams();
        approvalResult = service.checkBBLApprovalProcess(formParams);

        System.assert(!approvalResult, 'Should be false, because no data for detecting record');

        CF_Settings__c cfSetting = CFUtilsTest.createCFSettingsForRussia(true);
        insert cfSetting;
        approvalResult = service.checkBBLApprovalProcess(formParams);

        System.assert(!approvalResult, 'Should be false, because no data for detecting record');

        cfSetting.Approval_Process_Name__c = '';
        update cfSetting;
        approvalResult = service.checkBBLApprovalProcess(formParams);

        System.assert(!approvalResult, 'Should be false, because no data for detecting record');
    }

    @IsTest
    private static void testCheckBBLApprovalProcess_VariationsOfResult() {
        OpportunityTriggerHandler.enablesTrigger = false;
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        // select any process for testing
        List<ProcessDefinition> opportunityAprrovals = [SELECT DeveloperName FROM ProcessDefinition WHERE TableEnumOrId = 'Opportunity'];
        Boolean resultNotEmpty = !opportunityAprrovals.isEmpty() && opportunityAprrovals.get(0).DeveloperName != null;
        String processName = (resultNotEmpty) ? opportunityAprrovals.get(0).DeveloperName : 'ProcessName';

        E2EFormParams formParams = CFTestDataFactory.createFormParams('14234', null, opportunity.Id);
        CF_Settings__c cfSetting = CFUtilsTest.createCFSettingsForRussia(true);
        cfSetting.Approval_Process_Name__c = processName;
        insert cfSetting;
        CFServiceRuImpl service = new CFServiceRuImpl();
        Boolean approvalResult = service.checkBBLApprovalProcess(formParams);

        System.assert(!approvalResult, 'Empty history of approval process should be');

        try {
            // prepare request
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId(opportunity.Id);
            approvalRequest.setProcessDefinitionNameOrId(processName);
            approvalRequest.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(approvalRequest);

            // Prepare for approve
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            Approval.ProcessWorkitemRequest approvalRequestSubmit = new Approval.ProcessWorkitemRequest();
            approvalRequestSubmit.setComments('Approving request');
            approvalRequestSubmit.setAction('Approve');
            approvalRequestSubmit.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            approvalRequestSubmit.setWorkitemId(newWorkItemIds.get(0));
            Approval.process(approvalRequestSubmit);

            approvalResult = service.checkBBLApprovalProcess(formParams);
            System.assert(approvalResult);
            System.assert(!service.companyIsToBeBlocked(), 'Company should not be blocked');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Smth wrong with approval, we testing only result of approve.' + ' Exception: ' + e.getMessage());
        }
    }

    @IsTest
    private static void testGetActualCFRs_NullParam() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report.RU_Application_Blocked__c = false;
        insert report;

        CFService service = new CFServiceRuImpl();
        List<Credit_Factory_Report__c> cfrRecords = service.getActualCFRs(null);

        System.assertEquals(0, cfrRecords.size());
    }

    @IsTest
    private static void testGetActualCFRs_PositiveScenario() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        Opportunity opportunity2 = CFTestDataFactory.createOpportunity(account);
        insert new List<Opportunity>{ opportunity, opportunity2};

        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report.RU_Application_Blocked__c = false;
        Credit_Factory_Report__c reportSecondOpp = CFTestDataFactory.createCreditFactoryReport(account, opportunity2);
        reportSecondOpp.RU_Application_Blocked__c = false;
        insert new List<Credit_Factory_Report__c>{ report, reportSecondOpp};

        CFService service = new CFServiceRuImpl();
        List<Credit_Factory_Report__c> cfrRecords = service.getActualCFRs(opportunity.Id);

        System.assertEquals(1, cfrRecords.size());
        System.assertEquals(report.Id, cfrRecords.get(0).Id);
    }

    @IsTest
    private static void testGetChosenCFR() {
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;

        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        report.RU_Application_Blocked__c = false;
        report.RU_Client_Choice__c = true;
        insert report;

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c creditFactoryReport = service.getChosenCFR(null);
        System.assertEquals(null, creditFactoryReport);

        creditFactoryReport = service.getChosenCFR(opportunity.Id);
        System.assertEquals(report.Id, creditFactoryReport.Id);

        report.RU_Client_Choice__c = false;
        update report;
        creditFactoryReport = service.getChosenCFR(opportunity.Id);
        System.assertEquals(null, creditFactoryReport);
    }

    @IsTest
    private static void testSaveChekedCFR() {
        CFDAORuImpl cfRuDao = new CFDAORuImpl();
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        insert opportunity;
        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        insert report;

        E2EFormParams formParams = new E2EFormParams();

        formParams.creditDecision = report.id;
        service.saveChekedCFR(opportunity.id, formParams);
        List<Credit_Factory_Report__c> cfrsForUpdate = cfRuDao.getCfrForUpdate(opportunity.id);
        System.assertEquals(true, cfrsForUpdate[0].RU_Client_choice__c);

        formParams.creditDecision = CFUtils.PRESCORING_RU;
        service.saveChekedCFR(opportunity.id, formParams);
        cfrsForUpdate = cfRuDao.getCfrForUpdate(opportunity.id);
        System.assertEquals(false, cfrsForUpdate[0].RU_Client_choice__c);
    }
}
