@IsTest
private class ETELUTest {
    static final String COUNTRY_CODE = 'lu';
    static final String LANGUAGE = 'fr';
    static final String COUNTRY = 'Luxembourg';
    static final String NEW_CUSTOMER = 'NEW E2E CUSTOMER';
    static final String IMPL_KEY_SHELL = 'Luxembourg';
    static final String OFFER_ITEM_TYPE_SHELL = 'Shell Fuel Card';
    static final String PRODUCT_NAME_SHELL = 'Home Station LU';
    static final String RECORD_TYPE_NAME = 'Luxembourg';


    @TestSetup
    static void createLongFormData() {
        ETEUtilsTest.createCustomSettings(COUNTRY, IMPL_KEY_SHELL);
        ETEUtilsTest.createStaticResourceForSteps();
        ETEUtilsTest.createStaticResource('ETE_common_components_translations');
        ETEUtilsTest.createStaticResource('ETE_default_settings_lu');
        ETEUtilsTest.createE2EApiKeys('E2EForm');
        createMultiproductData(COUNTRY_CODE);
    }


    @IsTest
    static void formFirstLoadingTest() {
        Test.startTest();
        ApexPages.currentPage().getparameters().put('utm_products', ETEGlobalUtils.doEncryptParams('product1;product2', COUNTRY_CODE));
        ETEController e2eFormCtrl = new ETEController();
        e2eFormCtrl.runLongFormLU();
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
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('source', encodedStr);
        ETEController e2eFormCtrl = new ETEController();
        e2eFormCtrl.runLongFormLU();
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
        Test.startTest();
        {
            String stepName = ETEUtilsTest.STEPS.products_and_services.name();
            Product2 product = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL];
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
                                            'productId' => ETEGlobalUtils.doEncryptParams(product.Id, COUNTRY_CODE),
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

            ETEUtilsTest.prepareRequest(JSON.serialize(body), COUNTRY_CODE);
            ETERest.doPost();
            E2E_Data_Object__c dataObject = [SELECT Id FROM E2E_Data_Object__c];
            ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, stepName, dataObject.Id, IMPL_KEY_SHELL);
            ETEUtilsTest.checkStatusCodeAndNextStep(COUNTRY_CODE, stepName);
        }
        Test.stopTest();
    }


    @IsTest
    static void contactsStepDataSavingPositiveCaseTest() {
        String stepName = ETEUtilsTest.STEPS.contacts.name();
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c dataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        // create opportunity
        Opportunity opp = ETEUtilsTest.createOpportunity(dataObject, null);
        insert opp;

        // create offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(dataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(dataObject, productsList);
        insert offerItems;

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        userModelContact.phone = '+352 282 61208';
        userModelContact.email = 'test@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => dataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => productsList,
                'offer_item' => offerItems,
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = COUNTRY;
        userModel.name = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyName = 'LU Kundentestsystem Gro';
        userModel.companyShortName = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyId = '09379370071090';
        userModel.agreementToPhoneContact = true;
        userModel.agreeToProcessPersDataForMarketing = true;
        userModel.termsAndConditionsAgreement = true;

        Map<String, Object> body = new Map<String, Object>{
                'method' => 'doNextStep',
                'country' => COUNTRY_CODE,
                'user_model' => userModel
        };

        Test.startTest();
        {
            ETEUtilsTest.prepareRequest(JSON.serialize(body), COUNTRY_CODE);
            ETERest.doPost();

            ETEUtilsTest.enqueueJobsForStep(
                    COUNTRY_CODE,
                    ETEUtilsTest.STEPS.contacts.name(),
                    dataObject.Id,
                    IMPL_KEY_SHELL
            );

            List<String> jobsNeededToRun = new List<String>();
            for (E2E_Data_Log__c dataLog : [SELECT Name, Job_Status__c, Exception_Description__c FROM E2E_Data_Log__c]) {
                System.assertEquals(null, dataLog.Exception_Description__c);
                if (dataLog.Job_Status__c == 'Queued') {
                    jobsNeededToRun.add(dataLog.Name);
                }
            }

            ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobsNeededToRun, dataObject.Id, COUNTRY_CODE, COUNTRY);
            jobChainHandler.runNext();

            String responseBody = RestContext.response.responseBody.toString();
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(responseBodyMap.get('statusCode') == 100);
        }
        Test.stopTest();
    }

    @IsTest
    static void contactsStepDataSavingNegativeCaseTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem Gro');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        E2E_Data_Object__c dataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        // set invalid phone number
        userModelContact.phone = '+352 282 61XXX';
        userModelContact.email = 'test@test.com';
        userModelContact.role = 'Decision Maker';
        userModelContact.isPrimary = true;
        List<ETEUserModel.ETE_Contact> userModelContacts = new List<ETEUserModel.ETE_Contact>();
        userModelContacts.add(userModelContact);
        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
                'data_object' => dataObject,
                'ete_contact' => new List<E2E_Data_Contact__c>(),
                'product' => new List<E2E_Data_Product__c>(),
                'offer_item' => new List<E2E_Data_Offer_Item__c>(),
                'additional_service' => new List<E2E_Data_Additional_Service__c>()
        };
        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.contacts = userModelContacts;
        userModel.name = 'LU Kundentestsystem Gro';

        Map<String, Object> body = new Map<String, Object>{
                'method' => 'doNextStep',
                'country' => COUNTRY_CODE,
                'user_model' => userModel
        };

        Test.startTest();
        {
            ETEUtilsTest.prepareRequest(JSON.serialize(body), COUNTRY_CODE);
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
        }
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
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => 'AT1234567' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'RUBINOCCI', 'LastName' => 'RENÉ', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'TEST OPTIMUM', 'StageName' => 'Closed Won', 'CloseDate' => Date.today() });
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
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        userModelContact.phone = '+352 282 61208';
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
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.contacts = userModelContacts;
        userModel.name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN';
        userModel.selectedCompanyName = 'LU Kundentestsystem Gro';
        userModel.companyShortName = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyId = '09379370071090';
        userModel.agreementToPhoneContact = true;
        userModel.agreeToProcessPersDataForMarketing = true;
        userModel.termsAndConditionsAgreement = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, IMPL_KEY_SHELL);
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
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => 'AT1234567' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'RUBINOCCI', 'LastName' => 'RENÉ', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'StageName' => 'Pending Sales – Information', 'CloseDate' => Date.today() });
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
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        userModelContact.phone = '+352 282 61208';
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
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.contacts = userModelContacts;
        userModel.name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN';
        userModel.selectedCompanyName = 'LU Kundentestsystem Gro';
        userModel.companyShortName = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyId = '09379370071090';
        userModel.agreementToPhoneContact = true;
        userModel.agreeToProcessPersDataForMarketing = true;
        userModel.termsAndConditionsAgreement = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, IMPL_KEY_SHELL);
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
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => 'AT1234567' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'RUBINOCCI', 'LastName' => 'RENÉ', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'StageName' => 'Prospecting', 'CloseDate' => Date.today() });
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
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        userModelContact.phone = '+352 282 61208';
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
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.contacts = userModelContacts;
        userModel.name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN';
        userModel.selectedCompanyName = 'LU Kundentestsystem Gro';
        userModel.companyShortName = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyId = '09379370071090';
        userModel.agreementToPhoneContact = true;
        userModel.agreeToProcessPersDataForMarketing = true;
        userModel.termsAndConditionsAgreement = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, IMPL_KEY_SHELL);
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
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => 'AT1234567' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'RUBINOCCI', 'LastName' => 'RENÉ', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'StageName' => 'Closed Lost', 'CloseDate' => Date.today().addDays(-100), 'Gruende_verloren__c' => 'Refused Credit'});
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        Opportunity existingOppty = [SELECT CloseDate FROM Opportunity WHERE Name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN' LIMIT 1];
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
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        userModelContact.phone = '+352 282 61208';
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
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.contacts = userModelContacts;
        userModel.name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN';
        userModel.selectedCompanyName = 'LU Kundentestsystem Gro';
        userModel.companyShortName = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyId = '09379370071090';
        userModel.agreementToPhoneContact = true;
        userModel.agreeToProcessPersDataForMarketing = true;
        userModel.termsAndConditionsAgreement = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, IMPL_KEY_SHELL);
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
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => 'AT1234567' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'RUBINOCCI', 'LastName' => 'RENÉ', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN', 'StageName' => 'CreditCheck abgelehnt', 'CloseDate' => Date.today()});
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        Opportunity existingOppty = [SELECT CloseDate FROM Opportunity WHERE Name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN' LIMIT 1];
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
        userModelContact.name = 'RUBINOCCI RENÉ';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'RUBINOCCI';
        userModelContact.lastName = 'RENÉ';
        userModelContact.phone = '+352 282 61208';
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
        userModel.implKey = COUNTRY;
        userModel.contacts = userModelContacts;
        userModel.name = 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN';
        userModel.selectedCompanyName = 'LU Kundentestsystem Gro';
        userModel.companyShortName = 'LU Kundentestsystem Gro';
        userModel.selectedCompanyId = '09379370071090';
        userModel.agreementToPhoneContact = true;
        userModel.agreeToProcessPersDataForMarketing = true;
        userModel.termsAndConditionsAgreement = true;

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, ETEUtilsTest.STEPS.contacts.name(), existingE2EDataObject.Id, IMPL_KEY_SHELL);
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
        searchCompanyRequestParams.put('requestedCompany', 'LU Kundentestsystem AG - BITTE NICHT ÄNDERN');
        String searchCompanyRequestBody = JSON.serialize(searchCompanyRequestParams);
        ETEUtilsTest.prepareRequest(searchCompanyRequestBody, COUNTRY_CODE);
        Test.startTest();
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"> <env:Header/> <env:Body> <ns2:searchResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"> <ns2:header> <ns2:communicationlanguage>en</ns2:communicationlanguage> <ns2:transmissiontimestamp>2020-12-22T12:26:55.988+01:00</ns2:transmissiontimestamp> <ns2:keylistversion>20</ns2:keylistversion> <ns2:clientapplicationname>FleetCor Credit Factory</ns2:clientapplicationname> <ns2:clientapplicationversion>3</ns2:clientapplicationversion> <ns2:useraccount>345013323001</ns2:useraccount> <ns2:responseid>6d0cd8c4-870c-4d4d-8e1f-af276ccd78cc</ns2:responseid> </ns2:header> <ns2:body> <ns2:hit> <ns2:identificationnumber>09379370071104</ns2:identificationnumber> <ns2:companyname>LU- Kundentestsystem SA NEGATIV - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:street>Rue Henri IV</ns2:street> <ns2:housenumber>345</ns2:housenumber> <ns2:postcode>2543</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>false</ns2:additionalinformation> </ns2:hit> <ns2:hit> <ns2:identificationnumber>09379370071100</ns2:identificationnumber> <ns2:companyname>LU- Kundentestsystem SARL NEGATIV - BITTE NICHT ÄNDERN</ns2:companyname> <ns2:street>Rue de Pays</ns2:street> <ns2:housenumber>98</ns2:housenumber> <ns2:postcode>1234</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-LU-10</ns2:key> <ns2:designation>Société à responsabilité limitée</ns2:designation> <ns2:shortdesignation>Sarl</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>false</ns2:additionalinformation> </ns2:hit> <ns2:hit> <ns2:identificationnumber>09379370071091</ns2:identificationnumber> <ns2:companyname>LU Kundentestsystem AG - BITTE NICHT ÄNDERN, leer</ns2:companyname> <ns2:street>Allée Francois</ns2:street> <ns2:housenumber>197</ns2:housenumber> <ns2:postcode>2520</ns2:postcode> <ns2:city>Luxembourg</ns2:city> <ns2:country> <ns2:key>LU</ns2:key> <ns2:designation>Luxembourg</ns2:designation> </ns2:country> <ns2:legalform> <ns2:key>LEFO-LU-11</ns2:key> <ns2:designation>Société Anonyme</ns2:designation> <ns2:shortdesignation>SA</ns2:shortdesignation> </ns2:legalform> <ns2:reportavailable>true</ns2:reportavailable> <ns2:reportcompanyname>true</ns2:reportcompanyname> <ns2:reportaddress>true</ns2:reportaddress> <ns2:operationalstatus> <ns2:key>ONST-1</ns2:key> <ns2:designation>active</ns2:designation> </ns2:operationalstatus> <ns2:additionalinformation>false</ns2:additionalinformation> </ns2:hit> <ns2:morehits>false</ns2:morehits> </ns2:body> </ns2:searchResponse> </env:Body> </env:Envelope>', null);
            Test.setMock(HttpCalloutMock.class, searchMock);
            ETERest.doPost();
            String responseBody = RestContext.response.responseBody.toString();
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(responseBodyMap.get('statusCode') == 100);
            System.assert(((List<Object>) responseBodyMap.get('companies')).size() > 0);
        Test.stopTest();
    }


    @IsTest
    static void additionalServicesGetServicesTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoiceLU');
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
    static void additionalServicesDoNextStepTest() {
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoiceLU');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_SHELL, COUNTRY);

        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'additional_services');
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'RUBINOCCI RENÉ');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'RUBINOCCI');
        dataContactParams.put('Last_Name__c', 'RENÉ');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+352 282 61208');
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
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        // return additional services front frontend
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
        userModel.implKey = COUNTRY;
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
        System.assert(!services.isEmpty());
    }

    @IsTest
    static void creditLineGetDecisionsSuccessTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'RUBINOCCI RENÉ');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'RUBINOCCI');
        dataContactParams.put('Last_Name__c', 'RENÉ');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+352 282 61208');
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

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = COUNTRY, Index__c = 5.25);
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
    static void creditLineGetDecisionsBlackListTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', 'LU - KUNDENTESTSYSTEM GROUP SA - BITTE NICHT ÄNDERN');
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'RUBINOCCI RENÉ');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'RUBINOCCI');
        dataContactParams.put('Last_Name__c', 'RENÉ');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+352 282 61208');
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

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = COUNTRY, Index__c = 5.25);
        insert fuelPrice;

        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Opportunity__c = oppty.Id;
        report.Class_Rating__c = '3';
        insert report;

        Credit_Black_List_Company__c blackList = CreditFactoryTestUtils.generateBlackListCompanyLU();
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
        System.assert(statusCode == 104);
    }

    @IsTest
    static void creditLineDoNextStepTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'RUBINOCCI RENÉ');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'RUBINOCCI');
        dataContactParams.put('Last_Name__c', 'RENÉ');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+352 282 61208');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);
        // return contacts
        List<Contact> contacts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(contacts);

        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);

        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Fuel_Price__c fuelPrice = new Fuel_Price__c(Name = COUNTRY, Index__c = 5.25);
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
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.securityAmountToPay = 1400;
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
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'credit_line', existingE2EDataObject.Id, IMPL_KEY_SHELL);
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
    static void sepaConfirmationStepTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'payment_data');
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('Credit_Limit__c', 1100);
        dataObjectParams.put('Max_Credit_Limit__c', 1200);
        dataObjectParams.put('Security_Amount_To_Pay__c', 0);
        dataObjectParams.put('Billing_Period__c', '15');
        dataObjectParams.put('Payment_Method__c', 'Direct Debit');
        dataObjectParams.put('Direct_Debit_Mandate_Type__c', 'Core');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'RUBINOCCI RENÉ');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'RUBINOCCI');
        dataContactParams.put('Last_Name__c', 'RENÉ');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+352 282 61208');
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

        E2E_Data_Log__c checkBusinessObjectsJob = new E2E_Data_Log__c(Name = 'checkBusinessObjects', Job_Status__c = 'Completed', Job_ID__c = '123456789', E2E_Data_Object__c = existingE2EDataObject.Id);
        additionalSObjectsForTest.add(checkBusinessObjectsJob);
        E2E_Data_Log__c syncContactDataJob = new E2E_Data_Log__c(Name = 'syncContactData', Job_Status__c = 'Completed', Job_ID__c = '123456788', E2E_Data_Object__c = existingE2EDataObject.Id);
        additionalSObjectsForTest.add(syncContactDataJob);
        E2E_Data_Log__c reportRequestJob = new E2E_Data_Log__c(Name = 'reportRequest', Job_Status__c = 'Completed', Job_ID__c = '123456787', E2E_Data_Object__c = existingE2EDataObject.Id);
        additionalSObjectsForTest.add(reportRequestJob);
        insert additionalSObjectsForTest;

        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(oppty.Id, conts[0].Id);
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
        userModel.implKey = IMPL_KEY_SHELL;
        userModel.accountHolder = contact.FirstName + ' ' + contact.LastName;
        userModel.iban = 'LU280019400644750000';
        userModel.swift = 'SPIHAT22XXX';
        userModel.acceptSepa = true;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'doNextStep');
        requestParams.put('country', COUNTRY_CODE);
        requestParams.put('user_model', userModel);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        ETEUtilsTest.enqueueJobsForStep(COUNTRY_CODE, 'payment_data', existingE2EDataObject.Id, IMPL_KEY_SHELL);
        Test.stopTest();

        String transitionResponseBody = RestContext.response.responseBody.toString();
        Map<String, Object> transitionResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(transitionResponseBody);
        System.assertEquals(100, transitionResponseBodyMap.get('statusCode'));
        E2E_Data_Object__c dataObject = [SELECT IBAN__c, SWIFT__c, Accept_Sepa__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals(true, dataObject.Accept_Sepa__c);
        System.assertEquals('LU280019400644750000', dataObject.IBAN__c);
        System.assertEquals('SPIHAT22XXX', dataObject.SWIFT__c);
        List<Attachment> sepaAttachments = [SELECT Name FROM Attachment WHERE Name = 'SEPAMandate.pdf'];
        System.assertEquals(1, sepaAttachments.size());
    }


