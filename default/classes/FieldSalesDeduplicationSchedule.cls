global class FieldSalesDeduplicationSchedule implements Schedulable{

    global void execute(SchedulableContext param1){
        Database.executeBatch(new FieldSalesDeduplicationBatch(null));
    }

}