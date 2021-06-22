@isTest
public with sharing class ProfileManagerTest {
    @IsTest
    private static void testGetProfileByName() {
        Profile profile = ProfileManager.getProfileByName('System administrator');
        System.assertNotEquals(null, profile);

        profile = ProfileManager.getProfileByName(null);
        System.assertEquals(null, profile);
    }

    @IsTest
    private static void testGetRoleIdByName() {
        Profile profile = ProfileManager.getUserProfileById(UserInfo.getProfileId());
        System.assertNotEquals(null, profile);

        profile = ProfileManager.getUserProfileById(null);
        System.assertEquals(null, profile);
    }
}
