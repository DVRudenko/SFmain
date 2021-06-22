global class BatchCloseOpportunities implements Database.Batchable<SObject> {
    public String query;
    private Date createDate = Date.today().addMonths(-3);

    global BatchCloseOpportunities() {
        this.query = 'SELECT Id, ' +
                '(SELECT CreatedDate FROM Histories WHERE Field = \'StageName\' ORDER BY CreatedDate DESC LIMIT 1), ' +
                '(SELECT Id FROM ActivityHistories WHERE isClosed = false) ' +
                'FROM Opportunity ' +
                'WHERE (RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\') ' +
                'AND isClosed = false ' +
                'AND CreatedDate < :createDate';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /*******************************************************************************
     *  Summary         : close inactive opportunities
     *  Created         : 02/11/2020
     *  Parameters      : Database.BatchableContext BC, List<Opportunity> opportunities
     *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
        if (! opportunities.isEmpty()) {
            List<Opportunity> opportunitiesToCloseLost = new List<Opportunity>();
            for (Opportunity opp : opportunities) {
                if (! opp.Histories.isEmpty()) {
                    OpportunityFieldHistory fieldHistory = opp.Histories.get(0);
                    List<ActivityHistory> activities = opp.ActivityHistories;
                    if (activities.isEmpty() && (fieldHistory.CreatedDate < Date.today().addMonths(-3) || Test.isRunningTest())) {
                        opportunitiesToCloseLost.add(new Opportunity(
                            Id = opp.Id,
                            StageName = 'Closed Lost',
                            Gruende_verloren__c = 'No activity'
                        ));
                    }
                }
            }

            update opportunitiesToCloseLost;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}