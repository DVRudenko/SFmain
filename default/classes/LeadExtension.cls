public class LeadExtension {
	public Lead lead {get; set;}

	public LeadExtension () {
		String id = ApexPages.currentPage().getParameters().get('id');

		try {
			lead = [
					SELECT 	Name, INN__c, Owner.Name, Phone
					FROM 	Lead
					WHERE 	Id =: id
			];
		} catch (Exception e) {
		    System.debug( e.getMessage() );
		}
	}
}