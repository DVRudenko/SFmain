public with sharing class MZKRequestSettingUtils {
    public static final String MZK_SETTING = 'settings';
    public static final String MZK_ORGANIZATION = 'organization';
    public static final String MZK_REQUEST_SETTING = 'MZKRequestSetting';

    public static Map<String, Object> getProductResource() {
        List<StaticResource> resources = [SELECT Body FROM StaticResource WHERE Name = :MZK_REQUEST_SETTING LIMIT 1];
        if (!resources.isEmpty()) {
            return (Map<String, Object>) JSON.deserializeUntyped(resources[0].Body.toString());
        }
        return null;
    }

    public static Map<String, Object> getProductSettings() {
        Map<String, Object> productResurce = getProductResource();
        if (productResurce != null) {
            return (Map<String, Object>) ((Map<String, Object>) productResurce.get(MZK_SETTING)).get(MZK_ORGANIZATION);
        }
        return null;
    }
}