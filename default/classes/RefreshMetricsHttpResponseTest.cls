@isTest
global class RefreshMetricsHttpResponseTest implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"replyCode":0,"replyText":"OK","data":{"ids":["547700997"]}}');
        res.setStatus('OK');
    return res;    
   }
}