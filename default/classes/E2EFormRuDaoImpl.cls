public without sharing class E2EFormRuDaoImpl implements E2EFormRuDao {

    //****** Content Dao *****//
    /*******************************************************************************
    *  Name            : getLongFormPages(String country, Set<String> elementsOfStep, String deviceType)
    *  Summary         : return elements of step by name
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, Set<String> elementsOfStep, String deviceType
    *  Returns         : Map<Id, LongForm_Page__c>
    ******************************************************************************/
    public Map<Id, LongForm_Page__c> getLongFormPages(String country, Set<String> elementsOfStep, String deviceType) {
        return new Map<Id, LongForm_Page__c>([
                SELECT Name, Type__c, Long_Form__c
                FROM LongForm_Page__c
                WHERE Long_Form__r.Country__c = :country AND
                (Name IN:elementsOfStep OR
                Name = 'FOOTER' OR
                Name = 'SYSTEM ERROR') AND
                Device_View__c = :deviceType
                LIMIT 10000
        ]);
    }

    /*******************************************************************************
    *  Name            : getSharedResources(String country, Set<String> elementsOfStep, String deviceType)
    *  Summary         : return elements of step by name
    *  CreatedDate     : 19/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, Set<String> elementsOfStep, String deviceType
    *  Returns         : Map<Id, LongForm_Page__c>
    ******************************************************************************/
    public Map<Id, LongForm_Page__c> getSharedResources(String country, Set<String> elementsOfStep, String deviceType) {
        return new Map<Id, LongForm_Page__c>([
                SELECT Name, Type__c, Long_Form__c
                FROM LongForm_Page__c
                WHERE Long_Form__r.Country__c = :country AND
                Name IN:elementsOfStep AND
                Device_View__c = :deviceType
                LIMIT 10000
        ]);
    }

    /*******************************************************************************
    *  Name            : getElementsListByPages(Set<Id> pagesIds)
    *  Summary         : return LongForm elements by page ids
    *  CreatedDate     : 10/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<Id> pagesIds
    *  Returns         : List<LongForm_Element__c>
    ******************************************************************************/
    public List<LongForm_Element__c> getElementsListByPages(Set<Id> pagesIds) {
        return new List<LongForm_Element__c>([
                SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c, (SELECT Id, Name, Product__c FROM LongForm_Offers__r), (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
                FROM LongForm_Element__c
                WHERE Long_Form_Page__c IN :pagesIds
                LIMIT 10000
        ]);
    }

    /*******************************************************************************
    *  Name            : getOffersByIds(Set<Id> offerIds)
    *  Summary         : return map LongForm_Offer__c object by offer ids
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<Id> offerIds
    *  Returns         : Map<Id, LongForm_Offer__c>
    ******************************************************************************/
    public Map<Id, LongForm_Offer__c> getOffersByIds(Set<Id> offerIds) {
        return new Map<Id, LongForm_Offer__c>([
                SELECT Id, Name, (SELECT Id, Name, Label__c FROM Long_Form_Fleetcor_Products__r)
                FROM LongForm_Offer__c
                WHERE Id IN :offerIds
                LIMIT 2000
        ]);
    }

    /*******************************************************************************
    *  Name            : getProductsByOffer(Set<Id> offerIds)
    *  Summary         : return map LongForm_Fleetcor_Product__c object by offer ids
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : 22/10/2020
    *  Parameters      : Set<Id> offerIds
    *  Returns         : Map<Id, LongForm_Fleetcor_Product__c>
    ******************************************************************************/
    public Map<Id, LongForm_Fleetcor_Product__c> getProductsByOffer(Set<Id> offerIds) {
        return new Map<Id, LongForm_Fleetcor_Product__c>([
            SELECT Id, Name, (SELECT Id, Name, Label__c, Show_Tariff__c FROM LongForm_Tariffs__r WHERE Show_Tariff__c = TRUE)
            FROM LongForm_Fleetcor_Product__c
            WHERE Long_Form_Offer__c IN :offerIds
            LIMIT 2000
        ]);
    }

    /*******************************************************************************
    *  Name            : getTariffsByProduct(Set<Id> productIds)
    *  Summary         : return map LongForm_Tariff__c object by product ids
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : 22/10/2020
    *  Parameters      : Set<Id> productIds
    *  Returns         : Map<Id, LongForm_Tariff__c>
    ******************************************************************************/
    public Map<Id, LongForm_Tariff__c> getTariffsByProduct(Set<Id> productIds) {
        return new Map<Id, LongForm_Tariff__c>([
            SELECT Id, Name, (SELECT Id, Name FROM LongForm_Properties__r), Show_Tariff__c
            FROM LongForm_Tariff__c
            WHERE LongForm_Fleetcor_Product__c IN :productIds
            AND Show_Tariff__c = TRUE
            LIMIT 2000
        ]);
    }

    /*******************************************************************************
    *  Name            : getPropertiesByTariff(Set<Id> tariffIds)
    *  Summary         : return map LongForm_Property__c object by tariff ids
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<Id> tariffIds
    *  Returns         : Map<Id, LongForm_Property__c>
    ******************************************************************************/
    public Map<Id, LongForm_Property__c> getPropertiesByTariff(Set<Id> tariffIds) {
        return new Map<Id, LongForm_Property__c>([
                SELECT Id, Name, Value__c, Popup__c, (SELECT Name, Value__c FROM LongForm_Property_Items__r)
                FROM LongForm_Property__c
                WHERE LongForm_Tariff__c IN :tariffIds
                LIMIT 2000
        ]);
    }

    //****** Account Dao *****//
    /*******************************************************************************
   *  Name            : createAccount(Map<String, LongFormPage> pagesMap)
   *  Summary         : create account
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Map<String, LongFormPage> pagesMap
   *  Returns         : created account id
   ******************************************************************************/
    public Id createAccount(Account account) {
        String objName = Account.class.getName();
        List<Account> accounts = new List<Account>();
        accounts.add(account);
        insertSObjects(objName, accounts);
        return account.id;
    }

    /*******************************************************************************
    *  Name            : updateAccount(Account account)
    *  Summary         : update account
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Account account
    *  Returns         : updated account id
    ******************************************************************************/
    public Id updateAccount(Account account) {
        String objName = Account.class.getName();
        List<Account> accounts = new List<Account>();
        accounts.add(account);
        updateSObjects(objName, accounts);
        return account.id;
    }

    /*******************************************************************************
    *  Name            : getAccountById(Id accountId)
    *  Summary         : get account by id
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : 25/07/2018
    *  Parameters      : Id accounts
    *  Returns         : account
    ******************************************************************************/
    public Account getAccountById(Id accountId) {
        Account account = new Account();
        account = [
                SELECT Id, Name, INN__c, OGRN_ppr__c, KPP__c, OKPO_ppr__c, Code_Word__c, Organization_Type__c,
                        BillingAddress, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                        ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Checking_Account__c,
                        SWIFT_BIC__c, Bank__c, Cor_bank_account__c, Phone, Company_Legal_Name1__c, OwnerId, Transit_ID_a__c,
                        Last_pump_date__c, Date_of_transfer_to_service__c, Region__c, Owner.ManagerId, Original_document_courier_info__c, Cards_delivery_courier_info__c,(
                        SELECT Id, Name, PPR_Lost_Reasons__c, StageName, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, Owner.ManagerId,
                                Owner.Email, CloseDate, INN_Opp__c, Day_transfer__c, Owner.UserRole.Name, MAIN_ID__c, Probability, Transit_ID__c, IsClosed
                        FROM Opportunities
                )
                FROM Account
                WHERE Id = :accountId
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Account', 'Russian')
                LIMIT 1
        ];
        return account;
    }

    /*******************************************************************************
    *  Name            : getAccountsByINN(String INN)
    *  Summary         : get accounts by INN
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String INN
    *  Returns         : accounts list
    ******************************************************************************/
    public List<Account> getAccountsByINN(String INN) {
        List<Account> accountsList = new List<Account>();
        accountsList = ([
                SELECT Id, Name, INN__c, Phone, Company_Legal_Name1__c, Last_pump_date__c, Date_of_transfer_to_service__c, OwnerId, Transit_ID_a__c, (
                        SELECT Id, Name, PPR_Lost_Reasons__c, StageName, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, Owner.ManagerId,
                                Owner.UserRole.Name, Owner.Email, CloseDate, MAIN_ID__c, INN_Opp__c, Day_transfer__c, Probability, Transit_ID__c, IsClosed
                        FROM Opportunities
                )
                FROM Account
                WHERE INN__c = :INN
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Account', 'Russian')
                LIMIT 100
        ]);
        return accountsList;
    }

    /*******************************************************************************
    *  Name            : getAccountsByIds()
    *  Summary         : get accounts by Set ids
    *  CreatedDate     : 29/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<Id> - set with ids
    *  Returns         : account map
    ******************************************************************************/
    public Map<Id, Account> getAccountsByIds(Set<Id> accountIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap = new Map<Id, Account>([
                SELECT Id, Name, INN__c, Phone, Company_Legal_Name1__c, Last_pump_date__c, Date_of_transfer_to_service__c, OwnerId, Transit_ID_a__c, Region__c, (
                        SELECT Id, Name, INN_Opp__c, PPR_Lost_Reasons__c, StageName, OwnerId, Owner.Name, Owner.FirstName, Owner.ManagerId,
                                Owner.LastName, Owner.UserRole.Name, Owner.Email, CloseDate, Day_transfer__c, Probability, Transit_ID__c, IsClosed
                        FROM Opportunities
                )
                FROM Account
                WHERE Id IN :accountIds
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Account', 'Russian')
                LIMIT 100
        ]);
        return accountMap;
    }

    /*******************************************************************************
    *  Name            : deleteAccount(Id accountId)
    *  Summary         : delete Account
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account account
    *  Returns         : void
    ******************************************************************************/
    public void deleteAccount(Account account) {
        delete account;
    }

    public void mergerAccount(Account master, List<Account> duplicates) {
        mergerSObject(master, duplicates);
    }

    //****** Contact Dao *****//

    /*******************************************************************************
    *  Name            : createContact(Contact contact)
    *  Summary         : create contact
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Contact contact
    *  Returns         : created contact id
    ******************************************************************************/
    public Id createContact(Contact contact) {
        String objName = Contact.class.getName();
        List<Contact> contacts = new List<Contact>();
        //Временное исправление e2e бизнеса и класика для обхода ВР Dont_Use_Standard_Create_Button
        contact.PD_Avaliable_LastName_Update__c = true;
        contacts.add(contact);
        insertSObjects(objName, contacts);
        return contact.id;
    }

    /*******************************************************************************
    *  Name            : createContacts(List<Contact> contacts)
    *  Summary         : create Contacts
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : list of Contact
    *  Returns         : void
    ******************************************************************************/
    public List<Contact> createContacts(List<Contact> contacts) {
        //Временное исправление e2e бизнеса и класика для обхода ВР Dont_Use_Standard_Create_Button
        for (Contact curContact : contacts) {
            curContact.PD_Avaliable_LastName_Update__c = true;
        }
        String objName = Contact.class.getName();
        insertSObjects(objName, contacts);
        return contacts;
    }

    /*******************************************************************************
   *  Name            : updateContact(Contact contact)
   *  Summary         : update contact
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Contact contact
   *  Returns         : updated contact id
   ******************************************************************************/
    public Id updateContact(Contact contact) {
        //Временное исправление e2e бизнеса и класика для обхода ВР Dont_Use_Standard_Create_Button
        contact.PD_Avaliable_LastName_Update__c = true;
        String objName = Contact.class.getName();
        List<Contact> contacts = new List<Contact>();
        contacts.add(contact);
        updateSObjects(objName, contacts);
        return contact.id;
    }

    /*******************************************************************************
    *  Name            : getContactById(Id contactId)
    *  Summary         : get contact by id
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id contact
    *  Returns         : contact
    ******************************************************************************/
    public Contact getContactById(Id contactId) {
        Contact contact = new Contact();
        contact = [
                SELECT Id, FirstName, LastName, Email, MobilePhone, Phone, AccountId,
                        Agree_to_receive_comm_info_by_email__c, Additional_Emails__c,
                        Agree_to_process_pers_data_for_marketing__c, Salutation
                FROM Contact
                WHERE Id = :contactId
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Contact', 'Russian')
                LIMIT 1
        ];
        return contact;
    }

    public Contact getContactByContactId(Id contactId) {
        List<Contact> contact = new List<Contact>();
        contact = [
                SELECT Id, FirstName, LastName, Email, MobilePhone, Phone, AccountId,
                        Agree_to_receive_comm_info_by_email__c, Additional_Emails__c,
                        Agree_to_process_pers_data_for_marketing__c, Salutation
                FROM Contact
                WHERE Id = :contactId
        ];
        return !contact.isEmpty() ? contact[0] : null;
    }

    public List<Contact> getContactsByEmail(String email) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, AccountId, MobilePhone, Email, Additional_Emails__c
                FROM Contact
                WHERE (
                        Email = :email
                        OR Additional_Emails__c LIKE :'%' + email + '%'
                )
                AND RecordTypeId = :ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId()
                ORDER BY CreatedDate DESC
                LIMIT 5000
        ];
        return contactList;
    }

    public List<Contact> getContactsByDomain(String domain) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, AccountId, Name, MobilePhone, Email, Additional_Emails__c
                FROM Contact
                WHERE (
                        Email LIKE :'%@' + domain
                        OR Additional_Emails__c LIKE :'%@' + domain + '%'
                )
                AND RecordTypeId = :ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId()
                LIMIT 5000
        ];
        return contactList;
    }

    public List<Contact> getContactsByNamePhoneEmail(String name, String phone, String email, String defaultEmail) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, AccountId, Name, MobilePhone, Email, Formatted_phones__c, Formatted_phones_additional__c,
                        Additional_Emails__c
                FROM Contact
                WHERE Name LIKE :'%' + name
                AND (
                        Formatted_phones__c LIKE :'%' + phone + '%'
                        OR Formatted_phones_additional__c LIKE :'%' + phone + '%'
                )
                AND (
                        Email = :email
                        OR Email = :defaultEmail
                        OR Additional_Emails__c LIKE :'%' + email + '%'
                        OR Additional_Emails__c LIKE :'%' + defaultEmail + '%'
                )
                AND LeadSource = 'E2E Form RU'
                AND RecordTypeId = :ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId()
                LIMIT 100
        ];
        return contactList;
    }

    public List<Contact> getContactsByLastName(String lastName) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, AccountId, Name, LastName, MobilePhone, Email
                FROM Contact
                WHERE LastName = :lastName
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Contact', 'Russian')
                LIMIT 100
        ];
        return contactList;
    }

    public List<Contact> getContactsByLastName(String lastName, Id accountId) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, AccountId, Name, LastName, MobilePhone, Email
                FROM Contact
                WHERE LastName = :lastName
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Contact', 'Russian')
                AND AccountId = :accountId
                LIMIT 100
        ];
        return contactList;
    }

    public List<Contact> getContactsByAccountAndTitle(Id accountId, String title) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, Name, FirstName, MiddleName, LastName, Title, MobilePhone
                FROM Contact
                WHERE AccountId = :accountId AND Title = :title
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Contact', 'Russian')
                ORDER BY CreatedDate DESC
                LIMIT 100
        ];
        return contactList;
    }

    public List<Contact> getContactsByAccount(Id accountId) {
        List<Contact> contactList = new List<Contact>();
        contactList = [
                SELECT Id, Name, FirstName, MiddleName, LastName, Title, MobilePhone
                FROM Contact
                WHERE AccountId = :accountId
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Contact', 'Russian')
                ORDER BY CreatedDate DESC
                LIMIT 100
        ];
        return contactList;
    }

    //***** Opportunity Dao ******//

    /*******************************************************************************
    *  Name            : createOpportunity(Opportunity opportunity)
    *  Summary         : create opportunity
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : created opportunity id
    ******************************************************************************/
    public Id createOpportunity(Opportunity opportunity) {
        String objName = Opportunity.class.getName();
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(opportunity);
        insertSObjects(objName, opportunities);
        return opportunity.id;
    }

    /*******************************************************************************
    *  Name            : updateOpportunity(Opportunity opportunity)
    *  Summary         : update opportunity
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : updated opportunity id
    ******************************************************************************/
    public Id updateOpportunity(Opportunity opportunity) {
        String objName = Opportunity.class.getName();
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(opportunity);
        updateSObjects(objName, opportunities);
        return opportunity.id;
    }


    /*******************************************************************************
    *  Name            : updateOpportunities(List<Opportunity> opportunities
    *  Summary         : update opportunity list
    *  CreatedDate     : 28/08/2018
    *  ModifiedDate    : -
    *  Parameters      : list<Opportunity> opportunity
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunities(List<Opportunity> opportunities) {
        String objName = Opportunity.class.getName();
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList.addAll(opportunities);
        updateSObjects(objName, opportunityList);
    }

    /*******************************************************************************
    *  Name            : getOpportunityById(Id opportunityId)
    *  Summary         : get opportunity by id
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : opportunity
    ******************************************************************************/
    public Opportunity getOpportunityById(Id opportunityId) {
        Opportunity opportunity = new Opportunity();
        //SF-1313/SF-1429 start
        opportunity = [
                SELECT Id, Name, AccountId, Organization_Type__c, PPR_Lost_Reasons__c, OwnerId, Owner.FirstName, Owner.UserRole.Name,
                    Owner.LastName, Owner.Name, Owner.Email, Owner.ManagerId, Source_of_Lead_o__c, Source_if_self_sourced_c__c,
                    Lead_Source_TypeOpp__c, PPR_First_Contact_Inbound_Outbound__c, Prepay_Amount__c, Scoring_Date__c, StageName,
                    Scoring_Expiration_Date__c, Scoring_Status__c, Manual_Entry__c, MAIN_ID__c, Req_Num_MZK__c, CloseDate,
                    E2E_Status__c, E2E_Sub_Status__c, E2E_Sales_Type__c, E2E_Last_Activity__c, Day_transfer__c, Probability,
                    Transit_ID__c, IsClosed, E2E_Encoded_URL__c, Source_PP__c, INN_Opp__c, Product_PPR__c, Number_of_Cards__c,
                    CategoryContract__c, Business_process__c, Promo_campaign__c, Virtual_cards__c, Promo_Code1__c,
                    PPR_Electronic_document_management__c, Personal_office_phone__c, ALL_Cards__c, Our_organization__c,
                    (
                        SELECT id, E2E_Black_List__c, E2E_Black_List_Limitations__c, E2E_Scoring_Decision__c
                        FROM E2EFormRuData__r
                    ),
                    (
                        SELECT Contact.Id, Contact.FirstName, Contact.MiddleName, Contact.LastName,
                            Role, Contact.Email, Contact.Additional_Emails__c, Contact.Additional_Phones__c, Contact.Phone, Contact.MobilePhone, IsPrimary
                        FROM OpportunityContactRoles
                    )
                FROM Opportunity
                WHERE Id = :opportunityId
                AND RecordTypeId = :GlobalUtils.getRecordTypeId('Opportunity', 'Russian_Sales')
                LIMIT 1
        ];
        //SF-1313/SF-1429 end
        return opportunity;
    }
	
    //SF-1313 start
    /*******************************************************************************
    *  Name            : getOpportunitiesByAccount(Id accountId)
    *  Summary         : get Opportunities list by Account
    *  CreatedDate     : 23/07/2020
    *  ModifiedDate    : -
    *  Parameters      : Id accountId
    *  Returns         : List<Opportunity>
    ******************************************************************************/
    public List<Opportunity> getOpportunitiesByAccount(Id accountId) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = [
                SELECT Id, OwnerId, Owner.ManagerId, Name
                FROM Opportunity
                WHERE AccountId = :accountId
                AND RecordTypeId = :OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID
                ORDER BY CreatedDate DESC
                LIMIT 100
        ];
        return opportunityList;
    }
    //SF-1313 end

    /*******************************************************************************
    *  Name            : getLastModifiedStageByOpportunityId(Id opportunityId)
    *  Summary         : get OpportunityHistory by id
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId
    *  Returns         : OpportunityHistory history list
    ******************************************************************************/
    public List<OpportunityHistory> getLastModifiedStageByOpportunityId(Id opportunityId) {
        return ([
                SELECT StageName, Closedate, CreatedDate
                FROM OpportunityHistory
                WHERE OpportunityId = :opportunityId
                ORDER BY CreatedDate DESC
                LIMIT 1
        ]);
    }

    /*******************************************************************************
    *  Name            : getOpportunitiesByIds(Set<Id> opportunitiesIds)
    *  Summary         : get Opportunities list by ids
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : -
    *  Parameters      : Set<Id> opportunitiesIds
    *  Returns         : List<Opportunity>
    ******************************************************************************/
    public List<Opportunity> getOpportunitiesByIds(Set<Id> opportunitiesIds) {
        return ([
                SELECT Id, OwnerId, Owner.ManagerId, Name
                FROM Opportunity
                WHERE Id IN :opportunitiesIds
        ]);
    }

    //****** OpportunityContactRole Dao *****//

    /*******************************************************************************
    *  Name            : createOpportunityContactRole(List<OpportunityContactRole> opportunityContactRoles)
    *  Summary         : create OpportunityContactRole
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : list of OpportunityContactRole
    *  Returns         : void
    ******************************************************************************/
    public void createOpportunityContactRole(List<OpportunityContactRole> opportunityContactRoles) {
        String objName = OpportunityContactRole.class.getName();
        insertSObjects(objName, opportunityContactRoles);
    }

    /*******************************************************************************
    *  Name            : getOpportunityContactRole(Id contactId, Id opportunityId)
    *  Summary         : get OpportunityContactRole by contact id and opportunity id
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : contact id, opportunity id
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public OpportunityContactRole getOpportunityContactRole(Id contactId, Id opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole = [
                SELECT Id, ContactId, OpportunityId, Role
                FROM OpportunityContactRole
                WHERE ContactId = :contactId AND
                OpportunityId = :opportunityId
                LIMIT 1
        ];
        return opportunityContactRole;
    }

    /*******************************************************************************
    *  Name            : getOpportunityContactRoles(Id contactId, Id opportunityId)
    *  Summary         : get OpportunityContactRole list by contact id and opportunity id
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : contact id, opportunity id
    *  Returns         : OpportunityContactRoles - list
    ******************************************************************************/
    public List<OpportunityContactRole> getOpportunityContactRoles(Id contactId, Id opportunityId) {
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        opportunityContactRoles = [
                SELECT Id, ContactId, OpportunityId, Role
                FROM OpportunityContactRole
                WHERE ContactId = :contactId AND
                OpportunityId = :opportunityId
                LIMIT 1
        ];
        return opportunityContactRoles;
    }

    /*******************************************************************************
    *  Name            : getOpportunityContactRoles(Id opportunityId)
    *  Summary         : get OpportunityContactRoles by opportunity id
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : opportunity id
    *  Returns         : List<OpportunityContactRole>
    ******************************************************************************/
    public List<OpportunityContactRole> getOpportunityContactRoles(Id opportunityId) {
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        opportunityContactRoles = [
                SELECT Id, ContactId, OpportunityId, Role, Contact.FirstName, Contact.MiddleName, Contact.LastName, Contact.Name
                FROM OpportunityContactRole
                WHERE OpportunityId = :opportunityId
        ];
        return opportunityContactRoles;
    }

    /*******************************************************************************
    *  Name            : updateOpportunityContactRole(List<OpportunityContactRole> opportunityContactRoles)
    *  Summary         : update OpportunityContactRoles
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : list of OpportunityContactRole
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityContactRole(List<OpportunityContactRole> opportunityContactRoles) {
        String objName = OpportunityContactRole.class.getName();
        updateSObjects(objName, opportunityContactRoles);
    }


    //****** Document Dao *****//

    /*******************************************************************************
    *  Name            : createDocument(Document document)
    *  Summary         : create document
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Document document
    *  Returns         : created document id
    ******************************************************************************/
    public Id createDocument(Document document) {
        String objName = Document.class.getName();
        List<Document> documents = new List<Document>();
        documents.add(document);
        insertSObjects(objName, documents);
        return document.id;
    }

    /*******************************************************************************
    *  Name            : getDocumentById(Id documentId)
    *  Summary         : get document by id
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id documentId
    *  Returns         : document
    ******************************************************************************/
    public Document getDocumentById(Id documentId) {
        Document document = new Document();
        document = [
                SELECT Id, Name, Body, ContentType, Type
                FROM Document
                WHERE Id = :documentId
                LIMIT 1
        ];
        return document;
    }

    /*******************************************************************************
    *  Name            : getFolderByName(String folderName)
    *  Summary         : get folder by name
    *  CreatedDate     : 24/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String folderName
    *  Returns         : folder
    ******************************************************************************/
    public Folder getFolderByName(String folderName) {
        Folder folder = new Folder();
        folder = [
                SELECT Id, Name, Type
                FROM Folder
                WHERE Name = :folderName
                LIMIT 1
        ];
        return folder;
    }


    //******* Form Service *****//

    /*******************************************************************************
    *  Name            : createFormDataRecord(E2EFormData__c formData)
    *  Summary         : create Form Data record
    *  CreatedDate     : 17/07/2018
    *  ModifiedDate    : -
    *  Parameters      : E2EFormData__c formData
    *  Returns         : created form data record id
    ******************************************************************************/
    public Id createFormDataRecord(E2EFormData__c formData) {
        String objName = E2EFormData__c.class.getName();
        List<E2EFormData__c> formDataList = new List<E2EFormData__c>();
        formDataList.add(formData);
        insertSObjects(objName, formDataList);
        return formData.id;
    }

    /*******************************************************************************
    *  Name            : updateFormData(E2EFormData__c formDataRecord)
    *  Summary         : update data record
    *  CreatedDate     : 17/07/2018
    *  ModifiedDate    : -
    *  Parameters      : E2EFormData__c formData
    *  Returns         : updated form data record id
    ******************************************************************************/
    public Id updateFormData(E2EFormData__c formDataRecord) {
        String objName = E2EFormData__c.class.getName();
        List<E2EFormData__c> formDataList = new List<E2EFormData__c>();
        formDataList.add(formDataRecord);
        updateSObjects(objName, formDataList);
        return formDataRecord.id;
    }

    /*******************************************************************************
    *  Name            : getFormDataById(Id formDataRecordId)
    *  Summary         : get Form Data Record by id
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id formDataRecordId
    *  Returns         : Form Data Record
    ******************************************************************************/
    public E2EFormData__c getFormDataById(Id formDataRecordId) {
        if (formDataRecordId == null) return null;
        List<E2EFormData__c> formDataRecords = [
                SELECT Id, Name, E2E_Account_Id__c, E2E_Contact_Id__c, E2E_Opportunity_Id__c, E2E_Contact_Phone__c,
                        E2E_Contact_Email__c, E2E_Account_Name__c, E2E_INN__c, E2E_Product__c, E2E_Process_Personal_Data__c,
                        E2E_Send_Marketing_Email__c, E2E_Manual_Entry__c, E2E_Num_Cards__c, E2E_Promo_Campaign__c,
                        E2E_Personal_Manager_srv__c, E2E_Document_Delivery_srv__c, E2E_Overdraft_srv__c, Free_overdraft__c,
                        E2E_Payment_Condition__c, E2E_OGRN__c, E2E_KPP__c, E2E_OKPO__c, E2E_Legal_Address__c,
                        E2E_Post_Address__c, E2E_Executive_Person__c, E2E_Executive_Person_Manual__c, E2E_Chief_Accountant__c,
                        E2E_Code_Word__c, E2E_Checking_Account__c, E2E_Bank__c, E2E_BIC__c, E2E_Cor_Bank_Account__c,
                        E2E_Prepay_Amount__c, E2E_Last_Step__c, E2E_IP_Address__c,
                        E2E_Scoring_Date__c, E2E_Scoring_Expiration_Date__c, E2E_Spark_Id__c, E2E_Main_Company_Full_Name__c,
                        E2E_Bank_Name_Short__c, E2E_Bank_Address__c, E2E_Bank_Town__c, E2E_Bank_OKPO__c, E2E_Product_Id__c, E2E_Tariff_Id__c,
                        E2E_Courier_Comments__c, E2E_Shipping_Str__c, E2E_Billing_Code__c, E2E_Billing_State__c, E2E_Billing_City__c,
                        E2E_Black_List_Code__c, E2E_Black_List__c, E2E_Black_List_Limitations__c, E2E_Scoring_Decision_Code__c,
                        E2E_Scoring_Decision__c, E2E_Source__c, E2E_Shipping_State__c, E2E_Account_Short_Name__c, E2E_Form_URL__c,
                        E2E_Shipping_City__c, E2E_Shipping_Country__c, E2E_Shipping_House__c, E2E_Shipping_Code__c, E2E_Reg_Date__c,
                        E2E_Billing_House__c, E2E_Billing_Str__c, E2E_Billing_Apartment__c, E2E_Shipping_Apartment__c, E2E_Personal_Office_Email__c,
                        E2E_Offer__c, E2E_Manual_Entry_Legal_Info__c, E2E_Transit_Cont_Id__c, E2E_Req_Num_MZK__c, E2E_Contract_Number__c,
                        Last_deduplication_time__c, E2E_Dedup_Status__c, E2E_Dedup_Status_Info__c, E2E_Process_Status__c, E2E_Empty_SPARK_OKPO__c
                FROM E2EFormData__c
                WHERE Id = :formDataRecordId
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        if (formDataRecords != null && formDataRecords.size() > 0) return formDataRecords[0];
        return null;
    }

    /*******************************************************************************
    *  Name            : getFormDataByAccountIdAndContactId(Id accountId, Id contactId)
    *  Summary         : get Form Data Record by account Id and contact Id
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Id accountId, Id contactId
    *  Returns         : Form Data Record
    ******************************************************************************/
    public List<E2EFormData__c> getFormDataByAccountIdAndContactId(Id accountId, Id contactId) {
        List<E2EFormData__c> formDataRecords = new List<E2EFormData__c>();
        formDataRecords = [
                SELECT Id, E2E_Account_Id__c, E2E_Contact_Id__c, E2E_Opportunity_Id__c, E2E_Contact_Phone__c,
                        E2E_Contact_Email__c, E2E_Account_Name__c, E2E_INN__c, E2E_Product__c, E2E_Process_Personal_Data__c,
                        E2E_Send_Marketing_Email__c, E2E_Manual_Entry__c, E2E_Num_Cards__c, E2E_Promo_Campaign__c,
                        E2E_Personal_Manager_srv__c, E2E_Document_Delivery_srv__c, E2E_Overdraft_srv__c,
                        E2E_Payment_Condition__c, E2E_OGRN__c, E2E_KPP__c, E2E_OKPO__c, E2E_Legal_Address__c,
                        E2E_Post_Address__c, E2E_Executive_Person__c, E2E_Chief_Accountant__c,
                        E2E_Code_Word__c, E2E_Checking_Account__c, E2E_Bank__c, E2E_BIC__c, E2E_Cor_Bank_Account__c,
                        E2E_Prepay_Amount__c, E2E_Last_Step__c, E2E_IP_Address__c, E2E_Product_Id__c, E2E_Tariff_Id__c,
                        E2E_Scoring_Date__c, E2E_Scoring_Expiration_Date__c, E2E_Spark_Id__c, E2E_Main_Company_Full_Name__c,
                        E2E_Bank_Name_Short__c, E2E_Bank_Address__c, E2E_Bank_Town__c, E2E_Bank_OKPO__c
                FROM E2EFormData__c
                WHERE E2E_Account_Id__c = :accountId
                AND E2E_Contact_Id__c = :contactId
                LIMIT 1
        ];
        return formDataRecords;
    }

    //******* Lead Dao *****//
    /*******************************************************************************
    *  Name            : getDuplicatedLeads(String email, String phone)
    *  Summary         : get Lead by email and phone
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String email, String phone
    *  Returns         : lead list
    ******************************************************************************/
    public List<Lead> getDuplicatedLeads(String email, String phone) {
        List<Lead> leadsList = new List<Lead>();
        String searchPhone = '%' + phone + '%';
        leadsList = ([
                SELECT Id, OwnerId, Status, Email, Name, Owner.Email, Owner.Type, Owner.Name,
                        Lead_Status_Specific__c, Owner.UserRole.ParentRoleId, INN__c, Phone, Additional_Emails__c,
                        Formatted_phones__c, Formatted_phones_additional__c
                FROM Lead
                WHERE (
                        Email = :email
                        OR Additional_Emails__c LIKE :'%' + email + '%'
                        OR Formatted_phones__c LIKE :searchPhone
                        OR Formatted_phones_additional__c LIKE :searchPhone
                )
                AND IsConverted = FALSE
                AND Status != 'Disqualified'
                AND RecordTypeId = :LeadHandler.leadRecordTypes.get(GlobalUtils.LeadRecordTypes.Russian_Sales.name()).getRecordTypeId()
                LIMIT 5000
        ]);
        return leadsList;
    }

    /*******************************************************************************
    *  Name            : updateLeads(List<Lead> leadsList)
    *  Summary         : update leads
    *  CreatedDate     : 07/08/2018
    *  ModifiedDate    : -
    *  Parameters      : list of the lead
    *  Returns         : -
    ******************************************************************************/
    public void updateLeads(List<Lead> leadsList) {
        //Временное исправление e2e бизнеса и класика для обхода ВР Dont_Use_Standard_Create_Button
        for (Lead curLead : leadsList) {
            curLead.PD_Avaliable_LastName_Update__c = true;
        }
        String objName = Lead.class.getName();
        updateSObjects(objName, leadsList);
    }


    //******* User Service *****//
    /*******************************************************************************
    *  Name            : getUserByName(String name)
    *  Summary         : get user by name
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : -
    *  Parameters      : user name
    *  Returns         : user
    ******************************************************************************/
    public User getUserByName(String name) {
        User user = new User();
        user = ([
                SELECT Id, Name, Email, FirstName, LastName
                FROM User
                WHERE Name = :name
                LIMIT 1
        ]);
        return user;
    }

    public Map<Id, User> getUsersByNames(Set<String> names) {
        return new Map<Id, User>([
                SELECT Id, Name, Email
                FROM User
                WHERE Name IN :names
                LIMIT 250
        ]);
    }

    public Map<Id, User> getUsersMapByIds(Set<Id> userIds) {
        return new Map<Id, User>([
                SELECT Id, Name, Email, ManagerId
                FROM User
                WHERE Id IN :userIds
                LIMIT 1000
        ]);
    }

    public List<User> getUsersByUserRoleId(Set<Id> userRoleIds) {
        List<User> userList = new List<User>();
        userList = ([
                SELECT Id, Name, UserRoleId
                FROM User
                WHERE UserRoleId IN :userRoleIds
                LIMIT 250
        ]);
        return userList;
    }

    public EmailTemplate getEmailTemplateByDevName(String devName) {
        EmailTemplate template = new EmailTemplate();

        template = ([
                SELECT Subject, HtmlValue, Body
                FROM EmailTemplate
                WHERE DeveloperName = :devName
                LIMIT 1
        ]);
        return template;
    }

    public UserRole getUserRoleById(String roleId) {
        UserRole role = new UserRole();
        role = ([
                SELECT Id, Name, RollupDescription, DeveloperName
                FROM UserRole
                WHERE Id = :roleId
                LIMIT 1
        ]);
        return role;
    }

    /*******************************************************************************
    *  Name            : insertSObjects(String objectName, List<SObject> sObjectList)
    *  Summary         : insert list SObject
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : List<SObject> sObjectList
    *  Returns         : void
    ******************************************************************************/
    @TestVisible
    private void insertSObjects(String objectName, List<SObject> sObjectList) {
        Database.SaveResult[] srList = Database.insert(sObjectList, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                String error = '';
                for (Database.Error err : sr.getErrors()) {
                    error += err.getMessage();
                }
                throw new E2EFormRuException(objectName + ': ' + error);
            }
        }
    }

    /*******************************************************************************
    *  Name            : insertSObject(String objectName, SObject sObj)
    *  Summary         : insert SObject
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : SObject sObj
    *  Returns         : void
    ******************************************************************************/
    @TestVisible
    private void insertSObject(String objectName, SObject sObj) {
        Database.SaveResult srRes = Database.insert(sObj, false);
        if (!srRes.isSuccess()) {
            String error = '';
            for (Database.Error err : srRes.getErrors()) {
                error += err.getMessage();
            }
            throw new E2EFormRuException(objectName + ': ' + error);
        }
    }

    /*******************************************************************************
    *  Name            : updateSObjects(String objectName, List<SObject> sObjectList)
    *  Summary         : update list SObject
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : List<SObject> sObjectList
    *  Returns         : void
    ******************************************************************************/
    private void updateSObjects(String objectName, List<SObject> sObjectList) {
        Database.SaveResult[] srList = Database.update(sObjectList, false);
        System.debug('**** updateSObjects DEBUG: ' + srList);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                String error = '';
                for (Database.Error err : sr.getErrors()) {
                    error += err.getMessage();
                }
                throw new E2EFormRuException(objectName + ': ' + error);
            }
        }
    }
    //update sObject through interface E2EFormRuDao sf-1131
    public void updSObjects(String objectName, List<SObject> sObjectList) {
        System.debug('listOwner---------?????>>>' + sObjectList );
        Database.SaveResult[] srList = Database.update(sObjectList, false);
        System.debug('**** updateSObjects DEBUG: ' + srList);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                String error = '';
                for (Database.Error err : sr.getErrors()) {
                    error += err.getMessage();
                }
                throw new E2EFormRuException(objectName + ': ' + error);
            }
        }
    }

    private void mergerSObject(SObject master, List<SObject> duplicates) {
        Database.MergeResult[] results = Database.merge(master, duplicates, false);
        System.debug('**** mergerSObject DEBUG: ' + results);
        for (Database.MergeResult sr : results) {
            if (!sr.isSuccess()) {
                String error = '';
                for (Database.Error err : sr.getErrors()) {
                    error += err.getMessage();
                }
                System.debug('Error: ' + error);
                throw new E2EFormRuException('Error: ' + error);
            }
        }
    }

    public User isRoleAnInbound(Id id) {
        Opportunity opportunity = new Opportunity();
        opportunity = ([
                SELECT id, OwnerId
                FROM Opportunity
                WHERE Id = :id
                LIMIT 1
        ]);

        User user = new User();
        user = ([
                SELECT id, name, userrole.name
                FROM User
                WHERE Id = :opportunity.OwnerId
                LIMIT 1
        ]);
        return User;
    }

    public Opportunity getOpportunityStep(Id id) {
        Opportunity opp = [SELECT StageName, E2E_Active_Substep__c FROM Opportunity WHERE Id = :Id];
        return opp;
    }
}