//    @IsTest
//    static void paymentOptionsStepTest() {
//        Map<String, Object> dataObjectParams = new Map<String, Object>();
//        dataObjectParams.put('Name', NEW_CUSTOMER);
//        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
//        dataObjectParams.put('Current_Step__c', 'pay_deposit');
//        dataObjectParams.put('Salutation__c', 'Mr.');
//        dataObjectParams.put('First_Name__c', 'RUBINOCCI');
//        dataObjectParams.put('Last_Name__c', 'RENÉ');
//        dataObjectParams.put('Selected_Company_Name__c', 'test company');
//        dataObjectParams.put('Security_Amount_To_Pay__c', 1200);
//        dataObjectParams.put('StageName__c', 'Prospecting');
//        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
//        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
//        List<SObject> additionalSObjectsForTest = new List<SObject>();
//        // return opportunity
//        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
//        additionalSObjectsForTest.add(oppty);
//        insert additionalSObjectsForTest;
//        // generate user model
//        Map<String, Object> dataObjectsToConvertMap = new Map<String, Object>{
//                'data_object' => existingE2EDataObject,
//                'ete_contact' => new List<E2E_Data_Contact__c>(),
//                'product' => new List<E2E_Data_Product__c>(),
//                'offer_item' => new List<E2E_Data_Offer_Item__c>(),
//                'additional_service' => new List<E2E_Data_Additional_Service__c>()
//        };
//        ETEUserModel userModel = ETEGlobalUtils.convertToETEUserModel(dataObjectsToConvertMap);
//        userModel.implKey = COUNTRY;
//        Map<String, Object> requestParams = new Map<String, Object>();
//        requestParams.put('method', 'doNextStep');
//        requestParams.put('country', COUNTRY_CODE);
//        requestParams.put('user_model', userModel);
//        String requestBody = JSON.serialize(requestParams);
//        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
//        Test.startTest();
//        ETERest.doPost();
//        String transitionResponseBody = RestContext.response.responseBody.toString();
//        Map<String, Object> transitionResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(transitionResponseBody);
//        System.assertEquals(103, transitionResponseBodyMap.get('statusCode'));
//        System.assertEquals(null, transitionResponseBodyMap.get('params_to_redirect'));
//        requestParams.put('method', 'getLinkToRedirect');
//        requestBody = JSON.serialize(requestParams);
//        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
//        ETERest.doPost();
//        String getLinkToRedirectResponseBody = RestContext.response.responseBody.toString();
//        Map<String, Object> getLinkToRedirectResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(getLinkToRedirectResponseBody);
//        System.assertEquals(103, getLinkToRedirectResponseBodyMap.get('statusCode'));
//        Test.stopTest();
//    }


