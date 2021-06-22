@isTest
public class E2EFormRuDaoImplTest {

    public static void initPagesStructure() {
        E2EFormRuTestUtils.createLongFormRU();
        E2EFormRuTestUtils.createContactDetailsStep();
        E2EFormRuTestUtils.createCompanyInformationStep();
        E2EFormRuTestUtils.createOrderStep();
        E2EFormRuTestUtils.createLegalDetailsStep();
        E2EFormRuTestUtils.createPaymentDetailsStep();
    }

    // ***** Content Dao ***** //
    @isTest
    public static void testContentDao() {
        initPagesStructure();

        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        // get long form pages
        Set<String> elementsOfStep = new Set<String>{
                'CONTACT DETAILS', 'ORDER'
        };
        Map<Id, LongForm_Page__c> pageMap = e2eFormRuDao.getLongFormPages('Russia', elementsOfStep, 'Desktop');
        System.assertEquals(true, !pageMap.isEmpty());

        //getSharedResources
        Map<Id, LongForm_Page__c> pageMap2 = e2eFormRuDao.getSharedResources('Russia', elementsOfStep, 'Desktop');
        System.assertEquals(false, pageMap2.isEmpty());

        // get elements list by pages
        List<LongForm_Element__c> elementList = e2eFormRuDao.getElementsListByPages(pageMap.keySet());
        System.assertEquals(true, elementList.size() > 0);


        // get products by offer
        Set<Id> offerIds = new Set<Id>();
        for (LongForm_Element__c element : elementList) {
            for (LongForm_Offer__c offer : element.LongForm_Offers__r) {
                offerIds.add(offer.Id);
            }
        }
        Map<Id, LongForm_Fleetcor_Product__c> productMap = e2eFormRuDao.getProductsByOffer(offerIds);
        System.assertEquals(true, !productMap.isEmpty());

        // get tariffs by product
        Map<Id, LongForm_Tariff__c> tariffMap = e2eFormRuDao.getTariffsByProduct(productMap.keySet());
        System.assertEquals(true, !tariffMap.isEmpty());
        System.assertEquals(5, tariffMap.size());

        // get properties by tariff
        Map<Id, LongForm_Property__c> propertyMap = e2eFormRuDao.getPropertiesByTariff(tariffMap.keySet());
        System.assertEquals(true, !propertyMap.isEmpty());

        // get offers by ids
        Map<Id, LongForm_Offer__c> offerMap = e2eFormRuDao.getOffersByIds(offerIds);
        System.assertEquals(true, !offerMap.isEmpty());
    }


    // ***** User Dao ***** //
    @isTest
    public static void testUserDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        // get one user by name
        User templateUser = E2EFormRuTestUtils.createUser();
        insert templateUser;
        User existingUser = e2eFormRuDao.getUserByName('User Test');
        System.assertEquals(true, existingUser.Id != null);

        // get users By names
        User templateUser2 = E2EFormRuTestUtils.createUser();
        templateUser2.Username = 'new_user2_email@email.ru';
        templateUser2.LastName = 'Test 2';
        insert templateUser2;

        Map<Id, User> users = e2eFormRuDao.getUsersByNames(new Set<String>{
                'User Test', 'User Test 2'
        });
        System.assertEquals(true, !users.isEmpty());

        // get users by user role id
        List<User> usersList = e2eFormRuDao.getUsersByUserRoleId(new Set<Id>{
                templateUser.UserRoleId
        });
        System.assertEquals(true, usersList.size() > 0);

