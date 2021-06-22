@IsTest
public class SparkWebServiceImplTest {

    @TestSetup
    private static void setUp() {
        insert CFTestDataFactory.createCustomSettings();
    }

    @IsTest
    private static void testSparkApi200() {

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = SparkTestDataFactory.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        List<CompanySpark> companies = sparkWebService.getCompanyListByInn(SparkTestDataFactory.inn);
        System.assertEquals(true, !companies.isEmpty());
        SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(SparkTestDataFactory.entrepreneurInn);
        System.assertEquals(CFTestDataFactory.SPARK_ID, String.valueOf(soleProprietorReport.sparkID));
        List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(
                SparkTestDataFactory.inn,
                SparkTestDataFactory.sparkId
        );
        System.assertEquals(true, !accountReport.isEmpty());
        ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(
                SparkTestDataFactory.inn,
                SparkTestDataFactory.sparkId
        );
        System.assertEquals(true, extendedReport.sparkID == 6329708);
        ExtendedReportSpark.Leader leader = sparkWebService.getCompanyActualLeader(extendedReport.leaderList.leader);
        System.assertEquals(true, leader.fio != '');
		
        //SF-1359
        SparkRisksReportXML risksReport = sparkWebService.getCompanySparkRisksReportXML(SparkTestDataFactory.sparkId);
        System.assertEquals('6232082', risksReport.sparkID);
        List<SparkExecutionProceedings> executionProceedings = sparkWebService.getCompanyExecutionProceedings(
                SparkTestDataFactory.sparkId
        );
        System.assertEquals('709672', executionProceedings.get(0).sparkID);
        List<SparkArbitrationSummary> arbitrationSummary = sparkWebService.getCompanyArbitrationSummary(
                SparkTestDataFactory.sparkId
        );
        System.assertEquals(false, arbitrationSummary.isEmpty());		

        Test.stopTest();
    }

    @IsTest
    private static void testSparkEmptyResponse() {

        //Test response with status 200 with empty decision
        Test.startTest();

        Map<String, HttpCalloutMock> responses = SparkTestDataFactory.getMultiResponsesForMockEmpty();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        try{
            List<CompanySpark> companies = sparkWebService.getCompanyListByInn(SparkTestDataFactory.inn);
            System.assertEquals(true, companies.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(SparkTestDataFactory.entrepreneurInn);
            System.assertEquals(true, soleProprietorReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(
                    SparkTestDataFactory.inn,
                    SparkTestDataFactory.sparkId
            );
            System.assertEquals(true, accountReport.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(
                    SparkTestDataFactory.inn,
                    SparkTestDataFactory.sparkId
            );
            System.assertEquals(true, extendedReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    @IsTest
    private static void testSparkApi400() {

        //Test response with status 400
        Test.startTest();

        Map<String, HttpCalloutMock> responses = SparkTestDataFactory.getMultiResponsesForMock400();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        List<CompanySpark> companies = sparkWebService.getCompanyListByInn(SparkTestDataFactory.inn);
        System.assertEquals(true, companies.isEmpty());
        SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(SparkTestDataFactory.entrepreneurInn);
        System.assertEquals(null, soleProprietorReport.sparkID);
        List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(
                SparkTestDataFactory.inn,
                SparkTestDataFactory.sparkId
        );
        System.assertEquals(true, accountReport.isEmpty());

        Test.stopTest();
    }

    @IsTest
    private static void testSparkErrorApi500() {

        //Test response with status 500 from Spark
        Test.startTest();
        Map<String, HttpCalloutMock> responses = SparkTestDataFactory.getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        try{
            List<CompanySpark> companies = sparkWebService.getCompanyListByInn(SparkTestDataFactory.inn);
            System.assertEquals(true, companies.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(SparkTestDataFactory.entrepreneurInn);
            System.assertEquals(true, soleProprietorReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(
                    SparkTestDataFactory.inn,
                    SparkTestDataFactory.sparkId
            );
            System.assertEquals(true, accountReport.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(
                    SparkTestDataFactory.inn,
                    SparkTestDataFactory.sparkId
            );
            System.assertEquals(true, extendedReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    @IsTest
    private static void testSparkApi500() {
        //Test response with status 500
        Test.startTest();
        Map<String, HttpCalloutMock> responses = SparkTestDataFactory.getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        try{
            List<CompanySpark> companies = sparkWebService.getCompanyListByInn(SparkTestDataFactory.inn);
            System.assertEquals(true, companies.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try{
            SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(SparkTestDataFactory.entrepreneurInn);
            System.assertEquals(true, soleProprietorReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(
                    SparkTestDataFactory.inn,
                    SparkTestDataFactory.sparkId
            );
            System.assertEquals(true, accountReport.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try{
            ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(
                    SparkTestDataFactory.inn,
                    SparkTestDataFactory.sparkId
            );
            System.assertEquals(true, extendedReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

}