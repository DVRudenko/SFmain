@isTest
public with sharing class UserRoleManagerTest {

    public static final String PPR_FLEETCOR_ROLE_LABEL = 'PPR_Fleetcor';

    @IsTest
    private static void testGetRoleIdByName() {
        UserRole userRole = UserRoleManager.getUserRoleById(UserInfo.getUserRoleId());
        System.assertNotEquals(null, userRole);

        userRole = UserRoleManager.getUserRoleById(null);
        System.assertEquals(null, userRole);
    }

    @IsTest
    private static void testGetUserRoleByName() {

        UserRole userRole = UserRoleManager.getUserRoleByName(PPR_FLEETCOR_ROLE_LABEL);
        System.assertEquals([SELECT Id FROM UserRole WHERE DeveloperName = :PPR_FLEETCOR_ROLE_LABEL].get(0).Id, userRole.Id);

        userRole = UserRoleManager.getUserRoleByName(null);
        System.assertEquals(null, userRole);

        userRole = UserRoleManager.getUserRoleByName('');
        System.assertEquals(null, userRole);

        userRole = UserRoleManager.getUserRoleByName('  ');
        System.assertEquals(null, userRole);

    }
}
