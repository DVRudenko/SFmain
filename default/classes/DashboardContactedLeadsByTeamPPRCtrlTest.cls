/**
 * Created by A.Syromyatnikov on 29.01.2019.
 */

@IsTest
public class DashboardContactedLeadsByTeamPPRCtrlTest {
    public static User u;
    public static Lead newLead;
    public static Task newTask;

    private static RecordType taskRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND sObjectType = 'Task' LIMIT 1];

    @IsTest
    public static void testDashboardContactedLeadPPRCtrl() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'PPR_Bryansk'];
        Test.startTest();
        createTeamLeaderUser(r.Id);
        Test.stopTest();

        System.runAs(u) {
            createLead();

            DashboardContactedLeadsByTeamPPRCtrl controller = new DashboardContactedLeadsByTeamPPRCtrl();
            controller.init();
            controller.getRolesList();
            controller.changeRole();

            createTask();
            controller.init();
        }
    }

    @isTest
    public static void testTopDealsDashboardException() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'Role_Up'];
        Test.startTest();
        createTeamLeaderUser(r.Id); //Role_Up
        Test.stopTest();

        System.runAs(u) {
            DashboardContactedLeadsByTeamPPRCtrl controllerErr = new DashboardContactedLeadsByTeamPPRCtrl();

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
                FirstName = 'Bruce',
                LastName = 'Wayne',
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