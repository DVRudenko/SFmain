public virtual class ETEMultiProductBaseImpl implements ETEMultiProductInterface {

    protected String implKey;
    protected String source;
    protected String countryCode;
    protected String utmProducts;
    protected String finalVariant;
    protected ETEMultiProductResponse response;
    private Map<String, Map<String, Object>> resourcesMap = new Map<String, Map<String, Object>>();

    public virtual ETEMultiProductResponse getProducts (Map<String, String> params) {
        response = new ETEMultiProductResponse();
        try {
            setParamsFromUserModel(params);
            List<Product2> products = getAvailableProducts();
            List<Map<String, Object>> resultList = new List<Map<String, Object>>();
            for (Product2 product : products) {
                Map<String, Object> productModel = getProductModel(product);
                resultList.add(productModel);
            }
            Object result = addModStampInResourcePath(resultList);
            response.setStatusCode(ETEMultiProductRest.STATUS_CODE_SUCCESS);
            response.setData(result);
        } catch (Exception e) {
            response.setStatusCode(ETEMultiProductRest.STATUS_CODE_PAGE_NOT_FOUND);
            response.setData(e.getMessage() + e.getStackTraceString());
            return response;
        }
        return response;
    }

    public virtual ETEMultiProductResponse getOrder (Map<String, String> params) {
        response = new ETEMultiProductResponse();
        try {
            setParamsFromUserModel(params);
            String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
            List<E2E_Data_Product__c> dataProducts = new List<E2E_Data_Product__c>();
            if (String.isNotEmpty(dataObjectId)) {
                dataProducts = [
                        SELECT  Name, RecordType.Name, ProductID__c, Type_Name__c, Type_ID__c,
                                (SELECT Id FROM E2E_Data_Offer_Items__r),
                                (SELECT Name, RecordType.Name, Brand__c, ESI__c FROM E2E_Data_Locator_Items__r)
                        FROM    E2E_Data_Product__c
                        WHERE   E2E_Data_Object__c =: dataObjectId
                ];
            }
            
            Set<String> productsIds = new Set<String>();
            Map<String, E2E_Data_Product__c> dataProductByProductIdMap = new Map<String, E2E_Data_Product__c>();
            for (E2E_Data_Product__c dataProduct : dataProducts) {
                productsIds.add(dataProduct.ProductID__c);
                dataProductByProductIdMap.put(dataProduct.ProductID__c, dataProduct);
            }
        
            List<Product2> products = [
                    SELECT  Integration_Name__c
                    FROM    Product2
                    WHERE   Id IN : productsIds
            ];
        
            Map<String, Object> translations = new Map<String, Object>();
            Map<String, Map<String, Object>> orderModelByIntegrationName = new Map<String, Map<String, Object>>();
            for (Product2 nextProduct : products) {
                Map<String, Object> orderModel = getOrderModel(nextProduct, dataProductByProductIdMap.get(nextProduct.Id), translations);
                orderModelByIntegrationName.put(nextProduct.Integration_Name__c, orderModel);
            }
        
            Map<String, Object> resultMap = new Map<String, Object>{
                'content' => translations,
                'order' => orderModelByIntegrationName.values()
            };
            Object result = addModStampInResourcePath(resultMap);
            response.setStatusCode(ETEMultiProductRest.STATUS_CODE_SUCCESS);
            response.setData(result);
        } catch (Exception e) {
            response.setStatusCode(ETEMultiProductRest.STATUS_CODE_PAGE_NOT_FOUND);
            response.setData(e.getMessage() + e.getStackTraceString());
            return response;
        }
        return response;
    }

    public virtual Object getCheckoutData (Map<String, String> params) {
        setParamsFromUserModel(params);
        Map<String, Object> result = new Map<String, Object>();
        String dataId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        Map<String, E2E_Data_Product__c> productsMap = e2eDatabase.retrieveETEProducts(dataId);
        Map<String, Object> feeTypesToLangMap = getResourceContentMap('ETE_MP_fee_types', null);
        Opportunity opp = e2eDatabase.retrieveOpportunity(dataId);
        Quote quote = e2eDatabase.retrieveOpportunityQuote(opp.Id);
        Set<String> productIds = new Set<String>();
        if (quote != null) {
            for (QuoteLineItem nextQuoteLineItem : quote.QuoteLineItems) {
                productIds.add(nextQuoteLineItem.Product2Id);
            }
        } else {
            for (E2E_Data_Product__c product : productsMap.values()) {
                productIds.add(product.ProductID__c);
            }
        }
    
        List<Product2> products = [
                SELECT  Name, Family, Integration_Name__c, Country__c, CurrencyIsoCode,
                        (SELECT Value__c, Fee_Type__c, Value_Type__c, CurrencyIsoCode FROM Fees__r WHERE Display_for_E2E__c = TRUE ORDER BY Order__c)
                FROM    Product2
                WHERE   Id IN : productIds
        ];
    
        Map<String, Map<String, Object>> offerResourceNameToDataMap = new Map<String, Map<String, Object>>();
        Decimal payForProducts = 0;
        for (Product2 nextProduct : products) {
            String resourceName = 'ETE_MP_OFFER_' + nextProduct.Integration_Name__c;
            if (!offerResourceNameToDataMap.containsKey(resourceName)) {
                offerResourceNameToDataMap.put(resourceName, new Map<String, Object>());
            }

            if (quote != null) {
                for (QuoteLineItem nextQuoteLineItem : quote.QuoteLineItems) {
                    if (nextProduct.Id ==  nextQuoteLineItem.Product2Id) {
                        Decimal totalWithTax = nextQuoteLineItem.TotalPrice + nextQuoteLineItem.TotalPrice * nextQuoteLineItem.Vat__c / 100;
                        payForProducts = payForProducts + totalWithTax;
                        offerResourceNameToDataMap.get(resourceName).put('count', nextQuoteLineItem.Quantity);
                        offerResourceNameToDataMap.get(resourceName).put('total', nextQuoteLineItem.TotalPrice);
                        offerResourceNameToDataMap.get(resourceName).put('totalWithTax', totalWithTax);
                        offerResourceNameToDataMap.get(resourceName).put('vat', nextQuoteLineItem.Vat__c);
                    }
                }
            } else {
                Integer count = 0;
                for (E2E_Data_Product__c e2eProduct : productsMap.values()) {
                    if (nextProduct.Id == e2eProduct.ProductID__c) {
                        count += 1;
                    }
                }
                offerResourceNameToDataMap.get(resourceName).put('count', count);
                offerResourceNameToDataMap.get(resourceName).put('total', '0');//TODO take from Product Line Item
                offerResourceNameToDataMap.get(resourceName).put('vat', '0');//TODO take from Product Line Item
            }


            List<Object> tariffList = new List<Object>();
            for (Fee__c fee : nextProduct.Fees__r) {
                Map<String, String> valuesMap = new Map<String, String>();
                Map<String, String> labelsMap = new Map<String, String>();
                Map<String, Object> feeTypeLangs = (Map<String, Object>)feeTypesToLangMap.get(fee.Fee_Type__c);
                if (feeTypeLangs != null && feeTypeLangs.containsKey('en')) {
                    for (String nextLang : feeTypeLangs.keySet()) {
                        labelsMap.put(nextLang, (String) feeTypeLangs.get(nextLang));
                        if (String.isEmpty(fee.Value__c) || fee.Value__c == '0') {
                            valuesMap.put(nextLang, freeTranslations().get(nextLang));
                        } else if (fee.Value_Type__c == 'Amount') {
                            String isoCodeForLang = currencyCodes().get(nextProduct.CurrencyIsoCode);
                            String isoValue = fee.Value__c + ' ';
                            isoValue += nextLang == 'en' || isoCodeForLang == null ? nextProduct.CurrencyIsoCode : isoCodeForLang;
                            valuesMap.put(nextLang, isoValue);
                        } else if (fee.Value_Type__c == 'Percentage') {
                            valuesMap.put(nextLang, fee.Value__c + '%');
                        } else {
                            String elseValue = fee.Value__c;
                            if (nextLang == 'en') {
                                for (String key : feesReplacemets().keySet()) {
                                    elseValue = elseValue.replace(key, feesReplacemets().get(key));
                                }
                            }
                            valuesMap.put(nextLang, elseValue);
                        }
                    }

                    tariffList.add(new Map<String, Object>{
                            'value' => valuesMap,
                            'label' => labelsMap
                    });
                }
            }
            offerResourceNameToDataMap.get(resourceName).put('tariffs', tariffList);
        }
    
        List<StaticResource> offerContents = [
                SELECT  Body, Name
                FROM    StaticResource
                WHERE   Name IN : offerResourceNameToDataMap.keySet()
        ];
    
        List<Object> orders = new List<Object>();
        for (StaticResource res : offerContents) {
            Map<String, Object> offerDataMap = offerResourceNameToDataMap.get(res.Name);
            Map<String, Object> contentMap = (Map<String, Object>) JSON.deserializeUntyped(res.Body.toString());
            List<Object> promos = (List<Object>) contentMap.get('promo');
            List<Object> tariffs = (List<Object>) offerDataMap.get('tariffs');
            promos.addAll(tariffs);
            Map<String, Object> order = new Map<String, Object>();
            order.put('quantity', offerDataMap.get('count'));
            order.put('total', offerDataMap.get('total'));
            order.put('totalWithTax', offerDataMap.get('totalWithTax'));
            order.put('vat', offerDataMap.get('vat'));
            order.put('tariffs', promos);
            order.put('title', contentMap.get('offerTitle'));
            order.put('image', contentMap.get('offerPreviewImage'));
            order.put('offerName', contentMap.get('offerName'));
            orders.add(order);
        }
        result.put('products', orders);


        // prepare information about Selected Additional services
        List<E2E_Data_Additional_Service__c> additionalServicesList = e2eDatabase.retrieveSelectedAdditionalServices(dataId);
        if (!additionalServicesList.isEmpty()) {
            List<String> listNamesOfStaticResourcesForAS = new List<String>();
            for (E2E_Data_Additional_Service__c nextAdditionalService : additionalServicesList) {
                listNamesOfStaticResourcesForAS.add(this.normalizeString('ETE_MP_AS_' + nextAdditionalService.Name));
            }

            List<StaticResource> additionalServicesStaticResources = [
                    SELECT  Body, Name
                    FROM    StaticResource
                    WHERE   Name IN : listNamesOfStaticResourcesForAS
            ];

            List<Object> additionalServices = new List<Object>();
            for (StaticResource res : additionalServicesStaticResources) {
                Map<String, Object> contentMap = (Map<String, Object>) JSON.deserializeUntyped(res.Body.toString());
                Map<String, Object> translationsMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(contentMap.get('translations')));
                Map<String, Object> settingsMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(contentMap.get('settings')));
                Map<String, Object> additionalServiceMap = new Map<String, Object>();
                additionalServiceMap.put('title', translationsMap.get('title'));
                additionalServiceMap.put('description', translationsMap.get('description'));
                additionalServiceMap.put('image', settingsMap.get('bgImage'));
                additionalServiceMap.put('amount', '0'); //TODO
                additionalServices.add(additionalServiceMap);
            }
            result.put('additionalServices', additionalServices);
        }

        // prepare information about creditLimit
        Decimal securityAmountToPay = opp.Security_Amount_To_Pay__c != null ? opp.Security_Amount_To_Pay__c : 0;
        if (opp.CF_Credit_Limit__c != null) {
            Map<String, Object> mapCreditLimit = new Map<String, Object>();
            mapCreditLimit.put('available', opp.CF_Credit_Limit__c);
            mapCreditLimit.put('deposit', securityAmountToPay);
            result.put('creditLimit', mapCreditLimit);
        }

        // calculate total
        Decimal grandTotal = quote != null ? quote.Grand_Total__c : 0;
        // Decimal total = securityAmountToPay + payForProducts;
        Decimal total = securityAmountToPay + grandTotal;
        result.put('total', total);

        return result;
    }


    protected void setParamsFromUserModel (Map<String, String> params) {
        if (params.containsKey('implKey')) {
            implKey = params.get('implKey');
            countryCode = ETEGlobalUtils.getCountryCodeByImplKey(implKey);
        }
        if (params.containsKey('source')) {
            source = params.get('source');
        }
        if (params.containsKey('utmProducts')) {
            utmProducts = params.get('utmProducts');
        }
        if (params.containsKey('finalVariant')) {
            finalVariant = params.get('finalVariant');
        }
    }


    protected String normalizeString (String str) {
        return str.toUpperCase();
    }


    protected Map<String, Object> getResourceContentMap (String resourceName, String fileName) {
        Map<String, Object> resourceObject = new Map<String, Object>();
        fileName = fileName == null ? '' : fileName + '.json';
        try {
            if (resourcesMap.containsKey(resourceName + fileName)) {
                resourceObject = resourcesMap.get(resourceName + fileName);
            } else {
                String jsonData = PageReference.forResource(resourceName, fileName).getContent().toString();
                Map<String, Object> jsonDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
                // select implementation for each param
                for (String key : jsonDataMap.keySet()) {
                    Map<String, Object> keyImpls = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(jsonDataMap.get(key)));
                    Object impl = keyImpls.containsKey(implKey) ? keyImpls.get(implKey) : keyImpls.get('default_impl');
                    resourceObject.put(key, impl);
                }
                // save result to avoid repeating of this operation
                resourcesMap.put(resourceName + fileName, resourceObject);
            }
        } catch (Exception e) {
            throw new ETERestException('No static resource for the next path: ' + resourceName + '/' + fileName);
        }
        return resourceObject;
    }


    protected List<Product2> getAvailableProducts () {
        List<Product2> products = new List<Product2>();
        if (utmProducts != null) {
            List<String> offersIntegrationNames = ETEGlobalUtils.doDecryptParams(utmProducts, countryCode).split(';');
            products = getProductsByIntegrationNames(offersIntegrationNames);
        }
        if (products.isEmpty()) {
            List<String> offersIntegrationNames = getBaseOfferItems();
            products = getProductsByIntegrationNames(offersIntegrationNames);
        }
        return products;
    }


    protected List<Product2> getProductsByIntegrationNames (List<String> offersIntegrationNames) {
        String country = ETEGlobalUtils.returnCountry(countryCode);
        country = country.contains('-') ? country.split('-').get(0) : country;
        return [
                SELECT  Name, Family, Integration_Name__c, Country__c, CurrencyIsoCode,
                        (SELECT Offer_Item_Type__r.Name, Offer_Item_Type__r.Integration_Name__c FROM Offer_to_Item_Type_Junctions__r LIMIT 1),
                        (SELECT Value__c, Fee__r.Fee_Type__c, Value_Type__c, CurrencyIsoCode, Order__c FROM FLEETCOR_Offer__r WHERE Display_For_E2E__c = TRUE ORDER BY Order__c)
                FROM    Product2
                WHERE   Available_for_E2E__c = TRUE AND
                        Country__c LIKE : country + '%' AND
                        IsActive = TRUE AND
                        (Expiration_Date__c = NULL OR Expiration_Date__c >= TODAY ) AND
                        Integration_Name__c IN : offersIntegrationNames
                        ORDER BY Name
        ];
    }


    protected List<String> getBaseOfferItems () {
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        Map<String, Object> untypedSettings = e2eDatabase.getSettings(implKey, countryCode);
        List<String> baseOfferItems = new List<String>();
        for (Object next: (List<Object>) untypedSettings.get('baseOfferItems')) {
            baseOfferItems.add(String.valueOf(next));
        }
        return baseOfferItems;
    }


    private Map<String, Object> getProductModel (Product2 product) {
        Map<String, Object> productResourceMap = getResourceContentMap('ETE_MP_OFFERS', product.Integration_Name__c);
        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(product.Country__c);
        Offer_to_Item_Type_Junction__c typeJunction = product.Offer_to_Item_Type_Junctions__r.get(0);
        String encodedProductId = ETEGlobalUtils.doEncryptParams(product.Id, countryCode);
        String encodedOfferItemTypeId = ETEGlobalUtils.doEncryptParams(typeJunction.Offer_Item_Type__c, countryCode);

        Map<String, Object> productModel = new Map<String, Object>{
            'product' => product.Family,
            'integrationName' => product.Integration_Name__c,
            'fleetcorOffer' => encodedProductId,
            'offerItemTypeName' => typeJunction.Offer_Item_Type__r.Name,
            'offerItemType' => encodedOfferItemTypeId,
            'currencyIsoCode' => product.CurrencyIsoCode,
            'promo' => productResourceMap.get('promo'),
            'offerName' => productResourceMap.get('offerName'),
            'cardTitle' => productResourceMap.get('cardTitle'),
            'offerPreviewImage' => productResourceMap.get('offerPreviewImage'),
            'offerSubTitle' => productResourceMap.get('offerSubTitle'),
            'offerTitle' => productResourceMap.get('offerTitle'),
            'settings' => productResourceMap.get('settings')
        };

        Map<String, Object> productTranslations = new Map<String, Object>();
        addSingleTranslationForModel(productModel, productTranslations, 'offerTitle');
        addSingleTranslationForModel(productModel, productTranslations, 'offerSubTitle');
        addSingleTranslationForModel(productModel, productTranslations, 'cardTitle');
        addListTranslationForModel(productModel, productTranslations, 'promo', null);

        // set information about fees
        List<Object> fees = getFeesAndAddTranslationsForThem(product, productTranslations);
        productModel.put('fees', fees);

        // set information about Offer Item Type
        Map<String, Object> oitResourceMap = getResourceContentMap('ETE_MP_OITS', product.Offer_to_Item_Type_Junctions__r.get(0).Offer_Item_Type__r.Integration_Name__c);
        if (oitResourceMap.containsKey('typeOfCard')) {
            productModel.put('typeOfCard', oitResourceMap.get('typeOfCard'));
            addListTranslationForModel(productModel, productTranslations, 'typeOfCard', new Set<String>{'label'});
        }
        if (oitResourceMap.containsKey('typeOfVehicle')) {
            productModel.put('typeOfVehicle', oitResourceMap.get('typeOfVehicle'));
            addListTranslationForModel(productModel, productTranslations, 'typeOfVehicle', new Set<String>{'label'});
        }
        productModel.put('translations', productTranslations);
        return productModel;
    }


    private Map<String, Object> getOrderModel (Product2 product, E2E_Data_Product__c dataProduct, Map<String, Object> translations) {
        Map<String, Object> productResourceMap = getResourceContentMap('ETE_MP_OFFERS', product.Integration_Name__c);
        Map<String, Object> orderModel = new Map<String, Object>{
            'integrationName' => product.Integration_Name__c,
            'offerName' => productResourceMap.get('offerName'),
            'offerTitle' => productResourceMap.get('offerTitle'),
            'description' => productResourceMap.get('offerSubTitle'),
            'title_multiple' => productResourceMap.get('offerTitleMoreOne'),
            'icon' => productResourceMap.get('offerPreviewImage'),
            'count' => dataProduct.E2E_Data_Offer_Items__r.size()
        };

        addSingleTranslationForModel(orderModel, translations, 'offerTitle');
        addSingleTranslationForModel(orderModel, translations, 'description');
        addSingleTranslationForModel(orderModel, translations, 'title_multiple');

        List<Object> firstTimeList = (List<Object>) productResourceMap.get('firstTime');
        List<Object> items = new List<Object>();
        for (Integer i = 0; i < firstTimeList.size(); i++) {
            String label = product.Integration_Name__c + '_firstTimeItem_' + i;
            translations.put(label, firstTimeList.get(i));
            items.add(label);
        }
        orderModel.put('items', items);
        return orderModel;
    }


    protected List<Object> getFeesAndAddTranslationsForThem (Product2 product, Map<String, Object> translations) {
        Map<String, Object> feeTypesContentMap = getResourceContentMap('ETE_MP_fee_types', null);
        List<Object> fees = new List<Object>();
        for (Offer_Fee__c offerFee : product.FLEETCOR_Offer__r) {
            String feeType = offerFee.Fee__r.Fee_Type__c;
            Map<String, Object> feeModel = new Map<String, Object>();
            feeModel.put('label', feeType);

            // if we don't have any translation, we will see an empty space on the form
            if (feeTypesContentMap.containsKey(feeType)) {
                //add translations for fee type (label)
                Map<String, Object> feeTypeTranslationMap = (Map<String, Object>) feeTypesContentMap.get(feeType);
                translations.put(feeType, feeTypeTranslationMap);

                //add translations for fee value
                String valueTranslationsKey = product.Integration_Name__c + '_' + feeType + '_' + offerFee.Order__c;
                if (offerFee.Value__c == null || offerFee.Value__c == '0') {
                    // fee_free translation stores in ETE_common_components_translations
                    feeModel.put('value', 'fee_free'); 
                } else {
                    Map<String, Object> feeTranslationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(feeTypeTranslationMap));
                    Map<String, String> valueTranslations = new Map<String, String>();
                    for (String nextLang : feeTranslationMap.keySet()) {
                        String valueTranslateForNextLang = '';
                        if (offerFee.Value_Type__c == 'Amount') {
                            String isoCode = product.CurrencyIsoCode;
                            Object currencyTranslate = nextLang != 'en' && currencyCodes().containsKey(isoCode) ? currencyCodes().get(isoCode) : isoCode;
                            valueTranslateForNextLang = offerFee.Value__c + ' ' + currencyTranslate;
                        } else if (offerFee.Value_Type__c == 'Percentage') {
                            valueTranslateForNextLang = offerFee.Value__c + ' %';
                        } else if (offerFee.Value_Type__c == 'Text') {
                            valueTranslateForNextLang = offerFee.Value__c;
                            if (nextLang == 'en') {
                                for (String key : feesReplacemets().keySet()) {
                                    valueTranslateForNextLang = valueTranslateForNextLang.replace(key, feesReplacemets().get(key));
                                }
                            }
                        }
                        valueTranslations.put(nextLang, valueTranslateForNextLang);
                    }
                    translations.put(valueTranslationsKey, valueTranslations);
                    feeModel.put('value', valueTranslationsKey);
                }
            }
            fees.add(feeModel);
        }
        return fees;
    }


    protected void addSingleTranslationForModel (Map<String, Object> model, Map<String, Object> translations, String modelKey) {
        String integrationName = (String) model.get('integrationName');
        translations.put(integrationName + '_' + modelKey, model.get(modelKey));
        model.put(modelKey, integrationName + '_' + modelKey);
    }
    

    protected void addListTranslationForModel (Map<String, Object> model, Map<String, Object> translations, String modelKey, Set<String> fieldsForProcessing) {
        List<Object> modelKeyList = (List<Object>) model.get(modelKey);
        List<Object> modelKeyListUpdated = new List<Object>();
        String integrationName = (String) model.get('integrationName');
        for (Integer i = 0; i < modelKeyList.size(); i++) {
            Map<String, Object> nextItemMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(modelKeyList.get(i)));
            for (String key : nextItemMap.keySet()) {
                if (fieldsForProcessing == null || fieldsForProcessing.contains(key)) {
                    String translationKey = integrationName + '_' + modelKey + '_' + key + '_' + i;
                    translations.put(translationKey, nextItemMap.get(key));
                    nextItemMap.put(key, translationKey);
                }
            }
            modelKeyListUpdated.add(nextItemMap);
        }
        model.put(modelKey, modelKeyListUpdated);
    }


    protected Object addModStampInResourcePath (Object obj) {
        String resultJson = JSON.serialize(obj);
        for (StaticResource next : [SELECT Name, SystemModstamp FROM StaticResource WHERE Name IN ('ete_images', 'ETE_DOCUMENTS_1', 'ETE_DOCUMENTS_2')]) {
            String path = '/resource/' + String.valueOf(((Datetime)next.get('SystemModStamp')).getTime()) + '/' + next.Name;
            resultJson = resultJson.replace('/resource/' + next.Name, path);
        }
        return JSON.deserializeUntyped(resultJson);
    }

    protected Map<String, String> freeTranslations() {
        return new Map<String, String>{
            'en' => 'FREE',
            'sk' => 'ZADARMO',
            'cs' => 'ZDARMA',
            'hu' => 'DÍJMENTES',
            'pl' => 'NIEPOBIERANA',
            'de' => 'KOSTENLOS',
            'nl' => 'GRATIS',
            'fr' => 'GRATUIT'
        };
    } 

    protected Map<String, String> currencyCodes() {
        return new Map<String, String>{
            'PLN' => 'ZŁ',
            'CZK' => 'Kč',
            'HUF' => 'Ft'
        };
    }

    protected Map<String, String> feesReplacemets() {
        return new Map<String, String> {
            'litr' => 'liter',
            '€' => 'EUR',
            'ZŁ/miesięcznie' => 'PLN/month',
            'ZŁ / MIESIĄC' => ' PLN / MONTH',
            'Kč / měsíc' => ' CZK / month',
            'ZŁ / 12 MIESIĘCY' => 'PLN / 12 MONTHS',
            'przez pierwsze 3 miesiące, 8 gr brutto od 4-go miesiąca' => 'for the first 3 months, 8 gr brutto/liter from 4th month',
            'przez pierwsze 6 miesięcy, 8 gr brutto od 7-go miesiąca' => 'for the first 6 months, 8 gr brutto/liter from 7th month',
            'KOSZTY ZALEŻĄ OD OPERATORA' => 'PRICES DEPEND ON THE CARRIER'
        };
    }

    private class ETERestException extends Exception {}
}