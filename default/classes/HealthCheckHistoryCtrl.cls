public class HealthCheckHistoryCtrl {
    public List<Health_Check__c> healthChecksList {get; set;}

    /******************************************************************************
    *  Name            : init()
    *  Summary         : initial data initialization
    *  CreatedDate     : 30/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
    	String opptyId = ApexPages.CurrentPage().getparameters().get('oppid');
    	this.healthChecksList = getHealthChecks(opptyId);
    }


    /*******************************************************************************
    *  Name            : getHealthChecks(String opptyId)
    *  Summary         : get health check objects list 
    *  CreatedDate     : 30/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : List<Health_Check__c> - healthChecksList
    ******************************************************************************/
    public List<Health_Check__c> getHealthChecks(String opptyId) {
    	List<Health_Check__c> healthChecksOfTheOpptyList = [
    		SELECT Country__c, Description__c, Device__c, From_Step__c, Opportunity__c, Start_Action__c, To_Step__c, Time_execution__c
    		FROM Health_Check__c
    		WHERE Opportunity__c = :opptyId
    		ORDER BY Start_Action__c ASC
    	];
    	return healthChecksOfTheOpptyList;
    }
}