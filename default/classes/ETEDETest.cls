@IsTest
private class ETEDETest {
    static final String COUNTRY_CODE = 'de';
    static final String COUNTRY = 'Germany';
    static final String NEW_CUSTOMER = 'NEW E2E CUSTOMER';
    static final String IMPL_KEY_SHELL = 'Germany';
    static final String OFFER_ITEM_TYPE_SHELL = 'Shell Fuel Card';
    static final String OFFER_ITEM_TYPE_EV = 'EV Fob';
    static final String PRODUCT_NAME_SHELL = 'Inbound Typ B';
    static final String PRODUCT_NAME_EV = 'EV DE Promo';
    static final String RECORD_TYPE_NAME = 'Germany';


    @TestSetup
    static void createLongFormData() {
        ETEUtilsTest.createCustomSettings(COUNTRY, IMPL_KEY_SHELL);
        ETEUtilsTest.createStaticResourceForSteps();
        ETEUtilsTest.createStaticResource('ETE_common_components_translations');
        ETEUtilsTest.createStaticResource('ETE_default_settings_de');
        ETEUtilsTest.createE2EApiKeys('E2EForm');
        createMultiproductData(COUNTRY_CODE);
    }


    @IsTest
    static void formFirstLoadingTest() {
        Test.startTest();
            ApexPages.currentPage().getparameters().put('utm_products', ETEGlobalUtils.doEncryptParams('product1;product2', COUNTRY_CODE));
            ETEController e2eFormCtrl = new ETEController();
            e2eFormCtrl.runLongFormDE();
        Test.stopTest();
    }


    @IsTest
    static void saveCustomerFeedbackTest() {
        String stepName = ETEUtilsTest.STEPS.products_and_services.name();
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', stepName);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c dataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        Map<String, Object> body = new Map<String, Object>{
                'method' => 'saveFeedback',
                'countryCode' => COUNTRY_CODE,
                'implKey' => IMPL_KEY_SHELL,
                'source' => ETEGlobalUtils.doEncryptParams(dataObject.Id, COUNTRY_CODE),
                'rating' => 50,
                'feedback' => 'Hello World!'
        };

        Test.startTest();
            ETEUtilsTest.prepareRequest(JSON.serialize(body), COUNTRY_CODE);
            ETERest.doPost();
            List<E2E_Data_Log__c> feedbacksLogs = [SELECT Feedback_Local__c FROM E2E_Data_Log__c WHERE E2E_Data_Object__c = :dataObject.Id];
            System.assertEquals(1, feedbacksLogs.size());
            System.assertEquals('Hello World!', feedbacksLogs.get(0).Feedback_Local__c);
            String responseBody = RestContext.response.responseBody.toString();
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(responseBodyMap.get('statusCode') == 100);
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
        e2eFormCtrl.runLongFormDE();
        Test.stopTest();
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
        userModelContact.name = 'John Johnson';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'John';
        userModelContact.lastName = 'Johnson';
        userModelContact.phone = '+49 177-777-777';
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
        userModel.contacts = userModelContacts;
        userModel.name = 'Buchverlagsgesellschaft Druck mbH';
        userModel.selectedCompanyName = 'Buchverlagsgesellschaft Druck mbH';
        userModel.companyShortName = 'Buchverlagsgesellschaft D';
        userModel.selectedCompanyId = '1645768';
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
        // CASE: INVALID INPUT DATA
        String stepName = ETEUtilsTest.STEPS.contacts.name();

        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        E2E_Data_Object__c dataObject = ETEUtilsTest.createDataObject(dataObjectParams);

