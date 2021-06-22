public with sharing class DashboardTopDealsPPRCtrl {
    public String selectedPeriod { get; set; } //String for period display list
    public String selectedYear { get; set; } //String for year display list
    public String startDateOfMonthString { get; set; }
    public String endDateOfMonthString { get; set; }
    public UserRole currentRole { get; set; } //role of connected user
    public UserRole userRole { get; set; } //role by which gathering data
    public String selectedRole { get; set; } //String role for role display list
    public String lookInUser { get; set; } //String user for lookIn user display list
    public Integer recordsLimit { get; set; } //Integer for top display list
    public List<SortingList> sortingList { get; set; }
    public Map<String, Decimal> finalTopDealsMap { get; set; } //Map with oppty Id and Projected_Liters_weekly__c
    public Map<String, Opportunity> namesOfTopDealsMap { get; set; } //Map with oppty Id and Name
    public Map<String, String> linkColorsMap { get; set; } //Map with oppty Id and color link (according to last contact value)
    public Map<Id, UserRole> mapOfAvailableRoles { get; set; } //Map with UserRoleId and UserRole sObject which is available for current user
    public Date startDateOfPeriod; //start of looking period
    public Date endDateOfPeriod; //end of looking period
    public String topCondition { get; set; } //String for radio buttons
    private String userId; //connected userId

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 10/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {

            if (this.userId == null) {
                this.userId = DashboardMethods.returnUserId();
            }

            if (this.selectedYear == null) {
                this.selectedYear = DashboardMethods.returnCurrentYear();
            }

            if (this.currentRole == null) {
                User currentUser = [
                        SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
                        FROM User
                        WHERE Id = :this.userId
                        AND IsActive = true
                ];
                this.currentRole = currentUser.UserRole;
            }

            if (this.userRole == null) {
                this.userRole = DashboardMethods.getUserRole(DashboardMethods.returnUserRoleId());
            }

            if (this.selectedRole == null) {
                this.selectedRole = this.userRole.Id;
            }

            if (this.lookInUser == null) {
                this.lookInUser = '--Нет--';
            }

            if (this.mapOfAvailableRoles == null) {
                this.mapOfAvailableRoles = new Map<Id, UserRole>();
                for (UserRole userRole : DashboardMethods.userRoleTree.toUserRoleList(this.currentRole)) {
                    this.mapOfAvailableRoles.put(userRole.Id, userRole);
                }
            }

            if (this.recordsLimit == null) {
                this.recordsLimit = Integer.valueOf(DashboardMethods.limitsList.get(0).getValue());
            }

            if (this.topCondition == null)
            {
                this.topCondition = 'Liters';
            }

            generateDataForCharts();
            generateTopDealsList('By Role');

        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : generateTopDealsList()
    *  Type            : method
    *  Summary         : generating Top Deals in progress list for the selected period
    *  CreatedDate     : 10/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateTopDealsList(String condition) {
        this.finalTopDealsMap = new Map<String, Decimal>();
        this.namesOfTopDealsMap = new Map<String, Opportunity>();
        this.sortingList = new List<SortingList>();
        this.linkColorsMap = new Map<String, String>();

        Map<Id, Opportunity> allOpportunitiesMap;

        String query = 'SELECT Name, Owner.Name, OwnerId, StageName, Projected_Liters_weekly__c, Number_of_Vehicles__c, CreatedDate,' +
                '(SELECT Id, LastModifiedDate FROM Tasks WHERE IsClosed = TRUE ORDER BY LastModifiedDate DESC LIMIT 1) FROM Opportunity ' +
                'WHERE ((CreatedDate <= :endDateOfPeriod AND CreatedDate >= :startDateOfPeriod) OR (Last_Owner_Change_Date_RUS__c <= :endDateOfPeriod AND Last_Owner_Change_Date_RUS__c >= :startDateOfPeriod)) ' +
                'AND StageName NOT IN (\'Отказ\', \'Moved to Start\', \'Потерян в конкуренции\') ' +
                'AND RecordType.Name = \'Russian Sales\' ';

        if(condition == 'By Role')
        {
            List<Id> ids = DashboardMethods.userRoleTree.toIdList(this.userRole);
            query += 'AND Owner.UserRoleId IN :ids ';
        }

        if(condition == 'By User')
        {
            query += 'AND OwnerId = :lookInUser ';
        }

        if(this.topCondition == 'Liters')
        {
            query += 'AND Projected_Liters_weekly__c != null ' +
                    'AND Projected_Liters_weekly__c != 0 ' +
                    'ORDER BY Projected_Liters_weekly__c DESC ';
        }

        if(this.topCondition == 'Vehicles')
        {
            query += 'AND Number_of_Vehicles__c != null ' +
                    'AND Number_of_Vehicles__c != 0 ' +
                    'ORDER BY Number_of_Vehicles__c DESC ';
        }

        query += 'LIMIT :recordsLimit';

        System.debug(query);

        List<Opportunity> allOpportunitiesList = Database.query(query);

        for (Opportunity opportunity : allOpportunitiesList) {

            this.namesOfTopDealsMap.put(opportunity.Id, opportunity);

            String lastContact = '';
            if (opportunity.Tasks.isEmpty()) {
                lastContact = '30+';
            } else if (opportunity.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) > 30) {
                lastContact = '30+';
            } else if (opportunity.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) > 15 &&
                    opportunity.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) <= 30 ) {
                lastContact = '16-30';
            } else if (opportunity.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) <= 15) {
                lastContact = '1-15';
            }

            this.linkColorsMap.put(opportunity.Id, lastContact);

            if(this.topCondition == 'Liters')
            {
                this.finalTopDealsMap.put(opportunity.Id, opportunity.Projected_Liters_weekly__c);
                this.sortingList.add(new SortingList(opportunity.Id, opportunity.Projected_Liters_weekly__c));
            }

            if(this.topCondition == 'Vehicles')
            {
                this.finalTopDealsMap.put(opportunity.Id, opportunity.Number_of_Vehicles__c);
                this.sortingList.add(new SortingList(opportunity.Id, opportunity.Number_of_Vehicles__c));
            }
        }
    }

    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Type            : method
    *  Summary         : generating FLT periods (months and weeks) list
    *  CreatedDate     : 08/05/2018
    *  Parameters      : -
    *  Returns         : SelectOption (FLT periods)
    ******************************************************************************/
    public List<SelectOption> getPeriodsList() {
        return DashboardMethods.getPeriodsList(this.selectedYear);
    }

    /*******************************************************************************
    *  Name            : getLimitsList()
    *  Type            : method
    *  Summary         : Display limit in limit selectbox
    *  CreatedDate     : 15/05/2018
    *  Parameters      :
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getLimitsList() {
        return DashboardMethods.limitsList;
    }

    /*******************************************************************************
    *  Name            : getYearsList()
    *  Type            : method
    *  Summary         : Display years in selectbox
    *  CreatedDate     : 08/05/2018
    *  Parameters      :
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYearsList() {
        return DashboardMethods.getYearsList();
    }

    /*******************************************************************************
    *  Name            : getRolesList()
    *  Type            : method
    *  Summary         : Display available roles in selectbox
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getRolesList() {
        List<SelectOption> selectRoleList = new List<SelectOption>();

        for (String option : DashboardMethods.userRoleTree.toListWithLevels(this.currentRole)) {
            selectRoleList.add(new SelectOption(option.remove('- ').trim(), option.remove(option.remove('- ')) + this.mapOfAvailableRoles.get(option.remove('- ').trim()).Name));
        }
        return selectRoleList;
    }

    /*******************************************************************************
    *  Name            : getLookInUserList()
    *  Type            : method
    *  Summary         : Display available users in selectbox
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getLookInUserList() {
        List<SelectOption> selectLookInUser = new List<SelectOption>();

        List<User> users = [SELECT Id, Name FROM User WHERE UserRoleId IN :DashboardMethods.userRoleTree.toIdList(this.userRole) AND IsActive = true ORDER BY Name];

        selectLookInUser.add(new SelectOption('--Нет--', '--Нет--'));

        for (User user : users) {
            selectLookInUser.add(new SelectOption(user.Id, user.Name));
        }

        return selectLookInUser;
    }

    /*******************************************************************************
    *  Name            : changeYear()
    *  Type            : method
    *  Summary         : Setting the period depending on the selected year
    *  CreatedDate     : 08/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeYear() {
        List<Fleetcor_Calendar_Week__c> currentFLTweek = [
                SELECT Id, Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name
                FROM Fleetcor_Calendar_Week__c
                WHERE Start_Date__c <= TODAY AND
                End_Date__c >= TODAY
                LIMIT 1
        ];

        String currentWeekId;
        String currentFLTyear;
        if (!currentFLTweek.isEmpty()) {
            currentWeekId = currentFLTweek.get(0).Id;
            currentFLTyear = currentFLTweek.get(0).Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name;
        }

        if (this.selectedYear != currentFLTyear) {
            String firstMonthId = [
                    SELECT Id
                    FROM Fleetcor_Calendar_Month__c
                    WHERE Name = :DashboardMethods.monthsMap.get(1) AND
                    Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                    LIMIT 1
            ].Id;
            this.selectedPeriod = firstMonthId;
        } else {
            this.selectedPeriod = currentWeekId;
        }

        if (this.lookInUser == '--Нет--') {
            init();
        } else {
            generateDataForCharts();
            generateTopDealsList('By User');
        }
    }

    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Type            : method
    *  Summary         : generating of the values of the selected period
    *  CreatedDate     : 10/05/2018
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
                LIMIT 1
        ];

        Fleetcor_Calendar_Month__c currentMonth = new Fleetcor_Calendar_Month__c();
        if (this.selectedPeriod == null) {
            if (currentWeek.isEmpty()) {
                currentWeek = [
                        SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                        FROM Fleetcor_Calendar_Week__c
                        WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                        ORDER BY Start_Date__c DESC
                        LIMIT 1
                ];
            }

            String curMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Name;
            currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c, Fleetcor_Calendar_Year__r.Name
                    FROM Fleetcor_Calendar_Month__c
                    WHERE Name = :curMonth AND Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                    LIMIT 1
            ];

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
                        LIMIT 1
                ];

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
                        LIMIT 1
                ];

                //month
                this.startDateOfPeriod = currentMonth.Start_Date__c;
                this.endDateOfPeriod = currentMonth.End_Date__c;
                startDateOfMonth = currentMonth.Start_Date__c;
                endDateOfMonth = currentMonth.End_Date__c;
            }
        }
        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + DashboardMethods.monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + DashboardMethods.monthsMap.get(endDateOfMonth.month());
    }

    /*******************************************************************************
    *  Name            : changeLimit()
    *  Type            : method
    *  Summary         : generating report depending on period selected
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changePeriod() {
        if (this.lookInUser == '--Нет--') {
            init();
        } else {
            generateDataForCharts();
            generateTopDealsList('By User');
        }
    }

    /*******************************************************************************
    *  Name            : changeRole()
    *  Type            : method
    *  Summary         : Setting UserRole depending on the selected UserRole
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeRole() {
        this.userRole = this.mapOfAvailableRoles.get(selectedRole);
        this.lookInUser = '--Нет--';
        generateTopDealsList('By Role');
    }

    /*******************************************************************************
    *  Name            : changeLookInUser()
    *  Type            : method
    *  Summary         : generating report depending on look in user selected
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeLookInUser() {
        if (this.lookInUser == '--Нет--') {
            generateTopDealsList('By Role');
        } else {
            generateTopDealsList('By User');
        }
    }

    /*******************************************************************************
    *  Name            : changeLimit()
    *  Type            : method
    *  Summary         : generating report depending on limit selected
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeLimit() {
        if (this.lookInUser == '--Нет--') {
            generateTopDealsList('By Role');
        } else {
            generateTopDealsList('By User');
        }
    }

    /*******************************************************************************
    *  Name            : changeTopCondition()
    *  Type            : method
    *  Summary         : handle radio change
    *  CreatedDate     : 20/06/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public void changeTopCondition()
    {
        changeLookInUser();//call generate data according to Role or User choose
    }

    /*******************************************************************************
    *  Name            : getTopConditions()
    *  Type            : method
    *  Summary         : get values for Projected liters/Vehicles number radio buttons
    *  CreatedDate     : 20/06/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getTopConditions() {
        String litersLabel = Opportunity.SObjectType.fields.Projected_Liters_weekly__c.getDescribe().label;// .getLabelPlural();
        String vehiclesLabel = Opportunity.SObjectType.fields.Number_of_Vehicles__c.getDescribe().label; //getDescribe().getLabelPlural();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Liters', litersLabel));
        options.add(new SelectOption('Vehicles', vehiclesLabel));
        //Number_of_Vehicles__c

        return options;
    }

    /*******************************************************************************
    *  Name            : sortingList()
    *  Summary         : Sorting by total fuel consumption
    *  CreatedDate     : 10/05/2018
    *  Parameters      : String id, Decimal compareValue
    *  Returns         : Integer
    ******************************************************************************/
    public class SortingList {
        public String id { get; set; }
        public Decimal compareValue { get; set; }

        public sortingList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }
    }
}