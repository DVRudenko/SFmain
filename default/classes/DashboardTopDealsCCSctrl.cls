public with sharing class DashboardTopDealsCCSctrl {
	public String selectedPeriod {get; set;}
	public String selectedYear {get; set;}
	public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Map<String, Opportunity> finalTop10DealsMap {get;set;}
    public List<SortingList> sortedDealsList {get;set;}
    public Map<String, String> namesOfTopDealsMap {get; set;}
    public Map<String, String> linkColorsMap {get; set;}
    public User currentUser {get; set;}
    private Map<Id, Opportunity> allOpportunitiesMap;
    private Date startDateOfPeriod;
    private Date endDateOfPeriod;

    public DashboardTopDealsCCSctrl() {  
    }

    public void init() {
    	try {
    		returnUser();
    		if (this.selectedYear == null) {
            	this.selectedYear = returnCurrentYear();
       	 	}
       	 	if (availableRolesSet.contains(this.currentUser.UserRole.Name)) {
       	 		generateDataForCharts();
        		generateTopDealsCCSList();
       	 	} else {
       	 		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This dashboard is not available for current user'));
       	 	}       	 	
    	} catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }  	 
    }


    /*******************************************************************************
    *  Name            : generateTopDealsCCSList()
    *  Summary         : generating Top Deals in progress list for the selected period   
    *  CreatedDate     : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
 	public void generateTopDealsCCSList() {
 		if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead' || this.currentUser.UserRole.Name == 'CCS SME Team Lead' ||
            this.currentUser.UserRole.Name == 'CCS CZ KAM Team Lead' || this.currentUser.UserRole.Name == 'CCS CZ LAM Team Lead') {

 			Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
	            SELECT Id
	            FROM UserRole
	            WHERE ParentRoleId = :this.currentUser.UserRoleId
	            LIMIT 1000]);

	        Map<Id, User> salesTeamMap = new Map<Id, User>([
	            SELECT Name
	            FROM User
	            WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :this.currentUser.Id) AND 
	        		  isActive = TRUE
	            LIMIT 10000]);


	        this.allOpportunitiesMap = new Map<Id, Opportunity>([
                SELECT Name, OwnerId, StageName, Expected_Volume__c, CreatedDate, Probability,
                   (SELECT Field, NewValue, CreatedDate
                   	FROM Histories 
                   	WHERE Field = 'StageName' 
               		ORDER BY CreatedDate DESC 
               		LIMIT 1)
                FROM Opportunity
                WHERE OwnerId IN :salesTeamMap.keySet() AND
    				(Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'Outbound') AND
    				Expected_Volume__c != 0 AND
                    StageName != 'Closed Lost' AND 
                    StageName != 'Duplicate' AND
                  	CreatedDate <= :this.endDateOfPeriod
              	ORDER BY Expected_Volume__c DESC
                LIMIT 50000]);
	    } else if (this.currentUser.UserRole.Name == 'CCS CZ Telesales' || 
	    		this.currentUser.UserRole.Name == 'CCS CZ SME' || this.currentUser.UserRole.Name == 'CCS SK SME' ||
                this.currentUser.UserRole.Name == 'CCS CZ KAM' || this.currentUser.UserRole.Name == 'CCS CZ LAM') {
	    	this.allOpportunitiesMap = new Map<Id, Opportunity>([
                SELECT Name, OwnerId, StageName, Expected_Volume__c, CreatedDate, Probability,
                   (SELECT Field, NewValue, CreatedDate 
                   	FROM Histories 
                   	WHERE Field = 'StageName' 
               		ORDER BY CreatedDate DESC 
               		LIMIT 1)
                FROM Opportunity
                WHERE OwnerId = :this.currentUser.Id AND
    				(Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'Outbound') AND
                    StageName != 'Closed Lost' AND 
                    StageName != 'Duplicate' AND
    				Expected_Volume__c != 0 AND
                  	CreatedDate <= :this.endDateOfPeriod
              	ORDER BY Expected_Volume__c DESC
                LIMIT 50000]);
	    }


        Map<Id, Opportunity> top10DealsOfOpportunityMap = new Map<Id, Opportunity>();
        Integer counter = 0;
        for (Opportunity opp : this.allOpportunitiesMap.values()) {
            if (counter >= 10) {
                break;
            }
            if (! opp.Histories.isEmpty()) {
                if (opp.Histories.get(0).NewValue == 'Closed Won' &&
                    opp.Histories.get(0).CreatedDate >= this.startDateOfPeriod && opp.Histories.get(0).CreatedDate <= this.endDateOfPeriod.addDays(1)) {
                    top10DealsOfOpportunityMap.put(opp.Id, opp);
                } else if (opp.Histories.get(0).NewValue != 'Closed Won') {
                    top10DealsOfOpportunityMap.put(opp.Id, opp);
                }
            } else {
                if (opp.StageName == 'Closed Won' &&
                    opp.CreatedDate >= this.startDateOfPeriod && opp.CreatedDate <= this.endDateOfPeriod.addDays(1)) {
                    top10DealsOfOpportunityMap.put(opp.Id, opp);
                } else if (opp.StageName != 'Closed Won') {
                    top10DealsOfOpportunityMap.put(opp.Id, opp);
                }
            }
            counter = top10DealsOfOpportunityMap.size();
        }
        Map<Id, String> lastActivityOpptyMap = returnTop10Deals(top10DealsOfOpportunityMap);

        //FINAL
        this.finalTop10DealsMap = new Map<String, Opportunity>();
        this.sortedDealsList = new List<SortingList>();
        this.namesOfTopDealsMap = new Map<String, String>();
        this.linkColorsMap = new Map<String, String>();
        for (Id oppId : lastActivityOpptyMap.keySet()) {
        	SortingList sortingListValue = new SortingList(oppId, this.allOpportunitiesMap.get(oppId).Expected_Volume__c, this.allOpportunitiesMap.get(oppId).Probability);   
        	this.sortedDealsList.add(sortingListValue);
            this.finalTop10DealsMap.put(oppId, this.allOpportunitiesMap.get(oppId));
        	if (! this.allOpportunitiesMap.get(oppId).Histories.isEmpty()) {
                this.namesOfTopDealsMap.put(oppId, this.allOpportunitiesMap.get(oppId).Name + ' (' + this.allOpportunitiesMap.get(oppId).Histories.get(0).NewValue + ')');
            } else {
                this.namesOfTopDealsMap.put(oppId, this.allOpportunitiesMap.get(oppId).Name + ' (' + this.allOpportunitiesMap.get(oppId).StageName + ')');
            }
            this.linkColorsMap.put(oppId, lastActivityOpptyMap.get(oppId));
        }
        this.sortedDealsList.sort();
 	}


 	/*******************************************************************************
    *  Name            : returnTop10Deals(Map<Id, Opportunity> top10DealsOfOpportunityMap)
    *  Summary         : return Top 10 Deals    
    *  CreatedDate     : 24/10/2017
    *  Parameters      : Map<Id, Opportunity> top10DealsOfOpportunityMap
    *  Returns         : Map<Id, String> lastActivityMap
    ******************************************************************************/
 	public Map<Id, String> returnTop10Deals(Map<Id, Opportunity> top10DealsOfOpportunityMap) {
 		Integer firstPeriodDays;
 		Integer startSecondPeriodDays;
 		Integer endSecondPeriodDays;
 		Integer thirdPeriodDays;
 		if (this.currentUser.UserRole.Name != 'CCS CZ LAM Team Lead' &&
 			this.currentUser.UserRole.Name != 'CCS CZ LAM' &&
            this.currentUser.UserRole.Name != 'CCS CZ KAM Team Lead' &&
            this.currentUser.UserRole.Name != 'CCS CZ KAM') {
 			firstPeriodDays = 3;
			startSecondPeriodDays = 4;
			endSecondPeriodDays = 5;
			thirdPeriodDays = 6;
 		} else {
 			firstPeriodDays = 21;
			startSecondPeriodDays = 28;
			endSecondPeriodDays = 35;
			thirdPeriodDays = 42;
 		}
        Map<Id, String> lastActivityMap = new Map<Id, String>();
		for (Opportunity oppty : top10DealsOfOpportunityMap.values()) {
            if (Date.today() >= this.startDateOfPeriod && Date.today() <= this.endDateOfPeriod) {
                if (oppty.Histories.isEmpty()) {   
                    lastActivityMap.put(oppty.Id, '6+');
                } else if (oppty.Histories.get(0).CreatedDate.Date().daysBetween(Datetime.now().Date()) >= thirdPeriodDays) {
                    lastActivityMap.put(oppty.Id, '6+');
                } else if (oppty.Histories.get(0).CreatedDate.Date().daysBetween(Datetime.now().Date()) == startSecondPeriodDays ||
                           oppty.Histories.get(0).CreatedDate.Date().daysBetween(Datetime.now().Date()) == endSecondPeriodDays) {
                    lastActivityMap.put(oppty.Id, '4-5');
                } else if (oppty.Histories.get(0).CreatedDate.Date().daysBetween(Datetime.now().Date()) <= firstPeriodDays) {
                    lastActivityMap.put(oppty.Id, '1-3');
                }
            } else {
                if (oppty.Histories.isEmpty()) {   
                    lastActivityMap.put(oppty.Id, '6+');
                } else if (oppty.Histories.get(0).CreatedDate.Date().daysBetween(this.endDateOfPeriod) >= thirdPeriodDays) {
                    lastActivityMap.put(oppty.Id, '6+');
                } else if (oppty.Histories.get(0).CreatedDate.Date().daysBetween(this.endDateOfPeriod) == startSecondPeriodDays ||
                           oppty.Histories.get(0).CreatedDate.Date().daysBetween(this.endDateOfPeriod) == endSecondPeriodDays) {
                    lastActivityMap.put(oppty.Id, '4-5');
                } else if (oppty.Histories.get(0).CreatedDate.Date().daysBetween(this.endDateOfPeriod) <= firstPeriodDays) {
                    lastActivityMap.put(oppty.Id, '1-3');
                }
            }	     
		}
		return lastActivityMap;
 	}


 	/*******************************************************************************
    *  Name            : sortingList()
    *  Summary         : Sorting by total fuel consumption    
    *  CreatedDate     : 24/10/2017
    *  Parameters      : String id, Decimal compareValue
    *  Returns         : Integer
    ******************************************************************************/
    public class SortingList implements Comparable {
        public String id {get; set;}
        public Decimal compareValue {get; set;}
        public Decimal probabilityValue {get; set;}

        public sortingList(String id, Decimal compareValue, Decimal probabilityValue) {
            this.id = id;
            this.compareValue = compareValue;
            this.probabilityValue = probabilityValue;
        }

        public Integer compareTo(Object compareTo) {
            SortingList compareToU = (SortingList)compareTo;
            if (this.compareValue < compareToU.compareValue) {
                return 1;
            } else if (this.compareValue > compareToU.compareValue) {
                return -1;
            } else {
                // First value the same, consider second value
                if (this.probabilityValue < compareToU.probabilityValue) {
                    return 1;
                } else if (this.probabilityValue > compareToU.probabilityValue) {
                    return -1;
                } else {
                    return 0;
                }          
            }       
        }
    }


    /*******************************************************************************
    *  Name            : returnUser()
    *  Summary         : getting current user    
    *  CreatedDate     : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUser() {
		String userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        this.currentUser = [
            SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId];
	}


	/*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generating of the values of the selected period   
    *  CreatedDate     : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCharts() {
    	Date startDateOfMonth;
    	Date endDateOfMonth;
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                  Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        Fleetcor_Calendar_Month__c currentMonth = new Fleetcor_Calendar_Month__c();
        if (this.selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }
            String curMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Name;
            currentMonth = [
                SELECT Name, Start_Date__c, End_Date__c, Fleetcor_Calendar_Year__r.Name
                FROM Fleetcor_Calendar_Month__c 
                WHERE Name = :curMonth AND Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                LIMIT 1];

	        //week
	        this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentMonth.Start_Date__c;
			endDateOfMonth = currentMonth.End_Date__c;
			this.selectedPeriod = currentWeek.get(0).Id;
        } else {
    		Id selectedId = selectedPeriod;          
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //week
		        this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
	            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
	            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
				endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;    
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //month
		        this.startDateOfPeriod = currentMonth.Start_Date__c;
	            this.endDateOfPeriod = currentMonth.End_Date__c;
	            startDateOfMonth = currentMonth.Start_Date__c;
				endDateOfMonth = currentMonth.End_Date__c;	
            }         
        }

        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Summary         : generating FLT periods (months and weeks) list   
    *  CreatedDate     : 24/10/2017
    *  Parameters      : -
    *  Returns         : SelectOption (FLT periods)
    ******************************************************************************/
    public List<SelectOption> getPeriodsList() {
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
    *  Name            : getYearsList()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 24/10/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYearsList() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> fltYearsList = [SELECT Name FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : fltYearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }
        return options;
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 24/10/2017
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


    /*******************************************************************************
    *  Name            : changeYear()
    *  Summary         : Setting the period depending on the selected year    
    *  CreatedDate     : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
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


    private Set<String> availableRolesSet = new Set<String>{
        'CCS Telesales Team Lead', 
        'CCS CZ Telesales',
        'CCS SME Team Lead', 
        'CCS CZ SME',
        'CCS SK SME',
        'CCS CZ KAM Team Lead',
        'CCS CZ KAM',
        'CCS CZ LAM Team Lead',
        'CCS CZ LAM'};

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
}