/**
 * Created by marekhaken on 18/07/2020.
 */

global class MerlinOrderStageHttpMockImpl implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MerlinOrderStageHttpMockImpl(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('{"error": "Neplatný podpis", "success": false}');
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}