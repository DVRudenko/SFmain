public with sharing class RefreshMetricsOnGoalController {
	public String goalId;
   	
   	public RefreshMetricsOnGoalController(ApexPages.StandardController standardController) {
		goalId = standardController.getId();    
    }

    public void init() {
    	Set<Id> goalIdsSet = new Set<Id>();
    	goalIdsSet.add(goalId);
    	RefreshMetrics.refreshMetrics(goalIdsSet);
    }
}