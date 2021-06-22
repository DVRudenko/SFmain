global class FlowBusinessDaysFromCloseDate {
	@InvocableMethod(label='Close Date + days: Starts Schedule Due Date')
	global static void convertLeads(List<FlowBusinessDaysFromCloseDateRequest> requests) {
		for (FlowBusinessDaysFromCloseDateRequest req : requests) {
			changeStartsDueDate(req);
		}
	}

	public static void changeStartsDueDate(FlowBusinessDaysFromCloseDateRequest request) {
		Opportunity opp = [SELECT CloseDate, Land_Opp__c FROM Opportunity WHERE Id = :request.opportunityId];
		BusinessHours defaultBH;
		if (opp.Land_Opp__c == 'Czech republic' || opp.Land_Opp__c == 'Slovakia') {
            defaultBH = [
                    SELECT Id
                    FROM BusinessHours
                    WHERE Name = 'CZ_SK'
                    LIMIT 1];
		} else {
            defaultBH = [
                    SELECT Id
                    FROM BusinessHours
                    WHERE Name = 'Default'
                    LIMIT 1];
		}

		Datetime dueDate = BusinessHours.addGmt(defaultBH.id, opp.CloseDate, request.numberOfDays * 32400000 + 1);
		Date dueDateFinal = Date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());
		opp.Starts_Schedule__c = dueDateFinal;
		update opp;
	}

	global class FlowBusinessDaysFromCloseDateRequest {
		@InvocableVariable(required=true)
		public Id opportunityId;

		@InvocableVariable(required=true)
		public Integer numberOfDays;
	}
}