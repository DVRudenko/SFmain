public class ETEResponseHandler {

    public Map<String, Object> generateResponseStatus(String message) {
        Map<String, Object> responseMap = new Map<String, Object>();
        Integer statusCode = returnStatusCode(message);
        responseMap.put('statusCode', statusCode);
        if (statusCode != 200) {
            responseMap.put('message', message);
        } else {
            responseMap.put('message', 'unknown error');
        }
        return responseMap;
    }

    private static Integer returnStatusCode(String errorMessage) {
        switch on errorMessage {
            when null,
                    'report ordering',
                    'Black list',
                    'High e-mail risk',
                    'High risk industry' {
                return 100;
            }
            when 'job pending' {
                return 101;
            }
            when 'order completed' {
                return 102;
            }
            when 'redirection need' {
                return 103;
            }
            // Credit Logic
            when 'Too high limit',
                    'Too risky',
                    'Risky but manageable',
                    'Inactive company',
                    'Empty address',
                    'Negative information',
                    'Executions and potentially high exposure' {
                return 104;
            }
            when 'report pending' {
                return 105;
            }
            // CF System Error
            when 'Unknown credit factory error',
                'The order is still being processed. Please contact your administrator.' {
                return 106;
            }
            when 'authorization need' {
                return 107;
            }
            when 'verification code is not valid' {
                return 108;
            }
            when else {
                return 200;
            }
        }
    }

    public String checkCreditScoringErrors(String verdict, String statusCode) {
        if (verdict == 'Yes' && statusCode == '001') {
            return null;
        } else if (verdict == 'No' && (statusCode == '002' || statusCode == '004')) {
            return 'Too high limit';
        } else if (verdict == 'No' && statusCode == '005') {
            return 'Too risky';
        } else if (verdict == 'No' && statusCode == '006') {
            return 'Risky but manageable';
        } else if (verdict == 'No' && statusCode == '008') {
            return 'Black list';
        } else if (verdict == 'No' && statusCode == '009') {
            return 'High e-mail risk';
        } else if (verdict == 'No' && statusCode == '010') {
            return 'High risk industry';
        } else if (verdict == 'No' && statusCode == '007') {
            return 'Too risky';
        } else if (verdict == 'No' && statusCode == '012') {
            return 'Inactive company';
        } else if (verdict == 'No' && statusCode == '013') {
            return 'Empty address';
        } else if (verdict == 'No' && statusCode == '014') {
            return 'Executions and potentially high exposure';
        } else if (verdict == 'No' && statusCode == '016') {
            return 'Negative information';
        } else {
            return 'Unknown credit factory error';
        }
    }


    public void createExceptionLog(Map<String, Object> exceptionLogParams) {
        if (! exceptionLogParams.isEmpty()) {
            String countryCode = String.valueOf(exceptionLogParams.get('countryCode'));
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
            String recordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Exception').getRecordTypeId();
            String dataObjectId = ETEGlobalUtils.doDecryptParams((String) exceptionLogParams.get('source'), countryCode);
            E2E_Data_Log__c newExceptionDataLog = new E2E_Data_Log__c();
            newExceptionDataLog.put('Name', 'Exception on ' + String.valueOf(exceptionLogParams.get('currentStep')) + ' step');
            newExceptionDataLog.put('E2E_Data_Object__c', dataObjectId);
            newExceptionDataLog.put('RecordTypeId', recordTypeId);
            if (exceptionLogParams.containsKey('statusCode') && exceptionLogParams.get('statusCode') != null) {
                newExceptionDataLog.put('Error_Code__c', Decimal.valueOf(String.valueOf(exceptionLogParams.get('statusCode'))));
            }
            newExceptionDataLog.put('Exception_Type__c', exceptionLogParams.get('exceptionType'));
            newExceptionDataLog.put('Exception_Description__c', exceptionLogParams.get('exceptionMessage'));
            newExceptionDataLog.put('Exception_Source__c', exceptionLogParams.get('exceptionSource'));
            newExceptionDataLog.put('Device_Type__c', exceptionLogParams.get('deviceType'));
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{newExceptionDataLog});
        }
    }


    public Map<String, Object> prepareExceptionLogParams(Map<String, Object> requestParams,
            String deviceType,
            Object statusCode,
            String errorMessage,
            Exception exceptionDetails,
            String exceptionSource) {
        Map<String, Object> exceptionLogParamsMap = new Map<String, Object>();
        if (requestParams.containsKey('user_model')) {
            String requestUserModelJson = JSON.serialize(requestParams.get('user_model'));
            ETEUserModel userModelFromRequest = (ETEUserModel) System.JSON.deserialize(requestUserModelJson, Type.forName('ETEUserModel'));
            if (! String.isEmpty(userModelFromRequest.source)) {
                exceptionLogParamsMap.put('currentStep', userModelFromRequest.currentStep);
                exceptionLogParamsMap.put('countryCode', userModelFromRequest.countryCode);
                exceptionLogParamsMap.put('source', userModelFromRequest.source);
            }
        } else if (requestParams.containsKey('source') && requestParams.containsKey('country')) {
            String countryCode = (String) requestParams.get('country');
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
            String dataObjectId = ETEGlobalUtils.doDecryptParams((String) requestParams.get('source'), countryCode);
            E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
            exceptionLogParamsMap.put('currentStep', dataObject.Current_Step__c);
            exceptionLogParamsMap.put('countryCode', dataObject.Country_Code__c);
            exceptionLogParamsMap.put('source', requestParams.get('source'));
        }
        if (! exceptionLogParamsMap.isEmpty()) {
            exceptionLogParamsMap.put('deviceType', deviceType);
            exceptionLogParamsMap.put('exceptionSource', exceptionSource);
            exceptionLogParamsMap.put('statusCode', statusCode);
            if (exceptionDetails != null) {
                errorMessage += ' (Cls: ' + exceptionDetails.getStackTraceString() + ')';
                exceptionLogParamsMap.put('exceptionType', 'System Error');
            } else {
                if (statusCode == 104 || statusCode == 100) {
                    exceptionLogParamsMap.put('exceptionType', 'Credit Logic');
                } else if (statusCode == 106) {
                    exceptionLogParamsMap.put('exceptionType', 'CF System Error');
                }
            }
            exceptionLogParamsMap.put('exceptionMessage', errorMessage);
        }
        return exceptionLogParamsMap;
    }


    public String convertResponseToJson(Map<String, Object> responseParams) {
        String responseJson = JSON.serialize(responseParams);
        return responseJson;
    }
}
