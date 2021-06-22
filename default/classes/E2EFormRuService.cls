public interface E2EFormRuService {

    //******* Content Service *****//
    void collectContent(String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType);
    void collectSharedResource(String country, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType, String source);
    void collectContentDataByLink(Id formDataId, String stepName, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, Map<String, LongFormTariff> msl_suffix, Map<String, String> objectIds);

    //****** Account Service *****//
    Id createAccount(E2EFormParams formParams);
    void updateAccount(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step);
    void updateAccount(Id accountId, E2EFormParams formParams);
    Account getAccountById(Id accountId);
    void deleteAccountById(Id accountId);

    //****** Contact Service *****//
    Id createContact(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, GlobalUtils.BusinessProcessType businessProcessType);
    Id createEmployeeContact(Id accountId, String employeeFio, String title, String businessProcessType);
    void updateContact(Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step);
    void updateContact(Contact contact, E2EFormParams formParams);
    void updateProfileEmailForContact(Id contactId, Id formDataId, String email);
    void updateEmployeeContact(Id contactId, String employeeFio, String title, String businessProcessType);
    Contact getContactById(Id contactId);
    void updateContactPhone(Id contactId, String phone);
    Map<String, OpportunityContactRole> markPrimaryAndAdditionalContactRole(List<OpportunityContactRole> contacts);

    //****** Opportunity Service *****//
    Id createOpportunity(Id accountId, E2EFormParams formParams);
    void updateOpportunityStage(Id opportunityId, String stageName);
    void updateOpportunity(Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step);
    void updateOpportunity(Id opportunityId, E2EFormParams formParams);
    Opportunity getOpportunityById(Id opportunity);
    void forceUpdateOpportunity(Id opportunityId, String error);
    void updateEncodedUrl(Id opportunityId, Id formDataId, E2EFormParams formParams);

    //****** OpportunityContactRole Service *****//
//    void createOpportunityContactRoles(Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step);
    void createOpportunityContactRole(Id opportunityId, Id accountId, String role, Boolean isPrimary);
    void updateOpportunityContactRole(Id opportunityId, Id contactId, String role, Boolean isPrimary);

    //****** Document Service *****//
    Id createDocument(String name, Blob content, String contentType, Id folderId);

    //****** Form Service *****//
    Id createFormDataRecord(Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams);
    Id createFormDataRecord(Id accountId, Id opportunityId, E2EFormParams formParams); // for E2E Business
    void updateFormData(Id formDataId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step, String source);
    void updateFormData(Id formDataId, E2EFormParams formParams);
    void updateFormData(E2EFormParams formParams);
    E2EFormData__c getFormDataById(Id formDataRecordId);
    void changeObjectOwner(Id objectId, String newUserName);
    sObject changeObjectOwner(Id objectId, String newUserName, Boolean dml); //sf-1131

    E2EFormParams getCurrentDataToShowOnForm(Account account, Opportunity opportunity, E2EFormData__c formData);
    List<SelectOption> getFieldPickListSelectOptions(Schema.DescribeFieldResult fieldResult);

    //******* Duplicate Process *****//
    void duplicateLeadProcess(Map<String, LongFormPage> pagesMap);
    Map<String, String> deduplicateE2EClient(String name, Map<String, LongFormPage> pagesMap);
    E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId, Id formDataId);
    E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, E2EFormRuDeduplicationResult deduplicationResult);
    E2EFormRuDeduplicationResult transferCustomer(E2EFormRuDeduplicationResult deduplicationResult);

    //******* Report Service Integration *****//
    ReportRequestData prepareReportRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap, Boolean preview, GlobalUtils.BusinessProcessType businessProcessType);
    ReportRequestData prepareReportRequestData(E2EFormParams formParams, Boolean preview, GlobalUtils.BusinessProcessType businessProcessType);

    //******* Transit Integration *****//
    TransitRequestData prepareTransitRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap, GlobalUtils.BusinessProcessType businessProcessType);
    TransitDocLinkRequestData prepareTransitDocLinkRequestData(ReportResponseData responseData, E2EFormParams formParams);

    //******** MZK Integration ********//
    MZKRequest prepareMzkRequest(Id formDataId, E2EFormParams formParams);

    //******** Crm Integration ********//
    CrmTask prepareCrmRequest(String phone, String email, String inn, List<Opportunity> opportunities);


    void collectDataFromSpark(Id formDataId, Id accountId, E2EFormParams formParams);

    //******* Remote Actions *****//
    void updateSoleProprietorInfoFromSpark(E2EFormParams formParams, String formDataId);
    void updateCompanyInformationFromSpark (E2EFormParams formParams, String formDataId, String opportunityId);
    void updateVerifiedDecision(E2EFormParams formParams, String formDataId, String opportunityId);
    void updateScoringDecision(E2EFormParams formParams, String formDataId, String opportunityId);

    boolean isRoleInbound(Id id);
    String getCurrentStep(Id id);
    //******* Update sObject *****//
    void updSObjects(String objectName, List<SObject> sObjectList);
}