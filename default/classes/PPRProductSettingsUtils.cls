/**
 * Created by A.Syromyatnikov on 5/17/2020.
 */

public with sharing class PPRProductSettingsUtils {

    private static Map<String, Object> resource = (Map<String, Object>) JSON.deserializeUntyped(
            ([
                    SELECT Body
                    FROM StaticResource
                    WHERE Name = 'PPRProductSettings'
                    LIMIT 1
            ]).Body.toString()
    );

    public static Map<String, Object> getProductSettings(String product) {
        return (Map<String, Object>) ((Map<String, Object>) resource.get('settings')).get(product);
    }

    public static Map<String, Object> getTariffSettings(String product, String tariff) {
        return (Map<String, Object>) getProductSettings(product).get(tariff);
    }

    public static Map<String, Object> getMapping() {
        return (Map<String, Object>) resource.get('mapping');
    }

    public static Map<String, Object> getTariffMapping(String tariffLabel) {
        return (Map<String, Object>) getMapping().get(tariffLabel);
    }

}