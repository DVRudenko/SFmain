@isTest
private class SparkalkulatorControllerTest {
    @isTest
    private static void testSTD1() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		String recId = [
				SELECT Id 
				FROM RecordType 
				WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1].Id;

		Opportunity newOpp = new Opportunity(
			RecordTypeId = recId,
			Anzahl_der_Karten__c = 5,
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Herkunft_Land__c = 'DE',
			StageName = 'CreditCheck',
			Name = 'test opp',
			Angebotsdauer__c = '3 Monate',
			Home_Station__c = 'test',
			ESI__c = 'test',
			CloseDate = Date.today());
		insert newOpp;

		ApexPages.CurrentPage().getparameters().put('id', newOpp.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newOpp);
		SparkalkulatorController sic = new SparkalkulatorController(sc);
    }

   @isTest
    private static void testSTD2() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		String recId = [
				SELECT Id 
				FROM RecordType 
				WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1].Id;

		Opportunity newOpp = new Opportunity(
			RecordTypeId = recId,
			Anzahl_der_Karten__c = 5,
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Herkunft_Land__c = 'DE',
			StageName = 'CreditCheck',
			Name = 'test opp',
			Angebotsdauer__c = '4 Monate',
			ESI__c = 'test',
			Home_Station__c = 'test',
			CloseDate = Date.today());
		insert newOpp;

		ApexPages.CurrentPage().getparameters().put('id', newOpp.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newOpp);
		SparkalkulatorController sic = new SparkalkulatorController(sc);
    }

       @isTest
    private static void testSTD3() {
    	Account newAccount = new Account(
    		Name = 'test',
			BillingCountry = 'Germany');
    	insert newAccount;

		String recId = [
				SELECT Id 
				FROM RecordType 
				WHERE Name = 'Euroshell' AND SobjectType = 'Opportunity' LIMIT 1].Id;

		Opportunity newOpp = new Opportunity(
			RecordTypeId = recId,
			Anzahl_der_Karten__c = 5,
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Herkunft_Land__c = 'DE',
			StageName = 'CreditCheck',
			Name = 'test opp',
			Angebotsdauer__c = '5 Monate',
			ESI__c = 'test',
			Home_Station__c = 'test',
			CloseDate = Date.today());
		insert newOpp;

		ApexPages.CurrentPage().getparameters().put('id', newOpp.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newOpp);
		SparkalkulatorController sic = new SparkalkulatorController(sc);
    }   
}