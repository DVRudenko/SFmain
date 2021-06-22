@IsTest
private class ETEDropOffBatchTest {

    @IsTest
    static void testDropOff() {
        Account acc = new Account(
                Name = 'Tet',
                BillingCountry = 'Poland'
        );
        insert acc;

        String dataobjectRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Object__c' AND DeveloperName = 'Poland' LIMIT 1].Id;
        E2E_Data_Object__c e2eData = new E2E_Data_Object__c(
                RecordTypeId = dataobjectRecordTypeId,
                Selected_Company_Name__c = 'Test Company mbH',
                Selected_Company_Id__c = '1645768',
                E2E_Status__c = 'In progress',
                Country_Code__c = 'pl',
                Vat_ID__c = 'PL9551247103',
                E2E_Last_Activity__c = System.now().addMinutes(-60)
        );
        insert e2eData;

        E2E_Data_Contact__c dataContact = new E2E_Data_Contact__c(
                Salutation__c = 'Mr.',
                First_Name__c = 'John',
                Last_Name__c = 'Johnson',
                Phone__c = '123123123',
                Email__c = 'test@test.com',
                Role__c = 'Decision Maker',
                isPrimary__c = true,
                E2E_Data_Object__c = e2eData.Id
        );
        insert dataContact;

        List<E2E_Data_Log__c> dataLogsToInsert = new List<E2E_Data_Log__c>();
        E2E_Data_Log__c exceptionDataLog = new E2E_Data_Log__c(
                Name = 'syncContactData',
                E2E_Data_Object__c = e2eData.Id,
                Exception_Type__c = 'System Error',
                Exception_Description__c = 'Company is not in the list'
        );
        dataLogsToInsert.add(exceptionDataLog);

        String recordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        E2E_Data_Log__c feedbackDataLog = new E2E_Data_Log__c(
                RecordTypeId = recordTypeId,
                Name = 'Customer Feedback',
                E2E_Data_Object__c = e2eData.Id,
                Rating__c = 50,
                Feedback_Local__c = 'Helló Világ!',
                Feedback_English__c = 'Hello World!'
        );
        dataLogsToInsert.add(feedbackDataLog);
        insert dataLogsToInsert;

        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                AccountId = acc.Id,
                E2E_Data_Object__c = e2eData.Id
        );
        insert opp;

        ETEUtilsTest.createE2EApiKeys('E2EFormPL');

        E2E_Form_General_Settings__c setting = new E2E_Form_General_Settings__c(
                Name = 'Poland',
                Abandonment_User__c = UserInfo.getUserId()
        );
        insert setting;

        Test.startTest();
            Database.executeBatch(new ETEDropOffBatch(), 1);
        Test.stopTest();

        E2E_Data_Object__c e2eDataTest = [
                SELECT E2E_Status__c
                FROM E2E_Data_Object__c
                WHERE Id = :e2eData.Id
        ];
        E2E_Data_Contact__c e2eContactTest = [SELECT Fleetcor_Contact__c FROM E2E_Data_Contact__c WHERE Id = :dataContact.Id LIMIT 1];
        Opportunity testOpp = [SELECT OwnerId, E2E_Status__c, (SELECT Id FROM Customer_Feedbacks__r) FROM Opportunity WHERE Id = :opp.Id];

        System.assert(e2eDataTest.E2E_Status__c == 'Drop off');
        System.assert(testOpp.E2E_Status__c == 'Drop off');
        System.assert(testOpp.OwnerId == UserInfo.getUserId());
        System.assert(e2eContactTest.Fleetcor_Contact__c != null);
        System.assertEquals(1, testOpp.Customer_Feedbacks__r.size());
    }


    @IsTest
    static void testDataCleanCase_1() {
        String dataobjectRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Object__c' AND DeveloperName = 'Poland' LIMIT 1].Id;
        E2E_Data_Object__c e2eData = new E2E_Data_Object__c(
                RecordTypeId = dataobjectRecordTypeId,
                Name = 'NEW E2E CUSTOMER',
                Selected_Company_Name__c = 'NEW E2E CUSTOMER',
                E2E_Status__c = 'In progress',
                Country_Code__c = 'pl',
                E2E_Last_Activity__c = System.now().addMinutes(-60)
        );
        insert e2eData;

        String recordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        E2E_Data_Log__c feedbackDataLog = new E2E_Data_Log__c(
                RecordTypeId = recordTypeId,
                Name = 'Customer Feedback',
                E2E_Data_Object__c = e2eData.Id,
                Rating__c = 50,
                Feedback_Local__c = 'Helló Világ!',
                Feedback_English__c = 'Hello World!'
        );
        insert feedbackDataLog;

        ETEUtilsTest.createE2EApiKeys('E2EFormPL');

        E2E_Form_General_Settings__c setting = new E2E_Form_General_Settings__c(
                Name = 'Poland',
                Abandonment_User__c = UserInfo.getUserId()
        );
        insert setting;

        Test.startTest();
            Database.executeBatch(new ETEDropOffBatch(), 1);
        Test.stopTest();

        System.assert([SELECT Id FROM E2E_Data_Object__c].size() == 0);
        System.assert([SELECT Id FROM Customer_Feedback__c].size() == 1);
    }


    @IsTest
    static void testDataCleanCase_2() {
        String dataobjectRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Object__c' AND DeveloperName = 'Poland' LIMIT 1].Id;
        E2E_Data_Object__c e2eData = new E2E_Data_Object__c(
                RecordTypeId = dataobjectRecordTypeId,
                E2E_Status__c = 'In progress',
                E2E_Last_Activity__c = System.now().addMinutes(-60),
                Country_Code__c = 'pl'
        );
        insert e2eData;

        String recordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        E2E_Data_Log__c feedbackDataLog = new E2E_Data_Log__c(
                RecordTypeId = recordTypeId,
                Name = 'Customer Feedback',
                E2E_Data_Object__c = e2eData.Id,
                Rating__c = 50,
                Feedback_Local__c = 'Helló Világ!',
                Feedback_English__c = 'Hello World!'
        );
        insert feedbackDataLog;

        insert new E2E_Data_Offer_Item__c(
                E2E_Data_Object__c = e2eData.Id
        );

        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp',
                E2E_Data_Object__c = e2eData.Id
        );
        insert opp;

        Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                IsActive = true,
                Integration_Name__c = 'test'
        );
        insert prod;

        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
        );
        insert pbEntry;

        OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;

        Offer_Item__c offer = new Offer_Item__c(
                Opportunity_Product_Id__c = oli.Id
        );
        insert offer;

        Test.startTest();
        {
            Database.executeBatch(new ETEDropOffBatch(), 1);
        }
        Test.stopTest();

        System.assert([SELECT Id FROM E2E_Data_Object__c].size() == 0);
        System.assert([SELECT Id FROM Opportunity].size() == 0);
        System.assert([SELECT Id FROM Customer_Feedback__c].size() == 1);
        System.assert([SELECT Id FROM OpportunityLineItem].size() == 0);
        System.assert([SELECT Id FROM Offer_Item__c].size() == 0);
        System.assert([SELECT Id FROM E2E_Data_Log__c].size() == 0);
        System.assert([SELECT Id FROM E2E_Data_Offer_Item__c].size() == 0);
    }
}