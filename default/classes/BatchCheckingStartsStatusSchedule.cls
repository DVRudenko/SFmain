global class BatchCheckingStartsStatusSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCheckingStartsStatus batch = new BatchCheckingStartsStatus();
        Database.executeBatch(batch);
    }
}