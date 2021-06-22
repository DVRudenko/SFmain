public class ETEUtilsTest {
    public enum STEPS {
        products_and_services,
        contacts,
        company_details,
        additional_services,
        credit_line,
        documents,
        pay_deposit
    }

    public static void createCustomSettings(String country, String implKey) {
        List<SObject> customSettingsToInsert = new List<SObject>();
        if (country == 'Poland' || country == 'Hungary' || country == 'Czech Republic' || country == 'Slovakia') {
            CreditSystem__c creditSystemSettings;
            if (country == 'Poland') {
                creditSystemSettings = CreditFactoryTestUtils.generateCrifSetting();
                customSettingsToInsert.add(creditSystemSettings);

                CreditSystem__c krdSettings = CreditFactoryTestUtils.generateKrdSetting();
                customSettingsToInsert.add(krdSettings);

                List<Credit_Factory_Calculation__c> calculations = CreditFactoryTestUtils.generateCreditFactoryCalculationsPL();
                customSettingsToInsert.addAll(calculations);

                E2E_Docusign_Templates__c contractSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E PL Contract',
                    Attachment_Name__c = 'Umowa Karty euroShell (DocuSign).pdf',
                    Docusign_Template_Id__c = 'eeba098f-62fc-4cc5-8160-b1f7f6b8073c',
                    Docusign_Template_Name__c = 'E2E PL Umowa Karty euroShell'
                );
                customSettingsToInsert.add(contractSettings);

                E2E_Docusign_Templates__c depositAgreementSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E PL Deposit Agreement',
                        Attachment_Name__c = 'Umowa_o_kaucji (DocuSign).pdf',
                        Docusign_Template_Id__c = '4ef2c17d-1f28-4fed-8aa0-2f0de38928da',
                        Docusign_Template_Name__c = 'E2E PL Umowa o kaucji'
                );
                customSettingsToInsert.add(depositAgreementSettings);

                E2E_Docusign_Templates__c contractLotosSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E PL Lotos Contract',
                        Attachment_Name__c = 'Umowa Karty Lotos (DocuSign).pdf',
                        Docusign_Template_Id__c = '709219ce-00bb-4141-b809-99dfbd931032',
                        Docusign_Template_Name__c = 'E2E PL Lotos Contract'
                );
                customSettingsToInsert.add(contractLotosSettings);

                E2E_Docusign_Templates__c depositAgreementLotosSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E PL Lotos Deposit Agreement',
                        Attachment_Name__c = 'Umowa o kaucji Lotos (DocuSign).pdf',
                        Docusign_Template_Id__c = 'e224d243-874d-40c3-a2bf-8723b9084135',
                        Docusign_Template_Name__c = 'E2E PL Lotos Deposit Agreement'
                );
                customSettingsToInsert.add(depositAgreementLotosSettings);

            } else if (country == 'Hungary') {
                creditSystemSettings = CreditFactoryTestUtils.generateCofaceSetting();
                customSettingsToInsert.add(creditSystemSettings);

                E2E_Docusign_Templates__c contractSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E HU Contract',
                    Attachment_Name__c = 'ContractHU.pdf',
                    Docusign_Template_Id__c = '278a3f4f-012c-434d-bdc8-cd79e0f964c0',
                    Docusign_Template_Name__c = 'E2E HU Contract'
                );
                customSettingsToInsert.add(contractSettings);

                E2E_Docusign_Templates__c depositAgreementSettings = new E2E_Docusign_Templates__c(
                    Name = 'E2E HU Deposit Agreement',
                    Attachment_Name__c = 'DepositAgreementHU.pdf',
                    Docusign_Template_Id__c = '3f85c150-add3-435a-a5ab-6bd2a93a32b5',
                    Docusign_Template_Name__c = 'E2E HU Deposit Agreement'
                );
                customSettingsToInsert.add(depositAgreementSettings);

                CF_Order_Notifications__c orderNotificationsSettings = CreditFactoryTestUtils.createOrderNotificationHU();
                customSettingsToInsert.add(orderNotificationsSettings);
            } else if (country == 'Czech Republic' || country == 'Slovakia') {
                creditSystemSettings = CreditFactoryTestUtils.generateCribisSetting();
                customSettingsToInsert.add(creditSystemSettings);
                if (country == 'Czech Republic') {
                    E2E_Docusign_Templates__c contractSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E CZ Contract',
                        Attachment_Name__c = 'ContractCZ.pdf',
                        Docusign_Template_Id__c = '278a3f4f-012c-434d-bdc8-cd79e0f964c0',
                        Docusign_Template_Name__c = 'E2E CZ Contract'
                    );
                    customSettingsToInsert.add(contractSettings);

                    E2E_Docusign_Templates__c depositAgreementSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E CZ Deposit Agreement',
                        Attachment_Name__c = 'DepositAgreementCZ.pdf',
                        Docusign_Template_Id__c = '3f85c150-add3-435a-a5ab-6bd2a93a32b5',
                        Docusign_Template_Name__c = 'E2E CZ Deposit Agreement'
                    );
                    customSettingsToInsert.add(depositAgreementSettings);
                }
                else {
                    E2E_Docusign_Templates__c contractSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E SK Contract',
                        Attachment_Name__c = 'ContractSK.pdf',
                        Docusign_Template_Id__c = '278a3f4f-012c-434d-bdc8-cd79e0f964c0',
                        Docusign_Template_Name__c = 'E2E SK Contract'
                    );
                    customSettingsToInsert.add(contractSettings);

                    E2E_Docusign_Templates__c depositAgreementSettings = new E2E_Docusign_Templates__c(
                        Name = 'E2E SK Deposit Agreement',
                        Attachment_Name__c = 'DepositAgreementHU.pdf',
                        Docusign_Template_Id__c = '3f85c150-add3-435a-a5ab-6bd2a93a32b5',
                        Docusign_Template_Name__c = 'E2E SK Deposit Agreement'
                    );
                    customSettingsToInsert.add(depositAgreementSettings);
                }
            }

            E2E_Docusign_Settings__c e2eDocusignSettings = new E2E_Docusign_Settings__c(
                    Name = country,
                    AccountId__c = '68300806-41ed-466c-a7f1-9c97ace583e0',
                    Body__c = 'test',
                    IntegratorsKeyDesktop__c = '57c6330f-6449-4c36-9336-482e9a2d6cdf',
                    IntegratorsKeyMob__c = 'a6d9ca37-8d88-4058-86cb-09d372a38fe6',
                    Password__c = 'Fleetcor2019!',
                    Subject__c = 'Karty paliwowe FLEETCOR-dokumenty do podpisu elektronicznego',
                    UserId__c = 'e425921f-bf72-4a5b-84af-2dbdc472a16e',
                    WebServiceUrl__c = 'https://demo.docusign.net/api/3.0/dsapi.asmx'
            );
            customSettingsToInsert.add(e2eDocusignSettings);

            E2E_PayU_Settings__c payUSettings = new E2E_PayU_Settings__c(
                    Name = implKey,
                    API_Endpoint__c = 'https://secure.snd.payu.com',
                    Client_Id__c = '356975',
                    Client_Secret__c = '8d2da48cbb22b1a0b9dac3dc62262987',
                    Company_Id__c = 236039,
                    IsActive__c = true,
                    notifyUrl__c = 'https://e2e-e2efleetcor.cs101.force.com',
                    Pos_Id__c = '356975',
                    Second_key_MD5__c = 'a85b502dfbc3c010b1746ed8cb2a2b6f',
                    Shop_Id__c = 'Fa1uzXfU');
            customSettingsToInsert.add(payUSettings);
        } else if (country == 'Germany' || country == 'Netherlands' ||
                    country == 'Belgium-NL' || country == 'Belgium-FR' || country == 'France' ||
                    country == 'Switzerland-DE' || country == 'Switzerland-FR' ||
                    country == 'Austria' || country == 'Luxembourg') {
            CreditSystem__c creditSystemSettings;
            if (country == 'Germany') {
                creditSystemSettings = CreditFactoryTestUtils.generateSchufaSetting();
                customSettingsToInsert.add(CreditFactoryTestUtils.returnSolvencySettingsDE());
                customSettingsToInsert.add(CreditFactoryTestUtils.generateOrderNotificationsSettingsDE());
                customSettingsToInsert.addAll(CreditFactoryTestUtils.generateCreditFactoryCalculationsDE());
            } else if (country == 'Netherlands' || country == 'Belgium-NL' || country == 'Belgium-FR' || country == 'France') {
                if (country == 'Belgium-NL' || country == 'Belgium-FR') {
                    customSettingsToInsert.addAll(CreditFactoryTestUtils.generateCreditFactoryCalculationsBE());
                }
                else if (country == 'Netherlands') {
                    customSettingsToInsert.addAll(CreditFactoryTestUtils.generateCreditFactoryCalculationsNL());
                }
                creditSystemSettings = CreditFactoryTestUtils.generateCreditsafeSetting();
                customSettingsToInsert.add(CreditFactoryTestUtils.generateCompanyInfoSetting());
            } else if (country == 'Switzerland-DE' || country == 'Switzerland-FR') {
                creditSystemSettings = CreditFactoryTestUtils.generateCrediconnectSetting();
                customSettingsToInsert.add(CreditFactoryTestUtils.returnSolvencySettingsCH());
                customSettingsToInsert.addAll(CreditFactoryTestUtils.generateCreditFactoryCalculationsCH());
            } else if (country == 'Austria' || country == 'Luxembourg') {
                creditSystemSettings = CreditFactoryTestUtils.generateCreditreformSettings();
                if (country == 'Luxembourg') {
                    creditSystemSettings.Name = 'CreditreformLU';
                }
                customSettingsToInsert.add(CreditFactoryTestUtils.returnSolvencySettingsAT());
            }
            customSettingsToInsert.add(creditSystemSettings);
            LexisNexis_Settings__c lexisNexisSettings = CreditFactoryTestUtils.generateLexisNexisSetting();
            customSettingsToInsert.add(lexisNexisSettings);
            IBAN_API_Settings__c ibanApiSettings = new IBAN_API_Settings__c(
                    Name = country,
                    Endpoint__c = 'https://rest.sepatools.eu/validate_iban/',
                    Login__c = 'Fleetcor',
                    Password__c = 'Fleetcor2019'
            );
            customSettingsToInsert.add(ibanApiSettings);
        }
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
                Name = country,
                Abandonment_User__c = UserInfo.getUserId(),
                Test_mode__c = false,
                Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Enable_authorization_non_granted_check__c = true,
                Set_GFN_Status__c = true
        );
        customSettingsToInsert.add(e2eFormGeneralSettings);

        GFNI_Settings__c gfnSettings = new GFNI_Settings__c(
                API_version__c = '1',
                Client_system__c = 'SME',
                Culture__c = 'en-GB',
                IsForRobot__c = false,
                Name = 'GFN Integration Settings',
                Prod_endpoint__c = 'https://api.prod.endpoint',
                Test_endpoint__c = 'https://api.test.endpoint',
                Test_mode__c = true,
                test_x_ibm_client_id__c = '86b094c8-b431-44bd-8925-8909db6b34cf',
                test_x_ibm_client_secret__c = 'J0hE4tJ6wA5dK5nB3aH4fD3wX0iG5wS2uT3vG0mX7eL4rT4mE6',
                x_ibm_client_id__c = '4b4e495e-9b0f-4461-bea4-90bbfb6ea8af',
                x_ibm_client_secret__c = 'M4uT7aP5lC5vT1tG3vQ0rT7gX7lG5nO7lG3iY1mY1nD8sS5bS3'
        );
        customSettingsToInsert.add(gfnSettings);

        GFNI_General_Settings__c gfnGeneralSetting = new GFNI_General_Settings__c();
        gfnGeneralSetting.Name = 'PL';
        gfnGeneralSetting.Application_Status__c = '/applicationstatus';
        gfnGeneralSetting.Create_Customer_and_Cards__c = '/customer';
        gfnGeneralSetting.Get_Customer_Id__c = '/customerId';
        gfnGeneralSetting.IsForRobot__c = false;
        gfnGeneralSetting.Number_Of_Send_Tries__c = 3;
        gfnGeneralSetting.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        gfnGeneralSetting.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        gfnGeneralSetting.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        gfnGeneralSetting.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        gfnGeneralSetting.Support_email__c = 'test@email.com';
        gfnGeneralSetting.Test_support_email__c = 'test@test.com';
        gfnGeneralSetting.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        gfnGeneralSetting.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        gfnGeneralSetting.Test_mode__c = true;
        customSettingsToInsert.add(gfnGeneralSetting);
        insert customSettingsToInsert;
    }

    public static E2E_Data_Object__c createDataObject(Map<String, Object> dataObjectParams) {
        E2E_Data_Object__c newDataObject = new E2E_Data_Object__c();
        for (String dataObjectFieldApiName : dataObjectParams.keySet()) {
            if (dataObjectFieldApiName != 'RecordTypeName') {
                newDataObject.put(dataObjectFieldApiName, dataObjectParams.get(dataObjectFieldApiName));
            }
        }
        String recordTypeName = (String) dataObjectParams.get('RecordTypeName');
        String dataobjectRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Object__c' AND DeveloperName = :recordTypeName LIMIT 1].Id;
        newDataObject.RecordTypeId = dataobjectRecordTypeId;
        insert newDataObject;
        return newDataObject;
    }


    public static List<E2E_Data_Contact__c> createDataContacts(List<Object> dataContactsParams) {
        List<E2E_Data_Contact__c> contactsToInsert = new List<E2E_Data_Contact__c>();
        for (Object dataContactParams : dataContactsParams) {
            Map<String, Object> dataContactParamsMap = (Map<String, Object>) dataContactParams;
            E2E_Data_Contact__c newDataContact = new E2E_Data_Contact__c();
            for (String dataContactFieldApiName : dataContactParamsMap.keySet()) {
                newDataContact.put(dataContactFieldApiName, dataContactParamsMap.get(dataContactFieldApiName));
            }
            contactsToInsert.add(newDataContact);
        }
        insert contactsToInsert;
        return contactsToInsert;
    }


    public static Account createAccount(E2E_Data_Object__c dataObject) {
        Account account = new Account(
                Name = dataObject.Name,
                Type = 'Customer',
                E2E__c = true,
                BillingCountry = ETEGlobalUtils.returnCountry(dataObject.Country_Code__c),
                Sec_Channel__c = 'Inbound',
                AccountSource = 'E2E Form'
        );
        insert account;
        return account;
    }


    public static List<Contact> createContacts(List<E2E_Data_Contact__c> dataContacts, Account account) {
        List<Contact> contactsToInsert = new List<Contact>();
        for (E2E_Data_Contact__c dataContact : dataContacts) {
            contactsToInsert.add(
                new Contact(
                    AccountId = account.Id,
                    Salutation = dataContact.Salutation__c,
                    FirstName = dataContact.First_Name__c,
                    LastName = dataContact.Last_Name__c,
                    E2E__c = true,
                    Email = dataContact.Email__c,
                    Phone = dataContact.Phone__c
                )
            );
        }
        return contactsToInsert;
    }


    public static OpportunityContactRole createOpptyContactRole(String opptyId, String contactId) {
        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = opptyId,
                ContactId = contactId
        );
        return ocr;
    }


    public static Opportunity createOpportunity(E2E_Data_Object__c dataObject, Account account) {
        Opportunity newOppty = new Opportunity(
                Name = 'NEW E2E CUSTOMER',
                StageName = dataObject.StageName__c,
                E2E_Data_Object__c = dataObject.Id,
                E2E_Active_Substep__c = dataObject.Current_Step__c,
                CloseDate = Date.today(),
                Last_Owner_Change_Date__c = Datetime.now(),
                Language_preference__c = ETEGlobalUtils.returnLanguagePreference(dataObject.Country_Code__c),
                E2E_2__c = true,
                Eco_Fee__c = false,
                LeadSource = 'E2E Form',
                Direct_Debit_Mandate_Type__c = '',
                Bevollmaechtigung__c = false,
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                Product__c = '',
                CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(dataObject.Country_Code__c),
                Type = 'New Business',
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E'
        );
        if (account != null) { newOppty.AccountId = account.Id; }
        return newOppty;
    }


    public static Payment_Transaction__c createPaymentTransaction(Decimal amount, String opptyId) {
        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c(
                Name = 'test name',
                OpportunityId__c = opptyId,
                Amount__c = amount
        );
        return paymentTransaction;
    }


    public static List<E2E_Data_Product__c> createProducts(E2E_Data_Object__c dataObject, Product2 product, Offer_Item_Type__c offerItemType) {
        List<E2E_Data_Product__c> productsList = new List<E2E_Data_Product__c>();
        E2E_Data_Product__c product_1 = new E2E_Data_Product__c(
                E2E_Data_Object__c = dataObject.Id,
                Name = offerItemType.Name,
                RecordTypeId = Schema.SObjectType.E2E_Data_Product__c.getRecordTypeInfosByName().get('Product').getRecordTypeId(),
                ProductID__c = product.Id,
                Type_Name__c = offerItemType.Name,
                Type_ID__c = offerItemType.Id
        );
        productsList.add(product_1);
        insert productsList;
        return productsList;
    }


    public static List<E2E_Data_Offer_Item__c> createETEOfferItems(E2E_Data_Object__c dataObject, List<E2E_Data_Product__c> productsList) {
        List<E2E_Data_Offer_Item__c> offerItemsList = new List<E2E_Data_Offer_Item__c>();
        for (E2E_Data_Product__c product : productsList) {
            offerItemsList.add(
                new E2E_Data_Offer_Item__c(
                        E2E_Data_Product__c = product.Id,
                        Fleetcor_Offer_Item__c = null,
                        Category_Of_Products__c = '2 Category 1 plus vehicle-related goods and services (oils, car wash)',
                        Company_Name__c = dataObject.Company_Short_Name__c,
                        Driver_Name__c = 'Karta Shell 1',
                        Type_Of_Card__c = 'Multi Network Card -- National',
                        Type_Of_Vehicle__c = 'PKW',
                        Monthly_Fuel_Consumption__c = 300
                )
            );
        }
        return offerItemsList;
    }


    public static List<E2E_Data_Offer_Item__c> createOfferItems(E2E_Data_Object__c dataObject, Product2 product, Offer_Item_Type__c offerItemType) {
        List<E2E_Data_Offer_Item__c> offerItemsList = new List<E2E_Data_Offer_Item__c>();
//        E2E_Data_Offer_Item__c offerItem_1 = new E2E_Data_Offer_Item__c(
//                E2E_Data_Object__c = dataObject.Id,
//                Offer_Name__c = offerItemType.Name,
//                Fleetcor_Offer__c = product.Id,
//                Offer_Item_Type_Name__c = offerItemType.Name,
//                Offer_Item_Type_Id__c = offerItemType.Id,
//                Fleetcor_Offer_Item__c = null,
//                Category_Of_Products__c = '2 Category 1 plus vehicle-related goods and services (oils, car wash)',
//                Company_Name__c = dataObject.Company_Short_Name__c,
//                Driver_Name__c = 'Karta Shell 1',
//                Type_Of_Card__c = 'Multi Network Card -- National',
//                Type_Of_Vehicle__c = 'PKW',
//                Monthly_Fuel_Consumption__c = 300
//        );
//        offerItemsList.add(offerItem_1);
        return offerItemsList;
    }


    public static void createE2EApiKeys(String keyName) {
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = keyName,
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;
    }


    public static void prepareRequest(String requestBody, String countryCode) {
        String siteUrl = ETEGlobalUtils.returnSiteUrl(countryCode);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = siteUrl + '/services/apexrest/e2e';
        req.headers.put('Referer', siteUrl);
        req.headers.put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
    }


    public static void createStaticResource(String staticResourceName) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(staticResourceName);
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
    }


    public static void createStaticResourceForSteps () {
        createStaticResource('ETE_STEP_products_and_services');
        createStaticResource('ETE_STEP_contacts');
        createStaticResource('ETE_STEP_additional_services');
        createStaticResource('ETE_STEP_credit_line');
        createStaticResource('ETE_STEP_documents');
        createStaticResource('ETE_STEP_payment_data');
        createStaticResource('ETE_STEP_pay_deposit');
    }


    public static List<Object> getStepsFromDefaultSettings (String implKey) {
        String resourceName = new List<String>((ETEGlobalUtils.returnDefaultSettingKey(implKey)))[0];
        StaticResource def = [SELECT Body FROM StaticResource WHERE Name =: resourceName];
        Map<String, Object> defMap = (Map<String, Object>) JSON.deserializeUntyped(def.Body.toString());
        List<Object> steps = (List<Object>) JSON.deserializeUntyped(JSON.serialize(defMap.get('steps')));
        return steps;
    }


    public static void enqueueJobsForStep (String countryCode, String stepName, String dataObjectId, String implKey) {
        List<Object> steps = getStepsFromDefaultSettings(implKey);
        List<String> jobsToRunList = new List<String>();

        for (Object nextStepObj : steps) {
            Map<String, Object> nextStepMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(nextStepObj));
            if (String.valueOf(nextStepMap.get('name')) == stepName) {
                List<Object> jobsToRun = (List<Object>) JSON.deserializeUntyped(JSON.serialize(nextStepMap.get('jobs_to_run')));
                for (Object nextJobToRunObj : jobsToRun) {
                    Map<String, Object> nextJobToRunMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(nextJobToRunObj));
                    jobsToRunList.addAll(nextJobToRunMap.keySet());
                }
            }
        }

        if (jobsToRunList.size() > 0) {
            jobsToRunList.remove(0);
        }

        for (String nextJob : jobsToRunList) {
            System.enqueueJob(new ETEJobsQueue(new List<String>{nextJob}, dataObjectId, countryCode, implKey));
        }
    }


    public static void checkStatusCodeAndNextStep (String countryCode, String stepName) {
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assert(String.valueOf(responseBodyMap.get('statusCode')) == '100');
        Map<String, Object> userModel = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(responseBodyMap.get('user_model')));

        List<Object> steps = getStepsFromDefaultSettings((String) userModel.get('implKey'));
        String nextStepFromSettings;

        for (Integer i = 0; i < steps.size(); i++) {
            Object stepObj = steps.get(i);
            Map<String, Object> stepMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(stepObj));
            if (String.valueOf(stepMap.get('name')) == stepName) {
                if (steps.size() > i + 1) {
                    Object nextStepObj = steps.get(i + 1);
                    Map<String, Object> nextStepMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(nextStepObj));
                    nextStepFromSettings = String.valueOf(nextStepMap.get('name'));
                }
            }
        }

        if (nextStepFromSettings == null) {
            System.assert(String.valueOf(userModel.get('eteStatus')) == 'Finished');
        } else {
            System.assert(String.valueOf(userModel.get('eteStatus')) == 'In progress');
            System.assert(String.valueOf(userModel.get('currentStep')) == nextStepFromSettings);
        }
    }


    public static void createAdditionalServices(String productName, String country) {
        List<Additional_Service__c> additionalServicesList = new List<Additional_Service__c>();
        Additional_Service__c service_1 = new Additional_Service__c(
                Type__c = 'Paper Invoice',
                Selected_by_default__c = false,
                Integration_Name__c = 'paperinvoicepl',
                Amount__c = 14,
                Country__c = country.contains('-') ? country.substringBefore('-') : country,
                Active__c = true
        );
        additionalServicesList.add(service_1);
        insert additionalServicesList;

        Product2 prod = [SELECT Id FROM Product2 WHERE Name =: productName];
        insert new Offer_Additional_Service__c(
                Product__c = prod.Id,
                State__c = 'Optional Preselected',
                Additional_Service__c = service_1.Id
        );
    }

    public static List<ETEUserModel.Additional_Service> createAdditionalServicesFromFrontend(Boolean isEmpty){
        List<ETEUserModel.Additional_Service> result = new List<ETEUserModel.Additional_Service>();
        List<Additional_Service__c> additionalServicesList = [SELECT Integration_Name__c FROM Additional_Service__c WHERE Active__c = true];
        for(Additional_Service__c cService: additionalServicesList){
            if(!isEmpty){
                ETEUserModel.Additional_Service service = new ETEUserModel.Additional_Service();
                service.id = cService.Integration_Name__c;
                service.selected = true;
                result.add(service);
            }
        }

        return result;
    }


    public static void createDeduplicationTestData(Map<String, Map<String, Object>> dataToDeduplicationTest) {
        Account acc = new Account();
        for (String fieldApiName : dataToDeduplicationTest.get('acc').keySet()) {
            acc.put(fieldApiName, dataToDeduplicationTest.get('acc').get(fieldApiName));
        }
        insert acc;

        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        for (String fieldApiName : dataToDeduplicationTest.get('con').keySet()) {
            contact.put(fieldApiName, dataToDeduplicationTest.get('con').get(fieldApiName));
        }
        insert contact;

        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        for (String fieldApiName : dataToDeduplicationTest.get('oppty').keySet()) {
            opp.put(fieldApiName, dataToDeduplicationTest.get('oppty').get(fieldApiName));
        }
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = contact.Id;
        ocr.OpportunityId = opp.Id;
        for (String fieldApiName : dataToDeduplicationTest.get('ocr').keySet()) {
            ocr.put(fieldApiName, dataToDeduplicationTest.get('ocr').get(fieldApiName));
        }
        insert ocr;
    }
}
