public class PD_SFSoap {

    String endpoint;
    public String response {get; private set;}

    public PD_SFSoap() {
        response = '';
    }

    public PD_SFSoap setEndpoint(String value) {
        endpoint = value;
        return this;
    }

    public PD_SFSoap send(String body) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + UserInfo.getOrganizationId());
        request.setHeader('SOAPAction', '""');
        request.setHeader('Content-type', 'text/xml');
        request.setMethod('POST');
        request.setBody(body);
        request.setTimeout(120000);
        response = h.send(request).getBody();
        //if (!System.Test.isRunningTest()) response = h.send(request).getBody();
        if (response.contains('soapenv:Fault')) {
            throw new PD_SoapFaultException(response.substringAfter('<faultstring>').substringBefore('</faultstring>'));
        }
        return this;
    }

}