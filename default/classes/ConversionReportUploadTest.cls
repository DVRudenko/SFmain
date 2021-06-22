@isTest
public with sharing class ConversionReportUploadTest {

    public static void initPeriods() {
        Date now = System.Today();

        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(now.year()));
        insert year;

        Fleetcor_Calendar_Month__c month_1 = new Fleetcor_Calendar_Month__c(
                Name = 'October',
                Month_Number__c = 10,
                Start_Date__c = now.addDays(-20),
                End_Date__c = now.addDays(-1),
                Fleetcor_Calendar_Year__c = year.Id);
        insert month_1;

        Fleetcor_Calendar_Month__c month_2 = new Fleetcor_Calendar_Month__c(
                Name = 'November',
                Month_Number__c = 11,
                Start_Date__c = now.addDays(-40),
                End_Date__c = now.addDays(-21),
                Fleetcor_Calendar_Year__c = year.Id);
        insert month_2;

        Fleetcor_Calendar_Month__c month_3 = new Fleetcor_Calendar_Month__c(
                Name = 'Dec',
                Month_Number__c = 12,
                Start_Date__c = now,
                End_Date__c = now.addDays(20),
                Fleetcor_Calendar_Year__c = year.Id);
        insert month_3;
    }

    @isTest
    public static void testGetMails() {
        initPeriods();
        ConversionReportPPRCtrl conversionReportPPRCtrl = new ConversionReportPPRCtrl();
        conversionReportPPRCtrl.salesGroup = '00E0O0000023vG5UAI';
        String roleName = 'PPR PSO 3';
        Date FC = System.Today();
        conversionReportPPRCtrl.monthReport = System.Today().format();
        conversionReportPPRCtrl.periodFC = FC.format();
        conversionReportPPRCtrl.reportType = 'final';
        conversionReportPPRCtrl.uploadData();

        IConversionReport currentReportPPRImpl = new ConversionReportUpload(
                conversionReportPPRCtrl.uploadListAssignment,
                roleName + ' ' + FC.format() + '.csv',
                new String[] {'example.test@ecample=.com'}
        );
        System.assertEquals(1, currentReportPPRImpl.getMails().size());
        currentReportPPRImpl.getFileType();
    }
}