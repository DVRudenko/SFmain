public interface ETEBusinessObjectsInterface {
    E2E_Data_Object__c initDataObject(List<String> availableStepsList, String countryCode, String implKey);
    Opportunity initOpportunity(E2E_Data_Object__c dataObject, String priceBookId);
    CreditFactoryCompany getCFReport(CreditFactory creditFactory, String opptyId);
    Account initAccount(String country, E2E_Data_Object__c dataObject);
    Contact initContact();
    OpportunityContactRole initOpportunityContactRole();
}