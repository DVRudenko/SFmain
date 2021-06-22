@isTest
public class CompanyVerificationScoringTest {

    @isTest
    static void test() {
        CompanyVerificationScoring verifiedDecision = new CompanyVerificationScoring();
        verifiedDecision.decision = 3;
        verifiedDecision.limitation = 0;
        verifiedDecision.blackListType = new List<Integer>();
        verifiedDecision.blackListType.add(10);
        verifiedDecision.sfRequestId = '0066E0000058ZwnQAE';

        System.assert(verifiedDecision != null);
        System.assert(verifiedDecision.decision != null);
        System.assert(verifiedDecision.limitation != null);
        System.assert(verifiedDecision.blackListType != null);
        System.assert(verifiedDecision.sfRequestId != null);
    }
}