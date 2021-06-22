global class EmarsysAllLogsSchedule implements Schedulable {

    public String emailName;
    public String campaignName;
    public String emarsysContactType;

    /*******************************************************************************
    *  Name            : EmarsysAllLogsSchedule(String emailName, String campaignName, String emarsysContactType)
    *  Summary         : constructor
    *  CreatedDate     : 10/02/2017
    *  Parameters      : String emailName - email name for log, String campaignName -
                        campaign for log, String emarsysContactType - type of parent sobject for log
    *  Returns         :
    ******************************************************************************/
    public EmarsysAllLogsSchedule(String emailName, String campaignName, String emarsysContactType) {
        this.emailName = emailName;
        this.campaignName = campaignName;
        this.emarsysContactType = emarsysContacttype;
    }


    /*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute batch for creating logs
    *  CreatedDate     : 10/02/2017
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc) {
        try {
            EmarsysAllLogsBatch blcl = new EmarsysAllLogsBatch(this.emailName, this.campaignName, this.emarsysContacttype);
            Database.executeBatch(blcl);

            List<CronTrigger> jobsList = [
                    SELECT Id
                    FROM CronTrigger
                    WHERE CronJobDetail.Name LIKE '%Emarsys EU Creating Logs%'
                    AND NextFireTime = null
                    LIMIT 100
            ];
            if (! jobsList.isEmpty()) {
                for (CronTrigger job : jobsList) {
                    System.abortJob(job.Id);
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }
}