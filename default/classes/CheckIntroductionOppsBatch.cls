global class CheckIntroductionOppsBatch implements Database.Batchable<sObject> {
    public String query;

    global CheckIntroductionOppsBatch() {
        this.query = 'SELECT Id, OwnerId, CreatedDate, Registered_Country__c, Sec_Channel__c ' +
                    'FROM Opportunity ' +
                    'WHERE E2E_Last_Activity__c = null AND ' +
                    'E2E_Status__c = \'Introduction\' AND ' +
                    'E2E__c = true AND StageName != \'Closed Won\' AND StageName != \'Closed Lost\' AND ' +
                    '(Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\')';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
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
                String settingKey;
                if (oppty.Sec_Channel__c == 'Inbound') {
                    settingKey = oppty.Registered_Country__c;
                } else {
                    settingKey = oppty.Registered_Country__c + 'JITB';
                }
                if (adoptionProcessSettings.containsKey(settingKey) && generalSettingsE2E.containsKey(oppty.Registered_Country__c) &&
                    numberOfDaysSinceCreatedDate >= adoptionProcessSettings.get(settingKey).Number_Of_Days_To_Reassign__c && oppty.OwnerId == e2eUser.Id) {
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
                    opp.E2E_Status__c = 'Abandoned (hard)';
                    opp.E2E_Sub_Status__c = 'Switched to manual';
                    opp.E2E_Sales_Type__c = 'E2E downgraded to manual';                    
                    opptiesToReassignList.add(opp);
                }
            }
            update opptiesToReassignList;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}