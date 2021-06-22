@isTest
global class CreditsafeSearchMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest request) {
        String requestType = '';
        if (request.getEndpoint() == 'https://connect.creditsafe.com/v1/authenticate') {
            requestType = 'Creditsafe Auth';
        } else if (request.getEndpoint().contains('https://connect.creditsafe.com/v1/companies') && request.getHeader('Content-Type') == 'application/json') {
            requestType = 'Creditsafe JSON';
        }
        
        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('Creditsafe Auth', '{"token":"eyJraWQiOiJNSytSKzRhYUk4YjBxVkhBMkZLZFN4Ykdpb3RXbTNXOGhZWE45dXF3K3YwPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MGM2MGY0Ni0wNzlhLTQ2NTctOTk4MS03NWNhODIyZmMwNjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTXY4TUFxaDFjIiwiY29nbml0bzp1c2VybmFtZSI6Im5pa2l0YS5wb3BvdkBmbGVldGNvci5ydSIsImN1c3RvbTpjc1VzZXJJZCI6IjEwMDA0NjE1MjAiLCJhdWQiOiI0cDg4ZGRnN3VnNnIxam1la2Rkdmluam9xMCIsImN1c3RvbTpjc1VzZXJDb3VudHJ5Q29kZSI6Ik5MIiwiZXZlbnRfaWQiOiI0ZmMzM2JkNS1hN2RhLTQxZWMtYjk4Mi03OGUzM2M1MGVmMWIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTU2NTI0OTE0OSwiZXhwIjoxNTY1MjUyNzQ5LCJpYXQiOjE1NjUyNDkxNDksImVtYWlsIjoibmlraXRhLnBvcG92QGZsZWV0Y29yLnJ1In0.ljym9TO8WeXc-AyMJPKBTvifO9_ApxmbgkkKZEJzX_rLpNz8QF6NsCafTZhFnAJf8I69iqkmrcw9vSJWEGcXZkpcdWQvh5BnnuCbOWvsPb3IrvLQYFuItuuYsaPBPA5M7RaMH037eEgYopjKY1KKLfBaMWpyUkqP2ETqAAlkOWmG-jOgPuI99DLt_yR47YOoLNLSrXHbQ6vVAcXVrGTp5bp8_W661SUYMzE91I8UsBHdt7NkfAWXU6_H1CjywaHPNyV9kWDsZrRxRh_Z3yJYrJC0qQryfRvqLiF2yV73HhqrJ_BGx47BOjtsF-NLZkn_Q7KnScWB7qoOEE1S_DcTMQ"}');
        requestBodyMap.put('Creditsafe JSON', '{"totalSize": 1,"companies": [{"id": "NL001-X-502603400000","country": "NL","regNo": "502603400000","vatNo": ["822640065"],"safeNo": "NL02613772","name": "Testgear B.V.","tradingNames": ["Testgear B.V.","Testgear B.V."],"address": {"simpleValue": "10, Molensingel, 2614LB, DELFT","street": "Molensingel","city": "DELFT","postCode": "2614LB","houseNo": "10"},"status": "active","officeType": "headOffice","dateOfLatestAccounts": "2016-12-31T00:00:00.000000Z","dateOfLatestChange": "2013-02-21T22:30:43.000Z","activityCode": "6420","statusDescription": "ACTIVE"}]}');
        
        HttpResponse response = new HttpResponse();
    	response.setBody(requestBodyMap.get(requestType));
    	response.setStatus('OK');
        response.setStatusCode(200);
    	return response;
    }
}