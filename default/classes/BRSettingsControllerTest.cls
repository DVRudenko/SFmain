@IsTest
public with sharing class BRSettingsControllerTest {

    @TestSetup
    private static void setup() {
        insert BRTestDataFactory.createSetting();
    }

    @IsTest
    private static void getAllBRSettingsTest() {
        System.assertNotEquals(null, BRSettingsController.getAllBRSettings());
    }

    @IsTest
    private static void testSaveSetting_EmptyData() {
        try {
            BRSettingsController.saveSetting(null);
        } catch(Exception e) {
            System.assertEquals(BRSettingsController.EMPTY_SETTING_DATA, e.getMessage());
        }

        try {
            BRSettingsController.saveSetting('');
        } catch(Exception e) {
            System.assertEquals(BRSettingsController.EMPTY_SETTING_DATA, e.getMessage());
        }
    }

    @IsTest
    private static void testSaveSetting_Success() {
        BRSettingWrapper settingWrapper = new BRSettingWrapper();
        settingWrapper.name = 'test from wrapper';
        settingWrapper.sObjectName = 'Opportunity';
        settingWrapper.isActive = true;
        settingWrapper.sObjectStatus = 'free';
        BRSettingsController.saveSetting(JSON.serialize(settingWrapper));
        BR_Setting__c newSetting = [SELECT SObject__c FROM BR_Setting__c WHERE Name = :settingWrapper.name];

        System.assertEquals(settingWrapper.sObjectName, newSetting.SObject__c);
    }

    @IsTest
    private static void testDeleteSetting() {
        try {
            BRSettingsController.deleteSetting(null);
        } catch(Exception e) {
            System.assertEquals(BRSettingsController.EMPTY_SETTING_DATA, e.getMessage());
        }

        BR_Setting__c newSetting = BRTestDataFactory.createSetting();
        insert newSetting;

        BRSettingsController.deleteSetting(newSetting.Id);
        List<BR_Setting__c> settingsFromDB = [SELECT Id FROM BR_Setting__c WHERE Id =: newSetting.Id];

        System.assertEquals(0, settingsFromDB.size());
    }
}
