public with sharing class ArchiveCustomLogBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private String query;
    private Date archiveDate;
    private List<String> sources;
    private List<String> failedRecords = new List<String>();
    private Custom_log_archivation_settings__c settings;


    /****************************************************************************
    *  Name            : ArchiveCustomLogBatch
    *  Summary         : transfer Custom_log__c records into big object Common_log__b
    *  CreatedDate     : 14/02/2020
    *  Parameters      : Custom_log_archivation_settings__c settings
    *  Returns         : -
    *****************************************************************************/
    public ArchiveCustomLogBatch(Custom_log_archivation_settings__c settings) {
        try {
            this.settings = settings;
            this.archiveDate = Date.today().addDays(-1 * settings.Days_logs_to_archive__c.intValue());
            this.sources = settings.Sources__c.deleteWhitespace().split('[;]');
            this.query = 'SELECT CreatedDate, E2E_Form_Ru_Data__c, Errors__c, External_user__c, INN__c, Source__c ' +
                        'FROM Custom_log__c ' +
                        'WHERE Source__c IN :sources ' +
                        'AND DAY_ONLY(CreatedDate) <= :archiveDate ' +
                        'ORDER BY CreatedDate DESC';
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }


    public void execute(Database.BatchableContext context, List<Custom_log__c> records) {
        try {
            // make some changes
            List<Common_log__b> bigLogs = new List<Common_log__b>();
            List<Custom_log__c> logsToDelete = new List<Custom_log__c>();
            // for each source
            for (Integer i = 0; i < sources.size(); i++) {
                String source = this.sources.get(i);
                Map<Long, Custom_log__c> unixTimeCustomLogMap = new Map<Long, Custom_log__c>();
                List<String> inns = new List<String>();
                // create map
                for (Custom_log__c log : records) {
                    if (source.equals(log.Source__c)) {
                        unixTimeCustomLogMap.put(log.CreatedDate.getTime(), log);
                    }
                }
                // remove last logs for each INN from Map in order to not archive it
                for (Long unixTime : unixTimeCustomLogMap.keySet()) {
                    if ( !inns.contains(unixTimeCustomLogMap.get(unixTime).INN__c)) {
                        inns.add(unixTimeCustomLogMap.get(unixTime).INN__c);
                        unixTimeCustomLogMap.remove(unixTime);
                    }
                }
                // create big objects
                for (Custom_log__c log : unixTimeCustomLogMap.values()) {
                    Common_log__b commonLog = new Common_log__b(
                            E2E_Form_Ru_Data__c = log.E2E_Form_Ru_Data__c,
                            Created_DateTime__c = log.CreatedDate,
                            Message__c = JSON.serialize(log),
                            Type__c = log.Source__c,
                            Unix_time__c = String.valueOf(log.CreatedDate.getTime())
                    );
                    bigLogs.add(commonLog);
                    logsToDelete.add(log);
                }
            }

            //insert archived log and collect errors
            if ( !Test.isRunningTest()) {
                for (Database.SaveResult saveResult : Database.insertImmediate(bigLogs)) {
                    GlobalUtils.processSaveResult(saveResult, this.failedRecords);
                }
            }
            //delete old logs and collect errors
            for (Database.DeleteResult deleteResult : Database.delete(logsToDelete, false)) {
                GlobalUtils.processDeleteResult(deleteResult, this.failedRecords);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext context) {
        try {
            if (String.isNotBlank(this.settings.Notification_recipients__c)) {
                //send notification and errors if any
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.htmlBody = '<div>ArchiveCustomLogBatch ' + context.getJobId() +  ' for ' + this.settings.Name + ' finished execution</div><br><div>Errors during execution:</div>';
                for (String failedRecord : this.failedRecords) {
                    message.htmlBody += failedRecord + '<br>';
                }
                message.toAddresses = this.settings.Notification_recipients__c.deleteWhitespace().split('[;]');
                message.saveAsActivity = false;
                message.senderDisplayName = 'SFDC DEBUG PRODUCTION';
                message.subject =  this.settings.Name + ' ArchiveCustomLogBatch execution results';
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(this.query);
    }



}