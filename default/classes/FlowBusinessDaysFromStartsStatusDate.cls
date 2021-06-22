global class FlowBusinessDaysFromStartsStatusDate {
	@InvocableMethod(label='Starts Status Date + days: Starts Schedule Due Date')
	global static void convertLeads(List<FlowBusinessDaysFromStartsStatusDateRequest> requests) {
		for (FlowBusinessDaysFromStartsStatusDateRequest req : requests) {
			changeStartsDueDate(req);
		}
	}

	public static void changeStartsDueDate(FlowBusinessDaysFromStartsStatusDateRequest request) {
		Opportunity opp = [
			SELECT CloseDate, Starts_Status__c, Starts_Status_Delay__c, Starts_Schedule__c, Land_Opp__c 
			FROM Opportunity 
			WHERE Id = :request.opportunityId];
		List<OpportunityFieldHistory> fieldsHistories = [
		        SELECT Field, OpportunityId, NewValue, CreatedDate
		        FROM OpportunityFieldHistory 
		        WHERE Field = 'Starts_Status__c' AND 
		              OpportunityId = :opp.Id
		        ORDER BY CreatedDate DESC
		        LIMIT 25000];

        Datetime dateOfstatusChange;
        if (! fieldsHistories.isEmpty()) {
        	dateOfstatusChange = fieldsHistories.get(0).CreatedDate;
        } else {
        	dateOfstatusChange = opp.CloseDate;
        }

		BusinessHours fleetcorBH;
		if (opp.Land_Opp__c == 'Czech republic') {
            fleetcorBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'CZ'
                LIMIT 1];
		} else if (opp.Land_Opp__c == 'Slovakia') {
			fleetcorBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'SK'
                LIMIT 1];
		} else if (opp.Land_Opp__c == 'Hungary') {
			fleetcorBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'HU'
                LIMIT 1];
		} else if (opp.Land_Opp__c == 'Poland') {
			fleetcorBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'PL'
                LIMIT 1];
		} else {
            fleetcorBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'Default'
                LIMIT 1];
		}	

		Datetime dueDate = BusinessHours.addGmt(fleetcorBH.id, dateOfstatusChange, request.numberOfDays * 32400000 + 1);
		Date dueDateFinal = Date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());
		if (opp.Starts_Schedule__c != dueDateFinal || opp.Starts_Status_Delay__c == true) {
			opp.Starts_Schedule__c = dueDateFinal;
			opp.Starts_Status_Delay__c = false;
			update opp;
		}	
	}

	global class FlowBusinessDaysFromStartsStatusDateRequest {
		@InvocableVariable(required=true)
		public Id opportunityId;

		@InvocableVariable(required=true)
		public Integer numberOfDays;
	}
}