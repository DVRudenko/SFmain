public with sharing class DashboardStartsSLAoverdueReportCtrl {
	public String selectedUserId;
    public String userName {get; set;}
    public Integer amountOfOpportunities {get; set;}
    public Decimal percentAllExpiredOpps {get; set;}
    public Map<String, List<Opportunity>> statusToAllOppsMap {get; set;}
    public Map<String, Decimal> statusToAmountOppsMap {get; set;}
    public Integer numberOfStatuses {get; set;}

    public DashboardStartsSLAoverdueReportCtrl() {
        
    }

    public void init() {
    	try {
            returnUserId();
    	    generateOpportunityData();
    	} catch (Exception e) {
    	     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }


    /*******************************************************************************
    *  Name            : returnUserId()
    *  Summary         : Get user Id    
    *  CreatedDate     : 15/01/2018 
    *  ModifiedDate    : 15/01/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUserId() {
        this.selectedUserId = Apexpages.currentPage().getParameters().get('userid');
    }


    /*******************************************************************************
    *  Name            : generateOpportunityData()
    *  Summary         : Generate data table
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateOpportunityData() {
        Map<Id, User> salesTeamMap = new Map<Id, User>([
                SELECT Name
                FROM User
                WHERE isActive = TRUE
                LIMIT 10000]);
        userName = salesTeamMap.get(selectedUserId).Name;

        List<Opportunity> fullOpportunityList = [
                SELECT Id, Name, GFN_number_for_starts__c, Total_consumption_l_month__c, Starts_Status__c, CloseDate, Account.First_Pump_Date__c, Registered_Country__c, OwnerId,
                    Starts_Schedule__c, Starts_SLA_Expired__c, Starts_Overdue_days__c
                FROM Opportunity
                WHERE StageName = 'Closed Won' AND
                    (RecordType.Name = 'Euroshell' OR RecordType.Name = 'Euroshell Starts') AND
                    Starts_Close_Date__c > TODAY AND
                    Starts_Status__c IN :availableStartsStatus AND
                    OwnerId = :selectedUserId
                LIMIT 50000];

        List<Opportunity> expiredOppsList = new List<Opportunity>();
        for (Opportunity oppty : fullOpportunityList) {
            if (oppty.Starts_SLA_Expired__c == true) {
                expiredOppsList.add(oppty);
            }
        }

        Map<String, List<Opportunity>> statusToExpiredOppsMap = new Map<String, List<Opportunity>>();
        Decimal amountOfExpiredOpps = 0;
        this.statusToAllOppsMap = new Map<String, List<Opportunity>>();
        this.statusToAmountOppsMap = new Map<String, Decimal>();
        this.amountOfOpportunities = fullOpportunityList.size();
        for (Opportunity oppty : expiredOppsList) {
            if( ! this.statusToAllOppsMap.containsKey(oppty.Starts_Status__c)) {
                this.statusToAllOppsMap.put(oppty.Starts_Status__c, new List<Opportunity>());
            }
            this.statusToAllOppsMap.get(oppty.Starts_Status__c).add(oppty);
            if (! statusToExpiredOppsMap.containsKey(oppty.Starts_Status__c) ) {
                statusToExpiredOppsMap.put(oppty.Starts_Status__c, new List<Opportunity>() );
            }
            statusToExpiredOppsMap.get(oppty.Starts_Status__c).add(oppty);
            if (oppty.Starts_SLA_Expired__c == true) {
                amountOfExpiredOpps++;
            }
        }

        if (this.amountOfOpportunities != 0) {
            this.percentAllExpiredOpps = ((amountOfExpiredOpps * 100) / this.amountOfOpportunities).setScale(0);
        } else {
            this.percentAllExpiredOpps = 0;
        }

        for (String status : this.statusToAllOppsMap.keySet()) {
            if ( ! this.statusToAmountOppsMap.containsKey(status)) {
                this.statusToAmountOppsMap.put(status, this.statusToAllOppsMap.get(status).size());
            }
        }

        this.numberOfStatuses = this.statusToAmountOppsMap.size();
    }

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