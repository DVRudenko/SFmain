public with sharing class PPR_Mapping_Utils {
    private static final StaticResource pprApiResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PPR_API_Mapping' LIMIT 1];

    public static final Map<String, Object> customerStatusMap {
        get {
            return (Map<String, Object>) pprApiMap.get('CustomerStatus');
        }
        private set;
    }

    public static final Map<String, Object> pprApiMap {
        get {
            return (Map<String, Object>) JSON.deserializeUntyped(PPR_Mapping_Utils.pprApiResource.Body.toString());
        }
        private set;
    }

    public static Map<String, Object> getValidationMap(String validationName) {
        return (Map<String, Object>) pprApiMap.get(validationName);
    }
}