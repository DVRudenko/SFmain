public class TemporaryBatchToUpdateClientOfferAS implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT  Account__c, Opportunity__r.AccountId
                FROM    Client_Offer_Additional_Service__c
                WHERE   CreatedDate >= 2020-01-01T01:01:01Z AND
                        Opportunity__r.AccountId != NULL AND
                        Account__c = NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Client_Offer_Additional_Service__c> scope) {
        ClientOfferAddServiceHandler.enablesTrigger = false;
        for (Client_Offer_Additional_Service__c n : scope) {
            n.Account__c = n.Opportunity__r.AccountId;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {}
}