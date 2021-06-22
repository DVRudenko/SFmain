public with sharing class DashboardFieldMeetingsPlanCCSctrl {
    public String selectedPeriod {get; set;}
    public String selectedYear {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Decimal currentPlan {get; set;}
    public User currentUser {get; set;}
    public Map<String, User> salesTeamMap {get; set;}
    public Map<String, EventTypesWrapper> finalEventTypesMap {get; set;}
    public Map<String, Event> allEventsForSelectedPeriod;
    public List<FinalList> finalList {get; set;}
    private Date startDateOfPeriod;
    private Date endDateOfPeriod;

    public DashboardFieldMeetingsPlanCCSctrl() {    
    }

    public void init() {
        try {
            returnUser();
            if (this.selectedYear == null) {
                this.selectedYear = returnCurrentYear();
            }
            if (availableRolesSet.contains(this.currentUser.UserRole.Name)) {
                this.finalEventTypesMap = new Map<String, EventTypesWrapper>();
                generateDataForCharts();
                generateFieldMeetingsPlan();
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This dashboard is not available for current user'));
            }       
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        } 
    }


    /*******************************************************************************
    *  Name            : generateFieldMeetingsPlan()
    *  Summary         : generate Field Meetings Plan for selected period for user  
    *  CreatedDate     : 26/10/2017
    *  ModifiedDate    : 26/03/2018
    *  Parameters      : -
    *  Returns         : void 
    ******************************************************************************/
    public void generateFieldMeetingsPlan() {
        if (this.currentUser.UserRole.Name == 'CCS SME Team Lead' || 
            this.currentUser.UserRole.Name == 'CCS CZ KAM Team Lead' || 
            this.currentUser.UserRole.Name == 'CCS CZ LAM Team Lead') {

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

            this.allEventsForSelectedPeriod = new Map<String, Event>([
                SELECT Id, OwnerId, Type
                FROM Event
                WHERE StartDateTime >= :this.startDateOfPeriod AND StartDateTime <= :this.endDateOfPeriod AND
                    OwnerId IN :this.salesTeamMap.keySet() AND
                    Type IN :eventsTypeSet
                LIMIT 50000
            ]);
  
            for (Event ev : this.allEventsForSelectedPeriod.values()) {
                if (! this.finalEventTypesMap.containsKey(ev.OwnerId)) {
                    this.finalEventTypesMap.put(ev.OwnerId, new EventTypesWrapper());
                    this.finalEventTypesMap.get(ev.OwnerId).firstMeetingType = 0;
                    this.finalEventTypesMap.get(ev.OwnerId).nextMeetingType = 0;
                    this.finalEventTypesMap.get(ev.OwnerId).retentionType = 0;
                    this.finalEventTypesMap.get(ev.OwnerId).developmentType = 0;
                    this.finalEventTypesMap.get(ev.OwnerId).careType = 0;
                    this.finalEventTypesMap.get(ev.OwnerId).trainingType = 0;
                    this.finalEventTypesMap.get(ev.OwnerId).acquisitionType = 0;
                }
                if (ev.Type == 'První schůzka') {
                    this.finalEventTypesMap.get(ev.OwnerId).firstMeetingType++; 
                } else if (ev.Type == 'Následná schůzka') {
                    this.finalEventTypesMap.get(ev.OwnerId).nextMeetingType++;
                } else if (ev.Type == 'Retence') {
                    this.finalEventTypesMap.get(ev.OwnerId).retentionType++;
                } else if (ev.Type == 'Rozvoj') {
                    this.finalEventTypesMap.get(ev.OwnerId).developmentType++;
                } else if (ev.Type == 'Péče') {
                    this.finalEventTypesMap.get(ev.OwnerId).careType++;
                } else if (ev.Type == 'Trénink') {
                    this.finalEventTypesMap.get(ev.OwnerId).trainingType++;
                } else if (ev.Type == 'Akvizice') {
                    this.finalEventTypesMap.get(ev.OwnerId).acquisitionType++;
                }
            }

            this.finalList = new List<FinalList>();
            for (String userId : this.salesTeamMap.keySet()) {
                if (! this.finalEventTypesMap.containsKey(userId)) {
                    this.finalEventTypesMap.put(userId, new EventTypesWrapper());
                    this.finalEventTypesMap.get(userId).firstMeetingType = 0;
                    this.finalEventTypesMap.get(userId).nextMeetingType = 0;
                    this.finalEventTypesMap.get(userId).retentionType = 0;
                    this.finalEventTypesMap.get(userId).developmentType = 0;
                    this.finalEventTypesMap.get(userId).careType = 0;
                    this.finalEventTypesMap.get(userId).trainingType = 0;
                    this.finalEventTypesMap.get(userId).acquisitionType = 0;
                }
                //sorting
                this.finalList.add(new FinalList(
                    userId,
                    this.finalEventTypesMap.get(userId).firstMeetingType + this.finalEventTypesMap.get(userId).nextMeetingType + this.finalEventTypesMap.get(userId).retentionType +
                    this.finalEventTypesMap.get(userId).developmentType + this.finalEventTypesMap.get(userId).careType + this.finalEventTypesMap.get(userId).trainingType +
                    this.finalEventTypesMap.get(userId).acquisitionType)
                );
            }
            this.finalList.sort();
        } else if (this.currentUser.UserRole.Name == 'CCS CZ SME' ||
                    this.currentUser.UserRole.Name == 'CCS SK SME' ||
                    this.currentUser.UserRole.Name == 'CCS CZ KAM' ||
                    this.currentUser.UserRole.Name == 'CCS CZ LAM') {

            this.allEventsForSelectedPeriod = new Map<String, Event>([
                SELECT Id, OwnerId, Type
                FROM Event
                WHERE StartDateTime >= :this.startDateOfPeriod AND StartDateTime <= :this.endDateOfPeriod AND
                    OwnerId = :this.currentUser.Id AND
                    Type IN :eventsTypeSet
                LIMIT 50000
            ]);

            this.finalEventTypesMap.put(this.currentUser.Id, new EventTypesWrapper());
            this.finalEventTypesMap.get(this.currentUser.Id).firstMeetingType = 0;
            this.finalEventTypesMap.get(this.currentUser.Id).nextMeetingType = 0;
            this.finalEventTypesMap.get(this.currentUser.Id).retentionType = 0;
            this.finalEventTypesMap.get(this.currentUser.Id).developmentType = 0;
            this.finalEventTypesMap.get(this.currentUser.Id).careType = 0;
            this.finalEventTypesMap.get(this.currentUser.Id).trainingType = 0;
            this.finalEventTypesMap.get(this.currentUser.Id).acquisitionType = 0;
            
            for (Event ev : this.allEventsForSelectedPeriod.values()) {
                if (ev.Type == 'První schůzka') {
                    this.finalEventTypesMap.get(this.currentUser.Id).firstMeetingType++; 
                } else if (ev.Type == 'Následná schůzka') {
                    this.finalEventTypesMap.get(this.currentUser.Id).nextMeetingType++;
                } else if (ev.Type == 'Retence') {
                    this.finalEventTypesMap.get(this.currentUser.Id).retentionType++;
                } else if (ev.Type == 'Rozvoj') {
                    this.finalEventTypesMap.get(this.currentUser.Id).developmentType++;
                } else if (ev.Type == 'Péče') {
                    this.finalEventTypesMap.get(this.currentUser.Id).careType++;
                } else if (ev.Type == 'Trénink') {
                    this.finalEventTypesMap.get(this.currentUser.Id).trainingType++;
                } else if (ev.Type == 'Akvizice') {
                    this.finalEventTypesMap.get(this.currentUser.Id).acquisitionType++;
                }
            }
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
    *  Name            : EventTypesWrapper
    *  Summary         : storage of events with different types    
    *  CreatedDate     : 26/10/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public class EventTypesWrapper {
        public Integer firstMeetingType {get; set;}
        public Integer nextMeetingType {get; set;}
        public Integer retentionType {get; set;}
        public Integer developmentType {get; set;}
        public Integer careType {get; set;}
        public Integer trainingType {get; set;}
        public Integer acquisitionType {get; set;}
    }


    /*******************************************************************************
    *  Name            : returnUser()
    *  Summary         : getting current user    
    *  CreatedDate     : 26/10/2017
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
    *  CreatedDate     : 26/10/2017
    *  ModifiedDate    : 08/01/2018
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

        Dashboard_meeting_plans__c weeklyKamPlan = Dashboard_meeting_plans__c.getInstance('KAM');
        Dashboard_meeting_plans__c weeklyLamPlan = Dashboard_meeting_plans__c.getInstance('LAM');
        Dashboard_meeting_plans__c weeklySmePlan = Dashboard_meeting_plans__c.getInstance('SME');

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
                SELECT Name, Start_Date__c, End_Date__c, Fleetcor_Calendar_Year__r.Name, Number_of_weeks__c
                FROM Fleetcor_Calendar_Month__c 
                WHERE Name = :curMonth AND Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                LIMIT 1];

            //week
            this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentMonth.Start_Date__c;
            endDateOfMonth = currentMonth.End_Date__c;
            this.selectedPeriod = currentWeek.get(0).Id;
            Decimal numberWeeks = currentMonth.Number_of_weeks__c;
            if (this.currentUser.UserRole.Name == 'CCS CZ KAM Team Lead') {
                if (weeklyKamPlan != null) {
                    this.currentPlan = weeklyKamPlan.Weekly_plan__c;
                } else {
                    this.currentPlan = 0;
                }
            } else if (this.currentUser.UserRole.Name == 'CCS CZ LAM Team Lead') {
                if (weeklyLamPlan != null) {
                    this.currentPlan = weeklyLamPlan.Weekly_plan__c;
                } else {
                    this.currentPlan = 0;
                }
            } else if (this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
                if (weeklySmePlan != null) {
                    this.currentPlan = weeklySmePlan.Weekly_plan__c;
                } else {
                    this.currentPlan = 0;
                }
            }
        } else {
            Id selectedId = selectedPeriod;          
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                            Fleetcor_Calendar_Month__r.Number_of_weeks__c, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //week
                this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
                this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
                startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
                endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c; 
                Decimal numberWeeks = currentWeek.get(0).Fleetcor_Calendar_Month__r.Number_of_weeks__c;
                if (this.currentUser.UserRole.Name == 'CCS CZ KAM Team Lead') {
                    if (weeklyKamPlan != null) {
                        this.currentPlan = weeklyKamPlan.Weekly_plan__c;
                    } else {
                        this.currentPlan = 0;
                    }
                } else if (this.currentUser.UserRole.Name == 'CCS CZ LAM Team Lead') {
                    if (weeklyLamPlan != null) {
                        this.currentPlan = weeklyLamPlan.Weekly_plan__c;
                    } else {
                        this.currentPlan = 0;
                    }
                } else if (this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
                    if (weeklySmePlan != null) {
                        this.currentPlan = weeklySmePlan.Weekly_plan__c;
                    } else {
                        this.currentPlan = 0;
                    }
                }
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {

                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c, Number_of_weeks__c
                    FROM Fleetcor_Calendar_Month__c
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //month
                this.startDateOfPeriod = currentMonth.Start_Date__c;
                this.endDateOfPeriod = currentMonth.End_Date__c;
                startDateOfMonth = currentMonth.Start_Date__c;
                endDateOfMonth = currentMonth.End_Date__c;
                Decimal numberWeeks = currentMonth.Number_of_weeks__c;
                if (this.currentUser.UserRole.Name == 'CCS CZ KAM Team Lead') {
                    this.currentPlan = numberWeeks * weeklyKamPlan.Weekly_plan__c;
                } else if (this.currentUser.UserRole.Name == 'CCS CZ LAM Team Lead') {
                    this.currentPlan = numberWeeks * weeklyLamPlan.Weekly_plan__c;
                } else if (this.currentUser.UserRole.Name == 'CCS SME Team Lead') {
                    this.currentPlan = numberWeeks * weeklySmePlan.Weekly_plan__c;
                }
            }
        }
        this.startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        this.endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Summary         : generating FLT periods (months and weeks) list   
    *  CreatedDate     : 26/10/2017
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
    *  CreatedDate     : 26/10/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYearsList() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> fltYearsList = [
                SELECT Name 
                FROM Fleetcor_Calendar_Year__c 
                ORDER BY Name DESC 
                LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : fltYearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }
        return options;
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 26/10/2017
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
    *  CreatedDate     : 26/10/2017
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
        'CCS SME Team Lead',
        'CCS CZ SME',
        'CCS SK SME',
        'CCS CZ KAM Team Lead',
        'CCS CZ LAM Team Lead',
        'CCS CZ KAM',
        'CCS CZ LAM'};

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