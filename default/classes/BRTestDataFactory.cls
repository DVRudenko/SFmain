@IsTest
public with sharing class BRTestDataFactory {
    public static List<Schema.PicklistEntry> conditionPEList = GlobalUtils.getPicklistValues(BR_filter__c.getSObjectType(), 'Condition__c');
    public static List<Schema.PicklistEntry> fieldTypePEList = GlobalUtils.getPicklistValues(BR_filter__c.getSObjectType(), 'Field_type__c');

    public static BR_Setting__c createSetting() {
        return new BR_Setting__c(
                Name = 'Test setting',
                Is_active__c = true,
                SObject_status__c = 'Free',
                SObject__c = 'Opportunity'
        );
    }

    public static BR_case__c createCase(Id settingId) {
        return new BR_case__c(
                Name = 'test case',
                BR_Setting__c = settingId,
                Filter_logic__c = 'test logic'
        );
    }

    public static BR_filter__c createFilter(Id caseId) {
        return new BR_filter__c(
                BR_case__c = caseId,
                Condition__c = conditionPEList.get(0).getValue(),
                Field__c = 'test',
                Field_type__c = fieldTypePEList.get(0).getValue(),
                Field_value__c = 'test',
                Filter_number__c = 1
        );
    }

    public static BRSettingWrapper createSettingWrapper() {
        BRSettingWrapper settingWrapper = new BRSettingWrapper();
        settingWrapper.name = 'test from wrapper';
        settingWrapper.sObjectName = 'Opportunity';
        settingWrapper.isActive = true;
        List<Schema.PicklistEntry> sObjectStatusPEList = GlobalUtils.getPicklistValues(BR_Setting__c.getSObjectType(), 'SObject_status__c');
        settingWrapper.sObjectStatus = sObjectStatusPEList.get(0).getValue();

        return settingWrapper;
    }

    public static BRSettingWrapper.BRCase createCaseWrapper() {
        BRSettingWrapper.BRCase brCase = new BRSettingWrapper.BRCase();
        brCase.name = 'test case';
        brCase.filterLogic = 'test';

        return brCase;
    }

    public static BRSettingWrapper.BRFilter createFilterWrapper() {
        BRSettingWrapper.BRFilter filter = new BRSettingWrapper.BRFilter();
        filter.condition = conditionPEList.get(0).getValue();
        filter.fieldType = fieldTypePEList.get(0).getValue();
        filter.field = 'test';
        filter.fieldValue = 'test';
        filter.filterNumber = '1';

        return filter;
    }
}
