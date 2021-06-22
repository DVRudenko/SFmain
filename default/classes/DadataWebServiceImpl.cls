public without sharing class DadataWebServiceImpl implements DadataWebService {

    public static String token = 'd5182da81809ba8c3ff0c20337c7dc760911eea4';
    public static String url = 'https://suggestions.dadata.ru';

    public DadataBank getBankData(String bic) {
        String url = url + '/suggestions/api/4_1/rs/findById/bank';
        String requestBody = '{"query": "' + bic + '"}';
        HttpResponse response = post(requestBody, url);
        if (response.getStatusCode() == 200) {
            DadataBank dadataBank = new DadataBank();
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> suggestions = (List<Object>) responseBody.get('suggestions');
            Map<String, Object> suggestion = (Map<String, Object>) suggestions.get(0);
            Map<String, Object> data = (Map<String, Object>) suggestion.get('data');
            Map<String, Object> name = (Map<String, Object>) data.get('name');
            Map<String, Object> address = (Map<String, Object>) data.get('address');
            dadataBank.name = (String) name.get('payment');
            dadataBank.nameShort = (String) name.get('short');
            dadataBank.bic = (String) data.get('bic');
            dadataBank.correspondentAccount = (String) data.get('correspondent_account');
            dadataBank.okpo = (String) data.get('okpo');
            dadataBank.town = (String) ((Map<String, Object>) address.get('data')).get('city_with_type');
            dadataBank.address = (String) address.get('value');
            return dadataBank;
        } else {
            throw new GlobalException('DadataWebServiceImpl getBankData: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' responseBody ' + response.getBody() + '; requestBody: ' + requestBody);
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getDadataToken() {
        E2E_business_settings__c e2eBusinessSetting = E2E_business_settings__c.getValues(GlobalUtils.FleetcorCountries.Russia.name());
        return e2eBusinessSetting?.DaData_Token__c;
    }

    private HttpResponse post(String body, String url) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Token ' + token);
        request.setBody(body);
        request.setMethod('POST');
        request.setTimeout(120000);
        return new Http().send(request);
    }
}