public with sharing class DashboardStartsSLAoverdueCtrl {
	public User currentUser {get; set;}
	public Map<Id, User> salesUserMap {get; set;}
	public Map<Id, Decimal> finalExpiredOpportunitiesMap {get; set;}
	public Map<Id, Decimal> finalTotalOpportunityForUserMap {get; set;}
	public Map<Id, Decimal> percentExpiredOpportunitiesForUserMap {get; set;}
	public Decimal percentOfExpiredOpportunityForSale {get; set;}
	public Decimal totalPercentOfExpiredOpportunityForTeamLead {get; set;}
	public Decimal numberExpiredOpportunityForSale {get; set;}

    public DashboardStartsSLAoverdueCtrl() {
        
    }


    public void init() {
    	try {
    		returnUserId();
	    	generateSLAoverdueData();
    	} catch (Exception e) {
    	     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }


    /*******************************************************************************
    *  Name            : generateSLAoverdueData()
    *  Summary         : Generate SLA overdue Data    
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateSLAoverdueData() {
    	if (availableTeamleaderRoleSet.contains(this.currentUser.UserRole.Name)) {
	    	Map<Id, UserRole> salesRoleMap = new Map<Id, UserRole>([
	    			SELECT Id
	    			FROM UserRole
	    			WHERE ParentRoleId = :this.currentUser.UserRoleId
	    			LIMIT 1000]);

	    	this.salesUserMap = new Map<Id, User>([
	    			SELECT Id, Name
	    			FROM User 
	    			WHERE (UserRoleId IN :salesRoleMap.keySet() OR Id = :currentUser.Id) AND 
	    				  isActive = true 
	    			LIMIT 10000]);

	    	Map<Id, Opportunity> fullOpportunityMap = new Map<Id, Opportunity>([
	    			SELECT Id, Name, OwnerId, Starts_SLA_Expired__c
	    			FROM Opportunity
	    			WHERE StageName = 'Closed Won' AND
	    	    	  	(RecordType.Name = 'Euroshell' OR RecordType.Name = 'Euroshell Starts') AND
	        	    	Starts_Close_Date__c > TODAY AND
	        	    	Starts_Status__c IN :availableStartsStatus AND
	        	    	OwnerId IN :salesUserMap.keySet()
	        	   	LIMIT 50000]);

	       	Map<Id, List<Opportunity>> expiredOpportunitiesMap = new Map<Id, List<Opportunity>>();
	       	Map<Id, List<Opportunity>> totalOpportunitiesMap = new Map<Id, List<Opportunity>>();

	       	for (Opportunity opp : fullOpportunityMap.values()) {
	       		if (opp.Starts_SLA_Expired__c == true) {
		       		if (! expiredOpportunitiesMap.containsKey(opp.OwnerId)) {
		       			expiredOpportunitiesMap.put(opp.OwnerId, new List<Opportunity>());
		       		}
		       		expiredOpportunitiesMap.get(opp.OwnerId).add(opp);
		       	}
		       	if (! totalOpportunitiesMap.containsKey(opp.OwnerId)) {
	       			totalOpportunitiesMap.put(opp.OwnerId, new List<Opportunity>());
	       		}
	       		totalOpportunitiesMap.get(opp.OwnerId).add(opp);
	       	}

	       	this.finalExpiredOpportunitiesMap = new Map<Id, Decimal>();
	       	this.finalTotalOpportunityForUserMap = new Map<Id, Decimal>();
	       	this.percentExpiredOpportunitiesForUserMap = new Map<Id, Decimal>();

	       	Decimal totalExpiredOpportunities = 0;
	       	for (Id userId : this.salesUserMap.keySet()) {
	       		if (! expiredOpportunitiesMap.containsKey(userId)) {
	       			expiredOpportunitiesMap.put(userId, new List<Opportunity>());
	       		}
	       		if (! totalOpportunitiesMap.containsKey(userId)) {
	       			totalOpportunitiesMap.put(userId, new List<Opportunity>());
	       		}
	       		this.finalExpiredOpportunitiesMap.put(userId, expiredOpportunitiesMap.get(userId).size());
	       		this.finalTotalOpportunityForUserMap.put(userId, totalOpportunitiesMap.get(userId).size());
	       		if (this.finalTotalOpportunityForUserMap.get(userId) != 0) {	  
	       			Decimal percent = ((this.finalExpiredOpportunitiesMap.get(userId) / this.finalTotalOpportunityForUserMap.get(userId)) * 100).setScale(0);
	       			this.percentExpiredOpportunitiesForUserMap.put(userId, percent);
	       		} else {
	       			this.percentExpiredOpportunitiesForUserMap.put(userId, 0);
	       		}
	       		totalExpiredOpportunities += this.finalExpiredOpportunitiesMap.get(userId);   		
	       	}
	       	this.totalPercentOfExpiredOpportunityForTeamLead = 0;
	       	if (! fullOpportunityMap.isEmpty()) {
	       		this.totalPercentOfExpiredOpportunityForTeamLead = ((totalExpiredOpportunities / fullOpportunityMap.size()) * 100).setScale(0);
	       	}
	    } else if (availableSalesRoleSet.contains(this.currentUser.UserRole.Name)) {
	    	List<Opportunity> fullOpportunityList = [
	    			SELECT Id, Name, OwnerId, Starts_SLA_Expired__c
	    			FROM Opportunity
	    			WHERE StageName = 'Closed Won' AND
	    	    	  	(RecordType.Name = 'Euroshell' OR RecordType.Name = 'Euroshell Starts') AND
	        	    	CloseDate > TODAY AND
	        	    	Starts_Status__c IN :availableStartsStatus AND
	        	    	OwnerId = :this.currentUser.Id
	        	   	LIMIT 50000];

            this.numberExpiredOpportunityForSale = 0;
			List<Opportunity> expiredOpportunitiesList = new List<Opportunity>();
			for (Opportunity opp : fullOpportunityList) {
				if (opp.Starts_SLA_Expired__c == true) {
					this.numberExpiredOpportunityForSale++;
				}
			}
			this.percentOfExpiredOpportunityForSale = 0;
			if (fullOpportunityList.size() != 0) {
				this.percentOfExpiredOpportunityForSale = ((this.numberExpiredOpportunityForSale / fullOpportunityList.size()) * 100).setScale(0);
			}
	    } else {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'This dashboard is not available for current user'));
	    }
    }


    /*******************************************************************************
    *  Name            : returnUserId()
    *  Summary         : Return current user Id    
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 09/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUserId() {
    	String userId = ApexPages.CurrentPage().getparameters().get('userId');
    	if (userId == null) {
    		userId = UserInfo.getUserId();
    	}
    	this.currentUser = [
				SELECT Id, Name, FirstName, LastName, UserRole.Name, UserRoleId, Profile.Name
				FROM User 
				WHERE Id = :userId];
    }


    private Set<String> availableTeamleaderRoleSet = new Set<String>{
    	'Teamleiter Inbound',
    	'Teamleiter Inbound 2',
    	'Starts Team Manager',
    	'Teamleiter Outbound 1',
    	'Teamleiter Outbound 2',
    	'Teamleiter Outbound 5'
    };

    private Set<String> availableSalesRoleSet = new Set<String>{
    	'Salesteam Inbound',
    	'Salesteam Inbound 2',
    	'Starts Team Rep',
    	'Salesteam Outbound 1',
    	'Salesteam Outbound 2',
    	'Salesteam Outbound 5'
    };

    private Set<String> availableStartsStatus = new Set<String>{
        '0.4 Registration in GFN: Winback',
        '0.5 Missing information',
        '0.6 Missing information provided',
        '0.9 Ready for GFN',
        '1. Customer registered in GFN (card issued & delivered)',
        '2.1 First Check: Cards/PINs Received',
        '2.2 First Check: Not Reached',
        '2.3 First Check: Delay',
        '2.4 First Check: Winback',
        '3.1 Volume Check 1: Customer Pumping',
        '3.2 Volume Check 1: Not Reached',
        '3.3 Volume Check 1: Delay',
        '3.4 Volume Check 1: Winback',
        '4.1.1 Volume Check 2: Pumping Enough',
        '4.1.2 Volume Check 2: Pumping NOT Enough',
        '4.2 Volume Check 2: Not Reached',
        '4.3 Volume Check 2: Delay',
        '4.4 Volume Check 2: Winback',
        '5.4 Final Check: Winback'
    };
}