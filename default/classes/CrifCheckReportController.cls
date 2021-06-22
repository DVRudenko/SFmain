public class CrifCheckReportController {
    public String account {get;set;}
    
    public Map <String, Schema.SObjectField> schemaMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
    public String fields, endpoint, apiKey, response, nip;
    
    public String getFields()
    {
        List<String> entities = new List<String>(schemaMap.keySet());
        entities.sort();
        
        String result = '';
        
        for(String e : entities)
        {
            result += e + ';';
        }
       
        return result;
    }
    
    public void sendRequest()
    {
        apiKey = '65ded5353c5ee48d0b7d48c591b8f430';
        
        nip = [SELECT account.NIP__c from account where Id = :account][0].NIP__c;
        
        endpoint = 'http://intercodec.cz/subdom/fleetcor/www/?nip=' + nip + '&apiKey=' + apiKey;
        
        //endpoint += '&fields='+fields;
        
        Http h = new Http();
            HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                //req.setMethod('GET');
                req.setMethod('POST');
                req.setBody('fields='+ fields);
                req.setCompressed(true);
            HttpResponse res = h.send(req);
        response = res.getBody();
        processResponse();
    }
    
    public void processResponse()
    {
        Map<String, String> keyValues = (Map<String, String>) JSON.deserialize(response, Map<String, String>.class);
        
        Account a = Database.query(
            String.format(
                'SELECT website FROM Account WHERE Id = \'\'{0}\'\'', new String[]{ account }
            )
        );
        
        for(String key : keyValues.keySet()) {
            String value = keyValues.get(key);
            try
            {
                /*if(value.isNumeric()) {
                    a.put(key, Integer.valueOf(value));
                }
                else{*/
                    a.put(key, value);
               // }
                update a;
            } catch (DmlException e) {
                
            }
        }
    }
    
    public pagereference actionReport()
    {
        account = Apexpages.currentPage().getParameters().get('id');
        fields = getFields();
        sendRequest();
        
        return null;
    }
}