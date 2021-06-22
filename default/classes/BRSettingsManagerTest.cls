@IsTest
public with sharing class BRSettingsManagerTest {

    private static BRSettingsManager manager = new BRSettingsManager();

    @IsTest
    private static void getAllBRSettingsTest() {
        System.assertEquals(0, manager.getAllBRSettings().size());

        insert BRTestDataFactory.createSetting();
        System.assertEquals(1, manager.getAllBRSettings().size());
    }

    @IsTest
    private static void testGetCasesAndDependedFiltersBySettingId() {
        System.assertEquals(new List<BR_case__c>{}, manager.getCasesAndDependedFiltersBySettingId(null));

        BR_Setting__c newSetting = BRTestDataFactory.createSetting();
        BR_Setting__c newSettingSecond = BRTestDataFactory.createSetting();
        insert new List<BR_Setting__c>{newSetting, newSettingSecond};
        BR_case__c newCase = BRTestDataFactory.createCase(newSetting.Id);
        BR_case__c newCaseSecond = BRTestDataFactory.createCase(newSettingSecond.Id);
        insert new List<BR_case__c>{newCase, newCaseSecond};
        BR_filter__c newFilter = BRTestDataFactory.createFilter(newCase.Id);
        BR_filter__c newFilterSecond = BRTestDataFactory.createFilter(newCaseSecond.Id);
        insert new List<BR_filter__c>{newFilter, newFilterSecond};
        List<BR_case__c> cases = manager.getCasesAndDependedFiltersBySettingId(newSetting.Id);

        System.assertEquals(1, cases.size());
        System.assertEquals(newCase.Id, cases.get(0).Id);

        System.assertEquals(1, cases.get(0).BR_filters__r.size());
        System.assertEquals(newFilter.Id, cases.get(0).BR_filters__r.get(0).Id);
    }
}
