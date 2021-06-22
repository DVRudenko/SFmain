public with sharing class PPR_API_ArchiveCustomLogSchedule implements Schedulable{


    public void execute(SchedulableContext param1) {
        Database.executeBatch(new ArchiveCustomLogBatch(Custom_log_archivation_settings__c.getValues('PPR_API')));
    }
}