public with sharing class CFTestDataFactory {

    public static final String URL = 'http://99.240.174.55/PPRMiddleware';
    public static final String TOKEN = 'token';

    public static final String INN = '7743676000';
    public static final String SPARK_ID = '6329708';
    public static String ogrn = '1087746118162';
    public static final String OPPORTUNITY_ID = '0066E0000058ZwnQAE';
    public static final String SOLE_INN = '770605086143';
    public static Map<String, String> responseHeaders = new Map<String, String>{
            'Authorization' => TOKEN
    };
    public static String blackListURI = URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' +
            OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID;
    public static String blackListSoleURI = URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' +
            OPPORTUNITY_ID + '&inn=' + SOLE_INN + '&sparkId=' + SPARK_ID;
    public static SingleRequestMock blackListMock = new SingleRequestMock(
            200, 'Complete',
            '{"statusCode":200,"message":"Scoring Integration",' +
                    '"content":{"decision":0,"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
            responseHeaders);
    public static SingleRequestMock blackListMockDenial = new SingleRequestMock(
            200, 'Complete',
            '{"statusCode":200,"message":"Scoring Integration",' +
                    '"content":{"decision":3,"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
            responseHeaders);
    public static String prescoringDecisionURI = URL + '/scoring/get-decision-prescoring';
    public static SingleRequestMock prescoringDecisionMock = new SingleRequestMock(
            200, 'Complete',
            '{"statusCode":200, "message":"Scoring Integration", "content": {\n' +
                    '    "decision": true,\n' +
                    '    "dateRequest":"01.01.2020",\n' +
                    '    "expireDate": "01.04.2020",\n' +
                    '    "creditPeriod": 5,\n' +
                    '    "paymentTimeLimit": 10,\n' +
                    '    "overdraft": 5000,\n' +
                    '    "blocked": false\n' +
                    '}}',
            responseHeaders
    );
    public static SingleRequestMock noDataMock = new SingleRequestMock(
            200, 'Complete',
            '{"statusCode":400,"message":"Scoring Integration",' +
                    '"content":{}}',
    responseHeaders);

    public static E2E_Form_Ru_General_Settings__c createCustomSettings() {
        return new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Middleware_Url__c = URL,
                Test_Middleware_Url__c = URL,
                Middleware_Token__c = TOKEN
        );
    }

    public static DecisionPrescoring createPrescoringResponseBody(Boolean decision, Boolean isBlocked) {
        DecisionPrescoring data = new DecisionPrescoring();
        data.decision = decision;
        data.dateRequest = '01.01.2020';
        data.expireDate = '01.04.2020';
        data.creditPeriod = 10;
        data.paymentTimeLimit = 20;
        data.overdraft = 100000;
        data.blocked = isBlocked;
        return data;
    }

    public static RequestPrescoring createPrescoringRequestBody() {
        RequestPrescoring requestPrescoring = new RequestPrescoring();
        requestPrescoring.prescoringDataId = '534554';
        requestPrescoring.creditApplicationId = '5345435';
        requestPrescoring.inn = INN;
        requestPrescoring.companyStatusIsActing = true;
        requestPrescoring.frozenAccounts = false;
        requestPrescoring.bankruptcyMessage = false;
        requestPrescoring.dateFirstReg = String.valueOf(Date.today());
        requestPrescoring.trialsAsPlaintiffLastYear = 10;
        requestPrescoring.trialsAsPlaintiffCurrentYear = 10;
        requestPrescoring.trialsAsDefendantLastYear = 10;
        requestPrescoring.trialsAsDefendantCurrentYear = 10;
        requestPrescoring.consolidatedIndicator = 'test';
        requestPrescoring.fixedAssets1150 = 1000;
        requestPrescoring.currentAssets1200 = 1000;
        requestPrescoring.shortTermLiabilities1500 = 1000;
        requestPrescoring.capitalAndReserves1300 = 1000;
        requestPrescoring.revenue2110 = 1000;
        requestPrescoring.turnover = 1000;
        requestPrescoring.sumExecutionProceedings = 25.2;
        requestPrescoring.simultaneousChangeFounderAndCEO = true;
        return requestPrescoring;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {
        SingleRequestMock getJSONCompanyVerification = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"decision":3,"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"decision":3,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(blackListURI, getJSONCompanyVerification);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONScoringDecision);
        responses.put(prescoringDecisionURI, prescoringDecisionMock);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMockEmptyDecision() {
        SingleRequestMock getJSONCompanyVerification = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}',
                responseHeaders);

        SingleRequestMock getJSONPrescoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200, "message":"Scoring Integration", "content": {}}',
                responseHeaders
        );

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONCompanyVerification);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONScoringDecision);
        responses.put(prescoringDecisionURI, getJSONPrescoringDecision);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMockError500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyVerificationError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecisionError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONPrescoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":500, "message":"Scoring Integration", "content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders
        );

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONCompanyVerificationError500);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONScoringDecisionError500);
        responses.put(URL + '/scoring/get-decision-prescoring', getJSONPrescoringDecision);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyVerification500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONPrescoringDecision = new SingleRequestMock(
                500, 'Complete',
                '{"statusCode":500, "message":"Scoring Integration", "content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders
        );

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONCompanyVerification500);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + OPPORTUNITY_ID + '&inn=' + INN + '&sparkId=' + SPARK_ID, getJSONScoringDecision500);
        responses.put(URL + '/scoring/get-decision-prescoring', getJSONPrescoringDecision);
        return responses;
    }

    public static Account createAccount() {
        Account account = new Account(
                Spark_ID__c = '3534',
                OKPO_ppr__c = '2353435',
                INN__c = '667042907512',
                Company_Legal_Name1__c = 'legal name',
                KPP__c = 12345,
                OKVED__c = 'okved',
                BillingCountry = 'Russia',
                BillingCity = 'city',
                BillingStreet = 'street',
                BillingPostalCode = 'code',
                Organization_Type__c = 'ОАО',
                Name = 'test'
        );
        return account;
    }

    public static Account createRussianAccount(String inn) {
        return new Account(
                INN__c = inn,
                BillingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                Name = 'test'
        );
    }

    public static Account createLegalAccount() {
        return createRussianAccount(INN);
    }

    public static Account createSoleAccount() {
        return createRussianAccount(SOLE_INN);
    }

    public static Opportunity createOpportunity(Account account) {
        Opportunity opportunity = new Opportunity(
                Name = 'in progress',
                AccountId = account.Id,
                Business_process__c = GlobalUtils.BusinessProcessType.Standard.name(),
                RecordTypeId = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID,
                StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
                OwnerId = UserInfo.getUserId(),
                CloseDate = Date.today(),
                Projected_Liters_weekly__c = 1000
        );
        return opportunity;
    }

    public static void populateDataForCF(E2EFormParams formParams) {
        formParams.isActing = false;
        formParams.sparkId = 12345;
        formParams.soleProprietorFio = 'FIO';
        formParams.mainCompanyFullNameSpark = 'Company';
        formParams.registrationDateSpark = '01.01.2000';
        formParams.ogrnipSpark = '123456';
        formParams.okpoSpark = '7564564';
        formParams.ogrnSpark = '4576756756';
        formParams.kppSpark = '9087070';
        formParams.okvedSpark = 'okved';
        formParams.legalAddressSpark = 'Владимирская обл, г. Гусь-Хрустальный, проспект 50 Лет Советской Власти, д. 8';
        formParams.postCodeSpark = '127287';
        formParams.regionSpark = 'г. Москва';
        formParams.citySpark = 'г. Москва';
        formParams.streetSpark = 'ул. Хуторская 2-Я';
        formParams.buildingSpark = 'дом 38А';
        formParams.normName = 'НКТ СОФТВЭР, ООО';

        formParams.verifiedDecision = ScoringWebServiceImpl.blackListDecisionMapping.get(0);
        formParams.verifiedDecisionCode = '0';
        formParams.verifiedLimitation = '10';
        formParams.scoringDecision = ScoringWebServiceImpl.scoringDecisionMapping.get(0);
        formParams.scoringDecisionCode = '0';
        formParams.scoringDateString = ((Datetime) Date.today()).format('dd.MM.yyyy');
        formParams.scoringDate = Date.today();
        formParams.scoringExpirationDate = formParams.scoringDate.addMonths(3);
    }

    public static E2EFormParams createFormParams(String inn, Decimal sparkId, Id opportunityId) {
        E2EFormParams formParams =  new E2EFormParams();
        formParams.companyInn = inn;
        formParams.opportunityId = opportunityId;
        formParams.sparkId = sparkId;
        formParams.businessProcess = GlobalUtils.BusinessProcessType.Standard.name();
        return formParams;
    }

    public static Credit_Factory_Report__c createFRAUDReport(Boolean criteria) {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c();
        report.RU_scoring_type__c = CFUtils.FRAUD_SCORING_TYPE;
        report.RecordTypeId = CFUtils.RUSSIAN_FRAUD_RECORD_TYPE;
        report.Scoring_notification_sent__c = criteria;
        report.Source_of_lead_matched__c = criteria;
        report.New_legal__c = criteria;
        report.First_bill__c = criteria;
        report.Different_post_address__c = criteria;
        return report;
    }

    public static OpportunityScoring createDefaultOpportunityScoring(Boolean criteria) {
        OpportunityScoring scoring = new OpportunityScoring();
        scoring.notificationSent = criteria;
        scoring.sourceOfLead = criteria;
        scoring.newLegal = criteria;
        scoring.newFounder = criteria;
        scoring.firstBill = criteria;
        scoring.differentPostAddress = criteria;
        scoring.massRegistrationAddress = criteria;
        return scoring;
    }

    public static Credit_Factory_Report__c createCreditFactoryReport(Account account, Opportunity opportunity) {
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
                Name = CFUtils.PRESCORING_RU,
                Credit_System_Number__c = '554676',
                Credit_Limit__c = '20000',
                RU_Scoring_date__c = Date.today(),
                RU_scoring_type__c = CFUtils.PRESCORING,
                RU_Scoring_expiration_date__c = Date.today().addMonths(3),
                RU_Scoring_description__c = 'descr',
                RU_scoring_decision_state__c = 'state',
                RU_Client_choice__c = false,
                RU_denial_reason__c = 'reason',
                RU_scoring_decision_code__c = '0',
                RU_scoring_decision__c = CFUtils.ScoringDecision.Credit_approved.name(),
                RU_credit_type__c = 'Free',
                RU_credit_term__c = '7',
                RU_payment_term__c = '1',
                RecordTypeId = CFUtils.RUSSIAN_CREDIT_RECORD_TYPE,
                Opportunity__c = opportunity.Id,
                Account__c = account.Id
        );
        return report;
    }

}