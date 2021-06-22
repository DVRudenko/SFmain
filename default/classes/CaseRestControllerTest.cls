@IsTest
public with sharing class CaseRestControllerTest {

    private static final String VALIDATION_ERROR_MESSAGE = 'Required field is missing: ';

    static {
        Case_management_settings__c settings = new Case_management_settings__c();
        settings.Name = 'SettingsEU';
        settings.Case_from_web_priority__c = 'Medium';
        settings.Case_from_web_origin__c = 'Web';
        settings.Case_from_web_initial_status__c = 'New';
        insert settings;
    }

    private static RestRequest prepareRequest() {
        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json;charset=UTF-8');
        request.httpMethod = 'POST';
        request.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/caseManagement/case/v1';
        return request;
    }

    @TestSetup
    static void createdTestData(){
        Account acc = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Endkunde'),
                Name = 'Test GFN Account',
                GFN_Nr__c = 'DE12478550',
                ColCo__c = 'DE',
                BillingCountry = 'Germany'
        );
        insert acc;

        Contact newContact = new Contact (
    		Salutation = 'Herr',
    		FirstName = 'Bob',
    		LastName  = 'Test',
    		Phone = '1234567',
    		MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
    		MailingStreet = '298 S. Ringo Street',
    		MailingCity = 'Little Rock',
			MailingPostalCode = '72201',
            Email = 'alex.fleetcor@gmail.com',
            AccountId = acc.Id
		);
		insert newContact;
    }

    @IsTest
    public static void testStatus200OptionalNull() {
        RestContext.request = prepareRequest();
        RestContext.request.requestBody = Blob.valueOf(
                '{"email": "alex.fleetcor@gmail.com",' +
                        '"fullName": "John cooper",' +
                        '"country": "Germany",' +
                        '"language": "German",' +
                        ' "description": "Ich brauche hilfe!",' +
                        ' "topic": "Invoices & Payments",' +
                        ' "subTopic": "Invoice Resend",' +
                        ' "customerId": null, ' +
                        '"phoneNumber": null, ' +
                        '"subject": "Erneute Rechnungs-Übersendung", ' +
                        '"ico": "12345678"}'
        );
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseRestController.createCase(
                String.valueOf(body.get('email')),
                String.valueOf(body.get('fullName')),
                String.valueOf(body.get('country')),
                String.valueOf(body.get('language')),
                String.valueOf(body.get('description')),
                String.valueOf(body.get('topic')),
                String.valueOf(body.get('subTopic')),
                String.valueOf(body.get('customerId')),
                String.valueOf(body.get('phoneNumber')),
                String.valueOf(body.get('subject')),
                String.valueOf(body.get('ico'))
        );
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(true, responseBody.success);
        System.assertNotEquals(null, responseBody.id);
        System.assertEquals(null, responseBody.errors);
        Case createdCase = ([
                SELECT Id, SuppliedEmail, SuppliedName, SuppliedPhone, Topic__c, Subject,
                        Sub_topic__c, Description, Customer_ID__c, Country__c, Language__c
                FROM Case
                WHERE Id = :responseBody.id
        ]);
        System.assertEquals(String.valueOf(body.get('email')), createdCase.SuppliedEmail);
        System.assertEquals(String.valueOf(body.get('fullName')), createdCase.SuppliedName);
        System.assertEquals(String.valueOf(body.get('country')), createdCase.Country__c);
        System.assertEquals(String.valueOf(body.get('language')), createdCase.Language__c);
        System.assertEquals(String.valueOf(body.get('description')), createdCase.Description);
        System.assertEquals(String.valueOf(body.get('topic')), createdCase.Topic__c);
        System.assertEquals(String.valueOf(body.get('subTopic')), createdCase.Sub_topic__c);
        System.assertEquals(null, createdCase.Customer_ID__c);
        System.assertEquals(String.valueOf(body.get('subject')), createdCase.Subject);
        System.assertEquals(null, createdCase.SuppliedPhone);

    }

    @IsTest
    public static void testStatus200() {
        RestContext.request = prepareRequest();
        RestContext.request.requestBody = Blob.valueOf(
                '{"email": "alex.fleetcor@gmail.com",' +
                        '"fullName": "John cooper",' +
                        '"country": "Germany",' +
                        '"language": "German",' +
                        ' "description": "Ich brauche hilfe!",' +
                        ' "topic": "Invoices & Payments",' +
                        ' "subTopic": "Invoice Resend",' +
                        ' "customerId": "DE12345678", ' +
                        '"phoneNumber": "88005553535", ' +
                        '"subject": "Erneute Rechnungs-Übersendung", ' +
                        '"ico": "12345678"}'
        );
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseRestController.createCase(
                String.valueOf(body.get('email')),
                String.valueOf(body.get('fullName')),
                String.valueOf(body.get('country')),
                String.valueOf(body.get('language')),
                String.valueOf(body.get('description')),
                String.valueOf(body.get('topic')),
                String.valueOf(body.get('subTopic')),
                String.valueOf(body.get('customerId')),
                String.valueOf(body.get('phoneNumber')),
                String.valueOf(body.get('subject')),
                String.valueOf(body.get('ico'))
        );
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(true, responseBody.success);
        System.assertNotEquals(null, responseBody.id);
        System.assertEquals(null, responseBody.errors);
        Case createdCase = ([
                SELECT Id, SuppliedEmail, SuppliedName, SuppliedPhone, Topic__c, Subject,
                        Sub_topic__c, Description, Customer_ID__c, Country__c, Language__c
                FROM Case
                WHERE Id = :responseBody.id
        ]);
        System.assertEquals(String.valueOf(body.get('email')), createdCase.SuppliedEmail);
        System.assertEquals(String.valueOf(body.get('fullName')), createdCase.SuppliedName);
        System.assertEquals(String.valueOf(body.get('country')), createdCase.Country__c);
        System.assertEquals(String.valueOf(body.get('language')), createdCase.Language__c);
        System.assertEquals(String.valueOf(body.get('description')), createdCase.Description);
        System.assertEquals(String.valueOf(body.get('topic')), createdCase.Topic__c);
        System.assertEquals(String.valueOf(body.get('subTopic')), createdCase.Sub_topic__c);
        System.assertEquals(String.valueOf(body.get('customerId')), createdCase.Customer_ID__c);
        System.assertEquals(String.valueOf(body.get('subject')), createdCase.Subject);
        System.assertEquals(String.valueOf(body.get('phoneNumber')), createdCase.SuppliedPhone);

    }

    @IsTest
    public static void testStatus500() {
        RestContext.request = prepareRequest();
        RestContext.request.requestBody = Blob.valueOf(
                '{"email": "alex.fleetcor@gmail.com",' +
                        '"fullName": "John cooper",' +
                        '"country": "Germany",' +
                        '"language": "German",' +
                        ' "description": "Ich brauche hilfe!",' +
                        ' "topic": "Invoices & Payments",' +
                        ' "subTopic": "IbIbIbIbIbIbIbIbIbIbIbIbIbIbIbIbIbIbIbIb",' +
                        ' "customerId": null, ' +
                        '"phoneNumber": null, ' +
                        '"subject": "Erneute Rechnungs-Übersendung", ' +
                        '"ico": "12345678"}'
        );
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseRestController.createCase(
                String.valueOf(body.get('email')),
                String.valueOf(body.get('fullName')),
                String.valueOf(body.get('country')),
                String.valueOf(body.get('language')),
                String.valueOf(body.get('description')),
                String.valueOf(body.get('topic')),
                String.valueOf(body.get('subTopic')),
                String.valueOf(body.get('customerId')),
                String.valueOf(body.get('phoneNumber')),
                String.valueOf(body.get('subject')),
                String.valueOf(body.get('ico'))
        );
        Test.stopTest();
        System.assertEquals(500, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(false, responseBody.success);
        System.assertEquals(null, responseBody.id);
        System.assertNotEquals(null, responseBody.errors);

    }

    @IsTest
    public static void testStatus400() {
        RestContext.request = prepareRequest();
        RestContext.response = new RestResponse();
        Test.startTest();
        CaseRestController.createCase(
                '',
                '',
                '',
                null,
                ' ',
                '',
                null,
                '',
                ' ',
                '',
                ''
        );
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('application/json;charset=UTF-8', RestContext.response.headers.get('Content-Type'));
        ResponseBody responseBody = (ResponseBody) JSON.deserialize(RestContext.response.responseBody.toString(), ResponseBody.class);
        System.assertEquals(false, responseBody.success);
        System.assertEquals(null, responseBody.id);
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'email'));
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'fullName'));
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'country'));
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'language'));
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'description'));
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'topic'));
        System.assert(responseBody.errors.contains(RestServiceUtils.VALIDATION_ERROR_MESSAGE + 'subject'));
    }

}