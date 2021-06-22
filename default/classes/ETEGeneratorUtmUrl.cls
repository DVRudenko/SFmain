public with sharing class ETEGeneratorUtmUrl {

    public final static String UTM_GET_KEY = 'utm_products';

    @AuraEnabled(cacheable = true)
    public static List<Product2> getActiveForEteProduct(){
        return [
            SELECT Id, Name, Family, Country__c, Integration_Name__c 
            FROM Product2 
            WHERE IsActive = true AND Available_for_E2E__c = true
        ];
    }

    @AuraEnabled
    public static String generateLink(String productsIntNames, String country, String implKey){

        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);
        String domainPart = ETEGlobalUtils.returnSiteUrl(countryCode);
        String urlPath = ETEGlobalUtils.returnUrlPath(implKey).getUrl();
        String triedPart = ETEGlobalUtils.doEncryptParams(productsIntNames, countryCode);
        String link = domainPart + urlPath + '?' + ETEGeneratorUtmUrl.UTM_GET_KEY + '=' + triedPart;

        return link;
    }
}
