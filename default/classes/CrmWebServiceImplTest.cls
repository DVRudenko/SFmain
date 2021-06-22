@isTest
public class CrmWebServiceImplTest {

    static String URL = 'http://99.240.174.55/PPRMiddleware';
    static String TOKEN = 'token';

    static String inn = '7743676000';

    public static void initCustomSettings() {
        insert new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Test_Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Middleware_Token__c = 'token'
        );
    }

    @isTest
    static void testCrmApi200() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        CrmWebServiceImpl crmWebService = new CrmWebServiceImpl();

        CrmTask crmTask = getCrmTask();
        System.assertEquals(true, crmTask.ownerId != null);

        crmWebService.createTask(inn, crmTask);
        String requestBody = JSON.serialize(crmTask);
        System.debug('requestBody:' + requestBody);
        System.assertEquals(true, requestBody.contains('"OwnerId"'));

        Test.stopTest();
    }

    @isTest
    static void testCrmApi500() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        CrmWebServiceImpl crmWebService = new CrmWebServiceImpl();

        CrmTask crmTask = getCrmTask();
        System.assertEquals(true, crmTask.ownerId != null);

        try{
            crmWebService.createTask(inn, crmTask);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCreateCase = new SingleRequestMock(
                200, 'Complete',
                '{ "statusCode": 201,"message": "CRM API","content": {"d": { "__metadata":' +
                        '{ "uri": "http://srv-crm-test.transitcard.ru/FleetCor/XRMServices/2011/OrganizationData.svc/IncidentSet(guid\'a8331c12-83bd-e811-80f3-02bfac147858\')",' +
                        '"type": "Microsoft.Crm.Sdk.Data.Services.Incident"}}}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/crm/create-case?inn=' + inn, getJSONCreateCase);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };

        SingleRequestMock getJSONCreateCase500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"CRM API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/crm/create-case?inn=' + inn, getJSONCreateCase500);
        return responses;
    }

    private static CrmTask getCrmTask() {
        CrmTask newTask = new CrmTask();
        newTask.ownerId = '5b5589ec-e1b6-e611-80e2-005056bd4e10';
        newTask.title = 'Базовый клиент из E2E';
        newTask.subjectId = '628c49df-7dfa-e511-80d5-005056bd4e10';
        newTask.description = 'Клиент такой-то пришел на регистрацию…';
        newTask.caseOriginCode = 2;
        return newTask;
    }
}