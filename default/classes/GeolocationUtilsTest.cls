@isTest
public class GeolocationUtilsTest {

    @isTest
    public static void testVerifyAddressInformation(){
        Map<String, String> addressMap = new Map<String, String>();
        addressMap.put('country','Россия');
        addressMap.put('province','Свердловская область');
        addressMap.put('area','город Нижний тагил');
        List<FS_Tree_Area__mdt> listAreas = [
                SELECT id, Label, Alternative_Names__c,
                        FS_Tree_Province__r.Label, FS_Tree_Province__r.Alternative_Names__c,
                        FS_Tree_Province__r.FS_Tree_Country__r.Label,
                        FS_Territory__r.Label
                FROM FS_Tree_Area__mdt
        ];
        String result = GeolocationUtils.verifyAddressInformation(addressMap, listAreas);
        system.assertEquals(result.contains('ERRROR'), false);
    }

    @isTest
    public static void testVerifyAddressInformation2(){
        Map<String, String> addressMap = new Map<String, String>();
        addressMap.put('country','Россия');
        addressMap.put('area','город Нижний тагил');
        List<FS_Tree_Area__mdt> listAreas = [
                SELECT id, Label, Alternative_Names__c,
                        FS_Tree_Province__r.Label, FS_Tree_Province__r.Alternative_Names__c,
                        FS_Tree_Province__r.FS_Tree_Country__r.Label,
                        FS_Territory__r.Label
                FROM FS_Tree_Area__mdt
        ];
        String result = GeolocationUtils.verifyAddressInformation(addressMap, listAreas);
        system.assertEquals(result.contains('ERRROR'), false);
    }

    @isTest
    public static void testGetAddressObjectFromGoogle(){
        String address = 'Россия, Екатеринбург, ленина 81';
        SingleRequestMock newMock = new SingleRequestMock(200,'OK','{"results" : [{"address_components" : [{"long_name" : "623702","short_name" : "623702","types" : [ "postal_code" ]},{"long_name" : "Свердловская область","short_name" : "Свердловская обл.","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "Екатеринбург","short_name" : "Екатеринбург","types" : [ "administrative_area_level_2" ]},{"long_name" : "Россия","short_name" : "RU", "types" : [ "country", "political" ]}],"formatted_address" : "Свердловская обл., Россия, 623702", "geometry" : {"bounds" : {"northeast" : {"lat" : 56.90778299999999, "lng" : 60.879642},"southwest" : {"lat" : 56.834169,"lng" : 60.81281689999999}}, "location" : {"lat" : 56.8712764, "lng" : 60.8409019}, "location_type" : "APPROXIMATE", "viewport" : {"northeast" : {"lat" : 56.90778299999999, "lng" : 60.879642},"southwest" : {"lat" : 56.834169, "lng" : 60.81281689999999}}},"partial_match" : true, "place_id" : "ChIJwyxBluISwUMRnH9dcSR2oJk", "types" : [ "postal_code" ]}], "status" : "OK"}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, newMock);
        Map<String, String> result = GeolocationUtils.getAddressObjectFromGoogle(address, 'apikey');
        Test.stopTest();
        system.assertNotEquals(result.size(), 0);
    }

    @isTest
    public static void testIsPointBelongToPolygon(){
        String polygonPoints = '56.18226-57.43652;61.95962-59.2163;61.44926-62.1167;56.80088-65.06103';
        String point = '59.517-60.675';
        Boolean status;
        status = GeolocationUtils.isPointBelongToPolygon(point, polygonPoints);
        system.assertEquals(status, true);

        String pointOut = '59.517-56.129';
        status = GeolocationUtils.isPointBelongToPolygon(pointOut, polygonPoints);
        system.assertEquals(status, false);
    }

    @isTest
    public static void testIsPointBelongToPolygonFast(){
        String polygonPoints = '56.18226-57.43652;61.95962-59.2163;61.44926-62.1167;56.80088-65.06103';
        String point = '59.517-60.675';
        Boolean status;
        status = GeolocationUtils.isPointBelongToPolygonFast(point, polygonPoints);
        system.assertEquals(status, true);

        String pointOut = '59.517-56.129';
        status = GeolocationUtils.isPointBelongToPolygonFast(pointOut, polygonPoints);
        system.assertEquals(status, false);
    }

}