@isTest
public class EmarsysEmailUrlMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
    	Map<String, String> requestBodyMap = new Map<String, String>();
    	requestBodyMap.put('https://api.emarsys.net/api/v2/email/297202/url', '{"replyCode":0,"replyText":"OK","data":' +
    		'{"url":"https://api.emarsys.net/u/gm.php?prm=i5txRheNRF_765355226_297202_1"}}');
    	requestBodyMap.put('https://api.emarsys.net/u/gm.php?prm=i5txRheNRF_765355226_297202_1', '<html><head></head><body style="visibility: visible;"></body></html>');
    	HttpResponse response = new HttpResponse();
    	response.setBody(requestBodyMap.get(request.getEndpoint()));
    	return response;
    }
}