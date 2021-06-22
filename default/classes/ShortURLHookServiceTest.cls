@isTest
private class ShortURLHookServiceTest {

    // LinkRedirectController, TwilioSMSHookController

    public static final String COUNTRY_DE = 'Germany';
    public static final String COUNTRY_PL = 'Poland';
    public static final String COUNTRY_CHDE = 'Switzerland-DE';
    final static String client_number = '+0000000000';
    final static String obnNumberDE = '000000';
    final static String obnNumberPL = 'R000001';
    final static String nonexisting_obnNumber = '0001000';
    public static String existing_short_urlDE;
    public static String existing_encoded_urlDE;
    public static String existing_short_urlPL;
    public static String existing_encoded_urlPL;

    @isTest
    static void smsControllerTestDE() {
        OpportunityTriggerHandler.enablesTrigger = false;
        prepareRecordsDE();
        Test.startTest();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/twiliohook';
            req.httpMethod = 'POST';
            req.addParameter('from','123456789');
            req.addParameter('body','000000');
            req.addParameter('country','Germany');
            RestContext.request = req;
            String res = TwilioSMSHookController.getPost();
            System.assert(res.contains('{"link":"'));
        Test.stopTest();
    }

    @isTest
    static void smsControllerTestPL() {
        OpportunityTriggerHandler.enablesTrigger = false;
        prepareRecordsPL();
        Test.startTest();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/twiliohook';
            req.httpMethod = 'POST';
            req.addParameter('from','123456789');
            req.addParameter('body','000001');
            req.addParameter('country','Poland');
            RestContext.request = req;
            String res = TwilioSMSHookController.getPost();
            System.assert(res.contains('{"link":"'));
        Test.stopTest();
    }

    @isTest
    static void smsLotosCase1TestPL() {
        String lotosObn = 'LOTOSP123';
        Boolean isLotosPartnerExistInDataBase = true;
        prepareRecordsLotosPL(lotosObn, isLotosPartnerExistInDataBase);
        Test.startTest();
        RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/twiliohook';
            req.httpMethod = 'POST';
            req.addParameter('from', '123456789');
            req.addParameter('body', lotosObn);
            req.addParameter('country', 'Poland');
            RestContext.request = req;
            String res = TwilioSMSHookController.getPost();
        Test.stopTest();
        List<Opportunity> oppList = [SELECT E2E_Short_Link__c FROM Opportunity];
        System.assert(res.contains(oppList.get(0).E2E_Short_Link__c));
    }

    @isTest
    static void smsLotosCase2TestPL() {
        String lotosObn = 'LOTOS123';
        Boolean isLotosPartnerExistInDataBase = true;
        prepareRecordsLotosPL(lotosObn, isLotosPartnerExistInDataBase);
        Test.startTest();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/twiliohook';
            req.httpMethod = 'POST';
            req.addParameter('from', '123456789');
            req.addParameter('body', lotosObn);
            req.addParameter('country', 'Poland');
            RestContext.request = req;
            String res = TwilioSMSHookController.getPost();
        Test.stopTest();
        List<Opportunity> oppList = [SELECT E2E_Short_Link__c FROM Opportunity];
        System.assert(res.contains(oppList.get(0).E2E_Short_Link__c));
    }

    @isTest
    static void smsLotosCase3TestPL() {
        String lotosObn = '123';
        Boolean isLotosPartnerExistInDataBase = false;
        prepareRecordsLotosPL(lotosObn, isLotosPartnerExistInDataBase);
        Test.startTest();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/twiliohook';
            req.httpMethod = 'POST';
            req.addParameter('from', '123456789');
            req.addParameter('body', lotosObn);
            req.addParameter('country', 'Poland');
            RestContext.request = req;
            String res = TwilioSMSHookController.getPost();
        Test.stopTest();
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance('Poland');
        System.assertEquals(e2eShortUrlDetail.E2E_Form_Url__c, 'https://online.fleetcor.pl/etepl');
    }


