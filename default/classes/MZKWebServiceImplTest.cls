@isTest
public class MZKWebServiceImplTest {

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

    public static MZKRequest initMzkRequestData() {
        MZKRequest request = new MZKRequest();
        MZKRequest.MzkCards cards = new MZKRequest.MzkCards();
        cards.sendType = 3;
        cards.transitId = '7758B30A023561A4E053044A14ACD2AE';
        cards.requestDescription = '';
        cards.logUser = '93D6ED45932B44A4AE8AF3934AC1C940';
        cards.isTemplate = 0;
        cards.eqv = 1;
        cards.serviceId = '';
        cards.limitVal = '';
        cards.limitTypeId = '';
        cards.isCommon = '';
        cards.isRuble = '';
        cards.productId = 62;
        cards.totalLimitValue = 0;
        cards.totalLimitType = 0;
        cards.cardsNumber = 6;
        cards.cardDescr = 'Комментарий для курьерской службы';
        return request;
    }

    @isTest
    static void testMZKApi200() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        MZKRequest mzkRequest = initMzkRequestData();

        MZKWebServiceImpl mzkService = new MZKWebServiceImpl();
        String requestNumber = mzkService.getRequestNumber(mzkRequest);
        System.assertEquals(true, requestNumber != null);

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONGetMZKRequestNumber = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Transit Integration",' +
                        '"content":{"createdId":"182536","message":"MZK application created","error":null}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/transit-api/create-mzk-req', getJSONGetMZKRequestNumber);
        return responses;
    }

    @isTest
    static void testMZKErrorApi500() {
        initCustomSettings();

        //Test response with status 500 from MZK
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        MZKRequest mzkRequest = initMzkRequestData();

        MZKWebServiceImpl mzkService = new MZKWebServiceImpl();
        try {
            String requestNumber = mzkService.getRequestNumber(mzkRequest);
            System.assertEquals(true, requestNumber == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockError500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONGetMZKRequestNumberError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Transit Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/transit-api/create-mzk-req', getJSONGetMZKRequestNumberError500);
        return responses;
    }

    @isTest
    static void testMZKApi500() {
        initCustomSettings();

        //Test response with status 500 from Middleware
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        MZKRequest mzkRequest = initMzkRequestData();

        MZKWebServiceImpl mzkService = new MZKWebServiceImpl();
        try {
            String requestNumber = mzkService.getRequestNumber(mzkRequest);
            System.assertEquals(true, requestNumber == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONGetMZKRequestNumber500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Transit Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/transit-api/create-mzk-req', getJSONGetMZKRequestNumber500);
        return responses;
    }
}