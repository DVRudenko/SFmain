global class ScheduleBatchStartsOverdueDays implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCalculatingStartsOverdueDays batch = new BatchCalculatingStartsOverdueDays();
        Database.executeBatch(batch);
    }
}