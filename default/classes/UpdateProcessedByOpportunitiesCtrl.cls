public with sharing class UpdateProcessedByOpportunitiesCtrl {
	public Set<Id> opportunityIds {get; set;}
	public List<Opportunity> selectedRecords {get; set;}
	public List<SelectOption> processedByOpportunityOptions {get; set;}
	public String selectedProcessedBy {get; set;}


	/*******************************************************************************
	*  Name            : UpdateProcessedByOpportunitiesCtrl(ApexPages.StandardSetController controller)
	*  Summary         : Create the List of sObjects that have been selected.
	*  CreatedDate     : 01.03.2018
	*  ModifiedDate    : 01.03.2018
	*  Parameters      : ApexPages.StandardSetController controller
	*  Returns         : 
	******************************************************************************/
    public UpdateProcessedByOpportunitiesCtrl(ApexPages.StandardSetController controller) {
        List<Opportunity> selectedListOpportunities = controller.getSelected();
        this.opportunityIds = generateOpportunityIds(selectedListOpportunities);
    }


    /*******************************************************************************
    *  Name            : void init()
    *  Summary         : Meethod for initialization    
    *  CreatedDate     : 01.03.2018
    *  ModifiedDate    : 01.03.2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void init() {
    	this.selectedRecords = selectOpportunitiesList();
    	this.processedByOpportunityOptions = generateProcessedByOptions();
    	this.selectedProcessedBy = this.processedByOpportunityOptions.get(0).getValue();
    }


    /*******************************************************************************
    *  Name            : Set<Id> generateOpportunityIds(List<Opportunity> selectedListOpportunities)
    *  Summary         : Create selected Opportunities Ids   
    *  CreatedDate     : 01.03.2018
    *  ModifiedDate    : 01.03.2018
    *  Parameters      : List<Opportunity> selectedListOpportunities
    *  Returns         : Set<Id> opportunityIds
    ******************************************************************************/
    public Set<Id> generateOpportunityIds(List<Opportunity> selectedListOpportunities) {
    	Set<Id> opportunityIds = new Set<Id>();
    	for (Opportunity opportunity : selectedListOpportunities) {
    		opportunityIds.add(opportunity.Id);
    	}
    	return opportunityIds;
    }


    /*******************************************************************************
    *  Name            : List<Opportunity> selectOpportunitiesList()
    *  Summary         : Return the selected list of Opportunities    
    *  CreatedDate     : 01.03.2018
    *  ModifiedDate    : 01.03.2018
    *  Parameters      : 
    *  Returns         : List<Opportunity> listOfOpportunities
    ******************************************************************************/
    public List<Opportunity> selectOpportunitiesList() {
    	List<Opportunity> listOfOpportunities = [
    	        SELECT Name, bearbeitet_von__c
    	        FROM Opportunity
    	        WHERE Id IN :this.opportunityIds];
    	return listOfOpportunities;
    }


    /*******************************************************************************
    *  Name            : List<SelectOption> generateProcessedByOptions()
    *  Summary         : Return the Processed by picklist of Opportunity   
    *  CreatedDate     : 01.03.2018
    *  ModifiedDate    : 01.03.2018
    *  Parameters      : 
    *  Returns         : List<SelectOption> processedByOpportunityOptions
    ******************************************************************************/
    public List<SelectOption> generateProcessedByOptions() {
    	Schema.DescribeFieldResult fieldProcessedByResults = Opportunity.bearbeitet_von__c.getDescribe();
    	List<Schema.PicklistEntry> picklistValues = fieldProcessedByResults.getPicklistValues();
    	List<SelectOption> processedByOpportunityOptions = new List<SelectOption>();
    	for (Schema.PicklistEntry fields : picklistValues) {
    		processedByOpportunityOptions.add( new SelectOption(fields.getValue(), fields.getLabel()) );
    	}
    	return processedByOpportunityOptions;
    }


    /*******************************************************************************
    *  Name            : updateProcessedByData()
    *  Summary         : Update Processed by fiels    
    *  CreatedDate     : 01.03.2018
    *  ModifiedDate    : 01.03.2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void updateProcessedByData() {
    	try {
	     	for (Opportunity opportunity : selectedRecords) {
	    		opportunity.bearbeitet_von__c = this.selectedProcessedBy;
	    	}
	    	update selectedRecords;
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Opportunities have been updated.'));	
    	} catch (Exception e) {
    		ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()) );
    	}
    }
}