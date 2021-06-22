global class OpportunityStageStatusSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new OpportunityStageStatusBatch(), 1);
    }
}