    private static void prepareRecordsPL() {
        String base_url = Url.getSalesforceBaseUrl().toString();
        List<SObject> custom_settings = new List<SObject>();

        E2E_Form_General_Settings__c settingseE2EFormGeneral = new E2E_Form_General_Settings__c();
        settingseE2EFormGeneral.Name = 'Poland';
        settingseE2EFormGeneral.Enable_authorization_non_granted_check__c = false;
        settingseE2EFormGeneral.Files_Generator_Url__c = base_url;
        settingseE2EFormGeneral.Payment_URL__c = base_url;
        settingseE2EFormGeneral.Set_GFN_Status__c = false;
        settingseE2EFormGeneral.Test_Mode__c = false;
        custom_settings.add(settingseE2EFormGeneral);

        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Poland';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etepl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2E_Short_Url__c settingsE2EShortUrl2 = new E2E_Short_Url__c();
        settingsE2EShortUrl2.Name = 'Germany';
        settingsE2EShortUrl2.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl2.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl2.E2E_Form_Url__c = base_url + '/etede';
        settingsE2EShortUrl2.E2E_JITB_Form_Url__c = base_url + '/e2ejitblocator';
        custom_settings.add(settingsE2EShortUrl2);

        E2EKeysAPI__c settingsEKeysAPIPL = new E2EKeysAPI__c(Name = 'E2EFormPL', AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=', paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp', PSPID__c = 'fleetcorTEST', SHA_KeyIn__c = 'FleetcorTest!12@', SHA_KeyOut__c = 'IngenFleetTest1!');
        custom_settings.add(settingsEKeysAPIPL);
        E2EKeysAPI__c settingsEKeysAPIDE = new E2EKeysAPI__c(Name = 'E2EForm', AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=', paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp', PSPID__c = 'fleetcorTEST', SHA_KeyIn__c = 'FleetcorTest!12@', SHA_KeyOut__c = 'IngenFleetTest1!');
        custom_settings.add(settingsEKeysAPIDE);

        insert custom_settings;

        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumberPL,
                Name = 'ValidOBN2',
                ShippingCountry = 'Poland',
                BillingCountry = 'Poland',
                BillingCity = 'Warsaw',
                BillingStreet = 'Strasse',
                Type = 'Customer',
                E2E__c = true);
        insert retailerAccount;


        List<Account> checkRetailer = [SELECT BillingStreet,BillingCity,BillingCountry FROM Account WHERE BillingCountry = :COUNTRY_PL AND OBN__c != null AND OBN__c = :obnNumberPL ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumberPL;
            station = checkRetailer.get(0);
            homestation = station.BillingStreet +', '+station.BillingCity+', '+station.BillingCountry;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumberPL + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Poland',
                ShippingCountry = 'Poland',
                Type = 'Customer',
                E2E__c = true);
        insert account;

        // Opportunity creation
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = '',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'Polish',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'SMS',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity;

        Datetime to_be_removed_time = Datetime.now().addDays(-4).addHours(1);
        Opportunity opportunity2 = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = 'Shell Basic 2020',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'Polish',
                Primary_Contact_Phone__c = client_number,
                Agree_to_process_pers_data_for_marketing__c = true,
                Agree_to_telephone_contact__c = true,
                Agree_to_receive_comm_info_by_email__c = true,
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'Tablet',
                CurrencyIsoCode = 'PLN',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity2;
        Test.setCreatedDate(opportunity2.Id, to_be_removed_time);

        // Contact creation
        Contact contact = new Contact(
                Salutation = 'Mrs',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Poland');
        insert contact;

        // create contact role
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                OpportunityId = opportunity.Id,
                ContactId = contact.Id,
                IsPrimary = true);
        insert oppContactRole;

