public without sharing class CreditFactoryCtrl {


    /*******************************************************************************
    *  Summary         : Return Credit Factory data.
    *  CreatedDate     : 04/05/2020 by Anton Buzak
    *  Parameters      : opportunityId - id of current Opportunity
    *  Returns         : data from database
    ******************************************************************************/
    @AuraEnabled
    public static Map<String, Object> generateDataMap(String opportunityId) {
        try {
            List<SObject> sobjectsList = new List<SObject>();
            Opportunity opportunity = CreditFactoryService.selectOpportunity(opportunityId);
            sobjectsList.add(opportunity);
            Account account = CreditFactoryService.selectAccount(opportunity.AccountId);
            sobjectsList.add(account);
            List<Contact> contactsList = CreditFactoryService.selectAccountContacts(opportunity.AccountId);
            sobjectsList.addAll(contactsList);
            List<AccountContactRelation> accountContactRelationsList = CreditFactoryService.selectAccountContactRelations(opportunity.AccountId);
            sobjectsList.addAll(accountContactRelationsList);
            List<OpportunityContactRole> opportunityContactRolesList = CreditFactoryService.selectOpportunityContactRoles(opportunityId);
            sobjectsList.addAll(opportunityContactRolesList);
            List<dsfs__DocuSign_Status__c> docuSignStatusesList = CreditFactoryService.selectDocuSignStatusesList(opportunityId);
            sobjectsList.addAll(docuSignStatusesList);
            List<Tankkarten__c> tankkartensList = CreditFactoryService.selectTankkartens(opportunityId);
            sobjectsList.addAll(tankkartensList);
            List<OpportunityLineItem> lineItemsList = CreditFactoryService.selectLineItems(opportunityId);
            sobjectsList.addAll(lineItemsList);
            List<Offer_Item__c> offerItemsList = CreditFactoryService.selectOfferItems((new Map<Id, OpportunityLineItem>(lineItemsList)).keySet());
            sobjectsList.addAll(offerItemsList);
            List<Attachment> attachmentsList = CreditFactoryService.selectAttachmentsList(opportunityId);
            sobjectsList.addAll(attachmentsList);
            List<ContentVersion> filesList = CreditFactoryService.selectFilesList(opportunityId);
            sobjectsList.addAll(filesList);
            List<Credit_Factory_Calculation__c> calculationsList = CreditFactoryService.selectCreditFactoryCalculationsList(opportunity.Account.BillingCountry);
            sobjectsList.addAll(calculationsList);
            Map<String, Object> dataMap = CreditFactoryService.generateDataStructureMap(sobjectsList);
            return dataMap;
        } catch (Exception e) {
            throw new AuraHandledException('Select data failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
    

    /*******************************************************************************
    *  Summary         : do validaiton before searching
    *  CreatedDate     : 04/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : validation error
    ******************************************************************************/
    @AuraEnabled
    public static String validateSearch(Map<String, Object> dataMap) {
        try {
            String searchValidationError;
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(creditFactorySettings.returnSearchValidations(), false);
            for (CreditFactoryValidationItem validationItem : validationItemsMap.values()) {
                if (validationItem.passed == false) {
                    searchValidationError = validationItem.description;
                }
            }
            
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            if (validationItemsMap.containsKey('Duplicates')) {
                CreditFactoryValidationItem validationItem = validationItemsMap.get('Duplicates');
                if (validationItem.passed == false) {
                    Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
                    updateSObjects(duplicateFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                    submitForApproval('Duplicate', internalCompany.opportunityId);
                    searchValidationError = validationItem.description + '<br/>' + CreditFactoryGlobalUtils.SUBMIT_FOR_APPROVAL;
                }
            }

            return searchValidationError;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*******************************************************************************
    *  Summary         : Check existiing report in database
    *  CreatedDate     : 18/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : validation error
    ******************************************************************************/
    @AuraEnabled 
    public static Boolean checkExistingReports(Map<String, Object> dataMap) {
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            Boolean areReportsExist;
            if (creditFactory.areReportsExist(internalCompany.opportunityId)) {
                areReportsExist = true;
            }
            else {
                areReportsExist = false;
            }

            return areReportsExist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    /*******************************************************************************
    *  Summary         : Do searching
    *  CreatedDate     : 04/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : list of searched companies
    ******************************************************************************/
    @AuraEnabled
    public static Map<String, Object> searchCompanies(Map<String, Object> dataMap) {
        String noMatchesError = '';
        Map<String, Object> searchMap = new Map<String, Object>();
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
            List<CreditFactoryCompany> companiesList = creditFactory.requestSearchCompanies(creditFactorySettings.returnSearchParameters());

            if (companiesList.isEmpty()) {
                noMatchesError = 'No matches for this company. ';
                CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
                creditFactoryValidation.setInternalCFCompany(dataMap);
                Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Order'}, false);
                CreditFactoryValidationItem validationItem = validationItemsMap.get('Order');
                if (validationItem.passed == false || validationItem.description != null) {
                    searchMap.put('message', noMatchesError + validationItem.description);
                    if (validationItem.parametersMap != null && validationItem.parametersMap.containsKey('isTaxIdApprove') &&
                            validationItem.parametersMap.get('isTaxIdApprove') == true) {
                        searchMap.put('isTaxIdApprove', true);
                    }
                } 
                else {
                    dataMap = setInternalCFCompanyWithAttachmentBody(dataMap);
                    creditFactory.setInternalCFCompany(dataMap);
                    CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);
                    String orderItemMessage = '';
                    if (orderItem != null) {
                        orderItemMessage = orderItem.message;
                        Map<String, Object> fieldsToUpdateMap = creditFactory.returnOrderFieldsToUpdate(orderItem.orderReferenceNumber);
                        updateSObjects(fieldsToUpdateMap, internalCompany.opportunityId, internalCompany.accountId, null, null);
                    }

                    searchMap.put('message', noMatchesError + orderItemMessage);
                }
            } 
            else {
                Map<String, Object> fieldsToUpdateMap = creditFactory.returnSearchFieldsToUpdate();
                updateSObjects(fieldsToUpdateMap, internalCompany.opportunityId, internalCompany.accountId, null, null);
            }

            searchMap.put('companies', companiesList);
        } catch (Exception e) {
            searchMap.put('message', e.getMessage());
        }

        return searchMap;
    }


    /*******************************************************************************
    *  Summary         : Add attachments with the body to dataMap
    *  CreatedDate     : 08/06/2020 by Ivan Kulinkovich
    *  Parameters      : dataMap - internal data
    *  Returns         : Map<String, Object> dataMap
    ******************************************************************************/
    private static Map<String, Object> setInternalCFCompanyWithAttachmentBody(Map<String, Object> dataMap) {
        String opportunityId = String.valueOf(dataMap.get('opportunityId'));
        List<Attachment> attachmentsList = CreditFactoryService.selectAttachmentsList(opportunityId);
        List<ContentVersion> filesList = CreditFactoryService.selectFilesList(opportunityId);
        List<Map<String, Object>> attachmentsListToAdd = new List<Map<String, Object>>();
        for (Attachment attachment : attachmentsList) {
            Map<String, Object> attachmentsMap = CreditFactoryService.generateAttachmentsDataStructure(attachment);
            attachmentsMap.put('body', EncodingUtil.base64Encode(attachment.Body));
            attachmentsListToAdd.add(attachmentsMap);
        }

        List<Map<String, Object>> filesListToAdd = new List<Map<String, Object>>();
        for (ContentVersion file : filesList) {
            Map<String, Object> filesMap = CreditFactoryService.generateFilesDataStructure(file);
            filesMap.put('versionData', EncodingUtil.base64Encode(file.VersionData));
            filesListToAdd.add(filesMap);
        }

        dataMap.put('attachments', attachmentsListToAdd);
        dataMap.put('files', filesListToAdd);

        return dataMap;
    }


    /*******************************************************************************
    *  Summary         : Return search columns data for LWC
    *  CreatedDate     : 17/08/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : search columns data
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getSearchColumns(String country) {
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(country);
        List<Object> searchColumnsList = creditFactorySettings.returnSearchColumns();

        return searchColumnsList;
    }


    /*******************************************************************************
    *  Summary         : Process case with company is not in the searched list
    *  CreatedDate     : 06/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : list of searched companies
    ******************************************************************************/
    @AuraEnabled
    public static Map<String, Object> processCompanyNotInTheList(Map<String, Object> dataMap) {
        String notInTheListError = 'Company is not in the list. ';
        Map<String, Object> notInTheListMap = new Map<String, Object>();
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Order'}, false);
            CreditFactoryValidationItem validationItem = validationItemsMap.get('Order');
            if (validationItem.passed == false || validationItem.description != null) {
                notInTheListMap.put('message', notInTheListError + validationItem.description);
                if (validationItem.parametersMap != null && validationItem.parametersMap.containsKey('isTaxIdApprove') &&
                        validationItem.parametersMap.get('isTaxIdApprove') == true) {
                    notInTheListMap.put('isTaxIdApprove', true);
                }
            } 
            else {
                CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
                dataMap = setInternalCFCompanyWithAttachmentBody(dataMap);
                creditFactory.setInternalCFCompany(dataMap);
                CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
                CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);
                String orderItemMessage = '';
                if (orderItem != null) {
                    orderItemMessage = orderItem.message;
                    Map<String, Object> fieldsToUpdateMap = creditFactory.returnOrderFieldsToUpdate(orderItem.orderReferenceNumber);
                    updateSObjects(fieldsToUpdateMap, internalCompany.opportunityId, internalCompany.accountId, null, null);
                }

                notInTheListMap.put('message', notInTheListError + orderItemMessage);
            }
        } catch (Exception e) {
            notInTheListMap.put('message', e.getMessage());
        }

        return notInTheListMap;
    }


    /*******************************************************************************
    *  Summary         : Approve tax id and send order
    *  CreatedDate     : 22/10/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : list of searched companies
    ******************************************************************************/
    @AuraEnabled
    public static Map<String, Object> approveTaxId(Map<String, Object> dataMap) {
        Map<String, Object> notInTheListMap = new Map<String, Object>();
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            CreditFactoryOrderItem orderItem = creditFactory.requestOrder(null);
            String orderItemMessage = '';
            if (orderItem != null) {
                orderItemMessage = orderItem.message;
                Map<String, Object> fieldsToUpdateMap = creditFactory.returnOrderFieldsToUpdate(orderItem.orderReferenceNumber);
                updateSObjects(fieldsToUpdateMap, internalCompany.opportunityId, internalCompany.accountId, null, null);
            }

            notInTheListMap.put('message', orderItemMessage);
        } catch (Exception e) {
            notInTheListMap.put('message', e.getMessage());
        }

        return notInTheListMap;
    }


    /*******************************************************************************
     *  Summary         : Choose company from the list
     *  CreatedDate     : 13/11/2019 by Anton Buzak
     *  Parameters      : dataMap - internal data, selectedCompanyId - id of selected company,
                          isStartReportsCheck - send request for starting reports check if true
     *  Returns         : map of scoring results
     ******************************************************************************/
    @AuraEnabled
    public static Map<String, Object> chooseCompany(Map<String, Object> dataMap, 
                                                    String selectedCompanyId,
                                                    Boolean isStartReportsCheck) {
        Map<String, Object> reportMap = new Map<String, Object>();
        try {
            String unavailableReportError = '';
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            if (isStartReportsCheck == true) {
                creditFactory.requestStartReportsCheck(selectedCompanyId);
            }

            CreditFactoryReportsItem cfReportsItem = creditFactory.requestCompanyReports(selectedCompanyId);
            if (cfReportsItem.isWaiting == true) {
                reportMap.put('isWaiting', cfReportsItem.isWaiting);
                reportMap.put('message', cfReportsItem.errorMessage);
            }
            else if (cfReportsItem.isReportAvailable == false) {
                unavailableReportError = cfReportsItem.errorMessage;
                reportMap.put('message', unavailableReportError);
                if (cfReportsItem.isOrderAvailable == true) {
                    CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
                    creditFactoryValidation.setInternalCFCompany(dataMap);
                    Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Order'}, false);
                    CreditFactoryValidationItem validationItem = validationItemsMap.get('Order');
                    if (validationItem.passed == false) {
                        reportMap.put('message', unavailableReportError + ' ' + validationItem.description);
                    }
                    else {
                        dataMap = setInternalCFCompanyWithAttachmentBody(dataMap);
                        creditFactory.setInternalCFCompany(dataMap);
                        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(cfReportsItem.orderId);
                        String orderItemMessage = '';
                        if (orderItem != null) {
                            orderItemMessage = orderItem.message;
                            Map<String, Object> fieldsToUpdateMap = creditFactory.returnOrderFieldsToUpdate(orderItem.orderReferenceNumber);
                            updateSObjects(fieldsToUpdateMap, internalCompany.opportunityId, internalCompany.accountId, null, null);
                        }

                        reportMap.put('message', unavailableReportError + ' ' + orderItemMessage);
                    }
                }
            }
            else {
                reportMap = doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);

                List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
                for (Credit_Factory_Report__c report : reportsList) {
                    report.Opportunity__c = internalCompany.opportunityId;
                    report.Account__c = internalCompany.accountId;
                }

                insert reportsList;

                List<Credit_Factory_Report_Employee__c> employeesList = creditFactory.createCFReportEmployeesInstances();
                for (Credit_Factory_Report_Employee__c employee : employeesList) {
                    for (Credit_Factory_Report__c report : reportsList) {
                        if (GlobalUtils.returnRecordTypeName('Credit_Factory_Report__c', report.RecordTypeId) ==
                                GlobalUtils.returnRecordTypeName('Credit_Factory_Report_Employee__c', employee.RecordTypeId)) {
                            employee.Credit_Factory_Report__c = report.Id;
                        }
                    }
                }

                insert employeesList;

                Map<String, Object> reportFieldsToUpdate = creditFactory.returnReportFieldsToUpdate();
                if (reportMap.containsKey('reasonLost')) {
                    Map<String, Object> closedLostFieldsToUpdate = creditFactory.returnClosedLostFieldsToUpdate((String) reportMap.get('reasonLost'));
                    reportFieldsToUpdate.putAll(closedLostFieldsToUpdate);
                }
                else if (reportMap.containsKey('cfResult')) {
                    CreditFactoryResult result = (CreditFactoryResult) reportMap.get('cfResult');
                    if (result != null) {
                        if (result.statusCode == '005' || result.statusCode == '007') {
                            Map<String, Object> closedLostFieldsToUpdate = creditFactory.returnClosedLostFieldsToUpdate('Refused Credit');
                            reportFieldsToUpdate.putAll(closedLostFieldsToUpdate);
                        }
                        else if (result.statusCode == '014') {
                            Credit_Black_List_Company__c blackListCompany = creditFactory.createBlackListInstance();
                            insert blackListCompany;
                        }
                    }
                }

                String primaryContactId;
                for (CreditFactoryCompany.CreditFactoryContact contact : internalCompany.creditFactoryContacts) {
                    if (contact.relation == 'OpportunityContactRole' && contact.isPrimary == true) {
                        primaryContactId = contact.id;
                        break;
                    }
                }

                updateSObjects(reportFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, primaryContactId, null);

                creditFactory.createPdfReports(internalCompany.opportunityId);
            }
        } catch (Exception e) {
            reportMap.put('message', e.getMessage());
        }

        return reportMap;
    }


    /*******************************************************************************
     *  Summary         : Select company from database
     *  CreatedDate     : 18/05/2020 by Anton Buzak
     *  Parameters      : dataMap - internal data
     *  Returns         : map of scoring results
     ******************************************************************************/
    @AuraEnabled
    public static Map<String, Object> selectCompany(Map<String, Object> dataMap) {
        Map<String, Object> reportMap = new Map<String, Object>();
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);

            Boolean bigRequestedBeforeScoring;
            String companyId;
            for (CreditFactoryCompany company : cfReportsItem.companiesList) {
                if (company.recordType == 'Default') {
                    bigRequestedBeforeScoring = company.bigRequested;
                    companyId = company.id;
                    break;
                }
            }

            reportMap = doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
            Map<String, Object> reportFieldsToUpdate = new Map<String, Object>();

            String reportId;
            Boolean isAdditionalScoringUpdateNeeded = false;
            for (CreditFactoryCompany company : cfReportsItem.companiesList) {
                if (company.recordType == 'Default' && bigRequestedBeforeScoring == false && company.bigRequested == true) {
                    isAdditionalScoringUpdateNeeded = true;
                    reportId = companyId;
                    break;
                }
            }

            Boolean isPaymentHistoryRequested = false;
            if (reportMap.containsKey('reasonLost')) {
                Map<String, Object> closedLostFieldsToUpdate = creditFactory.returnClosedLostFieldsToUpdate((String) reportMap.get('reasonLost'));
                reportFieldsToUpdate.putAll(closedLostFieldsToUpdate);
            }
            else if (reportMap.containsKey('cfResult')) {
                CreditFactoryResult result = (CreditFactoryResult) reportMap.get('cfResult');
                if (result != null) {
                    Map<String, Object> paymentHistoryFieldsToUpdate = new Map<String, Object>();
                    Map<String, Object> additionalScoringFieldsToUpdate = new Map<String, Object>();
                    Map<String, Object> fieldsToUpdateInReport = new Map<String, Object>();

                    if (result.requiredUpdates != null && result.requiredUpdates == 'Payment history data') {
                        paymentHistoryFieldsToUpdate = creditFactory.returnPaymentHistoryFieldsToUpdate();
                        reportId = companyId;
                        isPaymentHistoryRequested = true;
                    }

                    if (result.statusCode == '005' || result.statusCode == '007') {
                        Map<String, Object> closedLostFieldsToUpdate = creditFactory.returnClosedLostFieldsToUpdate('Refused Credit');
                        reportFieldsToUpdate.putAll(closedLostFieldsToUpdate);
                    }
                    else if (result.statusCode == '001' && isAdditionalScoringUpdateNeeded) {
                        additionalScoringFieldsToUpdate = creditFactory.returnReportAdditionalScoringFieldsToUpdate();
                    }

                    if (! paymentHistoryFieldsToUpdate.isEmpty()) {
                        fieldsToUpdateInReport.putAll((Map<String, Object>) paymentHistoryFieldsToUpdate.get('Credit_Factory_Report__c'));
                    }

                    if (! additionalScoringFieldsToUpdate.isEmpty()) {
                        fieldsToUpdateInReport.putAll((Map<String, Object>) additionalScoringFieldsToUpdate.get('Credit_Factory_Report__c'));
                    }

                    if (! fieldsToUpdateInReport.isEmpty()) {
                        reportFieldsToUpdate.put('Credit_Factory_Report__c', fieldsToUpdateInReport);
                    }
                }
            }

            String primaryContactId;
            for (CreditFactoryCompany.CreditFactoryContact contact : internalCompany.creditFactoryContacts) {
                if (contact.relation == 'OpportunityContactRole' && contact.isPrimary == true) {
                    primaryContactId = contact.id;
                    break;
                }
            }

            Map<String, Object> fieldsMap = new Map<String, Object>();
            Map<String, Object> opportunityFieldsMap = creditFactory.returnOpportunityFieldsToUpdate();
            fieldsMap.put('Opportunity', opportunityFieldsMap);

            if (internalCompany.stage == 'Credit Report Generated') {
                Map<String, Object> accountFieldsMap = creditFactory.returnAccountFieldsToUpdate();
                fieldsMap.put('Account', accountFieldsMap);
            }

            reportFieldsToUpdate.putAll(fieldsMap);

            updateSObjects(reportFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, primaryContactId, reportId);

            if (isPaymentHistoryRequested) {
                creditFactory.createPaymentHistoryAttachment(internalCompany.opportunityId);
            }

        } catch (Exception e) {
            reportMap.put('message', e.getMessage());
        }

        return reportMap;
    }
    
    
     /*******************************************************************************
     *  Summary         : Score company
     *  CreatedDate     : 21/05/2020 by Anton Buzak
     *  Parameters      : dataMap - internal data
     *  Returns         : map of scoring results
     ******************************************************************************/
    private static Map<String, Object> doScoring(Map<String, Object> dataMap,
                                                CreditFactoryReportsItem cfReportsItem,
                                                CreditFactoryCompany internalCompany,
                                                CreditFactory creditFactory) {
        Map<String, Object> reportMap = new Map<String, Object>();
        for (CreditFactoryCompany company : cfReportsItem.companiesList) {
            if (company.recordType == 'Default') {
                reportMap.put('selectedCompany', company);
            } else {
                reportMap.put('additionalCompany', company);
            }
        }

        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
        creditFactoryValidation.setInternalCFCompany(dataMap);
        creditFactoryValidation.setExternalCreditFactoryCompanies(cfReportsItem.companiesList);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(creditFactorySettings.returnReportValidations(), true);

        String validationMessage = '';
        Boolean isStopValidationFailed = false;
        String reasonLost;
        List<String> failedValidationsList = new List<String>();
        for (String validationName : validationItemsMap.keySet()) {
            if (validationItemsMap.get(validationName).passed == false) {
                validationMessage += validationItemsMap.get(validationName).description + '</br>';
                failedValidationsList.add(validationName);
                List<String> reportStopValidationsMap = creditFactorySettings.returnReportStopValidations();
                if (reportStopValidationsMap.contains(validationName)) {
                    isStopValidationFailed = true;
                }

                if (validationItemsMap.get(validationName).parametersMap != null && validationItemsMap.get(validationName).parametersMap.containsKey('ReasonLost')) {
                    reasonLost = (String) validationItemsMap.get(validationName).parametersMap.get('ReasonLost');
                }
            } 
        }
        
        reportMap.put('failedValidations', failedValidationsList);
        
        CreditFactoryResult cfResult;
        if (validationMessage != '') {
            validationMessage = validationMessage.removeEnd('</br>');
            reportMap.put('validationMessage', validationMessage);
        }
        
        if (isStopValidationFailed == false) {
            cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), validationItemsMap);
        }
        else {
            validationMessage += '</br>Fix all validation errors or refer to Credit.';
            reportMap.put('validationMessage', validationMessage);
            if (reasonLost != null) {
                reportMap.put('reasonLost', reasonLost);
            }
        }

        if (cfResult != null && cfResult.statusCode == '002') {
            Map<String, CreditFactoryValidationItem> additionalScoringValidationItemsMap = creditFactoryValidation.validate(creditFactorySettings.returnAdditionalScoringValidations(), true);
            for (CreditFactoryValidationItem item : additionalScoringValidationItemsMap.values()) {
                if (item.passed == false) {
                    validationMessage += item.description + '</br>';
                }
            }

            if (validationMessage != '') {
                validationMessage = validationMessage.removeEnd('</br>');
                reportMap.put('validationMessage', validationMessage);
            }
            else {
                cfReportsItem = creditFactory.requestAdditionalCreditScoringData(additionalScoringValidationItemsMap);
                cfResult = creditFactory.doCreditScoring(creditFactorySettings.returnPaymentDetails(), additionalScoringValidationItemsMap);
            }
        }
        
        reportMap.put('cfResult', cfResult);
        
        String infoMessage = '';
        String warningMessage = '';
        String errorMessage = '';
        if (cfResult != null && cfResult.messagesList != null) {
            for (CreditFactoryResult.Message cfMessage : cfResult.messagesList) {
                if (cfMessage.severity == 'info') {
                    infoMessage += cfMessage.text + '</br>';
                }
                else if (cfMessage.severity == 'warning') {
                    warningMessage += cfMessage.text + '</br>';
                }
                else if (cfMessage.severity == 'error') {
                    errorMessage += cfMessage.text + '</br>';
                }
            }
        }
        
        if (infoMessage != '') {
            infoMessage = infoMessage.removeEnd('</br>');
            reportMap.put('infoMessage', infoMessage);
        }
        
        if (warningMessage != '') {
            warningMessage = warningMessage.removeEnd('</br>');
            reportMap.put('warningMessage', warningMessage);
        }
        
        if (errorMessage != '') {
            errorMessage = errorMessage.removeEnd('</br>');
            reportMap.put('errorMessage', errorMessage);
        }

        return reportMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get data for LWC sections
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : companyData - external company data,
                         additionalCompanyDate - external additional company data,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getSectionsData(Object companyData, Object additionalCompanyData, Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        CreditFactoryCompany externalCompany = new CreditFactoryCompany();
        String creditFactoryJsonData = JSON.serialize(companyData);
        externalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);

        CreditFactoryCompany externalAdditionalCompany = new CreditFactoryCompany();
        String creditFactoryAdditionalJsonData = JSON.serialize(additionalCompanyData);
        externalAdditionalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryAdditionalJsonData, CreditFactoryCompany.class);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        List<Object> sectionsDataList = creditFactorySettings.returnReportSectionsData(internalCompany, externalCompany, externalAdditionalCompany);
        
        return sectionsDataList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get data for LWC update buttons
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : companyData - external company date,
                         additionalCompanyDate - external additional company data,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAddressData(Object companyData, Object additionalCompanyData, Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        CreditFactoryCompany externalCompany = new CreditFactoryCompany();
        String creditFactoryJsonData = JSON.serialize(companyData);
        externalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);

        CreditFactoryCompany externalAdditionalCompany = new CreditFactoryCompany();
        String creditFactoryAdditionalJsonData = JSON.serialize(additionalCompanyData);
        externalAdditionalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryAdditionalJsonData, CreditFactoryCompany.class);
        
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        Map<String, Object> updateDataMap = creditFactorySettings.returnAddressUpdateData(internalCompany, externalCompany, externalAdditionalCompany);
        
        return updateDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get data for LWC update buttons
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : companyData - external company date,
                         additionalCompanyDate - external additional company data,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getNameUpdateData(Object companyData, Object additionalCompanyData, Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        CreditFactoryCompany externalCompany = new CreditFactoryCompany();
        String creditFactoryJsonData = JSON.serialize(companyData);
        externalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);

        CreditFactoryCompany externalAdditionalCompany = new CreditFactoryCompany();
        String creditFactoryAdditionalJsonData = JSON.serialize(additionalCompanyData);
        externalAdditionalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryAdditionalJsonData, CreditFactoryCompany.class);
        
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        Map<String, Object> updateDataMap = creditFactorySettings.returnNameUpdateData(internalCompany, externalCompany, externalAdditionalCompany);
        
        return updateDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get data for LWC update buttons
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : companyData - external company date,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTaxIdUpdateData(Object companyData, Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        CreditFactoryCompany externalCompany = new CreditFactoryCompany();
        String creditFactoryJsonData = JSON.serialize(companyData);
        externalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);
        
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        Map<String, Object> updateDataMap = creditFactorySettings.returnTaxIdUpdateData(internalCompany, externalCompany);
        
        return updateDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Get data for LWC update buttons
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : companyData - external company date,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTradeRegisterNumberUpdateData(Object companyData, Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        CreditFactoryCompany externalCompany = new CreditFactoryCompany();
        String creditFactoryJsonData = JSON.serialize(companyData);
        externalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);
        
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        Map<String, Object> updateDataMap = creditFactorySettings.returnTradeRegisterNumberUpdateData(internalCompany, externalCompany);
        
        return updateDataMap;
    }


    /*******************************************************************************
    *  Summary         : Get data for LWC update buttons
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : companyData - external company date,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getVatNumberUpdateData(Object companyData, Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);
        CreditFactoryCompany externalCompany = new CreditFactoryCompany();
        String creditFactoryJsonData = JSON.serialize(companyData);
        externalCompany = (CreditFactoryCompany) JSON.deserialize(creditFactoryJsonData, CreditFactoryCompany.class);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        Map<String, Object> updateDataMap = creditFactorySettings.returnVatNumberUpdateData(internalCompany, externalCompany);

        return updateDataMap;
    }


    /*******************************************************************************
    *  Summary         : Get data for LWC update buttons
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : companyData - external company date,
                         dataMap - internal company data
    *  Returns         : sections map
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSwiftBicUpdateData(Map<String, Object> dataMap) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactorySettings creditFactorySettings = CreditFactoryService.returnCreditFactorySettings(implKey);

        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        Map<String, Object> updateDataMap = creditFactorySettings.returnSwiftBicUpdateData(internalCompany);

        return updateDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : Update report fields via button
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data, 
                         type - type of update
    *  Returns         : success message
    ******************************************************************************/
    @AuraEnabled
    public static String doUpdate(Map<String, Object> dataMap, 
                                  String type) {
        String country = String.valueOf(dataMap.get('country'));
        String recordType = String.valueOf(dataMap.get('recordType'));
        String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
        creditFactory.selectCompanyReports(internalCompany.opportunityId);
        String successMessage;
        if (type == 'address') {
            successMessage = updateAddress(internalCompany.accountId, creditFactory);
        }
        else if (type == 'additionalAddress') {
            successMessage = updateAdditionalAddress(internalCompany.accountId, creditFactory);
        }
        else if (type == 'postalAddress') {
            successMessage = updatePostalAddress(internalCompany.accountId, creditFactory);
        }
        else if (type == 'registeredAddress') {
            successMessage = updateRegisteredAddress(internalCompany.accountId, creditFactory);
        }
        else if (type == 'name') {
            successMessage = updateName(internalCompany.accountId, creditFactory);
        }
        else if (type == 'tradeName') {
            successMessage = updateTradeName(internalCompany.accountId, creditFactory);
        }
        else if (type == 'additionalName') {
            successMessage = updateAdditionalName(internalCompany.accountId, creditFactory);
        }
        else if (type == 'taxId') {
            successMessage = updateTaxId(internalCompany.accountId, creditFactory);
        }
        else if (type == 'tradeRegisterNumber') {
            successMessage = updateTradeRegisterNumber(internalCompany.accountId, creditFactory);
        }
        else if (type == 'vatNumber') {
            successMessage = updateVatNumber(internalCompany.accountId, creditFactory);
        }
        else if (type == 'swiftBic') {
            successMessage = updateSwiftBic(internalCompany.opportunityId, creditFactory);
        }
        
        return successMessage;
    }
    
    
    /*******************************************************************************
    *  Summary         : Update Address
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateAddress(String accountId, CreditFactory creditFactory) {
        try {
            Map<String, Object> fieldsToUpdateMap = creditFactory.returnAddressFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Address has been updated.';
    	} catch (Exception e) {
            throw new AuraHandledException('Address update failed.');
        }
    }


    /*******************************************************************************
    *  Summary         : Update Address
    *  CreatedDate     : 10/09/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateAdditionalAddress(String accountId, CreditFactory creditFactory) {
        try {
            Map<String, Object> fieldsToUpdateMap = creditFactory.returnAdditionalAddressFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Address has been updated.';
    	} catch (Exception e) {
            throw new AuraHandledException('Address update failed.');
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Update Postal Address
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updatePostalAddress(String accountId, CreditFactory creditFactory) {
        try {
    		Map<String, Object> fieldsToUpdateMap = creditFactory.returnPostalAddressFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Address has been updated.';
    	} catch (Exception e) {
            throw new AuraHandledException('Address update failed.');
        }
    }
    
    /*******************************************************************************
    *  Summary         : Update Registered Address
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateRegisteredAddress(String accountId, CreditFactory creditFactory) {
        try {
    		Map<String, Object> fieldsToUpdateMap = creditFactory.returnRegisteredAddressFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Address has been updated.';
    	} catch (Exception e) {
            throw new AuraHandledException('Address update failed.');
        }
    }
    

    /*******************************************************************************
    *  Summary         : Update Account Name
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateName(String accountId, CreditFactory creditFactory) {
    	try {
            Map<String, Object> fieldsToUpdateMap = creditFactory.returnNameFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Account Name has been updated.';
    	} catch (Exception e) {
            throw new AuraHandledException('Account Name update failed.');
        }
    }


    /*******************************************************************************
    *  Summary         : Update Account Name
    *  CreatedDate     : 30/09/2020 by Ivan Kulinkovich
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateTradeName(String accountId, CreditFactory creditFactory) {
        try {
            Map<String, Object> fieldsToUpdateMap = creditFactory.returnTradeNameFieldsToUpdate();
            updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
            return 'Account Name has been updated.';
        } catch (Exception e) {
            throw new AuraHandledException('Account Name update failed.');
        }
    }


    /*******************************************************************************
    *  Summary         : Update Account Name
    *  CreatedDate     : 10/09/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateAdditionalName(String accountId, CreditFactory creditFactory) {
    	try {
            Map<String, Object> fieldsToUpdateMap = creditFactory.returnAdditionalNameFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Account Name has been updated.';
    	} catch (Exception e) {
            throw new AuraHandledException('Account Name update failed.');
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Update Account Tax Id
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateTaxId(String accountId, CreditFactory creditFactory) {
    	try {
    		Map<String, Object> fieldsToUpdateMap = creditFactory.returnTaxIdFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Tax Id has been updated.';
    	} catch (Exception e) {
            String duplicateValueError = '';
            if (e.getMessage().contains('Duplicate Tax ID number is found.')) {
            	duplicateValueError = ' ' + 'Duplicate value is found.';
            }
            
            throw new AuraHandledException('Tax Id update failed.' + duplicateValueError);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Update Account Trade Register Number
    *  CreatedDate     : 26/05/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateTradeRegisterNumber(String accountId, CreditFactory creditFactory) {
    	try {
    		Map<String, Object> fieldsToUpdateMap = creditFactory.returnTradeRegisterNumberFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Trade Register Number has been updated.';
    	} catch(Exception e) {
            throw new AuraHandledException('Trade Register Number update failed.');
        }
    }


    /*******************************************************************************
    *  Summary         : Update Account Vat Number
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateVatNumber(String accountId, CreditFactory creditFactory) {
    	try {
    		Map<String, Object> fieldsToUpdateMap = creditFactory.returnVatNumberFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, null, accountId, null, null);
    		return 'Vat Number has been updated.';
    	} catch(Exception e) {
            throw new AuraHandledException('Vat Number update failed.');
        }
    }


    /*******************************************************************************
    *  Summary         : Update Opportunity Swift Bic
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : accountId - id of account,
                         creditFactory - credit factory interface
    *  Returns         : success message
    ******************************************************************************/
    private static String updateSwiftBic(String opportunityId, CreditFactory creditFactory) {
    	try {
    		Map<String, Object> fieldsToUpdateMap = creditFactory.returnSwiftBicFieldsToUpdate();
    		updateSObjects(fieldsToUpdateMap, opportunityId, null, null, null);
    		return 'SWIFT BIC has been updated.';
    	} catch(Exception e) {
            throw new AuraHandledException('SWIFT BIC update failed.');
        }
    }

    
    /*******************************************************************************
    *  Summary         : Set "Update Opportunity" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : success message
    ******************************************************************************/
    @AuraEnabled
    public static void setUpdateOpportunityDecision(Map<String, Object> dataMap) {
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
            doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
            Map<String, Object> fieldsToUpdate = creditFactory.returnUpdateOpportunityFieldsToUpdate();
            updateSObjects(fieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
        } catch (Exception e) {
            throw new AuraHandledException('Update Opportunity failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Set "Contract Check" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : validation message
    ******************************************************************************/
    @AuraEnabled
    public static String changeToContractCheck(Map<String, Object> dataMap) {
        try {
            String validationMessage;
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            
            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);
            CreditFactoryValidationItem validationItem = validationItemsMap.get('Duplicates'); 
            if (validationItem.passed == false) {
                Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
                updateSObjects(duplicateFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                submitForApproval('Duplicate', internalCompany.opportunityId);
                validationMessage = validationItem.description + '<br/>' + CreditFactoryGlobalUtils.SUBMIT_FOR_APPROVAL;
            } else {
                CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
                doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
                Map<String, Object> fieldsToUpdate = creditFactory.returnContractCheckFieldsToUpdate();
                updateSObjects(fieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                submitForApproval('Contract Check', internalCompany.opportunityId);
            }
            
            return validationMessage;
        } catch (Exception e) {
            throw new AuraHandledException('Change to Contract Check failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
    
    
    /*******************************************************************************
	*  Summary         : Submit opportunity for approval
	*  ModifiedDate    : 27/05/2020 by Anton Buzak 
	*  Parameters      : type - type of request, 
                         opportunityId - id of opportunity 
	*  Returns         : -
	******************************************************************************/
	private static void submitForApproval(String type, String opportunityId) {
		Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
		if (type == 'Contract Check') request.setComments('Submitting request for Contract check.');
        request.setObjectId(opportunityId);
        request.setSubmitterId(UserInfo.getUserId()); 
        request.setSkipEntryCriteria(false);
        Approval.process(request); 
	}
    
    
    /*******************************************************************************
    *  Summary         : Set "Closed Won" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : validation message
    ******************************************************************************/
    @AuraEnabled
    public static String changeToClosedWon(Map<String, Object> dataMap) {
        try {
            String validationMessage;
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            
            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);
            CreditFactoryValidationItem validationItem = validationItemsMap.get('Duplicates'); 
            if (validationItem.passed == false) {
                Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
                updateSObjects(duplicateFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                submitForApproval('Duplicate', internalCompany.opportunityId);
                validationMessage = validationItem.description + '<br/>' + CreditFactoryGlobalUtils.SUBMIT_FOR_APPROVAL;
            } else {
                CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
                doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
                Map<String, Object> closedWonFieldsToUpdate = creditFactory.returnClosedWonFieldsToUpdate();
                updateSObjects(closedWonFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
            }
            
            return validationMessage;
        } catch (Exception e) {
            String exceptionMessage = 'Change to Closed Won failed. '; 
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')) {
                exceptionMessage += e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') + '.';
            } else {
                exceptionMessage += CreditFactoryGlobalUtils.CONTACT_ADMIN;
            }
            
            throw new AuraHandledException(exceptionMessage);
        }
    }


    /*******************************************************************************
    *  Summary         : Set "Pending SEPA" decision
    *  CreatedDate     : 18/08/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : validation message
    ******************************************************************************/
    @AuraEnabled
    public static String changeToPendingSepa(Map<String, Object> dataMap) {
        try {
            String validationMessage;
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();

            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);
            CreditFactoryValidationItem validationItem = validationItemsMap.get('Duplicates');
            if (validationItem.passed == false) {
                Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
                updateSObjects(duplicateFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                submitForApproval('Duplicate', internalCompany.opportunityId);
                validationMessage = validationItem.description + '<br/>' + CreditFactoryGlobalUtils.SUBMIT_FOR_APPROVAL;
            } else {
                CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
                doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
                Map<String, Object> closedWonFieldsToUpdate = creditFactory.returnPendingSepaFieldsToUpdate();
                updateSObjects(closedWonFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
            }

            return validationMessage;
        } catch (Exception e) {
            String exceptionMessage = 'Change to Pending SEPA failed. ';
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')) {
                exceptionMessage += e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') + '.';
            } else {
                exceptionMessage += CreditFactoryGlobalUtils.CONTACT_ADMIN;
            }

            throw new AuraHandledException(exceptionMessage);
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Set "Pending Deposit" decision
    *  CreatedDate     : 27/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : map of results
    ******************************************************************************/
    @AuraEnabled
    public static String changeToPendingDeposit(Map<String, Object> dataMap) {
        try {
            String validationMessage;
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            
            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);
            CreditFactoryValidationItem validationItem = validationItemsMap.get('Duplicates'); 
            if (validationItem.passed == false) {
                Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
                updateSObjects(duplicateFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                submitForApproval('Duplicate', internalCompany.opportunityId);
                validationMessage = validationItem.description + '<br/>' + CreditFactoryGlobalUtils.SUBMIT_FOR_APPROVAL;
            } else {
                CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
                doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
                Map<String, Object> fieldsToUpdate = creditFactory.returnPendingDepositFieldsToUpdate();
                updateSObjects(fieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
            }
            
            return validationMessage;
        } catch (Exception e) {
            throw new AuraHandledException('Change to Pending Deposit failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Set "Pending Advance Payment" decision
    *  CreatedDate     : 26/02/2021 by Ivan Kulinkovich
    *  Parameters      : dataMap - internal data
    *  Returns         : map of results
    ******************************************************************************/
    @AuraEnabled
    public static String changeToPendingAdvancePayment(Map<String, Object> dataMap) {
        try {
            String validationMessage;
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();

            CreditFactoryValidation creditFactoryValidation = CreditFactoryService.returnCreditFactoryValidation(implKey);
            creditFactoryValidation.setInternalCFCompany(dataMap);
            Map<String, CreditFactoryValidationItem> validationItemsMap = creditFactoryValidation.validate(new List<String> {'Duplicates'}, false);
            CreditFactoryValidationItem validationItem = validationItemsMap.get('Duplicates');
            if (validationItem.passed == false) {
                Map<String, Object> duplicateFieldsToUpdate = creditFactory.returnDuplicateFieldsToUpdate();
                updateSObjects(duplicateFieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
                submitForApproval('Duplicate', internalCompany.opportunityId);
                validationMessage = validationItem.description + '<br/>' + CreditFactoryGlobalUtils.SUBMIT_FOR_APPROVAL;
            } else {
                CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
                doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
                Map<String, Object> fieldsToUpdate = creditFactory.returnPendingAdvancePaymentFieldsToUpdate();
                updateSObjects(fieldsToUpdate, internalCompany.opportunityId, internalCompany.accountId, null, null);
            }

            return validationMessage;
        } catch (Exception e) {
            throw new AuraHandledException('Change to Pending Advance Payment failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Summary         : Send request for parent contact
    *  CreatedDate     : 10/09/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : -
    ******************************************************************************/
    @AuraEnabled
    public static String updateContacts(Map<String, Object> dataMap) {
        try {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            CreditFactoryReportsItem cfReportsItem = creditFactory.selectCompanyReports(internalCompany.opportunityId);
            Map<String, Object> reportMap = doScoring(dataMap, cfReportsItem, internalCompany, creditFactory);
            String contactParentCompanyId = ((CreditFactoryResult) reportMap.get('cfResult')).contactParentCompanyId;
            List<Credit_Factory_Report_Employee__c> currentEmployeesList = creditFactory.createCFReportEmployeesInstances();
            List<Credit_Factory_Report_Employee__c> employeesListToUpsert = new List<Credit_Factory_Report_Employee__c>();
            for (Credit_Factory_Report_Employee__c employee : currentEmployeesList) {
                if (employee.RecordTypeId == GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default') && employee.Company_Id__c == contactParentCompanyId) {
                    employee.Reported__c = true;
                    employeesListToUpsert.add(employee);
                }
            }

            List<Credit_Factory_Report_Employee__c> newEmployeesList = creditFactory.requestParentCompanyContacts(contactParentCompanyId);
            List<Credit_Factory_Report__c> reportsList = creditFactory.createCFReportsInstances();
            for (Credit_Factory_Report__c report : reportsList) {
                if (report.RecordType.Name == 'Default') {
                    for (Credit_Factory_Report_Employee__c employee : newEmployeesList) {
                        employee.Credit_Factory_Report__c = report.Id;
                    }
                }
            }

            employeesListToUpsert.addAll(newEmployeesList);

            upsert employeesListToUpsert;

            return 'Employees data has been updated.';
        } catch (Exception e) {
            throw new AuraHandledException('Update employees failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
  

    /*******************************************************************************
    *  Summary         : Save all validation errors in Opportunity
    *  CreatedDate     : 26/09/2019 by Anton Buzak
    *  Parameters      : dataMap - internal data, 
                         errorMessage - error,
                         isReportGenerated - identifier of step
    *  Returns         : void
    ******************************************************************************/
    @AuraEnabled
    public static void saveErrors(Map<String, Object> dataMap, String errorMessage, Boolean isReportGenerated) {
        if (! String.isEmpty(errorMessage)) {
            String country = String.valueOf(dataMap.get('country'));
            String recordType = String.valueOf(dataMap.get('recordType'));
            String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
            creditFactory.setInternalCFCompany(dataMap);
            CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
            internalCompany.cfErrors = overrideCfErrors(internalCompany.cfErrors, errorMessage);
            internalCompany.lastCfErrors = overrideLastCfErrors(internalCompany.lastCfErrors, errorMessage, internalCompany.cfStage);
            internalCompany.cfStage = overrideCFStage(internalCompany.cfStage, isReportGenerated);
            Map<String, Object> fieldsToUpdateMap = new Map<String, Object>();
            Map<String, Object> opportunityFieldsMap = new Map<String, Object>();
            opportunityFieldsMap.put('Credit_Factory_Errors__c', internalCompany.cfErrors);
            opportunityFieldsMap.put('Last_CF_Errors__c', internalCompany.lastCfErrors);
            opportunityFieldsMap.put('CF_Stage__c', internalCompany.cfStage);
            fieldsToUpdateMap.put('Opportunity', opportunityFieldsMap);
            updateSObjects(fieldsToUpdateMap, String.valueOf(dataMap.get('opportunityId')), String.valueOf(dataMap.get('accountId')), null, null);
        }
    }

   /*******************************************************************************
   *  Summary         : Override Credit Factory errors field
   *  CreatedDate     : 26/09/2019 by Anton Buzak
   *  Parameters      : currentCfErrors - current value of Credit Factory Errors field,
                      : errorsToAdd - error
   *  Returns         : new value of credit factory errors
   ******************************************************************************/
   private static String overrideCfErrors(String cfErrors, String errorsToAdd) {
        if (errorsToAdd != null) {
            for (String errorToAdd : errorsToAdd.split('</br>')) {
                errorToAdd = CreditFactoryGlobalUtils.clearErrorMessage(errorToAdd);
                if (cfErrors == null) {
                    cfErrors = errorToAdd;
                } 
                else if (! cfErrors.contains(errorToAdd)) {
                    cfErrors += '\n' + errorToAdd;
                }
            }
        }

       return cfErrors;
   }

   /*******************************************************************************
   *  Summary         : Override Last CF errors field
   *  CreatedDate     : 26/09/2019 by Anton Buzak
   *  Parameters      : currentCfErrors - current value of Credit Factory Errors field,
                        errorsToAdd - error, cfStage - Credit Factory stage
   *  Returns         : new value of last credit factory errors
   ******************************************************************************/
   private static String overrideLastCfErrors(String lastCfErrors, String errorsToAddList, String cfStage) {
        if (errorsToAddList != null) {
            if (cfStage != 'Auto CW' && cfStage != 'Manual scoring' &&
                    cfStage != 'Pending deposit' && cfStage != 'Pending Credit - Contract Check') {
                lastCfErrors = null;
                for (String errorToAdd : errorsToAddList.split('</br>')) {
                    errorToAdd = CreditFactoryGlobalUtils.clearErrorMessage(errorToAdd);
                    if (lastCfErrors == null) {
                        lastCfErrors = errorToAdd;
                    }
                    else {
                        lastCfErrors += '\n' + errorToAdd;
                    }
                }
            } 
            else if (cfStage == 'Manual scoring') {
                for (String errorToAdd : errorsToAddList.split('</br>')) {
                    errorToAdd = CreditFactoryGlobalUtils.clearErrorMessage(errorToAdd);
                    if (errorToAdd == 'Duplicates found.') {
                        lastCfErrors = errorToAdd;
                    }
                }
            }
        }
       
       return lastCfErrors;
   }


    /*******************************************************************************
     *  Summary         : Override Last CF errors field
     *  CreatedDate     : 26/09/2019 by Anton Buzak
     *  Parameters      : cfStage - Credit Factory stage,
                          isReportGenerated - identifier of step
     *  Returns         : new value of credit factory stage
     ******************************************************************************/
    private static String overrideCFStage(String currentCfStage, Boolean isReportGenerated) {
        String newCfStage = currentCfStage;
        if (currentCfStage != null && currentCfStage != 'Auto CW' && currentCfStage != 'Manual scoring' &&
                currentCfStage != 'Pending deposit' && currentCfStage != 'Pending Credit - Contract Check' &&
                ! currentCfStage.contains('Pending Credit Report')) {
            if (isReportGenerated == true) {
                newCfStage = 'Error (Report generated)';
            } 
            else {
                newCfStage = 'Error (Report not generated)';
            }
        }

        return newCfStage;
    }


    /*******************************************************************************
    *  Summary         : update Opportunity, Account and Contacts   
    *  Created         : 05/03/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private static void updateSObjects(Map<String, Object> sObjectsMap,
                                       String opportunityId, String accountId, String contactId, String reportId) {
        if (sObjectsMap.containsKey('Account') && accountId != null) {
            Account account = new Account(
                Id = accountId
            );

            Map<String, Object> accountFieldsMap = (Map<String, Object>) sObjectsMap.get('Account');
            for (String accountField : accountFieldsMap.keySet()) {
                account.put(accountField, accountFieldsMap.get(accountField));
            }
            
            update account;
        }
        
        if (sObjectsMap.containsKey('Opportunity') && opportunityId != null) {
            Opportunity opportunity = new Opportunity(
                Id = opportunityId
            );
            
            Map<String, Object> opportunityFieldsMap = (Map<String, Object>) sObjectsMap.get('Opportunity');
            for (String opportunityField : opportunityFieldsMap.keySet()) {
                opportunity.put(opportunityField, 
                        opportunityFieldsMap.get(opportunityField));
            }
            
            update opportunity;
        }

        if (sObjectsMap.containsKey('Contact') && contactId != null) {
            Contact contact = new Contact(
                Id = contactId
            );

            Map<String, Object> contactFieldsMap = (Map<String, Object>) sObjectsMap.get('Contact');
            for (String contactField : contactFieldsMap.keySet()) {
                contact.put(contactField, contactFieldsMap.get(contactField));
            }

            update contact;
        }
        
        if (sObjectsMap.containsKey('Credit_Factory_Report__c') && reportId != null) {
            Credit_Factory_Report__c report = new Credit_Factory_Report__c(
                Id = reportId
            );

            Map<String, Object> reportFieldsMap = (Map<String, Object>) sObjectsMap.get('Credit_Factory_Report__c');
            for (String reportField : reportFieldsMap.keySet()) {
                report.put(reportField, reportFieldsMap.get(reportField));
            }
            
            update report;
        }
    }
    
    
    /*******************************************************************************
    *  Summary         : Select tasks with call object
    *  Created         : 28/05/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : list of tasks
    ******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Task> getCallTasksList(String opportunityId) {
        List<Task> tasksList = [
                SELECT Subject, ActivityDate, Status, Priority, LastModifiedDate
                FROM Task
                WHERE WhatId = :opportunityId AND CallObject != null];
        
        return tasksList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Confirm call task
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : dataMap - internal data
    *  Returns         : success message
    ******************************************************************************/
    @AuraEnabled
    public static String confirmCall(Map<String, Object> dataMap, String callId) {
        try {
            String successMessage;
            if (! String.isEmpty(callId)) {
                String country = String.valueOf(dataMap.get('country'));
                String recordType = String.valueOf(dataMap.get('recordType'));
                String implKey = CreditFactoryGlobalUtils.returnImplKey(country, recordType);
                CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(implKey);
                creditFactory.setInternalCFCompany(dataMap);
                CreditFactoryCompany internalCompany = creditFactory.getInternalCFCompany();
                creditFactory.selectCompanyReports(internalCompany.opportunityId);
                Map<String, Object> fieldsToUpdateMap = creditFactory.returnCallFieldsToUpdate(callId);
                updateSObjects(fieldsToUpdateMap, internalCompany.opportunityId, internalCompany.accountId, null, null);
                successMessage = 'Contact role has been confirmed.';
            }
            else {
                throw new CreditFactoryException('Call confirmation failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
            }
            
            return successMessage;
        } catch (Exception e) {
            throw new AuraHandledException('Call confirmation failed. ' + CreditFactoryGlobalUtils.CONTACT_ADMIN);
        }
    }
}