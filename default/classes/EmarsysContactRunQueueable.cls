/**
 * Created by Yury on 23.09.2020.
 */


public with sharing class EmarsysContactRunQueueable implements Queueable, Database.AllowsCallouts {

    public List<Emarsys_Contact_Subscriptions__c> listEmarsysContactSubscriptionsRunId;
    public List<Emarsys_Contact_Subscriptions__c> EmarsysContactSubscriptions;
    String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());


    public EmarsysContactRunQueueable(List<Emarsys_Contact_Subscriptions__c> EmarsysContact, List<Emarsys_Contact_Subscriptions__c> StrParam) {
        this.EmarsysContactSubscriptions = EmarsysContact;
        this.listEmarsysContactSubscriptionsRunId = StrParam;
    }

    public void execute(QueueableContext context) {

        if (!EmarsysContactSubscriptions.isEmpty()) {
            System.debug('EmarsysContactSubscriptions ' +EmarsysContactSubscriptions);

            String resBody = EmarsysWebService.getRunIdInSegment(EmarsysContactSubscriptions[0].Segment_Id__c, emarsysAccount);

            if (!resBody.contains('"data":""')) {
                System.debug('data ' + resBody);
                EmarsysRunIdDataEntity listingEntity = (EmarsysRunIdDataEntity) JSON.deserialize(resBody, EmarsysRunIdDataEntity.class);
                String RunId = listingEntity.data.run_id;
                EmarsysContactSubscriptions[0].Run_id__c = RunId;
                System.debug('run id ' + RunId);
            }

            list<Emarsys_Contact_Subscriptions__c> EmarsysContactSubscriptionsClone = EmarsysContactSubscriptions.clone();
            list<Emarsys_Contact_Subscriptions__c> ListEmarsysRunId = new list<Emarsys_Contact_Subscriptions__c>();
            if(listEmarsysContactSubscriptionsRunId != null){
                ListEmarsysRunId = listEmarsysContactSubscriptionsRunId;
            }
            ListEmarsysRunId.add(EmarsysContactSubscriptionsClone[0]);
            listEmarsysContactSubscriptionsRunId = ListEmarsysRunId;

             EmarsysContactSubscriptions.remove(0);


        }
        if (!EmarsysContactSubscriptions.isEmpty()) {
            System.enqueueJob(new EmarsysContactRunQueueable(EmarsysContactSubscriptions, listEmarsysContactSubscriptionsRunId));
        }
        else if (!listEmarsysContactSubscriptionsRunId.isEmpty()) {
            System.debug('update ' + listEmarsysContactSubscriptionsRunId);
            {
                try {
                    update listEmarsysContactSubscriptionsRunId;
                } catch (DmlException e) {
                    System.debug('exception: ' + e.getMessage());
                }
            }
        }
    }
}
