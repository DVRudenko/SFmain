global class EmarsysLogCheckerSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        LeadEmarsysCheckerBatch leadbatch = new LeadEmarsysCheckerBatch();
        Database.executeBatch(leadbatch);

        OpportunityEmarsysCheckerBatch opportunitybatch = new OpportunityEmarsysCheckerBatch();
        Database.executeBatch(opportunitybatch);
    }
}