@IsTest
public class ContactScoreHandlerTest {
    @TestSetup
    public static void createTestData() {
        String euroshellOppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Euroshell').getRecordTypeId();
        
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
                Email = 'test1@test.com',
                Opportunity_Scoring__c = 20);
        Contact con2 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST2',
                AccountId = acc.Id,
                Email = 'test2@test.com',
                Opportunity_Scoring__c = null);        
        Contact con3 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST3',
                AccountId = acc.Id,
                Email = 'test3@test.com',
                Opportunity_Scoring__c = 20);
        Contact con4 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST4',
                AccountId = acc.Id,
                Email = 'test4@test.com',
                Opportunity_Scoring__c = 20);
        Contact con5 = new Contact(
                Salutation = 'Herr',
                LastName = 'TEST5',
                AccountId = acc.Id,
                Email = 'test5@test.com',
                Opportunity_Scoring__c = 20);        
        insert new List <Contact> {con1, con2, con3, con4, con5};

        Opportunity opp1_withContacts = new Opportunity(
                Name = 'TEST1',
                RecordTypeId = euroshellOppRecId,
                AccountId = acc.id,
                Primary_Contact__c = con1.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Form_of_Payment__c = 'Bank Transfer - after delivery',
                Monthly_Payment_Method__c = 'Bank transfer',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required'
        );
        Opportunity opp2_withContacts = new Opportunity(
                Name = 'TEST2',
                Product__c = 'Carnet Standard 2019',
                RecordTypeId = euroshellOppRecId,
                AccountId = acc.id,
                Primary_Contact__c = con3.Id,
                CloseDate = Date.today(),
                StageName = 'Qualify',
                Type = 'New GFN',
                Form_of_Payment__c = 'Bank Transfer - after delivery',
                Monthly_Payment_Method__c = 'Bank transfer',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required'
        );
        Opportunity opp3_noContacts = new Opportunity(
                Name = 'TEST3',
                RecordTypeId = euroshellOppRecId,
                AccountId = acc.id,
                CloseDate = Date.today(),
                StageName = 'Prospecting'
        );
        insert new List <Opportunity> {opp1_withContacts, opp2_withContacts, opp3_noContacts};

        OpportunityContactRole ocr1 = new OpportunityContactRole(
                OpportunityId = opp1_withContacts.Id,
                ContactId = con1.Id,
                IsPrimary = true
        );
        OpportunityContactRole ocr2 = new OpportunityContactRole(
                OpportunityId = opp1_withContacts.Id,
                ContactId = con2.Id,
                IsPrimary = false
        );
        OpportunityContactRole ocr3 = new OpportunityContactRole(
                OpportunityId = opp2_withContacts.Id,
                ContactId = con3.Id,
                IsPrimary = false
        );
        OpportunityContactRole ocr4 = new OpportunityContactRole(
                OpportunityId = opp2_withContacts.Id,
                ContactId = con4.Id,
                IsPrimary = false
        );
        OpportunityContactRole ocr5 = new OpportunityContactRole(
                OpportunityId = opp2_withContacts.Id,
                ContactId = con5.Id,
                IsPrimary = false
        );
        insert new List <OpportunityContactRole> {ocr1, ocr2, ocr3, ocr4, ocr5};
    }

    @IsTest
    static void testSetOpportunityScoreOnContacts_OppsList_case1() {
        // run test for all oppties
        Map <Id,Opportunity> oppsMap = new Map <Id,Opportunity> ([SELECT Id FROM Opportunity]);

        Test.startTest();   
            // -------- Test case 1: --- a few opps with contact roles and without; score to set: 25 (the highest score from all open oppties)
            ContactScoreHandler.theHighestScoreForTesting = 25;
            Map <Id, Contact> contactsWithNewScores = ContactScoreHandler.setOpportunityScoreOnContacts_OppsList(oppsMap.keySet());
            system.debug('11' + oppsMap);
            system.debug('22' + contactsWithNewScores);

            Integer allContactsNumber = [SELECT count() FROM OpportunityContactRole];
            system.assertEquals (allContactsNumber, contactsWithNewScores.size()); // for all contacts should be set a new value
            
            for (Contact con : contactsWithNewScores.values()) {
                system.assertEquals(25, con.Opportunity_Scoring__c);
            }
        Test.stopTest();
    }
    @IsTest
    static void testSetOpportunityScoreOnContacts_OppsList_case2() {
        // run test for oppty without related contacts
        Map <Id,Opportunity> oppsMap = new Map <Id,Opportunity> ([SELECT Id FROM Opportunity WHERE Name = 'TEST3']);

        Test.startTest();   
            // -------- Test case 2: --- No contact roles related to the opportunity; no score to set ---
            ContactScoreHandler.theHighestScoreForTesting = null;
            Map <Id, Contact> contactsWithNewScores = ContactScoreHandler.setOpportunityScoreOnContacts_OppsList(oppsMap.keySet());
            system.assert(contactsWithNewScores.isEmpty()); // no contacts to update
        Test.stopTest();
    }
    @IsTest
    static void testSetOpportunityScoreOnContacts_ContactRoles_case1() {
        // run test for contact which already has score value = 20
        OpportunityContactRole ocr = [SELECT ContactId, Contact.Opportunity_Scoring__c 
                                      FROM OpportunityContactRole 
                                      WHERE Opportunity.Name = 'TEST1' 
                                      AND Contact.Opportunity_Scoring__c = 20][0];
        Map <Id, Integer> oppContactRolesMap = new Map <Id, Integer> {ocr.ContactId => (Integer)ocr.Contact.Opportunity_Scoring__c};

        Test.startTest();
            // -------- Test case 1: --- score to set: 50 (the highest score from all open oppties) ---
            // current scoring on the contact: 20
            ContactScoreHandler.theHighestScoreForTesting =  50;
            Map <Id, Contact> contactsWithNewScores = ContactScoreHandler.setOpportunityScoreOnContacts_ContactRoles(oppContactRolesMap);
            system.assertEquals(50, contactsWithNewScores.values()[0].Opportunity_Scoring__c); // new value is set
        Test.stopTest();
    }
    @IsTest
    static void testSetOpportunityScoreOnContacts_ContactRoles_case2() {
        // run test for contact which already has score value = 20
        OpportunityContactRole ocr = [SELECT ContactId, Contact.Opportunity_Scoring__c
                                      FROM OpportunityContactRole 
                                      WHERE Opportunity.Name = 'TEST1'
                                      AND Contact.Opportunity_Scoring__c = 20][0];
        Map <Id, Integer> oppContactRolesMap = new Map <Id, Integer> {ocr.ContactId => (Integer)ocr.Contact.Opportunity_Scoring__c};
        
        Test.startTest();
            // -------- Test case 2: --- no score to set;  ---
            // current scoring on the contact: 20
            ContactScoreHandler.theHighestScoreForTesting =  null;
            Map <Id, Contact> contactsWithNewScores = ContactScoreHandler.setOpportunityScoreOnContacts_ContactRoles(oppContactRolesMap);
            system.assert(contactsWithNewScores.isEmpty()); // contact will stay with its score value = 20
        Test.stopTest();
    }
    @IsTest
    static void testSetOpportunityScoreOnContacts_ContactRoles_case3() {
        // run test for contact which doesn't have a score value
        OpportunityContactRole ocr = [SELECT ContactId, Contact.Opportunity_Scoring__c
                                      FROM OpportunityContactRole 
                                      WHERE Opportunity.Name = 'TEST1' 
                                      AND Contact.Opportunity_Scoring__c = null][0];
        Map <Id, Integer> currentContactScoresMap = new Map <Id, Integer> {ocr.ContactId => (Integer)ocr.Contact.Opportunity_Scoring__c};
        
        Test.startTest();
            // -------- Test case 3: --- score to set: 23 (the highest score from all open oppties)
            // current scoring on the contact: null
            ContactScoreHandler.theHighestScoreForTesting =  23;
            Map <Id, Contact> contactsWithNewScores = ContactScoreHandler.setOpportunityScoreOnContacts_ContactRoles(currentContactScoresMap);
            system.assertEquals(23, contactsWithNewScores.values()[0].Opportunity_Scoring__c);
        Test.stopTest();
    }
    @IsTest
    static void testSetOpportunityScoreOnContacts_ContactRoles_case4() {
        // run test for contact which doesn't have a score value
        OpportunityContactRole ocr = [SELECT ContactId, Contact.Opportunity_Scoring__c
                                      FROM OpportunityContactRole 
                                      WHERE Opportunity.Name = 'TEST1' 
                                      AND Contact.Opportunity_Scoring__c = null][0];
        Map <Id, Integer> currentContactScoresMap = new Map <Id, Integer> {ocr.ContactId => (Integer)ocr.Contact.Opportunity_Scoring__c};
        
        Test.startTest();
            // -------- Test case 4: --- no new score; 
            // current scoring on the contact: null
            ContactScoreHandler.theHighestScoreForTesting =  null;
            Map <Id, Contact> contactsWithNewScores = ContactScoreHandler.setOpportunityScoreOnContacts_ContactRoles(currentContactScoresMap);
            system.assert(contactsWithNewScores.isEmpty()); // no contacts to update
        Test.stopTest();
    }
}