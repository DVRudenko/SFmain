global class AccountPenaltyDecreaseBatch implements Database.Batchable<sObject> {
    /** 
	 *this batch runs daily to decrease account penalty rating 
	*/

	global final FieldSalesTerritory_General_Settings__c fieldSalesSettings;
	global final String query;
	global final Id russianAccRT;

	global AccountPenaltyDecreaseBatch() {
		this.fieldSalesSettings = FieldSalesTerritory_General_Settings__c.getInstance('RU');
		this.russianAccRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
		this.query = 'SELECT Id, Rating_FS_Penalty__c ' + 
					' FROM Account ' +
					' WHERE RecordTypeId = :russianAccRT ' + // decrease penalty for russian accs only
					' AND Rating_FS_Penalty__c > 0 ';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List <Account> accsToUpdate = new List <Account> ();
		for (sObject sObj : scope) {
			Account acc = (Account) sObj;
			// update account penalty rating
			Decimal currentPenaltyVal = acc.Rating_FS_Penalty__c;
			Account accToUpdate = new Account (
				Id = acc.Id, 
				Rating_FS_Penalty__c = currentPenaltyVal - 1
			);
			accsToUpdate.add(accToUpdate);
		}
		if (!accsToUpdate.isEmpty()) {
			update accsToUpdate;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}