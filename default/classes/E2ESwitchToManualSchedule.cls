global class E2ESwitchToManualSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new E2ESwitchToManualBatch());
    }
}