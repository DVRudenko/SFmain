global class EmarsysLogsUpdateSchedule implements Schedulable {
	//Schedule expression: "20 0,30 8-18 ? * MON-FRI"
    global void execute(SchedulableContext sc) {
        EmarsysLogsUpdateBatch logsUpdateBatch = new EmarsysLogsUpdateBatch();
        Database.executeBatch(logsUpdateBatch, 30);	
    }
}