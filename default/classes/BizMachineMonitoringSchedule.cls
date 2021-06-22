/**
 * Created by marekhaken on 26/08/2020.
 */

global class BizMachineMonitoringSchedule implements Schedulable, Database.AllowsCallouts{
    /*
    BizMachineMonitoringSchedule bizsche = new BizMachineMonitoringSchedule();
    String sch = '0 47 9 * * ? *';
    String jobID = System.schedule('BizMachine monitoring', sch, bizsche);
    */

    global void execute(SchedulableContext ctx) {
        BizMachineMonitoringBatch ws = new BizMachineMonitoringBatch();
        Database.executeBatch(ws, 1);
    }
}