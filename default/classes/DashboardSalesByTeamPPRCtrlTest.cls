/**
 * Created by A.Syromyatnikov on 30.01.2019.
 */

@IsTest
public with sharing class DashboardSalesByTeamPPRCtrlTest {
    private static User u;
    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader' LIMIT 1];


    private static DashboardSalesByTeamPPRCtrl controller {
        get {
            if (controller == null) {
                controller = new DashboardSalesByTeamPPRCtrl();
                return controller;
            }
            return controller;
        }
        private set;
    }

    @isTest
    private static void testDashboard() {

        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'PPR_Bryansk'];
        Test.startTest();
        createTeamLeaderUser(r.Id);
        Test.stopTest();

        System.runAs(u) {
            controller.getRolesList();
            controller.changeRole();
            String role = controller.selectedRole;
            UserRole role2 = controller.currentRole;
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
}