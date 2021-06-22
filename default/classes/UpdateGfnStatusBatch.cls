global with sharing class UpdateGfnStatusBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private String query;
    private GFNI_Batch_Settings__c updateBatchSetting;
    public UpdateGfnStatusBatch(GFNI_Batch_Settings__c updateBatchSetting) {
        this.query = 'SELECT Id, Gfn_Nr__c, Gfn_Number__c, RecordTypeId, ColCo__c, ColCoID__c FROM ERP__c';
        this.updateBatchSetting = updateBatchSetting;
        if(updateBatchSetting != null) {
            if(updateBatchSetting.Where_Condition__c != null) {
                this.query = this.query + ' WHERE ' + updateBatchSetting.Where_Condition__c;
            }
            if(updateBatchSetting.Query_Limit__c != null) {
                this.query = this.query + ' LIMIT ' + updateBatchSetting.Query_Limit__c;
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            return Database.getQueryLocator(this.query);
        } catch(Exception e) {
            UpdateGfnStatusBatchHandler.saveLogs(e.getMessage());
            UpdateGfnStatusBatchHandler.sendErrorMessage(e, this.updateBatchSetting.Error_Message_Reciever__c);
            return Database.getQueryLocator('SELECT Id FROM ERP__c LIMIT 0');
        }
    }


    global void execute(Database.BatchableContext BC, List<ERP__c> erpList) {
        try{
            UpdateGfnStatusBatchHandler.getGfnStatuses(erpList);
        } catch(Exception e) {
            UpdateGfnStatusBatchHandler.saveLogs(e.getMessage());
            UpdateGfnStatusBatchHandler.sendErrorMessage(e, this.updateBatchSetting.Error_Message_Reciever__c);
        }
    }


    global void finish(Database.BatchableContext BC) {

    }
}
