public class ETEJobsQueue implements Queueable, Database.AllowsCallouts {
    private String jobToRunName;
    private ETEJobExecutor jobExecutorImpl;
    private ETEDatabaseInterface e2eDatabase;
    private String dataObjectId;
    private E2E_Data_Log__c existingJobInDataBase;
    private Map<String, E2E_Data_Log__c>  existingJobsMap;


    public ETEJobsQueue (List<String> jobsNeededToRun, String dataObjectId, String countryCode, String implKey) {
        this.dataObjectId = dataObjectId;
        jobExecutorImpl = ETEGlobalUtils.getJobExecutor(jobsNeededToRun, dataObjectId, countryCode, implKey);
        jobToRunName = jobsNeededToRun.get(0);
        e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        existingJobsMap = returnExistingJobs(e2eDatabase, this.dataObjectId);
        existingJobInDataBase = existingJobsMap.get(jobToRunName);
    }


    public void execute(QueueableContext sc) {
        try {
            switch on jobToRunName {
                when 'checkBusinessObjects' {
                    jobExecutorImpl.checkBusinessObjects(e2eDatabase, existingJobInDataBase);
                } when 'reportRequest' {
                    jobExecutorImpl.doReportRequest(e2eDatabase, existingJobInDataBase);
                } when 'deduplication' {
                    jobExecutorImpl.doDeduplication(e2eDatabase, existingJobInDataBase);
                } when 'syncProductsAndServices',
                        'syncContactData',
                        'syncCompanyDetails',
                        'syncAdditionalServices',
                        'syncCreditDecisionsData',
                        'syncDocumentsAgreements',
                        'syncPaymentDetails',
                        'syncPaymentData',
                        'syncFinishedDeal' {
                    jobExecutorImpl.syncData(e2eDatabase, existingJobsMap, existingJobInDataBase, jobToRunName);
                }
            }
        } catch (Exception e) {
            existingJobInDataBase.Exception_Type__c = 'System Error';
            existingJobInDataBase.Job_Status__c = 'Failed';
            existingJobInDataBase.Exception_Description__c = e.getMessage() + ': ' + e.getStackTraceString();
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{existingJobInDataBase});
        }
    }


    private Map<String, E2E_Data_Log__c> returnExistingJobs(ETEDatabaseInterface e2eDatabase, String dataObjectId) {
        List<E2E_Data_Log__c> exsistingLogsList = e2eDatabase.retrieveE2EDataLogs(dataObjectId);
        Map<String, E2E_Data_Log__c>  existingJobsMap = new Map<String, E2E_Data_Log__c>();
        for (E2E_Data_Log__c job : exsistingLogsList) {
            existingJobsMap.put(job.Name, job);
        }
        return existingJobsMap;
    }
}
