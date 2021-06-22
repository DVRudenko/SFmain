global class E2ESwitchToManualBatch implements Database.Batchable<sObject> {
    public String query;
    public Set<String> e2eStatus = new Set<String>{
            'Abandoned (hard)',
            'Abandoned (soft)',
            'Rejected',
            'Finished'
    };    

    global E2ESwitchToManualBatch() {
        this.query = 'SELECT Id, OwnerId, E2E_Sub_Status__c, E2E_Sales_Type__c, E2E_Status__c, Account.BillingCountry, StageName, Number_of_open_tasks__c, ' +
                            '(SELECT Email_Name__c, CreatedDate FROM Emarsys_Logs__r) ' +
                     'FROM Opportunity ' +
                     'WHERE E2E__c = TRUE AND ' +
                            'IsClosed != TRUE AND ' +
                            '(((E2E_Status__c = \'Abandoned (hard)\' OR  E2E_Status__c = \'Abandoned (soft)\') AND E2E_Sub_Status__c = \'Marketing automation\') OR ' + 
                            'E2E_Sales_Type__c = \'Manual upgraded to E2E\')';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        System.enqueueJob(new E2ESwitchToManualQueueable(scope));
    }

    global void finish(Database.BatchableContext BC) {
        reStartSchedule();
    }

    /*******************************************************************************
    *  Name            : reStartSchedule()
    *  Summary         : Restart schedule job
    *  CreatedDate     : 31/08/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void reStartSchedule() {
        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'E2E Switch To Manual Schedule%' AND PreviousFireTime != null
                LIMIT 100
        ];
        if ( ! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }

        String schedule = datetime.now().addMinutes(16).second() + ' ' + datetime.now().addMinutes(16).minute() + ' *' + ' ?' + ' *' + ' *';
        E2ESwitchToManualSchedule scheduleSwitchToManual = new E2ESwitchToManualSchedule();
        System.schedule('E2E Switch To Manual Schedule' + ' ' + datetime.now().addMinutes(16) + '(' + math.random() + ')', schedule, scheduleSwitchToManual);
    }
}