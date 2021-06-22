@isTest
private class EnrollTargetIntoSalesCadenceTest{
    @TestSetup
    private static void setupData() {
        /*
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
        insert new List <Contact> {con1};

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
        insert new List <Opportunity> {opp1};

        OpportunityContactRole ocr1 = new OpportunityContactRole(
                OpportunityId = opp1.Id,
                ContactId = con1.Id,
                IsPrimary = true
        );
        insert new List <OpportunityContactRole> {ocr1};
        */
        String endkundeRecId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Endkunde').getRecordTypeId();

        Lead testLead = new Lead(
            Salutation = 'Herr',
            LastName = 'test lead',
            Company = 'test company',
            Status = 'Open',
            Anzahl_der_Fahrzeuge__c = 2,
            CountryCode = 'DE',
            Country = 'Germany',
            Street = 'test street',
            City = 'test city',
            Phone = '+7777777777',
            Email = 'test@test.com',
            RecordTypeId = endkundeRecId,
            Steuernummer__c = '0',
            Sec_Channel__c = 'JITB',
            Channel__c = 'Internet',
            LeadSource = 'Other',
            Branche_NACE__c = 'Manufacturing',
            Beschaeftigte__c = '5-9'

        );
        insert testLead;
        testLead.OwnerId = UserInfo.getUserId();
        update testLead;
        String response = '[ {"outputValues" : { }, "isSuccess" : true, "errors" : null, "actionName" : "assignTargetToSalesCadence" } ]';
        SingleRequestMock enrollTargeResultMock = new SingleRequestMock(200, null, response , null);
        Test.setMock(HttpCalloutMock.class, enrollTargeResultMock);

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true AND MasterLabel = 'Konvertierte Leads' LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
    }
    @IsTest
    private static void testEnrollContacts() {
        String targetId = [SELECT Id FROM Contact][0].Id;
        String salesCadenceName = 'Test Cadence';
        Test.startTest();
            String response = '[ {"outputValues" : { }, "isSuccess" : true, "errors" : null, "actionName" : "assignTargetToSalesCadence" } ]';
            SingleRequestMock enrollTargeResultMock = new SingleRequestMock(200, null, response , null);
            Test.setMock(HttpCalloutMock.class, enrollTargeResultMock);
            EnrollTargetIntoSalesCadence.enrollContacts(new List <Id> {targetId});            
        Test.stopTest();
    }
    @IsTest
    private static void testSendRequest() {
        String targetId = [SELECT Id FROM Contact][0].Id;
        String salesCadenceName = 'Test Cadence';
        Test.startTest();
            String response = '[ {"outputValues" : { }, "isSuccess" : true, "errors" : null, "actionName" : "assignTargetToSalesCadence" } ]';
            SingleRequestMock enrollTargeResultMock = new SingleRequestMock(200, null, response , null);
            Test.setMock(HttpCalloutMock.class, enrollTargeResultMock);
            EnrollTargetIntoSalesCadence.sendRequest(new Map <String, String> {targetId => salesCadenceName});            
        Test.stopTest();
    }
    @IsTest
    private static void testSendRequest_Error() {
        String targetId = [SELECT Id FROM Contact][0].Id;
        String salesCadenceName = 'Test Cadence';
        Test.startTest();
            String response = '[ {"outputValues" : { }, "isSuccess" : false, "errors" : "not found", "actionName" : "assignTargetToSalesCadence" } ]';
            SingleRequestMock enrollTargeResultMock = new SingleRequestMock(404, null, response , null);
            Test.setMock(HttpCalloutMock.class, enrollTargeResultMock);
            EnrollTargetIntoSalesCadence.sendRequest(new Map <String, String> {targetId => salesCadenceName});            
        Test.stopTest();
    }
}