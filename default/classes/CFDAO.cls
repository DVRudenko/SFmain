public interface CFDAO {

    List<SObject> updateSObjects(List<SObject> sObjects);

    // **** Account DAO **** //
    List<Account> updateAccounts(List<Account> accounts);

    Account getAccountById(Id accountId);

    // **** Credit factory report DAO **** //
    List<Credit_Factory_Report__c> insertCreditFactoryReports(List<Credit_Factory_Report__c> reports);

    List<Credit_Factory_Report__c> updateCreditFactoryReports(List<Credit_Factory_Report__c> reports);

    List<Credit_Factory_Report__c> getCFR(Set<Id> ids);

    List<Credit_Factory_Report__c> getCFR(Set<Id> opportunityIds, String scoringType, Id recordTypeId);

    List<Credit_Factory_Report__c> getActualCFRs(Id opportunityId, List<String> recordTypeIds);

    List<Credit_Factory_Report__c> getCfrForUpdate(Id opportunityId);

    // **** Opportunity DAO **** //
    List<Opportunity> getOpportunities (List<Id> opportunityIds, List<Id> recordTypeIds);

    List<Opportunity> getOpportunities(Set<Id> ids);

    List<Opportunity> getOpportunitiesByAccountIdAndStages(Id accountId, List<String> excludeStages);

    List<Opportunity> updateOpportunities(List<Opportunity> opportunities);

    List<E2EFormData__c> getByOpportunityId(Set<Id> ids);

}
