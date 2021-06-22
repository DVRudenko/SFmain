@isTest
public with sharing class EmailReportQueueableTest {

    private static final String userFirstName = 'Ilya';
    private static final String userLastName = 'Lopatin';

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

    @future
    public static void initUsers() {

        Profile saleProfile = [
                SELECT Id
                FROM Profile
                WHERE Name IN ('Russian Sales Manager')];

        UserRole saleRole = [
                SELECT Id
                FROM UserRole
                WHERE Name = 'PPR Bryansk PSO 3'];

        User saleUser = new User(
                Username = 'usertest@fleetcor.de',
                Alias = 'uset1@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Ilya',
                LastName = 'NewLopatin',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                UserRoleId = saleRole.Id,
                ProfileId = saleProfile.Id,
                Points__c = 0,
                Earned_Points__c = 0);
        insert saleUser;


        Profile teamLeadProfile = [
                SELECT Id
                FROM Profile
                WHERE Name IN ('Russian Team Leader')];

        UserRole teamLeadRole = [
                SELECT Id
                FROM UserRole
                WHERE Name = 'PPR SME'];

        User leadUser = new User(
                Username = 'newusertest@fleetcor.de',
                Alias = 'uset2@fl',
                Email = 'newusertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                FirstName = userFirstName,
                LastName = userLastName,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                UserRoleId = teamLeadRole.Id,
                ProfileId = teamLeadProfile.Id,
                Points__c = 0,
                Earned_Points__c = 0);
        insert leadUser;
    }

    public static void initSettings() {
        RU_Conversion_Report_Email_User__c customSetting = new RU_Conversion_Report_Email_User__c(
                Name = userFirstName + ' ' + userLastName
        );
        insert customSetting;
    }

    @isTest
    public static void testWithSendEmails() {
        initUsers();
        initPeriods();
        initSettings();

        Test.startTest();
            IConversionReport currentReportPPRImpl = new ConversionReportPPRImpl(System.Today(), 'xls', 'current');
            System.enqueueJob(new EmailReportQueueable(currentReportPPRImpl));
        Test.stopTest();
    }

    @isTest
    public static void testWithoutSendEmails() {
        initUsers();
        initPeriods();
        initSettings();

        Test.startTest();
            IConversionReport currentReportPPRImpl = new ConversionReportPPRImpl(System.Today().addDays(2), 'xls', 'current');
            System.enqueueJob(new EmailReportQueueable(currentReportPPRImpl));
        Test.stopTest();
    }
}