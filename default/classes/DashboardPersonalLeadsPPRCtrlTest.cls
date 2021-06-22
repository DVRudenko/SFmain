/**
 * Created by Nikita.Dayanov on 06.07.2018.
 */

@isTest
private class DashboardPersonalLeadsPPRCtrlTest {

    public static User u;
    public static Lead newLead;
    public static Task newTask;
    public static Task wrongOwnerTask;
    public static Lead anotherLead;
    public static DateTime testDateTime = DateTime.now();

    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND sObjectType = 'Account' LIMIT 1];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Opportunity' LIMIT 1];
    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];

    @IsTest
    public static void testDashboardContactedLeadPPRCtrl()
    {
        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
        Test.stopTest();

        System.runAs(u) {
            createLead();

            DashboardPersonalLeadsPPRCtrl controller = new DashboardPersonalLeadsPPRCtrl();
            controller.init();

            createTask();
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
        insert newLead;
    }

    private static void createTask() {
        newTask = new Task(
                OwnerId = u.Id,
                RecordTypeId = taskRt.Id,
                Subject = 'Call',
                Type = 'Call',
                Status = 'In Progress',
                Priority = 'Normal',
                WhoId = newLead.Id,
                ActivityDate = Date.today().addDays(-2));
        insert newTask;
        Datetime createdDate = Date.today().addDays(-5);
        Test.setCreatedDate(newTask.Id, createdDate);
    }

}