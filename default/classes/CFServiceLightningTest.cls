@IsTest
public with sharing class CFServiceLightningTest {

    @TestSetup
    private static void setUp() {
        insert CFTestDataFactory.createCustomSettings();
    }

    @IsTest
    public static void getSoleProprietorSparkDataTestInvalidINN() {
        Boolean exceptionCaught = false;
        String inn = null;
        try {
            CFServiceLightning.getSoleProprietorSparkData(inn);
        } catch (ValidationException e) {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught);
    }

    @IsTest
    public static void getSoleProprietorSparkDataTestNoData() {
        String inn = SparkTestDataFactory.entrepreneurInn;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.entrepreneurReportURI => SparkTestDataFactory.noDataMock
        }));
        System.assertEquals(null, CFServiceLightning.getSoleProprietorSparkData(inn));
        Test.stopTest();
    }

    @IsTest
    public static void getSoleProprietorSparkDataTestOK() {
        String inn = SparkTestDataFactory.entrepreneurInn;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.entrepreneurReportURI => SparkTestDataFactory.entrepreneurReportMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getSoleProprietorSparkData(inn)));
        Test.stopTest();
    }

    @IsTest
    public static void getCompanySparkDataTestInvalidINN() {
        Boolean exceptionCaught = false;
        String inn = null;
        try {
            CFServiceLightning.getCompanySparkData(inn);
        } catch (ValidationException e) {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught);
    }

    @IsTest
    public static void getCompanySparkDataTestNoCompanyData() {
        String inn = SparkTestDataFactory.inn;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.noDataMock
        }));
        System.assertEquals(null, CFServiceLightning.getCompanySparkData(inn));
        Test.stopTest();
    }

    @IsTest
    public static void getCompanySparkDataTestNoExtendedData() {
        String inn = SparkTestDataFactory.inn;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.companyListMock,
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.noDataMock
        }));
        System.assertEquals(null, CFServiceLightning.getCompanySparkData(inn));
        Test.stopTest();
    }

    @IsTest
    public static void getCompanySparkDataTestOK() {
        String inn = SparkTestDataFactory.inn;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.companyListURI => SparkTestDataFactory.companyListMock,
                SparkTestDataFactory.extendedReportURI => SparkTestDataFactory.extendedReportMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getCompanySparkData(inn)));
        Test.stopTest();
    }

    @IsTest
    public static void getBlackListDataTestInvalidINN() {
        Boolean exceptionCaught = false;
        String inn = null;
        try {
            CFServiceLightning.getBlackListData(inn, CFTestDataFactory.SPARK_ID, CFTestDataFactory.OPPORTUNITY_ID);
        } catch (ValidationException e) {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught);
    }

    @IsTest
    public static void getBlackListDataTestInvalidSparkID() {
        String sparkID = null;
        System.assertEquals(null, CFServiceLightning.getBlackListData(CFTestDataFactory.INN, sparkID, CFTestDataFactory.OPPORTUNITY_ID));

        sparkID = '';
        System.assertEquals(null, CFServiceLightning.getBlackListData(CFTestDataFactory.INN, sparkID, CFTestDataFactory.OPPORTUNITY_ID));

        sparkID = '   ';
        System.assertEquals(null, CFServiceLightning.getBlackListData(CFTestDataFactory.INN, sparkID, CFTestDataFactory.OPPORTUNITY_ID));
    }

    @IsTest
    public static void getBlackListDataTestNoData() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                CFTestDataFactory.blackListURI => CFTestDataFactory.noDataMock
        }));
        System.assertEquals(null, CFServiceLightning.getBlackListData(CFTestDataFactory.INN, CFTestDataFactory.SPARK_ID, CFTestDataFactory.OPPORTUNITY_ID));
        Test.stopTest();
    }

    @IsTest
    public static void getBlackListDataTestOK() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                CFTestDataFactory.blackListURI => CFTestDataFactory.blackListMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getBlackListData(CFTestDataFactory.INN, CFTestDataFactory.SPARK_ID, CFTestDataFactory.OPPORTUNITY_ID)));
        Test.stopTest();
    }

    @IsTest
    public static void getPreScoringDataTestInvalidArgument() {
        //null JSON
        System.assertEquals(null, CFServiceLightning.getPreScoringData(null, 200));

        //invalid turnover
        Boolean exceptionCaught = false;
        try {
            CFServiceLightning.getPreScoringData('{}', null);
        } catch (ValidationException e) {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught);
    }

    @IsTest
    public static void getPreScoringDataTestNoData() {
        SparkDataForPrescoring data = new SparkDataForPrescoring();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.noDataMock
        }));
        System.assertEquals(null, CFServiceLightning.getPreScoringData(generateFullSparkJSON(), 200));
        Test.stopTest();
    }

    @IsTest
    public static void getPreScoringDataTestOK() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                CFTestDataFactory.prescoringDecisionURI => CFTestDataFactory.prescoringDecisionMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getPreScoringData(generateFullSparkJSON(), 200)));
        Test.stopTest();
    }

    @IsTest
    public static void getSparkArbitrationSummaryListInvalidArgument() {
        System.assertEquals(null, CFServiceLightning.getSparkArbitrationSummaryList(null));
    }

    @IsTest
    public static void getSparkExecutionProceedingsInvalidArgument() {
        System.assertEquals(null, CFServiceLightning.getSparkExecutionProceedings(null));
    }

    @IsTest
    public static void getSparkFinancialReportsInvalidArgument() {
        System.assertEquals(null, CFServiceLightning.getSparkFinancialReports(null, '1234567890'));
        System.assertEquals(null, CFServiceLightning.getSparkFinancialReports('3123434', null));
    }

    @IsTest
    public static void getSparkRiskReportInvalidArgument() {
        System.assertEquals(null, CFServiceLightning.getSparkRiskReport(null));
    }

    @IsTest
    public static void getSparkArbitrationSummaryListOK() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.arbitrationSummaryURI => SparkTestDataFactory.arbitrationSummaryMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getSparkArbitrationSummaryList(SparkTestDataFactory.sparkId)));
        Test.stopTest();
    }

    @IsTest
    public static void getSparkExecutionProceedingsOK() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.executionProceedingsURI => SparkTestDataFactory.executionProceedingsMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getSparkExecutionProceedings(SparkTestDataFactory.sparkId)));
        Test.stopTest();
    }

    @IsTest
    public static void getSparkFinancialReportsOK() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.accountingReportURI => SparkTestDataFactory.accountingReportMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getSparkFinancialReports(SparkTestDataFactory.sparkId, SparkTestDataFactory.inn)));
        Test.stopTest();
    }

    @IsTest
    public static void getSparkRiskReportOK() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(new Map<String, SingleRequestMock> {
                SparkTestDataFactory.riskReportURI => SparkTestDataFactory.riskReportMock
        }));
        System.assert(String.isNotBlank(CFServiceLightning.getSparkRiskReport(SparkTestDataFactory.sparkId)));
        Test.stopTest();
    }

    private static Object getContentFromMock(SingleRequestMock jsonMock) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonMock.bodyAsString);
        return data.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY);
    }

    private static Object getObjectFromMock(SingleRequestMock jsonMock, System.Type clazz) {
        return JSON.deserialize(JSON.serialize(getContentFromMock(jsonMock)), clazz);
    }

    private static String generateFullSparkJSON() {
        SparkDataForPrescoring data = new SparkDataForPrescoring();
        data.companyData = (ExtendedReportSpark) getObjectFromMock(SparkTestDataFactory.extendedReportMock, ExtendedReportSpark.class);
        data.riskReport = (SparkRisksReportXML) getObjectFromMock(SparkTestDataFactory.riskReportMock, SparkRisksReportXML.class);

        data.arbitrationSummaryList = new List<SparkArbitrationSummary>();
        List<Object> objects = (List<Object>) getContentFromMock(SparkTestDataFactory.arbitrationSummaryMock);
        for (Object o : objects) {
            data.arbitrationSummaryList.add((SparkArbitrationSummary) JSON.deserialize(JSON.serialize(o), SparkArbitrationSummary.class));
        }

        data.executionProceedings = new List<SparkExecutionProceedings>();
        objects = (List<Object>) getContentFromMock(SparkTestDataFactory.executionProceedingsMock);
        for (Object o : objects) {
            data.executionProceedings.add((SparkExecutionProceedings) JSON.deserialize(JSON.serialize(o), SparkExecutionProceedings.class));
        }

        data.financialReports = new List<FinancialReportSpark>();
        objects = (List<Object>) getContentFromMock(SparkTestDataFactory.accountingReportMock);
        for (Object o : objects) {
            data.financialReports.add((FinancialReportSpark) JSON.deserialize(JSON.serialize(o), FinancialReportSpark.class));
        }

        return JSON.serialize(data);
    }

    @IsTest
    private static void getPickListCreditFactoryReportTest() {
        Map<String, String> pickListData = CFServiceLightning.getPickListCreditFactoryReport();
        System.assertNotEquals(0, pickListData.size());
        System.assertEquals(true, pickListData.containsKey(CFUtils.ScoringDecision.Credit_approved.name()));
    }
}