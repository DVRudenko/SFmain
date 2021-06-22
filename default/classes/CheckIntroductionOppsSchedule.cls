global class CheckIntroductionOppsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
    	CheckIntroductionOppsBatch batch = new CheckIntroductionOppsBatch();
        Database.executeBatch(batch); 
    }
}