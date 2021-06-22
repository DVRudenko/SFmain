public with sharing class SalesDashboardContactedLeadCtrl {
    private String userId;
    public User currentUser {get; set;}
    public Integer leadsNoTasksForSales {get; set;}
    public Integer leadsWithTasksForSales {get; set;}
    public Map<Id, User> salesTeamMap {get; set;}
    public List<FinalList> finalList {get; set;}
    public Map<Id, Integer> quantityleadsNoTaskForTeamlead {get; set;}
    public Map<Id, Integer> quantityleadsWithTaskForTeamlead {get; set;}


    public void init() {
        returnUserId();
        salesTeamMap = new Map<Id, User>();
        finalList = new List<FinalList>();
        contactedLeads();
    }


    /*******************************************************************************
    *  Name            : contactedLeads()
    *  Summary         : getting all overdue contacted leads for current user and teamleader    
    *  CreatedDate     : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void contactedLeads() {
        Date todayDate = Date.today();
        currentUser = [
            SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId];

        // overdue contacted leads for teamleader
        if (inboundRolesSet.contains(currentUser.UserRole.Name) || outboundRolesSet.contains(currentUser.UserRole.Name)) {
            
            Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId = :currentUser.UserRoleId
                LIMIT 1000]);

            salesTeamMap = new Map<Id, User>([
                SELECT Name
                FROM User
                WHERE (UserRoleId IN :salesRolesMap.keySet() AND isActive = TRUE) OR 
                      Name = :currentUser.Name
                LIMIT 10000]);

            // add additional users for Teamleiter Inbound
            if (currentUser.UserRole.Name == 'Teamleiter Inbound') {
                String groupName = 'Contacted_Lead_Dashboard_for_TL_Inbound';
                List<User> additionalUsersList = userIdsFromGroupList(groupName);
                salesTeamMap.putAll(additionalUsersList);
            }

            // add additional users for Teamleiter Inbound 2
            if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                String groupName = 'Contacted_Lead_Dashboard_for_TL_Inb_2';
                List<User> additionalUsersList = userIdsFromGroupList(groupName);
                salesTeamMap.putAll(additionalUsersList);
            }

            Map<Id, Lead> allContactedLeadsMap = new Map<Id, Lead>();
            if (currentUser.UserRole.Name == 'CCS Telesales Team Lead') {
                allContactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status
                    FROM Lead
                    WHERE  Status != 'Disqualified' AND
                        Status != 'Konvertierte Leads' AND
                        Status != 'Uzavřeno' AND 
                        Sec_Channel__c = 'Inbound' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        ConvertedOpportunityId = null AND 
                        OwnerId = :salesTeamMap.keySet()
                    LIMIT 50000]);
            } else if (currentUser.UserRole.Name == 'CCS SME Team Lead') {
                allContactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status
                    FROM Lead
                    WHERE  Status != 'Disqualified' AND
                        Status != 'Konvertierte Leads' AND
                        Status != 'Uzavřeno' AND 
                        Sec_Channel__c = 'Inbound' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN' OR LeadSource = 'Příchozí poptávka') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        ConvertedOpportunityId = null AND 
                        OwnerId = :salesTeamMap.keySet()
                    LIMIT 50000]);
            } else {
                allContactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status
                    FROM Lead
                    WHERE Status = 'Contacted' AND
                        ConvertedOpportunityId = null AND
                        OwnerId = :salesTeamMap.keySet()
                    LIMIT 50000]);
            }

            Map<Id, List<Task>> leadsTaskTeamleaderMap = new Map<Id, List<Task>>();
            Map<Id, List<Event>> leadsEventTeamleaderMap = new Map<Id, List<Event>>();
            for (Lead lead : allContactedLeadsMap.values()) {
                leadsTaskTeamleaderMap.put(lead.Id, new List<Task>());
                leadsEventTeamleaderMap.put(lead.Id, new List<Event>());
            }

            // map with tasks for current teamleader
            for (Task t : [SELECT Id, OwnerId, Type, WhoId, Status, ActivityDate, isClosed
                    FROM Task
                    WHERE WhoId IN: allContactedLeadsMap.keySet() AND isClosed = false
                    LIMIT 50000]) {
                if (leadsTaskTeamleaderMap.containsKey(t.WhoId)) {
                    if ((t.OwnerId == allContactedLeadsMap.get(t.WhoId).OwnerId)){
                        leadsTaskTeamleaderMap.get(t.WhoId).add(t);
                    }
                }
            }

            // leads with/without tasks for teamleader
            Map<Id, List<Lead>> finalleadsNoTaskForTeamlead = new  Map<Id, List<Lead>>();
            Map<Id, List<Lead>> finalleadsWithTaskForTeamlead = new  Map<Id, List<Lead>>();
            if (currentUser.UserRole.Name == 'CCS SME Team Lead') {
                // map with events for current teamleader
                for (Event e : [SELECT Id, OwnerId, Type, WhoId, EndDateTime, Visit_Done__c
                                FROM Event
                                WHERE WhoId IN: allContactedLeadsMap.keySet() AND EndDateTime >= :todayDate
                                LIMIT 50000]) {
                    if (leadsEventTeamleaderMap.containsKey(e.WhoId)) {
                        if (e.OwnerId == allContactedLeadsMap.get(e.WhoId).OwnerId){
                            leadsEventTeamleaderMap.get(e.WhoId).add(e);
                        }
                    }
                }

                for (Lead l : allContactedLeadsMap.values()){
                    if (leadsTaskTeamleaderMap.get(l.Id).isEmpty() && leadsEventTeamleaderMap.get(l.Id).isEmpty()){
                        if(! finalleadsNoTaskForTeamlead.containsKey(l.OwnerId)){
                            finalleadsNoTaskForTeamlead.put(l.OwnerId, new List<Lead>());
                        }
                        finalleadsNoTaskForTeamlead.get(l.OwnerId).add(l);
                    } else {
                        for (Task t : leadsTaskTeamleaderMap.get(l.Id)) {
                            if (leadsEventTeamleaderMap.get(l.Id).isEmpty() && t.ActivityDate < todayDate){
                                if(! finalleadsWithTaskForTeamlead.containsKey(l.OwnerId)){
                                    finalleadsWithTaskForTeamlead.put(l.OwnerId, new List<Lead>());
                                }
                                finalleadsWithTaskForTeamlead.get(l.OwnerId).add(l);
                                break;
                            }
                        }
                    }
                }
            } else {
                for (Lead l : allContactedLeadsMap.values()){
                    if (leadsTaskTeamleaderMap.get(l.Id).isEmpty()) {
                        if(! finalleadsNoTaskForTeamlead.containsKey(l.OwnerId)) {
                            finalleadsNoTaskForTeamlead.put(l.OwnerId, new List<Lead>());
                        }
                        finalleadsNoTaskForTeamlead.get(l.OwnerId).add(l);
                    } else {
                        for (Task t : leadsTaskTeamleaderMap.get(l.Id)) {
                            if (t.ActivityDate < todayDate){
                                if(! finalleadsWithTaskForTeamlead.containsKey(l.OwnerId)){
                                    finalleadsWithTaskForTeamlead.put(l.OwnerId, new List<Lead>());
                                }
                                finalleadsWithTaskForTeamlead.get(l.OwnerId).add(l);
                                break;
                            }
                        }
                    }
                }
            }
            
            ///FINAL
            for (Id userId : salesTeamMap.keySet()) {
                if ( ! finalleadsNoTaskForTeamlead.containsKey(userId)) {
                    finalleadsNoTaskForTeamlead.put(userId,new List<Lead>());
                }
                if ( ! finalleadsWithTaskForTeamlead.containsKey(userId)) {
                    finalleadsWithTaskForTeamlead.put(userId,new List<Lead>());
                }
            }

            quantityleadsNoTaskForTeamlead = new Map<Id, Integer>();
            quantityleadsWithTaskForTeamlead = new Map<Id, Integer>();
            for (String uid : finalleadsNoTaskForTeamlead.keySet()) {
                quantityleadsNoTaskForTeamlead.put(uid, finalleadsNoTaskForTeamlead.get(uid).size());
            }
            for (String uid : finalleadsWithTaskForTeamlead.keySet()) {
                quantityleadsWithTaskForTeamlead.put(uid, finalleadsWithTaskForTeamlead.get(uid).size());
            }
            for (String uid : finalleadsNoTaskForTeamlead.keySet()){
                finalList.add(new FinalList(
                    uid, 
                    finalleadsNoTaskForTeamlead.get(uid).size() + finalleadsWithTaskForTeamlead.get(uid).size()));
            }
            finalList.sort();

        } else if (salesRolesSet.contains(currentUser.UserRole.Name)) {
            
            Map<Id, Lead> contactedLeadsMap = new Map<Id, Lead>();
            if (currentUser.UserRole.Name == 'CCS CZ Telesales') {
                contactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status
                    FROM Lead
                    WHERE  Status != 'Disqualified' AND
                        Status != 'Konvertierte Leads' AND
                        Status != 'Uzavřeno' AND 
                        Sec_Channel__c = 'Inbound' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        ConvertedOpportunityId = null AND 
                        OwnerId = :currentUser.Id
                    LIMIT 50000]);
            } else if (currentUser.UserRole.Name == 'CCS CZ SME' || currentUser.UserRole.Name == 'CCS SK SME') {
                contactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status
                    FROM Lead
                    WHERE  Status != 'Disqualified' AND
                        Status != 'Konvertierte Leads' AND
                        Status != 'Uzavřeno' AND 
                        Sec_Channel__c = 'Inbound' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN' OR LeadSource = 'Příchozí poptávka') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        ConvertedOpportunityId = null AND 
                        OwnerId = :currentUser.Id
                    LIMIT 50000]);
            } else {
                contactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status
                    FROM Lead
                    WHERE Status = 'Contacted' AND
                          ConvertedOpportunityId = null AND
                          OwnerId = :currentUser.Id
                    LIMIT 50000]);
            }
                
            Map<Id, List<Task>> leadsTaskMap = new Map<Id, List<Task>>();
            Map<Id, List<Event>> leadsEventMap = new Map<Id, List<Event>>();
            for (Lead lead : contactedLeadsMap.values()) {
                leadsTaskMap.put(lead.Id, new List<Task>());
                leadsEventMap.put(lead.Id, new List<Event>());
            }

            // map with tasks for current user
            for (Task t : [SELECT Id, OwnerId, Type, WhoId, Status, ActivityDate, isClosed
                    FROM Task
                    WHERE WhoId IN: contactedLeadsMap.keySet() AND isClosed = false
                    LIMIT 50000]) {
                if (leadsTaskMap.containsKey(t.WhoId)) {
                    if (t.OwnerId == contactedLeadsMap.get(t.WhoId).OwnerId){
                        leadsTaskMap.get(t.WhoId).add(t);
                    }  
                }
            }

            // leads with/without tasks for current user
            leadsNoTasksForSales = 0;
            leadsWithTasksForSales = 0;
            if (currentUser.UserRole.Name == 'CCS CZ SME' || currentUser.UserRole.Name == 'CCS SK SME') {
                // map with events for current teamleader
                for (Event e : [SELECT Id, OwnerId, Type, WhoId, EndDateTime, Visit_Done__c
                                FROM Event
                                WHERE WhoId IN: contactedLeadsMap.keySet() AND EndDateTime >= :todayDate
                                LIMIT 50000]) {
                    if (leadsEventMap.containsKey(e.WhoId)) {
                        if (e.OwnerId == contactedLeadsMap.get(e.WhoId).OwnerId){
                            leadsEventMap.get(e.WhoId).add(e);
                        }
                    }
                }
                
                for (Id leadId : leadsTaskMap.keySet()) {
                    if (leadsTaskMap.get(leadId).isEmpty() && leadsEventMap.get(leadId).isEmpty()) {
                        leadsNoTasksForSales++;
                    } else {
                        for (Task t : leadsTaskMap.get(leadId)) {
                            if (leadsEventMap.get(leadId).isEmpty() && t.ActivityDate < todayDate && t.OwnerId == currentUser.Id &&
                                t.OwnerId == contactedLeadsMap.get(leadId).OwnerId){
                                leadsWithTasksForSales++;
                                break;
                            }
                        }
                    }
                }
            } else {
                for (Id leadId : leadsTaskMap.keySet()) {
                    if (leadsTaskMap.get(leadId).isEmpty()) {
                        leadsNoTasksForSales++;
                    } else {
                        for (Task t : leadsTaskMap.get(leadId)) {
                            if (t.ActivityDate < todayDate && t.OwnerId == currentUser.Id &&
                                t.OwnerId == contactedLeadsMap.get(leadId).OwnerId){
                                leadsWithTasksForSales++;
                                break;
                            }
                        }
                    }
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid User Role'));
        }
    }


    /*******************************************************************************
    *  Name            : List<User> userIdsFromGroupList (String groupName)
    *  Summary         : return user id's list from public group    
    *  CreatedDate     : 19/04/2017
    *  Parameters      : String groupName
    *  Returns         : List<User>
    ******************************************************************************/
    public static List<User> userIdsFromGroupList (String groupName) {
        // store the results in a set so we don't get duplicates
        Set<Id> userIdsSet = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        // Loop through all group members in a group
        for (GroupMember m : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :groupName]) {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType)) {
                userIdsSet.add(m.UserOrGroupId);
            }
        }
        List<User> addUsersForDashboardTLInboundList = [
            SELECT Id, Name
            FROM User
            WHERE Id IN :userIdsSet AND
                  isActive = TRUE               
            LIMIT 50000];

        return addUsersForDashboardTLInboundList;  
    }


    /*******************************************************************************
    *  Name            : finalList()
    *  Summary         : sales are ordering on the number of overdue leads     
    *  CreatedDate     : -
    *  Parameters      : String id, Decimal compareValue
    *  Returns         : Integer
    ******************************************************************************/
    public class FinalList implements Comparable {
        public String id {get; set;}
        public Decimal compareValue {get; set;}

        public finalList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            FinalList compareToU = (FinalList)compareTo;
            if (compareValue == compareToU.compareValue) return 0;
            if (compareValue < compareToU.compareValue) return 1;
            return -1;        
        }
    }


    /*******************************************************************************
    *  Name            : returnUserId()
    *  Summary         : getting ID current user    
    *  CreatedDate     : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
            if (userId == null) {
                userId = UserInfo.getUserId();
            }
    }

    private final Set<String> leadSourceForCCSSet = new Set<String>{
        'CCS WEB Telesales FB',
        'MVF Web Lead',
        'efektivnetankovanie.sk',
        'efektivnitankovani.cz',
        'Web CCS',
        'Web CCS (Napište nám)',
        'Web CCS (Napište nám SK)',
        'Web CCS (objednávka CCS Bonus+ SK)',
        'Web CCS (objednávka CCS Bonus Fleet)',
        'Web CCS (objednávka CCS Bonus Fleet SK)',
        'Web CCS (objednávka CCS Bonus SK)',
        'Web CCS (objednávka CCS Business)',
        'Web CCS (objednávka CCS Business SK)',
        'Web CCS (objednávka CCS Carnet)',
        'Web CCS (objednávka CCS Limit)',
        'Web CCS (objednávka CCS Limit+)',
        'Web CCS (objednávka CCS Limit +MINI)',
        'Web CCS (objednávka CCS Limit+ SK)',
        'Web CCS (objednávka CCS Limit SK)',
        'Web CCS (objednávka CCS Toll)',
        'Web CCS (objednávka CCS Toll SK)',
        'Web CCS (objednávka UTA/CCS)',
        'Web CCS (objednávka UTA/CCS SK)'
    }; 

    private final Set<String> inboundRolesSet = new Set<String>{
        'Teamleiter Inbound',
        'Teamleiter Inbound 2',
        'Teamleiter Harte Hank',
        'CCS Telesales Team Lead',
        'CCS SME Team Lead',
        'AllStar Teamleader'
    };


    private final Set<String> outboundRolesSet = new Set<String>{
        'Teamleiter Outbound 1',
        'Teamleiter Outbound 2',
        'Teamleiter Outbound 3',
        'Teamleiter Outbound 4',
        'Teamleiter Outbound 5'
    };


    private final Set<String> salesRolesSet = new Set<String>{
        'Salesteam Outbound 1',
        'Salesteam Outbound 2',
        'Salesteam Outbound 3',
        'Salesteam Outbound 4',
        'Salesteam Outbound 5',
        'Salesteam Inbound',
        'Salesteam Inbound 2',
        'Salesteam',
        'Salesteam Harte Hank',
        'Harte Hank Dutch INBOUND',
        'Harte Hank Dutch OUTBOUND',
        'Harte Hank Germany',
        'CCS CZ Telesales',
        'CCS CZ SME',
        'CCS SK SME',
        'AllStar Sales'
    };
}