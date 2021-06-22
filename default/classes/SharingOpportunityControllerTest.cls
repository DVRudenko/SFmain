@isTest
public class SharingOpportunityControllerTest {
    public static Opportunity newOpp;
    public static Account newAccount;
    public static Contact newContact;

    public static void init() {
        newAccount = new Account(
                Name = 'test',
                GFN_Nr__c = '123',
                Type = 'Customer',
                Bundesland__c = 'Germany',
                BillingStreet = 'test street',
                BillingPostalCode = '1231',
                BillingCity = 'Berlin',
                BillingCountry = 'Germany',
                Beschaeftigte__c = '1-4',
                Strasse_E__c = 'test',
                Hausnummer_E__c = 'test',
                PLZ_E__c = 'test',
                Ort_E__c = 'tet',
                Land_E__c = 'DE',
                Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'tes',
                PLZ_und_Ort__c = 'test',
                IBAN_des_Zahlungspflichtigen__c = 'tes',
                SWIFT_BIC__c = 'test',
                Land__c = 'test land',
                Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
                Kraftstoffverbrauch_Liter_Monat__c = 2);
        insert newAccount;

        newOpp = new Opportunity(
                AccountId = newAccount.Id,
                Kraftstoffverbrauch_Liter_Monat__c = 2,
                Sec_Channel__c = 'Inbound',
                Anzahl_der_Karten__c = 5,
                Gruende_verloren__c = 'test',
                Derzeitige_Zahlungsmethode__c = 'Bank',
                Total_consumption_l_month__c = 123,
                Name_of_the_payer_Account_holder__c = 'test',
                Last_Owner_Change_Date__c = Date.today(),
                Number_of_Vehicles__c = 123,
                Angebotsdauer__c = '3 Monate',
                IBAN__c = '2131',
                SWIFT_BIC__c = '1234124',
                Kundensegment__c = 'Campaign_1',
                Zahlungsart__c = 'Lastschrift',
                Zahlungsziel__c = '7',
                StageName = 'Prospecting',
                Product__c = 'None',
                Name = 'test opp',
                Disable_for_KPI__c = FALSE,
                CloseDate = Date.today());
        insert newOpp;

        newContact = new Contact(
                Salutation = 'Herr',
                FirstName = 'Bob',
                LastName = 'Test',
                Email = 'test@test.com',
                MailingCountry = 'Germany',
                MailingStreet = '298 S. Ringo Street',
                MailingCity = 'Little Rock',
                MailingState = 'Berlin',
                MailingPostalCode = '72201'
        );
        insert newContact;

        OpportunityFieldHistory createHistory = new OpportunityFieldHistory(
                OpportunityId = newOpp.Id,
                Field = 'created'
        );
        insert createHistory;

        OpportunityFieldHistory convertHistory = new OpportunityFieldHistory(
                OpportunityId = newOpp.Id,
                Field = 'opportunityCreatedFromLead'
        );
        insert convertHistory;
    }

    @isTest
    public static void historyTest() {
        init();

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
        SharingOpportunityController sharingOpportunityController = new SharingOpportunityController(sc);
        Test.stopTest();

        System.assert(sharingOpportunityController.opportunity != null);
        System.assert(sharingOpportunityController.opportunityHistory.size() == 2);
    }

}