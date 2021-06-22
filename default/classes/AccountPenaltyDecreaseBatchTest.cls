@isTest
private class AccountPenaltyDecreaseBatchTest {

	static {
		insert CFUtilsTest.createCFSettingsForRussia(false);
	}

	@testSetup static void setup() {
	//----- CUSTOM SETTINGS -----
		FieldSalesTerritory_General_Settings__c fieldSalesSettings = new FieldSalesTerritory_General_Settings__c(
                Name = 'RU',
                Penalty_for_refusal__c = 365
        );
        insert fieldSalesSettings;     
    }

	@isTest static void mainTest() {
	/* test decreasing account penalty rating
	*/
    //----- OWNER -----     
        User buddy = [SELECT Id FROM  User 
                      WHERE Id IN (SELECT AssigneeId 
                                  FROM PermissionSetAssignment 
                                  WHERE PermissionSet.Name = 'FieldSalesTerritory_buddy')
                      LIMIT 1];
     //----- ACCOUNTS -----
		Id russianAccRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
		Account acc1 = new Account (
			RecordTypeId = russianAccRT,
			OwnerId = buddy.Id,	
			Name = 'TestAcc1',
			Rating_FS__c = 30,
			Rating_FS_Penalty__c = 100,
			Phone = '+71234567891',
			BillingPostalCode = '123',
            BillingStreet = 'САНКТ-ПЕТЕРБУРГ', 
            INN__C = '1234567890'
		);
		insert new List <Account> {acc1};
    //----- OPPORTUNITIES -----
		Id russianOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
		Opportunity opp1 = new Opportunity (
			RecordTypeId = russianOppRT,
			OwnerId = buddy.Id,	
			AccountId = acc1.Id,
			Name = 'TestOpp1Acc1',
			StageName = 'Отказ',
			CloseDate = date.today(),
            Last_Owner_Change_Date_RUS__c = system.now().addDays(-50)
		);
		Opportunity opp2 = new Opportunity (
			RecordTypeId = russianOppRT,
			OwnerId = buddy.Id,	
			AccountId = acc1.Id,
			Name = 'TestOpp2Acc1',
			StageName = 'Отказ',
			CloseDate = date.today(),
            Last_Owner_Change_Date_RUS__c = system.now().addDays(-50)
		);
		insert new List <Opportunity> {opp1, opp2};
	// ----- START TEST -----
		Test.startTest();
		AccountPenaltyDecreaseBatch batch = new AccountPenaltyDecreaseBatch ();
		database.executeBatch(batch, 200);
		Test.stopTest();
	}	

	@isTest static void testEmpty() {
	/* no opps to decrease rating in the batch
	*/
	//----- OWNER -----     
        User buddy = [SELECT Id FROM  User 
                      WHERE Id IN (SELECT AssigneeId 
                                  FROM PermissionSetAssignment 
                                  WHERE PermissionSet.Name = 'FieldSalesTerritory_buddy')
                      LIMIT 1];
	//----- ACCOUNTS -----
		Id russianAccRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
		Account acc1 = new Account (
			RecordTypeId = russianAccRT,
			OwnerId = buddy.Id,	
			Name = 'TestAcc1',
			Rating_FS__c = 30,
			Rating_FS_Penalty__c = 0, //  no penalty rating to decrease
			Phone = '+71234567891', 
			BillingPostalCode = '123',
            BillingStreet = 'САНКТ-ПЕТЕРБУРГ', 
            INN__C = '1234567890'
		);
		insert new List <Account> {acc1};
    //----- OPPORTUNITIES -----
		Id russianOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
		Opportunity opp1 = new Opportunity (
			RecordTypeId = russianOppRT,
			OwnerId = buddy.Id,	
			AccountId = acc1.Id,
			Name = 'TestOpp1Acc1',
			StageName = 'Отказ',
			CloseDate = date.today(),
            Last_Owner_Change_Date_RUS__c = system.now().addDays(-50)
		);
		insert new List <Opportunity> {opp1};
		// ----- START TEST -----
		Test.startTest();
		// no opps to decrease rating in the batch
		AccountPenaltyDecreaseBatch batch = new AccountPenaltyDecreaseBatch ();
		database.executeBatch(batch, 200);
		Test.stopTest();
	}
}