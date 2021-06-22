public with sharing class BlackListDecision {

    public String decisionCode;
    public String decision;

    /*****************************************************************************
    *  Name            : buildDecision(CompanyVerificationScoring companyVerificationScoring)
    *  Summary         : builds BlackListDecision based on response from black list service
    *  CreatedDate     : 17.03.2021
    *  Parameters      : CompanyVerificationScoring companyVerificationScoring - response from black list service
    *  Returns         : -
    ******************************************************************************/
    public void buildDecision(CompanyVerificationScoring companyVerificationScoring) {
        if (companyVerificationScoring != null) {
            this.decisionCode = String.valueOf(companyVerificationScoring.decision);
            this.decision = ScoringWebServiceImpl.blackListDecisionMapping.get(companyVerificationScoring.decision);
        }
    }

}