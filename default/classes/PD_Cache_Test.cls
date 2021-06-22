/**
 * Created by pgolyakov on 2019-07-25.
 */
@isTest
private class PD_Cache_Test {

    @isTest static void test_get() {
        PD_Cache__c cach = new PD_Cache__c(Value2__c = 'value', key__c = 'key');
        insert cach;
        system.assertEquals('value', PD_Cache.get('key'));
    }

    @isTest static void test_empty() {
        system.assertEquals(null, PD_Cache.get('key'));
    }

}