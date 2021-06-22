global class HealthCheckNotificationScheduler implements Schedulable {

    // String sch = '0 1 9 * * ? *';
    // String schName = 'Health Check Notification 9 AM';

    // String sch = '0 1 10 * * ? *';
    // String schName = 'Health Check Notification 10 AM';

    // String sch = '0 1 11 * * ? *';
    // String schName = 'Health Check Notification 11 AM';

    // String sch = '0 1 12 * * ? *';
    // String schName = 'Health Check Notification 12 AM';

    // String sch = '0 1 13 * * ? *';
    // String schName = 'Health Check Notification 01 PM';

    // String sch = '0 1 14 * * ? *';
    // String schName = 'Health Check Notification 02 PM';

    // String sch = '0 1 15 * * ? *';
    // String schName = 'Health Check Notification 03 PM';

    // String sch = '0 1 16 * * ? *';
    // String schName = 'Health Check Notification 04 PM';

    // String sch = '0 1 17 * * ? *';
    // String schName = 'Health Check Notification 05 PM';

    // String sch = '0 1 18 * * ? *';
    // String schName = 'Health Check Notification 06 PM';

    // String sch = '0 1 19 * * ? *';
    // String schName = 'Health Check Notification 07 PM';

    // String sch = '0 1 20 * * ? *';
    // String schName = 'Health Check Notification 08 PM';

    // String sch = '0 1 21 * * ? *';
    // String schName = 'Health Check Notification 09 PM';

    // System.schedule(schName, sch, new HealthCheckNotificationScheduler());
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new HealthCheckNotificationBatch());
    }
}