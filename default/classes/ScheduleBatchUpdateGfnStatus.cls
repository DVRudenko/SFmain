public with sharing class ScheduleBatchUpdateGfnStatus implements Schedulable {
    public void execute(SchedulableContext SC) {
        Integer batchSize = 100;
        GFNI_Batch_Settings__c batchSetting;
        List<GFNI_Batch_Settings__c> batchSettingList = [
            SELECT  Batch_Size__c,
                    Query_Limit__c,
                    Where_Condition__c,
                    Error_Message_Reciever__c
            FROM    GFNI_Batch_Settings__c
            WHERE   Active__c = true
            AND     Name = 'Update_Gfn_Status'
        ];
        if(batchSettingList.size() == 1) {
            batchSetting = batchSettingList[0];
            if(batchSettingList[0].Batch_Size__c != null) {
                batchSize = Integer.valueOf(batchSettingList[0].Batch_Size__c);
            }
        }
        Id batchJobId = Database.executeBatch(new UpdateGfnStatusBatch(batchSetting), batchSize);
    }
}
