public virtual class ETEDatabaseBaseImpl implements ETEDatabaseInterface {

    public virtual Map<String, Object> getSettings(String implKey, String country) {
        Set<String> defaultSettingsKey = ETEGlobalUtils.returnDefaultSettingKey(implKey);
        List<String> defaultSettingsJsonList = retrieveStaticResourcesByName(defaultSettingsKey);
        String defaultSettingsJson = defaultSettingsJsonList.get(0);
        Map<String, Object> defaultSettingsMap = (Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJson);
        List<String> availableSteps = returnAvailableSteps(defaultSettingsMap);
        Set<String> requestedStaticResourcesNames = ETEGlobalUtils.generateStaticResourcesNames(country, availableSteps);
        requestedStaticResourcesNames.add('ETE_finish');
        List<String> stepResourcesJsonsList = retrieveStaticResourcesByName(requestedStaticResourcesNames);
        Map<String, Object> settings = returnFinalSettings(country, implKey, defaultSettingsJson, stepResourcesJsonsList);
        return settings;
    }


    public virtual Map<String, Object> getContent(String implKey, String country, Map<String, Object> settings) {
        Set<String> availableLanguages = returnAvailableLanguages(settings);
        List<String> availableSteps = returnAvailableSteps(settings);
        Set<String> requestedStaticResourcesNames = ETEGlobalUtils.generateStaticResourcesNames(country, availableSteps);
        requestedStaticResourcesNames.add('ETE_finish');
        requestedStaticResourcesNames.add('ETE_common_components_translations');
        List<String> stepResourcesList = retrieveStaticResourcesByName(requestedStaticResourcesNames);
        Map<String, Object> content = returnAllContents(implKey, stepResourcesList, availableLanguages);
        return content;
    }


    public virtual List<String> retrieveStaticResourcesByName(Set<String> requestedStaticResourcesNames) {
        Map<String, String> staticResourcesFromPlatformCacheMap = getStaticResourcesFromPlatformCache(requestedStaticResourcesNames);
        Map<String, String> missingStaticResourcesMap = getMissingStaticResources(staticResourcesFromPlatformCacheMap,
                requestedStaticResourcesNames);
        List<String> staticResourcesJsonsList = new List<String>();
        if (! staticResourcesFromPlatformCacheMap.isEmpty()) {
            staticResourcesJsonsList.addAll(staticResourcesFromPlatformCacheMap.values());
        }
        if (! missingStaticResourcesMap.isEmpty()) {
            staticResourcesJsonsList.addAll(missingStaticResourcesMap.values());
            putStaticResourcesToPlatformCache(missingStaticResourcesMap);
        }
        return staticResourcesJsonsList;
    }


    public virtual List<E2E_Data_Log__c> retrieveE2EDataLogs(String dataObjectId) {
        List<E2E_Data_Log__c> e2eDataLogsList = [
                SELECT Id, Name, RecordTypeId, RecordType.Name, Error_Code__c, Field__c, Job_ID__c, Job_Status__c, New_Value__c,
                        Old_Value__c, Status__c, Exception_Source__c, Device_Type__c, Exception_Description__c, Exception_Type__c,
                        E2E_Step__c, Form_Identification__c, Rating__c, Feedback_Local__c, Feedback_English__c
                FROM E2E_Data_Log__c
                WHERE E2E_Data_Object__c = :dataObjectId
                ORDER BY CreatedDate DESC
        ];
        return e2eDataLogsList;
    }


    public virtual List<E2E_Data_Log__c> retrieveE2EDataLogByName(String dataObjectId, String dataLogName) {
        List<E2E_Data_Log__c> e2eDataLogsList = [
                SELECT Id, Name, RecordTypeId, RecordType.Name, Error_Code__c, Field__c, Job_ID__c, Job_Status__c, New_Value__c,
                        Old_Value__c, Status__c, Exception_Source__c, Device_Type__c, Exception_Description__c, Exception_Type__c
                FROM E2E_Data_Log__c
                WHERE E2E_Data_Object__c = :dataObjectId AND Name = :dataLogName
                LIMIT 1
        ];
        return e2eDataLogsList;
    }


    public virtual List<Payment_Transaction__c> retrievePendingPaymentTransactions(String opptyId, Decimal deposit) {
        List<Payment_Transaction__c> pendingTransactions = [
                SELECT Id, OrderID__c, Amount__c, Currency__c, OpportunityID__c, PayUOrderId__c
                FROM Payment_Transaction__c
                WHERE Status__c = null AND
                OpportunityID__c = :opptyId AND
                Amount__c = :deposit
                LIMIT 1
        ];
        return pendingTransactions;
    }


    public virtual List<Payment_Transaction__c> retrieveActivePaymentTransactions(String payOrderId) {
        List<Payment_Transaction__c> activePaymmentTransactionList = [
                SELECT Id, Amount__c, BuyerCustomerId__c, BuyerEmail__c, BuyerFirstName__c, BuyerLastName__c, BuyerPhone__c, MerchantPosId__c,
                        PaymentMethod__c, PayUOrderId__c, Status__c
                FROM Payment_Transaction__c
                WHERE PayUOrderId__c = :payOrderId
                LIMIT 1];
        return activePaymmentTransactionList;
    }


    public virtual List<dsfs__DocuSign_Status__c> retrieveDocuSignStatuses(String opptyId) {
        List<dsfs__DocuSign_Status__c> docusignStatusList = [
                SELECT dsfs__DocuSign_Envelope_ID__c, dsfs__Opportunity__c, dsfs__Envelope_Status__c
                FROM dsfs__DocuSign_Status__c
                WHERE dsfs__Opportunity__c = :opptyId
                LIMIT 1000];
        return docusignStatusList;
    }


    public virtual List<Attachment> retrieveAttchments(Set<String> attachNames, String parentId) {
        List<Attachment> attachmentsList = [
                SELECT Id, Name
                FROM Attachment
                WHERE Name IN :attachNames AND
                ParentId = :parentId
                LIMIT 1000];
        return attachmentsList;
    }


    public virtual List<Credit_Factory_Report__c> retrieveCFReports(String opptyId) {
        List<Credit_Factory_Report__c> cfReportList = [
                SELECT Name, Name__c, RecordType.Name, Age_of_Company__c, City__c, Class_Rating__c, Company_Id__c, Company_Status__c, Country__c, County_Court__c, Credit_Decision__c, Credit_Limit__c, Credit_Limit_Currency__c,
                        Credit_System_Number__c, Date_Last_Register_Entry__c, Date_Legal_Form__c, Date_of_Foundation__c, Email__c, Fax__c, First_Legal_Form__c, Fiscal_Number__c, Housenumber__c, Legal_Form__c,
                        Mobile__c, Obligation_Overdue__c, Opportunity__c, Order_Situation__c, Payment_Behaviour__c, Phone__c, Postcode__c, Reference_Number__c, Register_Number__c, Request_Status__c,
                        Solvency_Index__c, Staff_Range__c, Street__c, Tax_Id__c, Trade_Name__c, Turn_Over__c, VAT_Number__c, Website__c, Billing_Period__c, Credit_Limit_Weekly_7__c, Credit_Limit_Bi_Weekly_7__c,
                        Credit_Limit_Monthly_7__c, Max_Credit_Limit_Weekly_7__c, Max_Credit_Limit_Bi_Weekly_7__c, Max_Credit_Limit_Monthly_7__c, Max_Value_Weekly_7__c, Max_Value_Bi_Weekly_7__c, Max_Value_Monthly_7__c,
                        Deposit_Weekly_7__c, Deposit_Bi_Weekly_7__c, Deposit_Monthly_7__c, Trade_Register_Number__c,
                        Decision_Verdict__c, Decision_Status_Code__c,
                (SELECT Name, Id__c, Address__c, Company_Id__c, Company_Role__c, Company_Type__c, Credit_Factory_Report__c, Date_of_Birth__c, Participation_Date__c, Reported__c, Type__c
                FROM Credit_Factory_Report_Employees__r)
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :opptyId
                ORDER BY CreatedDate DESC
        ];
        return cfReportList;
    }


    public virtual List<Customer_Feedback__c> retrieveCustomerFeedbacks(String opptyId) {
        List<Customer_Feedback__c> customerFeedbacks = [
                SELECT E2E_Step__c, E2E_Data_Log__c, Feedback_English__c, Feedback_Local__c, Form_Identification__c,
                        Rating__c
                FROM Customer_Feedback__c
                WHERE Opportunity__c = :opptyId
        ];
        return customerFeedbacks;
    }


    public virtual List<Quote> retrieveQuotes(String opptyId) {
        List<Quote> existingQuotes = [
                SELECT  Id, Grand_Total__c
                FROM    Quote
                WHERE   OpportunityId =: opptyId
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        return existingQuotes;
    }


    public virtual Map<String, EmailTemplate> retrieveEmailTemplatesByNames (Set<String> templateNames) {
        Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
        for (EmailTemplate emailTemplate : [SELECT Id, Name, DeveloperName, Body, HtmlValue, Subject
                                            FROM EmailTemplate
                                            WHERE DeveloperName IN :templateNames
                                            LIMIT 1000]) {
            templatesMap.put(emailTemplate.DeveloperName, emailTemplate);
        }
        return templatesMap;
    }


    public virtual List<ProcessInstance> retrieveApprovalProcesses(String opptyId) {
        List<ProcessInstance> pi = [
                SELECT TargetObjectId, Status, ProcessDefinitionId
                FROM ProcessInstance
                WHERE TargetObjectId = :opptyId
                ORDER BY CreatedDate DESC
                LIMIT 1];
        return pi;
    }


    public virtual void insertOpptyLineItems(List<OpportunityLineItem> opportunityLineItems) {
        insert opportunityLineItems;
    }


    public virtual void deleteOpptyLineItems(List<OpportunityLineItem> opportunityLineItemsToDelete) {
        delete opportunityLineItemsToDelete;
    }


    public virtual void upsertOpptyOfferItems(List<Offer_Item__c> offerItemsToUpsertList) {
        upsert offerItemsToUpsertList;
    }


    public virtual void deleteOpptyOfferItems(List<Offer_Item__c> offerItemsToDeleteList) {
        delete offerItemsToDeleteList;
    }


    public virtual void upsertE2EDataLogs(List<E2E_Data_Log__c> e2eDataLogs) {
        upsert e2eDataLogs;
    }


    public virtual void upsertDataObject(E2E_Data_Object__c e2EDataObject) {
        upsert e2EDataObject;
    }


    public virtual void upsertETEContacts(List<E2E_Data_Contact__c> contactsToUpsertList) {
        upsert contactsToUpsertList;
    }


    public virtual void deleteContacts(List<E2E_Data_Contact__c> contactsToDeleteList) {
        delete contactsToDeleteList;
    }


    public virtual void deleteSFcontacts(List<Contact> contactsToDelete) {
        delete contactsToDelete;
    }


    public virtual void deleteOpptyContactRoles(List<OpportunityContactRole> ocrToDelete) {
        delete ocrToDelete;
    }


    public virtual void upsertOfferItems(List<E2E_Data_Offer_Item__c> offerItemsToUpsertList) {
        upsert offerItemsToUpsertList;
    }


    public virtual void deleteOfferItems(List<E2E_Data_Offer_Item__c> offerItemsToDeleteList) {
        delete offerItemsToDeleteList;
    }



    public virtual void upsertETELocatorItems(List<E2E_Data_Locator_Item__c> locatorItemsToUpsertList) {
        upsert locatorItemsToUpsertList;
    }


    public virtual void deleteETELocatorItems(List<E2E_Data_Locator_Item__c> locatorItemsToDeleteList) {
        delete locatorItemsToDeleteList;
    }


    public virtual void upsertETEProducts(List<E2E_Data_Product__c> productsToUpsertList) {
        upsert productsToUpsertList;
    }


    public virtual void deleteETEProducts(List<E2E_Data_Product__c> productsToDeleteList) {
        delete productsToDeleteList;
    }


    public virtual void deleteCreditFactoryReports(List<Credit_Factory_Report__c> cfreports) {
        delete cfreports;
    }


    public virtual void deleteAttchments(List<Attachment> cfattachments) {
        delete cfattachments;
    }


    public virtual void deleteDocusignStatuses(List<dsfs__DocuSign_Status__c> docuSignStatusesToDelete) {
        delete docuSignStatusesToDelete;
    }


    public virtual void deleteAdditionalServices(List<E2E_Data_Additional_Service__c> additionalServices) {
        delete additionalServices;
    }


    public virtual void deleteClientOfferAdditionalServices(List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesToDelete) {
        delete clientOfferAdditionalServicesToDelete;
    }


    public virtual void upsertAccount(Account account) {
        upsert account;
    }


    public virtual void upsertOpportunity(Opportunity opportunity) {
        upsert opportunity;
    }


    public virtual void upsertContactRoles(List<OpportunityContactRole> contactRoles) {
        upsert contactRoles;
    }


    public virtual void upsertSFContacts(List<Contact> contacts) {
        upsert contacts;
    }

    public virtual void upsertCreditFactoryReports(List<Credit_Factory_Report__c> cfreports) {
        upsert cfreports;
    }

    public virtual void insertCreditBlackList(Credit_Black_List_Company__c blackListCompany) {
        insert blackListCompany;
    }


    public virtual void upsertCreditFactoryEmployees(List<Credit_Factory_Report_Employee__c> reportEmployees) {
        upsert reportEmployees;
    }


    public virtual void upsertAdditionalServices(List<E2E_Data_Additional_Service__c> additionalServices) {
        upsert additionalServices;
    }


    public virtual void upsertClientOfferAdditionalServices(List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesToUpsert) {
        upsert clientOfferAdditionalServicesToUpsert;
    }


    public virtual void upsertPaymentTransaction(Payment_Transaction__c paymentTransaction) {
        upsert paymentTransaction;
    }


    public virtual void insertCustomerFeedbacks(List<Customer_Feedback__c> customerFeedbacksList) {
        insert customerFeedbacksList;
    }


    public virtual void insertQuoteDocument(QuoteDocument quoteDoc) {
        insert quoteDoc;
    }


    public virtual void updateLead(Lead lead) {
        update lead;
    }


    public virtual void updateEmarsysLogs(List<Emarsys_Log__c> emarsysLogs) {
        update emarsysLogs;
    }


    public virtual List<Emarsys_Log__c> retrieveEmarsysLogs(String leadId) {
        List<Emarsys_Log__c> emarsysLogList = [SELECT Opportunity__c FROM Emarsys_Log__c WHERE Lead__c = :leadId];
        List<Emarsys_Log__c> emarsysLogs;
        if (! emarsysLogList.isEmpty()) {
            emarsysLogs = emarsysLogList;
        }
        return emarsysLogs;
    }


    public virtual E2E_Data_Object__c retrieveETEDataObject(String dataId) {
        List<E2E_Data_Object__c> dataObjectsList = [
                SELECT Name, RecordTypeId, RecordType.Name, Salutation__c, First_Name__c, Last_Name__c, Phone__c, Email__c, Agreement_To_Phone_Contact__c,
                        Agreement_To_Receive_Info_By_Email__c, Agreement_Privacy_Policy__c, Country_Code__c, E2E_Last_Activity__c,
                        Current_Step__c, Selected_Company_Name__c, Selected_Company_Id__c, StageName__c, E2E_Status__c,
                        Terms_And_Conditions_Agreement__c, Authorized_Signatory_Confirmed__c, Customer_IP_Address__c,
                        Security_Amount_To_Pay__c, Payment_Status__c, Deposit_Agreement__c, Company_Short_Name__c,
                        Device_Type__c, Payment_Method__c, Credit_Limit__c, Max_Credit_Limit__c, Billing_Period__c,
                        Payment_Terms__c, E_Invoice__c, Paper_Invoice__c, Security_Level__c, Current_Language__c,
                        Registered_Postal_Code__c, Registered_Country__c, Registered_City__c, Registered_Street__c,
                        Utm_Campaign__c, Utm_Content__c, Utm_Medium__c, Utm_Placement__c, Utm_Source__c, Utm_Term__c, Utm_Url__c,
                        Birthdate__c, Company_Form__c, E2E_Finish_Details__c, Tax_ID__c, Agree_to_process_pers_data_for_marketing__c,
                        Accept_Sepa__c, Account_Holder__c, IBAN__c, SWIFT__c, Risk_Category__c, Direct_Debit_Mandate_Type__c,
                        ESI__c, Home_Station__c, PM__c, Brand__c, Available_Min_Deposit__c, Utm_Products__c, Deposit_Reason__c, Vat_ID__c,
                        Trade_Register_Number__c, Lead__c, Credit_System_Rating__c, Client_Id__c, Verification_Code__c,
                        Verification_Date__c, Bank_Account_Prefix__c, Bank_Account_Number__c, Bank_Code__c, Bank_Name__c
                FROM E2E_Data_Object__c
                WHERE Id = :dataId
        ];
        E2E_Data_Object__c dataObject;
        if (! dataObjectsList.isEmpty()) {
            dataObject = dataObjectsList.get(0);
        } else {
            throw new LongFormException('requested object is not found');
        }
        return dataObject;
    }


    public virtual Lead retrieveLead(String leadId) {
        List<Lead> leadList = [
                SELECT ConvertedAccountId, ConvertedOpportunityId, ConvertedContactId, Description, ConvertedContact.Phone, CountryCode, Owner.Name, Sec_Channel__c, IsConverted, Company,
                       LeadSource, Phone, Number_of_Cards_facebook__c, Anzahl_der_Fahrzeuge__c, CCS_number_of_cards__c, RecordType.Name, Country, E2E_Manual_Adoption_Date__c, Steuernummer__c,
                       Agree_to_process_pers_data_for_marketing__c, Agree_to_receive_comm_info_by_email__c, Agree_to_telephone_contact__c
                FROM Lead
                WHERE Id = :leadId
        ];
        Lead lead;
        if (! leadList.isEmpty()) {
            lead = leadList.get(0);
        }
        return lead;
    }


    public virtual Account retrieveAccount(String accountId) {
        List<Account> accountsList = [
                SELECT  Name, BillingCountry, BillingStreet, BillingPostalCode, BillingCity, BillingState, ShippingCountry,
                        ShippingStreet, ShippingPostalCode, ShippingCity, Steuernummer__c,
                        HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Umsatzsteuer_ID__c, Ort_der_Registrierung_Handelsregisterort__c
                FROM Account
                WHERE Id = :accountId
        ];
        Account account;
        if (! accountsList.isEmpty()) {
            account = accountsList.get(0);
        }
        return account;
    }


    public virtual List<Contact> retrieveContacts(Set<String> contactIds) {
        List<Contact> contactsList = [
                SELECT AccountId, Salutation, Name, Title, FirstName, LastName, Email, Phone, Authorised_signatory__c,
                        Birthdate
                FROM Contact
                WHERE Id IN :contactIds
        ];
        return contactsList;
    }


    public virtual Opportunity retrieveConvertedOpportunity(String opptyId) {
        List<Opportunity> opptiesList = [
                SELECT Id,
                        (SELECT AccountTo.OBN__c, AccountTo.BillingStreet, AccountTo.BillingCity, AccountTo.BillingCountry, AccountTo.Id, AccountTo.Name_des_Mitarbeiters__c
                        FROM Partners
                        WHERE AccountTo.OBN__c != NULL AND AccountTo.BillingStreet != null AND AccountTo.BillingCity != NULL AND AccountTo.BillingCountry != NULL LIMIT 1)
                FROM Opportunity
                WHERE Id = :opptyId
        ];
        Opportunity opportunity;
        if (! opptiesList.isEmpty()) {
            opportunity = opptiesList.get(0);
        }
        return opportunity;
    }


    public virtual Opportunity retrieveOpportunity(String dataObjectId) {
        List<Opportunity> opptiesList = [
                SELECT Name, OwnerId, StageName, E2E_CF_Reports_Counter__c, AccountId, AGB_Datenschutzhinweise_Richtigkeit__c, Agree_To_Deposit_Agreement__c,
                        CF_Credit_Limit__c, Zahlungsart__c, Rechnungsperiode__c, Zahlungsziel_Credit__c, Max_Credit_Limit__c, E2E_2__c,
                        E2E_Step__c, E2E_Data_Object__c, Security_Amount_To_Pay__c, Security_To_Pay__c, CF_Search_Parameters__c, Credit_Stage__c,
                        Einwilligung_Lastschriftverfahren__c, ESI__c, LeadSource, Retailer_OBN__c, E2E_System_Error_Description__c, E2E_Errors__c,
                        Direct_Debit_Mandate_Type__c, Credit_System_Rating__c, Pricebook2Id, Registered_Country__c, Risk_Category__c,
                        Bank_Account_Prefix__c, Bank_Account_Number__c, Bank_Code__c, Bank_Name__c, Bank_Country__c
                FROM Opportunity
                WHERE E2E_Data_Object__c = :dataObjectId
        ];
        Opportunity opportunity;
        if (! opptiesList.isEmpty()) {
            opportunity = opptiesList.get(0);
        }
        return opportunity;
    }

    public virtual Quote retrieveOpportunityQuote (String oppId) {
        List<Quote> quotesList = [
                SELECT  Grand_Total__c, 
                        (SELECT Product2Id, Quantity, TotalPrice, Vat__c
                         FROM   QuoteLineItems)
                FROM    Quote
                WHERE   OpportunityId =: oppId
        ];
        Quote quote;
        if (! quotesList.isEmpty()) {
            quote = quotesList.get(0);
        }
        return quote;
    }


    public virtual Map<String, OpportunityContactRole> retrievePrimaryOpportunityContactRole(String opptyId) {
        Map<String, OpportunityContactRole> primaryOCR = new Map<String, OpportunityContactRole>();
        for (OpportunityContactRole ocr : [SELECT Id, OpportunityId, ContactId
                                        FROM OpportunityContactRole
                                        WHERE OpportunityId = :opptyId AND ContactId != NULL AND IsPrimary = true
                                        LIMIT 1]) {
            primaryOCR.put(ocr.ContactId, ocr);
        }
        return primaryOCR;
    }


    public virtual Map<String, OpportunityContactRole> retrieveAllOpportunityContactRoles(String opptyId) {
        Map<String, OpportunityContactRole> allOCRs = new Map<String, OpportunityContactRole>();
        for (OpportunityContactRole ocr : [SELECT Id, OpportunityId, ContactId
                                            FROM OpportunityContactRole
                                            WHERE OpportunityId = :opptyId AND ContactId != NULL
                                            LIMIT 100]) {
            allOCRs.put(ocr.ContactId, ocr);
        }
        return allOCRs;
    }


    public virtual List<E2E_Data_Contact__c> retrieveETEContacts(String dataId) {
        List<E2E_Data_Contact__c> contactsList = [
                SELECT Name, First_Name__c, Last_Name__c, Salutation__c, Email__c, Phone__c,Birthdate__c, Fleetcor_Contact__c,
                        isPrimary__c, Role__c, Index__c, E2E_Data_Object__c
                FROM E2E_Data_Contact__c
                WHERE E2E_Data_Object__c = :dataId
        ];
        return contactsList;
    }


    public virtual E2E_Data_Contact__c retrieveETEPrimaryContact(String dataId) {
        List<E2E_Data_Contact__c> primaryContactsList = [
                SELECT  Name, First_Name__c, Last_Name__c, Salutation__c, Email__c, Phone__c,Birthdate__c, Fleetcor_Contact__c,
                        isPrimary__c, Role__c, Index__c, E2E_Data_Object__c
                FROM    E2E_Data_Contact__c
                WHERE   E2E_Data_Object__c = :dataId AND isPrimary__c = TRUE
                LIMIT   1
        ];
        E2E_Data_Contact__c dataContact;
        if (! primaryContactsList.isEmpty()) {
            dataContact = primaryContactsList[0];
        }
        return dataContact;
    }


    public virtual Map<String, E2E_Data_Product__c> retrieveETEProducts(String dataObjectId) {
        Map<String, E2E_Data_Product__c> productsMap = new Map<String, E2E_Data_Product__c>([
                SELECT  Id, Name, RecordType.Name, E2E_Data_Object__c, ProductID__c, Type_Name__c, Type_ID__c
                FROM    E2E_Data_Product__c
                WHERE   E2E_Data_Object__c = :dataObjectId
        ]);
        return productsMap;
    }


    public virtual Map<String, E2E_Data_Offer_Item__c> retrieveETEOfferItems(Set<String> productsIds) {
        Map<String, E2E_Data_Offer_Item__c> offerItemsMap = new Map<String, E2E_Data_Offer_Item__c>([
                SELECT  Name, Offer_Name__c, Fleetcor_Offer__c, Fleetcor_Offer_Item__c, Category_Of_Products__c, Company_Name__c,
                        Driver_Name__c, License_Plate_Number__c, Mileage_Data__c, Type_Of_Card__c, Type_Of_Vehicle__c,
                        Offer_Item_Type_Name__c, Offer_Item_Type_Id__c, Monthly_Fuel_Consumption__c, Activate_EV_Charging__c,
                        Locked_Pin_Change__c, Daily_Card_Limit__c, Monthly_Card_Limit__c, E2E_Data_Product__c
                FROM    E2E_Data_Offer_Item__c
                WHERE   E2E_Data_Product__c IN :productsIds
        ]);
        return offerItemsMap;
    }


    public virtual Map<String, E2E_Data_Locator_Item__c> retrieveETELocatorItems(Set<String> productsIds) {
        Map<String, E2E_Data_Locator_Item__c> locatorItemsMap = new Map<String, E2E_Data_Locator_Item__c>([
                SELECT  Name, RecordType.Name, E2E_Data_Product__c, Brand__c, ESI__c
                FROM    E2E_Data_Locator_Item__c
                WHERE   E2E_Data_Product__c IN :productsIds
        ]);
        return locatorItemsMap;
    }


    public virtual List<PricebookEntry> retrieveProductEntries(Set<String> productIdsSet) {
        List<PricebookEntry> priceBookEntries = [SELECT Name, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :productIdsSet];
        return priceBookEntries;
    }


    public virtual Pricebook2 retrieveStandardPricebook() {
        Pricebook2 standardPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book'];
        return standardPriceBook;
    }


    public virtual List<OpportunityLineItem> retrieveOpptyLineItemsByParentId(String opptyId) {
        List<OpportunityLineItem> opptyLineItems = [
                SELECT Id, Name, Product2Id, Quantity, UnitPrice, PriceBookEntry.Id, Description
                FROM OpportunityLineItem
                WHERE OpportunityId = :opptyId
        ];
        return opptyLineItems;
    }


    public virtual List<OpportunityLineItem> retrieveOpptyLineItemsById(Set<String> opptyLineItemIdsSet) {
        List<OpportunityLineItem> opptyLineItems = [
                SELECT Id, Product2Id
                FROM OpportunityLineItem
                WHERE Id IN :opptyLineItemIdsSet
        ];
        return opptyLineItems;
    }


    public virtual List<Offer_Item__c> retrieveBusinessOfferItems(Set<String> opptyLineItemIdsSet) {
        List<Offer_Item__c> businessOfferItemsList = [
                SELECT Category_of_products__c, Opportunity_Product_Id__c
                FROM Offer_Item__c
                WHERE Opportunity_Product_Id__c = :opptyLineItemIdsSet
        ];
        return businessOfferItemsList;
    }


    public virtual List<Quote> retrieveExistingQuotes(String opptyId) {
        List<Quote> existingQuotesList = [
                SELECT Id,
                    (SELECT Id, Quantity, UnitPrice, Description, Product2Id, PriceBookEntry.Id
                    FROM QuoteLineItems)
                FROM Quote
                WHERE OpportunityId = :opptyId
                ORDER BY CreatedDate DESC
                LIMIT 1];
        return existingQuotesList;
    }


    public virtual List<E2E_Data_Additional_Service__c> retrieveAdditionalServices(String dataId) {
        List<E2E_Data_Additional_Service__c> additionalServicesList = [
                SELECT Name, Selected__c
                FROM E2E_Data_Additional_Service__c
                WHERE E2E_Data_Object__c = :dataId
        ];
        return additionalServicesList;
    }


    public virtual List<E2E_Data_Additional_Service__c> retrieveSelectedAdditionalServices (String dataId) {
        List<E2E_Data_Additional_Service__c> additionalServicesList = [
                SELECT  Name, Selected__c
                FROM    E2E_Data_Additional_Service__c
                WHERE   E2E_Data_Object__c = :dataId AND Selected__c = TRUE
        ];
        return additionalServicesList;
    }


    public virtual List<Client_Offer_Additional_Service__c> retrieveClientOfferAdditionalServices(String opptyId) {
        List<Client_Offer_Additional_Service__c> clientOfferAdditionalServicesList = [
                SELECT Additional_Service__c, Opportunity__c, Selected__c, Additional_Service__r.Integration_Name__c
                FROM Client_Offer_Additional_Service__c
                WHERE Opportunity__c = :opptyId
        ];
        return clientOfferAdditionalServicesList;
    }


    public virtual List<Additional_Service__c> retrieveAdditionalServicesSettingsByName(Set<String> additionalServiceIntegrationNamesSet) {
        List<Additional_Service__c> additionalServicesSettingsList = [
                SELECT Id, Integration_Name__c
                FROM Additional_Service__c
                WHERE Integration_Name__c IN :additionalServiceIntegrationNamesSet AND
                Active__c = true
        ];
        return additionalServicesSettingsList;
    }


    private static List<String> returnAvailableSteps(Map<String, Object> defaultSettingsMap) {
        List<String> availableSteps = new List<String>();
        for (Object stepObject : (List<Object>) defaultSettingsMap.get('steps')) {
            Map<String, Object> stepsSettings = (Map<String, Object>) stepObject;
            for (String stepParam : stepsSettings.keySet()) {
                if (stepParam == 'name') {
                    availableSteps.add(String.valueOf(stepsSettings.get(stepParam)));
                }
            }
        }
        return availableSteps;
    }


    private static Set<String> returnAvailableLanguages(Map<String, Object> settingsMap) {
        Set<String> availableLanguages = new Set<String>();
        for (Object languageObject : (List<Object>) settingsMap.get('langs')) {
            availableLanguages.add(String.valueOf(languageObject));
        }
        return availableLanguages;
    }


    private static Map<String, String> getStaticResourcesFromPlatformCache(Set<String> staticResourcesNames) {
        Map<String, String> availableStaticResourcesMap = new Map<String, String>();
        Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.e2elongform');
        for (String resourcesName : staticResourcesNames) {
            String partitionKey = resourcesName.replaceAll('_', '');
            if (orgPartition.contains(partitionKey) && orgPartition.get(partitionKey) != null) {
                String cachedJson = (String) orgPartition.get(partitionKey);
                availableStaticResourcesMap.put(resourcesName, cachedJson);
            }
        }
        return availableStaticResourcesMap;
    }


    private static void putStaticResourcesToPlatformCache(Map<String, String> missingStaticResourcesMap) {
        Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.e2elongform');
        for (String staticResourceName : missingStaticResourcesMap.keySet()) {
            String key = staticResourceName.replaceAll('_', '');
            orgPartition.put(key, missingStaticResourcesMap.get(staticResourceName), 60*60*48);
        }
    }


    private static Map<String, String> getMissingStaticResources(Map<String, String> staticResourcesFromPlatformCacheMap,
            Set<String> requestedStaticResourcesNames) {
        Set<String> missingStaticResourcesNames = new Set<String>();
        for (String requestedStaticResourcesName : requestedStaticResourcesNames) {
            if (! staticResourcesFromPlatformCacheMap.containsKey(requestedStaticResourcesName)) {
                missingStaticResourcesNames.add(requestedStaticResourcesName);
            }
        }
        Map<String, String> missingStaticResourcesMap = new Map<String, String>();
        if (! missingStaticResourcesNames.isEmpty()) {
            List<StaticResource> resourcesList = [
                    SELECT Name, Body
                    FROM StaticResource
                    WHERE Name IN :missingStaticResourcesNames];

            for (StaticResource resource : resourcesList) {
                missingStaticResourcesMap.put(resource.Name, resource.Body.toString());
            }
        }
        return missingStaticResourcesMap;
    }


    private static Map<String, Object> returnFinalSettings(String country,
                                                        String implKey,
                                                        String defaultSettingsJson,
                                                        List<String> stepResourcesList) {
        Map<String, Object> finalSettingsMap = new Map<String, Object>();
        if (! String.isEmpty(defaultSettingsJson)) {
            finalSettingsMap.putAll((Map<String, Object>) JSON.deserializeUntyped(defaultSettingsJson));
        }
        for (String stepResourceJson : stepResourcesList) {
            Map<String, Object> stepDataMap = (Map<String, Object>) JSON.deserializeUntyped(stepResourceJson);
            Map<String, Object> objectsSettingsMap = (Map<String, Object>) stepDataMap.get('settings');
            for (String objectKey : objectsSettingsMap.keySet()) {
                Map<String, Object> fieldsSettingsMap = (Map<String, Object>) objectsSettingsMap.get(objectKey);
                for (String fieldName : fieldsSettingsMap.keySet()) {
                    Map<String, Object> fieldsParamsByCountryMap = (Map<String, Object>) fieldsSettingsMap.get(fieldName);
                    if (fieldsParamsByCountryMap.containsKey(implKey)) {
                        Map<String, Object> fieldsParamsMap = (Map<String, Object>) fieldsParamsByCountryMap.get(implKey);
                        for (String fieldParam : fieldsParamsMap.keySet()) {
                            if (fieldParam != 'mapto') {
                                finalSettingsMap.put((String) fieldsParamsMap.get('mapto') + '_' + fieldParam, fieldsParamsMap.get(fieldParam));
                            }
                        }
                    }
                }
            }
            if (stepDataMap.containsKey('content_settings')) {
                Map<String, Object> contentSettingsMap = (Map<String, Object>) stepDataMap.get('content_settings');
                for (String settingsKey : contentSettingsMap.keySet()) {
                    Map<String, Object> contentSettingsByCountryMap = (Map<String, Object>) contentSettingsMap.get(settingsKey);
                    if (contentSettingsByCountryMap.containsKey(country)) {
                        finalSettingsMap.put(settingsKey, contentSettingsByCountryMap.get(country));
                    }
                }
            }
        }
        return finalSettingsMap;
    }


    private static Map<String, Object> returnAllContents(String implKey, List<String> formResourcesList, Set<String> availableLanguages) {
        Map<String, Object> allTranslationsMap = new Map<String, Object>();
        Map<String, Object> availableTranslationsMap = new Map<String, Object>();

        for (String formResourceJson : formResourcesList) {
            Map<String, Object> formResourceDataMap = (Map<String, Object>) JSON.deserializeUntyped(formResourceJson);
            if (formResourceDataMap.containsKey('translations')) {
                allTranslationsMap.putAll((Map<String, Object>) formResourceDataMap.get('translations'));
            } else {
                allTranslationsMap.putAll(formResourceDataMap);
            }
        }
        for (String translationKey : allTranslationsMap.keySet()) {
            Map<String, Object> implKeyByTranslationKeyMap = (Map<String, Object>) allTranslationsMap.get(translationKey);
            String currentImplKey = implKeyByTranslationKeyMap.containsKey(implKey) ? implKey : 'default_impl';
            Map<String, Object> langsByImplKeyMap = (Map<String, Object>) implKeyByTranslationKeyMap.get(currentImplKey);
            Map<String, Object> currentAvailableTranslationsMap = new Map<String, Object>();
            
            if (langsByImplKeyMap != null) {
                for (String language : availableLanguages) {
                    String currentLangKey = langsByImplKeyMap.containsKey(language) ? language : 'en';
                    currentAvailableTranslationsMap.put(language, langsByImplKeyMap.get(currentLangKey));
                }
                availableTranslationsMap.put(translationKey, currentAvailableTranslationsMap);
            }
        }
        return availableTranslationsMap;
    }
}