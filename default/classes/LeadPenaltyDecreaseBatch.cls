global class LeadPenaltyDecreaseBatch implements Database.Batchable<sObject> {
	/** 
	 *this batch runs daily to decrease lead penalty rating 
	*/

	global final FieldSalesTerritory_General_Settings__c fieldSalesSettings;
	global final String query;
	global final Id russianLeadRT;
	
	global LeadPenaltyDecreaseBatch() {
		this.fieldSalesSettings = FieldSalesTerritory_General_Settings__c.getInstance('RU');
		this.russianLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
		this.query = 'SELECT Id, Rating_FS_Penalty__c ' + 
					' FROM Lead ' +
					' WHERE RecordTypeId = :russianLeadRT' + // decrease penalty for russian leads only
					' AND Rating_FS_Penalty__c > 0 ';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List <Lead> leadsToUpdate = new List <Lead> ();
		for (sObject sObj : scope) {
			Lead lead = (Lead) sObj;
			Decimal currentPenaltyVal = lead.Rating_FS_Penalty__c;
			Lead leadToUpdate = new Lead (
				Id = lead.Id,
				Rating_FS_Penalty__c = currentPenaltyVal - 1
			);
			leadsToUpdate.add(leadToUpdate);
		}
		if (!leadsToUpdate.isEmpty()) {
			update leadsToUpdate;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}