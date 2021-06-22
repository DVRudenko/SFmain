@isTest
global class HealthCheckCreditFactoryMockPL implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req) {
        String requestType = '';
        if (req.getEndpoint() == 'https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService') {
            requestType = 'search';
        } else if (req.getEndpoint() == 'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService') {
            requestType = 'xmlReport';
        } else if (req.getEndpoint().contains('https://demo.deltavista.pl/pdfservice/pdfservlet')) {
          requestType = 'pdfReport';
        }

        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('search', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:SearchResponse xmlns:ns1="http://www.deltavista.com/dspone/webservices/search"><ns1:Candidates><ns1:Address><ns1:CompanyRegistrationInfo><ns1:directoryEntry><ns1:type>PL_NIP</ns1:type><ns1:ID>6822360549</ns1:ID></ns1:directoryEntry></ns1:CompanyRegistrationInfo></ns1:Address></ns1:Candidates></ns1:SearchResponse></soapenv:Body></soapenv:Envelope>');
        requestBodyMap.put('xmlReport', '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns1:orderCheckResponse xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001"><ns1:companyBasicData><ns1:registration><ns1:companyRegistry><ns1:type>PL_NIP</ns1:type><ns1:number>4835372542</ns1:number></ns1:companyRegistry></ns1:registration></ns1:companyBasicData></ns1:orderCheckResponse></soapenv:Body></soapenv:Envelope>');
        requestBodyMap.put('pdfReport', 'testBlobBody');
        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        response.setStatusCode(200);
        response.setBody(requestBodyMap.get(requestType));
        return response;
    }
}