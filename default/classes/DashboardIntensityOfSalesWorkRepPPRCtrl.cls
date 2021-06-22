/**
 * Created by Nikita.Mikhailov on 23.05.2018.
 */

public with sharing class DashboardIntensityOfSalesWorkRepPPRCtrl {
    public User currentUser { get; set; } //report for this user
    public String selectedPeriod { get; set; } //String for period display list
    public String selectedYear { get; set; } //String for year display list
    public String radioValue { get; set; } //String for radio buttons
    public String startDateOfMonthString { get; set; }
    public String endDateOfMonthString { get; set; }
    public Integer numberTasks { get; set; } //number of closed tasks in selected period
    public Integer numberOppties { get; set; } //number of valid opptys
    public Integer numberLeads { get; set; } //number of valid leads
    public Integer numberOpenOpptys { get; set; } //number of open opptys
    public Integer numberClosedOpptys { get; set; } //number of closed opptys
    public Integer numberOpenLeads { get; set; } //number of open leads
    public Integer numberClosedLeads { get; set; } //number of closed leads
    public ApexPages.StandardSetController opptySsc { get; set; } //valid opptys and pagination
    public ApexPages.StandardSetController leadSsc { get; set; } //valid leads and pagination
    public Map<String, String> mapOfIdsAndDaysCreation { get; set; } //map of Id's and number's of days since creation
    public Map<String, String> mapOfIdsAndDaysActivity { get; set; } //map of id's and number's of days since last activity
    public Map<String, String> mapOfIdsAndDaysTransfer { get; set; } // map of id's and number's of days since last transfer
    public Date startDateOfPeriod; //selected period start date
    public Date endDateOfPeriod; //selected period end date

    public List<Opportunity> opportunities { //page of valid opptys
        get {
            return (List<Opportunity>) this.opptySsc.getRecords();
        }
        private set;
    }

    public List<Lead> leads { //page of valid leads
        get {
            return (List<Lead>) this.leadSsc.getRecords();
        }
        private set;
    }

    public Boolean disabledPrevious {
        get {
            if (this.radioValue == 'Opportunity') {
                return !this.opptySsc.getHasPrevious();
            } else {
                return !this.leadSsc.getHasPrevious();
            }
        }
        private set;
    }

    public Boolean disabledNext {
        get {
            if (this.radioValue == 'Opportunity') {
                return !this.opptySsc.getHasNext();
            } else {
                return !this.leadSsc.getHasNext();
            }
        }
        private set;
    }

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
            if (radioValue == null) {
                radioValue = 'Opportunity';
            }

            String periodId = Apexpages.currentPage().getParameters().get('period');
            String year = ApexPages.currentPage().getParameters().get('year');
            if (this.selectedPeriod == null) {
                this.selectedPeriod = periodId;
            }
            if (this.selectedYear == null) {
                this.selectedYear = year;
            }

            generateDataForCharts();
            calculatingIntensityOfSalesWorkReport();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : calculatingIntensityOfSalesWorkReport()
    *  Type            : method
    *  Summary         : downloading a detailed sales intensity report for the user for the selected period
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculatingIntensityOfSalesWorkReport() {
        String userId = Apexpages.currentPage().getParameters().get('userid');
        this.currentUser = [
                SELECT Name, Profile.Name, LocaleSidKey, UserRole.Name
                FROM User
                WHERE Id = :userId
                LIMIT 1
        ];

        List <Opportunity> validOpptiesMap = new List<Opportunity>([
                SELECT Name,
                        OwnerId,
                        StageName,
                        CreatedDate,
                        CloseDate,
                        Last_Owner_Change_Date_RUS__c, (SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false ORDER BY ActivityDate DESC LIMIT 1)
                FROM Opportunity
                WHERE OwnerId = :this.currentUser.Id
                AND StageName NOT IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                LIMIT 50000
        ]);

        this.numberOpenOpptys = validOpptiesMap.size();

        List<Opportunity> opptiesWithTerminalStatusMap = new List<Opportunity>([
                SELECT Name, OwnerId, StageName, CreatedDate, CloseDate, Last_Owner_Change_Date_RUS__c, (
                        SELECT Field, CreatedDate, NewValue
                        FROM Histories
                        WHERE Field = 'StageName' AND
                        CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                ), (SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false ORDER BY ActivityDate DESC LIMIT 1)
                FROM Opportunity
                WHERE OwnerId = :this.currentUser.Id
                AND StageName IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                LIMIT 50000
        ]);

        Integer count = 0;

        for (Opportunity opp : opptiesWithTerminalStatusMap) {
            if (!opp.Histories.isEmpty()) {
                validOpptiesMap.add(opp);
                count++;
            }
        }

        this.numberClosedOpptys = count;
        this.numberOppties = validOpptiesMap.size();

        List<Lead> validLeadsMap = new List<Lead>([
                SELECT Name,
                        OwnerId,
                        Status,
                        CreatedDate,
                        LastTransferDate, (SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false ORDER BY ActivityDate DESC LIMIT 1)
                FROM Lead
                WHERE OwnerId = :this.currentUser.Id
                AND IsConverted = false
                AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                LIMIT 50000
        ]);

        this.numberOpenLeads = validLeadsMap.size();

        List<Lead> leadsWithTerminalStatusMap = new List<Lead>([
                SELECT Name, OwnerId, Status, CreatedDate, LastTransferDate, (
                        SELECT Field, CreatedDate, NewValue
                        FROM Histories
                        WHERE Field = 'Status' AND
                        CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                ), (SELECT Id, ActivityDate FROM Tasks WHERE IsClosed = false ORDER BY ActivityDate DESC LIMIT 1)
                FROM Lead
                WHERE OwnerId = :this.currentUser.Id AND
                IsConverted = false
                AND Status IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                LIMIT 50000
        ]);

        count = 0;

        for (Lead ld : leadsWithTerminalStatusMap) {
            if (!ld.Histories.isEmpty()) {
                validLeadsMap.add(ld);
                count++;
            }
        }

        this.numberClosedLeads = count;
        this.numberLeads = validLeadsMap.size();

        Map<Id, Task> validTasksMap = new Map<Id, Task>([
                SELECT Id, LastModifiedDate, WhatId, WhoId
                FROM Task
                WHERE OwnerId = :this.currentUser.Id
                AND IsClosed = TRUE
                AND LastModifiedDate >= :this.startDateOfPeriod
                AND LastModifiedDate <= :this.endDateOfPeriod
                LIMIT 50000
        ]);
        this.numberTasks = validTasksMap.size();

        Map<String, Task> lastActiveTaskMap = new Map<String, Task>();
        for (Task t : validTasksMap.values()) {
            if (t.WhatId != null) {
                if (!lastActiveTaskMap.containsKey(t.WhatId)) {
                    lastActiveTaskMap.put(t.WhatId, t);
                } else if (t.LastModifiedDate > lastActiveTaskMap.get(t.WhatId).LastModifiedDate) {
                    lastActiveTaskMap.put(t.WhatId, t);
                }
            }
            if (t.WhoId != null) {
                if (!lastActiveTaskMap.containsKey(t.WhoId)) {
                    lastActiveTaskMap.put(t.WhoId, t);
                } else if (t.LastModifiedDate > lastActiveTaskMap.get(t.WhoId).LastModifiedDate) {
                    lastActiveTaskMap.put(t.WhoId, t);
                }
            }
        }

        this.mapOfIdsAndDaysCreation = new Map<String, String>();
        this.mapOfIdsAndDaysActivity = new Map<String, String>();
        this.mapOfIdsAndDaysTransfer = new Map<String, String>();

        for (Opportunity opp : validOpptiesMap) {
            if (lastActiveTaskMap.containsKey(opp.Id)) {
                if (opp.StageName != 'Moved to Start' && opp.StageName != 'Отказ' && opp.StageName != 'Потерян в конкуренции') {
                    this.mapOfIdsAndDaysCreation.put(opp.Id, String.valueOf(opp.CreatedDate.Date().daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysTransfer.put(opp.Id, String.valueOf(opp.Last_Owner_Change_Date_RUS__c.Date().daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysActivity.put(opp.Id, String.valueOf(lastActiveTaskMap.get(opp.Id).LastModifiedDate.Date().daysBetween(Datetime.now().Date())));
                } else {
                    this.mapOfIdsAndDaysCreation.put(opp.Id, String.valueOf(opp.CreatedDate.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysTransfer.put(opp.Id, String.valueOf(opp.Last_Owner_Change_Date_RUS__c.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysActivity.put(opp.Id, String.valueOf(lastActiveTaskMap.get(opp.Id).LastModifiedDate.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date())));
                }
            } else {
                if (opp.StageName != 'Moved to Start' && opp.StageName != 'Отказ' && opp.StageName != 'Потерян в конкуренции') {
                    this.mapOfIdsAndDaysCreation.put(opp.Id, String.valueOf(opp.CreatedDate.Date().daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysTransfer.put(opp.Id, String.valueOf(opp.Last_Owner_Change_Date_RUS__c.Date().daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysActivity.put(opp.Id, 'Нет задач');
                } else {
                    this.mapOfIdsAndDaysCreation.put(opp.Id, String.valueOf(opp.CreatedDate.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysTransfer.put(opp.Id, String.valueOf(opp.Last_Owner_Change_Date_RUS__c.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysActivity.put(opp.Id, 'Нет задач');
                }
            }
        }

        this.opptySsc = new ApexPages.StandardSetController(validOpptiesMap);
        this.opptySsc.setPageSize(100);

        List<Lead> finalObjectStatisticListLead = new List<Lead>();

        for (Lead lead : validLeadsMap) {
            if (lastActiveTaskMap.containsKey(lead.Id)) {
                if (lead.Status != 'Disqualified' && lead.Status != 'QUALIFIED - Convert to Opportunity') {
                    this.mapOfIdsAndDaysCreation.put(lead.Id, String.valueOf(lead.CreatedDate.Date().daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysTransfer.put(lead.Id, String.valueOf(lead.LastTransferDate.daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysActivity.put(lead.Id, String.valueOf(lastActiveTaskMap.get(lead.Id).LastModifiedDate.Date().daysBetween(Datetime.now().Date())));
                } else {
                    this.mapOfIdsAndDaysCreation.put(lead.Id, String.valueOf(lead.CreatedDate.Date().daysBetween(lead.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysTransfer.put(lead.Id, String.valueOf(lead.LastTransferDate.daysBetween(lead.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysActivity.put(lead.Id, String.valueOf(lastActiveTaskMap.get(lead.Id).LastModifiedDate.Date().daysBetween(lead.Histories.get(0).CreatedDate.Date())));
                }
            } else {
                if (lead.Status != 'Disqualified' && lead.Status != 'QUALIFIED - Convert to Opportunity') {
                    this.mapOfIdsAndDaysCreation.put(lead.Id, String.valueOf(lead.CreatedDate.Date().daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysTransfer.put(lead.Id, String.valueOf(lead.LastTransferDate.daysBetween(Datetime.now().Date())));
                    this.mapOfIdsAndDaysActivity.put(lead.Id, 'Нет задач');
                } else {
                    this.mapOfIdsAndDaysCreation.put(lead.Id, String.valueOf(lead.CreatedDate.Date().daysBetween(lead.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysTransfer.put(lead.Id, String.valueOf(lead.LastTransferDate.daysBetween(lead.Histories.get(0).CreatedDate.Date())));
                    this.mapOfIdsAndDaysActivity.put(lead.Id, 'Нет задач');
                }
            }
        }
        this.leadSsc = new ApexPages.StandardSetController(validLeadsMap);
        this.leadSsc.setPageSize(100);
    }

    /*******************************************************************************
    *  Name            : beginningPage()
    *  Type            : method
    *  Summary         : move to the first page
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void beginningPage() {
        if (this.radioValue == 'Opportunity') {
            this.opptySsc.first();
        } else {
            this.leadSsc.first();
        }
    }

    /*******************************************************************************
    *  Name            : previousPage()
    *  Type            : method
    *  Summary         : move to the previous page
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void previousPage() {
        if (this.radioValue == 'Opportunity') {
            this.opptySsc.previous();
        } else {
            this.leadSsc.previous();
        }
    }

    /*******************************************************************************
    *  Name            : nextPage()
    *  Type            : method
    *  Summary         : move to the next page
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void nextPage() {
        if (this.radioValue == 'Opportunity') {
            this.opptySsc.next();
        } else {
            this.leadSsc.next();
        }
    }

    /*******************************************************************************
    *  Name            : endPage()
    *  Type            : method
    *  Summary         : move to the end page
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void endPage() {
        if (this.radioValue == 'Opportunity') {
            this.opptySsc.last();
        } else {
            this.leadSsc.last();
        }
    }

    /*******************************************************************************
    *  Name            : getRadioValues()
    *  Type            : method
    *  Summary         : get values for Opportunity/Lead radio buttons
    *  CreatedDate     : 22/05/2018
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getRadioValues() {
        String opptyLabel = Opportunity.SObjectType.getDescribe().getLabelPlural();
        String leadLabel = Lead.SObjectType.getDescribe().getLabelPlural();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Opportunity', opptyLabel));
        options.add(new SelectOption('Lead', leadLabel));

        return options;
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
            Id selectedId = this.selectedPeriod;
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
                Fleetcor_Calendar_Month__c currentMonth = [
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
    *  Type            : method
    *  Summary         : Setting the period depending on the selected year
    *  CreatedDate     : 22/05/2018
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
}