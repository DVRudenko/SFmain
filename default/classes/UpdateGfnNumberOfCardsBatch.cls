global with sharing class UpdateGfnNumberOfCardsBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private String query;
    private GFNI_Batch_Settings__c updateBatchSetting;
    private List<UpdateGfnNumberOfCardsBatchHandler.ExceptionWrapper> errorList = new List<UpdateGfnNumberOfCardsBatchHandler.ExceptionWrapper>();
    // private Map<String, Exception> errorMap = new Map<String, Exception>();
    public UpdateGfnNumberOfCardsBatch(GFNI_Batch_Settings__c updateBatchSetting) {
        this.query = 'SELECT Id, Gfn_Nr__c, Gfn_Number__c, RecordTypeId, ColCo__c, ColCoID__c FROM ERP__c';
        this.updateBatchSetting = updateBatchSetting;
        System.debug(' updateBatchSetting=== ' + updateBatchSetting);
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
            UpdateGfnNumberOfCardsBatchHandler.updateGfnNumberOfCards(erpList, errorList);
            if(errorList.size() > 50) {
                UpdateGfnNumberOfCardsBatchHandler.handleErrors(this.updateBatchSetting.Error_Message_Reciever__c, this.errorList);
                this.errorList.clear();
            }
        } catch(Exception e) {
            UpdateGfnStatusBatchHandler.saveLogs(e.getMessage());
            UpdateGfnStatusBatchHandler.sendErrorMessage(e, this.updateBatchSetting.Error_Message_Reciever__c);
        }
    }


    global void finish(Database.BatchableContext BC) {
        UpdateGfnNumberOfCardsBatchHandler.handleErrors(this.updateBatchSetting.Error_Message_Reciever__c, this.errorList);
    }
}
