/**
 * Created by Nikita.Mikhailov on 30.05.2018.
 */

public with sharing class DashboardNetStartsPPRCtrl {

    public String selectedPeriod { get; set; } //String for period display list
    public String startDateOfMonthString { get; set; }
    public String endDateOfMonthString { get; set; }
    public String selectedRole { get; set; } //String role for role display list
    public String selectedYear { get; set; } //String for year display list
    public String finalValues { get; set; } //JSON string representing finalList of looking values

    private Map<Id, User> salesTeamMap { get; set; } //Users Map to gather and show data
    private Date startDateOfPeriod; //start of looking period
    private Date endDateOfPeriod; //end of looking period
    private String userId { get; set; } //connected userId
    private UserRole userRole { get; set; } //role by which gathering data
    private UserRole currentRole { get; set; } //role of connected user
    private Map<Id, UserRole> mapOfAvailableRoles { get; set; }//Map with UserRoleId and UserRole sObject which is available for current user
    private String selectedMonthId { get; set; }//Selected month id

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            if (this.userId == null) {
                this.userId = DashboardMethods.returnUserId();
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

            if (this.selectedYear == null) {
                this.selectedYear = DashboardMethods.returnCurrentYear();
            }

            if (this.mapOfAvailableRoles == null) {
                this.mapOfAvailableRoles = new Map<Id, UserRole>();
                for (UserRole userRole : DashboardMethods.userRoleTree.toUserRoleList(this.currentRole)) {
                    this.mapOfAvailableRoles.put(userRole.Id, userRole);
                }
            }

            if (this.salesTeamMap == null) {
                this.salesTeamMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE IsActive = true AND UserRoleId IN :DashboardMethods.userRoleTree.toUserRoleList(this.userRole)]);
            }

            generateDataForCharts();
            generateNetStartsReport();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : generateNetStartsReport()
    *  Type            : method
    *  Summary         : gather data for report
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void generateNetStartsReport() {
        this.finalValues = '';

        List<Starts__c> volumes = [
                SELECT Id, Opportunity__r.OwnerId, starts__c, Pump_date_oppty__c
                FROM Starts__c
                WHERE Pump_date_oppty__c >= :startDateOfPeriod AND Pump_date_oppty__c <= :endDateOfPeriod
                AND Transit_ID__c != null
                AND client_week_number__c <= 10
                ORDER BY client_week_number__c
                LIMIT 50000
        ];

        Map<Id, Decimal> userIdsWithFactStarts = new Map<Id, Decimal>();

        for (Starts__c volume : volumes) {
            if (userIdsWithFactStarts.get(volume.Opportunity__r.OwnerId) == null) {
                userIdsWithFactStarts.put(volume.Opportunity__r.OwnerId, volume.starts__c == null ? 0 : volume.starts__c);
            } else {
                userIdsWithFactStarts.put(volume.Opportunity__r.OwnerId, volume.starts__c + (userIdsWithFactStarts.get(volume.Opportunity__r.OwnerId) == null ? 0 : userIdsWithFactStarts.get(volume.Opportunity__r.OwnerId)));
            }
        }

        List<Sales_Plan__c> salesPlanList = new List<Sales_Plan__c>([
                SELECT Id, Nets__c, User__c, Fleetcor_Calendar_Month__c, Fleetcor_Calendar_Month__r.Number_of_weeks__c
                FROM Sales_Plan__c
                WHERE User__c IN :this.salesTeamMap.keySet()
                AND Fleetcor_Calendar_Month__c = :this.selectedMonthId
        ]);

        Map<Id, Decimal> salesPlanForUsers = new Map<Id, Decimal>();

        for (Sales_Plan__c plan : salesPlanList) {
            Decimal numberOfWeeks = plan.Fleetcor_Calendar_Month__r.Number_of_weeks__c;
            if (plan.Nets__c != null){
                salesPlanForUsers.put(plan.User__c, selectedPeriod.contains('a0G') != true ? plan.Nets__c / numberOfWeeks : plan.Nets__c);
            } else {
                salesPlanForUsers.put(plan.User__c, 0);
            }
        }

        List<UserWithPlanAndNets> finalList = new List<UserWithPlanAndNets>();

        for (Id id : this.salesTeamMap.keySet()) {
            Decimal fact = Math.round(userIdsWithFactStarts.get(id) == null ? 0 : userIdsWithFactStarts.get(id));
            Decimal plan = Math.round(salesPlanForUsers.get(id) == null ? 0 : salesPlanForUsers.get(id));
            Decimal percentage = plan == 0 ? 0 : Math.round(fact / plan * 100);
            finalList.add(new UserWithPlanAndNets(this.salesTeamMap.get(id), plan, fact, percentage));
        }

        this.finalValues = JSON.serialize(finalList);
    }

    /*******************************************************************************
    *  Name            : UserWithPlanAndNets()
    *  Type            : class
    *  Summary         : class to handle User, plan, fact and percentage data
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public class UserWithPlanAndNets {
        public User user { get; set; }
        public Decimal plan { get; set; }
        public Decimal fact { get; set; }
        public Decimal percentage { get; set; }

        public userWithPlanAndNets(User user, Decimal plan, Decimal fact, Decimal percentage) {
            this.user = user;
            this.plan = plan;
            this.fact = fact;
            this.percentage = percentage;
        }
    }

    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Type            : method
    *  Summary         : generating of the values of the selected period
    *  CreatedDate     : 30/05/2018
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
            this.selectedMonthId = currentMonth.Id;
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
                        SELECT Id, Name, Start_Date__c, End_Date__c
                        FROM Fleetcor_Calendar_Month__c
                        WHERE Id = :this.selectedPeriod
                        LIMIT 1
                ];

                //month
                this.startDateOfPeriod = currentMonth.Start_Date__c;
                this.endDateOfPeriod = currentMonth.End_Date__c;
                this.selectedMonthId = currentMonth.Id;
                startDateOfMonth = currentMonth.Start_Date__c;
                endDateOfMonth = currentMonth.End_Date__c;
            }
        }
        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + DashboardMethods.monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + DashboardMethods.monthsMap.get(endDateOfMonth.month());
    }

    /*******************************************************************************
    *  Name            : getRolesList()
    *  Type            : method
    *  Summary         : Display available roles in selectbox
    *  CreatedDate     : 30/05/2018
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
    *  Name            : getPeriodsList()
    *  Type            : method
    *  Summary         : generating FLT periods (months and weeks) list
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : SelectOption (FLT periods)
    ******************************************************************************/
    public List<SelectOption> getPeriodsList() {
        return DashboardMethods.getPeriodsList(this.selectedYear);
    }

    /*******************************************************************************
    *  Name            : getYearsList()
    *  Type            : method
    *  Summary         : Display years in selectbox
    *  CreatedDate     : 30/05/2018
    *  Parameters      :
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYearsList() {
        return DashboardMethods.getYearsList();
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

        init();
    }

    /*******************************************************************************
    *  Name            : changeRole()
    *  Type            : method
    *  Summary         : Setting UserRole depending on the selected UserRole
    *  CreatedDate     : 30/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeRole() {
        this.userRole = this.mapOfAvailableRoles.get(selectedRole);
        this.salesTeamMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE IsActive = true AND UserRoleId IN :DashboardMethods.userRoleTree.toUserRoleList(this.userRole)]);
        generateNetStartsReport();
    }
}