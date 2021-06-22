public with sharing class NumberClosedWonOpportunitiesCtrl {
	private ApexPages.StandardController controller {get; set;}
	public Integer numberOfClosedWonOppties {get; set;}

    public NumberClosedWonOpportunitiesCtrl(ApexPages.StandardController controller) { 
    }

    public void init() {
    	String accountId = ApexPages.currentPage().getParameters().get('id');
    	Map<Id, Lead> allLeadsThisAccountMap = new Map<Id, Lead>([
    		SELECT Id
    		FROM Lead
    		WHERE Partner__c = :accountId
			LIMIT 50000
		]);

    	this.numberOfClosedWonOppties = [SELECT COUNT() FROM Lead WHERE ConvertedOpportunity.StageName = 'Closed Won' AND Id IN :allLeadsThisAccountMap.keySet()];
    }
}