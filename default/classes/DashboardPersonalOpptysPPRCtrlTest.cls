/**
 * Created by Nikita.Dayanov on 05.07.2018.
 */

@isTest
private class DashboardPersonalOpptysPPRCtrlTest {

    public Static User u;
    public Static Opportunity newOpp;
    public Static Task newTask;
    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only' LIMIT 1];

    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND sObjectType = 'Account' LIMIT 1];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];
    private static User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    @IsTest
    public static void testPersonalOpptysPPRCtrl() {

        System.runAs(thisUser) {
            createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
            createCustomSettings();
        }

        System.runAs(u) {
            createOpp();

            DashboardPersonalOpptysPPRCtrl controller = new DashboardPersonalOpptysPPRCtrl();
            controller.init();

            createTask();
            controller.init();
        }
    }

    static void createTeamLeaderUser(Id userRoleId) {

        u = new User(
                UserRoleId = userRoleId,
                ProfileId = userProfileId.Id,
                Username = System.now().millisecond() + '_23423_test2@test.com',
                Alias = 'voyaka',
                Email = 'd.pozharsky_1233@chastpikinerov.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Dmitri',
                Lastname = 'Pozharskiy',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'Europe/Moscow'
        );
        Database.insert(u);
    }

    private static void createOpp() {
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
                    CategoryContract__c = 'О'
            );
            insert newOpp;
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
                WhatId = newOpp.Id,
                ActivityDate = Date.today().addDays(-20));
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