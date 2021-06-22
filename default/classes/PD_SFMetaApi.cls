public class PD_SFMetaApi {

    String metaEndPoint;
    String sessionId;
    PD_SFSoap soap;

    public PD_SFMetaApi () {
        soap = new PD_SFSoap();
        sessionId = UserInfo.getSessionId();
        String instanceName = [select InstanceName from Organization where id=:UserInfo.getOrganizationId()].InstanceName.toLowerCase();
        metaEndPoint = 'https://' + instanceName + '.salesforce.com/services/Soap/m/36.0/' + UserInfo.getOrganizationId();
    }

    public String readMeta(String type, String[] members) {
        system.debug('reading meta ' + type);
        String body =
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                        +'   <soapenv:Header>'
                        +'      <met:SessionHeader>'
                        +'         <met:sessionId>' + sessionId + '</met:sessionId>'
                        +'      </met:SessionHeader>'
                        +'   </soapenv:Header>'
                        +'  <soapenv:Body>'
                        +'      <met:readMetadata>'
                        +'          <met:type>' + type + '</met:type>';
        for (String member:members) {
            body += '<met:fullNames>' + member + '</met:fullNames>';
        }

        body += '      </met:readMetadata>'
                +'   </soapenv:Body>'
                +'</soapenv:Envelope>';
        return soap.setEndpoint(metaEndPoint).send(body).response;
    }

    public String listMeta(String type) {
        system.debug('Listling meta' + type);
        String body =
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
                        +'   <soapenv:Header>'
                        +'      <met:SessionHeader>'
                        +'         <met:sessionId>' + sessionId + '</met:sessionId>'
                        +'      </met:SessionHeader>'
                        +'   </soapenv:Header>'
                        +'   <soapenv:Body>'
                        +'      <met:listMetadata>'
                        +'         <met:queries>'
                        +'            <met:type>' + type + '</met:type>'
                        +'         </met:queries>'
                        +'         <met:asOfVersion>36.0</met:asOfVersion>'
                        +'      </met:listMetadata>'
                        +'   </soapenv:Body>'
                        +'</soapenv:Envelope>';

        return soap.setEndpoint(metaEndPoint).send(body).response;
    }
}