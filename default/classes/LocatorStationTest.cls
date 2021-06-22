@isTest
private class LocatorStationTest {

    @isTest
    static void parseTest() {
        List<LocatorStation> stations = LocatorStation.parse('[{"address":"address 1","city":"city 1","postCode":"postCode 1","country":"Belgium","telephone":"telephone 1","esi":"esi 1"},{"address":"address 2","city":"city 2","postCode":"postCode 2","country":"country 2","telephone":"telephone 2","esi":"esi 2"},{"address":"address 2","city":"city 2","postCode":"postCode 2","country":"Switzerland","telephone":"telephone 2","esi":"esi 2"}]');
        System.assert(stations.size() == 3);
        System.assert(stations.get(0).country == 'Belgium-FR');
        System.assert(stations.get(1).country == 'country 2');
        System.assert(stations.get(2).country == 'Switzerland-DE');
    }
}