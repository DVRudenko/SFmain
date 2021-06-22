global class LeadEmarsysCheckerBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Datetime thirtyDays = Datetime.now().addDays(-30);
    private Datetime hour = Datetime.now().addHours(-1);
    private String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
    LeadEmarsysLogService emarsysService = new LeadEmarsysLogService();
    List<Lead> reportLeadsList = new List<Lead>();
    private static Set<String> countrySet = new Set<String>{
        'Germany', 
        'Netherlands', 
        'Belgium-NL', 
        'Belgium-FR',
        'Hungary',
        'Poland'
    };
    public String query;

    global LeadEmarsysCheckerBatch() {
        this.query = 'SELECT Id, ConvertedOpportunityId, IsConverted, Name, Company, Email, Country, LeadSource, Quali_Status__c, Sec_Channel__c, CreatedDate, ' +
                        '(SELECT Id, Email_Name__c, CreatedDate FROM Emarsys_Logs__r), ' +
                        '(SELECT CreatedDate, NewValue, OldValue, Field FROM Histories WHERE Field = \'Quali_Status__c\') ' +
                     'FROM Lead ' + 
                     'WHERE CreatedDate >= :thirtyDays AND ' + 
                        'CreatedDate <= :hour AND ' + 
                        'RecordTypeId = :endkundeRecId AND ' + 
                        'Country IN :countrySet';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        if ( ! scope.isEmpty() ) {
            List<Lead> leadList = new List<Lead>();
            for (Sobject so : scope) {
                Lead lead = (Lead)so;
                leadList.add(lead);
            }
            leadList = emarsysService.checkLeads(leadList);
            this.reportLeadsList.addAll(leadList);
        }
    }

    global void finish(Database.BatchableContext BC) {
        emarsysService.createExcelDocument(this.reportLeadsList);
    }
}