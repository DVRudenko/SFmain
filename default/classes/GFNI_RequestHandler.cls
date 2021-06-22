/**
 * Created by Nikita.Mikhailov on 17.01.2019.
 */
public with sharing class GFNI_RequestHandler {

    /*******************************************************************************
    *  Name            : sendRequest
    *  Summary         : builds and sends REST request to IBM GW, specified by Endpoint
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String JSON body, String EndpointName
    *  Returns         : HttpResponse
    ******************************************************************************/
    public static HttpResponse sendRequest(String body, String method, String countryCode) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if (GFNI_Utils.getGeneralSettings(countryCode).Test_mode__c) {
            request.setEndpoint(GFNI_Utils.getGeneralSettings(countryCode).Test_Endpoint__c + method);
            request.setHeader('x-ibm-client-id', GFNI_Utils.getGeneralSettings(countryCode).test_x_ibm_client_id__c);//defines by IBM GW
            request.setHeader('x-ibm-client-secret', GFNI_Utils.getGeneralSettings(countryCode).test_x_ibm_client_secret__c);//defines by IBM GW
        } else {
            request.setEndpoint(GFNI_Utils.getGeneralSettings(countryCode).Prod_Endpoint__c + method);
            request.setHeader('x-ibm-client-id', GFNI_Utils.getGeneralSettings(countryCode).x_ibm_client_id__c);//defines by IBM GW
            request.setHeader('x-ibm-client-secret', GFNI_Utils.getGeneralSettings(countryCode).x_ibm_client_secret__c);//defines by IBM GW
        }

        request.setMethod('POST');
        request.setHeader('content-type', 'application/json');
        request.setHeader('accept', 'application/json');
        request.setTimeout(120000);//TODO: move to  custom setting

        request.setBody(body);

        HttpResponse response;

        System.debug('GFNI_RequestHandler: sending request to ' + request.getEndpoint());

        try {
            response = http.send(request);
        } catch (Exception e) {
            throw new GlobalException(e);
        }

        if (response.getStatusCode() != 200) {
            throw new GlobalException('Response is not 200: ' + response.getStatus() + ' | ' + String.valueOf(response.getStatusCode()) + ' | ' + response.getBody());
        }

        return response;
    }
}