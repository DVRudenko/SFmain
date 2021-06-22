/**
 * Created by Nikita.Mikhailov on 22.05.2018.
 */

public with sharing class DashboardIntensityOfSalesWorkPPRCtrl {
    public String selectedPeriod { get; set; } //String for period display list
    public String selectedYear { get; set; } //String for year display list
    public String startDateOfMonthString { get; set; }
    public String endDateOfMonthString { get; set; }
    public UserRole currentRole { get; set; } //role of connected user
    public UserRole userRole { get; set; } //role by which gathering data
    public String selectedRole { get; set; } //String role for role display list
    public Map<Id, User> salesTeamMap { get; set; } //map of user to show on report
    public List<FinalList> finalList { get; set; } //list of FinalList class - id of user -> intensity
    public Map<String, Integer> finalOpportunitiesOfUserMap { get; set; }
    public Map<String, Integer> finalLeadsOfUserMap { get; set; }
    public Map<String, Integer> finalTasksOfUserMap { get; set; }
    public Map<Id, UserRole> mapOfAvailableRoles { get; set; } //Map with UserRoleId and UserRole sObject which is available for current user
    private String userId; //connected user id
    public Date startDateOfPeriod; //selected period start date
    public Date endDateOfPeriod; //selected period end date


    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {

            if (this.selectedYear == null) {
                this.selectedYear = DashboardMethods.returnCurrentYear();
            }

            if (this.userId == null) {
                this.userId = DashboardMethods.returnUserId();
            }

            if (this.currentRole == null) {
                User currentUser = [
                        SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
                        FROM User
                        WHERE Id = :this.userId
                ];
                this.currentRole = currentUser.UserRole;
            }

            if (this.userRole == null) {
                this.userRole = DashboardMethods.getUserRole(DashboardMethods.returnUserRoleId());
            }

            if (this.selectedRole == null) {
                this.selectedRole = this.userRole.Id;
            }

            if (this.mapOfAvailableRoles == null) {
                this.mapOfAvailableRoles = new Map<Id, UserRole>();
                for (UserRole userRole : DashboardMethods.userRoleTree.toUserRoleList(this.currentRole)) {
                    this.mapOfAvailableRoles.put(userRole.Id, userRole);
                }
            }

            this.finalList = new List<FinalList>();
            this.finalOpportunitiesOfUserMap = new Map<String, Integer>();
            this.finalLeadsOfUserMap = new Map<String, Integer>();
            this.finalTasksOfUserMap = new Map<String, Integer>();

            generateDataForCharts();
            calculatingIntensityOfSalesWork();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : getRolesList()
    *  Type            : method
    *  Summary         : Display available roles in selectbox
    *  CreatedDate     : 22/05/2018
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
    *  Name            : changeRole()
    *  Type            : method
    *  Summary         : Setting UserRole depending on the selected UserRole
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeRole() {
        this.userRole = this.mapOfAvailableRoles.get(selectedRole);
        init();
    }

    /*******************************************************************************
    *  Name            : calculatingIntensityOfSalesWork()
    *  Type            : method
    *  Summary         : calculating the intensity of sales for the selected period
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculatingIntensityOfSalesWork() {

        List<Id> userIds = DashboardMethods.userRoleTree.toIdList(this.userRole);

        for (Id id : userIds) {
            System.debug(id);
        }

        this.salesTeamMap = new Map<Id, User>(
        [
                SELECT Id, Name
                FROM User
                WHERE UserRoleId IN :userIds
                AND isActive = TRUE
                LIMIT 10000
        ]
        );

        List<Opportunity> validOpptiesList = new List<Opportunity>([
                SELECT Name, OwnerId, StageName, CreatedDate
                FROM Opportunity
                WHERE Owner.UserRoleId IN :userIds
                AND StageName NOT IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                LIMIT 50000
        ]);

        List<Opportunity> opptiesWithTerminalStatusList = new List<Opportunity>([
                SELECT Name, OwnerId, StageName, CreatedDate, (
                        SELECT Field, CreatedDate, NewValue
                        FROM Histories
                        WHERE Field = 'StageName'
                        AND CreatedDate >= :this.startDateOfPeriod
                        AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM Opportunity
                WHERE Owner.UserRoleId IN :userIds
                AND (StageName = 'Moved to Start' OR
                StageName = 'Отказ' OR
                StageName = 'Потерян в конкуренции')
                LIMIT 50000
        ]);

        for (Opportunity opp : opptiesWithTerminalStatusList) {
            if (!opp.Histories.isEmpty()) {
                validOpptiesList.add(opp);
            }
        }

        Map<String, List<Opportunity>> allOpportunitiesOfUserMap = new Map<String, List<Opportunity>>();
        for (Opportunity opp : validOpptiesList) {
            if (!allOpportunitiesOfUserMap.containsKey(opp.OwnerId)) {
                allOpportunitiesOfUserMap.put(opp.OwnerId, new List<Opportunity>());
            }
            allOpportunitiesOfUserMap.get(opp.OwnerId).add(opp);
        }

        List<Lead> validLeadsList = new List<Lead>([
                SELECT Name, OwnerId, Status, CreatedDate
                FROM Lead
                WHERE Owner.UserRoleId IN :userIds
                AND IsConverted = false
                AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                LIMIT 50000
        ]);

        List<Lead> leadsWithTerminalStatusList = new List<Lead>([
                SELECT Name, OwnerId, Status, CreatedDate, (
                        SELECT Field, CreatedDate, NewValue
                        FROM Histories
                        WHERE Field = 'Status'
                        AND CreatedDate >= :this.startDateOfPeriod
                        AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM Lead
                WHERE Owner.UserRoleId IN :userIds
                AND IsConverted = false
                AND Status IN ('Disqualified','QUALIFIED - Convert to Opportunity')
                LIMIT 50000
        ]);

        for (Lead ld : leadsWithTerminalStatusList) {
            if (!ld.Histories.isEmpty()) {
                validLeadsList.add(ld);
            }
        }

        Map<String, List<Lead>> allLeadsOfUserMap = new Map<String, List<Lead>>();
        for (Lead lead : validLeadsList) {
            if (!allLeadsOfUserMap.containsKey(lead.OwnerId)) {
                allLeadsOfUserMap.put(lead.OwnerId, new List<Lead>());
            }
            allLeadsOfUserMap.get(lead.OwnerId).add(lead);
        }

        List<Task> validTasksList = [
                SELECT Id, OwnerId, Type, WhoId, Status, ActivityDate, isClosed
                FROM Task
                WHERE IsClosed = TRUE
                AND LastModifiedDate >= :this.startDateOfPeriod
                AND LastModifiedDate <= :this.endDateOfPeriod
                AND Owner.UserRoleId IN :userIds
                LIMIT 50000
        ];

        Map<String, List<Task>> allTasksOfUserMap = new Map<String, List<Task>>();
        for (Task t : validTasksList) {
            if (!allTasksOfUserMap.containsKey(t.OwnerId)) {
                allTasksOfUserMap.put(t.OwnerId, new List<Task>());
            }
            allTasksOfUserMap.get(t.OwnerId).add(t);
        }

        ///FINAL
        for (String userId : this.salesTeamMap.keySet()) {
            if (!allOpportunitiesOfUserMap.containsKey(userId)) {
                allOpportunitiesOfUserMap.put(userId, new List<Opportunity>());
            }

            if (!allLeadsOfUserMap.containsKey(userId)) {
                allLeadsOfUserMap.put(userId, new List<Lead>());
            }

            if (!allTasksOfUserMap.containsKey(userId)) {
                allTasksOfUserMap.put(userId, new List<Task>());
            }

            this.finalOpportunitiesOfUserMap.put(userId, allOpportunitiesOfUserMap.get(userId).size());
            this.finalLeadsOfUserMap.put(userId, allLeadsOfUserMap.get(userId).size());
            this.finalTasksOfUserMap.put(userId, allTasksOfUserMap.get(userId).size());

            if (allOpportunitiesOfUserMap.get(userId).size() + allLeadsOfUserMap.get(userId).size() != 0) {
                finalList.add(new FinalList(
                        userId,
                        Decimal.valueOf(allTasksOfUserMap.get(userId).size()) / (allOpportunitiesOfUserMap.get(userId).size() + allLeadsOfUserMap.get(userId).size())));
            } else {
                finalList.add(new FinalList(
                        userId,
                        0));
            }
        }

        finalList.sort();
    }

    public class FinalList implements Comparable {
        public String id { get; set; }
        public Decimal compareValue { get; set; }

        public finalList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            FinalList compareToU = (FinalList) compareTo;
            if (compareValue == compareToU.compareValue) return 0;
            if (compareValue < compareToU.compareValue) return -1;
            return 1;
        }
    }


    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Type            : method
    *  Summary         : generating of the values of the selected period
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCharts() {
        Date startDateOfMonth;
        Date endDateOfMonth;
        List<Fleetcor_Calendar_Week__c> currentWeek = [
                SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                        Start_Date__c, End_Date__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND
                Start_Date__c <= TODAY AND End_Date__c >= TODAY
                LIMIT 1
        ];

        Fleetcor_Calendar_Month__c currentMonth = new Fleetcor_Calendar_Month__c();
        if (this.selectedPeriod == null) {
            if (currentWeek.isEmpty()) {
                currentWeek = [
                        SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                                Start_Date__c, End_Date__c
                        FROM Fleetcor_Calendar_Week__c
                        WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                        ORDER BY Start_Date__c DESC
                        LIMIT 1
                ];
            }
            //week
            this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
            endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;
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
        this.startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + DashboardMethods.monthsMap.get(startDateOfMonth.month());
        this.endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + DashboardMethods.monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Type            : method
    *  Summary         : generating FLT periods (months and weeks) list
    *  CreatedDate     : 22/05/2018
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
    *  CreatedDate     : 22/05/2018
    *  Parameters      :
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYearsList() {
        return DashboardMethods.getYearsList();
    }

    /*******************************************************************************
    *  Name            : changeYear()
    *  Summary         : Setting the period depending on the selected year
    *  CreatedDate     : 22/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeYear() {
        List<Fleetcor_Calendar_Week__c> currentFLTweek = [
                SELECT Id, Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name
                FROM Fleetcor_Calendar_Week__c
                WHERE Start_Date__c <= TODAY
                AND End_Date__c >= TODAY
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
                    WHERE Name = :DashboardMethods.monthsMap.get(1)
                    AND Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                    LIMIT 1
            ].Id;
            this.selectedPeriod = firstMonthId;
        } else {
            this.selectedPeriod = currentWeekId;
        }
        init();
    }
}