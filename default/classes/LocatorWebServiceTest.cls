@IsTest
private class LocatorWebServiceTest {

    private static String domain;

    @testSetup
    static void setup() {
        List<Domain> domains = [SELECT Domain FROM Domain];
        LocatorWebServiceTest.domain = domains.get(0).Domain;
    }

    @isTest 
    static void testGetReportWithNullSecretKey() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        String result = LocatorWebService.getReport();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assert(message == 'Error! Base auth error');
    }

    @isTest 
    static void testGetReportWithInvalidSecretKey() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/';
        request.httpMethod = 'GET';
        request.headers.put('secretKey', 'novalidsecretkey');
        RestContext.request = request;
        String result = LocatorWebService.getReport();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assert(message == 'Error! Base auth error');
    }

    @isTest 
    static void testGetReportWithValidSecretKeyAndNovalidBatchId_1() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/novalidbatchid';
        request.httpMethod = 'GET';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        request.headers.put('folderName', 'notavailible');
        RestContext.request = request;
        String result = LocatorWebService.getReport();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assertEquals('Error! folderId is empty', message);
    }

    @isTest 
    static void testGetReportWithValidSecretKeyAndNovalidBatchId_2() {
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/novalidbatchid';
        request.httpMethod = 'GET';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        RestContext.request = request;
        String result = LocatorWebService.getReport();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assertEquals('Error! errorsList is empty', message);
    }

    @isTest 
    static void testGetReportWithValidSecretKeyAndNovalidBatchId_3() {
        Test.startTest();
        List<Account> accounts = new List<Account>();
        RecordType recordTypeAcc = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];

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
                    RecordTypeId= recordTypeAcc.Id
            ));
        }
        insert accounts;

        String stationsJson = '['+
                '{"name":"name 1","address":"","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"+4331333258","esi":"1"},'+
                '{"name":"name 2","address":"address 2","city":"","postCode":"postCode 2","country":"Austria","telephone":"+4331333257","esi":"2"},'+
                '{"name":"name 3","address":"address 3","city":"city 3","postCode":"","country":"Austria","telephone":"+4331333258","esi":"3"},'+
                '{"name":"name 4","address":"address 4","city":"city 4","postCode":"postCode 4","country":"Austria","telephone":"","esi":"4"},'+
                '{"name":"name 5","address":"address 5","city":"city 5","postCode":"postCode 5","country":"Austria","telephone":"+4331333256","esi":""},'+
                '{"name":"name 6","address":"address 6","city":"city 6","postCode":"postCode 6","country":"Austria","telephone":"retwadrnrtwnd","esi":"6"},'+
                '{"name":"name 7","address":"address 7","city":"city 7","postCode":"postCode 7","country":"Austria","telephone":"+4331333255","esi":"7"},'+
                '{"name":"name 8","address":"address 8","city":"city 8","postCode":"postCode 8","country":"Austria","telephone":"+4331333254","esi":"8"},'+
                '{"name":"name 9","address":"address 9","city":"city 9","postCode":"postCode 9","country":"Austria","telephone":"erberberberwny","esi":"9"}]';

        List<LocatorStation> stations = LocatorStation.parse(stationsJson);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];
        LocatorStationsBatch locatorBatch = new LocatorStationsBatch(stations, recordType.Id);
        Id batchId = Database.executeBatch(locatorBatch, 10);
        Test.stopTest();

        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/' + String.valueOf(batchId);
        request.httpMethod = 'GET';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        RestContext.request = request;

        String result = LocatorWebService.getReport();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        System.assert(status == 'error');
    }

    @isTest 
    static void testUpdateStationsWithNullSecretKey() {

        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/';
        request.httpMethod = 'POST';
        RestContext.request = request;

        String result = LocatorWebService.updateStations(null, null);
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assertEquals('Error! Invalid auth key', message);
    }

    @isTest 
    static void testUpdateStationsWithInvalidSecretKey() {

        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/';
        request.httpMethod = 'POST';
        request.headers.put('secretKey', 'novalidsecretkey');
        RestContext.request = request;

        String result = LocatorWebService.updateStations(null, null);
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assertEquals('Error! Invalid auth key', message);
    }

    @isTest 
    static void testUpdateStationsWithValidSecretKeyAndNotAvailibleRecordType() {

        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/';
        request.httpMethod = 'POST';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        RestContext.request = request;

        String stationsJson = '['+
                '{"name":"name 3","address":"","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"+4331333258","esi":"1"},'+
                '{"name":"name 3","address":"address 2","city":"","postCode":"postCode 2","country":"Austria","telephone":"+4331333257","esi":"2"},'+
                '{"name":"name 3","address":"address 3","city":"city 3","postCode":"","country":"Austria","telephone":"+4331333258","esi":"3"},'+
                '{"name":"name 3","address":"address 4","city":"city 4","postCode":"postCode 4","country":"Austria","telephone":"","esi":"4"},'+
                '{"name":"name 3","address":"address 5","city":"city 5","postCode":"postCode 5","country":"Austria","telephone":"+4331333256","esi":""},'+
                '{"name":"name 3","address":"address 6","city":"city 6","postCode":"postCode 6","country":"Austria","telephone":"retwadrnrtwnd","esi":"6"},'+
                '{"name":"name 3","address":"address 7","city":"city 7","postCode":"postCode 7","country":"Austria","telephone":"+4331333255","esi":"7"},'+
                '{"name":"name 3","address":"address 8","city":"city 8","postCode":"postCode 8","country":"Austria","telephone":"+4331333254","esi":"8"},'+
                '{"name":"name 3","address":"address 9","city":"city 9","postCode":"postCode 9","country":"Austria","telephone":"erberberberwny","esi":"9"}]';
        String result = LocatorWebService.updateStations(stationsJson, 'notavailiblerecordtype');
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
        String status = String.valueOf(resultMap.get('status'));
        String message = String.valueOf(resultMap.get('message'));
        System.assert(status == 'error');
        System.assertEquals('Error! Retailer RecordType is empty', message);
    }

    @isTest 
    static void testUpdateStationsWithValidSecretKeySuccess() {
        Test.startTest();
        List<Account> accounts = new List<Account>();
        RecordType recordTypeAcc = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Retailer'];

        for (Integer i=0;i<1;i++) {
            accounts.add(new Account(
                    name='Account '+i,
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
                    RecordTypeId= recordTypeAcc.Id
            ));
        }
        insert accounts;
        
        RestRequest request = new RestRequest();
        request.requestUri =
                'https://'+ LocatorWebServiceTest.domain +'/services/apexrest/locator/';
        request.httpMethod = 'POST';
        request.headers.put('secretKey', 'P!v^h9UOC2j&');
        RestContext.request = request;

        String stationsJson = '['+
                '{"name":"name 3","address":"","city":"city 1","postCode":"postCode 1","country":"Austria","telephone":"+4331333258","esi":"1"},'+
                '{"name":"name 3","address":"address 2","city":"","postCode":"postCode 2","country":"Austria","telephone":"+4331333257","esi":"2"},'+
                '{"name":"name 3","address":"address 3","city":"city 3","postCode":"","country":"Austria","telephone":"+4331333258","esi":"3"},'+
                '{"name":"name 3","address":"address 4","city":"city 4","postCode":"postCode 4","country":"Austria","telephone":"","esi":"4"},'+
                '{"name":"name 3","address":"address 5","city":"city 5","postCode":"postCode 5","country":"Austria","telephone":"+4331333256","esi":""},'+
                '{"name":"name 3","address":"address 6","city":"city 6","postCode":"postCode 6","country":"Austria","telephone":"retwadrnrtwnd","esi":"6"},'+
                '{"name":"name 3","address":"address 7","city":"city 7","postCode":"postCode 7","country":"Austria","telephone":"+4331333255","esi":"7"},'+
                '{"name":"name 3","address":"address 8","city":"city 8","postCode":"postCode 8","country":"Austria","telephone":"+4331333254","esi":"8"},'+
                '{"name":"name 3","address":"address 9","city":"city 9","postCode":"postCode 9","country":"Austria","telephone":"erberberberwny","esi":"9"}]';

        String result = LocatorWebService.updateStations(stationsJson, null);
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);

        Test.stopTest();
        String status = String.valueOf(resultMap.get('status'));
        System.assert(status == 'success');
        System.assert(resultMap.containsKey('batchId'));
    }
}