@RestResource(urlMapping='/PPR_API/v1/CreateClient')
global with sharing class PPR_API_CreateClient {
    @HttpPost
    global static void doPost() {
        Logger logger = new Logger('PPR API');
        RestResponse res = RestContext.response;
        try {
            logger.info(
                    'Incoming POST request from ' + RestContext.request.remoteAddress
                            + ' to ' + Url.getOrgDomainUrl() + RestContext.request.resourcePath,
                    RestContext.request.requestBody.toString()
            );
            PPR_API_ServiceImpl apiService = new PPR_API_ServiceImpl();
            PPR_API_ResponseBody responce = apiService.validationCheck(RestContext.request.requestBody.toString());
            if (responce != null && responce.message != null) {
                System.debug('message = ' + responce.message);
                res.statusCode = 500;
            } else {
                System.debug('responce = ' + responce);
                res.statusCode = 200;
            }
            res.responseBody = Blob.valueOf(JSON.serializePretty(responce, true));
        } catch(Exception e) {
            logger.fatal('PPR_API_CreateClient.doPost method', e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serializePretty(ResponseBodyBuilder.constructPPR_API_ResponseBodyError(e.getTypeName() + ': ' + e.getMessage()), true));
            res.statusCode = 500;
        } finally {
            logger.saveLogs();
        }
    }
}
