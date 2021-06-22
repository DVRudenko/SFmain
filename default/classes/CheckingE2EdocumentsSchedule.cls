global class CheckingE2EdocumentsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        CheckingE2EdocumentsBatch batch = new CheckingE2EdocumentsBatch();
        Database.executeBatch(batch);
    }
}