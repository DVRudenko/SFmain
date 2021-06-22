@IsTest
private class ETEPLTest {
    static final String COUNTRY_CODE = 'pl';
    static final String COUNTRY = 'Poland';
    static final String NEW_CUSTOMER = 'NEW E2E CUSTOMER';
    static final String IMPL_KEY_SHELL = 'Poland';
    static final String IMPL_KEY_LOTOS = 'Poland Lotos';
    static final String OFFER_ITEM_TYPE_SHELL = 'Shell Fuel Card';
    static final String OFFER_ITEM_TYPE_LOTOS = 'Lotos Fuel Card';
    static final String PRODUCT_NAME_SHELL = 'Shell Basic 2020';
    static final String PRODUCT_NAME_LOTOS = 'Lotos Biznes';


    @TestSetup
    static void createLongFormData() {
        ETEUtilsTest.createCustomSettings(COUNTRY, IMPL_KEY_SHELL);
        ETEUtilsTest.createStaticResourceForSteps();
        ETEUtilsTest.createStaticResource('ETE_common_components_translations');
        ETEUtilsTest.createStaticResource('ETE_default_settings_pl');
        ETEUtilsTest.createStaticResource('ETE_default_settings_lotos_pl');
        ETEUtilsTest.createE2EApiKeys('E2EFormPL');
        createMultiproductData(COUNTRY_CODE);
    }


    @IsTest
    static void formFirstLoadingTest() {
        Test.startTest();
            ApexPages.currentPage().getparameters().put('utm_products', ETEGlobalUtils.doEncryptParams('product1;product2', COUNTRY_CODE));
            ETEController e2eFormCtrl = new ETEController();
            e2eFormCtrl.runLongFormPL();
        Test.stopTest();
    }


    @IsTest
    static void returnToFormTest() {
        Test.startTest();
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('source', encodedStr);
        ETEController e2eFormCtrl = new ETEController();
        e2eFormCtrl.runLongFormPL();
        Test.stopTest();
    }


    @IsTest
    static void saveCustomerFeedbackTest() {
        String stepName = ETEUtilsTest.STEPS.products_and_services.name();
        // create offer
        Product2 fleetcorOffer = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL];
        Offer_Item_Type__c offerItemType = [SELECT Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL];

