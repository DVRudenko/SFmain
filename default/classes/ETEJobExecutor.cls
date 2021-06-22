public interface ETEJobExecutor {
    void checkBusinessObjects(ETEDatabaseInterface e2eDatabase, E2E_Data_Log__c existingJobInDataBase);
    void doReportRequest(ETEDatabaseInterface e2eDatabase, E2E_Data_Log__c existingJobInDataBase);
    void doDeduplication(ETEDatabaseInterface e2eDatabase, E2E_Data_Log__c existingJobInDataBase);
    void syncData(ETEDatabaseInterface e2eDatabase,
            Map<String, E2E_Data_Log__c>  existingJobsMap,
            E2E_Data_Log__c existingJobInDataBase,
            String actionName);
    void attachPdfDocument(ETEDatabaseInterface e2eDatabase, String fileName, String docType, String opptyId, E2E_Data_Object__c e2eDataObject);
    Quote mapQuoteFields(ETEDatabaseInterface e2eDatabase, Quote quote, Opportunity oppty);
    List<Client_Offer_Additional_Service__c> mapClientOfferAddServicesFieldsWithE2EDataAddServicesFields(
            Map<String, Client_Offer_Additional_Service__c> finalClientOfferAdditionalServices,
            Map<String, E2E_Data_Additional_Service__c> e2eDataAddi1tionalServicesMap);
    Account mapAccountFieldsWithCFReportFields(Account account,
            E2E_Data_Object__c e2eDataObject,
            CreditFactoryCompany creditFactoryCompany,
            Map<String, Object> additionalFieldsToUpdateFromCFReport);
    Opportunity mapOpportunityFieldsWithDataObjectFields(Opportunity opportunity, E2E_Data_Object__c e2eDataObject);
    Map<String, Offer_Item__c> mapOpptyOfferItemsFieldsWithDataOfferItemsFields(E2E_Data_Object__c dataObject,
            Opportunity opportunity,
            Map<String, E2E_Data_Product__c> eteProductsByParentIdMap,
            Map<String, Map<String, Offer_Item__c>> finalBusinessOfferItems,
            Map<String, List<E2E_Data_Offer_Item__c>> dataOfferItemsMap);
    void mapOpportunityFieldsWithLocatorItemsFields(Opportunity opportunity, Map<String, E2E_Data_Locator_Item__c> existingE2ELocatorItemsMap);
    Account mapAccountFieldsWithDataObjectFields(Account account, E2E_Data_Object__c e2eDataObject);
    Opportunity setExceptionParams(Opportunity opportunity,
            E2E_Data_Object__c e2eDataObject,
            List<E2E_Data_Log__c> existingJobsList);
    Opportunity mapOpportunityFieldsWithCFReportFields(Opportunity opportunity,
            CreditFactoryCompany creditFactoryCompany,
            Map<String, Object> additionalFieldsToUpdateFromCFReport);
    void mapSFcontactFieldsWithETEcontactFields(List<E2E_Data_Contact__c> existingETEdataContacts,
            Map<String, Contact> sfContactsToSync,
            Map<String, OpportunityContactRole> opptyContactRolesToSync);
    void mapSFcontactFieldsWithCFreportFields(Map<String, Contact> sfContactsToSync,
            CreditFactoryCompany creditFactoryCompany,
            Map<String, Object> additionalFieldsToUpdateFromCFReport);
    List<Customer_Feedback__c> mapCustomerFeedbackFields(ETEDatabaseInterface e2eDatabase, String opptyId, List<E2E_Data_Log__c> existingJobsList);
}
