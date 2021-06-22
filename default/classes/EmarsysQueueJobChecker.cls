public with sharing class EmarsysQueueJobChecker implements Queueable, Database.AllowsCallouts {
    private static final String STATUS = 'status';
    private static final String STATUS_DONE = 'done';
    private static final String RESULT = 'result';
    private static final String CONTACT_LIST_ID = 'contact_list_id';
    private static final String DATA = 'data';
    private static final String REPLY_CODE = 'replyCode';

    private List<Emarsys_Contact_Subscriptions__c> segments;
    private String emarsysAccount;

    public EmarsysQueueJobChecker(List<Emarsys_Contact_Subscriptions__c> segments, String emarsysAccount) {
        this.segments = segments;
        this.emarsysAccount = emarsysAccount;
    }

    public void execute(QueueableContext context) {
        if (segments != null && segments.size() > 0) {
            Emarsys_Contact_Subscriptions__c segment = segments[0];
            
            if (String.isNotBlank(segment.Run_id__c)) {
                String body = EmarsysWebService.getStatusOfSegmentRun(segment.Run_id__c, emarsysAccount);
                Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);
                Integer replyCode  = (Integer) bodyMap.get(REPLY_CODE);
                if (replyCode ==  0) {
                    Map<String, Object> data = (Map<String, Object>) bodyMap.get(DATA);
                    String status = (String) data.get(STATUS);

                    if (status == STATUS_DONE) {
                        Map<String, Object> resultObjectMap = (Map<String, Object>) data.get(RESULT);
                        segment.Contact_List_Id__c = String.valueOf(resultObjectMap.get(CONTACT_LIST_ID));
                        if (String.isNotEmpty(segment.Contact_List_Id__c)) {
                            update segment;
                            segments.remove(0);
                        }
                    }
                } else {
                    segments.remove(0);
                }

                if (segments.isEmpty()) {
                    scheduleEmarsysJob();
                } else  {
                    System.enqueueJob(new EmarsysQueueJobChecker(segments, emarsysAccount));
                }
            }
        } else {
            scheduleEmarsysJob();
        }
    }

    private void scheduleEmarsysJob() {
        Datetime currentValue = Datetime.now();
        Integer minutes = currentValue.minute() + 30;
        Integer hours = currentValue.hour() + 1;
        if (minutes > 59) {
            minutes = minutes - 60;
            hours++;
        }
        hours = (hours > 23) ? hours - 24 : hours;

        EmarsysContactsJobService.scheduleJob(EmarsysJobCheckerScheduler.JOB_NAME, minutes, hours, EmarsysContactsJobService.JobTypes.JOB_CHECK);
    }
}