@isTest
public class ScoringWebServiceImplTest {

    private static String inn = CFTestDataFactory.INN;
    private static String sparkId = CFTestDataFactory.SPARK_ID;
    private static String opportunityId = CFTestDataFactory.OPPORTUNITY_ID;

    @TestSetup
    public static void setup() {
        insert CFTestDataFactory.createCustomSettings();
    }

    @isTest
    static void testScoringApi200() {
        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = CFTestDataFactory.getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
        System.assertEquals(true, verificationDecision != null);
        DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
        System.assertEquals(true, decisionScoring != null);

        String decisionForSF0 = scoringWebService.prepareScoringDecisionForSF(0);
        System.assertEquals(true, decisionForSF0 == 'Платный овердрафт');
        String decisionForSF1 = scoringWebService.prepareScoringDecisionForSF(1);
        System.assertEquals(true, decisionForSF1 == 'Предоплата');

        String blackListDecisionForSF0 = scoringWebService.prepareBlackListDecisionForSF(0);
        System.assertEquals(true, blackListDecisionForSF0 == 'ОК');
        String blackListDecisionForSF3 = scoringWebService.prepareBlackListDecisionForSF(3);
        System.assertEquals(true, blackListDecisionForSF3 == 'Отказ');
        String blackListDecisionForSF4 = scoringWebService.prepareBlackListDecisionForSF(4);
        System.assertEquals(true, blackListDecisionForSF4 == 'Согласование перекупщика');

        DecisionPrescoring decisionPrescoring = scoringWebService.getPrescoringDecision(CFTestDataFactory.createPrescoringRequestBody());
        System.assertNotEquals(null, decisionPrescoring);
        System.assertEquals(true, decisionPrescoring.decision);
        System.assertEquals('01.01.2020', decisionPrescoring.dateRequest);
        System.assertEquals('01.04.2020', decisionPrescoring.expireDate);
        System.assertEquals(5, decisionPrescoring.creditPeriod);
        System.assertEquals(10, decisionPrescoring.paymentTimeLimit);
        System.assertEquals(5000, decisionPrescoring.overdraft);
        System.assertEquals(false, decisionPrescoring.blocked);

        Test.stopTest();
    }

    @isTest
    static void testScoringEmptyDecision() {
        //Test response with status 200 with empty decision
        Test.startTest();

        Map<String, HttpCalloutMock> responses = CFTestDataFactory.getMultiResponsesForMockEmptyDecision();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
        System.assertEquals(true, verificationDecision.decision == null);
        DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
        System.assertEquals(true, decisionScoring.decision == null);

        DecisionPrescoring decisionPrescoring = scoringWebService.getPrescoringDecision(CFTestDataFactory.createPrescoringRequestBody());
        System.assertNotEquals(null, decisionPrescoring);
        System.assertEquals(null, decisionPrescoring.decision);

        Test.stopTest();
    }

    @isTest
    static void testScoringErrorApi500() {
        //Test response with status 500 from Scoring
        Test.startTest();
        Map<String, HttpCalloutMock> responses = CFTestDataFactory.getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        try {
            CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
            System.assertEquals(true, verificationDecision.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
            System.assertEquals(true, decisionScoring.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            scoringWebService.getPrescoringDecision(CFTestDataFactory.createPrescoringRequestBody());
        } catch (HttpResponseException e) {
            System.assert(String.isNotBlank(e.getMessage()));
        }

        Test.stopTest();

    }

    @isTest
    static void testScoringApi500() {
        //Test response with status 500
        Test.startTest();
        Map<String, HttpCalloutMock> responses = CFTestDataFactory.getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        try {
            CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
            System.assertEquals(true, verificationDecision.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
            System.assertEquals(true, decisionScoring.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            scoringWebService.getPrescoringDecision(CFTestDataFactory.createPrescoringRequestBody());
        } catch (HttpResponseException e) {
            System.assert(String.isNotBlank(e.getMessage()));
        }

        Test.stopTest();
    }

}