@isTest
global class IngenicoMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest request){
		HttpResponse response = new HttpResponse();
		response.setStatus('OK');
		response.setStatusCode(200);
		response.setBody('<TITLE>Payment confirmation</TITLE>');
		return response;
	}
}