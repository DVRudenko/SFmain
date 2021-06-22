/**
 * Created by Nikita.Dayanov on 26.07.2018.
 */

public with sharing class DashboardPersonalIntensityOfWorkPPRCtrl {

    public String selectedPeriod { get; set; } //String for period display list
    public String selectedYear { get; set; } //String for year display list

    public String userId {public get; set;}
    public String userName { public get; set; }
    public Fleetcor_Calendar_Month__c currentMonth { public get; set; }
    public List<Decimal> intensities {public get; set;}
    public String weekNumbersLabels { public get; set; }
    public String numberOfTaskstoday {public get; set;}
    Integer numberOfWeeks {get; set;}
    private Fleetcor_Calendar_Week__c currentWeek {get; set;}

/********************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 27/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try{
            if(this.userId == null){
                this.userId = DashboardMethods.returnUserId();
            }
            if(this.userName == null){
                this.userName = DashboardMethods.getUser(this.userId).Name;
            }

            setupCurrentFleetcorMonth();
            setupCurrentFleetcorWeek();
            setupCurrentFleetcorYear();

            this.numberOfWeeks = this.currentMonth.Number_of_weeks__c.intValue();
            intensities = new List<Decimal>((Integer) this.currentMonth.Number_of_weeks__c);
            getNumberOfTasksForToday();
            generateWeekNumbers();
            calculatePersonalIntensityOfSalesWork();

        }
        catch (Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : calculatePersonalIntensityOfSalesWork()
    *  Type            : method
    *  Summary         : calculate intensities for each week in current month
    *  CreatedDate     : 27/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculatePersonalIntensityOfSalesWork() {

        // Get week sObjects for this month as a list
        List<Fleetcor_Calendar_Week__c> thisMonthWeeks = [
                SELECT Name, Start_Date__c, End_Date__c, Id, Fleetcor_Calendar_Month__r.Id
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Id = :this.currentMonth.Id
                ORDER BY Start_Date__c
        ];


        //Opportunities
        List<Opportunity> validOpptiesList = new List<Opportunity>([
                        SELECT Name, OwnerId, StageName, CreatedDate
                        FROM Opportunity
                        WHERE OwnerId =: userId
                        AND StageName NOT IN ('Moved to Start', 'Отказ', 'Потерян в конкуренции')
                        LIMIT 50000
        ]);


        List<Opportunity> opptiesWithTerminalStatusList = new List<Opportunity>([
                SELECT Name, OwnerId, StageName, CreatedDate, (
                    SELECT Field, CreatedDate, NewValue
                    FROM Histories
                    WHERE Field = 'StageName'
                    AND CreatedDate >=: this.currentMonth.Start_Date__c
                    AND CreatedDate <=: this.currentMonth.End_Date__c.addDays(1)
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                )
                FROM Opportunity
                WHERE OwnerId =: this.userId
                AND (StageName = 'Moved to Start' OR
                StageName = 'Отказ' OR
                StageName = 'Потерян в конкуренции')
                LIMIT 50000
        ]);

        List<Opportunity> validTerminalStatusOpportunities = new List<Opportunity>();
        for (Opportunity opp : opptiesWithTerminalStatusList) {
            if (!opp.Histories.isEmpty()) {
                validTerminalStatusOpportunities.add(opp);
            }
        }


        // Leads //
        List<Lead> validLeadsList = new List<Lead>([
                SELECT Name, OwnerId, Status, CreatedDate
                FROM Lead
                WHERE OwnerId =: userId
                AND IsConverted = FALSE
                AND Status NOT IN ('Disqualified', 'QUALIFIED - Convert to Opportunity')
                LIMIT 50000
        ]);


        List<Lead> leadsWithTerminalStatusList = new List<Lead>([
                SELECT Name, OwnerId, Status, CreatedDate, (
                        SELECT Field, CreatedDate, NewValue
                        FROM Histories
                        WHERE Field = 'Status'
                        AND CreatedDate >=: this.currentMonth.Start_Date__c
                        AND CreatedDate <=: this.currentMonth.End_Date__c.addDays(1)
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM Lead
                WHERE  Owner.Id =: this.userId
                AND IsConverted = FALSE
                AND Status IN ('Disqualified','QUALIFIED - Convert to Opportunity')
                LIMIT 50000
        ]);

        List<Lead> validTerminalStatusLeads = new List<Lead>();
        for (Lead ld : leadsWithTerminalStatusList) {
            if (!ld.Histories.isEmpty()) {
                validTerminalStatusLeads.add(ld);
            }
        }

        List<Task> validTasksList = [
                SELECT Id, OwnerId, Type, WhoId, Status, ActivityDate, isClosed, LastModifiedDate
                FROM Task
                WHERE IsClosed = TRUE
                AND LastModifiedDate >= :this.currentMonth.Start_Date__c
                AND LastModifiedDate <= :this.currentMonth.End_Date__c
                AND OwnerId =: userId
                LIMIT 50000
        ];

        Integer weekTasks = 0;
        Integer weekOpptys = 0;
        Integer weekLeads = 0;

        for(Fleetcor_Calendar_Week__c week : thisMonthWeeks){

            weekTasks = 0;
            weekOpptys = 0;
            weekLeads = 0;

            for(Task t : validTasksList){
                if(t.LastModifiedDate >= week.Start_Date__c & t.LastModifiedDate <= week.End_Date__c){
                    weekTasks++;
                }
            }

            for(Opportunity opp : validTerminalStatusOpportunities){
                for(OpportunityFieldHistory hist : opp.Histories){
                    if(hist.CreatedDate >= week.Start_Date__c && hist.CreatedDate <= week.End_Date__c &&
                            (hist.NewValue.equals('Отказ') |
                                    hist.NewValue.equals('Потерян в конкуренции'))) {
                        weekOpptys++;
                        break;
                    }
                }

            }

            for(Lead l : validTerminalStatusLeads){
                for(LeadHistory hist : l.Histories){
                    if(hist.CreatedDate >= week.Start_Date__c && hist.CreatedDate <= week.End_Date__c &&
                            (hist.NewValue.equals('Disqualified') |
                                    hist.NewValue.equals('QUALIFIED - Convert to Opportunity'))) {

                        weekLeads++;
                        break;
                    }
                }

            }

            if(validOpptiesList.size() + validLeadsList.size() != 0){
                this.intensities.add(Decimal.valueOf(weekTasks) /
                        (validOpptiesList.size() + weekOpptys + validLeadsList.size() + weekLeads));
            }
            else{
                this.intensities.add(0.0);
            }

        }

    }

    private void setupCurrentFleetcorMonth() {

        //To test particular month: uncomment and change TODAY to selectMonthDay in query below
        // Date selectMonthDay = Date.newInstance(2018, 4, 15); //2018-05-15; s
        List<Fleetcor_Calendar_Month__c> currentMonth = [
                SELECT Name, Start_Date__c, End_Date__c, Number_of_weeks__c, Fleetcor_Calendar_Year__r.Name, Id
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c <= TODAY  AND End_Date__c >= TODAY
        ];
        if (currentMonth.size() > 1) {
            throw new QueryException('Wrong query for current month');
        }

        this.currentMonth = currentMonth.get(0);

    }

    private void setupCurrentFleetcorWeek() {
//        Date selectMonthDay = Date.newInstance(2018, 4, 15);
        List<Fleetcor_Calendar_Week__c> currentWek = [
                SELECT Name, Id, Start_Date__c, End_Date__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY
        ];
        this.selectedPeriod = currentWek.get(0).Id;
        this.currentWeek = currentWek.get(0);
    }

    private void setupCurrentFleetcorYear() {
        this.selectedYear = this.currentMonth.Fleetcor_Calendar_Year__r.Name;
    }

    private void generateWeekNumbers() {
        List<Integer> labels = new List<Integer>(this.numberOfWeeks);
        for (Integer i = 0; i < labels.size(); i++) {
            labels[i] = i + 1;
        }
        this.weekNumbersLabels = JSON.serialize(labels);
    }

    private void getNumberOfTasksForToday() {
        List<Task> validTasksList = [
                SELECT Id
                FROM Task
                WHERE OwnerId =: this.userId
                AND Status = 'In Progress'
        ];
        this.numberOfTaskstoday = String.valueOf(validTasksList.size());
    }

}