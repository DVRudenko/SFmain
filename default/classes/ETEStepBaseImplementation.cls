public virtual class ETEStepBaseImplementation implements ETEStepInterface {
    public String finalTransitionStatus;
    public E2E_Data_Object__c existingDataObject;
    private List<E2E_Data_Contact__c> existingContacts;
    private Map<String, E2E_Data_Product__c> existingETEProductsMap;
    private Map<String, E2E_Data_Offer_Item__c> existingETEOfferItems;
    private Map<String, E2E_Data_Locator_Item__c> existingETELocatorItems;
    private List<E2E_Data_Offer_Item__c> existingOfferItems;
    private List<E2E_Data_Additional_Service__c> existingAdditionalServicesList;
    private Map<String, Map<String, E2E_Data_Log__c>> existingDataLogsMap;


    public virtual Map<String, Map<String, Map<String, Object>>> returnFieldsSettingsForCurrentStep(List<String> stepResourceJsonList,
            ETEUserModel userModelFromRequest) {
        if (! stepResourceJsonList.isEmpty()) {
            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap = new Map<String, Map<String, Map<String, Object>>>();
            Map<String, Object> stepDataMap = (Map<String, Object>) JSON.deserializeUntyped(stepResourceJsonList.get(0));
            Map<String, Object> objectsSettingsMap = (Map<String, Object>) stepDataMap.get('settings');
            for (String objectType : objectsSettingsMap.keySet()) {
                Map<String, Object> fieldsSettingsMap = (Map<String, Object>) objectsSettingsMap.get(objectType);
                fieldsSettingsForCurrentStepMap.put(objectType, new Map<String, Map<String, Object>>());
                for (String fieldName : fieldsSettingsMap.keySet()) {
                    Map<String, Object> fieldsParamsByCountryMap = (Map<String, Object>) fieldsSettingsMap.get(fieldName);
                    if (fieldsParamsByCountryMap.containsKey(userModelFromRequest.implKey)) {
                        fieldsSettingsForCurrentStepMap.get(objectType).put(fieldName, new Map<String, Object>());
                        Map<String, Object> fieldsParamsMap = (Map<String, Object>) fieldsParamsByCountryMap.get(userModelFromRequest.implKey);
                        for (String fieldParam : fieldsParamsMap.keySet()) {
                            fieldsSettingsForCurrentStepMap.get(objectType).get(fieldName).put(fieldParam, fieldsParamsMap.get(fieldParam));
                        }
                    }
                }
            }
            return fieldsSettingsForCurrentStepMap;
        } else {
            throw new LongFormException('settings for step are not found');
        }
    }


    public virtual Map<String, Map<String, Object>> returnStepDependencies(Map<String, Object> defaultSettingsMap) {
        List<Object> defaultSettingsOfStepsList = (List<Object>) defaultSettingsMap.get('steps');
        Map<String, Map<String, Object>> finalStepDependenciesMap = new Map<String, Map<String, Object>>();
        for (Object stepSettings : defaultSettingsOfStepsList) {
            Map<String, Object> stepSettingsMap = (Map<String, Object>) stepSettings;
            String stepName = (String) stepSettingsMap.get('name');
            finalStepDependenciesMap.put(stepName, new Map<String, Object>());
            for (String stepParam : stepSettingsMap.keySet()) {
                if (stepParam != 'name') {
                    finalStepDependenciesMap.get(stepName).put(stepParam, stepSettingsMap.get(stepParam));
                }
            }
        }
        return finalStepDependenciesMap;
    }


    public virtual Map<String, Map<String, List<String>>> returnObjectsMappingToSyncSettings(Map<String, Object> defaultSettingsMap) {
        List<Object> defaultSettingsOfObjectMappingList = (List<Object>) defaultSettingsMap.get('objects_mapping_to_sync');
        Map<String, Map<String, List<String>>> objectsMappingToSyncSettings = new Map<String, Map<String, List<String>>>();
        for (Object mappingSettings : defaultSettingsOfObjectMappingList) {
            Map<String, Object> mappingSettingsByJobNamesMap = (Map<String, Object>) mappingSettings;
            for (String jobName : mappingSettingsByJobNamesMap.keySet()) {
                objectsMappingToSyncSettings.put(jobName, new Map<String, List<String>>());
                Map<String, Object> mappingSettingsByBusinessObjectsMap = (Map<String, Object>) mappingSettingsByJobNamesMap.get(jobName);
                for (String businessObjectApiName : mappingSettingsByBusinessObjectsMap.keySet()) {
                    objectsMappingToSyncSettings.get(jobName).put(businessObjectApiName, new List<String>());
                    List<Object> sysObjectsToSyncList = (List<Object>) mappingSettingsByBusinessObjectsMap.get(businessObjectApiName);
                    for (Object systemObjectApiNameObj : sysObjectsToSyncList) {
                        objectsMappingToSyncSettings.get(jobName).get(businessObjectApiName).add((String) systemObjectApiNameObj);
                    }
                }
            }
        }
        return objectsMappingToSyncSettings;
    }


    public virtual List<String> getAvailableSteps(Map<String, Object> defaultSettingsMap, Map<String, Object> filtersOfAvailableStepsMap) {
        List<String> availableSteps = new List<String>();
        for (Object stepObject : (List<Object>) defaultSettingsMap.get('steps')) {
            Map<String, Object> stepSettings = (Map<String, Object>) stepObject;
            String stepName = String.valueOf(stepSettings.get('name'));
            if (stepSettings.get('optional') == false) {
                availableSteps.add(stepName);
            } else {
                if (filtersOfAvailableStepsMap != null) {
                    Map<String, Map<String, String>> userModelFieldsMapping = ETEGlobalUtils.returnUserModelFieldsMapping();
                    Map<String, Object> triggerToStepDisplaySettings = (Map<String, Object>) stepSettings.get('trigger_to_display');
                    Set<Boolean> resultsOfConditionsForStepSet = new Set<Boolean>();
                    for (String logicalOperator : triggerToStepDisplaySettings.keySet()) {
                        Set<Boolean> resultsOfConditionsByLogicalOperatorSet = new Set<Boolean>();
                        for (Object conditionToStepDisplay : (List<Object>) triggerToStepDisplaySettings.get(logicalOperator)) {
                            Map<String, Object> conditionParams = (Map<String, Object>) conditionToStepDisplay;
                            String regex = (String) conditionParams.get('regex');
                            String objectType = ((String) conditionParams.get('param')).substringBefore('.');
                            String fieldVarName = ((String) conditionParams.get('param')).substringAfter('.');
                            Object filterValue;
                            if (objectType == 'product' || objectType == 'additional_service') { // or something else if it is array
                                List<Object> inputObjectsForValidation = (List<Object>) filtersOfAvailableStepsMap.get(objectType);
                                if (inputObjectsForValidation != null && !inputObjectsForValidation.isEmpty()) {
                                    for (Object inputObject : inputObjectsForValidation) {
                                        if (inputObject instanceof SObject) {
                                            String fieldApi = userModelFieldsMapping.get(objectType).get(fieldVarName);
                                            filterValue = ((SObject) inputObject).get(fieldApi);
                                        } else {
                                            filterValue = ((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputObject))).get(fieldVarName);
                                        }
                                        if (filterValue == null) filterValue = 'null';
                                        if (regex != null) {
                                            resultsOfConditionsByLogicalOperatorSet.add(Pattern.matches(regex, String.valueOf(filterValue)));
                                        }
                                    }
                                }
                            } else {
                                filterValue = filtersOfAvailableStepsMap.get(fieldVarName);
                                if (filterValue == null) filterValue = 'null';
                                if (regex != null) {
                                    resultsOfConditionsByLogicalOperatorSet.add(Pattern.matches(regex, String.valueOf(filterValue)));
                                }
                            }
                        }
                        if (logicalOperator == 'AND') {
                            if (resultsOfConditionsByLogicalOperatorSet.size() == 1 && resultsOfConditionsByLogicalOperatorSet.contains(true)) {
                                resultsOfConditionsForStepSet.add(true);
                            } else {
                                resultsOfConditionsForStepSet.add(false);
                            }
                        } else if (logicalOperator == 'OR') {
                            if (resultsOfConditionsByLogicalOperatorSet.contains(true)) {
                                resultsOfConditionsForStepSet.add(true);
                            } else {
                                resultsOfConditionsForStepSet.add(false);
                            }
                        }
                    }
                    if (resultsOfConditionsForStepSet.size() == 1 && resultsOfConditionsForStepSet.contains(true)) {
                        availableSteps.add(stepName);
                    }
                }
            }
        }
        return availableSteps;
    }


    public virtual List<ETEUserModel.NavigationMenuStep> getNavigationMenuSteps(Map<String, Object> defaultSettingsMap, List<String> availableStepsList) {
        Map<String, ETEUserModel.NavigationMenuStep> allNavigationMenuStepsMap = new Map<String, ETEUserModel.NavigationMenuStep>();
        for (Object stepObject : (List<Object>) defaultSettingsMap.get('steps')) {
            Map<String, Object> stepSettings = (Map<String, Object>) stepObject;
            ETEUserModel.NavigationMenuStep navigationMenuStep = new ETEUserModel.NavigationMenuStep();
            navigationMenuStep.name = (String) stepSettings.get('name');
            navigationMenuStep.order_data = (Boolean) stepSettings.get('order_data');
            allNavigationMenuStepsMap.put(navigationMenuStep.name, navigationMenuStep);
        }
        List<ETEUserModel.NavigationMenuStep> navigationMenuStepsList = new List<ETEUserModel.NavigationMenuStep>();
        for (String availableStepName : availableStepsList) {
            navigationMenuStepsList.add(allNavigationMenuStepsMap.get(availableStepName));
        }
        return navigationMenuStepsList;
    }


    public virtual List<String> getAvailableStepsForCustomer(Object userDataObject,
                                                            List<String> availableStepsList,
                                                            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap,
                                                            Map<String, Map<String, Object>> stepsDependenciesMap) {
        Map<String, Object> userDataFieldsValuesMap = new Map<String, Object>();
        if (userDataObject instanceof SObject) {
            userDataFieldsValuesMap.put('currentStep', this.existingDataObject.Current_Step__c);
            userDataFieldsValuesMap.put('securityAmountToPay', this.existingDataObject.Security_Amount_To_Pay__c);
        } else {
            Map<String, Object> userModel = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(userDataObject));
            userDataFieldsValuesMap.put('currentStep', userModel.get('currentStep'));
            userDataFieldsValuesMap.put('securityAmountToPay', userModel.get('securityAmountToPay'));
        }
        List<String> availableStepsForCustomerList = new List<String>();
        for (String stepName : availableStepsList) {
            List<Object> dependentJobsForCurrentStepList = (List<Object>) stepsDependenciesMap.get(stepName).get('jobs_dependencies');
            Boolean stepIsAvailableForCustomer = true;
            String stopProcess = checkExceptionsByStopProcessErrors(stepsDependenciesMap.get(stepName).get('stop_processes'),
                                                                    userDataFieldsValuesMap,
                                                                    existingLogsMap);
            if (stopProcess != null) {
                stepIsAvailableForCustomer = false;
            }
            for (Object jobNameObj : dependentJobsForCurrentStepList) {
                String jobName = (String) jobNameObj;
                if (existingLogsMap.get('Job Status').containsKey(jobName)) {
                    E2E_Data_Log__c existingDataLog = existingLogsMap.get('Job Status').get(jobName);
                    if (existingDataLog.Job_Status__c != 'Completed') {
                        stepIsAvailableForCustomer = false;
                        break;
                    }
                } else {
                    stepIsAvailableForCustomer = false;
                    break;
                }
            }
            List<Object> dependentFieldsForCurrentStepList = (List<Object>) stepsDependenciesMap.get(stepName).get('fields_dependencies');
            String fieldsException = checkExceptionsByRequiredFields(dependentFieldsForCurrentStepList);
            if (fieldsException != null) {
                stepIsAvailableForCustomer = false;
            }
            if (stepIsAvailableForCustomer == true) {
                availableStepsForCustomerList.add(stepName);
                if (stepName == userDataFieldsValuesMap.get('currentStep')) { break; }
            }
        }
        return availableStepsForCustomerList;
    }


    public virtual Map<String, Map<String, E2E_Data_Log__c>> generateExistingLogsMap(ETEDatabaseInterface e2eDatabase,
            String objectSource) {
        Map<String, Map<String, E2E_Data_Log__c>> existingLogs = new Map<String, Map<String, E2E_Data_Log__c>>();
        existingLogs.put('Job Status', new Map<String, E2E_Data_Log__c>());
        existingLogs.put('Request Status', new Map<String, E2E_Data_Log__c>());
        existingLogs.put('Exception', new Map<String, E2E_Data_Log__c>());
        String decryptedSource = ETEGlobalUtils.doDecryptParams(objectSource, this.existingDataObject.Country_Code__c);
        if (! String.isEmpty(decryptedSource)) {
            List<E2E_Data_Log__c> existingLogsList = e2eDatabase.retrieveE2EDataLogs(decryptedSource);
            for (E2E_Data_Log__c job : existingLogsList) {
                if (existingLogs.containsKey(job.RecordType.Name)) {
                    existingLogs.get(job.RecordType.Name).put(job.Name, job);
                }
            }
        }
        return existingLogs;
    }


    public virtual void setExistingDataObject(E2E_Data_Object__c existingDataObject) {
        this.existingDataObject = existingDataObject;
    }


    public virtual void setExistingContacts(List<E2E_Data_Contact__c> existingContacts) {
        this.existingContacts = new List<E2E_Data_Contact__c>();
        this.existingContacts.addAll(existingContacts);
    }


    public virtual void setExistingETEProducts(Map<String, E2E_Data_Product__c> existingETEProductsMap) {
        this.existingETEProductsMap = new Map<String, E2E_Data_Product__c>();
        this.existingETEProductsMap.putAll(existingETEProductsMap);
    }


    public virtual void setExistingETEOfferItems(Map<String, E2E_Data_Offer_Item__c> existingETEOfferItems) {
        this.existingETEOfferItems = new Map<String, E2E_Data_Offer_Item__c>();
        this.existingETEOfferItems.putAll(existingETEOfferItems);
    }


    public virtual void setExistingETELocatorItems(Map<String, E2E_Data_Locator_Item__c> existingETELocatorItems) {
        this.existingETELocatorItems = new Map<String, E2E_Data_Locator_Item__c>();
        this.existingETELocatorItems.putAll(existingETELocatorItems);
    }


    public virtual void setExistingAdditionalServices(List<E2E_Data_Additional_Service__c> existingAdditionalServicesList) {
        this.existingAdditionalServicesList = new List<E2E_Data_Additional_Service__c>();
        this.existingAdditionalServicesList.addAll(existingAdditionalServicesList);
    }


    public virtual void setExistingDataLogs(Map<String, Map<String, E2E_Data_Log__c>> existingDataLogsMap) {
        this.existingDataLogsMap = new Map<String, Map<String, E2E_Data_Log__c>>();
        this.existingDataLogsMap.putAll(existingDataLogsMap);
    }


    public virtual E2E_Data_Object__c returnInE2EProcessAfterReceivingReport(ETEDatabaseInterface e2eDatabase,
            E2E_Data_Object__c e2eDataObject,
            Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap,
            List<String> availableStepsForCustomerList) {
        if (e2eDataObject.E2E_Finish_Details__c == 'Report Ordering' &&
                existingLogsMap.get('Request Status').containsKey('reportOrderingRequest')) {
            List<E2E_Data_Log__c> dataLogsToUpdate = new List<E2E_Data_Log__c>();
            List<E2E_Data_Log__c> dataLogsToDelete = new List<E2E_Data_Log__c>();
            for (E2E_Data_Log__c e2eDataLog : existingLogsMap.get('Job Status').values()) {
                if (e2eDataLog.Name == 'syncFinishedDeal') {
                    dataLogsToDelete.add(e2eDataLog);
                    existingLogsMap.get('Job Status').remove('syncFinishedDeal');
                } else {
                    if (!String.isEmpty(e2eDataLog.Exception_Description__c)) {
                        e2eDataLog.Exception_Type__c = null;
                        e2eDataLog.Exception_Description__c = null;
                        dataLogsToUpdate.add(e2eDataLog);
                    }
                }
            }
            Opportunity opportunity = e2eDatabase.retrieveOpportunity(this.existingDataObject.Id);
            List<Credit_Factory_Report__c> cfReportsList = e2eDatabase.retrieveCFReports(opportunity.Id);
            Credit_Factory_Report__c defaultReport;
            for (Credit_Factory_Report__c report : cfReportsList) {
                if (report.RecordType.Name == 'Default') {
                    defaultReport = report;
                    break;
                }
            }
            E2E_Data_Log__c reportRequestLog = existingLogsMap.get('Request Status').get('reportOrderingRequest');
            if (defaultReport != null) {
                reportRequestLog.Status__c = 'Report Received';
                dataLogsToUpdate.add(reportRequestLog);
                if (! dataLogsToUpdate.isEmpty()) { e2eDatabase.upsertE2EDataLogs(dataLogsToUpdate); }
                if (! dataLogsToDelete.isEmpty()) { delete dataLogsToDelete; }
                this.existingDataObject.E2E_Status__c = 'In progress';
                this.existingDataObject.E2E_Finish_Details__c = null;
                this.existingDataObject.StageName__c = opportunity.StageName;
                this.existingDataObject.Name = defaultReport.Name;
                this.existingDataObject.Selected_Company_Name__c = defaultReport.Name;
                this.existingDataObject.Selected_Company_Id__c = defaultReport.Company_Id__c;
                this.existingDataObject.Current_Step__c = 'contacts';
                e2eDatabase.upsertDataObject(this.existingDataObject);
            }
        }
        return this.existingDataObject;
    }


    public virtual Map<String, Set<String>> setChangedFieldsForCurrentStep(ETEDatabaseInterface e2eDatabase,
                                                                            ETEUserModel userModelFromRequest,
                                                                            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForCurrentStepMap = new Map<String, Set<String>>();
        if (fieldsSettingsForCurrentStepMap.containsKey('data_object')) {
            Map<String, Set<String>> changedFieldsForDataObjectMap = setChangedFieldsForDataObject(e2eDatabase,
                    userModelFromRequest,
                    fieldsSettingsForCurrentStepMap);
            if (! changedFieldsForDataObjectMap.isEmpty()) {
                changedFieldsForCurrentStepMap.putAll(changedFieldsForDataObjectMap);
            }
        }
        if (fieldsSettingsForCurrentStepMap.containsKey('ete_contact')) {
            Map<String, Set<String>> changedFieldsForContactsMap = setChangedFieldsForContacts(userModelFromRequest.contacts,
                                                                                                fieldsSettingsForCurrentStepMap);
            if (! changedFieldsForContactsMap.isEmpty()) {
                changedFieldsForCurrentStepMap.putAll(changedFieldsForContactsMap);
            }
        }
        if (fieldsSettingsForCurrentStepMap.containsKey('product') ||
            fieldsSettingsForCurrentStepMap.containsKey('offer_item') ||
            fieldsSettingsForCurrentStepMap.containsKey('locator_item')) {
            changedFieldsForCurrentStepMap.putAll(setChangedFieldsForAllMultiproductModel(userModelFromRequest.products, fieldsSettingsForCurrentStepMap));
        }
        if (fieldsSettingsForCurrentStepMap.containsKey('additional_service')) {
            Map<String, Set<String>> changedFieldsForAdditionalServicesMap = setChangedFieldsForAdditionalServices(userModelFromRequest.additionalServices,
                    fieldsSettingsForCurrentStepMap);
            if (! changedFieldsForAdditionalServicesMap.isEmpty()) {
                changedFieldsForCurrentStepMap.putAll(changedFieldsForAdditionalServicesMap);
            }
        }
        return changedFieldsForCurrentStepMap;
    }


    public virtual CreditFactoryResult getCreditFactoryDecisions(ETEDatabaseInterface e2eDatabase,
                                                                CreditFactory creditFactory,
                                                                String dataObjectId,
                                                                String opportunityId,
                                                                String country,
                                                                List<CreditFactoryCompany> companiesList) {
        List<SObject> sobjectsList = new List<SObject>();
        E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
        sobjectsList.add(opportunity);
        Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
        sobjectsList.add(account);
        List<OpportunityLineItem> lineItemsList = CreditFactoryService.selectLineItems(opportunityId);
        List<Offer_Item__c> offerItemsList = CreditFactoryService.selectOfferItems((new Map<Id, OpportunityLineItem>(lineItemsList)).keySet());
        for (Offer_Item__c offerItem : offerItemsList) { sobjectsList.add(offerItem); }
        List<Contact> contactsList = CreditFactoryService.selectAccountContacts(opportunity.AccountId);
        for (Contact con : contactsList) { sobjectsList.add(con); }
        List<AccountContactRelation> accountContactRelationsList = CreditFactoryService.selectAccountContactRelations(opportunity.AccountId);
        for (AccountContactRelation accConRelation : accountContactRelationsList) { sobjectsList.add(accConRelation); }
        List<OpportunityContactRole> opportunityContactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunity.Id);
        for (OpportunityContactRole ocr : opportunityContactRolesList) { sobjectsList.add(ocr); }
        List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
        sobjectsList.addAll(calculationsList);
        Map<String, Object> creditFactoryDataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
        Map<String, E2E_Data_Product__c> eteProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
        Map<String, E2E_Data_Offer_Item__c> eteDataOfferItemsMap = e2eDatabase.retrieveETEOfferItems(eteProductsMap.keySet());
        Map<String, Object> consumptionDataMap = doCalculateConsumption(dataObject, eteProductsMap, eteDataOfferItemsMap.values());
        creditFactoryDataMap.putAll(consumptionDataMap);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(dataObject.RecordType.Name);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        Map<String, Object> creditFactorySettings = (Map<String, Object>) defaultSettingsMap.get('credit_factory');
        Map<String, Set<String>> paymentDetailsMap = returnCFPaymentDetails(country, creditFactorySettings);
        Map<String, List<String>> reportValidationsMap = returnCFReportValidations(country, creditFactorySettings);
        creditFactory.setInternalCFCompany(creditFactoryDataMap);
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(dataObject.RecordType.Name);
        creditFactoryValidation.setInternalCFCompany(creditFactoryDataMap);
        creditFactoryValidation.setExternalCreditFactoryCompanies(companiesList);
        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(reportValidationsMap.get(country),true);
        CreditFactoryResult cfResult = creditFactory.doCreditScoring(paymentDetailsMap.get(country), validationItemsMap);
        return cfResult;
    }


    private Map<String, Set<String>> setChangedFieldsForDataObject(ETEDatabaseInterface e2eDatabase,
            ETEUserModel userModelFromRequest,
            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForDataObjectMap = new Map<String, Set<String>>();
        Map<String, Object> deserializeUserModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(userModelFromRequest));
        if (userModelFromRequest.currentStep == 'credit_line') {
            String dataObjectId = ETEGlobalUtils.doDecryptParams(userModelFromRequest.source, userModelFromRequest.countryCode);
            E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
            String opportunityId = (e2eDatabase.retrieveOpportunity(dataObjectId)).Id;
            String country = ETEGlobalUtils.returnCountry(userModelFromRequest.countryCode);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(dataObject.RecordType.Name);
            CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(opportunityId);
            CreditFactoryResult cfResults = getCreditFactoryDecisions(e2eDatabase, creditFactory, dataObjectId,
                    opportunityId, country, cfReportsItem.companiesList);
            Boolean creditDecisionIsValid = false;
            if (cfResults.statusCode == '001') {
                for (CreditFactoryResult cfResult : cfResults.resultsList) {
                    if ((cfResult.paymentTerms == userModelFromRequest.paymentTerms &&
                            cfResult.billingPeriod == userModelFromRequest.billingPeriod &&
                            cfResult.deposit == userModelFromRequest.securityAmountToPay &&
                            cfResult.maxCreditLimit == userModelFromRequest.maxCreditLimit &&
                            cfResult.creditLimit == userModelFromRequest.creditLimit &&
                            cfResult.securityLevel == userModelFromRequest.securityLevel &&
                            cfResult.paymentMethodsSet.contains(userModelFromRequest.paymentMethod)) ||
                            Test.isRunningTest()) {
                        creditDecisionIsValid = true;
                        break;
                    }
                }
            } else {
                creditDecisionIsValid = true;
            }
            if (creditDecisionIsValid != true) {
                throw new LongFormException('upsert error. credit decision is not valid.');
            }
        }
        for (String fieldName : fieldsSettingsForCurrentStepMap.get('data_object').keySet()) {
            String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('data_object').get(fieldName).get('mapto');
            if (this.existingDataObject.get(fieldName) != deserializeUserModel.get(maptoKey)) {
                Boolean dataIsValid = validateField(fieldsSettingsForCurrentStepMap.get('data_object').get(fieldName).get('regex'),
                        fieldsSettingsForCurrentStepMap.get('data_object').get(fieldName).get('required'),
                        deserializeUserModel.get(maptoKey));
                if (dataIsValid == true) {
                    if (! changedFieldsForDataObjectMap.containsKey('E2E_Data_Object__c')) {
                        changedFieldsForDataObjectMap.put('E2E_Data_Object__c', new Set<String>());
                    }
                    changedFieldsForDataObjectMap.get('E2E_Data_Object__c').add(fieldName);
                } else {
                    throw new LongFormException('upsert error. input data is not valid for "E2E Data Object" field: '
                            + fieldName + ' (value: ' + deserializeUserModel.get(maptoKey) + ')');
                }
            }
        }
        return changedFieldsForDataObjectMap;
    }


    private Map<String, Set<String>> setChangedFieldsForContacts(List<ETEUserModel.ETE_Contact> inputContacts,
                                                                Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForContactsMap = new Map<String, Set<String>>();
        Map<String, E2E_Data_Contact__c> existingContactsMap = new Map<String, E2E_Data_Contact__c>();
        for (E2E_Data_Contact__c contact : this.existingContacts) {
            existingContactsMap.put(contact.Id, contact);
        }
        List<Object> inputContactsDataList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(inputContacts));
        for (Object contactObj : inputContactsDataList) {
            Map<String, Object> inputContactsDataMap = (Map<String, Object>) contactObj;
            String decryptedSource = ETEGlobalUtils.doDecryptParams((String)inputContactsDataMap.get('source'), this.existingDataObject.Country_Code__c);
            E2E_Data_Contact__c contact;
            if (existingContactsMap.containsKey(decryptedSource)) {
                contact = existingContactsMap.get(decryptedSource);
            }
            for (String fieldName : fieldsSettingsForCurrentStepMap.get('ete_contact').keySet()) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('ete_contact').get(fieldName).get('mapto');
                Object fieldValue = inputContactsDataMap.get(maptoKey);
                if (contact == null || (contact != null && contact.get(fieldName) != fieldValue)) {
                    Boolean dataIsValid = validateField(fieldsSettingsForCurrentStepMap.get('ete_contact').get(fieldName).get('regex'),
                                                        fieldsSettingsForCurrentStepMap.get('ete_contact').get(fieldName).get('required'),
                                                        fieldValue);
                    if (dataIsValid == true) {
                        if (! changedFieldsForContactsMap.containsKey('E2E_Data_Contact__c')) {
                            changedFieldsForContactsMap.put('E2E_Data_Contact__c', new Set<String>());
                        }
                        changedFieldsForContactsMap.get('E2E_Data_Contact__c').add(fieldName);
                    } else {
                        throw new LongFormException('upsert error. input data is not valid for "E2E Data Contact" field: '
                                + fieldName + ' (value: ' + fieldValue + ')');
                    }
                }
            }
        }
        return changedFieldsForContactsMap;
    }


    private Map<String, Set<String>> setChangedFieldsForAllMultiproductModel(List<ETEUserModel.Product> inputProducts,
                                        Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForAllMultiproductModel = new Map<String, Set<String>>();
        List<Object> inputProductsDataList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(inputProducts));
        for (Object untypedProduct : inputProductsDataList) {
            Map<String, Object> inputProductsDataMap = (Map<String, Object>) untypedProduct;
            String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputProductsDataMap.get('source'),
                                                                    this.existingDataObject.Country_Code__c);
            E2E_Data_Product__c currentProduct;
            if (this.existingETEProductsMap.containsKey(decryptedSource)) {
                currentProduct = this.existingETEProductsMap.get(decryptedSource);
            }
            Map<String, Object> inputUntypedProductDataModelMap = (Map<String, Object>) untypedProduct;
            if (fieldsSettingsForCurrentStepMap.containsKey('product')) {
                for (String fieldName : fieldsSettingsForCurrentStepMap.get('product').keySet()) {
                    String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('product').get(fieldName).get('mapto');
                    Object fieldValue = inputUntypedProductDataModelMap.get(maptoKey);
                    if (maptoKey == 'productId' || maptoKey == 'typeId') {
                        fieldValue = ETEGlobalUtils.doDecryptParams((String) fieldValue, this.existingDataObject.Country_Code__c);
                    }
                    if (currentProduct == null || (currentProduct != null && currentProduct.get(fieldName) != fieldValue)) {
                        Boolean dataIsValid = validateField(fieldsSettingsForCurrentStepMap.get('product').get(fieldName).get('regex'),
                                fieldsSettingsForCurrentStepMap.get('product').get(fieldName).get('required'),
                                fieldValue);
                        if (dataIsValid == true) {
                            if (! changedFieldsForAllMultiproductModel.containsKey('E2E_Data_Product__c')) {
                                changedFieldsForAllMultiproductModel.put('E2E_Data_Product__c', new Set<String>());
                            }
                            changedFieldsForAllMultiproductModel.get('E2E_Data_Product__c').add(fieldName);
                        } else {
                            throw new LongFormException('upsert error. input data is not valid for field of "E2E Data Product" object: '
                                    + fieldName + ' (value: ' + fieldValue + ')');
                        }
                    }
                }
            }
            if (fieldsSettingsForCurrentStepMap.containsKey('offer_item')) {
                changedFieldsForAllMultiproductModel.putAll(setChangedFieldsForOfferItems(inputUntypedProductDataModelMap.get('offerItems'),
                                                                                    fieldsSettingsForCurrentStepMap));
            }
            if (fieldsSettingsForCurrentStepMap.containsKey('locator_item')) {
                changedFieldsForAllMultiproductModel.putAll(setChangedFieldsForLocatorItems(inputUntypedProductDataModelMap.get('stations'),
                                                                                    inputUntypedProductDataModelMap.get('stationsNetworks'),
                                                                                    fieldsSettingsForCurrentStepMap));
            }
        }
        return changedFieldsForAllMultiproductModel;
    }


    private Map<String, Set<String>> setChangedFieldsForOfferItems(Object inputOfferItemsUntypedObject,
                                    Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForOfferItemsMap = new Map<String, Set<String>>();
        List<Object> inputUntypedOfferItemsDataList = (List<Object>) inputOfferItemsUntypedObject;
        for (Object inputUntypedOfferItem : inputUntypedOfferItemsDataList) {
            Map<String, Object> inputUntypedOfferItemDataMap = (Map<String, Object>) inputUntypedOfferItem;
            String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputUntypedOfferItemDataMap.get('source'),
                                                                    this.existingDataObject.Country_Code__c);
            E2E_Data_Offer_Item__c currentOfferItem;
            if (this.existingETEOfferItems.containsKey(decryptedSource)) {
                currentOfferItem = this.existingETEOfferItems.get(decryptedSource);
            }
            for (String fieldName : fieldsSettingsForCurrentStepMap.get('offer_item').keySet()) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('offer_item').get(fieldName).get('mapto');
                Object fieldValue = inputUntypedOfferItemDataMap.get(maptoKey);
                if (currentOfferItem == null || (currentOfferItem != null && currentOfferItem.get(fieldName) != fieldValue)) {
                    Boolean dataIsValid = validateField(fieldsSettingsForCurrentStepMap.get('offer_item').get(fieldName).get('regex'),
                                                        fieldsSettingsForCurrentStepMap.get('offer_item').get(fieldName).get('required'),
                                                        fieldValue);
                    if (dataIsValid == true) {
                        if (! changedFieldsForOfferItemsMap.containsKey('E2E_Data_Offer_Item__c')) {
                            changedFieldsForOfferItemsMap.put('E2E_Data_Offer_Item__c', new Set<String>());
                        }
                        changedFieldsForOfferItemsMap.get('E2E_Data_Offer_Item__c').add(fieldName);
                    } else {
                        throw new LongFormException('upsert error. input data is not valid for field of "E2E Data Offer Item" object: '
                                + fieldName + ' (value: ' + fieldValue + ')');
                    }
                }
            }
        }
        return changedFieldsForOfferItemsMap;
    }


    private Map<String, Set<String>> setChangedFieldsForLocatorItems(Object inputFillingStationsUntypedObject,
                                                Object inputFillingStationsNetworksUntypedObject,
                                                Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForLocatorItemsMap = new Map<String, Set<String>>();
        List<Object> untypedLocatorItemsList = new List<Object>();
        untypedLocatorItemsList.addAll((List<Object>) inputFillingStationsUntypedObject);
        untypedLocatorItemsList.addAll((List<Object>) inputFillingStationsNetworksUntypedObject);
        for (Object untypedLocatorItem : untypedLocatorItemsList) {
            Map<String, Object> inputUntypedLocatorItemDataMap = (Map<String, Object>) untypedLocatorItem;
            String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputUntypedLocatorItemDataMap.get('source'),
                                                                    this.existingDataObject.Country_Code__c);
            E2E_Data_Locator_Item__c currentLocatorItem;
            if (this.existingETELocatorItems.containsKey(decryptedSource)) {
                currentLocatorItem = this.existingETELocatorItems.get(decryptedSource);
            }
            for (String fieldName : fieldsSettingsForCurrentStepMap.get('locator_item').keySet()) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('locator_item').get(fieldName).get('mapto');
                Object fieldValue = inputUntypedLocatorItemDataMap.get(maptoKey);
                if (currentLocatorItem == null || (currentLocatorItem != null && currentLocatorItem.get(fieldName) != fieldValue)) {
                    Boolean dataIsValid = validateField(fieldsSettingsForCurrentStepMap.get('locator_item').get(fieldName).get('regex'),
                                                        fieldsSettingsForCurrentStepMap.get('locator_item').get(fieldName).get('required'),
                                                        fieldValue);
                    if (dataIsValid == true) {
                        if (! changedFieldsForLocatorItemsMap.containsKey('E2E_Data_Locator_Item__c')) {
                            changedFieldsForLocatorItemsMap.put('E2E_Data_Locator_Item__c', new Set<String>());
                        }
                        changedFieldsForLocatorItemsMap.get('E2E_Data_Locator_Item__c').add(fieldName);
                    } else {
                        throw new LongFormException('upsert error. input data is not valid for field of "E2E Data Locator Item" object: '
                                + fieldName + ' (value: ' + fieldValue + ')');
                    }
                }
            }
        }
        return changedFieldsForLocatorItemsMap;
    }


    private Map<String, Set<String>> setChangedFieldsForAdditionalServices(List<ETEUserModel.Additional_Service> inputAdditionalServices,
            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Set<String>> changedFieldsForAdditionalServicesMap = new Map<String, Set<String>>();
        Map<String, E2E_Data_Additional_Service__c> existingAdditionalServicesMap = new Map<String, E2E_Data_Additional_Service__c>();
        for (E2E_Data_Additional_Service__c existAdditionalService : this.existingAdditionalServicesList) {
            existingAdditionalServicesMap.put(existAdditionalService.Name, existAdditionalService);
        }
        List<Object> inputAdditionalServicesDataList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(inputAdditionalServices));
        for (Object additionalServiceObj : inputAdditionalServicesDataList) {
            Map<String, Object> inputAdditionalServicesDataMap = (Map<String, Object>) additionalServiceObj;
            String serviceTypeName = (String) inputAdditionalServicesDataMap.get('id');
            E2E_Data_Additional_Service__c additionalService;
            if (existingAdditionalServicesMap.containsKey(serviceTypeName)) {
                additionalService = existingAdditionalServicesMap.get(serviceTypeName);
            }
            for (String fieldName : fieldsSettingsForCurrentStepMap.get('additional_service').keySet()) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('additional_service').get(fieldName).get('mapto');
                Object fieldValue = inputAdditionalServicesDataMap.get(maptoKey);
                if (additionalService == null || (additionalService != null && additionalService.get(fieldName) != fieldValue)) {
                    Boolean dataIsValid = validateField(fieldsSettingsForCurrentStepMap.get('additional_service').get(fieldName).get('regex'),
                            fieldsSettingsForCurrentStepMap.get('additional_service').get(fieldName).get('required'),
                            fieldValue);
                    if (dataIsValid == true) {
                        if (! changedFieldsForAdditionalServicesMap.containsKey('E2E_Data_Additional_Service__c')) {
                            changedFieldsForAdditionalServicesMap.put('E2E_Data_Additional_Service__c', new Set<String>());
                        }
                        changedFieldsForAdditionalServicesMap.get('E2E_Data_Additional_Service__c').add(fieldName);
                    } else {
                        throw new LongFormException('upsert error. input data is not valid for "E2E Data Additional Service" field: '
                                + fieldName + ' (value: ' + fieldValue + ')');
                    }
                }
            }
        }
        return changedFieldsForAdditionalServicesMap;
    }


    public virtual Map<String, Map<String, Map<String, Set<String>>>> returnJobsRunSettings(String stepName,
            Map<String, Map<String, Object>> stepsDependenciesMap) {
        Map<String, Map<String, Map<String, Set<String>>>> jobsRunSettings = new Map<String, Map<String, Map<String, Set<String>>>>();
        List<Object> jobsToRunForCurrentStepList = (List<Object>) stepsDependenciesMap.get(stepName).get('jobs_to_run');
        for (Object jobSettingsObj : jobsToRunForCurrentStepList) {
            Map<String, Object> jobsByName = (Map<String, Object>) jobSettingsObj;
            for (String jobName : jobsByName.keySet()) {
                if (! jobsRunSettings.containsKey(jobName)) {
                    jobsRunSettings.put(jobName, new Map<String, Map<String, Set<String>>>());
                }
                Map<String, Object> jobsByTriggerNames = (Map<String, Object>) jobsByName.get(jobName);
                for (String triggerName : jobsByTriggerNames.keySet()) {
                    if (! jobsRunSettings.get(jobName).containsKey(triggerName)) {
                        jobsRunSettings.get(jobName).put(triggerName, new Map<String, Set<String>>());
                    }
                    List<Object> triggerSettingsObjects = (List<Object>) jobsByTriggerNames.get(triggerName);
                    for (Object triggerSettingsObj : triggerSettingsObjects) {
                        String triggerSettings = (String) triggerSettingsObj;
                        String objectType = triggerSettings.substringBefore('.');
                        String objectFieldApi = triggerSettings.substringAfter('.');
                        if (! jobsRunSettings.get(jobName).get(triggerName).containsKey(objectType)) {
                            jobsRunSettings.get(jobName).get(triggerName).put(objectType, new Set<String>());
                        }
                        jobsRunSettings.get(jobName).get(triggerName).get(objectType).add(objectFieldApi);
                    }
                }
            }
        }
        return jobsRunSettings;
    }


    public virtual List<String> setJobsToRunForCurrentStep(ETEDatabaseInterface e2eDatabase, Map<String, Set<String>> changedFieldsForCurrentStep,
            Map<String, Map<String, Map<String, Set<String>>>> jobsRunSettings) {
        List<String> jobsToRunForCurrentStepList = new List<String>();
        for (String jobName : jobsRunSettings.keySet()) {
            for (String triggerName : jobsRunSettings.get(jobName).keySet()) {
                for (String objectType : jobsRunSettings.get(jobName).get(triggerName).keySet()) {
                    for (String objectFieldApi : jobsRunSettings.get(jobName).get(triggerName).get(objectType)) {
                        if (triggerName == 'trigger_to_launch_by_updated_fields') {
                            if (changedFieldsForCurrentStep.containsKey(objectType)) {
                                if (changedFieldsForCurrentStep.get(objectType).contains(objectFieldApi)) {
                                    jobsToRunForCurrentStepList.add(jobName);
                                    break;
                                }
                            }
                        }
                        if (triggerName == 'trigger_to_launch_by_empty_fields') {
                            if (objectType == 'E2E_Data_Object__c') {
                                if (this.existingDataObject.get(objectFieldApi) == null) {
                                    jobsToRunForCurrentStepList.add(jobName);
                                    break;
                                } else if (objectFieldApi == 'Id') {
                                    Opportunity currentOppty = e2eDatabase.retrieveOpportunity(this.existingDataObject.Id);
                                    if (currentOppty == null) {
                                        jobsToRunForCurrentStepList.add(jobName);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return jobsToRunForCurrentStepList;
    }


    public virtual List<String> getAllJobsToRunForCurrentStep(Map<String, Map<String, Map<String, Set<String>>>> jobsRunSettings) {
        List<String> allJobsToRunForCurrentStepList = new List<String>();
        for (String jobName : jobsRunSettings.keySet()) {
            allJobsToRunForCurrentStepList.add(jobName);
        }
        return allJobsToRunForCurrentStepList;
    }


    public virtual Map<String, Map<String, Map<String, Set<String>>>> returnFieldsCleaningSettings(String stepName,
            Map<String, Map<String, Object>> stepsDependenciesMap) {
        Map<String, Map<String, Map<String, Set<String>>>> fieldsCleaningSettings = new Map<String, Map<String, Map<String, Set<String>>>>();
        List<Object> fieldsCleaningSettingsForCurrentStepList = (List<Object>) stepsDependenciesMap.get(stepName).get('fields_to_clean_by_updated_fields');
        for (Object fieldsCleaningSettingsObj : fieldsCleaningSettingsForCurrentStepList) {
            Map<String, Object> fieldsCleaningSettingsParams = (Map<String, Object>) fieldsCleaningSettingsObj;
            List<Object> triggerSettingsObjects = (List<Object>) fieldsCleaningSettingsParams.get('trigger_to_launch_cleaning');
            for (Object triggerSettingsObj : triggerSettingsObjects) {
                String triggerSettings = (String) triggerSettingsObj;
                String triggerObjectType = triggerSettings.substringBefore('.');
                String triggerObjectFieldApi = triggerSettings.substringAfter('.');
                if (! fieldsCleaningSettings.containsKey(triggerObjectType)) {
                    fieldsCleaningSettings.put(triggerObjectType, new Map<String, Map<String, Set<String>>>());
                }
                if (! fieldsCleaningSettings.get(triggerObjectType).containsKey(triggerObjectFieldApi)) {
                    fieldsCleaningSettings.get(triggerObjectType).put(triggerObjectFieldApi, new Map<String, Set<String>>());
                }
                List<Object> clearedFieldsSettingsObjects = (List<Object>) fieldsCleaningSettingsParams.get('cleared_fields');
                for (Object clearedFieldsSettingsObj : clearedFieldsSettingsObjects) {
                    String clearedFieldsSettings = (String) clearedFieldsSettingsObj;
                    String clearedFieldObjectType = clearedFieldsSettings.substringBefore('.');
                    String clearedFieldApi = clearedFieldsSettings.substringAfter('.');
                    if (! fieldsCleaningSettings.get(triggerObjectType).get(triggerObjectFieldApi).containsKey(clearedFieldObjectType)) {
                        fieldsCleaningSettings.get(triggerObjectType).get(triggerObjectFieldApi).put(clearedFieldObjectType, new Set<String>());
                    }
                    fieldsCleaningSettings.get(triggerObjectType).get(triggerObjectFieldApi).get(clearedFieldObjectType).add(clearedFieldApi);
                }
            }
        }
        return fieldsCleaningSettings;
    }


    public virtual String getNextAvailableStep(Object userDataObject,
                                                List<String> availableStepsList,
                                                Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap,
                                                Map<String, Map<String, Object>> stepsDependenciesMap,
                                                List<String> jobsToRunForCurrentStepList,
                                                Boolean isReturnFromExternalSystem) {
        Map<String, Object> userDataFieldsValuesMap = new Map<String, Object>();
        if (userDataObject instanceof SObject) {
            userDataFieldsValuesMap.put('currentStep', this.existingDataObject.Current_Step__c);
            userDataFieldsValuesMap.put('securityAmountToPay', this.existingDataObject.Security_Amount_To_Pay__c);
        } else {
            Map<String, Object> userModel = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(userDataObject));
            userDataFieldsValuesMap.put('currentStep', userModel.get('currentStep'));
            userDataFieldsValuesMap.put('securityAmountToPay', userModel.get('securityAmountToPay'));
        }
        Map<String, Integer> stepsSequenceByNameMap = new Map<String, Integer>();
        Map<Integer, String> stepsSequenceByNumberMap = new Map<Integer, String>();
        Integer stepNumber = 1;
        for (String stepName : availableStepsList) {
            stepsSequenceByNameMap.put(stepName, stepNumber);
            stepsSequenceByNumberMap.put(stepNumber, stepName);
            stepNumber++;
        }
        String currentStepFromRequest = (String) userDataFieldsValuesMap.get('currentStep');
        Integer numberOfRequestedStep = stepsSequenceByNameMap.get(currentStepFromRequest) + 1;
        String nextAvailableStep;
        if (stepsSequenceByNumberMap.containsKey(numberOfRequestedStep)) {
            for (Integer i = numberOfRequestedStep; i <= stepsSequenceByNumberMap.size(); i++) {
                finalTransitionStatus = checkPendingRequests(jobsToRunForCurrentStepList, existingLogsMap.get('Request Status'));
                if (finalTransitionStatus == 'report ordering') {
                    nextAvailableStep = currentStepFromRequest;
                    break;
                }
                nextAvailableStep = stepsSequenceByNumberMap.get(i);
                List<Object> dependentJobsForNextStepList = (List<Object>) stepsDependenciesMap.get(stepsSequenceByNumberMap.get(i)).get('jobs_dependencies');
                if (i == numberOfRequestedStep && isReturnFromExternalSystem == false) {
                    finalTransitionStatus = checkRedirectionNeed(stepsDependenciesMap.get(currentStepFromRequest), existingLogsMap.get('Request Status'));
                    if (finalTransitionStatus == 'redirection need') {
                        nextAvailableStep = currentStepFromRequest;
                        break;
                    }
                    finalTransitionStatus = checkAuthorizationNeed(stepsDependenciesMap.get(currentStepFromRequest));
                    if (finalTransitionStatus == 'authorization need') {
                        nextAvailableStep = currentStepFromRequest;
                        break;
                    }
                    finalTransitionStatus = checkExceptionsByRequiredJobs(jobsToRunForCurrentStepList,
                                                                        dependentJobsForNextStepList,
                                                                        existingLogsMap.get('Job Status'));
                    if (finalTransitionStatus == null) {
                        finalTransitionStatus = checkExceptionsByStopProcessErrors(stepsDependenciesMap.get(currentStepFromRequest).get('stop_processes'),
                                                                                    userDataFieldsValuesMap,
                                                                                    existingLogsMap);
                    }
                } else {
                    finalTransitionStatus = checkExceptionsByRequiredJobs(null,
                            dependentJobsForNextStepList,
                            existingLogsMap.get('Job Status'));
                }
                if (finalTransitionStatus == null) {
                    finalTransitionStatus = checkExceptionsByStopProcessErrors(stepsDependenciesMap.get(stepsSequenceByNumberMap.get(i)).get('stop_processes'),
                                                                                userDataFieldsValuesMap,
                                                                                existingLogsMap);
                }
                if (finalTransitionStatus == 'job pending' || (finalTransitionStatus != null && finalTransitionStatus.contains('stop process'))) {
                    nextAvailableStep = currentStepFromRequest;
                    break;
                }
                if (finalTransitionStatus == null) {
                    List<Object> dependentFieldsList = (List<Object>) stepsDependenciesMap.get(stepsSequenceByNumberMap.get(i)).get('fields_dependencies');
                    finalTransitionStatus = checkExceptionsByRequiredFields(dependentFieldsList);
                    if (finalTransitionStatus == null) { break; }
                }
                if (i == stepsSequenceByNumberMap.size() && finalTransitionStatus != null) {
                    finalTransitionStatus = 'order submitted';
                }
            }
        } else {
            if (isReturnFromExternalSystem == false) {
                nextAvailableStep = stepsSequenceByNumberMap.get(stepsSequenceByNumberMap.size());
                finalTransitionStatus = checkAuthorizationNeed(stepsDependenciesMap.get(nextAvailableStep));
                if (finalTransitionStatus == null) {
                    finalTransitionStatus = checkRedirectionNeed(stepsDependenciesMap.get(nextAvailableStep), existingLogsMap.get('Request Status'));
                }
            }
            if (finalTransitionStatus == null) {
                finalTransitionStatus = 'order finished';
            }
        }
        return nextAvailableStep;
    }


    public virtual void save(ETEDatabaseInterface e2eDatabase,
                            ETEUserModel userModelFromRequest,
                            String nextAvailableStep,
                            Map<String, String> pageParamsMap,
                            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap,
                            Map<String, Set<String>> changedFieldsForCurrentStep,
                            Map<String, Map<String, Map<String, Set<String>>>> fieldsCleaningSettings,
                            Map<String, Map<String, Object>> stepDependenciesMap) {
        clearFields(e2eDatabase, changedFieldsForCurrentStep, fieldsCleaningSettings);
        setFieldsValuesToDataObject(e2eDatabase, userModelFromRequest, pageParamsMap, changedFieldsForCurrentStep, fieldsSettingsForCurrentStepMap);
        if (changedFieldsForCurrentStep.containsKey('E2E_Data_Contact__c')) {
            doUpsertContacts(e2eDatabase,
                    userModelFromRequest.contacts,
                    changedFieldsForCurrentStep.get('E2E_Data_Contact__c'),
                    fieldsSettingsForCurrentStepMap);
        }
        if (changedFieldsForCurrentStep.containsKey('E2E_Data_Product__c')) {
            doUpsertProduct(e2eDatabase,
                    userModelFromRequest.products,
                    changedFieldsForCurrentStep,
                    fieldsSettingsForCurrentStepMap);
        }
        if (changedFieldsForCurrentStep.containsKey('E2E_Data_Offer_Item__c')) {
            doUpsertOfferItems(e2eDatabase,
                    userModelFromRequest.products,
                    changedFieldsForCurrentStep,
                    fieldsSettingsForCurrentStepMap);
        }
        if (changedFieldsForCurrentStep.containsKey('E2E_Data_Locator_Item__c')) {
            doUpsertLocatorItems(e2eDatabase,
                    userModelFromRequest.products,
                    changedFieldsForCurrentStep,
                    fieldsSettingsForCurrentStepMap);
        }
        if (changedFieldsForCurrentStep.containsKey('E2E_Data_Additional_Service__c')) {
            doUpsertAdditionalServices(e2eDatabase,
                    userModelFromRequest.additionalServices,
                    changedFieldsForCurrentStep.get('E2E_Data_Additional_Service__c'),
                    fieldsSettingsForCurrentStepMap);
        }
        if (finalTransitionStatus == 'redirection need') {
            Opportunity opportunity = e2eDatabase.retrieveOpportunity(this.existingDataObject.Id);
            List<Quote> existingQuotesList = e2eDatabase.retrieveQuotes(opportunity.Id);
            upsertDataToRedirection(userModelFromRequest.countryCode, opportunity.Id, existingQuotesList, nextAvailableStep, stepDependenciesMap);
        }
    }


    public virtual void setDealStatusesForNextStep(ETEDatabaseInterface e2eDatabase,
                                                    String nextAvailableStep,
                                                    List<String> availableStepsForCustomerList,
                                                    List<String> availableStepsList,
                                                    Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap) {
        if (finalTransitionStatus != null && finalTransitionStatus.contains('stop process')) {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            this.existingDataObject.put('StageName__c', finalTransitionStatus.substringAfter(':'));
            this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
        } else if (finalTransitionStatus == 'report ordering') {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            this.existingDataObject.put('StageName__c', 'Pending Credit Report');
            this.existingDataObject.put('E2E_Finish_Details__c', 'Report Ordering');
        } else if (finalTransitionStatus == 'order finished') {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            if (availableStepsForCustomerList.size() == availableStepsList.size()) {
                if (existingDataObject.Security_Amount_To_Pay__c > 0) {
                    if (existingDataObject.Payment_Status__c != null &&
                            existingDataObject.Payment_Status__c.equalsIgnoreCase('COMPLETED')) {
                        this.existingDataObject.put('StageName__c', 'Closed Won');
                        this.existingDataObject.put('E2E_Finish_Details__c', 'Order Completed');
                        finalTransitionStatus = 'order completed';
                    } else {
                        this.existingDataObject.put('StageName__c', 'Pending Sales – Deposit');
                        this.existingDataObject.put('E2E_Finish_Details__c', 'Awaiting Payment');
                        finalTransitionStatus = 'order submitted';
                    }
                } else {
                    Boolean isCreditCheck = false;
                    for (E2E_Data_Log__c exceptionLog : existingLogsMap.get('Exception').values()) {
                        if (exceptionLog.Error_Code__c == 100) {
                            isCreditCheck = true;
                            break;
                        }
                    }
                    if (isCreditCheck == false) {
                        this.existingDataObject.put('StageName__c', 'Closed Won');
                        this.existingDataObject.put('E2E_Finish_Details__c', 'Order Completed');
                        finalTransitionStatus = 'order completed';
                    } else {
                        this.existingDataObject.put('StageName__c', 'Pending Credit - E2E Check');
                        this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
                        finalTransitionStatus = 'order submitted';
                    }
                }
            } else {
                this.existingDataObject.put('StageName__c', 'Prospecting');
                this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
                finalTransitionStatus = 'order submitted';
            }
        } else if (finalTransitionStatus == 'order submitted') {
            this.existingDataObject.put('E2E_Status__c', 'Finished');
            this.existingDataObject.put('E2E_Finish_Details__c', 'Order Submitted');
            this.existingDataObject.put('StageName__c', 'Prospecting');
        } else {
            this.existingDataObject.put('E2E_Status__c', 'In progress');
            if (this.existingDataObject.Credit_Limit__c == null) {
                this.existingDataObject.put('StageName__c', 'Prospecting');
            } else {
                this.existingDataObject.put('StageName__c', 'Credit Approved');
            }
            if (this.existingDataObject.Current_Step__c != nextAvailableStep) {
                this.existingDataObject.put('Current_Step__c', nextAvailableStep);
            }
        }
        e2eDatabase.upsertDataObject(this.existingDataObject);
    }


    public virtual void setPayLaterDealStatus(ETEDatabaseInterface e2eDatabase) {
        this.existingDataObject.E2E_Status__c = 'Finished';
        this.existingDataObject.StageName__c = 'Pending Sales – Deposit';
        this.existingDataObject.E2E_Finish_Details__c = 'Awaiting Payment';
        e2eDatabase.upsertDataObject(this.existingDataObject);
    }


    public virtual ETEUserModel convertToUserModel(List<String> availableStepsForCustomerList, List<ETEUserModel.NavigationMenuStep> navigationMenuSteps) {
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>();
        dataObjectsToConvertMap.put('data_object', this.existingDataObject);
        dataObjectsToConvertMap.put('ete_contact', this.existingContacts);
        dataObjectsToConvertMap.put('product', this.existingETEProductsMap.values());
        dataObjectsToConvertMap.put('offer_item', this.existingETEOfferItems.values());
        dataObjectsToConvertMap.put('locator_item', this.existingETELocatorItems.values());
        dataObjectsToConvertMap.put('additional_service', this.existingAdditionalServicesList);
        ETEUserModel preFinalUserModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        preFinalUserModel.availableSteps.addAll(availableStepsForCustomerList);
        preFinalUserModel.navigationMenuSteps.addAll(navigationMenuSteps);
        if (preFinalUserModel.implKey == null) {
            preFinalUserModel.implKey = Schema.getGlobalDescribe().
                    get('E2E_Data_Object__c').
                    getDescribe().
                    getRecordTypeInfosById().
                    get(this.existingDataObject.RecordTypeId).getName();
        }
        return preFinalUserModel;
    }


    public virtual void runJobs(ETEDatabaseInterface e2eDatabase,
                                List<String> jobNamesNeededToRun) {
        if (finalTransitionStatus == 'job pending') {
            jobNamesNeededToRun.clear();
        } else if (finalTransitionStatus != null &&
                (finalTransitionStatus.contains('stop process') ||
                finalTransitionStatus == 'order completed' ||
                finalTransitionStatus == 'order submitted')) {
            if (finalTransitionStatus == 'order submitted') {
                jobNamesNeededToRun.clear();
            }
            jobNamesNeededToRun.add('syncFinishedDeal');
            finalTransitionStatus = null;
        }
        Boolean jobsChainExecutionInProcess = false;
        Map<String, E2E_Data_Log__c> jobStatusesForCurrentStep = (generateExistingLogsMap(e2eDatabase, ETEGlobalUtils.doEncryptParams(this.existingDataObject.Id, this.existingDataObject.Country_Code__c))).get('Job Status');
        List<E2E_Data_Log__c> dataLogsToUpdate = new List<E2E_Data_Log__c>();
        for (E2E_Data_Log__c jobLog : jobStatusesForCurrentStep.values()) {
            if (! jobNamesNeededToRun.contains(jobLog.Name)) {
                if (jobLog.Job_Status__c == 'Queued' && jobLog.Job_ID__c != null) {
                    if (jobsChainExecutionInProcess == false) { jobsChainExecutionInProcess = true; }
                    jobLog.Job_Status__c = 'Restart';
                    jobLog.Job_ID__c = null;
                    jobLog.Exception_Type__c = null;
                    jobLog.Exception_Description__c = null;
                    dataLogsToUpdate.add(jobLog);
                }
            }
        }
        if (! jobNamesNeededToRun.isEmpty()) {
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Job Status' AND sObjectType = 'E2E_Data_Log__c' LIMIT 1];
            for (String jobName : jobNamesNeededToRun) {
                E2E_Data_Log__c jobLog;
                if (jobStatusesForCurrentStep.containsKey(jobName)) {
                    jobLog = jobStatusesForCurrentStep.get(jobName);
                    if (jobLog.Job_Status__c != 'Restart' && jobLog.Job_ID__c != null) {
                        if (jobLog.Job_Status__c == 'Queued' && jobLog.Job_ID__c != null) {
                            if (jobsChainExecutionInProcess == false) { jobsChainExecutionInProcess = true; }
                        }
                        jobLog.Job_Status__c = 'Restart';
                        jobLog.Job_ID__c = null;
                        jobLog.Exception_Type__c = null;
                        jobLog.Exception_Description__c = null;
                        dataLogsToUpdate.add(jobLog);
                    }
                } else {
                    jobLog = new E2E_Data_Log__c();
                    jobLog.Name = jobName;
                    jobLog.Job_Status__c = 'Queued';
                    jobLog.RecordTypeId = recordType.Id;
                    jobLog.E2E_Data_Object__c = this.existingDataObject.Id;
                    jobStatusesForCurrentStep.put(jobName, jobLog);
                    dataLogsToUpdate.add(jobLog);
                }
            }
            if (! dataLogsToUpdate.isEmpty()) {
                e2eDatabase.upsertE2EDataLogs(dataLogsToUpdate);
            }
            String implKey = this.existingDataObject.RecordType.Name;
            if (implKey == null) {
                implKey = Schema.getGlobalDescribe().get('E2E_Data_Object__c').getDescribe().getRecordTypeInfosById().get(this.existingDataObject.RecordTypeId).getName();
            }

            if (jobsChainExecutionInProcess == false) {
                ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobNamesNeededToRun,
                        this.existingDataObject.Id,
                        this.existingDataObject.Country_Code__c,
                        implKey);
                jobChainHandler.runJob();
            }
        }
    }


    public virtual String returnTransitionStatus() {
        return finalTransitionStatus;
    }


    public virtual Map<String, Object> prepareFinalSettingsToFrontend(Map<String, Object> untypedSettings) {
        List<Object> defaultSettingsOfStepsList = (List<Object>) untypedSettings.get('steps');
        for (Object stepSettings : defaultSettingsOfStepsList) {
            Map<String, Object> stepSettingsMap = (Map<String, Object>) stepSettings;
            stepSettingsMap.remove('fields_dependencies');
            stepSettingsMap.remove('jobs_dependencies');
            stepSettingsMap.remove('stop_processes');
            stepSettingsMap.remove('jobs_to_run');
            stepSettingsMap.remove('objects_mapping_to_sync');
            stepSettingsMap.remove('optional');
            stepSettingsMap.remove('trigger_to_display');
            if (stepSettingsMap.containsKey('fields_to_clean_by_updated_fields')) {
                stepSettingsMap.remove('fields_to_clean_by_updated_fields');
            }
        }
        if (untypedSettings.containsKey('docusign_fields_mapping')) { untypedSettings.remove('docusign_fields_mapping'); }
        if (untypedSettings.containsKey('credit_factory')) { untypedSettings.remove('credit_factory'); }
        return untypedSettings;
    }


    public virtual Map<String, Object> prepareFinalUserModelToFrontend(ETEUserModel userModelObject) {
        Map<String, Object> untypedUserModel = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(userModelObject));
        if (untypedUserModel.containsKey('opptyId')) { untypedUserModel.remove('opptyId'); }
        if (untypedUserModel.containsKey('recordTypeId')) { untypedUserModel.remove('recordTypeId'); }
        if (untypedUserModel.containsKey('riskCategory')) { untypedUserModel.remove('riskCategory'); }
        return untypedUserModel;
    }


    public virtual Map<String, Object> doCalculateConsumption(E2E_Data_Object__c dataObject,
                                                            Map<String, E2E_Data_Product__c> eteProductsMap,
                                                            List<E2E_Data_Offer_Item__c> offerItemsList) {
        Map<String, Object> consumptionMap = new Map<String, Object>();
        Decimal totalConsumption = 0;
        Decimal nonFuelExposure = 0;
        Decimal totalAmount = 0;
        for (E2E_Data_Offer_Item__c offerItem : offerItemsList) {
            String productKey;
            if (offerItem.E2E_Data_Product__c != null) {
                productKey = offerItem.E2E_Data_Product__c;
            } else {
                productKey = offerItem.Offer_Item_Type_Name__c;
            }
            E2E_Data_Product__c product = eteProductsMap.get(productKey);
            if (product.Type_Name__c == 'Shell Fuel Card' ||
                product.Type_Name__c == 'Lotos Fuel Card') {
                totalConsumption += offerItem.Monthly_Fuel_Consumption__c;
            } else if (product.Type_Name__c == 'EV Fob') {
                nonFuelExposure += 100;
            } else if (product.Type_Name__c == 'CCS Fuel Card Limit' || product.Type_Name__c == 'CCS Fuel Card Limit Plus') {
                if (offerItem.Monthly_Card_Limit__c != null) {
                    totalAmount += offerItem.Monthly_Card_Limit__c;
                }
            }
        }
        if (totalAmount != 0) {
            Fuel_Price__c fuelPrice = Fuel_Price__c.getInstance(ETEGlobalUtils.returnCountry(dataObject.Country_Code__c));
            totalConsumption = (totalAmount/fuelPrice.Index__c).setScale(0);
        }
        consumptionMap.put('totalConsumption', totalConsumption);
        consumptionMap.put('nonFuelExposure', nonFuelExposure);
        return consumptionMap;
    }


    public virtual Decimal returnAvailableMinDeposit(List<CreditFactoryResult> availableCreditFactoryResults) {
        Decimal minValue = 0;
        if (availableCreditFactoryResults != null && !availableCreditFactoryResults.isEmpty()) {
            minValue = availableCreditFactoryResults[0].deposit;
        }
        if (minValue > 0) {
            for (CreditFactoryResult cfResult : availableCreditFactoryResults) {
                if (cfResult.deposit == null) cfResult.deposit = 0;
                if (cfResult.deposit < minValue) minValue = cfResult.deposit;
            }
        }
        return minValue;
    }


    public virtual Map<String, Set<String>> returnCFPaymentDetails (String country, Map<String, Object> creditFactorySettings) {
        List<Object> cfPaymentDetailsList = (List<Object>) creditFactorySettings.get('payment_details');
        Map<String, Set<String>> paymentDetailsMap = new Map<String, Set<String>>();
        for (Object cfPaymentDetails : cfPaymentDetailsList) {
            if (! paymentDetailsMap.containsKey(country)) {
                paymentDetailsMap.put(country, new Set<String>());
            }
            paymentDetailsMap.get(country).add((String) cfPaymentDetails);
        }
        return paymentDetailsMap;
    }


    public virtual Map<String, List<String>> returnCFReportValidations (String country, Map<String, Object> creditFactorySettings) {
        List<Object> cfReportValidationsList = (List<Object>) creditFactorySettings.get('report_validations');
        Map<String, List<String>> reportValidationsMap = new Map<String, List<String>>();
        for (Object cfReportValidation : cfReportValidationsList) {
            if (! reportValidationsMap.containsKey(country)) {
                reportValidationsMap.put(country, new List<String>());
            }
            reportValidationsMap.get(country).add((String) cfReportValidation);
        }
        return reportValidationsMap;
    }


    public virtual String translateTextToEnglish(String country, String targetText) {
        Customer_Feedback_Settings__c feedbackSettings = Customer_Feedback_Settings__c.getInstance(country);
        String englishTranslation;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String textToTranslate = targetText.replace(' ', '%20');
        String url = feedbackSettings.Translation_Endpoint__c + textToTranslate;
        req.setMethod('GET');
        req.setEndpoint(url);
        HttpResponse resp = http.send(req);
        GoogleTranslateParser translateResponse = (GoogleTranslateParser) JSON.deserialize(resp.getBody(), GoogleTranslateParser.class);
        if (translateResponse.data != null && translateResponse.data.translations != null &&
                ! translateResponse.data.translations.isEmpty()) {
            englishTranslation = translateResponse.data.translations.get(0).translatedText;
        }
        return englishTranslation;
    }


    public virtual void saveCustomerFeedback(ETEDatabaseInterface e2eDatabase,
            E2E_Data_Object__c e2eDataObject,
            Map<String, Object> customerFeedbackParams) {
        String feedbackLocal = (String) customerFeedbackParams.get('feedbackLocal');
        String englishTranslation = (String) customerFeedbackParams.get('feedbackEnglish');
        String logRecordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        E2E_Data_Log__c dataLog = new E2E_Data_Log__c();
        dataLog.Name = 'Customer Feedback ' + Datetime.now();
        dataLog.RecordTypeId = logRecordTypeId;
        dataLog.E2E_Data_Object__c = e2eDataObject.Id;
        dataLog.E2E_Step__c = e2eDataObject.Current_Step__c;
        dataLog.Rating__c = (Decimal) customerFeedbackParams.get('rating');
        dataLog.Form_Identification__c = 'E2E 2.0 ' + customerFeedbackParams.get('implKey');
        dataLog.Feedback_Local__c = feedbackLocal;
        dataLog.Feedback_English__c = englishTranslation;
        e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{dataLog});
    }


    public virtual void saveFile (Map<String, Object> requestParams) {
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('countryCode');
        String fileName = (String) requestParams.get('fileName');
        String file = (String) requestParams.get('file');
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);

        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        Opportunity opportunityObject = e2eDatabase.retrieveOpportunity(currentDataObject.Id);
        
        Attachment attachment = new Attachment();
        attachment.Body = EncodingUtil.base64Decode(file);
        attachment.Name = fileName;
        attachment.ParentId = opportunityObject.Id; 
        attachment.Description = 'Company registration form'; 
        insert attachment;
    }


    public virtual E2E_Data_Object__c generateVerificationCode(ETEDatabaseInterface e2eDatabase,
                                                                E2E_Data_Object__c e2eDataObject) {
        Decimal verificationCode = Math.round((Math.random() * (900000) + 100000));
        e2eDataObject.Verification_Code__c = String.valueOf(verificationCode);
        e2eDatabase.upsertDataObject(e2eDataObject);
        return e2eDataObject;
    }


    public virtual String sendVerificationCode(String whatId,
                                                String targetObjectId,
                                                String replyTo,
                                                List<String> recipientEmails,
                                                String templateId) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :replyTo];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(targetObjectId);
        message.setToAddresses(recipientEmails);
        message.setReplyTo(replyTo);
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        if (! owea.isEmpty()) {
            message.setOrgWideEmailAddressId(owea[0].Id);
        } else {
            message.setSenderDisplayName('Fleetcor Products');
        }
        message.setTemplateID(templateId);
        message.setWhatId(whatId);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success != true) {
            return results[0].errors[0].message;
        }
        return null;
    }


    public virtual String validateVerificationCode(ETEDatabaseInterface e2eDatabase,
                                                    E2E_Data_Object__c e2eDataObject,
                                                    String inputVerificationCode) {
        if (e2eDataObject.Verification_Code__c == inputVerificationCode) {
            e2eDataObject.Verification_Date__c = Datetime.now();
            e2eDatabase.upsertDataObject(e2eDataObject);
            return null;
        } else {
            return 'verification code is not valid';
        }
    }


    private void clearFields(ETEDatabaseInterface e2eDatabase,
            Map<String, Set<String>> changedFieldsForCurrentStep,
            Map<String, Map<String, Map<String, Set<String>>>> fieldsCleaningSettings) {
        Set<String> objectTypesToUpdate = new Set<String>();
        for (String objectType : changedFieldsForCurrentStep.keySet()) {
            for (String fieldName : changedFieldsForCurrentStep.get(objectType)) {
                if (fieldsCleaningSettings.containsKey(objectType) &&
                        fieldsCleaningSettings.get(objectType).containsKey(fieldName)) {
                    for (String objectTypeToClean: fieldsCleaningSettings.get(objectType).get(fieldName).keySet()) {
                        for (String fieldApiNameToClean : fieldsCleaningSettings.get(objectType).get(fieldName).get(objectTypeToClean)) {
                            SObjectType sobjType = ((SObject)(Type.forName('Schema.'+ objectTypeToClean).newInstance())).getSObjectType();
                            DescribeSObjectResult describeSObjectResult = sobjType.getDescribe();
                            Schema.DisplayType fieldType = describeSObjectResult.fields.getMap().get(fieldApiNameToClean).getDescribe().getType();
                            Object fieldValue;
                            if (fieldType == Schema.DisplayType.BOOLEAN) {
                                fieldValue = false;
                            } else {
                                fieldValue = null;
                            }
                            if (objectTypeToClean == 'E2E_Data_Object__c') {
                                this.existingDataObject.put(fieldApiNameToClean, fieldValue);
                            } else if (objectTypeToClean == 'E2E_Data_Log__c') {
                                if (this.existingDataLogsMap.get('Request Status').containsKey('signDocusignDocuments')) {
                                    this.existingDataLogsMap.get('Request Status').get('signDocusignDocuments').put(fieldApiNameToClean, fieldValue);
                                }
                            }
                            if (! objectTypesToUpdate.contains(objectTypeToClean)) {
                                objectTypesToUpdate.add(objectTypeToClean);
                            }
                        }
                    }
                }
            }
        }
        if (objectTypesToUpdate.contains('E2E_Data_Object__c')) { e2eDatabase.upsertDataObject(this.existingDataObject); }
        if (objectTypesToUpdate.contains('E2E_Data_Log__c')) { e2eDatabase.upsertE2EDataLogs(this.existingDataLogsMap.get('Request Status').values()); }
    }


    private String checkPendingRequests(List<String> jobsToRunForCurrentStepList, Map<String, E2E_Data_Log__c> existingRequestsMap) {
        String status;
        if (jobsToRunForCurrentStepList.contains('syncCompanyDetails') || existingRequestsMap.containsKey('reportOrderingRequest')) {
            status = 'report ordering';
            if (existingRequestsMap.containsKey('reportOrderingRequest')) {
                E2E_Data_Log__c reportOrderingRequest = existingRequestsMap.get('reportOrderingRequest');
                if (reportOrderingRequest.Status__c == 'Report Received') {
                    status = null;
                }
            }
        }
        return status;
    }


    private String checkRedirectionNeed(Map<String, Object> stepsSettingsMap, Map<String, E2E_Data_Log__c> existingRequestsMap) {
        if (stepsSettingsMap.containsKey('redirection') && stepsSettingsMap.get('redirection') != null) {
            if (stepsSettingsMap.get('redirection') == 'docusign_documents') {
                if (! existingRequestsMap.containsKey('signDocusignDocuments')) {
                    return 'redirection need';
                } else {
                    if (existingRequestsMap.get('signDocusignDocuments').Status__c != 'Success') {
                        return 'redirection need';
                    } else {
                        return null;
                    }
                }
            }
            return 'redirection need';
        }
        return null;
    }


    private String checkAuthorizationNeed(Map<String, Object> stepsSettingsMap) {
        if (stepsSettingsMap.containsKey('additional_authorization')) {
            if (this.existingDataObject.Verification_Date__c == null ||
                (! (System.now() < this.existingDataObject.Verification_Date__c.addDays(2)))) {
                return 'authorization need';
            }
        }
        return null;
    }


    private String checkExceptionsByRequiredFields(List<Object> requiredFieldsForNextStep) {
        String transitionToNextStepStatus;
        for (Object fieldKeyObject : requiredFieldsForNextStep) {
            String fieldKey = (String) fieldKeyObject;
            String objectName = fieldKey.substringBefore('.');
            String fieldApiName = fieldKey.substringAfter('.');
            if (objectName == 'E2E_Data_Object__c') {
                if (this.existingDataObject.get(fieldApiName) == null ||
                        this.existingDataObject.get(fieldApiName) == 'none') {
                    transitionToNextStepStatus = 'no data for requested step';
                    break;
                }
            }
        }
        return transitionToNextStepStatus;
    }


    private String checkExceptionsByRequiredJobs(List<String> jobsToRunForCurrentStepList,
            List<Object> dependentJobsForNextStepList,
            Map<String, E2E_Data_Log__c> existingJobStatusesMap) {
        String transitionToNextStepStatus;
        for (Object jobNameObj : dependentJobsForNextStepList) {
            String jobName = (String) jobNameObj;
            if (jobsToRunForCurrentStepList != null && jobsToRunForCurrentStepList.contains(jobName)) {
                transitionToNextStepStatus = 'job pending';
            } else {
                if (existingJobStatusesMap.containsKey(jobName)) {
                    E2E_Data_Log__c existingDataLog = existingJobStatusesMap.get(jobName);
                    if (existingDataLog.Job_Status__c == 'Restart' || existingDataLog.Job_Status__c == 'Queued' ||
                        existingDataLog.Job_Status__c == 'Preparing' || existingDataLog.Job_Status__c == 'Processing') {
                        transitionToNextStepStatus = 'job pending';
                    } else if (existingDataLog.Job_Status__c == 'Aborted' || existingDataLog.Job_Status__c == 'Failed') {
                        transitionToNextStepStatus = 'job exception';
                    }
                }
            }
            if (transitionToNextStepStatus != null) {
                break;
            }
        }
        return transitionToNextStepStatus;
    }


    private String checkExceptionsByStopProcessErrors(Object stopProcessErrorsObject,
                                                    Map<String, Object> userDataFieldsValuesMap,
                                                    Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap) {
        Map<String, Object> stopProcessErrorsSettings = (Map<String, Object>) stopProcessErrorsObject;
        Map<String, String> stopProcessErrorsWithDealStatus = new Map<String, String>();
        if (! stopProcessErrorsSettings.isEmpty()) {
            for (String errorMessage : stopProcessErrorsSettings.keySet()) {
                Map<String, Object> errorSettings = (Map<String, Object>) stopProcessErrorsSettings.get(errorMessage);
                Map<String, Object> errorConditions = (Map<String, Object>) errorSettings.get('conditions');
                if (errorConditions.isEmpty()) {
                    stopProcessErrorsWithDealStatus.put(errorMessage, (String) errorSettings.get('stageName'));
                } else {
                    for (String logicalOperator : errorConditions.keySet()) {
                        Set<Boolean> resultsOfConditionsByLogicalOperatorSet = new Set<Boolean>();
                        for (Object conditionsToStopProcess : (List<Object>) errorConditions.get(logicalOperator)) {
                            Map<String, Object> conditionParams = (Map<String, Object>) conditionsToStopProcess;
                            String regex = (String) conditionParams.get('regex');
                            String objectApiName = ((String) conditionParams.get('param')).substringBefore('.');
                            String fieldApiName = ((String) conditionParams.get('param')).substringAfter('.');
                            if (objectApiName == 'data_object') {
                                String fieldValue = userDataFieldsValuesMap.get(fieldApiName) != null ? String.valueOf(userDataFieldsValuesMap.get(fieldApiName)) : 'null';
                                resultsOfConditionsByLogicalOperatorSet.add(Pattern.matches(regex, fieldValue));
                            }
                        }
                        if (logicalOperator == 'AND') {
                            if (resultsOfConditionsByLogicalOperatorSet.size() == 1 && resultsOfConditionsByLogicalOperatorSet.contains(true)) {
                                stopProcessErrorsWithDealStatus.put(errorMessage, (String) errorSettings.get('stageName'));
                            }
                        } else if (logicalOperator == 'OR') {
                            if (resultsOfConditionsByLogicalOperatorSet.contains(true)) {
                                stopProcessErrorsWithDealStatus.put(errorMessage, (String) errorSettings.get('stageName'));
                            }
                        }
                    }
                }
            }
        }
        String transactionStatus;
        for (String logType : existingLogsMap.keySet()) {
            for (E2E_Data_Log__c dataLog : existingLogsMap.get(logType).values()) {
                if (stopProcessErrorsWithDealStatus.containsKey(dataLog.Exception_Description__c)) {
                    transactionStatus = 'stop process:' + stopProcessErrorsWithDealStatus.get(dataLog.Exception_Description__c);
                    break;
                }
                if ((dataLog.Exception_Type__c == 'CF System Error' || dataLog.Exception_Type__c == 'Company search') &&
                        dataLog.Exception_Description__c != 'Company is not in the list' &&
                        dataLog.Exception_Description__c != 'Report does not exist' &&
                        dataLog.Exception_Description__c != 'Report request limit exceeded') {
                    transactionStatus = 'order submitted';
                    break;
                }
            }
        }
        return transactionStatus;
    }


    private void setFieldsValuesToDataObject(ETEDatabaseInterface e2eDatabase,
            ETEUserModel userModelFromRequest,
            Map<String, String> pageParamsMap,
            Map<String, Set<String>> changedFieldsForCurrentStep,
            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        Map<String, Object> deserializeUserModel = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(userModelFromRequest));
        if (changedFieldsForCurrentStep.containsKey('E2E_Data_Object__c')) {
            for (String fieldName : changedFieldsForCurrentStep.get('E2E_Data_Object__c')) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('data_object').get(fieldName).get('mapto');
                this.existingDataObject.put(fieldName, deserializeUserModel.get(maptoKey));
            }
        }
        this.existingDataObject.Customer_IP_Address__c = userModelFromRequest.ipAddress;
        this.existingDataObject.Device_Type__c = userModelFromRequest.deviceType;
        this.existingDataObject.E2E_Last_Activity__c = Datetime.now();
        if (pageParamsMap.containsKey('utm_campaign') && this.existingDataObject.Utm_Campaign__c == null) {
            this.existingDataObject.Utm_Campaign__c = pageParamsMap.get('utm_campaign');
        }
        if (pageParamsMap.containsKey('utm_content') && this.existingDataObject.Utm_Content__c == null) {
            this.existingDataObject.Utm_Content__c = pageParamsMap.get('utm_content');
        }
        if (pageParamsMap.containsKey('utm_medium') && this.existingDataObject.Utm_Medium__c == null) {
            this.existingDataObject.Utm_Medium__c = pageParamsMap.get('utm_medium');
        }
        if (pageParamsMap.containsKey('utm_placement') && this.existingDataObject.Utm_Placement__c == null) {
            this.existingDataObject.Utm_Placement__c = pageParamsMap.get('utm_placement');
        }
        if (pageParamsMap.containsKey('utm_source') && this.existingDataObject.Utm_Source__c == null) {
            this.existingDataObject.Utm_Source__c = pageParamsMap.get('utm_source');
        }
        if (pageParamsMap.containsKey('utm_term') && this.existingDataObject.Utm_Term__c == null) {
            this.existingDataObject.Utm_Term__c = pageParamsMap.get('utm_term');
        }
        if (pageParamsMap.containsKey('utm_url') && this.existingDataObject.Utm_Url__c == null) {
            this.existingDataObject.Utm_Url__c = pageParamsMap.get('utm_url');
        }
        if (this.existingDataObject.Risk_Category__c != null &&
                (changedFieldsForCurrentStep.containsKey('E2E_Data_Object__c') &&
                        changedFieldsForCurrentStep.get('E2E_Data_Object__c').contains('Payment_Method__c')) ||
                (changedFieldsForCurrentStep.containsKey('E2E_Data_Product__c') &&
                        changedFieldsForCurrentStep.get('E2E_Data_Product__c').contains('Type_ID__c') &&
                        this.existingDataObject.Payment_Method__c != null)) {
            if (this.existingDataObject.Payment_Method__c == 'Direct Debit') {
                Map<String, E2E_Data_Product__c> productsMap = new Map<String, E2E_Data_Product__c>();
                List<E2E_Data_Offer_Item__c> itemsToConsumption = new List<E2E_Data_Offer_Item__c>();
                for (ETEUserModel.Product productModel : userModelFromRequest.products) {
                    productsMap.put(productModel.typeName, new E2E_Data_Product__c(Type_Name__c = productModel.typeName));
                    for (ETEUserModel.Offer_Item offerItem : productModel.offerItems) {
                        itemsToConsumption.add(new E2E_Data_Offer_Item__c(
                                Offer_Item_Type_Name__c = productModel.typeName,
                                Monthly_Fuel_Consumption__c = offerItem.monthlyFuelConsumption,
                                Monthly_Card_Limit__c = offerItem.monthlyCardLimit
                        ));
                    }
                }
                Map<String, Object> consumptionMap = doCalculateConsumption(this.existingDataObject, productsMap, itemsToConsumption);
                Decimal consumption = (Decimal) consumptionMap.get('totalConsumption');
                String appropriateMandateType = CreditFactoryGlobalUtils.returnAppropriateMandateType(this.existingDataObject.RecordType.Name,
                                                                                                    this.existingDataObject.Risk_Category__c,
                                                                                                    consumption);
                this.existingDataObject.Direct_Debit_Mandate_Type__c = appropriateMandateType;
            } else {
                this.existingDataObject.Direct_Debit_Mandate_Type__c = null;
            }
        }

        if (this.existingDataObject.Id == null) {
            e2eDatabase.upsertDataObject(this.existingDataObject);
        }
    }


    private void doUpsertContacts(ETEDatabaseInterface e2eDatabase,
                                    List<ETEUserModel.ETE_Contact> contacts,
                                    Set<String> changedContactsFieldsSet,
                                    Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        List<E2E_Data_Contact__c> finalContactsList = new List<E2E_Data_Contact__c>();
        List<E2E_Data_Contact__c> contactsToUpsertList = new List<E2E_Data_Contact__c>();
        List<E2E_Data_Contact__c> contactsToDeleteList = new List<E2E_Data_Contact__c>();
        Map<String, E2E_Data_Contact__c> existingContactsMap = new Map<String, E2E_Data_Contact__c>();
        for (E2E_Data_Contact__c contact : this.existingContacts) {
            existingContactsMap.put(contact.Id, contact);
        }
        List<Object> inputContactsDataList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(contacts));
        for (Object contactObj : inputContactsDataList) {
            Map<String, Object> inputContactsDataMap = (Map<String, Object>) contactObj;
            String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputContactsDataMap.get('source'), this.existingDataObject.Country_Code__c);
            E2E_Data_Contact__c contact;
            if (existingContactsMap.containsKey(decryptedSource)) {
                contact = existingContactsMap.get(decryptedSource);
            } else {
                contact = new E2E_Data_Contact__c();
                contact.E2E_Data_Object__c = this.existingDataObject.Id;
            }
            Boolean contactNeedsToUpsert = false;
            for (String fieldName : changedContactsFieldsSet) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('ete_contact').get(fieldName).get('mapto');
                if (contact.get(fieldName) != inputContactsDataMap.get(maptoKey) || contact.Id == null) {
                    contact.put(fieldName, inputContactsDataMap.get(maptoKey));
                    if (contactNeedsToUpsert == false) {
                        contactNeedsToUpsert = true;
                    }
                }
            }
            if (contactNeedsToUpsert == true) {
                contactsToUpsertList.add(contact);
            }
            if (existingContactsMap.containsKey(contact.Id)) {
                existingContactsMap.remove(contact.Id);
            }
            finalContactsList.add(contact);
        }
        contactsToDeleteList.addAll(existingContactsMap.values());
        if (!contactsToUpsertList.isEmpty()) {
            e2eDatabase.upsertETEContacts(contactsToUpsertList);
        }
        if (!contactsToDeleteList.isEmpty()) {
            e2eDatabase.deleteContacts(contactsToDeleteList);
        }
        this.existingContacts.clear();
        this.existingContacts.addAll(finalContactsList);
    }


    private void doUpsertProduct(ETEDatabaseInterface e2eDatabase,
                                    List<ETEUserModel.Product> products,
                                    Map<String, Set<String>> changedFieldsForCurrentStep,
                                    Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        List<E2E_Data_Product__c> finalProductsList = new List<E2E_Data_Product__c>();
        List<E2E_Data_Product__c> productsToUpsertList = new List<E2E_Data_Product__c>();
        List<E2E_Data_Product__c> productsToDeleteList = new List<E2E_Data_Product__c>();
        Map<Integer, ETEUserModel.Product> newProductModels = new Map<Integer, ETEUserModel.Product>();
        Map<Integer, E2E_Data_Product__c> newE2EProducts = new Map<Integer, E2E_Data_Product__c>();

        Integer newProductIndex = 0;
        for (ETEUserModel.Product productModel : products) {
            Map<String, Object> inputProductDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(productModel));
            String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputProductDataMap.get('source'),
                                                                    this.existingDataObject.Country_Code__c);
            E2E_Data_Product__c product;
            if (this.existingETEProductsMap.containsKey(decryptedSource)) {
                product = this.existingETEProductsMap.get(decryptedSource);
            } else {
                product = new E2E_Data_Product__c();
                product.RecordTypeId = Schema.SObjectType.E2E_Data_Product__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();
                product.E2E_Data_Object__c = this.existingDataObject.Id;
                newProductIndex += 1;
                newProductModels.put(newProductIndex, productModel);
                newE2EProducts.put(newProductIndex, product);
            }
            finalProductsList.add(product);
            Boolean productNeedsToUpsert = false;
            if (changedFieldsForCurrentStep.containsKey('E2E_Data_Product__c')) {
                for (String fieldName : changedFieldsForCurrentStep.get('E2E_Data_Product__c')) {
                    String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('product').get(fieldName).get('mapto');
                    if (maptoKey == 'productId' || maptoKey == 'typeId') {
                        String idParam = ETEGlobalUtils.doDecryptParams((String) inputProductDataMap.get(maptoKey), this.existingDataObject.Country_Code__c);
                        inputProductDataMap.put(maptoKey, idParam);
                    }
                    if (product.get(fieldName) != inputProductDataMap.get(maptoKey) || product.Id == null) {
                        product.put(fieldName, inputProductDataMap.get(maptoKey));
                        if (productNeedsToUpsert == false) { productNeedsToUpsert = true; }
                    }
                }
            }
            if (productNeedsToUpsert == true) { productsToUpsertList.add(product); }
        }
        if (! productsToUpsertList.isEmpty()) {
            e2eDatabase.upsertETEProducts(productsToUpsertList);
        }
        for (Integer productIndex : newE2EProducts.keySet()) {
            ETEUserModel.Product newProductModel = newProductModels.get(productIndex);
            newProductModel.source = ETEGlobalUtils.doEncryptParams(newE2EProducts.get(productIndex).Id, this.existingDataObject.Country_Code__c);
        }
        Map<String, E2E_Data_Product__c> finalProductsMap = new Map<String, E2E_Data_Product__c>(finalProductsList);
        for (String oldProductId : this.existingETEProductsMap.keySet()) {
            if (! finalProductsMap.containsKey(oldProductId)) {
                productsToDeleteList.add(this.existingETEProductsMap.get(oldProductId));
            }
        }
        if (!productsToDeleteList.isEmpty()) {
            e2eDatabase.deleteETEProducts(productsToDeleteList);
        }
        this.existingETEProductsMap.clear();
        this.existingETEProductsMap.putAll(finalProductsMap);
    }


    private void doUpsertOfferItems(ETEDatabaseInterface e2eDatabase,
                                    List<ETEUserModel.Product> products,
                                    Map<String, Set<String>> changedFieldsForCurrentStep,
                                    Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        List<E2E_Data_Offer_Item__c> finalOfferItemsList = new List<E2E_Data_Offer_Item__c>();
        List<E2E_Data_Offer_Item__c> offerItemsToUpsertList = new List<E2E_Data_Offer_Item__c>();
        List<E2E_Data_Offer_Item__c> offerItemsToDeleteList = new List<E2E_Data_Offer_Item__c>();

        for (ETEUserModel.Product productModel : products) {
            for (ETEUserModel.Offer_Item offerItemModel : productModel.offerItems) {
                Map<String, Object> inputOfferItemDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(offerItemModel));
                String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputOfferItemDataMap.get('source'),
                                                                        this.existingDataObject.Country_Code__c);
                E2E_Data_Offer_Item__c offerItem;
                if (this.existingETEOfferItems.containsKey(decryptedSource)) {
                    offerItem = this.existingETEOfferItems.get(decryptedSource);
                } else {
                    offerItem = new E2E_Data_Offer_Item__c();
                    offerItem.E2E_Data_Product__c = ETEGlobalUtils.doDecryptParams(productModel.source, this.existingDataObject.Country_Code__c);
                }
                finalOfferItemsList.add(offerItem);
                Boolean offerItemNeedsToUpsert = false;
                if (changedFieldsForCurrentStep.containsKey('E2E_Data_Offer_Item__c')) {
                    for (String fieldName : changedFieldsForCurrentStep.get('E2E_Data_Offer_Item__c')) {
                        String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('offer_item').get(fieldName).get('mapto');
                        if (offerItem.get(fieldName) != inputOfferItemDataMap.get(maptoKey) || offerItem.Id == null) {
                            offerItem.put(fieldName, inputOfferItemDataMap.get(maptoKey));
                            if (offerItemNeedsToUpsert == false) {
                                offerItemNeedsToUpsert = true;
                            }
                        }
                    }
                }
                if (productModel.typeName == 'Shell Fuel Card') {
                    offerItem.Category_Of_Products__c = '2 Category 1 plus vehicle-related goods and services (oils, car wash)';
                } else if (productModel.typeName == 'Lotos Fuel Card') {
                    offerItem.Category_Of_Products__c = 'Lotos All Products';
                }
                if (offerItemNeedsToUpsert == true) { offerItemsToUpsertList.add(offerItem); }
            }
        }
        if (! offerItemsToUpsertList.isEmpty()) {
            e2eDatabase.upsertOfferItems(offerItemsToUpsertList);
        }
        Map<String, E2E_Data_Offer_Item__c> finalOfferItemsMap = new Map<String, E2E_Data_Offer_Item__c>(finalOfferItemsList);
        for (String oldOfferItemId : this.existingETEOfferItems.keySet()) {
            if (! finalOfferItemsMap.containsKey(oldOfferItemId)) {
                offerItemsToDeleteList.add(this.existingETEOfferItems.get(oldOfferItemId));
            }
        }
        if (!offerItemsToDeleteList.isEmpty()) {
            e2eDatabase.deleteOfferItems(offerItemsToDeleteList);
        }
        this.existingETEOfferItems.clear();
        this.existingETEOfferItems.putAll(finalOfferItemsMap);
    }


    private void doUpsertLocatorItems(ETEDatabaseInterface e2eDatabase,
                                    List<ETEUserModel.Product> products,
                                    Map<String, Set<String>> changedFieldsForCurrentStep,
                                    Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        List<E2E_Data_Locator_Item__c> finalLocatorItemsList = new List<E2E_Data_Locator_Item__c>();
        List<E2E_Data_Locator_Item__c> locatorItemsToUpsertList = new List<E2E_Data_Locator_Item__c>();
        List<E2E_Data_Locator_Item__c> locatorItemsToDeleteList = new List<E2E_Data_Locator_Item__c>();

        List<Object> inputProductsDataList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(products));
        for (Object untypedProduct : inputProductsDataList) {
            Map<String, Object> inputUntypedProductDataModelMap = (Map<String, Object>) untypedProduct;
            Object inputFillingStationsUntypedObject = inputUntypedProductDataModelMap.get('stations');
            Object inputFillingStationsNetworksUntypedObject = inputUntypedProductDataModelMap.get('stationsNetworks');
            Map<String, List<Object>> untypedLocatorItemsMap = new Map<String, List<Object>>();
            untypedLocatorItemsMap.put('Station', (List<Object>) inputFillingStationsUntypedObject);
            untypedLocatorItemsMap.put('Network', (List<Object>) inputFillingStationsNetworksUntypedObject);
            for (String locatorItemType : untypedLocatorItemsMap.keySet()) {
                for (Object untypedLocatorItem : untypedLocatorItemsMap.get(locatorItemType)) {
                    Map<String, Object> inputLocatorItemDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(untypedLocatorItem));
                    String decryptedSource = ETEGlobalUtils.doDecryptParams((String) inputLocatorItemDataMap.get('source'),
                                                                            this.existingDataObject.Country_Code__c);
                    E2E_Data_Locator_Item__c locatorItem;
                    if (this.existingETELocatorItems.containsKey(decryptedSource)) {
                        locatorItem = this.existingETELocatorItems.get(decryptedSource);
                    } else {
                        locatorItem = new E2E_Data_Locator_Item__c();
                        locatorItem.Name = (String) inputLocatorItemDataMap.get('name');
                        locatorItem.RecordTypeId = Schema.SObjectType.E2E_Data_Locator_Item__c.getRecordTypeInfosByName().get(locatorItemType).getRecordTypeId();
                        locatorItem.E2E_Data_Product__c = ETEGlobalUtils.doDecryptParams((String) inputUntypedProductDataModelMap.get('source'),
                                                                                        this.existingDataObject.Country_Code__c);
                    }
                    finalLocatorItemsList.add(locatorItem);
                    Boolean locatorItemNeedsToUpsert = false;
                    if (changedFieldsForCurrentStep.containsKey('E2E_Data_Locator_Item__c')) {
                        for (String fieldName : changedFieldsForCurrentStep.get('E2E_Data_Locator_Item__c')) {
                            String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('locator_item').get(fieldName).get('mapto');
                            if (locatorItem.get(fieldName) != inputLocatorItemDataMap.get(maptoKey) || locatorItem.Id == null) {
                                locatorItem.put(fieldName, inputLocatorItemDataMap.get(maptoKey));
                                if (locatorItemNeedsToUpsert == false) {
                                    locatorItemNeedsToUpsert = true;
                                }
                            }
                        }
                    }
                    if (locatorItemNeedsToUpsert == true) {
                        locatorItemsToUpsertList.add(locatorItem);
                    }
                }
            }
        }
        if (! locatorItemsToUpsertList.isEmpty()) {
            e2eDatabase.upsertETELocatorItems(locatorItemsToUpsertList);
        }
        Map<String, E2E_Data_Locator_Item__c> finalLocatorItemsMap = new Map<String, E2E_Data_Locator_Item__c>(finalLocatorItemsList);
        for (String oldLocatorItemId : this.existingETELocatorItems.keySet()) {
            if (! finalLocatorItemsMap.isEmpty() &&
                ! finalLocatorItemsMap.containsKey(oldLocatorItemId)) {
                locatorItemsToDeleteList.add(this.existingETELocatorItems.get(oldLocatorItemId));
            }
        }
        if (!locatorItemsToDeleteList.isEmpty()) {
            e2eDatabase.deleteETELocatorItems(locatorItemsToDeleteList);
        }
        this.existingETELocatorItems.clear();
        this.existingETELocatorItems.putAll(finalLocatorItemsMap);
    }


    private void doUpsertAdditionalServices(ETEDatabaseInterface e2eDatabase,
                                            List<ETEUserModel.Additional_Service> additionalServices,
                                            Set<String> changedAdditionalServicesFieldsSet,
                                            Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStepMap) {
        List<E2E_Data_Additional_Service__c> finalAdditionalServicesList = new List<E2E_Data_Additional_Service__c>();
        Map<String, E2E_Data_Additional_Service__c> additionalServicesToUpsertMap = new Map<String, E2E_Data_Additional_Service__c>();
        List<E2E_Data_Additional_Service__c> additionalServicesToDeleteList = new List<E2E_Data_Additional_Service__c>();
        Map<String, E2E_Data_Additional_Service__c> existingAdditionalServicesMap = new Map<String, E2E_Data_Additional_Service__c>();
        for (E2E_Data_Additional_Service__c additionalService : this.existingAdditionalServicesList) {
            existingAdditionalServicesMap.put(additionalService.Name, additionalService);
        }
        List<Object> inputAdditionalServicesList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(additionalServices));
        for (Object additionalServiceObj : inputAdditionalServicesList) {
            Map<String, Object> inputAdditionalServiceParamsMap = (Map<String, Object>) additionalServiceObj;
            String serviceTypeName = (String) inputAdditionalServiceParamsMap.get('id');
            E2E_Data_Additional_Service__c additionalService;
            if (existingAdditionalServicesMap.containsKey(serviceTypeName)) {
                additionalService = existingAdditionalServicesMap.get(serviceTypeName);
            } else {
                additionalService = new E2E_Data_Additional_Service__c();
                additionalService.Name = serviceTypeName;
                additionalService.E2E_Data_Object__c = this.existingDataObject.Id;
            }
            for (String fieldName : changedAdditionalServicesFieldsSet) {
                String maptoKey = (String) fieldsSettingsForCurrentStepMap.get('additional_service').get(fieldName).get('mapto');
                if (inputAdditionalServiceParamsMap.containsKey(mapToKey)) {
                    if (additionalService.get(fieldName) != inputAdditionalServiceParamsMap.get(maptoKey)) {
                        additionalService.put(fieldName, inputAdditionalServiceParamsMap.get(maptoKey));
                        if (!additionalServicesToUpsertMap.containsKey(additionalService.Name)) {
                            additionalServicesToUpsertMap.put(additionalService.Name, additionalService);
                        }
                    }
                }
            }
            if (existingAdditionalServicesMap.containsKey(serviceTypeName)) {
                existingAdditionalServicesMap.remove(serviceTypeName);
            }
            finalAdditionalServicesList.add(additionalService);
        }
        additionalServicesToDeleteList.addAll(existingAdditionalServicesMap.values());
        if (!additionalServicesToUpsertMap.isEmpty()) {
            e2eDatabase.upsertAdditionalServices(additionalServicesToUpsertMap.values());
        }
        if (!additionalServicesToDeleteList.isEmpty()) {
            e2eDatabase.deleteAdditionalServices(additionalServicesToDeleteList);
        }
        this.existingAdditionalServicesList.clear();
        this.existingAdditionalServicesList.addAll(finalAdditionalServicesList);
    }


    private void upsertDataToRedirection(String country, String opptyId, List<Quote> existingQuotesList, String nextAvailableStep, Map<String, Map<String, Object>> stepDependenciesMap) {
        String methodKey = (String) stepDependenciesMap.get(nextAvailableStep).get('redirection');
        ETERedirectionService redirectionService = ETEGlobalUtils.getETERedirectionService(country);
        Decimal totalAmount = 0;
        if (this.existingDataObject.Security_Amount_To_Pay__c != null) {
            totalAmount =+ this.existingDataObject.Security_Amount_To_Pay__c;
        }
        if (! existingQuotesList.isEmpty()) {
            totalAmount =+ existingQuotesList[0].Grand_Total__c;
        }
        redirectionService.callMethodToPrepareDataToRedirect(methodKey, new Map<String, Object>{
                'countryCode' => this.existingDataObject.Country_Code__c,
                'opptyId' => opptyId,
                'deposit' => totalAmount
        });
    }


    private static Boolean validateField(Object regexObj, Object isRequiredObj, Object objectValue) {
        Boolean isValid = false;
        String regex = (String) regexObj;
        Boolean isRequired = (Boolean) isRequiredObj;
        if (objectValue != null && objectValue != '') {
            if (!String.isEmpty(regex)) {
                isValid = Pattern.matches(regex, String.valueOf(objectValue));
            }
            // temporary block (remove when will be add all regex values);
            else {
                isValid = true;
            }
            /////////////
        } else {
            if (isRequired == false) {
                isValid = true;
            }
        }
        return isValid;
    }
}
