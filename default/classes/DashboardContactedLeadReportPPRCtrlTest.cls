/**
 * Created by Nikita.Mikhailov on 28.05.2018.
 */

@IsTest
private class DashboardContactedLeadReportPPRCtrlTest {
    public Static User u;
    public Static Lead newLead;
    public Static Task newTask;

    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader' LIMIT 1];
    private static RecordType taskRecType = [SELECT Id FROM RecordType WHERE Name like '%Russian%' AND SobjectType = 'Task'];
    private static RecordType oppRt = [SELECT Id FROM RecordType WHERE Name like '%Russian%' AND SobjectType = 'Opportunity'];
    private static RecordType accRt = [SELECT Id FROM RecordType WHERE Name like '%Russian%' AND SobjectType = 'Account'];

    @IsTest
    public static void testDashboardContactedLeadReportPPRCtrl1()
    {
        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
        Test.stopTest();

        System.runAs(u) {
            createLead();

            DashboardContactedLeadReportPPRCtrl controller = new DashboardContactedLeadReportPPRCtrl();
            controller.init();
            createTask();
            controller.init();

            List<DashboardContactedLeadReportPPRCtrl.LeadWrapper> leads = controller.leadsWithoutTasks;
            leads = controller.leadsWithOverdueTasks;
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
                Disable_for_KPI__c = FALSE,
                PD_Avaliable_LastName_Update__c  = true
        );
        insert newLead;
    }

    private static void createTask() {
        newTask = new Task(
                OwnerId = u.Id,
                RecordTypeId = taskRecType.Id,
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