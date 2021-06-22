@isTest
global class CompanyInfoSearchMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest request) {
		String requestType = '';
        if (request.getEndpoint() == 'https://connect.creditsafe.com/v1/authenticate') {
            requestType = 'Creditsafe Auth';
        } else if (request.getEndpoint().contains('https://connect.creditsafe.com/v1/companies') && request.getHeader('Content-Type') == 'application/json') {
            requestType = 'Creditsafe JSON';
        } else if (request.getEndpoint() == 'https://ws1.webservices.nl:443/soap_doclit.php') {
            requestType = 'CompanyInfo';
        }

	  	Map<String, String> requestBodyMap = new Map<String, String>();
		requestBodyMap.put('Creditsafe Auth', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}');
        requestBodyMap.put('Creditsafe JSON', '{"companies": [],"totalSize": 0,"messages": [{"code": "NoResults","text": "No companies matching specified search criteria found.","type": "Information"}],"correlationId": "6fb61c30-d487-11e9-9c9d-02562b862d16"}');
	    requestBodyMap.put('CompanyInfo', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessSearchResponse xmlns="http://www.webservices.nl/soap/"><out><paging><curpage>1</curpage><perpage>20</perpage><numpages>1</numpages><numresults>1</numresults><maxresults>500</maxresults></paging><results><item><dossier_number>64184382</dossier_number><establishment_number>000033032157</establishment_number><trade_name>Ucar Bouw</trade_name><match_type>undetermined</match_type><establishment_city>\'S-HERTOGENBOSCH</establishment_city><establishment_street>Aert van Nesstraat</establishment_street><correspondence_city>\'S-HERTOGENBOSCH</correspondence_city><correspondence_street>Aert van Nesstraat</correspondence_street><indication_main_establishment>true</indication_main_establishment></item></results></out></dutchBusinessSearchResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>');
	    HttpResponse response = new HttpResponse();
	    response.setStatus('OK');
	    response.setStatusCode(200);
	    response.setBody(requestBodyMap.get(requestType));
	    return response;
  	}
}