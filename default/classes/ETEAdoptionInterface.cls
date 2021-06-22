public interface ETEAdoptionInterface {
    Database.LeadConvertResult convertLeadToE2E(E2E_Data_Object__c e2eDataObject, Account account, Opportunity opportunity, Contact contact);
    Lead updateLead(Lead lead);
    Account insertAccount(E2E_Data_Object__c e2eDataObject, Lead lead);
    Opportunity insertOpportunity(E2E_Data_Object__c e2eDataObject, Lead lead, Account account);
    Contact insertContact(E2E_Data_Object__c e2eDataObject, Account account, E2E_Data_Contact__c e2EDataContact);
    void insertOpportunityContactRole(Opportunity opportunity, Contact contact);
    List<Emarsys_Log__c> setFieldsToUpdateEmarsysLogs(List<Emarsys_Log__c> emarsysLogs, Opportunity opportunity);
}