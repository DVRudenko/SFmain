/**
 * Created by Nikita.Mikhailov on 16.05.2018.
 */

@isTest
private class DashboardTopDealsPPRCtrlTest {
    public static User u;
    public static Opportunity newOpp;
    public static Account newAcc;
    public static DateTime testDateTime = DateTime.now();

    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND sObjectType = 'Account' LIMIT 1];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];

    @isTest
    public static void testTopDealsDashboard1() {
        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY'); //PPR_Fleetcor
        createCustomSettings();
        Test.stopTest();

        System.runAs(u) {
            createAcc();
            createOpp();

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
            insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                    Name = 'July',
                    Month_Number__c = 7,
                    Start_Date__c = Date.today().addDays(-10),
                    End_Date__c = Date.today().addDays(20),
                    Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
                    Start_Date__c = Date.today().addDays(-3),
                    End_Date__c = Date.today().addDays(4),
                    Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            DashboardTopDealsPPRCtrl controller = new DashboardTopDealsPPRCtrl();
            controller.init();
            controller.getYearsList();
            controller.getPeriodsList();
            controller.getLimitsList();
            controller.getRolesList();
            controller.selectedPeriod = month.Id;
            controller.changeYear();
            controller.selectedRole = [SELECT Id FROM UserRole WHERE Name = 'PPR Telesales'].Id;
            controller.changeRole();
            controller.getLookInUserList();
            controller.changePeriod();
            controller.changeLookInUser();
            controller.changeLimit();
            controller.getTopConditions();
            controller.changeTopCondition();
            controller.topCondition = 'Cards';
            controller.changeTopCondition();

            controller.lookInUser = u.Id;
            controller.changePeriod();
            controller.changeLookInUser();
            controller.changeLimit();
            controller.changeYear();

            controller.selectedYear = '1900';

            year = new Fleetcor_Calendar_Year__c(Name = '1900');
            insert year;

            month = new Fleetcor_Calendar_Month__c(
                    Name = 'January',
                    Month_Number__c = 1,
                    Start_Date__c = Date.today().addDays(-100),
                    End_Date__c = Date.today().addDays(-80),
                    Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            controller.changeYear();

            week = new Fleetcor_Calendar_Week__c(
                    Start_Date__c = Date.today().addDays(-17),
                    End_Date__c = Date.today().addDays(-13),
                    Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            controller.selectedPeriod = null;
            controller.generateDataForCharts();
        }
    }

    @isTest
    public static void testTopDealsDashboardException() {
        Test.startTest();
        createTeamLeaderUser('00E20000001fPpGEAU'); //Role_Up
        Test.stopTest();

        System.runAs(u) {
            DashboardTopDealsPPRCtrl controllerErr = new DashboardTopDealsPPRCtrl();

            controllerErr.init();
        }
    }

    @future static void createTeamLeaderUser(Id userRoleId) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader'];

        u = new User(
                UserRoleId = userRoleId,
                ProfileId = p.Id,
                Username = System.now().millisecond() + '_23423_test2@test.com',
                Alias = 'batman',
                Email = 'bruce.wayne_1233@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow'
        );
        Database.insert(u);
    }

    private static void createAcc() {
        if (newAcc == null) {
            newAcc = new Account(
                    Name = 'test',
                    RecordTypeId = accRt.Id,
                    INN__c = '1231231231',
                    Industry = 'Торговля (опт. розница)'
            );
            insert newAcc;
        }
    }

    private static void createOpp() {
        if (newOpp == null) {
            newOpp = new Opportunity(
                    OwnerId = u.Id,
                    AccountId = newAcc.Id,
                    RecordTypeId = oppRt.Id,
                    Name = 'testOpp',
                    Number_of_Vehicles__c = 100,
                    Projected_Liters_weekly__c = 5000,
                    StageName = 'Договор на проверке',
                    CloseDate = System.today() + 10,
                    Most_Important_Feature__c = 'Налив',
                    Most_Important_Feature_specific__c = 'Бензовоз',
                    Area_Traveled__c = 'Local',
                    Travel_Pattern__c = 'Regular Route',
                    Primary_Fueling_Method__c = 'Bank Card',
                    Primary_Fueling_Method_specific__c = 'Visa',
                    PPR_First_Contact_Inbound_Outbound__c = 'Chat',
                    Source_of_Lead_o__c = 'Прочая БД',
                    Number_Business_CARD__c = 1,
                    Number_of_Cards__c = 1,
                    Product_PPR__c = 'ГАЗПРОМ – сеть АЗС',
                    Credit_days_ppr__c = 'Предоплата',
                    PPR_Electronic_document_management__c = 'not_using',
                    CategoryContract__c = 'О',
                    Number_of_cars__c = 1,
                    Projected_amount_in_rub_month__c = 700,
                    Insurance__c = 'Agree'
            );
            insert newOpp;
        }
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}