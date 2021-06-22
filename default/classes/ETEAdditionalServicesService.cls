public without sharing class ETEAdditionalServicesService {

    public static String generateJSONResponseBody(List<Offer_Additional_Service__c> servicesList) {
        Map<String, Offer_Additional_Service__c> serviceByStaticNameMap = convertToMap(servicesList);
        List<StaticResource> resourcesList = selectStaticRecources(serviceByStaticNameMap.keySet());
        
        if (serviceByStaticNameMap.size() != resourcesList.size()) {
            throw new ETERestException('No static resources for selected services.');
        }

        Map<String, Object> content = new Map<String, Object>();
        List<Object> settings = new List<Object>();

        for (StaticResource res : resourcesList) {
            String bodyStr = res.Body.toString();
            Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(bodyStr);
            Offer_Additional_Service__c additionalService = serviceByStaticNameMap.get(normalizeString(res.Name));
            Map<String, Object> nextContent = applyIntegrationNameToContent(bodyMap.get('translations'), additionalService);
            Object nextSettings = applyIntegrationNameToSettings(bodyMap.get('settings'), additionalService);
            content.putAll(nextContent);
            settings.add(nextSettings);
        }
        
        return JSON.serialize(new Map<String, Object>{
            'additionalServicesSettings' => settings,
            'additionalServicesContent' => content
        });
    }


    public static List<Offer_Additional_Service__c> selectAdditionalServices(Map<String, Object> requestParams) {
        String countryCode = (String) requestParams.get('countryCode');
        String source = (String) requestParams.get('source');
        String country = getCountry(countryCode);
        String dataId = ETEGlobalUtils.doDecryptParams(source, countryCode);

        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        List<Offer_Additional_Service__c> servicesList = new List<Offer_Additional_Service__c>();
        Set<String> productIds = new Set<String>();

        if (dataId != null) {
            Map<String, E2E_Data_Product__c> productsMap = e2eDatabase.retrieveETEProducts(dataId);
            for (E2E_Data_Product__c product : productsMap.values()) {
                productIds.add(product.ProductID__c);
            }
        }
        for (Product2 nextProduct: selectProducts(country, productIds)) {
            servicesList.addAll(nextProduct.Offer_Additional_Services__r);
        }
        return servicesList;
    }

    
    private static Object applyIntegrationNameToSettings(Object settingsObj, Offer_Additional_Service__c additionalService) {
        Map<String, Object> deserializedJson = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(settingsObj));
        Map<String, Object> result = new Map<String, Object>();
        String prefix = additionalService.Additional_Service__r.Integration_Name__c;

        if (deserializedJson.get('show_more').toString() == 'true') {
            result.put('more_information', prefix + '_more_information');
        }
        if (deserializedJson.get('show_checkbox_1').toString() == 'true') {
            result.put('additional_checkbox_1', prefix + '_additional_checkbox_1');
        }
        if (deserializedJson.get('show_checkbox_2').toString() == 'true') {
            result.put('additional_checkbox_2', prefix + '_additional_checkbox_2');
        }

        result.put('id', prefix);
        result.put('title', prefix + '_title');
        result.put('description', prefix + '_description');
        result.put('bgImage', deserializedJson.get('bgImage').toString());
        result.put('selected', String.valueOf(additionalService.State__c == 'Optional Preselected'));
        result.put('value', String.valueOf(additionalService.Value__c));
        result.put('valueType', String.valueOf(additionalService.Value_Type__c));
        result.put('showCheckbox', 'true');
        return result;
    }


    private static Map<String, Object> applyIntegrationNameToContent(Object contentObj, Offer_Additional_Service__c additionalService) {
        Map<String, Object> deserializedJson = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(contentObj));
        Map<String, Object> result = new Map<String, Object>();
        for (String key : deserializedJson.keySet()) {
            String newKey = additionalService.Additional_Service__r.Integration_Name__c + '_' + key;
            result.put(newKey, deserializedJson.get(key));
        }
        return result;
    }


    public static Map<String, Offer_Additional_Service__c> convertToMap (List<Offer_Additional_Service__c> servicesList) {
        Map<String, Offer_Additional_Service__c> serviceByStaticNameMap = new Map<String, Offer_Additional_Service__c>();
        for (Offer_Additional_Service__c service : servicesList) {
            serviceByStaticNameMap.put(normalizeString('ETE_MP_AS_' + service.Additional_Service__r.Integration_Name__c), service);
        }
        return serviceByStaticNameMap;
    }


    private static String normalizeString (String str) {
        return str.toUpperCase();
    }


    private static String getCountry (String countryCode) {
        String country = ETEGlobalUtils.returnCountry(countryCode);
        if ( country == null ) {
            throw new ETERestException('Invalid country parameter');
        }
        return country;
    }


    public static List<StaticResource> selectStaticRecources (Set<String> staticNames) {
        return [
                SELECT  Body, Name
                FROM    StaticResource
                WHERE   Name IN : staticNames
        ];
    }
    

    public static List<Product2> selectProducts (String country, Set<String> productIds) {
        
        if (country != null && country.contains('-')) {
            country = '%' + country.substringBefore('-') + '%';
        }

        if (productIds.isEmpty()) {
            return [
                    SELECT  Name, Family, Integration_Name__c, Country__c, CurrencyIsoCode,
                            (SELECT State__c, Value__c, Value_Type__c, 
                                Additional_Service__r.Name, Additional_Service__r.Type__c, 
                                Additional_Service__r.Amount__c, Additional_Service__r.Integration_Name__c
                                FROM Offer_Additional_Services__r 
                                WHERE Additional_Service__r.Active__c = true)
                    FROM    Product2
                    WHERE   Available_for_E2E__c = TRUE AND
                            Country__c LIKE :country AND
                            IsActive = TRUE
            ];
        } else {
            return [
                    SELECT  Name, Family, Integration_Name__c, Country__c, CurrencyIsoCode,
                            (SELECT State__c, Value__c, Value_Type__c,
                                Additional_Service__r.Name, Additional_Service__r.Type__c, 
                                Additional_Service__r.Amount__c, Additional_Service__r.Integration_Name__c 
                                FROM Offer_Additional_Services__r 
                                WHERE Additional_Service__r.Active__c = true)
                    FROM    Product2
                    WHERE   Available_for_E2E__c = TRUE AND
                            Country__c LIKE :country AND
                            IsActive = TRUE AND
                            Id IN : productIds
            ];
        }
        
    }
    

    public class ETERestException extends Exception {}
}
