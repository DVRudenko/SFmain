public class MZKWebServiceImpl implements MZKWebService {

    private final static String MZK_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String MZK_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    public String getRequestNumber(MZKRequest mzkRequest) {
        String requestNumber = '';
        String url = MZK_URL + '/transit-api/create-mzk-req';
        
        String requestBody = JSON.serialize(mzkRequest);
        HttpResponse response = sendRequest(url, requestBody);

        System.debug('******* MZK REQUEST URL: ' + url);
        System.debug('******* MZK REQUEST BODY: ' + requestBody);

        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            System.debug('******* MZK RESPONSE BODY: ' + responseBody);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (responseMap.get('statusCode') == 200) {
                Object responseContent = (Object) (responseMap.get('content'));
                System.debug('******* MZK RESPONSE CONTENT: ' + responseContent);
                Map<String, Object> responseMapId = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(responseContent));
                String responseContentId = (String)(responseMapId.get('createdId'));
                requestNumber = responseContentId;
            } else {
                throw new E2EFormRuException('MZKWebServiceImpl createRequest: '
                        + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
            }
        } else {
            throw new E2EFormRuException('MZKWebServiceImpl createRequest: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
        }
        return requestNumber;
    }

    public static HttpResponse sendRequest(String url, String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', MZK_TOKEN);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }

}