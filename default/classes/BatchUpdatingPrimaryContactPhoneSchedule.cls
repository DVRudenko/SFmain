global class BatchUpdatingPrimaryContactPhoneSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchUpdatingPrimaryContactPhone batch = new BatchUpdatingPrimaryContactPhone();
        Database.executeBatch(batch);
    }
}