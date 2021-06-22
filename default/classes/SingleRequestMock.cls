public class SingleRequestMock implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    public String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;

    public SingleRequestMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(code);
        if (status != null) res.setStatus(status);
        if (bodyAsBlob != null) {
            res.setBodyAsBlob(bodyAsBlob);
        } else {
            res.setBody(bodyAsString);
        }

        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                res.setHeader(key, responseHeaders.get(key));
            }
        }
        return res;
    }
}