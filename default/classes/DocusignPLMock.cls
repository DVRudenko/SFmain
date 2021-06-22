@isTest
global class DocusignPLMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest request) {
    	HttpResponse response = new HttpResponse();
	    response.setStatus('OK');
	    response.setStatusCode(200);
	    response.setBody('test');
	    return response;
    }
}