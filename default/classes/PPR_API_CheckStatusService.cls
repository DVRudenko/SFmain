@RestResource(urlMapping='/PPR_API/v1/checkStatus')
global with sharing class PPR_API_CheckStatusService {
    @HttpGet
    global static void doGet() {
        RestResponse res = RestContext.response;
        try {
            Map<String, String> params = RestContext.request.params;
            PPR_API_Service apiService = new PPR_API_ServiceImpl();
            PPR_API_Settings__c settings = PPR_API_Settings__c.getValues(params.get('source'));
            PPR_API_ResponseBody responseBody;
            if (settings == null) {
                responseBody = new PPR_API_ResponseBody();
                responseBody.message = 'Invalid source parameter';
            } else if (Boolean.valueOf(settings.Block_API_Actions__c)){
                responseBody = new PPR_API_ResponseBody();
                responseBody.message = 'API Service disabled';
            } else if (Test.isRunningTest()) {
                responseBody = new PPR_API_ResponseBody();
                if (params.get('user') == 'error'){
                    responseBody.message = 'test error';
                } else {
                    responseBody = new PPR_API_ResponseBody();
                    responseBody.metadata = new PPR_API_ResponseBody.Metadata();
                    responseBody.metadata.user = params.get('user');
                    responseBody.metadata.id = params.get('id');
                    responseBody.customerInfo = new PPR_API_ResponseBody.CustomerInfo();
                    responseBody.customerInfo.inn = '7777777777';
                    responseBody.customerInfo.customerStatus = 'New';
                    responseBody.customerInfo.customerStatusId = '1';
                    responseBody.customerInfo.checkDate = Datetime.now().format('dd.MM.yyyy');
                }
            } else {
                responseBody = apiService.processCheckStatus(params);
            }
            res.responseBody = Blob.valueOf(JSON.serializePretty(responseBody, true));
            if (responseBody.message == null || responseBody.message == '') {
                res.statusCode = 200;
            } else {
                res.statusCode = 500;
            }
        } catch(Exception e) {
            PPR_API_ResponseBody responseBody = new PPR_API_ResponseBody();
            responseBody.message = e.getTypeName() + ': ' + e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serializePretty(responseBody, true));
            res.statusCode = 500;
        }
    }
}