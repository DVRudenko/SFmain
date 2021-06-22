@isTest
private class LeadPenaltyDecreaseBatchTest {
	@testSetup static void setup() {
	//----- CUSTOM SETTINGS -----
		FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365
        );
        insert fieldSalesSettings;
    }

	@isTest static void mainTest() {
    /* test decreasing lead penalty rating
	*/
    //----- OWNER -----
        User buddy = [SELECT Id FROM  User
                      WHERE Id IN (SELECT AssigneeId
                                  FROM PermissionSetAssignment
                                  WHERE PermissionSet.Name = 'FieldSalesTerritory_buddy')
                      LIMIT 1];
    //----- LEADS -----
		Id russianLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
		Lead lead1 = new Lead (
			RecordTypeId = russianLeadRT,
			OwnerId = buddy.Id,
			Salutation = 'Herr1',
			LastName = 'Test LastName',
			LeadSource = 'Partner',
			Rating_FS__c = 30,
			Rating_FS_Penalty__c = 100,
			Status = 'Disqualified',
			Duplicate_Record_Mark__c = false,
			IsConverted = false,
			Phone = '+71231111111',
			Company = 'test1',
			Country = 'Russia',
	        Region__c = 'Кировская область',
			Street = 'САНКТ-ПЕТЕРБУРГ',
	        Partner_OBN__c = '123123',
	        INN__c = '234234123423',
	        Branche_NACE__c = 'Apotheken - 4773',
	        Anzahl_der_Fahrzeuge__c = 5,
	        Beschaeftigte__c = '1-4',
	        Sec_Channel__c = 'Inbound'
		);
		insert new List <Lead> {lead1};
	// ----- START TEST -----
		Test.startTest();
		LeadPenaltyDecreaseBatch batch = new LeadPenaltyDecreaseBatch ();
		database.executeBatch(batch, 200);
		Test.stopTest();
	}

	@isTest static void testEmpty() {
	/* no leads to decrease rating in the batch
	*/
    //----- OWNER -----
        User buddy = [SELECT Id FROM  User
                      WHERE Id IN (SELECT AssigneeId
                                  FROM PermissionSetAssignment
                                  WHERE PermissionSet.Name = 'FieldSalesTerritory_buddy')
                      LIMIT 1];
    //----- LEADS -----
		Id russianLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
		Lead lead1 = new Lead (
			RecordTypeId = russianLeadRT,
			OwnerId = buddy.Id,
			Salutation = 'Herr1',
			LastName = 'Test LastName',
			LeadSource = 'Partner',
			Rating_FS__c = 30,
			Rating_FS_Penalty__c = 0, //  no penalty rating to decrease
			Status = 'Disqualified',
			Duplicate_Record_Mark__c = false,
			IsConverted = false,
			Phone = '+71231111111',
			Company = 'test1',
			Country = 'Russia',
	        Region__c = 'Кировская область',
			Street = 'САНКТ-ПЕТЕРБУРГ',
	        Partner_OBN__c = '123123',
	        INN__c = '234234123423',
	        Branche_NACE__c = 'Apotheken - 4773',
	        Anzahl_der_Fahrzeuge__c = 5,
	        Beschaeftigte__c = '1-4',
	        Sec_Channel__c = 'Inbound'
		);
		insert new List <Lead> {lead1};
	// ----- START TEST -----
		Test.startTest();
		LeadPenaltyDecreaseBatch batch = new LeadPenaltyDecreaseBatch ();
		database.executeBatch(batch, 200);
		Test.stopTest();
	}
}