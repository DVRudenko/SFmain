public virtual class ETEJobExecutorBaseImpl implements ETEJobExecutor {
    private List<String> jobsNeededToRun;
    private String dataObjectId;
    private String countryCode;


    public ETEJobExecutorBaseImpl (List<String> jobsNeededToRun, String dataObjectId, String countryCode) {
        this.jobsNeededToRun = jobsNeededToRun;
        this.dataObjectId = dataObjectId;
        this.countryCode = countryCode;
    }


    public virtual void checkBusinessObjects(ETEDatabaseInterface e2eDatabase, E2E_Data_Log__c existingJobInDataBase) {
        E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(this.dataObjectId);
        ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(dataObject.RecordType.Name);
        Opportunity opportunity = e2eDatabase.retrieveOpportunity(dataObject.Id);
        if (opportunity == null) {
            if (dataObject.Lead__c != null) {
                E2E_Data_Contact__c e2ePrimaryContact = e2eDatabase.retrieveETEPrimaryContact(dataObject.Id);
                ETEAdoptionInterface e2eAdoptionImpl = ETEGlobalUtils.getETEAdoptionService(dataObject.RecordType.Name);
                Lead lead = e2eDatabase.retrieveLead(dataObject.Lead__c);
                if ( ! lead.IsConverted) {
                    Account duplicateAccount = ETEDeduplicationService.findDupAccount(dataObject, null, lead);
                    Account account;
                    if (duplicateAccount == null) {
                        account = e2eAdoptionImpl.insertAccount(dataObject, lead);
                    } else {
                        account = duplicateAccount;
                    }
                    opportunity  = e2eAdoptionImpl.insertOpportunity(dataObject, lead, account);
                    Contact contact = e2eAdoptionImpl.insertContact(dataObject, account, e2ePrimaryContact);
                    e2eAdoptionImpl.insertOpportunityContactRole(opportunity, contact);
                    List<Emarsys_Log__c> emarsysLogs = e2eDatabase.retrieveEmarsysLogs(dataObject.Lead__c);
                    if ( emarsysLogs != null ) {
                        emarsysLogs = e2eAdoptionImpl.setFieldsToUpdateEmarsysLogs(emarsysLogs, opportunity);
                        e2eDatabase.updateEmarsysLogs(emarsysLogs);
                    }
                    E2E_Data_Contact__c e2EDataContact = e2eDatabase.retrieveETEPrimaryContact(dataObject.Id);
                    e2EDataContact.Fleetcor_Contact__c = contact.Id;
                    List<E2E_Data_Contact__c> e2EDataContactsToUpsert = new List<E2E_Data_Contact__c>();
                    e2EDataContactsToUpsert.add(e2EDataContact);
                    e2eDatabase.upsertETEContacts(e2EDataContactsToUpsert);

                    e2eAdoptionImpl.convertLeadToE2E(dataObject, account, opportunity, contact);
                    e2eAdoptionImpl.updateLead(lead);
                }
            } else {
                String priceBookId;
                if (! Test.isRunningTest()) {
                    priceBookId = e2eDatabase.retrieveStandardPricebook().Id;
                } else {
                    priceBookId = Test.getStandardPricebookId();
                }
                opportunity = businessObjectsHandler.initOpportunity(dataObject, priceBookId);
                e2eDatabase.upsertOpportunity(opportunity);
            }
        }
        existingJobInDataBase = e2eDatabase.retrieveE2EDataLogByName(dataObject.Id, existingJobInDataBase.Name).get(0);
        if (existingJobInDataBase.Job_Status__c != 'Restart') {
            this.jobsNeededToRun.remove(0);
            existingJobInDataBase.Job_Status__c = 'Completed';
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{existingJobInDataBase});
        }
        // run next job
        if (! Test.isRunningTest()) {
            ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(this.jobsNeededToRun,
                                                                        this.dataObjectId,
                                                                        this.countryCode,
                                                                        dataObject.RecordType.Name);
            jobChainHandler.runNext();
        }
    }


    public virtual void doReportRequest(ETEDatabaseInterface e2eDatabase, E2E_Data_Log__c existingJobInDataBase) {
        try {
            String country = ETEGlobalUtils.returnCountry(this.countryCode);
            E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(this.dataObjectId);
            CreditFactoryReportsItem reportsItem;
            ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(dataObject.RecordType.Name);
            if (! String.isEmpty(dataObject.Selected_Company_Id__c)) {
                Opportunity opportunity = e2eDatabase.retrieveOpportunity(dataObject.Id);
                if (dataObject.Selected_Company_Id__c != 'none') {
                    if (opportunity.E2E_CF_Reports_Counter__c == null) {
                        opportunity.E2E_CF_Reports_Counter__c = 0;
                    }
                    List<Credit_Factory_Report__c> existingCFReports = new List<Credit_Factory_Report__c>();
                    List<Attachment> existingCFAttachments = new List<Attachment>();
                    if (opportunity.E2E_CF_Reports_Counter__c < 2) {
                        existingCFReports = e2eDatabase.retrieveCFReports(opportunity.Id);
                        Set<String> cfAttachmentsNames = new Set<String>();
                        cfAttachmentsNames.addAll(CreditFactoryGlobalUtils.returnAttachmentNamesMap(country).values());
                        existingCFAttachments = e2eDatabase.retrieveAttchments(cfAttachmentsNames, opportunity.Id);
                        List<Map<String, Object>> contactsList = new List<Map<String, Object>>();
                        Map<String, Object> contactsDataMap = new Map<String, Object>();
                        E2E_Data_Contact__c primaryContact = e2eDatabase.retrieveETEPrimaryContact(this.dataObjectId);
                        contactsDataMap.put('firstName', primaryContact.First_Name__c);
                        contactsDataMap.put('lastName', primaryContact.Last_Name__c);
                        contactsDataMap.put('isPrimary', true);
                        contactsDataMap.put('email', primaryContact.Email__c);
                        contactsDataMap.put('dateOfBirth', ETEGlobalUtils.convertStringToDate(primaryContact.Birthdate__c));
                        contactsDataMap.put('relation', 'OpportunityContactRole');
                        contactsList.add(contactsDataMap);
                        Map<String, E2E_Data_Product__c> eteProductsMap = e2eDatabase.retrieveETEProducts(dataObjectId);
                        Map<String, E2E_Data_Offer_Item__c> eteDataOfferItemsMap = e2eDatabase.retrieveETEOfferItems(eteProductsMap.keySet());
                        Map<String, Object> consumptionDataMap = e2eStep.doCalculateConsumption(dataObject, eteProductsMap, eteDataOfferItemsMap.values());
                        Map<String, Object> creditFactoryDataMap = new Map<String, Object>();
                        creditFactoryDataMap.put('creditFactoryContacts', contactsList);
                        creditFactoryDataMap.put('totalConsumption', (Decimal) consumptionDataMap.get('totalConsumption'));
                        creditFactoryDataMap.put('countryCode', dataObject.Country_Code__c);
                        creditFactoryDataMap.put('country', ETEGlobalUtils.returnCountry(dataObject.Country_Code__c));
                        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(dataObject.RecordType.Name);
                        creditFactory.setInternalCFCompany(creditFactoryDataMap);
                        if (! Test.isRunningTest()) {
                            creditFactory.requestStartReportsCheck(dataObject.Selected_Company_Id__c);
                            reportsItem = creditFactory.requestCompanyReports(dataObject.Selected_Company_Id__c);
                        } else {
                            reportsItem = new CreditFactoryReportsItem();
                            reportsItem.isReportAvailable = true;
                        }
                        if (reportsItem.isReportAvailable == true) {
                            List<Credit_Factory_Report__c> reportsList = new List<Credit_Factory_Report__c>();
                            if (! Test.isRunningTest()) {
                                reportsList = creditFactory.createCFReportsInstances();
                            } else {
                                reportsList.add(CreditFactoryTestUtils.generateCreditFactoryReport(country));
                            }
                            Account account;
                            if (opportunity.AccountId != null) {
                                account = e2eDatabase.retrieveAccount(opportunity.AccountId);
                            } else {
                                ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(dataObject.RecordType.Name);
                                account = businessObjectsHandler.initAccount(country, dataObject);
                                e2eDatabase.upsertAccount(account);
                                opportunity.AccountId = account.Id;
                            }
                            for (Credit_Factory_Report__c report : reportsList) {
                                report.Opportunity__c = opportunity.Id;
                                report.Account__c = account.Id;
                            }
                            // upsert credit factory reports
                            e2eDatabase.upsertCreditFactoryReports(reportsList);
                            if (! Test.isRunningTest()) {
                                creditFactory.createPdfReports(opportunity.Id);
                            }

                            // upsert credit factory employees
                            List<Credit_Factory_Report_Employee__c> reportEmployees = new List<Credit_Factory_Report_Employee__c>();
                            if (! Test.isRunningTest()) {
                                reportEmployees = creditFactory.createCFReportEmployeesInstances();
                            } else {
                                reportEmployees.add(CreditFactoryTestUtils.generateCreditFactoryReportEmployee(country));
                            }
                            for (Credit_Factory_Report_Employee__c employee : reportEmployees) {
                                for (Credit_Factory_Report__c report : reportsList) {
                                    if (GlobalUtils.returnRecordTypeName('Credit_Factory_Report__c', report.RecordTypeId) ==
                                        GlobalUtils.returnRecordTypeName('Credit_Factory_Report_Employee__c', employee.RecordTypeId)) {
                                        employee.Credit_Factory_Report__c = report.Id;
                                    }
                                }
                            }
                            e2eDatabase.upsertCreditFactoryEmployees(reportEmployees);

                            // upsert opportunity
                            opportunity.E2E_CF_Reports_Counter__c = opportunity.E2E_CF_Reports_Counter__c + 1;
                            e2eDatabase.upsertOpportunity(opportunity);
                        } else {
                            if (reportsItem.isWaiting != true) {
                                // report doesn't exist;
                                existingJobInDataBase.Exception_Type__c = 'Company search';
                                existingJobInDataBase.Exception_Description__c = 'Report does not exist';
                            } else {
                                // Schufa Germany
                                return;
                            }
                        }
                    } else {
                        existingJobInDataBase.Exception_Type__c = 'Process Error';
                        existingJobInDataBase.Exception_Description__c = 'Report request limit exceeded';
                    }
                    if (String.isEmpty(existingJobInDataBase.Exception_Description__c)) {
                        if (! existingCFReports.isEmpty()) { e2eDatabase.deleteCreditFactoryReports(existingCFReports); }
                        if (! existingCFAttachments.isEmpty()) { e2eDatabase.deleteAttchments(existingCFAttachments); }
                    }
                } else {
                    existingJobInDataBase.Exception_Type__c = 'Company search';
                    existingJobInDataBase.Exception_Description__c = 'Company is not in the list';
                }
                if (existingJobInDataBase.Exception_Description__c == 'Report does not exist') {
                    if (reportsItem != null && reportsItem.isOrderAvailable == true) {
                        Boolean isReportOrder = false;
                        Map<String, Object> untypedSettings = e2eDatabase.getSettings(dataObject.RecordType.Name, this.countryCode);
                        Map<String, Map<String, Object>> stepDependenciesMap = e2eStep.returnStepDependencies(untypedSettings);
                        for (String stepName : stepDependenciesMap.keySet()) {
                            List<Object> jobsToRunList = (List<Object>) stepDependenciesMap.get(stepName).get('jobs_to_run');
                            for (Object jobToRun :  jobsToRunList) {
                                Map<String, Object> jobsToRunSettingsMap = (Map<String, Object>) jobToRun;
                                if (jobsToRunSettingsMap.containsKey('syncCompanyDetails')) {
                                    isReportOrder = true;
                                    break;
                                }
                            }

                            if (isReportOrder) {
                                break;
                            }
                        }

                        if (isReportOrder) {
                            String orderId = reportsItem.orderId;
                            doReportOrder(e2eDatabase, orderId, dataObject, opportunity);
                            e2eDatabase.upsertOpportunity(opportunity);
                        }
                    }
                }
            }
            String existingJobStatus = e2eDatabase.retrieveE2EDataLogByName(dataObject.Id, existingJobInDataBase.Name).get(0).Job_Status__c;
            if (existingJobStatus != 'Restart') {
                this.jobsNeededToRun.remove(0);
                existingJobInDataBase.Job_Status__c = 'Completed';
                e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{existingJobInDataBase});
            }
            // run next job
            if (! Test.isRunningTest()) {
                ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(this.jobsNeededToRun,
                                                                            this.dataObjectId,
                                                                            this.countryCode,
                                                                            dataObject.RecordType.Name);
                jobChainHandler.runNext();
            }
        } catch (Exception e) {
            existingJobInDataBase.Exception_Type__c = 'CF System Error';
            existingJobInDataBase.Job_Status__c = 'Failed';
            existingJobInDataBase.Exception_Description__c = e.getMessage() + ' ' + e.getStackTraceString();
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{existingJobInDataBase});
        }
    }


    public virtual void doDeduplication(ETEDatabaseInterface e2eDatabase, E2E_Data_Log__c existingJobInDataBase) {
        E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(this.dataObjectId);
        List<E2E_Data_Contact__c> existingETEdataContacts = e2eDatabase.retrieveETEContacts(dataObject.Id);
        ETEDeduplicationService dedupService = new ETEDeduplicationService(dataObject, existingETEdataContacts);
        dedupService.findDuplicates();
        Account dupAccount = dedupService.getAccount();
        Contact primaryDupContact = dedupService.getPrimaryContact();
        Contact dupContact = dedupService.getContact();

        Opportunity opportunity = dedupService.getOpportunity();
        if (dupAccount != null || primaryDupContact != null || dupContact != null) {
            Map<String, OpportunityContactRole> contactRoleMap = new Map<String, OpportunityContactRole>([SELECT ContactId, IsPrimary FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id]);
            if (dupAccount != null) {
                String currentAccountId = opportunity.AccountId;
                opportunity.AccountId = dupAccount.Id;
                e2eDatabase.upsertOpportunity(opportunity);
                if (! contactRoleMap.isEmpty()) {
                    Map<String, String> contactRoleToContactIdMap = new Map<String, String>();
                    for (OpportunityContactRole ocr : contactRoleMap.values()) {
                        contactRoleToContactIdMap.put(ocr.Id, ocr.ContactId);
                    }
                    List<Contact> currentyContacts = [SELECT AccountId FROM Contact WHERE Id = :contactRoleToContactIdMap.values()];
                    for (Contact contact : currentyContacts) {
                        contact.AccountId = dupAccount.Id;
                    }
                    e2eDatabase.upsertSFContacts(currentyContacts);
                }
                if (currentAccountId != null) {
                    delete e2eDatabase.retrieveAccount(currentAccountId);
                }
                dedupService.updateDupAccountAsMergedInE2E();
                dedupService.generateCase();
                dedupService.processCase();
            }
            if (primaryDupContact != null || dupContact != null) {
                String accountId;
                if (dupAccount != null) {
                    accountId = dupAccount.Id;
                } else {
                    accountId = opportunity.AccountId;
                }
                dedupService.updateDupContactAsMergedInE2E(accountId);
                List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
                if (! contactRoleMap.isEmpty()) {
                    for (OpportunityContactRole ocr : contactRoleMap.values()) {
                        OpportunityContactRole contactRole = ocr;
                        if (ocr.IsPrimary) {
                            contactRole.ContactId = primaryDupContact.Id;
                        } else {
                            contactRole.ContactId = dupContact.Id;
                        }
                        opportunityContactRoles.add(contactRole);
                    }
                } else {
                    if (primaryDupContact != null) {
                        OpportunityContactRole primaryContactRole =  new OpportunityContactRole(
                                ContactId = primaryDupContact.Id,
                                OpportunityId = opportunity.Id,
                                IsPrimary = true);
                        opportunityContactRoles.add(primaryContactRole);
                    }
                    if (dupContact != null) {
                        OpportunityContactRole contactRole =  new OpportunityContactRole(
                                ContactId = dupContact.Id,
                                OpportunityId = opportunity.Id,
                                IsPrimary = false);
                        opportunityContactRoles.add(contactRole);
                    }
                }
                e2eDatabase.upsertContactRoles(opportunityContactRoles);
            }
        }
        String stopProcess = dedupService.getStopProcess();
        if (stopProcess != null) {
            existingJobInDataBase.Exception_Type__c = 'Process Error';
            existingJobInDataBase.Exception_Description__c = stopProcess;
        }
        String existingJobStatus = e2eDatabase.retrieveE2EDataLogByName(dataObject.Id, existingJobInDataBase.Name).get(0).Job_Status__c;
        if (existingJobStatus != 'Restart') {
            this.jobsNeededToRun.remove(0);
            existingJobInDataBase.Job_Status__c = 'Completed';
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{existingJobInDataBase});
        }
        // run next job
        if (! Test.isRunningTest()) {
            ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(this.jobsNeededToRun,
                                                                            this.dataObjectId,
                                                                            this.countryCode,
                                                                            dataObject.RecordType.Name);
            jobChainHandler.runNext();
        }
    }


    private void doReportOrder(ETEDatabaseInterface e2eDatabase,
                                        String orderId,
                                        E2E_Data_Object__c dataObject,
                                        Opportunity opportunity) {
        CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(dataObject.RecordType.Name);
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('name', dataObject.Selected_Company_Name__c);
        dataMap.put('taxId', dataObject.Tax_ID__c);
        dataMap.put('tradeRegisterNumber', dataObject.Trade_Register_Number__c);
        dataMap.put('vatNumber', dataObject.Vat_ID__c);
        dataMap.put('registeredStreet', dataObject.Registered_Street__c);
        dataMap.put('registeredCity', dataObject.Registered_City__c);
        dataMap.put('registeredPostCode', dataObject.Registered_Postal_Code__c);
        dataMap.put('opportunityId', opportunity.Id);
        List<Map<String, Object>> contactsList = new List<Map<String, Object>>();
        Map<String, Object> contactsDataMap = new Map<String, Object>();
        E2E_Data_Contact__c primaryContact = e2eDatabase.retrieveETEPrimaryContact(dataObject.Id);
        contactsDataMap.put('isPrimary', true);
        contactsDataMap.put('relation', 'OpportunityContactRole');
        contactsDataMap.put('dateOfBirth', ETEGlobalUtils.convertStringToDate(dataObject.Birthdate__c));
        contactsDataMap.put('firstName', primaryContact.First_Name__c);
        contactsDataMap.put('lastName', primaryContact.Last_Name__c);
        contactsList.add(contactsDataMap);
        dataMap.put('creditFactoryContacts', contactsList);
        List<Attachment> attachments = CreditFactoryService.selectAttachmentsList(opportunity.Id);
        for (Attachment attachment : attachments) {
            Map<String, Object> attachmentsDataStructureMap = CreditFactoryService.generateAttachmentsDataStructure(attachment);
            attachmentsDataStructureMap.put('body', EncodingUtil.base64Encode(attachment.Body));
            List<Map<String, Object>> attachmentsList = CreditFactoryService.generateStructureValuesList(dataMap, 'attachments', attachmentsDataStructureMap);
            dataMap.put('attachments', attachmentsList);
        }

        creditFactory.setInternalCFCompany(dataMap);
        CreditFactoryOrderItem orderItem = creditFactory.requestOrder(orderId);
        if (orderItem != null) {
            Map<String, Object> opptyFieldsToUpdateMap = creditFactory.returnOrderFieldsToUpdate(orderItem.orderReferenceNumber);
            if (opptyFieldsToUpdateMap.containsKey('Opportunity')) {
                Map<String, Object> fieldsMap = (Map<String, Object>) opptyFieldsToUpdateMap.get('Opportunity');
                for (String opptyFieldApiName : fieldsMap.keySet()) {
                    opportunity.put(opptyFieldApiName, fieldsMap.get(opptyFieldApiName));
                }
            }
            List<E2E_Data_Log__c> reportOrderLogs = e2eDatabase.retrieveE2EDataLogByName(dataObject.Id,'reportOrderingRequest');
            E2E_Data_Log__c reportOrderingLog;
            if (reportOrderLogs.isEmpty()) {
                String recordTypeId = Schema.SObjectType.E2E_Data_Log__c.getRecordTypeInfosByName().get('Request Status').getRecordTypeId();
                reportOrderingLog = new E2E_Data_Log__c();
                reportOrderingLog.RecordTypeId = recordTypeId;
                reportOrderingLog.Name = 'reportOrderingRequest';
                reportOrderingLog.E2E_Data_Object__c = dataObject.Id;
            } else {
                reportOrderingLog = reportOrderLogs.get(0);
            }
            reportOrderingLog.Status__c = 'Report Requested';
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c> {reportOrderingLog});
        }
    }


    public virtual void syncData(ETEDatabaseInterface e2eDatabase,
                                Map<String, E2E_Data_Log__c>  existingJobsMap,
                                E2E_Data_Log__c existingJobInDataBase,
                                String actionName) {
        String country = ETEGlobalUtils.returnCountry(this.countryCode);
        E2E_Data_Object__c dataObject = e2eDatabase.retrieveETEDataObject(this.dataObjectId);
        ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(dataObject.RecordType.Name);
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(dataObject.RecordType.Name);
        List<String> defaultSettingsJsonList = e2eDatabase.retrieveStaticResourcesByName(defaultSettingsKey);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJsonList.get(0));
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(dataObject.RecordType.Name);
        Map<String, Map<String, List<String>>> objectsMappingToSyncSettings = e2eStep.returnObjectsMappingToSyncSettings(defaultSettingsMap);
        Map<String, List<String>> objectsMappingToSync = objectsMappingToSyncSettings.get(actionName);
        Set<String> allObjectsToSyncSet = new Set<String>();
        Set<String> syncDirectionKeysSet = new Set<String>();
        for (String businessObjectType : objectsMappingToSync.keySet()) {
            if (! allObjectsToSyncSet.contains(businessObjectType)) { allObjectsToSyncSet.add(businessObjectType); }
            for (String objectWithData : objectsMappingToSync.get(businessObjectType)) {
                if (! allObjectsToSyncSet.contains(objectWithData)) { allObjectsToSyncSet.add(objectWithData); }
                String syncDirectionKey = businessObjectType + '=>' + objectWithData;
                syncDirectionKeysSet.add(syncDirectionKey);
            }
        }
        Opportunity opportunity = e2eDatabase.retrieveOpportunity(dataObject.Id);
        CreditFactoryCompany creditFactoryCompany;
        Map<String, Object> additionalFieldsToUpdateFromCFReport;
        if (allObjectsToSyncSet.contains('Credit_Factory_Report__c')) {
            CreditFactory creditFactory = CreditFactoryService.returnCreditFactory(dataObject.RecordType.Name);
            creditFactoryCompany = businessObjectsHandler.getCFReport(creditFactory, opportunity.Id);
            if (creditFactoryCompany != null) {
                List<Map<String, Object>> contactsList = new List<Map<String, Object>>();
                Map<String, Object> contactsDataMap = new Map<String, Object>();
                E2E_Data_Contact__c primaryContact = e2eDatabase.retrieveETEPrimaryContact(dataObject.Id);
                contactsDataMap.put('firstName', primaryContact.First_Name__c);
                contactsDataMap.put('lastName', primaryContact.Last_Name__c);
                contactsDataMap.put('isPrimary', true);
                contactsDataMap.put('relation', 'OpportunityContactRole');
                contactsList.add(contactsDataMap);
                Map<String, Object> creditFactoryDataMap = new Map<String, Object>();
                creditFactoryDataMap.put('creditFactoryContacts', contactsList);
                creditFactory.setInternalCFCompany(creditFactoryDataMap);
                additionalFieldsToUpdateFromCFReport = creditFactory.returnReportFieldsToUpdate();
            }
        }
        Account account;
        if (allObjectsToSyncSet.contains('Account')) {
            if (opportunity.AccountId != null) {
                account = e2eDatabase.retrieveAccount(opportunity.AccountId);
            } else {
                account = businessObjectsHandler.initAccount(country, dataObject);
            }
        }

        Map<String, Contact> sfContactsToSync;
        Map<String, OpportunityContactRole> opptyContactRolesToSync;
        List<E2E_Data_Contact__c> existingETEdataContacts;
        if (allObjectsToSyncSet.contains('Contact')) {
            existingETEdataContacts = e2eDatabase.retrieveETEContacts(dataObject.Id);
            sfContactsToSync = new Map<String, Contact>();
            opptyContactRolesToSync = new Map<String, OpportunityContactRole>();
            generateFinalContactsDataToSyncMap(e2eDatabase,
                                                businessObjectsHandler,
                                                opportunity.Id,
                                                sfContactsToSync,
                                                opptyContactRolesToSync,
                                                existingETEdataContacts);
        }
        Map<String, E2E_Data_Product__c> eteProductsByParentIdMap;
        Map<String, PricebookEntry> pricebookEntriesMap;
        Map<String, OpportunityLineItem> product2IdToOpptyLineItemMap;
        Map<String, OpportunityLineItem> oliToInsert;
        List<OpportunityLineItem> oliToDelete;
        Map<String, List<E2E_Data_Offer_Item__c>> existingDataOfferItemsMap;
        Map<String, Map<String, Offer_Item__c>> existingBusinessOfferItemsMap;
        Map<String, Offer_Item__c> offerItemsToUpsertMap;
        List<Offer_Item__c> offerItemsToDeleteList;
        Map<String, E2E_Data_Locator_Item__c> existingE2ELocatorItemsMap;
        if (allObjectsToSyncSet.contains('E2E_Data_Product__c') ||
            allObjectsToSyncSet.contains('E2E_Data_Offer_Item__c') ||
            allObjectsToSyncSet.contains('E2E_Data_Locator_Item__c')) {
            eteProductsByParentIdMap = getE2EDataProducts(e2eDatabase, dataObject.Id);
            product2IdToOpptyLineItemMap = getExistingOpptyLineItems(e2eDatabase, opportunity.Id);
            oliToInsert = new Map<String, OpportunityLineItem>();
            oliToDelete = new List<OpportunityLineItem>();
            if (allObjectsToSyncSet.contains('E2E_Data_Product__c')) {
                pricebookEntriesMap = new Map<String, PricebookEntry>();
                for (PricebookEntry pricebookEntry : e2eDatabase.retrieveProductEntries(eteProductsByParentIdMap.keySet())) {
                    if (opportunity.Pricebook2Id == pricebookEntry.Pricebook2Id) {
                        pricebookEntriesMap.put(pricebookEntry.Product2Id, pricebookEntry);
                    }
                }
            }
            if (allObjectsToSyncSet.contains('E2E_Data_Product__c') || allObjectsToSyncSet.contains('E2E_Data_Offer_Item__c')) {
                existingDataOfferItemsMap = getE2EDataOfferItems(e2eDatabase, eteProductsByParentIdMap);
                if (allObjectsToSyncSet.contains('E2E_Data_Offer_Item__c')) {
                    offerItemsToDeleteList = new List<Offer_Item__c>();
                    existingBusinessOfferItemsMap = getExistingBusinessOfferItems(e2eDatabase, product2IdToOpptyLineItemMap);
                }
            }
            if (allObjectsToSyncSet.contains('E2E_Data_Locator_Item__c')) {
                Set<String> e2eProductIdsSet = new Map<String, E2E_Data_Product__c>(eteProductsByParentIdMap.values()).keySet();
                existingE2ELocatorItemsMap = e2eDatabase.retrieveETELocatorItems(e2eProductIdsSet);
            }
        }
        Map<String, E2E_Data_Additional_Service__c> e2eDataAdditionalServicesMap;
        List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesToUpsertList;
        Map<String, Client_Offer_Additional_Service__c> clientOfferAdditionalServicesMap;
        if (allObjectsToSyncSet.contains('E2E_Data_Additional_Service__c')) {
            e2eDataAdditionalServicesMap = getE2EDataAdditionalServices(e2eDatabase, dataObject.Id);
            clientOfferAdditionalServicesMap = getClientOfferAdditionalServices(e2eDatabase, opportunity.Id);
        }
        Organization org = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
        for (String syncKey : syncDirectionKeysSet) {
            switch on syncKey {
                when 'OpportunityLineItem=>E2E_Data_Product__c' {
                        generateFinalOpportunityLineItems(opportunity.Id,
                                                        eteProductsByParentIdMap,
                                                        pricebookEntriesMap,
                                                        existingDataOfferItemsMap,
                                                        product2IdToOpptyLineItemMap,
                                                        oliToInsert,
                                                        oliToDelete);
                } when 'Offer_Item__c=>E2E_Data_Offer_Item__c' {
                    Map<String, Map<String, Offer_Item__c>> finalBusinessOfferItems = generateFinalBusinessOfferItemsMap(existingDataOfferItemsMap,
                                                        existingBusinessOfferItemsMap,
                                                        offerItemsToDeleteList);
                    offerItemsToUpsertMap = mapOpptyOfferItemsFieldsWithDataOfferItemsFields(dataObject,
                                                        opportunity,
                                                        eteProductsByParentIdMap,
                                                        finalBusinessOfferItems,
                                                        existingDataOfferItemsMap);
                } when 'Opportunity=>E2E_Data_Locator_Item__c' {
                    mapOpportunityFieldsWithLocatorItemsFields(opportunity, existingE2ELocatorItemsMap);
                } when 'Client_Offer_Additional_Service__c=>E2E_Data_Additional_Service__c' {
                    Map<String, Client_Offer_Additional_Service__c> finalClientOfferAdditionalServices = generateFinalClientOfferAdditionalServicesMap(
                                                        e2eDatabase,
                                                        opportunity.Id,
                                                        dataObject.Country_Code__c,
                                                        e2eDataAdditionalServicesMap,
                                                        clientOfferAdditionalServicesMap
                                                );
                    clientOfferAdditionalServicesToUpsertList = mapClientOfferAddServicesFieldsWithE2EDataAddServicesFields(finalClientOfferAdditionalServices,
                            e2eDataAdditionalServicesMap);
                }
                when 'Opportunity=>E2E_Data_Object__c' {
                    opportunity = mapOpportunityFieldsWithDataObjectFields(opportunity, dataObject);
                    opportunity = setExceptionParams(opportunity, dataObject, existingJobsMap.values());
                    if (actionName == 'syncPaymentDetails') {
                        if (dataObject.RecordType.Name != 'Switzerland-DE' && dataObject.RecordType.Name != 'Switzerland-FR') {
                            String docType = ETEGlobalUtils.returnSepaDocumentType(dataObject.RecordType.Name + '_' + dataObject.Direct_Debit_Mandate_Type__c);
                            if (docType != null) { attachPdfDocument(e2eDatabase, 'SEPAMandate.pdf', docType, opportunity.Id, dataObject); }
                        } else {
                            attachPdfDocument(e2eDatabase, 'Business Direct Debit Agreement.pdf', 'mandateAcceptance', opportunity.Id, dataObject);
                        }
                    } else if (actionName == 'syncCompanyDetails') {
                        doReportOrder(e2eDatabase, null, dataObject, opportunity);
                    } else if (actionName == 'syncPaymentData') {
                        attachPdfDocument(e2eDatabase, 'Deposit Agreement.pdf', 'depositAgreement', opportunity.Id, dataObject);
                    }  else if (actionName == 'syncDocumentsAgreements') {
                        if (dataObject.RecordType.Name == 'Poland') {
                            attachPdfDocument(e2eDatabase, 'Contract Agreement.pdf', 'ete_step_documents_contract', opportunity.Id, dataObject);
                        } else {
                            attachPdfDocument(e2eDatabase, 'Contract Agreement.pdf', 'documentsAgreement', opportunity.Id, dataObject);
                        }
                    } else if (actionName == 'syncContactData') {
                        E2E_Data_Contact__c primaryContact;
                        for (E2E_Data_Contact__c dataContact : existingETEdataContacts) {
                            if (dataContact.isPrimary__c == true) {
                                primaryContact = dataContact;
                                break;
                            }
                        }
                        if (!org.IsSandbox) {
                            sendFacebookEvent(dataObject.RecordType.Name, primaryContact.Email__c);
                        }
                    }
                }
                when 'Opportunity=>Credit_Factory_Report__c' {
                    if (creditFactoryCompany != null) {
                        opportunity = mapOpportunityFieldsWithCFReportFields(opportunity, creditFactoryCompany, additionalFieldsToUpdateFromCFReport);
                    }
                }
                when 'Account=>E2E_Data_Object__c' {
                    account = mapAccountFieldsWithDataObjectFields(account, dataObject);
                }
                when 'Account=>Credit_Factory_Report__c' {
                    if (creditFactoryCompany != null) {
                        account = mapAccountFieldsWithCFReportFields(account, dataObject, creditFactoryCompany, additionalFieldsToUpdateFromCFReport);
                    } else {
                        account.Name = dataObject.Selected_Company_Name__c;
                        account.Steuernummer__c = dataObject.Tax_ID__c;
                    }
                }
                when 'Contact=>E2E_Data_Contact__c' {
                    mapSFcontactFieldsWithETEcontactFields(existingETEdataContacts, sfContactsToSync, opptyContactRolesToSync);
                }
                when 'Contact=>Credit_Factory_Report__c' {
                    if (creditFactoryCompany != null) {
                        mapSFcontactFieldsWithCFreportFields(sfContactsToSync, creditFactoryCompany, additionalFieldsToUpdateFromCFReport);
                    }
                }
            }
        }
        List<Customer_Feedback__c> customerFeedbacksList = mapCustomerFeedbackFields(e2eDatabase, opportunity.Id, existingJobsMap.values());

        doSyncBusinessObjects(e2eDatabase,
                            product2IdToOpptyLineItemMap,
                            oliToInsert,
                            oliToDelete,
                            existingDataOfferItemsMap,
                            offerItemsToUpsertMap,
                            offerItemsToDeleteList,
                            clientOfferAdditionalServicesToUpsertList,
                            opportunity,
                            account,
                            sfContactsToSync,
                            opptyContactRolesToSync,
                            existingETEdataContacts,
                            customerFeedbacksList,
                            dataObject);
        String existingJobStatus = e2eDatabase.retrieveE2EDataLogByName(dataObject.Id, existingJobInDataBase.Name).get(0).Job_Status__c;
        if (existingJobStatus != 'Restart') {
            this.jobsNeededToRun.remove(0);
            existingJobInDataBase.Job_Status__c = 'Completed';
            e2eDatabase.upsertE2EDataLogs(new List<E2E_Data_Log__c>{existingJobInDataBase});
        }
        // run next job
        if (! Test.isRunningTest()) {
            ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(this.jobsNeededToRun,
                                                                        this.dataObjectId,
                                                                        this.countryCode,
                                                                        dataObject.RecordType.Name);
            jobChainHandler.runNext();
        }
    }


    public virtual Quote mapQuoteFields(ETEDatabaseInterface e2eDatabase, Quote quote, Opportunity oppty) {
        Account account = e2eDatabase.retrieveAccount(oppty.AccountId);
        Map<String, OpportunityContactRole> primaryOCRmap = e2eDatabase.retrievePrimaryOpportunityContactRole(oppty.Id);
        List<Contact> primaryContact = e2eDatabase.retrieveContacts(primaryOCRmap.keySet());
        if (account != null) {
            quote.BillingName = account.Name;
            quote.BillingStreet = account.BillingStreet;
            quote.BillingPostalCode = account.BillingPostalCode;
            quote.BillingCity = account.BillingCity;
            quote.BillingCountry = account.BillingCountry;
            quote.ShippingName = account.Name;
            quote.ShippingCountry = account.ShippingCountry;
            quote.ShippingStreet = account.ShippingStreet;
            quote.ShippingPostalCode = account.ShippingPostalCode;
            quote.ShippingCity = account.ShippingCity;
        }
        quote.ContactId = primaryContact[0].Id;
        quote.Phone = primaryContact[0].Phone;
        quote.Email = primaryContact[0].Email;
        return quote;
    }


    public virtual Map<String, Offer_Item__c> mapOpptyOfferItemsFieldsWithDataOfferItemsFields(E2E_Data_Object__c dataObject,
                                                                                                Opportunity opportunity,
                                                                                                Map<String, E2E_Data_Product__c> eteProductsByParentIdMap,
                                                                                                Map<String, Map<String, Offer_Item__c>> finalBusinessOfferItems,
                                                                                                Map<String, List<E2E_Data_Offer_Item__c>> dataOfferItemsMap) {
        Map<String, Offer_Item__c> offerItemsToUpsertMap = new Map<String, Offer_Item__c>();
        Decimal numberOfCars = 0;
        Decimal numberOfTrucks = 0;
        List<E2E_Data_Offer_Item__c> allE2EOfferItemsList = new List<E2E_Data_Offer_Item__c>();
        for (String offerId : dataOfferItemsMap.keySet()) {
            for (E2E_Data_Offer_Item__c dataOfferItem : dataOfferItemsMap.get(offerId)) {
                Offer_Item__c opptyOfferItem = finalBusinessOfferItems.get(offerId).get(dataOfferItem.Id);
                opptyOfferItem.Category_of_products__c = dataOfferItem.Category_Of_Products__c;
                opptyOfferItem.Company_Name__c = dataOfferItem.Company_Name__c;
                opptyOfferItem.Driver_Name__c = dataOfferItem.Driver_Name__c;
                opptyOfferItem.License_plate_number__c = dataOfferItem.License_Plate_Number__c;
                opptyOfferItem.Mileage_data__c = dataOfferItem.Mileage_Data__c;
                opptyOfferItem.Offer_Item_Type__c = eteProductsByParentIdMap.get(offerId).Type_ID__c;
                opptyOfferItem.Type_of_Card__c = dataOfferItem.Type_Of_Card__c;
                opptyOfferItem.Type_of_Vehicle__c = dataOfferItem.Type_Of_Vehicle__c;
                opptyOfferItem.Fuel_card_consumption_monthly__c = dataOfferItem.Monthly_Fuel_Consumption__c;
                opptyOfferItem.Daily_card_limit_value__c = dataOfferItem.Daily_Card_Limit__c;
                opptyOfferItem.Monthly_card_limit_value__c = dataOfferItem.Monthly_Card_Limit__c;
                opptyOfferItem.Activate_EV_Charging__c = dataOfferItem.Activate_EV_Charging__c;
                opptyOfferItem.Locked_Pin_Change__c = dataOfferItem.Locked_Pin_Change__c;
                offerItemsToUpsertMap.put(dataOfferItem.Id, opptyOfferItem);
                if (dataOfferItem.Type_Of_Vehicle__c == 'PKW') {
                    numberOfCars++;
                } else if (dataOfferItem.Type_Of_Vehicle__c == 'LKW') {
                    numberOfTrucks++;
                }
                allE2EOfferItemsList.add(dataOfferItem);
            }
        }
        ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(dataObject.RecordType.Name);
        Map<String, Object> consumptionDataMap = e2eStep.doCalculateConsumption(dataObject, new Map<String, E2E_Data_Product__c>(eteProductsByParentIdMap.values()), allE2EOfferItemsList);
        opportunity.put('Total_consumption_l_month__c', consumptionDataMap.get('totalConsumption'));
        opportunity.put('Suggested_Total_Consumption__c', consumptionDataMap.get('totalConsumption'));
        opportunity.put('Diesel_consumption_l_month__c', consumptionDataMap.get('totalConsumption'));
        opportunity.put('Gasoline_consumption_l_month__c', 0);
        opportunity.put('Derzeitige_Zahlungsmethode__c', 'Barzahlung');
        opportunity.put('Non_fuel_exposure__c', consumptionDataMap.get('nonFuelExposure'));
        opportunity.put('Number_of_cars__c', numberOfCars);
        opportunity.put('Number_of_trucks__c', numberOfTrucks);
        opportunity.put('Total_number_of_vehicles__c', numberOfCars + numberOfTrucks);
        return offerItemsToUpsertMap;
    }


    public virtual void mapOpportunityFieldsWithLocatorItemsFields(Opportunity opportunity,
                                                    Map<String, E2E_Data_Locator_Item__c> existingE2ELocatorItemsMap) {
        opportunity.Home_Station__c = '';
        for (E2E_Data_Locator_Item__c dataLocatorItem : existingE2ELocatorItemsMap.values()) {
            opportunity.Home_Station__c += dataLocatorItem.Name + '; ';
        }
    }


    public virtual List<Client_Offer_Additional_Service__c> mapClientOfferAddServicesFieldsWithE2EDataAddServicesFields(Map<String, Client_Offer_Additional_Service__c> finalClientOfferAdditionalServices,
                                                    Map<String, E2E_Data_Additional_Service__c> e2eDataAdditionalServicesMap) {
        List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesToUpsertList = new List<Client_Offer_Additional_Service__c>();
        for (String integrationName : e2eDataAdditionalServicesMap.keySet()) {
            E2E_Data_Additional_Service__c e2eDataAdditionalService = e2eDataAdditionalServicesMap.get(integrationName);
            Client_Offer_Additional_Service__c clientOfferAdditionalService = finalClientOfferAdditionalServices.get(integrationName);
            clientOfferAdditionalService.Selected__c = e2eDataAdditionalService.Selected__c;
            clientOfferAdditionalServicesToUpsertList.add(clientOfferAdditionalService);
        }
        return clientOfferAdditionalServicesToUpsertList;
    }


    public virtual Account mapAccountFieldsWithCFReportFields(Account account,
                                                            E2E_Data_Object__c dataObject,
                                                            CreditFactoryCompany creditFactoryCompany,
                                                            Map<String, Object> additionalFieldsToUpdateFromCFReport) {
        String cityUpper = ! String.isEmpty(creditFactoryCompany.city) ? creditFactoryCompany.city.toUpperCase() + '_BEST' :
                            ! String.isEmpty(creditFactoryCompany.registeredCity) ? creditFactoryCompany.registeredCity.toUpperCase() + '_REGS' :
                            ! String.isEmpty(creditFactoryCompany.postalCity) ? creditFactoryCompany.postalCity.toUpperCase() + '_POST' : null;
        String addressType;
        if (cityUpper != null) {
            addressType = '_' + cityUpper.substringAfter('_');
            cityUpper = cityUpper.removeEnd(addressType);
            cityUpper = cityUpper.contains('-') ? cityUpper.substringBefore('-') : cityUpper;
            cityUpper = cityUpper.length() > 40 ? cityUpper.substring(0,40) : cityUpper;
        }
        String streetUpper = ! String.isEmpty(creditFactoryCompany.street) && addressType == '_BEST' ? creditFactoryCompany.street.toUpperCase() :
                            ! String.isEmpty(creditFactoryCompany.registeredStreet) && addressType == '_REGS' ? creditFactoryCompany.registeredStreet.toUpperCase() :
                            ! String.isEmpty(creditFactoryCompany.postalStreet) && addressType == '_POST' ? creditFactoryCompany.postalStreet.toUpperCase() : '';

        String housenumberUpper = ! String.isEmpty(creditFactoryCompany.houseNumber) && addressType == '_BEST' ? creditFactoryCompany.houseNumber.toUpperCase() :
                            ! String.isEmpty(creditFactoryCompany.registeredHouseNumber) && addressType == '_REGS' ? creditFactoryCompany.registeredHouseNumber.toUpperCase() :
                            ! String.isEmpty(creditFactoryCompany.postalHouseNumber) && addressType == '_POST' ? creditFactoryCompany.postalHouseNumber.toUpperCase() : '';

        String postalCode = ! String.isEmpty(creditFactoryCompany.postCode) && addressType == '_BEST' ? creditFactoryCompany.postCode :
                            ! String.isEmpty(creditFactoryCompany.registeredPostCode) && addressType == '_REGS' ? creditFactoryCompany.registeredPostCode :
                            ! String.isEmpty(creditFactoryCompany.postalPostCode) && addressType == '_POST' ? creditFactoryCompany.postalPostCode : '';

        String companyName = creditFactoryCompany.name;
        if (companyName.length() > 120) {
            companyName = companyName.substring(0, 117) + '...';
        }
        String country = ETEGlobalUtils.returnCountry(dataObject.Country_Code__c);
        account.Name = companyName;
        account.BillingStreet = streetUpper + ' ' + housenumberUpper;
        account.BillingPostalCode = postalCode;
        account.BillingCity = cityUpper;
        account.BillingCountry = country;
        account.ShippingCountry = country;
        account.ShippingStreet = streetUpper + ' ' + housenumberUpper;
        account.ShippingPostalCode = postalCode;
        account.ShippingCity = cityUpper;
        account.Gesellschaftsform__c = creditFactoryCompany.legalForm;
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = creditFactoryCompany.tradeRegisterNumber;
        account.Ort_der_Registrierung_Handelsregisterort__c = creditFactoryCompany.countyCourt;
        account.Steuernummer__c = creditFactoryCompany.taxId;
        account.Umsatzsteuer_ID__c = creditFactoryCompany.vatNumber;

        if (additionalFieldsToUpdateFromCFReport.containsKey('Account')) {
            Map<String, Object> fieldsMap = (Map<String, Object>) additionalFieldsToUpdateFromCFReport.get('Account');
            for (String accountFieldApiName : fieldsMap.keySet()) {
                account.put(accountFieldApiName, fieldsMap.get(accountFieldApiName));
            }
        }
        return account;
    }


    public virtual Account mapAccountFieldsWithDataObjectFields(Account account,
                                                                E2E_Data_Object__c dataObject) {
        String country = ETEGlobalUtils.returnCountry(dataObject.Country_Code__c);
        account.Name = dataObject.Selected_Company_Name__c;
        String street = ! String.isEmpty(dataObject.Registered_Street__c) ? dataObject.Registered_Street__c.toUpperCase() : '';
        String postalCode = ! String.isEmpty(dataObject.Registered_Postal_Code__c) ? dataObject.Registered_Postal_Code__c : '';
        String city = ! String.isEmpty(dataObject.Registered_City__c) ? dataObject.Registered_City__c.toUpperCase() : '';
        account.BillingCountry = country;
        account.BillingStreet = street;
        account.BillingPostalCode = postalCode;
        account.BillingCity = city;
        account.ShippingCountry = country;
        account.ShippingStreet = street;
        account.ShippingPostalCode = postalCode;
        account.ShippingCity = city;
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = dataObject.Trade_Register_Number__c;
        account.Steuernummer__c = dataObject.Tax_ID__c;
        account.Umsatzsteuer_ID__c = dataObject.Vat_ID__c;
        return account;
    }


    public virtual Opportunity mapOpportunityFieldsWithDataObjectFields(Opportunity opportunity, E2E_Data_Object__c dataObject) {
        // products and services
        opportunity.Client_Id__c = dataObject.Client_Id__c;
        if (opportunity.ESI__c != dataObject.ESI__c) {
            opportunity.ESI__c = dataObject.ESI__c;
            opportunity.Home_Station__c = dataObject.Home_Station__c;
        }
        // contacts details
        opportunity.Name = dataObject.Selected_Company_Name__c;
        opportunity.Primary_Contact_Phone__c = dataObject.Phone__c;
        opportunity.Agree_to_Privacy_Policy__c = dataObject.Agreement_Privacy_Policy__c;
        opportunity.Agree_to_process_pers_data_for_marketing__c = dataObject.Agree_to_process_pers_data_for_marketing__c;
        opportunity.Agree_to_telephone_contact__c = dataObject.Agreement_To_Phone_Contact__c;
        opportunity.Agree_to_receive_comm_info_by_email__c = dataObject.Agreement_To_Receive_Info_By_Email__c;
        // documents / payment details
        if (opportunity.AGB_Datenschutzhinweise_Richtigkeit__c != dataObject.Terms_And_Conditions_Agreement__c) {
            opportunity.AGB_Datenschutzhinweise_Richtigkeit__c = dataObject.Terms_And_Conditions_Agreement__c;
            opportunity.Date_of_Acceptance_TC__c = Datetime.now();
        }
        opportunity.Bank_Account_Prefix__c = dataObject.Bank_Account_Prefix__c;
        opportunity.Bank_Account_Number__c = dataObject.Bank_Account_Number__c;
        if (opportunity.Bank_Name__c != dataObject.Bank_Name__c ||
            opportunity.Bank_Code__c != dataObject.Bank_Code__c) {
            opportunity.Bank_Code__c = dataObject.Bank_Code__c;
            opportunity.Bank_Name__c = dataObject.Bank_Name__c;
            opportunity.Bank_Country__c = ETEGlobalUtils.returnCountry(dataObject.Country_Code__c);
        }
        opportunity.Name_of_the_payer_Account_holder__c = dataObject.Account_Holder__c;
        opportunity.IBAN__c = dataObject.IBAN__c;
        opportunity.SWIFT_BIC__c = dataObject.SWIFT__c;
        if (opportunity.Einwilligung_Lastschriftverfahren__c != dataObject.Accept_Sepa__c) {
            opportunity.Einwilligung_Lastschriftverfahren__c = dataObject.Accept_Sepa__c;
            opportunity.Send_SEPA_approval_link__c = dataObject.Accept_Sepa__c;
            opportunity.SEPA_Request_Approved__c = dataObject.Accept_Sepa__c;
            opportunity.SEPA_Request_Approval_Date__c = Datetime.now();
        }
        // pay_deposit
        if (opportunity.Agree_To_Deposit_Agreement__c != dataObject.Deposit_Agreement__c) {
            opportunity.Agree_To_Deposit_Agreement__c = dataObject.Deposit_Agreement__c;
            if (opportunity.Agree_To_Deposit_Agreement__c == true) {
                opportunity.Date_For_Agree_To_Deposit_Agreement__c = Datetime.now();
            } else {
                opportunity.Date_For_Agree_To_Deposit_Agreement__c = null;
            }
        }

        // credit line
        String paymentMethod;
        if (dataObject.Payment_Method__c == 'Direct Debit') {
            paymentMethod = 'Lastschrift';
        } else if (dataObject.Payment_Method__c == 'Bank Transfer') {
            paymentMethod = 'Banküberweisung';
        }
        if (opportunity.CF_Credit_Limit__c != dataObject.Credit_Limit__c || opportunity.Zahlungsart__c != paymentMethod ||
            opportunity.Rechnungsperiode__c != dataObject.Billing_Period__c || opportunity.Zahlungsziel_Credit__c != dataObject.Payment_Terms__c ||
            opportunity.Max_Credit_Limit__c != dataObject.Max_Credit_Limit__c || opportunity.Credit_System_Rating__c != dataObject.Credit_System_Rating__c ||
            opportunity.Risk_Category__c != dataObject.Risk_Category__c) {
            opportunity.CF_Credit_Limit__c = dataObject.Credit_Limit__c;
            opportunity.Zahlungsart__c = paymentMethod;
            opportunity.Rechnungsperiode__c = dataObject.Billing_Period__c;
            opportunity.Zahlungsziel_Credit__c = dataObject.Payment_Terms__c;
            opportunity.Max_Credit_Limit__c = dataObject.Max_Credit_Limit__c;
            opportunity.Security_level_H_he_der_Sicherheit__c = dataObject.Security_Level__c;
            opportunity.Credit_System_Rating__c = dataObject.Credit_System_Rating__c;
            opportunity.Risk_Category__c = dataObject.Risk_Category__c;
            opportunity.StageName = dataObject.StageName__c;
            opportunity.E2E_Status__c = dataObject.E2E_Status__c;
            opportunity.E2E_Sub_Status__c = '';
            opportunity.Deposit_reason__c = dataObject.Deposit_Reason__c;
            if (dataObject.Credit_Limit__c != null) {
                opportunity.Credit_check_date__c = Date.today();
                opportunity.bearbeitet_von__c = 'Autoprocessed by E2E';
            } else {
                opportunity.Credit_check_date__c = null;
                opportunity.bearbeitet_von__c = null;
            }
            if (dataObject.Security_Amount_To_Pay__c != 0 && dataObject.Security_Amount_To_Pay__c != null) {
                opportunity.Security_Amount_To_Pay__c = dataObject.Security_Amount_To_Pay__c;
                opportunity.CF_Stage__c = 'Pending deposit';
                opportunity.E2E_payment_status__c = null;
                opportunity.Security_To_Pay__c = 'Kaution';
                opportunity.Kredit_Entscheidung__c = 'Sicherheit verlangt';
                opportunity.Billing_Period_by_Sales__c = true;
                opportunity.Pending_Deposit_by_CF__c = true;
            } else {
                opportunity.Security_Amount_To_Pay__c = null;
                opportunity.CF_Stage__c = 'Report generated';
                opportunity.E2E_payment_status__c = 'NO DEPOSIT';
                opportunity.Security_To_Pay__c = '';
                opportunity.Kredit_Entscheidung__c = 'Genehmigt';
                opportunity.Billing_Period_by_Sales__c = false;
                opportunity.Pending_Deposit_by_CF__c = false;
            }
        }
        // other
        if (opportunity.Direct_Debit_Mandate_Type__c != dataObject.Direct_Debit_Mandate_Type__c) {
            opportunity.Direct_Debit_Mandate_Type__c = dataObject.Direct_Debit_Mandate_Type__c;
        }
        opportunity.Device_Type__c = dataObject.Device_Type__c;
        opportunity.Language_preference__c = ETEGlobalUtils.returnLanguagePreference(dataObject.Current_Language__c);
        opportunity.E2E_Encoded_URL__c = ETEGlobalUtils.doEncryptParams(dataObject.Id, dataObject.Country_Code__c);
        opportunity.Visitor_ID__c = dataObject.Customer_IP_Address__c;
        opportunity.E2E_Last_Activity__c = dataObject.E2E_Last_Activity__c;
        opportunity.E2E_Step__c = dataObject.Current_Step__c;
        opportunity.Utm_campaign__c = dataObject.Utm_Campaign__c;
        opportunity.Utm_content__c = dataObject.Utm_Content__c;
        opportunity.Utm_medium__c = dataObject.Utm_Medium__c;
        opportunity.Utm_placement__c = dataObject.Utm_Placement__c;
        opportunity.Utm_source__c = dataObject.Utm_Source__c;
        opportunity.Utm_term__c = dataObject.Utm_Term__c;
        opportunity.Utm_url__c = dataObject.Utm_Url__c;
        if (dataObject.Utm_Campaign__c != null && dataObject.Utm_Campaign__c.containsIgnoreCase('monevia')) {
            if (opportunity.Retailer_OBN__c == null) {
                List<Account> moneviaAccountList = [SELECT Id FROM Account WHERE Id = '0013Y00002bKAIqQAO' LIMIT 1];
                opportunity.LeadSource = 'Partner';
                opportunity.Retailer_OBN__c = 'BP005';
                if (! moneviaAccountList.isEmpty()) { opportunity.Retailer_Name__c = moneviaAccountList.get(0).Id; }
            }
        }
        opportunity.E2E_Errors__c = null;

        // stop process
        if (dataObject.E2E_Status__c == 'Finished') {
            opportunity.StageName = dataObject.StageName__c;
            opportunity.E2E_Status__c = dataObject.E2E_Status__c;
            opportunity.E2E_Finish_Details__c = dataObject.E2E_Finish_Details__c;
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(ETEGlobalUtils.returnCountry(dataObject.Country_Code__c));
            if (dataObject.StageName__c == 'Closed Won') {
                opportunity.CloseDate = Date.today();
                opportunity.E2E_Step__c = 'Congratulations';
                if (settings.Enable_authorization_non_granted_check__c) {
                    opportunity.Starts_Status__c = '0. Request received';
                }
            } else if (dataObject.StageName__c == 'Closed Lost') {
                opportunity.Kredit_Entscheidung__c = 'Abgelehnt';
            } else {
                if (settings != null && settings.Abandonment_User__c != null &&
                    dataObject.E2E_Finish_Details__c != 'Report Ordering') {
                    opportunity.OwnerId = settings.Abandonment_User__c;
                }
            }
            if (dataObject.Payment_Status__c == 'COMPLETED') {
                opportunity.E2E_payment_status__c = 'ACCEPT';
                opportunity.Garantie_other__c = opportunity.Security_Amount_To_Pay__c;
                opportunity.Garantie__c = opportunity.Security_To_Pay__c;
                opportunity.E2E_Step__c = 'Congratulations';
                if (dataObject.Security_Amount_To_Pay__c > 0) {
                    opportunity.Kredit_Entscheidung__c = 'Genehmigt, Sicherheit geliefert';
                }
            } else if (dataObject.Payment_Status__c != null) {
                opportunity.E2E_payment_status__c = dataObject.Payment_Status__c;
            }
            if (dataObject.E2E_Finish_Details__c == 'Awaiting Payment' &&
                dataObject.Payment_Status__c == null) {
                opportunity.E2E_payment_status__c = 'PAYMENT GATEWAY OFF';
            }
        }
        return opportunity;
    }


    public virtual Opportunity setExceptionParams(Opportunity opportunity,
                                                    E2E_Data_Object__c dataObject,
                                                    List<E2E_Data_Log__c> existingJobsList) {
        for (E2E_Data_Log__c dataLog : existingJobsList) {
            if (dataLog.Exception_Type__c != null) {
                opportunity.E2E_Errors__c = dataLog.Exception_Type__c;
                TimeZone tz = UserInfo.getTimeZone();
                DateTime dt = Datetime.now();
                Datetime errorDt = dt.addSeconds((tz.getOffset(dt)/1000));
                if (! String.isEmpty(opportunity.E2E_System_Error_Description__c)) {
                    if (! opportunity.E2E_System_Error_Description__c.contains(dataLog.Exception_Description__c)) {
                        opportunity.E2E_System_Error_Description__c += ';' + '\n' + errorDt + ': ' + dataLog.Exception_Description__c;
                    }
                } else {
                    opportunity.E2E_System_Error_Description__c = errorDt + ': ' + dataLog.Exception_Description__c;
                }
                if (dataLog.Exception_Description__c == 'Company is not in the list') {
                    String searchParam;
                    if (dataObject.Tax_ID__c != null) {
                        searchParam = 'input tax id: ' + dataObject.Tax_ID__c;
                    } else if (dataObject.Vat_ID__c != null) {
                        searchParam = 'input vat id: ' + dataObject.Vat_ID__c;
                    } else {
                        searchParam = 'input company name: ' + dataObject.Selected_Company_Name__c;
                    }
                    if (opportunity.CF_Search_Parameters__c != null && opportunity.CF_Search_Parameters__c != '') {
                        if (! opportunity.CF_Search_Parameters__c.contains(searchParam)) {
                            opportunity.CF_Search_Parameters__c += ';' + '\n' + errorDt + ': ' + searchParam;
                        }
                    } else {
                        opportunity.CF_Search_Parameters__c = errorDt + ': ' + searchParam;
                    }
                }
            }
        }
        return opportunity;
    }


    public virtual void attachPdfDocument(ETEDatabaseInterface e2eDatabase,
                                            String fileName,
                                            String docType,
                                            String opptyId,
                                            E2E_Data_Object__c dataObject) {
        String baseUrl = ETEGlobalUtils.returnSiteUrl(this.countryCode);
        String docUrl;
        if (dataObject.RecordType.Name != 'Poland') {
            docUrl = baseUrl + '/apex/etedocuments?' +
                    'doc=' + docType + '&countryCode=' + this.countryCode +
                    '&language=' + dataObject.Current_Language__c + '&source=' + ETEGlobalUtils.doEncryptParams(dataObject.Id, this.countryCode) +
                    '&implKey=' + dataObject.RecordType.Name;
        } else {
            docUrl = baseUrl + '/apex/etepdfview?' +
                    'target=' + docType + '&impl=' + dataObject.RecordType.Name +
                    '&country_code=' + dataObject.Country_Code__c +
                    '&source=' + ETEGlobalUtils.doEncryptParams(dataObject.Id, this.countryCode);
        }
        if (fileName == 'SEPAMandate.pdf') {
            docUrl += '&iban=' +  dataObject.IBAN__c + '&swift=' + dataObject.SWIFT__c + '&accountHolder=' + dataObject.Account_Holder__c;
        }
        PageReference sepaMandatePage = new PageReference(docUrl);
        Blob pdfContent;
        if (Test.IsRunningTest()) {
            pdfContent = Blob.valueOf('test');
        } else {
            pdfContent = sepaMandatePage.getContentAsPDF();
        }
        List<Attachment> attachmentCheck = e2eDatabase.retrieveAttchments(new Set<String>{fileName}, opptyId);
        if ( ! attachmentCheck.isEmpty() ) { e2eDatabase.deleteAttchments(attachmentCheck); }
        Attachment attachment = new Attachment(ParentId = opptyId, Body = pdfContent, Name = fileName);
        insert attachment;
    }


    public virtual Opportunity mapOpportunityFieldsWithCFReportFields(Opportunity opportunity,
            CreditFactoryCompany creditFactoryCompany,
            Map<String, Object> additionalFieldsToUpdateFromCFReport) {
        if (additionalFieldsToUpdateFromCFReport.containsKey('Opportunity')) {
            Map<String, Object> fieldsMap = (Map<String, Object>) additionalFieldsToUpdateFromCFReport.get('Opportunity');
            for (String opptyFieldApiName : fieldsMap.keySet()) {
                opportunity.put(opptyFieldApiName, fieldsMap.get(opptyFieldApiName));
            }
        }
        String companyName = creditFactoryCompany.name;
        if (companyName.length() > 120) {
            companyName = companyName.substring(0, 117) + '...';
        }
        opportunity.Name = companyName;
        if (creditFactoryCompany.staffCompanyRange != null) {
            opportunity.Zahl_der_Mitarbeiter__c = creditFactoryCompany.staffCompanyRange;
        } else {
            opportunity.Zahl_der_Mitarbeiter__c = String.valueOf(creditFactoryCompany.creditFactoryContacts.size());
        }
        return opportunity;
    }


    public virtual void mapSFcontactFieldsWithETEcontactFields(List<E2E_Data_Contact__c> existingETEdataContacts,
                                                                Map<String, Contact> sfContactsToSync,
                                                                Map<String, OpportunityContactRole> opptyContactRolesToSync) {
        for (E2E_Data_Contact__c eteDataContact : existingETEdataContacts) {
            Contact contact = sfContactsToSync.get(eteDataContact.Id);
            contact.Salutation = eteDataContact.Salutation__c;
            contact.FirstName = eteDataContact.First_Name__c;
            contact.LastName = eteDataContact.Last_Name__c;
            contact.Phone = eteDataContact.Phone__c;
            contact.Email = eteDataContact.Email__c;
            Date birthdateFromUserModel;
            if (! String.isEmpty(eteDataContact.Birthdate__c)) {
                List<String> birthdateDetails = (eteDataContact.Birthdate__c).split('\\.');
                birthdateFromUserModel = Date.newInstance(Integer.valueOf(birthdateDetails.get(2)),
                        Integer.valueOf(birthdateDetails.get(1)),
                        Integer.valueOf(birthdateDetails.get(0)));
            }
            contact.Birthdate = ETEGlobalUtils.convertStringToDate(eteDataContact.Birthdate__c);
            opptyContactRolesToSync.get(eteDataContact.Id).IsPrimary = eteDataContact.isPrimary__c;
            contact.Authorised_signatory__c = false;
            if (eteDataContact.Role__c == 'Authorised signatory') {
                contact.Authorised_signatory__c = true;
            }
        }
    }


    public virtual void mapSFcontactFieldsWithCFreportFields(Map<String, Contact> sfContactsToSync,
                                                            CreditFactoryCompany creditFactoryCompany,
                                                            Map<String, Object> additionalFieldsToUpdateFromCFReport) {
        String streetUpper = creditFactoryCompany.street != null ? creditFactoryCompany.street.toUpperCase() : '';
        String housenumberUpper = creditFactoryCompany.houseNumber != null ? creditFactoryCompany.houseNumber.toUpperCase() : '';
        String cityUpper = creditFactoryCompany.city != null ? creditFactoryCompany.city.toUpperCase() : '';
        cityUpper = cityUpper.contains('-') ? cityUpper.substringBefore('-') : cityUpper;
        cityUpper = cityUpper.length() > 40 ? cityUpper.substring(0,40) : cityUpper;
        for (Contact contact : sfContactsToSync.values()) {
            contact.MailingStreet = streetUpper + ' ' + housenumberUpper;
            contact.MailingPostalCode = creditFactoryCompany.postCode;
            contact.MailingCity = cityUpper;
            contact.MailingCountry = creditFactoryCompany.country;
            if (additionalFieldsToUpdateFromCFReport.containsKey('Contact')) {
                Map<String, Object> fieldsMap = (Map<String, Object>) additionalFieldsToUpdateFromCFReport.get('Contact');
                for (String contactFieldApiName : fieldsMap.keySet()) {
                    contact.put(contactFieldApiName, fieldsMap.get(contactFieldApiName));
                }
            }
        }
    }


    public virtual List<Customer_Feedback__c> mapCustomerFeedbackFields(ETEDatabaseInterface e2eDatabase, String opptyId, List<E2E_Data_Log__c> existingLogsList) {
        List<E2E_Data_Log__c> existingE2EDataFeedbacksList = new List<E2E_Data_Log__c>();
        for (E2E_Data_Log__c dataLog : existingLogsList) {
            if (dataLog.RecordType.Name == 'Customer Feedback') {
                existingE2EDataFeedbacksList.add(dataLog);
            }
        }
        Map<String, Customer_Feedback__c> existingCustomerFeedbackMap = new Map<String, Customer_Feedback__c>();
        for (Customer_Feedback__c customerFeedback : e2eDatabase.retrieveCustomerFeedbacks(opptyId)) {
            existingCustomerFeedbackMap.put(customerFeedback.E2E_Data_Log__c, customerFeedback);
        }
        List<Customer_Feedback__c> customerFeedbacksToInsert = new List<Customer_Feedback__c>();
        if (existingE2EDataFeedbacksList.size() != existingCustomerFeedbackMap.size()) {
            String recordTypeId = Schema.SObjectType.Customer_Feedback__c.getRecordTypeInfosByName().get('E2E Feedback').getRecordTypeId();
            for (E2E_Data_Log__c e2eDataFeedback : existingE2EDataFeedbacksList) {
                if (! existingCustomerFeedbackMap.containsKey(e2eDataFeedback.Id)) {
                    customerFeedbacksToInsert.add(
                        new Customer_Feedback__c(
                            RecordTypeId = recordTypeId,
                            E2E_Data_Log__c = e2eDataFeedback.Id,
                            Opportunity__c = opptyId,
                            E2E_Step__c = e2eDataFeedback.E2E_Step__c,
                            Form_Identification__c = e2eDataFeedback.Form_Identification__c,
                            Rating__c = e2eDataFeedback.Rating__c,
                            Feedback_Local__c = e2eDataFeedback.Feedback_Local__c,
                            Feedback_English__c = e2eDataFeedback.Feedback_English__c
                        )
                    );
                }
            }
        }
        return customerFeedbacksToInsert;
    }


    private static void createQuotePDF(ETEDatabaseInterface e2eDatabase, String opptyId, String countryCode) {
        List<Quote> existingQuotesList = e2eDatabase.retrieveQuotes(opptyId);
        if (! existingQuotesList.isEmpty()) {
            String siteUrl = ETEGlobalUtils.returnSiteUrl(countryCode);
            String quoteID = existingQuotesList[0].Id;
            PageReference pg = new PageReference(siteUrl + '/CreateQuotePDF?id=' + quoteID);
            Blob blb;
            if (! Test.isRunningTest()) {
                blb = pg.getContent();
            } else {
                blb = Blob.valueOf('Unit.Test');
            }
            Attachment attachmentPDF = new Attachment();
            attachmentPdf.ParentId = opptyId;
            attachmentPdf.Name = 'Carnet_podsumowanie_zamowienia_' + String.valueOf(System.now()) + '.pdf';
            attachmentPdf.Body = blb;
            insert attachmentPdf;
        }
    }


    private Map<String, E2E_Data_Product__c> getE2EDataProducts(ETEDatabaseInterface e2eDatabase, String dataObjectId) {
        Map<String, E2E_Data_Product__c> e2eProductsByParentIdMap = new Map<String, E2E_Data_Product__c>();
        for (E2E_Data_Product__c e2eProduct : e2eDatabase.retrieveETEProducts(dataObjectId).values()) {
            e2eProductsByParentIdMap.put(e2eProduct.ProductID__c, e2eProduct);
        }
        return e2eProductsByParentIdMap;
    }


    private Map<String, List<E2E_Data_Offer_Item__c>> getE2EDataOfferItems(ETEDatabaseInterface e2eDatabase,
                                                                        Map<String, E2E_Data_Product__c> eteProductsByParentIdMap) {
        Map<String, E2E_Data_Product__c> eteProductsByIdMap = new Map<String, E2E_Data_Product__c>(eteProductsByParentIdMap.values());
        Map<String, List<E2E_Data_Offer_Item__c>> e2eDataOfferItemsByProduct2IdMap = new Map<String, List<E2E_Data_Offer_Item__c>>();
        for (E2E_Data_Offer_Item__c e2eOfferItem : e2eDatabase.retrieveETEOfferItems(eteProductsByIdMap.keySet()).values()) {
            String product2Id = eteProductsByIdMap.get(e2eOfferItem.E2E_Data_Product__c).ProductID__c;
            if (! e2eDataOfferItemsByProduct2IdMap.containsKey(product2Id)) {
                e2eDataOfferItemsByProduct2IdMap.put(product2Id, new List<E2E_Data_Offer_Item__c>());
            }
            e2eDataOfferItemsByProduct2IdMap.get(product2Id).add(e2eOfferItem);
        }
        return e2eDataOfferItemsByProduct2IdMap;
    }


    private Map<String, OpportunityLineItem> getExistingOpptyLineItems(ETEDatabaseInterface e2eDatabase, String opptyId) {
        List<OpportunityLineItem> opptyLineItems = e2eDatabase.retrieveOpptyLineItemsByParentId(opptyId);
        Map<String, OpportunityLineItem> product2IdToOpptyLineItemMap = new Map<String, OpportunityLineItem>();
        for (OpportunityLineItem opptyLineItem : opptyLineItems) {
            product2IdToOpptyLineItemMap.put(opptyLineItem.Product2Id, opptyLineItem);
        }
        return product2IdToOpptyLineItemMap;
    }


    private Map<String, Map<String, Offer_Item__c>> getExistingBusinessOfferItems(ETEDatabaseInterface e2eDatabase,
                                                                                Map<String, OpportunityLineItem> product2IdToOpptyLineItemMap) {
        Map<String, Map<String, Offer_Item__c>> existingBusinessOfferItemsMap = new Map<String, Map<String, Offer_Item__c>>();
        if (product2IdToOpptyLineItemMap != null) {
            Map<String, String> opptyLineItemIdToProduct2IdMap = new Map<String, String>();
            for (String productId : product2IdToOpptyLineItemMap.keySet()) {
                opptyLineItemIdToProduct2IdMap.put(product2IdToOpptyLineItemMap.get(productId).Id, productId);
            }
            List<Offer_Item__c> businessOfferItemsList = e2eDatabase.retrieveBusinessOfferItems(opptyLineItemIdToProduct2IdMap.keySet());
            for (Offer_Item__c offerItem : businessOfferItemsList) {
                String product2Id = opptyLineItemIdToProduct2IdMap.get(offerItem.Opportunity_Product_Id__c);
                if (! existingBusinessOfferItemsMap.containsKey(product2Id)) {
                    existingBusinessOfferItemsMap.put(product2Id, new Map<String, Offer_Item__c>());
                }
                existingBusinessOfferItemsMap.get(product2Id).put(offerItem.Id, offerItem);
            }
        }
        return existingBusinessOfferItemsMap;
    }


    private void generateFinalOpportunityLineItems(String opptyId,
                                                    Map<String, E2E_Data_Product__c> eteProductsByParentIdMap,
                                                    Map<String, PricebookEntry> pricebookEntriesMap,
                                                    Map<String, List<E2E_Data_Offer_Item__c>> existingDataOfferItemsMap,
                                                    Map<String, OpportunityLineItem> product2IdToOpptyLineItemMap,
                                                    Map<String, OpportunityLineItem> oliToInsert,
                                                    List<OpportunityLineItem> oliToDelete) {
        for (String product2Id : eteProductsByParentIdMap.keySet()) {
            if (! product2IdToOpptyLineItemMap.containsKey(product2Id)) {
                if (! pricebookEntriesMap.containsKey(product2Id)) {
                    throw new LongFormException('there are no active price books');
                } else {
                    oliToInsert.put(product2Id,
                        new OpportunityLineItem(
                                OpportunityId = opptyId,
                                PricebookEntryId = pricebookEntriesMap.get(product2Id).Id,
                                Product2Id = product2Id,
                                Quantity = existingDataOfferItemsMap.get(product2Id).size(),
                                UnitPrice = pricebookEntriesMap.get(product2Id).UnitPrice)
                    );
                }
            }
        }
        for (String existingProduct2Id : product2IdToOpptyLineItemMap.keySet()) {
            if (! eteProductsByParentIdMap.containsKey(existingProduct2Id)) {
                oliToDelete.add(product2IdToOpptyLineItemMap.get(existingProduct2Id));
            }
        }
    }


    private Map<String, Map<String, Offer_Item__c>> generateFinalBusinessOfferItemsMap(
                                                    Map<String, List<E2E_Data_Offer_Item__c>> existingDataOfferItemsMap,
                                                    Map<String, Map<String, Offer_Item__c>> existingBusinessOfferItemsMap,
                                                    List<Offer_Item__c> offerItemsToDeleteList) {
        Map<String, Map<String, Offer_Item__c>> finalBusinessOfferItems = new Map<String, Map<String, Offer_Item__c>>();
        Set<String> currentOfferItemIds = new Set<String>();
        for (String product2Id : existingDataOfferItemsMap.keySet()) {
            if (! finalBusinessOfferItems.containsKey(product2Id)) {
                finalBusinessOfferItems.put(product2Id, new Map<String, Offer_Item__c>());
            }
            for (E2E_Data_Offer_Item__c e2eOfferItem : existingDataOfferItemsMap.get(product2Id)) {
                if (e2eOfferItem.Fleetcor_Offer_Item__c != null) {
                    currentOfferItemIds.add(e2eOfferItem.Fleetcor_Offer_Item__c);
                }
                currentOfferItemIds.add(e2eOfferItem.Id);
                if (! existingBusinessOfferItemsMap.containsKey(product2Id)) {
                    finalBusinessOfferItems.get(product2Id).put(e2eOfferItem.Id, new Offer_Item__c());
                } else {
                    if (! existingBusinessOfferItemsMap.get(product2Id).containsKey(e2eOfferItem.Fleetcor_Offer_Item__c)) {
                        finalBusinessOfferItems.get(product2Id).put(e2eOfferItem.Id, new Offer_Item__c());
                    } else {
                        finalBusinessOfferItems.get(product2Id).put(
                                e2eOfferItem.Id, existingBusinessOfferItemsMap.get(product2Id).get(e2eOfferItem.Fleetcor_Offer_Item__c)
                        );
                    }
                }
            }
        }
        for (String product2Id : existingBusinessOfferItemsMap.keySet()) {
            for (String offerItemId : existingBusinessOfferItemsMap.get(product2Id).keySet()) {
                if (! currentOfferItemIds.contains(offerItemId)) {
                    offerItemsToDeleteList.add(existingBusinessOfferItemsMap.get(product2Id).get(offerItemId));
                }
            }
        }
        return finalBusinessOfferItems;
    }


    private Map<String, E2E_Data_Additional_Service__c> getE2EDataAdditionalServices(ETEDatabaseInterface e2eDatabase, String dataObjectId) {
        Map<String, E2E_Data_Additional_Service__c> existingE2EDataAdditionalServicesMap = new Map<String, E2E_Data_Additional_Service__c>();
        List<E2E_Data_Additional_Service__c> e2eDataAdditionalServicesList = e2eDatabase.retrieveAdditionalServices(dataObjectId);
        for (E2E_Data_Additional_Service__c additionalService : e2eDataAdditionalServicesList) {
            existingE2EDataAdditionalServicesMap.put(additionalService.Name, additionalService);
        }
        return existingE2EDataAdditionalServicesMap;
    }


    private Map<String, Client_Offer_Additional_Service__c> getClientOfferAdditionalServices(ETEDatabaseInterface e2eDatabase, String opptyId) {
        Map<String, Client_Offer_Additional_Service__c> existingClientOfferAdditionalServicesMap = new Map<String, Client_Offer_Additional_Service__c>();
        List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesList = e2eDatabase.retrieveClientOfferAdditionalServices(opptyId);
        for (Client_Offer_Additional_Service__c clientOfferAdditionalService : clientOfferAdditionalServicesList) {
            existingClientOfferAdditionalServicesMap.put(clientOfferAdditionalService.Additional_Service__r.Integration_Name__c, clientOfferAdditionalService);
        }
        return existingClientOfferAdditionalServicesMap;
    }


    private Map<String, Client_Offer_Additional_Service__c> generateFinalClientOfferAdditionalServicesMap(ETEDatabaseInterface e2eDatabase,
                                                                                                String opptyId,
                                                                                                String countryCode,
                                                                                                Map<String, E2E_Data_Additional_Service__c> e2eDataAdditionalServicesMap,
                                                                                                Map<String, Client_Offer_Additional_Service__c> clientOfferAdditionalServicesMap) {
        Map<String, Client_Offer_Additional_Service__c> finalClientOfferAdditionalServicesMap = new Map<String, Client_Offer_Additional_Service__c>();
        List<Client_Offer_Additional_Service__c> clientOfferAdditionalServiceToDeleteList = new List<Client_Offer_Additional_Service__c>();
        for (String integrationName : clientOfferAdditionalServicesMap.keySet()) {
            if (! e2eDataAdditionalServicesMap.containsKey(integrationName)) {
                clientOfferAdditionalServiceToDeleteList.add(clientOfferAdditionalServicesMap.get(integrationName));
            } else {
                finalClientOfferAdditionalServicesMap.put(integrationName, clientOfferAdditionalServicesMap.get(integrationName));
            }
        }
        Set<String> clientOfferAdditionalServiceNamesToInsertSet = new Set<String>();
        for (String integrationName : e2eDataAdditionalServicesMap.keySet()) {
            if (! finalClientOfferAdditionalServicesMap.containsKey(integrationName)) {
                clientOfferAdditionalServiceNamesToInsertSet.add(integrationName);
            }
        }
        if (! clientOfferAdditionalServiceNamesToInsertSet.isEmpty()) {
            List<Additional_Service__c> additionalServiceSettingsList = e2eDatabase.retrieveAdditionalServicesSettingsByName(clientOfferAdditionalServiceNamesToInsertSet);
            if (clientOfferAdditionalServiceNamesToInsertSet.size() != additionalServiceSettingsList.size()) {
                throw new LongFormException('additional services settings error');
            }
            for (Additional_Service__c additionalService : additionalServiceSettingsList) {
                finalClientOfferAdditionalServicesMap.put(additionalService.Integration_Name__c, new Client_Offer_Additional_Service__c(
                        Opportunity__c = opptyId,
                        Additional_Service__c = additionalService.Id,
                        CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(countryCode)
                )
                );
            }
        }
        if (! clientOfferAdditionalServiceToDeleteList.isEmpty() ) { e2eDatabase.deleteClientOfferAdditionalServices(clientOfferAdditionalServiceToDeleteList); }
        return finalClientOfferAdditionalServicesMap;
    }


    private void generateFinalContactsDataToSyncMap(ETEDatabaseInterface e2eDatabase,
                                                    ETEBusinessObjectsInterface businessObjectsHandler,
                                                    String opptyId,
                                                    Map<String, Contact> sfContactsToSync,
                                                    Map<String, OpportunityContactRole> opptyContactRolesToSync,
                                                    List<E2E_Data_Contact__c> existingETEdataContacts) {
        Map<String, OpportunityContactRole> existingOpptyContactRoles = e2eDatabase.retrieveAllOpportunityContactRoles(opptyId);
        Map<String, Contact> existingSFcontactsMap = new Map<String, Contact>();
        for (Contact contact : e2eDatabase.retrieveContacts(existingOpptyContactRoles.keySet())) {
            existingSFcontactsMap.put(contact.Id, contact);
        }
        for (E2E_Data_Contact__c dataContact : existingETEdataContacts) {
            if (existingSFcontactsMap.containsKey(dataContact.Fleetcor_Contact__c)) {
                sfContactsToSync.put(dataContact.Id, existingSFcontactsMap.get(dataContact.Fleetcor_Contact__c));
                opptyContactRolesToSync.put(dataContact.Id, existingOpptyContactRoles.get(dataContact.Fleetcor_Contact__c));
                existingSFcontactsMap.remove(dataContact.Fleetcor_Contact__c);
            } else {
                sfContactsToSync.put(dataContact.Id, businessObjectsHandler.initContact());
                opptyContactRolesToSync.put(dataContact.Id, businessObjectsHandler.initOpportunityContactRole());
            }
        }
        if (! existingSFcontactsMap.isEmpty()) {
            e2eDatabase.deleteSFContacts(existingSFcontactsMap.values());
        }
    }


    private void doSyncBusinessObjects(ETEDatabaseInterface e2eDatabase,
                                    Map<String, OpportunityLineItem> existingProduct2IdToOpptyLineItemMap,
                                    Map<String, OpportunityLineItem> oliToInsert,
                                    List<OpportunityLineItem> oliToDelete,
                                    Map<String, List<E2E_Data_Offer_Item__c>> dataOfferItemsMap,
                                    Map<String, Offer_Item__c> offerItemsToUpsertMap,
                                    List<Offer_Item__c> offerItemsToDeleteList,
                                    List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesToUpsertList,
                                    Opportunity opportunity,
                                    Account account,
                                    Map<String, Contact> sfContactsToSync,
                                    Map<String, OpportunityContactRole> opptyContactRolesToSync,
                                    List<E2E_Data_Contact__c> existingETEdataContacts,
                                    List<Customer_Feedback__c> customerFeedbacksList,
                                    E2E_Data_Object__c dataObject) {
        if (opportunity.StageName == 'Closed Won') { createQuotePDF(e2eDatabase, opportunity.Id, dataObject.Country_Code__c); }
        if (account != null) {
            e2eDatabase.upsertAccount(account);
            opportunity.AccountId = account.Id;
            if (! sfContactsToSync.isEmpty()) {
                for (String dataContactId : sfContactsToSync.keySet()) {
                    sfContactsToSync.get(dataContactId).AccountId = account.Id;
                }
            }
            if (! sfContactsToSync.isEmpty()) {
                e2eDatabase.upsertSFContacts(sfContactsToSync.values());
            }
        }
        e2eDatabase.upsertOpportunity(opportunity);
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        List<OpportunityContactRole> ocrsToUpsert = new List<OpportunityContactRole>();
        if (existingETEdataContacts != null) {
            for (E2E_Data_Contact__c eteDataContact : existingETEdataContacts) {
                if (String.isEmpty(eteDataContact.Fleetcor_Contact__c)) {
                    OpportunityContactRole ocr = opptyContactRolesToSync.get(eteDataContact.Id);
                    ocr.OpportunityId = opportunity.Id;
                    ocr.ContactId = sfContactsToSync.get(eteDataContact.Id).Id;
                    ocrsToUpsert.add(ocr);
                    eteDataContact.Fleetcor_Contact__c = sfContactsToSync.get(eteDataContact.Id).Id;
                }
                if (! ocrsToUpsert.isEmpty()) {
                    e2eDatabase.upsertContactRoles(ocrsToUpsert);
                    e2eDatabase.upsertETEContacts(existingETEdataContacts);
                }
            }
        }
        if (oliToInsert != null && ! oliToInsert.isEmpty()) { e2eDatabase.insertOpptyLineItems(oliToInsert.values()); }
        if (oliToDelete != null && ! oliToDelete.isEmpty()) { e2eDatabase.deleteOpptyLineItems(oliToDelete); }
        if (! customerFeedbacksList.isEmpty()) {
            e2eDatabase.insertCustomerFeedbacks(customerFeedbacksList);
        }
        if (offerItemsToUpsertMap != null && ! offerItemsToUpsertMap.isEmpty()) {
            for (String product2Id : dataOfferItemsMap.keySet()) {
                for (E2E_Data_Offer_Item__c dataOfferItem : dataOfferItemsMap.get(product2Id)) {
                    Offer_Item__c offerItem = offerItemsToUpsertMap.get(dataOfferItem.Id);
                    if (oliToInsert.containsKey(product2Id)) {
                        offerItem.Opportunity_Product_Id__c = oliToInsert.get(product2Id).Id;
                    } else {
                        offerItem.Opportunity_Product_Id__c = existingProduct2IdToOpptyLineItemMap.get(product2Id).Id;
                    }
                }
            }
            e2eDatabase.upsertOpptyOfferItems(offerItemsToUpsertMap.values());
            List<E2E_Data_Offer_Item__c> dataOfferItemsToUpsert = new List<E2E_Data_Offer_Item__c>();
            for (String offerId : dataOfferItemsMap.keySet()) {
                for (E2E_Data_Offer_Item__c dataOfferItem : dataOfferItemsMap.get(offerId)) {
                    if (dataOfferItem.Fleetcor_Offer_Item__c == null) {
                        dataOfferItem.Fleetcor_Offer_Item__c = offerItemsToUpsertMap.get(dataOfferItem.Id).Id;
                        dataOfferItemsToUpsert.add(dataOfferItem);
                    }
                }
            }
            if (!dataOfferItemsToUpsert.isEmpty()) {
                e2eDatabase.upsertOfferItems(dataOfferItemsToUpsert);
            }
        }
        if (offerItemsToDeleteList != null && ! offerItemsToDeleteList.isEmpty()) {
            e2eDatabase.deleteOpptyOfferItems(offerItemsToDeleteList);
        }
        if (clientOfferAdditionalServicesToUpsertList != null && ! clientOfferAdditionalServicesToUpsertList.isEmpty()) {
            ClientOfferAddServiceHandler.enablesTrigger = false;
            for (Client_Offer_Additional_Service__c clientOfferAdditionalService : clientOfferAdditionalServicesToUpsertList) {
                clientOfferAdditionalService.Account__c = opportunity.AccountId;
            }
            e2eDatabase.upsertClientOfferAdditionalServices(clientOfferAdditionalServicesToUpsertList);
            Map<Id, Client_Offer_Additional_Service__c> clientOfferAdditionalServicesToUpsertMap = new Map<Id, Client_Offer_Additional_Service__c>();
            for (Client_Offer_Additional_Service__c clientOfferAdditionalService : clientOfferAdditionalServicesToUpsertList) {
                clientOfferAdditionalServicesToUpsertMap.put(clientOfferAdditionalService.Id, clientOfferAdditionalService);
            }
            ClientOfferAddServiceHandler.addAdditionalServicesToOpp(clientOfferAdditionalServicesToUpsertMap);
            ClientOfferAddServiceHandler.updateOpptyAdditionalServicesNames(clientOfferAdditionalServicesToUpsertMap);
        }
        if (opportunity.StageName == 'Pending Credit - E2E Check') {
            List<ProcessInstance> approvalProcesses = e2eDatabase.retrieveApprovalProcesses(opportunity.Id);
            if (approvalProcesses.isEmpty()) {
                sendToApprovalProcess(dataObject.RecordType.Name, opportunity);
            }
        }
    }


    private void sendToApprovalProcess(String implKey, Opportunity opportunity) {
        String processDefinition = ETEGlobalUtils.returnApprovalProcessDefinition(implKey);
        if (processDefinition != null) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Automated CreditCheck request from E2E.');
            req.setObjectId(opportunity.Id);
            req.setSubmitterId(opportunity.OwnerId);
            req.setSkipEntryCriteria(true);
            req.setProcessDefinitionNameOrId(processDefinition);
            Approval.process(req);
        }
    }


    private void sendFacebookEvent(String implKey, String targetEmail){
        /**
         * Example param:
         * formUrl = 'https://online.fleetcor.pl/etepl';
         */
        Blob targetBlob = Blob.valueOf(targetEmail);
        Blob resultBlob = System.Crypto.generateDigest('SHA-256', targetBlob);
        String resultEmail = EncodingUtil.convertToHex(resultBlob);

        String path = ETEGlobalUtils.returnUrlPath(implKey).getUrl().replace('/apex', '');
        String domainUrl = ETEGlobalUtils.returnSiteUrl(this.countryCode);
        String formUrl = domainUrl + path;
        
        String facebookPixelId = '2429086550650484';
        String access_token = 'EAAL9BzZCDPwwBALEYnFNPkCfD4ZBY2dL88avYw0iLI0lmh2bqCET7pWEZApSLSIWFuPMbUk0KrlWdNjoLFEUeSfuGM5omN2pMghxt1IqZAduOZBZCAZA4N6kJeCZBZCswAHzfyxZCxA8HRX8AH6fTuleSSdBmPLn4ZAJjtBZBMa9FPEWXS0z6R1obe7jwRgCtRl8aCoZD';

        Long timeNow =  DateTime.now().getTime()/1000;
        String data = '[{"event_name": "SubmitApplication","event_time": ' + timeNow + ',"action_source": "website","event_source_url": "' + formUrl + '","user_data": {"em": "'+resultEmail+'"}}]';
        String body = 'data=' + EncodingUtil.urlEncode(data, 'UTF-8') +
                    '&access_token=' + EncodingUtil.urlEncode(access_token, 'UTF-8'); 
        /**
         *  For test mode use test_event_code;
         *  '&test_event_code=TEST20051';
         */   

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('https://graph.facebook.com/v10.0/' + facebookPixelId + '/events');
        req.setMethod('POST');
        req.setBody(body);
        req.setCompressed(true);
        try {
            res = http.send(req);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }    
    }
}