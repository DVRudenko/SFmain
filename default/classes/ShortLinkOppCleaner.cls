global class ShortLinkOppCleaner implements Schedulable {


    global void execute(SchedulableContext ctx) {

        ShortLinkOppCleanerBatch b = new ShortLinkOppCleanerBatch();
        database.executebatch(b,200);
    }

}