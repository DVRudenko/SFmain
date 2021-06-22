public interface ETEStepInterface {
    Map<String, Map<String, Map<String, Object>>> returnFieldsSettingsForCurrentStep(List<String> stepResourceJsonList,
                            ETEUserModel userModelFromRequest);
    void setExistingDataObject(E2E_Data_Object__c existingDataObject);
    void setExistingContacts(List<E2E_Data_Contact__c> existingContacts);
    void setExistingETEProducts(Map<String, E2E_Data_Product__c> existingETEProductsMap);
    void setExistingETEOfferItems(Map<String, E2E_Data_Offer_Item__c> existingETEOfferItemsMap);
    void setExistingETELocatorItems(Map<String, E2E_Data_Locator_Item__c> existingETELocatorItemsMap);
    void setExistingAdditionalServices(List<E2E_Data_Additional_Service__c> existingAdditionalServicesList);
    void setExistingDataLogs(Map<String, Map<String, E2E_Data_Log__c>> existingDataLogsMap);
    E2E_Data_Object__c returnInE2EProcessAfterReceivingReport(ETEDatabaseInterface e2eDatabase,
                            E2E_Data_Object__c e2EDataObject,
                            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap,
                            List<String> availableStepsForCustomerList);
    Map<String, Map<String, Object>> returnStepDependencies(Map<String, Object> defaultSettingsMap);
    Map<String, Map<String, List<String>>> returnObjectsMappingToSyncSettings(Map<String, Object> defaultSettingsMap);
    Map<String, Map<String, E2E_Data_Log__c>> generateExistingLogsMap(ETEDatabaseInterface e2eDatabase, String objectSource);
    List<String> getAvailableSteps(Map<String, Object> defaultSettingsMap, Map<String, Object> filtersOfAvailableStepsMap);
    List<ETEUserModel.NavigationMenuStep> getNavigationMenuSteps(Map<String, Object> defaultSettingsMap, List<String> availableStepsList);
    List<String> getAvailableStepsForCustomer(Object userDataObject,
                            List<String> availableStepsList,
                            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap,
                            Map<String, Map<String, Object>> stepsDependenciesMap);
    Map<String, Set<String>> setChangedFieldsForCurrentStep(ETEDatabaseInterface e2eDatabase,
                            ETEUserModel userModelFromRequest,
                            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap);
    Map<String, Map<String, Map<String, Set<String>>>> returnJobsRunSettings(String stepName,
                            Map<String, Map<String, Object>> stepsDependenciesMap);
    List<String> setJobsToRunForCurrentStep(ETEDatabaseInterface e2eDatabase,
                            Map<String, Set<String>> changedFieldsForCurrentStep,
                            Map<String, Map<String, Map<String, Set<String>>>> jobsRunSettings);
    List<String> getAllJobsToRunForCurrentStep(Map<String, Map<String, Map<String, Set<String>>>> jobsRunSettings);
    Map<String, Map<String, Map<String, Set<String>>>> returnFieldsCleaningSettings(String stepName,
                            Map<String, Map<String, Object>> stepsDependenciesMap);
    String getNextAvailableStep(Object userDataObject,
                            List<String> availableStepsList,
                            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap,
                            Map<String, Map<String, Object>> stepsDependenciesMap,
                            List<String> jobsToRunForCurrentStepList,
                            Boolean isReturnFromExternalSystem);
    void save(ETEDatabaseInterface e2eDatabase,
                            ETEUserModel userModelFromRequest,
                            String nextAvailableStep,
                            Map<String, String> pageParamsMap,
                            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap,
                            Map<String, Set<String>> changedFieldsForCurrentStep,
                            Map<String, Map<String, Map<String, Set<String>>>> fieldsCleaningSettings,
                            Map<String, Map<String, Object>> stepDependenciesMap);
    void setDealStatusesForNextStep(ETEDatabaseInterface e2eDatabase,
                            String nextAvailableStep,
                            List<String> availableStepsForCustomerList,
                            List<String> availableStepsList,
                            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap);
    void setPayLaterDealStatus(ETEDatabaseInterface e2eDatabase);
    void runJobs(ETEDatabaseInterface e2eDatabase, List<String> jobNamesNeededToRun);
    ETEUserModel convertToUserModel(List<String> availableStepsForCustomerList,
                            List<ETEUserModel.NavigationMenuStep> navigationMenuSteps);
    Map<String, Object> prepareFinalSettingsToFrontend(Map<String, Object> untypedSettings);
    Map<String, Object> prepareFinalUserModelToFrontend(ETEUserModel userModelObject);
    String returnTransitionStatus();
    Map<String, Object> doCalculateConsumption(E2E_Data_Object__c dataObject,
                            Map<String, E2E_Data_Product__c> eteProductsMap,
                            List<E2E_Data_Offer_Item__c> offerItemsList);
    Decimal returnAvailableMinDeposit(List<CreditFactoryResult> availableCreditFactoryResults);
    Map<String, Set<String>> returnCFPaymentDetails(String country, Map<String, Object> creditFactorySettings);
    Map<String, List<String>> returnCFReportValidations(String country, Map<String, Object> creditFactorySettings);
    CreditFactoryResult getCreditFactoryDecisions(ETEDatabaseInterface e2eDatabase,
                            CreditFactory creditFactory,
                            String dataObjectId,
                            String opportunityId,
                            String country,
                            List<CreditFactoryCompany> companiesList);
    String translateTextToEnglish(String country, String feedbackLocal);
    void saveCustomerFeedback(ETEDatabaseInterface e2eDatabase, E2E_Data_Object__c e2eDataObject, Map<String, Object> customerFeedbackParams);
    void saveFile(Map<String, Object> requestParams);
    E2E_Data_Object__c generateVerificationCode(ETEDatabaseInterface e2eDatabase, E2E_Data_Object__c e2eDataObject);
    String sendVerificationCode(String whatId, String targetObjectId, String replyTo, List<String> recipientEmails, String templateId);
    String validateVerificationCode(ETEDatabaseInterface e2eDatabase, E2E_Data_Object__c e2eDataObject, String inputVerificationCode);
}