        Map<String, Object> feedbackBody = new Map<String, Object>{
                'method' => 'saveFeedback',
                'countryCode' => COUNTRY_CODE,
                'implKey' => IMPL_KEY_SHELL,
                'source' => '',
                'rating' => 50,
                'feedback' => 'Hello World!'
        };
        Test.startTest();
        ETEUtilsTest.prepareRequest(JSON.serialize(feedbackBody), COUNTRY_CODE);
        ETERest.doPost();
        E2E_Data_Object__c dataObject = [SELECT Id FROM E2E_Data_Object__c];
        String source = ETEGlobalUtils.doEncryptParams(dataObject.Id, COUNTRY_CODE);
        Map<String, Object> nextStepRequestBody = new Map<String, Object>{
                'method' => 'doNextStep',
                'country' => COUNTRY_CODE,
                'user_model' => new Map<String, Object>{
                        'source' => source,
                        'currentStep' => stepName,
                        'implKey' => IMPL_KEY_SHELL,
                        'countryCode' => COUNTRY_CODE,
                        'currentLang' => COUNTRY_CODE,
                        'name' => NEW_CUSTOMER,
                        'selectedCompanyName' => NEW_CUSTOMER,
                        'products' => new List<Object>{
                                new Map<String, Object>{
                                        'name' => PRODUCT_NAME_SHELL,
                                        'productId' => ETEGlobalUtils.doEncryptParams(fleetcorOffer.Id, COUNTRY_CODE),
                                        'typeName' => offerItemType.Name,
                                        'typeId' => ETEGlobalUtils.doEncryptParams(offerItemType.Id, COUNTRY_CODE),
                                        'offerItems' => new List<Object>{
                                                new Map<String, Object>{
                                                        'driverName' => 'Karta Shell 1',
                                                        'typeOfCard' => 'Multi Network Card -- National',
                                                        'typeOfVehicle' => 'PKW',
                                                        'monthlyFuelConsumption' => '300'
                                                }
                                        },
                                        'stations' => new List<Object>(),
                                        'stationsNetworks' => new List<Object>()
                                }
                        }
                }
        };
        ETEUtilsTest.prepareRequest(JSON.serialize(nextStepRequestBody), COUNTRY_CODE);
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, stepName, dataObject.Id, IMPL_KEY_SHELL);
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();
        List<Opportunity> opps = [SELECT Id, (SELECT Id FROM Customer_Feedbacks__r) FROM Opportunity WHERE E2E_Data_Object__c = :dataObject.Id];
        System.assertEquals(1, opps.size());
        System.assertEquals(1, opps.get(0).Customer_Feedbacks__r.size());
    }


    @IsTest
    static void pasStepSaveDataPositiveTest() {
        String stepName = ETEUtilsTest.STEPS.products_and_services.name();
        Product2 fleetcorOffer = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL];
        Offer_Item_Type__c offerItemType = [SELECT Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL];

        Map<String, Object> body = new Map<String, Object>{
                'method' => 'doNextStep',
                'country' => COUNTRY_CODE,
                'user_model' => new Map<String, Object>{
                        'currentStep' => stepName,
                        'implKey' => IMPL_KEY_SHELL,
                        'countryCode' => COUNTRY_CODE,
                        'currentLang' => COUNTRY_CODE,
                        'name' => NEW_CUSTOMER,
                        'selectedCompanyName' => NEW_CUSTOMER,
                        'products' => new List<Object>{
                                new Map<String, Object>{
                                        'name' => PRODUCT_NAME_SHELL,
                                        'productId' => ETEGlobalUtils.doEncryptParams(fleetcorOffer.Id, COUNTRY_CODE),
                                        'typeName' => offerItemType.Name,
                                        'typeId' => ETEGlobalUtils.doEncryptParams(offerItemType.Id, COUNTRY_CODE),
                                        'offerItems' => new List<Object>{
                                                new Map<String, Object>{
                                                        'driverName' => 'Karta Shell 1',
                                                        'typeOfCard' => 'Multi Network Card -- National',
                                                        'typeOfVehicle' => 'PKW',
                                                        'monthlyFuelConsumption' => '300'
                                                }
                                        },
                                        'stations' => new List<Object>(),
                                        'stationsNetworks' => new List<Object>()
                                }
                        }
                }
        };

        Test.startTest();
        {
            ETEUtilsTest.prepareRequest(JSON.serialize(body), COUNTRY_CODE);
            ETERest.doPost();
            E2E_Data_Object__c dataObject = [SELECT Id FROM E2E_Data_Object__c];
            ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, stepName, dataObject.Id, IMPL_KEY_SHELL);
            ETEUtilsTest.checkStatusCodeAndNextStep(COUNTRY_CODE, stepName);
        }
        Test.stopTest();
    }


    @IsTest
    static void pasStepSaveDataLotosPositiveTest() {
        String stepName = ETEUtilsTest.STEPS.products_and_services.name();
        Product2 fleetcorOffer = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_LOTOS];
        Offer_Item_Type__c offerItemType = [SELECT Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_LOTOS];

        Map<String, Object> body = new Map<String, Object>{
                'method' => 'doNextStep',
                'country' => COUNTRY_CODE,
                'user_model' => new Map<String, Object>{
                        'currentStep' => stepName,
                        'implKey' => IMPL_KEY_LOTOS,
                        'countryCode' => COUNTRY_CODE,
                        'currentLang' => COUNTRY_CODE,
                        'name' => NEW_CUSTOMER,
                        'selectedCompanyName' => NEW_CUSTOMER,
                        'utmProducts' => ETEGlobalUtils.doEncryptParams('product1;product2', COUNTRY_CODE),
                        'products' => new List<Object>{
                                new Map<String, Object>{
                                        'name' => PRODUCT_NAME_SHELL,
                                        'productId' => ETEGlobalUtils.doEncryptParams(fleetcorOffer.Id, COUNTRY_CODE),
                                        'typeName' => offerItemType.Name,
                                        'typeId' => ETEGlobalUtils.doEncryptParams(offerItemType.Id, COUNTRY_CODE),
                                        'offerItems' => new List<Object>{
                                                new Map<String, Object>{
                                                        'driverName' => 'Karta Lotos 1',
                                                        'typeOfCard' => PRODUCT_NAME_LOTOS,
                                                        'typeOfVehicle' => 'PKW',
                                                        'monthlyFuelConsumption' => '300'
                                                }
                                        },
                                        'stations' => new List<Object>(),
                                        'stationsNetworks' => new List<Object>()
                                }
                        }
                }
        };

        Test.startTest();
        {
            ETEUtilsTest.prepareRequest(JSON.serialize(body), COUNTRY_CODE);
            ETERest.doPost();
            E2E_Data_Object__c dataObject = [SELECT Id FROM E2E_Data_Object__c];
            ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, stepName, dataObject.Id, 'Poland Lotos');
            ETEUtilsTest.checkStatusCodeAndNextStep(COUNTRY_CODE, stepName);
        }
        Test.stopTest();
    }

    @IsTest
    static void contactsStepDataSavingPositiveCaseTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'John Johnson';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'John';
        userModelContact.lastName = 'Johnson';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.contacts = userModelContacts;
        userModel.name = 'Wodnowo';
        userModel.selectedCompanyName = 'Wodnowo';
        userModel.companyShortName = 'Wodnowo';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland');
        List<String> jobsNeededToRun = new List<String>();
        for (E2E_Data_Log__c dataLog : [SELECT Name, Job_Status__c, Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
            if (dataLog.Job_Status__c == 'Queued') {
                jobsNeededToRun.add(dataLog.Name);
            }
        }
        ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobsNeededToRun, existingE2EDataObject.Id, COUNTRY_CODE, 'Poland');
        jobChainHandler.runNext();
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();
    }

    @IsTest
    static void contactsStepDataSavingNegativeCaseTest() {
        // CASE: INVALID INPUT DATA
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'John Johnson';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'John';
        userModelContact.lastName = 'Johnson';
        // set invalid phone number
        userModelContact.phone = '+48 777-777-XXX';
        userModelContact.email = 'test@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => new List<E2E_Data_Product__c>(),
                'offer_item' => new List<E2E_Data_Offer_Item__c>(),
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.contacts = userModelContacts;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
            ETERest.doPost();
        List<String> exceptionMessages = new List<String>();
        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            if (!String.isEmpty(dataLog.Exception_Description__c)) {
                exceptionMessages.add(dataLog.Exception_Description__c);
            }
        }
        System.assertEquals(1, exceptionMessages.size());
        System.assert(exceptionMessages.get(0).contains('input data is not valid'));
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 200);
        Test.stopTest();
    }


    @IsTest
    static void contactsStepDuplicateCase1Test() {
        // Case 1: Already a customer
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '8338085693' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'StageName' => 'Closed Won', 'CloseDate' => Date.today() });
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'Bruce Wayne';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'Bruce';
        userModelContact.lastName = 'Wayne';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test123@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.contacts = userModelContacts;
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.selectedCompanyName = 'BRAMKA SP. Z O.O.';
        userModel.companyShortName = 'BRAMKA SP Z OO';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland');
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();

        Boolean isValidCase1 = false;
        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            if (dataLog.Exception_Description__c == 'Already a customer') {
                isValidCase1 = true;
                break;
            }
        }
        System.assertEquals(true, isValidCase1, 'Invalid Already a customer case');
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = [SELECT OwnerId, E2E_Status__c FROM Opportunity WHERE Id = :oppty.Id];
        System.assertEquals(u.Id, opp.OwnerId, 'Invalid Already a customer opportunity owner');
        System.assertEquals('Finished', opp.E2E_Status__c, 'Invalid Finished E2E Status');
    }


    @IsTest
    static void contactsStepDuplicateCase2Test() {
        // Case 2: Already in process
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '8338085693' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'StageName' => 'Pending Sales – Information', 'CloseDate' => Date.today() });
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'Bruce Wayne';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'Bruce';
        userModelContact.lastName = 'Wayne';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test123@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.contacts = userModelContacts;
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.selectedCompanyName = 'BRAMKA SP. Z O.O.';
        userModel.companyShortName = 'BRAMKA SP Z OO';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland');
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();

        Boolean isValidCase = false;
        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            if (dataLog.Exception_Description__c == 'Already in process') {
                isValidCase = true;
                break;
            }
        }
        System.assertEquals(true, isValidCase, 'Invalid Already in process case');
        Opportunity opp = [SELECT OwnerId, E2E_Status__c, StageName, Gruende_verloren__c,Kredit_Entscheidung__c FROM Opportunity WHERE Id = :oppty.Id];
        System.assertEquals('Abgelehnt', opp.Kredit_Entscheidung__c, 'Invalid Credit decision');
        System.assertEquals('Duplicate', opp.Gruende_verloren__c, 'Invalid Sub-stage');
    }


    @IsTest
    static void contactsStepDuplicateCase3Test() {
        // Case 3: Switched old opportunity to E2E
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '8338085693' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'StageName' => 'Prospecting', 'CloseDate' => Date.today() });
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'Bruce Wayne';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'Bruce';
        userModelContact.lastName = 'Wayne';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test123@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.contacts = userModelContacts;
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.selectedCompanyName = 'BRAMKA SP. Z O.O.';
        userModel.companyShortName = 'BRAMKA SP Z OO';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland');
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();

        Opportunity opp = [SELECT OwnerId, E2E_Status__c, StageName, Gruende_verloren__c, Kredit_Entscheidung__c FROM Opportunity WHERE Id != :oppty.Id];
        System.assertEquals('Finished', opp.E2E_Status__c, 'Invalid Finished E2E Status');
        System.assertEquals('Switched to E2E', opp.Gruende_verloren__c, 'Invalid Sub-stage');
    }


    @IsTest
    static void contactsStepDuplicateCase4Test() {
        // Case 4: Credit notification
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '8338085693' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'StageName' => 'Closed Lost', 'CloseDate' => Date.today().addDays(-100), 'Gruende_verloren__c' => 'Refused Credit'});
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        Opportunity existingOppty = [SELECT CloseDate FROM Opportunity WHERE Name = 'BRAMKA SP. Z O.O.' LIMIT 1];
        existingOppty.CloseDate = Date.today().addDays(-100);
        update existingOppty;
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'Bruce Wayne';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'Bruce';
        userModelContact.lastName = 'Wayne';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test123@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.contacts = userModelContacts;
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.selectedCompanyName = 'BRAMKA SP. Z O.O.';
        userModel.companyShortName = 'BRAMKA SP Z OO';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland');
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();
    }


    @IsTest
    static void contactsStepDuplicateCase5Test() {
        // Case 5: Switched old rejected by credit to E2E
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '8338085693' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BRAMKA SP. Z O.O.', 'StageName' => 'CreditCheck abgelehnt', 'CloseDate' => Date.today()});
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        Opportunity existingOppty = [SELECT CloseDate FROM Opportunity WHERE Name = 'BRAMKA SP. Z O.O.' LIMIT 1];
        existingOppty.CloseDate = Date.today().addDays(-100);
        update existingOppty;
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'Bruce Wayne';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'Bruce';
        userModelContact.lastName = 'Wayne';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test123@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.contacts = userModelContacts;
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.selectedCompanyName = 'BRAMKA SP. Z O.O.';
        userModel.companyShortName = 'BRAMKA SP Z OO';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland');
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();

        Opportunity opp = [SELECT OwnerId, E2E_Status__c, StageName, Gruende_verloren__c, Kredit_Entscheidung__c FROM Opportunity WHERE Id != :oppty.Id];
        System.assertEquals('Closed Lost', opp.StageName, 'Invalid Stage');
        System.assertEquals('Switched to E2E', opp.Gruende_verloren__c, 'Invalid Sub-stage');
    }


    @IsTest
    static void searchCompanyTest() {
        Map<String, Object> searchCompanyRequestParams = new Map<String, Object>();
        searchCompanyRequestParams.put('method', 'doSearchCompany');
        searchCompanyRequestParams.put('country', COUNTRY_CODE);
        searchCompanyRequestParams.put('requestedCompany', 'Wodnowo');
        String searchCompanyRequestBody = JSON.serialize(searchCompanyRequestParams);
        ETEUtilsTest.prepareRequest(searchCompanyRequestBody, COUNTRY_CODE);
        Test.startTest();
        SingleRequestMock searchCompanyMock = new SingleRequestMock(200, 'Complete', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:SearchResponse xmlns:ns1="http://www.deltavista.com/dspone/webservices/search"><ns1:Candidates><ns1:Address><ns1:AddressId>1364828</ns1:AddressId><ns1:ParentId>1364828</ns1:ParentId><ns1:FirstName>Mariusz</ns1:FirstName><ns1:MaidenName/><ns1:Name>Wernyks</ns1:Name><ns1:LegalForm>1</ns1:LegalForm><ns1:Sex>1</ns1:Sex><ns1:Street>Kacza</ns1:Street><ns1:Unit>1</ns1:Unit><ns1:Zip>82-333</ns1:Zip><ns1:City>Wodnowo</ns1:City><ns1:Country>POL</ns1:Country><ns1:DateLastChange>2018-01-10+01:00</ns1:DateLastChange><ns1:ReferenceNumbers><ns1:ReferenceNumber><ns1:Name>DV_AID</ns1:Name><ns1:Value>1063000003842286</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_LID</ns1:Name><ns1:Value>3372000003842288</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_UID</ns1:Name><ns1:Value>2700000003842287</ns1:Value></ns1:ReferenceNumber></ns1:ReferenceNumbers></ns1:Address><ns1:CompareResult><ns1:HitType>1</ns1:HitType><ns1:Similarity>77.0</ns1:Similarity></ns1:CompareResult></ns1:Candidates><ns1:Candidates><ns1:Address><ns1:AddressId>1364830</ns1:AddressId><ns1:ParentId>1364830</ns1:ParentId><ns1:FirstName/><ns1:MaidenName/><ns1:Name>Kacze wyroby BIS Mariusz Wernyks</ns1:Name><ns1:LegalForm>2</ns1:LegalForm><ns1:Sex>0</ns1:Sex><ns1:Street>Kacza</ns1:Street><ns1:Unit>1</ns1:Unit><ns1:Zip>82-333</ns1:Zip><ns1:City>Wodnowo</ns1:City><ns1:Country>POL</ns1:Country><ns1:DateLastChange>2018-01-10+01:00</ns1:DateLastChange><ns1:CompanyRegistrationDate>2015-10-04+02:00</ns1:CompanyRegistrationDate><ns1:ReferenceNumbers><ns1:ReferenceNumber><ns1:Name>DV_AID</ns1:Name><ns1:Value>1208000003842292</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_LID</ns1:Name><ns1:Value>3372000003842288</ns1:Value></ns1:ReferenceNumber><ns1:ReferenceNumber><ns1:Name>DV_UID</ns1:Name><ns1:Value>2849000003842293</ns1:Value></ns1:ReferenceNumber></ns1:ReferenceNumbers><ns1:CompanyRegistrationInfo><ns1:directoryEntry><ns1:type>PL_NIP</ns1:type><ns1:ID>8338085693</ns1:ID></ns1:directoryEntry></ns1:CompanyRegistrationInfo><ns1:CompanyStatus>ACTIVE</ns1:CompanyStatus><ns1:IsRegistered>false</ns1:IsRegistered></ns1:Address><ns1:CompareResult><ns1:HitType>1</ns1:HitType><ns1:Similarity>100.0</ns1:Similarity></ns1:CompareResult></ns1:Candidates></ns1:SearchResponse></soapenv:Body></soapenv:Envelope>', null);
        Test.setMock(HttpCalloutMock.class, searchCompanyMock);
        ETERest.doPost();
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        System.assert(((List<Object>) responseBodyMap.get('companies')).size() > 0);
        Test.stopTest();
    }

    @IsTest
    static void additionalServicesGetServicesTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicepl');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_SHELL, COUNTRY);
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'getAdditionalServices');
        requestParams.put('countryCode', COUNTRY_CODE);
        requestParams.put('implKey', IMPL_KEY_SHELL);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        Test.stopTest();

        String result = RestContext.response.responseBody.toString();
        Map<String, Object> additionalServicesMap = (Map<String, Object>)JSON.deserializeUntyped(result);

        Boolean additionalServicesSettingsContains = additionalServicesMap.containsKey('additionalServicesSettings');
        System.assert(additionalServicesSettingsContains);

        List<Object> additionalServicesSettings = (List<Object>)additionalServicesMap.get('additionalServicesSettings');
        Boolean additionalServicesSettingsNotEmpty = !additionalServicesSettings.isEmpty();
        System.assert(additionalServicesSettingsNotEmpty);
    }


    @IsTest
    static void additionalServicesLotosGetServicesTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicepl');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_LOTOS, COUNTRY);
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'getAdditionalServices');
        requestParams.put('countryCode', COUNTRY_CODE);
        requestParams.put('implKey', IMPL_KEY_LOTOS);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        Test.stopTest();

        String result = RestContext.response.responseBody.toString();
        Map<String, Object> additionalServicesMap = (Map<String, Object>)JSON.deserializeUntyped(result);

        Boolean additionalServicesSettingsContains = additionalServicesMap.containsKey('additionalServicesSettings');
        System.assert(additionalServicesSettingsContains);

        List<Object> additionalServicesSettings = (List<Object>)additionalServicesMap.get('additionalServicesSettings');
        Boolean additionalServicesSettingsNotEmpty = !additionalServicesSettings.isEmpty();
        System.assert(additionalServicesSettingsNotEmpty);
    }

    @IsTest
    static void additionalServicesDoNextStepTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicepl');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_SHELL, COUNTRY);

        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'additional_services');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // return additional services fron frontend
        List<ETEUserModel.Additional_Service> additionalServicesFromFrontend = ETEUtilsTest.createAdditionalServicesFromFrontend(false);

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.additionalServices = additionalServicesFromFrontend;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        Test.stopTest();

        List<E2E_Data_Log__c> logs = [SELECT Exception_Description__c FROM E2E_Data_Log__c];

        for (E2E_Data_Log__c dataLog : logs) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }

        String result = RestContext.response.responseBody.toString();

        Map<String, Object> responseBodyMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        Integer statusCode = (Integer) responseBodyMap.get('statusCode');
        System.assert(statusCode == 100);

        Map<String, Object> userModelResponse = (Map<String, Object>) responseBodyMap.get('user_model');
        List<Object> services = (List<Object>) userModelResponse.get('additionalServices');
        Boolean additionalServicesNotEmpty = !services.isEmpty();
        System.assert(additionalServicesNotEmpty);
    }

    @IsTest
    static void creditLineGetDecisionsSuccessTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        offerItems.get(0).Monthly_Fuel_Consumption__c = 1100;

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Payment_History_Requested__c = false;
        report.Opportunity__c = oppty.Id;
        insert report;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doCalculateCreditDecisions');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('source', userModel.source);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
            SingleRequestMock krdReportMock = new SingleRequestMock(200, 'Complete', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><h:Authorization xmlns:h="http://krd.pl/Authorization/Response" xmlns="http://krd.pl/Authorization/Response" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Ticket>00AC0D1F03AE9AA7D552448CECC06F1953D29B000</Ticket><TicketExpirationDate>2020-08-05T11:45:23+02:00</TicketExpirationDate><ShouldChangePassword>false</ShouldChangePassword><PasswordExpirationDate>2017-06-08T00:00:00+02:00</PasswordExpirationDate></h:Authorization></s:Header><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><InformationDisclosureResponse xmlns="http://krd.pl/Chase3.1/Dto"><DisclosureReport><Number>U1/0000333361/2020</Number><Created>2020-08-04T11:45:24+02:00</Created><SearchCriterion><NonConsumerIdentityNumber><TaxId>7665256263</TaxId></NonConsumerIdentityNumber><AuthorizationDateSpecified>false</AuthorizationDateSpecified><ActAuthorizationDateSpecified>false</ActAuthorizationDateSpecified><SearchType>RegularSearch</SearchType><SearchCriterionType>TaxId</SearchCriterionType></SearchCriterion><Requester><LegalPerson><Name>KLIENT DEMO_CHASE3.1</Name><IdentityNumber><TaxId>5327161905</TaxId></IdentityNumber><SeatAddress><Line>Danuty Siedzikówny 12, Wrocław</Line><Line>51-214 Wrocław</Line><Line>PL</Line></SeatAddress></LegalPerson><LoginFullName>KLIENT DEMO_CHASE3.1</LoginFullName></Requester><Summary><InformationCount>0</InformationCount><OInformationCount>0</OInformationCount><DInformationCount>0</DInformationCount><DebtorsCount>0</DebtorsCount><CreditorsCount>0</CreditorsCount><TotalArrears><Amount>0</Amount><Currency>PLN</Currency></TotalArrears></Summary><PositiveInformationSummary><ProvidersCount>1</ProvidersCount><PaidObligationsCount>1</PaidObligationsCount><AveragePaidDebt>3900.00</AveragePaidDebt><AveragePaymentTimeInDays>7</AveragePaymentTimeInDays><SumPaidDebt>3900.0000</SumPaidDebt></PositiveInformationSummary><Report><PaidObligationInformations><PaidObligationInformation><Provider category="87"><LegalPerson><IdentityNumber><TaxId>5327161905</TaxId></IdentityNumber><Name>KLIENT DEMO_CHASE3.1</Name><SeatAddress><Line>Danuty Siedzikówny 12, Wrocław</Line><Line>51-214 Wrocław</Line><Line>PL</Line></SeatAddress><Branch>Other</Branch></LegalPerson></Provider><ShowProvider>true</ShowProvider><PaidObligationsForSubjects><PaidObligationsForSubject><Subject><LegalPerson><IdentityNumber><TaxId>7665256263</TaxId></IdentityNumber><Name>Mago Sp. z o.o.</Name><SeatAddress><Line>Bukowa 123</Line><Line>40-120 Katowice</Line><Line>PL</Line></SeatAddress></LegalPerson></Subject><PaidObligations><PaidObligation category="0"><Currency>PLN</Currency><TotalDebt>3900.0000</TotalDebt><PaidDebt>3900.0000</PaidDebt><DueDate>2019-10-01T00:00:00+02:00</DueDate><PaidDate>2019-10-08T00:00:00+02:00</PaidDate><Reason>Invoice</Reason><IsSumOfInstalments>false</IsSumOfInstalments><TotalDebtPLN>3900.0000</TotalDebtPLN><PaidDebtPLN>3900.0000</PaidDebtPLN></PaidObligation></PaidObligations></PaidObligationsForSubject></PaidObligationsForSubjects></PaidObligationInformation></PaidObligationInformations></Report></DisclosureReport></InformationDisclosureResponse></s:Body></s:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, krdReportMock);
            ETERest.doPost();
        Test.stopTest();

        List<E2E_Data_Log__c> logs = [SELECT Exception_Description__c FROM E2E_Data_Log__c];

        for (E2E_Data_Log__c dataLog : logs) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> reportResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCode = (Integer) reportResponse.get('statusCode');
        System.assert(statusCode == 100);

        List<Object> items = (List<Object>) reportResponse.get('cf_decisions');
        Boolean itemsNotEmpty = !items.isEmpty();
        System.assert(itemsNotEmpty);
    }

    @IsTest
    static void creditLineGetDecisionsTooRiskyTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Opportunity__c = oppty.Id;
        report.Class_Rating__c = '3';
        insert report;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doCalculateCreditDecisions');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('source', userModel.source);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        Test.stopTest();

        List<E2E_Data_Log__c> logs = [SELECT Exception_Description__c FROM E2E_Data_Log__c];
        List<E2E_Data_Log__c> exceptionsLogs = new  List<E2E_Data_Log__c>();

        for (E2E_Data_Log__c dataLog : logs) {
            if(dataLog.Exception_Description__c != null){
                exceptionsLogs.add(dataLog);
            }
        }

        Boolean exceptionsLogsNotEmpty = !exceptionsLogs.isEmpty();
        System.assert(exceptionsLogsNotEmpty);

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> reportResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCode = (Integer) reportResponse.get('statusCode');
        System.assert(statusCode == 104);
    }

    @IsTest
    static void creditLineGetDecisionsBlackListTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', 'Kacze wyroby BIS Mariusz Wernyks');
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Kacze wyroby BIS Mariusz Wernyks');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Opportunity__c = oppty.Id;
        report.Class_Rating__c = '3';
        insert report;

        Credit_Black_List_Company__c blackList = CreditFactoryTestUtils.generateBlackListCompanyPL();
        insert blackList;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doCalculateCreditDecisions');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('source', userModel.source);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        Test.stopTest();

        List<E2E_Data_Log__c> logs = [SELECT Exception_Description__c FROM E2E_Data_Log__c];
        List<E2E_Data_Log__c> exceptionsLogs = new  List<E2E_Data_Log__c>();

        for (E2E_Data_Log__c dataLog : logs) {
            if(dataLog.Exception_Description__c != null){
                exceptionsLogs.add(dataLog);
            }
        }

        Boolean exceptionsLogsNotEmpty = !exceptionsLogs.isEmpty();
        System.assert(exceptionsLogsNotEmpty);
        System.assertEquals('Black list', exceptionsLogs.get(0).Exception_Description__c);

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> reportResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCode = (Integer) reportResponse.get('statusCode');
        System.assert(statusCode == 100);
    }

    @IsTest
    static void creditLineDoNextStepTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Opportunity__c = oppty.Id;
        insert report;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);

        userModel.implKey = 'Poland';
        userModel.paymentTerms = '7';
        userModel.billingPeriod = '15';
        userModel.securityAmountToPay = 1400;
        userModel.maxCreditLimit = 1400;
        userModel.creditLimit = 1400;
        userModel.securityLevel = 100;
        userModel.paymentMethod = 'Direct Debit';
        userModel.paperInvoice = true;
        userModel.eInvoice = false;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'credit_line', existingE2EDataObject.Id, 'Poland');
        Test.stopTest();

        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> dataResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCode = (Integer) dataResponse.get('statusCode');
        System.assert(statusCode == 100);

        Map<String, Object> userModelResponse = (Map<String, Object>) dataResponse.get('user_model');
        String paymentMethod = (String)userModelResponse.get('paymentMethod');
        Integer securityAmountToPay = (Integer)userModelResponse.get('securityAmountToPay');
        System.assertEquals('Direct Debit', paymentMethod);
        System.assertEquals(1400, securityAmountToPay);
    }


    @IsTest
    static void documentsStepTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'documents');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Company_Form__c', 'Private limited company');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('Payment_Method__c', 'Direct Debit');
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        additionalSObjectsForTest.add(oppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(oppty.Id, contacts[0].Id);
        insert ocr;
        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => new List<E2E_Data_Product__c>(),
                'offer_item' => new List<E2E_Data_Offer_Item__c>(),
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.termsAndConditionsAgreement = true;
        userModel.authorizedSignatoryConfirmed = true;
        userModel.birthdate = '18.05.2000';

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'documents', existingE2EDataObject.Id, 'Poland');
        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }
        String transitionResponseBody = RestContext.response.responseBody.toString();
        Map<String, Object> transitionResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(transitionResponseBody);
        System.assertEquals(103, transitionResponseBodyMap.get('statusCode'));
        System.assertEquals(null, transitionResponseBodyMap.get('redirect_to'));
        requestParams.put('method', 'getLinkToRedirect');
        requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        ETERest.doPost();
        String getLinkToRedirectResponseBody = RestContext.response.responseBody.toString();
        Map<String, Object> getLinkToRedirectResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(getLinkToRedirectResponseBody);
        System.assertEquals(103, getLinkToRedirectResponseBodyMap.get('statusCode'));
        System.assertEquals('https://docusigntest.com', getLinkToRedirectResponseBodyMap.get('redirect_to'));
        Test.stopTest();
    }


    @IsTest
    static void reSigningDocumentsTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'documents');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Company_Form__c', 'Private limited company');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('Payment_Method__c', 'Direct Debit');
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        additionalSObjectsForTest.add(oppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(oppty.Id, contacts[0].Id);
        insert ocr;
        // create signing Docusign documents data log
        String recordTypeReportRequestId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Request Status').getRecordTypeId();
        E2E_Data_Log__c signDocusignDocumentsLog = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = recordTypeReportRequestId,
                Name = 'signDocusignDocuments',
                Status__c = 'Success'
        );
        insert signDocusignDocumentsLog;
        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => new List<E2E_Data_Product__c>(),
                'offer_item' => new List<E2E_Data_Offer_Item__c>(),
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        userModel.termsAndConditionsAgreement = true;
        userModel.authorizedSignatoryConfirmed = true;
        userModel.birthdate = '18.05.2000';

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
            ETERest.doPost();
            ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'documents', existingE2EDataObject.Id, 'Poland');
            for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
                System.assertEquals(null, dataLog.Exception_Description__c);
            }
            String transitionResponseBody = RestContext.response.responseBody.toString();
            Map<String, Object> transitionResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(transitionResponseBody);
            System.assertEquals(100, transitionResponseBodyMap.get('statusCode'));
        Test.stopTest();
    }


    @IsTest
    static void paymentOptionsStepTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'checkout');
        dataObjectParams.put('Selected_Company_Name__c', 'test company');
        dataObjectParams.put('Security_Amount_To_Pay__c', 1200);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => new List<E2E_Data_Product__c>(),
                'offer_item' => new List<E2E_Data_Offer_Item__c>(),
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland';
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'documents', existingE2EDataObject.Id, 'Poland');
        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }
        String transitionResponseBody = RestContext.response.responseBody.toString();
        Map<String, Object> transitionResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(transitionResponseBody);
        System.assertEquals(103, transitionResponseBodyMap.get('statusCode'));
        System.assertEquals(null, transitionResponseBodyMap.get('redirect_to'));
        requestParams.put('method', 'getLinkToRedirect');
        requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        ETERest.doPost();
        String getLinkToRedirectResponseBody = RestContext.response.responseBody.toString();
        Map<String, Object> getLinkToRedirectResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(getLinkToRedirectResponseBody);
        System.assertEquals(103, getLinkToRedirectResponseBodyMap.get('statusCode'));
        System.assertEquals('https://payutest.com?orderId=1234567&', getLinkToRedirectResponseBodyMap.get('redirect_to'));
        Test.stopTest();
    }


    @IsTest
    static void returnFromDocusignToFormTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'documents');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Security_Amount_To_Pay__c', 0);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        additionalSObjectsForTest.add(existingOppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contacts[0].Id);
        insert ocr;

        List<RecordType> dataLogRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Log__c' AND DeveloperName = 'Job_Status' LIMIT 1];
        List<E2E_Data_Log__c> completedJobsToInsertList = new List<E2E_Data_Log__c>();
        E2E_Data_Log__c checkBusinessObjectsJob = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = dataLogRecordTypeList.get(0).Id,
                Name = 'checkBusinessObjects',
                Job_Status__c = 'Completed'
        );
        completedJobsToInsertList.add(checkBusinessObjectsJob);

        E2E_Data_Log__c syncContactDataJob = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = dataLogRecordTypeList.get(0).Id,
                Name = 'syncContactData',
                Job_Status__c = 'Completed'
        );
        completedJobsToInsertList.add(syncContactDataJob);
        insert completedJobsToInsertList;

        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('source', encodedStr);
        ApexPages.currentPage().getParameters().put('srvc', 'docusign');
        ApexPages.currentPage().getParameters().put('countryCode', COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('event', 'OnSigningComplete');
        Test.startTest();
        ETERedirectionController redirectionCtrl = new ETERedirectionController();
        redirectionCtrl.checkStatus();
        Test.stopTest();
        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Closed Won', dataObject.StageName__c);
        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Closed Won', oppty.StageName);
    }


    @IsTest
    static void returnFromPayUToFormTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'documents');
        dataObjectParams.put('Selected_Company_Name__c', 'test company');
        dataObjectParams.put('Security_Amount_To_Pay__c', 1200);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        insert existingOppty;
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        Payment_Transaction__c paymentTransaction = ETEUtilsTest.createPaymentTransaction(existingE2EDataObject.Security_Amount_To_Pay__c, existingOppty.Id);
        additionalSObjectsForTest.add(paymentTransaction);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contacts[0].Id);
        insert ocr;

        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('source', encodedStr);
        ApexPages.currentPage().getParameters().put('srvc', 'payu');
        ApexPages.currentPage().getParameters().put('countryCode', COUNTRY_CODE);
        Test.startTest();
        paymentTransaction.Status__c = 'COMPLETED';
        update paymentTransaction;
        ETERedirectionController redirectionCtrl = new ETERedirectionController();
        redirectionCtrl.checkStatus();
        Test.stopTest();
        E2E_Data_Object__c dataObject = [SELECT Payment_Status__c, E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('COMPLETED', dataObject.Payment_Status__c);
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Closed Won', dataObject.StageName__c);
        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Closed Won', oppty.StageName);
    }


    @IsTest
    static void payLaterTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'checkout');
        dataObjectParams.put('Selected_Company_Name__c', 'test company');
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        additionalSObjectsForTest.add(existingOppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contacts[0].Id);
        insert ocr;
        String source = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'payLater');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('source', source);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        Test.stopTest();
        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Pending Sales – Deposit', dataObject.StageName__c);
        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Pending Sales – Deposit', oppty.StageName);
    }


    @IsTest
    static void createExceptionLogTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        String source = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'createExceptionLog');
        requestParams.put('countryCode', COUNTRY_CODE);
        requestParams.put('source', source);
        requestParams.put('currentStep', ETEUtilsTest.STEPS.contacts.name());
        requestParams.put('statusCode', 150);
        requestParams.put('exceptionType', 'System Error');
        requestParams.put('exceptionMessage', 'Test Frontend Error');
        requestParams.put('exceptionSource', 'Frontend');
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        List<String> exceptionMessages = new List<String>();
        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            if (!String.isEmpty(dataLog.Exception_Description__c)) {
                exceptionMessages.add(dataLog.Exception_Description__c);
            }
        }
        System.assertEquals(1, exceptionMessages.size());
        System.assertEquals('Test Frontend Error', exceptionMessages.get(0));
        Test.stopTest();
    }

    @IsTest
    static void getDocumentHtmlViewTest() {
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'htmlView');
        requestParams.put('countryCode', COUNTRY_CODE);
        requestParams.put('language', COUNTRY_CODE);
        requestParams.put('implKey', IMPL_KEY_SHELL);
        requestParams.put('type', 'agreeToTelephoneContact');
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        Integer statusCode = RestContext.response.statusCode;
        String htmlResponseBody = RestContext.response.responseBody.toString();
        System.assertEquals(200, statusCode);
        System.assertEquals('<h1>Hello World</h1>', htmlResponseBody);
        Test.stopTest();
    }


    @IsTest
    static void getUserModelTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Poland');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'getUserModel');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('implKey', 'Poland');
        requestParams.put('source', ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE));
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
            ETERest.doPost();
            String responseBody = RestContext.response.responseBody.toString();
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(String.valueOf(responseBodyMap.get('statusCode')) == '100');
        Test.stopTest();
    }

    // Lotos process
    @IsTest
    static void lotos_contactsStepDataSavingPositiveCaseTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(oppty);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_LOTOS LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_LOTOS LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'John Johnson';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'John';
        userModelContact.lastName = 'Johnson';
        userModelContact.phone = '+48 777-777-777';
        userModelContact.email = 'test@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland Lotos';
        userModel.contacts = userModelContacts;
        userModel.name = 'BRAMKA SP. Z O.O.';
        userModel.selectedCompanyName = 'Wodnowo';
        userModel.companyShortName = 'Wodnowo';
        userModel.selectedCompanyId = '8338085693';
        userModel.agreementToPhoneContact = true;
        userModel.agreementToReceiveInfoByEmail = true;
        userModel.agreementPrivacyPolicy = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, 'Poland Lotos');
        List<String> jobsNeededToRun = new List<String>();
        for (E2E_Data_Log__c dataLog : [SELECT Name, Job_Status__c, Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
            if (dataLog.Job_Status__c == 'Queued') {
                jobsNeededToRun.add(dataLog.Name);
            }
        }
        ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobsNeededToRun, existingE2EDataObject.Id, COUNTRY_CODE, 'Poland');
        jobChainHandler.runNext();
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        Test.stopTest();
    }


    @IsTest
    static void lotos_additionalServicesDoNextStepTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicepl');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_LOTOS, COUNTRY);

        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'additional_services');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create account
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);
        // return contacts
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(contacts);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_LOTOS LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_LOTOS LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // return additional services from frontend
        List<ETEUserModel.Additional_Service> additionalServicesFromFrontend = ETEUtilsTest.createAdditionalServicesFromFrontend(false);
        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland Lotos';
        userModel.additionalServices = additionalServicesFromFrontend;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
            ETERest.doPost();
        Test.stopTest();

        String result = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        Integer statusCode = (Integer) responseBodyMap.get('statusCode');
        System.assert(statusCode == 100);
        Map<String, Object> userModelResponse = (Map<String, Object>) responseBodyMap.get('user_model');
        List<Object> services = (List<Object>) userModelResponse.get('additionalServices');
        Boolean additionalServicesNotEmpty = !services.isEmpty();
        System.assert(additionalServicesNotEmpty);
    }


    @IsTest
    static void lotos_additionalServicesDoNextStepStopProcessCaseTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicepl');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_LOTOS, COUNTRY);

        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'additional_services');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create account
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);
        // return contacts
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(contacts);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_LOTOS LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_LOTOS LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // return additional services from frontend
        List<ETEUserModel.Additional_Service> additionalServicesFromFrontend = ETEUtilsTest.createAdditionalServicesFromFrontend(false);
        // create stop process case
        List<RecordType> dataLogRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Log__c' AND DeveloperName = 'Job_Status' LIMIT 1];
        E2E_Data_Log__c alreadyACustomerDataLogException = new E2E_Data_Log__c(
            E2E_Data_Object__c = existingE2EDataObject.Id,
            RecordTypeId = dataLogRecordTypeList.get(0).Id,
            Name = 'deduplication',
            Exception_Description__c = 'Already a customer'
        );
        insert alreadyACustomerDataLogException;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = 'Poland Lotos';
        userModel.additionalServices = additionalServicesFromFrontend;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
            ETERest.doPost();
        Test.stopTest();

        String result = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        Integer statusCode = (Integer) responseBodyMap.get('statusCode');
        System.assert(statusCode == 100);
        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, E2E_Finish_Details__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Order Submitted', dataObject.E2E_Finish_Details__c);
        Map<String, Object> userModelResponse = (Map<String, Object>) responseBodyMap.get('user_model');
        List<Object> services = (List<Object>) userModelResponse.get('additionalServices');
        Boolean additionalServicesNotEmpty = !services.isEmpty();
        System.assert(additionalServicesNotEmpty);
    }


    @IsTest
    static void lotos_creditLineDepositCaseDoNextStepTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_LOTOS LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_LOTOS LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Opportunity__c = oppty.Id;
        insert report;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);

        userModel.implKey = 'Poland Lotos';
        userModel.paymentTerms = '7';
        userModel.billingPeriod = '15';
        userModel.securityAmountToPay = 1400;
        userModel.maxCreditLimit = 1400;
        userModel.creditLimit = 1400;
        userModel.securityLevel = 100;
        userModel.paymentMethod = 'Direct Debit';
        userModel.paperInvoice = true;
        userModel.eInvoice = false;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'credit_line', existingE2EDataObject.Id, 'Poland');
        Test.stopTest();

        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> dataResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCode = (Integer) dataResponse.get('statusCode');
        System.assert(statusCode == 100);

        Map<String, Object> userModelResponse = (Map<String, Object>) dataResponse.get('user_model');
        String paymentMethod = (String)userModelResponse.get('paymentMethod');
        Integer securityAmountToPay = (Integer)userModelResponse.get('securityAmountToPay');
        System.assertEquals('Direct Debit', paymentMethod);
        System.assertEquals(1400, securityAmountToPay);
    }


    @IsTest
    static void lotos_creditLineNoDepositCaseDoNextStepTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agreement_Privacy_Policy__c', true);
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);

        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_LOTOS LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_LOTOS LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = 'Poland', Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Opportunity__c = oppty.Id;
        insert report;

        // generate user model
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => existingE2EDataObject,
                'ete_contact' => existingE2EDataContacts,
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);

        userModel.implKey = 'Poland Lotos';
        userModel.paymentTerms = '7';
        userModel.billingPeriod = '15';
        userModel.securityAmountToPay = 0;
        userModel.maxCreditLimit = 1400;
        userModel.creditLimit = 1400;
        userModel.securityLevel = 100;
        userModel.paymentMethod = 'Direct Debit';
        userModel.paperInvoice = true;
        userModel.eInvoice = false;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'credit_line', existingE2EDataObject.Id, 'Poland');
        Test.stopTest();

        for (E2E_Data_Log__c dataLog : [SELECT Exception_Description__c FROM E2E_Data_Log__c]) {
            System.assertEquals(null, dataLog.Exception_Description__c);
        }

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> dataResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCode = (Integer) dataResponse.get('statusCode');
        System.assert(statusCode == 100);

        Map<String, Object> userModelResponse = (Map<String, Object>) dataResponse.get('user_model');
        String paymentMethod = (String)userModelResponse.get('paymentMethod');
        Integer securityAmountToPay = (Integer)userModelResponse.get('securityAmountToPay');
        System.assertEquals('Direct Debit', paymentMethod);
        System.assertEquals(0, securityAmountToPay);
    }


    @IsTest
    static void lotos_returnFromDocusignToFormTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'documents');
        dataObjectParams.put('Selected_Company_Name__c', 'Wodnowo');
        dataObjectParams.put('Selected_Company_Id__c', '8338085693');
        dataObjectParams.put('Security_Amount_To_Pay__c', 0);
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        additionalSObjectsForTest.add(existingOppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contacts[0].Id);
        insert ocr;

        List<RecordType> dataLogRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Log__c' AND DeveloperName = 'Job_Status' LIMIT 1];
        List<E2E_Data_Log__c> completedJobsToInsertList = new List<E2E_Data_Log__c>();
        E2E_Data_Log__c checkBusinessObjectsJob = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = dataLogRecordTypeList.get(0).Id,
                Name = 'checkBusinessObjects',
                Job_Status__c = 'Completed'
        );
        completedJobsToInsertList.add(checkBusinessObjectsJob);

        E2E_Data_Log__c syncContactDataJob = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = dataLogRecordTypeList.get(0).Id,
                Name = 'syncContactData',
                Job_Status__c = 'Completed'
        );
        completedJobsToInsertList.add(syncContactDataJob);
        insert completedJobsToInsertList;

        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('source', encodedStr);
        ApexPages.currentPage().getParameters().put('srvc', 'docusign');
        ApexPages.currentPage().getParameters().put('countryCode', COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('event', 'OnSigningComplete');
        Test.startTest();
        ETERedirectionController redirectionCtrl = new ETERedirectionController();
        redirectionCtrl.checkStatus();
        Test.stopTest();
        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Closed Won', dataObject.StageName__c);
        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Closed Won', oppty.StageName);
    }


    @IsTest
    static void lotos_payLaterTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'checkout');
        dataObjectParams.put('Selected_Company_Name__c', 'test company');
        dataObjectParams.put('StageName__c', 'Qualify');
        dataObjectParams.put('RecordTypeName', 'Poland_Lotos');
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'John Johnson');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'John');
        dataContactParams.put('Last_Name__c', 'Johnson');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+48 777-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
        additionalSObjectsForTest.add(existingOppty);
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, account);
        additionalSObjectsForTest.addAll(contacts);
        insert additionalSObjectsForTest;
        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contacts[0].Id);
        insert ocr;
        String source = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'payLater');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('source', source);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        Test.stopTest();
        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Negotiate', dataObject.StageName__c);
        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Negotiate', oppty.StageName);
    }


    public static void createMultiproductData (String countryCode) {
        String currencyCode = ETEGlobalUtils.returnCurrencyCode(countryCode);
        String country = ETEGlobalUtils.returnCountry(countryCode);


        List<Product2> listProducts = new List<Product2>();
        Product2 prod = new Product2(
                Name = PRODUCT_NAME_SHELL,
                Family = 'SHELL',
                Available_for_E2E__c = true,
                IsActive = true,
                Country__c = country,
                CurrencyIsoCode = currencyCode,
                Integration_Name__c = 'shellbasic2020' + countryCode
        );
        Product2 prodLotos = new Product2(
                Name = PRODUCT_NAME_LOTOS,
                Family = 'LOTOS',
                Available_for_E2E__c = true,
                IsActive = true,
                Country__c = country,
                CurrencyIsoCode = currencyCode,
                Integration_Name__c = 'lotosbiznes'
        );
        listProducts.add(prod);
        listProducts.add(prodLotos);
        insert listProducts;


        insert new List<PricebookEntry>{
                new PricebookEntry(
                        Product2Id = prod.Id,
                        IsActive = true,
                        CurrencyIsoCode = currencyCode,
                        UnitPrice = 0,
                        Pricebook2Id = Test.getStandardPricebookId()
                ),
                new PricebookEntry(
                        Product2Id = prodLotos.Id,
                        IsActive = true,
                        CurrencyIsoCode = currencyCode,
                        UnitPrice = 0,
                        Pricebook2Id = Test.getStandardPricebookId()
                )
        };


        Fee__c fee = new Fee__c(
                Fee_Type__c = 'Monthly Card Fee',
                Country__c = COUNTRY.split('-').get(0)
        );
        insert fee;

        insert new List<Offer_Fee__c>{
                new Offer_Fee__c(
                        FLEETCOR_Offer__c = prod.Id,
                        Fee__c = fee.Id,
                        Value__c = '5',
                        Value_Type__c = 'Amount',
                        Display_For_E2E__c = true
                ),
                new Offer_Fee__c(
                        FLEETCOR_Offer__c = prodLotos.Id,
                        Fee__c = fee.Id,
                        Value__c = '5',
                        Value_Type__c = 'Amount',
                        Display_For_E2E__c = true
                )
        };


        List<Offer_Item_Type__c> listOfferItemTypes = new List<Offer_Item_Type__c>();
        Offer_Item_Type__c offerItemType = new Offer_Item_Type__c(
                Name = OFFER_ITEM_TYPE_SHELL,
                Integration_Name__c = 'shellfuelcard'
        );
        Offer_Item_Type__c offerItemTypeLotos = new Offer_Item_Type__c(
                Name = OFFER_ITEM_TYPE_LOTOS,
                Integration_Name__c = 'lotosfuelcard'
        );
        listOfferItemTypes.add(offerItemType);
        listOfferItemTypes.add(offerItemTypeLotos);
        insert  listOfferItemTypes;


        insert new List<Offer_to_Item_Type_Junction__c>{
                new Offer_to_Item_Type_Junction__c(
                        Product__c = prod.Id,
                        Offer_Item_Type__c = offerItemType.Id
                ),
                new Offer_to_Item_Type_Junction__c(
                        Product__c = prodLotos.Id,
                        Offer_Item_Type__c = offerItemTypeLotos.Id
                )
        };


        ETEUtilsTest.createStaticResource('ETE_MP_OFFERS');
        ETEUtilsTest.createStaticResource('ETE_MP_fee_types');
        ETEUtilsTest.createStaticResource('ETE_MP_OIT_shellfuelcard');
        ETEUtilsTest.createStaticResource('ETE_MP_OIT_lotosfuelcard');
    }
}
