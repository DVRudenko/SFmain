global class EmarsysJobCheckerScheduler implements Schedulable {
    global static final String JOB_NAME = 'Emarsys job cheker (second request)';
    global static final String FIRST_RUN_CRON = '0 0 0 ? * MON-FRI';

    global void execute(SchedulableContext SC) {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        List<Emarsys_Contact_Subscriptions__c> segments = [
            SELECT Run_id__c
            FROM Emarsys_Contact_Subscriptions__c
            WHERE Run_id__c != NULL AND Contact_List_Id__c = NULL
        ];

        Boolean fisrtRun = EmarsysContactsJobService.checkIsFirstLaunch(JOB_NAME, FIRST_RUN_CRON);

        if (segments.size() > 0) {
            System.enqueueJob(new EmarsysQueueJobChecker(segments, emarsysAccount));
        } else {
            EmarsysContactsJobService.scheduleJob(JOB_NAME, fisrtRun ? 30 : 0, fisrtRun ? 1 : 0, EmarsysContactsJobService.JobTypes.JOB_CHECK);
        }
    }
}