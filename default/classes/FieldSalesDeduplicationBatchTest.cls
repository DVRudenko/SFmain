@IsTest
private class FieldSalesDeduplicationBatchTest {

    @isTest
    static void testBatchMethod() {
        createCustomSettings();
        String recordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity' LIMIT 1].id;
        String recordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account' LIMIT 1].id;
        String recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Lead' LIMIT 1].id;

        Lead lead1 = new Lead(LastName = 'test', Company = 'test', Country = 'Russia', Email = 'test@test.com', RecordTypeId = recordTypeLead, Status = 'Open', Inn__c = '1234567890');
        insert lead1;

        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 50,
                INN__C = '1234567890', RecordTypeId = recordTypeAcc);
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),
                AccountId = account.id, RecordTypeId = recordTypeOpp);
        insert opportunity;

        Test.startTest();
        Database.executeBatch(new FieldSalesDeduplicationBatch(null));
        Test.stopTest();
    }

    @isTest
    static void testBatchMethod2() {
        String recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Lead' LIMIT 1].id;

        Lead lead2 = new Lead(LastName = 'test2', Company = 'test2', Country = 'Russia', Email = 'test@test.com', RecordTypeId = recordTypeLead, Status = 'Open', Inn__c = '1234567891');
        insert lead2;

        Lead lead3 = new Lead(LastName = 'test3', Company = 'test3', Country = 'Russia', Email = 'test@test.com', RecordTypeId = recordTypeLead, Status = 'Open', Inn__c = '1234567891');
        insert lead3;

        Test.startTest();
        Database.executeBatch(new FieldSalesDeduplicationBatch(1));
        Test.stopTest();
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}