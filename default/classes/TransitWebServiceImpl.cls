public class TransitWebServiceImpl implements TransitWebService{

    private final static String TRANSIT_SERVICE_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String TRANSIT_SERVICE_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    public TransitResponseData storeContData(TransitRequestData requestData) {
        String url = TRANSIT_SERVICE_URL + '/transit-api/create-cont';
        String requestBody = JSON.serialize(requestData);

        System.debug('******* TRANSIT SERVICE REQUEST URL: ' + url);
        System.debug('******* TRANSIT SERVICE REQUEST BODY: ' + requestBody);

        HttpResponse response = sendPostRequest(url, requestBody);
        System.debug('*******  TRANSIT SERVICE RESPONSE: ' + response);

        TransitResponseData reportResponse = new TransitResponseData();

        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            System.debug('******* TRANSIT SERVICE RESPONSE BODY: ' + responseBody);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if ((responseMap.containsKey('statusCode') && responseMap.get('statusCode') == 200 || responseMap.containsKey('statusCode') && responseMap.get('statusCode') == 302) &&  responseMap.containsKey('content')) {
                Object responseContent = (Object)(responseMap.get('content'));
                System.debug('******* TRANSIT SERVICE RESPONSE CONTENT: ' + responseContent);
                reportResponse = (TransitResponseData)(JSON.deserialize(JSON.serialize(responseContent), TransitResponseData.class));
            } else {
                throw new E2EFormRuException('TransitWebServiceImpl storeContData: '
                        + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
            }
        } else {
            throw new E2EFormRuException('TransitWebServiceImpl storeContData: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
        }
        return reportResponse;
    }

    public void createDocumentLinks(TransitDocLinkRequestData requestData) {
        String url = TRANSIT_SERVICE_URL + '/transit-api/link-docs-to-cont';
        String requestBody = JSON.serialize(requestData);

        System.debug('******* TRANSIT SERVICE CREATE LINKS REQUEST URL: ' + url);
        System.debug('******* TRANSIT SERVICE CREATE LINKS REQUEST BODY: ' + requestBody);

        HttpResponse response = sendPostRequest(url, requestBody);
        System.debug('*******  TRANSIT SERVICE RESPONSE: ' + response);

        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if ((responseMap.containsKey('statusCode') && responseMap.get('statusCode') == 200)) {
                System.debug('******* TRANSIT SERVICE CREATE LINKS: OK');
            } else {
                throw new E2EFormRuException('TransitWebServiceImpl createDocumentLinks: '
                        + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
            }
        } else {
            throw new E2EFormRuException('TransitWebServiceImpl createDocumentLinks: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
        }
    }

    /*******************************************************************************
    *  Name            : sendRequest()
    *  Summary         : sent REST request
    *  CreatedDate     : 31/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String url, String Method, String requestBody
    *  Returns         : -
    ******************************************************************************/
    private HttpResponse sendPostRequest(String url, String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', TRANSIT_SERVICE_TOKEN);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setBody(requestBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

}