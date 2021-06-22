global class BatchCalculatingStartsOverdueDays implements Database.Batchable<sObject> {
    public String query;
    public List<Sobject> scopee;

    global BatchCalculatingStartsOverdueDays() {
        this.query = 'SELECT Starts_SLA_Expired__c, Starts_Schedule__c, Account.BillingCountry, Starts_Overdue_days__c ' + 
                     'FROM Opportunity ' +
                     'WHERE Starts_Schedule__c < TODAY AND ' +
                            'Starts_Status__c != \'5.1.1 Final Check: Pumping Enough\' AND ' +
                            'Starts_Status__c != \'5.1.2 Final Check: Pumping NOT Enough\' AND ' +
                            'Starts_Status__c != \'5.2 Final Check:Not Pumping\' AND ' +
                            'Starts_Status__c != \'5.3 Final Check: Delay\' AND ' +
                            'Starts_Status__c != \'5.5 Winback Failed\' AND ' +
                            'Starts_Status__c != \'5.6 Fraud\' ' +
                     'LIMIT 50000';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {

        this.scopee = scope;
        List<BusinessHours> businessHoursList = [
            SELECT Id, Name
            FROM BusinessHours
            WHERE Name = 'CZ' OR
                  Name = 'SK' OR
                  Name = 'HU' OR
                  Name = 'PL' OR
                  Name = 'Default'
            LIMIT 10];

        Map<String, BusinessHours> allBusinessHoursMap = new Map<String, BusinessHours>();
        if (! businessHoursList.isEmpty()) {
            for (BusinessHours bh : businessHoursList) {
                if (bh.Name == 'CZ') {
                    allBusinessHoursMap.put('Czech republic', bh);
                } else if (bh.Name == 'SK') {
                    allBusinessHoursMap.put('Slovakia', bh);
                } else if (bh.Name == 'HU') {
                    allBusinessHoursMap.put('Hungary', bh);
                } else if (bh.Name == 'PL') {
                    allBusinessHoursMap.put('Poland', bh);
                } else if (bh.Name == 'Default') {
                    allBusinessHoursMap.put('other', bh);
                }
            }
        }

        Map<Opportunity, Integer> opptyToUpdateMap = new Map<Opportunity, Integer>();
        if (! scope.isEmpty()) {
            for (Sobject so : scope) {
                Opportunity opp = (Opportunity)so;      
                BusinessHours currentBusinessHours;
                if (allBusinessHoursMap.containsKey(opp.Account.BillingCountry)) {
                    currentBusinessHours = allBusinessHoursMap.get(opp.Account.BillingCountry);
                } else {
                    currentBusinessHours = allBusinessHoursMap.get('other');
                }

                Integer potentialOverdueDays = opp.Starts_Schedule__c.daysBetween(Date.today());
                Integer counter = 0;
                for (Integer i = 1; i <= potentialOverdueDays; i++) {
                    Datetime scheduleDatetime = Datetime.newInstance(opp.Starts_Schedule__c.year(), opp.Starts_Schedule__c.month(), opp.Starts_Schedule__c.day(), 12, 00, 00);
                    Boolean isWithin = BusinessHours.isWithin(currentBusinessHours.Id, scheduleDatetime.addDays(i));
                    if (isWithin) {
                        counter ++;
                    }
                }
                opptyToUpdateMap.put(opp, counter);
            }
        }

        List<Opportunity> finalOpptiesToUpdateList = new List<Opportunity>();
        for (Opportunity oppty : opptyToUpdateMap.keySet()) {
            oppty.Starts_Overdue_days__c = opptyToUpdateMap.get(oppty);
            finalOpptiesToUpdateList.add(oppty);
        }
        update finalOpptiesToUpdateList;
    }

    global void finish(Database.BatchableContext BC) {
    }
}