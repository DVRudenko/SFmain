/**
 * Created by Nikita.Dayanov on 26.07.2018.
 */

@isTest
public with sharing class DashboardPersonalIntenstyWorkPPRCtrlTest {

    public static User u;
    public static Task newTask;
    public static Lead newLead;
    public static LeadHistory leadHist;
    public static Opportunity newOpp;
    private static Fleetcor_Calendar_Year__c currentYear;
    private static Fleetcor_Calendar_Month__c currentMonth;
    private static Fleetcor_Calendar_Week__c currentWeek;

    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];

    @IsTest
    public static void testDashboardPersonalIntensityPPRCtrl() {
        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY'); //PPR_Fleetcor

        Test.stopTest();

        System.runAs(u) {
            DashboardPersonalIntensityOfWorkPPRCtrl controller = new DashboardPersonalIntensityOfWorkPPRCtrl();
            createYear();
            createMonth();
            createTask();
            createWeek();
            createLead();
            createOpp();

            controller.init();
        }
    }

    @future static void createTeamLeaderUser(Id userRoleId) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader'];

        u = new User(
            UserRoleId = userRoleId,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_23423_test2@test.com',
            Alias = 'batman',
            Email = 'kuzma.minin_1233@pomestyegorki.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Kuzma',
            Lastname = 'Minin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Moscow'
        );
        Database.insert(u);
    }

    private static void createTask() {
        newTask = new Task(
            OwnerId = u.Id,
            RecordTypeId = taskRt.Id,
            Subject = 'Call',
            Type = 'Call',
            Status = 'In Progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-2));

        insert newTask;
        Datetime createdDate = Date.today().addDays(-5);
        Test.setCreatedDate(newTask.Id, createdDate);
    }

    private static void createYear() {
        currentYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
        insert currentYear;
    }

    private static void createMonth() {
        currentMonth = new Fleetcor_Calendar_Month__c(
            Start_Date__c = Date.today().addDays(-15),
            End_Date__c = Date.today().addDays(15),
            Fleetcor_Calendar_Year__c = currentYear.Id);
        insert currentMonth;
    }

    private static void createWeek() {
        currentWeek = new Fleetcor_Calendar_Week__c(
            Start_Date__c = Date.today().addDays(-4),
            End_Date__c = Date.today().addDays(3),
            Fleetcor_Calendar_Month__c = currentMonth.Id);
        insert currentWeek;
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
            Disable_for_KPI__c = FALSE,
                PD_Avaliable_LastName_Update__c  = true
        );
        leadHist = new LeadHistory(Lead = newLead, LeadId = newLead.Id);
        newLead.Histories.add(leadHist);

        insert newLead;
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
                PPR_Electronic_document_management__c = 'НЕТ',
                CategoryContract__c = 'О'
            );
        }
    }
}