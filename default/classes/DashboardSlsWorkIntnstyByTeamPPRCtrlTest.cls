/**
 * Created by A.Syromyatnikov on 30.01.2019.
 */

@IsTest
public with sharing class DashboardSlsWorkIntnstyByTeamPPRCtrlTest {
    public static User u;
    public static Account newAcc;
    public static Lead newLead;
    public static Opportunity newOpp;
    public static Task newTask;

    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader' LIMIT 1];
    private static RecordType taskRecType = [SELECT Id FROM RecordType WHERE Name LIKE '%Russian%' AND SobjectType = 'Task'];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name LIKE '%Russian%' AND SobjectType = 'Opportunity'];
    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name LIKE '%Russian%' AND SobjectType = 'Account'];

    @isTest
    public static void testIntensityOfSalesWorkPPR1() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'PPR_Bryansk'];
        Test.startTest();
        createTeamLeaderUser(r.Id);
        createCustomSettings();
        Test.stopTest();

        System.runAs(u) {
            createAcc();
            createLead();
            createOpp();
            createTask();

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

            DashboardSlsWorkIntensityByTeamPPRCtrl controller = new DashboardSlsWorkIntensityByTeamPPRCtrl();
            controller.init();
            controller.getRolesList();
            controller.changeRole();
            controller.getPeriodsList();
            controller.getYearsList();
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
    public static void testIntensityOfSalesWorkPPRException() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'Role_Up'];
        Test.startTest();
        createTeamLeaderUser(r.Id); //Role_Up
        Test.stopTest();

        System.runAs(u) {
            DashboardSlsWorkIntensityByTeamPPRCtrl controllerErr = new DashboardSlsWorkIntensityByTeamPPRCtrl();

            controllerErr.init();
        }
    }

    @future
    static void createTeamLeaderUser(Id userRoleId) {

        u = new User(
                UserRoleId = userRoleId,
                ProfileId = userProfileId.Id,
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


    private static void createLead() {
        newLead = new Lead(
                OwnerId = u.Id,
                Country = 'Germany',
                CountryCode = 'DE',
                Company = 'test company',
                Salutation = 'Herr',
                Anzahl_der_Karten_Euroshell__c = 'test',
                Status = 'Open',
                Anzahl_der_Fahrzeuge__c = 2,
                FirstName = 'testName',
                LastName = 'testFam',
                Sec_Channel__c = 'Inbound',
                Phone = '+493333333',
                LeadSource = 'Internet',
                Quali_Status__c = 'Refused to talk',
                Branche_NACE__c = 'Apotheken - 4773',
                Beschaeftigte__c = '1-4',
                Disable_for_KPI__c = false,
                PD_Avaliable_LastName_Update__c = true
        );
        insert newLead;
    }

    private static void createAcc() {
        if (newAcc == null) {
            newAcc = new Account(
                    Name = 'test',
                    RecordTypeId = accRt.Id,
                    INN__c = '1231231231',
                    BillingCountry = 'Russia',
                    Industry = 'Торговля (опт. розница)'
            );
            insert newAcc;
        }
    }

    private static void createOpp() {
        newOpp = new Opportunity(
                OwnerId = u.Id,
                AccountId = newAcc.Id,
                RecordTypeId = oppRt.Id,
                Name = 'testOpp',
                Number_of_Vehicles__c = 100,
                Projected_Liters_weekly__c = 5000,
                StageName = 'Договор на проверке',
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
                Insurance__c = 'Agree',
                CloseDate = Date.today());
        insert newOpp;
    }

    private static void createTask() {
        newTask = new Task(
                OwnerId = u.Id,
                RecordTypeId = taskRecType.Id,
                Subject = 'Call',
                Type = 'Call',
                Status = 'Completed',
                Priority = 'Normal',
                WhatId = newOpp.Id,
                WhoId = null,
                ActivityDate = Date.today().addDays(-1));
        insert newTask;
//        Datetime createdDate = Date.today();
//        Test.setCreatedDate(newTask.Id, createdDate);
    }

    private static void createCustomSettings() {
        CF_Settings__c cf_settings = new CF_Settings__c();
        cf_settings.Name = 'Russia';
        cf_settings.Check_on_opportunity_create__c = false;
        cf_settings.Check_on_opportunity_update__c = false;
        insert cf_settings;
    }
}