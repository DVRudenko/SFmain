public with sharing class ContactedLeadReport {
	public String selectedUserId {get; set;}
	public String userParam {get; set;}
	public String nameUser {get; set;}
	public Integer numberOfLeads {get; set;}
	public Integer numberOfLeadsWithoutTasks {get; set;}
	public Integer numberOfLeadsWithTasks {get; set;}
	public Map<Id, User> salesTeamMap {get; set;}
	public List<Lead> finalLeadsWithoutTasksForUserList {get; set;}
	public List<Lead> finalLeadsWithTasksForUserList {get; set;}

    public ContactedLeadReport() {
    	selectedUserId = 'None';        
    }

    public void init() {
       	userParam = Apexpages.currentPage().getParameters().get('userid');
    	salesTeamMap = new Map<Id, User>();
    	if (userParam != null) {
            selectedUserId = userParam;
        }
        contactedLeads();

        if (numberOfLeadsWithoutTasks >= 1000) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
    	}

    	if (numberOfLeadsWithTasks >= 1000) {	
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
    	}       
    }

    public void contactedLeads() {
    	if (selectedUserId != 'None') {

    		Date todayDate = Date.today();
    		salesTeamMap = new Map<Id, User>([
                SELECT Name, UserRole.Name
                FROM User
                WHERE isActive = TRUE
                LIMIT 10000]);
    		nameUser = salesTeamMap.get(selectedUserId).Name; 
    		String userRole = salesTeamMap.get(selectedUserId).UserRole.Name;

    		Map<Id, Lead> contactedLeadsMap = new Map<Id, Lead>();
    		if (userRole == 'CCS Telesales Team Lead' || userRole == 'CCS CZ Telesales') {
    			contactedLeadsMap = new Map<Id, Lead>([
    				SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country, Quali_Status__c
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
                        OwnerId = :selectedUserId
                    LIMIT 50000]);
    		} else if (userRole == 'CCS SME Team Lead' || userRole == 'CCS CZ SME' || userRole == 'CCS SK SME') {
    			contactedLeadsMap = new Map<Id, Lead>([
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country, Quali_Status__c
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
                        OwnerId = :selectedUserId
                    LIMIT 50000]);
    		} else {
    			contactedLeadsMap = new Map<Id, Lead>([
		            SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                        LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country, Quali_Status__c
		            FROM Lead
		            WHERE Status = 'Contacted' AND
		            	ConvertedOpportunityId = null AND
	             		OwnerId = :selectedUserId
		            ORDER BY CreatedDate
	            	LIMIT 50000]);
    		}

            Map<Id, List<Task>> leadsTaskMap = new Map<Id, List<Task>>();
            Map<Id, List<Event>> leadsEventMap = new Map<Id, List<Event>>();
	        for (Lead lead : contactedLeadsMap.values()) {
	            leadsTaskMap.put(lead.Id, new List<Task>());
                leadsEventMap.put(lead.Id, new List<Event>());
	        }

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

        	// All leads for user
        	Map<Id, List<Lead>> leadsWithoutTasksForUser = new Map<Id, List<Lead>>();
        	Map<Id, List<Lead>> leadsWithTasksForUser = new Map<Id, List<Lead>>();
            if (userRole == 'CCS SME Team Lead' || userRole == 'CCS CZ SME' || userRole == 'CCS SK SME') {
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

                for (Lead l : contactedLeadsMap.values()) {
                    if (leadsTaskMap.get(l.Id).isEmpty() && leadsEventMap.get(l.Id).isEmpty()) {
                        if (! leadsWithoutTasksForUser.containsKey(l.OwnerId)){
                            leadsWithoutTasksForUser.put(l.OwnerId, new List<Lead>());
                        }
                        leadsWithoutTasksForUser.get(l.OwnerId).add(l);
                    } else {
                        for (Task t : leadsTaskMap.get(l.Id)) {
                            if (leadsEventMap.get(l.Id).isEmpty() && t.ActivityDate < todayDate) {
                                if(! leadsWithTasksForUser.containsKey(l.OwnerId)) {
                                    leadsWithTasksForUser.put(l.OwnerId, new List<Lead>());
                                }
                                leadsWithTasksForUser.get(l.OwnerId).add(l);
                                break;
                            }
                        }
                    }
                }
            } else {
                for (Lead l : contactedLeadsMap.values()) {
                    if (leadsTaskMap.get(l.Id).isEmpty()) {
                        if(! leadsWithoutTasksForUser.containsKey(l.OwnerId)){
                            leadsWithoutTasksForUser.put(l.OwnerId, new List<Lead>());
                        }
                        leadsWithoutTasksForUser.get(l.OwnerId).add(l);
                    } else {
                        for (Task t : leadsTaskMap.get(l.Id)) {
                            if (t.ActivityDate < todayDate) {
                                if(! leadsWithTasksForUser.containsKey(l.OwnerId)) {
                                    leadsWithTasksForUser.put(l.OwnerId, new List<Lead>());
                                }
                                leadsWithTasksForUser.get(l.OwnerId).add(l);
                                break;
                            }
                        }
                    }
                }
            }

    		// FINAL
    		// for contacted leads without tasks
    		finalLeadsWithoutTasksForUserList = new List<Lead>();
    		finalLeadsWithTasksForUserList = new List<Lead>();

    		List<Lead> finalLeadsWithoutTasksForUserTempList = new List<Lead>();
            for (List<Lead> leadList : leadsWithoutTasksForUser.values()) {
            	for (Lead li : leadList) {
            		finalLeadsWithoutTasksForUserTempList.add(li);
            	}
	        }

	        Integer counter = 0;
	        for (Lead lead : finalLeadsWithoutTasksForUserTempList) {
	        	if (counter == 1000) break;
	        	finalLeadsWithoutTasksForUserList.add(lead);
	        	counter++;
	        }
	        numberOfLeadsWithoutTasks = finalLeadsWithoutTasksForUserTempList.size();

	        // for contacted leads with tasks
	        List<Lead> finalLeadsWithTasksForUserTempList = new List<Lead>();
            for (List<Lead> leadList : leadsWithTasksForUser.values()) {
            	for (Lead li : leadList) {
            		finalLeadsWithTasksForUserTempList.add(li);
            	}
	        }

	        Integer count = 0;
	        for (Lead lead : finalLeadsWithTasksForUserTempList) {
	        	if (count == 1000) break;
	        	finalLeadsWithTasksForUserList.add(lead);
	        	count++;
	        }
	        numberOfLeadsWithTasks = finalLeadsWithTasksForUserTempList.size();

	        numberOfLeads = finalLeadsWithoutTasksForUserTempList.size() + finalLeadsWithTasksForUserTempList.size();
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