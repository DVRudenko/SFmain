/**
 * Created by Yury on 23.09.2020.
 */

global class EmarsysContactRunSchedule implements Schedulable {
    public List<Emarsys_Contact_Subscriptions__c> blankList;
    public String CRON_EXP = '00' + ' ' + '00' + ' ' + '18' + ' '
            + datetime.now().addHours(24).day() + ' ' + datetime.now().addHours(0).month() + ' ? ' + datetime.now().addHours(0).year();
    public String schedule = '0 0 20 * * ? *';

    global void execute(SchedulableContext context) {
        StartJob();
    }

    public void StartJob(){
        list<Emarsys_Contact_Subscriptions__c> EmarsysContactSubscriptions = Emarsys_Contact_Subscriptions__c.getAll().values();
        list<Emarsys_Contact_Subscriptions__c> ListEmarsysSubscriptions = new list<Emarsys_Contact_Subscriptions__c>();
        for (Emarsys_Contact_Subscriptions__c EmarsysSubscriptions : EmarsysContactSubscriptions){
            if(((System.Test.isRunningTest()) || EmarsysSubscriptions.Segment_Id__c !=Null && EmarsysSubscriptions.Run_id__c == Null && EmarsysSubscriptions.Last_Update_Segment_Date__c < Datetime.newInstance(date.today(), Time.newInstance(18, 0,0,0))
                    && Datetime.now().time()>Time.newInstance(18, 0, 0, 0) && Datetime.now().time()< Time.newInstance(23, 59, 0, 0))
                         || (EmarsysSubscriptions.Segment_Id__c !=Null && EmarsysSubscriptions.Run_id__c == Null && EmarsysSubscriptions.Last_Update_Segment_Date__c < Datetime.newInstance(date.today()-1, Time.newInstance(18, 0,0,0))
                            && Datetime.now().time()>Time.newInstance(0, 0, 0, 0) && Datetime.now().time()< Time.newInstance(8, 0, 0, 0))){
                ListEmarsysSubscriptions.add(EmarsysSubscriptions);
            }
        }
        if(!ListEmarsysSubscriptions.isEmpty()){
            System.debug('ListEmarsysSubscriptions ' + ListEmarsysSubscriptions);
            System.enqueueJob(new EmarsysContactRunQueueable(ListEmarsysSubscriptions, blankList));
        }

        if (ExecutedJobs().size()<1) {
            scheduleRequest('RunScheduler at 20:00', schedule);
            System.debug('RunScheduler  at 20');
        } else {
            AbortedJobs();
            scheduleRequest('RunScheduler at 18:00', CRON_EXP);
            System.debug('RunScheduler at 18 next day' );
        }
    }

    private static void scheduleRequest(String scheduleName, String cron_exp) {
        EmarsysContactRunSchedule EmarsysContactRunSchedule = new EmarsysContactRunSchedule();
        System.schedule(scheduleName, cron_exp, EmarsysContactRunSchedule);
    }

    public List<CronTrigger> ExecutedJobs() {
        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE '%RunScheduler%' AND StartTime = TODAY
                LIMIT 3];

        return jobsList;
    }

    public List<CronTrigger> AbortedJobs() {
        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE '%RunScheduler%'

        ];
        if (! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
                 }
            }
        return null;
    }
}
