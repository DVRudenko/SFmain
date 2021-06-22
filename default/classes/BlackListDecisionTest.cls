@IsTest
public with sharing class BlackListDecisionTest {

    @TestSetup
    private static void setUp() {
        insert CFTestDataFactory.createCustomSettings();
    }

    @IsTest
    public static void buildDecisionTest() {
        BlackListDecision decision = new BlackListDecision();
        decision.buildDecision(null);
        System.assertEquals(null, decision.decision);
        System.assertEquals(null, decision.decisionCode);

        CompanyVerificationScoring verificationScoring = new CompanyVerificationScoring();
        decision.buildDecision(verificationScoring);
        System.assertEquals(null, decision.decision);
        System.assertEquals(null, decision.decisionCode);

        verificationScoring.decision = 0;
        decision.buildDecision(verificationScoring);
        System.assertEquals(ScoringWebServiceImpl.blackListDecisionMapping.get(verificationScoring.decision), decision.decision);
        System.assertEquals('0', decision.decisionCode);
    }

}