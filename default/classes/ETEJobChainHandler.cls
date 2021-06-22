public class ETEJobChainHandler {
    public List<String> jobsNeededToRun;
    public String dataObjectId;
    public String countryCode;
    public String implKey;
    public Map<String, E2E_Data_Log__c> exsistingJobsMap;


    public ETEJobChainHandler(List<String> jobsNeededToRun, String dataObjectId, String countryCode, String implKey) {
        this.jobsNeededToRun = jobsNeededToRun;
        this.dataObjectId = dataObjectId;
        this.countryCode = countryCode;
        this.implKey = implKey;
    }


    public void runNext() {
        setExistingJobs();
        this.jobsNeededToRun = setFinalJobsNeededToRunList();
        if (hasNext()) { runJob(); }
    }


    public void runJob() {
        if (this.exsistingJobsMap == null) {
            setExistingJobs();
            this.jobsNeededToRun = setFinalJobsNeededToRunList();
        }
        String jobNameToRun = this.jobsNeededToRun.get(0);
        E2E_Data_Log__c exsistingJob = this.exsistingJobsMap.get(jobNameToRun);
        String jobId = System.enqueueJob(new ETEJobsQueue(this.jobsNeededToRun, this.dataObjectId, this.countryCode, this.implKey));
        exsistingJob.Job_ID__c = jobId;
        exsistingJob.Job_Status__c = 'Queued';
        update exsistingJob;
    }


    private Boolean hasNext() {
        return this.jobsNeededToRun.size() > 0;
    }


    private void setExistingJobs() {
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(this.countryCode);
        List<E2E_Data_Log__c> exsistingLogsList = e2eDatabase.retrieveE2EDataLogs(this.dataObjectId);
        this.exsistingJobsMap = new Map<String, E2E_Data_Log__c>();
        for (E2E_Data_Log__c job : exsistingLogsList) {
            if (job.RecordType.Name == 'Job Status') {
                this.exsistingJobsMap.put(job.Name, job);
            }
        }
    }


    private List<String> setFinalJobsNeededToRunList() {
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(this.countryCode);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(this.implKey);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        List<Object> defaultSettingsByStepsList = (List<Object>) defaultSettingsMap.get('steps');
        List<String> jobsToRunInCorrectOrder = new List<String>();
        for (Object stepDefaultSettingsObject : defaultSettingsByStepsList) {
            Map<String, Object> stepDefaultSettings = (Map<String, Object>) stepDefaultSettingsObject;
            List<Object> jobsToRunSettingsObjects = (List<Object>) stepDefaultSettings.get('jobs_to_run');
            for (Object jobToRunSettingsObject : jobsToRunSettingsObjects) {
                Map<String, Object> jobToRunSettings = (Map<String, Object>) jobToRunSettingsObject;
                jobsToRunInCorrectOrder.addAll(jobToRunSettings.keySet());
            }
        }
        List<String> jobsNeededToRunFinalList = new List<String>();
        for (String jobName : jobsToRunInCorrectOrder) {
            if (! jobsNeededToRunFinalList.contains(jobName)) {
                if (this.exsistingJobsMap.containsKey(jobName)) {
                    E2E_Data_Log__c exsistingJob = this.exsistingJobsMap.get(jobName);
                    if (this.jobsNeededToRun.contains(jobName)) {
                        jobsNeededToRunFinalList.add(jobName);
                    } else if (exsistingJob.Job_Status__c != 'Completed') {
                        jobsNeededToRunFinalList.add(jobName);
                        if (exsistingJob.Job_ID__c != null && exsistingJob.Job_Status__c == 'Queued') {
                            System.abortJob(exsistingJob.Job_ID__c);
                        }
                    }
                }
            }
        }
        if (this.exsistingJobsMap.containsKey('syncFinishedDeal')) {
            E2E_Data_Log__c finishedDealJob = this.exsistingJobsMap.get('syncFinishedDeal');
            if (finishedDealJob.Job_Status__c != 'Completed') {
                jobsNeededToRunFinalList.add('syncFinishedDeal');
                if (finishedDealJob.Job_ID__c != null) {
                    System.abortJob(finishedDealJob.Job_ID__c);
                }
            }
        }
        return jobsNeededToRunFinalList;
    }
}
