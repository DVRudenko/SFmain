@RestResource(urlMapping='/sf-ru-conrtact-proccessing/v1/contract-status')
global with sharing class DirectumContractRestController {

    @HttpPost
    global static void updateContract() {
        RestResponse response = RestContext.response;
        DirectumResponseBody responseBody = new DirectumResponseBody();
        Logger logger = new Logger('DirectumContractRestController');
        try {
            String jsonStr = RestContext.request.requestBody.toString();
            logger.info(RestContext.request.httpMethod + ' request from '
                    + RestContext.request.remoteAddress, jsonStr);
            DirectumContractStatusRequestBody res = DirectumContractStatusRequestBody.parse(jsonStr);
            if (res != null) {

                // TODO тут будут методы по обработке запроса contract-status

                // return response
                response.statusCode = 200; //if accepted and converted
                responseBody.message = 'Contract updated successfully';
                response.responseBody = Blob.valueOf(JSON.serializePretty(responseBody, true));
            }
        } catch (Exception e) {
            responseBody.message = e.getTypeName() + ': ' + e.getMessage();
            response.responseBody = Blob.valueOf(JSON.serializePretty(responseBody, true));
            response.statusCode = 500;  //server error
            logger.fatal('/sf-ru-conrtact-proccessing/v1/contract-status method exception', responseBody.message);
        } finally {
            //save all logs
            logger.saveLogs();
            System.debug('response statusCode = ' + response.statusCode);
            System.debug('response message = ' + responseBody.message);
        }
    }
}