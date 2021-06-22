/**
 * Created by A.Syromyatnikov on 29.01.2019.
 */

@IsTest
public class DashboardOpenOpptysByTeamPPRCtrlTest {
    public static User u;
    public static Opportunity newOppty;
    public static Task newTask;

    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];

    @IsTest
    public static void testDashboardOpenOpptyPPRCtrl() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'PPR_Bryansk'];
        Test.startTest();
        createTeamLeaderUser(r.Id);
        createCustomSettings();
        Test.stopTest();

        System.runAs(u) {
            createOpp();

            DashboardOpenOpptysByTeamPPRCtrl controller = new DashboardOpenOpptysByTeamPPRCtrl();
            controller.init();
            controller.getRolesList();
            controller.changeRole();

            createTask();
            controller.init();
        }
    }

    @isTest
    public static void testDashboardOpenOpptyException() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'Role_Up'];
        Test.startTest();
        createTeamLeaderUser(r.Id);
        createCustomSettings();
        Test.stopTest();

        System.runAs(u) {
            DashboardOpenOpptysByTeamPPRCtrl controllerErr = new DashboardOpenOpptysByTeamPPRCtrl();

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
                    PPR_Electronic_document_management__c = 'not_using',
                    CategoryContract__c = 'О'
            );
            insert newOppty;
        }
    }

    private static void createTask() {
        newTask = new Task(
                OwnerId = u.Id,
                RecordTypeId = taskRt.Id,
                Subject = 'Call',
                Type = 'Call',
                Status = 'In Progress',
                Priority = 'Normal',
                WhatId = newOppty.Id,
                ActivityDate = Date.today().addDays(-2));
        insert newTask;
        Datetime createdDate = Date.today().addDays(-5);
        Test.setCreatedDate(newTask.Id, createdDate);
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}