public with sharing class TransferCleanPhonesInLeadsBatch implements Database.Batchable<SObject>, Database.Stateful {

    /****************************************************************************
    *  Name            : TransferCleanPhonesInContactsBatch
    *  Summary         : collects all Russian Leads and inserts cleaned phone numbers in Formatted_phones__c field
    *  CreatedDate     : 02/12/2019
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/

    public String query;
    private final Id LEAD_RECORD_TYPE =  LeadHandler.leadRecordTypes.get(GlobalUtils.LeadRecordTypes.Russian_Sales.name()).getRecordTypeId();
    private List<String> failedRecords = new List<String>();

    public TransferCleanPhonesInLeadsBatch() {
        this.query = 'SELECT Id, Formatted_phones__c, Formatted_phones_additional__c, ' +
                        'Phone, MobilePhone, PPR_Contact_Phone__c, Additional_Phones__c ' +
                        'FROM Lead ' +
                        'WHERE RecordTypeId = :LEAD_RECORD_TYPE ';
    }

    public void execute(Database.BatchableContext context, List<Lead> records) {
        try {
            //transfer phone numbers
            for (Lead lead : records) {
                LeadHandler.unifyPhoneNumbers(lead);
            }
            //update records and collect errors
            for (Database.SaveResult saveResult : Database.update(records, false)) {
                if ( !saveResult.success) {
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
        message.htmlBody = '<div>TransferCleanPhonesInLeadsBatch ' + context.getJobId() + ' finished execution</div><br><div>Errors during execution:</div>';
        for (String failedRecord : this.failedRecords) {
            message.htmlBody += failedRecord + '<br>';
        }
        message.toAddresses = new List<String>{
                'a.syromyatnikov@fleetcor.ru',
                'german.buksh@pprcard.ru',
                'tatiana.kim@transitcard.ru',
                'natalia.skachko@transitcard.ru'
        };
        message.saveAsActivity = false;
        message.senderDisplayName = 'SFDC DEBUG PRODUCTION';
        message.subject = 'TransferCleanPhonesInLeadsBatch execution results';
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(this.query);
    }
}