public with sharing class UpdateOpportunityOwnerCtrl {
	public Set<Id> opportunityIds;
	public List<Opportunity> selectedRecords {get; set;}
	public Opportunity opportunity {get; set;}

	/*******************************************************************************
	*  Name            : UpdateOpportunityOwnerCtrl(ApexPages.StandardSetController controller)
	*  Summary         : Create the List of sObjects that have been selected.    
	*  CreatedDate     : 01/06/2018
	*  ModifiedDate    : -
	*  Parameters      : ApexPages.StandardSetController controller
	*  Returns         : -
	******************************************************************************/
    public UpdateOpportunityOwnerCtrl(ApexPages.StandardSetController controller) {
        List<Opportunity> selectedListOpportunities = controller.getSelected();
        this.opportunityIds = generateOpportunityIds(selectedListOpportunities);
        this.opportunity = new Opportunity();
    }


    /*******************************************************************************
    *  Name            : void init()
    *  Summary         : Meethod for initialization    
    *  CreatedDate     : 01/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
    	this.selectedRecords = selectOpportunitiesList();
        if (this.selectedRecords == null || this.selectedRecords.isEmpty()) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.INFO, 'Choose at least one record.'));
            return;
        }
    }


    /*******************************************************************************
    *  Name            : Set<Id> generateOpportunityIds(List<Opportunity> selectedListOpportunities)
    *  Summary         : Create selected Opportunities Ids   
    *  CreatedDate     : 01/06/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> selectedListOpportunities
    *  Returns         : Set<Id> opportunityIdsSet
    ******************************************************************************/
    public Set<Id> generateOpportunityIds(List<Opportunity> selectedListOpportunities) {
    	Set<Id> opportunityIdsSet = new Set<Id>();
    	for (Opportunity opp : selectedListOpportunities) {
    		opportunityIdsSet.add(opp.Id);
    	}
    	return opportunityIdsSet;
    }


    /*******************************************************************************
    *  Name            : List<Opportunity> selectOpportunitiesList()
    *  Summary         : Return the selected list of Opportunities    
    *  CreatedDate     : 01/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : List<Opportunity> oppList
    ******************************************************************************/
    public List<Opportunity> selectOpportunitiesList() {
    	List<Opportunity> oppList = [
    	        SELECT OwnerId, AccountId
    	        FROM Opportunity
    	        WHERE Id IN :this.opportunityIds
    	        LIMIT 50000];
    	return oppList;
    }


    /*******************************************************************************
    *  Name            : updateOppOwner()
    *  Summary         : Update Opportunity Owner fields    
    *  CreatedDate     : 01/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateOppOwner() {
    	try {
    		if (this.opportunity.OwnerId == null) {
    			ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a Opportunity Owner.') );
                return;
    		}
            if (this.selectedRecords == null || this.selectedRecords.isEmpty()) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.ERROR, 'You have not selected any records.'));
                return;
            }

            Set<String> accIdSet = new Set<String>();
			for (Opportunity opp : this.selectedRecords) {
                accIdSet.add(opp.AccountId);
    			opp.OwnerId = this.opportunity.OwnerId;
    		}
    		update this.selectedRecords;

            if ( ! accIdSet.isEmpty()) {
                List<Account> accountToUpdateList = [SELECT OwnerId FROM Account WHERE Id IN :accIdSet LIMIT 50000];
                if ( ! accountToUpdateList.isEmpty()) {
                    for (Account acc : accountToUpdateList) {
                        acc.OwnerId = this.opportunity.OwnerId;
                    }
                    update accountToUpdateList;
                }

                List<Contact> contactsToUpdateList = [SELECT OwnerId FROM Contact WHERE AccountId IN :accIdSet LIMIT 50000];
                if ( ! contactsToUpdateList.isEmpty()) {
                    for (Contact con : contactsToUpdateList) {
                        con.OwnerId = this.opportunity.OwnerId;
                    }
                    update contactsToUpdateList;
                }
            }

    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'The records owner has been successfully changed.'));
    	} catch (Exception e) {
    		ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()) );
    	}
    }
}