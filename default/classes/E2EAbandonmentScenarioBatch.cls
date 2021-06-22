global class E2EAbandonmentScenarioBatch implements Database.Batchable<sObject>{

    public String query;
    public Set<Integer> abandonmentSteps = new Set<Integer> { 0, 1, 2, 3, 4 };
    public Set<String> e2eStatus = new Set<String>{
            'Abandoned (hard)',
            'Abandoned (soft)',
            'Rejected',
            'Finished',
            'Ordering Credit Report'
    };

    global E2EAbandonmentScenarioBatch(){
        this.query = '';
        this.query = 'SELECT Id, Name, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Last_Activity__c, OwnerId, IsClosed, E2E_Manual_Adoption_Date__c, E2E_Assistant__c, ' +
                'E2E_Status__c, E2E_Sub_Status__c, E2E_Sales_Type__c, RecordTypeId, Account.BillingCountry, E2E__c, LeadSource, Channel__c ';
        this.query +=' FROM Opportunity ';
        this.query +=' WHERE ';
        //EU conditions
        this.query +=' (E2E__c = TRUE ';
        this.query +='  AND IsClosed = FALSE ';
        this.query +='  AND StageName != \'Pending Sales – Deposit\' ';
        this.query +='  AND E2E_Status__c NOT IN :e2eStatus ';
        this.query +='  AND E2E_Sub_Status__c != \'Marketing automation\' AND E2E_Sub_Status__c != \'Switched to manual\'';
        this.query +='  AND E2E_Active_Step__c IN :abandonmentSteps ';
        this.query +='  AND Last_E2E_Error__c = \'\' ';
        this.query +='  AND E2E_Last_Activity__c != NULL) ';
        //RU conditions
        this.query +='  OR ';
        this.query +='  (LeadSource = \'E2E Form RU\'';
        this.query +='   AND E2E_Status__c != \'Клиент завершил\'';
        this.query +='   AND E2E_Status__c != \'Отказ от E2E\'';
        this.query +='   AND E2E_Last_Activity__c = LAST_N_DAYS:2 ) ';
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        System.enqueueJob(new E2EAbandonmentScenarioQueueable(scope));
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void finish(Database.BatchableContext bc) {}

}