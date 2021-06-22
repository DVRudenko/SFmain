public class ETEMultiProductCcsImpl extends ETEMultiProductBaseImpl {

    private Map<String, Object> TRANSLATIONS;

    public override ETEMultiProductResponse getProducts (Map<String, String> params) {
        this.response = new ETEMultiProductResponse();
        try {
            setParamsFromUserModel(params);
            this.TRANSLATIONS = new Map<String, Object>();
            List<Product2> products = getAvailableProducts();
            Map<String, Object> offersTypesMap = new Map<String, Object>();

            for (Product2 product : products) {
                Offer_to_Item_Type_Junction__c jOfferItemType = product.Offer_to_Item_Type_Junctions__r.get(0);
                String offerTypeIntegrationName = jOfferItemType.Offer_Item_Type__r.Integration_Name__c;
                Map<String, Object> offerType;

                if (!offersTypesMap.containsKey(offerTypeIntegrationName)) {
                    offerType = getOfferTypeModel(jOfferItemType);
                    offersTypesMap.put(offerTypeIntegrationName, offerType);
                } else {
                    offerType = (Map<String,Object>) offersTypesMap.get(offerTypeIntegrationName);
                }

                Map<String, Object> productModel = getProductModel(product);
                String defaultOfferIntagrationName = (String) offerType.get('defaultOfferIntagrationName');
                productModel.put('selected', product.Integration_Name__c == defaultOfferIntagrationName);

                List<Map<String, Object>> offers = (List<Map<String, Object>>) offerType.get('offers');
                offers.add(productModel);
            }

            Map<String, Object> resultMap = new Map<String, Object>{
                    'translations' => this.TRANSLATIONS,
                    'offerTypes' => offersTypesMap.values()
            };
            Object result = addModStampInResourcePath(resultMap);
            this.response
                .setStatusCode(ETEMultiProductRest.STATUS_CODE_SUCCESS)
                .setData(result);
        } catch (Exception e) {
            this.response
                .setStatusCode(ETEMultiProductRest.STATUS_CODE_PAGE_NOT_FOUND)
                .setData(e.getMessage() + e.getStackTraceString());
            return this.response;
        }
        return this.response;
    }

    public override ETEMultiProductResponse getOrder (Map<String, String> params) {
        this.response = new ETEMultiProductResponse();
        try {
            this.TRANSLATIONS = new Map<String, Object>();
            this.setParamsFromUserModel(params);
            String dataId = ETEGlobalUtils.doDecryptParams(this.source, this.countryCode);
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(this.countryCode);
            Map<String, E2E_Data_Product__c> productsMap = e2eDatabase.retrieveETEProducts(dataId);
            Map<String, E2E_Data_Offer_Item__c> itemsMap = e2eDatabase.retrieveETEOfferItems(productsMap.keySet());

            Map<String, Integer> productDataCountsMap = new Map<String, Integer>();
            for (String key : itemsMap.keySet()) {
                E2E_Data_Offer_Item__c offerItem = itemsMap.get(key);
                if(productDataCountsMap.containsKey(offerItem.E2E_Data_Product__c)){
                    Integer count = productDataCountsMap.remove(offerItem.E2E_Data_Product__c) + 1;
                    productDataCountsMap.put(offerItem.E2E_Data_Product__c, count);
                }else{
                    productDataCountsMap.put(offerItem.E2E_Data_Product__c, 1);
                }
            }

            Map<String, Integer> productsCountsMap = new Map<String, Integer>();
            for (E2E_Data_Product__c dataProduct : productsMap.values()) {
                productsCountsMap.put(
                    dataProduct.ProductID__c,
                    productDataCountsMap.get(dataProduct.Id)
                );
            }

            List<Product2> products = [
                SELECT  Name, Family, Integration_Name__c, CurrencyIsoCode,
                        (SELECT Offer_Item_Type__r.Name, Offer_Item_Type__r.Integration_Name__c FROM Offer_to_Item_Type_Junctions__r LIMIT 1)
                FROM    Product2
                WHERE   Available_for_E2E__c = TRUE AND
                        IsActive = TRUE AND
                        Id IN : productsCountsMap.keySet()
            ];

            Map<String, Object> offersTypesMap = new Map<String, Object>();

            for (Product2 product : products) {
                Offer_to_Item_Type_Junction__c jOfferItemType = product.Offer_to_Item_Type_Junctions__r.get(0);
                String offerTypeIntegrationName = jOfferItemType.Offer_Item_Type__r.Integration_Name__c;
                Map<String, Object> offerType;

                if(!offersTypesMap.containsKey(offerTypeIntegrationName)) {
                    offerType = new Map<String, Object>{
                        'name' => jOfferItemType.Offer_Item_Type__r.Name,
                        'integrationName' => jOfferItemType.Offer_Item_Type__r.Integration_Name__c,
                        'count' => productsCountsMap.get(product.Id)
                    };
                    offerType = this.initOfferTypeResources(offerType);
                    this.addSingleTranslationForModel(offerType, this.TRANSLATIONS, 'description');
                    this.addSingleTranslationForModel(offerType, this.TRANSLATIONS, 'title');
                    offersTypesMap.put(offerTypeIntegrationName, offerType);
                }
            }

            Map<String,Object> resultMap = new Map<String,Object>{
                'translations' => this.TRANSLATIONS,
                'offersTypes' => offersTypesMap.values()
            };
            Object result = addModStampInResourcePath(resultMap);
            this.response
                .setStatusCode(ETEMultiProductRest.STATUS_CODE_SUCCESS)
                .setData(result);
        } catch (Exception e) {
            this.response
                .setStatusCode(ETEMultiProductRest.STATUS_CODE_PAGE_NOT_FOUND)
                .setData(e.getMessage() + e.getStackTraceString());
            return this.response;
        }
        return this.response;
    }

    private Map<String, Object> initOfferTypeResources (Map<String, Object> offerType) {
        String offerTypeIntegrationName = (String) offerType.get('integrationName');
        Map<String, Object> oitResourceMap = getResourceContentMap('ETE_MP_OITS', offerTypeIntegrationName);
        offerType.put('title', oitResourceMap.get('title'));
        offerType.put('description', oitResourceMap.get('description'));
        offerType.put('image', oitResourceMap.get('image'));
        offerType.put('imagePath', oitResourceMap.get('image_path'));
        return offerType;
    }


    private Map<String, Object> getProductModel (Product2 product) {
        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(product.Country__c);
        Offer_to_Item_Type_Junction__c typeJunction = product.Offer_to_Item_Type_Junctions__r.get(0);
        String encodedProductId = ETEGlobalUtils.doEncryptParams(product.Id, countryCode);
        String encodedOfferItemTypeId = ETEGlobalUtils.doEncryptParams(typeJunction.Offer_Item_Type__c, countryCode);
        Map<String, Object> productModel = new Map<String, Object>{
            'id' => encodedProductId,
            'offerTypeId' => encodedOfferItemTypeId,
            'name' => product.Name,
            'family' => product.Family,
            'integrationName' => product.Integration_Name__c,
            'currencyIsoCode' => product.CurrencyIsoCode,
            'fleetcorOffer' => 'fleetcorOffer' + product.Integration_Name__c,
            'selected' => false,
            'userItems' => new List<Object>(),
            'settings' => new Map<String, Object>()
        };
        Map<String, Object> productResourceMap = getResourceContentMap('ETE_MP_OFFERS', product.Integration_Name__c);
        productModel.putAll(productResourceMap);
        addSingleTranslationForModel(productModel, TRANSLATIONS, 'title');
        addSingleTranslationForModel(productModel, TRANSLATIONS, 'description');
        addListTranslationForModel(productModel, TRANSLATIONS, 'promos', null);

        // set information about fees
        List<Object> fees = getFeesAndAddTranslationsForThem(product, TRANSLATIONS);
        productModel.put('fees', fees);
        return productModel;
    }


    private Map<String, Object> getOfferTypeModel (Offer_to_Item_Type_Junction__c jOfferItemType) {
        String countryCode = ETEGlobalUtils.getCountryCodeByImplKey(implKey);
        String encodedId = ETEGlobalUtils.doEncryptParams(jOfferItemType.Offer_Item_Type__r.Id, countryCode);
        Map<String, Object> offerTypeModel = new Map<String, Object>{
            'id' => encodedId,
            'name' => jOfferItemType.Offer_Item_Type__r.Name,
            'integrationName' => jOfferItemType.Offer_Item_Type__r.Integration_Name__c,
            'settings' => new Map<String, Object>(),
            'offers' => new List<Map<String, Object>>()
        };
        Map<String, Object> offerTypeResourceMap = getResourceContentMap('ETE_MP_OITS', jOfferItemType.Offer_Item_Type__r.Integration_Name__c);
        offerTypeModel.putAll(offerTypeResourceMap);
        addSingleTranslationForModel(offerTypeModel, TRANSLATIONS, 'title');
        addSingleTranslationForModel(offerTypeModel, TRANSLATIONS, 'description');
        addListTranslationForModel(offerTypeModel, TRANSLATIONS, 'categoryOfProducts', new Set<String>{'label', 'description'});
        addListTranslationForModel(offerTypeModel, TRANSLATIONS, 'services', new Set<String>{'label'});
        return offerTypeModel;
    }
}