/**
 * Created by A.Syromyatnikov on 5/19/2020.
 */

@IsTest
public with sharing class PPRProductSettingsUtilsTest {

    @IsTest
    private static void getProductSettingsTest(){
        Map<String, Object> product = PPRProductSettingsUtils.getProductSettings(
                GlobalUtils.E2EProduct.PetrolPlus_Rover.name()
        );
        System.assert(!product.isEmpty());
        System.assert(product.get('mzkId') != null);
        System.assert(product.get('reportId') != null);
    }

    @IsTest
    private static void getTariffSettingsTest(){
        Map<String, Object> tariff = PPRProductSettingsUtils.getTariffSettings(
                GlobalUtils.E2EProduct.PetrolPlus_Rover.name(),
                'OPTIMAL_CARDS'
        );
        System.assert(!tariff.isEmpty());
        System.assert(tariff.get('transitId') != null);
        System.assert(tariff.get('reportId') != null);
    }

    @IsTest
    private static void getMappingTest(){
        Map<String, Object> mapping = PPRProductSettingsUtils.getMapping();
        System.assertNotEquals(null, mapping);
    }

    @IsTest
    private static void getTariffMappingTest(){
        Map<String, Object> settings = (Map<String, Object>) JSON.deserializeUntyped(
            ([
                    SELECT Body
                    FROM StaticResource
                    WHERE Name = 'PPRProductSettings'
                    LIMIT 1
            ]).Body.toString()
        );
        Map<String, Object> tariffSettings = (Map<String, Object>) settings.get('mapping');
        String tariffKey = new List<String>(tariffSettings.keySet())[0];
        Map<String, Object> selectedTariff = (Map<String, Object>) tariffSettings.get(tariffKey);

        Map<String, Object> tariff = PPRProductSettingsUtils.getTariffMapping(tariffKey);
        System.assertEquals(selectedTariff.get('tariff'), tariff.get('tariff'));
        System.assertEquals(selectedTariff.get('product'), tariff.get('product'));
    }
}