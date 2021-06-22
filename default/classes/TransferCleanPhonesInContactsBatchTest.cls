@IsTest
private class TransferCleanPhonesInContactsBatchTest {

    private static final Id RU_CONTACT_RECORD_TYPE = ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId();
    private static final Id RU_ACCOUNT_RECORD_TYPE = GlobalUtils.getRecordTypeId(Account.class.getName(), 'Russian');
    private static final String DELIMITER = PhoneNumberUtils.PHONE_NUMBER_DELIMITER;

    @IsTest
    static void testBehavior() {
        Account account = new Account(
                Name = 'test',
                RecordTypeId = RU_ACCOUNT_RECORD_TYPE
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
        ContactTriggerHandler.enablesTrigger = false;
        insert contacts;
        Test.startTest();
        Database.executeBatch(new TransferCleanPhonesInContactsBatch());
        Test.stopTest();

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
        System.assertEquals('1231232244', contact3.Formatted_phones_additional__c);
        System.assert(String.isEmpty(contact3.Formatted_phones__c));
        contact4 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Contact
                WHERE Id = :contact4.Id
                LIMIT 1
        ]);
        System.assert(String.isEmpty(contact4.Formatted_phones__c));
        System.assert(String.isEmpty(contact2.Formatted_phones_additional__c));
    }

}