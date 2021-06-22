public with sharing class ScheduleBatchUpdateGfnNumberOfCards implements Schedulable {

    public void execute(SchedulableContext SC) {
        // GFNI_Utils.runGfnRelatedBatch(new UpdateGfnNumberOfCardsBatch(batchSetting), 'Update_Gfn_Number_of_cards', 100);
        Integer batchSize = 100;
        GFNI_Batch_Settings__c batchSetting = GFNI_Utils.getGfnRelatedBatchSettings('Update_Gfn_Number_of_cards');
        if(batchSetting.Batch_Size__c != null && batchSetting.Batch_Size__c < batchSize) {
            batchSize = Integer.valueOf(batchSetting.Batch_Size__c);
        }
        Id batchJobId = Database.executeBatch(new UpdateGfnNumberOfCardsBatch(batchSetting), batchSize);
    }

}
