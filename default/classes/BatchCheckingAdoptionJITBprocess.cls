global class BatchCheckingAdoptionJITBprocess implements Database.Batchable<sObject> {
    public String query;

    global BatchCheckingAdoptionJITBprocess() {
        this.query = 'SELECT Id, OwnerId, CreatedDate, Registered_Country__c ' +
                    'FROM Opportunity ' +
                    'WHERE E2E_Last_Activity__c = null AND ' +
                    'Sec_Channel__c = \'JITB\' AND ' +
                    'E2E__c = true AND StageName != \'Closed Won\' AND StageName != \'Closed Lost\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        User e2eUser;
        List<User> usersList = [SELECT Id, Username FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        Map<String, Adoption_Process_Settings__c> adoptionProcessSettings = Adoption_Process_Settings__c.getall();
        Map<String, E2E_Form_General_Settings__c> generalSettingsE2E = E2E_Form_General_Settings__c.getall();
        Map<String, List<Opportunity>> opptiesToReassignMap = new Map<String, List<Opportunity>>();
        if (! usersList.isEmpty()) {
            e2eUser = usersList.get(0);
            for (Sobject sobj : scope) {
                Opportunity oppty = (Opportunity) sobj;
                Integer numberOfDaysSinceCreatedDate = (Date.valueOf(oppty.CreatedDate)).daysBetween(System.today());
                if (adoptionProcessSettings.containsKey(oppty.Registered_Country__c + 'JITB') && generalSettingsE2E.containsKey(oppty.Registered_Country__c) &&
                    numberOfDaysSinceCreatedDate >= adoptionProcessSettings.get(oppty.Registered_Country__c + 'JITB').Number_Of_Days_To_Reassign__c && oppty.OwnerId == e2eUser.Id) {
                    if (! opptiesToReassignMap.containsKey(generalSettingsE2E.get(oppty.Registered_Country__c).Abandonment_User__c)) {
                        opptiesToReassignMap.put(generalSettingsE2E.get(oppty.Registered_Country__c).Abandonment_User__c, new List<Opportunity>());
                    }
                    opptiesToReassignMap.get(generalSettingsE2E.get(oppty.Registered_Country__c).Abandonment_User__c).add(oppty);
                }
            }
        }
        if (! opptiesToReassignMap.isEmpty()) {
            List<Opportunity> opptiesToReassignList = new List<Opportunity>();
            for (String abandonmentUserId : opptiesToReassignMap.keySet()) {
                for (Opportunity opp : opptiesToReassignMap.get(abandonmentUserId)) {
                    opp.OwnerId = abandonmentUserId;
                    opptiesToReassignList.add(opp);
                }
            }
            update opptiesToReassignList;
        }
    }

    global void finish(Database.BatchableContext BC) {}
}