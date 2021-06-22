public with sharing class BRSettingsManager {

    public List<BR_Setting__c> getAllBRSettings() {
        return ([
                SELECT
                Id,
                Is_active__c,
                Name,
                SObject__c,
                SObject_status__c
                FROM BR_Setting__c
        ]);
    }

    public List<BR_case__c> getCasesAndDependedFiltersBySettingId(Id settingId) {
        if (settingId == null) {
            return new List<BR_case__c>();
        }
        return [
                SELECT Id, (SELECT Id FROM BR_filters__r)
                FROM BR_case__c
                WHERE BR_Setting__c = :settingId
        ];
    }
}
