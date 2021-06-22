global class ETEDropOffScheduler implements Schedulable {
    global void execute(SchedulableContext param) {
        ETEDropOffBatch dropOffBatch = new ETEDropOffBatch();
        Database.executeBatch(dropOffBatch, 1);
    }
}