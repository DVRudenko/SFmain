@isTest
private class ContactTriggerHandlerTest {

    private static final Id RU_CONTACT_RECORD_TYPE = ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId();
    private static final Id RU_ACCOUNT_RECORD_TYPE = GlobalUtils.getRecordTypeId(Account.class.getName(), 'Russian');
    private static final String DELIMITER = PhoneNumberUtils.PHONE_NUMBER_DELIMITER;

    static {
        insert CFUtilsTest.createCFSettingsForRussia(false);
    }

    @IsTest
    private static void testUnifyPhoneNumbers() {
        Account account = new Account(
                Name = 'test',
                RecordTypeId = RU_ACCOUNT_RECORD_TYPE,
                BillingCountry = 'Russia'
        );
        insert account;
        Contact contact1 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '+0 123 123 22 22#343',
                MobilePhone = '',
                PPR_Contact_Phone__c = '+2 434434 3443#',
                HomePhone = '+12345678901#54',
                OtherPhone = '+999 999 99 99',
                AssistantPhone = '',
                Additional_Phones__c = '+12345678899#35.+1231232222'
        );
        Contact contact2 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '',
                MobilePhone = '+000 0001122#54',
                PPR_Contact_Phone__c = '',
                HomePhone = '',
                OtherPhone = '',
                AssistantPhone = '+34 435 234 22 22 #544',
                Additional_Phones__c = ''
        );
        Contact contact3 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = RU_CONTACT_RECORD_TYPE,
                Phone = '',
                MobilePhone = '',
                PPR_Contact_Phone__c = '',
                HomePhone = '',
                OtherPhone = '',
                AssistantPhone = '',
                Additional_Phones__c = '+1231232244#454'
        );
        Contact contact4 = new Contact(
                AccountId = account.Id,
                LastName = 'test',
                RecordTypeId = ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Contact_layout.name()).getRecordTypeId(),
                Phone = '+8 800 555 35 35#23'
        );
        List<Contact> contacts = new List<Contact>{contact1, contact2, contact3, contact4};
        insert contacts;
        update contacts;

        contact1 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Contact
                WHERE Id = :contact1.Id
                LIMIT 1
        ]);
        System.assertEquals(
                '1231232222' + DELIMITER + '4344343443' + DELIMITER + '2345678901' + DELIMITER + '9999999999',
                contact1.Formatted_phones__c
        );
        System.assertEquals('2345678899' + DELIMITER + '1231232222', contact1.Formatted_phones_additional__c);
        contact2 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Contact
                WHERE Id = :contact2.Id
                LIMIT 1
        ]);
        System.assertEquals('0000001122' + DELIMITER + '4352342222', contact2.Formatted_phones__c);
        System.assert(String.isEmpty(contact2.Formatted_phones_additional__c));
        contact3 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Contact
                WHERE Id = :contact3.Id
                LIMIT 1
        ]);
        System.assert(String.isEmpty(contact3.Formatted_phones__c));
        System.assertEquals('1231232244', contact3.Formatted_phones_additional__c);
        contact4 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Contact
                WHERE Id = :contact4.Id
                LIMIT 1
        ]);
        System.assert(String.isEmpty(contact4.Formatted_phones_additional__c));
        System.assert(String.isEmpty(contact4.Formatted_phones__c));
    }

    @isTest
    private static void testCreateContactRoleInOpportunities(){
        String recordTypeAcc = GlobalUtils.returnRecordTypeId('Account','Russian');
        Account testAccount = new Account(Name = 'testoppo1', RecordTypeId = recordTypeAcc, BillingCountry = 'Russia');
        insert testAccount;

        string Account = [SELECT Id, Name FROM Account WHERE Id =: testAccount.Id LIMIT 1].Id;

        String RecordTypeOpp = GlobalUtils.returnRecordTypeId('Opportunity','Russian Sales');
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'TESTOPPORTUNITIES';
        testOpportunity.AccountId = Account;
        testOpportunity.Number_of_Vehicles__c = 1;
        testOpportunity.StageName = 'Qualified Lead';
        testOpportunity.CloseDate = Date.newInstance(2018, 01, 15);
        testOpportunity.Most_Important_Feature__c = 'Reporting';
        testOpportunity.Area_Traveled__c = 'Regional';
        testOpportunity.The_region__c = 'г. Санкт-Петербург';
        testOpportunity.Travel_Pattern__c = 'Regular Route';
        testOpportunity.Primary_Fueling_Method__c = 'Coupons';
        testOpportunity.PPR_First_Contact_Inbound_Outbound__c = 'Inbound call';
        testOpportunity.Source_of_Lead_o__c = 'Выставка';
        testOpportunity.RecordTypeId = RecordTypeOpp;
        insert testOpportunity;

        String recordTypeCon = GlobalUtils.returnRecordTypeId('Contact','Russian');
        Contact testContact = new Contact(LastName='Chang', RecordTypeId = recordTypeCon, Salutation='Mr.', AccountId = Account);
        insert testContact;
        update testContact;

        List<OpportunityContactRole> rolesList = [SELECT OpportunityId FROM OpportunityContactRole WHERE OpportunityId =: testOpportunity.Id];
        System.assertEquals(1, rolesList.size());
    }

    /*******************************************************************************
    *  Name            : testsetFive9Phone()
    *  Summary         : Testing setFive9Phone() before update and before insert
    *  CreatedDate     : 01/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    private static void testsetFive9Phone() {
        List<Contact> contactsToInsertList = new List<Contact>();

        Contact contactGermany = new Contact(
            Phone = '0049 111 22 33',
            MobilePhone = '0112/33(0)2',
            Fax = '282245167',
            MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
            LastName = 'test',
            Salutation = 'Herr');
        contactsToInsertList.add(contactGermany);
        insert contactsToInsertList;

        Set<Id> idsToTest = new Set<Id>();
        for (Contact currentCon : contactsToInsertList) {
            idsToTest.add(currentCon.Id);
        }

        Map<Id, Contact> contactsToTestMap = new Map<Id, Contact>([
                SELECT Phone, MobilePhone, Fax, MailingCountry
                FROM Contact
                WHERE Id IN :idsToTest
                LIMIT 10000]);

        // Germany
        System.assertEquals('+491112233', contactsToTestMap.get(contactGermany.Id).Phone);
        System.assertEquals('+491123302', contactsToTestMap.get(contactGermany.Id).MobilePhone);
        System.assertEquals('+49282245167', contactsToTestMap.get(contactGermany.Id).Fax);
    }


    /*******************************************************************************
    *  Name            : preventUpdateOfInactiveContactsTest()
    *  Summary         : Test Preventing update if there is no active Opportunities related Contact
    *  CreatedDate     : 11/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    /*
    @isTest
    static void preventUpdateOfInactiveContactsTest() {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        Inactive_Records_Profiles__c profile = new Inactive_Records_Profiles__c(
            Name = profileName);
        insert profile;

        String contactRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Contact layout' AND SObjectType = 'Contact' LIMIT 1].Id;

        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Germany');
        insert account;

        String opportunityRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SObjectType = 'Opportunity' LIMIT 1].Id;

        Contact contact = new Contact(
            LastName = 'test');
        insert contact;

        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            RecordTypeId = opportunityRecordTypeId,
            Name = 'test',
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-32));
        insert opportunity;

        Test.setCreatedDate(opportunity.Id, Date.today().addDays(-32));

        OpportunityContactRole contactRole = new OpportunityContactrole(
            ContactId = contact.Id,
            OpportunityId = opportunity.Id);
        insert contactRole;

        try {
            update contact;
        } catch (Exception e) {
            System.AssertEquals(true, e.getMessage().contains('You are not allowed to update Accounts linked to closed Opportunities. ' +
                'Please create a new open Opportunity or clone the existing one to be able to update related Contact record.'));
        }
    }
     */
}