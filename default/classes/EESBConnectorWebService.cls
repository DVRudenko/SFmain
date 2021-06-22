public abstract class EESBConnectorWebService {

    protected final GATEWAY__c GATEWAY;

    @TestVisible
    protected virtual HttpResponse sendPostRequest(String endpoint, String body) {
        new DefaultValidator().validate(String.class, 'body', body);
        new DefaultValidator().validate(String.class, 'endpoint', endpoint);

        HttpRequest request = new HttpRequest();
        request.setHeader(HttpUtils.HEADER.IBM_GATEWAY.CLIENT_SECRET, GATEWAY == null ? '' : GATEWAY.CLIENT_SECRET__c == null ? '' : GATEWAY.CLIENT_SECRET__c);
        request.setHeader(HttpUtils.HEADER.IBM_GATEWAY.CLIENT_ID, GATEWAY == null ? '' : GATEWAY.CLIENT_ID__c == null ? '' : GATEWAY.CLIENT_ID__c);
        request.setHeader(HttpUtils.HEADER.CONTENT_TYPE, HttpUtils.HEADER.JSON);
        request.setEndpoint(endpoint);
        request.setBody(body);
        request.setMethod(HttpUtils.METHOD.POST);
        request.setTimeout(HttpUtils.MAX_TIMEOUT);
        return new Http().send(request);
    }
}