        if (station != null) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = station.Id;
            newPartner.OpportunityId = opportunity.Id;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }

        opportunity.E2E_Short_Link__c = generateShortId(obnNumberPL, opportunity.Id);
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EFormPL');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        existing_short_urlPL = opportunity.E2E_Short_Link__c;
        existing_encoded_urlPL = opportunity.E2E_Encoded_URL__c;
    }

    private static void prepareRecordsLotosPL(String obn, Boolean isPartnerExist) {
        String base_url = 'https://online.fleetcor.pl';
        List<SObject> custom_settings = new List<SObject>();
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Poland';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etepl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);
        insert custom_settings;

        E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c(Name = 'E2EFormPL', AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=', paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp', PSPID__c = 'fleetcorTEST', SHA_KeyIn__c = 'FleetcorTest!12@', SHA_KeyOut__c = 'IngenFleetTest1!');
        insert settingsEKeysAPI;

        if (isPartnerExist) {
            Account lotosPartner = new Account(
                    Name = 'LOTOS',
                    Phone = '+48123321321321',
                    Partnertyp__c = 'Lotos partner',
                    OBN__c = obn,
                    BillingCountry = 'Poland'
            );
            insert lotosPartner;
        }
    }

    private static void prepareRecordsDE() {
        String base_url = Url.getSalesforceBaseUrl().toString();
        List<SObject> custom_settings = new List<SObject>();

        E2E_Form_General_Settings__c settingseE2EFormGeneral = new E2E_Form_General_Settings__c();
        settingseE2EFormGeneral.Name = 'Germany';
        settingseE2EFormGeneral.Enable_authorization_non_granted_check__c = false;
        settingseE2EFormGeneral.Files_Generator_Url__c = base_url;
        settingseE2EFormGeneral.Payment_URL__c = base_url;
        settingseE2EFormGeneral.Set_GFN_Status__c = false;
        settingseE2EFormGeneral.Test_Mode__c = false;
        custom_settings.add(settingseE2EFormGeneral);

        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etede';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        ShortLinkEmailNotification__c notifications = new ShortLinkEmailNotification__c();
        notifications.Name = 'roman.rastriga@fleetcor.ru';
        custom_settings.add(notifications);

        E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c();
        settingsEKeysAPI.Name = 'E2EForm';
        settingsEKeysAPI.AES256_Key__c = 'MTIzNDU2Nzg5MDEyMzQ1NjEyMzQ1Njc4OTAxMjM0NTY=';
        custom_settings.add(settingsEKeysAPI);

        ShortLinkOBNsRefreshed__c cachedOBN = new ShortLinkOBNsRefreshed__c(Name = obnNumberDE);
        ShortLinkOBNsRefreshed__c cachedOBN2 = new ShortLinkOBNsRefreshed__c(Name = nonexisting_obnNumber);
        custom_settings.add(cachedOBN);
        custom_settings.add(cachedOBN2);

        insert custom_settings;

        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumberDE,
                Name = 'ValidOBN',
                ShippingCountry = 'Germany',
                BillingCountry = 'Germany',
                BillingCity = 'Berlin',
                BillingStreet = 'Strasse',
                Type = 'Customer',
                E2E__c = true);
        insert retailerAccount;


        List<Account> checkRetailer = [SELECT BillingStreet,BillingCity,BillingCountry FROM Account WHERE BillingCountry = :COUNTRY_DE AND OBN__c != null AND OBN__c = :obnNumberDE ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumberDE;
            station = checkRetailer.get(0);
            homestation = station.BillingStreet +', '+station.BillingCity+', '+station.BillingCountry;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumberDE + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Germany',
                ShippingCountry = 'Germany',
                Type = 'Customer',
                E2E__c = true);
        insert account;

        // Opportunity creation
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = '',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'German',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'SMS',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity;

        Datetime to_be_removed_time = Datetime.now().addDays(-4).addHours(1);
        Opportunity opportunity2 = new Opportunity(
                Name = 'LongForm:'+esi+'_123456789',
                E2E_Last_Activity__c = to_be_removed_time,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = '',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'German',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'Tablet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity2;
        Test.setCreatedDate(opportunity2.Id, to_be_removed_time);

        // Contact creation
        Contact contact = new Contact(
                Salutation = 'Mr',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Germany');
        insert contact;

        // create contact role
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                OpportunityId = opportunity.Id,
                ContactId = contact.Id,
                IsPrimary = true);
        insert oppContactRole;

        if (station != null) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = station.Id;
            newPartner.OpportunityId = opportunity.Id;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }

        opportunity.E2E_Short_Link__c = generateShortId(obnNumberDE, opportunity.Id);
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        existing_short_urlDE = opportunity.E2E_Short_Link__c;
        existing_encoded_urlDE = opportunity.E2E_Encoded_URL__c;
    }

    private static String generateShortId(String obnNumber, Id oppId) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance('Germany');
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(String.valueOf(obnNumber + oppId)))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }
}