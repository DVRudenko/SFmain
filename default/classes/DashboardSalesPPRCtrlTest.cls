/**
 * Created by Nikita.Mikhailov on 22.05.2018.
 */

@isTest
private class DashboardSalesPPRCtrlTest {

    private Static User u;
    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader' LIMIT 1];


    private static DashboardSalesPPRCtrl controller {
        get {
            if (controller == null) {
                controller = new DashboardSalesPPRCtrl();
                return controller;
            }
            return controller;
        }
        private set;
    }

    @isTest
    private static void testDashboard() {

        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
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