global class ScheduleBatchCloseOpportunities implements Schedulable {

    /*******************************************************************************
     *  Summary         : close inactive opportunities (0 0 4 ? * MON-FRI)
     *  Created         : 02/11/2020
     *  Parameters      : -
     *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext ch) {
        BatchCloseOpportunities batchCloseOpportunities = new BatchCloseOpportunities();
        Database.executeBatch(batchCloseOpportunities);
    }
}