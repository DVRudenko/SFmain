public with sharing class RefreshMetricsOnGoalListViewCtrl {
	public Set<Id> goalIds;
	public Boolean isValid {get; set;}
   	
   	public RefreshMetricsOnGoalListViewCtrl(ApexPages.StandardSetController standardController) {
   		this.isValid = true;
		goalIds = new Set<Id>();
		if (standardController.getSelected().isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Не выбрана ни одна из Целей.'));
			this.isValid = false;
			return;
		}
    	for (sObject gl : standardController.getSelected()) {
    		goalIds.add(gl.Id);	
    	}    
    }

    public void init() {
		RefreshMetrics.refreshMetrics(goalIds);
    }
}