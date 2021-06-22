public interface CFService {

    // **** E2EFormParams service **** //
    Boolean getSoleProprietorSparkData(E2EFormParams formParams);

    Boolean getCompanySparkShortData(E2EFormParams formParams);

    Boolean getCompanySparkExtendedData(E2EFormParams formParams);

    Boolean getBlackListDecisionData(E2EFormParams formParams, Boolean checkScoringExpired);

    Boolean getScoringDecisionData(E2EFormParams formParams);

    Boolean checkBBLApprovalProcess(E2EFormParams formParams); // BBL – ЧЧС

    // **** Account service **** //
    Account blockCompany(Account account);

    Account getAccountById(Id accountId);

    // **** Credit factory report service **** //
    Credit_Factory_Report__c createCFRuPrescoringData(E2EFormParams formParams, Boolean updatePrescoring);

    Credit_Factory_Report__c updateCFRuPrescoringData(Credit_Factory_Report__c report, E2EFormParams formParams);

    Credit_Factory_Report__c createFRAUDScoringData(OpportunityScoring scoring);

    Credit_Factory_Report__c updateFRAUDScoringData(Credit_Factory_Report__c report, OpportunityScoring scoring);

    Credit_Factory_Report__c getCFRById(Id id);

    Credit_Factory_Report__c getCFR(Id opportunityId, String scoringType, Id recordTypeId);

    List<Credit_Factory_Report__c> getActualCFRs(Id opportunityId);

    Credit_Factory_Report__c getChosenCFR(Id opportunityId);

    void saveChekedCFR(Id opportunityId, E2EFormParams formParams);

    // **** Opportunity service **** //
    Opportunity getOpportunity(Id id);

    Opportunity updateOpportunity(Opportunity opportunity);

    E2EFormData__c getByOpportunityId(Id opportunityId);

    // **** Scoring preparation **** //
    TransitRequestData.ContMonitoring prepareScoringDataForTransit(OpportunityScoring scoring);

    TransitRequestData.ContMonitoring prepareScoringDataForTransit(Credit_Factory_Report__c report);

    OpportunityScoring processOpportunityScoring(E2EFormParams params);
}
