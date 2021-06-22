global class OpportunityEmarsysCheckerBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Datetime thirtyDays = Datetime.now().addDays(-30);
    private Datetime hour = Datetime.now().addHours(-1);
    private Set<String> recordTypeIdsSet = new Set<String>{
        GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'),
        GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts')
    };
    OpportunityEmarsysLogService emarsysService = new OpportunityEmarsysLogService();
    List<Opportunity> reportOpportunitiesList = new List<Opportunity>();
    private static Set<String> countrySet = new Set<String>{
        'Germany', 
        'Netherlands', 
        'Belgium-NL', 
        'Belgium-FR',
        'Hungary',
        'Poland', 
        'France'
    };
    public String query;

    global OpportunityEmarsysCheckerBatch() {
        this.query = 'SELECT Id, Name, StageName, E2E_Sales_Type__c, Sec_Channel__c, Registered_Country__c, Security_Amount_To_Pay__c, ' + 
                            'E2E_payment_status__c, E2E_Active_Step__c, E2E_Switch_To_Manual__c, Account.BillingCountry, CreatedDate, ' + 
                            'Zahlungsart__c, E2E_Status__c, E2E_Sub_Status__c, ' + 
                         '(SELECT Id ' + 
                         'FROM OpportunityContactRoles ' + 
                         'WHERE IsPrimary = TRUE AND Contact.Email != NULL AND Contact.LastName != NULL AND Contact.FirstName != NULL AND Contact.Salutation != NULL), ' + 
                         '(SELECT Id, Email_Name__c, CreatedDate FROM Emarsys_Logs__r), ' +
                         '(SELECT CreatedDate, NewValue, OldValue, Field FROM Histories) ' +
                     'FROM Opportunity ' +
                     'WHERE CreatedDate >= :thirtyDays AND ' + 
                         'CreatedDate <= :hour AND ' + 
                         'RecordTypeId IN :recordTypeIdsSet AND ' + 
                         'Account.BillingCountry IN :countrySet AND ' +
                         'E2E__c = TRUE';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        if ( ! scope.isEmpty() ) {
            List<Opportunity> opportunityList = new List<Opportunity>();
            for (Sobject so : scope) {
                Opportunity lead = (Opportunity)so;
                opportunityList.add(lead);
            }
            opportunityList = emarsysService.checkOpportunities(opportunityList);
            this.reportOpportunitiesList.addAll(opportunityList);
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (! this.reportOpportunitiesList.isEmpty()) {
            emarsysService.createExcelDocument(this.reportOpportunitiesList);
        }
    }
}