@isTest
public class DecisionScoringTest {

    @isTest
    static void test() {
        DecisionScoring decision = new DecisionScoring();
        decision.decision = 3;
        decision.points = '0';
        decision.sfRequestId = '0066E0000058ZwnQAE';

        System.assert(decision != null);
        System.assert(decision.decision != null);
        System.assert(decision.points != null);
        System.assert(decision.sfRequestId != null);
    }
}