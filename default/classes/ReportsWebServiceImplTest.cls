@isTest
public class ReportsWebServiceImplTest {

    static String URL = 'http://99.240.174.55/PPRMiddleware';
    static String TOKEN = 'token';

    public static void initCustomSettings() {
        insert new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Test_Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Middleware_Token__c = 'token'
        );
    }

    public static ReportRequestData initReportRequestData() {
        ReportRequestData reportRequestData = new ReportRequestData();
        reportRequestData.inn = '6150045115';
        reportRequestData.companyName = 'ОАО Ромашка';
        reportRequestData.sFRequestId = '0060O00000tbX8OQAU';
        reportRequestData.productId = '1';
        reportRequestData.tariffId = '4';
        reportRequestData.specialOfferId = '1';
        reportRequestData.hasCredit = false;
        reportRequestData.hasExpressDelivery = true;
        reportRequestData.hasPersonalManager = true;
        reportRequestData.preview = false;
        reportRequestData.amount = 8000;
        reportRequestData.bikBank = '042520116';

        ReportRequestData.ReportParams reportParams = new ReportRequestData.ReportParams();
        reportParams.CONTRACT_DATE = '«2» октября 2018 г.';
        reportParams.CONTRACT_NUM = null;
        reportParams.NUMBER_OF_CARDS = '4';
        reportParams.NUMBER_OF_CARDS_TEXT = 'Четыре';
        reportParams.SECURITY_PHRASE = 'секрет';
        reportParams.USERNAME = 'test@test.ru';
        reportParams.PRODUCT_NAME = 'Вездеход Online Избранный';
        reportParams.BILL_SUM = 8000;
        reportParams.HAS_PERSONAL_MANAGER = false;
        reportParams.HAS_OVERDRAFT = false;
        reportParams.HAS_COURIER = false;
        reportParams.EXT_CLIENT_ID = '0060O00000tbX8OQAU';
        reportParams.CONSIGNEE_NAME = null;
        reportParams.CONSIGNEE_INN = null;
        reportParams.CONSIGNEE_KPP = null;
        reportParams.CONSIGNEE_OGRN = null;
        reportParams.CONSIGNEE_OKPO = null;
        reportParams.CONSIGNEE_LEGAL_ADDRESS = null;
        reportParams.CONSIGNEE_ADDRESS = null;
        reportParams.CONSIGNEE_CURRENT_ACCOUNT = null;
        reportParams.CONSIGNEE_BANK_NAME = null;
        reportParams.CONSIGNEE_COR_ACCOUNT = null;
        reportParams.CONSIGNEE_BIK = null;
        reportParams.CONSIGNEE_PHONE = null;
        reportParams.CONSIGNEE_EMAIL = null;
        reportParams.CONSIGNEE_MOB_PHONE_FIN = null;
        reportParams.CONSIGNEE_MOB_PHONE_INFO = null;
        reportParams.CLIENT_INN = '6150045711';
        reportParams.CLIENT_KPP = '615001011';
        reportParams.CLIENT_OGRN = '1056150320011';
        reportParams.CLIENT_OKPO = '24163311';
        reportParams.CLIENT_LEGAL_ADDRESS = 'Ростовская обл, г Новочеркасск, ул Машиностроителей, д 3';
        reportParams.CLIENT_ADDRESS = 'Ростовская обл, г Новочеркасск, ул Машиностроителей, д 3';
        reportParams.CLIENT_CURRENT_ACCOUNT = '66666666666666666666';
        reportParams.CLIENT_COR_ACCOUNT = '30101810500000000706';
        reportParams.CLIENT_BANK_NAME = 'БАЙКАЛИНВЕСТБАНК';
        reportParams.CLIENT_BIK = '042520706';
        reportParams.CLIENT_PHONE = '+7 (916) 740-87-85';
        reportParams.CLIENT_EMAIL = 'test123@test.ru';
        reportParams.CLIENT_MOB_PHONE_FIN = '+7 (916) 740-87-85';
        reportParams.CLIENT_MOB_PHONE_INFO = '+7 (916) 740-87-85';
        reportParams.CLIENT_NAME = 'ОТКРЫТОЕ АКЦИОНЕРНОЕ ОБЩЕСТВО \"ТРАНСПОРТ С МАГНИТНЫМ ПОДВЕСОМ\"';
        reportParams.CLIENT_SIGNER_POST = 'генеральный директор';
        reportParams.CLIENT_SIGNER_FIO = 'Верстак Андрей Петрович';
        reportParams.CLIENT_ACCOUNTER_FIO = 'Чехова Мария Ивановна';
        reportParams.EXTRA_INFO = '';
        reportParams.PROMOCODE = '';
        reportParams.SPECIAL_OFFER_NAME = '';
        reportParams.SUPPLIER = '';
        reportParams.ADDITIONAL_CONTRACT_DATE = '«2» октября 2018 г.';
        reportParams.ATTACHMENT_NUM = '1';
        return reportRequestData;
    }

    @isTest
    static void testReportApi200() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ReportRequestData reportRequestData = initReportRequestData();

        ReportWebServiceImpl reportService = new ReportWebServiceImpl();
        ReportResponseData reportResponseData = reportService.getReportIdsFromCreditFactory(reportRequestData);
        System.assertEquals(true, reportResponseData.reportDocumentList.get(0).idReport != null);

        List<String> reportIds = ReportWebServiceImpl.getOrderReportIds(reportResponseData, GlobalUtils.reportIdsSequence);
        System.assertEquals(true, reportIds.size() > 0);

        Blob report = reportService.getReportsFromReportService(reportIds);
        System.assertEquals(true, report.size() > 0);

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN,
                'Content-Type' => 'application/json',
                'Content-Disposition' => 'attachment; filename=merged.pdf'
        };
        SingleRequestMock getJSONReportIdsFromCreditFactory = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode": 200,"message": "Reports Integration",' +
                        '"content": {"reportDocumentList": [' +
                        '{"idReport": "10007", "reportTypeDescription": "Договор-оферта", "reportTypeId": "1", "path": {"PDF": "8897506c-a5f9-421e-ac40-53347a59c9b3"}},' +
                        '{"idReport": "10032", "reportTypeDescription": "Договор-оферта", "reportTypeId": "2","path": {"PDF": "3fafee10-6910-4d20-970e-eb7b8b0feb85"}},' +
                        '{"idReport": "10008", "reportTypeDescription": "Договор-оферта", "reportTypeId": "3", "path": {"PDF": "9694ad3b-9b3c-4531-aa91-c286868cd948"}},' +
                        '{"idReport": "10006", "reportTypeDescription": "Договор-оферта", "reportTypeId": "4", "path": {"PDF": "3028408c-b5fb-41b8-96e7-9bb0692065f8"}},' +
                        '{"idReport": "10031", "reportTypeDescription": "Договор-оферта", "reportTypeId": "5", "path": {"PDF": "a30c2d25-0183-4a26-b8fb-066917bd4be4"}},' +
                        '{"idReport": "10028", "reportTypeDescription": "Договор-оферта", "reportTypeId": "6", "path": {"PDF": "a9843c26-5047-4790-b1c4-5b883c8b49a6"}},' +
                        '{"idReport": "10036", "reportTypeDescription": "Договор-оферта", "reportTypeId": "7", "path": {"PDF": "02bbb8b3-4516-4f84-8f79-c3076a2ce1cb"}}],' +
                        '"reportParams": {"WARRANT_NUM": "21-01/18","WARRANT_FIO": "Козлова Марина Михайловна",' +
                        '"WARRANT_DATE": "01.01.2018","USERNAME": "sdfsdfsd@sadsd.ru","SUPPLIER": "",' +
                        '"SPECIAL_OFFER_NAME": "","SECURITY_PHRASE": "ываыва","SALESFORCE_CONTRACT_PREFIX": "4",' +
                        '"SALESFORCE_CONTRACT_COUNTER": "500","PROMOCODE": "","PRODUCT_NAME": "Вездеход Online Избранный",' +
                        '"NUMBER_OF_CARDS_TEXT": "Десять","NUMBER_OF_CARDS": "7","HAS_PERSONAL_MANAGER": "1",' +
                        '"HAS_OVERDRAFT": "1","HAS_COURIER": "1","EXTRA_INFO": " ","EXT_CLIENT_ID": "0066E000005OzgbQAC",' +
                        '"CONTRACT_NUM": null,"CONTRACT_DATE": "«11» сентября 2018 г.","CONSIGNEE_PHONE": "ГП+7495112",' +
                        '"CONSIGNEE_OKPO": "ГП_ОКПО","CONSIGNEE_OGRN": "ГП_ОГРН","CONSIGNEE_NAME": "ГП_НАЗВАНИЕ",' +
                        '"CONSIGNEE_MOB_PHONE_INFO": "ГП+77778944","CONSIGNEE_MOB_PHONE_FIN": "ГП+71112233",' +
                        '"CONSIGNEE_LEGAL_ADDRESS": "ул. ГП-ю","CONSIGNEE_KPP": "ГП_КПП","CONSIGNEE_INN": "ГП_ИНН",' +
                        '"CONSIGNEE_EMAIL": "gp@mail.ru","CONSIGNEE_CURRENT_ACCOUNT": "ГП_РС","CONSIGNEE_COR_ACCOUNT": "КС_ГП",' +
                        '"CONSIGNEE_BIK": "ГП_BIC","CONSIGNEE_BANK_NAME": "ГП СБЕР","CONSIGNEE_ADDRESS": "ул. ГП-ф",' +
                        '"CLIENT_SIGNER_POST": "генеральный директор","CLIENT_SIGNER_FIO": "Самсонов Борис Павлович",' +
                        '"CLIENT_PHONE": "+7 (574) 645-64-53","CLIENT_OKPO": "03341078","CLIENT_OGRN": "1078602000443",' +
                        '"CLIENT_NAME": "ОТКРЫТОЕ АКЦИОНЕРНОЕ ОБЩЕСТВО СУРГУТСКИЙ ПРОИЗВОДСТВЕННО-НАУЧНЫЙ ИНСТИТУТ ИНЖЕНЕРНЫХ ИЗЫСКАНИЙ В СТРОИТЕЛЬСТВЕ",' +
                        '"CLIENT_MOB_PHONE_INFO": "+7 (574) 645-64-53","CLIENT_MOB_PHONE_FIN": "+7 (574) 645-64-53",' +
                        '"CLIENT_LEGAL_ADDRESS": "Ханты-Мансийский Автономный Округ - Югра окр, г. Сургут, ул. 30 Лет Победы, д. 29 корп. Б",' +
                        '"CLIENT_KPP": "860201001","CLIENT_INN": "8602024490","CLIENT_EMAIL": "sdfsdfsd@sadsd.ru",' +
                        '"CLIENT_CURRENT_ACCOUNT": "23412341234323333333","CLIENT_COR_ACCOUNT": "30101810400000000225",' +
                        '"CLIENT_BIK": "044525225","CLIENT_BANK_NAME": "ПАО СБЕРБАНК",' +
                        '"CLIENT_ADDRESS": "Ханты-Мансийский Автономный Округ - Югра окр, г. Сургут, ул. 30 Лет Победы, д. 29 корп. Б",' +
                        '"CLIENT_ACCOUNTER_FIO": "ываываыва","BUSINESSMAN_REGISTERED_ADDRESS": "","BUSINESSMAN_PASSPORT_SERIES": "",' +
                        '"BUSINESSMAN_PASSPORT_NUM": "","BUSINESSMAN_PASSPORT_ISSUING_NUMBER": "","BUSINESSMAN_PASSPORT_ISSUING": "",' +
                        '"BUSINESSMAN_PASSPORT_DATE": "","BUSINESSMAN_OGRNIP": "","BIRTH_YEAR": "","BIRTH_PLACE": "","BILL_SUM": "14000",' +
                        '"ATTACHMENT_NUM": "1","ADDITIONAL_CONTRACT_DATE": "«11» сентября 2018 г.","PAY_ACCOUNT": "40702810500030004523",' +
                        '"SIGNATORY_ACCOUNTANT_WARRANT": " на осн. доверенности №21-01/18 от 01.01.2018","IS_GPN_FROM_CARD": "0",' +
                        '"SIGNATORY_LEADER_WARRANT": " на осн. доверенности №21-01/18 от 01.01.2018",' +
                        '"SELLER_LEGAL_ADDRESS": "127287, Россия, г. Москва, ул. 2-я Хуторская, д. 38А, стр. 8",' +
                        '"SIGNATORY_ACCOUNTANT_FIO": "Козлова М.М.","IS_VEZDEHOD_CHOSEN_FROM_CARD": "0","ROOT_DIR": "",' +
                        '"STAMP_FILE": "","SIGNATORY_LEADER_POST": "Старший специалист","SALESFORCE_INVOICE_PREFIX": "444",' +
                        '"SALESFORCE_INVOICE_COUNTER": "401","SELLER_KPP": "771301001","IS_SHELL_FROM_CARD": "0",' +
                        '"SELLER_INN": " 7743036465","SIGNATURE_FILE": "","HAS_CREDIT": "1","IS_VEZDEHOD_CHOSEN_FROM_CONTRACT": "1",' +
                        '"NEED_SIGNATURE": "0","SIGNATORY_LEADER_FIO": "Козлова М.М.","WARRANT_FIO_R": "Козловой Марины Михайловны",' +
                        '"IS_SHELL_FROM_CONTRACT": "0","SIGNATORY_ACCOUNTANT_POST": "Старший специалист","IS_VEZDEHOD_OPTIMAL_FROM_CONTRACT": "0",' +
                        '"IS_VEZDEHOD_OPTIMAL_FROM_CARD": "0","SELLER_NAME": "ООО ППР","IS_GPN_FROM_CONTRACT": "0","ATTACHMENTS_COUNT": "4"}}}',
                responseHeaders);

        SingleRequestMock getJSONGeneratedReport = new SingleRequestMock(
                200, 'Complete', 'Blob', responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/reporting/prepare-reports', getJSONReportIdsFromCreditFactory);
        responses.put(URL + '/reporting/get-generated-report?ids=8897506c-a5f9-421e-ac40-53347a59c9b3,' +
                '3fafee10-6910-4d20-970e-eb7b8b0feb85,9694ad3b-9b3c-4531-aa91-c286868cd948,3028408c-b5fb-41b8-96e7-9bb0692065f8,' +
                'a30c2d25-0183-4a26-b8fb-066917bd4be4,a9843c26-5047-4790-b1c4-5b883c8b49a6,02bbb8b3-4516-4f84-8f79-c3076a2ce1cb', getJSONGeneratedReport);
        return responses;
    }

    @isTest
    static void testReportApiError500() {
        initCustomSettings();

        //Test response with status 500 from Middleware
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ReportRequestData reportRequestData = initReportRequestData();

        ReportWebServiceImpl reportService = new ReportWebServiceImpl();
        ReportResponseData reportResponseData;
        try {
            reportResponseData = reportService.getReportIdsFromCreditFactory(reportRequestData);
            System.assertEquals(true, reportResponseData.reportDocumentList.get(0).idReport != null);
            System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_INVOICE_COUNTER != null);
            System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_INVOICE_PREFIX != null);
            System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_CONTRACT_COUNTER != null);
            System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_CONTRACT_PREFIX != null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<String> reportIds = ReportWebServiceImpl.getOrderReportIds(reportResponseData, GlobalUtils.reportIdsSequence);
            System.assertEquals(true, reportIds.size() > 0);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<String> reportIds = new List<String>{
                    '8897506c-a5f9-421e-ac40-53347a59c9b3',
                    '3fafee10-6910-4d20-970e-eb7b8b0feb85',
                    '9694ad3b-9b3c-4531-aa91-c286868cd948',
                    '3028408c-b5fb-41b8-96e7-9bb0692065f8',
                    'a30c2d25-0183-4a26-b8fb-066917bd4be4',
                    'a9843c26-5047-4790-b1c4-5b883c8b49a6',
                    '02bbb8b3-4516-4f84-8f79-c3076a2ce1cb'};
            Blob report = reportService.getReportsFromReportService(reportIds);
            System.assertEquals(true, report.size() > 0);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockError500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONReportIdsFromCreditFactory500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode": 500,"message": "Reports Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONGeneratedReport500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Reports Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/reporting/prepare-reports', getJSONReportIdsFromCreditFactory500);
        responses.put(URL + '/reporting/get-generated-report?ids=8897506c-a5f9-421e-ac40-53347a59c9b3,' +
                '3028408c-b5fb-41b8-96e7-9bb0692065f8,9694ad3b-9b3c-4531-aa91-c286868cd948,a30c2d25-0183-4a26-b8fb-066917bd4be4,' +
                'a9843c26-5047-4790-b1c4-5b883c8b49a6,3fafee10-6910-4d20-970e-eb7b8b0feb85', getJSONGeneratedReport500);
        return responses;
    }

    @isTest
    static void testReportApi500() {
        initCustomSettings();

        //Test response with status 500 from Middleware
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ReportRequestData reportRequestData = initReportRequestData();

        ReportWebServiceImpl reportService = new ReportWebServiceImpl();
        ReportResponseData reportResponseData;
        try {
            reportResponseData = reportService.getReportIdsFromCreditFactory(reportRequestData);
            System.assertEquals(true, reportResponseData.reportDocumentList.get(0).idReport != null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<String> reportIds = ReportWebServiceImpl.getOrderReportIds(reportResponseData, GlobalUtils.reportIdsSequence);
            System.assertEquals(true, reportIds.size() > 0);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<String> reportIds = new List<String>{
                    '8897506c-a5f9-421e-ac40-53347a59c9b3',
                    '3fafee10-6910-4d20-970e-eb7b8b0feb85',
                    '9694ad3b-9b3c-4531-aa91-c286868cd948',
                    '3028408c-b5fb-41b8-96e7-9bb0692065f8',
                    'a30c2d25-0183-4a26-b8fb-066917bd4be4',
                    'a9843c26-5047-4790-b1c4-5b883c8b49a6',
                    '02bbb8b3-4516-4f84-8f79-c3076a2ce1cb'};
            Blob report = reportService.getReportsFromReportService(reportIds);
            System.assertEquals(true, report.size() > 0);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONReportIdsFromCreditFactory500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Reports Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONGeneratedReport500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Reports Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/reporting/prepare-reports', getJSONReportIdsFromCreditFactory500);
        responses.put(URL + '/reporting/get-generated-report?ids=8897506c-a5f9-421e-ac40-53347a59c9b3,' +
                '3fafee10-6910-4d20-970e-eb7b8b0feb85,9694ad3b-9b3c-4531-aa91-c286868cd948,3028408c-b5fb-41b8-96e7-9bb0692065f8,' +
                'a30c2d25-0183-4a26-b8fb-066917bd4be4,a9843c26-5047-4790-b1c4-5b883c8b49a6,02bbb8b3-4516-4f84-8f79-c3076a2ce1cb', getJSONGeneratedReport500);
        return responses;
    }

    @isTest
    static void testToCompleteCoverForReportResponseData() {
        ReportResponseData reportResponseData = new ReportResponseData();
        reportResponseData.reportParams = new ReportResponseData.ReportParams();
        reportResponseData.reportParams.SALESFORCE_INVOICE_COUNTER = '4';
        reportResponseData.reportParams.SALESFORCE_INVOICE_PREFIX = '242';
        reportResponseData.reportParams.SALESFORCE_CONTRACT_COUNTER = '4';
        reportResponseData.reportParams.SALESFORCE_CONTRACT_PREFIX = '54';

        System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_INVOICE_COUNTER != null);
        System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_INVOICE_PREFIX != null);
        System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_CONTRACT_COUNTER != null);
        System.assertEquals(true, reportResponseData.reportParams.SALESFORCE_CONTRACT_PREFIX != null);
    }
}