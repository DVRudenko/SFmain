@IsTest
public with sharing class CardsRangeWebServiceImplTest {

    static {
        E2EFormRuTestUtils.initCustomSettings();
    }


    @IsTest
    public static void testCardsRangeApi200() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(getResponseMockMap200()));
        CardsRangeWebService cardsRangeWebService = new CardsRangeWebServiceImpl();
        List<Map<String, Object>> cards = cardsRangeWebService.getEntities('Cards', null);
        System.assertEquals(2, cards.size());
        System.assertEquals('4001696969', String.valueOf(cards.get(1).get('number')));

        List<String> queryOptions = new List<String>();
        queryOptions.add('$select=id,number');
        Map<String, Object> card = cardsRangeWebService.getEntity('Cards', '1337f71a-81b2-11ea-a527-6bba62241001', queryOptions);
        System.assertEquals('1111', (String) card.get('number'));
        System.assertEquals('1337f71a-81b2-11ea-a527-6bba62241001', (String) card.get('id'));
        System.assertEquals(null, (Boolean) card.get('is_active'));

        cardsRangeWebService.updateEntity('Cards', '1337f71a-81b2-11ea-a527-6bba62241001', new Map<String, Object>());

        Map<String, Map<String, Object>> idDataMap = new Map<String, Map<String, Object>>();
        idDataMap.put('1337f71a-81b2-11ea-a527-6bba62241001', new Map<String, Object> {
                'is_issued' => true
        });
        cardsRangeWebService.updateEntities('Cards', idDataMap);

        idDataMap.put('4856f71a-81b2-11ea-a527-6bba62241001', new Map<String, Object> {
                'is_active' => false
        });
        cardsRangeWebService.updateEntities('Cards', idDataMap);
        Test.stopTest();
    }

    @IsTest
    public static void testCardsRangeApi500() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(getResponseMockMap500()));
        CardsRangeWebService cardsRangeWebService = new CardsRangeWebServiceImpl();
        try {
            cardsRangeWebService.getEntities('Cards', new List<String>());
        } catch (Exception e) {
            System.assert(e.getMessage().contains('CardsRangeWebServiceImpl getEntities: 500'));
        }
        try {
            List<String> queryOptions = new List<String>();
            queryOptions.add('$select=id,number');
            cardsRangeWebService.getEntity('Cards', '1337f71a-81b2-11ea-a527-6bba62241001', queryOptions);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('CardsRangeWebServiceImpl getEntity: 500'));
        }
        try {
            cardsRangeWebService.updateEntity('Cards', '1337f71a-81b2-11ea-a527-6bba62241001', new Map<String, Object>());
        } catch (Exception e) {
            System.assert(e.getMessage().contains('CardsRangeWebServiceImpl updateEntity: 500'));
        }
        try {
            cardsRangeWebService.updateEntities('Cards', new Map<String, Map<String, Object>>());
        } catch (Exception e) {
            System.assert(e.getMessage().contains('CardsRangeWebServiceImpl updateEntities: 500'));
        }
        Test.stopTest();
    }

    @IsTest
    private static void testExceptions() {
        CardsRangeWebServiceImpl cardsRangeWebService = new CardsRangeWebServiceImpl();
        try {
            cardsRangeWebService.buildBatchChangeSet(CardsRangeWebServiceImpl.HttpMethod.GET, new List<String>(), 'Cards', '271337f71a-81b2-11ea-a527-6bba62241001', '{}');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('change set builder for GET request not implemented'));
        }

        String changeSet = cardsRangeWebService.buildBatchChangeSet(CardsRangeWebServiceImpl.HttpMethod.POST, null, '  ', '  ', '  ');
        System.assertEquals('', changeSet);
    }


    public static Map<String, HttpCalloutMock> getResponseMockMap200() {
        Map<String, HttpCalloutMock> responseMockMap = new Map<String, HttpCalloutMock>();
        responseMockMap.put(CardsRangeWebServiceImpl.uri + 'Cards?$format=application/json', new SingleRequestMock(
                200,
                'OK',
                '{"@odata.context":"$metadata#Cards","value":[{"is_issued":true,"timestamp_created":"2020-04-04T14:31:16.52501Z","number":"1111","is_active":true,"id":"1337f71a-81b2-11ea-a527-6bba62241001","timestamp_issued":null},{"is_issued":true,"timestamp_created":"2020-04-03T16:53:44.17511Z","number":"4001696969","is_active":true,"id":"1337f71a-81b2-11ea-a527-6bba62241001","timestamp_issued":"2020-04-04T16:55:44.17511Z"}]}',
                null)
        );
        responseMockMap.put(CardsRangeWebServiceImpl.uri + 'Cards(%271337f71a-81b2-11ea-a527-6bba62241001%27)?$format=application/json&$select=id,number', new SingleRequestMock(
                200,
                'OK',
                '{"@odata.context":"$metadata#Cards(number,id)/$entity","number":"1111","id":"1337f71a-81b2-11ea-a527-6bba62241001"}',
                null)
        );
        responseMockMap.put(CardsRangeWebServiceImpl.uri + 'Cards(%271337f71a-81b2-11ea-a527-6bba62241001%27)', new SingleRequestMock(
                204,
                'No Content',
                '',
                null)
        );
        responseMockMap.put(CardsRangeWebServiceImpl.uri + '$batch', new SingleRequestMock(
                202,
                'Accepted',
                '',
                null
        ));
        return responseMockMap;
    }

    public static Map<String, HttpCalloutMock> getResponseMockMap500() {
        Map<String, HttpCalloutMock> responseMockMap = new Map<String, HttpCalloutMock>();
        responseMockMap.put(CardsRangeWebServiceImpl.uri + 'Cards?$format=application/json', new SingleRequestMock(
                500,
                'Internal server error',
                '',
                null)
        );
        responseMockMap.put(CardsRangeWebServiceImpl.uri + 'Cards(%271337f71a-81b2-11ea-a527-6bba62241001%27)?$format=application/json&$select=id,number', new SingleRequestMock(
                500,
                'Internal server error',
                '',
                null)
        );
        responseMockMap.put(CardsRangeWebServiceImpl.uri + 'Cards(%271337f71a-81b2-11ea-a527-6bba62241001%27)', new SingleRequestMock(
                500,
                'Internal server error',
                '',
                null)
        );
        responseMockMap.put(CardsRangeWebServiceImpl.uri + '$batch', new SingleRequestMock(
                500,
                'Internal server error',
                '',
                null
        ));
        return responseMockMap;
    }

}