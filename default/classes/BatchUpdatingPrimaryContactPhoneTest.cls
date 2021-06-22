@isTest
private class BatchUpdatingPrimaryContactPhoneTest {
	public static Opportunity newOpportunity;
	public static Contact newContact;
	public static OpportunityContactRole ocr;

	static {
		insert CFUtilsTest.createCFSettingsForRussia(false);
	}


	static testMethod void testUpdatingPrimaryContactPhone() {
    	createOpportunity();	 
    	createContact();
    	createOpportunityContactRole();   

        Test.startTest();
        	BatchUpdatingPrimaryContactPhone batch = new BatchUpdatingPrimaryContactPhone();
        	Database.executeBatch(batch); 
        Test.stopTest();   

    	Opportunity updatedOppty = [
    		SELECT Primary_Contact_Phone__c
    		FROM Opportunity
    		WHERE Id = :newOpportunity.Id
    		LIMIT 1];

		System.assertEquals('+491234567', updatedOppty.Primary_Contact_Phone__c);
    }

    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            RecordTypeId = rt.Id,
            Name = 'test opportunity',
            Starts_Status__c = '0. Request received',
            Starts_Schedule__c = Date.today().addDays(-1),
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

    private static void createContact() {
    	newContact = new Contact(
    		Salutation = 'Herr',
    		FirstName = 'Bob',
    		LastName  = 'Test',
    		Phone = '1234567',
    		MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
    		MailingStreet = '298 S. Ringo Street',
    		MailingCity = 'Little Rock',
			MailingPostalCode = '72201'
		);
		insert newContact;
    }

    private static void createOpportunityContactRole() {
    	ocr = new OpportunityContactRole(
    		ContactId = newContact.Id,
    		OpportunityId = newOpportunity.Id,
    		IsPrimary = TRUE,
    		Role = 'Decision Maker'
		);
		insert ocr;
    }
}