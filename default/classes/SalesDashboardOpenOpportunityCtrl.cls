public with sharing class SalesDashboardOpenOpportunityCtrl {
	private String userid;
    public User currentUser {get; set;}
    public Integer oppWithTasksForSales {get; set;}
    public Integer oppWithoutTasksForSales {get; set;}
    public Map<Id, User> salesTeamMap {get; set;}
    public Map<Id, Integer> quantityOppWithoutTasksForTeamlead {get; set;}
    public Map<Id, Integer> quantityOppWithTasksForTeamlead {get; set;}
    public List<FinalList> finalList {get; set;}


    public void init() {
        returnUserId();
        salesTeamMap = new Map<Id, User>();
        finalList = new List<FinalList>();
        selectOpenOpportunities();
    }


    /*******************************************************************************
    *  Name            : selectOpenOpportunities()
    *  Summary         : getting all open opportunities with/without tasks for current user and teamleader    
    *  CreatedDate     : 23.11.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void selectOpenOpportunities() {
    	Date todayDate = Date.today();
        Date date2018 = Date.newInstance(2018, 0, 0);

		currentUser = [
                SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :userid];

        // Open opportunity for current sales
        if (salesRolesSet.contains(currentUser.UserRole.Name)) {

            Map<Id, Opportunity> openOppforSalesMap = new Map<Id, Opportunity>();
            if (currentUser.UserRole.Name == 'CCS CZ Telesales') {
                openOppforSalesMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c, Land_Opp__c
                    FROM Opportunity
                    WHERE StageName != 'Closed Won' AND 
                        StageName != 'Closed Lost' AND 
                        StageName != 'CreditCheck abgelehnt' AND
                        StageName != 'Duplicate' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        RecordType.Name = 'CCS Opportunity Layout' AND 
                        OwnerId = :currentUser.Id
                    LIMIT 50000]);
            } else if (currentUser.UserRole.Name == 'CCS CZ SME' || currentUser.UserRole.Name == 'CCS SK SME') {
                openOppforSalesMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c, Land_Opp__c
                    FROM Opportunity
                    WHERE StageName != 'Closed Won' AND 
                        StageName != 'Closed Lost' AND 
                        StageName != 'Uzavřeno' AND 
                        StageName != 'No Sale' AND 
                        StageName != 'CreditCheck abgelehnt' AND
                        StageName != 'Duplicate' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        RecordType.Name = 'CCS Opportunity Layout' AND 
                        OwnerId = :currentUser.Id AND 
                        CloseDate >= :date2018
                    LIMIT 50000]);
            } else {
                openOppforSalesMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c, Land_Opp__c
                    FROM Opportunity
                    WHERE StageName != 'Closed Won' AND 
                        StageName != 'Closed Lost' AND 
                        StageName != 'CreditCheck abgelehnt' AND
                        RecordType.Name != 'CCS Opportunity Layout' AND 
                        OwnerId = :currentUser.Id
                    LIMIT 50000]);
            }      	

        	Map<Id, List<Task>> oppTaskMap = new Map<Id, List<Task>>();
            Map<Id, List<Event>> oppEventMap = new Map<Id, List<Event>>();
	            for (Opportunity op : openOppforSalesMap.values()) {
	                oppTaskMap.put(op.Id, new List<Task>());
                    oppEventMap.put(op.Id, new List<Event>());
	            }

            // map tasks for current user
            for (Task t : [SELECT Id, OwnerId, Type, WhatId, Status, ActivityDate, isClosed
                FROM Task
                WHERE WhatId IN: openOppforSalesMap.keySet() AND isClosed = false
                LIMIT 50000]) {
	            if (oppTaskMap.containsKey(t.WhatId)) {
	                if (t.OwnerId == openOppforSalesMap.get(t.WhatId).OwnerId){
	                    oppTaskMap.get(t.WhatId).add(t);
	                }  
	            }
	        }

	        // Opportunity with/without tasks for current user
	        oppWithTasksForSales = 0;
            oppWithoutTasksForSales = 0;
            if (currentUser.UserRole.Name == 'CCS CZ SME' || currentUser.UserRole.Name == 'CCS SK SME') {
                // map events for current user
                for (Event e : [SELECT Id, OwnerId, Type, WhatId, EndDateTime, Visit_Done__c
                                FROM Event
                                WHERE WhatId IN: openOppforSalesMap.keySet() AND EndDateTime >= :todayDate
                                LIMIT 50000]) {
                    if (oppEventMap.containsKey(e.WhatId)) {
                        if (e.OwnerId == openOppforSalesMap.get(e.WhatId).OwnerId){
                            oppEventMap.get(e.WhatId).add(e);
                        }
                    }
                }

                for (Id oppId : oppTaskMap.keySet()){
                    if (oppTaskMap.get(oppId).isEmpty() && oppEventMap.get(oppId).isEmpty()) {
                        oppWithoutTasksForSales++;
                    } else {
                        for (Task t : oppTaskMap.get(oppId)){
                            if (oppEventMap.get(oppId).isEmpty() && t.ActivityDate < todayDate && t.OwnerId == currentUser.Id &&
                                t.OwnerId == openOppforSalesMap.get(oppId).OwnerId){
                                oppWithTasksForSales++;
                                break;
                            }
                        }
                    }
                }
            } else {
                for (Id oppId : oppTaskMap.keySet()){
                    if (oppTaskMap.get(oppId).isEmpty()) {
                        oppWithoutTasksForSales++;
                    } else {
                        for (Task t : oppTaskMap.get(oppId)){
                            if (t.ActivityDate < todayDate && t.OwnerId == currentUser.Id &&
                                t.OwnerId == openOppforSalesMap.get(oppId).OwnerId){
                                oppWithTasksForSales++;
                                break;
                            }
                        }
                    }
                }
            }
        // Open opportunity for current teamleaders
        } else if (teamleadersRolesSet.contains(currentUser.UserRole.Name)) {
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
                String groupName = 'Overdue_Open_Opp_Dashboard_for_TL_Inb';
                List<User> additionalUsersList = userIdsFromGroupList(groupName);
                salesTeamMap.putAll(additionalUsersList);
            }

            // add additional users for Teamleiter Inbound 2
            if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                String groupName = 'Overdue_Open_Opp_Dashboard_for_TL_Inb_2';
                List<User> additionalUsersList = userIdsFromGroupList(groupName);
                salesTeamMap.putAll(additionalUsersList);
            }

            Map<Id, Opportunity> openOppforTeamleaderMap = new Map<Id, Opportunity>();
            if (currentUser.UserRole.Name == 'CCS Telesales Team Lead') {
                openOppforTeamleaderMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c, Land_Opp__c
                    FROM Opportunity
                    WHERE StageName != 'Closed Won' AND 
                        StageName != 'Closed Lost' AND 
                        StageName != 'CreditCheck abgelehnt' AND
                        StageName != 'Duplicate' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        RecordType.Name = 'CCS Opportunity Layout' AND 
                        OwnerId = :salesTeamMap.keySet()
                    LIMIT 50000]);
            } else if (currentUser.UserRole.Name == 'CCS SME Team Lead') {
                openOppforTeamleaderMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c, Land_Opp__c
                    FROM Opportunity
                    WHERE StageName != 'Closed Won' AND 
                        StageName != 'Closed Lost' AND 
                        StageName != 'Uzavřeno' AND 
                        StageName != 'CreditCheck abgelehnt' AND
                        StageName != 'Duplicate' AND
                        ((LeadSource IN :leadSourceForCCSSet AND Channel__c = 'web') OR
                        ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN') AND (Channel__c = 'call' OR Channel__c = 'email')) OR 
                        ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                        ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                        ) AND
                        RecordType.Name = 'CCS Opportunity Layout' AND 
                        OwnerId = :salesTeamMap.keySet() AND 
                        CloseDate >= :date2018
                    LIMIT 50000]);
            } else {
                openOppforTeamleaderMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c, Land_Opp__c
                    FROM Opportunity
                    WHERE StageName != 'Closed Won' AND 
                        StageName != 'Closed Lost' AND 
                        StageName != 'CreditCheck abgelehnt' AND
                        RecordType.Name != 'CCS Opportunity Layout' AND 
                        OwnerId = :salesTeamMap.keySet()
                    LIMIT 50000]);
            }
            

            Map<Id, List<Task>> oppTasksTeamleaderMap = new Map<Id, List<Task>>();
            Map<Id, List<Event>> oppEventsTeamleaderMap = new Map<Id, List<Event>>();
            for (Opportunity opp : openOppforTeamleaderMap.values()) {
                oppTasksTeamleaderMap.put(opp.Id, new List<Task>());
                oppEventsTeamleaderMap.put(opp.Id, new List<Event>());
            }

            // map with tasks for current teamleader
            for (Task t : [SELECT Id, OwnerId, Type, WhatId, Status, ActivityDate, isClosed
                    FROM Task
                    WHERE WhatId IN: openOppforTeamleaderMap.keySet() AND isClosed = false
                    LIMIT 50000]) {
                if (oppTasksTeamleaderMap.containsKey(t.WhatId)) {
                    if ((t.OwnerId == openOppforTeamleaderMap.get(t.WhatId).OwnerId)) {
                        oppTasksTeamleaderMap.get(t.WhatId).add(t);
                    }
                }
            }

            // Opportunities with/without tasks for teamleader
            Map<Id, List<Opportunity>> finalOppWithoutTaskForTeamlead = new Map<Id, List<Opportunity>>();
            Map<Id, List<Opportunity>> finalOppWithTaskForTeamlead = new Map<Id, List<Opportunity>>();

            if (currentUser.UserRole.Name == 'CCS SME Team Lead') {
                // map events for current user
                for (Event e : [SELECT Id, OwnerId, Type, WhatId, EndDateTime, Visit_Done__c
                                FROM Event
                                WHERE WhatId IN: openOppforTeamleaderMap.keySet() AND EndDateTime >= :todayDate
                                LIMIT 50000]) {
                    if (oppEventsTeamleaderMap.containsKey(e.WhatId)) {
                        if (e.OwnerId == openOppforTeamleaderMap.get(e.WhatId).OwnerId) {
                            oppEventsTeamleaderMap.get(e.WhatId).add(e);
                        }
                    }
                }
                
                for (Opportunity op : openOppforTeamleaderMap.values()) {
                    if (oppTasksTeamleaderMap.get(op.Id).isEmpty() && oppEventsTeamleaderMap.get(op.Id).isEmpty()) {
                        if(! finalOppWithoutTaskForTeamlead.containsKey(op.OwnerId)) {
                            finalOppWithoutTaskForTeamlead.put(op.OwnerId, new List<Opportunity>());
                        }
                        finalOppWithoutTaskForTeamlead.get(op.OwnerId).add(op);
                    } else {
                        for (Task t : oppTasksTeamleaderMap.get(op.Id)) {
                            if (oppEventsTeamleaderMap.containsKey(op.Id) && oppEventsTeamleaderMap.get(op.Id).isEmpty() && t.ActivityDate < todayDate) {
                                if(! finalOppWithTaskForTeamlead.containsKey(op.OwnerId)) {
                                    finalOppWithTaskForTeamlead.put(op.OwnerId, new List<Opportunity>());
                                }
                                finalOppWithTaskForTeamlead.get(op.OwnerId).add(op);
                                break;
                            }
                        }
                    }
                }
            } else {
                for (Opportunity op : openOppforTeamleaderMap.values()) {
                    if (oppTasksTeamleaderMap.get(op.Id).isEmpty()) {
                        if(! finalOppWithoutTaskForTeamlead.containsKey(op.OwnerId)) {
                            finalOppWithoutTaskForTeamlead.put(op.OwnerId, new List<Opportunity>());
                        }
                        finalOppWithoutTaskForTeamlead.get(op.OwnerId).add(op);
                    } else {
                        for (Task t : oppTasksTeamleaderMap.get(op.Id)) {
                            if (t.ActivityDate < todayDate) {
                                if(! finalOppWithTaskForTeamlead.containsKey(op.OwnerId)) {
                                    finalOppWithTaskForTeamlead.put(op.OwnerId, new List<Opportunity>());
                                }
                                finalOppWithTaskForTeamlead.get(op.OwnerId).add(op);
                                break;
                            }
                        }
                    }
                }
            }
            
            ///FINAL
            for (Id userId : salesTeamMap.keySet()) {
                if ( ! finalOppWithoutTaskForTeamlead.containsKey(userId)) {
                    finalOppWithoutTaskForTeamlead.put(userId, new List<Opportunity>());
                }
                if ( ! finalOppWithTaskForTeamlead.containsKey(userId)) {
                    finalOppWithTaskForTeamlead.put(userId, new List<Opportunity>());
                }
            }

            quantityOppWithoutTasksForTeamlead = new Map<Id, Integer>();
            quantityOppWithTasksForTeamlead = new Map<Id, Integer>();
            
            for (String uid : finalOppWithoutTaskForTeamlead.keySet()){
                finalList.add(new FinalList(
                    uid, 
                    finalOppWithoutTaskForTeamlead.get(uid).size() + finalOppWithTaskForTeamlead.get(uid).size()));

                quantityOppWithoutTasksForTeamlead.put(uid, finalOppWithoutTaskForTeamlead.get(uid).size());
                quantityOppWithTasksForTeamlead.put(uid, finalOppWithTaskForTeamlead.get(uid).size());
            }
            finalList.sort();
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
    *  Summary         : order by the number of open opportunities     
    *  CreatedDate     : 23.11.2016
    *  Parameters      : String id, Decimal compareValue
    *  Returns         : Integer value
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
    *  CreatedDate     : 23.11.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void returnUserId() {
        userid = Apexpages.currentPage().getParameters().get('userid');
            if (userid == null) {
                userid = UserInfo.getUserId();
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


    private final Set<String> teamleadersRolesSet = new Set<String>{
    	'Teamleiter Inbound',
        'Teamleiter Inbound 2',
        'Teamleiter Harte Hank',
        'Teamleiter Outbound 1',
        'Teamleiter Outbound 2',
        'Teamleiter Outbound 3',
        'Teamleiter Outbound 4',
        'Teamleiter Outbound 5',
        'Teamleiter',
        'CCS SME Team Lead',
        'CCS Telesales Team Lead',
        'AllStar Teamleader'
    };
}