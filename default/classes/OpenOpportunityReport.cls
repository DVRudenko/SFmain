public with sharing class OpenOpportunityReport {
	private String userid;
	public String userParam {get; set;}
	public String nameUser {get; set;}
	public String selectedUserId {get; set;}
	public Integer numberOfOpp {get; set;}
	public Integer numberOfOppWithoutTasks {get; set;}
	public Integer numberOfOppWithTasks {get; set;}
	public List<Opportunity> finalOppWithoutTasksForUserList {get; set;}
	public List<Opportunity> finalOppWithTasksForUserList {get; set;}
	public Map<Id, User> usersMap {get; set;}



    public OpenOpportunityReport() {
    	selectedUserId = 'None';        
    }

    public void init() {
    	userParam = Apexpages.currentPage().getParameters().get('userid');
    	usersMap = new Map<Id, User>();
    	if (userParam != null) {
            selectedUserId = userParam;
        }
        selectOpenOpportunities();

        if (numberOfOppWithoutTasks >= 1000) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
    	}

    	if (numberOfOppWithTasks >= 1000) {	
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
    	}
    }


    /*******************************************************************************
    *  Name            : selectOpenOpportunities()
    *  Summary         : getting all open opportunities with/without tasks for selected user   
    *  CreatedDate     : 24.11.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void selectOpenOpportunities() {
    	Date todayDate = Date.today();
        Date date2018 = Date.newInstance(2018, 0, 0);

		usersMap = new Map<Id, User>([
                SELECT Name, UserRole.Name
                FROM User
                WHERE isActive = TRUE
                LIMIT 10000]);
		nameUser = usersMap.get(selectedUserId).Name;

        // Open opportunity for current sales
        if (selectedUserId != 'None') {
            String userRole = usersMap.get(selectedUserId).UserRole.Name;
            Map<Id, Opportunity> openOppforSalesMap = new Map<Id, Opportunity>();
        	
            if (userRole == 'CCS Telesales Team Lead' || userRole == 'CCS CZ Telesales') {
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
                        OwnerId = :selectedUserId
                    LIMIT 50000]);
            } else if (userRole == 'CCS SME Team Lead' || userRole == 'CCS CZ SME' || userRole == 'CCS SK SME') {
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
                        OwnerId = :selectedUserId AND 
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
                        OwnerId = :selectedUserId
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

	        // All open Opportunities for user
        	Map<Id, List<Opportunity>> oppWithoutTasksForUser = new Map<Id, List<Opportunity>>();
        	Map<Id, List<Opportunity>> oppWithTasksForUser = new Map<Id, List<Opportunity>>();

            if (userRole == 'CCS SME Team Lead' || userRole == 'CCS CZ SME' || userRole == 'CCS SK SME') {
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

                for (Opportunity opp : openOppforSalesMap.values()) {
                    if (oppTaskMap.get(opp.Id).isEmpty() && oppEventMap.get(opp.Id).isEmpty()) {
                        if (! oppWithoutTasksForUser.containsKey(opp.OwnerId)) {
                            oppWithoutTasksForUser.put(opp.OwnerId, new List<Opportunity>());
                        }
                        oppWithoutTasksForUser.get(opp.OwnerId).add(opp);
                    } else {
                        for (Task t : oppTaskMap.get(opp.Id)) {
                            if (oppEventMap.get(opp.Id).isEmpty() && t.ActivityDate < todayDate) {
                                if (! oppWithTasksForUser.containsKey(opp.OwnerId)) {
                                    oppWithTasksForUser.put(opp.OwnerId, new List<Opportunity>());
                                }
                                oppWithTasksForUser.get(opp.OwnerId).add(opp);
                                break;
                            }
                        }
                    }
                }
            } else {
                for (Opportunity opp : openOppforSalesMap.values()) {
                    if (oppTaskMap.get(opp.Id).isEmpty()) {
                        if (! oppWithoutTasksForUser.containsKey(opp.OwnerId)) {
                            oppWithoutTasksForUser.put(opp.OwnerId, new List<Opportunity>());
                        }
                        oppWithoutTasksForUser.get(opp.OwnerId).add(opp);
                    } else {
                        for (Task t : oppTaskMap.get(opp.Id)) {
                            if (t.ActivityDate < todayDate) {
                                if (! oppWithTasksForUser.containsKey(opp.OwnerId)) {
                                    oppWithTasksForUser.put(opp.OwnerId, new List<Opportunity>());
                                }
                                oppWithTasksForUser.get(opp.OwnerId).add(opp);
                                break;
                            }
                        }
                    }
                }
            }

    		// FINAL
    		// for open Opportunities without tasks
    		finalOppWithoutTasksForUserList = new List<Opportunity>();
    		finalOppWithTasksForUserList = new List<Opportunity>();

    		List<Opportunity> finalOppWithoutTasksForUserTempList = new List<Opportunity>();
            for (List<Opportunity> oppList : oppWithoutTasksForUser.values()) {
            	for (Opportunity o : oppList) {
            		finalOppWithoutTasksForUserTempList.add(o);
            	}
	        }

	        Integer counter = 0;
	        for (Opportunity oppot : finalOppWithoutTasksForUserTempList) {
	        	if (counter == 1000) break;
	        	finalOppWithoutTasksForUserList.add(oppot);
	        	counter++;
	        }
	        numberOfOppWithoutTasks = finalOppWithoutTasksForUserTempList.size();

	        // for open Opportunities with tasks
	        List<Opportunity> finalOppWithTasksForUserTempList = new List<Opportunity>();
            for (List<Opportunity> oppList : oppWithTasksForUser.values()) {
            	for (Opportunity o : oppList) {
            		finalOppWithTasksForUserTempList.add(o);
            	}
	        }

	        Integer count = 0;
	        for (Opportunity oppot : finalOppWithTasksForUserTempList) {
	        	if (count == 1000) break;
	        	finalOppWithTasksForUserList.add(oppot);
	        	count++;
	        }
	        numberOfOppWithTasks = finalOppWithTasksForUserTempList.size();
	        numberOfOpp = finalOppWithoutTasksForUserTempList.size() + finalOppWithTasksForUserTempList.size();
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
}