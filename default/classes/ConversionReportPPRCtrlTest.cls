@IsTest
public class ConversionReportPPRCtrlTest {
    @testSetup
    static void createCalendar() {
        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
        insert year;

        List<Fleetcor_Calendar_Month__c> fleetcorCalendarMonthList = new List<Fleetcor_Calendar_Month__c>();

        Fleetcor_Calendar_Month__c augustMonth = new Fleetcor_Calendar_Month__c();
        augustMonth.Name = 'August';
        augustMonth.Start_Date__c = Date.newinstance(2017, 8, 28);
        augustMonth.End_Date__c = Date.newinstance(2017, 9, 24);
        augustMonth.Fleetcor_Calendar_Year__c = year.Id;
        fleetcorCalendarMonthList.add(augustMonth);

        Fleetcor_Calendar_Month__c septemberMonth = new Fleetcor_Calendar_Month__c();
        septemberMonth.Name = 'September';
        septemberMonth.Start_Date__c = Date.newinstance(2017, 9, 25);
        septemberMonth.End_Date__c = Date.newinstance(2017, 10, 29);
        septemberMonth.Fleetcor_Calendar_Year__c = year.Id;
        fleetcorCalendarMonthList.add(septemberMonth);

        insert fleetcorCalendarMonthList;

        List<Fleetcor_Calendar_Week__c> fleetcorCalendarWeekList = new List<Fleetcor_Calendar_Week__c>();

        Fleetcor_Calendar_Week__c augustWeek = new Fleetcor_Calendar_Week__c( 
            Start_Date__c = Date.today().addDays(-3), 
            End_Date__c = Date.today().addDays(4),
            Fleetcor_Calendar_Month__c = augustMonth.Id);
        fleetcorCalendarWeekList.add(augustWeek);

        Fleetcor_Calendar_Week__c septemberWeek = new Fleetcor_Calendar_Week__c( 
            Start_Date__c = Date.today().addDays(-3), 
            End_Date__c = Date.today().addDays(4),
            Fleetcor_Calendar_Month__c = septemberMonth.Id);
        fleetcorCalendarWeekList.add(septemberWeek);

        insert fleetcorCalendarWeekList;
    }

    private static void initUserForReportSend() {
        RU_Conversion_Report_Email_For_Source__c email = new RU_Conversion_Report_Email_For_Source__c(Name = 'test.test@example.com');
        insert email;
    }

    @isTest 
    static void createLeadPartners() {

        Id testSalesGroup = null;
        testSalesGroup = [SELECT Id FROM UserRole WHERE Name LIKE '%PPR Bryansk Partner Sales (1)%' LIMIT 1].get(0).Id;

        ConversionReportPPRCtrl controller = new ConversionReportPPRCtrl();

        Fleetcor_Calendar_Month__c[] periodFCTemp = [
                SELECT Start_Date__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c <= 2017-08-28
                AND End_Date__c >= 2017-09-24
                ORDER BY Start_Date__c
                LIMIT 1
        ];
        String testPeriodFC = periodFCTemp.get(0).Start_Date__c.format();
        String testMonthReport = Date.newInstance(periodFCTemp.get(0).Start_Date__c.year(), periodFCTemp.get(0).Start_Date__c.month() + 1, 1).format();

        controller.periodFC = testPeriodFC;
        controller.monthReport = testMonthReport;
        controller.salesGroup = testSalesGroup;
        controller.reportType = 'final';
        controller.init();

        PageReference pageRef = Page.ConversionReportPPR;
        pageRef.getParameters().put('salesGroup', testSalesGroup);
        pageRef.getParameters().put('monthReport', testMonthReport);
        pageRef.getParameters().put('periodFC', testPeriodFC);
    }

    @isTest 
    static void createLeadPartnersAdd() {

        Id testSalesGroup = null;
        testSalesGroup = [SELECT Id FROM UserRole WHERE Name LIKE '%PPR Bryansk Partner Sales (1)%' LIMIT 1].get(0).Id;

        ConversionReportPPRCtrl controller = new ConversionReportPPRCtrl();

        Fleetcor_Calendar_Month__c[] periodFCTemp = [
                SELECT Start_Date__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c <= 2017-09-25 
                AND End_Date__c >= 2017-10-29
                ORDER BY Start_Date__c
                LIMIT 1
        ];
        String testPeriodFC = periodFCTemp.get(0).Start_Date__c.format();
        String testMonthReport = Date.newInstance(periodFCTemp.get(0).Start_Date__c.year(), periodFCTemp.get(0).Start_Date__c.month() + 1, 1).format();

        controller.periodFC = testPeriodFC;
        controller.monthReport = testMonthReport;
        controller.salesGroup = testSalesGroup;
        controller.reportType = 'final';
        controller.init();

        PageReference pageRef = Page.ConversionReportPPR;
        pageRef.getParameters().put('salesGroup', testSalesGroup);
        pageRef.getParameters().put('monthReport', testMonthReport);
        pageRef.getParameters().put('periodFC', testPeriodFC);
    }

    @isTest 
    static void createLeadPSO3() {
        initUserForReportSend();

        Id testSalesGroup = null;
        testSalesGroup = [SELECT Id FROM UserRole WHERE Name LIKE '%PPR Bryansk PSO 3%' LIMIT 1].get(0).Id;

        ConversionReportPPRCtrl controller = new ConversionReportPPRCtrl();

        Fleetcor_Calendar_Month__c[] periodFCTemp = [
                SELECT Start_Date__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Start_Date__c <= 2017-08-28
                AND End_Date__c >= 2017-09-24
                ORDER BY Start_Date__c
                LIMIT 1
        ];
        String testPeriodFC = periodFCTemp.get(0).Start_Date__c.format();
        String testMonthReport = Date.newInstance(periodFCTemp.get(0).Start_Date__c.year(), periodFCTemp.get(0).Start_Date__c.month() + 1, 1).format();

        controller.periodFC = testPeriodFC;
        controller.monthReport = testMonthReport;
        controller.salesGroup = testSalesGroup;
        controller.reportType = 'final';
        controller.mode = 'send';
        controller.init();

        PageReference pageRef = Page.ConversionReportPPR;
        pageRef.getParameters().put('salesGroup', testSalesGroup);
        pageRef.getParameters().put('monthReport', testMonthReport);
        pageRef.getParameters().put('periodFC', testPeriodFC);
    }
}