public without sharing class CFRuBatch implements Database.Batchable<SObject>, Database.Stateful {

    /****************************************************************************
    *  Name            : CFRuBatch
    *  Summary         : fix field values related to CFIntegrationLogic for Russia
    *  CreatedDate     : 29/01/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    public String query;
    private final Id OPPORTUNITY_RECORD_TYPE = OpportunityTriggerHandler.RUSSIAN_RECORD_TYPE_ID;
    private List<String> failedRecords = new List<String>();

    public CFRuBatch() {
        this.query = 'SELECT Id, CF_checking__c ' +
                'FROM Opportunity ' +
                'WHERE CF_checking__c = TRUE ' +
                'AND RecordTypeId = :OPPORTUNITY_RECORD_TYPE';
    }

    public void execute(Database.BatchableContext context, List<Opportunity> records) {
        try {
            // make some changes
            for (Opportunity opportunity : records) {
                opportunity.CF_checking__c = false;
            }
            //update records and collect errors
            for (Database.SaveResult saveResult : Database.update(records, false)) {
                if (!saveResult.success) {
                    String message = '<div>Errors with record ' + saveResult.id + '<br>';
                    for (Database.Error error : saveResult.errors) {
                        message += error.getMessage() + '. In fields: ' + error.getFields() + '<br>';
                    }
                    message += '</div>';
                    this.failedRecords.add(message);
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(e.getMessage(), e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext context) {
        //send notification and errors if any
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.htmlBody = '<div>CFRuBatch ' + context.getJobId() +  ' finished execution</div><br><div>Errors during execution:</div>';
        for (String failedRecord : this.failedRecords) {
            message.htmlBody += failedRecord + '<br>';
        }
        message.toAddresses = new List<String>{
                'a.syromyatnikov@fleetcor.ru',
                'tatiana.kim@transitcard.ru'
        };
        message.saveAsActivity = false;
        message.senderDisplayName = 'SFDC DEBUG PRODUCTION';
        message.subject = 'CFRuBatch execution results';
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(this.query);
    }
}