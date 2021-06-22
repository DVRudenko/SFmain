@isTest
public with sharing class E2EFormRuServiceImplTest {
    @isTest
    public static void testAccountService() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuDataTestFactory.initPagesStructure();

        E2EFormRuService formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // create account
        Id accountId = formService.createAccount(formParams);
        System.assertNotEquals(null, accountId);

        //****** update account step: CompanyInformation ******//
        Test.startTest();
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Test.stopTest();
        Account accountFirst = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(
            pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value.toUpperCase(),
            accountFirst.Name
        );
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value, accountFirst.INN__c);
        System.assertEquals(formParams.postCodeSpark, accountFirst.BillingPostalCode);
        System.assertEquals(formParams.citySpark.toUpperCase(), accountFirst.BillingCity);
        System.assertEquals(formParams.regionSpark, accountFirst.Region__c);

        //****** update account step: LegalDetails ******//
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.LegalDetails.name());

        Account accountSecond = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value,
            accountSecond.OGRN_ppr__c
        );
        System.assertEquals(
            Decimal.valueOf(pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').value),
            accountSecond.KPP__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value,
            accountSecond.OKPO_ppr__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value,
            accountSecond.Code_Word__c
        );

        // check legal address
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').value,
            accountSecond.BillingCountry
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').value.toUpperCase(),
            accountSecond.BillingCity
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').value.toUpperCase(),
            accountSecond.BillingPostalCode
        );
        String legalAddressStreet =
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').value +
            ' ' +
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value +
            ' ' +
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
        System.assertEquals(legalAddressStreet.trim().toUpperCase(), accountSecond.BillingStreet);

        // check postal address
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').value,
            accountSecond.ShippingCountry
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').value.toUpperCase(),
            accountSecond.ShippingCity
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').value,
            accountSecond.ShippingPostalCode
        );
        String postalAddressStreet =
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').value +
            ' ' +
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').value +
            ' ' +
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').value;
        System.assertEquals(postalAddressStreet.trim().toUpperCase(), accountSecond.ShippingStreet);

        //****** update account step: PaymentDetails ******//
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.PaymentDetails.name());
        Account accountThird = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value,
            accountThird.Checking_Account__c
        );
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value,
            accountThird.Bank__c
        );
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value,
            accountThird.SWIFT_BIC__c
        );
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value,
            accountThird.Cor_Bank_Account__c
        );

        //****** check get account by id *****//
        Account accountTest = formService.getAccountById(accountId);
        System.assertEquals(accountId, accountTest.Id);
    }

    @isTest
    public static void testContactService() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuDataTestFactory.initPagesStructure();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        //***** test to create contact *****//
        Id contactId = formService.createContact(accountId, pagesMap, formParams, GlobalUtils.BusinessProcessType.E2EClassic);
        System.assertNotEquals(null, contactId);
        Id contactIdBusiness = formService.createContact(accountId, null, formParams, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertNotEquals(null, contactIdBusiness);

        //***** test to update contact step: ContactDetails *****//
        formService.updateContact(contactId, pagesMap, formParams, GlobalUtils.E2ERuSteps.ContactDetails.name());
        Contact contactFirst = E2EFormRuTestUtils.getContactById(contactId);
        //System.assertEquals(formService.convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value), contactFirst.MobilePhone);
        System.assertEquals(
            formService.convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value),
            contactFirst.Phone
        );
        System.assertEquals(
            pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value,
            contactFirst.Email
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value),
            contactFirst.Agree_to_receive_comm_info_by_email__c
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value),
            contactFirst.Agree_to_process_pers_data_for_marketing__c
        );

        //***** test to update contact step: CompanyInformation *****//
        formService.updateContact(contactId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Contact contactSecond = E2EFormRuTestUtils.getContactById(contactId);
        System.assert(contactSecond.LastName.lastIndexOf('E2E') != -1);

        //***** test to create employee contact *****//
        Id employeeContactId = formService.createEmployeeContact(
            accountId,
            'Ivanov Ivan Ivanovich',
            'Decision Maker',
            GlobalUtils.BusinessProcessType.E2EClassic.name()
        );
        Contact employeeContact = E2EFormRuTestUtils.getContactById(employeeContactId);
        System.assertEquals('Ivanov Ivan Ivanovich', employeeContact.LastName);
        System.assertEquals('Decision Maker', employeeContact.Title);

        //***** test to update employee contact *****//
        formService.updateEmployeeContact(
            employeeContactId,
            'Petrov Petr Petrovich',
            'Accounting (for invoices)',
            GlobalUtils.BusinessProcessType.E2EBusiness.name()
        );
        Contact contactThird = E2EFormRuTestUtils.getContactById(employeeContactId);
        System.assertEquals('Petrov Petr Petrovich', contactThird.LastName);
        System.assertEquals('Accounting (for invoices)', contactThird.Title);

        //***** test to update contact phone *****//
        formService.updateContactPhone(employeeContactId, '+79237212121');
        Contact contactFourth = E2EFormRuTestUtils.getContactById(employeeContactId);
        //System.assertEquals('9237212121', contactFourth.MobilePhone);
        System.assertEquals('+7 9237212121', contactFourth.Phone);

        //***** test to get contact by id *****//
        Contact existingContact = formService.getContactById(employeeContactId);
        System.assertNotEquals(null, existingContact);
    }

    @IsTest
    private static void updateProfileEmailForContactTest() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuService formService = new E2EFormRuServiceImpl();
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();

        contact.Email = 'base@email.ru';
        contact.Additional_Emails__c = 'additional1@email.ru:additional2@email.ru';
        insert contact;
        formData.E2E_Contact_Email__c = contact.Email;
        formData.E2E_Personal_Office_Email__c = 'additional1@email.ru';
        insert formData;
        formService.updateProfileEmailForContact(contact.Id, formData.Id, 'additional3@email.ru');
        String result = ([
                SELECT Additional_Emails__c
                FROM Contact
                WHERE Id = :contact.Id
        ]).get(0).Additional_Emails__c;
        System.assert(result.contains('additional2@email.ru'));
        System.assert(result.contains('additional3@email.ru'));

        contact.Email = 'base@email.ru';
        contact.Additional_Emails__c = 'additional1@email.ru:additional2@email.ru';
        update contact;
        formData.E2E_Contact_Email__c = contact.Email;
        formData.E2E_Personal_Office_Email__c = 'additional1@email.ru';
        update formData;
        formService.updateProfileEmailForContact(contact.Id, formData.Id, 'base@email.ru');
        result = ([
                SELECT Additional_Emails__c
                FROM Contact
                WHERE Id = :contact.Id
        ]).get(0).Additional_Emails__c;
        System.assert(result.contains('additional1@email.ru'));
        System.assert(result.contains('additional2@email.ru'));

        contact.Email = 'base@email.ru';
        contact.Additional_Emails__c = '';
        update contact;
        formData.E2E_Contact_Email__c = contact.Email;
        formData.E2E_Personal_Office_Email__c = '';
        update formData;
        formService.updateProfileEmailForContact(contact.Id, formData.Id, 'additional@email.ru');
        result = ([
                SELECT Additional_Emails__c
                FROM Contact
                WHERE Id = :contact.Id
        ]).get(0).Additional_Emails__c;
        System.assert(result.contains('additional@email.ru'));
    }

    @isTest
    public static void testOpportunityService() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        //***** test to create opportunity *****//
        Id opportunityId = formService.createOpportunity(accountId, formParams);
        System.assertNotEquals(null, opportunityId);

        //***** test to update opportunity step: CompanyInformation *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Opportunity opportunityFirst = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals(
            pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value.toUpperCase(),
            opportunityFirst.Name
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').value),
            opportunityFirst.Manual_Entry__c
        );
        System.assertEquals(formParams.scoringDate, opportunityFirst.Scoring_Date__c);
        System.assertEquals('Отклонен', opportunityFirst.E2E_Sales_Type__c);
        System.assertEquals('Чёрный список', opportunityFirst.E2E_Sub_Status__c);

        //***** test to update opportunity step: Order *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.Order.name());
        Opportunity opportunitySecond = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals('Вездеход Online "Оптимальный" Карты', opportunitySecond.Product_PPR__c);
        System.assertEquals(
            pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value,
            opportunitySecond.Promo_campaign__c
        );
        System.assertEquals(
            Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value),
            opportunitySecond.Number_of_Cards__c
        );
        System.assertEquals('Agreement Terms and Conditions', opportunitySecond.StageName);

        //***** test to update opportunity step: PaymentDetails *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.PaymentDetails.name());
        Opportunity opportunityThird = E2EFormRuTestUtils.getOpportunityById(opportunityId);

        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.LegalDetails.name());
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(accountId);
        insert opportunity;
        System.assertEquals(
                pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT PHONE').elementItemsMap.get('DEFAULT VALUE').value,
                opportunity.Personal_office_phone__c
        );

        //***** test to update opportunity step: Congratulations *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.Congratulations.name());
        Opportunity opportunityFourth = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals('Клиент завершил', opportunityFourth.E2E_Status__c);

        //***** test forceUpdateOpportunity *****//
        formService.forceUpdateOpportunity(opportunityId, 'Error');
        Opportunity opportunityFifth = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals('Перевод в ручную обработку', opportunityFifth.E2E_Sub_Status__c);
        System.assertEquals('Клиент завершил', opportunityFifth.E2E_Status__c);
        System.assertEquals('Error', opportunityFifth.E2E_Errors__c);
    }

    @isTest
    public static void testOpportunityContactRoleService() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init opportunity and account
        Opportunity opportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createDefaultOpportunity());

        Id accountId = opportunity.AccountId;
        Id opportunityId = opportunity.Id;
        Id contactId = formService.createEmployeeContact(accountId, 'главный во всем', 'крыша', GlobalUtils.BusinessProcessType.E2EBusiness.name());

        //***** test to create opportunityContactRole *****//
        //        formService.createOpportunityContactRoles(opportunityId, accountId, pagesMap, GlobalUtils.E2ERuSteps.LegalDetails.name());
        //        //TODO: Дописать тест на проверку созданного контакта

        formService.createOpportunityContactRole(opportunityId, contactId, 'Decision Maker', false);
        OpportunityContactRole role = ([
            SELECT Id, Role, IsPrimary
            FROM OpportunityContactRole
            WHERE ContactId = :contactId AND OpportunityId = :opportunityId
            LIMIT 1
        ]);
        System.assertEquals('Decision Maker', role.Role);
        System.assertEquals(false, role.IsPrimary);

        //***** test markPrimaryAndAdditionalContactRole *****//
        List<OpportunityContactRole> opportunityContactRoles = ([
            SELECT Id, IsPrimary, Role
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunityId
        ]);
        Map<String, OpportunityContactRole> maOpportunityContactRolesByStrings = formService.markPrimaryAndAdditionalContactRole(
            opportunityContactRoles
        );
        System.assertNotEquals(null, maOpportunityContactRolesByStrings);
    }

    @isTest
    public static void testFormDataService() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        //***** test to create FormDataRecord *****//
        Id formDataId = formService.createFormDataRecord(accountId, contactId, opportunityId, pagesMap, formParams);
        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(formParams.ipAddress, formDataRecord.E2E_IP_Address__c);
        System.assertEquals(
            pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecord.E2E_Contact_Phone__c
        );
        System.assertEquals(
            pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecord.E2E_Contact_Email__c
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value),
            formDataRecord.E2E_Send_Marketing_Email__c
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value),
            formDataRecord.E2E_Process_Personal_Data__c
        );
        System.assertEquals(GlobalUtils.E2ERuSteps.ContactDetails.name(), formDataRecord.E2E_Last_Step__c);

        //***** test to create FormDataRecord step: ContactDetails *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.ContactDetails.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordFirst = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(
            pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFirst.E2E_Contact_Phone__c
        );
        System.assertEquals(
            pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFirst.E2E_Contact_Email__c
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').value),
            formDataRecordFirst.E2E_Send_Marketing_Email__c
        );
        System.assertEquals(
            Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').value),
            formDataRecordFirst.E2E_Process_Personal_Data__c
        );
        System.assertEquals(accountId, formDataRecordFirst.E2E_Account_Id__c);
        System.assertEquals(contactId, formDataRecordFirst.E2E_Contact_Id__c);
        System.assertEquals(opportunityId, formDataRecordFirst.E2E_Opportunity_Id__c);

        //***** test to create FormDataRecord step: CompanyInformation *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordSecond = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(
            pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordSecond.E2E_Account_Name__c
        );
        System.assertEquals(
            pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordSecond.E2E_INN__c
        );
        // TODO: дописать проверку остальных полей

        //***** test to create FormDataRecord step: CompanyInformation *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.Order.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordThird = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value, formDataRecordThird.E2E_Product_Id__c);
        System.assertEquals(
            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').value,
            formDataRecordThird.E2E_Tariff_Id__c
        );
        System.assertEquals(
            Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').value),
            formDataRecordThird.E2E_Num_Cards__c
        );
        System.assertEquals(
            pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordThird.E2E_Promo_Campaign__c
        );
        // TODO: дописать проверку остальных полей

        //***** test to create FormDataRecord step: LegalDetails *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.LegalDetails.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordFourth = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFourth.E2E_OKPO__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFourth.E2E_Legal_Address__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFourth.E2E_Post_Address__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFourth.E2E_Code_Word__c
        );
        // TODO: дописать проверку остальных полей

        //***** test to create FormDataRecord step: PaymentDetails *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.PaymentDetails.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordFifth = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFifth.E2E_Checking_Account__c
        );
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFifth.E2E_Bank__c
        );
        System.assertEquals(
            pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').value,
            formDataRecordFifth.E2E_BIC__c
        );
        // TODO: дописать проверку остальных полей

        //***** test to update form data for PPR API *****//
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Source__c = 'old source';
        formData.E2E_Process_Status__c = 'status';
        formData.Last_deduplication_time__c = Datetime.now().addDays(-5);
        formData.E2E_Scoring_Date__c = Date.today().addDays(-5);
        insert formData;

        E2EFormParams e2EFormParams = new E2EFormParams();
        e2EFormParams.formDataId = formData.Id;
        e2EFormParams.companyInn = '1234567890';
        e2EFormParams.source = 'source';
        e2EFormParams.deduplicationDatetime = Datetime.now();
        formService.updateFormData(e2EFormParams);

        formData = formService.getFormDataById(formData.Id);
        System.assertEquals('e2etest@e2etest.ru', formData.E2E_Contact_Email__c);
        System.assertEquals('source', formData.E2E_Source__c);
        System.assertEquals('status', formData.E2E_Process_Status__c);
        System.assertEquals('1234567890', formData.E2E_INN__c);
        System.assertEquals(Datetime.now().date(), formData.Last_deduplication_time__c.date());
        System.assertEquals(Date.today().addDays(-5), formData.E2E_Scoring_Date__c);
    }

    //****** Test Deduplication Service

    public static List<Id> initDefaultE2EObjects() {
        List<Id> sobjectIds = new List<Id>();
        // init default e2e objects
        Id e2eAccountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, e2eAccountId);
        sobjectIds.add(e2eAccountId);

        Id e2eOpportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(e2eAccountId)).Id;
        System.assertNotEquals(null, e2eOpportunityId);
        sobjectIds.add(e2eOpportunityId);

        Id e2eContactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(e2eAccountId)).Id;
        System.assertNotEquals(null, e2eContactId);
        sobjectIds.add(e2eContactId);

        Id e2eFormDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormData(e2eAccountId, e2eContactId, e2eOpportunityId)).Id;
        System.assertNotEquals(null, e2eFormDataId);
        sobjectIds.add(e2eFormDataId);

        return sobjectIds;
    }

    @isTest // Тест для перехода в E2E, найден Account по INN
    public static void testDeduplicationGoToE2EProcessCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Qualified Lead', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в E2E, найден Account по INN, но ушел по статусам Opportunity
    public static void testDuplicateGoToE2EPrecessCase2() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Отказ', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в E2EProcess, найден дубль по домену email. Отправлен в E2EProcess по Opportunity
    public static void testDuplicateGoToE2EPrecessCase3() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount('222222222', null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Отказ', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, 'test1@domovoi.ru')
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
        }
    }

    //******* Test: go to Inbound process ******//

    @isTest // Тест для перехода в Inbound, найден Account по INN, но ушел в Inbound по статусам Opportunity
    public static void testDuplicateGoToInboundCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Check Credit History', Date.today(), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Договор на проверке', Date.today(), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.Inbound.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в Inbound, найден Account по Contact, но ушел в Inbound по статусам Opportunity
    public static void testDuplicateGoToInboundCase2() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount('3333333333', null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Check Credit History', Date.today(), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Договор на проверке', Date.today(), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.Inbound.name(), result.statusCode);
        }
    }

    //******* Test: go to KO ******//

    @isTest // Тест для перехода в KO, найден Account по INN, но ушел в KO по Opportunity.StageName == 'Договор на проверке' and Opportunity.CloseDate >= 5
    public static void testDuplicateGoToKOCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Договор на проверке', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.KO.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в KO, найден Account по INN, но ушел в KO по Opportunity.StageName == 'Договор на проверке' and Opportunity.CloseDate >= 5
    public static void testDuplicateGoToKOCase2() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.KO.name(), result.statusCode);
        }
    }

    @isTest // Тест переход в Сервис, найден Account по INN
    public static void testDeduplicationGoToServiceCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today(), owner)
            );
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today(), owner)
            );
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(
                E2EFormRuDataTestFactory.INN,
                E2EFormRuDataTestFactory.email,
                e2eAccountId,
                e2eContactId,
                e2eOpportunityId,
                e2eFormDataId
            );
            System.assertEquals(GlobalUtils.DeduplicationStatus.Service.name(), result.statusCode);
        }
    }

    //******* Test: convert to Service ******//

    @isTest
    public static void testConvertClientToServiceInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Moved to Start', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();

            Test.startTest();
            formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(deduplicationResult.e2eOpportunity.Id);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            System.assertEquals('Существующий клиент', resultOpportunity.PPR_Lost_Reasons__c);
            // TODO: Добавить проверку смены владельца
        }
    }

    @isTest
    public static void testConvertClientToService() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
            deduplicationResult.innDuplication = false;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Moved to Start', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();

            Test.startTest();
            formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(deduplicationResult.e2eOpportunity.Id);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: convert to Inbound ******//

    @isTest
    public static void testConvertClientToInboundInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Inbound.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            formService.transferCustomer(deduplicationResult);

            System.assertEquals('Qualified Lead', deduplicationResult.e2eOpportunity.StageName);
            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: convert to KO ******//

    @isTest
    public static void testConvertClientToKOInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects

            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            Test.startTest();
            formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(deduplicationResult.e2eOpportunity.Id);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            System.assertEquals('Возврат в Воронку', resultOpportunity.PPR_Lost_Reasons__c);
            // TODO: Добавить проверку смены владельца
        }
    }

    @isTest
    public static void testConvertClientToKO() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
            deduplicationResult.innDuplication = false;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            Test.startTest();
            formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            System.assertEquals('Возврат в Воронку', resultOpportunity.PPR_Lost_Reasons__c);
            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: convert to E2E ******//

    @isTest
    public static void testConvertClientToE2EInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            Test.startTest();
            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            formService.transferCustomer(deduplicationResult);
            Test.stopTest();
            // TODO: Добавить проверку смены владельца
        }
    }

    @isTest
    public static void testConvertClientToE2E() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            insert CFUtilsTest.createCFSettingsForRussia(false);
            E2EFormRuTestUtils.initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            deduplicationResult.innDuplication = false;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(
                E2EFormRuTestUtils.createAccount(E2EFormRuDataTestFactory.INN, null, null)
            );
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(
                E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner)
            );
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(
                E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, E2EFormRuDataTestFactory.phone, E2EFormRuDataTestFactory.email)
            );
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            formService.transferCustomer(deduplicationResult);

            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: prepare Transit request ******//

    @isTest
    public static void testPrepareTransitRequest() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        formParams.registrationDateSpark = Date.today().format();
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        formParams.isSoleProprietor = false;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(accountId);
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(opportunity).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        formParams.freeOverdraft = true;
        E2EFormData__c formData = E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus');
        formData.Free_overdraft__c = true;
        Id formDataId = E2EFormRuTestUtils.insertFormData(formData).Id;
        System.assertNotEquals(null, formDataId);

        //  Prepare request for Legal Person
        E2E_Form_Transit_Settings__c transitSettings = E2E_Form_Transit_Settings__c.getValues('E2EFormRu');
        TransitRequestData transitRequestDataLegalPerson = formService.prepareTransitRequestData(
            formDataId,
            formParams,
            pagesMap,
            GlobalUtils.BusinessProcessType.E2EClassic
        );
        System.assertEquals(
            String.format('{0}-{1}', new List<String>{ formParams.contractPrefix, formParams.contractCounter }),
            transitRequestDataLegalPerson.cont.contractNumber
        );
        System.assertEquals('"' + formData.E2E_Account_Short_Name__c + '"', transitRequestDataLegalPerson.cont.companyName);
        System.assertEquals(
            formParams.normName.substring(formParams.normName.lastIndexOf(',') + 1).trim(),
            transitRequestDataLegalPerson.cont.companyType
        );
        System.assertEquals(formParams.ogrnSpark, transitRequestDataLegalPerson.cont.ogrn);
        System.assertEquals('43523456456', transitRequestDataLegalPerson.cont.kpp);
        System.assertEquals(null, transitRequestDataLegalPerson.cont.factProsrochki);
        System.assertEquals(null, transitRequestDataLegalPerson.cont.tipPeni);
        System.assertEquals(null, transitRequestDataLegalPerson.cont.znacheniePeni);
        System.assertEquals(null, transitRequestDataLegalPerson.cont.procentPoCreditu);
        System.assertEquals(2, transitRequestDataLegalPerson.cont.tipCredita);
        System.assertEquals(2, transitRequestDataLegalPerson.cont.contractType);
        System.assertEquals(3, transitRequestDataLegalPerson.cont.dueDate);
        System.assertEquals(transitSettings.Allowed_Debt_Sum__c, transitRequestDataLegalPerson.cont.dopustimayaZadolzenostSumma);
        System.assertEquals(transitSettings.Overdraft_Value__c, transitRequestDataLegalPerson.cont.znachenieOvedrafta);
        System.assertEquals(transitSettings.Overdraft_Sum__c, transitRequestDataLegalPerson.cont.overdrSumm);
        System.assertEquals(opportunity.Personal_office_phone__c, transitRequestDataLegalPerson.cont.persOfficePhone);

        if (Boolean.valueOf(CFUtils.getScoringSettings('active'))) {
            //System.assertEquals(1, [SELECT Id FROM Credit_Factory_Report__c WHERE Opportunity__c = :formParams.opportunityId].size());
            System.assert(transitRequestDataLegalPerson.contMonitoring != null);
            System.assert(transitRequestDataLegalPerson.contMonitoring.notificationSent != null);
            System.assert(transitRequestDataLegalPerson.contMonitoring.sourceOfLead != null);
            System.assert(transitRequestDataLegalPerson.contMonitoring.newLegal != null);
            System.assert(transitRequestDataLegalPerson.contMonitoring.firstBill != null);
            System.assert(transitRequestDataLegalPerson.contMonitoring.differentPostAddress != null);
        }
        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testPrepareTransitRequestSoleProprietor() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        formParams.registrationDateSpark = Date.today().format();
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        formParams.isSoleProprietor = true;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(accountId);
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(opportunity).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        Boolean addScoringEnabled = Boolean.valueOf(CFUtils.getScoringSettings('active'));
        if (addScoringEnabled) {
            Credit_Factory_Report__c report = CFTestDataFactory.createFRAUDReport(true);
            report.Opportunity__c = opportunityId;
            insert report;
        }

        // for EDM info
        List<StaticResource> edmSRList = [SELECT Body FROM StaticResource WHERE Name = :E2EFormRuServiceImplHelper.EDM_RESOURCE_NAME LIMIT 1];
        String edmTransitvalue = '';

        Boolean edmResourceExist = edmSRList != null && !edmSRList.isEmpty();

        if (edmResourceExist) {
            Map<String, Object> resourceNames = (Map<String, Object>) ((Map<String, Object>) JSON.deserializeUntyped(
                (edmSRList.get(0)).Body.toString()
            ));
            List<String> keys = new List<String>(resourceNames.keySet());
            edmTransitvalue = (String) resourceNames.get(keys.get(0));
            formParams.electronicDocumentManagement = keys.get(0);
        }

        // Prepare request for Sole Proprietor
        TransitRequestData transitRequestDataForSoleProprietor = formService.prepareTransitRequestData(
            formDataId,
            formParams,
            pagesMap,
            GlobalUtils.BusinessProcessType.E2EClassic
        );
        System.assertEquals(
            String.format('{0}-{1}', new List<String>{ formParams.contractPrefix, formParams.contractCounter }),
            transitRequestDataForSoleProprietor.cont.contractNumber
        );
        System.assertEquals(formParams.mainCompanyFullNameSpark.removeStart('ИП '), transitRequestDataForSoleProprietor.cont.companyName);
        System.assertEquals('ИП', transitRequestDataForSoleProprietor.cont.companyType);
        System.assertEquals(formParams.ogrnipSpark, transitRequestDataForSoleProprietor.cont.ogrn);
        System.assertEquals(opportunity.Personal_office_phone__c, transitRequestDataForSoleProprietor.cont.persOfficePhone);

        if (addScoringEnabled) {
            System.assert(transitRequestDataForSoleProprietor.contMonitoring != null);
            System.assert(transitRequestDataForSoleProprietor.contMonitoring.notificationSent != null);
            System.assert(transitRequestDataForSoleProprietor.contMonitoring.sourceOfLead != null);
            System.assert(transitRequestDataForSoleProprietor.contMonitoring.newLegal != null);
            System.assert(transitRequestDataForSoleProprietor.contMonitoring.firstBill != null);
            System.assert(transitRequestDataForSoleProprietor.contMonitoring.differentPostAddress != null);
        }
        if (edmResourceExist) {
            System.assertEquals(edmTransitvalue, transitRequestDataForSoleProprietor.edmInfo.electronicDocumentManagement);
            System.assertEquals(1, transitRequestDataForSoleProprietor.edmInfo.docSigned);
        }
        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testPrepareTransitRequestSoleProprietorPPR_API() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();
        PPR_API_Settings__c pprApiSetting = PPR_API_DataTestFactory.createPPR_API_Settings();
        insert pprApiSetting;

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        formParams.isSoleProprietor = true;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(accountId);
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(opportunity).Id;
        Opportunity opp = new Opportunity(Id = opportunityId);
        opp.Source_PP__c = 'europlan';
        update opp;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'europlan')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        formParams.overdraftSum = '1000';
        // Prepare request for Sole Proprietor
        TransitRequestData transitRequestDataForSoleProprietor = formService.prepareTransitRequestData(
            formDataId,
            formParams,
            pagesMap,
            GlobalUtils.BusinessProcessType.PPR_API
        );

        System.assertEquals(-1000, transitRequestDataForSoleProprietor.cont.overdrSumm);
        System.assertEquals(14, transitRequestDataForSoleProprietor.cont.tipCredita);
        System.assertEquals(14, transitRequestDataForSoleProprietor.cont.contractType);
        System.assertEquals(3, transitRequestDataForSoleProprietor.cont.dueDate);
        System.assertEquals('europlan', transitRequestDataForSoleProprietor.cont.partnerGuarantor);
        System.assertEquals(opportunity.Personal_office_phone__c, transitRequestDataForSoleProprietor.cont.persOfficePhone);
    }

    @isTest
    public static void testPrepareTransitRequest_SoleProprietorBusiness() {
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();

        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        formParams.isSoleProprietor = true;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(accountId);
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(opportunity).Id;
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;

        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(
            new Account(Id = accountId),
            new Opportunity(Id = opportunityId)
        );
        report.RU_Scoring_Credit_Period__c = 20000;
        report.RU_Scoring_Payment_Time_Limit__c = 20;
        report.Credit_Limit__c = '10000';
        report.RU_Application_Blocked__c = false;
        report.RU_Client_Choice__c = true;
        insert report;

        TransitRequestData transitRequestData = formService.prepareTransitRequestData(
            formDataId,
            formParams,
            pagesMap,
            GlobalUtils.BusinessProcessType.E2EBusiness
        );

        System.assertEquals(null, transitRequestData.cont.contractType);
        System.assertEquals(20, transitRequestData.cont.dueDate);
        System.assertEquals(10000, transitRequestData.cont.dopustimayaZadolzenostSumma);
        System.assertEquals(-10000, transitRequestData.cont.overdrSumm);
        System.assertEquals(null, transitRequestData.cont.invoiceDueDate);
        System.assertEquals(opportunity.Personal_office_phone__c, transitRequestData.cont.persOfficePhone);

        Transit_Contract_Type_Mapping__c transitContractTypeMapping = E2EFormRuDataTestFactory.createTransitContractTypeMapping(30, 2);
        insert transitContractTypeMapping;
        report.RU_Scoring_Credit_Period__c = 30;
        update report;

        transitRequestData = formService.prepareTransitRequestData(formDataId, formParams, pagesMap, GlobalUtils.BusinessProcessType.E2EBusiness);

        System.assertEquals(2, transitRequestData.cont.contractType);
        System.assertEquals(20, transitRequestData.cont.invoiceDueDate);
        System.assertEquals(opportunity.Personal_office_phone__c, transitRequestData.cont.persOfficePhone);
    }

    @isTest
    public static void testPreparePersonalFio() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        TransitRequestData.Personal transitPersonalRequestData = new TransitRequestData.Personal();

        formService.preparePersonalFio(transitPersonalRequestData, 'Иванов Иван Иванович');
        System.assertEquals('Иван', transitPersonalRequestData.name);
        System.assertEquals('Иванов', transitPersonalRequestData.surname);
        System.assertEquals('Иванович', transitPersonalRequestData.parentName);

        formService.preparePersonalFio(transitPersonalRequestData, 'Иванов Иван');
        System.assertEquals('Иван', transitPersonalRequestData.name);
        System.assertEquals('Иванов', transitPersonalRequestData.surname);
        System.assertEquals(' ', transitPersonalRequestData.parentName);

        formService.preparePersonalFio(transitPersonalRequestData, 'Иванов');
        System.assertEquals(' ', transitPersonalRequestData.name);
        System.assertEquals(' ', transitPersonalRequestData.surname);
        System.assertEquals(' ', transitPersonalRequestData.parentName);

        formService.preparePersonalFio(transitPersonalRequestData, null);
        System.assertEquals(' ', transitPersonalRequestData.name);
        System.assertEquals(' ', transitPersonalRequestData.surname);
        System.assertEquals(' ', transitPersonalRequestData.parentName);
    }

    //******* Test: prepare MZK request ******//

    @isTest
    public static void testPrepareMZKRequest() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        formParams.virtualCards = true;
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        Test.startTest();
        MZKRequest mzkRequest = formService.prepareMzkRequest(formDataId, formParams);
        Test.stopTest();

        //        System.assertEquals(1, mzkRequest.Cards.virtualCards);

        E2E_Form_MZK_Settings__c mzkSettings = E2E_Form_MZK_Settings__c.getValues('E2EFormRu');
        System.assertEquals('e2e', mzkRequest.Cards.cardDescr);
        System.assertEquals(mzkSettings.Service_Groups__c, mzkRequest.Cards.serviceGroups);

        Map<String, Object> product = PPRProductSettingsUtils.getProductSettings(
            pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').value
        );
        System.assertEquals(Integer.valueOf(product.get('mzkId')), mzkRequest.Cards.productId);
        // TODO: Добавить проверку остальных полей
    }

    //******* Test: prepare Crm request ******//

    @isTest
    public static void testPrepareCrmRequest() {
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        String transitId = '344444222221111';
        String phone = '83234234234';
        String email = 'test@test.ru';
        String inn = '11111111111';
        CrmTask crmTask = formService.prepareCrmRequest(phone, email, inn, new List<Opportunity>{ new Opportunity(Transit_ID__c = transitId) });
        System.assertEquals(
            String.format('Тел: {0}; e-mail: {1}; ИНН: {2}; ', new List<String>{ phone, email, inn }) +
            'CONT_IDS: ' +
            transitId,
            crmTask.Description
        );
    }

    //******* Test: prepare Report request ******//

    @isTest
    public static void testPrepareReportRequest_Company() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        E2EFormData__c formData = E2EFormRuTestUtils.insertFormData(
            E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
        );
        System.assertNotEquals(null, formData);

        Test.startTest();
        formParams.personalOfficePhone = '777';
        formParams.emailForPersonalOffice = 'test@test.com';
        ReportRequestData reportRequestData = formService.prepareReportRequestData(
            formData.Id,
            formParams,
            pagesMap,
            false,
            GlobalUtils.BusinessProcessType.E2EClassic
        );
        Test.stopTest();
        System.assertEquals(GlobalUtils.createOrganiozationName(formParams.normName), reportRequestData.companyName);
        System.assertEquals(formData.E2E_INN__c, reportRequestData.inn);

        pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '111111111111';
        reportRequestData = formService.prepareReportRequestData(
            formData.Id,
            formParams,
            pagesMap,
            false,
            GlobalUtils.BusinessProcessType.E2EClassic
        );

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testPrepareReportRequest_SoleProprietor() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        formParams.isSoleProprietor = true;
        E2EFormRuDataTestFactory.initContentMap(pagesMap);
        pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value = '111111111111';

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        E2EFormData__c formData = E2EFormRuTestUtils.insertFormData(
            E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
        );
        System.assertNotEquals(null, formData);

        Test.startTest();
        formParams.personalOfficePhone = '777';
        formParams.emailForPersonalOffice = 'test@test.com';
        ReportRequestData reportRequestData = formService.prepareReportRequestData(
            formData.Id,
            formParams,
            pagesMap,
            false,
            GlobalUtils.BusinessProcessType.E2EClassic
        );
        Test.stopTest();
        Account accFromDB = [SELECT Name FROM Account WHERE Id = :account.Id];
        System.assertEquals(accFromDB.Name, reportRequestData.companyName);
        System.assertEquals(formData.E2E_INN__c, reportRequestData.inn);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testCollectContent() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuDataTestFactory.initPagesStructure();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.ContactDetails.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('CONTACT DETAILS'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.CompanyInformation.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('COMPANY INFORMATION'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.Order.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('ORDER'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.LegalDetails.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('LEGAL DETAILS'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.PaymentDetails.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('PAYMENT DETAILS'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
    }

    @isTest
    public static void testCollectContentByLink() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        Map<String, LongFormTariff> msl_suffix = new Map<String, LongFormTariff>();
        Map<String, String> objectIds = new Map<String, String>();

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.ContactDetails.name(), pagesMap, formParams, msl_suffix, objectIds);

        formService.collectContentDataByLink(
            formDataId,
            GlobalUtils.E2ERuSteps.CompanyInformation.name(),
            pagesMap,
            formParams,
            msl_suffix,
            objectIds
        );

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.Order.name(), pagesMap, formParams, msl_suffix, objectIds);
        System.assertEquals(false, msl_suffix.containsKey('1OPTIMAL_CARDS'));

        E2EFormData__c formdataRecord = new E2EFormData__c(Id = formDataId);
        formdataRecord.E2E_Num_Cards__c = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards_Card__c);
        update formdataRecord;

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.Order.name(), pagesMap, formParams, msl_suffix, objectIds);
        System.assertEquals(true, msl_suffix.containsKey('1OPTIMAL_CONTRACT'));

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.LegalDetails.name(), pagesMap, formParams, msl_suffix, objectIds);

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.PaymentDetails.name(), pagesMap, formParams, msl_suffix, objectIds);
    }

    //***** Remote Action *****//

    @isTest
    public static void testUpdateSoleProprietorInfoFromSpark() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        formParams.emptySparkOkpo = true;
        formService.updateSoleProprietorInfoFromSpark(formParams, formDataId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_OGRN__c == formParams.ogrnipSpark);
        System.assert(formDataRecord.E2E_OKPO__c == formParams.okpoSpark);
        System.assert(formDataRecord.E2E_Empty_SPARK_OKPO__c);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testUpdateCompanyInformationFromSpark() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        formParams.emptySparkOkpo = true;
        formService.updateCompanyInformationFromSpark(formParams, formDataId, opportunityId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_Reg_Date__c == formParams.registrationDateSpark);
        System.assert(formDataRecord.E2E_OGRN__c == formParams.ogrnSpark);
        System.assert(formDataRecord.E2E_Empty_SPARK_OKPO__c);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testUpdateVerifiedDecision() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        formService.updateVerifiedDecision(formParams, formDataId, opportunityId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_Black_List_Code__c == formParams.verifiedDecisionCode);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testUpdateScoringDecision() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')
            )
            .Id;
        System.assertNotEquals(null, formDataId);

        formService.updateScoringDecision(formParams, formDataId, opportunityId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_Scoring_Decision_Code__c == formParams.scoringDecisionCode);
        System.assert(formDataRecord.E2E_Scoring_Decision__c == formParams.scoringDecision);

        // TODO: добавить проверку остальных полей
    }

    @IsTest(SeeAllData=true)
    public static void getSummaryMailInfoTestGuestUser() {
        try {
            User guest = ([SELECT Id, Name FROM User WHERE Name = 'E2E RU Site Guest User']);
            System.runAs(guest) {
                EmailTemplate summaryEmail = [SELECT Id, HTMLValue, Name, Subject FROM EmailTemplate WHERE Name = 'E2E RU Order Confirmation'];
                System.assertNotEquals(null, summaryEmail);
                System.debug('SUBJECT: ' + summaryEmail.Subject);
                System.debug('BODY: ' + summaryEmail.HtmlValue);
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
            System.debug('LINE: ' + e.getLineNumber());
        }
    }

    @IsTest(SeeAllData=true)
    public static void getSummaryMailInfoTestAdmin() {
        EmailTemplate summaryEmail = [SELECT Id, HTMLValue, Name, Subject FROM EmailTemplate WHERE Name = 'E2E RU Order Confirmation'];
        System.assertNotEquals(null, summaryEmail);
        System.debug('SUBJECT: ' + summaryEmail.Subject);
        System.debug('BODY: ' + summaryEmail.HtmlValue);
    }

    @IsTest
    public static void testUpdateOpportunityE2eBusiness() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuService formRuService = new E2EFormRuServiceImpl();
        Opportunity opportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opportunity;

        E2EFormParams formParams = new E2EFormParams();
        formParams.companyName = 'TEST';
        formParams.numOfCards = 10;
        formParams.product = 'Вездеход Online "Избранный +" Карты';
        formParams.personalOfficePhone = '+7 999 222 00 11';
        formRuService.updateOpportunity(opportunity.Id, formParams);

        opportunity = formRuService.getOpportunityById(opportunity.Id);
        System.assertEquals(10, opportunity.Number_of_Cards__c);
        System.assertEquals('TEST', opportunity.Name);
        System.assertEquals('Вездеход Online "Избранный +" Карты', opportunity.Product_PPR__c);
        System.assertEquals(formParams.personalOfficePhone, opportunity.Personal_office_phone__c);
    }

    @IsTest
    public static void testUpdateContactE2eBusiness() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuService formRuService = new E2EFormRuServiceImpl();
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        insert contact;

        E2EFormParams formParams = new E2EFormParams();
        formParams.mainContactPhone = '+7 8005553535';
        formParams.mainContactEmail = 'zabuza@ddd.ct';
        formParams.emailForPersonalOffice = 'personal@mail.ru';
        formRuService.updateContact(contact, formParams);

        contact = formRuService.getContactById(contact.Id);
        System.assertEquals('+7 8005553535', contact.Phone);
        System.assertEquals('zabuza@ddd.ct', contact.Email);
        contact = ([
                SELECT Id, Additional_Emails__c
                FROM Contact
                WHERE Id = :contact.Id
        ]).get(0);
        System.assert(contact.Additional_Emails__c.contains('personal@mail.ru'));

    }

    @IsTest
    public static void testUpdateAccountE2eBusiness() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuService formRuService = new E2EFormRuServiceImpl();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        insert account;

        //isSoleProprietor = false
        E2EFormParams formParams = new E2EFormParams();
        formParams.companyName = 'TEST';
        formParams.companyInn = '1234567890';
        formParams.okpo = '00196533';
        formParams.isSoleProprietor = false;
        formParams.ogrn = '1022402056324';
        formParams.kpp = '246201001';
        formParams.normName = 'AOO, test';
        formParams.codeWord = 'ваываы';
        formParams.companyLegalAddressCountry = 'Russia';
        formParams.companyLegalAddressCity = 'г Красноярск';
        formParams.companyLegalAddressState = 'Красноярский край';
        formParams.companyLegalAddressStreet = 'Транспортный проезд';
        formParams.companyLegalAddressPostalCode = '660123';
        formParams.postalAddressCountry = 'Russia';
        formParams.postalAddressCity = 'г Красноярск';
        formParams.postalAddressStreet = '1022402056324';
        formParams.postalAddressPostalCode = '660123';
        formParams.companyLegalAddressHouse = '1';
        formParams.legalAddressAdditionally = 'fsdfd';
        formParams.postalAddressHouse = '2';
        formParams.postalAddressAdditionally = 'проезд';
        formParams.checkingAccount = '34534645645645645645';
        formParams.bankNameShort = 'ВЗАИМОДЕЙСТВИЕ';
        formParams.corBankAccount = '30101810250040000760';
        formParams.bankBic = '045004760';
        formRuService.updateAccount(account.Id, formParams);

        account = formRuService.getAccountById(account.Id);
        System.assertEquals('TEST', account.Name);
        System.assertEquals('1234567890', account.INN__c);
        System.assertEquals('00196533', account.OKPO_ppr__c);
        System.assertEquals('1022402056324', account.OGRN_ppr__c);
        System.assertEquals('246201001', String.valueOf(account.KPP__c));
        System.assertNotEquals(null, account.Organization_Type__c);
        System.assertEquals(formParams.codeWord, account.Code_Word__c);
        System.assertEquals(formParams.companyLegalAddressCountry, account.BillingCountry);
        //        System.assertEquals(formParams.companyLegalAddressCity, account.BillingCity);
        System.assertNotEquals(null, account.BillingStreet);
        System.assertEquals(formParams.companyLegalAddressPostalCode, account.BillingPostalCode);
        //        System.assertEquals(formParams.companyLegalAddressState, account.Region__c);
        System.assertEquals(formParams.postalAddressCountry, account.ShippingCountry);
        //        System.assertEquals(formParams.postalAddressCity, account.ShippingCity);
        System.assertNotEquals(null, account.ShippingStreet);
        System.assertEquals(formParams.postalAddressPostalCode, account.ShippingPostalCode);
        System.assertEquals(formParams.checkingAccount, account.Checking_Account__c);
        System.assertEquals(formParams.bankNameShort, account.Bank__c);
        System.assertEquals(formParams.bankBic, account.SWIFT_BIC__c);
        System.assertEquals(formParams.corBankAccount, account.Cor_Bank_Account__c);

        //isSoleProprietor = true
        formParams.isSoleProprietor = true;
        formRuService.updateAccount(account.Id, formParams);

        account = formRuService.getAccountById(account.Id);
        System.assertEquals('1022402056324', account.OGRN_ppr__c);
        System.assertEquals('ИП', account.Organization_Type__c);
    }

    @IsTest
    public static void testAccountServiceCase2() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuDataTestFactory.initPagesStructure();

        E2EFormRuService formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        formParams.isSoleProprietor = true;
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // create account
        Id accountId = formService.createAccount(formParams);
        System.assertNotEquals(null, accountId);

        //****** update account step: CompanyInformation ******//
        Test.startTest();
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Test.stopTest();
        Account accountFirst = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(
            pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').value.toUpperCase(),
            accountFirst.Name
        );
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').value, accountFirst.INN__c);
        System.assertEquals(formParams.postCodeSpark, accountFirst.BillingPostalCode);
        System.assertEquals(formParams.citySpark.toUpperCase(), accountFirst.BillingCity);
        System.assertEquals(formParams.regionSpark, accountFirst.Region__c);

        //****** update account step: LegalDetails ******//
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.LegalDetails.name());

        Account accountSecond = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').value,
            accountSecond.OGRN_ppr__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').value,
            accountSecond.OKPO_ppr__c
        );
        System.assertEquals(
            pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').value,
            accountSecond.Code_Word__c
        );
    }

    @IsTest
    public static void testOpportunityUpdateQueueable() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuService formService = new E2EFormRuServiceImpl();
        Opportunity opportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opportunity;

        opportunity.Name = 'TEST';
        Test.startTest();
        System.enqueueJob(new E2EFormRuServiceImpl.updateOpportunityQueueable(opportunity, 'firstFormUrl'));
        Test.stopTest();

        opportunity = formService.getOpportunityById(opportunity.Id);
        System.assertEquals('TEST', opportunity.Name);
    }

    @IsTest
    public static void testPrepareReportRequestDataByFormParams() {
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = E2EFormRuTestUtils.createDefaultFormParams();
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        formParams.tariffId = 'LIGHT_CARDS';
        formParams.personalOfficePhone = '777';
        formParams.emailForPersonalOffice = 'test@test.com';

        formParams.isSoleProprietor = true;
        ReportRequestData reportRequestData = formService.prepareReportRequestData(formParams, true, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertNotEquals(null, reportRequestData);

        formParams.isSoleProprietor = false;
        ReportRequestData reportRequestData2 = formService.prepareReportRequestData(formParams, true, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertNotEquals(null, reportRequestData2);

        //VS SF-1422 start
        formParams.businessType = 0;
        ReportRequestData reportRequestData3 = formService.prepareReportRequestData(formParams, true, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertNotEquals(null, reportRequestData3);

        formParams.businessType = 4;
        ReportRequestData reportRequestData4 = formService.prepareReportRequestData(formParams, true, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertNotEquals(null, reportRequestData4);
        //VS SF-1422 end

        E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Send_Contract_To_Client__c = true;
        formParams.sendToInbound = false;
        ReportRequestData reportRequestData5 = formService.prepareReportRequestData(formParams, false, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertNotEquals(null, reportRequestData5);
        System.assertEquals('', reportRequestData5.reportParams.CREDIT_PERIOD);
        System.assertEquals(false, reportRequestData5.createPrescoringDocument);
        System.assertEquals('', reportRequestData5.reportParams.CREDIT_CONDITIONS);

        formParams.freeOverdraft = true;
        ReportRequestData reportRequestData6 = formService.prepareReportRequestData(formParams, false, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertEquals(System.Label.Free_overdraft_conditions_for_docs, reportRequestData6.reportParams.CREDIT_CONDITIONS);

        Credit_Factory_Report__c report = CFTestDataFactory.createCreditFactoryReport(
            new Account(Id = formParams.accountId),
            new Opportunity(Id = formParams.opportunityId)
        );
        report.RU_Scoring_Credit_Period__c = 20000;
        report.RU_Scoring_Payment_Time_Limit__c = 20;
        report.Credit_Limit__c = '10000';
        report.RU_Application_Blocked__c = false;
        report.RU_Client_Choice__c = true;
        insert report;
        Transit_Contract_Type_Mapping__c transitContractTypeMapping = E2EFormRuDataTestFactory.createTransitContractTypeMapping(20000, 2);
        transitContractTypeMapping.Credit_Period_In_Words__c = 'words';
        insert transitContractTypeMapping;

        ReportRequestData reportRequestData7 = formService.prepareReportRequestData(formParams, false, GlobalUtils.BusinessProcessType.E2EBusiness);
        System.assertEquals('words', reportRequestData7.reportParams.CREDIT_PERIOD);
        System.assertEquals('20', reportRequestData7.reportParams.DUE_DATE);
        System.assertEquals('Двадцати', reportRequestData7.reportParams.DUE_DATE_IN_WORDS);
        System.assertEquals('10000', reportRequestData7.reportParams.CREDIT_LIMIT);
        System.assertEquals('Десять тысяч', reportRequestData7.reportParams.CREDIT_LIMIT_IN_WORDS);
        System.assert(reportRequestData7.createPrescoringDocument);
        System.assertEquals(
                CFUtils.PRESCORING_RU + '. ' + report.Credit_Limit__c +
                ' рублей, срок кредита - ' + report.RU_Scoring_Credit_Period__c +
                ' дней, срок оплаты кредита - ' + report.RU_Scoring_Payment_Time_Limit__c + ' дней.',
                reportRequestData7.reportParams.CREDIT_CONDITIONS
        );
        System.assertEquals(formParams.personalOfficePhone, reportRequestData7.reportParams.PERSONAL_OFFICE_PHONE);
        System.assertEquals(formParams.emailForPersonalOffice, reportRequestData7.reportParams.PERSONAL_OFFICE_EMAIL);
    }

    @IsTest
    public static void testPrepareReportRequestDataByFormData() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = E2EFormRuTestUtils.createDefaultFormParams();
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);

        Account account;
        Opportunity opportunity;
        E2EFormData__c formDataRecord;
        E2EFormRuTestUtils.initCustomSettings();

        account = E2EFormRuTestUtils.createAccount('1234567890', System.today(), System.today());
        account.Name = 'Test acc';
        account.Organization_Type__c = 'ООО';
        account.ShippingPostalCode = '123456';
        account.BillingPostalCode = '123456';
        account.ShippingStreet = 'ул Автомобилистов';
        account.KPP__c = 330401001;
        account.Checking_Account__c = '88794484848484848484';
        account.Code_Word__c = 'КОДВОРД';
        account.OKPO_ppr__c = '00288679';
        insert account;

        opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        formDataRecord = E2EFormRuTestUtils.createDefaultFormData();
        formDataRecord.E2E_INN__c = account.INN__c;
        formDataRecord.E2E_Account_Id__c = account.Id;
        formDataRecord.E2E_Opportunity_Id__c = opportunity.Id;
        formDataRecord.E2E_Personal_Manager_srv__c = true;
        formDataRecord.E2E_Document_Delivery_srv__c = true;
        formDataRecord.E2E_Product_Id__c = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        formDataRecord.E2E_Num_Cards__c = 1;
        formDataRecord.E2E_Tariff_Id__c = '1OPTIMAL_CARDS';
        formDataRecord.E2E_Scoring_Decision_Code__c = '0';
        formDataRecord.E2E_Overdraft_srv__c = true;
        formDataRecord.E2E_Code_Word__c = account.Code_Word__c;
        formDataRecord.E2E_Personal_Office_Email__c = 'test@test.te';
        formDataRecord.E2E_Product__c = 'Вездеход Online Оптимальный';
        formDataRecord.E2E_KPP__c = '330401001';
        formDataRecord.E2E_OGRN__c = '1033300200383';
        formDataRecord.E2E_OKPO__c = '00288679';
        formDataRecord.E2E_Legal_Address__c = 'Владимирская обл, г. Гусь-Хрустальный, проспект 50 Лет Советской Власти, д. 8';
        formDataRecord.E2E_Post_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        formDataRecord.E2E_Main_Company_Full_Name__c = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "ЛЕС РУК"';
        formDataRecord.E2E_Executive_Person__c = 'Фархатдинова Лиана Игоревна, генеральный директор';
        formDataRecord.E2E_Billing_Code__c = '123456';
        formDataRecord.E2E_Account_Short_Name__c = 'ГЛОБУС';
        formDataRecord.E2E_Prepay_Amount__c = '14892';
        formDataRecord.E2E_BIC__c = '044525974';
        formDataRecord.E2E_Bank__c = 'АО "ТИНЬКОФФ БАНК"';
        formDataRecord.E2E_Cor_Bank_Account__c = '13131313131341341341';
        formDataRecord.E2E_Bank_OKPO__c = '00288679';
        formDataRecord.E2E_Bank_Town__c = 'г Волжский';
        formDataRecord.E2E_Bank_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        insert formDataRecord;
        formParams.personalOfficePhone = '777';
        formParams.emailForPersonalOffice = 'test@test.com';

        ReportRequestData reportRequestData_test = formService.prepareReportRequestData(
            formDataRecord.Id,
            formParams,
            null,
            true,
            GlobalUtils.BusinessProcessType.E2EBusiness
        );
        System.assertNotEquals(null, reportRequestData_test.tariffId);

        formParams.isSoleProprietor = true;
        ReportRequestData reportRequestData = formService.prepareReportRequestData(
            formDataRecord.Id,
            formParams,
            null,
            true,
            GlobalUtils.BusinessProcessType.E2EBusiness
        );
        System.assertNotEquals(null, reportRequestData);

        formParams.isSoleProprietor = false;
        ReportRequestData reportRequestData2 = formService.prepareReportRequestData(
            formDataRecord.Id,
            formParams,
            null,
            true,
            GlobalUtils.BusinessProcessType.E2EBusiness
        );
        System.assertNotEquals(null, reportRequestData2);

        E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Send_Contract_To_Client__c = true;
        formParams.sendToInbound = false;
        ReportRequestData reportRequestData3 = formService.prepareReportRequestData(
            formDataRecord.Id,
            formParams,
            null,
            false,
            GlobalUtils.BusinessProcessType.E2EBusiness
        );
        System.assertNotEquals(null, reportRequestData3);
    }

    @IsTest
    public static void testCreateFormData() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = E2EFormRuTestUtils.createDefaultFormParams();
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);

        Account account = E2EFormRuTestUtils.createAccount('1234567890', System.today(), System.today());
        account.Name = 'Test acc';
        account.Organization_Type__c = 'ООО';
        account.ShippingPostalCode = '123456';
        account.BillingPostalCode = '123456';
        account.ShippingStreet = 'ул Автомобилистов';
        account.KPP__c = 330401001;
        account.Checking_Account__c = '88794484848484848484';
        account.Code_Word__c = 'КОДВОРД';
        account.OKPO_ppr__c = '00288679';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        Id id = formService.createFormDataRecord(account.Id, opportunity.Id, formParams);
        System.assertNotEquals(null, id);
    }

    @IsTest
    public static void testUpdateFormData() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = E2EFormRuTestUtils.createDefaultFormParams();
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.Free_overdraft__c = false;
        formData.E2E_Overdraft_srv__c = false;
        insert formData;

        formParams.freeOverdraft = true;
        formParams.emptySparkOkpo = true;
        formService.updateFormData(formData.Id, formParams);

        formData = formService.getFormDataById(formData.Id);
        System.assertEquals(false, formData.E2E_Overdraft_srv__c);
        System.assertEquals(true, formData.Free_overdraft__c);
        System.assertEquals(true, formData.E2E_Empty_SPARK_OKPO__c);
    }

    @IsTest
    public static void testFormDataUpdateQueueable() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuService formService = new E2EFormRuServiceImpl();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        insert formData;

        formData.E2E_Product__c = 'TEST';
        Test.startTest();
        System.enqueueJob(new E2EFormRuServiceImpl.updateFormDataQueueable(formData, 'firstFormUrl'));
        Test.stopTest();

        formData = formService.getFormDataById(formData.Id);
        System.assertEquals('TEST', formData.E2E_Product__c);
    }

    @IsTest(SeeAllData=true)
    public static void testChangeObjectOwner() {
        E2EFormRuService formService = new E2EFormRuServiceImpl();
        E2EFormRuDao formRuDao = new E2EFormRuDaoImpl();
        User user = formRuDao.getUserByName('Anna Rudas');

        Opportunity opportunity = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opportunity;

        formService.changeObjectOwner(opportunity.Id, user.Name);
        opportunity = formService.getOpportunityById(opportunity.Id);
        System.assertEquals(user.Id, opportunity.OwnerId);
    }

    @IsTest
    public static void testGetCurrentDataToShowOnForm() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuService formService = new E2EFormRuServiceImpl();
        Account account;
        Opportunity opportunity;
        E2EFormData__c formDataRecord;
        E2EFormRuTestUtils.initCustomSettings();

        account = E2EFormRuTestUtils.createAccount('1234567890', System.today(), System.today());
        account.Name = 'Test acc';
        account.Organization_Type__c = 'ООО';
        account.ShippingPostalCode = '123456';
        account.BillingPostalCode = '123456';
        account.ShippingStreet = 'ул Автомобилистов';
        account.KPP__c = 330401001;
        account.Checking_Account__c = '88794484848484848484';
        account.Code_Word__c = 'КОДВОРД';
        account.OKPO_ppr__c = '00288679';
        insert account;

        opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.Virtual_cards__c = true;
        insert opportunity;

        formDataRecord = E2EFormRuTestUtils.createDefaultFormData();
        formDataRecord.E2E_INN__c = account.INN__c;
        formDataRecord.E2E_Account_Id__c = account.Id;
        formDataRecord.E2E_Opportunity_Id__c = opportunity.Id;
        formDataRecord.E2E_Personal_Manager_srv__c = true;
        formDataRecord.E2E_Document_Delivery_srv__c = true;
        formDataRecord.E2E_Product_Id__c = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        formDataRecord.E2E_Num_Cards__c = 1;
        formDataRecord.E2E_Tariff_Id__c = '1OPTIMAL_CARDS';
        formDataRecord.E2E_Scoring_Decision_Code__c = '0';
        formDataRecord.E2E_Overdraft_srv__c = true;
        formDataRecord.Free_overdraft__c = true;
        formDataRecord.E2E_Code_Word__c = account.Code_Word__c;
        formDataRecord.E2E_Personal_Office_Email__c = 'test@test.te';
        formDataRecord.E2E_Product__c = 'Вездеход Online Оптимальный';
        formDataRecord.E2E_KPP__c = '330401001';
        formDataRecord.E2E_OGRN__c = '1033300200383';
        formDataRecord.E2E_OKPO__c = '00288679';
        formDataRecord.E2E_Legal_Address__c = 'Владимирская обл, г. Гусь-Хрустальный, проспект 50 Лет Советской Власти, д. 8';
        formDataRecord.E2E_Post_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        formDataRecord.E2E_Main_Company_Full_Name__c = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "ЛЕС РУК"';
        formDataRecord.E2E_Executive_Person__c = 'Фархатдинова Лиана Игоревна, генеральный директор';
        formDataRecord.E2E_Billing_Code__c = '123456';
        formDataRecord.E2E_Account_Short_Name__c = 'ГЛОБУС';
        formDataRecord.E2E_Prepay_Amount__c = '14892';
        formDataRecord.E2E_BIC__c = '044525974';
        formDataRecord.E2E_Bank__c = 'АО "ТИНЬКОФФ БАНК"';
        formDataRecord.E2E_Cor_Bank_Account__c = '13131313131341341341';
        formDataRecord.E2E_Bank_OKPO__c = '00288679';
        formDataRecord.E2E_Bank_Town__c = 'г Волжский';
        formDataRecord.E2E_Bank_Address__c = 'Волгоградская обл, г Волжский, ул Автомобилистов, д 6';
        formDataRecord.E2E_Empty_SPARK_OKPO__c = true;
        insert formDataRecord;

        E2EFormParams formParams = formService.getCurrentDataToShowOnForm(account, opportunity, formDataRecord);
        System.assertNotEquals(null, formParams);
        System.assertEquals(true, formParams.virtualCards);
        System.assertEquals(true, formParams.freeOverdraft);
        System.assertEquals(true, formParams.emptySparkOkpo);
        System.assertEquals(opportunity.Personal_office_phone__c, formParams.personalOfficePhone);
    }

    @isTest
    public static void testFormDataValidator() {
        FormDataValidator testValidator = new FormDataValidator();
        Boolean testFlag = false;

        Test.startTest();
        try {
            testValidator.validateFieldFulling('');
        } catch (E2EFormRuException e) {
            testFlag = true;
        }
        System.assert(testFlag);
        testFlag = false;
        try {
            testValidator.validateFieldFulling(null);
        } catch (E2EFormRuException e) {
            testFlag = true;
        }
        System.assert(testFlag);
        testFlag = false;
        try {
            testValidator.validateIsNotBlank('', '');
        } catch (E2EFormRuException e) {
            testFlag = true;
        }
        System.assert(testFlag);
        testFlag = false;
        try {
            testValidator.validateIsNotBlank(null, null);
        } catch (E2EFormRuException e) {
            testFlag = true;
        }
        System.assert(testFlag);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateOpportunityStage() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        //***** test to create opportunity *****//
        Id opportunityId = formService.createOpportunity(accountId, formParams);
        System.assertNotEquals(null, opportunityId);

        Test.startTest();
        formService.updateOpportunityStage(opportunityId, 'Awaiting payment');
        Test.stopTest();
    }

    @isTest
    public static void testGetSummaryMailInfo() {
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);

        Test.startTest();
        Map<String, String> emailData = formService.getSummaryMailInfo(formParams);
        Test.stopTest();
        System.assertNotEquals(null, emailData);
    }

    @isTest
    static void testForCoverage() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuServiceImpl service = new E2EFormRuServiceImpl();
        E2E_Form_Ru_General_Settings__c ru = new E2E_Form_Ru_General_Settings__c();
        ru.Name = 'E2EFormRu';
        insert ru;
        Opportunity opp = E2EFormRuTestUtils.createDefaultOpportunity();
        insert opp;
        Id oppId = opp.Id;
        service.getCurrentStep(oppId);
        service.isRoleInbound(oppId);
    }

    @isTest
    static void testGetPromocode() {
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuDataTestFactory.initPagesStructure();
        E2EFormRuTestUtils.initCustomSettings();
        PPR_API_Settings__c pprApiSetting = PPR_API_DataTestFactory.createPPR_API_Settings();
        insert pprApiSetting;
        List<E2E_Promocodes__c> promocodes = new List<E2E_Promocodes__c>();
        promocodes.add(PPR_API_DataTestFactory.createPromocode('9Е06', '@159;', '159@19,9;'));
        promocodes.add(PPR_API_DataTestFactory.createPromocode('9Е07', '@160;', '160@19,17;'));
        insert promocodes;

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initE2EFormParamsData(formParams);
        E2EFormRuDataTestFactory.initContentMap(pagesMap);

        // init account
        formParams.isSoleProprietor = true;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        Opportunity opp = new Opportunity(Id = opportunityId);
        opp.Source_PP__c = 'europlan';
        update opp;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(
                E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'europlan')
            )
            .Id;
        System.assertNotEquals(null, formDataId);
    }

    @IsTest
    private static void testDuplicateLeadProcess() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuService e2EFormRuService = new E2EFormRuServiceImpl();
        E2EFormRuDataTestFactory.initPagesStructure();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        e2EFormRuService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initContentMap(pagesMap);
        Lead lead = E2EFormRuTestUtils.createDefaultLead();
        lead.Phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
        lead.Email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        insert lead;

        Test.startTest();
        e2EFormRuService.duplicateLeadProcess(pagesMap);
        Test.stopTest();

        lead = ([SELECT Id, Status, Lead_Status_Specific__c FROM Lead WHERE Id = :lead.Id LIMIT 1]);
        System.assertEquals('Disqualified', lead.Status);
        System.assertEquals('Switched to E2E', lead.Lead_Status_Specific__c);
    }

    @IsTest
    private static void testDeduplicateE2EClassicClient() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormRuService e2EFormRuService = new E2EFormRuServiceImpl();
        E2EFormRuDataTestFactory.initPagesStructure();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        e2EFormRuService.collectContent(
            GlobalUtils.FleetcorCountries.Russia.name(),
            GlobalUtils.E2ERuSteps.Congratulations.name(),
            pagesMap,
            GlobalUtils.DeviceType.Desktop
        );
        E2EFormRuDataTestFactory.initContentMap(pagesMap);
        Contact contact = E2EFormRuTestUtils.createDefaultContact();
        contact.Phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').value;
        contact.Email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').value;
        insert contact;
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(contact.AccountId);
        insert opportunity;
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Contact_Id__c = contact.Id;
        formData.E2E_Account_Id__c = contact.AccountId;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        formData.E2E_Contact_Phone__c = contact.Phone;
        formData.E2E_Contact_Email__c = contact.Email;
        insert formData;

        Map<String, String> result = e2EFormRuService.deduplicateE2EClient('E2E', pagesMap);
        System.debug('testDeduplicateE2EClassicClient ' + result);
        System.assertEquals(formData.E2E_Account_Id__c, result.get('accountId'));
        System.assertEquals(formData.E2E_Opportunity_Id__c, result.get('opportunityId'));
        System.assertEquals(formData.E2E_Contact_Id__c, result.get('contactId'));
        System.assertEquals(formData.Id, result.get('formDataId'));
        System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.get('statusCode'));

        System.assertEquals(true, e2EFormRuService.deduplicateE2EClient('dsd', pagesMap).isEmpty());
    }
}
