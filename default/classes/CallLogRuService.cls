@RestResource(urlMapping='/CallLogRuService')
global class CallLogRuService {

    /*******************************************************************************
    *  Name            : receiveCallLogInformation
    *  Summary         : process call data which is sent from Naumen (for calls which were not connected to operator)
    *  CreatedDate     : 24.01.2020
    *  ModifiedDate    : 24.01.2020
    *  Parameters      : --
    *  Returns         : String - result of processing
    ******************************************************************************/
    @HttpPost
    global static String receiveCallLogInformation() {
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            CallLogRu logRu = CallLogRu.parse(jsonBody);
            Database.executeBatch(new CallLogRuBatch(logRu));
            String subject = 'Request has been successfully received';
            String body = '"REQUEST PARAMS": '+ RestContext.request.params +' ||| "REQUEST HEADER":'+ String.join(RestContext.request.headers.values(), ',') + ' ||| "REQUEST BODY":' + RestContext.request.requestBody.toString();
            Naumen_RecordsHelper.sendLogsEmail(body, subject);
            return 'Request has been successfully received' + ' ||| ' + logRu;
        } catch(Exception e) {
            String errMsg = 'PhoneLogService - Invalid Request. Error in service processing. ' + String.valueOf(e.getMessage()) + ' ||| Stack Trace: ' + String.valueOf(e.getStackTraceString()) + '||| "REQUEST PARAMS": '+ RestContext.request.params +' ||| "REQUEST HEADER":'+ String.join(RestContext.request.headers.values(), ',') + ' ||| "REQUEST BODY":' + RestContext.request.requestBody.toString();
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            return 'Invalid Request. Error in service processing';
        }
    }

}