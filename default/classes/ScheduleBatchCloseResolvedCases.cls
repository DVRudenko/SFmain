global class ScheduleBatchCloseResolvedCases implements Schedulable {

    global void execute(SchedulableContext param1) {
        BatchCloseResolvedCases batchCloseResolvedCases = new BatchCloseResolvedCases();
        Database.executeBatch(batchCloseResolvedCases);
    }

}