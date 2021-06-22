global class BatchUpdatingPrimaryContactPhone implements Database.Batchable<sObject> {
    public String query;

    global BatchUpdatingPrimaryContactPhone() {
        this.query = 'SELECT Primary_Contact_Phone__c, ' +
                            '(SELECT Contact.Phone ' +
                            'FROM OpportunityContactRoles ' +
                            'WHERE IsPrimary = TRUE ' + 
                            'LIMIT 1) ' +
                    'FROM Opportunity ' +
                    'WHERE RecordType.Name = \'Russian Sales\' AND ' +
                        '(Primary_Contact_Phone__c = null OR Primary_Contact_Phone__c = \'\') AND ' +
                        'StageName != \'Closed Won\' AND ' +
                        'StageName != \'Closed Lost\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Opportunity> opptiesToUpdateList = new List<Opportunity>();
        for (Sobject so : scope) {
            Opportunity opp = (Opportunity)so;
            if (! opp.OpportunityContactRoles.isEmpty() && opp.OpportunityContactRoles.get(0).Contact.Phone != null) {
                opp.Primary_Contact_Phone__c = opp.OpportunityContactRoles.get(0).Contact.Phone;
                opptiesToUpdateList.add(opp);
            }
        }
        update opptiesToUpdateList; 
    }

    global void finish(Database.BatchableContext BC) {
    }
}