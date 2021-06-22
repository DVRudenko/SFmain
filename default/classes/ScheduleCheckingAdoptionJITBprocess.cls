global class ScheduleCheckingAdoptionJITBprocess implements Schedulable {
    global void execute(SchedulableContext sc) {
    	BatchCheckingAdoptionJITBprocess batch = new BatchCheckingAdoptionJITBprocess();
        Database.executeBatch(batch);
    }
}