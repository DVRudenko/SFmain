public with sharing class DashboardLeadProcessingTimeCCSctrl {
	public User currentUser {get; set;}
    public String startDateOfWeekString {get; set;}
    public String endDateOfWeekString {get; set;}
    public Fleetcor_Calendar_Week__c currentWeek {get; set;}
    public Fleetcor_Calendar_Month__c currentMonth {get; set;}
    public Map<String, Decimal> timesMap {get; set;}
    public Map<String, Integer> toProcessMap {get; set;}
    public Map<String, Integer> quantityLeadsMap {get; set;}
    public Decimal finalMinutesAT {get; set;}
    public String selectedPeriod {get; set;}
    public Date startDateOfPeriod {get; set;}
    public Date endDateOfPeriod {get; set;}
    public String startDateOfWeekParam {get; set;}
    public String endDateOfWeekParam {get; set;}
    public String selectedYear {get; set;}
    public String selectedSecChannel {get; set;}

    private static Date todayDate; 
    private Set<String> reassignmentCountriesSet;
    private Set<String> countriesSet;
    private String userId;

    public DashboardLeadProcessingTimeCCSctrl() {    
    }

    public void init() {
        try {
            returnUserId();
            this.currentUser = [SELECT Profile.Name, UserRoleId, UserRole.Name, LocaleSidKey, Name FROM User WHERE Id = :userId];
            this.timesMap = new Map<String, Decimal>();
            this.toProcessMap = new Map<String, Integer>();
            this.quantityLeadsMap = new Map<String, Integer>();
            if (this.selectedYear == null) {
                this.selectedYear = returnCurrentYear();
            }
            generateDataForCharts();
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
      
            Map<Id, User> salesTeamMap = new Map<Id, User>([
                SELECT Name
                FROM User
                WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :currentUser.Id) AND 
                      isActive = TRUE
                LIMIT 10000]);

            Set<Id> usersSet = new Set<Id>();
            for (String userId : salesTeamMap.keySet()) {
                usersSet.add(userId);
            } 

            if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead') {
            	Map<String, Lead> currentLeadsMap = new Map<String, Lead>([
	                SELECT OwnerId, CreatedDate, Status, Country, IsConverted, Sec_Channel__c, Quali_Status__c, LeadSource, LastTransferDate,
	                      (SELECT Field, NewValue, OldValue, CreatedDate 
	                       FROM Histories 
	                       WHERE Field = 'Status'
	                       ORDER BY CreatedDate ASC 
	                       LIMIT 1000)
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceTelesalesCCSset AND 
	                      Sec_Channel__c = 'Inbound' AND 
	                      Channel__c = 'web' AND
	                      OwnerId IN :usersSet AND
	                      Disable_for_Processing_Time__c = FALSE
	                LIMIT 50000]);

                for (Lead lead : currentLeadsMap.values()){
                    if (lead.Status == 'Contacted' && 
                        (lead.Quali_Status__c == 'Customer reached – forwarded to Field' ||  
                        lead.Quali_Status__c == 'Forwarded internally' ||
                        lead.Quali_Status__c == 'Forwarded to external provider' ||
                        lead.Quali_Status__c == 'Forwarded to Market')) {
                        currentLeadsMap.remove(lead.Id);
                    }
                }  

                Map<String, LeadHistory> currentLeadStatusHistoryMap = new Map<String, LeadHistory>();       
                for (Lead lead : currentLeadsMap.values()) {
                	if (! lead.Histories.isEmpty()) {
                		for (LeadHistory lh : lead.Histories) {
                            if (! currentLeadStatusHistoryMap.containsKey(lead.Id) && (lh.OldValue == 'Open' || (lh.NewValue == 'Konvertierte Leads' && lead.IsConverted == true))) {
                                currentLeadStatusHistoryMap.put(lead.Id, lh);
                            }
                		}
                	}
                    if (! currentLeadStatusHistoryMap.isEmpty()) {
                        for (String leadId : currentLeadStatusHistoryMap.keySet()) {
                            if (! (currentLeadStatusHistoryMap.get(leadId).CreatedDate >= startDateOfPeriod && currentLeadStatusHistoryMap.get(leadId).CreatedDate < endDateOfPeriod.addDays(1)) ) {
                                currentLeadStatusHistoryMap.remove(leadId);
                            }
                        }
                    }
                }
                for (String leadId : currentLeadsMap.keySet()) {
                	if (! currentLeadStatusHistoryMap.containsKey(leadId)) {
                		currentLeadsMap.remove(leadId);
                	}
                }

	            List<Lead> currentToProcessLeads = [
	                SELECT OwnerId, CreatedDate, Status, Country, IsConverted, Sec_Channel__c, Quali_Status__c, LeadSource, LastTransferDate
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceTelesalesCCSset AND 
	                      Sec_Channel__c = 'Inbound' AND 
	                      Channel__c = 'web' AND
	                      OwnerId IN :usersSet AND
	                      Status = 'Open' AND
                          Status != 'Konvertierte Leads' AND
	                      Disable_for_Processing_Time__c = FALSE
	                LIMIT 50000];

	            teamProcessingTimeCalculate(currentLeadsMap, currentToProcessLeads, currentLeadStatusHistoryMap, null);
            } else if (this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
            	Map<String, Lead> currentLeadsMap = new Map<String, Lead>([
	                SELECT OwnerId, CreatedDate, Status, Country, IsConverted, Sec_Channel__c, Quali_Status__c, LeadSource, LastTransferDate,
	                      (SELECT Field, NewValue, OldValue, CreatedDate 
	                       FROM Histories 
	                       WHERE Field = 'Quali_Status__c' OR Field = 'Status'
	                       ORDER BY CreatedDate ASC 
	                       LIMIT 1000)
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceSmeCCSset AND
                          OwnerId IN :usersSet AND
	                      ((Sec_Channel__c = 'Inbound' AND Channel__c = 'E-mail') OR (Sec_Channel__c = 'Inbound' AND Channel__c = 'web')) AND
	                      Disable_for_Processing_Time__c = FALSE
	                LIMIT 50000]);    

                Map<String, LeadHistory> currentLeadQualiStatusHistoryMap = new Map<String, LeadHistory>();
                for (Lead lead : currentLeadsMap.values()){
                    if (lead.Status == 'Contacted' && 
                       	(lead.Quali_Status__c == 'Forwarded internally' ||
                        lead.Quali_Status__c == 'Forwarded to Market')) {
                        currentLeadsMap.remove(lead.Id);
                    }
                } 
                
                Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap = new Map<String, LeadHistory>();
                Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap = new Map<String, LeadHistory>();
				for (Lead lead : currentLeadsMap.values()) {
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
				            if (! (leadsAfterCustomerReachedStatusHistoryMap.get(leadId).CreatedDate >= startDateOfPeriod && leadsAfterCustomerReachedStatusHistoryMap.get(leadId).CreatedDate < endDateOfPeriod.addDays(1)) ) {
				                leadsAfterCustomerReachedStatusHistoryMap.remove(leadId);
                                leadsInCustomerReachedStatusHistoryMap.remove(leadId);
				            }
				        }
				    }
				}        

                for (String leadId : currentLeadsMap.keySet()) {
				    if (! leadsAfterCustomerReachedStatusHistoryMap.containsKey(leadId) || ! leadsInCustomerReachedStatusHistoryMap.containsKey(leadId)) {
				        currentLeadsMap.remove(leadId);
				    }
				}

	            List<Lead> currentToProcessLeads = [
	                SELECT OwnerId, CreatedDate, Status, Country, IsConverted, Sec_Channel__c, Quali_Status__c, LeadSource, LastTransferDate
	                FROM Lead 
	                WHERE LeadSource IN :leadSourceSmeCCSset AND
                          OwnerId IN :usersSet AND
	                      ((Sec_Channel__c = 'Inbound' AND Channel__c = 'E-mail') OR (Sec_Channel__c = 'Inbound' AND Channel__c = 'web')) AND 
	                      Quali_Status__c = 'Customer reached – forwarded to Field' AND
                          Status != 'Konvertierte Leads' AND
	                      Disable_for_Processing_Time__c = FALSE
	                LIMIT 50000];

	            teamProcessingTimeCalculate(currentLeadsMap, currentToProcessLeads, leadsAfterCustomerReachedStatusHistoryMap, leadsInCustomerReachedStatusHistoryMap);
            }      
        }    
    }
        
	/*******************************************************************************
	*  Name            : teamProcessingTimeCalculate(Map<String, Lead> currentLeadsMap, List<Lead> currentToProcessLeads, Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap, Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap)
	*  Summary         : calculating team processing time    
	*  CreatedDate     : 14/09/2017
	*  ModifiedDate    : 23/03/2018
	*  Parameters      : Map<String, Lead> currentLeadsMap, List<Lead> currentToProcessLeads, 
	                    Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap - OldValue == 'Customer reached – forwarded to Field'
	                    Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap - NewValue == 'Customer reached – forwarded to Field'
	*  Returns         : void
	******************************************************************************/
    public void teamProcessingTimeCalculate(Map<String, Lead> currentLeadsMap, List<Lead> currentToProcessLeads, Map<String, LeadHistory> leadsAfterCustomerReachedStatusHistoryMap, Map<String, LeadHistory> leadsInCustomerReachedStatusHistoryMap) {
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
        for (Lead lead : currentLeadsMap.values()) {
            currentUserOwnerLeadsIdSet.add(lead.OwnerId);
        }
        for (Lead lead : currentToProcessLeads) {
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

        if (this.selectedSecChannel == null) {
            this.selectedSecChannel = 'Inbound in bh';
        }
        Map<String, Integer> quantityLeadsMap = new Map<String, Integer>(); 
        List<Lead> currentLeadsForCharts = new List<Lead>();
        List<Lead> currentToProcessLeadsForCharts = new List<Lead>();
        if (this.selectedSecChannel == 'Inbound in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeadsMap.values()) {
                if (l.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Inbound not in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeadsMap.values()) {
                if (l.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Inbound Total') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Inbound') {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeadsMap.values()) {
                if (l.Sec_Channel__c == 'Inbound') {
                    currentLeadsForCharts.add(l);
                }
            }
        }

        for (Lead l : currentToProcessLeadsForCharts) {
            String countryString = prepareCountry(l.Country);

            if ( ! toProcessMap.containsKey(countryString)) {
                toProcessMap.put(countryString, 0);
            }
            
            Integer quantityLeads = toProcessMap.get(countryString) + 1;
            toProcessMap.put(countryString, quantityLeads);

            if ( ! timesMap.containsKey(countryString)) {
                timesMap.put(countryString, 0);
                quantityLeadsMap.put(countryString, 0);
            }
        }

        for (Lead l : currentLeadsForCharts) {
            String countryString = prepareCountry(l.Country);   

            if ( ! timesMap.containsKey(countryString)) {
                timesMap.put(countryString, 0);
                quantityLeadsMap.put(countryString, 0);
            }

            if ( ! toProcessMap.containsKey(countryString)) {
                toProcessMap.put(countryString, 0);
            }

            Decimal minutes = 0;
            Decimal hours = 0;
            Integer quantityLeads = 0;

            if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead') {
			    minutes = BusinessHours.diff(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate, leadsAfterCustomerReachedStatusHistoryMap.get(l.Id).CreatedDate)/1000/60;   
			    minutes = timesMap.get(countryString) + minutes;
			    timesMap.put(countryString, minutes);
			} else if (this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
			    hours = BusinessHours.diff(businessHoursForUsersMap.get(l.OwnerId).Id, leadsInCustomerReachedStatusHistoryMap.get(l.Id).CreatedDate, leadsAfterCustomerReachedStatusHistoryMap.get(l.Id).CreatedDate)/1000/60/60;   
			    hours = timesMap.get(countryString) + hours;
			    timesMap.put(countryString, hours);
			}    
            
            quantityLeads = quantityLeadsMap.get(countryString) + 1;
            quantityLeadsMap.put(countryString, quantityLeads);
        }

        for (String country : timesMap.keyset()) {
            if (quantityLeadsMap.get(country) != 0) {
                Decimal timeTemp = timesMap.get(country) / quantityLeadsMap.get(country);
                timesMap.put(country, timeTemp.setScale(2));
            }
        } 
    }


    public void changeYear() {
        List<Fleetcor_Calendar_Week__c> currentFLTweek = [
            SELECT Id, Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name
            FROM Fleetcor_Calendar_Week__c
            WHERE Start_Date__c <= TODAY AND 
                  End_Date__c >= TODAY
            LIMIT 1];

        String currentWeekId;
        String currentFLTyear;
        if (! currentFLTweek.isEmpty()) {
            currentWeekId = currentFLTweek.get(0).Id;
            currentFLTyear = currentFLTweek.get(0).Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name;
        }

        if (this.selectedYear != currentFLTyear) {
            String firstMonthId = [
                SELECT Id
                FROM Fleetcor_Calendar_Month__c
                WHERE Name = :monthsMap.get(1) AND
                    Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                LIMIT 1].Id;
            this.selectedPeriod = firstMonthId;
        } else {
            this.selectedPeriod = currentWeekId;
        }
        init();       
    }
    

    public String prepareCountry(String country) {
        String countryString = country;
        if ( ! countryString.contains('-')) {
            countryString = country.toLowerCase();
            List<String> elems = countryString.split(' ');
            countryString = '';
            for (String x : elems) {
                countryString += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + ' ';
            }
            
            countryString = countryString.removeEnd(' '); 
        }
        return countryString;
    }


    /*******************************************************************************
    *  Name            : getYears()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 14/09/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> yearsList = [SELECT Name FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : yearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }

        return options;
    }


    /*******************************************************************************
    *  Name            : getcurrentWeeks()
    *  Summary         : Display weeks in selectbox     
    *  CreatedDate     : 14/09/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getcurrentWeeks() {
        String thisMonth = '';
        Integer monthIndex = 12;
        
        List<Fleetcor_Calendar_Month__c> currentWeekTemp = [
                SELECT Name, Month_Number__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                      Start_Date__c <= TODAY AND 
                      End_Date__c >= TODAY 
                LIMIT 1];
        
        List<SelectOption> options = new List<SelectOption>();
        Set<String> monthsSet = new Set<String>();

        if ( ! currentWeekTemp.isEmpty() ) {
            for (Integer i = 1; i <= currentWeekTemp.get(0).Month_Number__c; i++) {
                monthsSet.add(monthsMap.get(i));
            }
            monthIndex = Integer.valueOf(currentWeekTemp.get(0).Month_Number__c);
        } else {
            for (Integer i = 1; i <= 12; i++) {
                monthsSet.add(monthsMap.get(i));
            }      
        }

        List<Fleetcor_Calendar_Week__c> weeksList = [
                SELECT End_Date__c, Start_Date__c, Fleetcor_Calendar_Month__r.Name,
                    Fleetcor_Calendar_Month__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Name IN :monthsSet AND 
                   Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                ORDER BY Start_Date__c DESC];

        for (Fleetcor_Calendar_Week__c week : weeksList) {

            if (thisMonth != week.Fleetcor_Calendar_Month__r.Name) {
                thisMonth = week.Fleetcor_Calendar_Month__r.Name;
                options.add(new SelectOption(week.Fleetcor_Calendar_Month__c, monthsMap.get(monthIndex)));
                if (monthIndex != 1) {
                    monthIndex--;
                }
            }
            
            options.add(
                new SelectOption(
                    week.Id, 
                    '---' + week.Fleetcor_Calendar_Month__r.Name + ' (' + week.Start_Date__c.day() + '.' + week.Start_Date__c.month() + ' - ' + 
                    week.End_Date__c.day() + '.' + week.End_Date__c.month() + ')'));
        }

        return options;
    }


    /*******************************************************************************
    *  Name            : getSecChannels
    *  Summary         : display SecChannels in business hours or not for CCS teams 
    *  CreatedDate     : 14/09/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getSecChannels() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Inbound in bh', 'Inbound in business hours'));
        options.add(new SelectOption('Inbound not in bh', 'Inbound not in business hours'));
        options.add(new SelectOption('Inbound Total', 'Inbound Total'));
        
        return options;
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 14/09/2017
    *  Parameters      : 
    *  Returns         : String – year
    ******************************************************************************/
    public String returnCurrentYear() {
        String currentYear = String.valueOf(Date.today().year());
        Date lastDayOfYear = [
            SELECT End_Date__c 
            FROM Fleetcor_Calendar_Month__c
            WHERE Fleetcor_Calendar_Year__r.Name = :currentYear
            ORDER BY End_Date__c DESC 
            LIMIT 1].End_Date__c;
        if (Date.today() > lastDayOfYear) {
            return String.valueOf(Date.today().year() + 1);
        } else {
            return String.valueOf(Date.today().year());
        }
    }


    public void generateDataForCharts() {
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                  Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        //todayDate = Date.newinstance(2016, 4, 15);
        if (selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }

            selectedPeriod = currentWeek.get(0).Id;
            startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            endDateOfPeriod = currentWeek.get(0).End_Date__c;
        } else {
            Id selectedId = selectedPeriod;
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :selectedPeriod
                    LIMIT 1];
                startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            	endDateOfPeriod = currentWeek.get(0).End_Date__c;     
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :selectedPeriod
                    LIMIT 1];
                startDateOfPeriod = currentMonth.Start_Date__c;
            	endDateOfPeriod = currentMonth.End_Date__c;
            }
        }
        this.startDateOfWeekString = String.valueOf(this.startDateOfPeriod.day()) + ' ' + monthsMap.get(this.startDateOfPeriod.month());
        this.endDateOfWeekString = String.valueOf(this.endDateOfPeriod.day()) + ' ' + monthsMap.get(this.endDateOfPeriod.month());

        this.startDateOfWeekParam = this.startDateOfPeriod.year() + '-' + this.startDateOfPeriod.month() + '-' + this.startDateOfPeriod.day();
        this.endDateOfWeekParam = this.endDateOfPeriod.year() + '-' + this.endDateOfPeriod.month() + '-' + this.endDateOfPeriod.day();
    }

    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
            if (userId == null) {
                userId = UserInfo.getUserId();
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

    private Map<Integer, String> monthsMap = new Map<Integer, String>{
        1 => 'January', 
        2 => 'February', 
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'}; 

    private Map<String, Integer> monthsMapRev = new Map<String, Integer>{
        'January' => 1, 
        'February' => 2, 
        'March' => 3,
        'April' => 4,
        'May' => 5,
        'June' => 6,
        'July' => 7,
        'August' => 8,
        'September' => 9,
        'October' => 10,
        'November' => 11,
        'December' => 12};
}