public class PD_Cache {
    public static String get(String key) {
        PD_Cache__c[] caches = [select Value__c, Value2__c  from PD_Cache__c where key__c = :key];
        if (caches.size() == 0) {
            return null;
        }
        return caches[0].Value2__c;
    }
}