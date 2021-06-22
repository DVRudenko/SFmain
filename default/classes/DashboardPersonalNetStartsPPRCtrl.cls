/**
 * Created by Nikita.Dayanov on 02.07.2018.
 */

public with sharing class DashboardPersonalNetStartsPPRCtrl {

    private String userId;
    public String userName { public get; set; }
    public Date startOfMonthDate { get; set; }
    public Date endOfMonthDate { get; set; }
    private Fleetcor_Calendar_Month__c currentMonth { get; set; }
    public Integer numberOfWeeks { get; set; }
    public String monthPlanData { get; set; }
    public String monthNetStartsData { get; set; }
    public String weekNumbersLabels { get; set; }
    public String errorMesg { public get; set; }

    /*******************************************************************************
    *  Name            : init()
    *  Type            : method
    *  Summary         : init report
    *  CreatedDate     : 02/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            if (this.userId == null) {
                this.userId = DashboardMethods.returnUserId();
            }

            if (this.userName == null) {
                this.userName = DashboardMethods.getUser(this.userId).Name;
            }

            getCurrentFleetcorMonth();
            getNumberOfWeeks();
            generateWeekNumbers();
            getPlanDataThisMonth();
            getNetStartsDataThisMonth();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString() + ' line: ' + e.getLineNumber()));
        }
    }

    /*******************************************************************************
    *  Name            : getNetStartsDataThisMonth()
    *  Type            : method
    *  Summary         : Get NetStarts data for each week of current month
    *  CreatedDate     : 03/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void getNetStartsDataThisMonth() {

        // I need pump_date + 16 weeks
        // Date startTimeBorder = this.startOfMonthDate.addDays(-16 * 7);


        //Get all starts that are are still actual for current month
        List<Starts__c> starts = [
                SELECT Id, Opportunity__r.OwnerId, starts__c, Pump_date_oppty__c, client_week_number__c
                FROM Starts__c
                WHERE Pump_date_oppty__c >= :this.startOfMonthDate AND Pump_date_oppty__c <=: this.endOfMonthDate
                AND Opportunity__r.OwnerId = :this.userId
                AND Transit_ID__c != null
                ORDER BY client_week_number__c
                LIMIT 50000
        ];
        // If there are too many starts found, set up error message
        if (starts.size() == 50000) {
            this.errorMesg = 'Слишком много NetStarts! Свяжитесь с командой разработчиков';
        } else {
            this.errorMesg = '1';
        }

        // Get week sObjects for this month as a list
        List<Fleetcor_Calendar_Week__c> thisMonthWeeks = [
                SELECT Name, Start_Date__c, End_Date__c, Id, Fleetcor_Calendar_Month__r.Id
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Id = :this.currentMonth.Id
                ORDER BY Start_Date__c
        ];

        // Create list for summed starts. Logic: index maps the fleetcor_week to sum_of_starts value
        List<Decimal> summedStarts = new List<Decimal>(this.numberOfWeeks);
        for (Integer i = 0; i < summedStarts.size(); i++) {
            summedStarts[i] = 0.0;
        }

        // Iterate over Starts__c
        for (Starts__c start : starts) {
            // For Start: look which week does it belong to
            for (Integer i = 0; i < thisMonthWeeks.size(); i++) {
                // Add Net to week according to pump date borders

                if (start.Pump_date_oppty__c >= thisMonthWeeks[i].Start_Date__c &&
                        start.Pump_date_oppty__c <= thisMonthWeeks[i].End_Date__c) {
                    summedStarts[i] += start.starts__c;
                }
            }
        }
        // Make cumulative: each week is a sum of previous weeks + this week's starts
        // NOTE: Summation starts with index of 1
        for (Integer i = 1; i < thisMonthWeeks.size(); i++) {
            summedStarts[i] += summedStarts[i - 1];
        }

        this.monthNetStartsData = JSON.serialize(summedStarts);
    }

    /*******************************************************************************
    *  Name            : getPlanDataThisMonth()
    *  Type            : method
    *  Summary         : Get plan data for each week of current month
    *  CreatedDate     : 03/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void getPlanDataThisMonth() {

        List<Sales_Plan__c> salesPlanList = new List<Sales_Plan__c>([
                SELECT Id, Nets__c, User__c, Fleetcor_Calendar_Month__c, Fleetcor_Calendar_Month__r.Number_of_weeks__c
                FROM Sales_Plan__c
                WHERE User__r.Id = :this.userId
                AND Fleetcor_Calendar_Month__r.Id = :this.currentMonth.Id
        ]);
        List<Decimal> planPoints = new List<Decimal>(this.numberOfWeeks);
        Decimal plan;
        try {
            plan = salesPlanList.get(0).Nets__c;
        } catch (Exception e) {

        }

        for (Integer i = 0; i < planPoints.size(); i++) {
            if (plan != null) {
                planPoints[i] = plan * (i + 1) / this.numberOfWeeks;
            } else {
                planPoints[i] = 0.0;
            }

        }
        this.monthPlanData = JSON.serialize(planPoints);
    }

    /*******************************************************************************
    *  Name            : getCurrentFleetcorMonth()
    *  Type            : method
    *  Summary         : get Fleetcor_Calendar_Month__c sObject for current month
    *  CreatedDate     : 03/07/2018
    *  Parameters      : -
    *  Returns         : Fleetcor_Calendar_Month__c
    ******************************************************************************/
    // TODO: When method tested, change List<Fl..._Month__c> to Fleetcor_Calendar_Month__c
    // And remove Exception throw
    public void getCurrentFleetcorMonth() {


        // BACKDOOR
        //Yoy can choose any month:
//        Date selectMonthDay = Date.newInstance(2018,04,15);
        Date selectMonthDay = Date.today();
        List<Fleetcor_Calendar_Month__c> currentMonth = [
                SELECT Name, Start_Date__c, End_Date__c, Number_of_weeks__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c <=: selectMonthDay AND End_Date__c >=: selectMonthDay
        ];


//        List<Fleetcor_Calendar_Month__c> currentMonth = [
//                SELECT Name, Start_Date__c, End_Date__c, Number_of_weeks__c
//                FROM Fleetcor_Calendar_Month__c
//                WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY
//        ];
        if (currentMonth.size() > 1) {
            throw new QueryException('Wrong query for current month');
        }

        this.currentMonth = currentMonth.get(0);
        this.startOfMonthDate = currentMonth.get(0).Start_Date__c;
        this.endOfMonthDate = currentMonth.get(0).End_Date__c;
    }

    /*******************************************************************************
    *  Name            : getCurrentFleetcorWeek()
    *  Type            : method
    *  Summary         : get Fleetcor_Calendar_Week__c sObject for current week
    *  CreatedDate     : 03/07/2018
    *  Parameters      : -
    *  Returns         : Fleetcor_Calendar_Week__c
    ******************************************************************************/
    // TODO: When method tested, change List<Fl..._Week__c> to Fleetcor_Calendar_Week__c
    // And remove Exception throw
    public Fleetcor_Calendar_Week__c getCurrentFleetcorWeek() {

        List<Fleetcor_Calendar_Week__c> currentWeek = [
                SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY
        ];
        if (currentWeek.size() > 1) {
            throw new QueryException('Wrong query for current week');
        }

        return currentWeek.get(0);
    }

    /*******************************************************************************
    *  Name            : getNumberOfWeeks()
    *  Type            : method
    *  Summary         : get number of weeks in current Fleetcor month
    *  CreatedDate     : 02/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getNumberOfWeeks() {
        List<Fleetcor_Calendar_Month__c> currentMonth = [
                SELECT Name, Start_Date__c, End_Date__c, Number_of_weeks__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY
        ];
        if (currentMonth.size() > 1) {
            throw new QueryException('Wrong query for current week');
        }

        this.numberOfWeeks = currentMonth.get(0).Number_of_weeks__c.intValue();
        this.numberOfWeeks = this.currentMonth.Number_of_weeks__c.intValue();
    }

    /*******************************************************************************
    *  Name            : generateWeekNumbers()
    *  Type            : method
    *  Summary         : generate week numbers for x-axis labels
    *  CreatedDate     : 04/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateWeekNumbers() {
        List<Integer> labels = new List<Integer>(this.numberOfWeeks);
        for (Integer i = 0; i < labels.size(); i++) {
            labels[i] = i + 1;
        }
        this.weekNumbersLabels = JSON.serialize(labels);
    }





    // TODO: Remove only after verification that this calculation is not correct
    /*******************************************************************************
    *  Name            : getNetStartsDataThisMonth()
    *  Type            : method
    *  Summary         : Method with alternative NetStarts calculation
    *  CreatedDate     : 03/07/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    /*
    private void OLDgetNetStartsDataThisMonth() {

        // I need pump_date + 16 weeks
        Date startTimeBorder = this.startOfMonthDate.addDays(-16 * 7);

        //Get all starts that are are still actual for current month
        List<Starts__c> starts = [
                SELECT Id, Opportunity__r.OwnerId, starts__c, Pump_date_oppty__c, client_week_number__c
                FROM Starts__c
                WHERE Pump_date_oppty__c >= :startTimeBorder
                AND Opportunity__r.OwnerId = :this.userId
                AND Transit_ID__c != null
                ORDER BY client_week_number__c
                LIMIT 50000
        ];
        // If there are too many starts found, set up error message
        if (starts.size() == 50000) {
            this.errorMesg = 'Слишком много NetStarts! Свяжитесь с командой разработчиков';
        } else {
            this.errorMesg = '1';
        }

        // Get week sObjects for this month as a list
        List<Fleetcor_Calendar_Week__c> thisMonthWeeks = [
                SELECT Name, Start_Date__c, End_Date__c, Id, Fleetcor_Calendar_Month__r.Id
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Id = :this.currentMonth.Id
                ORDER BY Start_Date__c
        ];

        // Create list for summed starts. Logic: index maps the fleetcor_week to sum_of_starts value
        List<Decimal> summedStarts = new List<Decimal>(this.numberOfWeeks);
        for (Integer i = 0; i < summedStarts.size(); i++) {
            summedStarts[i] = 0.0;
        }

        // Iterate over Starts__c
        for (Starts__c start : starts) {
            // For Start: look which week does it belong to
            for (Integer i = 0; i < thisMonthWeeks.size(); i++) {
                // Add Net to week according to pump date borders

                if (start.Pump_date_oppty__c >= thisMonthWeeks[i].Start_Date__c.addDays(-start.client_week_number__c.intValue() * 7) &&
                        start.Pump_date_oppty__c <= thisMonthWeeks[i].End_Date__c.addDays(-start.client_week_number__c.intValue() * 7)) {
                    summedStarts[i] += start.starts__c;
                }
            }
        }
        // Make cumulative: each week is a sum of previous weeks + this week's starts
        // NOTE: Summation starts with index of 1
        for (Integer i = 1; i < thisMonthWeeks.size(); i++) {
            summedStarts[i] += summedStarts[i - 1];
        }

        this.monthNetStartsData = JSON.serialize(summedStarts);
    }
    */

}