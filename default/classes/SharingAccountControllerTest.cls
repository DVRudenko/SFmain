@isTest
public class SharingAccountControllerTest {
    public static Account newAccount;

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

        AccountHistory createHistory = new AccountHistory(
                AccountId = newAccount.Id,
                Field = 'created'
        );
        insert createHistory;

        AccountHistory convertHistory = new AccountHistory(
                AccountId = newAccount.Id,
                Field = 'accountCreatedFromLead'
        );
        insert convertHistory;
    }

    @isTest
    public static void hostoryTest() {
        init();

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
            SharingAccountController sharingAccountController = new SharingAccountController(sc);
        Test.stopTest();

        System.assert(sharingAccountController.account != null);
        System.assert(sharingAccountController.accountHistory.size() == 2);
    }
}