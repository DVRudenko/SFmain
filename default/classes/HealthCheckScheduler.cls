global class HealthCheckScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Credit Factory
        Database.executeBatch(new HealthCheckCreditFactoryBatch(), 1);

        // Vat
        Database.executeBatch(new HealthCheckVatIdCheckBatch(), 1);

		// Ingenico
        testIngenico();        

        // Docusign
        testDocusign();	

        // Locator
        Database.executeBatch(new HealthCheckLocatorBatch(), 1);
    }

    @future(callout=true)
    global static void testIngenico() {
    	try {
			String endPoint;
			String PSPID;
			endPoint = 'https://secure.ogone.com/ncol/prod//orderstandard_utf8.asp?';
			PSPID = 'fleetcorPROD';

			String amount = '1000';
			String brand = 'Visa';
			String PM = 'CreditCard';
			String currencyTransaction = 'EUR';
			String orderId = 'OrderNoTesz-999999999';
			String SHAkey =  E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c;
			String SHASIGN = E2EFormEncryption.getHashAlgorithmStringSHA1(
			               'AMOUNT=' + amount + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c +
			               'BRAND=' + brand + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c +
			               'CURRENCY=' + currencyTransaction + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c +
			               'ORDERID=' + orderId + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c +
			               'PM=' + PM + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c +
			               'PSPID=' + PSPID + E2EKeysAPI__c.getValues('E2EForm').SHA_KeyIn__c);

			HttpRequest req = new HttpRequest();
			req.setEndpoint(endpoint+'ORDERID='+orderId+'&PSPID='+PSPID+'&CURRENCY='+currencyTransaction+'&AMOUNT='+amount+'&BRAND='+brand+'&PM='+PM+'&SHASIGN='+SHASIGN);
			req.setMethod('GET');
			Http http = new Http();
			HttpResponse res = http.send(req);
			String jsonData = res.getBody();
 	    	if (jsonData == null) {
	            Health_Check__c log = new Health_Check__c(
	                Name='Ingenico WebServiceError',
	                Country__c = 'Germany',
	                Error__c = 'Web Service response is empty');
	            insert log;	
 	    	} else 
 	    	if ( ! jsonData.containsIgnorecase('<TITLE>Payment confirmation</TITLE>') ) {
	            Health_Check__c log = new Health_Check__c(
	                Name='Ingenico WebServiceError',
	                Country__c = 'Germany',
	                Error__c = 'Web Service response is not valid');
	            insert log;	
 	    	}
    	} catch (Exception e) {
            Health_Check__c log = new Health_Check__c(
                Name='Ingenico WebServiceError',
                Country__c = 'Germany',
                Error__c = 'Web Service is not available',
                Error_Description__c = e.getMessage());
            insert log;	    	     
    	}
    }	

	@future(callout=true)
	global static void testDocusign() {
		try {
			String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
			String userId = 'e425921f-bf72-4a5b-84af-2dbdc472a16e'; // sandbox user
			String password = 'Fleetcor2019!'; // sandbox user password
			String integratorsKey = '57c6330f-6449-4c36-9336-482e9a2d6cdf';
			String accoungId = '68300806-41ed-466c-a7f1-9c97ace583e0';
			String auth = '<DocuSignCredentials><Username>' + userId 
			            + '</Username><Password>' + password 
			            + '</Password><IntegratorKey>' + integratorsKey 
			            + '</IntegratorKey></DocuSignCredentials>';

			String envelopeId;
			String token;

			DocusignNetApi30.ApiServiceSOAP dsApiSend = dsapi_send(webServiceUrl, auth);

			// create envelope info
			DocusignNetApi30.EnvelopeInformation envelope = new DocusignNetApi30.EnvelopeInformation();
			envelope.Subject = 'Test subject';
			envelope.EmailBlurb = 'Test body';
			envelope.AccountId  = accoungId;

			// Recipient Information
			DocusignNetApi30.Recipient recipient = new DocusignNetApi30.Recipient();
			recipient.ID = 1;
			recipient.Type_x = 'Signer';
			recipient.RoutingOrder = 1;
			recipient.Email = 'test@test.com';
			recipient.UserName = 'Test';
			recipient.RoleName = 'Signer';

			// make recipient captive for embedded experience
			recipient.CaptiveInfo = new DocusignNetApi30.RecipientCaptiveInfo();
			recipient.CaptiveInfo.ClientUserId = '1';

			// Role assignments
			DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment();
			roleAssignment.RoleName = recipient.RoleName;
			roleAssignment.RecipientID = recipient.ID;

			// Create array of recipients
			DocusignNetApi30.ArrayOfRecipient1 signers = new DocusignNetApi30.ArrayOfRecipient1();
			signers.Recipient = new DocusignNetApi30.Recipient[1];
			signers.Recipient[0] = recipient;

			// create array of templates
			DocusignNetApi30.ArrayOfTemplateReference templateReferences = generateDocusignTemplates(roleAssignment);

			// create docusign envelope from templates
			if ( ! Test.isRunningTest() ) {
				DocusignNetApi30.EnvelopeStatus envelopeStatus = dsApiSend.CreateEnvelopeFromTemplates(templateReferences, signers, envelope, true);
				envelopeId = envelopeStatus.EnvelopeID;
			}

			// assumes apiService = preconfigured api proxy
			DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion authenticationAssert = new DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion();
			authenticationAssert.AssertionID = 'Your AssertionID Here';
			authenticationAssert.AuthenticationInstant = system.now();
			authenticationAssert.AuthenticationMethod = 'Password';
			authenticationAssert.SecurityDomain = 'YourApp.com';

			DocusignNetApi30.RequestRecipientTokenClientURLs clientURLs = new DocusignNetApi30.RequestRecipientTokenClientURLs();
			clientURLs.OnAccessCodeFailed = getURL();
			clientURLs.OnCancel = getURL();
			clientURLs.OnDecline = getURL();
			clientURLs.OnException = getURL();
			clientURLs.OnFaxPending = getURL();
			clientURLs.OnIdCheckFailed = getURL();
			clientURLs.OnSessionTimeout = getURL();
			clientURLs.OnSigningComplete = getURL();
			clientURLs.OnTTLExpired = getURL();
			clientURLs.OnViewingComplete = getURL();

			token = dsApiSend.RequestRecipientToken(envelopeId, recipient.captiveinfo.ClientUserId, recipient.UserName, recipient.Email, authenticationAssert, clientURLs);
			System.debug('DEBUG: token === ' + token);
			if (token == null) {
	            Health_Check__c log = new Health_Check__c(
	                Name='Docusign WebServiceError',
	                Country__c = 'Poland',
	                Error__c = 'Token is not valid');
	            insert log;
			}

			// delete envelope from docusign
			DocusignNetApi30.DeleteEnvelopesArg arg = new DocusignNetApi30.DeleteEnvelopesArg();
			DocusignNetApi30.ArrayOfString2 arrayOfStrings = new DocusignNetApi30.ArrayOfString2();
			arrayOfStrings.EnvelopeId = new List<String>();
			arrayOfStrings.EnvelopeId.add(envelopeId);

			DocusignNetApi30.FolderTypeInfo sentFolder = new DocusignNetApi30.FolderTypeInfo();
			sentFolder.FolderType = 'SentItems';
			sentFolder.FolderName = 'Sent';

			arg.EnvelopeIds = arrayOfStrings;
			arg.AccountId = accoungId;
			arg.FolderFrom = sentFolder;

			dsApiSend.DeleteEnvelopes(arg);

			// delete docusign status from SF
			List<dsfs__DocuSign_Status__c> docusignStatus = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE dsfs__Subject__c = :envelope.Subject AND dsfs__Envelope_Status__c = 'Voided'];
			if ( ! docusignStatus.isEmpty() ) {
			    delete docusignStatus;
			}			
		} catch (Exception e) {
            Health_Check__c log = new Health_Check__c(
                Name='Docusign WebServiceError',
                Country__c = 'Poland',
                Error__c = 'Web Service is not available',
                Error_Description__c = e.getMessage());
            insert log;			
		}
	}

	private static DocusignNetApi30.APIServiceSoap dsapi_send(String webServiceUrl, String auth) {
	    // Get DSapi and authenticate
	    DocusignNetApi30.APIServiceSoap dsApiSend = new DocusignNetApi30.APIServiceSoap();
	    dsApiSend.endpoint_x = webServiceUrl;
	    dsApiSend.inputHttpHeaders_x = new Map<String, String>();
	    dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
	    return dsApiSend;
	}

	private static String getURL() {
	    String popURL = URL.getSalesforceBaseUrl().toExternalForm();
	    return popURL + '/apex/e2eformpl?source=&test=test';
	}

	private static DocusignNetApi30.ArrayOfTemplateReference generateDocusignTemplates(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment) {
	    DocusignNetApi30.ArrayOfTemplateReference templateReferences = new DocusignNetApi30.ArrayOfTemplateReference();
	    String templateId = '44aa7e57-375e-49d9-8a3d-ae81d94e62a2';

	    // Create object for server-side template
	    DocusignNetApi30.TemplateReference docusignTemplate = new DocusignNetApi30.TemplateReference();
	    docusignTemplate.Template = templateId;
	    docusignTemplate.TemplateLocation = 'Server';

	    // Add role assignment
	    docusignTemplate.RoleAssignments = new DocusignNetApi30.ArrayOfTemplateReferenceRoleAssignment();
	    docusignTemplate.RoleAssignments.RoleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment[1];
	    docusignTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;

	    templateReferences.TemplateReference = new List<DocusignNetApi30.TemplateReference>();
	    templateReferences.TemplateReference.add(docusignTemplate);

	    return templateReferences;
	}    
}