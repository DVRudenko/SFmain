public class SharingLeadController {
	public Lead lead{get; private set;}
	public List<HistoryUtils.ObjectHistoryLine> leadHistory{get; set;}

	public SharingLeadController(ApexPages.StandardController stdController) {

		try{
			Id leadId = stdController.getId();
			DescribeSObjectResult describeResult = leadId.getSObjectType().getDescribe();
			List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
			String query =
					' SELECT ' + String.join( fieldNames, ',' ) +
					', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status from OpenActivities Order by CreatedDate DESC LIMIT 500) ' +
					', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status, Description from ActivityHistories Order by CreatedDate DESC LIMIT 500)' +
					' FROM ' + describeResult.getName() +
					' WHERE ' + ' id = :leadId' +
					' LIMIT 1 '
			;
			List<SObject> records = Database.query( query );
			lead = (Lead)records.get(0);

			HistoryUtils historyUtils = new HistoryUtils();
			leadHistory = historyUtils.getObjectHistory(leadId);

		}catch (Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, e.getMessage()));
		}
	}
}