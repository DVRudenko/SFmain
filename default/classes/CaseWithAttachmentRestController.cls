@RestResource(UrlMapping = '/caseManagement/caseWithAttachment/v1')
global class CaseWithAttachmentRestController {

    public static final String VALIDATION_ERROR_MESSAGE = 'Required url parameter is missing: ';

    /*******************************************************************************
    *  Name            : createCaseWithAttachment()
    *  Summary         : creates a new Case with single related attachment
    *  CreatedDate     : 25.06.2019
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @HttpPost
    global static void createCaseWithAttachment() {
        Savepoint savepoint = Database.setSavepoint();
        try {
            Blob requestBody = RestContext.request.requestBody;
            Map<String, String> params = RestContext.request.params;
            RestServiceUtils.base64DecodeQueryParams(params);
            //check required fields
            Boolean isCCSSiteWebform = (params.get('country') == 'Czech Republic') || (params.get('country') == 'Slovakia');
            params.put('subject', (isCCSSiteWebform ? params.get('topic') : params.get('subject')));
            List<String> validationErrors = validateRequiredFields(requestBody, params);
            if ( !validationErrors.isEmpty()) {
                //if validation fails, send validation error response
                RestServiceUtils.setJSONRestResponse(RestContext.response, null, false, 400, validationErrors);
                return;
            }
            Case_management_settings__c settings = Case_management_settings__c.getInstance('SettingsEU');
            Case createdCase = RestServiceUtils.createCase(params, settings.Case_from_web_initial_status__c,
                    settings.Case_from_web_origin__c, settings.Case_from_web_priority__c, isCCSSiteWebform);
            //insert Case
            insert createdCase;
            //create and insert initial message
            EmailMessage message = RestServiceUtils.createMessage(createdCase, isCCSSiteWebform);
            insert message;
            Attachment newAttachment = RestServiceUtils.createAttachment(message.Id, params, requestBody);
            //insert Attachment
            insert newAttachment;
            //send response
            RestServiceUtils.setJSONRestResponse(RestContext.response, createdCase.Id, true, 200, null);
        } catch (Exception ex) {
            //if errors, log it and return error response
            Database.rollback(savepoint);
            ExceptionLogger.sendException(ex.getMessage() + '\n' + JSON.serialize(RestContext.request.params), ex.getStackTraceString());
            RestServiceUtils.setJSONRestResponse(RestContext.response, null, false, 500, new List<String> {ex.getMessage()});
        }
    }


    /*******************************************************************************
    *  Name            : validateRequiredFields()
    *  Summary         : validates required fields
    *  CreatedDate     : 17.06.2019
    *  Parameters      : Blob requestBody, Map<String, String> requestParams - parameters from URI and request body
    *  Returns         : List<String> - errors if any
    ******************************************************************************/
    private static List<String> validateRequiredFields(Blob requestBody, Map<String, String> requestParams) {
        List<String> errors = new List<String>();
        if (String.isBlank(requestParams.get('email'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'email');
        }
        if (String.isBlank(requestParams.get('fullName'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'fullName');
        }
        if (String.isBlank(requestParams.get('country'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'country');
        }
        if (String.isBlank(requestParams.get('language'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'language');
        }
        if (String.isBlank(requestParams.get('description'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'description');
        }
        if (String.isBlank(requestParams.get('topic'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'topic');
        }
        if (String.isBlank(requestParams.get('subTopic')) && !(requestParams.get('country') == 'Czech Republic' || requestParams.get('country') == 'Slovakia')) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'subTopic');
        }
        if (String.isBlank(requestParams.get('subject'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'subject');
        }
        if (requestBody == null || requestBody.size() < 1) {
            errors.add('Request body is empty');
        }
        if (String.isBlank(requestParams.get('fileContentType'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'fileContentType');
        }
        if (String.isBlank(requestParams.get('fileName'))) {
            errors.add(VALIDATION_ERROR_MESSAGE + 'fileName');
        } else if (requestParams.get('fileName').containsNone('.')) {
            errors.add('Extension of filename is missing');
        }
        return errors;
    }

}