        // generate user model
        ETEUserModel.ETE_Contact userModelContact = new ETEUserModel.ETE_Contact();
        userModelContact.index = 0;
        userModelContact.name = 'John Johnson';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'John';
        userModelContact.lastName = 'Johnson';
        // set invalid phone number
        userModelContact.phone = '+49 177-777-XXX';
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
        userModel.name = 'Buchverlagsgesellschaft Druck mbH';
        userModel.contacts = userModelContacts;

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
        dataObjectParams.put('RecordTypeName', COUNTRY);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '1645768' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'StageName' => 'Closed Won', 'CloseDate' => Date.today() });
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
        userModelContact.phone = '+49 177-777-777';
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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.selectedCompanyId = '1645768';
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
        dataObjectParams.put('RecordTypeName', COUNTRY);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '1645768' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'StageName' => 'Pending Sales – Information', 'CloseDate' => Date.today() });
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
        userModelContact.phone = '+49 177-777-777';
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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.selectedCompanyId = '1645768';
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
        dataObjectParams.put('RecordTypeName', COUNTRY);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '1645768' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'StageName' => 'Prospecting', 'CloseDate' => Date.today() });
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
        userModelContact.phone = '+49 177-777-777';
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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.selectedCompanyId = '1645768';
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
        dataObjectParams.put('RecordTypeName', COUNTRY);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '1645768' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'StageName' => 'Closed Lost', 'CloseDate' => Date.today().addDays(-100), 'Gruende_verloren__c' => 'Refused Credit'});
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        Opportunity existingOppty = [SELECT CloseDate FROM Opportunity WHERE Name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH' LIMIT 1];
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
        userModelContact.phone = '+49 177-777-777';
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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.selectedCompanyId = '1645768';
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
        dataObjectParams.put('RecordTypeName', COUNTRY);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // create test data
        Map<String, Map<String, Object>> dataForDeduplicationTest = new Map<String, Map<String, Object>>();
        dataForDeduplicationTest.put('acc', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'BillingCountry' => COUNTRY, 'Steuernummer__c' => '1645768' });
        dataForDeduplicationTest.put('con', new Map<String, Object>{
                'Salutation' => 'Mr.', 'FirstName' => 'Bruce', 'LastName' => 'Wayne', 'Email' => 'test123@test.com' });
        dataForDeduplicationTest.put('oppty', new Map<String, Object>{
                'Name' => 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH', 'StageName' => 'CreditCheck abgelehnt', 'CloseDate' => Date.today()});
        dataForDeduplicationTest.put('ocr', new Map<String, Object>{ 'IsPrimary' => true });
        ETEUtilsTest.createDeduplicationTestData(dataForDeduplicationTest);
        Opportunity existingOppty = [SELECT CloseDate FROM Opportunity WHERE Name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH' LIMIT 1];
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
        userModelContact.phone = '+49 177-777-777';
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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.selectedCompanyId = '1645768';
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
        searchCompanyRequestParams.put('requestedCompany', 'Buchverlagsgesellschaft Druck mbH');
        String searchCompanyRequestBody = JSON.serialize(searchCompanyRequestParams);
        ETEUtilsTest.prepareRequest(searchCompanyRequestBody, COUNTRY_CODE);
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"companyId": 1645768,"companyName": "Buchverlagsgesellschaft Druck mbH","formOfOrganisation": "GMBH","street": "Schillerstr. 52-60","city": "Frankfurt am Main","dialingCode": "069","phoneNumber": "3352587","vatId": "DE123547899","branchCode": "7112","registerCourt": "Frankfurt am Main","traderegisterNumber": "HRB 3867","alreadyOnboarded": false,"onboardingDate": "","headQuarterID": 1645768}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/search/full/detail', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ETERest.doPost();
            String responseBody = RestContext.response.responseBody.toString();
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(responseBodyMap.get('statusCode') == 100);
            System.assert(((List<Object>) responseBodyMap.get('companies')).size() > 0);
        Test.stopTest();
    }


    @IsTest
    static void displayOptionalCompanyDetailsStepTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.contacts.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
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
        userModelContact.name = 'Bruce Wayne';
        userModelContact.salutation = 'Mr.';
        userModelContact.firstName = 'Bruce';
        userModelContact.lastName = 'Wayne';
        userModelContact.phone = '+49 177-777-777';
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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.selectedCompanyId = 'none';
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
            List<String> jobsNeededToRun = new List<String>();
            for (E2E_Data_Log__c dataLog : [SELECT Name, Job_Status__c, Exception_Description__c FROM E2E_Data_Log__c]) {
                System.assertEquals(null, dataLog.Exception_Description__c);
                if (dataLog.Job_Status__c == 'Queued') {
                    jobsNeededToRun.add(dataLog.Name);
                }
            }
            ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobsNeededToRun, existingE2EDataObject.Id, COUNTRY_CODE, IMPL_KEY_SHELL);
            jobChainHandler.runNext();
            String responseBody = RestContext.response.responseBody.toString();
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(responseBodyMap.get('statusCode') == 100);
            E2E_Data_Object__c dataObject = [SELECT Current_Step__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
            System.assertEquals('company_details', dataObject.Current_Step__c);
        Test.stopTest();
    }


    @IsTest
    static void reportOrderRequestTest() {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.company_details.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('Selected_Company_Id__c', 'none');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        OpportunityContactRole ocr = ETEUtilsTest.createOpptyContactRole(oppty.Id, conts[0].Id);
        insert ocr;

        Attachment attachment = CreditFactoryTestUtils.generateGWAAttachment();
        attachment.Name = 'test';
        attachment.Description = 'Company registration form';
        attachment.ParentId = oppty.Id;
        insert attachment;

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
        userModel.name = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.selectedCompanyName = 'BUCHVERLAGSGESELLSCHAFT DRUCK MBH';
        userModel.companyShortName = 'BUCHVERLAGSGESELLSCHAFT D';
        userModel.city = 'Frankfurt am Main';
        userModel.street = 'Schillerstr. 52-60';
        userModel.postalCode = '60313';
        userModel.taxId = '1234123412341';
        userModel.vatId = 'DE123412341';
        userModel.tradeRegisterNumber = 'HRB 1234';

        Map<String, Object> goToNextStepRequestParams = new Map<String, Object>();
        goToNextStepRequestParams.put('method', 'doNextStep');
        goToNextStepRequestParams.put('country', COUNTRY_CODE);
        goToNextStepRequestParams.put('user_model', userModel);
        String goToNextStepRequestBody = JSON.serialize(goToNextStepRequestParams);
        ETEUtilsTest.prepareRequest(goToNextStepRequestBody, COUNTRY_CODE);

        Test.startTest();
            ETERest.doPost();
        Test.stopTest();

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(responseBodyMap.get('statusCode') == 100);
        E2E_Data_Object__c dataObject = [SELECT E2E_Status__c, E2E_Finish_Details__c FROM E2E_Data_Object__c WHERE Id = :existingE2EDataObject.Id LIMIT 1];
        System.assertEquals('Finished', dataObject.E2E_Status__c);
        System.assertEquals('Report Ordering', dataObject.E2E_Finish_Details__c);
    }


    @IsTest
    static void saveFileTest () {
        // create data object
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.company_details.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('Selected_Company_Id__c', 'none');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // return opportunity
        Opportunity opportunityObject = ETEUtilsTest.createOpportunity(existingE2EDataObject, null);
        additionalSObjectsForTest.add(opportunityObject);
        // return offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        additionalSObjectsForTest.addAll(offerItems);
        insert additionalSObjectsForTest;

        Map<String, Object> saveFileParams = new Map<String, Object>();
        String fileName = 'File Name.pdf';
        String source = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        saveFileParams.put('method', 'saveFile');
        saveFileParams.put('source', source);
        saveFileParams.put('countryCode', COUNTRY_CODE);
        saveFileParams.put('implKey', IMPL_KEY_SHELL);
        saveFileParams.put('fileName', fileName);
        saveFileParams.put('file', EncodingUtil.base64Encode(Blob.valueOf('File Body')));

        String saveFileBody = JSON.serialize(saveFileParams);
        ETEUtilsTest.prepareRequest(saveFileBody, COUNTRY_CODE);

        Test.startTest();
        ETERest.doPost();
        Test.stopTest();

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals(100, responseBodyMap.get('statusCode'));

        List<Attachment> opportunityAttachmentsList = [SELECT Id, Name FROM Attachment WHERE ParentId =: opportunityObject.Id];
        System.assertEquals(1, opportunityAttachmentsList.size());
        System.assertEquals(fileName, opportunityAttachmentsList.get(0).Name);
    }


    @IsTest
    static void returnToFormAfterReportGenerationTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', ETEUtilsTest.STEPS.company_details.name());
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', 'none');
        dataObjectParams.put('E2E_Status__c', 'Finished');
        dataObjectParams.put('E2E_Finish_Details__c', 'Report Ordering');
        dataObjectParams.put('RecordTypeName', RECORD_TYPE_NAME);
        E2E_Data_Object__c existingE2EDataObject = ETEUtilsTest.createDataObject(dataObjectParams);
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        // return opportunity
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        insert oppty;
        Credit_Factory_Report__c report = CreditFactoryTestUtils.generateCreditFactoryReport(COUNTRY);
        report.Company_Id__c = '1645768';
        report.Payment_History_Requested__c = false;
        report.Opportunity__c = oppty.Id;
        insert report;

        List<E2E_Data_Log__c> logsToInsert = new List<E2E_Data_Log__c>();
        String recordTypeReportRequestId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Request Status').getRecordTypeId();
        E2E_Data_Log__c checkBusinessObjectsJob = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = recordTypeReportRequestId,
                Name = 'reportOrderingRequest',
                Status__c = 'Report Requested'
        );
        logsToInsert.add(checkBusinessObjectsJob);

        String recordTypeJobStatusId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Job Status').getRecordTypeId();
        E2E_Data_Log__c reportOrderJob = new E2E_Data_Log__c(
                E2E_Data_Object__c = existingE2EDataObject.Id,
                RecordTypeId = recordTypeJobStatusId,
                Name = 'syncCompanyDetails',
                Job_Status__c = 'Completed'
        );
        logsToInsert.add(reportOrderJob);
        insert logsToInsert;
        String encodedStr = ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE);
        ApexPages.currentPage().getParameters().put('source', encodedStr);
        ApexPages.currentPage().getParameters().put('rep_ord', 'true');
        Test.startTest();
            ETEController e2eFormCtrl = new ETEController();
            e2eFormCtrl.runLongFormDE();
        Test.stopTest();
        E2E_Data_Object__c dataObject = [SELECT Selected_Company_Name__c, Selected_Company_Id__c, E2E_Status__c,
                                                E2E_Finish_Details__c
                                        FROM E2E_Data_Object__c
                                        WHERE Id = :existingE2EDataObject.Id
                                        LIMIT 1];
        System.assertEquals('Buchverlagsgesellschaft Druck mbH', dataObject.Selected_Company_Name__c);
        System.assertEquals('1645768', dataObject.Selected_Company_Id__c);
        System.assertEquals('In progress', dataObject.E2E_Status__c);
        System.assertEquals(null, dataObject.E2E_Finish_Details__c);
    }


    @IsTest
    static void additionalServicesGetServicesTest() {
         ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicede');
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
        ETEUtilsTest.createStaticResource('ETE_MP_AS_paperinvoicede');
        ETEUtilsTest.createAdditionalServices(PRODUCT_NAME_SHELL, COUNTRY);

        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'additional_services');
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
        dataObjectParams.put('Name', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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

        Credit_Black_List_Company__c blackList = CreditFactoryTestUtils.generateBlackListCompanyDE();
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
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
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
        dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
        userModel.iban = 'DE89370400440532013000';
        userModel.swift = 'GKCCBEBB';
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
        System.assertEquals('DE89370400440532013000', dataObject.IBAN__c);
        System.assertEquals('GKCCBEBB', dataObject.SWIFT__c);
        List<Attachment> sepaAttachments = [SELECT Name FROM Attachment WHERE Name = 'SEPAMandate.pdf'];
        System.assertEquals(1, sepaAttachments.size());
    }


    @IsTest
    static void paymentOptionsStepTest() {
         Map<String, Object> dataObjectParams = new Map<String, Object>();
         dataObjectParams.put('Name', NEW_CUSTOMER);
         dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
         dataObjectParams.put('Current_Step__c', 'pay_deposit');
         dataObjectParams.put('Selected_Company_Name__c', 'test company');
         dataObjectParams.put('Security_Amount_To_Pay__c', 1200);
         dataObjectParams.put('StageName__c', 'Prospecting');
         dataObjectParams.put('Deposit_Agreement__c', false);
         dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
         userModel.implKey = COUNTRY;
         userModel.depositAgreement = true;
         Map<String, Object> requestParams = new Map<String, Object>();
         requestParams.put('method', 'doNextStep');
         requestParams.put('country', COUNTRY_CODE);
         requestParams.put('user_model', userModel);
         String requestBody = JSON.serialize(requestParams);
         ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
         Test.startTest();
            ETERest.doPost();
            String transitionResponseBody = RestContext.response.responseBody.toString();
            Map<String, Object> transitionResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(transitionResponseBody);
            System.assertEquals(103, transitionResponseBodyMap.get('statusCode'));
            System.assertEquals(null, transitionResponseBodyMap.get('params_to_redirect'));
            requestParams.put('method', 'getLinkToRedirect');
            requestBody = JSON.serialize(requestParams);
            ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
            ETERest.doPost();
            String getLinkToRedirectResponseBody = RestContext.response.responseBody.toString();
            Map<String, Object> getLinkToRedirectResponseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(getLinkToRedirectResponseBody);
            System.assertEquals(103, getLinkToRedirectResponseBodyMap.get('statusCode'));
         Test.stopTest();
         List<Attachment> depositAgreementAttachments = [SELECT Name FROM Attachment WHERE Name = 'Deposit Agreement.pdf'];
         System.assertEquals(1, depositAgreementAttachments.size());
    }


    @IsTest
    static void returnFromIngenicoToFormTest() {
         Map<String, Object> dataObjectParams = new Map<String, Object>();
         dataObjectParams.put('Name', NEW_CUSTOMER);
         dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
         dataObjectParams.put('Current_Step__c', 'pay_deposit');
         dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
         dataObjectParams.put('Security_Amount_To_Pay__c', 1200);
         dataObjectParams.put('StageName__c', 'Prospecting');
         dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
         ApexPages.currentPage().getParameters().put('srvc', 'ingenico');
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
         dataObjectParams.put('Current_Step__c', 'pay_deposit');
         dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
         dataObjectParams.put('StageName__c', 'Prospecting');
         dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
         dataObjectParams.put('RecordTypeName', COUNTRY);
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
        requestParams.put('type', 'agreeToProcessPersDataForMarketing');
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
        ETERest.doPost();
        Integer statusCode = RestContext.response.statusCode;
        String htmlResponseBody = RestContext.response.responseBody.toString();
        System.assertEquals(200, statusCode);
        System.assertEquals('<h1>DE Hello World</h1>', htmlResponseBody);
        Test.stopTest();
    }


    @IsTest
    static void getUserModelTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'credit_line');
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', COUNTRY);
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
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
    static void checkSchufaReportTest() {
        Map<String, Object> dataObjectParams = new Map<String, Object>();
        dataObjectParams.put('Name', NEW_CUSTOMER);
        dataObjectParams.put('Country_Code__c', COUNTRY_CODE);
        dataObjectParams.put('Current_Step__c', 'additional_services');
        dataObjectParams.put('Selected_Company_Name__c', 'Buchverlagsgesellschaft Druck mbH');
        dataObjectParams.put('Selected_Company_Id__c', '1645768');
        dataObjectParams.put('Agreement_To_Phone_Contact__c', true);
        dataObjectParams.put('Agreement_To_Receive_Info_By_Email__c', true);
        dataObjectParams.put('Agree_to_process_pers_data_for_marketing__c', true);
        dataObjectParams.put('Terms_And_Conditions_Agreement__c', true);
        dataObjectParams.put('StageName__c', 'Prospecting');
        dataObjectParams.put('RecordTypeName', 'Germany');
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
        dataContactParams.put('Phone__c', '+49 177-777-777');
        dataContactParams.put('Role__c', 'Decision Maker');
        dataContactParams.put('isPrimary__c', true);
        eteContactsList.add(dataContactParams);
        List<E2E_Data_Contact__c> existingE2EDataContacts = ETEUtilsTest.createDataContacts(eteContactsList);

        // create offer items
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name =: PRODUCT_NAME_SHELL LIMIT 1];
        Offer_Item_Type__c offerItemType = [SELECT Id, Name FROM Offer_Item_Type__c WHERE Name =: OFFER_ITEM_TYPE_SHELL LIMIT 1];
        List<E2E_Data_Product__c> productsList = ETEUtilsTest.createProducts(existingE2EDataObject, product, offerItemType);
        List<E2E_Data_Offer_Item__c> offerItems = ETEUtilsTest.createETEOfferItems(existingE2EDataObject, productsList);
        insert offerItems;

        List<SObject> additionalSObjectsForTest = new List<SObject>();
        // insert account and return cont
        Account acc = ETEUtilsTest.createAccount(existingE2EDataObject);
        Opportunity oppty = ETEUtilsTest.createOpportunity(existingE2EDataObject, acc);
        additionalSObjectsForTest.add(oppty);
        List<Contact> conts = ETEUtilsTest.createContacts(existingE2EDataContacts, acc);
        additionalSObjectsForTest.addAll(conts);
        E2E_Data_Log__c dataLog = new E2E_Data_Log__c(Name = 'reportRequest', Job_Status__c = 'Queued', Job_ID__c = '123456789', E2E_Data_Object__c = existingE2EDataObject.Id);
        additionalSObjectsForTest.add(dataLog);
        insert additionalSObjectsForTest;

        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'checkSchufaReport');
        requestParams.put('countryCode', COUNTRY_CODE);
        requestParams.put('index', 1);
        requestParams.put('source', ETEGlobalUtils.doEncryptParams(existingE2EDataObject.Id, COUNTRY_CODE));
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String, HttpCalloutMock>();
            SingleRequestMock schufaAuthMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', schufaAuthMock);
            SingleRequestMock schufaOrderEconomyInfoMock = new SingleRequestMock(200, 'Complete', '"ok"', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full/X1/order', schufaOrderEconomyInfoMock);
            SingleRequestMock shufaOrderStatusMock = new SingleRequestMock(200, 'Complete', '{"companyIDs": 1645768,"name": "Buchverlagsgesellschaft Druck mbH","order": [{"name": "CoreData","orderDate": "10.03.2020 13:05:34","reason": "","ordered": true,"completed": true,"failed": false},{"name": "Linkage","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "FullEconomyInfo","orderDate": "11.03.2020 06:29:52","reason": "","ordered": true,"completed": true,"failed": false},{"name": "ShortEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "CompactEconomyInfo","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "Compliance","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "MediaScreening","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false},{"name": "TransparencyRegister","orderDate": "","reason": "","ordered": false,"completed": false,"failed": false}],"tradeRegisterOrder": [{"documentType": "AD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "CD","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "LG","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""},{"documentType": "GSS","uid": 0,"status": "","ordered": false,"completed": false,"failed": false,"reason": ""}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/1645768/orders', shufaOrderStatusMock);
            SingleRequestMock shufaReportMock = new SingleRequestMock(200, 'Complete', '{"hints": [{"code": "F1","description": "Fallklasse: 1 - (Ein) Wirtschaftlich Berechtigte(r) wurde anhand der einschlägigen Vermutungsregel detektiert. Es gibt keine Hinweise auf mögliche weitere wirtschaftlich Berechtigte.  Die Fallklasse stellt eine Zusammenfassung der Ermittlungsergebnisse dar.  "},{"description": "Diese Auskunft ist nur für den Empfänger bestimmt. Der Empfänger darf die übermittelten Daten nur für den Zweck nutzen oder verarbeiten, für den sie erteilt bzw. angefordert worden sind."},{"code": "Kapitalbezeichner","description": "Stammkapital"},{"code": "geschaeftszahlen.info.schaetzung","description": "Bei den vorgenannten Unternehmenszahlen kann es sich teilweise um auf Basis von Branchendurchschnittswerten geschätzte Angaben handeln."},{"code": "jahresabschluss.hinweis","description": "Es werden Jahresabschlüsse nach HGB berücksichtigt. Jahresabschlüsse nach abweichenden Rechnungslegungsvorschriften, wie IFRS, RechKredV oder Substanzwertberechnung, finden keine Berücksichtigung."}],"classificationNumbers": [{"code": "datumGesellschafter","description": "Datum Gesellschafterinformationen","date": "2019-10-17T00:00:00.000+02:00"}],"coreData": {"companyData": {"companyId": 1645768,"vatID": "DE123547899","name": "Buchverlagsgesellschaft Druck mbH","foundationDate": "08.08.1991","legalForm": "Gesellschaft mit beschränkter Haftung","legalFormAbbreviation": "GmbH","branch": "Ingenieurbüros","branchCode": "7112","sideBranches": [{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false},{"branchType": {"code": "2","description": "WZ-08"},"code": "7022","description": "Unternehmensberatung","mainBranch": false}],"registercourt": "Frankfurt am Main","registerCourtZipCode": "60313","tradeRegisterNumber": "HRB 3867","website": "www.Buchverlagsgesellschaft-frankfurt.de","street": "Schillerstr. 52-60","city": "Frankfurt am Main","zipcode": "60313","currentCommunicationData": {"phoneNumber": {"dialingCode": "069","number": "3352587"},"faxNumber": {"dialingCode": "069","number": "3352599"},"website": "www.Buchverlagsgesellschaft-frankfurt.de","email": "kontakt@Buchverlagsgesellschaft-frankfurt.de"}},"legalRepresentatives": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}],"beneficialOwner": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "BERTRAM","lastname": "NADLER-SCHULZ","birthdate": "14.01.1973","isSelected": false,"address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000700-1"}},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "CORNELIUS","lastname": "OTTERSBACH","birthdate": "27.11.1968","isSelected": false,"address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false,"fictional": false,"property": {"code": 1,"description": "Gesellschafter"},"eligiblePath": {"text": "Wirtschaftliche Berechtigung durch direktes Eigentum ","id": "p8000701-1"}}],"nonBeneficials": [{"id": "38e3d171-4723-48da-ad33-d21e203279ac","isSelected": false,"checkedIdentity": false,"soleSignatureAuthorized": false,"eligibleInformation": {"text": "Ermittlungsabbruch. SONSTIGES.","id": "s8000200-1"}}],"representationAuthorized": [{"id": "2a00aed2-ad10-463f-87dc-27f23b1c9053","schufaid": "DHT3OA8FEN","title": "Herr","firstname": "Bertram","lastname": "Nadler-Schulz","birthdate": "14.01.1973","isSelected": false,"position": "Geschäftsführer","address": "SCHUETZENBAHN 58 45127 ESSEN","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false},{"id": "78e65cc8-c48f-49f8-8cea-f4cc6aacdb02","schufaid": "DHT4OA7FEN","title": "Herr","firstname": "Cornelius","lastname": "Ottersbach","birthdate": "27.11.1968","isSelected": false,"position": "Geschäftsführer","address": "BOHMERTSTR. 333 45964 GLADBECK","birthplace": "TDS UDB B2B GWG","checkedIdentity": true,"soleSignatureAuthorized": false}]},"tradeRegisterData": {"tradeRegisterNumber": "HRB 3867","zipCode": "60313","city": "Frankfurt am Main"},"financialStanding": {"creditLimit": {"amount": 25000,"scale": 1,"currency": "EUR"},"financialIndex": {"currentScore": {"name": "BONI_INDEX_V3","date": "11.03.2020","score": 150,"riskQuota": 0.55,"hintTexts": [{"code": "score-bereich","description": "100-249"},{"code": "score-bereich-erlaeuterung","description": "Zu diesem Unternehmen liegen keine Informationen über kritische Zahlungsstörungen vor. Das Risiko, dass Zahlungsschwierigkeiten auftreten werden, ist stark unterdurchschnittlich."}]}},"hintTexts": [{"code": "bonitaetsinformationen.info.kreditlimit","description": "Das Kreditlimit ist das Ergebnis eines Scorings  und kann einen Wert von maximal 250.000,00 EUR annehmen. Es bietet dem Vertragspartner lediglich einen Orientierungswert bei der Kredit-/Limitvergabe. Die Empfehlung zeigt an, in welcher Höhe ein typischer Lieferantenkredit (nicht Bankkreditlimit, Warenkreditversicherungslimit o.ä.) gemäß unserer automatisierten Einschätzung standardmäßig zum angefragten Unternehmen empfohlen werden kann."},{"code": "bonitaetsinformationen.info.ausfallquote","description": "Die Ausfallquote gibt die Wahrscheinlichkeit einer Zahlungsstörung innerhalb eines Zeitraums von 12 Monaten an."},{"code": "BI_Verfahren","description": "2010"}]},"employees": [{"minCount": 20,"maxCount": 49,"class": 5,"year": 2018,"description": "20-49"}],"volume": [{"class": 5,"year": 2018,"description": "0,5 Mio. bis 1 Mio. EUR","minimum": {"amount": 500001,"scale": 1,"currency": "EUR"},"maximum": {"amount": 1000000,"scale": 1,"currency": "EUR"}}],"liableEquity": {"year": 2009,"amount": {"amount": 51150,"scale": 1,"currency": "EUR"}},"bankAccounts": [{"name": "Deutsche Bank","city": "Essen","zipCode": "45116","bic": "DEUTDEDEXXX","bankCode": "36070050"},{"name": "Postbank","city": "Essen","zipCode": "45125","bic": "PBNKDEFF360","bankCode": "36010043"},{"name": "Volksbank Rhein-Ruhr (Gf P2)","city": "Duisburg","zipCode": "47013","bankCode": "35060386"}],"corporateManagement": [{"person": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram","lastName": "Nadler-Schulz","gender": "M","birthDate": "14.01.1973","currentAddress": {"street": "Schuetzenbahn 58","zipCode": "45127","city": "Essen","adressType": {}}},"soleSignaturyAuthorized": false},{"person": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius","lastName": "Ottersbach","gender": "M","birthDate": "27.11.1968","currentAddress": {"street": "Bohmerstr. 333","zipCode": "45964","city": "Gladbeck","adressType": {}}},"soleSignaturyAuthorized": false}],"functionaries": [{"person": {"checkedIdentity": false,"schufaId": "13245","firstName": "Tobias","lastName": "Theel","gender": "M","birthDate": "17.01.1993","birthPlace": "Fritzlar","currentAddress": {"street": "Grebensteiner Str. 1A","zipCode": "34127","city": "Kassel","country": "DEU","adressType": {}}},"function": {"code": 5,"description": "Prokurist","status": "Aktiv"},"linking": {"corporation": {"currentAddress": {"adressType": {}},"tradeRegister": {}},"function": {}}}],"associates": [{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT3OA8FEN","firstName": "Bertram Nadler-Schulz","birthDate": "14.01.1973","currentAddress": {"city": "Essen","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 50,"volume": {"amount": 25575,"scale": 1,"currency": "EUR"},"associateType": {"code": 1,"description": "Gesellschafter"},"associatePerson": {"checkedIdentity": false,"schufaId": "DHT4OA7FEN","firstName": "Cornelius Ottersbach","birthDate": "27.11.1968","currentAddress": {"city": "Gladbeck","country": "DEU","adressType": {}}},"associateOther": {}},{"volumePercent": 0,"volume": {"amount": 0,"scale": 1,"currency": "EUR"},"associateType": {"code": 2,"description": "Komplementär"},"associatePerson": {"checkedIdentity": false,"firstName": "Rollo Ralf"},"associateOther": {}}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/schufa/1645768/full', shufaReportMock);
            SingleRequestMock lexisNexisReportMock = new SingleRequestMock(200, 'Complete', '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4="urn:idu"><SOAP-ENV:Body><ns4:IDUProcessResponse><Results><Summary><Status xsi:type="xsd:boolean">true</Status><ID xsi:type="xsd:string">1361854425</ID><IKey xsi:type="xsd:string">1556717457</IKey><equifaxUsername xsi:type="xsd:string"/><Reference xsi:type="xsd:string">TESTCFPL</Reference><Scorecard xsi:type="xsd:string">IDU default</Scorecard><Smartscore xsi:type="xsd:int">0</Smartscore><ResultText xsi:type="xsd:string">REFER</ResultText><ProfileURL xsi:type="xsd:string">https://idu.tracesmart.co.uk/?page=save&amp;id=1361854425&amp;ikey=1556717457</ProfileURL><Credits xsi:type="xsd:int">44253</Credits><Errors xsi:type="ns4:ErrorPart" xsi:nil="true"/></Summary><Address xsi:nil="true"/><Smartlink xsi:nil="true"/><Deathscreen xsi:nil="true"/><Ccj xsi:nil="true"/><DrivingLicence xsi:nil="true"/><DOB xsi:nil="true"/><Age xsi:nil="true"/><NHS xsi:nil="true"/><NI xsi:nil="true"/><Sanction xsi:nil="true"/><Passport xsi:nil="true"/><Birth xsi:nil="true"/><CardNumber xsi:nil="true"/><Insolvency xsi:nil="true"/><Mpan xsi:nil="true"/><BankAccountValidation xsi:nil="true"/><Crediva xsi:nil="true"/><CreditActive xsi:nil="true"/><TravelVisa xsi:nil="true"/><IDCard xsi:nil="true"/><BankAccountVerification xsi:nil="true"/><SearchActivity xsi:nil="true"/><CompanyDirector xsi:nil="true"/><PRS xsi:nil="true"/><Marriage xsi:nil="true"/><PollNumber xsi:nil="true"/><OnlineProfile xsi:nil="true"/><DocumentAuthentication xsi:nil="true"/><EmailAddresses xsi:nil="true"/><PhoneNumbers xsi:nil="true"/><Otp xsi:nil="true"/><OneTimePassword xsi:nil="true"/><Kba xsi:nil="true"/><EmailRisks xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="ns4:EmailRiskArray[1]"><EmailRisk xsi:type="ns4:EmailRisk"><EmailExists xsi:type="xsd:string">Yes</EmailExists><DomainExists xsi:type="xsd:string">Yes</DomainExists><EmailDate xsi:nil="true"/><DomainDate xsi:type="xsd:string">1998-04-28T13:00:00Z</DomainDate><StatusID xsi:type="xsd:int">2</StatusID><FraudRiskBand xsi:type="xsd:int">6</FraudRiskBand><RiskDescriptionID xsi:type="xsd:int">14</RiskDescriptionID><RiskAdviceID xsi:type="xsd:int">3</RiskAdviceID><FraudWithinIndustry xsi:nil="true"/><FraudType xsi:nil="true"/><TotalHits xsi:type="xsd:int">1</TotalHits><UniqueHits xsi:type="xsd:int">1</UniqueHits><NameMatch xsi:type="xsd:string">Y</NameMatch><EmailAddress xsi:type="xsd:string">kamyk1210@wp.pl</EmailAddress></EmailRisk></EmailRisks></Results></ns4:IDUProcessResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>', null);
            mocksMap.put('https://sandbox.ws-idu.tracesmart.co.uk/v5.3/index.php', lexisNexisReportMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ETERest.doPost();
        Test.stopTest();
        List<Credit_Factory_Report__c> creditReportsList = [
            SELECT Name
            FROM Credit_Factory_Report__c
            WHERE Opportunity__c = :oppty.Id LIMIT 1];
        System.assertEquals(1, creditReportsList.size());
    }


    @IsTest
    static void validateIbanTest() {
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('method', 'validateIban');
        requestParams.put('iban', 'DE89370400440532013000');
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
        requestParams.put('iban', 'DE89370400440532013000');
        requestParams.put('countryCode', COUNTRY_CODE);
        String requestBody = JSON.serialize(requestParams);
        ETEUtilsTest.prepareRequest(requestBody, COUNTRY_CODE);
        Test.startTest();
            SingleRequestMock searchCompanyMock = new SingleRequestMock(200, 'Complete', '{"iban":"DE89370400440532013000","result":"passed","return_code":0,"checks":["length","bank_code","account_number","iban_checksum"],"bic_candidates":[{"bic":"GKCCBEBB","zip":"","city":"","wwwcount":0,"sampleurl":""}],"all_bic_candidates":[{"bic":"GKCCBEBB","zip":"","city":"","wwwcount":0,"sampleurl":""}],"country":"BE","bank_code":"096","bank_and_branch_code":"096","bank":"","bank_address":"Bd Pacheco 441000 Brussels","bank_street":"Bd Pacheco 44","bank_city":"Brussels","bank_state":"","bank_postal_code":"1000","bank_url":"","branch":"","branch_code":"","in_scl_directory":"yes","sct":"yes","sdd":"yes","cor1":"no","b2b":"yes","scc":"no","sct_inst":"yes","sct_inst_readiness_date":"2018-11-18","account_number":"096123456769","account_validation_method":"","account_validation":"","length_check":"passed","account_check":"passed","bank_code_check":"passed","iban_checksum_check":"passed","data_age":"20190405","iban_listed":"www","iban_www_occurrences":"1","www_seen_from":"2017-06-22","www_seen_until":"2017-06-22","iban_url":"","url_rank":"711224","url_category":"","url_min_depth":"0","www_prominence":"","iban_reported_to_exist":0,"iban_last_reported":"","iban_candidate":"","IBANformat":"BEkk BBBC CCCC CCCC","formatcomment":"The last 12 digits represent: B = bank code, C = account No.","balance":99408}', null);
            Test.setMock(HttpCalloutMock.class, searchCompanyMock);
            ETERest.doPost();
        Test.stopTest();
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(String.valueOf(responseBodyMap.get('statusCode')) == '100');
        System.assert(responseBodyMap.get('swift') == 'GKCCBEBB');
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
                Integration_Name__c = 'inboundtypbde'
        );
        Product2 prodEV = new Product2(
                Name = PRODUCT_NAME_EV,
                Family = 'EV',
                Available_for_E2E__c = true,
                IsActive = true,
                Country__c = country,
                CurrencyIsoCode = currencyCode,
                Integration_Name__c = 'evdepromode'
        );
        listProducts.add(prod);
        listProducts.add(prodEV);
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
                        Product2Id = prodEV.Id,
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
                        FLEETCOR_Offer__c = prodEV.Id,
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
        Offer_Item_Type__c offerItemTypeEV = new Offer_Item_Type__c(
                Name = OFFER_ITEM_TYPE_EV,
                Integration_Name__c = 'evfob'
        );
        listOfferItemTypes.add(offerItemType);
        listOfferItemTypes.add(offerItemTypeEV);
        insert  listOfferItemTypes;


        insert new List<Offer_to_Item_Type_Junction__c>{
                new Offer_to_Item_Type_Junction__c(
                        Product__c = prod.Id,
                        Offer_Item_Type__c = offerItemType.Id
                ),
                new Offer_to_Item_Type_Junction__c(
                        Product__c = prodEV.Id,
                        Offer_Item_Type__c = offerItemTypeEV.Id
                )
        };


        ETEUtilsTest.createStaticResource('ETE_MP_OFFERS');
        ETEUtilsTest.createStaticResource('ETE_MP_OFFERS');
        ETEUtilsTest.createStaticResource('ETE_MP_fee_types');
        ETEUtilsTest.createStaticResource('ETE_MP_OIT_shellfuelcard');
        ETEUtilsTest.createStaticResource('ETE_MP_OIT_evfob');
    }


    @IsTest
    static void getSourceForLocatorJITB() {

        String country = 'Germany';
        String esi = 'PR003';
        Account retailerAccount = new Account(
                Name = 'test',
                BillingCountry = country,
                OBN__c = esi
        );
        E2E_Short_Url__c shortUrlSettings = new E2E_Short_Url__c(
            Name = 'Germany',
            E2E_Form_Url__c = 'https://online.fleetcor.de/',
            E2E_JITB_Form_Url__c = 'https://online.fleetcor.de/etejitblocator',
            Private_Key__c = 'P83U8MmjgIBU0V4l',
            Short_Url__c = 'https://online.fleetcor.de/i'
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
