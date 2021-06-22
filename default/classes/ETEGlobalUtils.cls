public class ETEGlobalUtils {

    public static ETEMultiProductInterface getETEMultiProductImplementation(String implKey) {
        ETEMultiProductInterface instance;
        switch on implKey {
            when 'Poland', 'Germany', 'Netherlands', 'Belgium-NL', 'Belgium-FR',
                'Hungary', 'Slovakia', 'Czech Republic', 'France', 'Switzerland-DE', 'Switzerland-FR',
                'Luxembourg', 'Austria', 'Poland Lotos' {
                instance = new ETEMultiProductBaseImpl();
            }
            when 'Czech Republic CCS', 'Slovakia CCS' {
                instance = new ETEMultiProductCcsImpl();
            }
        }
        return instance;
    }
    
    public static ETEDatabaseInterface getDatabaseConnector(String countryCode) {
        ETEDatabaseInterface e2eDatabaseConnector;
        switch on countryCode {
            when 'de', 'pl', 'nl', 'benl', 'befr', 'hu', 'sk', 'cz', 'fr', 'chfr', 'chde', 'lu', 'at' {
                e2eDatabaseConnector = new ETEDatabaseBaseImpl();
            }
        }
        return e2eDatabaseConnector;
    }


    public static ETEStepInterface getETEStepImplementation(String implKey) {
        ETEStepInterface e2eStepImpl;
        switch on implKey {
            when 'Poland', 'Germany', 'Netherlands', 'Belgium-NL', 'Belgium-FR',
                'Hungary', 'Slovakia', 'Czech Republic', 'France', 'Switzerland-DE', 'Switzerland-FR',
                'Luxembourg', 'Austria' {
                e2eStepImpl = new ETEStepBaseImplementation();
            }
            when 'Poland Lotos', 'Czech Republic CCS', 'Slovakia CCS' {
                e2eStepImpl = new ETEStepLotosImplementation();
            }
        }
        return e2eStepImpl;
    }


    public static ETEBusinessObjectsInterface getETEBusinessObjectsHandler(String implKey) {
        ETEBusinessObjectsInterface e2eBusinessObjectsHandler;
        switch on implKey {
            when 'Poland', 'Germany', 'Netherlands', 'Belgium-NL', 'Belgium-FR',
                'Hungary', 'Slovakia', 'Czech Republic', 'France', 'Switzerland-FR', 'Switzerland-DE',
                'Luxembourg', 'Austria' {
                e2eBusinessObjectsHandler = new ETEBusinessObjectsHandler();
            }
            when 'Czech Republic CCS', 'Slovakia CCS' {
                e2eBusinessObjectsHandler = new ETEBusinessObjectsCCSHandler();
            }
            when 'Poland Lotos' {
                e2eBusinessObjectsHandler = new ETEBusinessObjectsLotosHandler();
            }
        }
        return e2eBusinessObjectsHandler;
    }


    public static ETEJobExecutor getJobExecutor(List<String> jobsNeededToRun, String dataObjectId, String countryCode, String implKey) {
        ETEJobExecutor jobExecutorImpl;
        switch on implKey {
            when 'Poland', 'Germany', 'Netherlands', 'Belgium-NL', 'Belgium-FR', 'Hungary',
                'Slovakia', 'Czech Republic', 'France', 'Switzerland-FR', 'Switzerland-DE',
                'Luxembourg', 'Austria', 'Czech Republic CCS', 'Slovakia CCS' {
                jobExecutorImpl = new ETEJobExecutorBaseImpl(jobsNeededToRun, dataObjectId, countryCode);
            }
            when 'Poland Lotos' {
                jobExecutorImpl = new ETEJobExecutorLotosImpl(jobsNeededToRun, dataObjectId, countryCode);
            }
        }
        return jobExecutorImpl;
    }


    public static ETERedirectionService getETERedirectionService(String countryCode) {
        ETERedirectionService e2eRedirectServiceImpl;
        switch on countryCode {
            when 'pl', 'de', 'nl', 'benl', 'befr', 'hu', 'sk', 'cz', 'fr', 'chfr', 'chde', 'lu', 'at' {
                e2eRedirectServiceImpl = new ETERedirectionServiceBaseImpl();
            }
        }
        return e2eRedirectServiceImpl;
    }


    public static ETEAdoptionInterface getETEAdoptionService(String implKey) {
        ETEAdoptionInterface e2eAdoptionImpl;
        switch on implKey {
            when 'Poland', 'Germany', 'Netherlands', 'Belgium-NL', 'Belgium-FR',
                    'Hungary', 'Slovakia', 'Czech Republic', 'France', 'Switzerland-DE', 'Switzerland-FR',
                    'Luxembourg', 'Austria', 'Czech Republic CCS', 'Slovakia CCS' {
                e2eAdoptionImpl = new ETEAdoptionBaseImpl();
            }
            when 'Poland Lotos' {
                e2eAdoptionImpl = new ETEAdoptionLotosBaseImpl();
            }
        }

        return e2eAdoptionImpl;
    }


    public static String returnSiteUrl(String countryCode) {
        Organization org = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
        Site site = [SELECT GuestUserId, Name, Subdomain, MasterLabel, UrlPathPrefix FROM Site WHERE Name = :'E2E' LIMIT 1];
        String url;
        if (org.IsSandbox) {
            url = 'https://' + UserInfo.getUserName().substringAfterLast('.') + '-' + site.Subdomain + '.' + org.InstanceName.toLowerCase() + '.force.com';
        } else {
            switch on countryCode {
                when 'pl' { url = 'https://online.fleetcor.pl'; }
                when 'de' { url = 'https://online.fleetcor.de'; }
                when 'nl' { url = 'https://online.fleetcor.nl'; }
                when 'benl', 'befr' { url = 'https://online.fleetcorcards.be'; }
                when 'hu' { url = 'https://online.fleetcor.hu'; }
                when 'sk' { url = 'https://online.fleetcor.sk'; }
                when 'cz' { url = 'https://online.fleetcor.cz'; }
                when 'fr' { url = 'https://online.fleetcor.fr'; }
                when 'chfr', 'chde' { url = 'https://online.fleetcor.ch'; }
                when 'at' { url = 'https://online.fleetcor.at'; }
                when 'lu' { url = 'https://online.fleetcor.lu'; }
                when null { url = ApexPages.currentPage().getHeaders().get('Host'); }
            }
        }
        return url;
    }


    public static PageReference returnUrlPath(String implKey) {
        PageReference urlPath;
        switch on implKey {
            when 'Poland' { urlPath = Page.etepl; }
            when 'Poland Lotos' { urlPath = Page.etelotospl; }
            when 'Germany' { urlPath = Page.etede; }
            when 'Netherlands' { urlPath = Page.etenl; }
            when 'Belgium-NL' { urlPath = Page.etebenl; }
            when 'Belgium-FR' { urlPath = Page.etebefr; }
            when 'Hungary' { urlPath = Page.etehu; }
            when 'Slovakia' { urlPath = Page.etesk; }
            when 'Slovakia CCS' { urlPath = Page.eteccssk; }
            when 'Czech Republic' { urlPath = Page.etecz; }
            when 'Czech Republic CCS' { urlPath = Page.eteccscz; }
            when 'France' { urlPath = Page.etefr; }
            when 'Switzerland-FR' { urlPath = Page.etechfr; }
            when 'Switzerland-DE' { urlPath = Page.etechde; }
            when 'Luxembourg' { urlPath = Page.etelu; }
            when 'Austria' { urlPath = Page.eteat; }
        }
        return urlPath;
    }


    public static String doEncryptParams(String stringToEncode, String countryCode) {
        String eteFormType = returnETEFormType(countryCode);
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(eteFormType).AES256_Key__c);
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        return encodedStringUrl;
    }


    public static String doDecryptParams(String encryptedParams, String countryCode) {
        String decryptedParams;
        if (! String.isEmpty(encryptedParams)) {
            String eteFormType = returnETEFormType(countryCode);
            E2EKeysAPI__c eteapiKeys = E2EKeysAPI__c.getValues(eteFormType);
            encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
            if (eteapiKeys == null) throw new LongFormException('The link is corrupted. Please contact your administrator');
            Blob key = EncodingUtil.base64Decode(eteapiKeys.AES256_Key__c);
            Blob dest = EncodingUtil.base64Decode(encryptedParams);
            Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
            decryptedParams = decrypted.toString();
        }
        return decryptedParams;
    }


    public static Set<String> generateStaticResourcesNames (String countryCode, List<String> availableSteps) {
        Set<String> availableStepsList = new Set<String>();
        switch on countryCode {
            when 'de','at','nl','pl','hu','fr', 'sk', 'cz', 'benl','befr','chde','chfr','lu' {
                for (String step : availableSteps) {
                    availableStepsList.add('ETE_STEP_' + step);
                }
                return availableStepsList;
            }
            when else { return null; }
        }
    }


    public static String returnETEFormType (String countryCode) {
        switch on countryCode {
            when 'pl' { return 'E2EFormPL'; }
            when 'at' { return 'E2EFormAT'; }
            when 'nl' { return 'E2EFormNL'; }
            when 'hu' { return 'E2EFormHU'; }
            when 'fr' { return 'E2EFormFR'; }
            when 'benl' { return 'E2EFormBENL'; }
            when 'befr' { return 'E2EFormBEFR'; }
            when 'chde' { return 'E2EFormCHDE'; }
            when 'chfr' { return 'E2EFormCHFR'; }
            when 'de', 'sk', 'cz', 'lu' { return 'E2EForm'; }
            when else { return null; }
        }
    }


    public static Set<String> returnDefaultSettingKey(String implKey) {
        switch on implKey {
            when 'Poland' { return new Set<String>{'ETE_default_settings_pl'}; }
            when 'Poland Lotos' { return new Set<String>{'ETE_default_settings_lotos_pl'}; }
            when 'Germany' { return new Set<String>{'ETE_default_settings_de'}; }
            when 'Netherlands' { return new Set<String>{'ETE_default_settings_nl'}; }
            when 'Belgium-NL' { return new Set<String>{'ETE_default_settings_benl'}; }
            when 'Belgium-FR' { return new Set<String>{'ETE_default_settings_befr'}; }
            when 'Hungary' { return new Set<String>{'ETE_default_settings_hu'}; }
            when 'Slovakia' { return new Set<String>{'ETE_default_settings_sk'}; }
            when 'Slovakia CCS' { return new Set<String>{'ETE_default_settings_ccs_sk'}; }
            when 'Czech Republic' { return new Set<String>{'ETE_default_settings_cz'}; }
            when 'Czech Republic CCS' { return new Set<String>{'ETE_default_settings_ccs_cz'}; }
            when 'France' { return new Set<String>{'ETE_default_settings_fr'}; }
            when 'Switzerland-FR' { return new Set<String>{'ETE_default_settings_chfr'}; }
            when 'Switzerland-DE' { return new Set<String>{'ETE_default_settings_chde'}; }
            when 'Luxembourg' { return new Set<String>{'ETE_default_settings_lu'}; }
            when 'Austria' { return new Set<String>{'ETE_default_settings_at'}; }
            when else { return null; }
        }
    }

    public static String returnCountry(String countryCode) {
        switch on countryCode {
            when 'pl' { return 'Poland'; }
            when 'de' { return 'Germany'; }
            when 'nl' { return 'Netherlands'; }
            when 'benl' { return 'Belgium-NL'; }
            when 'befr' { return 'Belgium-FR'; }
            when 'hu' { return 'Hungary'; }
            when 'sk' { return 'Slovakia'; }
            when 'cz' { return 'Czech Republic'; }
            when 'fr' { return 'France'; }
            when 'chfr' { return 'Switzerland-FR'; }
            when 'chde' { return 'Switzerland-DE'; }
            when 'at' { return 'Austria'; }
            when 'lu' { return 'Luxembourg'; }
            when else { return null; }
        }
    }

    public static String getCountryCodeByImplKey(String implKey) {
        switch on implKey {
            when 'Poland' { return 'pl'; }
            when 'Poland Lotos' { return 'pl'; }
            when 'Germany' { return 'de'; }
            when 'Netherlands' { return 'nl'; }
            when 'Belgium-NL' { return 'benl'; }
            when 'Belgium-FR' { return 'befr'; }
            when 'Hungary' { return 'hu'; }
            when 'Slovakia' { return 'sk'; }
            when 'Slovakia CCS' { return 'sk'; }
            when 'Czech Republic' { return 'cz'; }
            when 'Czech Republic CCS' { return 'cz'; }
            when 'France' { return 'fr'; }
            when 'Switzerland-FR' { return 'chfr'; }
            when 'Switzerland-DE' { return 'chde'; }
            when 'Luxembourg' { return 'lu'; }
            when 'Austria' { return 'at'; }
            when else { return null; }
        }
    }

    public static String returnTwoLettersCountry(String country) {
        switch on country {
            when 'Poland' { return 'pl'; }
            when 'Germany' { return 'de'; }
            when 'Netherlands' { return 'nl'; }
            when 'Belgium-NL' { return 'benl'; }
            when 'Belgium-FR' { return 'befr'; }
            when 'Hungary' { return 'hu'; }
            when 'Slovakia' { return 'sk'; }
            when 'Czech Republic' { return 'cz'; }
            when 'France' { return 'fr'; }
            when 'Switzerland-FR' { return 'chfr'; }
            when 'Switzerland-DE' { return 'chde'; }
            when 'Luxembourg' { return 'lu'; }
            when 'Austria' { return 'at'; }
            when else { return null; }
        }
    }

    public static String returnBuildTypeByImplKey(String implKey) {
        switch on implKey {
            when 'Poland'               { return 'pl'; }
            when 'Poland Lotos'         { return 'lotos_pl'; }
            when 'Germany'              { return 'de'; }
            when 'Netherlands'          { return 'nl'; }
            when 'Belgium-NL'           { return 'benl'; }
            when 'Belgium-FR'           { return 'befr'; }
            when 'Hungary'              { return 'hu'; }
            when 'Slovakia'             { return 'sk'; }
            when 'Slovakia CCS'         { return 'ccs_sk'; }
            when 'Czech Republic'       { return 'cz'; }
            when 'Czech Republic CCS'   { return 'ccs_cz'; }
            when 'France'               { return 'fr'; }
            when 'Switzerland-FR'       { return 'chfr'; }
            when 'Switzerland-DE'       { return 'chde';}
            when 'Luxembourg'           { return 'lu'; }
            when 'Austria'              { return 'at'; }
            when else                   { return null; }
        }
    }


    public static String returnLanguagePreference(String currentLanguage) {
        switch on currentLanguage {
            when 'pl' { return 'Polish'; }
            when 'de' { return 'German'; }
            when 'nl' { return 'Dutch'; }
            when 'fr' { return 'French'; }
            when 'en' { return 'English'; }
            when 'hu' { return 'Hungarian'; }
            when 'sk' { return 'Slovak'; }
            when 'cs' { return 'Czech'; }
            when else { return null; }
        }
    }


    public static String returnDefaultLanguage(String countryCode) {
        switch on countryCode {
            when 'en' { return 'en'; }
            when 'pl' { return 'pl'; }
            when 'hu' { return 'hu'; }
            when 'de', 'chde', 'at' { return 'de'; }
            when 'nl', 'benl' { return 'nl'; }
            when 'fr', 'befr', 'chfr', 'lu' { return 'fr'; }
            when 'sk' { return 'sk'; }
            when 'cz' { return 'cs'; }
            when else { return null; }
        }
    }


    public static String returnCurrencyCode(String countryCode) {
        switch on countryCode {
            when 'pl' { return 'PLN'; }
            when 'de', 'nl', 'benl', 'befr', 'sk', 'fr', 'lu', 'at' { return 'EUR'; }
            when 'hu' { return 'HUF'; }
            when 'cz' { return 'CZK'; }
            when 'chde', 'chfr' { return 'CHF'; }
            when else { return null; }
        }
    }


    public static String returnSepaDocumentType(String docKey) {
        switch on docKey {
            when 'Germany_Core', 'Netherlands_Core', 'Belgium-NL_Core', 'Belgium-FR_Core', 'Luxembourg_Core', 'Austria_Core', 'France_Core', 'Czech Republic CCS_Core', 'Slovakia CCS_Core' { return 'documentsAgreement_core'; }
            when 'Germany_B2B', 'Netherlands_B2B', 'Belgium-NL_B2B', 'Belgium-FR_B2B', 'Luxembourg_B2B', 'Austria_B2B', 'France_B2B', 'Czech Republic CCS_B2B', 'Slovakia CCS_B2B' { return 'documentsAgreement'; }
            when else { return null; }
        }
    }


    public static String returnIngcoLanguage(String countryCode) {
        switch on countryCode {
            when 'de', 'at' { return 'de_DE'; }
            when 'nl' { return 'nl_NL'; }
            when 'benl' { return 'nl_BE'; }
            when 'befr' { return 'fr_BE'; }
            when 'fr' { return 'fr_FR'; }
            when else { return null; }
        }
    }


    public static String returnIngcoTemplate(String countryCode) {
        switch on countryCode {
            when 'de' { return 'ETE_DE_Template.html'; }
            when 'nl' { return 'ETE_NL_Template.html'; }
            when 'benl' { return 'ETE_BENL_Template.html'; }
            when 'befr' { return 'ETE_BEFR_Template.html'; }
            when 'fr' { return 'ETE_FR_Template.html'; }
            when 'at' { return 'ETE_AT_Template.html'; }
            when else { return null; }
        }
    }


    public static String returnApprovalProcessDefinition(String implKey) {
        switch on implKey {
            when 'Poland' { return 'CreditCheck_PL'; }
            when else { return null; }
        }
    }


    public static String returnOrderConfirmationEmailTemplateName (String implKey) {
        switch on implKey {
            when 'Czech Republic CCS' { return 'CCS_Order_Confirmation_CZ'; }
            when 'Slovakia CCS' { return 'CCS_Order_Confirmation_SK'; }
            when else { return null; }
        }
    }


    public static String returnSenderEmailAddress (String implKey) {
        switch on implKey {
            when 'Czech Republic CCS' { return 'no-reply@ccs.cz'; }
            when 'Slovakia CCS' { return 'no-reply@ccs.sk'; }
            when else { return 'no-reply@fleetcor.eu'; }
        }
    }


    public static Date convertStringToDate(String dateStr) {
        Date dt;
        if (! String.isEmpty(dateStr) && dateStr.contains('.')) {
            List<String> dateDetails = (dateStr).split('\\.');
            dt = Date.newInstance(Integer.valueOf(dateDetails.get(2)),
                    Integer.valueOf(dateDetails.get(1)),
                    Integer.valueOf(dateDetails.get(0)));
        }
        return dt;
    }


    public static ETEUserModel convertToETEUserModel(Map<String, Object> dataObjectsToConvertMap) {
        Map<String, Map<String, String>> userModelFieldsMapping = returnUserModelFieldsMapping();
        ETEUserModel usrModel = new ETEUserModel();
        Map<String, Object> untypedUserModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(usrModel));
        E2E_Data_Object__c dataObject = (E2E_Data_Object__c) dataObjectsToConvertMap.get('data_object');
        for (String objectKey : userModelFieldsMapping.keySet()) {
            switch on objectKey {
                when 'data_object' {
                    untypedUserModel.putAll(convertDataObject(dataObject, userModelFieldsMapping));
                } when 'ete_contact' {
                    List<E2E_Data_Contact__c> e2eContacts = (List<E2E_Data_Contact__c>) dataObjectsToConvertMap.get(objectKey);
                    untypedUserModel.put('contacts', convertDataContacts(dataObject.Country_Code__c, e2eContacts, userModelFieldsMapping));
                } when 'product' {
                    untypedUserModel.put('products', convertMultiproducts(dataObject.Country_Code__c, dataObjectsToConvertMap, userModelFieldsMapping));
                } when 'additional_service' {
                    List<E2E_Data_Additional_Service__c> e2eAdditionalServices = (List<E2E_Data_Additional_Service__c>) dataObjectsToConvertMap.get(objectKey);
                    untypedUserModel.put('additionalServices', convertAdditionalServices(dataObject.Country_Code__c, e2eAdditionalServices, userModelFieldsMapping));
                }
            }
        }
        usrModel = (ETEUserModel)JSON.deserialize(JSON.serialize(untypedUserModel), ETEUserModel.class);
        usrModel.availableSteps = new List<String>();
        usrModel.navigationMenuSteps = new List<ETEUserModel.NavigationMenuStep>();
        usrModel.implKey = dataObject.RecordType.Name;
        return usrModel;
    }


    private static Map<String, Object> convertDataObject(E2E_Data_Object__c dataObject, Map<String, Map<String, String>> userModelFieldsMapping) {
        Map<String, Object> untypedDataObjectModel = new Map<String, Object>();
        for (String dataModelFieldApi : userModelFieldsMapping.get('data_object').keySet()) {
            String dataObjectFieldApi = userModelFieldsMapping.get('data_object').get(dataModelFieldApi);
            Object dataObjectFieldValue = dataObject.get(dataObjectFieldApi);
            if (dataModelFieldApi == 'source') {
                if (dataObjectFieldValue != null) {
                    String sourceToModel = doEncryptParams((String) dataObjectFieldValue, dataObject.Country_Code__c);
                    untypedDataObjectModel.put(dataModelFieldApi, sourceToModel);
                }
            } else if (dataModelFieldApi == 'utmProducts') {
                if (dataObjectFieldValue != null) {
                    String utmProductsToModel = doEncryptParams((String) dataObjectFieldValue, dataObject.Country_Code__c);
                    untypedDataObjectModel.put(dataModelFieldApi, utmProductsToModel);
                }
            } else if (dataModelFieldApi == 'countryCode' || dataModelFieldApi == 'currentLang') {
                if (dataObjectFieldValue != null) {
                    untypedDataObjectModel.put(dataModelFieldApi, dataObjectFieldValue);
                } else {
                    untypedDataObjectModel.put(dataModelFieldApi, dataObject.Country_Code__c);
                }
            } else {
                if (dataObjectFieldValue == null) {
                    SObjectType sobjType = ((SObject)(Type.forName('Schema.E2E_Data_Object__c').newInstance())).getSObjectType();
                    DescribeSObjectResult describeSObjectResult = sobjType.getDescribe();
                    Schema.DisplayType fieldType = describeSObjectResult.fields.getMap().get(dataObjectFieldApi).getDescribe().getType();
                    if (fieldType == Schema.DisplayType.BOOLEAN) {
                        dataObjectFieldValue = false;
                    }
                }
                untypedDataObjectModel.put(dataModelFieldApi, dataObjectFieldValue);
            }
        }
        return untypedDataObjectModel;
    }


    private static List<Object> convertDataContacts(String countryCode, List<E2E_Data_Contact__c> e2eContacts, Map<String, Map<String, String>> userModelFieldsMapping) {
        List<Object> untypedContactsModel = new List<Object>();
        for (E2E_Data_Contact__c e2eContact : e2eContacts) {
            ETEUserModel.ETE_Contact e2eContactModel = new ETEUserModel.ETE_Contact();
            Map<String, Object> untypedContactModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(e2eContactModel));
            for (String contactModelFieldApi : userModelFieldsMapping.get('ete_contact').keySet()) {
                String contactObjectFieldApi = userModelFieldsMapping.get('ete_contact').get(contactModelFieldApi);
                Object contactObjectFieldValue = e2eContact.get(contactObjectFieldApi);
                if (contactModelFieldApi == 'source') {
                    if (contactObjectFieldValue != null) {
                        String encryptValue = doEncryptParams((String) contactObjectFieldValue, countryCode);
                        untypedContactModel.put(contactModelFieldApi, encryptValue);
                    }
                } else {
                    untypedContactModel.put(contactModelFieldApi, contactObjectFieldValue);
                }
            }
            untypedContactsModel.add(untypedContactModel);
        }
        return untypedContactsModel;
    }


    private static List<Object> convertMultiproducts(String countryCode,
                                                    Map<String, Object> dataObjectsToConvertMap,
                                                    Map<String, Map<String, String>> userModelFieldsMapping) {
        List<Object> untypedMultiProductsModel = new List<Object>();
        List<E2E_Data_Product__c> e2eProducts = (List<E2E_Data_Product__c>) dataObjectsToConvertMap.get('product');
        for (E2E_Data_Product__c e2eProduct : e2eProducts) {
            ETEUserModel.Product e2eProductModel = new ETEUserModel.Product();
            Map<String, Object> untypedProductModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(e2eProductModel));
            for (String productModelFieldApi : userModelFieldsMapping.get('product').keySet()) {
                String productObjectFieldApi = userModelFieldsMapping.get('product').get(productModelFieldApi);
                Object productObjectFieldValue = e2eProduct.get(productObjectFieldApi);
                if (productModelFieldApi == 'source' || productModelFieldApi == 'productId' || productModelFieldApi == 'typeId') {
                    if (productObjectFieldValue != null) {
                        String encryptValue = doEncryptParams((String) productObjectFieldValue, countryCode);
                        untypedProductModel.put(productModelFieldApi, encryptValue);
                    }
                } else {
                    untypedProductModel.put(productModelFieldApi, productObjectFieldValue);
                }
            }
            if (dataObjectsToConvertMap.containsKey('locator_item')) {
                Map<String, List<Object>> locatorItemsOfThisProduct = new Map<String, List<Object>>();
                locatorItemsOfThisProduct.put('stations', new List<Object>());
                locatorItemsOfThisProduct.put('stationsNetworks', new List<Object>());
                List<E2E_Data_Locator_Item__c> e2eLocatorItems = (List<E2E_Data_Locator_Item__c>) dataObjectsToConvertMap.get('locator_item');
                for (E2E_Data_Locator_Item__c e2eLocatorItem : e2eLocatorItems) {
                    if (e2eLocatorItem.E2E_Data_Product__c == e2eProduct.Id) {
                        Map<String, Object> convertedOfferItem = convertLocatorItem(countryCode, e2eLocatorItem, userModelFieldsMapping);
                        if (convertedOfferItem.containsKey('filling_station')) {
                            locatorItemsOfThisProduct.get('stations').add(convertedOfferItem.get('filling_station'));
                        } else if (convertedOfferItem.containsKey('filling_stations_network')) {
                            locatorItemsOfThisProduct.get('stationsNetworks').add(convertedOfferItem.get('filling_stations_network'));
                        }
                    }
                }
                untypedProductModel.put('stations', locatorItemsOfThisProduct.get('stations'));
                untypedProductModel.put('stationsNetworks', locatorItemsOfThisProduct.get('stationsNetworks'));
            }
            if (dataObjectsToConvertMap.containsKey('offer_item')) {
                List<Object> offerItemsOfThisProduct = new List<Object>();
                List<E2E_Data_Offer_Item__c> e2eOfferItems = (List<E2E_Data_Offer_Item__c>) dataObjectsToConvertMap.get('offer_item');
                for (E2E_Data_Offer_Item__c e2eOfferItem : e2eOfferItems) {
                    if (e2eOfferItem.E2E_Data_Product__c == e2eProduct.Id) {
                        Object convertedOfferItem = convertOfferItem(countryCode, e2eOfferItem, userModelFieldsMapping);
                        offerItemsOfThisProduct.add(convertedOfferItem);
                    }
                }
                untypedProductModel.put('offerItems', offerItemsOfThisProduct);
            }
            untypedMultiProductsModel.add(untypedProductModel);
        }
        return untypedMultiProductsModel;
    }


    private static Map<String, Object> convertLocatorItem(String countryCode,
                                                        E2E_Data_Locator_Item__c e2eLocatorItem,
                                                        Map<String, Map<String, String>> userModelFieldsMapping) {
        ETEUserModel.Offer_Item offerItem = new ETEUserModel.Offer_Item();
        Map<String, Object> convertedLocatorItem = new Map<String, Object>();
        Map<String, Object> untypedOfferModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(offerItem));
        String recordType = Schema.getGlobalDescribe().get('E2E_Data_Locator_Item__c').getDescribe().getRecordTypeInfosById().get(e2eLocatorItem.RecordTypeId).getName();
        String recordTypeKey;
        if (recordType == 'Station') {
            recordTypeKey = 'filling_station';
        } else if (recordType == 'Network') {
            recordTypeKey = 'filling_stations_network';
        }
        for (String offerModelFieldApi : userModelFieldsMapping.get(recordTypeKey).keySet()) {
            String offerObjectFieldApi = userModelFieldsMapping.get(recordTypeKey).get(offerModelFieldApi);
            Object offerObjectFieldValue = e2eLocatorItem.get(offerObjectFieldApi);
            if (offerModelFieldApi == 'source') {
                if (offerObjectFieldValue != null) {
                    String encryptValue = doEncryptParams((String) offerObjectFieldValue, countryCode);
                    untypedOfferModel.put(offerModelFieldApi, encryptValue);
                }
            } else {
                untypedOfferModel.put(offerModelFieldApi, offerObjectFieldValue);
            }
        }
        convertedLocatorItem.put(recordTypeKey, untypedOfferModel);
        return convertedLocatorItem;
    }


    private static Object convertOfferItem(String countryCode,
                                            E2E_Data_Offer_Item__c e2eOfferItem,
                                            Map<String, Map<String, String>> userModelFieldsMapping) {
        ETEUserModel.Offer_Item offerItem = new ETEUserModel.Offer_Item();
        Map<String, Object> untypedOfferModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(offerItem));
        for (String offerModelFieldApi : userModelFieldsMapping.get('offer_item').keySet()) {
            String offerObjectFieldApi = userModelFieldsMapping.get('offer_item').get(offerModelFieldApi);
            Object offerObjectFieldValue = e2eOfferItem.get(offerObjectFieldApi);
            if (offerModelFieldApi == 'source') {
                if (offerObjectFieldValue != null) {
                    String encryptValue = doEncryptParams((String) offerObjectFieldValue, countryCode);
                    untypedOfferModel.put(offerModelFieldApi, encryptValue);
                }
            } else {
                untypedOfferModel.put(offerModelFieldApi, offerObjectFieldValue);
            }
        }
        return untypedOfferModel;
    }


    private static List<Object> convertAdditionalServices(String countryCode, List<E2E_Data_Additional_Service__c> e2eAdditionalServices, Map<String, Map<String, String>> userModelFieldsMapping) {
        List<Object> additionalServiceObjects = new List<Object>();
        for (E2E_Data_Additional_Service__c e2eAdditionalService : e2eAdditionalServices) {
            ETEUserModel.Additional_Service additionalService = new ETEUserModel.Additional_Service();
            Map<String, Object> untypedAdditionalServiceModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(additionalService));
            for (String additionalServiceModelFieldApi : userModelFieldsMapping.get('additional_service').keySet()) {
                String additionalServiceObjectFieldApi = userModelFieldsMapping.get('additional_service').get(additionalServiceModelFieldApi);
                Object additionalServiceObjectFieldValue = e2eAdditionalService.get(additionalServiceObjectFieldApi);
                if (additionalServiceModelFieldApi == 'source') {
                    if (additionalServiceObjectFieldValue != null) {
                        String sourceToOffer = doEncryptParams((String) additionalServiceObjectFieldValue, countryCode);
                        untypedAdditionalServiceModel.put(additionalServiceModelFieldApi, sourceToOffer);
                    }
                } else {
                    untypedAdditionalServiceModel.put(additionalServiceModelFieldApi, additionalServiceObjectFieldValue);
                }
            }
            additionalServiceObjects.add(untypedAdditionalServiceModel);
        }
        return additionalServiceObjects;
    }


    public static ETEUserModel convertToUserModel(E2E_Data_Object__c dataObject,
                                                List<E2E_Data_Contact__c> contactsList,
                                                List<E2E_Data_Offer_Item__c> offerItemsList,
                                                List<E2E_Data_Additional_Service__c> additionalServicesList) {
        Map<String, Map<String, String>> userModelFieldsMapping = returnUserModelFieldsMapping();
        ETEUserModel usrModel = new ETEUserModel();
        Map<String, Object> untypedUserModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(usrModel));
        for (String dataModelFieldApi : userModelFieldsMapping.get('data_object').keySet()) {
            String dataObjectFieldApi = userModelFieldsMapping.get('data_object').get(dataModelFieldApi);
            Object dataObjectFieldValue = dataObject.get(dataObjectFieldApi);
            if (dataModelFieldApi == 'source') {
                if (dataObjectFieldValue != null) {
                    String sourceToModel = doEncryptParams((String) dataObjectFieldValue, dataObject.Country_Code__c);
                    untypedUserModel.put(dataModelFieldApi, sourceToModel);
                }
            } else if (dataModelFieldApi == 'utmProducts') {
                if (dataObjectFieldValue != null) {
                    String utmProductsToModel = doEncryptParams((String) dataObjectFieldValue, dataObject.Country_Code__c);
                    untypedUserModel.put(dataModelFieldApi, utmProductsToModel);
                }
            } else if (dataModelFieldApi == 'countryCode' || dataModelFieldApi == 'currentLang') {
                if (dataObjectFieldValue != null) {
                    untypedUserModel.put(dataModelFieldApi, dataObjectFieldValue);
                } else {
                    untypedUserModel.put(dataModelFieldApi, dataObject.Country_Code__c);
                }
            } else {
                if (dataObjectFieldValue == null) {
                    SObjectType sobjType = ((SObject)(Type.forName('Schema.E2E_Data_Object__c').newInstance())).getSObjectType();
                    DescribeSObjectResult describeSObjectResult = sobjType.getDescribe();
                    Schema.DisplayType fieldType = describeSObjectResult.fields.getMap().get(dataObjectFieldApi).getDescribe().getType();
                    if (fieldType == Schema.DisplayType.BOOLEAN) {
                        dataObjectFieldValue = false;
                    }
                }
                untypedUserModel.put(dataModelFieldApi, dataObjectFieldValue);
            }
        }

        List<Object> contactsObjects = new List<Object>();
        for (E2E_Data_Contact__c databaseContact : contactsList) {
            ETEUserModel.ETE_Contact e2eContact = new ETEUserModel.ETE_Contact();
            Map<String, Object> untypedContactModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(e2eContact));
            for (String contactModelFieldApi : userModelFieldsMapping.get('ete_contact').keySet()) {
                String contactObjectFieldApi = userModelFieldsMapping.get('ete_contact').get(contactModelFieldApi);
                Object contactObjectFieldValue = databaseContact.get(contactObjectFieldApi);
                if (contactModelFieldApi == 'source') {
                    if (contactObjectFieldValue != null) {
                        String encryptValue = doEncryptParams((String) contactObjectFieldValue, dataObject.Country_Code__c);
                        untypedContactModel.put(contactModelFieldApi, encryptValue);
                    }
                } else {
                    untypedContactModel.put(contactModelFieldApi, contactObjectFieldValue);
                }
            }
            contactsObjects.add(untypedContactModel);
        }
        untypedUserModel.put('contacts', contactsObjects);



        List<Object> additionalServiceObjects = new List<Object>();
        for (E2E_Data_Additional_Service__c databaseAdditionalService : additionalServicesList) {
            ETEUserModel.Additional_Service additionalService = new ETEUserModel.Additional_Service();
            Map<String, Object> untypedAdditionalServiceModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(additionalService));
            for (String additionalServiceModelFieldApi : userModelFieldsMapping.get('additional_service').keySet()) {
                String additionalServiceObjectFieldApi = userModelFieldsMapping.get('additional_service').get(additionalServiceModelFieldApi);
                Object additionalServiceObjectFieldValue = databaseAdditionalService.get(additionalServiceObjectFieldApi);
                if (additionalServiceModelFieldApi == 'source') {
                    if (additionalServiceObjectFieldValue != null) {
                        String sourceToOffer = doEncryptParams((String) additionalServiceObjectFieldValue, dataObject.Country_Code__c);
                        untypedAdditionalServiceModel.put(additionalServiceModelFieldApi, sourceToOffer);
                    }
                } else {
                    untypedAdditionalServiceModel.put(additionalServiceModelFieldApi, additionalServiceObjectFieldValue);
                }
            }
            additionalServiceObjects.add(untypedAdditionalServiceModel);
        }
        untypedUserModel.put('additionalServices', additionalServiceObjects);

        usrModel = (ETEUserModel)JSON.deserialize(JSON.serialize(untypedUserModel), ETEUserModel.class);
        usrModel.availableSteps = new List<String>();
        usrModel.navigationMenuSteps = new List<ETEUserModel.NavigationMenuStep>();
        usrModel.implKey = dataObject.RecordType.Name;
        return usrModel;
    }


    public static Map<String, Map<String, String>> returnUserModelFieldsMapping() {
        Map<String, Map<String, String>> userModelFieldsMapping = new Map<String, Map<String, String>>{
                'data_object' => new Map<String, String>{
                        'source' => 'Id',
                        'utmProducts' => 'Utm_Products__c',
                        'stageName' => 'StageName__c',
                        'eteStatus' => 'E2E_Status__c',
                        'eteFinishedDetails' => 'E2E_Finish_Details__c',
                        'currentLang' => 'Current_Language__c',
                        'countryCode' => 'Country_Code__c',
                        'currentStep' => 'Current_Step__c',
                        'esi' => 'ESI__c',
                        'homeStation' => 'Home_Station__c',
                        'salutation' => 'Salutation__c',
                        'firstName' => 'First_Name__c',
                        'lastName' => 'Last_Name__c',
                        'phone' => 'Phone__c',
                        'email' => 'Email__c',
                        'birthdate' => 'Birthdate__c',
                        'postalCode' => 'Registered_Postal_Code__c',
                        'country' => 'Registered_Country__c',
                        'city' => 'Registered_City__c',
                        'street' => 'Registered_Street__c',
                        'selectedCompanyName' => 'Selected_Company_Name__c',
                        'companyForm' => 'Company_Form__c',
                        'companyShortName' => 'Company_Short_Name__c',
                        'selectedCompanyId' => 'Selected_Company_Id__c',
                        'taxId' => 'Tax_ID__c',
                        'vatId' => 'Vat_ID__c',
                        'tradeRegisterNumber' => 'Trade_Register_Number__c',
                        'agreementToPhoneContact' => 'Agreement_To_Phone_Contact__c',
                        'agreementToReceiveInfoByEmail' => 'Agreement_To_Receive_Info_By_Email__c',
                        'agreementPrivacyPolicy' => 'Agreement_Privacy_Policy__c',
                        'agreeToProcessPersDataForMarketing' => 'Agree_to_process_pers_data_for_marketing__c',
                        'termsAndConditionsAgreement' => 'Terms_And_Conditions_Agreement__c',
                        'authorizedSignatoryConfirmed' => 'Authorized_Signatory_Confirmed__c',
                        'accountHolder' => 'Account_Holder__c',
                        'iban' => 'IBAN__c',
                        'swift' => 'SWIFT__c',
                        'acceptSepa' => 'Accept_Sepa__c',
                        'securityAmountToPay' => 'Security_Amount_To_Pay__c',
                        'depositReason' => 'Deposit_Reason__c',
                        'depositAgreement' => 'Deposit_Agreement__c',
                        'paymentMethod' => 'Payment_Method__c',
                        'securityLevel' => 'Security_Level__c',
                        'creditLimit' => 'Credit_Limit__c',
                        'maxCreditLimit' => 'Max_Credit_Limit__c',
                        'classRating' => 'Credit_System_Rating__c',
                        'billingPeriod' => 'Billing_Period__c',
                        'riskCategory' => 'Risk_Category__c',
                        'directDebitMandateType' => 'Direct_Debit_Mandate_Type__c',
                        'paymentTerms' => 'Payment_Terms__c',
                        'eInvoice' => 'E_Invoice__c',
                        'paperInvoice' => 'Paper_Invoice__c',
                        'pm' => 'PM__c',
                        'brand' => 'Brand__c',
                        'googleClientId' => 'Client_Id__c',
                        'bankAccountPrefix' => 'Bank_Account_Prefix__c',
                        'bankAccountNumber' => 'Bank_Account_Number__c',
                        'bankCode' => 'Bank_Code__c',
                        'bankName' => 'Bank_Name__c'
                },
                'ete_contact' => new Map<String, String>{
                        'source' => 'Id',
                        'index' => 'Index__c',
                        'salutation' => 'Salutation__c',
                        'firstName' => 'First_Name__c',
                        'lastName' => 'Last_Name__c',
                        'phone' => 'Phone__c',
                        'email' => 'Email__c',
                        'birthdate' => 'Birthdate__c',
                        'role' => 'Role__c',
                        'isPrimary' => 'isPrimary__c'
                },
                'product' => new Map<String, String>{
                        'source' => 'Id',
                        'name' => 'Name',
                        'productId' => 'ProductID__c',
                        'typeId' => 'Type_ID__c',
                        'typeName' => 'Type_Name__c'
                },
                'filling_station' => new Map<String, String>{
                        'source' => 'Id',
                        'name' => 'Name',
                        'brand' => 'Brand__c',
                        'esi' => 'ESI__c'
                },
                'filling_stations_network' => new Map<String, String>{
                        'source' => 'Id',
                        'name' => 'Name'
                },
                'offer_item' => new Map<String, String>{
                        'source' => 'Id',
                        'offerName' => 'Offer_Name__c',
                        'typeOfVehicle' => 'Type_Of_Vehicle__c',
                        'typeOfCard' => 'Type_Of_Card__c',
                        'mileageData' => 'Mileage_Data__c',
                        'lockedPinChange' => 'Locked_Pin_Change__c',
                        'evCharging' => 'Activate_EV_Charging__c',
                        'licensePlateNumber' => 'License_Plate_Number__c',
                        'driverName' => 'Driver_Name__c',
                        'companyName' => 'Company_Name__c',
                        'categoryOfProducts' => 'Category_Of_Products__c',
                        'dailyLimit' => 'Daily_Card_Limit__c',
                        'monthlyFuelConsumption' => 'Monthly_Fuel_Consumption__c',
                        'monthlyCardLimit' => 'Monthly_Card_Limit__c'
                },
                'additional_service' => new Map<String, String>{
                        'source' => 'Id',
                        'id' => 'Name',
                        'selected' => 'Selected__c'
                }
        };
        return userModelFieldsMapping;
    }

    public static String returnDeviceType(String userAgent) {
        Set<String> mobileDevicesSet = new Set<String>{
                'Android', 'webOS', 'iPhone', 'iPod', 'BlackBerry', 'IEMobile', 'Opera Mini'
        };
        Set<String> tabletDevicesSet = new Set<String>{
                'Tablet', 'iPad', 'Nexus 7', 'Nexus 10', 'KFAPWI'
        };
        String deviceType;
        for (String mobileType : mobileDevicesSet) {
            if (userAgent.containsIgnoreCase(mobileType)) {
                deviceType = 'Mobile';
                break;
            }
        }
        if (deviceType == null) {
            for (String tabletType : tabletDevicesSet) {
                if (userAgent.containsIgnoreCase(tabletType)) {
                    deviceType = 'Tablet';
                    break;
                }
            }
        }
        if (deviceType == null) { deviceType = 'Desktop'; }
        return deviceType;
    }
}