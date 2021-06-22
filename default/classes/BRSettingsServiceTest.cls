@IsTest
public with sharing class BRSettingsServiceTest {
    private static BRSettingsService service = new BRSettingsService();

    @IsTest
    private static void testSaveSetting_Exceptions() {
        service.saveSetting(null);

        BRSettingWrapper settingWrapper = new BRSettingWrapper();
        settingWrapper.name = 'test from wrapper';
        try {
            service.saveSetting(JSON.serialize(settingWrapper));
        } catch(Exception e) {
            System.assertEquals(BRSettingsService.SAVE_FAILED, e.getMessage());
        }
    }

    @IsTest
    private static void testSaveSetting_Success() {
        BRSettingWrapper settingWrapper = BRTestDataFactory.createSettingWrapper();
        service.saveSetting(JSON.serialize(settingWrapper));
        BR_Setting__c savedSetting = [
                SELECT SObject__c, SObject_status__c, Is_active__c
                FROM BR_Setting__c WHERE Name = :settingWrapper.name LIMIT 1
        ];

        System.assertEquals(settingWrapper.sObjectName, savedSetting.SObject__c);
        System.assertEquals(settingWrapper.isActive, savedSetting.Is_active__c);
        System.assertEquals(settingWrapper.sObjectStatus, savedSetting.SObject_status__c);

        settingWrapper.id = savedSetting.Id;
        BRSettingWrapper.BRCase brCase = BRTestDataFactory.createCaseWrapper();
        BRSettingWrapper.BRFilter filter = BRTestDataFactory.createFilterWrapper();
        brCase.filters = new List<BRSettingWrapper.BRFilter>{filter};
        settingWrapper.cases = new List<BRSettingWrapper.BRCase>{brCase};

        service.saveSetting(JSON.serialize(settingWrapper));
        BR_case__c savedCase = [SELECT Filter_logic__c, BR_Setting__c FROM BR_case__c WHERE Name =: brCase.name LIMIT 1];
        BR_filter__c savedFilter = [
                SELECT Condition__c, Field__c, Field_type__c, Field_value__c, BR_case__c
                FROM BR_filter__c WHERE Filter_number__c = 1 LIMIT 1
        ];

        System.assertEquals(brCase.filterLogic, savedCase.Filter_logic__c);

        System.assertEquals(filter.condition, savedFilter.Condition__c);
        System.assertEquals(filter.fieldType, savedFilter.Field_type__c);
        System.assertEquals(filter.field, savedFilter.Field__c);
        System.assertEquals(filter.fieldValue, savedFilter.Field_value__c);

        System.assertEquals(savedCase.Id, savedFilter.BR_case__c);
        System.assertEquals(savedSetting.Id, savedCase.BR_Setting__c);

        BR_filter__c newFilterForDeleteLogic = BRTestDataFactory.createFilter(savedCase.Id);
        insert newFilterForDeleteLogic;

        service.saveSetting(JSON.serialize(settingWrapper));

        List<BR_filter__c> listForDeletedFilter = [SELECT Id FROM BR_filter__c WHERE Id =:newFilterForDeleteLogic.Id];
        System.assertEquals(0, listForDeletedFilter.size());
    }

    @IsTest
    private static void testDeleteSetting() {
        try {
            service.deleteSetting(null);
        } catch(Exception e) {
            System.assertEquals(BRSettingsService.DELETE_FAILED, e.getMessage());
        }

        BR_Setting__c newSetting = BRTestDataFactory.createSetting();
        insert newSetting;

        BRSettingsController.deleteSetting(newSetting.Id);
        List<BR_Setting__c> settingsFromDB = [SELECT Id FROM BR_Setting__c WHERE Id =: newSetting.Id];

        System.assertEquals(0, settingsFromDB.size());
    }
}
