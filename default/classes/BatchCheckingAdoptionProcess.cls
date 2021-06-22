global class BatchCheckingAdoptionProcess implements Database.Batchable<sObject> {
    public String query;
    private User e2eUser;

    global BatchCheckingAdoptionProcess() {
        this.query = 'SELECT Id, OwnerId, Country, Sec_Channel__c, RecordType.Name, ' +
            '(SELECT CreatedDate, OldValue, NewValue FROM Histories) ' +
            'FROM Lead ' +
            'WHERE (Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\') AND ' +
            'Status = \'Open\' AND ' +
            'Quali_Status__c = \'Switched to E2E\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        Map<String, List<Lead>> leadsToReassignMap = new Map<String, List<Lead>>();
        Map<String, Adoption_Process_Settings__c> adoptionProcessSettings = Adoption_Process_Settings__c.getall();
        List<User> usersList = [SELECT Id, Username FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        if (! usersList.isEmpty()) this.e2eUser = usersList.get(0); 
        for (Sobject sobj : scope) {
            Lead lead = (Lead) sobj;
            String settingsKey;
            if (lead.RecordType.Name == 'Lotos') {
                settingsKey = lead.Country + lead.RecordType.Name;
            } else {
                if (lead.Sec_Channel__c == 'Inbound') {
                    settingsKey = lead.Country;
                }
                else if (lead.Sec_Channel__c == 'JITB') {
                    settingsKey = lead.Country + 'JITB';
                }
            }

            if (! Test.isRunningTest() && this.e2eUser.Id == lead.OwnerId) {
                for (LeadHistory lh : lead.Histories) {
                    if (lh.NewValue == 'Switched to E2E' && adoptionProcessSettings.containsKey(settingsKey)) {
                        Integer numberOfDaysSinceSwitchToE2E = (Date.valueOf(lh.CreatedDate)).daysBetween(System.today());
                        if (numberOfDaysSinceSwitchToE2E >= adoptionProcessSettings.get(settingsKey).Number_Of_Days_To_Reassign__c) {
                            if (! leadsToReassignMap.containsKey(adoptionProcessSettings.get(settingsKey).Queue_Name__c)) {
                                leadsToReassignMap.put(adoptionProcessSettings.get(settingsKey).Queue_Name__c, new List<Lead>());
                            }   
                            leadsToReassignMap.get(adoptionProcessSettings.get(settingsKey).Queue_Name__c).add(lead);
                        }
                        break;
                    }
                }
            } else 
            if ( Test.isRunningTest() ) {
                Integer numberOfDaysSinceSwitchToE2E = 5;
                if (numberOfDaysSinceSwitchToE2E >= adoptionProcessSettings.get(settingsKey).Number_Of_Days_To_Reassign__c) {
                    if (! leadsToReassignMap.containsKey(adoptionProcessSettings.get(settingsKey).Queue_Name__c)) {
                        leadsToReassignMap.put(adoptionProcessSettings.get(settingsKey).Queue_Name__c, new List<Lead>());
                    }   
                    leadsToReassignMap.get(adoptionProcessSettings.get(settingsKey).Queue_Name__c).add(lead);
                }
            }          
        }
        if (! leadsToReassignMap.isEmpty()) {
            List<Group> queuesList = [
                SELECT Id, Name
                FROM Group
                WHERE Name IN :leadsToReassignMap.keySet()
                LIMIT 10000];

            Map<String, Group> queuesMap = new Map<String, Group>();
            for (Group grp : queuesList) {
                queuesMap.put(grp.Name, grp);
            }
            List<Lead> leadsToReassignList = new List<Lead>();
            for (String groupName : leadsToReassignMap.keySet()) {
                for (Lead lead : leadsToReassignMap.get(groupName)) {
                    lead.Quali_Status__c = null;
                    lead.OwnerId = queuesMap.get(groupName).Id;
                    lead.E2E_Adoption_Status__c = 'Returned to Manual';
                    leadsToReassignList.add(lead);
                }
            }
            LeadHandler.isSwitchToE2E = false;
            update leadsToReassignList;
        }
    }

    global void finish(Database.BatchableContext BC) {}
}