        // get users map by ids
        Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(new Set<Id>{
                usersList.get(0).Id, usersList.get(1).Id
        });
        System.assertEquals(true, usersMap.size() == 2);
    }

    // ***** Lead Dao ***** //
    @isTest
    public static void testLeadDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Lead lead = E2EFormRuTestUtils.createDefaultLead();
        insert lead;

        Lead newLead = E2EFormRuTestUtils.createDefaultLead();
        insert newLead;
        newLead.MobilePhone = '8 123 333 22 55#123';
        newLead.PPR_Contact_Phone__c = '+7222 222 22 33';
        newLead.Additional_Phones__c = '123 222 54 76#23.8 800 222 2343';
        newLead.Additional_Emails__c = 'test1@mail.ru.test2@mail.ru';
        update newLead;

        // get duplicated leads
        System.assertEquals(2, e2eFormRuDao.getDuplicatedLeads(newLead.Email, PhoneNumberUtils.getRawPhoneNumber(newLead.Phone)).size());
        System.assertEquals(1, e2eFormRuDao.getDuplicatedLeads('test1@mail.ru', PhoneNumberUtils.getRawPhoneNumber(newLead.MobilePhone)).size());
        System.assertEquals(1, e2eFormRuDao.getDuplicatedLeads('test2@mail.ru', PhoneNumberUtils.getRawPhoneNumber(newLead.PPR_Contact_Phone__c)).size());
        System.assertEquals(1, e2eFormRuDao.getDuplicatedLeads('fsfd', PhoneNumberUtils.getRawPhoneNumber('123 222 54 76#23')).size());
        System.assertEquals(1, e2eFormRuDao.getDuplicatedLeads('', PhoneNumberUtils.getRawPhoneNumber('8 800 222 2343')).size());
        System.assertEquals(0, e2eFormRuDao.getDuplicatedLeads('sggf', PhoneNumberUtils.getRawPhoneNumber('2454')).size());

        // update leads
        lead.Company = 'ООО Технология';
        newLead.Company = 'ООО Технология+';
        List<Lead> leadsForUpdate = new List<Lead>();
        leadsForUpdate.add(lead);
        leadsForUpdate.add(newLead);

        e2eFormRuDao.updateLeads(leadsForUpdate);
        System.assertEquals(true, leadsForUpdate.get(0).Company == 'ООО Технология');
        System.assertEquals(true, leadsForUpdate.get(1).Company == 'ООО Технология+');
    }

    // ***** Account Dao ***** //
    @isTest
    public static void testAccountDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Account templateAccount = E2EFormRuTestUtils.createDefaultAccount();
        templateAccount.INN__c = '11122233';

        // create account
        Id newAccountId = e2eFormRuDao.createAccount(templateAccount);
        System.assertEquals(true, newAccountId != null);

        // get account by id
        Account existingAccount = e2eFormRuDao.getAccountById(templateAccount.Id);
        System.assertEquals(true, existingAccount.Id != null);
        System.assertEquals(true, existingAccount.Name == 'E2E RU Account Test');

        // update account
        templateAccount.Name = 'E2E Account RU New Name';
        Id updatedAccountId = e2eFormRuDao.updateAccount(templateAccount);
        System.assertEquals(true, templateAccount.Name == 'E2E Account RU New Name');

        // get accounts by INN
        List<Account> existingAccounts = e2eFormRuDao.getAccountsByINN('11122233');
        System.assertEquals(true, existingAccounts.size() == 1);

        // get accounts by ids
        Account templateAccount2 = E2EFormRuTestUtils.createDefaultAccount();
        templateAccount2.INN__c = '22233344';
        insert templateAccount2;

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(templateAccount.Id);
        accountIds.add(templateAccount2.Id);

        Map<Id, Account> accountsByIds = e2eFormRuDao.getAccountsByIds(accountIds);
        System.assertEquals(true, accountsByIds.size() == 2);

        // delete account
        e2eFormRuDao.deleteAccount(templateAccount2);
        List<Account> deletedAccount = [SELECT id FROM Account WHERE Id = :templateAccount2.Id LIMIT 1];
        System.assertEquals(true, deletedAccount.size() == 0);
    }

    // ***** Contact Dao ***** //
    @isTest
    public static void testContactsDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Account templateAccount = E2EFormRuTestUtils.createDefaultAccount();

        // create contact
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        Id newContactId = e2eFormRuDao.createContact(contact);
        System.assertEquals(true, newContactId != null);

        // get contact by email
        List<Contact> contactsByEmail = e2eFormRuDao.getContactsByEmail('e2etest@e2etest.ru');
        System.assertEquals(true, contactsByEmail.size() == 1);

        // create contacts list
        List<Contact> templateListContacts = new List<Contact>();
        Contact contact1 = E2EFormRuTestUtils.createDefaultContact();
        contact1.MobilePhone = '+7 9222333321';
        contact1.PPR_Contact_Phone__c = '+7 9222333323';
        contact1.Additional_Emails__c = 'test1@mail.ru.test2@mail.ru';
        templateListContacts.add(contact1);
        Contact contact2 = E2EFormRuTestUtils.createDefaultContact();
        contact2.HomePhone = '+7 9222333324';
        templateListContacts.add(contact2);
        Contact contact4 = E2EFormRuTestUtils.createDefaultContact();
        contact4.AssistantPhone = '+7 9222333325';
        templateListContacts.add(contact4);
        Contact contact5 = E2EFormRuTestUtils.createDefaultContact();
        contact5.OtherPhone = '+7 9222333326';
        contact5.Additional_Phones__c = '+7 9222333327.+7 9222333328';
        contact5.Additional_Emails__c = 'test1@mail.ru.test2@mail.ru';
        templateListContacts.add(contact5);


        List<Contact> existingContacts = e2eFormRuDao.createContacts(templateListContacts);
        System.assertEquals(true, existingContacts.size() == 4);

        // get contact by id
        Contact existingContact = e2eFormRuDao.getContactById(contact1.Id);
        System.assertEquals(true, existingContact.Id != null);
        System.assertEquals(true, existingContact.FirstName == 'Contact Test');

        // get contact by contact id
        Contact existingContactByContactId = e2eFormRuDao.getContactByContactId(contact1.Id);
        Contact emptyContactByContactId = e2eFormRuDao.getContactByContactId(null);
        System.assertEquals(null, emptyContactByContactId);
        System.assertEquals(true, existingContactByContactId.Id != null);
        System.assertEquals(true, existingContactByContactId.FirstName == 'Contact Test');

        // update contact
        contact1.Email = 'e2etestNEW@e2etestNEW.ru';
        e2eFormRuDao.updateContact(contact1);
        System.assertEquals(true, contact1.Email == 'e2etestNEW@e2etestNEW.ru');

        //get Contact by Email
        System.assertEquals(4, e2eFormRuDao.getContactsByEmail('e2etest@e2etest.ru').size());
        System.assertEquals(2, e2eFormRuDao.getContactsByEmail('test1@mail.ru').size());
        System.assertEquals(2, e2eFormRuDao.getContactsByEmail('test2@mail.ru').size());
        System.assertEquals(1, e2eFormRuDao.getContactsByEmail('e2etestNEW@e2etestNEW.ru').size());

        // get contact by domain
        List<Contact> contactsByDomain = e2eFormRuDao.getContactsByDomain('e2etestNEW.ru');
        System.assertEquals(true, contactsByDomain.size() == 1);
        System.assertEquals(2, e2eFormRuDao.getContactsByDomain('mail.ru').size());
        System.assertEquals(4, e2eFormRuDao.getContactsByDomain('e2etest.ru').size());

        // get contacts by name & phone & email
        //Phone + Email
        List<Contact> contactsByNamePhoneEmail = e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333322'), 'e2etest@e2etest.ru', ''
        );
        System.assertEquals(true, contactsByNamePhoneEmail.size() == 5);
        //MobilePhone + Additional_Emails__c
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333321'), 'test1@mail.ru', 'gdfg'
        ).size());
        //PPR_Contact_Phone__c + Additional_Emails__c
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333323'), 'test2@mail.ru', 'gdfg'
        ).size());
        //HomePhone + Email
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333324'), 'e2etest@e2etest.ru', 'gdfg'
        ).size());
        //AssistantPhone + Email
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333325'), 'e2etest@e2etest.ru', 'gdfg'
        ).size());
        //OtherPhone + Email
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333326'), 'sdfdsf', 'e2etest@e2etest.ru'
        ).size());
        //Additional_Phones__c + Additional_Emails__c
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333327'), 'fgfg', 'test1@mail.ru'
        ).size());
        //Additional_Phones__c + Additional_Emails__c
        System.assertEquals(1, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('+7 9222333328'), 'fgfg', 'test2@mail.ru'
        ).size());
        // No data
        System.assertEquals(0, e2eFormRuDao.getContactsByNamePhoneEmail(
                'E2E', PhoneNumberUtils.getRawPhoneNumber('1111111111'), 'fgfg', 'dsd'
        ).size());

        // get contacts by last name
        List<Contact> contactsByLastName = e2eFormRuDao.getContactsByLastName('E2E');
        System.assertEquals(true, contactsByLastName.size() == 5);

        // get contacts by last name & account id
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        insert account;
        Contact contact3 = E2EFormRuTestUtils.createContact(account.Id);
        insert contact3;
        List<Contact> contactsByLastNameAndAccId = e2eFormRuDao.getContactsByLastName('E2E', account.Id);
        System.assertEquals(true, contactsByLastNameAndAccId.size() == 1);

        // get contacts by account and contact title
        List<Contact> contactsByAccountAndTitle = e2eFormRuDao.getContactsByAccountAndTitle(contact.AccountId, contact.Title);
        System.assertEquals(1, contactsByAccountAndTitle.size());

        // get contacts by account and contact title
        List<Contact> contactsByAccount = e2eFormRuDao.getContactsByAccount(contact.AccountId);
        System.assertEquals(1, contactsByAccount.size());
    }

    // ***** Opportunity Dao ***** //
    @isTest
    public static void testOpportunityDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Opportunity templateOpportunity = E2EFormRuTestUtils.createDefaultOpportunity();

        // create opportunity
        Id newOpportunityId = e2eFormRuDao.createOpportunity(templateOpportunity);
        System.assertEquals(true, newOpportunityId != null);

        // get opportunity by id
        Opportunity existingOpportunity = e2eFormRuDao.getOpportunityById(newOpportunityId);
        System.assertEquals(true, existingOpportunity.Id != null);
        System.assertEquals(true, existingOpportunity.Name == 'E2E Opportunity Test');
        System.assertEquals(false, existingOpportunity.Virtual_cards__c);
        System.assertEquals(templateOpportunity.Personal_office_phone__c, existingOpportunity.Personal_office_phone__c);

        // update opportunity
        templateOpportunity.Name = 'E2E Opportunity Test New';
        Id updatedOpportunityId = e2eFormRuDao.updateOpportunity(templateOpportunity);
        System.assertEquals(true, templateOpportunity.Name == 'E2E Opportunity Test New');

        // update opportunities
        List<Opportunity> templateListOpportunities = new List<Opportunity>();
        Opportunity opportunity1 = E2EFormRuTestUtils.createDefaultOpportunity();
        opportunity1.Name = 'E2E Opportunity Test Updated';
        opportunity1.OwnerId = UserInfo.getUserId();
        templateListOpportunities.add(opportunity1);
        Opportunity opportunity2 = E2EFormRuTestUtils.createDefaultOpportunity();
        opportunity2.Name = 'E2E Opportunity Test Updated';
        opportunity2.OwnerId = UserInfo.getUserId();
        templateListOpportunities.add(opportunity2);
        insert templateListOpportunities;

        e2eFormRuDao.updateOpportunities(templateListOpportunities);
        System.assertEquals(true, opportunity1.Name == 'E2E Opportunity Test Updated');
        System.assertEquals(true, opportunity2.Name == 'E2E Opportunity Test Updated');

        // get last modified stage by opportunity id
        List<OpportunityHistory> oppHistory = e2eFormRuDao.getLastModifiedStageByOpportunityId(opportunity1.Id);
        System.assertEquals(true, oppHistory.size() == 0);

        //**********getOpportunitiesByIds test*****************//
        Map<Id, Opportunity> testOpportunities = new Map<Id, Opportunity>();
        for (Opportunity opportunity : templateListOpportunities) {
            testOpportunities.put(opportunity.Id, new Opportunity(Id = opportunity.Id, OwnerId = opportunity.OwnerId));
        }

        List<Opportunity> refusingOpportunityList = e2eFormRuDao.getOpportunitiesByIds(testOpportunities.keySet());
        System.assertEquals(templateListOpportunities.size(), refusingOpportunityList.size());
        System.debug('testOpportunities = ' + testOpportunities);
        System.debug('refusingOpportunityList = ' + refusingOpportunityList);
		
        //SF-1313
        //**********getOpportunitiesByAccount test*****************//
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        insert account;
        opportunity1.AccountId = account.Id;
        update opportunity1;

        List<Opportunity> opportunityByAccList = e2eFormRuDao.getOpportunitiesByAccount(account.Id);
        System.assertEquals(1, opportunityByAccList.size());		
    }

    // ***** OpportunityContactRole Dao ***** //
    @isTest
    public static void testOpportunityContactRoleDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        Opportunity templateOpportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        insert templateOpportunity;

        Contact templateContact = E2EFormRuTestUtils.createDefaultContact();
        insert templateContact;
        OpportunityContactRole contactRole = new OpportunityContactRole(
                OpportunityId = templateOpportunity.Id,
                Role = 'Accountant',
                IsPrimary = true,
                ContactId = templateContact.Id
        );

        Contact templateContact2 = E2EFormRuTestUtils.createDefaultContact();
        insert templateContact2;
        OpportunityContactRole contactRole2 = new OpportunityContactRole(
                OpportunityId = templateOpportunity.Id,
                Role = 'Accountant administrator',
                IsPrimary = false,
                ContactId = templateContact2.Id
        );

        // get opportunity contact role
        //OpportunityContactRole existingContactRole = e2eFormRuDao.getOpportunityContactRole(templateContact.Id, templateOpportunity.Id);
        //System.assertEquals(true, existingContactRole.Role == 'Decision Maker');

        // create opportunity contact role
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        opportunityContactRoles.add(contactRole);
        opportunityContactRoles.add(contactRole2);

        e2eFormRuDao.createOpportunityContactRole(opportunityContactRoles);
        System.assertEquals(true, contactRole.Id != null);
        System.assertEquals(true, contactRole2.Id != null);

        // get opportunity contact roles by contact and opportunity ids
        List<OpportunityContactRole> oppContactRoles = e2eFormRuDao.getOpportunityContactRoles(templateContact.Id, templateOpportunity.Id);
        System.assertEquals(true, oppContactRoles.size() == 1);
    }

    // ***** Form Service ***** //
    @isTest
    public static void testFormDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();

        // create form data record
        Id formDataId = e2eFormRuDao.createFormDataRecord(formData);
        System.assertEquals(true, formData.Id != null);

        // update form data
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        insert contact;
        formData.E2E_Account_Id__c = contact.AccountId;
        formData.E2E_Contact_Id__c = contact.Id;
        formData.E2E_INN__c = '11122233';
        Id updatedFormDataId = e2eFormRuDao.updateFormData(formData);
        System.assertEquals(true, formData.E2E_INN__c == '11122233');

        // get form data by id
        E2EFormData__c existingFormData = e2eFormRuDao.getFormDataById(formDataId);
        System.assertEquals(true, existingFormData != null);

        // get form data by account id and contact id
        List<E2EFormData__c> formDataList = e2eFormRuDao.getFormDataByAccountIdAndContactId(contact.AccountId, contact.Id);
        System.assertEquals(true, !formDataList.isEmpty());
    }

    // ***** Document Dao ***** //
    @isTest
    public static void testDocumentDao() {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();

        //create document
        Document templateDocument = E2EFormRuTestUtils.createDefaultDocument();
        e2eFormRuDao.createDocument(templateDocument);
        System.assertNotEquals(null, templateDocument.Id);

        //get document by id
        Document existingDocument = e2eFormRuDao.getDocumentById(templateDocument.Id);
        System.assertNotEquals(null, existingDocument);
    }

    // ***** EmailTemplate Dao ***** //
    @IsTest
    public static void testEmailTemplateDao() {
        E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();

        User guest = ([
                SELECT Id, Name
                FROM User
                WHERE Name = 'E2E RU Site Guest User'
        ]);
        System.runAs(guest) {
            for (GlobalUtils.EmailTemplateDevName devName : GlobalUtils.EmailTemplateDevName.values()) {
                System.debug('DEVELOPER NAME: ' + devName.name());
                EmailTemplate template = e2EFormRuDao.getEmailTemplateByDevName(devName.name());
                System.assertNotEquals(null, template);
            }
        }
    }

    @IsTest
    public static void testInsertSObject() {
        E2EFormRuDaoImpl e2EFormRuDao = new E2EFormRuDaoImpl();
        SObject account = E2EFormRuTestUtils.createDefaultAccount();
        e2EFormRuDao.insertSObject('Name', account);
        System.assertNotEquals(null, account.Id);
    }
}