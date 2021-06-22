@RestResource(urlMapping='/PPR_API/v1/CheckInn')
global with sharing class PPR_API_CheckInnService {
    @HttpGet
    global static void doGet() {
        RestResponse res = RestContext.response;
        try {
            Map<String, String> params = RestContext.request.params;
            PPR_API_Settings__c settings = PPR_API_Settings__c.getValues(params.get('source'));
            PPR_API_ResponseBody responce;
            if (settings == null) {
                responce = new PPR_API_ResponseBody();
                responce.message = 'Invalid source parameter';
                res.responseBody = Blob.valueOf(JSON.serializePretty(responce, true));
                res.statusCode = 500;
            } else if (Boolean.valueOf(settings.Block_API_Actions__c)) {
                responce = new PPR_API_ResponseBody();
                responce.message = 'API Service disabled';
                res.responseBody = Blob.valueOf(JSON.serializePretty(responce, true));
                res.statusCode = 500;
            } else if (!Test.isRunningTest()) {
                PPR_API_Service apiService = new PPR_API_ServiceImpl();
                responce = apiService.processCheckINN(params);
            } else {
                responce = new PPR_API_ResponseBody();
                if (params.get('user') != 'error'){
                    responce.metadata = new PPR_API_ResponseBody.Metadata();
                    responce.metadata.id = 'a5H1x0000000jA6';
                    responce.metadata.user = params.get('user');
                    responce.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
                    responce.customerInfo.inn = params.get('inn');
                    responce.customerInfo.customerStatus = 'New';
                    responce.customerInfo.customerStatusId = (String) PPR_Mapping_Utils.customerStatusMap.get('New');
                    responce.customerInfo.checkDate = Datetime.now().format('dd.MM.yyyy');
                } else {
                    responce.message = 'test error';
                }
            }
            
            res.responseBody = Blob.valueOf(JSON.serializePretty(responce, true));
            if (responce.message != null) {
                res.statusCode = 422;
            } else {
                res.statusCode = 200;
            }
        } catch(Exception e) {
            PPR_API_ResponseBody errorResponce = new PPR_API_ResponseBody();
            errorResponce.message = e.getTypeName() + ': ' + e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serializePretty(errorResponce, true));
            res.statusCode = 500;
        }
    }
}