//    @IsTest
//    static void returnFromIngenicoToFormTest() {
//        Map<String, Object> dataObjectParams = new Map<String, Object>();
//        dataObjectParams.put('Name', NEW_CUSTOMER);
//        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
//        dataObjectParams.put('Current_Step__c', 'pay_deposit');
//        dataObjectParams.put('Salutation__c', 'Mr.');
//        dataObjectParams.put('First_Name__c', 'RUBINOCCI');
//        dataObjectParams.put('Last_Name__c', 'RENÉ');
//        dataObjectParams.put('Email__c', 'test@test.com');
//        dataObjectParams.put('Phone__c', '+352 282 61208');
//        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
//        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
//        dataObjectParams.put('Security_Amount_To_Pay__c', 1200);
//        dataObjectParams.put('StageName__c', 'Prospecting');
//        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
//        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
//        List<SObject> additionalSObjectsForTest = new List<SObject>();
//        // return opportunity
//        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
//        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
//        insert existingOppty;
//        Contact contact = ETEUtilsTest.createContact(existingE2EDataObject, account);
//        additionalSObjectsForTest.add(contact);
//        Payment_Transaction__c paymentTransaction = ETEUtilsTest.createPaymentTransaction(existingE2EDataObject.Security_Amount_To_Pay__c, existingOppty.Id);
//        additionalSObjectsForTest.add(paymentTransaction);
//        insert additionalSObjectsForTest;
//        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contact.Id);
//        insert ocr;
//
//        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
//        ApexPages.currentPage().getParameters().put('source', encodedStr);
//        ApexPages.currentPage().getParameters().put('srvc', 'ingenico');
//        ApexPages.currentPage().getParameters().put('countryCode', COUNTRY_CODE);
//        Test.startTest();
//        paymentTransaction.Status__c = 'COMPLETED';
//        update paymentTransaction;
//        ETERedirectionController redirectionCtrl = new ETERedirectionController();
//        redirectionCtrl.checkStatus();
//        Test.stopTest();
//        E2E_Data_Object__c dataObject = [SELECT Payment_Status__c, E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
//        System.assertEquals('COMPLETED', dataObject.Payment_Status__c);
//        System.assertEquals('Finished', dataObject.E2E_Status__c);
//        System.assertEquals('Closed Won', dataObject.StageName__c);
//        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
//        System.assertEquals('Closed Won', oppty.StageName);
//    }


