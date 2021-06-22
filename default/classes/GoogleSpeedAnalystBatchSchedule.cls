global class GoogleSpeedAnalystBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        GoogleSpeedAnalystBatch batch = new GoogleSpeedAnalystBatch();
        Database.executeBatch(batch, 1);
    }
}