@isTest
global class HealthCheckCreditFactoryMockDE implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req) {
        String requestType = '';
        if (req.getBody().contains('<ns:searchRequest>')) {
            requestType = 'search';
        } else if (req.getBody().contains('<ns:reportRequest>')) {
            requestType = 'report';
        } 

        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('search', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"><env:Body><ns2:searchResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"><ns2:body><ns2:hit><ns2:identificationnumber>03453452013903</ns2:identificationnumber></ns2:hit><ns2:morehits>true</ns2:morehits></ns2:body></ns2:searchResponse></env:Body></env:Envelope>');
        requestBodyMap.put('report', '<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"><env:Body><ns2:reportResponse xmlns:ns2="https://onlineservice.creditreform.de/webservice/0520-0018"><ns2:body><ns2:identificationnumber>03453452013903</ns2:identificationnumber></ns2:body></ns2:reportResponse></env:Body></env:Envelope>');
        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        response.setStatusCode(200);
        response.setBody(requestBodyMap.get(requestType));
        return response;
    }
}