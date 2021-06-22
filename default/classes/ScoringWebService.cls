public interface ScoringWebService {

    DecisionScoring getScoringDecision(String inn, String sparkId, Id opportunityId);

    CompanyVerificationScoring verifyCompany(String inn, String sparkId, Id opportunityId);

    String prepareBlackListDecisionForSF(Integer verificationDecision);

    String prepareScoringDecisionForSF(Integer scoringDecision);
	
	DecisionPrescoring getPrescoringDecision(RequestPrescoring requestPrescoring);
}