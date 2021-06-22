public with sharing class BRSettingsController {
    public static final String EMPTY_SETTING_DATA = 'Error. Passed empty setting data.';

    private static BRSettingsManager manager = new BRSettingsManager();
    private static BRSettingsService service = new BRSettingsService();

    @AuraEnabled(Cacheable=true)
    public static List<BR_Setting__c> getAllBRSettings() {
        return manager.getAllBRSettings();
    }

    @AuraEnabled
    public static void saveSetting(String settingData) {
        if (String.isBlank(settingData)) {
            throw new GlobalException(EMPTY_SETTING_DATA);
        }
        service.saveSetting(settingData);
    }

    @AuraEnabled
    public static void deleteSetting(Id settingId) {
        if (settingId == null) {
            throw new GlobalException(EMPTY_SETTING_DATA);
        }
        service.deleteSetting(settingId);
    }
}
