@isTest
global class GoogleTranslateMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest request){
		HttpResponse response = new HttpResponse();
		response.setStatus('OK');
		response.setStatusCode(200);
		response.setBody('{"data": {"translations": [{"translatedText": "test", "detectedSourceLanguage": "en"}]}}');
		return response;
	}
}