public class OpportunityExtension {
	public List<Opportunity> opportunities {get; set;}
	public Opportunity opportunity {get; set;}

	public OpportunityExtension() {
		String ids = ApexPages.currentPage().getParameters().get('ids');
		String id = ApexPages.currentPage().getParameters().get('id');

		try {
			opportunities = [
					SELECT 	Name,
							Owner.Id,
							Owner.Name,
							Owner.UserRole.Name,
							INN_Opp__c,
							StageName,
							Day_transfer__c,
							CloseDate
					FROM 	Opportunity
					WHERE 	Id IN : ids.split(';')
			];
		} catch (Exception e) {
		    System.debug( e.getMessage() );
		}

		try {
			opportunity = [
					SELECT 	Name,
							Owner.Id,
							Owner.Name,
							Owner.UserRole.Name,
							INN_Opp__c,
							StageName,
							Day_transfer__c,
							CloseDate,
							Manual_Entry__c,
							Number_of_Cards__c
					FROM 	Opportunity
					WHERE 	Id =: id
			];
		} catch (Exception e) {
		    System.debug( e.getMessage() );
		}

	}
}