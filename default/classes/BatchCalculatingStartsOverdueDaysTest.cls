@isTest
private class BatchCalculatingStartsOverdueDaysTest {
	public static Account newAccount;
	public static Opportunity newOpportunity;

    static testMethod void calculatingStartsOverdueDaysTest() {
        createAccount();
        createOpportunity();

        Test.startTest();
	        BatchCalculatingStartsOverdueDays batch = new BatchCalculatingStartsOverdueDays();
	    	Database.executeBatch(batch);
    	Test.stopTest();
    }

    private static void createAccount() {
        newAccount = new Account(
            Name = 'test',
            GFN_Nr__c  = '123',
            Type = 'Customer',
            Bundesland__c = 'Germany',
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
            Kraftstoffverbrauch_Liter_Monat__c = 2
        );
        insert newAccount;
    }

    private static void createOpportunity() {
        newOpportunity = new Opportunity(
            AccountId = newAccount.Id,
            Name = 'test opportunity',
            Starts_Status__c = '0. Request received',
            Starts_Schedule__c = Date.today().addDays(-1),
            Starts_Overdue_days__c = 0,
            Starts_Status_Delay__c = false,
            Anzahl_der_Karten__c = 123,
            Zahlungsart__c = 'Lastschrift',
            Name_of_the_payer_Account_holder__c = 'test payer',
            Angebotsdauer__c = 'test',
            Language_preference__c = 'Polish',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = '123test',
            IBAN__c = '23424',
            SWIFT_BIC__c = '23423',
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(-50),
            Bevollmaechtigung__c = true
        );
        insert newOpportunity;
 	}   
}