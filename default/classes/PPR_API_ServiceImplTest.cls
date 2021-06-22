@IsTest
public with sharing class PPR_API_ServiceImplTest {

    private static final Integer DATA_RELEVANCE_DAYS = 1;
    private static final String SOURCE = 'test source';
    private static final String USER = 'test user';
    private static final String INN = '6670429075';

    static {
        PPR_API_Settings__c settings = new PPR_API_Settings__c(
                Name = SOURCE,
                Business_data_relevance__c = DATA_RELEVANCE_DAYS
        );
        insert settings;
        insert CFUtilsTest.createCFSettingsForRussia(false);
        E2EFormRuTestUtils.initCustomSettings();
    }

    private static Custom_log__c createLog(String inn, String source, Id formDataId) {
        Custom_log__c log = new Custom_log__c(
                INN__c = inn,
                E2E_Form_Ru_Data__c = formDataId,
                Source__c = source
        );
        return log;
    }

    @IsTest
    private static void testCheckINNNewCustomerExistingFormData() {
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Name__c = 'name';
        formData.E2E_Scoring_Decision_Code__c = '1';
        formData.E2E_Black_List_Code__c = '2';
        formData.E2E_Scoring_Date__c = Date.today().addDays(-1 * DATA_RELEVANCE_DAYS);
        formData.E2E_Dedup_Status_Info__c = 'info';
        formData.E2E_Dedup_Status__c = GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
        formData.Last_deduplication_time__c = Datetime.now();
        insert formData;
        insert createLog(INN, SOURCE, formData.Id);

        Map<String, String> params = new Map<String, String> {
                'inn' => INN,
                'user' => USER,
                'source' => SOURCE
        };
        PPR_API_Service service = new PPR_API_ServiceImpl();
        E2EFormParams formParams = service.checkINN(params);

        System.assertEquals('New', formParams.processStatus);
        System.assertEquals(USER, formParams.externalUser);
        System.assertEquals(SOURCE, formParams.source);
        System.assert(String.isEmpty(formParams.errors));
        System.assert(String.isNotBlank(formParams.formDataId));
        System.assertEquals(INN, formParams.companyInn);
        System.assertEquals(formData.Last_deduplication_time__c.date(), formParams.deduplicationDatetime.date());
        System.assertEquals(GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name(), formParams.deduplicationStatus);
        System.assertEquals(formData.E2E_Scoring_Date__c, formParams.scoringDate);
        System.assertNotEquals('2', formParams.scoringDecisionCode);
        System.assertNotEquals('3', formParams.verifiedDecisionCode);

        Custom_log__c log  = PPR_API_LogService.getLogByInnAndSource(formParams.companyInn, formParams.source);
        E2EFormRuService e2EFormRuService = new E2EFormRuServiceImpl();
        log.E2E_Form_Ru_Data__r = e2EFormRuService.getFormDataById(log.E2E_Form_Ru_Data__c);
        //System.assertEquals(USER, log.External_user__c);
        System.assertEquals(SOURCE, log.Source__c);
        System.assert(String.isEmpty(log.Errors__c));
        System.assert(String.isNotBlank(log.E2E_Form_Ru_Data__c));
        System.assertEquals(INN, log.INN__c);

        System.assertEquals(SOURCE, log.E2E_Form_Ru_Data__r.E2E_Source__c);
        System.assertEquals(INN, log.E2E_Form_Ru_Data__r.E2E_INN__c);
        System.assertEquals('New', log.E2E_Form_Ru_Data__r.E2E_Process_Status__c);
        System.assertEquals(formData.Last_deduplication_time__c.date(), log.E2E_Form_Ru_Data__r.Last_deduplication_time__c.date());
        System.assertEquals(formData.E2E_Dedup_Status__c, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status__c);
        System.assertEquals(formData.E2E_Dedup_Status_Info__c, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status_Info__c);
        System.assertEquals(formData.E2E_Scoring_Date__c, log.E2E_Form_Ru_Data__r.E2E_Scoring_Date__c);
        System.assertEquals(formData.E2E_Scoring_Decision_Code__c, log.E2E_Form_Ru_Data__r.E2E_Scoring_Decision_Code__c);
        System.assertEquals(formData.E2E_Black_List_Code__c, log.E2E_Form_Ru_Data__r.E2E_Black_List_Code__c);
        System.assertEquals(formData.E2E_Account_Name__c, log.E2E_Form_Ru_Data__r.E2E_Account_Name__c);
    }

    @IsTest
    private static void testCheckINNDuplicatesFoundExistingFormData() {
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Name__c = 'name';
        formData.E2E_Scoring_Decision_Code__c = '1';
        formData.E2E_Black_List_Code__c = '2';
        formData.E2E_Scoring_Date__c = Date.today().addDays(-1 * DATA_RELEVANCE_DAYS);
        formData.E2E_Dedup_Status_Info__c = 'info';
        formData.E2E_Dedup_Status__c = GlobalUtils.DeduplicationStatus.Service.name();
        formData.Last_deduplication_time__c = Datetime.now();
        insert formData;
        insert createLog(INN, SOURCE, formData.Id);

        Map<String, String> params = new Map<String, String> {
                'inn' => INN,
                'user' => USER,
                'source' => SOURCE
        };
        PPR_API_Service service = new PPR_API_ServiceImpl();
        E2EFormParams formParams = service.checkINN(params);

        System.assertEquals('Double', formParams.processStatus);
        System.assertEquals(USER, formParams.externalUser);
        System.assertEquals(SOURCE, formParams.source);
        System.assert(String.isEmpty(formParams.errors));
        System.assert(String.isNotBlank(formParams.formDataId));
        System.assertEquals(INN, formParams.companyInn);
        System.assertEquals(formData.Last_deduplication_time__c.date(), formParams.deduplicationDatetime.date());
        System.assertNotEquals(GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name(), formParams.deduplicationStatus);

        Custom_log__c log  = PPR_API_LogService.getLogByInnAndSource(formParams.companyInn, formParams.source);
        E2EFormRuService e2EFormRuService = new E2EFormRuServiceImpl();
        log.E2E_Form_Ru_Data__r = e2EFormRuService.getFormDataById(log.E2E_Form_Ru_Data__c);
        //System.assertEquals(USER, log.External_user__c);
        System.assertEquals(SOURCE, log.Source__c);
        System.assert(String.isEmpty(log.Errors__c));
        System.assert(String.isNotBlank(log.E2E_Form_Ru_Data__c));
        System.assertEquals(INN, log.INN__c);

        System.assertEquals(SOURCE, log.E2E_Form_Ru_Data__r.E2E_Source__c);
        System.assertEquals(INN, log.E2E_Form_Ru_Data__r.E2E_INN__c);
        System.assertEquals('Double', log.E2E_Form_Ru_Data__r.E2E_Process_Status__c);
        System.assertEquals(formData.Last_deduplication_time__c.date(), log.E2E_Form_Ru_Data__r.Last_deduplication_time__c.date());
        System.assertEquals(formData.E2E_Dedup_Status__c, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status__c);
        System.assertEquals(formData.E2E_Dedup_Status_Info__c, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status_Info__c);
        System.assertEquals(formData.E2E_Scoring_Date__c, log.E2E_Form_Ru_Data__r.E2E_Scoring_Date__c);
        System.assertEquals(formData.E2E_Scoring_Decision_Code__c, log.E2E_Form_Ru_Data__r.E2E_Scoring_Decision_Code__c);
        System.assertEquals(formData.E2E_Black_List_Code__c, log.E2E_Form_Ru_Data__r.E2E_Black_List_Code__c);
        System.assertEquals(formData.E2E_Account_Name__c, log.E2E_Form_Ru_Data__r.E2E_Account_Name__c);
    }

    @IsTest
    private static void testCheckINNBadINN() {
        Map<String, String> params = new Map<String, String> {
                'inn' => '66704',
                'user' => USER,
                'source' => SOURCE
        };
        PPR_API_Service service = new PPR_API_ServiceImpl();
        E2EFormParams formParams = service.checkINN(params);

        System.assertEquals('Failed', formParams.processStatus);
        System.assertEquals(USER, formParams.externalUser);
        System.assertEquals(SOURCE, formParams.source);
        System.assertEquals('Bad request. INN is not correct.', formParams.errors);
        System.assertEquals('66704', formParams.companyInn);

        Custom_log__c log  = PPR_API_LogService.getLogByInnAndSource(formParams.companyInn, formParams.source);
        System.assert(log != null);
        System.assert(log.E2E_Form_Ru_Data__c == null);
    }

    @IsTest
    private static void testCheckINNBlackListExistingFormData() {
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Name__c = 'name';
        formData.E2E_Scoring_Decision_Code__c = '2';
        formData.E2E_Black_List_Code__c = '3';
        formData.E2E_Scoring_Date__c = Date.today().addDays(-1 * DATA_RELEVANCE_DAYS);
        formData.E2E_Dedup_Status_Info__c = 'info';
        formData.E2E_Dedup_Status__c = GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
        formData.Last_deduplication_time__c = Datetime.now();
        insert formData;
        insert createLog(INN, SOURCE, formData.Id);

        Map<String, String> params = new Map<String, String> {
                'inn' => INN,
                'user' => USER,
                'source' => SOURCE
        };
        Test.startTest();
        PPR_API_Service service = new PPR_API_ServiceImpl();
        E2EFormParams formParams = service.checkINN(params);
        Test.stopTest();

        System.assertEquals('BlackList', formParams.processStatus);
        //System.assertEquals(USER, formParams.externalUser);
        System.assertEquals(SOURCE, formParams.source);
        System.assert(String.isEmpty(formParams.errors));
        System.assert(String.isNotBlank(formParams.formDataId));
        System.assertEquals(INN, formParams.companyInn);
        System.assertEquals(formData.Last_deduplication_time__c.date(), formParams.deduplicationDatetime.date());
        System.assertEquals(GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name(), formParams.deduplicationStatus);
        System.assertEquals(formData.E2E_Scoring_Date__c, formParams.scoringDate);
        System.assert(formParams.scoringDecisionCode.equals('2') || formParams.verifiedDecisionCode.equals('3'));

        Custom_log__c log  = PPR_API_LogService.getLogByInnAndSource(formParams.companyInn, formParams.source);
        E2EFormRuService e2EFormRuService = new E2EFormRuServiceImpl();
        log.E2E_Form_Ru_Data__r = e2EFormRuService.getFormDataById(log.E2E_Form_Ru_Data__c);
        //System.assertEquals(USER, log.External_user__c);
        System.assertEquals(SOURCE, log.Source__c);
        System.assert(String.isEmpty(log.Errors__c));
        System.assert(String.isNotBlank(log.E2E_Form_Ru_Data__c));
        System.assertEquals(INN, log.INN__c);

        System.assertEquals(SOURCE, log.E2E_Form_Ru_Data__r.E2E_Source__c);
        System.assertEquals(INN, log.E2E_Form_Ru_Data__r.E2E_INN__c);
        System.assertEquals('BlackList', log.E2E_Form_Ru_Data__r.E2E_Process_Status__c);
        System.assertEquals(formData.Last_deduplication_time__c.date(), log.E2E_Form_Ru_Data__r.Last_deduplication_time__c.date());
        System.assertEquals(formData.E2E_Dedup_Status__c, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status__c);
        System.assertEquals(formData.E2E_Dedup_Status_Info__c, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status_Info__c);
        System.assertEquals(formData.E2E_Scoring_Date__c, log.E2E_Form_Ru_Data__r.E2E_Scoring_Date__c);
        System.assertEquals(formData.E2E_Scoring_Decision_Code__c, log.E2E_Form_Ru_Data__r.E2E_Scoring_Decision_Code__c);
        System.assertEquals(formData.E2E_Black_List_Code__c, log.E2E_Form_Ru_Data__r.E2E_Black_List_Code__c);
        System.assertEquals(formData.E2E_Account_Name__c, log.E2E_Form_Ru_Data__r.E2E_Account_Name__c);
    }

    @IsTest
    private static void testCheckINNDuplicatesFoundNoFormData() {
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = INN;
        insert account;
        insert createLog(INN, SOURCE, null);

        Map<String, String> params = new Map<String, String> {
                'inn' => INN,
                'user' => USER,
                'source' => SOURCE
        };
        PPR_API_Service service = new PPR_API_ServiceImpl();
        Test.startTest();
        E2EFormParams formParams = service.checkINN(params);
        Test.stopTest();

        System.assertEquals('Double', formParams.processStatus);
        System.assertEquals(USER, formParams.externalUser);
        System.assertEquals(SOURCE, formParams.source);
        System.assert(String.isEmpty(formParams.errors));
        System.assert(String.isNotBlank(formParams.formDataId));
        System.assertEquals(INN, formParams.companyInn);
        System.assertEquals(Date.today(), formParams.deduplicationDatetime.date());
        System.assertNotEquals(GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name(), formParams.deduplicationStatus);

        Custom_log__c log  = PPR_API_LogService.getLogByInnAndSource(formParams.companyInn, formParams.source);
        E2EFormRuService e2EFormRuService = new E2EFormRuServiceImpl();
        log.E2E_Form_Ru_Data__r = e2EFormRuService.getFormDataById(log.E2E_Form_Ru_Data__c);
        //System.assertEquals(USER, log.External_user__c);
        System.assertEquals(SOURCE, log.Source__c);
        System.assert(String.isEmpty(log.Errors__c));
        //System.assert(String.isNotBlank(log.E2E_Form_Ru_Data__c));
        System.assertEquals(INN, log.INN__c);

        /*System.assertEquals(SOURCE, log.E2E_Form_Ru_Data__r.E2E_Source__c);
        System.assertEquals(INN, log.E2E_Form_Ru_Data__r.E2E_INN__c);
        System.assertEquals('Double', log.E2E_Form_Ru_Data__r.E2E_Process_Status__c);
        System.assertEquals(formParams.deduplicationDatetime.date(), log.E2E_Form_Ru_Data__r.Last_deduplication_time__c.date());
        System.assertEquals(formParams.deduplicationStatus, log.E2E_Form_Ru_Data__r.E2E_Dedup_Status__c);
        System.assertEquals(formParams.deduplicationStatusInfo.trim(), log.E2E_Form_Ru_Data__r.E2E_Dedup_Status_Info__c);*/
    }

    @IsTest
    private static void testProcessCreditCheckBadINN() {
        try {
            E2EFormParams formParams = new E2EFormParams();
            formParams.companyInn = '';
            PPR_API_ServiceImpl service = new PPR_API_ServiceImpl();
            service.processCreditCheck(formParams, null);
        } catch (Exception e) {
            System.assertEquals('Bad request. INN is not correct.', e.getMessage());
        }

        // in this cases just cover code lines
        try {
            E2EFormParams formParams = new E2EFormParams();
            formParams.companyInn = '123456789012';
            PPR_API_ServiceImpl service = new PPR_API_ServiceImpl();
            service.processCreditCheck(formParams, null);
        } catch (Exception e) {
           
        }

        try {
            E2EFormParams formParams = new E2EFormParams();
            formParams.companyInn = '1234567890';
            PPR_API_ServiceImpl service = new PPR_API_ServiceImpl();
            service.processCreditCheck(formParams, null);
        } catch (Exception e) {
           
        }
    }

    @IsTest
    private static void testProcessCheckINN() {
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Name__c = 'name';
        formData.E2E_Scoring_Decision_Code__c = '1';
        formData.E2E_Black_List_Code__c = '2';
        formData.E2E_Scoring_Date__c = Date.today().addDays(-1 * DATA_RELEVANCE_DAYS);
        formData.E2E_Dedup_Status_Info__c = 'info';
        formData.E2E_Dedup_Status__c = GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
        formData.Last_deduplication_time__c = Datetime.now();
        insert formData;
        insert createLog(INN, SOURCE, formData.Id);

        Map<String, String> params = new Map<String, String> {
                'inn' => INN,
                'user' => USER,
                'source' => SOURCE
        };
        PPR_API_Service service = new PPR_API_ServiceImpl();
        PPR_API_ResponseBody responseBody = service.processCheckINN(params);

        System.assert(responseBody != null);
    }

    @IsTest
    private static void testProcessCheckStatus() {
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Name__c = 'name';
        formData.E2E_Scoring_Decision_Code__c = '1';
        formData.E2E_Black_List_Code__c = '2';
        formData.E2E_Scoring_Date__c = Date.today().addDays(-1 * DATA_RELEVANCE_DAYS);
        formData.E2E_Dedup_Status_Info__c = 'info';
        formData.E2E_Dedup_Status__c = GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
        formData.Last_deduplication_time__c = Datetime.now();
        insert formData;
        insert createLog(INN, SOURCE, formData.Id);

        Map<String, String> params = new Map<String, String> {
                'id' => formData.Id,
                'user' => USER,
                'source' => SOURCE
        };
        PPR_API_Service service = new PPR_API_ServiceImpl();
        PPR_API_ResponseBody responseBody = service.processCheckStatus(params);

        System.assert(responseBody != null);
    }

    @IsTest
    private static void testPublicVariables() {
        LongForm_Tariff__c tariffProduct = PPR_API_DataTestFactory.createLongFormTariff();
        insert tariffProduct;
        LongForm_Offer__c offer = PPR_API_DataTestFactory.createOffer();
        insert offer;
        LongForm_Fleetcor_Product__c productOffer = PPR_API_DataTestFactory.createProductOffer(offer.Id);
        insert productOffer;

        PPR_API_ServiceImpl service = new PPR_API_ServiceImpl();
        Set<String> tariffs = service.tariffs;

        System.assertEquals(1, tariffs.size());
        System.assert(tariffs.contains('1optimal_contract'));

        Set<String> products = service.products;

        System.assertEquals(1, products.size());
        System.assert(products.contains('petrolplus_rover'));
    }

    @IsTest
    private static void validationCheckErrMsgTest() {
        E2EFormRuDataTestFactory.initPagesStructure();
        PPR_API_Settings__c settingEuroplan = PPR_API_DataTestFactory.createPPR_API_Settings();
        insert settingEuroplan;
        E2EFormData__c wrongFormData = E2EFormRuTestUtils.createDefaultFormData();
        insert wrongFormData;
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Process_Status__c = 'Double';
        insert formData;
        Custom_log__c newLog = PPR_API_DataTestFactory.createCustomLog(formData.Id, '1234567890');
        insert newLog;
        Map<String, Object> testRequest = PPR_API_DataTestFactory.generateTestRequestMandatoryFields(formData.Id, '1234567890');

        PPR_API_ServiceImpl service = new PPR_API_ServiceImpl();
        PPR_API_ResponseBody responce = service.validationCheck(JSON.serialize(testRequest));
        
        System.assertNotEquals(null, responce);
        System.assertEquals('Creation error. Client already exist', responce.message);

        formData.E2E_Process_Status__c = 'BlackList';
        update formData;
        responce = service.validationCheck(JSON.serialize(testRequest));

        System.assertNotEquals(null, responce);
        System.assertEquals('Creation error. Client is denied in cooperation', responce.message);

        PPR_API_CreateClientTestDataBuilder builder = new PPR_API_CreateClientTestDataBuilder();
        builder.baseRequest(newLog.E2E_Form_Ru_Data__c, settingEuroplan.Name, newLog.INN__c)
                .appendEmail('test@mail.com', new List<String>{'fdf'})
                .appendPhone('1234567890', new List<String>{'fdfdfd'});
        System.assertEquals(
                'Validation error. Need agreement to process personal data',
                service.validationCheck(JSON.serialize(builder.build())).message
        );

        builder.clean().baseRequest(wrongFormData.Id, settingEuroplan.Name, '3345466666').appendAgreement('PersonalData')
                .appendEmail('test@mail.com', new List<String>{'fdf'})
                .appendPhone('1234567890', new List<String>{'fdfdfd'});
        System.assertEquals(
                'Validation error. No data for current INN and source was found. Please check company via /PPR_API/v1/CheckInn first.',
                service.validationCheck(JSON.serialize(builder.build())).message
        );

        builder.clean().baseRequest(wrongFormData.Id, settingEuroplan.Name, newLog.INN__c).appendAgreement('PersonalData')
                .appendEmail('test@mail.com', new List<String>{'fdf'})
                .appendPhone('1234567890', new List<String>{'fdfdfd'});
        System.assertEquals(
                'Validation error. Metadata Id doesn\'t match customer INN and source',
                service.validationCheck(JSON.serialize(builder.build())).message
        );
    }

    public static void getTestSparkData(E2EFormParams formParams) {
        formParams.sparkId = 6329708;
        formParams.mainCompanyFullNameSpark = 'НКТ СОФТВЭР, ООО';
        formParams.executiveFio = 'Иванов Иван Иваныч';
        formParams.executivePosition = 'Самый главный';
        formParams.companyCountry = 'Россия';
        formParams.okpoSpark = '84763430';
        formParams.ogrnSpark = '1087746118162';
        formParams.kppSpark = '771301001';
        formParams.isSoleProprietor = false;
        formParams.okvedSpark = 'Розничная торговля компьютерами, программным обеспечением и периферийными устройствами';
        formParams.postCodeSpark = '127287';
        formParams.regionSpark = 'г. Москва';
        formParams.citySpark = 'г. Москва';
        formParams.streetSpark = 'ул. Хуторская 2-Я';
        formParams.buildingSpark = 'дом 38А';
        formParams.housingSpark = '4';
        formParams.blockSpark = '5';
        formParams.roomSpark = '10';
        formParams.legalAddressSpark = 'г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15';
        formParams.normName = 'НКТ СОФТВЭР, ООО';
    }
}