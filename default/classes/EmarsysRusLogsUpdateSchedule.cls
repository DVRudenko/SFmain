global class EmarsysRusLogsUpdateSchedule implements Schedulable {
    //Schedule expression: "20 0,30 8-18 ? * MON-FRI"
    global void execute(SchedulableContext sc) {
        EmarsysRusLogsUpdateBatch batch = new EmarsysRusLogsUpdateBatch();
        Database.executeBatch(batch, 30);
    }
}