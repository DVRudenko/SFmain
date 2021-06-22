global class UpdateLeadsTempBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    global UpdateLeadsTempBatch() {
        this.query = 'SELECT IsConverted, Quali_Status__c, E2E_Adoption_Status__c, Status, ' + 
                    '(' +
                        'SELECT  OldValue, ' + 
                        'Field, ' + 
                        'NewValue ' +
                        ' FROM    Histories' +
                        ' WHERE   Field = \'Quali_Status__c\'' +
                    ')' +
            ' FROM    Lead ' +
            ' WHERE   E2E_Adoption_Status__c = NULL ' +
            ' AND     CreatedDate > 2018-11-01T00:00:00Z ' +
            ' AND     CreatedDate < 2019-01-01T00:00:00Z ' +
            ' AND     Country IN :countriesSet ' +
            ' ORDER BY CreatedDate DESC ' + 
            ' LIMIT 50000';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        LeadHandler.enablesTrigger = false;
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead lead : (List<Lead>)scope){
            if(lead.Quali_Status__c == 'Switched to E2E' && !lead.IsConverted){
                lead.E2E_Adoption_Status__c = 'Adoption Email Sent';
                leadsToUpdate.add(lead);
            }
            if(lead.IsConverted && lead.Quali_Status__c =='Switched to E2E' && lead.Status != 'Disqualified'){
                lead.E2E_Adoption_Status__c = 'Successful Adoption';
                leadsToUpdate.add(lead);
            }
            if(lead.Quali_Status__c !='Switched to E2E' && !lead.Histories.isEmpty()){
                for(LeadHistory history : lead.Histories){
                    if(history.OldValue == 'Switched to E2E'){
                        lead.E2E_Adoption_Status__c = 'Returned to Manual';
                        leadsToUpdate.add(lead);
                        break;
                    }
                }        
            }
            if(String.isEmpty(lead.E2E_Adoption_Status__c)){
                lead.E2E_Adoption_Status__c = 'Manual Process';
                leadsToUpdate.add(lead);
            }
        }
        update leadsToUpdate;
    }

    global void finish(Database.BatchableContext BC) {

    }

    global static Set<String> countriesSet = new Set<String>{
        'Germany',
        'Poland',
        'Hungary',
        'France',
        'Netherlands',
        'Austria',
        'Belgium-FR',
        'Belgium-NL',
        'Switzerland-DE',
        'Switzerland-FR'
    };
}