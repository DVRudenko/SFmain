public virtual class ETERedirectionServiceBaseImpl implements ETERedirectionService {

    public virtual String callMethodToGetRedirectLink(String action, Map<String, Object> args) {
        action = action.toLowerCase();
        switch on action {
            when 'payu' {
                return getLinkToPayUPaymentGatewayRedirect(action, args);
            }
            when 'ingenico' {
                return getPaymentParamsToIngenicoPaymentGatewayRedirect(action, args);
            }
            when 'docusign_documents' {
                return getLinkToDocusignRedirect(action, args);
            }
            when else {
                throw new LongFormException('Method not implemented');
            }
        }
    }


    public virtual void callMethodToPrepareDataToRedirect(String action, Map<String, Object> args) {
        action = action.toLowerCase();
        switch on action {
            when 'payu', 'ingenico' {
                prepareTransaction((String)args.get('countryCode'), (String)args.get('opptyId'), (Decimal)args.get('deposit'));
            }
        }
    }


    public virtual PageReference callMethodToCheckRedirectionStatus(String action, Map<String, Object> args) {
        action = action.toLowerCase();
        switch on action {
            when 'payu', 'ingenico' {
                return checkPaymentTransactionStatus(action, args);
            }
            when 'docusign' {
                return checkDocusignStatus(args);
            }
            when else {
                throw new LongFormException('Method not implemented');
            }
        }
    }


    public virtual PageReference checkPaymentTransactionStatus(String action, Map<String, Object> args) {
        String countryCode = (String) args.get('countryCode');
        String source = (String)args.get('source');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        if (! String.isEmpty(currentDataObject.Payment_Status__c)) {
            if (currentDataObject.Payment_Status__c == 'COMPLETED' ||
                    currentDataObject.Payment_Status__c == 'CANCELED' ||
                    currentDataObject.Payment_Status__c == 'REJECTED') {
                return ETEGlobalUtils.returnUrlPath(currentDataObject.RecordType.Name);
            }
        }
        return null;
    }


    public virtual PageReference checkDocusignStatus(Map<String, Object> args) {
        String countryCode = (String) args.get('countryCode');
        String source = (String)args.get('source');
        String event = (String)args.get('event');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        Map<String, E2E_Data_Product__c> currentETEProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(currentDataObject.RecordType.Name);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(currentDataObject.RecordType.Name);
        e2eStep.setExistingDataObject(currentDataObject);
        Map<String, Map<String, Object>> stepDependenciesMap = e2eStep.returnStepDependencies(defaultSettingsMap);
        Map<String, Map<String, E2E_Data_Log__c>> existingLogsMap = e2eStep.generateExistingLogsMap(e2eDatabase, source);
        Map<String, Object> filtersOfAvailableStepsMap = new Map<String, Object>();
        filtersOfAvailableStepsMap.put('securityAmountToPay', currentDataObject.Security_Amount_To_Pay__c);
        filtersOfAvailableStepsMap.put('selectedCompanyId', currentDataObject.Selected_Company_Id__c);
        filtersOfAvailableStepsMap.put('paymentMethod', currentDataObject.Payment_Method__c);
        filtersOfAvailableStepsMap.put('paymentMethod', currentDataObject.Payment_Method__c);
        filtersOfAvailableStepsMap.put('product', currentETEProductsMap.values());
        List<String> availableStepsList = e2eStep.getAvailableSteps(defaultSettingsMap, filtersOfAvailableStepsMap);
        List<String> availableStepsForCustomerList = e2eStep.getAvailableStepsForCustomer(currentDataObject,
                                                                                            availableStepsList,
                                                                                            existingLogsMap,
                                                                                            stepDependenciesMap);
        String nextAvailableStep = e2eStep.getNextAvailableStep(currentDataObject,
                                                                availableStepsList,
                                                                existingLogsMap,
                                                                stepDependenciesMap,
                                                                new List<String>(),
                                                                true);
        String transitionStatus = e2eStep.returnTransitionStatus();
        PageReference pageToRedirect;
        if (transitionStatus != 'job pending') {
            if (event == 'OnSigningComplete' || event == 'OnViewingComplete') {
                E2E_Data_Log__c signDocusignDocumentsLog;
                if (existingLogsMap.get('Request Status').containsKey('signDocusignDocuments')) {
                    signDocusignDocumentsLog = existingLogsMap.get('Request Status').get('signDocusignDocuments');
                } else {
                    String logRecordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Request Status').getRecordTypeId();
                    signDocusignDocumentsLog = new E2E_Data_Log__c();
                    signDocusignDocumentsLog.Name = 'signDocusignDocuments';
                    signDocusignDocumentsLog.RecordTypeId = logRecordTypeId;
                    signDocusignDocumentsLog.E2E_Data_Object__c = currentDataObject.Id;
                }
                signDocusignDocumentsLog.Status__c = 'Success';
                e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c> {signDocusignDocumentsLog});
                e2eStep.setDealStatusesForNextStep(e2eDatabase, nextAvailableStep, availableStepsForCustomerList, availableStepsList, existingLogsMap);
                if (currentDataObject.E2E_Status__c == 'Finished') {
                    e2eStep.runJobs(e2eDatabase, new List<String>{'syncFinishedDeal'});
                }
            }
            pageToRedirect = ETEGlobalUtils.returnUrlPath(currentDataObject.RecordType.Name);
        }
        return pageToRedirect;
    }


    public virtual String getLinkToDocusignRedirect(String action, Map<String, Object> args) {
        String countryCode = (String) args.get('countryCode');
        String source = (String) args.get('source');
        Map<String, Object> docusignFieldsMappingObjectsMap = (Map<String, Object>) args.get('docusign_fields_mapping');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);

        Opportunity opportunity = e2eDatabase.retrieveOpportunity(currentDataObject.Id);
        Account account = e2eDatabase.retrieveAccount(opportunity.AccountId);
        Map<String, OpportunityContactRole> primaryOCR = e2eDatabase.retrievePrimaryOpportunityContactRole(opportunity.Id);
        Contact contact = e2eDatabase.retrieveContacts(primaryOCR.keySet())[0];

        Map<String, E2E_Data_Product__c> e2eProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
        Map<String, Map<String, Object>> docusignFieldsMapping = returnDocusignFieldsMapping(action,
                currentDataObject,
                docusignFieldsMappingObjectsMap,
                e2eProductsMap.values());

        Map<String, Object> docusignDocumentsMap = (Map<String, Object>) docusignFieldsMappingObjectsMap.get('docusign_documents');
        Set<String> attachmentNamesSet = new Set<String>();
        for (String templateName : docusignDocumentsMap.keySet()) {
            E2E_Docusign_Templates__c docusignSettungs = E2E_Docusign_Templates__c.getValues(templateName);
            if (docusignSettungs != null) {
                attachmentNamesSet.add(docusignSettungs.Attachment_Name__c);
            }
        }

        Map<String, E2E_Docusign_Templates__c> docusignTemplatesSettingsMap = returnDocusignTemplatesSettings(docusignFieldsMapping.keySet());
        List<dsfs__DocuSign_Status__c> docusignStatusesToDeleteList = e2eDatabase.retrieveDocuSignStatuses(opportunity.Id);
        List<Attachment> opptyAttachmentsToDeleteList = e2eDatabase.retrieveAttchments(attachmentNamesSet, opportunity.Id);

        String country = ETEGlobalUtils.returnCountry(countryCode);
        E2E_Docusign_Settings__c docusignSettings = E2E_Docusign_Settings__c.getInstance(country);
        DocusignNetApi30.APIServiceSoap docusignApiSOAPService = initDocusignSoapService(docusignSettings);
        DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion tokenAuthenticationRequest = prepareRecipientTokenAuthenticationAssertionRequest();
        DocusignNetApi30.RequestRecipientTokenClientURLs clientURLs = generateDocusignClientURLs(source, countryCode);

        DocusignNetApi30.EnvelopeInformation newEnvelope = createDocusignEnvelope(docusignSettings, opportunity.Id);
        DocusignNetApi30.Recipient recipient = createDocusignRecipient(contact.Name, contact.Email);
        DocusignNetApi30.ArrayOfRecipient1 signers = createDocusignSigners(recipient);
        DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment = createTemplateReferenceRoleAssignment(recipient.RoleName,
                recipient.ID);
        DocusignNetApi30.ArrayOfTemplateReference templateReferences = generateDocusignTemplateReferences(currentDataObject,
                opportunity,
                account,
                contact,
                docusignTemplatesSettingsMap,
                docusignFieldsMapping,
                roleAssignment);
        DocusignNetApi30.EnvelopeStatus envelopeStatus;
        if (! Test.isRunningTest()) {
            envelopeStatus = docusignApiSOAPService.CreateEnvelopeFromTemplates(templateReferences, signers, newEnvelope,true);
        } else {
            envelopeStatus = new DocusignNetApi30.EnvelopeStatus();
            envelopeStatus.EnvelopeID = 'testEnvelopeID';
        }
        String token;
        if (! Test.isRunningTest()) {
            token = docusignApiSOAPService.RequestRecipientToken(envelopeStatus.EnvelopeID, recipient.captiveinfo.ClientUserId, recipient.UserName, recipient.Email, tokenAuthenticationRequest, clientURLs);
        } else {
            token = 'https://docusigntest.com';
        }
        if (! docusignStatusesToDeleteList.isEmpty()) { e2eDatabase.deleteDocusignStatuses(docusignStatusesToDeleteList); }
        if (! opptyAttachmentsToDeleteList.isEmpty()) { e2eDatabase.deleteAttchments(opptyAttachmentsToDeleteList); }
        return token;
    }


    private Map<String, Map<String, Object>> returnDocusignFieldsMapping(String action,
            E2E_Data_Object__c currentDataObject,
            Map<String, Object> docusignFieldsMappingObjectsMap,
            List<E2E_Data_Product__c> e2eProductsList) {
        Map<String, Map<String, Object>> fieldsMapping = new Map<String, Map<String, Object>>();
        if (docusignFieldsMappingObjectsMap.containsKey(action)) {
            Map<String, Object> templateTypes = (Map<String, Object>) docusignFieldsMappingObjectsMap.get(action);
            for (String templateType : templateTypes.keySet()) {
                Map<String, Object> templateFieldsMappingParams = (Map<String, Object>) templateTypes.get(templateType);
                Map<String, Object> documentsToSignMap = new Map<String, Object>();

                Map<String, Object> triggerToStepDisplaySettings = new Map<String, Object>();
                if (templateFieldsMappingParams.containsKey('trigger_to_display')) {
                    triggerToStepDisplaySettings = (Map<String, Object>) templateFieldsMappingParams.get('trigger_to_display');
                }
                Set<Boolean> resultsOfConditionsSet = new Set<Boolean>();

                for (String fieldsMappingParam : templateFieldsMappingParams.keySet()) {
                    if (templateFieldsMappingParams.get('optional') == false) {
                        documentsToSignMap.put(fieldsMappingParam, templateFieldsMappingParams.values());
                    } else {
                        if ( ! triggerToStepDisplaySettings.isEmpty()) {
                            for (String logicalOperator : triggerToStepDisplaySettings.keySet()) {
                                Set<Boolean> resultsOfConditionsByLogicalOperatorSet = new Set<Boolean>();
                                for (Object conditionToStepDisplay : (List<Object>) triggerToStepDisplaySettings.get(logicalOperator)) {
                                    Map<String, Object> conditionParams = (Map<String, Object>) conditionToStepDisplay;
                                    String regex = (String) conditionParams.get('regex');
                                    String objectType = ((String) conditionParams.get('param')).substringBefore('.');
                                    if (objectType == 'product') {
                                        for (E2E_Data_Product__c product : e2eProductsList) {
                                            resultsOfConditionsByLogicalOperatorSet.add(Pattern.matches(regex, product.Type_Name__c));
                                        }
                                    } else if (objectType == 'data_object') {
                                        String securityAmountToPay = String.valueOf(currentDataObject.Security_Amount_To_Pay__c);
                                        if (securityAmountToPay == null) {
                                            securityAmountToPay = 'null';
                                        }
                                        resultsOfConditionsByLogicalOperatorSet.add(Pattern.matches(regex, securityAmountToPay));
                                    }
                                }

                                if (logicalOperator == 'OR') {
                                    if (resultsOfConditionsByLogicalOperatorSet.contains(true)) {
                                        resultsOfConditionsSet.add(true);
                                    } else {
                                        resultsOfConditionsSet.add(false);
                                    }
                                } else if (logicalOperator == 'AND') {
                                    if (resultsOfConditionsByLogicalOperatorSet.size() == 1 && resultsOfConditionsByLogicalOperatorSet.contains(true)) {
                                        resultsOfConditionsSet.add(true);
                                    } else {
                                        resultsOfConditionsSet.add(false);
                                    }
                                }
                            }
                            if (resultsOfConditionsSet.contains(true)) {
                                documentsToSignMap.put(fieldsMappingParam, templateFieldsMappingParams.values());
                            }
                        }
                    }
                }

                for (String fieldsMappingParam : documentsToSignMap.keySet()) {
                    if (fieldsMappingParam == 'fields' || fieldsMappingParam == 'mapping') {
                        if (!fieldsMapping.containsKey(templateType)) {
                            fieldsMapping.put(templateType, new Map<String, Object>());
                        }
                        fieldsMapping.get(templateType).put(fieldsMappingParam, templateFieldsMappingParams.get(fieldsMappingParam));
                    }
                }
            }
        }
        return fieldsMapping;
    }


    private Map<String, E2E_Docusign_Templates__c> returnDocusignTemplatesSettings(Set<String> templateNamesSet) {
        Map<String, E2E_Docusign_Templates__c> allCustomTemplatesSettingsMap = E2E_Docusign_Templates__c.getAll();
        Map<String, E2E_Docusign_Templates__c> finalCustomTemplatesSettingsMap = new Map<String, E2E_Docusign_Templates__c>();
        for (String templateName : templateNamesSet) {
            if (allCustomTemplatesSettingsMap.containsKey(templateName)) {
                finalCustomTemplatesSettingsMap.put(templateName, allCustomTemplatesSettingsMap.get(templateName));
            }
        }
        return finalCustomTemplatesSettingsMap;
    }


    private DocusignNetApi30.APIServiceSoap initDocusignSoapService(E2E_Docusign_Settings__c docusignSettings) {
        String auth = '<DocuSignCredentials><Username>' + docusignSettings.UserId__c
                + '</Username><Password>' + docusignSettings.Password__c
                + '</Password><IntegratorKey>' + docusignSettings.IntegratorsKeyDesktop__c
                + '</IntegratorKey></DocuSignCredentials>';
        // Get DSapi and authenticate
        DocusignNetApi30.APIServiceSoap docusignApiSOAPService = new DocusignNetApi30.APIServiceSoap();
        docusignApiSOAPService.endpoint_x = docusignSettings.WebServiceUrl__c;
        docusignApiSOAPService.inputHttpHeaders_x = new Map<String, String>();
        docusignApiSOAPService.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        return docusignApiSOAPService;
    }


    private DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion prepareRecipientTokenAuthenticationAssertionRequest() {
        DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion authenticationAssert = new DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion();
        authenticationAssert.AssertionID = 'Your AssertionID Here';
        authenticationAssert.AuthenticationInstant = System.now();
        authenticationAssert.AuthenticationMethod = 'Password';
        authenticationAssert.SecurityDomain = 'YourApp.com';
        return authenticationAssert;
    }


    private DocusignNetApi30.RequestRecipientTokenClientURLs generateDocusignClientURLs(String source, String countryCode) {
        DocusignNetApi30.RequestRecipientTokenClientURLs clientURLs = new DocusignNetApi30.RequestRecipientTokenClientURLs();
        String siteUrl = ETEGlobalUtils.returnSiteUrl(countryCode);
        String page = siteUrl + '/eteredirection?' + 'countryCode=' + countryCode +
                '&srvc=docusign&source=';

        clientURLs.OnAccessCodeFailed = page + source + '&event=OnAccessCodeFailed';
        clientURLs.OnCancel = page + source + '&event=OnCancel';
        clientURLs.OnDecline = page + source + '&event=OnDecline';
        clientURLs.OnException = page + source + '&event=OnException';
        clientURLs.OnFaxPending = page+ source + '&event=OnFaxPending';
        clientURLs.OnIdCheckFailed = page + source + '&event=OnIdCheckFailed';
        clientURLs.OnSessionTimeout = page + source + '&event=OnSessionTimeout';
        clientURLs.OnSigningComplete = page + source + '&event=OnSigningComplete';
        clientURLs.OnTTLExpired = page + source + '&event=OnTTLExpired';
        clientURLs.OnViewingComplete = page + source + '&event=OnViewingComplete';
        return clientURLs;
    }


    DocusignNetApi30.EnvelopeInformation createDocusignEnvelope(E2E_Docusign_Settings__c docusignSettings, String opptyId) {
        // create envelope info
        DocusignNetApi30.EnvelopeInformation envelope = new DocusignNetApi30.EnvelopeInformation();
        envelope.Subject = docusignSettings.Subject__c;
        envelope.EmailBlurb = docusignSettings.Body__c;
        envelope.AccountId  = docusignSettings.AccountId__c;

        // Set salesforce object
        DocusignNetApi30.CustomField field = new DocusignNetApi30.CustomField();
        field.Name = '##SFOpportunity';
        field.Value = opptyId;
        field.Show = 'false';
        DocusignNetApi30.ArrayOfCustomField arrayOfCustomField = new DocusignNetApi30.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new DocusignNetApi30.CustomField[1];
        arrayOfCustomField.CustomField[0] = field;
        envelope.CustomFields = arrayOfCustomField;
        return envelope;
    }


    private DocusignNetApi30.Recipient createDocusignRecipient(String recipientName, String recipientEmail) {
        // Recipient Information
        DocusignNetApi30.Recipient recipient = new DocusignNetApi30.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = recipientEmail;
        recipient.UserName = recipientName;
        recipient.RoleName = 'Signer';

        // make recipient captive for embedded experience
        recipient.CaptiveInfo = new DocusignNetApi30.RecipientCaptiveInfo();
        recipient.CaptiveInfo.ClientUserId = '1';


        return recipient;
    }


    private DocusignNetApi30.ArrayOfRecipient1 createDocusignSigners(DocusignNetApi30.Recipient recipient) {
        // Create array of signers
        DocusignNetApi30.ArrayOfRecipient1 signers = new DocusignNetApi30.ArrayOfRecipient1();
        signers.Recipient = new DocusignNetApi30.Recipient[1];
        signers.Recipient[0] = recipient;
        return signers;
    }


    private DocusignNetApi30.TemplateReferenceRoleAssignment createTemplateReferenceRoleAssignment(String recipientRoleName,
            Integer recipientID) {
        DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment();
        roleAssignment.RoleName = recipientRoleName;
        roleAssignment.RecipientID = recipientID;
        return roleAssignment;
    }


    private DocusignNetApi30.ArrayOfTemplateReference generateDocusignTemplateReferences(E2E_Data_Object__c currentDataObject,
            Opportunity opportunity,
            Account account,
            Contact contact,
            Map<String, E2E_Docusign_Templates__c> docusignTemplatesSettingsMap,
            Map<String, Map<String, Object>> docusignFieldsMapping,
            DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment) {
        Map<String, List<String>> templatesTabLabels = new Map<String, List<String>>();
        Map<String, Map<String, String>> templatesFieldsMapping = new Map<String, Map<String, String>>();
        for (String templateName : docusignFieldsMapping.keySet()) {
            Map<String, Object> fieldsMapping = (Map<String, Object>) docusignFieldsMapping.get(templateName).get('mapping');
            List<Object> labelObjects = (List<Object>) docusignFieldsMapping.get(templateName).get('fields');
            for (Object labelObj : labelObjects) {
                if (! templatesTabLabels.containsKey(templateName)) {
                    templatesTabLabels.put(templateName, new List<String>());
                    templatesFieldsMapping.put(templateName, new Map<String, String>());
                }
                String tabLabel = (String) labelObj;
                templatesTabLabels.get(templateName).add(tabLabel);
                templatesFieldsMapping.get(templateName).put(tabLabel, (String) fieldsMapping.get(tabLabel));
            }
        }
        DocusignNetApi30.ArrayOfTemplateReference templateReferences = new DocusignNetApi30.ArrayOfTemplateReference();
        templateReferences.TemplateReference = new List<DocusignNetApi30.TemplateReference>();
        for (String templateName : docusignTemplatesSettingsMap.keySet()) {
            E2E_Docusign_Templates__c docusignTemplateSettings = docusignTemplatesSettingsMap.get(templateName);
            DocusignNetApi30.TemplateReference docusignTemplate = new DocusignNetApi30.TemplateReference();
            docusignTemplate.Template = docusignTemplateSettings.Docusign_Template_Id__c;
            docusignTemplate.TemplateLocation = 'Server';
            // Add role assignment
            docusignTemplate.RoleAssignments = new DocusignNetApi30.ArrayOfTemplateReferenceRoleAssignment();
            docusignTemplate.RoleAssignments.RoleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment[1];
            docusignTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;
            // Add data for fields (TabLabel it's Data Label filed in docusign template)
            docusignTemplate.FieldData = new DocusignNetApi30.TemplateReferenceFieldData();
            docusignTemplate.FieldData.DataValues = new DocusignNetApi30.ArrayOfTemplateReferenceFieldDataDataValue();
            docusignTemplate.FieldData.DataValues.DataValue = new DocusignNetApi30.TemplateReferenceFieldDataDataValue[templatesTabLabels.get(templateName).size()];
            Integer fieldCounter = 0;
            for (String tablabel : templatesTabLabels.get(templateName)) {
                String mappingParams = templatesFieldsMapping.get(templateName).get(tabLabel);
                String objectType = mappingParams.substringBefore('.');
                String objectFieldApiName = mappingParams.substringAfter('.');
                DocusignNetApi30.TemplateReferenceFieldDataDataValue field = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
                field.TabLabel = tablabel;
                if (objectType == 'E2E_Data_Object__c') {
                    field.Value = String.valueOf(currentDataObject.get(objectFieldApiName));
                } else if (objectType == 'Account') {
                    field.Value = String.valueOf(account.get(objectFieldApiName));
                } else if (objectType == 'Opportunity') {
                    field.Value = String.valueOf(opportunity.get(objectFieldApiName));
                } else if (objectType == 'Contact') {
                    field.Value = String.valueOf(contact.get(objectFieldApiName));
                }
                docusignTemplate.FieldData.DataValues.DataValue[fieldCounter] = field;
                fieldCounter++;
            }
            templateReferences.TemplateReference.add(docusignTemplate);
        }
        return templateReferences;
    }


    public virtual String getLinkToPayUPaymentGatewayRedirect(String action, Map<String, Object> args) {
        String countryCode = (String) args.get('countryCode');
        String source = (String) args.get('source');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        E2E_Data_Contact__c primaryDataContact = e2eDatabase.retrieveETEPrimaryContact(dataObjectId);
        Opportunity opportunity = e2eDatabase.retrieveOpportunity(currentDataObject.Id);
        List<Quote> existingQuotesList = e2eDatabase.retrieveQuotes(opportunity.Id);
        Decimal totalAmount = 0;
        if (currentDataObject.Security_Amount_To_Pay__c != null) {
            totalAmount =+ currentDataObject.Security_Amount_To_Pay__c;
        }
        if (! existingQuotesList.isEmpty()) {
            totalAmount =+ existingQuotesList[0].Grand_Total__c;
        }
        List<Payment_Transaction__c> pendingTransactions = e2eDatabase.retrievePendingPaymentTransactions(opportunity.Id, totalAmount);
        String redirectUri;
        if (! pendingTransactions.isEmpty()) {
            String country = ETEGlobalUtils.returnCountry(countryCode);
            String accessToken = getPayUAccessToken(currentDataObject.RecordType.Name);
            Payment_Transaction__c currentTransaction = pendingTransactions.get(0);
            redirectUri = generatePayUPaymentOrder(e2eDatabase, accessToken, action, country, source, currentDataObject, opportunity.Id, currentTransaction, primaryDataContact);
        }
        return redirectUri;
    }


    public virtual String getPaymentParamsToIngenicoPaymentGatewayRedirect(String action, Map<String, Object> args) {
        String countryCode = (String) args.get('countryCode');
        String source = (String) args.get('source');
        ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
        String dataObjectId = ETEGlobalUtils.doDecryptParams(source, countryCode);
        E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(dataObjectId);
        Opportunity opportunity = e2eDatabase.retrieveOpportunity(currentDataObject.Id);
        List<Payment_Transaction__c> pendingTransactions = e2eDatabase.retrievePendingPaymentTransactions(opportunity.Id,
                                                                                currentDataObject.Security_Amount_To_Pay__c);
        Map<String, String> paymentMap = new Map<String, String>();
        if (! pendingTransactions.isEmpty()) {
            String eteFormType = ETEGlobalUtils.returnETEFormType(currentDataObject.Country_Code__c);
            E2EKeysAPI__c apiKeysSettings = E2EKeysAPI__c.getValues(eteFormType);
            Payment_Transaction__c currentTransaction = pendingTransactions.get(0);
            paymentMap.put('ORDERID'     , currentTransaction.OrderID__c);
            paymentMap.put('PSPID'       , apiKeysSettings.PSPID__c);
            paymentMap.put('CURRENCY'    , currentTransaction.Currency__c);
            paymentMap.put('AMOUNT'      , String.valueOf(currentTransaction.Amount__c * 100));
            paymentMap.put('PM'          , currentDataObject.PM__c);
            paymentMap.put('BRAND'       , currentDataObject.Brand__c);
            paymentMap.put('LANGUAGE'    , ETEGlobalUtils.returnIngcoLanguage(countryCode));
            String redirectionUrl = ETEGlobalUtils.returnSiteUrl(countryCode) + '/eteredirection?source=' +
                                    source + '&srvc=' + action + '&countryCode=' + countryCode;
            paymentMap.put('ACCEPTURL'   , redirectionUrl);
            paymentMap.put('DECLINEURL'  , redirectionUrl);
            paymentMap.put('EXCEPTIONURL', redirectionUrl);
            paymentMap.put('CANCELURL'   , redirectionUrl);
            paymentMap.put('TP'          , ETEGlobalUtils.returnIngcoTemplate(countryCode));

            String shaKeyIn = apiKeysSettings.SHA_KeyIn__c;
            paymentMap.put('SHASIGN', E2EFormEncryption.getHashAlgorithmStringSHA1(
                'ACCEPTURL=' + paymentMap.get('ACCEPTURL') + shaKeyIn +
                'AMOUNT=' + paymentMap.get('AMOUNT') + shaKeyIn +
                'BRAND=' + paymentMap.get('BRAND') + shaKeyIn +
                'CANCELURL=' + paymentMap.get('CANCELURL') + shaKeyIn +
                'CURRENCY=' + paymentMap.get('CURRENCY') + shaKeyIn +
                'DECLINEURL=' + paymentMap.get('DECLINEURL') + shaKeyIn +
                'EXCEPTIONURL=' + paymentMap.get('EXCEPTIONURL') + shaKeyIn +
                'LANGUAGE=' + paymentMap.get('LANGUAGE') + shaKeyIn +
                'ORDERID=' + paymentMap.get('ORDERID') + shaKeyIn +
                'PM=' + paymentMap.get('PM') + shaKeyIn +
                'PSPID=' + paymentMap.get('PSPID') + shaKeyIn +
                'TP=' + paymentMap.get('TP') + shaKeyIn
            ));
        }
        return JSON.serialize(paymentMap);
    }


    public virtual void prepareTransaction(String countryCode, String opptyId, Decimal deposit) {
        if (! String.isEmpty(opptyId)) {
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
            List<Payment_Transaction__c> existingTransactions = e2eDatabase.retrievePendingPaymentTransactions(opptyId, deposit);
            if (existingTransactions.isEmpty()) {
                Payment_Transaction__c currentTransaction = new Payment_Transaction__c();
                currentTransaction.Currency__c = ETEGlobalUtils.returnCurrencyCode(countryCode);
                currentTransaction.Amount__c = deposit;
                currentTransaction.OpportunityId__c = opptyId;
                e2eDatabase.upsertPaymentTransaction(currentTransaction);
            }
        }
    }


    private String getPayUAccessToken(String implKey) {
        E2E_PayU_Settings__c payUSettings = E2E_PayU_Settings__c.getValues(implKey);
        String accessToken;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(payUSettings.API_Endpoint__c + '/pl/standard/user/oauth/authorize');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials&client_id=' + payUSettings.Client_Id__c +
                '&client_secret=' + payUSettings.Client_Secret__c +
                '&pos_id=' + payUSettings.Pos_Id__c);
        Http http = new Http();
        HTTPresponse response;
        if (! Test.isRunningTest()) {
            response = http.send(request);
        } else {
            response = new HTTPresponse();
            response.setBody('{"access_token": "testToken"}');
        }
        PayUResultEntity entity = PayUResultEntity.parse(response.getBody());
        accessToken = entity.access_token;
        return accessToken;
    }


    private String generatePayUPaymentOrder(ETEDatabaseInterface e2eDatabase,
            String accessToken,
            String action,
            String country,
            String source,
            E2E_Data_Object__c currentDataObject,
            String opptyId,
            Payment_Transaction__c currentTransaction,
            E2E_Data_Contact__c primaryDataContact) {
        List<Quote> existingQuotesList = e2eDatabase.retrieveQuotes(opptyId);
        Decimal totalAmount = currentDataObject.Security_Amount_To_Pay__c != null ? currentDataObject.Security_Amount_To_Pay__c : 0;

        String totalAmountStr;
        if (! existingQuotesList.isEmpty()) {
            totalAmountStr = String.valueOf((totalAmount + existingQuotesList[0].Grand_Total__c) * 100).substringBefore('.');
        } else {
            totalAmountStr = String.valueOf(totalAmount) + '00';
        }
        String ipAddress = currentDataObject.Customer_IP_Address__c;

        E2E_PayU_Settings__c payUSettings = E2E_PayU_Settings__c.getValues(currentDataObject.RecordType.Name);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(payUSettings.API_Endpoint__c + '/api/v2_1/orders');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        String siteUrl = ETEGlobalUtils.returnSiteUrl(currentDataObject.Country_Code__c);
        request.setBody('{"notifyUrl": "' + siteUrl + '/services/apexrest/PayUResult", ' +
                '"continueUrl": "' + siteUrl + '/eteredirection?source=' + source +
                '&srvc=' + action + '&countryCode=' + currentDataObject.Country_Code__c + '", ' +
                '"customerIp": "' + ipAddress + '", ' +
                '"merchantPosId": "' + payUSettings.Pos_Id__c + '", ' +
                '"description": "Fleetcor market", ' +
                '"currencyCode": "' + ETEGlobalUtils.returnCurrencyCode(currentDataObject.Country_Code__c) + '", ' +
                '"totalAmount": "' + totalAmountStr + '", ' +
                '"buyer": {"email": "' + primaryDataContact.Email__c + '", ' +
                '"phone": "' + primaryDataContact.Phone__c + '", ' +
                '"firstName": "' + primaryDataContact.First_Name__c + '", ' +
                '"lastName": "' + primaryDataContact.Last_Name__c + '", ' +
                '"language": "' + currentDataObject.Current_Language__c + '"}, ' +
                '"settings": {"invoiceDisabled":"true"}, ' +
                '"products": [{"name": "Fleetcor fuel cards", ' +
                '"unitPrice": "' + totalAmountStr + '", ' +
                '"quantity": "1"}]}');
        Http http = new Http();
        HTTPresponse response;
        if (! Test.isRunningTest()) {
            response = http.send(request);
        } else {
            response = new HTTPresponse();
            response.setBody('{"redirectUri": "https://payutest.com?orderId=1234567&"}');
        }
        PayUResultEntity entity = PayUResultEntity.parse(response.getBody());

        // update payment transaction
        currentTransaction.PayUOrderId__c = entity.redirectUri.substringAfter('orderId=').substringBefore('&');
        e2eDatabase.upsertPaymentTransaction(currentTransaction);
        return entity.redirectUri;
    }
}