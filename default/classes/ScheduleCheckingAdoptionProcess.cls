global class ScheduleCheckingAdoptionProcess implements Schedulable {
    global void execute(SchedulableContext sc) {
    	BatchCheckingAdoptionProcess batch = new BatchCheckingAdoptionProcess();
        Database.executeBatch(batch);
    }
}