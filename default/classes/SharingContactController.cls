public class SharingContactController {
	public Contact contact{get; private set;}
	public List<HistoryUtils.ObjectHistoryLine> contactHistory{get; set;}

	public SharingContactController(ApexPages.StandardController stdController) {
		try {
			Id contactId = stdController.getId();
			DescribeSObjectResult describeResult = contactId.getSObjectType().getDescribe();
			List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );

			String query =
					' SELECT ' + String.join( fieldNames, ',' ) +
					', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status from OpenActivities Order by CreatedDate DESC LIMIT 500) ' +
					', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status, Description from ActivityHistories Order by CreatedDate DESC LIMIT 500)' +
					', (SELECT Opportunity.StageName, Opportunity.CreatedDate, Opportunity.Name, Opportunity.Contract_Number__c, ' +
					'Opportunity.CloseDate, Opportunity.ALL_Cards__c, Opportunity.Number_of_Vehicles__c  FROM OpportunityContactRoles LIMIT 500)' +
					' FROM ' + describeResult.getName() +
					' WHERE ' + ' id = :contactId' +
					' LIMIT 1 ';

			List<SObject> records = Database.query( query );
			contact = (Contact)records.get(0);

			HistoryUtils historyUtils = new HistoryUtils();
			contactHistory = historyUtils.getObjectHistory(contactId);

		}catch (Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, e.getMessage()));
		}
	}
}