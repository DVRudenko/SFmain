public with sharing class LeadProcessingTimeReportCCSctrl {
	public List<LeadWrapper> leadsListWrapper {get; set;}
    public List<LeadWrapper> leadsToProcessListWrapper {get; set;}
    public Map<String, Lead> excludedLeadsMap {get; set;}
    public Integer numberExcludedLeads {get; set;}
    public static BusinessHours defaultBH {get; set;}
    public Decimal timeofProcess {get; set;}
    public String selectedSecChannel {get; set;}
    public User currentUser {get; set;}
    
    private Date startDate;
	private Date endDate;
	private String country;
    private Set<String> reassignmentCountriesSet;
    

    public LeadProcessingTimeReportCCSctrl() {
    }


    public void init() {
    	try {
            returnUser();
            this.startDate = Date.valueOf(ApexPages.currentPage().getParameters().get('start'));
            this.endDate = Date.valueOf(ApexPages.currentPage().getParameters().get('end'));
            this.country = ApexPages.currentPage().getParameters().get('country');
            this.selectedSecChannel = ApexPages.CurrentPage().getparameters().get('selectedSecChannel');   
            generateLeadsLists();
        } catch (Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }


    public void generateLeadsLists() {
    	if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead' || this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
    		Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId = :this.currentUser.UserRoleId
                LIMIT 1000]);

            Set<Id> usersSet = new Set<Id>();
            Map<Id, User> salesTeamMap = new Map<Id, User>([
                SELECT Name
                FROM User
                WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :currentUser.Id) AND 
                      isActive = TRUE
                LIMIT 10000]);
            for (String userId : salesTeamMap.keySet()) {
                usersSet.add(userId);
            }

        	if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead') {
	            Map<String, Lead> leadsMap = new Map<String, Lead>([
	                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
	                    Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
	                    Status, Site_Agg_product__c, Quali_Status__c, LastTransferDate,
	                    (SELECT Field, NewValue, OldValue, CreatedDate 
	                    FROM Histories 
	                    WHERE Field = 'Status'
	                    ORDER BY CreatedDate ASC 
	                    LIMIT 1000)
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceTelesalesCCSset AND 
	                    Country = :country AND 
	                    Sec_Channel__c = 'Inbound' AND 
	                    Channel__c = 'web' AND
	                    OwnerId IN :usersSet AND
	                    Disable_for_Processing_Time__c = FALSE
	                ORDER BY CreatedDate DESC
	                LIMIT 50000]);
            
                for (Lead lead : leadsMap.values()){
                    if (lead.Status == 'Contacted' && 
                        (lead.Quali_Status__c == 'Customer reached – forwarded to Field' ||  
                        lead.Quali_Status__c == 'Forwarded internally' ||
                        lead.Quali_Status__c == 'Forwarded to external provider' ||
                        lead.Quali_Status__c == 'Forwarded to Market')) {
                        leadsMap.remove(lead.Id);
                    }
                }  
                Map<String, LeadHistory> leadStatusHistoryMap = new Map<String, LeadHistory>();       
                for (Lead lead : leadsMap.values()) {
                	if (! lead.Histories.isEmpty()) {
                		for (LeadHistory lh : lead.Histories) {
                			if (! leadStatusHistoryMap.containsKey(lead.Id) && (lh.OldValue == 'Open' || (lh.NewValue == 'Konvertierte Leads' && lead.IsConverted == true))) {
                				leadStatusHistoryMap.put(lead.Id, lh);
                			}
                		}
                	}
                    if (! leadStatusHistoryMap.isEmpty()) {
                        for (String leadId : leadStatusHistoryMap.keySet()) {
                            if (! (leadStatusHistoryMap.get(leadId).CreatedDate >= startDate && leadStatusHistoryMap.get(leadId).CreatedDate < endDate.addDays(1)) ) {
                                leadStatusHistoryMap.remove(leadId);
                            }
                        }
                    }
                }
                for (String leadId : leadsMap.keySet()) {
                	if (! leadStatusHistoryMap.containsKey(leadId) && ! Test.isRunningTest()) {
                		leadsMap.remove(leadId);
                	}
                }

	            Map<String, Lead> leadsToProcessMap = new Map<String, Lead>([
	                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
	                    Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
	                    Status, Site_Agg_product__c, Quali_Status__c, LastTransferDate
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceTelesalesCCSset AND
	                    Country = :country AND  
	                    Sec_Channel__c = 'Inbound' AND 
	                    Channel__c = 'web' AND
	                    OwnerId IN :usersSet AND
	                    Status = 'Open' AND
                        Status != 'Konvertierte Leads' AND
	                    Disable_for_Processing_Time__c = FALSE
	                ORDER BY CreatedDate DESC
	                LIMIT 50000]);

	            this.excludedLeadsMap = new Map<String, Lead>([
	                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
	                    Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
	                    Status, Site_Agg_product__c, Quali_Status__c, LastTransferDate,
	                    (SELECT Field, NewValue, OldValue, CreatedDate 
	                    FROM Histories 
	                    WHERE Field = 'Status' AND
	                       CreatedDate >= :startDate AND CreatedDate < :endDate.addDays(1)
	                    ORDER BY CreatedDate ASC 
	                    LIMIT 1)
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceTelesalesCCSset AND 
                        Country = :country AND 
	                    Sec_Channel__c = 'Inbound' AND 
	                    Channel__c = 'web' AND
	                    OwnerId IN :usersSet AND
	                    Disable_for_Processing_Time__c = TRUE
	                ORDER BY CreatedDate DESC
	                LIMIT 1000]);

	            Map<String, Lead> finalexcludedLeadsMap = new Map<String, Lead>();
	            for (Lead lead : this.excludedLeadsMap.values()) {
	                if (lead.Status == 'Open' || (! lead.Histories.isEmpty() && (lead.Histories.get(0).OldValue == 'Open' || (lead.Histories.get(0).NewValue == 'Konvertierte Leads' && lead.IsConverted == true)))) { 
	                    finalexcludedLeadsMap.put(lead.Id, lead);
	                }
	            }
	            this.excludedLeadsMap = finalexcludedLeadsMap;
	            this.numberExcludedLeads = this.excludedLeadsMap.size();
	            teamProcessingTimeCalculate(leadsMap, leadsToProcessMap, leadStatusHistoryMap, null);

	        } else if (this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
	            Map<String, Lead> leadsMap = new Map<String, Lead>([
	                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
	                    Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
	                    Status, Site_Agg_product__c, Quali_Status__c, LastTransferDate,
	                    (SELECT Field, NewValue, OldValue, CreatedDate 
	                    FROM Histories 
	                    WHERE Field = 'Quali_Status__c' OR Field = 'Status'
	                    ORDER BY CreatedDate ASC 
	                    LIMIT 1000)
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceSmeCCSset AND 
                        OwnerId IN :usersSet AND
	                    Country = :country AND
	                    ((Sec_Channel__c = 'Inbound' AND Channel__c = 'E-mail') OR (Sec_Channel__c = 'Inbound' AND Channel__c = 'web')) AND
	                    Disable_for_Processing_Time__c = FALSE
	                ORDER BY CreatedDate DESC
	                LIMIT 50000]);

                Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap = new Map<String, LeadHistory>();
                Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap = new Map<String, LeadHistory>();
                for (Lead lead : leadsMap.values()) {
                    if (! lead.Histories.isEmpty()) {
                        for (LeadHistory lh : lead.Histories) {
                            if (! leadsAfterCustomerReachedStatusHistoryMap.containsKey(lead.Id) && (lh.OldValue == 'Customer reached – forwarded to Field' || (lh.NewValue == 'Konvertierte Leads' && lead.IsConverted == true))) {
                                leadsAfterCustomerReachedStatusHistoryMap.put(lead.Id, lh);
                            }
                            if (! leadsInCustomerReachedStatusHistoryMap.containsKey(lead.Id) && (lh.NewValue == 'Customer reached – forwarded to Field' || (lh.NewValue == 'Konvertierte Leads' && lead.IsConverted == true))) {
                                leadsInCustomerReachedStatusHistoryMap.put(lead.Id, lh);
                            }
                        }
                    }

                    if (! leadsAfterCustomerReachedStatusHistoryMap.isEmpty()) {
                        for (String leadId : leadsAfterCustomerReachedStatusHistoryMap.keySet()) {
                            if (! (leadsAfterCustomerReachedStatusHistoryMap.get(leadId).CreatedDate >= startDate && leadsAfterCustomerReachedStatusHistoryMap.get(leadId).CreatedDate < endDate.addDays(1)) ) {
                                leadsAfterCustomerReachedStatusHistoryMap.remove(leadId);
                                leadsInCustomerReachedStatusHistoryMap.remove(leadId);
                            }
                        }
                    }
                }

                for (String leadId : leadsMap.keySet()) {
                    if (! leadsAfterCustomerReachedStatusHistoryMap.containsKey(leadId) || ! leadsInCustomerReachedStatusHistoryMap.containsKey(leadId)) {
                        leadsMap.remove(leadId);
                    }
                }


	            Map<String, Lead> leadsToProcessMap = new Map<String, Lead>([
	                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
	                    Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
	                    Status, Site_Agg_product__c, Quali_Status__c, LastTransferDate
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceSmeCCSset AND 
                        OwnerId IN :usersSet AND
	                    Country = :country AND
	                    ((Sec_Channel__c = 'Inbound' AND Channel__c = 'E-mail') OR (Sec_Channel__c = 'Inbound' AND Channel__c = 'web')) AND 
	                    Quali_Status__c = 'Customer reached – forwarded to Field' AND
                        Status != 'Konvertierte Leads' AND
	                    Disable_for_Processing_Time__c = FALSE
	                ORDER BY CreatedDate DESC
	                LIMIT 50000]);

	            this.excludedLeadsMap = new Map<String, Lead>([
	                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
	                    Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted, LastTransferDate,
	                    Status, Site_Agg_product__c, Quali_Status__c, Disable_for_Processing_Time__c, 
	                    (SELECT Field, NewValue, OldValue, CreatedDate 
	                    FROM Histories 
	                    WHERE (Field = 'Quali_Status__c' OR Field = 'Status') AND 
	                        CreatedDate >= :startDate AND CreatedDate < :endDate.addDays(1)
	                    ORDER BY CreatedDate ASC 
	                    LIMIT 1)
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceSmeCCSset AND 
                        OwnerId IN :usersSet AND
	                    Country = :country AND 
	                    ((Sec_Channel__c = 'Inbound' AND Channel__c = 'E-mail') OR (Sec_Channel__c = 'Inbound' AND Channel__c = 'web')) AND
	                    Quali_Status__c != null AND
	                    Disable_for_Processing_Time__c = TRUE
	                ORDER BY CreatedDate DESC
	                LIMIT 1000]);

	            Map<String, Lead> finalexcludedLeadsMap = new Map<String, Lead>();
	            for (Lead lead : this.excludedLeadsMap.values()) {
                    if (lead.Quali_Status__c == 'Customer reached – forwarded to Field' || 
                        (! lead.Histories.isEmpty() && 
                        (lead.Histories.get(0).OldValue == 'Customer reached – forwarded to Field' || (lead.Histories.get(0).NewValue == 'Konvertierte Leads' && lead.IsConverted == true)))) { 

                        finalexcludedLeadsMap.put(lead.Id, lead);
	                }
	            }
	            this.excludedLeadsMap = finalexcludedLeadsMap;
	            this.numberExcludedLeads = this.excludedLeadsMap.size();
	            teamProcessingTimeCalculate(leadsMap, leadsToProcessMap, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap);
	        }
    	}
    }


    /*******************************************************************************
    *  Name            : teamProcessingTimeCalculate(Map<String, Lead> leadsMap, Map<String, Lead> leadsToProcessMap, Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap, Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap)
    *  Summary         : calculating team processing time    
    *  CreatedDate     : 15/09/2017
    *  ModifiedDate    : 23/03/2018
    *  Parameters      : Map<String, Lead> leadsMap, Map<String, Lead> leadsToProcessMap, 
                        Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap - OldValue == 'Customer reached – forwarded to Field'
                        Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap - NewValue == 'Customer reached – forwarded to Field'
    *  Returns         : void
    ******************************************************************************/
    public void teamProcessingTimeCalculate(Map<String, Lead> leadsMap, Map<String, Lead> leadsToProcessMap, Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap, Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap) {
    	List<BusinessHours> businessHoursList = [
            SELECT Id, Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayEndTime, WednesdayStartTime,
                ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime,
                SundayEndTime, SundayStartTime
            FROM BusinessHours
            LIMIT 10000];

        Map<String, BusinessHours> localeBusinessHoursMap = new Map<String, BusinessHours>();
        for (BusinessHours bh : businessHoursList) {
            if (bh.Name == 'CZ') {
                localeBusinessHoursMap.put('cs_CZ', bh); 
            } else if (bh.Name == 'SK') {
                localeBusinessHoursMap.put('sk_SK', bh);
            } else if (bh.Name == 'HU') {
                localeBusinessHoursMap.put('hu_HU', bh);
            } else if (bh.Name == 'PL') {
                localeBusinessHoursMap.put('pl_PL', bh);
            } else if (bh.Name == 'Default') {
                localeBusinessHoursMap.put('Default', bh);
            }
        }

        Set<Id> currentUserOwnerLeadsIdSet = new Set<Id>();
        Set<Id> currentQueuesOwnerLeadsIdSet = new Set<Id>();
        for (Lead lead : leadsMap.values()) {
            currentUserOwnerLeadsIdSet.add(lead.OwnerId); 
        }
        for (Lead lead : leadsToProcessMap.values()) {
            currentUserOwnerLeadsIdSet.add(lead.OwnerId);  
        }

        List<User> currentUserList = [
            SELECT Id, Name, LocaleSidKey
            FROM User
            WHERE Id IN :currentUserOwnerLeadsIdSet
            LIMIT 10000];

        Map<String, BusinessHours> businessHoursForUsersMap = new Map<String, BusinessHours>();
        for (User us : currentUserList) {
            if (! currentUserList.isEmpty()) {
                if (us.LocaleSidKey == 'cs_CZ' || us.LocaleSidKey == 'cs_CZ_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('cs_CZ'));
                } else if (us.LocaleSidKey == 'sk_SK' || us.LocaleSidKey == 'sk_SK_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('sk_SK'));
                } else if (us.LocaleSidKey == 'hu_HU' || us.LocaleSidKey == 'hu_HU_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('hu_HU'));
                } else if (us.LocaleSidKey == 'pl_PL' || us.LocaleSidKey == 'pl_PL_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('pl_PL'));
                } else {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('Default'));
                }
            }     
        }
          
        this.leadsListWrapper = new List<LeadWrapper>();
        this.leadsToProcessListWrapper = new List<LeadWrapper>();  
        if (this.selectedSecChannel == 'Inbound in bh') {
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    this.leadsListWrapper.add(new LeadWrapper(this.currentUser, lead, businessHoursForUsersMap, this.selectedSecChannel, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    this.leadsToProcessListWrapper.add(new LeadWrapper(this.currentUser, lead, businessHoursForUsersMap, this.selectedSecChannel, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap));
                }
            }
        } else if (this.selectedSecChannel == 'Inbound not in bh') {
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    this.leadsListWrapper.add(new LeadWrapper(this.currentUser, lead, businessHoursForUsersMap, this.selectedSecChannel, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    this.leadsToProcessListWrapper.add(new LeadWrapper(this.currentUser, lead, businessHoursForUsersMap, this.selectedSecChannel, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap));
                }
            }
        } else if (this.selectedSecChannel == 'Inbound Total') {
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound') {
                    this.leadsListWrapper.add(new LeadWrapper(this.currentUser, lead, businessHoursForUsersMap, this.selectedSecChannel, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound') {
                    this.leadsToProcessListWrapper.add(new LeadWrapper(this.currentUser, lead, businessHoursForUsersMap, this.selectedSecChannel, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap));
                }
            }
        }

        this.timeofProcess = 0;
        Integer counter = 0;
        for (LeadWrapper lw : this.leadsListWrapper){
            this.timeofProcess += lw.diff;
            counter++;
        }

        if(counter != 0) {
            this.timeofProcess = (this.timeofProcess/counter).setScale(2);
        } else {
            this.timeofProcess = 0;
        }
    }

    public void returnUser() {
        String userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        this.currentUser = [SELECT Profile.Name, UserRoleId, UserRole.Name, LocaleSidKey, Name FROM User WHERE Id = :userId];
    }


    public class LeadWrapper {
        public Lead lead {get; set;}
        public Decimal diff {get; set;}
        public String selectedSecChannel {get; set;}

        public leadWrapper(User currentUser, Lead lead, Map<String, BusinessHours> businessHoursForUsersMap, String selectedSecChannel, Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap, Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap) {
            this.lead = lead;
            this.selectedSecChannel = selectedSecChannel;
            BusinessHours busHours = businessHoursForUsersMap.get(lead.OwnerId);
            if (currentUser.UserRole.Name == 'CCS Telesales Team Lead') {           
                if ((lead.Status != 'Open' || lead.IsConverted == true) && ! leadsAfterCustomerReachedStatusHistoryMap.isEmpty()) {
                    diff = BusinessHours.diff(busHours.Id, lead.CreatedDate, leadsAfterCustomerReachedStatusHistoryMap.get(lead.Id).CreatedDate)/1000/60;    
                } else {
                    diff = BusinessHours.diff(busHours.Id, lead.CreatedDate, Datetime.now())/1000/60;    
                }
            } else if (currentUser.UserRole.Name == 'CCS SME Team Lead') {
                if ((lead.Quali_Status__c != 'Customer reached – forwarded to Field' || lead.IsConverted == true) && ! leadsAfterCustomerReachedStatusHistoryMap.isEmpty() && ! leadsInCustomerReachedStatusHistoryMap.isEmpty()) {
                    diff = BusinessHours.diff(busHours.Id, leadsInCustomerReachedStatusHistoryMap.get(lead.Id).CreatedDate, leadsAfterCustomerReachedStatusHistoryMap.get(lead.Id).CreatedDate)/1000/60/60;
                } else {
                    diff = BusinessHours.diff(busHours.Id, lead.CreatedDate, Datetime.now())/1000/60/60;    
                }
            } 
        }
    }


    private Set<String> leadSourceTelesalesCCSset = new Set<String>{
        'CCS WEB Telesales FB',
        'MVF Web Lead',
        'efektivnetankovanie.sk',
        'efektivnitankovani.cz',
        'Web CCS',
        'Web CCS (Napište nám)',
        'Web CCS (Napište nám SK)',
        'Web CCS (landing page)',
        'Web CCS (objednávka CCS Bonus+ SK)',
        'Web CCS (objednávka CCS Bonus Fleet)',
        'Web CCS (objednávka CCS Bonus Fleet SK)',
        'Web CCS (objednávka CCS Bonus SK)',
        'Web CCS (objednávka CCS Business)',
        'Web CCS (objednávka CCS Business SK)',
        'Web CCS (objednávka CCS Carnet)',
        'Web CCS (objednávka CCS Carnet SK)',
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

    private Set<String> leadSourceSmeCCSset = new Set<String>{
        'CCS WEB Telesales FB',
        'MVF Web Lead',
        'Web CCS (objednávka CCS Bonus+)',
        'Web CCS (objednávka CCS Bonus)',
        'bonusky.cz',
        'bonusky.sk',
        'efektivnetankovanie.sk',
        'efektivnitankovani.cz',
        'Web CCS',
        'Web CCS (Napište nám)',
        'Web CCS (Napište nám SK)',
        'Web CCS (landing page)',
        'Web CCS (objednávka CCS Bonus+ SK)',
        'Web CCS (objednávka CCS Bonus Fleet)',
        'Web CCS (objednávka CCS Bonus Fleet SK)',
        'Web CCS (objednávka CCS Bonus SK)',
        'Web CCS (objednávka CCS Business)',
        'Web CCS (objednávka CCS Business SK)',
        'Web CCS (objednávka CCS Carnet)',
        'Web CCS (objednávka CCS Carnet SK)',
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