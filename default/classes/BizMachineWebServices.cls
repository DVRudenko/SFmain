/**
 * Created by marekhaken on 07/08/2020.
 */

public class BizMachineWebServices {
    public static Boolean useTest = isTest();

    public static Boolean isTest(){
        return [SELECT Id, IsSandbox  FROM Organization][0].IsSandbox;
    }

    public static String getEndpoint(){
        List<BizMachine_Settings__c> bizMachineSettings = [SELECT API_Key__c, Production_Endpoint__c, Sandbox_Endpoint__c FROM BizMachine_Settings__c LIMIT 1];
        if(bizMachineSettings.size() >0){
            if(isTest()){
                return bizMachineSettings[0].Sandbox_Endpoint__c;
            }else{
                return bizMachineSettings[0].Production_Endpoint__c;
            }
        }else{
            //Zapsat log, že nejsou Credentials
            CCSLog.writeError('BizMachine', 'No Credentials for Bizmachine API', 'In Custom settings There are no API key, Production and Sandbox Endpoint!');
            return null;
        }
    }

    public static String getDataset(){
        List<BizMachine_Settings__c> bizMachineSettings = [SELECT API_Key__c, Sandbox_Dataset__c, Production_Dataset__c FROM BizMachine_Settings__c LIMIT 1];
        if(bizMachineSettings.size() >0){
            if(isTest()){
                return bizMachineSettings[0].Sandbox_Dataset__c;
            }else{
                return bizMachineSettings[0].Production_Dataset__c;
            }
        }else{
            //Zapsat log, že nejsou Credentials
            return null;
        }
    }

    public static String getApiKey(){
        List<BizMachine_Settings__c> bizMachineSettings = [SELECT API_Key__c, Production_Endpoint__c, Sandbox_Endpoint__c FROM BizMachine_Settings__c LIMIT 1];
        if(bizMachineSettings.size() >0){
            return bizMachineSettings[0].API_Key__c;
        }else{
            CCSLog.writeError('BizMachine', 'No Credentials for Bizmachine API', 'In Custom settings There are no API key, Production and Sandbox Endpoint!');
            return null;
        }
    }

    public static HttpResponse getCompanyDetailHttpResponse(String ic) {
        HttpRequest req = new HttpRequest();
        system.debug('IČ: '+ic);
        String endpoint = getEndpoint()+'/v1/company/'+ic+'?template=automotive';
        req.setEndpoint(endpoint);
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-Api-Key', getApiKey());
        req.setHeader('X-Dataset', getDataset());
        req.setTimeout(120000);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        return res;
    }

    public static HttpResponse getCompanyTags(String ic) {
        HttpRequest req = new HttpRequest();
        String endpoint = getEndpoint()+'/prospector/cz/v3/companies/'+ic+'/tags';
        req.setEndpoint(endpoint);
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-Api-Key', getApiKey());
        req.setHeader('X-Dataset', getDataset());
        req.setTimeout(120000);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }

    public static HttpResponse setTagCompanyRelation(String ic, String uid) {
        HttpRequest req = new HttpRequest();
        String endpoint = getEndpoint()+'/prospector/cz/v2/companies/'+ic+'/tags/'+uid;
        req.setEndpoint(endpoint);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setHeader('X-Api-Key', getApiKey());
        req.setHeader('X-Dataset', getDataset());
        req.setTimeout(120000);
        req.setMethod('POST');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }

    public static HttpResponse removeTagCompanyRelation(String ic, String uid) {
        HttpRequest req = new HttpRequest();
        String endpoint = getEndpoint()+'/prospector/cz/v2/companies/'+ic+'/tags/'+uid;
        req.setEndpoint(endpoint);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setHeader('X-Api-Key', getApiKey());
        req.setHeader('X-Dataset', getDataset());
        req.setTimeout(120000);
        req.setBody('');
        req.setMethod('DELETE');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }

    public static HttpResponse getTagCompanies(String uid) {
        HttpRequest req = new HttpRequest();
        String endpoint = getEndpoint()+'/prospector/cz/v3/tags/'+uid+'/companies';
        req.setEndpoint(endpoint);
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-Api-Key', getApiKey());
        req.setHeader('X-Dataset', getDataset());
        req.setTimeout(120000);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
}