public class TemporaryBatchToUpdateOppLineItems implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT  Account__c, Opportunity.AccountId
                FROM    OpportunityLineItem
                WHERE   CreatedDate >= 2020-01-01T01:01:01Z AND
                        Opportunity.AccountId != NULL AND
                        Account__c = NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope) {
        for (OpportunityLineItem n : scope) {
            n.Account__c = n.Opportunity.AccountId;
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {}
}
