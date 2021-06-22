global class FieldSalesGeocoderSchedule implements Schedulable{

    private String province;

    global FieldSalesGeocoderSchedule(String province){
        this.province = province;
    }

    global void execute(SchedulableContext context){
        FieldSalesGeocoderBatch batch = new FieldSalesGeocoderBatch(province);
        Database.executeBatch(batch, 100);
    }
}