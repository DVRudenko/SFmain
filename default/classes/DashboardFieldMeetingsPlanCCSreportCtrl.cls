public with sharing class DashboardFieldMeetingsPlanCCSreportCtrl {
	private String periodId;
	private Date startDateOfPeriod;
    private Date endDateOfPeriod;
	public String selectedPeriod {get; set;}
	public String selectedYear {get; set;}
	public User selectedUser {get; set;}
	public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Decimal currentPlan {get; set;}
    public List<FieldMeeting> allFieldMeetingsList {get; set;}

    public DashboardFieldMeetingsPlanCCSreportCtrl() {     
    }


    public void init() {
    	try {
	    	returnUser();
	    	String periodId = Apexpages.currentPage().getParameters().get('period');
	        String year = ApexPages.currentPage().getParameters().get('year');
	        if (periodId == null || year == null) {
	        	throw new MessageException('An error occurred. Please select the required user again.');
	        }
	        if (this.selectedYear == null) {
	        	this.selectedYear = year;
	        }
	        if (this.selectedPeriod == null) {
	            this.selectedPeriod = periodId;
	        }
	        this.allFieldMeetingsList = new List<FieldMeeting>();
	        generateDataForCharts();
	        generateFieldMeetingsPlanReport();
	        if (this.allFieldMeetingsList.size() >= 1000) {
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '"All Field Meetings" table displays 1000 record max.'));
	    	}
	    } catch (Exception e) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }


    /*******************************************************************************
    *  Name            : generateFieldMeetingsPlanReport()
    *  Summary         : generating Field Meetings Plan report for selected user and period    
    *  CreatedDate     : 17/11/2017
    *  ModifiedDate    : 26/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateFieldMeetingsPlanReport() {
    	List<Event> allEventsForSelectedPeriodList = [
        	SELECT Id, OwnerId, Owner.Name, Type, Subject, WhoId, WhatId, Who.Name, What.Name, StartDateTime
        	FROM Event
        	WHERE StartDateTime >= :this.startDateOfPeriod AND StartDateTime <= :this.endDateOfPeriod AND
        		OwnerId = :this.selectedUser.Id AND
        		Type IN :eventsTypeSet
    		LIMIT 50000
        ];

    	List<FieldMeeting> finalFieldMeetingsList = new List<FieldMeeting>();
        for (Event event : allEventsForSelectedPeriodList) {  
        	FieldMeeting newMeeting = new FieldMeeting();
        	newMeeting.meetingId = event.Id;
        	newMeeting.ownerId = event.OwnerId;
        	newMeeting.ownerName = event.Owner.Name;
        	newMeeting.type = event.Type;
        	newMeeting.subject = event.Subject;
        	newMeeting.status = '';
        	newMeeting.startDateTime = String.valueOf(event.StartDateTime);
        	newMeeting.priority = '';
        	if (event.WhoId != null) {
        		if (String.valueOf(event.WhoId).subString(0,3) == '00Q') {
        			newMeeting.leadId = event.WhoId;
        			newMeeting.leadName = event.Who.Name;
        		} else if (String.valueOf(event.WhoId).subString(0,3) == '003') {
        			newMeeting.contactId = event.WhoId;
        			newMeeting.contactName = event.Who.Name;
        		}
        	}
        	if (event.WhatId != null) {
        		if (String.valueOf(event.WhatId).subString(0,3) == '001') {
        			newMeeting.accountId = event.WhatId;
        			newMeeting.accountName = event.What.Name;
        		} else if (String.valueOf(event.WhatId).subString(0,3) == '006') {
        			newMeeting.opportunityId = event.WhatId;
        			newMeeting.opportunityName = event.What.Name;
        		}
        	}
        	finalFieldMeetingsList.add(newMeeting);
        }

        Integer counter = 0;
        for (FieldMeeting fieldMeeting : finalFieldMeetingsList) {
        	if (counter == 1000) break;
        	this.allFieldMeetingsList.add(fieldMeeting);
        	counter++;
        }
    }

    public class MessageException extends Exception {}

    public class FieldMeeting {
        public String meetingId {get; set;}
        public String ownerId {get; set;}
        public String ownerName {get; set;}
        public String type {get; set;}
        public String subject {get; set;}
		public String status {get; set;}
        public String startDateTime {get; set;}
        public String priority {get; set;}
        public String leadId {get; set;}
        public String leadName {get; set;}
        public String contactId {get; set;}
        public String contactName {get; set;}
        public String accountId {get; set;} 
        public String accountName {get; set;} 
        public String opportunityId {get; set;}
        public String opportunityName {get; set;}
    }


    /*******************************************************************************
    *  Name            : returnUser()
    *  Summary         : getting selected user    
    *  CreatedDate     : 17/11/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUser() {
		String userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        this.selectedUser = [
            SELECT Id, FirstName, LastName, UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId
            LIMIT 1];
	}


	/*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generating of the values of the selected period   
    *  CreatedDate     : 17/11/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCharts() {
    	Date startDateOfMonth;
    	Date endDateOfMonth;
        
		Id selectedId = this.selectedPeriod;          
        if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
            List<Fleetcor_Calendar_Week__c> currentWeek = [
                SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                       Start_Date__c, End_Date__c, Fleetcor_Calendar_Month__r.Number_of_weeks__c
                FROM Fleetcor_Calendar_Week__c 
                WHERE Id = :this.selectedPeriod
                LIMIT 1];

            //week
	        this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
			endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c; 
			Decimal numberWeeks = currentWeek.get(0).Fleetcor_Calendar_Month__r.Number_of_weeks__c;
			if (numberWeeks == 4) {
				this.currentPlan = 6;
			} else {
				this.currentPlan = 5;
			}   
        } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
            Fleetcor_Calendar_Month__c currentMonth = [
                SELECT Name, Start_Date__c, End_Date__c
                FROM Fleetcor_Calendar_Month__c 
                WHERE Id = :this.selectedPeriod
                LIMIT 1];

            //month
	        this.startDateOfPeriod = currentMonth.Start_Date__c;
            this.endDateOfPeriod = currentMonth.End_Date__c;
            startDateOfMonth = currentMonth.Start_Date__c;
			endDateOfMonth = currentMonth.End_Date__c;	
			this.currentPlan = 25;
        }         
        this.startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        this.endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Summary         : generating FLT periods (months and weeks) list   
    *  CreatedDate     : 17/11/2017
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
    *  CreatedDate     : 17/11/2017
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
    *  CreatedDate     : 17/11/2017
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
    *  CreatedDate     : 17/11/2017
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


    private Set<String> eventsTypeSet = new Set<String>{
        'První schůzka', 
        'Následná schůzka',
        'Retence',
        'Rozvoj',
        'Péče', 
        'Trénink',
        'Akvizice'};

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