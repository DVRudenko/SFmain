public with sharing class DashboardCardsAndGPSUnitsSoldCCSctrl {
    public String selectedPeriod {get; set;}
    public String selectedYear {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public User currentUser {get; set;}
    public Map<String, User> salesTeamMap {get; set;}
    public Map<String, Decimal> numberOfCardsMap {get; set;}
    public Map<String, Decimal> numberOfCardsTodayMap {get; set;}
    public Map<String, Decimal> numberOfGPSunitsMap {get; set;}
    public Map<String, Decimal> numberOfGPSunitsTodayMap {get; set;}
    public Decimal accountSizeCards {get; set;}
    public Decimal accountSizeCarnet {get; set;}
    public List<FinalList> finalList {get; set;}
    private Map<String, Opportunity> allOpportunitiesMap;
    private Date startDateOfPeriod;
    private Date endDateOfPeriod;

    public DashboardCardsAndGPSUnitsSoldCCSctrl() {   
    }

    public void init() {
        try {
            returnUser();
            if (this.selectedYear == null) {
                this.selectedYear = returnCurrentYear();
            }  
            if (availableRolesSet.contains(this.currentUser.UserRole.Name)) {
                this.numberOfCardsMap = new Map<String, Decimal>();
                this.numberOfCardsTodayMap = new Map<String, Decimal>();
                this.numberOfGPSunitsMap = new Map<String, Decimal>();
                this.numberOfGPSunitsTodayMap = new Map<String, Decimal>(); 
                this.accountSizeCards = 0;  
                this.accountSizeCarnet = 0; 
                generateDataForCharts();
                calculateCardsAndGPSunits();
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This dashboard is not available for current user'));
            }           
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }    
    }


    /*******************************************************************************
    *  Name            : calculateCardsAndGPSunits()
    *  Summary         : calculating Cards And GPS units sold   
    *  CreatedDate     : 25/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculateCardsAndGPSunits() {
        if (this.currentUser.UserRole.Name == 'CCS Telesales Team Lead' || this.currentUser.UserRole.Name == 'CCS SME Team Lead' ||
            this.currentUser.UserRole.Name ==  'CCS CZ KAM Team Lead' || this.currentUser.UserRole.Name ==  'CCS CZ LAM Team Lead') {
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

            this.allOpportunitiesMap = new Map<String, Opportunity>([
                SELECT Id, OwnerId, CloseDate, Anzahl_der_Karten__c, Number_of_GPS_units__c
                FROM Opportunity
                WHERE StageName = 'Closed Won' AND
                    CloseDate >= :this.startDateOfPeriod AND CloseDate <= :this.endDateOfPeriod AND
                    OwnerId IN :this.salesTeamMap.keySet() AND 
                    Product_Solicited__c != 'CCS Bonus' AND
                    Product_Solicited__c != 'CCS Bonus+' AND
                    Product_Solicited__c != 'CCS Bonus Fleet' AND
                    ((Anzahl_der_Karten__c != null AND Anzahl_der_Karten__c != 0) OR
                    (Number_of_GPS_units__c != null AND Number_of_GPS_units__c != 0)) 
                LIMIT 50000
            ]);

            Map<String, List<Opportunity>> allOpptiesForOwnerMap = new Map<String, List<Opportunity>>();
            for (Opportunity oppty : this.allOpportunitiesMap.values()) {
                if (! allOpptiesForOwnerMap.containsKey(oppty.OwnerId)) {
                    allOpptiesForOwnerMap.put(oppty.OwnerId, new List<Opportunity>());
                }
                allOpptiesForOwnerMap.get(oppty.OwnerId).add(oppty);    
            }

            //calculating number cards
            for (String ownerId : allOpptiesForOwnerMap.keySet()) {
                Decimal numberCardsForOwner = 0;
                Decimal numberCardsTodayForOwner = 0;
                Decimal numberGPSForOwner = 0;
                Decimal numberGPSTodayForOwner = 0;

                Decimal numberAllCardsForAccount = 0;
                Decimal numberAllOpptiesWithCard = 0;
                Decimal numberAllGpsForAccount = 0;    
                Decimal numberAllOpptiesWithGpsUnits = 0;
                for (Opportunity opp : allOpptiesForOwnerMap.get(ownerId)) {
                    if (opp.Anzahl_der_Karten__c != null && opp.Anzahl_der_Karten__c != 0) {
                        numberCardsForOwner += opp.Anzahl_der_Karten__c;
                        if (opp.CloseDate == Date.today()) {
                            numberCardsTodayForOwner += opp.Anzahl_der_Karten__c;
                        }  
                        numberAllOpptiesWithCard++;
                    }
                    if (opp.Number_of_GPS_units__c != null && opp.Number_of_GPS_units__c != 0) {
                        numberGPSForOwner += opp.Number_of_GPS_units__c;
                        if (opp.CloseDate == Date.today()) {
                            numberGPSTodayForOwner += opp.Number_of_GPS_units__c;
                        }  
                        numberAllOpptiesWithGpsUnits++;
                    }
                }
                numberAllCardsForAccount += numberCardsForOwner;
                numberAllGpsForAccount += numberGPSForOwner;
                this.numberOfCardsMap.put(ownerId, numberCardsForOwner);
                this.numberOfCardsTodayMap.put(ownerId, numberCardsTodayForOwner);
                this.numberOfGPSunitsMap.put(ownerId, numberGPSForOwner);
                this.numberOfGPSunitsTodayMap.put(ownerId, numberGPSTodayForOwner);
                if (numberAllOpptiesWithCard != 0) {
                    this.accountSizeCards = (numberAllCardsForAccount/numberAllOpptiesWithCard).setScale(1); 
                }
                if (numberAllOpptiesWithGpsUnits != 0) {
                    this.accountSizeCarnet = (numberAllGpsForAccount/numberAllOpptiesWithGpsUnits).setScale(1);   
                }           
            }
                
            //FINAL
            this.finalList = new List<FinalList>();
            for (String userId : this.salesTeamMap.keySet()) {
                if (! this.numberOfCardsMap.containsKey(userId)) {
                    this.numberOfCardsMap.put(userId, 0);   
                }
                if (! this.numberOfCardsTodayMap.containsKey(userId)) {
                    this.numberOfCardsTodayMap.put(userId, 0);  
                }
                if (! this.numberOfGPSunitsMap.containsKey(userId)) {
                    this.numberOfGPSunitsMap.put(userId, 0);    
                }
                if (! this.numberOfGPSunitsTodayMap.containsKey(userId)) {
                    this.numberOfGPSunitsTodayMap.put(userId, 0);   
                }
                this.finalList.add(new FinalList(
                    userId,
                    this.numberOfCardsMap.get(userId) + this.numberOfGPSunitsMap.get(userId))
                );
            }
            this.finalList.sort();        
        } else if (this.currentUser.UserRole.Name == 'CCS CZ Telesales' || 
                this.currentUser.UserRole.Name == 'CCS CZ SME' || this.currentUser.UserRole.Name == 'CCS SK SME' ||
                this.currentUser.UserRole.Name == 'CCS CZ KAM' || this.currentUser.UserRole.Name == 'CCS CZ LAM') {

            this.allOpportunitiesMap = new Map<String, Opportunity>([
                SELECT Id, OwnerId, CloseDate, Anzahl_der_Karten__c, Number_of_GPS_units__c
                FROM Opportunity
                WHERE StageName = 'Closed Won' AND
                    CloseDate >= :this.startDateOfPeriod AND CloseDate <= :this.endDateOfPeriod AND
                    OwnerId = :this.currentUser.Id AND 
                    Product_Solicited__c != 'CCS Bonus' AND
                    Product_Solicited__c != 'CCS Bonus+' AND
                    Product_Solicited__c != 'CCS Bonus Fleet' AND
                    ((Anzahl_der_Karten__c != null AND Anzahl_der_Karten__c != 0) OR
                    (Number_of_GPS_units__c != null AND Number_of_GPS_units__c != 0)) 
                LIMIT 50000
            ]);

            Decimal numberCards = 0;
            Decimal numberCardsToday = 0;
            Decimal numberGPS = 0;
            Decimal numberGPSToday = 0;

            Decimal numberAllOpptiesWithCard = 0;  
            Decimal numberAllOpptiesWithGpsUnits = 0;
            for (Opportunity opp : this.allOpportunitiesMap.values()) {
                if (opp.Anzahl_der_Karten__c != null && opp.Anzahl_der_Karten__c != 0) {
                    numberCards += opp.Anzahl_der_Karten__c;
                    if (opp.CloseDate == Date.today()) {
                        numberCardsToday += opp.Anzahl_der_Karten__c;
                    }
                    numberAllOpptiesWithCard++;
                }
                if (opp.Number_of_GPS_units__c != null && opp.Number_of_GPS_units__c != 0) {
                    numberGPS += opp.Number_of_GPS_units__c;
                    if (opp.CloseDate == Date.today()) {
                        numberGPSToday += opp.Number_of_GPS_units__c;
                    }
                    numberAllOpptiesWithGpsUnits++;
                }   
            }

            this.numberOfCardsMap.put(this.currentUser.Id, numberCards);
            this.numberOfCardsTodayMap.put(this.currentUser.Id, numberCardsToday);
            this.numberOfGPSunitsMap.put(this.currentUser.Id, numberGPS);
            this.numberOfGPSunitsTodayMap.put(this.currentUser.Id, numberGPSToday);
            if (numberAllOpptiesWithCard != 0) {
                this.accountSizeCards = (numberOfCardsMap.get(this.currentUser.Id)/numberAllOpptiesWithCard).setScale(1);
            } 
            if (numberAllOpptiesWithGpsUnits != 0) {
                this.accountSizeCarnet = (numberOfGPSunitsMap.get(this.currentUser.Id)/numberAllOpptiesWithGpsUnits).setScale(1);
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
    *  Name            : returnUser()
    *  Summary         : getting current user    
    *  CreatedDate     : 25/10/2017
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
    *  CreatedDate     : 25/10/2017
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
    *  CreatedDate     : 25/10/2017
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
    *  CreatedDate     : 25/10/2017
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
    *  CreatedDate     : 25/10/2017
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
    *  CreatedDate     : 25/10/2017
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