@RestResource(UrlMapping='/e2e')
global without sharing class ETERest {

    @HttpPost
    global static void doPost() {
        ETEResponseHandler responseHandler = new ETEResponseHandler();
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        if (restResponse == null) {
            restResponse = new RestResponse();
            RestContext.response = restResponse;
        }
        restResponse.addHeader('Access-Control-Allow-Origin', 'http://localhost:8080');
        restResponse.addHeader('Access-Control-Allow-Methods', 'POST');

        String requestStr = restRequest.requestBody.toString();
        Map<String, Object> requestParams = (Map<String, Object>) System.JSON.deserializeUntyped(requestStr);
//        try {
//            String countryCode = (String) requestParams.get('country');
//            String siteUrl = ETEGlobalUtils.returnSiteUrl(countryCode);
//            if(restRequest.headers.get('Origin') != siteUrl) {
//                throw new LongFormException('Access Denied');
//            }
            String result;
            String method = (String) requestParams.get('method');
            switch on method {
                when 'doNextStep' {
                    result = doNextStep(responseHandler,
                            requestParams,
                            restRequest.remoteAddress,
                            new PageReference(restRequest.headers.get('Referer')).getParameters(),
                            restRequest.headers.get('User-Agent'),
                            true);
                }
                when 'doNextStepForPending' {
                    result = doNextStepForPending(responseHandler,
                            requestParams,
                            restRequest.remoteAddress,
                            restRequest.headers.get('User-Agent'),
                            false);
                }
                when 'doSearchCompany' { result = doSearchCompany(responseHandler, requestParams); }
                when 'checkSchufaReport' { result = checkSchufaReport(responseHandler, requestParams); }
                when 'doCalculateCreditDecisions' { result = doCalculateCreditDecisions(responseHandler, requestParams, restRequest.headers.get('User-Agent')); }
                when 'getLinkToRedirect' { result = getLinkToRedirect(responseHandler, requestParams); }
                when 'getAdditionalServices' { result = getAdditionalServices(responseHandler, requestParams); }
                when 'createExceptionLog' { result = createExceptionLog(responseHandler, requestParams, restRequest.headers.get('User-Agent')); }
                when 'payLater' { result = payLater(responseHandler, requestParams); }
                when 'htmlView' { result = htmlView(requestParams); }
                when 'getUserModel' { result = getUserModel(responseHandler, requestParams); }
                when 'validateIban' { result = validateIban(responseHandler, requestParams); }
                when 'getSwiftInfo' { result = getSwiftInfo(responseHandler, requestParams); }
                when 'locatorJitbSource' { result = generateSourceByLocator(responseHandler, requestParams); }
                when 'saveFeedback' { result = saveFeedback(responseHandler, requestParams); }
                when 'saveFile' { result = saveFile(responseHandler, requestParams); }
                when 'requestVerificationCode' { result = requestVerificationCode(responseHandler, requestParams); }
                when 'confirmVerificationCode' { result = confirmVerificationCode(responseHandler, requestParams); }
            }
            restResponse.responseBody = Blob.valueOf(result);
            restResponse.statusCode = 200;
//        } catch (Exception e) {
//            Map<String, Object> exceptionResponseParams = responseHandler.generateResponseStatus(e.getMessage());
//            Map<String, Object> exceptionLogParams = responseHandler.prepareExceptionLogParams(requestParams,
//                    ETEGlobalUtils.returnDeviceType(restRequest.headers.get('User-Agent')),
//                    exceptionResponseParams.get('statusCode'),
//                    e.getMessage(),
//                    e,
//                    'Backend');
//            responseHandler.createExceptionLog(exceptionLogParams);
//            String exceptionResponseJson = responseHandler.convertResponseToJson(exceptionResponseParams);
//            restResponse.responseBody = Blob.valueOf(exceptionResponseJson);
//            restResponse.statusCode = 500;
//        }
    }

    private static String htmlView(Map<String, Object> requestParams){
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('countryCode');
        String doc = (String) requestParams.get('type');
        String language = (String) requestParams.get('language');
        String implKey = (String) requestParams.get('implKey');
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            String content = ETEDocumentsCtrl.fillContent(source, countryCode, doc, language, implKey);
            resultMap.put('content', content);
        } catch (Exception e) {
            resultMap.put('error', e.getMessage() + e.getStackTraceString());
        }
        return JSON.serialize(resultMap);
    }


    private static String doNextStep(ETEResponseHandler responseHandler,
                                    Map<String, Object> requestParams,
                                    String ipAddress,
                                    Map<String, String> pageParamsMap,
                                    String userAgentInfo,
                                    Boolean isFirstRequest) {
        String requestUserModelJson = JSON.serialize(requestParams.get('user_model'));
        ETEUserModel userModelFromRequest = (ETEUserModel) System.JSON.deserialize(requestUserModelJson, Type.forName('ETEUserModel'));
        userModelFromRequest.ipAddress = ipAddress;
        userModelFromRequest.deviceType = ETEGlobalUtils.returnDeviceType(userAgentInfo);
        if (! String.isEmpty(userModelFromRequest.utmProducts) ) {
            userModelFromRequest.utmProducts = ETEGlobalUtils.doDecryptParams(userModelFromRequest.utmProducts, userModelFromRequest.countryCode);
        }

        // 1. source param validation from request (request validation)
        ETERequestValidation requestValidation = new ETERequestValidation();
        requestValidation.validateDataObjectSource(userModelFromRequest.source, userModelFromRequest.countryCode);

        // 2. retrieve step settings from database by country
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(userModelFromRequest.countryCode);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(userModelFromRequest.implKey);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(userModelFromRequest.implKey);
        Map<String, Object> filtersOfAvailableStepsMap = new Map<String, Object>();
        filtersOfAvailableStepsMap.put('securityAmountToPay', userModelFromRequest.securityAmountToPay);
        filtersOfAvailableStepsMap.put('selectedCompanyId', userModelFromRequest.selectedCompanyId);
        filtersOfAvailableStepsMap.put('paymentMethod', userModelFromRequest.paymentMethod);
        filtersOfAvailableStepsMap.put('product', userModelFromRequest.products);
        List<String> availableStepsList = e2eStep.getAvailableSteps(defaultSettingsMap, filtersOfAvailableStepsMap);

        // 3. get/init objects to upsert
        String dataObjectId = ETEGlobalUtils.doDecryptParams(userModelFromRequest.source, userModelFromRequest.countryCode);
        E2E_Data_Object__c currentDataObject;
        List<E2E_Data_Contact__c> currentContactsList = new List<E2E_Data_Contact__c>();
        Map<String, E2E_Data_Product__c> currentETEProductsMap = new Map<String, E2E_Data_Product__c>();
        Map<String, E2E_Data_Offer_Item__c> currentETEOfferItemsMap = new Map<String, E2E_Data_Offer_Item__c>();
        Map<String, E2E_Data_Locator_Item__c> currentETELocatorItemsMap = new Map<String, E2E_Data_Locator_Item__c>();
        List<E2E_Data_Additional_Service__c> currentAdditionalServicesList = new List<E2E_Data_Additional_Service__c>();
        if (dataObjectId != null) {
            currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
            currentContactsList = e2eDatabase.retrieveETEContacts(dataObjectId);
            currentETEProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
            currentETEOfferItemsMap = e2eDatabase.retrieveETEOfferItems(currentETEProductsMap.keySet());
            currentETELocatorItemsMap = e2eDatabase.retrieveETELocatorItems(currentETEProductsMap.keySet());
            currentAdditionalServicesList = e2eDatabase.retrieveAdditionalServices(dataObjectId);
            currentAdditionalServicesList = e2eDatabase.retrieveAdditionalServices(dataObjectId);
        } else {
            ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(userModelFromRequest.implKey);
            currentDataObject = businessObjectsHandler.initDataObject(availableStepsList, userModelFromRequest.countryCode, userModelFromRequest.implKey);
        }
        e2eStep.setExistingDataObject(currentDataObject);
        e2eStep.setExistingContacts(currentContactsList);
        e2eStep.setExistingETEProducts(currentETEProductsMap);
        e2eStep.setExistingETEOfferItems(currentETEOfferItemsMap);
        e2eStep.setExistingETELocatorItems(currentETELocatorItemsMap);
        e2eStep.setExistingAdditionalServices(currentAdditionalServicesList);
        Map<String, Map<String, Object>> stepDependenciesMap = e2eStep.returnStepDependencies(defaultSettingsMap);
        Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap = e2eStep.generateExistingLogsMap(e2eDatabase, userModelFromRequest.source);
        e2eStep.setExistingDataLogs(existingLogsMap);

        // 4. check that country from the request is correct
        requestValidation.validateRequestedCountry(currentDataObject.Country_Code__c, userModelFromRequest.countryCode);

        // 5. check next available step by required fields and jobs
        Set<String> requestedStaticResourceName = ETEGlobalUtils.generateStaticResourcesNames(currentDataObject.Country_Code__c,
                new List<String>{userModelFromRequest.currentStep});
        List<String> stepResourceJsonList = e2eDatabase.retrieveStaticResourcesByName(requestedStaticResourceName);
        Map<String, Map<String, Map<String, Object>>> fieldsSettingsForCurrentStep = e2eStep.returnFieldsSettingsForCurrentStep(stepResourceJsonList, userModelFromRequest);
        List<String> availableStepsForCustomerList = e2eStep.getAvailableStepsForCustomer(userModelFromRequest,
                                                                                        availableStepsList,
                                                                                        existingLogsMap,
                                                                                        stepDependenciesMap);
        Map<String, Set<String>> changedFieldsForCurrentStep = e2eStep.setChangedFieldsForCurrentStep(e2eDatabase,
                                                                                        userModelFromRequest,
                                                                                        fieldsSettingsForCurrentStep);
        Map<String, Map<String, Map<String, Set<String>>>> jobsRunSettings = e2eStep.returnJobsRunSettings(userModelFromRequest.currentStep,
                                                                                        stepDependenciesMap);
        List<String> jobsToRunForCurrentStepList = e2eStep.setJobsToRunForCurrentStep(e2eDatabase, changedFieldsForCurrentStep, jobsRunSettings);
        String nextAvailableStep = e2eStep.getNextAvailableStep(userModelFromRequest,
                                                                                        availableStepsList,
                                                                                        existingLogsMap,
                                                                                        stepDependenciesMap,
                                                                                        jobsToRunForCurrentStepList,
                                                                                        false);
        if (userModelFromRequest.currentStep != nextAvailableStep) {
            availableStepsForCustomerList.add(nextAvailableStep);
            for (String jobName : jobsRunSettings.keySet()) {
                if (jobName.contains('sync') && ! jobsToRunForCurrentStepList.contains(jobName)) {
                    jobsToRunForCurrentStepList.add(jobName);
                }
            }
        }
        if (isFirstRequest == true) {
            // 6. data validation and upsert for current step
            Map<String, Map<String, Map<String, Set<String>>>> fieldsCleaningSettings = e2eStep.returnFieldsCleaningSettings(userModelFromRequest.currentStep,
                                                                                        stepDependenciesMap);
            e2eStep.save(e2eDatabase,
                        userModelFromRequest,
                        nextAvailableStep,
                        pageParamsMap,
                        fieldsSettingsForCurrentStep,
                        changedFieldsForCurrentStep,
                        fieldsCleaningSettings,
                        stepDependenciesMap);
        }
        // 7. set deal statuses and next available step
        e2eStep.setDealStatusesForNextStep(e2eDatabase, nextAvailableStep, availableStepsForCustomerList, availableStepsList, existingLogsMap);
        // 8. run jobs
        if (isFirstRequest == true) {
            e2eStep.runJobs(e2eDatabase, jobsToRunForCurrentStepList);
        } else {
            List<String> allJobsToRunForCurrentStepList = e2eStep.getAllJobsToRunForCurrentStep(jobsRunSettings);
            e2eStep.runJobs(e2eDatabase, allJobsToRunForCurrentStepList);

        }
        // 9. return final response
        String transitionStatus = e2eStep.returnTransitionStatus();
        List<ETEUserModel.NavigationMenuStep> navigationMenuSteps = e2eStep.getNavigationMenuSteps(defaultSettingsMap, availableStepsList);
        ETEUserModel preFinalUserModel = e2eStep.convertToUserModel(availableStepsForCustomerList, navigationMenuSteps);
        Map<String, Object> finalUserModel = e2eStep.prepareFinalUserModelToFrontend(preFinalUserModel);
        Map<String, Object> transitionResponseParams = responseHandler.generateResponseStatus(transitionStatus);
        Integer statusCode = (Integer) transitionResponseParams.get('statusCode');
        if (statusCode != 103 && statusCode != 107) {
            transitionResponseParams.put('user_model', finalUserModel);
            if (statusCode == 104 || statusCode == 106 || statusCode == 200) {
                Map<String, Object> exceptionLogParams = responseHandler.prepareExceptionLogParams(requestParams,
                        ETEGlobalUtils.returnDeviceType(userAgentInfo),
                        transitionResponseParams.get('statusCode'),
                        transitionStatus,
                        null,
                        'Backend');
                responseHandler.createExceptionLog(exceptionLogParams);
            }
        }
        String transitionResponseJson = responseHandler.convertResponseToJson(transitionResponseParams);
        return transitionResponseJson;
    }


    private static String doNextStepForPending(ETEResponseHandler responseHandler,
            Map<String, Object> requestParams,
            String ipAddress,
            String userAgentInfo,
            Boolean isFirstRequest) {
        String transitionResponseJson = doNextStep(responseHandler, requestParams, ipAddress, null, userAgentInfo, isFirstRequest);
        return transitionResponseJson;
    }


    private static String doSearchCompany (ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String countryCode = (String) requestParams.get('country');
        Map<String, Object> creditFactoryDataMap = new Map<String, Object>();
        creditFactoryDataMap.put('opportunityName', (String) requestParams.get('requestedCompany'));
        creditFactoryDataMap.put('taxId', (String) requestParams.get('taxId'));
        creditFactoryDataMap.put('vatNumber', (String) requestParams.get('vatNumber'));
        creditFactoryDataMap.put('traderegisterNumber', (String) requestParams.get('tradeRegisterNumber'));
        creditFactoryDataMap.put('countryCode', countryCode);
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(ETEGlobalUtils.returnCountry(countryCode));
        creditFactory.setInternalCFCompany(creditFactoryDataMap);

        String searchParameter = (String) requestParams.get('searchParameter');
        List<CreditFactoryCompany> companiesList = creditFactory.requestSearchCompanies(new Set<String>{searchParameter} );
        List<Object> companiesListSearchResponse = new List<Object>();

        for (Integer i = 0; i < companiesList.size(); i++) {
            CreditFactoryCompany cfcompany = companiesList.get(i);
            companiesListSearchResponse.add(new Map<String, Object>{
                    'index' => i,
                    'id' => cfcompany.identificationNumber,
                    'taxId' => cfcompany.taxId,
                    'vatId' => cfcompany.vatId,
                    'tradeRegisterNumber' => cfcompany.tradeRegisterNumber,
                    'name' => cfcompany.name,
                    'postalCode' => cfcompany.postCode,
                    'country' => cfcompany.country,
                    'city' => cfcompany.city,
                    'street' => cfcompany.street,
                    'houseNumber' => cfcompany.houseNumber
            });
        }

        Map<String, Object> responseParams = responseHandler.generateResponseStatus(null);
        responseParams.put('companies', companiesListSearchResponse);
        String responseJson = responseHandler.convertResponseToJson(responseParams);
        return responseJson;
    }


    private static String checkSchufaReport(ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String source = (String) requestParams.get('source');
        Decimal index = (Decimal) requestParams.get('index');
        String countryCode = (String) requestParams.get('countryCode');
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        String country = ETEGlobalUtils.returnCountry(countryCode);
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        E2E_Data_Log__c requestReportJob = e2eDatabase.retrieveE2EDataLogByName(dataObjectId, 'reportRequest').get(0);
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(null);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        try {
            if (requestReportJob.Job_Status__c == 'Queued' || requestReportJob.Job_Status__c == 'Restart') {
                if (!String.isEmpty(requestReportJob.Job_ID__c)) {
                    List<Map<String, Object>> contactsList = new List<Map<String, Object>>();
                    Map<String, Object> contactsDataMap = new Map<String, Object>();
                    contactsDataMap.put('firstName', currentDataObject.First_Name__c);
                    contactsDataMap.put('lastName', currentDataObject.Last_Name__c);
                    contactsDataMap.put('isPrimary', true);
                    contactsDataMap.put('email', currentDataObject.Email__c);
                    contactsDataMap.put('relation', 'OpportunityContactRole');
                    contactsList.add(contactsDataMap);
                    Map<String, E2E_Data_Product__c> eteProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
                    Map<String, E2E_Data_Offer_Item__c> eteDataOfferItemsMap = e2eDatabase.retrieveETEOfferItems(eteProductsMap.keySet());
                    ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(currentDataObject.RecordType.Name);
                    Map<String, Object> consumptionDataMap = e2eStep.doCalculateConsumption(currentDataObject, eteProductsMap, eteDataOfferItemsMap.values());
                    Map<String, Object> creditFactoryDataMap = new Map<String, Object>();
                    creditFactoryDataMap.put('creditFactoryContacts', contactsList);
                    creditFactoryDataMap.put('totalConsumption', (Decimal) consumptionDataMap.get('totalConsumption'));
                    creditFactoryDataMap.put('countryCode', currentDataObject.Country_Code__c);
                    CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(country);
                    creditFactory.setInternalCFCompany(creditFactoryDataMap);
                    CreditFactoryReportsItem reportsItem = creditFactory.requestCompanyReports(currentDataObject.Selected_Company_Id__c);
                    if (reportsItem.isWaiting == true) {
                        if (index < 15) {
                            responseParams = responseHandler.generateResponseStatus('report pending');
                        } else {
                            responseParams = responseHandler.generateResponseStatus('The order is still being processed. Please contact your administrator.');
                            requestReportJob.Exception_Type__c = 'CF System Error';
                            requestReportJob.Exception_Description__c = 'The order is still being processed. Please contact your administrator.';
                        }
                    } else {
                        if (reportsItem.isReportAvailable == true) {
                            Opportunity opportunity = e2eDatabase.retrieveOpportunity(currentDataObject.Id);
                            List<Credit_Factory_Report__c> existingCFReports = e2eDatabase.retrieveCFReports(opportunity.Id);
                            Set<String> cfAttachmentsNames = new Set<String>();
                            cfAttachmentsNames.addAll(CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).values());
                            List<Attachment> existingCFAttachments = e2eDatabase.retrieveAttchments(cfAttachmentsNames, opportunity.Id);
                            List<Credit_Factory_Report__c> reportsList = new List<Credit_Factory_Report__c>();
                            if (!Test.isRunningTest()) {
                                reportsList = creditFactory.createCFReportsInstances();
                            } else {
                                reportsList.add(CreditFactoryTestUtils.generateCreditFactoryReport(country));
                            }
                            for (Credit_Factory_Report__c report : reportsList) {
                                report.Opportunity__c = opportunity.Id;
                            }
                            // upsert credit factory reports
                            e2eDatabase.upsertCreditFactoryReports(reportsList);
                            if (!Test.isRunningTest()) {
                                creditFactory.createPdfReports(opportunity.Id);
                            }

                            // upsert credit factory employees
                            List<Credit_Factory_Report_Employee__c> reportEmployees = new List<Credit_Factory_Report_Employee__c>();
                            if (!Test.isRunningTest()) {
                                reportEmployees = creditFactory.createCFReportEmployeesInstances();
                            } else {
                                reportEmployees.add(CreditFactoryTestUtils.generateCreditFactoryReportEmployee(country));
                            }
                            for (Credit_Factory_Report_Employee__c employee : reportEmployees) {
                                employee.Credit_Factory_Report__c = reportsList.get(0).Id;
                            }
                            e2eDatabase.upsertCreditFactoryEmployees(reportEmployees);

                            // upsert opportunity
                            if (opportunity.E2E_CF_Reports_Counter__c == null) {
                                opportunity.E2E_CF_Reports_Counter__c = 0;
                            }
                            opportunity.E2E_CF_Reports_Counter__c = opportunity.E2E_CF_Reports_Counter__c + 1;
                            e2eDatabase.upsertOpportunity(opportunity);
                            if (String.isEmpty(requestReportJob.Exception_Description__c)) {
                                if (!existingCFReports.isEmpty()) {
                                    e2eDatabase.deleteCreditFactoryReports(existingCFReports);
                                }
                                if (!existingCFAttachments.isEmpty()) {
                                    e2eDatabase.deleteAttchments(existingCFAttachments);
                                }
                            }
                        } else {
                            // report doesn't exist;
                            requestReportJob.Exception_Type__c = 'Company search';
                            requestReportJob.Exception_Description__c = 'Report does not exist';
                        }
                    }
                } else {
                    responseParams = responseHandler.generateResponseStatus('report pending');
                }
            }
        } catch (Exception e) {
            requestReportJob.Exception_Type__c = 'CF System Error';
            requestReportJob.Exception_Description__c = e.getMessage() + ' (Cls: ' + e.getStackTraceString() + ')';
            responseParams = responseHandler.generateResponseStatus(e.getMessage());
        }
        if (responseParams.get('statusCode') != 105 && requestReportJob.Job_Status__c != 'Completed') {
            requestReportJob.Job_Status__c = 'Completed';
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{ requestReportJob });
            // run next job
            if (!Test.isRunningTest()) {
                ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(new List<String>(), dataObjectId, countryCode, currentDataObject.RecordType.Name);
                jobChainHandler.runJob();
            }
        }
        String responseJson = responseHandler.convertResponseToJson(responseParams);
        return responseJson;
    }


    private static String doCalculateCreditDecisions(ETEResponseHandler responseHandler,
                                                    Map<String, Object> requestParams,
                                                    String userAgentInfo) {
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('country');
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        String opportunityId = (e2eDatabase.retrieveOpportunity(currentDataObject.Id)).Id;
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(currentDataObject.RecordType.Name);
        String country = ETEGlobalUtils.returnCountry(currentDataObject.Country_Code__c);
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(currentDataObject.RecordType.Name);
        CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(opportunityId);
        CreditFactoryResult cfResult = e2eStep.getCreditFactoryDecisions(e2eDatabase, creditFactory, currentDataObject.Id,
                opportunityId, country, cfReportsItem.companiesList);
        CreditFactoryCompany cfCompany;
        for (CreditFactoryCompany cfReport : cfReportsItem.companiesList) {
            if (cfReport.recordType == 'Default') {
                cfCompany = cfReport;
                break;
            }
        }
        if (cfResult.requiredUpdates == 'Payment history data') {
            Map<String, Object> paymentHistoryFieldsToUpdate = creditFactory.returnPaymentHistoryFieldsToUpdate();
            Credit_Factory_Report__c existingReport;
            if (! String.isEmpty(cfCompany.id)) {
                existingReport = new Credit_Factory_Report__c(Id = cfCompany.id);
                if (paymentHistoryFieldsToUpdate.containsKey('Credit_Factory_Report__c')) {
                    Map<String, Object> fieldsMap = (Map<String, Object>) paymentHistoryFieldsToUpdate.get('Credit_Factory_Report__c');
                    for (String cfFieldApiName : fieldsMap.keySet()) {
                        existingReport.put(cfFieldApiName, fieldsMap.get(cfFieldApiName));
                    }
                    e2eDatabase.upsertCreditFactoryReports(new List<Credit_Factory_Report__c> {existingReport});
                    creditFactory.createPaymentHistoryAttachment(opportunityId);
                }
            }
        }
        String creditScoringError = responseHandler.checkCreditScoringErrors(cfResult.verdict, cfResult.statusCode);
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(creditScoringError);
        if (creditScoringError != null) {
            Map<String, Object> exceptionLogParams = responseHandler.prepareExceptionLogParams(requestParams,
                                                                                                ETEGlobalUtils.returnDeviceType(userAgentInfo),
                                                                                                responseParams.get('statusCode'),
                                                                                                creditScoringError,
                                                                                                null,
                                                                                                'Backend');
            e2eStep.setExistingDataObject(currentDataObject);
            Map<String, E2E_Data_Log__c> existingExceptionsMap = e2eStep.generateExistingLogsMap(e2eDatabase, source).get('Exception');
            Set<String> errorsSet = new Set<String>();
            for (E2E_Data_Log__c dataLog : existingExceptionsMap.values()) {
                errorsSet.add(dataLog.Exception_Description__c);
            }
            if (! errorsSet.contains((String) exceptionLogParams.get('exceptionMessage'))) {
                responseHandler.createExceptionLog(exceptionLogParams);
                if (! errorsSet.contains((String) exceptionLogParams.get('exceptionMessage'))) {
                    responseHandler.createExceptionLog(exceptionLogParams);
                    if (exceptionLogParams.get('exceptionMessage') == 'Executions and potentially high exposure' &&
                            (currentDataObject.RecordType.Name == 'Czech Republic CCS' || currentDataObject.RecordType.Name == 'Slovakia CCS')) {
                        Credit_Black_List_Company__c blackListCompany = creditFactory.createBlackListInstance();
                        e2eDatabase.insertCreditBlackList(blackListCompany);
                    }
                }
            }
            // TEMP UNTIL IMPLEMENT IT TO ALL COUNTRIES
            if (currentDataObject.RecordType.Name != 'Poland' &&
                (creditScoringError == 'Black list' ||
                creditScoringError == 'High e-mail risk' ||
                creditScoringError == 'High risk industry')) {
                responseParams.put('statusCode', 104);
            }
        }
        Decimal availableMinDeposit = e2eStep.returnAvailableMinDeposit(cfResult.resultsList);
        if (currentDataObject.Registered_Postal_Code__c == null || currentDataObject.Registered_Country__c == null ||
                currentDataObject.Registered_City__c == null || currentDataObject.Registered_Street__c == null ||
                currentDataObject.Available_Min_Deposit__c != availableMinDeposit) {
            currentDataObject.Registered_Postal_Code__c = cfCompany.postCode;
            currentDataObject.Registered_Country__c = country;
            cfCompany.city = cfCompany.city == null ? cfCompany.city = '' : cfCompany.city;
            cfCompany.city = cfCompany.city.contains('-') ? cfCompany.city.substringBefore('-') : cfCompany.city;
            cfCompany.city = cfCompany.city.length() > 40 ? cfCompany.city.substring(0,40) : cfCompany.city;
            currentDataObject.Registered_City__c = cfCompany.city;
            currentDataObject.Registered_Street__c = cfCompany.street + ' ' + (cfCompany.houseNumber != null ? cfCompany.houseNumber : '');
            currentDataObject.Company_Form__c = cfCompany.legalForm;
            currentDataObject.Available_Min_Deposit__c = availableMinDeposit;
            currentDataObject.Tax_ID__c = cfCompany.taxId;
            currentDataObject.Vat_ID__c = cfCompany.vatNumber;
            e2eDatabase.upsertDataObject(currentDataObject);
        }
        if (responseParams.get('statusCode') == 100) {
            responseParams.put('cf_decisions', cfResult.resultsList);
        }
        String responseJson = responseHandler.convertResponseToJson(responseParams);
        return responseJson;
    }


    private static String getLinkToRedirect(ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        Map<String, Object> userModelMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(requestParams.get('user_model')));
        String countryCode = (String) userModelMap.get('countryCode');
        String implKey = (String) userModelMap.get('implKey');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(implKey);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
        Map<String, Map<String, Object>> stepDependenciesMap = e2eStep.returnStepDependencies(defaultSettingsMap);
        String methodKey = (String) stepDependenciesMap.get((String) userModelMap.get('currentStep')).get('redirection');
        ETERedirectionService redirectionService = ETEGlobalUtils.getETERedirectionService(countryCode);
        String source = (String) userModelMap.get('source');
        Map<String, Object> requestToRedirectionParams = new Map<String, Object>{
                'countryCode' => countryCode,
                'source' => source
        };
        if (defaultSettingsMap.containsKey('docusign_fields_mapping')) {
            requestToRedirectionParams.put('docusign_fields_mapping', defaultSettingsMap.get('docusign_fields_mapping'));
        }
        String linkToRedirect = redirectionService.callMethodToGetRedirectLink(methodKey, requestToRedirectionParams);
        Map<String, Object> linkGenerationResponseParams = new Map<String, Object>();
        if (! String.isEmpty(linkToRedirect)) {
            linkGenerationResponseParams = responseHandler.generateResponseStatus('redirection need');
            if (methodKey == 'ingenico') {
                String eteFormType = ETEGlobalUtils.returnETEFormType(countryCode);
                linkGenerationResponseParams.put('endpoint', E2EKeysAPI__c.getValues(eteFormType).paymentTransactionURL__c);
                linkGenerationResponseParams.put('params_to_redirect', linkToRedirect);
            } else {
                linkGenerationResponseParams.put('redirect_to', linkToRedirect);
            }
        } else {
            linkGenerationResponseParams = responseHandler.generateResponseStatus('there is no active payment transaction');
        }
        String redirectResponseJson = responseHandler.convertResponseToJson(linkGenerationResponseParams);
        return redirectResponseJson;
    }


    private static String createExceptionLog(ETEResponseHandler responseHandler,
            Map<String, Object> requestParams,
            String userAgentInfo) {
        String deviceType = ETEGlobalUtils.returnDeviceType(userAgentInfo);
        requestParams.put('deviceType', deviceType);
        responseHandler.createExceptionLog(requestParams);
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(null);
        String responseJson = responseHandler.convertResponseToJson(responseParams);
        return responseJson;
    }


    private static String getAdditionalServices (ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        List<Offer_Additional_Service__c> servicesList = ETEAdditionalServicesService.selectAdditionalServices(requestParams);
        String responseJson = ETEAdditionalServicesService.generateJSONResponseBody(servicesList);
        return responseJson;
    }


    private static String payLater(ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('country');
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        List<E2E_Data_Contact__c> currentContactsList = e2eDatabase.retrieveETEContacts(dataObjectId);
        Map<String, E2E_Data_Product__c> currentETEProductsMap = e2eDatabase.retrieveETEProducts(currentDataObject.Id);
        Map<String, E2E_Data_Offer_Item__c> currentETEOfferItemsMap = e2eDatabase.retrieveETEOfferItems(currentETEProductsMap.keySet());
        Map<String, E2E_Data_Locator_Item__c> currentETELocatorItemsMap = e2eDatabase.retrieveETELocatorItems(currentETEProductsMap.keySet());
        List<E2E_Data_Additional_Service__c> currentAdditionalServicesList = e2eDatabase.retrieveAdditionalServices(dataObjectId);
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(currentDataObject.RecordType.Name);
        e2eStep.setExistingDataObject(currentDataObject);
        e2eStep.setExistingContacts(currentContactsList);
        e2eStep.setExistingETEProducts(currentETEProductsMap);
        e2eStep.setExistingETEOfferItems(currentETEOfferItemsMap);
        e2eStep.setExistingETELocatorItems(currentETELocatorItemsMap);
        e2eStep.setExistingAdditionalServices(currentAdditionalServicesList);
        e2eStep.setPayLaterDealStatus(e2eDatabase);
        e2eStep.runJobs(e2eDatabase, new List<String>{'syncFinishedDeal'});
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(null);
        ETEUserModel preFinalUserModel = e2eStep.convertToUserModel(new List<String>(), new List<ETEUserModel.NavigationMenuStep>());
        Map<String, Object> finalUserModel = e2eStep.prepareFinalUserModelToFrontend(preFinalUserModel);
        responseParams.put('user_model', finalUserModel);
        String responseJson = responseHandler.convertResponseToJson(responseParams);
        return responseJson;
    }


    private static String getUserModel(ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('country');
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        String implKey = (String) requestParams.get('implKey');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        List<E2E_Data_Contact__c> currentContactsList = e2eDatabase.retrieveETEContacts(dataObjectId);
        Map<String, E2E_Data_Product__c> currentETEProductsMap = e2eDatabase.retrieveETEProducts(currentDataObject.Id);
        Map<String, E2E_Data_Offer_Item__c> currentETEOfferItemsMap = e2eDatabase.retrieveETEOfferItems(currentETEProductsMap.keySet());
        Map<String, E2E_Data_Locator_Item__c> currentETELocatorItemsMap = e2eDatabase.retrieveETELocatorItems(currentETEProductsMap.keySet());
        List<E2E_Data_Additional_Service__c> currentAdditionalServicesList = e2eDatabase.retrieveAdditionalServices(dataObjectId);
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
        e2eStep.setExistingDataObject(currentDataObject);
        e2eStep.setExistingContacts(currentContactsList);
        e2eStep.setExistingETEProducts(currentETEProductsMap);
        e2eStep.setExistingETEOfferItems(currentETEOfferItemsMap);
        e2eStep.setExistingETELocatorItems(currentETELocatorItemsMap);
        e2eStep.setExistingAdditionalServices(currentAdditionalServicesList);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(implKey);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        Map<String, Object> filtersOfAvailableStepsMap = new Map<String, Object>();
        filtersOfAvailableStepsMap.put('securityAmountToPay', currentDataObject.Security_Amount_To_Pay__c);
        filtersOfAvailableStepsMap.put('selectedCompanyId', currentDataObject.Selected_Company_Id__c);
        filtersOfAvailableStepsMap.put('paymentMethod', currentDataObject.Payment_Method__c);
        filtersOfAvailableStepsMap.put('product', currentETEProductsMap.values());
        List<String> availableStepsList = e2eStep.getAvailableSteps(defaultSettingsMap, filtersOfAvailableStepsMap);
        Map<String, Map<String, Object>> stepDependenciesMap = e2eStep.returnStepDependencies(defaultSettingsMap);
        Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap = e2eStep.generateExistingLogsMap(e2eDatabase, ETEGlobalUtils.doEncryptParams(currentDataObject.Id, countryCode));
        List<String> availableStepsForCustomerList = e2eStep.getAvailableStepsForCustomer(currentDataObject,
                availableStepsList,
                existingLogsMap,
                stepDependenciesMap);
        List<ETEUserModel.NavigationMenuStep> navigationMenuSteps = e2eStep.getNavigationMenuSteps(defaultSettingsMap, availableStepsList);
        ETEUserModel preFinalUserModel = e2eStep.convertToUserModel(availableStepsForCustomerList, navigationMenuSteps);
        Map<String, Object> finalUserModel = e2eStep.prepareFinalUserModelToFrontend(preFinalUserModel);
        Map<String, Object> transitionResponseParams = responseHandler.generateResponseStatus(null);
        transitionResponseParams.put('user_model', finalUserModel);
        String transitionResponseJson = responseHandler.convertResponseToJson(transitionResponseParams);
        return transitionResponseJson;
    }


    private static String validateIban(ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String iban = (String) requestParams.get('iban');
        Boolean ibanIsValid = SEPA_Toolkit.SEPAUtilities.ValidateIBAN(iban);
        Map<String, Object> transitionResponseParams = responseHandler.generateResponseStatus(null);
        transitionResponseParams.put('iban', iban);
        transitionResponseParams.put('is_valid', ibanIsValid);
        String ibanValidationResult = responseHandler.convertResponseToJson(transitionResponseParams);
        return ibanValidationResult;
    }


    private static String getSwiftInfo(ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String swift;
        Organization org = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
        if (org.IsSandbox == true && ! Test.isRunningTest()) {
            swift = 'GKCCBEBB';
        } else {
            String countryCode = (String) requestParams.get('countryCode');
            String iban = (String) requestParams.get('iban');
            IBAN_API_Settings__c ibanApiSettings = IBAN_API_Settings__c.getInstance(ETEGlobalUtils.returnCountry(countryCode));
            Blob headerValue = Blob.valueOf(ibanApiSettings.Login__c + ':' + ibanApiSettings.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = ibanApiSettings.Endpoint__c + iban;
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', authorizationHeader);
            HttpResponse response = h.send(request);
            IbanResponse ibanResponse = (IbanResponse)JSON.deserialize(response.getBody(), IbanResponse.class);
            if (! ibanResponse.all_bic_candidates.isEmpty()) {
                swift = ibanResponse.all_bic_candidates.get(0).bic;
            }
        }
        Map<String, Object> transitionResponseParams = responseHandler.generateResponseStatus(null);
        transitionResponseParams.put('swift', swift);
        String swiftInfo = responseHandler.convertResponseToJson(transitionResponseParams);
        return swiftInfo;
    }

    private static String generateSourceByLocator(ETEResponseHandler responseHandler, Map<String, Object> requestParams){

        String esi = (String) requestParams.get('esi');
        String country = (String) requestParams.get('country');
        String countryCode = (String) requestParams.get('countryCode');
        String recordType = (String) requestParams.get('recordType');
        String homeStation = (String) requestParams.get('homeStation');

        List<Account> retailerAccount = ETEDataGenerator.getRetailerAccount(country, esi);

        Decimal random = Integer.valueOf(Math.random() * 100000000);
        String formName = 'NEW ETE CUSTOMER:' + esi + '_' + String.valueOf(random);
        Account account = ETEDataGenerator.insertAccount('Endkunde', country, formName);

        E2E_Data_Object__c e2EDataObject = ETEDataGenerator.insertE2EDataObject(
                'products_and_services',
                'Prospecting',
                recordType,
                'jitb',
                null,
                esi,
                countryCode,
                countryCode,
                esi,
                homeStation,
                null
        );

        E2E_Data_Log__c dataLog = ETEDataGenerator.insertE2EDataLog(
                'Job_Status',
                e2EDataObject.Id,
                'Completed',
                'checkBusinessObjects'
        );

        Opportunity opportunity = ETEDataGenerator.insertOpportunity(
                formName,
                retailerAccount,
                account.Id,
                'Euroshell',
                'Prospecting',
                country,
                null,
                ETEDataGenerator.sourceURL,
                esi,
                e2EDataObject.Id,
                'JITB'
        );

        Contact contact = ETEDataGenerator.insertContact(
                formName,
                'Contact layout',
                account.Id,
                null,
                country
        );

        ETEDataGenerator.insertOpportunityContactRole(opportunity.Id, contact.Id);
        ETEDataGenerator.setPartnerRelationship(retailerAccount, opportunity.Id);


        Map<String,Object> result = responseHandler.generateResponseStatus(null);
        result.put('source', opportunity.E2E_Encoded_URL__c);
        return responseHandler.convertResponseToJson(result);
    }


    private static String saveFeedback(ETEResponseHandler responseHandler, Map<String, Object> requestParams){
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('countryCode');
//        String country = ETEGlobalUtils.returnCountry(countryCode);
        String implKey = (String) requestParams.get('implKey');
        String feedbackLocal = (String) requestParams.get('feedback');
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
//        String feedbackEnglish = e2eStep.translateTextToEnglish(country, feedbackLocal);
        Map<String, Object> customerFeedbackParams = new Map<String, Object>();
        customerFeedbackParams.put('implKey', implKey);
        customerFeedbackParams.put('rating', requestParams.get('rating'));
        customerFeedbackParams.put('feedbackLocal', feedbackLocal);
        customerFeedbackParams.put('feedbackEnglish', null);
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject;
        if (dataObjectId != null) {
            currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        } else {
            Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(implKey);
            List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
            Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
            Map<String, Object> filtersOfAvailableStepsMap = new Map<String, Object>();
            filtersOfAvailableStepsMap.put('securityAmountToPay', 0);
            filtersOfAvailableStepsMap.put('selectedCompanyId', null);
            filtersOfAvailableStepsMap.put('paymentMethod', null);
            filtersOfAvailableStepsMap.put('product', null);
            List<String> availableStepsList = e2eStep.getAvailableSteps(defaultSettingsMap, filtersOfAvailableStepsMap);
            ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(implKey);
            currentDataObject = businessObjectsHandler.initDataObject(availableStepsList, countryCode, implKey);
            currentDataObject.Name = currentDataObject.Selected_Company_Name__c;
            e2eDatabase.upsertDataObject(currentDataObject);
        }
        e2eStep.saveCustomerFeedback(e2eDatabase, currentDataObject, customerFeedbackParams);

        Map<String, Object> responseParams = responseHandler.generateResponseStatus(null);
        responseParams.put('source', ETEGlobalUtils.doEncryptParams(currentDataObject.Id, countryCode));
        String responseJson = responseHandler.convertResponseToJson(responseParams);
        return responseJson;
    }


    private static String saveFile (ETEResponseHandler responseHandler, Map<String, Object> requestParams){
        String implKey = (String) requestParams.get('implKey');
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
        e2eStep.saveFile(requestParams);
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(null);
        return responseHandler.convertResponseToJson(responseParams);
    }


    private static String requestVerificationCode(ETEResponseHandler responseHandler, Map<String, Object> requestParams){
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('countryCode');
        String recipientEmail = (String) requestParams.get('email');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        String replyTo = ETEGlobalUtils.returnSenderEmailAddress(currentDataObject.RecordType.Name);
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(currentDataObject.RecordType.Name);
        currentDataObject = e2eStep.generateVerificationCode(e2eDatabase, currentDataObject);
        E2E_Data_Contact__c e2ePrimaryContact = e2eDatabase.retrieveETEPrimaryContact(currentDataObject.Id);
        List<Contact> primaryContact = e2eDatabase.retrieveContacts(new Set<String>{e2ePrimaryContact.Fleetcor_Contact__c});
        String emailTemplateName = ETEGlobalUtils.returnOrderConfirmationEmailTemplateName(currentDataObject.RecordType.Name);
        Map<String, EmailTemplate> templatesMap = e2eDatabase.retrieveEmailTemplatesByNames(new Set<String>{emailTemplateName});
        String messageStatus = e2eStep.sendVerificationCode(currentDataObject.Id,
                                                            primaryContact[0].Id,
                                                            replyTo,
                                                            new List<String>{recipientEmail},
                                                            templatesMap.get(emailTemplateName).Id);
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(messageStatus);
        return responseHandler.convertResponseToJson(responseParams);
    }


    private static String confirmVerificationCode (ETEResponseHandler responseHandler, Map<String, Object> requestParams) {
        String source = (String) requestParams.get('source');
        String countryCode = (String) requestParams.get('countryCode');
        String verificationCode = (String) requestParams.get('verificationCode');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(currentDataObject.RecordType.Name);
        String verificationStatus = e2eStep.validateVerificationCode(e2eDatabase, currentDataObject, verificationCode);
        Map<String, Object> responseParams = responseHandler.generateResponseStatus(verificationStatus);
        return responseHandler.convertResponseToJson(responseParams);
    }
}