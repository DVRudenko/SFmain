global without sharing class CTI_cleanUpSchedulableBatch implements Database.Batchable<sObject>, Schedulable {
    
    global CTI_cleanUpSchedulableBatch() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date lastCreatedDate = Date.today() - 100;
        String query = 'SELECT  Name, CreatedDate FROM Call_History_Item__c WHERE   CreatedDate <: lastCreatedDate';
	    return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
	
    }

    global void execute(SchedulableContext SC) {
 	    Database.ExecuteBatch(new CTI_cleanUpSchedulableBatch());
    }
}