global class LeadQualiStatusSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new LeadQualiStatusBatch(), 1);
    }
}