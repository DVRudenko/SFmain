global class UpdateCaseFirstInteractionDateBatch implements Database.Batchable<sObject> {
    global final String query;

    global UpdateCaseFirstInteractionDateBatch() {
        this.query = 'SELECT Id FROM Case ' +
		'WHERE First_Interaction_Date__c = NULL AND RecordTypeId = \'0123Y0000003dr0QAA\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        System.debug('CASES SCOPE SIZE: ' + scope.size());
		
		// get set of case ids to collect case history 
		Set<Id> caseIds = new Set<Id>();
		for(sObject sObj : scope){
            Case c = (Case) sObj;
			caseIds.add(c.Id);
		}
		
		// get case history where status changed
		List<CaseHistory> caseHistories = [SELECT CaseId, CreatedById, CreatedDate, Field, Id, NewValue, OldValue
        FROM CaseHistory
        WHERE Field = 'Status'
        AND CaseId IN :caseIds
        ORDER BY CreatedDate DESC];
		
		// get only case Customer waiting history
		List<CaseHistory> caseCustomerWaitingHistories = new List<CaseHistory>();
		for(CaseHistory ch : caseHistories){
            if(String.valueOf(ch.NewValue).contains('Customer waiting')){
                caseCustomerWaitingHistories.add(ch);
            }
        }
		
		List<Case> updatedCases = new List<Case>();
		for(sObject sObj : scope){
            Case c = (Case) sObj;
			DateTime firstHistoryDate = null;
			for(CaseHistory ch : caseCustomerWaitingHistories){
				if(ch.CaseId == c.Id) {
					DateTime currentDate = ch.CreatedDate;
					if(firstHistoryDate != null){
						if(ch.CreatedDate <= firstHistoryDate){
							firstHistoryDate = ch.CreatedDate;
						}
					} else {
						currentDate = ch.CreatedDate;
						firstHistoryDate = currentDate;
					}
				}
			}
			c.First_Interaction_Date__c = firstHistoryDate;
			updatedCases.add(c);
		}
        System.debug('CASES FOR UPDATE WITH NEW FIRST INTERACTION CHANGE DATE = ' + updatedCases.size());

        if(!updatedCases.isEmpty()){
            update updatedCases;
            System.debug('UPDATED');
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}