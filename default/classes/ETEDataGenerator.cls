global class ETEDataGenerator {
    public static final String sourceQR = 'QR Code';
    public static final String sourceSMS = 'SMS';
    public static final String sourceTablet = 'Tablet';
    public static final String sourceURL = 'URL';

    public static String getETEFormName(String clientNumber, String obn) {
        String formName;

        if (clientNumber == null) {
            Decimal random = Integer.valueOf(Math.random() * 100000000);
            formName = 'LongForm:' + obn + '_' + String.valueOf(random);
        } else {
            formName = 'LongForm: ' + clientNumber;
        }

        return formName;
    }


    public static List<Account> getRetailerAccount(String country, String obn) {
        Set<String> obns = new Set<String>();
        obns.add(obn);
        if (country == 'Poland') {
            obns.add('R' + obn); // someone store obns in database with R prefix, actual for Poland only
        }
        List<Account> retailerAccount = [
                SELECT BillingStreet, BillingCity, BillingCountry, OBN__c, Name_des_Mitarbeiters__c, RecordType.Name, Partnertyp__c, Type
                FROM Account
                WHERE BillingCountry = :country AND
                      OBN__c != null AND
                      OBN__c IN :obns
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if ( ! retailerAccount.isEmpty() ) {
            return retailerAccount;
        } else {
            return new List<Account>();
        }
    }


    public static Account insertAccount(String recordTypeName, String country, String formName) {
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = :recordTypeName LIMIT 1];
        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);
        Account account = new Account(
                Name = formName,
                BillingCountry = country,
                CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(countryCode),
                ShippingCountry = country,
                Type = 'Customer',
                Sec_Channel_Acc__c = 'JITB',
                AccountSource = 'Partner',
                E2E__c = true
        );
        if ( ! accountRecordTypeList.isEmpty() ) {
            account.RecordTypeId = accountRecordTypeList.get(0).Id;
        }
        insert account;

        return account;
    }


    public static Opportunity insertOpportunity(String formName,
                                                List<Account> retailerAccount,
                                                String accountId,
                                                String recordTypeName,
                                                String stageName,
                                                String country,
                                                String clientNumber,
                                                String clientSource,
                                                String obn,
                                                String e2eDataObjectId,
                                                String typeOfStation) {
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = :recordTypeName LIMIT 1];
        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);
        String languagePref = ETEGlobalUtils.returnLanguagePreference(countryCode);
        String currencyIsoCode = ETEGlobalUtils.returnCurrencyCode(countryCode);
        String homeStation;
        String retailerName;
        String retailerObn;
        String esi;
        if ( ! retailerAccount.isEmpty() ) {
            Account account = retailerAccount.get(0);
            homeStation = account.BillingStreet + ', ' + account.BillingCity + ', ' + account.BillingCountry;
            retailerName = account.Id;
            retailerObn = account.Name_des_Mitarbeiters__c;
            esi = account.OBN__c;
        }
        String pricebookId;
        if (Test.isRunningTest()) {
            pricebookId = Test.getStandardPricebookId();
        } else {
            pricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book'].Id;
        }
        Opportunity opportunity = new Opportunity(
                Name = formName,
                Pricebook2Id = pricebookId,
                E2E_Data_Object__c = e2eDataObjectId,
                E2E_Encoded_URL__c = ETEGlobalUtils.doEncryptParams(e2eDataObjectId, countryCode),
                ESI__c = esi,
                Home_Station__c = homeStation,
                StageName = stageName,
                AccountId = accountId,
                CloseDate = Date.today(),
                Language_preference__c = languagePref,
                Primary_Contact_Phone__c = clientNumber,
                E2E_2__c = true,
                Sec_Channel__c = typeOfStation,
                Channel__c = 'POS',
                LeadSource = clientSource,
                CurrencyIsoCode = currencyIsoCode,
                Type = 'New Business',
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E',
                E2E_Step__c = 'products_and_services',
                Product__c = '',
                Retailer_Name__c = retailerName,
                Retailer_Employee__c = retailerObn,
                Retailer_OBN__c = obn
        );
        if ( ! opptyRecordTypeList.isEmpty() ) {
            opportunity.RecordTypeId = opptyRecordTypeList.get(0).Id;
        }
        insert opportunity;

        opportunity.E2E_Short_Link__c = generateShortId(obn, e2eDataObjectId, country);
        update opportunity;

        return opportunity;
    }


    public static E2E_Data_Object__c insertE2EDataObject(String step, String stageName, String recordTypeName, String utmSource,
                                                         String utmMedium, String utmContent, String countryCode, String language,
                                                         String esi, String homeStation, String phone) {
        if (recordTypeName.contains('-')) {
            recordTypeName = recordTypeName.replace('-', '_');
        }

        List<RecordType> e2eDataObjectRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Object__c' AND DeveloperName = :recordTypeName LIMIT 1];
        E2E_Data_Object__c dataObject = new E2E_Data_Object__c(
                Name = 'NEW E2E CUSTOMER',
                Current_Step__c = step,
                Phone__c = phone,
                StageName__c = stageName,
                E2E_Status__c = 'In progress',
                Country_Code__c = countryCode,
                ESI__c = esi,
                Home_Station__c = homeStation,
                Current_Language__c = ETEGlobalUtils.returnDefaultLanguage(countryCode),
                Selected_Company_Name__c = 'NEW E2E CUSTOMER',
                Security_Amount_To_Pay__c = 0,
                Utm_Source__c = utmSource,
                Utm_Medium__c = utmMedium,
                Utm_Content__c = utmContent
        );
        if ( ! e2eDataObjectRecordTypeList.isEmpty() ) {
            dataObject.RecordTypeId = e2eDataObjectRecordTypeList.get(0).Id;
        }
        insert dataObject;

        return dataObject;
    }


    public static E2E_Data_Contact__c insertE2EDataContact(E2E_Data_Object__c e2EDataObject, String clientNumber, Lead lead, Contact contact) {
        E2E_Data_Contact__c e2EDataContact = new E2E_Data_Contact__c();
        e2EDataContact.E2E_Data_Object__c = e2EDataObject.Id;
        e2EDataContact.Salutation__c = 'Mr.';
        e2EDataContact.Role__c = 'Decision Maker';
        e2EDataContact.isPrimary__c = true;
        e2EDataContact.Index__c = 0;
        if (contact != null) {
            e2EDataContact.Fleetcor_Contact__c = contact.Id;
        }
        if (clientNumber != null) {
            e2EDataContact.Phone__c = clientNumber;
        }
        if (lead != null) {
            e2EDataContact.Phone__c = lead.Phone;
            e2EDataContact.First_Name__c = lead.FirstName;
            e2EDataContact.Last_Name__c = lead.LastName;
            e2EDataContact.Email__c = lead.Email;
        }
        insert e2EDataContact;

        return e2EDataContact;
    }


    public static E2E_Data_Log__c insertE2EDataLog(String recordTypeName, String dataObjectId, String jobStatus, String name) {
        List<RecordType> e2eDataLogRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Log__c' AND DeveloperName = :recordTypeName LIMIT 1];
        E2E_Data_Log__c dataLog = new E2E_Data_Log__c(
                E2E_Data_Object__c = dataObjectId,
                Job_Status__c = jobStatus,
                Name = name
        );
        if ( ! e2eDataLogRecordTypeList.isEmpty() ) {
            dataLog.RecordTypeId = e2eDataLogRecordTypeList.get(0).Id;
        }
        insert dataLog;

        return dataLog;
    }


    public static Contact insertContact(String formName, String recordTypeName, String accountId, String clientNumber, String country) {
        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = :recordTypeName LIMIT 1];
        String countryCode = ETEGlobalUtils.returnTwoLettersCountry(country);
        Contact contact = new Contact(
                Salutation = 'Mr.',
                CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(countryCode),
                LastName = formName,
                AccountId = accountId,
                Phone = clientNumber,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = country
        );
        if ( ! contactRecordTypeList.isEmpty() ) {
            contact.RecordTypeId = contactRecordTypeList.get(0).Id;
        }
        insert contact;

        return contact;
    }


    public static void insertOpportunityContactRole(String opportunityId, String contactId) {
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                OpportunityId = opportunityId,
                ContactId = contactId,
                IsPrimary = true);
        insert oppContactRole;
    }


    public static void setPartnerRelationship(List<Account> retailerAccount, String opportunityId) {
        if ( ! retailerAccount.isEmpty() ) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = retailerAccount.get(0).Id;
            newPartner.OpportunityId = opportunityId;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }
    }


    private static String generateShortId(String obnNumber, String dataObjectId, String country) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
        String finalParam;
        if (obnNumber != null) {
            finalParam = String.valueOf(obnNumber + dataObjectId);
        } else {
            finalParam = String.valueOf(dataObjectId);
        }
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(finalParam))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }
}