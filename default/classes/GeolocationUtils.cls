public class GeolocationUtils {

    /*******************************************************************************
    *  Name            : getTerritoryByAddress()
    *  Summary         : determine territory by address information
    *  Parameters      : Map<String, String> address - map which contains pairs "street" : "TVERSKAYA", "house" : "10" etc.
    *                    List<FieldSalesTerritory__c> - list of territories
    *  Returns         : String - name of territory
    ******************************************************************************/
    public static String verifyAddressInformation(Map<String, String> address, List<FS_Tree_Area__mdt> areas){
        String result = '';
        system.debug('address='+address);
        system.debug(areas);
        String currentCountry = address.get('country');
        String currentProvince = address.get('province');
        String currentArea = address.get('area');
        if(currentCountry != null && currentArea != null){
            for(FS_Tree_Area__mdt area : areas){
                if(currentProvince != null) { // Поле "область" заполнено
                    if ((area.Label == currentArea || (area.Alternative_Names__c != null && String.valueOf(area.Alternative_Names__c).contains(currentArea)) || 'город ' + area.Label == currentArea) &&
                            (area.FS_Tree_Province__r.Label == currentProvince || ( area.FS_Tree_Province__r.Alternative_Names__c != null && String.valueOf(area.FS_Tree_Province__r.Alternative_Names__c).contains(currentProvince)) || area.FS_Tree_Province__r.Label == currentProvince + ' область') &&
                            area.FS_Tree_Province__r.FS_Tree_Country__r.Label == currentCountry) {
                        if (area.FS_Territory__c != null) {
                            result = 'SUCCESS';
                        } else {
                            result = 'ERROR:Custom Metadata <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + area.Id + '">FS_Tree_Area</a> is not bound to FS_Territory.';
                        }
                        // Прсваевае базовое имя области, если в адресе получили альтернативное имя
                        if(area.FS_Tree_Province__r.Label != currentProvince){
                            address.put('province', area.FS_Tree_Province__r.Label);
                        }
                        // Прсваевае базовое имя "Административно территориальной единицы", если в адресе получили альтернативное имя
                        if(area.Label != currentArea){
                            address.put('area', area.Label);
                        }
                        break;
                    }
                } else { // Поле "Область" не заполнено
                    if(area.Label == currentArea && area.FS_Tree_Province__r.FS_Tree_Country__r.Label == currentCountry){
                        if(area.FS_Territory__c != null){
                            result = 'SUCCESS';
                        } else {
                            result = 'ERROR:Custom Metadata <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + area.Id + '">FS_Tree_Area</a> is not bound to FS_Territory.';
                        }
                        address.put('province', area.FS_Tree_Province__r.Label);
                        break;
                    }
                }
            }
            if(result == ''){
                result = 'ERROR:Custom metadata FS_Tree_Area is not exist.';
            }
        }
        return result;
    }

    /*******************************************************************************
    *  Name            : getAddressObjectFromGoogle()
    *  Summary         : get address information from Google Geocoder
    *  Parameters      : String address
    *  Returns         : Map<String, String> - map which contains pairs "street" : "TVERSKAYA", "house" : "10" etc.
    ******************************************************************************/
    public static Map<String, String> getAddressObjectFromGoogle(String targetAddress, String apiKey){
        Map<String, String> result = new Map<String, String>();
        String responseBody = sendRequestToGeocoderGoogle(targetAddress, apiKey);
        system.debug(targetAddress);
        system.debug(responseBody);
        GeocoderGoogle geocoder = (GeocoderGoogle) (JSON.deserialize(responseBody, GeocoderGoogle.class));
        if(geocoder.status == 'OK'){
            if(geocoder.results.size() != 0){
                List<GeocoderGoogle.address_components> addressComponents = geocoder.results.get(0).address_components;
                for(GeocoderGoogle.address_components component : addressComponents){
                    if(component.types.contains('street_address') || component.types.contains('route')){
                        if(result.get('street') == null){
                            result.put('street', component.long_name);
                        } else {
                            result.put('street', result.get('street') + component.long_name);
                        }
                    }
                    else if(component.types.contains('country')){
                        result.put('country', component.long_name);
                    }
                    else if(component.types.contains('administrative_area_level_1')){
                        result.put('province', component.long_name);
                    }
                    else if(component.types.contains('administrative_area_level_2')){
                        result.put('area', component.long_name);
                    }
                    else if(component.types.contains('administrative_area_level_3')){
                        result.put('city_area', component.long_name);
                    }
                    else if(component.types.contains('locality')){
                        result.put('city', component.long_name);
                    }
                    else if(component.types.contains('street_number')){
                        result.put('house', component.long_name);
                    }
                    else if(component.types.contains('postal_code')){
                        result.put('postal_code', component.long_name);
                    }
                }
                result.put('longitude', String.valueOf(geocoder.results.get(0).geometry.location.lng));
                result.put('latitude',  String.valueOf(geocoder.results.get(0).geometry.location.lat));
            }
        }
        return result;
    }

    /*******************************************************************************
    *  Name            : sendRequestToGeocoderGoogle()
    *  Summary         : send request to google geocoder
    *  Parameters      : String address
    *  Returns         : String response body
    ******************************************************************************/
    public static String sendRequestToGeocoderGoogle(String address, String apiKey){
        String responseBody = '';
        try{
            String endPoint = 'https://maps.googleapis.com/maps/api/geocode/json?';
            endPoint += 'address=' + changeAddressForRequest(address);
            endPoint += '&key=' + apiKey;
            endPoint += '&language=ru';
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(endPoint);
            Http http = new Http();
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
        }
        catch(Exception e){
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
        return responseBody;
    }

    /*******************************************************************************
    *  Name            : changeAddressForRequest()
    *  Summary         : remove extra characters from address
    *  Parameters      : String address
    *  Returns         : String "clean address"
    ******************************************************************************/
    private static String changeAddressForRequest(String address){
        List<String> addressLines = address.split('\r\n');
        String result ='';
        if(addressLines.size() == 1){
            result = addressLines.get(0);
        } else {
            for(String line : addressLines){
                result += line + ' ';
            }
        }
        result = result.replaceAll(' ','+');
        return result;
    }

    /*** Coordinates CODE ***/

    public class Coordinates{
        public Decimal x;
        public Decimal y;

        public Coordinates(Decimal valueX, Decimal valueY){
            x = valueX; // N - North (северная широта)
            y = valueY; // E - East (восточная долгота)
        }
    }

    /*******************************************************************************
    *  Name            : isPointBelongToPolygonFast()
    *  Summary         : Fast algorithm: check that point is belong to polygon
    *  Parameters      : Example : isPointBelongToPolygon('61.96-59.21','56.18-57.43;61.95-59.21;61.44-62.11;56.80-65.06')
    *  Returns         : TRUE - point belong , else = FALSE
    ******************************************************************************/
    public static Boolean isPointBelongToPolygonFast(String point, String polygonPoints){
        Boolean result = false;
        Coordinates targetPoint = new Coordinates(Decimal.valueOf(point.substringBefore('-')),Decimal.valueOf(point.substringAfter('-')));

        Map<Integer, Coordinates> listCoordinates = new Map<Integer, Coordinates>();

        List<String> polygon = polygonPoints.split(';');
        Integer x = 0;
        for(String polygonPoint : polygon){
            listCoordinates.put(x, new Coordinates(Decimal.valueOf(polygonPoint.substringBefore('-')),Decimal.valueOf(polygonPoint.substringAfter('-'))));
            x++;
        }

        Integer j = listCoordinates.size()-1;
        for(Integer i = 0; i < listCoordinates.size(); i++){
            if(
                    (
                            ((listCoordinates.get(i).y <= targetPoint.y) && (targetPoint.y < listCoordinates.get(j).y)) ||
                                    ((listCoordinates.get(j).y <= targetPoint.y) && (targetPoint.y < listCoordinates.get(i).y))
                    ) &&
                            (targetPoint.x > (listCoordinates.get(j).x - listCoordinates.get(i).x) * (targetPoint.y - listCoordinates.get(i).y) /
                                    (listCoordinates.get(j).y - listCoordinates.get(i).y) + listCoordinates.get(i).x)
                    ){
                result = !result;
            }
            j = i;
        }


        return result;
    }

    /*******************************************************************************
    *  Name            : isPointBelongToPolygon()
    *  Summary         : check that point is belong to polygon
    *  Parameters      : Example : isPointBelongToPolygon('61.96-59.21','56.18-57.43;61.95-59.21;61.44-62.11;56.80-65.06')
    *  Returns         : TRUE - point belong , else = FALSE
    ******************************************************************************/
    public static Boolean isPointBelongToPolygon(String point, String polygonPoints){
        Boolean result;
        Coordinates targetPoint = new Coordinates(Decimal.valueOf(point.substringBefore('-')),Decimal.valueOf(point.substringAfter('-')));

        Map<Integer, Coordinates> listCoordinates = new Map<Integer, Coordinates>();
        List<String> polygon = polygonPoints.split(';');
        Integer x = 0;
        for(String polygonPoint : polygon){
            listCoordinates.put(x, new Coordinates(Decimal.valueOf(polygonPoint.substringBefore('-')),Decimal.valueOf(polygonPoint.substringAfter('-'))));
            x++;
        }

        Integer size = polygon.size();
        Integer i1, i2, n;
        Decimal s, s1, s2, s3;
        for (n=0; n < size; n++)
        {
            result = false;
            i1 = n < size-1 ? n + 1 : 0;
            while (result == false)
            {
                i2 = i1 + 1;
                if (i2 >= size)
                    i2 = 0;
                if (i2 == (n < size-1 ? n + 1 : 0))
                    break;
                s  = math.abs (listCoordinates.get(i1).x * (listCoordinates.get(i2).y - listCoordinates.get(n).y) +
                        listCoordinates.get(i2).x * (listCoordinates.get(n).y - listCoordinates.get(i1).y) +
                        listCoordinates.get(n).x  * (listCoordinates.get(i1).y - listCoordinates.get(i2).y));

                s1 = math.abs (listCoordinates.get(i1).x * (listCoordinates.get(i2).y - targetPoint.y) +
                        listCoordinates.get(i2).x * (targetPoint.y - listCoordinates.get(i1).y) +
                        targetPoint.x * (listCoordinates.get(i1).y - listCoordinates.get(i2).y));

                s2 = math.abs (listCoordinates.get(n).x * (listCoordinates.get(i2).y - targetPoint.y) +
                        listCoordinates.get(i2).x * (targetPoint.y - listCoordinates.get(n).y) +
                        targetPoint.x * (listCoordinates.get(n).y - listCoordinates.get(i2).y));

                s3 = math.abs (listCoordinates.get(i1).x * (listCoordinates.get(n).y - targetPoint.y) +
                        listCoordinates.get(n).x * (targetPoint.y - listCoordinates.get(i1).y) +
                        targetPoint.x * (listCoordinates.get(i1).y - listCoordinates.get(n).y));

                if (s == s1 + s2 + s3)
                {
                    result = true;
                    break;
                }
                i1 = i1 + 1;
                if (i1 >= size)
                    i1 = 0;
            }
            if (result == false)
                break;
        }

        return result;
    }

    public static Map<String, String> countriesTranslateEN = new Map<String,String>{
            'Россия' => 'Russia'
    };



}