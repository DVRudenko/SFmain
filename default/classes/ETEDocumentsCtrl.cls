public without sharing class ETEDocumentsCtrl {
    public static PageReference newPage;
    public static String content {get; set;}
    public static String dataId {get; set;}
    public static String style {get; set;}
    public static String pageMargin {get; set;}
    public static String productLogo {get; set;}
    public static Boolean showHeader {get; set;}
    public static String footer {get; set;}
    public static ETEDatabaseInterface e2eDatabase;
    public static E2E_Data_Object__c dataObject = new E2E_Data_Object__c();
    public static E2E_Data_Contact__c dataContactPrimary = new E2E_Data_Contact__c();
    public static Opportunity currentOpportunity = new Opportunity();
    public static Map<String, String> contentMap = new Map<String, String>();
    public static Map<String, List<String>> productFamiliesByTypeMap = new Map<String, List<String>>{
        'fuel' => new List<String>{'Lotos', 'SHELL'},
        'ev' => new List<String>{'EV'}
    };

    public static PageReference init () {
         try {
            pageMargin = '1.5cm 1cm 1cm 1cm';
            showHeader = true;
             footer = 'counter(page)';
            Map<String, String> pageParamsMap = ApexPages.currentPage().getParameters();
            String doc = pageParamsMap.get('doc');
            String source = pageParamsMap.get('source');
            String countryCode = pageParamsMap.get('countryCode');
            String language = pageParamsMap.get('language');
            String implKey = pageParamsMap.get('implKey');
            String productType = pageParamsMap.get('productType');

            if (String.isEmpty(productType)) {
                fillContent(source, countryCode, doc, language, implKey);
            } else {
                List<String> productFamilies = productFamiliesByTypeMap.get(productType);
                showHeader = false;
                pageMargin = '0';
                if (String.isNotEmpty(source) && source != 'null') {
                    if (String.isEmpty(countryCode)) { countryCode = 'pl'; }
                    
                    dataId = ETEGlobalUtils.doDecryptParams(source, countryCode);

                    List<Opportunity> listOpportunities = [
                            SELECT  Id, Name
                            FROM    Opportunity
                            WHERE   E2E_Data_Object__c =: dataId
                            LIMIT   1
                    ];
                    
                    List<OpportunityLineItem> items = [
                            SELECT  Id, Product2.Integration_Name__c
                            FROM    OpportunityLineItem 
                            WHERE   OpportunityId =: listOpportunities.get(0).Id
                            AND     Product2.Family IN : productFamilies
                            LIMIT   1
                    ];

                    String jsonData = PageReference.forResource('ETE_MP_OFFERS', items.get(0).Product2.Integration_Name__c + '.json').getContent().toString();
                    Map<String, Object> jsonDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
                    Map<String, Object> resourceObject = new Map<String, Object>();
                    // select implementation for each param
                    for (String key : jsonDataMap.keySet()) {
                        Map<String, Object> keyImpls = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(jsonDataMap.get(key)));
                        Object impl = keyImpls.containsKey(implKey) ? keyImpls.get(implKey) : keyImpls.get('default_impl');
                        resourceObject.put(key, impl);
                    }
                    String resourcePath = String.valueOf(resourceObject.get('tariffSheets'));
                    content = '<img src="'+ resourcePath + '" width="100%"/>';
                }
            }
         } catch (Exception e) {
             content = '';
         }
        return newPage;
    }

    public static String fillContent (String source, String countryCode, String doc, String language, String implKey) {
        if (String.isNotEmpty(countryCode)) {
            e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        }
        if (String.isNotEmpty(source) && source != 'null') {
            if (String.isEmpty(countryCode)) { countryCode = 'pl'; }
            dataId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        }

        String docName = getDocName(countryCode, doc, language, implKey);
        List<StaticResource> documents = getStaticResources(docName);

        if (documents.size() > 0) {
            content = documents.get(0).Body.toString();

            doSelectObjects();
            checkRender(doc, implKey);
            setStyle();
            setContentMap();

            mergeContent(currentOpportunity.getPopulatedFieldsAsMap(), 'currentOpportunity');
            mergeContent(dataObject.getPopulatedFieldsAsMap(), 'dataObject');
            mergeContent(dataContactPrimary.getPopulatedFieldsAsMap(), 'dataContactPrimary');
            //delete variables without any value
            content = content.replaceAll('(\\{!.*?\\})', '');
        }
        return content == null ? '' : content;
    }

    public static void mergeContent (Map<String, Object> valuesByFieldsMap, String prefix) {
        for (String key : valuesByFieldsMap.keySet()) {
            String reg = '(?i)(\\{!' + prefix + '.' + key + '\\})';
            content = content.replaceAll(reg, String.valueOf(valuesByFieldsMap.get(key)));
            //logic to prefill fields for nested objects like currentOpportunity.Account.
            //checking added to avoid processing of unused cases (reduce time to process)
            if (prefix == 'currentOpportunity' && key == 'Account') {
                try {
                    System.debug('mergeContent key === ' + key);
                    System.debug('valuesByFieldsMap.get(key) == ' + valuesByFieldsMap.get(key));
                    String serializedValue = JSON.serialize(valuesByFieldsMap.get(key));
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(serializedValue);
                    mergeContent(m, prefix + '.' + key);
                } catch (Exception e) {
                    // System.debug('e === ' + e);
                }
            }
        }
    }

    public static void doSelectObjects () {
        if (dataId != null) {
            dataObject = e2eDatabase.retrieveETEDataObject(dataId);
            dataContactPrimary = e2eDatabase.retrieveETEPrimaryContact(dataId);
            if (dataContactPrimary == null) {
                dataContactPrimary = new E2E_Data_Contact__c();
            }
            List<Opportunity> listOpportunities = [
                    SELECT  Id, Name, Name_of_the_payer_Account_holder__c, 
                            IBAN__c, SWIFT_BIC__c, Security_To_Pay__c,
                            Security_Amount_To_Pay__c, SEPA_Request_Approval_Date__c, Date_For_Agree_To_Deposit_Agreement__c, 
                            Credit_check_date__c, Number_of_electric_vehicles__c, Device_Type__c, 
                            Direct_Debit_Mandate_Type__c, Registered_Country__c,
                            Account.Name, Account.BillingCountryCode, Account.BillingCountry, 
                            Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, 
                            Account.IBAN__c, Account.SWIFT_BIC__c, Account.Steuernummer__c,
                            Account.Ort_der_Registrierung_Handelsregisterort__c, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, 
                            Account.UMR__c, Account.Umsatzsteuer_ID__c
                    FROM    Opportunity
                    WHERE   E2E_Data_Object__c =: dataId
                    LIMIT   1
            ];

            if ( !listOpportunities.isEmpty() ) {
                currentOpportunity = listOpportunities.get(0);
            }

            if (currentOpportunity.Account.UMR__c != null) {
                List<String> umrDigitsList = currentOpportunity.Account.UMR__c.split('');
                String umr = '';
                for (String d : umrDigitsList) {
                    umr += '<span style="width: 20px; float: left;">' + d + '</span>';
                }
                contentMap.put('{!umr}', umr);
            }

            contentMap.put('{!fullName}', dataContactPrimary.First_Name__c + ' ' + dataContactPrimary.Last_Name__c);
            contentMap.put('{!today}', Datetime.now().format('dd-MM-yyyy'));
            contentMap.put('{!securityAmountToPay}', getFormattedCurrency(dataObject.Security_Amount_To_Pay__c));
            contentMap.put('{!creditLimit}', getFormattedCurrency(dataObject.Credit_Limit__c));

            if (ApexPages.currentPage() != null) {
                Map<String, String> pageParamsMap = ApexPages.currentPage().getParameters();
                Map<String, Map<String, String>> userModelFieldsMapping = ETEGlobalUtils.returnUserModelFieldsMapping();
                //prefill data object fields from url params
                for (String nextPageParam : userModelFieldsMapping.get('data_object').keySet()) {
                    if (pageParamsMap.containsKey(nextPageParam)) {
                        String n = pageParamsMap.get(nextPageParam);
                        dataObject.put(userModelFieldsMapping.get('data_object').get(nextPageParam), n == 'null' ? '' : n);
                    }
                }
            }
        }
    }

    public static void checkRender (String doc, String implKey) {
        if (doc == 'documentsAgreement' && content.contains('<!-- depositAgreement -->')) {
            if (dataObject.Security_Amount_To_Pay__c == 0 ) {
                content = content.substring(0, content.indexOf('<!-- depositAgreement -->'));
            }
        }
        if (content.contains('<!-- image -->')) {
            showHeader = false;
            pageMargin = '0cm 0cm 0cm 0cm';
        }
        if (content.contains('<!-- hideHeader -->')) {
            showHeader = false;
        }
        if (content.contains('<!-- hideFooter -->')) {
            footer = '';
        }
        if (content.contains('<!-- pdf -->')) {
            newPage = new PageReference(content.remove('<!-- pdf -->'));
            newPage.setRedirect(true);
        }
        if (content.contains('<!-- pageMargin ') && content.contains(' pageMargin -->')) {
            Integer firstIndex = content.indexOf('<!-- pageMargin ') + '<!-- pageMargin '.length();
            Integer lastIndex = content.indexOf(' pageMargin -->');
            pageMargin = content.substring(firstIndex, lastIndex);
        }
        if (content.contains('<!-- productLogo ') && content.contains(' productLogo -->')) {
            Integer firstIndex = content.indexOf('<!-- productLogo ') + '<!-- productLogo '.length();
            Integer lastIndex = content.indexOf(' productLogo -->');
            productLogo = content.substring(firstIndex, lastIndex);
        }

        if (doc == 'documentsTermsAndConditions' && content.contains('<EV-Fob>') && content.contains('<Shell-Fuel-Card>')) {
            Map<String, E2E_Data_Product__c> e2eProductsMap = e2eDatabase.retrieveETEProducts(dataId);
            String fuelCardContent = getOfferItemContent(e2eProductsMap.values(), 'Shell Fuel Card', content );
            String evContent = getOfferItemContent(e2eProductsMap.values(), 'EV Fob', content );

            if (fuelCardContent != null && evContent != null) {
                evContent = '<div style="page-break-before: always;">' + evContent + '</div>';
            }

            content = '';
            content += fuelCardContent != null ? fuelCardContent : ''; 
            content += evContent != null ? evContent : ''; 
        }
    }

    public static String getOfferItemContent(List<E2E_Data_Product__c> e2eProductsList, String offerItemTypeName, String content){
        String result;

        for(E2E_Data_Product__c product : e2eProductsList){
            if(product.Type_Name__c == offerItemTypeName){
                String tagName = String.join(offerItemTypeName.split(' '), '-');
                result = content.substringBetween('<' + tagName + '>','</' + tagName + '>');
                break;
            }
        }
        
        return result;
    }

    public static void setStyle () {
        if (content.contains('<style>') && content.contains('</style>')) {
            Integer indexStart = content.indexOf('<style>') + '<style>'.length();
            Integer indexEnd = content.indexOf('</style>');
            style = content.substring(indexStart, indexEnd);
            content = content.remove(style);
            content = content.remove('<style></style>');
        }
    }

    public static void setContentMap () {
        for (String key : contentMap.keySet()) {
            if (contentMap.get(key) != null && contentMap.get(key) != 'null') {
                content = content.replace(key, contentMap.get(key));
            }
        }
    }

    public static String getDocName (String countryCode, String doc, String language, String implKey) {
        Map<String, Object> untypedSettings = e2eDatabase.getSettings(implKey, countryCode);
        Map<String, Object> eteDocumentsByName = (Map<String, Object>) untypedSettings.get('eteDocuments');
        Map<String, Object> documentVariantByLanguage = (Map<String, Object>) eteDocumentsByName.get(doc);
        return String.valueOf(documentVariantByLanguage.get(language));
    }

    public static String getFormattedCurrency (Decimal dec) {
        String result = '';
        String separator = ' ';

        if (dec != null) {
            List<String> arr = String.valueOf(dec).split('');
            for (Integer i = arr.size() - 1; i >= 0; i--) {
                result = arr[i] + result;
                if (Math.mod(arr.size() - i, 3) == 0) {
                    result = separator + result;
                }
            }

            if (result.indexOf(separator) == 0) {
                result = result.substring(1);
            }
        }

        return result;
    }

    public static List<StaticResource> getStaticResources (String resourcesName) {
        List<StaticResource> resultList = new List<StaticResource>();
        if (Test.isRunningTest()) {
            resultList = ETEDocumentsCtrlTest.getStaticResources(resourcesName);
        } else {
            resultList = [
                    SELECT  Body, Name, ContentType
                    FROM    StaticResource
                    WHERE   Name =: resourcesName
            ];
        }

        return resultList;
    }
}
/* Markers you can use in documents static resources
1.  Description: to show product logo in header of the document
    Example: <!-- productLogo <img src="/resource/ete_images/logo_lotos.png" height="17"/> productLogo -->

2.  Description: to show pdf document instead of eteDocument page
    Example: <!-- pdf -->/resource/ete_images/TermsAndConditions_PL_lotos.pdf

3.  Description: to hide document header and show an image on a page without borders
    Example: <!-- image --><img src="/resource/ETE_DOCUMENTS_2/priceList_PL.png" width="100%"/>
**/