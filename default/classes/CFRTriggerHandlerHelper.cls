public with sharing class CFRTriggerHandlerHelper {
    public static final String CFR_RT_STATIC_RESOURCE_NAME = 'CFR_RecordTypes';
    public static final String RT_FOR_CHANGE_OWNER = 'recordTypesForChangeOwner';
    private static final String CFR_RT_STATIC_RESOURCE_KEY = 'recordTypes';

    public Set<String> getRecordTypeNamessForCFR() {
        return getRecordTypesSetting(CFR_RT_STATIC_RESOURCE_KEY);
    }

    public Set<String> getRecordTypesSetting(String name) {
        Set<String> recordtypeNamesSet = new Set<String>();
        List<StaticResource> staticResources = [SELECT Body FROM StaticResource WHERE Name = :CFR_RT_STATIC_RESOURCE_NAME LIMIT 1];

        if (!staticResources.isEmpty()) {
            Map<String, Object> cfrRtNamesMap = (Map<String, Object>) JSON.deserializeUntyped(staticResources[0].Body.toString());
            List<Object> cfrRtNamesUntyped = (List<Object>) cfrRtNamesMap.get(name);
            for (Object cfrRtName : cfrRtNamesUntyped) {
                recordtypeNamesSet.add((String) cfrRtName);
            }
        }

        return recordtypeNamesSet;
    }
}