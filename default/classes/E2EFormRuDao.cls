public interface E2EFormRuDao {
    //******* Content Dao *****//
    Map<Id, LongForm_Page__c> getLongFormPages(String country, Set<String> elementsOfStep, String deviceType);
    Map<Id, LongForm_Page__c> getSharedResources(String country, Set<String> elementsOfStep, String deviceType);
    List<LongForm_Element__c> getElementsListByPages(Set<Id> pagesIds);
    Map<Id, LongForm_Fleetcor_Product__c> getProductsByOffer(Set<Id> offerIds);
    Map<Id, LongForm_Tariff__c> getTariffsByProduct(Set<Id> productIds);
    Map<Id, LongForm_Property__c> getPropertiesByTariff(Set<Id> tariffIds);
    Map<Id, LongForm_Offer__c> getOffersByIds(Set<Id> offerIds);

    //****** Account Dao *****//
    Id createAccount(Account account);
    Id updateAccount(Account account);
    Account getAccountById(Id accountId);
    List<Account> getAccountsByINN(String INN);
    Map<Id, Account> getAccountsByIds(Set<Id> accountIds);
    void mergerAccount(Account master, List<Account> duplicates);

    //****** Contact Dao *****//
    Id createContact(Contact contact);
    Id updateContact(Contact contact);
    Contact getContactById(Id contactId);
    Contact getContactByContactId(Id contactId);
    void deleteAccount(Account account);
    List<Contact> createContacts(List<Contact> contacts);
    List<Contact> getContactsByEmail(String email);
    List<Contact> getContactsByDomain(String domain);
    List<Contact> getContactsByNamePhoneEmail(String name, String phone, String email, String defaultEmail);
    List<Contact> getContactsByLastName(String lastName, Id accountId);
    List<Contact> getContactsByAccountAndTitle(Id accountId, String title);
    List<Contact> getContactsByAccount(Id accountId);

    //****** Opportunity Dao *****//
    Id createOpportunity(Opportunity opportunity);
    Id updateOpportunity(Opportunity opportunity);
    void updateOpportunities(List<Opportunity> opportunities);
    Opportunity getOpportunityById(Id opportunityId);
    List<OpportunityHistory> getLastModifiedStageByOpportunityId(Id opportunityId);
    List<Opportunity> getOpportunitiesByIds(Set<Id> opportunitiesIds);
    //SF-1313
    List<Opportunity> getOpportunitiesByAccount(Id accountId);
    //****** OpportunityContactRole Dao *****//
    void createOpportunityContactRole(List<OpportunityContactRole> opportunityContactRoles);
    OpportunityContactRole getOpportunityContactRole(Id contactId, Id opportunityId);
    List<OpportunityContactRole> getOpportunityContactRoles(Id opportunityId);
    void updateOpportunityContactRole(List<OpportunityContactRole> opportunityContactRoles);
    List<OpportunityContactRole> getOpportunityContactRoles(Id contactId, Id opportunityId);

    //****** Document Dao *****//
    Id createDocument(Document document);
    Document getDocumentById(Id documentId);
    Folder getFolderByName(String folderName);

    //******* Form Service *****//
    Id createFormDataRecord(E2EFormData__c formData);
    Id updateFormData(E2EFormData__c formDataRecord);
    E2EFormData__c getFormDataById(Id formDataRecordId);
    List<E2EFormData__c> getFormDataByAccountIdAndContactId(Id accountId, Id contactId);

    //******* Lead Dao *****//
    List<Lead> getDuplicatedLeads(String email, String phone);
    void updateLeads(List<Lead> leadsList);

    //******* User Dao *****//
    User getUserByName(String name);
    Map<Id, User> getUsersByNames(Set<String> names);
    Map<Id, User> getUsersMapByIds(Set<Id> userIds);
    List<User> getUsersByUserRoleId(Set<Id> userRoleIds);
    UserRole getUserRoleById(String roleId);

    //******* Email Template Dao *****//
    EmailTemplate getEmailTemplateByDevName(String devName);

    User isRoleAnInbound(Id id);
    Opportunity getOpportunityStep(Id id);

    //******* Update sObject *****// sf-1131
    void updSObjects(String objectName, List<SObject> sObjectList);

}
