@isTest
private class OpportunityScoreProcessTest {
    @TestSetup
    private static void setupData() {
        String euroshellOppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Euroshell').getRecordTypeId();
        String contactLayoutConRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId();

        Account acc = new Account(
            Name = 'TEST',
            BillingCountry = 'Poland',
            BillingCity = 'BERG',
            BillingStreet = 'LUDWIGSTRASSE 69');
        insert acc;

        Contact con1 = new Contact(
            RecordTypeId = contactLayoutConRecId,
            Salutation = 'Herr',
            LastName = 'TEST1',
            AccountId = acc.Id,
            Email = 'test1@test.com',
            Opportunity_Scoring__c = 20);
        Contact con2 = new Contact(
            RecordTypeId = contactLayoutConRecId,
            Salutation = 'Herr',
            LastName = 'TEST2',
            AccountId = acc.Id,
            Email = 'test2@test.com',
            Opportunity_Scoring__c = null);    
        Contact con3 = new Contact(
            RecordTypeId = contactLayoutConRecId,
            Salutation = 'Herr',
            LastName = 'TEST3',
            AccountId = acc.Id,
            Email = 'test3@test.com',
            Opportunity_Scoring__c = null);    
        insert new List <Contact> {con1, con2, con3};

        Opportunity opp1 = new Opportunity(
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
        Opportunity opp2 = new Opportunity(
            Name = 'TEST2',
            RecordTypeId = euroshellOppRecId,
            AccountId = acc.id,
            Primary_Contact__c = con1.Id,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        insert new List <Opportunity> {opp1, opp2};

        OpportunityContactRole ocr1 = new OpportunityContactRole(
                OpportunityId = opp1.Id,
                ContactId = con1.Id,
                IsPrimary = true
        );
        OpportunityContactRole ocr2 = new OpportunityContactRole(
                OpportunityId = opp1.Id,
                ContactId = con2.Id,
                IsPrimary = false
        );
        OpportunityContactRole ocr3 = new OpportunityContactRole(
                OpportunityId = opp2.Id,
                ContactId = con3.Id,
                IsPrimary = false
        );
        insert new List <OpportunityContactRole> {ocr1, ocr2, ocr3};
    }
    @IsTest
    private static void testSetScoreToRelatedcontacts() {
        List <Id> oppIds = new List <Id> ();
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        Test.startTest();
            ContactScoreHandler.theHighestScoreForTesting = 25;
            OpportunityScoreProcess.setScoreToRelatedcontacts(oppIds);
        Test.stopTest();
        List <Contact> contactsToCheck = [SELECT Id, LastName, Opportunity_Scoring__c FROM Contact];
        for (Contact con : contactsToCheck) {
            system.assertEquals(25, con.Opportunity_Scoring__c);
        }
    }
}
