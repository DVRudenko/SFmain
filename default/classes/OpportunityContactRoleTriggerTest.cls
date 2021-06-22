@IsTest
private class OpportunityContactRoleTriggerTest {
    @TestSetup
    static void createTestData() {
        String carnetOppoRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Carnet').getRecordTypeId();
    
        Account acc = new Account(
                Name = 'TEST',
                BillingCountry = 'Poland',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
        insert acc;

        Contact con1 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST1',
                AccountId = acc.Id,
                Email = 'test@test.com');
        Contact con2 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST2',
                AccountId = acc.Id,
                Email = 'test@test.com',
                Opportunity_Scoring__c = 20);
        Contact con3 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST3',
                AccountId = acc.Id,
                Email = 'test@test.com');
        Contact con4 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST4',
                AccountId = acc.Id,
                Email = 'test@test.com');
        Contact con5 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST5',
                AccountId = acc.Id,
                Email = 'test@test.com');
        insert new List <Contact> {con1, con2, con3, con4, con5};

        Opportunity opp1 = new Opportunity(
            Name = 'TEST1',
            Product__c = 'Carnet Standard 2019',
            RecordTypeId = carnetOppoRecId,
            AccountId = acc.id,
            CloseDate = Date.today(),
            StageName = 'Qualify',
            Type = 'New GFN',
            Form_of_Payment__c = 'Bank Transfer - after delivery',
            Monthly_Payment_Method__c = 'Bank transfer',
            Number_of_GPS_units__c = 3,
            Pricing_Approval_Status__c = 'Not required');
        Opportunity opp2 = new Opportunity(
                Name = 'TEST2',
                Product__c = 'Carnet Standard 2019',
                RecordTypeId = carnetOppoRecId,
                AccountId = acc.id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Form_of_Payment__c = 'Bank Transfer - after delivery',
                Monthly_Payment_Method__c = 'Bank transfer',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert new List <Opportunity> {opp1, opp2};
    }

    @IsTest
    static void testSetOpportunityScoreOnContacts_OneOpptyScored() {
        // -------- Test case 1: --- one oppty only, scored, scoring is not set on contact yet ---
        // current scoring on the contact: null
        // existing open oppties the highest score: 33
        // score to set: 33 (the highest score from all open oppties)
        Map <String, opportunity> oppsByNameMap = new Map <String, Opportunity>();
        List <Opportunity> testOpps = [SELECT Id, Name FROM Opportunity];
        for (Opportunity opp: testOpps) {
            oppsByNameMap.put(opp.Name, opp);
        }
        Contact testCon = [SELECT Opportunity_Scoring__c from Contact WHERE LastName = 'TEST1'];

        OpportunityContactRole ocr_existingOpp = new OpportunityContactRole(
            OpportunityId = oppsByNameMap.get('TEST1').Id,
            ContactId = testCon.Id,
            IsPrimary = true
        );
        insert ocr_existingOpp; // add 1 existing open opportunity related to a contact

        ContactScoreHandler.theHighestScoreForTesting =  33;

        Test.startTest();
            OpportunityContactRole ocr = new OpportunityContactRole(
                OpportunityId = oppsByNameMap.get('TEST2').Id,
                ContactId = testCon.Id,
                IsPrimary = true
            );
            insert ocr; // add second opportunity related to a contact

            Contact updatedCon = [SELECT Opportunity_Scoring__c from Contact WHERE Id = :testCon.Id];
            system.assertEquals(33, updatedCon.Opportunity_Scoring__c);
        Test.stopTest();
    }

    @IsTest
    static void testSetOpportunityScoreOnContacts_OpptyScoredAndContactScored() {
        // -------- Test case 2: --- one oppty only, scored, contact scoring is set ---
        // current scoring on the contact: 20
        // existing open oppties the highest score: 15
        // score to set: 15 (the highest score from all open oppties)

        Map <String, opportunity> oppsByNameMap = new Map <String, Opportunity>();
        List <Opportunity> testOpps = [SELECT Id, Name FROM Opportunity];
        for (Opportunity opp: testOpps) {
            oppsByNameMap.put(opp.Name, opp);
        }
        Contact testCon = [SELECT Opportunity_Scoring__c from Contact WHERE LastName = 'TEST2'];

        OpportunityContactRole ocr_existingOpp = new OpportunityContactRole(
            OpportunityId = oppsByNameMap.get('TEST1').Id,
            ContactId = testCon.Id,
            IsPrimary = true
        );
        insert ocr_existingOpp; // add 1 existing open opportunity related to a contact

        ContactScoreHandler.theHighestScoreForTesting =  15;

        Test.startTest();
            OpportunityContactRole ocr = new OpportunityContactRole(
                OpportunityId = oppsByNameMap.get('TEST2').Id,
                ContactId = testCon.Id,
                IsPrimary = true
            );
            insert ocr;

            Contact updatedCon = [SELECT Opportunity_Scoring__c from Contact WHERE Id = :testCon.Id];
            system.assertEquals(15, updatedCon.Opportunity_Scoring__c);
        Test.stopTest();
    }

    @IsTest
    static void testSetOpportunityScoreOnContacts_OpptyNotScored() {
        // -------- Test case 3: --- oppty not scored ---
        // current scoring on the contact: null
        // existing open oppties the highest score: null
        // score to set: none

        Opportunity testOpp = [SELECT Id from Opportunity WHERE Name = 'TEST1'];
        Contact testCon = [SELECT Opportunity_Scoring__c from Contact WHERE LastName = 'TEST3'];
        ContactScoreHandler.theHighestScoreForTesting = null;

        Test.startTest();
            OpportunityContactRole ocr = new OpportunityContactRole(
                OpportunityId = testOpp.Id,
                ContactId = testCon.Id,
                IsPrimary = true
            );
            insert ocr;

            Contact updatedCon = [SELECT Opportunity_Scoring__c from Contact WHERE Id = :testCon.Id];
            system.assertEquals(null, updatedCon.Opportunity_Scoring__c);
        Test.stopTest();
    }
    
    @IsTest
    static void testSetOpportunityScoreOnContacts_FewContacts() {
        // -------- Test case 4: --- a few contacts added, one oppty scored ---
        // current scoring on the contact: null
        // existing open oppties the highest score: 30
        // score to set: 30

        Map <String, opportunity> oppsByNameMap = new Map <String, Opportunity>();
        List <Opportunity> testOpps = [SELECT Id, Name FROM Opportunity];
        for (Opportunity opp: testOpps) {
            oppsByNameMap.put(opp.Name, opp);
        }
        Map <Id, Contact> testConsMap = new Map <Id, Contact>([SELECT Id, Opportunity_Scoring__c from Contact WHERE LastName IN ('TEST4', 'TEST5')]);
        
        OpportunityContactRole ocr_existingOpp1 = new OpportunityContactRole(
            OpportunityId = oppsByNameMap.get('TEST1').Id,
            ContactId = testConsMap.values()[0].Id,
            IsPrimary = true
        );
        OpportunityContactRole ocr_existingOpp2 = new OpportunityContactRole(
            OpportunityId = oppsByNameMap.get('TEST1').Id,
            ContactId = testConsMap.values()[1].Id,
            IsPrimary = true
        );
        insert new List <OpportunityContactRole> {ocr_existingOpp1, ocr_existingOpp2}; // add 2 existing open opportunity related to a contact
        
        
        ContactScoreHandler.theHighestScoreForTesting = 30;

        Test.startTest();
            OpportunityContactRole ocr1 = new OpportunityContactRole(
                OpportunityId = oppsByNameMap.get('TEST2').Id,
                ContactId = testConsMap.values()[0].Id,
                IsPrimary = true
            );
            OpportunityContactRole ocr2 = new OpportunityContactRole(
                OpportunityId = oppsByNameMap.get('TEST2').Id,
                ContactId = testConsMap.values()[1].Id,
                IsPrimary = true
            );
            insert new List <OpportunityContactRole> {ocr1, ocr2};

            Map <Id, Contact> updatedConsMap = new Map <Id, Contact> ([SELECT Opportunity_Scoring__c from Contact WHERE Id IN :testConsMap.keyset()]);
            system.assertEquals(30, updatedConsMap.get(ocr1.ContactId).Opportunity_Scoring__c);
            system.assertEquals(30, updatedConsMap.get(ocr2.ContactId).Opportunity_Scoring__c);
        Test.stopTest();
    }
}