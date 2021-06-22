@IsTest
public with sharing class MZKRequestSettingUtilsTest {

    @IsTest
    private static void getProductSettingsTest(){
        Map<String, Object> product = MZKRequestSettingUtils.getProductSettings();
        System.assert(!product.isEmpty());
        System.assertNotEquals(product.get('PPR'), null);
        System.assertNotEquals(product.get('GPC'), null);
    }

    @IsTest
    private static void getProductResourceTest(){
        Map<String, Object> product = MZKRequestSettingUtils.getProductResource();
        System.assert(!product.isEmpty());
    }

}