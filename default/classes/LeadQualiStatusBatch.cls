global class LeadQualiStatusBatch implements Database.Batchable<sObject> {
    public String query;

    /*******************************************************************************
    *  Name            : LeadQualiStatusBatch()
    *  Summary         : Get select Lead for batch   
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    global LeadQualiStatusBatch() {
        this.query = 'SELECT Status, Quali_Status__c, CreatedDate ' + 
                    'FROM Lead ' + 
                    'WHERE Country = \'Poland\' AND ' +
                        'Sec_Channel__c = \'JITB\' AND ' +
                        'Status = \'Quick Process\' AND ' +
                        'Quali_Status__c = \'Offer sent\'';
    }

    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc) 
    *  Summary         : Collect SObjects to pass to the interface method execute 
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }


    /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, list<Sobject> scope)
    *  Summary         : update Status and QualiStatus   
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext BC, list<Sobject> scope
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        if ( ! scope.isEmpty()) {
            List<Lead> leadsToUpdateList = new List<Lead>();
            for (Sobject so : scope) {
                Lead lead = (Lead)so;
                Integer daysInStatus;

                daysInStatus = (Date.valueOf(lead.CreatedDate)).daysBetween(Date.today());

                if (daysInStatus > 25) {
                    lead.Status = 'Disqualified';
                    lead.Quali_Status__c = 'No reply – Quick Process';

                    leadsToUpdateList.add(lead);
                }
            }
            
            if ( ! leadsToUpdateList.isEmpty()) {
                // 10/05/2018 Use Queueable class for fix DML operation(can't do update)
                System.enqueueJob(new QueueClass(leadsToUpdateList));
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

    public class QueueClass implements Queueable {
        List<SObject> sObjectsList;


        /*******************************************************************************
        *  Name            : QueueClass(List<SObject> sObjectsList)
        *  Summary         : constructor
        *  CreatedDate     : 10/05/2018
        *  ModifiedDate    : -
        *  Parameters      : List<SObject> sObjectsList - sObjects to update
        *  Returns         : -
        ******************************************************************************/
        public QueueClass(List<SObject> sObjectsList) {
            this.sObjectsList = sObjectsList;
        }


        /*******************************************************************************
        *  Name            : execute(QueueableContext context)
        *  Summary         : update Status and Quali_Status__c in SObject      
        *  CreatedDate     : 10/05/2018
        *  ModifiedDate    : -
        *  Parameters      : QueueableContext context - contains the job ID
        *  Returns         : void
        ******************************************************************************/
        public void execute(QueueableContext context) {
            try {
                update sObjectsList;
            } catch (Exception e) {
                Set<Id> IdsSet = new Set<Id>();
                for (SObject so : sObjectsList) {
                    IdsSet.add(so.Id);
                }
                ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Lead Id : ' + IdsSet, String.valueOf(e.getStackTraceString()));
            }
        }
    }
}