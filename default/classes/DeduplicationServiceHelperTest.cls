@IsTest
public with sharing class DeduplicationServiceHelperTest {
    @IsTest
    public static void exculeContactsFromListTest_NullOrEmptyLists() {
        List<Contact> sourceList = null;
        List<Contact> exclusionList = null;
        List<Contact> resultList = DeduplicationServiceHelper.exculeObjectsFromList(sourceList, exclusionList);
        System.assertEquals(null, resultList);
        sourceList = new List<Contact>();
        exclusionList = new List<Contact>();
        resultList = DeduplicationServiceHelper.exculeObjectsFromList(sourceList, exclusionList);
        System.assertEquals(new List<Contact>(), resultList);
    }

    @IsTest
    public static void exculeContactsFromListTest_WithObjectsLists() {
        List<Contact> sourceList = new List<Contact>();
        List<Contact> exclusionList = new List<Contact>();
        List<Contact> resultList = new List<Contact>();
        Map<String, Schema.RecordTypeInfo> contactRecordTypes = Contact.SObjectType.getDescribe().getRecordTypeInfosByName();
        Id russianRecordTypeId = contactRecordTypes.get('Russian').getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        Contact cont = new Contact(
            LastName = 'testcontact12345',
            Phone = '+71234567891',
            Email = 'Email12345678910@gggmail.ru',
            RecordTypeId = russianRecordTypeId
        );
        contacts.add(cont);
        Contact cont2 = cont.clone();
        contacts.add(cont2);
        insert contacts;

        exclusionList.add(cont);
        resultList = DeduplicationServiceHelper.exculeObjectsFromList(sourceList, exclusionList);
        System.assertEquals(new List<Contact>(), resultList);

        sourceList.add(cont);
        resultList = DeduplicationServiceHelper.exculeObjectsFromList(sourceList, exclusionList);
        System.assertEquals(new List<Contact>(), resultList);

        sourceList.addAll(contacts);
        resultList = DeduplicationServiceHelper.exculeObjectsFromList(sourceList, exclusionList);
        System.assertEquals(1, resultList.size());
        System.assertEquals(cont2.Id, resultList.get(0).Id);
    }

    @IsTest
    private static void matchAdditionalEmailsTest() {
        String email = 'test@test.ru';
        String phone = '1112223344';
        List<Contact> contacts = new List<Contact>{
            new Contact(Email = 'test@test.ru', Additional_Emails__c = 'test423@tsd.ds:fsdf@sdfgg.gf'),
            new Contact(Email = 'dfg@fd.fd', Additional_Emails__c = 'test423@tsd.ds:test@test.ru'),
            new Contact(Email = 'fsdf@fdf.fd', Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf'),
            new Contact(Email = 'test@test.ru', Additional_Emails__c = 'test@test.ru:fsdf@sdfgg.gf'),
            new Contact(
                Email = 'fsdf@fdf.fd',
                Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf',
                Formatted_phones__c = '1112223344',
                Formatted_phones_additional__c = ''
            ),
            new Contact(
                Email = 'fsdf@fdf.fd',
                Additional_Emails__c = 'testtest@test.ru:fsdf@sdfgg.gf',
                Formatted_phones__c = '1112223344',
                Formatted_phones_additional__c = '1112223344'
            ),
            new Contact(
                Email = 'fsdf@fdf.fd',
                Additional_Emails__c = 'test@tedsdst.ru:fsdf@sdfgg.gf',
                Formatted_phones__c = '',
                Formatted_phones_additional__c = '1112223344'
            )
        };
        System.assertEquals(3, DeduplicationServiceHelper.matchAdditionalEmails(contacts, email).size());
    }

    @isTest
    public static void testChekingOwnerForOpportunities() {
        DeduplicationServiceTestDataFactory testFactory = new DeduplicationServiceTestDataFactory();
        User owner = testFactory.createUser();
        insert owner;
        User currUser = testFactory.createAdminUser();
        insert currUser;

        System.runAs(owner) {
            Account account = testFactory.createAccount('111111111');
            insert account;

            Opportunity opportunity = testFactory.createOpportunity('TEST1', account.Id, 'Договор на проверке', date.today(), owner);
            Opportunity opportunityOtherOwner = testFactory.createOpportunity('TEST2', account.Id, 'Договор на проверке', date.today(), currUser);
            insert new List<Opportunity>{ opportunity, opportunityOtherOwner };
            List<Opportunity> foundOpportunities = new List<Opportunity>();
            foundOpportunities.add(opportunity);

            Boolean isDifferentOwnerFoundForOpportunities = DeduplicationServiceHelper.checkingOwnerForOpportunities(foundOpportunities, opportunity);
            System.assertEquals(false, isDifferentOwnerFoundForOpportunities);

            isDifferentOwnerFoundForOpportunities = DeduplicationServiceHelper.checkingOwnerForOpportunities(
                foundOpportunities,
                opportunityOtherOwner
            );
            System.assertEquals(true, isDifferentOwnerFoundForOpportunities);
        }
    }
}