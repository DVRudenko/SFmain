/**
 * Created by Nikita.Dayanov on 06.07.2018.
 */
@isTest
private class DashboardPersonalSalesPPRCtrlTest {

    private Static User u;
    private static Profile userProfileId = [SELECT Id FROM Profile WHERE Name = 'Russian Team Leader' LIMIT 1];

    @isTest
    private static void testDashboard() {

        Test.startTest();
        createTeamLeaderUser('00E0O0000023vGQUAY');//PPR_Fleetcor
        Test.stopTest();

        System.runAs(u) {
            DashboardPersonalSalesPPRCtrl controller = new DashboardPersonalSalesPPRCtrl();

            String usr = controller.userId;
            UserRole rol = controller.connectedUserRole;

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