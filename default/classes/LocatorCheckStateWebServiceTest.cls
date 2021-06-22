@IsTest
private class LocatorCheckStateWebServiceTest {
    private static String domain;

    @testSetup
    static void setup() {
        List<Domain> domains = [SELECT Domain FROM Domain];
        LocatorCheckStateWebServiceTest.domain = domains.get(0).Domain;

        List<Account> accounts = new List<Account>();
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];

        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(
                    Name='Account '+i,
                    BillingCity='City ' + i,
                    ShippingCity='City ' + i,
                    BillingStreet='Street ' + i,
                    ShippingStreet='Street ' + i,
                    BillingPostalCode='PostalCode ' + i,
                    ShippingPostalCode='PostalCode ' + i,
                    BillingCountry='Austria',
                    ShippingCountry='Austria',
                    OBN__c=String.valueOf(i),
                    Phone='+4331333258',
                    RecordTypeId= recordType.Id
            ));
        }
        insert accounts;
    }

    @isTest static void testGetUpdatingStateWithNullSecretKey() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://' + LocatorCheckStateWebServiceTest.domain + '/services/apexrest/locator-check-state';
        request.httpMethod = 'POST';
        RestContext.request = request;
        String result = LocatorCheckStateWebService.getUpdatingState(null);
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        System.assert(status == 'error');
        System.assert(resultMap.containsKey('message'));
    }

    @isTest static void testGetUpdatingStateWithNotValidSecretKey() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://' + LocatorCheckStateWebServiceTest.domain + '/services/apexrest/locator-check-state';
        request.httpMethod = 'POST';
        request.headers.put('secretKey', 'novalidsecretkey');
        RestContext.request = request;
        String result = LocatorCheckStateWebService.getUpdatingState(null);
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        System.assert(status == 'error');
        System.assert(resultMap.containsKey('message'));
    }

    @isTest static void testGetUpdatingStateWithValidSecretKeyAndNotValidBatchId() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://' + LocatorCheckStateWebServiceTest.domain + '/services/apexrest/locator-check-state';
        request.httpMethod = 'POST';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        RestContext.request = request;
        String result = LocatorCheckStateWebService.getUpdatingState('noexists');
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        System.assert(status == 'error');
        System.assert(resultMap.containsKey('message'));
        System.assert(resultMap.containsKey('cleanBatch'));
    }

    @isTest static void testGetUpdatingStateWithValidSecretKeyAndValidBatchId() {
        Test.startTest();
        String stationsJson = '['+
                '{"name":"name 3","address":"address 1","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"telephone 1","esi":"esi 1"},'+
                '{"name":"name 3","address":"address 2","city":"city 2","postCode":"postCode 2","country":"Austria","telephone":"telephone 2","esi":"esi 2"}]';

        List<LocatorStation> stations = LocatorStation.parse(stationsJson);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];
        LocatorStationsBatch locatorBatch = new LocatorStationsBatch(stations, recordType.Id);
        Id batchId = Database.executeBatch(locatorBatch, 10);
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://' + LocatorCheckStateWebServiceTest.domain + '/services/apexrest/locator-check-state';
        request.httpMethod = 'POST';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        RestContext.request = request;
        String result = LocatorCheckStateWebService.getUpdatingState(String.valueOf(batchId));
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        Test.stopTest();

        System.assert(resultMap.containsKey('countDone'));
        System.assert(resultMap.containsKey('countTotal'));

    }
}