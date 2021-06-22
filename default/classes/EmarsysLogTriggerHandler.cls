public class EmarsysLogTriggerHandler {

    public static void updateLeadStatus(List<Emarsys_Log__c> emarsysLogList) {
        Set<Id> leadIdSet = getRelatedLeadIds(emarsysLogList);
        List<Lead> leadListForUpdate = [
                SELECT  Id
                FROM    Lead
                WHERE   Id IN : leadIdSet
                AND     E2E_Adoption_Status__c	!= 'Adoption Email Sent'
        ];
        for(Lead lead : leadListForUpdate){
            lead.E2E_Adoption_Status__c = 'Adoption Email Sent';
            lead.E2E_Adoption_Date__c = Date.today();
        }
        //update leadListForUpdate;
        System.enqueueJob(new QueueClass(leadListForUpdate));
    }

    private static Set<Id> getRelatedLeadIds(List<Emarsys_Log__c> emarsysLogList){
        Set<Id> leadIdSet = new Set<Id>();
        for(Emarsys_Log__c log : emarsysLogList){
            if(log.Lead__c != null){
                leadIdSet.add(log.Lead__c);
            }
        }
        return leadIdSet;
    }

    public class QueueClass implements Queueable {
        List<SObject> sObjectsList;

        public QueueClass(List<SObject> sObjectsList) {
            this.sObjectsList = sObjectsList;
        }


        public void execute(QueueableContext context) {
            try {
                update sObjectsList;
            } catch (Exception e) {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }
}