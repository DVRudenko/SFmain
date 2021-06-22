public class ListingContactsHttpResponseGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
    	HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
    	res.setBody('{"replyCode": 0, "replyText": "OK", "data": ["385885793", "393615693"]}');
    	res.setStatusCode(200);
    return res;    
    }
}