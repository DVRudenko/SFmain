public with sharing class EmarsysContactIdsGatherer implements Queueable, Database.AllowsCallouts {
    public static final String SUCCESS_REPLY_CODE = '"replyCode":0';
    private List<Emarsys_Contact_Subscriptions__c> contactSubscriptions;
    private String emarsysAccount;

    public EmarsysContactIdsGatherer(List<Emarsys_Contact_Subscriptions__c> contactSubscriptions, String emarsysAccount) {
        this.contactSubscriptions = contactSubscriptions;
        this.emarsysAccount = emarsysAccount;
    }

    public void execute(QueueableContext context) {
        if (contactSubscriptions != null && contactSubscriptions.size() > 0) {
            Emarsys_Contact_Subscriptions__c currentContactSubscription = contactSubscriptions[0];

            if (currentContactSubscription.Contact_list_id__c != null) {
                String contactsListResponse = EmarsysWebService.getContactList(currentContactSubscription.Contact_list_id__c, emarsysAccount);

                if (contactsListResponse.contains(SUCCESS_REPLY_CODE)) {
                    EmarsysListingContactsEntity emarsysResponse = (EmarsysListingContactsEntity) JSON.deserialize(
                            contactsListResponse,
                            EmarsysListingContactsEntity.class
                    );

                    if (emarsysResponse != null && emarsysResponse.data != null && !emarsysResponse.data.isEmpty() && !Test.isRunningTest()) {
                        System.debug('run batch ');
                        EmarsysRusReactionLogsBatch reactionLogsBatch = new EmarsysRusReactionLogsBatch(
                                emarsysResponse.data,
                                currentContactSubscription.Segment_Id__c
                        );
                        Database.executeBatch(reactionLogsBatch);
                    }
                }

                currentContactSubscription.Contact_list_id__c = null;
                currentContactSubscription.Run_id__c = null;
                currentContactSubscription.Last_Update_Segment_Date__c = Datetime.now();
                update currentContactSubscription;
                contactSubscriptions.remove(0);
            }

            if (contactSubscriptions.isEmpty()) {
                scheduleEmarsysJob();
            } else {
                System.enqueueJob(new EmarsysContactIdsGatherer(contactSubscriptions, emarsysAccount));
            }
        } else {
            scheduleEmarsysJob();
        }
    }

    private void scheduleEmarsysJob() {
        Datetime currentValue = Datetime.now();
        Integer minutes = currentValue.minute();
        Integer hours = currentValue.hour() + 1;
        hours = (hours > 23) ? hours - 24 : hours;

        EmarsysContactsJobService.scheduleJob(
                EmarsysContactIdsGathererSchedule.JOB_NAME,
                minutes,
                hours,
                EmarsysContactsJobService.JobTypes.JOB_CONT_RETRIEV
        );
    }
}
