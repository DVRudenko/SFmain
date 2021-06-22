/**
 * Created by Nikita.Dayanov on 05.07.2018.
 */

@IsTest
private class DashboardPersonalNetStartsPPRCtrlTest {
    public Static User u;
    public Static Opportunity newOpp;
    public static Starts__c newStarts;
    public static Account acc;

    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only' LIMIT 1];
    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND sObjectType = 'Account' LIMIT 1];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
    private static User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];


    @IsTest
    public static void testPersonalNetStartsPPRCtrl() {

        System.runAs(thisUser) {
            createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
            createCustomSettings();
        }

        System.runAs(u) {
            createOpp();
            createStarts();
            createCalendar();
            DashboardPersonalNetStartsPPRCtrl controller = new DashboardPersonalNetStartsPPRCtrl();
            controller.init();

            controller.init();
        }
    }

    @IsTest
    public static void testGetCurrentWeek() {

        System.runAs(thisUser) {
            createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
            createCustomSettings();
        }

        System.runAs(u) {

            createCalendar();
            DashboardPersonalNetStartsPPRCtrl controller = new DashboardPersonalNetStartsPPRCtrl();
            Fleetcor_Calendar_Week__c week = controller.getCurrentFleetcorWeek();

            System.assertEquals(true, week != null);
            System.assertEquals(week.Start_Date__c, Date.today().addDays(-3));
        }
    }

    static void createCalendar() {
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
    }

    static void createTeamLeaderUser(Id userRoleId) {

        u = new User(
                UserRoleId = userRoleId,
                ProfileId = userProfileId.Id,
                Username = System.now().millisecond() + '_23423_test2@test.com',
                Alias = 'zabiyaka',
                Email = 'e.pugachev_1233@chastpikinerov.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Emelya',
                Lastname = 'Pugachev',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow'
        );
        Database.insert(u);
    }

    private static void createOpp() {
        if (acc == null) {
            acc = new Account(
                    Name = 'Aveg Inc.',
                    BillingCountry = 'Russia'
            );
            insert acc;
        }
        if (newOpp == null) {
            newOpp = new Opportunity(
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
                    PPR_Electronic_document_management__c = 'not_using',
                    CategoryContract__c = 'О',
                    PPR_Transit_First_Pump_Date__c = Date.today().addDays(-10)
            );
            insert newOpp;
        }
    }

    private static void createStarts() {
        if (newStarts == null) {
            newStarts = new Starts__c(
                    Opportunity__c = newOpp.id,
                    client_week_number__c = 2,
                    Account__c = acc.Id,
                    Transit_ID__c = '3798ywt978'
            );
            insert newStarts;
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