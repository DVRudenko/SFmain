@isTest
global class HealthCheckCreditFactoryMockHU implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req) {
        String requestType = '';
        if (req.getBody().contains('<web:searchByIdentifier>')) {
            requestType = 'searchByVatNumber';
        } else if (req.getBody().contains('<web:searchByNameAndAddress>')) {
            requestType = 'searchByName';
        } else if (req.getBody().contains('<web:getCompanyDetails>')) {
            requestType = 'reportAvailability';
        } else if (req.getBody().contains('<web:immediateOrder>')) {
            requestType = 'report'; // xml or pdf
        }

        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('searchByVatNumber', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><searchByIdentifierResponse xmlns="http://www.iconx.biz/webservices"><searchByIdentifierResult><SearchResults><SearchResult><InternalID>81466010</InternalID></SearchResult></SearchResults></searchByIdentifierResult></searchByIdentifierResponse></soap:Body></soap:Envelope>');
        requestBodyMap.put('searchByName', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><searchByNameAndAddressResponse xmlns="http://www.iconx.biz/webservices"><searchByNameAndAddressResult><SearchResults><SearchResult><InternalID>81466010</InternalID></SearchResult></SearchResults></searchByNameAndAddressResult></searchByNameAndAddressResponse></soap:Body></soap:Envelope>');
        requestBodyMap.put('reportAvailability', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><getCompanyDetailsResponse xmlns="http://www.iconx.biz/webservices"><getCompanyDetailsResult><CompanyDetails><Company><InternalID>81466010</InternalID></Company></CompanyDetails></getCompanyDetailsResult></getCompanyDetailsResponse></soap:Body></soap:Envelope>');
        requestBodyMap.put('report', '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><immediateOrderResponse xmlns="http://www.iconx.biz/webservices"><immediateOrderResult><OrderStatus><Company><InternalID>81466010</InternalID></Company></OrderStatus></immediateOrderResult></immediateOrderResponse></soap:Body></soap:Envelope>');
        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        response.setStatusCode(200);
        response.setBody(requestBodyMap.get(requestType));
        return response;
    }
}