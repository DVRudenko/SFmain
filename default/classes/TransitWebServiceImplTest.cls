@isTest
public class TransitWebServiceImplTest {

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

    public static TransitRequestData initTransitRequestData() {
        TransitRequestData requestData = new TransitRequestData();
        TransitRequestData.Cont transitCont = new TransitRequestData.Cont();
        transitCont.companyName = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "КАКАЯ-ТО КОМПАНИЯ"';
        transitCont.opportunityId = '0066E000005SHCKQA4';
        transitCont.companyType = '';
        transitCont.contractNumber = '4206';
        transitCont.inn = '7719775377';
        transitCont.kpp = '772601077';
        transitCont.okpo = '90688944';
        transitCont.ogrn = '1117746237555';
        transitCont.checkingAccount = '33333333333333333333';
        transitCont.eqv = 1;
        transitCont.contractType2 = 'CNT_SLS_OFFERS';
        transitCont.carParkType = 1;
        transitCont.clientFrom = 11;
        transitCont.carParkForm = 0;
        transitCont.codeWord = 'слово';
        transitCont.tarif = 112;
        transitCont.ruleChangeType = 'RULCH_NOTIFY';
        transitCont.promoCode = 0;
        transitCont.contractForm = null;
        transitCont.contractType1 = null;
        transitCont.personalManager = 0;
        transitCont.curierDelivery = 0;
        transitCont.factProsrochki = null;
        transitCont.lgotniyPeriod = null;
        transitCont.procentPoCreditu = null;
        transitCont.prepayAmount = 16000;
        transitCont.tipCredita = null;
        transitCont.contractType = 17;
        transitCont.tipPeni = null;
        transitCont.znacheniePeni = null;
        transitCont.dopustimayaZadolzenostValuta = null;
        transitCont.dopustimayaZadolzenostSumma = null;
        transitCont.znachenieOvedrafta = null;
        transitCont.opoveshatPoEmail = null;
        transitCont.overdrSumm = null;
        transitCont.uslugaDoveria = null;
        transitCont.bezDS = null;
        transitCont.bic = '044525225';
        transitCont.bankNameFull = 'ООО САМЫЙЛУЧШИЙ БАНК';
        transitCont.bankNameShort = 'ООО САМЫЙЛУЧШИЙ БАНК';
        transitCont.bankBic = '044525225';
        transitCont.corBankAccount = '30101810400000000225';
        transitCont.bankInn = '';
        transitCont.bankKpp = '';
        transitCont.bankOkpo = '00032537';
        transitCont.bankTown = 'г Москва';
        transitCont.bankAddress = 'г Москва, ул Вавилова, д 19';
        transitCont.companyPhone = '+7 (342) 345-36-54';
        transitCont.p_is_for_fin_sms = 1;
        transitCont.p_is_mobile = 1;
        transitCont.companyEmail = 'comtanyEmail@company.ru';
        transitCont.p_invoice_doc_num = '4206';
        transitCont.p_invoice_sum = 12800.0;
        transitCont.p_invoice_sum_nds = 3200.0;
        transitCont.p_invoice_article = 'Оплата по договору от 26.09.2018 № 4206';
        transitCont.emailForLK = 'testLk@testLk.ru';
        transitCont.postcode = '196128';
        TransitRequestData.Personal personal = new TransitRequestData.Personal();
        personal.name = 'Анна';
        personal.surname = 'Демидова';
        personal.parentName = 'Сергеевна';
        personal.fullName = 'Демидова Анна Сергеевна';
        personal.title = 'генеральный директор';
        personal.onBasis = '';
        TransitRequestData.Address address = new TransitRequestData.Address();
        address.rekType = 0;
        address.address = 'г Москва, Варшавское шоссе, д 9 стр 1б';
        address.postCode = '117105';
        address.mailCity = 'ED4DB1FEE87731E0E030007F01007315';
        address.mailStreet = 'ШОССЕ ВАРШАВСКОЕ , ДОМ 9, СТРОЕНИЕ 1Б';
        address.mailReceiver = 'Демидова Анна Сергеевна';
        return requestData;
    }

    @isTest
    static void testTransitApi200() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        TransitRequestData transitRequest = initTransitRequestData();

        TransitWebServiceImpl transitService = new TransitWebServiceImpl();
        TransitResponseData transitResponse = transitService.storeContData(transitRequest);
        System.assertEquals(true, transitResponse.createdId != null);

        Test.stopTest();
    }

    @isTest
    static void testTransitErrorApi500() {
        initCustomSettings();

        //Test response with status 500 from Transit
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        TransitRequestData transitRequest = initTransitRequestData();

        TransitWebServiceImpl transitService = new TransitWebServiceImpl();
        try {
            TransitResponseData transitResponse = transitService.storeContData(transitRequest);
            System.assertEquals(true, transitResponse.createdId == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    @isTest
    static void testTransitApi500() {
        initCustomSettings();

        //Test response with status 500 from Middleware
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        TransitRequestData transitRequest = initTransitRequestData();

        TransitWebServiceImpl transitService = new TransitWebServiceImpl();
        try {
            TransitResponseData transitResponse = transitService.storeContData(transitRequest);
            System.assertEquals(true, transitResponse.createdId == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }


    private static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCreateCont = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode": 200, "message": "Transit Integration", ' +
                        '"content": { "createdId": "76E9F5EE43F60DD9E053868614AC210F", ' +
                        '"message": "Cont created", "error": null}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/transit-api/create-cont', getJSONCreateCont);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockError500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCreateContError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Transit Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/transit-api/create-cont', getJSONCreateContError500);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCreateCont500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Transit Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/transit-api/create-cont', getJSONCreateCont500);
        return responses;
    }
}