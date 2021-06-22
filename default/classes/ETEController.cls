public without sharing class ETEController {
    public String settings {get; private set;}
    public String content {get; private set;}
    public String userModel {get; private set;}
    public ETEAssets scripts {get; private set;}


    public void runLongFormPL() {
        init('pl', 'Poland');
    }

    public void runLongFormLotosPL() {
        init('pl', 'Poland Lotos');
    }

    public void runLongFormDE() {
        init('de', 'Germany');
    }

    public void runLongFormNL() {
        init('nl', 'Netherlands');
    }

    public void runLongFormBENL() {
        init('benl', 'Belgium-NL');
    }

    public void runLongFormBEFR() {
        init('befr', 'Belgium-FR');
    }

    public void runLongFormHU() {
        init('hu', 'Hungary');
    }

    public void runLongFormSK() {
        init('sk', 'Slovakia');
    }

    public void runLongFormCcsSK() {
        init('sk', 'Slovakia CCS');
    }

    public void runLongFormCZ() {
        init('cz', 'Czech Republic');
    }

    public void runLongFormCcsCZ() {
        init('cz', 'Czech Republic CCS');
    }

    public void runLongFormFR() {
        init('fr', 'France');
    }

    public void runLongFormCHDE() {
        init('chde', 'Switzerland-DE');
    }

    public void runLongFormCHFR() {
        init('chfr', 'Switzerland-FR');
    }
    public void runLongFormAT() {
        init('at', 'Austria');
    }

     public void runLongFormLU() {
        init('lu', 'Luxembourg');
    }


    private void init(String countryCode, String implKey) {
        ETEResponseHandler responseHandler = new ETEResponseHandler();
        try {
            Map<String, String> pageParamsMap = new Map<String, String>();
            if (ApexPages.currentPage() != null) {
                pageParamsMap = ApexPages.currentPage().getParameters();
            }
            String source = pageParamsMap.containsKey('source') ? pageParamsMap.get('source') : null;
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
            ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
            Map<String, Object> untypedSettings = e2eDatabase.getSettings(implKey, countryCode);
            List<String> availableStepsList = e2eStep.getAvailableSteps(untypedSettings, null);
            E2E_Data_Object__c currentDataObject;
            List<E2E_Data_Contact__c> currentContactsList = new List<E2E_Data_Contact__c>();
            Map<String, E2E_Data_Product__c> currentETEProductsMap = new Map<String, E2E_Data_Product__c>();
            Map<String, E2E_Data_Offer_Item__c> currentETEOfferItemsMap = new Map<String, E2E_Data_Offer_Item__c>();
            Map<String, E2E_Data_Locator_Item__c> currentETELocatorItemsMap = new Map<String, E2E_Data_Locator_Item__c>();
            List<E2E_Data_Additional_Service__c> currentAdditionalServicesList = new List<E2E_Data_Additional_Service__c>();
            if (source != null) {
                String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
                currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
                currentContactsList = e2eDatabase.retrieveETEContacts(dataObjectId);
                currentETEProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
                currentETEOfferItemsMap = e2eDatabase.retrieveETEOfferItems(currentETEProductsMap.keySet());
                currentETELocatorItemsMap = e2eDatabase.retrieveETELocatorItems(currentETEProductsMap.keySet());
                currentAdditionalServicesList = e2eDatabase.retrieveAdditionalServices(dataObjectId);
            } else {
                ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(implKey);
                currentDataObject = businessObjectsHandler.initDataObject(availableStepsList, countryCode, implKey);
                if (pageParamsMap.containsKey('utm_products')) {
                    currentDataObject.Utm_Products__c = ETEGlobalUtils.doDecryptParams(pageParamsMap.get('utm_products'), countryCode);
                }
            }
            e2eStep.setExistingDataObject(currentDataObject);
            e2eStep.setExistingContacts(currentContactsList);
            e2eStep.setExistingETEProducts(currentETEProductsMap);
            e2eStep.setExistingETEOfferItems(currentETEOfferItemsMap);
            e2eStep.setExistingETELocatorItems(currentETELocatorItemsMap);
            e2eStep.setExistingAdditionalServices(currentAdditionalServicesList);

            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap = e2eStep.generateExistingLogsMap(e2eDatabase, source);
            Map<String, Map<String, Object>> stepDependenciesMap = e2eStep.returnStepDependencies(untypedSettings);
            if (pageParamsMap.containsKey('rep_ord')) {
                currentDataObject = e2eStep.returnInE2EProcessAfterReceivingReport(e2eDatabase, currentDataObject, existingLogsMap, availableStepsList);
            }
            Map<String, Object> filtersOfAvailableStepsMap = new Map<String, Object>();
            filtersOfAvailableStepsMap.put('securityAmountToPay', currentDataObject.Security_Amount_To_Pay__c);
            filtersOfAvailableStepsMap.put('selectedCompanyId', currentDataObject.Selected_Company_Id__c);
            filtersOfAvailableStepsMap.put('paymentMethod', currentDataObject.Payment_Method__c);
            filtersOfAvailableStepsMap.put('product', currentETEProductsMap.values());
            List<String> eteSteps = e2eStep.getAvailableSteps(untypedSettings, filtersOfAvailableStepsMap);
            scripts = new ETEAssets(implKey, eteSteps, currentDataObject.Current_Step__c);
            List<ETEUserModel.NavigationMenuStep> navigationMenuSteps = e2eStep.getNavigationMenuSteps(untypedSettings, eteSteps);
            List<String> availableStepsForCustomerList = e2eStep.getAvailableStepsForCustomer(currentDataObject,
                                                                                            eteSteps,
                                                                                            existingLogsMap,
                                                                                            stepDependenciesMap);
            ETEUserModel preFinalUserModel = e2eStep.convertToUserModel(availableStepsForCustomerList, navigationMenuSteps);
            Map<String, Object> finalUserModel = e2eStep.prepareFinalUserModelToFrontend(preFinalUserModel);
            Map<String, Object> settingsMap = e2eStep.prepareFinalSettingsToFrontend(untypedSettings);
            Map<String, Object> contentMap = e2eDatabase.getContent(implKey, countryCode, settingsMap);
            settings = responseHandler.convertResponseToJson(settingsMap);
            userModel = responseHandler.convertResponseToJson(finalUserModel);
            content = responseHandler.convertResponseToJson(contentMap);

            for (StaticResource next : [SELECT Name, SystemModstamp FROM StaticResource WHERE Name IN ('ete_images', 'ETE_DOCUMENTS_1', 'ETE_DOCUMENTS_2')]) {
                String path = '/resource/' + String.valueOf(((Datetime)next.get('SystemModStamp')).getTime()) + '/' + next.Name;
                content = content.replace('/resource/' + next.Name, path);
                settings = settings.replace('/resource/' + next.Name, path);
            }
        } catch (Exception e) {
            Map<String, Object> exceptionResponseParams = responseHandler.generateResponseStatus(e.getMessage());
            String exceptionResponseJson = responseHandler.convertResponseToJson(exceptionResponseParams);
//            return exceptionResponseJson;
        }
    }
}