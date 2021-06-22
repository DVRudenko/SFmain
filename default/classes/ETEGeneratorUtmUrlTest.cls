@isTest
private with sharing class ETEGeneratorUtmUrlTest {

    @TestSetup
    static void initData() {

        ETEUtilsTest.createE2EApiKeys('E2EForm');
        ETEUtilsTest.createE2EApiKeys('E2EFormPL');

        RecordType fleetcorRt = [SELECT Id FROM RecordType WHERE Name = 'FLEETCOR'];

        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'offerName1',
                Family = 'Lotos',
                RecordTypeId = fleetcorRt.Id,
                IsActive = true,
                Available_for_E2E__c = true,
                Integration_Name__c = 'integrationtestname1',
                Country__c = 'Poland'
            ),
            new Product2(
                Name = 'offerName2',
                Family = 'SHELL',
                RecordTypeId = fleetcorRt.Id,
                IsActive = false,
                Available_for_E2E__c = false,
                Integration_Name__c = 'integrationtestname2',
                Country__c = 'Germany'
            ),
            new Product2(
                Name = 'offerName3',
                Family = 'SHELL',
                RecordTypeId = fleetcorRt.Id,
                IsActive = true,
                Available_for_E2E__c = true,
                Integration_Name__c = 'integrationtestname3',
                Country__c = 'Germany'
            ),
            new Product2(
                Name = 'offerName4',
                Family = 'SHELL',
                RecordTypeId = fleetcorRt.Id,
                IsActive = true,
                Available_for_E2E__c = true,
                Integration_Name__c = 'integrationtestname4',
                Country__c = 'Germany'
            )
        };

        insert products;
    }

    @isTest
    static void selectProductsTest() {
        List<Product2> products = ETEGeneratorUtmUrl.getActiveForEteProduct();
        System.assertEquals(3, products.size());
        System.assertEquals('offerName1', products.get(0).Name);
        System.assertEquals('offerName3', products.get(1).Name);
    }

    @isTest
    static void generateLinkByProductsTest() {
        String link = ETEGeneratorUtmUrl.generateLink('integrationtestname3;integrationtestname4', 'Germany', 'Germany');

        String countryCode = ETEGlobalUtils.returnTwoLettersCountry('Germany');
        String domainPart = ETEGlobalUtils.returnSiteUrl(countryCode);
        String urlPath = ETEGlobalUtils.returnUrlPath('Germany').getUrl();

        String baseLink = link.substringBefore( '?'+ ETEGeneratorUtmUrl.UTM_GET_KEY +'=');
        String linkEncryptedSource = link.substringAfter( ETEGeneratorUtmUrl.UTM_GET_KEY + '=');
        String decodedLink =  ETEGlobalUtils.doDecryptParams(linkEncryptedSource, countryCode);

        System.assertEquals(domainPart + urlPath, baseLink);
        System.assertEquals('integrationtestname3;integrationtestname4', decodedLink);
    }
}
