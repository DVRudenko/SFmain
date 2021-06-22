@RestResource(UrlMapping='/caseManagement/case/v1')
global with sharing class CaseRestController {

    /*******************************************************************************
    *  Name            : createCase()
    *  Summary         : creates a new Case
    *  CreatedDate     : 17.06.2019
    *  Parameters      : String email, String fullName, String country, String language,
    *                  : String description, String topic, String subTopic,
    *                  : String customerId, String phoneNumber, String subject - JSON fields
    *  Returns         : -
    ******************************************************************************/
    @HttpPost
    global static void createCase(String email, String fullName, String country, String language,
            String description, String topic, String subTopic, String customerId, String phoneNumber, String subject, String ico) {
        try {
            Map<String, String> requiredFieldsMap = new Map<String, String> {
                    'email' => email,
                    'fullName' => fullName,
                    'country' => country,
                    'language' => language,
                    'description' => description,
                    'topic' => topic
            };
            //check required fields
            Boolean isCCSSiteWebform = (country == 'Czech Republic') || (country == 'Slovakia');
            requiredFieldsMap.put('subject', isCCSSiteWebform ? topic : subject);
            List<String> validationErrors = RestServiceUtils.validateRequiredFields(requiredFieldsMap);
            if ( !validationErrors.isEmpty()) {
                //if validation fails, send validation error response
                RestServiceUtils.setJSONRestResponse(RestContext.response, null, false, 400, validationErrors);
                return;
            }
            //create new Case and its initial message
            Map<String, String> allFieldsMap = requiredFieldsMap;
            allFieldsMap.put('customerId', customerId);
            allFieldsMap.put('phoneNumber', phoneNumber);
            allFieldsMap.put('subTopic', subTopic);
            allFieldsMap.put('ico', ico);
            Case_management_settings__c settings = Case_management_settings__c.getInstance('SettingsEU');
            Case createdCase = RestServiceUtils.createCase(allFieldsMap, settings.Case_from_web_initial_status__c,
                    settings.Case_from_web_origin__c, settings.Case_from_web_priority__c, isCCSSiteWebform);
            //commit to DB
            insert createdCase;
            EmailMessage emailMessage = RestServiceUtils.createMessage(createdCase, isCCSSiteWebform);
            insert emailMessage;
            //if success send success response
            RestServiceUtils.setJSONRestResponse(RestContext.response, createdCase.Id, true, 200, null);
        } catch (Exception ex) {
            //if exceptions, log it and return error response
            ExceptionLogger.sendException(ex.getMessage(), ex.getStackTraceString());
            RestServiceUtils.setJSONRestResponse(RestContext.response, null, false, 500, new List<String> {ex.getMessage()});
        }
    }

}