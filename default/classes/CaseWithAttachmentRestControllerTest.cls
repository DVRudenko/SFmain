@IsTest
public with sharing class CaseWithAttachmentRestControllerTest {

    static {
        Case_management_settings__c settings = new Case_management_settings__c();
        settings.Name = 'SettingsEU';
        settings.Case_from_web_priority__c = 'Medium';
        settings.Case_from_web_origin__c = 'Web';
        settings.Case_from_web_initial_status__c = 'New';
        insert settings;
    }

    @IsTest
    public static void testStatus200() {

        RestRequest request = new RestRequest();
        request.addParameter('email', 'alex.fleetcor@gmail.com');
        request.addParameter('fullName', 'John cooper');
        request.addParameter('country', 'Austria');
        request.addParameter('language', 'German');
        request.addParameter('description', 'Ich brauche hilfe!');
        request.addParameter('topic', 'Invoices & Payments');
        request.addParameter('subTopic', 'Invoice Resend');
        request.addParameter('customerId', 'DE1q323424');
        request.addParameter('phoneNumber', '+41234567890');
        request.addParameter('subject', 'Erneute Rechnungs-Übersendung');
        request.addParameter('fileName', 'text.txt');
        request.addParameter('fileContentType', 'text/plain');
        RestServiceUtils.base64EncodeQueryParams(request.params);
        request.httpMethod = 'POST';
        request.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/caseManagement/caseWithAttachment/v1';
        request.requestBody = Blob.valueOf('Hello');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseWithAttachmentRestController.createCaseWithAttachment();
        Test.stopTest();

        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(true, responseBody.success);
        System.assertNotEquals(null, responseBody.id);
        System.assertEquals(null, responseBody.errors);
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));

        Case createdCase = ([
                SELECT Id, SuppliedEmail, SuppliedName, SuppliedPhone, Topic__c, Subject,
                        Sub_topic__c, Description, Customer_ID__c, Country__c, Language__c
                FROM Case
                WHERE Id = :responseBody.id
        ]);
        EmailMessage relatedMessage = [
            SELECT  Id,
                    (
                        SELECT Id, ContentType, Name
                        FROM Attachments
                    )
            FROM    EmailMessage
            WHERE   ParentId =: createdCase.Id
        ];
        Attachment attachment = relatedMessage.Attachments.get(0);
        System.assertEquals(request.params.get('email'), createdCase.SuppliedEmail);
        System.assertEquals(request.params.get('fullName'), createdCase.SuppliedName);
        System.assertEquals(request.params.get('country'), createdCase.Country__c);
        System.assertEquals(request.params.get('language'), createdCase.Language__c);
        System.assertEquals(request.params.get('description'), createdCase.Description);
        System.assertEquals(request.params.get('topic'), createdCase.Topic__c);
        System.assertEquals(request.params.get('subTopic'), createdCase.Sub_topic__c);
        System.assertEquals(request.params.get('customerId'), createdCase.Customer_ID__c);
        System.assertEquals(request.params.get('subject'), createdCase.Subject);
        System.assertEquals(request.params.get('phoneNumber'), createdCase.SuppliedPhone);
        System.assertEquals(request.params.get('fileName'), attachment.Name);
        System.assertEquals(request.params.get('fileContentType'), attachment.ContentType);
    }

    @IsTest
    public static void testStatus200OptionalNull() {

        RestRequest request = new RestRequest();
        request.addParameter('email', 'alex.fleetcor@gmail.com');
        request.addParameter('fullName', 'John cooper');
        request.addParameter('country', 'Austria');
        request.addParameter('language', 'German');
        request.addParameter('description', 'Ich brauche hilfe!');
        request.addParameter('topic', 'Invoices & Payments');
        request.addParameter('subTopic', 'Invoice Resend');
        request.addParameter('customerId', null);
        request.addParameter('phoneNumber', null);
        request.addParameter('subject', 'Erneute Rechnungs-Übersendung');
        request.addParameter('fileName', 'text.txt');
        request.addParameter('fileContentType', 'text/plain');
        RestServiceUtils.base64EncodeQueryParams(request.params);
        request.httpMethod = 'POST';
        request.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/caseManagement/caseWithAttachment/v1';
        request.requestBody = Blob.valueOf('Hello');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseWithAttachmentRestController.createCaseWithAttachment();
        Test.stopTest();

        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(true, responseBody.success);
        System.assertNotEquals(null, responseBody.id);
        System.assertEquals(null, responseBody.errors);
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));

        Case createdCase = ([
                SELECT Id, SuppliedEmail, SuppliedName, SuppliedPhone, Topic__c, Subject,
                        Sub_topic__c, Description, Customer_ID__c, Country__c, Language__c
                FROM Case
                WHERE Id = :responseBody.id
        ]);
        EmailMessage relatedMessage = [
            SELECT  Id,
                    (
                        SELECT Id, ContentType, Name
                        FROM Attachments
                    )
            FROM    EmailMessage
            WHERE   ParentId =: createdCase.Id
        ];
        Attachment attachment = relatedMessage.Attachments.get(0);
        System.assertEquals(request.params.get('email'), createdCase.SuppliedEmail);
        System.assertEquals(request.params.get('fullName'), createdCase.SuppliedName);
        System.assertEquals(request.params.get('country'), createdCase.Country__c);
        System.assertEquals(request.params.get('language'), createdCase.Language__c);
        System.assertEquals(request.params.get('description'), createdCase.Description);
        System.assertEquals(request.params.get('topic'), createdCase.Topic__c);
        System.assertEquals(request.params.get('subTopic'), createdCase.Sub_topic__c);
        System.assertEquals(null, createdCase.Customer_ID__c);
        System.assertEquals(request.params.get('subject'), createdCase.Subject);
        System.assertEquals(null, createdCase.SuppliedPhone);
        System.assertEquals(request.params.get('fileName'), attachment.Name);
        System.assertEquals(request.params.get('fileContentType'), attachment.ContentType);
    }

    @IsTest
    public static void testStatus500() {

        RestRequest request = new RestRequest();
        request.addParameter('email', 'alex.fleetcor@gmail.com');
        request.addParameter('fullName', 'John cooper');
        request.addParameter('country', 'Austria');
        request.addParameter('language', 'German');
        request.addParameter('description', 'Ich brauche hilfe!');
        request.addParameter('topic', 'Invoices & Payments');
        request.addParameter('subTopic', 'sdfgdfgdfg');
        request.addParameter('customerId', 'DE1q323424');
        request.addParameter('phoneNumber', '+41234567890');
        request.addParameter('subject', 'Erneute Rechnungs-Übersendung');
        request.addParameter('fileName', 'text.txt');
        request.addParameter('fileContentType', 'text/plain');
        RestServiceUtils.base64EncodeQueryParams(request.params);
        request.httpMethod = 'POST';
        request.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/caseManagement/caseWithAttachment/v1';
        request.requestBody = Blob.valueOf('Hello');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseWithAttachmentRestController.createCaseWithAttachment();
        Test.stopTest();

        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(false, responseBody.success);
        System.assertEquals(null, responseBody.id);
        System.assertNotEquals(null, responseBody.errors);
        System.assertEquals(500, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
    }

    @IsTest
    public static void testStatus400FileNameEmpty() {

        RestRequest request = new RestRequest();
        request.addParameter('email', '   ');
        request.addParameter('fullName', '');
        request.addParameter('country', '');
        request.addParameter('description', '');
        request.addParameter('topic', '');
        request.addParameter('subTopic', '');
        request.addParameter('customerId', '   ');
        request.addParameter('phoneNumber', '');
        RestServiceUtils.base64EncodeQueryParams(request.params);
        request.httpMethod = 'POST';
        request.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/caseManagement/caseWithAttachment/v1';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseWithAttachmentRestController.createCaseWithAttachment();
        Test.stopTest();

        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(false, responseBody.success);
        System.assertEquals(null, responseBody.id);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'email'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'fullName'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'country'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'language'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'description'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'topic'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'subTopic'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'subject'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'fileName'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'fileContentType'));
        System.assert(responseBody.errors.contains('Request body is empty'));
    }

    @IsTest
    public static void testStatus400FileExtensionEmpty() {

        RestRequest request = new RestRequest();
        request.addParameter('email', '   ');
        request.addParameter('fullName', '');
        request.addParameter('country', '');
        request.addParameter('description', '');
        request.addParameter('topic', '');
        request.addParameter('subTopic', '');
        request.addParameter('customerId', '   ');
        request.addParameter('phoneNumber', '');
        request.addParameter('fileName', 'text');
        RestServiceUtils.base64EncodeQueryParams(request.params);
        request.httpMethod = 'POST';
        request.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/caseManagement/caseWithAttachment/v1';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseWithAttachmentRestController.createCaseWithAttachment();
        Test.stopTest();

        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(false, responseBody.success);
        System.assertEquals(null, responseBody.id);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'email'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'fullName'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'country'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'language'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'description'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'topic'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'subTopic'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'subject'));
        System.assert(responseBody.errors.contains(CaseWithAttachmentRestController.VALIDATION_ERROR_MESSAGE + 'fileContentType'));
        System.assert(responseBody.errors.contains('Extension of filename is missing'));
        System.assert(responseBody.errors.contains('Request body is empty'));
    }

}