public with sharing class TransferCleanPhonesInContactsBatch implements Database.Batchable<SObject>, Database.Stateful {

    /****************************************************************************
    *  Name            : TransferCleanPhonesInContactsBatch
    *  Summary         : collects all Russian Contacts and inserts cleaned phone numbers in Formatted_phones__c field
    *  CreatedDate     : 02/12/2019
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    public String query;
    private final Id CONTACT_RECORD_TYPE = ContactTriggerHandler.contactRecordTypes.get(GlobalUtils.ContactRecordTypes.Russian.name()).getRecordTypeId();
    private List<String> failedRecords = new List<String>();

    public TransferCleanPhonesInContactsBatch() {
        this.query = 'SELECT Id, Formatted_phones__c, Formatted_phones_additional__c, Phone, ' +
                'MobilePhone, PPR_Contact_Phone__c, Additional_Phones__c, ' +
                'HomePhone, OtherPhone, AssistantPhone ' +
                'FROM Contact ' +
                'WHERE RecordTypeId = :CONTACT_RECORD_TYPE ';
    }

    public void execute(Database.BatchableContext context, List<Contact> records) {
        try {
            //transfer phone numbers
            for (Contact contact : records) {
                ContactTriggerHandler.unifyPhoneNumbers(contact);
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
        message.htmlBody = '<div>TransferCleanPhonesInContactsBatch ' + context.getJobId() +  ' finished execution</div><br><div>Errors during execution:</div>';
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
        message.subject = 'TransferCleanPhonesInContactsBatch execution results';
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(this.query);
    }

}