public with sharing class CrmWebServiceImpl implements CrmWebService {

    private final static String CRM_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String CRM_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    /*******************************************************************************
    *  Name            : createTask(String inn, CrmTask crmTask)
    *  Summary         : create new task in CRM system
    *  CreatedDate     : 27/08/2018
    *  Parameters      : String inn
    *                    CrmTask - new task
    *  Returns         : void
    ******************************************************************************/
    public void createTask(String inn, CrmTask crmTask) {
        String url = CRM_URL + '/crm/create-case?inn=' + inn;
        String requestBody = JSON.serialize(crmTask);
        System.debug('******* CRM REQUEST URL: ' + url);
        System.debug('******* CRM REQUEST BODY: ' + requestBody);
        HttpResponse response = sendRequest(url, requestBody);

        String responseBody = response.getBody();
        System.debug('******* CRM RESPONSE BODY: ' + responseBody);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (response.getStatusCode() == 200) {
            System.debug('**** CRM RESPONSE: ' + response);
        } else {
            throw new E2EFormRuException('CrmWebServiceImpl createTask: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
    }

    private static HttpResponse sendRequest(String url, String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', CRM_TOKEN);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }
}