//    @IsTest
//    static void payLaterTest() {
//        Map<String, Object> dataObjectParams = new Map<String, Object>();
//        dataObjectParams.put('Name', NEW_CUSTOMER);
//        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
//        dataObjectParams.put('Current_Step__c', 'pay_deposit');
//        dataObjectParams.put('Salutation__c', 'Mr.');
//        dataObjectParams.put('First_Name__c', 'RUBINOCCI');
//        dataObjectParams.put('Last_Name__c', 'RENÉ');
//        dataObjectParams.put('Email__c', 'test@test.com');
//        dataObjectParams.put('Phone__c', '+352 282 61208');
//        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
//        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
//        dataObjectParams.put('StageName__c', 'Prospecting');
//        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
//        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
//        List<SObject> additionalSObjectsForTest = new List<SObject>();
//        Account account = ETEUtilsTest.createAccount(existingE2EDataObject);
//        Opportunity existingOppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, account);
//        additionalSObjectsForTest.add(existingOppty);
//        Contact contact = ETEUtilsTest.createContact(existingE2EDataObject, account);
//        additionalSObjectsForTest.add(contact);
//        insert additionalSObjectsForTest;
//        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(existingOppty.Id, contact.Id);
//        insert ocr;
//        String source = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
//        Map<String, Object> requestParams = new Map<String, Object>();
//        requestParams.put('method', 'payLater');
//        requestParams.put('country', COUNTRY_CODE);
//        requestParams.put('source', source);
//        String requestBody = JSON.serialize(requestParams);
//        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
//        Test.startTest();
//        ETERest.doPost();
//        Test.stopTest();
//        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, StageName__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
//        System.assertEquals('Finished', dataObject.E2E_Status__c);
//        System.assertEquals('Pending Sales – Deposit', dataObject.StageName__c);
//        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE E2E_Data_Object__c = :existingE2EDataObject.Id LIMIT 1];
//        System.assertEquals('Pending Sales – Deposit', oppty.StageName);
//    }


    @IsTest
    static void createExceptionLogTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
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
        requestParams.put('language', LANGUAGE);
        requestParams.put('implKey', IMPL_KEY_SHELL);
        requestParams.put('type', 'documentsAgreement');
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        Integer statusCode = RestContext.response.statusCode;
        String htmlResponseBody = RestContext.response.responseBody.toString();
        System.assertEquals(200, statusCode);
        System.assertEquals('<h1>LU Hello World</h1>', htmlResponseBody);
        Test.stopTest();
    }


    @IsTest
    static void getUserModelTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'LU Kundentestsystem AG');
        dataObjectParams.put('Selected_Company_Id__c', '09379370071090');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        List<Object> eteContactsList = new List<Object>();
        Map<String, Object> dataContactParams = new Map<String, Object>();
        dataContactParams.put('E2E_Data_Object__c', existingE2EDataObject.Id);
        dataContactParams.put('Index__c', 0);
        dataContactParams.put('Name', 'RUBINOCCI RENÉ');
        dataContactParams.put('Salutation__c', 'Mr.');
        dataContactParams.put('First_Name__c', 'RUBINOCCI');
        dataContactParams.put('Last_Name__c', 'RENÉ');
        dataContactParams.put('Email__c', 'test@test.com');
        dataContactParams.put('Phone__c', '+352 282 61208');
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
        requestParams.put('implKey', COUNTRY);
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


    @IsTest
    static void validateIbanTest() {
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'validateIban');
        requestParams.put('iban', 'LU280019400644750000');
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        Test.stopTest();
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(String.valueOf(responseBodyMap.get('statusCode')) == '100');
        System.assert(responseBodyMap.get('is_valid') == true);
    }


    @IsTest
    static void getSwiftInfoTest() {
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'getSwiftInfo');
        requestParams.put('iban', 'LU280019400644750000');
        requestParams.put('countryCode', COUNTRY_CODE);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        SingleRequestMock searchBicMock = new SingleRequestMock(200, 'Complete', '{"iban":"LU280019400644750000","result":"passed","return_code":0,"checks":["length","bank_code","account_number","iban_checksum"],"bic_candidates":[{"bic":"SPIHAT22XXX","zip":"","city":"","wwwcount":0,"sampleurl":""}],"all_bic_candidates":[{"bic":"SPIHAT22XXX","zip":"","city":"","wwwcount":0,"sampleurl":""}],"country":"LU","bank_code":"096","bank_and_branch_code":"096","bank":"","bank_address":"Bd Pacheco 441000 Brussels","bank_street":"Bd Pacheco 44","bank_city":"Brussels","bank_state":"","bank_postal_code":"1000","bank_url":"","branch":"","branch_code":"","in_scl_directory":"yes","sct":"yes","sdd":"yes","cor1":"no","b2b":"yes","scc":"no","sct_inst":"yes","sct_inst_readiness_date":"2018-11-18","account_number":"096123456769","account_validation_method":"","account_validation":"","length_check":"passed","account_check":"passed","bank_code_check":"passed","iban_checksum_check":"passed","data_age":"20190405","iban_listed":"www","iban_www_occurrences":"1","www_seen_from":"2017-06-22","www_seen_until":"2017-06-22","iban_url":"","url_rank":"711224","url_category":"","url_min_depth":"0","www_prominence":"","iban_reported_to_exist":0,"iban_last_reported":"","iban_candidate":"","IBANformat":"BEkk BBBC CCCC CCCC","formatcomment":"The last 12 digits represent: B = bank code, C = account No.","balance":99408}', null);
        Test.setMock(HttpCalloutMock.class, searchBicMock);
        ETERest.doPost();
        Test.stopTest();
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(String.valueOf(responseBodyMap.get('statusCode')) == '100');
        System.assert(responseBodyMap.get('swift') == 'SPIHAT22XXX');
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
                Integration_Name__c = 'homestationLU'
        );
        listProducts.add(prod);
        insert listProducts;


        insert new List<PricebookEntry>{
                new PricebookEntry(
                        Product2Id = prod.Id,
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
                )
        };


        List<Offer_Item_Type__c> listOfferItemTypes = new List<Offer_Item_Type__c>();
        Offer_Item_Type__c offerItemType = new Offer_Item_Type__c(
                Name = OFFER_ITEM_TYPE_SHELL,
                Integration_Name__c = 'shellfuelcard'
        );
        listOfferItemTypes.add(offerItemType);
        insert  listOfferItemTypes;


        insert new List<Offer_to_Item_Type_Junction__c>{
                new Offer_to_Item_Type_Junction__c(
                        Product__c = prod.Id,
                        Offer_Item_Type__c = offerItemType.Id
                )
        };


        ETEUtilsTest.createStaticResource('ETE_MP_OFFERS');
        ETEUtilsTest.createStaticResource('ETE_MP_fee_types');
        ETEUtilsTest.createStaticResource('ETE_MP_OIT_shellfuelcard');
    }


    @IsTest
    static void getSourceForLocatorJITB() {

        String country = COUNTRY;
        String esi = 'PR003';
        Account retailerAccount = new Account(
                Name = 'test',
                BillingCountry = country,
                OBN__c = esi
        );
        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
                Name = COUNTRY,
                E2E_Form_Url__c = 'https://online.fleetcor.lu/',
                E2E_JITB_Form_Url__c = 'https://online.fleetcor.fr/etejitblocator',
                Private_Key__c = 'P83U8MmjgIBU0V4l',
                Short_Url__c = 'https://online.fleetcor.lu/i'
        );

        insert shortUrlSettings;
        insert retailerAccount;



        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'locatorJitbSource');
        requestParams.put('country', COUNTRY);
        requestParams.put('esi', esi);
        requestParams.put('countryCode', COUNTRY_CODE);
        requestParams.put('homeStation', 'home station address');
        requestParams.put('recordType', COUNTRY);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);

        Test.startTest();

        ETERest.doPost();
        Integer statusCode = RestContext.response.statusCode;
        System.assertEquals(200, statusCode);

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> dataResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        Integer statusCodeFromBody = (Integer) dataResponse.get('statusCode');
        System.assert(statusCodeFromBody == 100);

        String source = (String) dataResponse.get('source');
        System.assert(source != null);

        Test.stopTest();
    }
}