public with sharing class DashboardNewActivitiesCCSctrl {
	public String selectedPeriod {get; set;}
	public String selectedYear {get; set;}
	public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Map<String, User> salesTeamMap {get; set;}
    public User currentUser {get; set;}
    public Integer monthActivitiesPlan {get; set;}
    public List<FinalList> finalList {get; set;}
    public Map<String, Integer> finalActivitiesMap {get; set;}
    public Map<String, Integer> todayActivitiesMap {get; set;} 
    private Date startDateOfPeriod;
    private Date endDateOfPeriod;

    public DashboardNewActivitiesCCSctrl() {    
    }

    public void init() {
    	try {
    		returnUser();
    		if (this.selectedYear == null) {
            	this.selectedYear = returnCurrentYear();
       	 	}
       	 	if (availableRolesSet.contains(this.currentUser.UserRole.Name)) {           
       	 		generateDataForCharts();
                this.todayActivitiesMap = new Map<String, Integer>();
                this.finalActivitiesMap = new Map<String, Integer>();
                Integer bussinesDays = returnBusinessDays(Datetime.newInstance(this.startDateOfPeriod.year(), this.startDateOfPeriod.month(), this.startDateOfPeriod.day()), Datetime.newInstance(this.endDateOfPeriod.year(), this.endDateOfPeriod.month(), this.endDateOfPeriod.day()));
                this.monthActivitiesPlan = 70 * bussinesDays;
                generateNewActivitiyData();
       	 	} else {
       	 		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This dashboard is not available for current user'));
       	 	}  	 	
   	 	} catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }


    /*******************************************************************************
    *  Name            : generateNewActivitiyData()
    *  Summary         : generating New Activities (tasks and events) for selected period    
    *  CreatedDate     : 30/10/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void generateNewActivitiyData() {
        if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead' || this.currentUser.UserRole.Name == 'CCS SME Team Lead' || 
            this.currentUser.UserRole.Name == 'CCS CZ KAM Team Lead' || this.currentUser.UserRole.Name == 'CCS CZ LAM Team Lead') {
            Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId = :this.currentUser.UserRoleId
                LIMIT 1000]);

            this.salesTeamMap = new Map<String, User>([
                SELECT Name
                FROM User
                WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :this.currentUser.Id) AND 
                      isActive = TRUE
                LIMIT 10000]);

            List<Task> tasksList = [
                SELECT OwnerId, CreatedDate, Owner.Name
                FROM Task
                WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND 
                    OwnerId IN :this.salesTeamMap.keySet() AND
                    Type != null
                LIMIT 30000];

            List<Event> eventsList = [
                SELECT OwnerId, CreatedDate, Owner.Name
                FROM Event
                WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND 
                    OwnerId IN :this.salesTeamMap.keySet() AND
                    Type != null
                LIMIT 30000];

            Map<String, List<Task>> allTasksForOwnerMap = new Map<String, List<Task>>();
            Map<String, List<Task>> allTodayTasksForOwnerMap = new Map<String, List<Task>>();
            for (Task task : tasksList) {
                //all tasks
                if (! allTasksForOwnerMap.containsKey(task.OwnerId) ) {
                    allTasksForOwnerMap.put(task.OwnerId, new List<Task>());
                }
                allTasksForOwnerMap.get(task.OwnerId).add(task);

                //today tasks         
                Date taskCreatedDate = Date.newInstance(task.CreatedDate.year(), task.CreatedDate.month(), task.CreatedDate.day());
                if (taskCreatedDate == Date.today()) {
                    if (! allTodayTasksForOwnerMap.containsKey(task.OwnerId) ) {
                        allTodayTasksForOwnerMap.put(task.OwnerId, new List<Task>());
                    }
                    allTodayTasksForOwnerMap.get(task.OwnerId).add(task);
                }
            }

            Map<String, List<Event>> allEventsForOwnerMap = new Map<String, List<Event>>();
            Map<String, List<Event>> allTodayEventsForOwnerMap = new Map<String, List<Event>>();
            for (Event event : eventsList) {
                //all events
                if (! allEventsForOwnerMap.containsKey(event.OwnerId) ) {
                    allEventsForOwnerMap.put(event.OwnerId, new List<Event>());
                }
                allEventsForOwnerMap.get(event.OwnerId).add(event);

                //today events
                Date eventCreatedDate = Date.newInstance(event.CreatedDate.year(), event.CreatedDate.month(), event.CreatedDate.day());
                if (eventCreatedDate == Date.today()) {
                    if (! allTodayEventsForOwnerMap.containsKey(event.OwnerId) ) {
                        allTodayEventsForOwnerMap.put(event.OwnerId, new List<Event>());
                    }
                    allTodayEventsForOwnerMap.get(event.OwnerId).add(event);
                }
            }

            this.finalList = new List<FinalList>();
            for (String userId : this.salesTeamMap.keySet()) {
                if (! allTasksForOwnerMap.containsKey(userId)) {
                    allTasksForOwnerMap.put(userId, new List<Task>());
                }
                if (! allTodayTasksForOwnerMap.containsKey(userId)) {
                    allTodayTasksForOwnerMap.put(userId, new List<Task>());
                }
                if (! allEventsForOwnerMap.containsKey(userId)) {
                    allEventsForOwnerMap.put(userId, new List<Event>());
                }
                if (! allTodayEventsForOwnerMap.containsKey(userId)) {
                    allTodayEventsForOwnerMap.put(userId, new List<Event>());
                }

                this.finalList.add(new FinalList(
                    userId, allTasksForOwnerMap.get(userId).size() + allEventsForOwnerMap.get(userId).size())
                );
                this.finalActivitiesMap.put(userId, allTasksForOwnerMap.get(userId).size() + allEventsForOwnerMap.get(userId).size());
                this.todayActivitiesMap.put(userId, allTodayTasksForOwnerMap.get(userId).size() + allTodayEventsForOwnerMap.get(userId).size());
            }
            this.finalList.sort();
        } else if (this.currentUser.UserRole.Name == 'CCS CZ Telesales' || this.currentUser.UserRole.Name == 'CCS CZ SME' || this.currentUser.UserRole.Name == 'CCS SK SME' ||
                   this.currentUser.UserRole.Name == 'CCS CZ KAM' || this.currentUser.UserRole.Name == 'CCS CZ LAM' ) {
            List<Task> tasksList = [
                SELECT OwnerId, CreatedDate, Owner.Name
                FROM Task
                WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND 
                    OwnerId = :this.currentUser.Id AND
                    Type != null
                LIMIT 30000];

            List<Event> eventsList = [
                SELECT OwnerId, CreatedDate, Owner.Name
                FROM Event
                WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND 
                    OwnerId = :this.currentUser.Id AND
                    Type != null
                LIMIT 30000];

            List<Task> todayTasksList = new List<Task>();
            for (Task task : tasksList) {
                Date taskCreatedDate = Date.newInstance(task.CreatedDate.year(), task.CreatedDate.month(), task.CreatedDate.day());
                if (taskCreatedDate == Date.today()) {
                    todayTasksList.add(task);
                }
            }

            List<Event> todayEventsList = new List<Event>();
            for (Event event : eventsList) {
                Date eventCreatedDate = Date.newInstance(event.CreatedDate.year(), event.CreatedDate.month(), event.CreatedDate.day());
                if (eventCreatedDate == Date.today()) {
                    todayEventsList.add(event);
                }
            }
            this.finalActivitiesMap.put(this.currentUser.Id, tasksList.size() + eventsList.size());
            this.todayActivitiesMap.put(this.currentUser.Id, todayTasksList.size() + todayEventsList.size());
        }
    }


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
    *  Name            : returnBusinessDays(Datetime sdate, Datetime edate)
    *  Summary         : counting the number of business days in the selected period    
    *  CreatedDate     : 27/10/2017
    *  Parameters      : -
    *  Returns         : number of business days
    ******************************************************************************/
    public Integer returnBusinessDays(Datetime startdate, Datetime enddate) {
        Integer iCount = 0;
        while (startdate < enddate) {
            if (startdate.format('E') != 'Sat' && startdate.format('E') != 'Sun') {
                iCount = iCount + 1;
            }
            startdate = startdate.addDays(1);
        }
        return iCount;
    }
    

    /*******************************************************************************
    *  Name            : returnUser()
    *  Summary         : getting current user    
    *  CreatedDate     : 27/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUser() {
		String userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        this.currentUser = [
            SELECT Id, FirstName, LastName, UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId];
	}


	/*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generating of the values of the selected period   
    *  CreatedDate     : 27/10/2017
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
    *  CreatedDate     : 27/10/2017
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
    *  CreatedDate     : 27/10/2017
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
    *  CreatedDate     : 27/10/2017
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
    *  CreatedDate     : 27/10/2017
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
        'CCS CZ LAM Team Lead',
        'CCS CZ KAM',
        'CCS CZ LAM'
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
}