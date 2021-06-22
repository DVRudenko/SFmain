global class EmarsysContactIdsGathererSchedule implements Schedulable {
    public static final String JOB_NAME = 'Emarsys Gahter Contact Ids';
    public static final String FIRST_RUN_CRON = '0 0 2 ? * MON-FRI';

    /*******************************************************************************
     *  Name            : execute(SchedulableContext sc)
     *  Summary         : run job for get contact list in EmarsysContactIdsGatherer
     *  CreatedDate     : 07/10/2020
     *  Parameters      : Schedulable sc - object to track the schedulable job
     *  Returns         : void
     ******************************************************************************/
    global void execute(SchedulableContext sc) {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        Datetime yesterdayEndDate = Datetime.newInstance(Date.today().addDays(-1), Time.newInstance(18, 0, 0, 0));

        List<Emarsys_Contact_Subscriptions__c> conSubList = [
                SELECT Id, Contact_list_id__c, Segment_Id__c
                FROM Emarsys_Contact_Subscriptions__c
                WHERE Contact_list_id__c != NULL AND Last_Update_Segment_Date__c < :yesterdayEndDate
        ];

        Boolean fisrtRun = EmarsysContactsJobService.checkIsFirstLaunch(JOB_NAME, FIRST_RUN_CRON);

        if (conSubList.isEmpty()) {
            EmarsysContactsJobService.scheduleJob(JOB_NAME, 0, fisrtRun ? 3 : 2, EmarsysContactsJobService.JobTypes.JOB_CONT_RETRIEV);
        } else {
            EmarsysContactIdsGatherer conIdGatherer = new EmarsysContactIdsGatherer(conSubList, emarsysAccount);
            System.enqueueJob(conIdGatherer);
        }
    }
}
