public class CreditFactoryService {
    
    
    /*******************************************************************************
    *  Summary         : Return Credit Factory implementation based on country.
    *  CreatedDate     : 24/01/2020 by Anton Buzak
    *  Parameters      : country - company country
    *  Returns         : credit factory implementation
    ******************************************************************************/
    public static CreditFactory returnCreditFactory(String implKey) {
        CreditFactory creditFactory;
        if (implKey == 'Poland' || implKey == 'Poland Lotos') {
            creditFactory = new CreditFactoryImplPL();
        }
        else if (implKey == 'Germany') {
            creditFactory = new CreditFactoryImplDE();
        }
        else if (implKey == 'Netherlands') {
            creditFactory = new CreditFactoryImplNL();
        }
        else if (implKey == 'Belgium-NL' || implKey == 'Belgium-FR') {
            creditFactory = new CreditFactoryImplBE();
        }
        else if (implKey == 'Slovakia') {
            creditFactory = new CreditFactoryImplSK();
        }
        else if (implKey == 'Hungary') {
            creditFactory = new CreditFactoryImplHU();
        }
        else if (implKey == 'Czech Republic') {
            creditFactory = new CreditFactoryImplCZ();
        }
        else if (implKey == 'France') {
            creditFactory = new CreditFactoryImplFR();
        }
        else if (implKey == 'Switzerland-DE' || implKey == 'Switzerland-FR' || implKey == 'Switzerland-IT') {
            creditFactory = new CreditFactoryImplCH();
        }
        else if (implKey == 'Austria') {
            creditFactory = new CreditFactoryImplAT();
        }
        else if (implKey == 'Luxembourg') {
            creditFactory = new CreditFactoryImplLU();
        }
        else if (implKey == 'Czech Republic CCS') {
            creditFactory = new CreditFactoryImplCZCCS();
        }
        else if (implKey == 'Slovakia CCS') {
            creditFactory = new CreditFactoryImplSKCCS();
        }

        return creditFactory;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Credit Factory validation implementation based on country.
    *  CreatedDate     : 24/01/2020 by Anton Buzak
    *  Parameters      : country - company country
    *  Returns         : credit Factory validation implementation
    ******************************************************************************/
    public static CreditFactoryValidation returnCreditFactoryValidation(String implKey) {
        CreditFactoryValidation creditFactoryValidation;
        if (implKey == 'Poland' || implKey == 'Poland Lotos') {
            creditFactoryValidation = new CreditFactoryValidationImplPL();
        }
        else if (implKey == 'Germany') {
            creditFactoryValidation = new CreditFactoryValidationImplDE();
        }
        else if (implKey == 'Netherlands') {
            creditFactoryValidation = new CreditFactoryValidationImplNL();
        }
        else if (implKey == 'Belgium-NL' || implKey == 'Belgium-FR') {
            creditFactoryValidation = new CreditFactoryValidationImplBE();
        }
        else if (implKey == 'Slovakia') {
            creditFactoryValidation = new CreditFactoryValidationImplSK();
        }
        else if (implKey == 'Hungary') {
            creditFactoryValidation = new CreditFactoryValidationImplHU();
        }
        else if (implKey == 'Czech Republic') {
            creditFactoryValidation = new CreditFactoryValidationImplCZ();
        }
        else if (implKey == 'France') {
            creditFactoryValidation = new CreditFactoryValidationImplFR();
        }
        else if (implKey == 'Switzerland-DE' || implKey == 'Switzerland-FR' || implKey == 'Switzerland-IT') {
            creditFactoryValidation = new CreditFactoryValidationImplCH();
        }
        else if (implKey == 'Austria') {
            creditFactoryValidation = new CreditFactoryValidationImplAT();
        }
        else if (implKey == 'Luxembourg') {
            creditFactoryValidation = new CreditFactoryValidationImplLU();
        }
        else if (implKey == 'Czech Republic CCS') {
            creditFactoryValidation = new CreditFactoryValidationImplCZCCS();
        }
        else if (implKey == 'Slovakia CCS') {
            creditFactoryValidation = new CreditFactoryValidationImplSKCCS();
        }

        return creditFactoryValidation;
    }
    
    
    /*******************************************************************************
    *  Summary         : Return Credit Factory settings implementation based on country.
    *  CreatedDate     : 28/05/2020 by Anton Buzak
    *  Parameters      : country - company country
    *  Returns         : credit Factory settings implementation
    ******************************************************************************/
    public static CreditFactorySettings returnCreditFactorySettings(String implKey) {
        CreditFactorySettings creditFactorySettings;
        if (implKey == 'Poland' || implKey == 'Poland Lotos') {
            creditFactorySettings = new CreditFactorySettingsImplPL();
        }
        else if (implKey == 'Germany') {
            creditFactorySettings = new CreditFactorySettingsImplDE();
        }
        else if (implKey == 'Netherlands') {
            creditFactorySettings = new CreditFactorySettingsImplNL();
        }
        else if (implKey == 'Belgium-NL' || implKey == 'Belgium-FR') {
            creditFactorySettings = new CreditFactorySettingsImplBE();
        }
        else if (implKey == 'Slovakia') {
            creditFactorySettings = new CreditFactorySettingsImplSK();
        }
        else if (implKey == 'Hungary') {
            creditFactorySettings = new CreditFactorySettingsImplHU();
        }
        else if (implKey == 'Czech Republic') {
            creditFactorySettings = new CreditFactorySettingsImplCZ();
        }
        else if (implKey == 'France') {
            creditFactorySettings = new CreditFactorySettingsImplFR();
        }
        else if (implKey == 'Switzerland-DE' || implKey == 'Switzerland-FR' || implKey == 'Switzerland-IT') {
            creditFactorySettings = new CreditFactorySettingsImplCH();
        }
        else if (implKey == 'Austria') {
            creditFactorySettings = new CreditFactorySettingsImplAT();
        }
        else if (implKey == 'Luxembourg') {
            creditFactorySettings = new CreditFactorySettingsImplLU();
        }
        else if (implKey == 'Czech Republic CCS') {
            creditFactorySettings = new CreditFactorySettingsImplCZCCS();
        }
        else if (implKey == 'Slovakia CCS') {
            creditFactorySettings = new CreditFactorySettingsImplSKCCS();
        }

        return creditFactorySettings;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Opportunity from database 
    *  CreatedDate     : 10/04/2020 by Anton Buzak
    *  Parameters      : opportunityId - id of opportunity
    *  Returns         : opportunity
    ******************************************************************************/
    public static Opportunity selectOpportunity(String opportunityId) {
        Opportunity opportunity = [
            SELECT Name, Credit_System_Id__c, IBAN__c, Zahlungsart__c, Einwilligung_Lastschriftverfahren__c,
                    bearbeitet_von__c, StageName, Zahlungsziel_2__c, Rechnungsperiode_2__c, RecordType.Name, Probability,
                    Total_consumption_l_month__c, Product__c, Anzahl_der_Karten__c, Derzeitige_Zahlungsmethode__c,
                    Account.Name, Credit_System_Number__c, AccountId, Zahlungsziel__c, Auftragsvolumen__c, Non_fuel_exposure__c,
                    Profit_loss_last_year__c, Profit_loss_year_before_last__c, Turnover_last_year__c, Sec_Channel__c,
                    e_Invoicing_PDF__c, Papierrechnung__c, Contact_Role_Confirmation_Call__c, Credit_Stage__c, Total_consumption_per_card__c,
                    CF_Stage__c, Visitor_ID__c, Custom_PIN__c, Credit_Factory_Errors__c, Last_CF_Errors__c, DocuSign_Status__c,
                    Total_cards_consumption_monthly__c, Owner.Name, CF_Orders__c, SWIFT_BIC__c, Requested_SWIFT_BIC__c, Direct_Debit_Mandate_Type__c,
                    SEPA_Request_Approved__c, Number_of_GPS_units__c, Account.BillingCountry
                FROM Opportunity 
                WHERE Id = :opportunityId];
        return opportunity;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Account from database 
    *  CreatedDate     : 10/04/2020 by Anton Buzak
    *  Parameters      : accountId - id of account
    *  Returns         : account
    ******************************************************************************/
    public static Account selectAccount(String accountId) {
        Account account = [
                SELECT BillingStreet, BillingCity, GFN_Nr__c, BillingCountry,
                    BillingCountryCode, BillingPostalCode, Steuernummer__c, 
                    Umsatzsteuer_ID__c, HR_Abteilung_HRA_HRB_und_HR_Nummer__c,
                    Type, Beschaeftigte__c, Name, ShippingStreet,
                    ShippingCity, ShippingPostalCode, Ort_der_Registrierung_Handelsregisterort__c,
                    Gruendungsjahr__c, Branche_NACE__c, Gesellschaftsform__c, Website
                FROM Account 
                WHERE Id = :accountId
        ];
        return account;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Account Contacts from database.
    *  CreatedDate     : 10/04/2020 by Anton Buzak
    *  Parameters      : accountId - Id of parent Account
    *  Returns         : contacts related to account
    ******************************************************************************/
    public static List<Contact> selectAccountContacts(String accountId) {
        List<Contact> contactsList = [
                SELECT FirstName, LastName, Email, Phone, MobilePhone
                FROM Contact
                WHERE AccountId = :accountId
        ];

        return contactsList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Account Contact Relation from database
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : accountId - Id of related Account
    *  Returns         : account relation contacts
    ******************************************************************************/
    public static List<AccountContactRelation> selectAccountContactRelations(String accountId) {
        List<AccountContactRelation> relationsList = [
                SELECT Account.Name, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone, Contact.MobilePhone
                FROM AccountContactRelation
                WHERE AccountId = :accountId
        ];

        return relationsList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Opportunity Contact Roles from database
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : accountId - Id of Opportunity
    *  Returns         : opportunity contact roles
    ******************************************************************************/
    public static List<OpportunityContactRole> selectOpportunityContactRoles(String opportunityId) {
        List<OpportunityContactRole> contactRolesList = [
                SELECT IsPrimary, Contact.Email, Contact.FirstName, Contact.LastName, 
                    Contact.Phone, Contact.MobilePhone, Role, Contact.Birthdate
                FROM OpportunityContactRole
                WHERE OpportunityId = :opportunityId
        ];
        
        return contactRolesList;
    }
    
    /*******************************************************************************
    *  Summary         : Select Opportunity Contact Roles from database
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : opportunityId - Id of Opportunity
    *  Returns         : opportunity contact roles
    ******************************************************************************/
    public static List<dsfs__DocuSign_Status__c> selectDocuSignStatusesList(String opportunityId) {
        List<dsfs__DocuSign_Status__c> dsStatusesList = [
                SELECT dsfs__Completed_Date_Time__c, Document_name__c, dsfs__Envelope_Status__c, (
                        SELECT Name
                        FROM R00NS0000000WUO2MAO__r)
                FROM dsfs__DocuSign_Status__c
                WHERE dsfs__Opportunity__c = :opportunityId];
        
        return dsStatusesList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Tankkartens form database   
    *  Created         : 17/04/2020 by Anton Buzak
    *  Parameters      : opportunityId - Id of Opportunity
    *  Returns         : list of tankkartens
    ******************************************************************************/
    public static List<Tankkarten__c> selectTankkartens(String opportunityId) {
        List<Tankkarten__c> tankkartensList = [
		        SELECT Id
		        FROM Tankkarten__c
		        WHERE Opportunity__c = :opportunityId];
        return tankkartensList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Opportunity Line Items from database
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : opportunityId - Id of Opportunity
    *  Returns         : line items list
    ******************************************************************************/
    public static List<OpportunityLineItem> selectLineItems(String opportunityId) {
        List<OpportunityLineItem> lineItemsList = [
                SELECT Product2.Family
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId];
        
        return lineItemsList;
    }
    
    
    /*******************************************************************************
    *  Summary         : Select Ofer Items from database
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : opportunityId - Id of Opportunity
    *  Returns         : ofer items list
    ******************************************************************************/
    public static List<Offer_Item__c> selectOfferItems(Set<Id> lineItemsIdsSet) {
        List<Offer_Item__c> offerItemsList = [
                SELECT Opportunity_Product_Id__c, Monthly_card_limit_value__c
                FROM Offer_Item__c
                WHERE Opportunity_Product_Id__c = :lineItemsIdsSet];
        
        return offerItemsList;
    }


    /*******************************************************************************
    *  Summary         : Select Attachments
    *  Created         : 10/08/2020 by Anton Buzak
    *  Parameters      : opportunityId - Id of Opportunity
    *  Returns         : attachments
    ******************************************************************************/
    public static List<Attachment> selectAttachmentsList(String opportunityId) {
        List<Attachment> attachmentsList = [
                SELECT Name, Description, Body
                FROM Attachment
                WHERE ParentId = :opportunityId];
        return attachmentsList;
    }


    /*******************************************************************************
    *  Summary         : Select ContentDocumentLinks
    *  Created         : 14/09/2020 by Ivan Kulinkovich
    *  Parameters      : opportunityId - Id of Opportunity
    *  Returns         : contentDocumentLinks
    ******************************************************************************/
    public static List<ContentVersion> selectFilesList(String opportunityId) {
        List<ContentDocumentLink> filesList = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :opportunityId];

        Set<Id> filesIdsSet = new Set<Id>();
        for (ContentDocumentLink file : filesList) {
            filesIdsSet.add(file.ContentDocumentId);
        }

        List<ContentVersion> contentVersionsList = [
                SELECT Title, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId IN :filesIdsSet
        ];

        return contentVersionsList;
    }


    /*******************************************************************************
    *  Summary         : Select ContentDocumentLinks
    *  Created         : 10/03/2021 by Ivan Kulinkovich
    *  Parameters      : String country
    *  Returns         : List<Credit_Factory_Calculation__c>
    ******************************************************************************/
    public static List<Credit_Factory_Calculation__c> selectCreditFactoryCalculationsList(String country) {
        if (country.contains('-')) {
            country = country.substringBefore('-');
        }

        List<Credit_Factory_Calculation__c> calculationsList = [
                SELECT Name, Class_Rating__c, Date_of_Foundation_month__c, Number_of_Cards__c, Country__c, Payment_Detail__c,
                        Total_Consumption_Min_Value__c, Total_Consumption_Max_Value__c, Order__c, Security_Level__c,
                        New_Business_Exception__c, Deposit_Reason__c, High_Risk__c
                FROM Credit_Factory_Calculation__c
                WHERE Country__c = :country
                ORDER BY Order__c
        ];

        return calculationsList;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate data structure   
    *  Created         : 10/04/2020
    *  Parameters      : sObjectsList - list of account, opportunity, contacts etc.
    *  Returns         : data structure
    ******************************************************************************/
    public static Map<String, Object> generateDataStructureMap(List<SObject> sObjectsList) {
        Map<String, Object> dataStructureMap = new Map<String, Object>();
        for (SObject sObj : sObjectsList) {
            if (sObj.getSObjectType() == Schema.Opportunity.getSObjectType()) {
                Opportunity opportunity = (Opportunity) sObj;
                Map<String, Object> opportunityDataStructureMap = generateOpportunityDataStructure(opportunity);
                dataStructureMap.putAll(opportunityDataStructureMap);
            }
            else if (sObj.getSObjectType() == Schema.Account.getSObjectType()) {
                Account account = (Account) sObj;
                Map<String, Object> accountDataStructureMap = generateAccountDataStructure(account);
                dataStructureMap.putAll(accountDataStructureMap);
            }
            else if (sObj.getSObjectType() == Schema.Contact.getSObjectType()) {
                Contact contact = (Contact) sObj;
                Map<String, Object> contactsDataMap = generateContactDataStructure(contact);
                List<Map<String, Object>> creditFactoryContactsList = generateStructureValuesList(dataStructureMap, 'creditFactoryContacts', contactsDataMap);
                dataStructureMap.put('creditFactoryContacts', creditFactoryContactsList);
            }
            else if (sObj.getSObjectType() == Schema.AccountContactRelation.getSObjectType()) {
                AccountContactRelation accountContactRelation = (AccountContactRelation) sObj;
                Map<String, Object> contactsDataMap = generateAccountContactRelationDataStructure(accountContactRelation);
                List<Map<String, Object>> creditFactoryContactsList = generateStructureValuesList(dataStructureMap, 'creditFactoryContacts', contactsDataMap);
                dataStructureMap.put('creditFactoryContacts', creditFactoryContactsList);
            }
            else if (sObj.getSObjectType() == Schema.OpportunityContactRole.getSObjectType()) {
                OpportunityContactRole opportunityContactRole = (OpportunityContactRole) sObj;
                Map<String, Object> contactsDataMap = generateOpportunityContactRoleStructure(opportunityContactRole);
                List<Map<String, Object>> creditFactoryContactsList = generateStructureValuesList(dataStructureMap, 'creditFactoryContacts', contactsDataMap);
                dataStructureMap.put('creditFactoryContacts', creditFactoryContactsList);
            }
            else if (sObj.getSObjectType() == Schema.dsfs__DocuSign_Status__c.getSObjectType()) {
                dsfs__DocuSign_Status__c docuSignStatus = (dsfs__DocuSign_Status__c) sObj;
                Map<String, Object> documentsDataMap = generateDocumentStructure(docuSignStatus);
                List<Map<String, Object>> documentsList = generateStructureValuesList(dataStructureMap, 'documentsStatusesList', documentsDataMap);
                dataStructureMap.put('documentsStatusesList', documentsList);
            }
            else if (sObj.getSObjectType() == Schema.Tankkarten__c.getSObjectType()) {
                Tankkarten__c card = (Tankkarten__c) sObj;
                Map<String, Object> cardsDataMap = generateTankkartenStructure(card);
                List<Map<String, Object>> cardsList = generateStructureValuesList(dataStructureMap, 'cards', cardsDataMap);
                dataStructureMap.put('cards', cardsList);
            }
            else if (sObj.getSObjectType() == Schema.OpportunityLineItem.getSObjectType()) {
                OpportunityLineItem lineItem = (OpportunityLineItem) sObj;
                Map<String, Object> lineItemsDataMap = generateLineItemStructure(lineItem);
                List<Map<String, Object>> lineItemsList = generateStructureValuesList(dataStructureMap, 'lineItems', lineItemsDataMap);
                dataStructureMap.put('lineItems', lineItemsList);
            }
            else if (sObj.getSObjectType() == Schema.Offer_Item__c.getSObjectType()) {
                Offer_Item__c offerItem = (Offer_Item__c) sObj;
                Map<String, Object> offerItemsDataMap = generateOfferItemStructure(offerItem);
                List<Map<String, Object>> offerItemsList = generateStructureValuesList(dataStructureMap, 'offerItems', offerItemsDataMap);
                dataStructureMap.put('offerItems', offerItemsList);
            }
            else if (sObj.getSObjectType() == Schema.Attachment.getSObjectType()) {
                Attachment attachment = (Attachment) sObj;
                Map<String, Object> attachmentsDataStructureMap = generateAttachmentsDataStructure(attachment);
                List<Map<String, Object>> attachmentsList = generateStructureValuesList(dataStructureMap, 'attachments', attachmentsDataStructureMap);
                dataStructureMap.put('attachments', attachmentsList);
            }
            else if (sObj.getSObjectType() == Schema.ContentVersion.getSObjectType()) {
                ContentVersion file = (ContentVersion) sObj;
                Map<String, Object> filesDataStructureMap = generateFilesDataStructure(file);
                List<Map<String, Object>> filesList = generateStructureValuesList(dataStructureMap, 'files', filesDataStructureMap);
                dataStructureMap.put('files', filesList);
            }
            else if (sObj.getSObjectType() == Schema.Credit_Factory_Calculation__c.getSObjectType()) {
                Credit_Factory_Calculation__c calculation = (Credit_Factory_Calculation__c) sObj;
                Map<String, Object> calculationsDataStructureMap = generateCalculationDataStructure(calculation);
                List<Map<String, Object>> calculationsList = generateStructureValuesList(dataStructureMap, 'calculations', calculationsDataStructureMap);
                dataStructureMap.put('calculations', calculationsList);
            }
        }
        
        return dataStructureMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Opportunity
    *  Created         : 10/04/2020
    *  Parameters      : opportunity - opportunity 
    *  Returns         : structure based on opportunity
    ******************************************************************************/
    private static Map<String, Object> generateOpportunityDataStructure(Opportunity opportunity) {
        Map<String, Object> opportunityDataStructureMap = new Map<String, Object>();
        opportunityDataStructureMap.put('opportunityId', opportunity.Id);
        opportunityDataStructureMap.put('paymentMethod', opportunity.Zahlungsart__c);
        opportunityDataStructureMap.put('directDebitFormAvailable', opportunity.Einwilligung_Lastschriftverfahren__c);
        opportunityDataStructureMap.put('directDebitMandateType', opportunity.Direct_Debit_Mandate_Type__c);
        opportunityDataStructureMap.put('iban', opportunity.IBAN__c);
        opportunityDataStructureMap.put('processedBy', opportunity.bearbeitet_von__c);
        opportunityDataStructureMap.put('cfStage', opportunity.CF_Stage__c);
        opportunityDataStructureMap.put('desiredBillingPeriod', opportunity.Zahlungsziel_2__c);
        opportunityDataStructureMap.put('desiredPaymentTerms', opportunity.Rechnungsperiode_2__c);
        opportunityDataStructureMap.put('recordType', opportunity.RecordType.Name);
        opportunityDataStructureMap.put('probability', opportunity.Probability);
        opportunityDataStructureMap.put('nonFuelExposure', opportunity.Non_fuel_exposure__c);
        opportunityDataStructureMap.put('product', opportunity.Product__c);
        opportunityDataStructureMap.put('numberOfCards', opportunity.Anzahl_der_Karten__c);
        opportunityDataStructureMap.put('paymentTerms', opportunity.Zahlungsziel__c);
        opportunityDataStructureMap.put('opportunityName', opportunity.Name);
        opportunityDataStructureMap.put('creditSystemNumber', opportunity.Credit_System_Number__c);
        opportunityDataStructureMap.put('profitLossLastYear', opportunity.Profit_loss_last_year__c);
        opportunityDataStructureMap.put('profitLossYearBeforeLast', opportunity.Profit_loss_year_before_last__c);
        opportunityDataStructureMap.put('turnOverLastYear', opportunity.Turnover_last_year__c);
        opportunityDataStructureMap.put('eInvoice', opportunity.e_Invoicing_PDF__c);
        opportunityDataStructureMap.put('paperInvoice', opportunity.Papierrechnung__c);
        opportunityDataStructureMap.put('contactRoleConfirmationCall', opportunity.Contact_Role_Confirmation_Call__c);
        opportunityDataStructureMap.put('visitorId', opportunity.Visitor_ID__c);
        opportunityDataStructureMap.put('customPin', opportunity.Custom_PIN__c);
        opportunityDataStructureMap.put('cfErrors', opportunity.Credit_Factory_Errors__c);
        opportunityDataStructureMap.put('lastCfErrors', opportunity.Last_CF_Errors__c);
        opportunityDataStructureMap.put('docuSignStatus', opportunity.DocuSign_Status__c);
        opportunityDataStructureMap.put('creditSystemCompanyNumber', opportunity.Credit_System_Id__c);
        opportunityDataStructureMap.put('ownerName', opportunity.Owner.Name);
        opportunityDataStructureMap.put('cfOrders', opportunity.CF_Orders__c);
        opportunityDataStructureMap.put('swiftBic', opportunity.SWIFT_BIC__c);
        opportunityDataStructureMap.put('requestedSwiftBic', opportunity.Requested_SWIFT_BIC__c);
        opportunityDataStructureMap.put('sepaRequestApproved', opportunity.SEPA_Request_Approved__c);
        opportunityDataStructureMap.put('numberOfGpsUnits', opportunity.Number_of_GPS_units__c);
        opportunityDataStructureMap.put('secChannel', opportunity.Sec_Channel__c);
        if (opportunity.RecordType.Name == 'Lotos') {
            opportunityDataStructureMap.put('stage', opportunity.Credit_Stage__c);
            if (opportunity.Total_consumption_l_month__c != null && opportunity.Total_consumption_l_month__c != 0) {
                opportunityDataStructureMap.put('totalConsumption', opportunity.Total_consumption_l_month__c);
            }
            else if (opportunity.Total_consumption_per_card__c != null && opportunity.Total_consumption_per_card__c != 0) {
                opportunityDataStructureMap.put('totalConsumption', opportunity.Total_consumption_per_card__c);
            }
            else {
                opportunityDataStructureMap.put('totalConsumption', opportunity.Total_cards_consumption_monthly__c);
            }
        }
        else {
            opportunityDataStructureMap.put('stage', opportunity.StageName);
            opportunityDataStructureMap.put('totalConsumption', opportunity.Total_consumption_l_month__c);
        }

        return opportunityDataStructureMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Account
    *  Created         : 10/04/2020
    *  Parameters      : account - account 
    *  Returns         : structure based on Account
    ******************************************************************************/
    private static Map<String, Object> generateAccountDataStructure(Account account) {
        Map<String, Object> accountDataStructureMap = new Map<String, Object>();
        accountDataStructureMap.put('name', account.Name);
        accountDataStructureMap.put('accountId', account.Id);
        accountDataStructureMap.put('registeredStreet', account.BillingStreet);
        accountDataStructureMap.put('registeredCity', account.BillingCity);
        accountDataStructureMap.put('country', account.BillingCountry);
        accountDataStructureMap.put('countryCode', account.BillingCountryCode);
        accountDataStructureMap.put('registeredPostCode', account.BillingPostalCode);
        accountDataStructureMap.put('taxId', account.Steuernummer__c);
        accountDataStructureMap.put('vatNumber', account.Umsatzsteuer_ID__c);
        accountDataStructureMap.put('tradeRegisterNumber', account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c);
        accountDataStructureMap.put('type', account.Type);
        accountDataStructureMap.put('numberOfEmployees', account.Beschaeftigte__c);
        accountDataStructureMap.put('shippingStreet', account.ShippingStreet);
        accountDataStructureMap.put('shippingCity', account.ShippingCity);
        accountDataStructureMap.put('shippingPostCode', account.ShippingPostalCode);
        accountDataStructureMap.put('countyCourt', account.Ort_der_Registrierung_Handelsregisterort__c);
        accountDataStructureMap.put('yearOfFoundation', account.Gruendungsjahr__c);
        accountDataStructureMap.put('industry', account.Branche_NACE__c);
        accountDataStructureMap.put('legalForm', account.Gesellschaftsform__c);
        accountDataStructureMap.put('website', account.Website);
        
        return accountDataStructureMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Contact
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : contact - contact
    *  Returns         : structure based on Contact
    ******************************************************************************/
    private static Map<String, Object> generateContactDataStructure(Contact contact) {
        Map<String, Object> contactsDataMap = new Map<String, Object>();
        contactsDataMap.put('firstName', contact.FirstName);
        contactsDataMap.put('lastName', contact.LastName);
        contactsDataMap.put('email', contact.Email);
        contactsDataMap.put('phone', contact.Phone);
        contactsDataMap.put('mobilePhone', contact.MobilePhone);
        contactsDataMap.put('id', contact.Id);
        contactsDataMap.put('relation', 'Account');
        
        return contactsDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Account Contact Relation
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : accountContactRelation - account contact celation
    *  Returns         : structure based on Account Contact Relation
    ******************************************************************************/
    private static Map<String, Object> generateAccountContactRelationDataStructure(AccountContactRelation accountContactRelation) {
        Map<String, Object> contactsDataMap = new Map<String, Object>();
        contactsDataMap.put('firstName', accountContactRelation.Contact.FirstName);
        contactsDataMap.put('lastName', accountContactRelation.Contact.LastName);
        contactsDataMap.put('email', accountContactRelation.Contact.Email);
        contactsDataMap.put('phone', accountContactRelation.Contact.Phone);
        contactsDataMap.put('mobilePhone', accountContactRelation.Contact.MobilePhone);
        contactsDataMap.put('id', accountContactRelation.Contact.Id);
        contactsDataMap.put('relation', 'AccountContactRelation');
        
        return contactsDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Opportunity Contact Role
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : opportunityContactRole - opportunity contact role
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    private static Map<String, Object> generateOpportunityContactRoleStructure(OpportunityContactRole opportunityContactRole) {
        Map<String, Object> contactsDataMap = new Map<String, Object>();
        contactsDataMap.put('firstName', opportunityContactRole.Contact.FirstName);
        contactsDataMap.put('lastName', opportunityContactRole.Contact.LastName);
        contactsDataMap.put('email', opportunityContactRole.Contact.Email);
        contactsDataMap.put('phone', opportunityContactRole.Contact.Phone);
        contactsDataMap.put('mobilePhone', opportunityContactRole.Contact.MobilePhone);
        contactsDataMap.put('id', opportunityContactRole.Contact.Id);
        contactsDataMap.put('isPrimary', opportunityContactRole.IsPrimary);
        contactsDataMap.put('role', opportunityContactRole.Role);
        contactsDataMap.put('relation', 'OpportunityContactRole');
        contactsDataMap.put('dateOfBirth', opportunityContactRole.Contact.Birthdate);
        
        return contactsDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Opportunity Contact Role
    *  Created         : 10/04/2020 by Anton Buzak
    *  Parameters      : opportunityContactRole - opportunity contact role
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    private static Map<String, Object> generateDocumentStructure(dsfs__DocuSign_Status__c dsStatus) {
        Map<String, Object> documentDataMap = new Map<String, Object>();
        documentDataMap.put('name', dsStatus.Document_name__c);
        documentDataMap.put('status', dsStatus.dsfs__Envelope_Status__c);
        documentDataMap.put('completedDate', dsStatus.dsfs__Completed_Date_Time__c);
        
        List<Map<String, Object>> documentRecipientsDataList = new List<Map<String, Object>>();
        for (dsfs__DocuSign_Recipient_Status__c documentRecipient : dsStatus.R00NS0000000WUO2MAO__r) {
            Map<String, Object> documentRecipientsDataMap = new Map<String, Object>();
            documentRecipientsDataMap.put('name', documentRecipient.Name);
            documentRecipientsDataList.add(documentRecipientsDataMap);
        }
        
        documentDataMap.put('documentRecipients', documentRecipientsDataList);
        
        return documentDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Tankkarten
    *  Created         : 17/04/2020 by Anton Buzak
    *  Parameters      : tankkarten - tankkarten related to opportunity
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    private static Map<String, Object> generateTankkartenStructure(Tankkarten__c tankkarten) {
        Map<String, Object> tankkartenDataMap = new Map<String, Object>();
        return tankkartenDataMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Opportunity Line Item
    *  Created         : 17/04/2020 by Anton Buzak
    *  Parameters      : lineItem - opportunity line item
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    private static Map<String, Object> generateLineItemStructure(OpportunityLineItem lineItem) {
        Map<String, Object> lineItemsMap = new Map<String, Object>();
        lineItemsMap.put('productFamily', lineItem.Product2.Family);
        lineItemsMap.put('id', lineItem.Id);
        return lineItemsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate structure based on Opportunity Line Item
    *  Created         : 17/04/2020 by Anton Buzak
    *  Parameters      : opportunityContactRole - opportunity contact role
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    private static Map<String, Object> generateOfferItemStructure(Offer_Item__c offerItem) {
        Map<String, Object> offerItemsMap = new Map<String, Object>();
        offerItemsMap.put('productId', offerItem.Opportunity_Product_Id__c);
        offerItemsMap.put('monthlyCardLimit', offerItem.Monthly_card_limit_value__c);
        return offerItemsMap;
    }


    /*******************************************************************************
    *  Summary         : generate structure based on Attachments
    *  Created         : 10/08/2020 by Anton Buzak
    *  Parameters      : attachment - attachment
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    public static Map<String, Object> generateAttachmentsDataStructure(Attachment attachment) {
        Map<String, Object> attachmentsMap = new Map<String, Object>();
        attachmentsMap.put('name', attachment.Name);
        attachmentsMap.put('description', attachment.Description);
        return attachmentsMap;
    }

    /*******************************************************************************
    *  Summary         : generate structure based on Files
    *  Created         : 14/09/2020 by Ivan Kulinkovich
    *  Parameters      : ContentDocumentLink - file
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    public static Map<String, Object> generateFilesDataStructure(ContentVersion file) {
        Map<String, Object> filesMap = new Map<String, Object>();
        filesMap.put('title', file.Title);
        return filesMap;
    }


    /*******************************************************************************
    *  Summary         : generate structure based on Credit Factory Calculations
    *  Created         : 09/03/2021 by Ivan Kulinkovich
    *  Parameters      : Credit_Factory_Calculation__c calculation
    *  Returns         : structure based on Opportunity Contact Role
    ******************************************************************************/
    private static Map<String, Object> generateCalculationDataStructure(Credit_Factory_Calculation__c calculation) {
        Map<String, Object> calculationsMap = new Map<String, Object>();
        calculationsMap.put('country', calculation.Country__c);
        calculationsMap.put('classRating', calculation.Class_Rating__c);
        String regexToFindOperator = '[^(0-9)+]';
        String regexToFindNumber = '[0-9]+';
        if (calculation.Date_of_Foundation_month__c != null) {
            String dateOfFoundationMonths = calculation.Date_of_Foundation_month__c.replaceAll(regexToFindOperator, '');
            String dateOfFoundationMonthsOperator = calculation.Date_of_Foundation_month__c.replaceAll(regexToFindNumber, '');
            calculationsMap.put('dateOfFoundationMonths', dateOfFoundationMonths);
            calculationsMap.put('dateOfFoundationMonthsOperator', dateOfFoundationMonthsOperator);
        }

        if (calculation.Number_of_Cards__c != null) {
            String numberOfCards = calculation.Number_of_Cards__c.replaceAll(regexToFindOperator, '');
            String numberOfCardsOperator = calculation.Number_of_Cards__c.replaceAll(regexToFindNumber, '');
            calculationsMap.put('numberOfCards', numberOfCards);
            calculationsMap.put('numberOfCardsOperator', numberOfCardsOperator);
        }

        calculationsMap.put('totalConsumptionMinValue', calculation.Total_Consumption_Min_Value__c);
        calculationsMap.put('totalConsumptionMaxValue', calculation.Total_Consumption_Max_Value__c);
        calculationsMap.put('securityLevel', calculation.Security_Level__c);
        calculationsMap.put('order', calculation.Order__c);
        calculationsMap.put('paymentDetail', calculation.Payment_Detail__c);
        calculationsMap.put('newBusinessException', calculation.New_Business_Exception__c);
        calculationsMap.put('depositReason', calculation.Deposit_Reason__c);
        calculationsMap.put('highRisk', calculation.High_Risk__c);

        return calculationsMap;
    }
    
    
    /*******************************************************************************
    *  Summary         : generate list of structure values   
    *  Created         : 17/04/2020
    *  Parameters      : -
    *  Returns         : list of structure values
    ******************************************************************************/
    public static List<Map<String, Object>> generateStructureValuesList(Map<String, Object> dataStructureMap, String valueType, Map<String, Object> valuesMap) {
        List<Map<String, Object>> offerItemsList = new List<Map<String, Object>>();
        if (dataStructureMap.containsKey(valueType)) {
            offerItemsList = (List<Map<String, Object>>) dataStructureMap.get(valueType);
        }
        
        offerItemsList.add(valuesMap);
        return offerItemsList;
    }
}