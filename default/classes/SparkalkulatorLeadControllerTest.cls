@isTest
private class SparkalkulatorLeadControllerTest {
    @isTest
    private static void testSTD1() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		Lead lead = new Lead(
			Anzahl_der_Fahrzeuge__c = 200,
			Monatlicher_Kraftstoffverbrauch_in_Liter__c = 100,
			Angebotsdauer_in_Monate__c = '3',
			Aktuelle_Zahlungsmethode__c = 'Barzahlung',
			Company = 'test',
			Zahlungsart__c = 'Banküberweisung',
			Country = 'Germany',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		SparkalkulatorLeadController sic = new SparkalkulatorLeadController(sc);
    }    

    @isTest
    private static void testSTD2() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		Lead lead = new Lead(
			Anzahl_der_Fahrzeuge__c = 200,
			Monatlicher_Kraftstoffverbrauch_in_Liter__c = 100,
			Angebotsdauer_in_Monate__c = '3',
			Aktuelle_Zahlungsmethode__c = 'Barzahlung',
			Company = 'test',
			Zahlungsart__c = 'Lastschrift',
			Country = 'Germany',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		SparkalkulatorLeadController sic = new SparkalkulatorLeadController(sc);
    } 
}