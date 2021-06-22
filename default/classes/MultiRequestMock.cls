public class MultiRequestMock implements HttpCalloutMock {

    Map<String, HttpCalloutMock> requests;

    public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock;
        if (requests.containsKey(req.getEndpoint())) {
            mock = requests.get(req.getEndpoint());
        }
        else {
            for (String key : requests.keySet()) {
                if (req.getBody().contains(key)) {
                    mock = requests.get(key);
                    break;
                }
            }
        }

        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new RequestMockException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}