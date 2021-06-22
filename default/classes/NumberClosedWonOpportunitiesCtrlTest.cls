@isTest
private class NumberClosedWonOpportunitiesCtrlTest {
    public Static Account newAccount;
	public Static Lead newLead;

    static testMethod void testCalculatingClosedWonOpportunities() {  
    	createAccount();
    	createLead();

    	Database.LeadConvert lc = new Database.LeadConvert();
    	lc.setLeadId(newLead.id);
    	
    	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
    	lc.setConvertedStatus(convertStatus.MasterLabel);

    	Database.LeadConvertResult lcr = Database.convertLead(lc);
    	System.assert(lcr.isSuccess());      

    	Lead lead = [SELECT ConvertedOpportunityId FROM Lead WHERE Id = :newLead.Id];
    	Opportunity convertedOpportunity = [
	        SELECT Id, AccountId, StageName, Angebotsdauer__c
	        FROM Opportunity 
	        WHERE Id = :lead.ConvertedOpportunityId];

        BackOffice_Notifications__c customSettings = new BackOffice_Notifications__c(
            Name = 'Germany',
            Email__c = 'test@test.com',
            Active__c = false);
        insert customSettings;

        convertedOpportunity.AccountId = newAccount.Id;
        convertedOpportunity.Angebotsdauer__c = '3 Monate';
        convertedOpportunity.StageName = 'Closed Won';
        update convertedOpportunity;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);
        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        NumberClosedWonOpportunitiesCtrl controller = new NumberClosedWonOpportunitiesCtrl(sc);
        controller.init();
    }


    private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
    		GFN_Nr__c  = '123',
			Type = 'Customer',
			Bundesland__c = 'Germany',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		Hausnummer_E__c = 'test',
    		PLZ_E__c = 'test',
    		OBN__c = '12345',
    		Ort_E__c = 'tet',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
    		BillingCountry = 'Germany',
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


	private static void createLead() {
		newLead = new Lead(
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test company',
			Salutation = 'Herr',
			Partner__c = newAccount.Id,
			Anzahl_der_Karten_Euroshell__c = 'test',
			Anzahl_der_Fahrzeuge__c = 2, 
			FirstName = 'testName', 
			LastName = 'testFam',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Quali_Status__c = 'Refused to talk',
            Branche_NACE__c = 'Apotheken - 4773',
            Beschaeftigte__c = '1-4',
            Disable_for_KPI__c = FALSE           
        );
		insert newLead;
	}
}