public class SharingOpportunityController {
	public Opportunity opportunity{get; private set;}
	public List<HistoryUtils.ObjectHistoryLine> opportunityHistory{get; set;}
	public String lang{get; set;}

	public SharingOpportunityController(ApexPages.StandardController stdController) {
		try {
			Id opportunityId = stdController.getId();
			DescribeSObjectResult describeResult = opportunityId.getSObjectType().getDescribe();
			//List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() ); COMMENTED BY EUGENE BECAUSE OF UNIT TEST ERROR
			String query =
					' SELECT Name, OwnerId, Lead_Owner_Role__c, Number_of_Cards__c, Number_Business_CARD__c, Date_of_First_Contact_Inbound_Outbound__c, ' +
					'PPR_Date_of_Scan__c, Product_PPR__c, Type, CategoryContract__c, Agreement_Counts__c, Agreement_Probability__c, INN_Opp__c, ' +
					'StageName, Approved_by_Start_Manager__c, CloseDate, PPR_Lost_To_Competitor__c, PPR_Lost_Reasons__c, Decision_Reason_Other__c,' +
					'Transfer_from_inbound__c, FieldsFilling__c, Transit_Ultra_Cards__c, Sprint_Ultra_Cards__c, Rover_Cards_X2_0_Ultra__c,' +
					'PPR_Special_conditions__c, Most_Important_Feature__c, Most_Important_Feature_specific__c, Area_Traveled__c, ' +
					'The_region__c, Travel_Pattern__c, Primary_Fueling_Method__c, Additional_Fueling_Methods__c, Field_Telematic__c,' +
					'Fleet_Type__c, Projected_Liters_weekly__c, Pre_scoring__c, Credit_days_ppr__c, Credit_desicion_ppr__c, PPR_Credit_Cost__c,' +
					'VAT_payer__c, Number_of_Vehicles_in_Leasing__c, How_Heard_About_Us__c, Referred_By__c, Channel_Source_Lead__c, ' +
					'Contract_Number__c, Agreement_Date__c, Transit_ID__c, Reaction_to_KP__c, Description, Operator__c, PPR_First_Contact_Inbound_Outbound__c,' +
					'Source_of_Lead_o__c, Source_of_Lead_re_engaging__c, Source_database__c, Source_if_self_sourced_c__c, ' +
					'Promo_Code1__c, Promo_campaign__c, Source_PP__c, PPR_Electronic_document_management__c' + 
					', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status from OpenActivities Order by CreatedDate DESC LIMIT 100) ' +
					', (Select Subject, Who.Name, Ownerid, Istask, Priority, ActivityDate, Status, Description from ActivityHistories Order by CreatedDate DESC LIMIT 100)' +
					', (SELECT StageName, Probability, Amount, Expectedrevenue, Closedate, CreatedDate, CreatedById FROM OpportunityHistories LIMIT 100)' +
					', (SELECT Contact.Name, Contact.Phone, Contact.Account.Name, Contact.Email FROM OpportunityContactRoles LIMIT 100)' +
					' FROM ' + describeResult.getName() +
					' WHERE ' + ' id = :opportunityId' +
					' LIMIT 1 ';

			List<SObject> records = Database.query( query );
			opportunity = (Opportunity)records.get(0);

			HistoryUtils historyUtils = new HistoryUtils();
			opportunityHistory = historyUtils.getObjectHistory(opportunityId);

		}catch (Exception e) {
			System.debug(e.getMessage());
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, e.getMessage()));
		}
	}
}