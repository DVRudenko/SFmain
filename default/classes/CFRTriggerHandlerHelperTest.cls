@IsTest
private class CFRTriggerHandlerHelperTest {

    @IsTest
    private static void testGetRecordTypesSetting() {
        CFRTriggerHandlerHelper helper = new CFRTriggerHandlerHelper();
        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Credit_Factory_Report__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        for (String recordType : helper.getRecordTypesSetting(CFRTriggerHandlerHelper.RT_FOR_CHANGE_OWNER)) {
            System.assert(recordTypeInfoMap.get(recordType).active);
        }
    }

}