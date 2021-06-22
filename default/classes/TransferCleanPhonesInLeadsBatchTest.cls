@IsTest
private class TransferCleanPhonesInLeadsBatchTest {

    private static final Id RU_LEAD_RECORD_TYPE = LeadHandler.leadRecordTypes.get(GlobalUtils.LeadRecordTypes.Russian_Sales.name()).getRecordTypeId();
    private static final String DELIMITER = PhoneNumberUtils.PHONE_NUMBER_DELIMITER;

    @IsTest
    static void testBehavior() {
        Lead lead1 = new Lead(
                LastName = 'test 1',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+7 435 545 34 65#54',
                MobilePhone = '+7 999 54443 23',
                PPR_Contact_Phone__c = '+88005553535#23',
                Additional_Phones__c = '+434545445423.+79999992334#33'
        );
        Lead lead2 = new Lead(
                LastName = 'test 2',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '+8 8005553535#33',
                MobilePhone = '',
                PPR_Contact_Phone__c = '+1111 222 33 44',
                Additional_Phones__c = ''
        );
        Lead lead3 = new Lead(
                LastName = 'test 3',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                RecordTypeId = RU_LEAD_RECORD_TYPE,
                Phone = '',
                MobilePhone = '',
                PPR_Contact_Phone__c = '',
                Additional_Phones__c = '+125453435454#34.+85556664523'
        );
        Lead lead4 = new Lead(
                LastName = 'test 3',
                Source_of_Lead__c = 'E2E Form RU',
                Company = 'test acc',
                Sec_Channel__c = 'JITB',
                LeadSource = 'ABVP',
                Status = 'Open',
                RecordTypeId = LeadHandler.leadRecordTypes.get(GlobalUtils.LeadRecordTypes.Carnet.name()).getRecordTypeId(),
                Phone = '+8 800 555 35 35#23',
                Country = 'Russia'
        );
        List<Lead> leads = new List<Lead>{lead1, lead2, lead3, lead4};
        LeadHandler.enablesTrigger = false;
        insert leads;
        Test.startTest();
        Database.executeBatch(new TransferCleanPhonesInLeadsBatch());
        Test.stopTest();

        lead1 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Lead
                WHERE Id = :lead1.Id
                LIMIT 1
        ]);
        System.assertEquals(
                '4355453465' + DELIMITER + '9995444323' + DELIMITER + '8005553535',
                lead1.Formatted_phones__c
        );
        System.assertEquals('4545445423' + DELIMITER + '9999992334', lead1.Formatted_phones_additional__c);
        lead2 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Lead
                WHERE Id = :lead2.Id
                LIMIT 1
        ]);
        System.assertEquals('8005553535' + DELIMITER + '1112223344', lead2.Formatted_phones__c);
        System.assert(String.isEmpty(lead2.Formatted_phones_additional__c));
        lead3 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Lead
                WHERE Id = :lead3.Id
                LIMIT 1
        ]);
        System.assertEquals('5453435454' + DELIMITER + '5556664523', lead3.Formatted_phones_additional__c);
        System.assert(String.isEmpty(lead3.Formatted_phones__c));
        lead4 = ([
                SELECT Id, Formatted_phones__c, Formatted_phones_additional__c
                FROM Lead
                WHERE Id = :lead4.Id
                LIMIT 1
        ]);
        System.assert(String.isEmpty(lead4.Formatted_phones__c));
        System.assert(String.isEmpty(lead4.Formatted_phones_additional__c));
    }

}