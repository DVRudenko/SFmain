public with sharing class SalesDashboardLiters {
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public List<String> messagesList {get; set;}
    public PlanWrapper currentPlan {get; set;}
    public Fleetcor_Calendar_Month__c currentMonth {get; set;}
    public String selectedYear {get; set;}
    public Integer myNumberOfLiters {get; set;}
    public Integer myNumberOfLitersNET {get; set;}
    public Map<Id, Integer> teamOppsMap {get; set;}
    public Map<Id, Integer> teamOppsCardsMap {get; set;}
    public Map<Id, PlanWrapper> teamOppsPlanMap {get; set;}
    public List<FinalList> finalList {get; set;}
    public User currentUser {get; set;}
    public String selectedMonth {get; set;}

    public Decimal todaysOpps {get; set;}
    public Map<String, Decimal> todaysSalesOppsMap {get; set;}
    
    private Date startDateOfMonth {get; set;}
    private Date endDateOfMonth {get; set;}
    private Date startDateOfWeek {get; set;}
    private Date endDateOfWeek {get; set;}
    private String userId;

    public Integer litersForecast {get; set;}
    public Decimal startsPlanNET {get; set;}
    public Decimal percentStarted {get; set;}
    public Decimal bonusRate {get; set;}

    public String periodName;
    public Date startDateOfPeriod;
    public Date endDateOfPeriod;
    public String selectedPeriod {get; set;}

    public SalesDashboardLiters() {

    }

    /*
        Description: Initial generation data for charts and get current plan
        Author: Eugene Vabishchevich
    */

    public void init() {
        this.litersForecast = 0;
        this.percentStarted = 80;
        this.messagesList = new List<String>();
        this.currentPlan = new PlanWrapper('',0,0,'');
        this.teamOppsMap = new Map<Id, Integer>();
        this.teamOppsCardsMap = new Map<Id, Integer>();
        this.teamOppsPlanMap = new Map<Id, PlanWrapper>();
        this.finalList = new List<FinalList>();
        this.todaysSalesOppsMap = new Map<String, Decimal>();
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
        generateDataForCharts();
        currentPlan();
        myNumberOfLitersNET = 0;
    }

    /*
        Method: Get PLAN record or display error message
        Description: Generate data for charts and get current plan + get my current Closed Won Opportunities
        Author: Eugene Vabishchevich
    */
    public void currentPlan() {
        returnUserId();
        currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :userId];
        if (this.periodName == 'month') {
            this.startDateOfPeriod = this.startDateOfMonth;
            this.endDateOfPeriod = this.endDateOfMonth;
        } else {
            this.startDateOfPeriod = this.startDateOfWeek;
            this.endDateOfPeriod = this.endDateOfWeek;
        }

        if (currentUser.Profile.Name == 'Sales' || currentUser.Profile.Name == 'Sales Inbound' || currentUser.Profile.Name == 'Harte Hanke (Sales)') {
            //sales
            if (currentUser.UserRole != null) {
                List<Sales_Plan__c> planList = [
                        SELECT Fleetcor_Calendar_Month__r.Name, Number_of_cards_Default__c, User__c, Year__c,
                               User__r.Name, Fleetcor_Calendar_Month__r.Number_of_weeks__c, User__r.UserRole.Name,
                               Number_of_liters_default__c
                        FROM Sales_Plan__c
                        WHERE Year__c = :this.selectedYear AND
                              Fleetcor_Calendar_Month__r.Name = :selectedMonth AND
                              User__c = :currentUser.Id
                        LIMIT 1000];

                todaysOpps = 0;
                List<Opportunity> todaysOppsList = [
                        SELECT Anzahl_der_Karten__c, Total_consumption_l_month__c
                        FROM Opportunity
                        WHERE OwnerId = :currentUser.Id AND StageName = 'Closed Won' AND 
                              CloseDate = TODAY
                        LIMIT 10000];
                for (Opportunity o : todaysOppsList) {
                    if (o.Total_consumption_l_month__c != null) {
                        todaysOpps = todaysOpps + o.Total_consumption_l_month__c*12;
                    }
                }

                List<Opportunity> myOpps = [
                        SELECT Anzahl_der_Karten__c, Total_consumption_l_month__c
                        FROM Opportunity
                        WHERE OwnerId = :currentUser.Id AND StageName = 'Closed Won' AND 
                              CloseDate >= :startDateOfPeriod AND CloseDate <= :endDateOfPeriod
                        LIMIT 10000];

                myNumberOfLiters = 0;
                for (Opportunity opp : myOpps) {
                    if (opp.Total_consumption_l_month__c != null) {
                        myNumberOfLiters += Integer.valueOf(opp.Total_consumption_l_month__c)*12;
                    }
                }

                if (planList.isEmpty()) {
                    messagesList.add('You don\'t have plan for current month. Please contact your administrator or team lead.');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, messagesList.get(0)));
                } else {
                    Decimal numberOfLiters;
                    if (this.periodName == 'month') {
                        numberOfLiters = planList.get(0).Number_of_liters_default__c;
                    } else {
                        numberOfLiters = planList.get(0).Number_of_liters_default__c / planList.get(0).Fleetcor_Calendar_Month__r.Number_of_weeks__c;
                    }
                    currentPlan = new PlanWrapper(
                        planList.get(0).User__r.Name, 
                        numberOfLiters, 
                        planList.get(0).Fleetcor_Calendar_Month__r.Number_of_weeks__c, 
                        planList.get(0).User__r.UserRole.Name);
                    startsPlanNET = currentPlan.numberOfLiters;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have User Role. Please contact your administrator.'));    
            }
        } else if (currentUser.Profile.Name == 'Salesteamleiter' || currentUser.Profile.Name == 'Harte Hank Teamleiter' || currentUser.Profile.Name == 'Salesteamleiter Inbound') {
            //team leader
            if (currentUser.UserRole.Name != null && currentUser.UserRole.Name.contains('Teamleiter')) {
                // String leadRole = currentUser.UserRole.Name;
                // String salesTeamRole = leadRole.replace('Teamleiter', 'Salesteam');
                Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                        SELECT Id
                        FROM UserRole
                        WHERE ParentRoleId = :currentUser.UserRoleId
                        LIMIT 1000]);

                Map<Id, User> salesTeamMap = new Map<Id, User>([
                        SELECT Id
                        FROM User
                        WHERE UserRoleId IN :salesRolesMap.keySet() AND isActive = TRUE
                        LIMIT 10000]);

                teamOppsPlanMap = new Map<Id, PlanWrapper>();
                teamOppsMap = new Map<Id, Integer>();

                List<Sales_Plan__c> planList = [
                        SELECT Fleetcor_Calendar_Month__r.Name, Number_of_cards_Default__c, User__c, Year__c,
                               User__r.Name, Fleetcor_Calendar_Month__r.Number_of_weeks__c, User__r.UserRole.Name,
                               Number_of_liters_default__c
                        FROM Sales_Plan__c
                        WHERE Year__c = :this.selectedYear AND
                              Fleetcor_Calendar_Month__r.Name = :selectedMonth AND
                              User__c IN :salesTeamMap.keySet()
                        LIMIT 10000];

                for (Sales_Plan__c plan : planList) {
                    if ( ! teamOppsPlanMap.containsKey(plan.User__c) ) {
                        Decimal numberOfLiters;
                        if (this.periodName == 'month') {
                            numberOfLiters = plan.Number_of_liters_default__c;
                        } else {
                            numberOfLiters = plan.Number_of_liters_default__c / plan.Fleetcor_Calendar_Month__r.Number_of_weeks__c;
                        }
                        teamOppsPlanMap.put(
                            plan.User__c, 
                            new PlanWrapper(plan.User__r.Name, numberOfLiters, plan.Fleetcor_Calendar_Month__r.Number_of_weeks__c, plan.User__r.UserRole.Name));    
                    }

                    if ( ! teamOppsCardsMap.containsKey(plan.User__c) ) {
                        teamOppsCardsMap.put(plan.User__c, 0);
                    }
                }

                List<Opportunity> salesOppsList = [
                        SELECT Anzahl_der_Karten__c, Name, OwnerId, Owner.Name, Total_consumption_l_month__c
                        FROM Opportunity
                        WHERE OwnerId IN :teamOppsPlanMap.keySet() AND StageName = 'Closed Won' AND 
                              CloseDate >= :startDateOfPeriod AND CloseDate <= :endDateOfPeriod
                        LIMIT 10000];

                List<Opportunity> todaysSalesOppsList = [
                        SELECT Anzahl_der_Karten__c, Name, OwnerId, Owner.Name, Total_consumption_l_month__c
                        FROM Opportunity
                        WHERE OwnerId IN :teamOppsPlanMap.keySet() AND StageName = 'Closed Won' AND 
                              CloseDate = TODAY
                        LIMIT 10000];

                for (Opportunity o : todaysSalesOppsList) {
                    if ( ! todaysSalesOppsMap.containsKey(o.Owner.Name)) {
                        todaysSalesOppsMap.put(o.Owner.Name, 0);
                    }

                    if (o.Total_consumption_l_month__c != null) {
                        Decimal i = todaysSalesOppsMap.get(o.Owner.Name) + o.Total_consumption_l_month__c * 12;
                        todaysSalesOppsMap.put(o.Owner.Name, i);
                    }
                }

                for (Opportunity o : salesOppsList) {
                    //Todays
                    if ( ! todaysSalesOppsMap.containsKey(o.Owner.Name)) {
                        todaysSalesOppsMap.put(o.Owner.Name, 0);
                    }

                    if ( ! teamOppsMap.containsKey(o.OwnerId) ) {
                        teamOppsMap.put(o.OwnerId, 0);
                    }

                    Integer i = teamOppsMap.get(o.OwnerId) + 1;
                    teamOppsMap.put(o.OwnerId,i);

                    //Liters
                    if ( ! teamOppsCardsMap.containsKey(o.OwnerId) ) {
                        teamOppsCardsMap.put(o.OwnerId, 0);
                    }

                    if (o.Total_consumption_l_month__c != null) {
                        Integer j = teamOppsCardsMap.get(o.OwnerId) + Integer.valueOf(o.Total_consumption_l_month__c) * 12;
                        teamOppsCardsMap.put(o.OwnerId, j);
                    }
                }

                for (Sales_Plan__c plan : planList) {
                    if ( ! teamOppsMap.containsKey(plan.User__c) ) {
                        teamOppsMap.put(plan.User__c, 0);
                    }

                    if ( ! todaysSalesOppsMap.containsKey(plan.User__r.Name) ) {
                        todaysSalesOppsMap.put(plan.User__r.Name, 0);
                    }
                }

                for (String uid : teamOppsMap.keySet()) {
                    finalList.add(new FinalList(
                        uid,
                        teamOppsCardsMap.get(uid)));
                }

                finalList.sort();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have valid User Role. Please contact your administrator.'));     
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Dashboard is available only for Sales and Sales Team Lead.'));
        }
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 26/12/2016
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

        if (selectedPeriod == null) {
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

            selectedPeriod = currentWeek.get(0).Id;
            selectedMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Name;
            this.periodName = 'week';
            doSetPeriod(currentMonth.Start_Date__c, currentMonth.End_Date__c, currentWeek.get(0).Start_Date__c, currentWeek.get(0).End_Date__c);
        } else {
            Id selectedId = selectedPeriod;           
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :selectedPeriod
                    LIMIT 1];

                this.periodName = 'week';
                selectedMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Name;
                doSetPeriod(currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c, currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c,
                            currentWeek.get(0).Start_Date__c, currentWeek.get(0).End_Date__c);      
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :selectedPeriod
                    LIMIT 1];

                this.periodName = 'month';
                selectedMonth = currentMonth.Name;
                doSetPeriod(currentMonth.Start_Date__c, currentMonth.End_Date__c, currentMonth.Start_Date__c, currentMonth.End_Date__c);  
            }         
        }
        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());    
    }


    public void doSetPeriod(Date startMonth, Date endMonth, Date startWeek, Date endWeek) {
        startDateOfMonth = startMonth;
        endDateOfMonth = endMonth;
        startDateOfWeek = startWeek;
        endDateOfWeek = endWeek;
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


    public Date returnFleetCorLastDayMonth(Date todayDateP) {
        DateTime tempEndDateOfMonth = DateTime.newInstance(todayDateP.toStartOfMonth().addDays(Date.daysInMonth(todayDateP.year(), todayDateP.month())), Time.newInstance(0, 0, 0, 0));
        Date dateEndDateOfMonth;

        if (tempEndDateOfMonth.format('EEEE') == 'Sunday') {
            dateEndDateOfMonth = Date.newinstance(tempEndDateOfMonth.year(), tempEndDateOfMonth.month(), tempEndDateOfMonth.day());
        } else {
            Date tempEndDate = Date.newinstance(tempEndDateOfMonth.year(), tempEndDateOfMonth.month(), tempEndDateOfMonth.day());
            dateEndDateOfMonth = tempEndDate.toStartOfWeek().toStartOfWeek().addDays(-1);
        }

        return dateEndDateOfMonth;
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
    *  Name            : getYears()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 26/12/2016
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

    public class PlanWrapper {
        public String name {get; set;}
        public Decimal numberOfLiters {get; set;}
        public Decimal numberOfWeeks {get; set;}
        public String userRole {get; set;}

        public PlanWrapper(String name, Decimal numberOfLiters, Decimal numberOfWeeks, String userRole) {
            this.name = name;
            this.numberOfWeeks = numberOfWeeks;
            this.userRole = userRole;
            if (userRole.contains('Inbound')) {
                if (numberOfWeeks == 3) {
                    this.numberOfLiters = (numberOfLiters * 1.3 * 0.75).round(System.RoundingMode.CEILING);
                } else if (numberOfWeeks == 5) {
                    this.numberOfLiters = (numberOfLiters * 1.3 * 1.25).round(System.RoundingMode.CEILING);
                } else {
                    this.numberOfLiters = (numberOfLiters * 1.3).round(System.RoundingMode.CEILING);
                }
            } else if (userRole.contains('Outbound') || userRole.contains('Salesteam Harte Hank')) {
                if (numberOfWeeks == 3) {
                    this.numberOfLiters = (numberOfLiters * 0.75).round(System.RoundingMode.CEILING);
                } else if (numberOfWeeks == 5) {
                    this.numberOfLiters = (numberOfLiters * 1.25).round(System.RoundingMode.CEILING);
                } else {
                    this.numberOfLiters = (numberOfLiters).round(System.RoundingMode.CEILING);
                }
            } else {
                this.numberOfLiters = 0;
            }
        }
    }

    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
            if (userId == null) {
                userId = UserInfo.getUserId();
            }
    }

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
        12 => 'December'
    }; 

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
        'December' => 12
    };
}