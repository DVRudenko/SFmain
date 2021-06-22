/**
 * Created by Nikita.Mikhailov on 15.06.2018.
 */

@IsTest
private class DashboardNetStartsPPRCtrlTest {
    public static User u;
    public static Opportunity newOppty;
    public static Task newTask;
    public static DateTime testDateTime = DateTime.now();

    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND sObjectType = 'Account' LIMIT 1];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];

    @IsTest
    public static void dashboardNetStartsPPRCtrl()
    {
        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
        Test.stopTest();

        System.runAs(u) {

            Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
            insert year;

            Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
                    Name = 'July',
                    Start_Date__c = Date.today().addDays(-10),
                    End_Date__c = Date.today().addDays(20),
                    Fleetcor_Calendar_Year__c = year.Id);
            insert month;

            Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
                    Start_Date__c = Date.today().addDays(-3),
                    End_Date__c = Date.today().addDays(3),
                    Fleetcor_Calendar_Month__c = month.Id);
            insert week;

            DashboardNetStartsPPRCtrl controller = new DashboardNetStartsPPRCtrl();
            controller.init();
            controller.getRolesList();
            controller.changeRole();
            controller.getPeriodsList();
            controller.getYearsList();
            controller.changeYear();
        }
    }

    @isTest
    public static void tesDashboardNetStartsPPRException() {
        Test.startTest();
        createTeamLeaderUser('00E20000001fPpGEAU'); //Role_Up
        Test.stopTest();

        System.runAs(u) {
            DashboardNetStartsPPRCtrl controllerErr = new DashboardNetStartsPPRCtrl();

            controllerErr.init();
        }
    }

    @future static void createTeamLeaderUser(Id userRoleId) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'API Only'];

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

    private static void createOpp() {
        if (newOppty == null) {
            newOppty = new Opportunity(
                    OwnerId = u.Id,
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
                    PPR_Electronic_document_management__c = 'НЕТ',
                    CategoryContract__c = 'О'
            );
            insert newOppty;
        }
    }
}