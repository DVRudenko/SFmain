@isTest
private class LinkRedirectControllerTest {
    private static String generateShortId(String obnNumber, Id oppId, String country) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(String.valueOf(obnNumber + oppId)))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }

    static testMethod void testSMS_DE(){
        ApexPages.currentPage().getParameters().put('test_country','de');
        E2ELongFormUtilsTest.createCustomSettings('Germany', 'E2EForm', 'Creditreform', '00520000005vYf3');

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';

        List<SObject> custom_settings = new List<SObject>();
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etede';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c();
        settingsEKeysAPI.Name = 'E2EForm';
        settingsEKeysAPI.AES256_Key__c = 'MTIzNDU2Nzg5MDEyMzQ1NjEyMzQ1Njc4OTAxMjM0NTY=';
        custom_settings.add(settingsEKeysAPI);

        insert custom_settings;

        System.assert(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c!=null);


        String obnNumber = '000000';
        String client_number = '+491234567890';
        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumber,
                Name = 'ValidOBN',
                BillingCountry = 'Germany',
                ShippingCountry = 'Germany',
                Type = 'Customer',
                Strasse_E__c = 'Strasse',
                Ort_E__c = 'Ort',
                Land_E__c = 'Land',
                AccountSource = 'E2E Form');
        insert retailerAccount;


        List<Account> checkRetailer = [
                SELECT Strasse_E__c,Ort_E__c,Land_E__c
                FROM Account
                WHERE OBN__c != null AND OBN__c = :obnNumber
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumber;
            station = checkRetailer.get(0);
            homestation = station.Strasse_E__c + ', ' + station.Ort_E__c + ', ' + station.Land_E__c;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumber + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Germany',
                ShippingCountry = 'Germany',
                Type = 'Customer',
                AccountSource = 'E2E Form');
        insert account;

        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                RecordTypeId = opptyRecordTypeList.get(0).Id,
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
                LeadSource = 'E2E Form',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Internet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                Eco_Fee__c = true,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity;

        Contact contact = new Contact(
                Salutation = 'Mr',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                LeadSource = 'E2E Form',
                MailingCountry = 'Germany');
        insert contact;

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

        opportunity.E2E_Short_Link__c = generateShortId(obnNumber, opportunity.Id, 'Germany');
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        Test.startTest();

        // existing opp-ty SMS test
        PageReference page = Page.i;
        Test.setCurrentPage(page);
        page.getParameters().put('s' + opportunity.E2E_Short_Link__c ,null);
        LinkRedirectController controller = new LinkRedirectController();
        PageReference res = controller.redirectURL();

        // obn QR test
        page.getParameters().clear();
        page.getParameters().put('q'+obnNumber,null);
        res = controller.redirectURL();
        // obn URL test
        page.getParameters().clear();
        page.getParameters().put('l'+obnNumber,null);
        res = controller.redirectURL();
        System.debug('obn URL test.. ok!');

        // obn URL test
        page.getParameters().clear();
        page.getParameters().put('u'+obnNumber,null);
        res = controller.redirectURL();

        // incorrect link test
        page.getParameters().clear();
        page.getParameters().put('zxcvbnm','hey');
        page.getParameters().put('asdfg','ho');
        res = controller.redirectURL();

        Test.stopTest();
    }

    static testMethod void testU_PL(){
        E2ELongFormUtilsTest.createCustomSettings('Poland', 'E2EFormPL', 'Creditreform', '00520000005vYf3');

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';

        List<SObject> custom_settings = new List<SObject>();
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Poland';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etepl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(Name = 'E2EFormPL', AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=', paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp', PSPID__c = 'fleetcorTEST', SHA_KeyIn__c = 'FleetcorTest!12@', SHA_KeyOut__c = 'IngenFleetTest1!');
        custom_settings.add(e2eKeysApi);

        insert custom_settings;

        String obnNumber = '000000';
        String client_number = '+48123456789';
        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumber,
                Name = 'ValidOBN',
                BillingCountry = 'Poland',
                ShippingCountry = 'Poland',
                Type = 'Customer',
                Strasse_E__c = 'Strasse',
                Ort_E__c = 'Ort',
                Land_E__c = 'Land',
                AccountSource = 'E2E Form');
        insert retailerAccount;


        List<Account> checkRetailer = [
                SELECT Strasse_E__c,Ort_E__c,Land_E__c
                FROM Account
                WHERE OBN__c != null AND
                OBN__c = :obnNumber
                ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumber;
            station = checkRetailer.get(0);
            homestation = station.Strasse_E__c +', '+station.Ort_E__c+', '+station.Land_E__c;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumber + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Poland',
                ShippingCountry = 'Poland',
                Type = 'Customer',
                AccountSource = 'E2E Form');
        insert account;

        // Opportunity creation
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                RecordTypeId = opptyRecordTypeList.get(0).Id,
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
                LeadSource = 'E2E Form',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Internet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                Eco_Fee__c = true,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity;

        Contact contact = new Contact(
                Salutation = 'Mr',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                LeadSource = 'E2E Form',
                MailingCountry = 'Poland');
        insert contact;

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

        opportunity.E2E_Short_Link__c = generateShortId(obnNumber, opportunity.Id, 'Poland');
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EFormPL');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        Test.startTest();
        PageReference page = Page.i;
        Test.setCurrentPage(page);
        LinkRedirectController controller = new LinkRedirectController();
        // obn QR test
        page.getParameters().put('test_country', 'pl');
        page.getParameters().put('u' + obnNumber, null);
        PageReference res = controller.redirectURL();

        Test.stopTest();
    }

    static testMethod void testQR_CH(){
        E2ELongFormUtilsTest.createCustomSettings('Switzerland-DE', 'E2EFormCHDE', 'Creditreform', '00520000005vYf3');

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';

        List<SObject> custom_settings = new List<SObject>();
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Switzerland-DE';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etechde';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c();
        settingsEKeysAPI.Name = 'E2EFormCHDE';
        settingsEKeysAPI.AES256_Key__c = 'MTIzNDU2Nzg5MDEyMzQ1NjEyMzQ1Njc4OTAxMjM0NTY=';
        custom_settings.add(settingsEKeysAPI);

        insert custom_settings;

        System.assert(E2EKeysAPI__c.getValues('E2EFormCHDE').AES256_Key__c!=null);


        String obnNumber = '000000';
        String client_number = '+41212345678';
        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumber,
                Name = 'ValidOBN',
                BillingCountry = 'Switzerland-DE',
                ShippingCountry = 'Switzerland-DE',
                Type = 'Customer',
                Strasse_E__c = 'Strasse',
                Ort_E__c = 'Ort',
                Land_E__c = 'Land',
                AccountSource = 'E2E Form'
        );
        insert retailerAccount;

        List<Account> checkRetailer = [
                SELECT Strasse_E__c,Ort_E__c,Land_E__c
                FROM Account
                WHERE OBN__c != null AND OBN__c = :obnNumber
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumber;
            station = checkRetailer.get(0);
            homestation = station.Strasse_E__c + ', ' + station.Ort_E__c + ', ' + station.Land_E__c;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumber + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Switzerland-DE',
                ShippingCountry = 'Switzerland-DE',
                Type = 'Customer',
                AccountSource = 'E2E Form');
        insert account;

        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                RecordTypeId = opptyRecordTypeList.get(0).Id,
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
                LeadSource = 'E2E Form',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Internet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                Eco_Fee__c = true,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E'
        );
        insert opportunity;

        Contact contact = new Contact(
                Salutation = 'Mr',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                LeadSource = 'E2E Form',
                MailingCountry = 'Switzerland-DE');
        insert contact;

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

        opportunity.E2E_Short_Link__c = generateShortId(obnNumber, opportunity.Id, 'Switzerland-DE');
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHDE');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EFormCHDE');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        Test.startTest();
        PageReference page = Page.i;
        Test.setCurrentPage(page);
        LinkRedirectController controller = new LinkRedirectController();
        // obn url test
        page.getParameters().put('test_country', 'ch');
        page.getParameters().put('q' + obnNumber, null);
        PageReference res = controller.redirectURL();

        Test.stopTest();
    }

    @isTest
    static void testLotos_PL() {
        String base_url = 'https://online.fleetcor.pl';
        List<SObject> custom_settings = new List<SObject>();
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Poland';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etelotospl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(Name = 'E2EFormPL', AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=', paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp', PSPID__c = 'fleetcorTEST', SHA_KeyIn__c = 'FleetcorTest!12@', SHA_KeyOut__c = 'IngenFleetTest1!');
        custom_settings.add(e2eKeysApi);

        insert custom_settings;

        String lotosObn = 'P123';
        Account lotosPartner = new Account(
                Name = 'LOTOS',
                Phone = '+48123321321321',
                Partnertyp__c = 'Lotos partner',
                OBN__c = lotosObn,
                BillingCountry = 'Poland'
        );
        insert lotosPartner;

        Test.startTest();
        PageReference page = Page.i;
        Test.setCurrentPage(page);
        LinkRedirectController controller = new LinkRedirectController();
        page.getParameters().put('test_country','pl');
        page.getParameters().put('q' + lotosObn + 'lotos', null);
        PageReference redirectUrl = controller.redirectURL();
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Retailer_OBN__c = :lotosObn];
        System.assert( ! oppList.isEmpty());
    }

    @IsTest
    static void testEmarsysSMSHU() {
        String base_url = 'https://online.fleetcor.hu';
        List<SObject> custom_settings = new List<SObject>();
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Hungary';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etehu';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormHU',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!');
        custom_settings.add(e2eKeysApi);

        List<User> e2eUser = [SELECT Id, ProfileId FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = new E2E_Form_General_Settings__c(
                Name = 'Hungary',
                Abandonment_User__c = e2eUser.get(0).Id,
                E2E_Guest_User_Id__c = e2eUser.get(0).Id,
                Integration_Admin_Id__c = indAdmin.get(0).Id,
                Enable_authorization_non_granted_check__c = false,
                Files_Generator_Url__c = 'http://e2e-e2efleetcor.cs108.force.com',
                Payment_URL__c = 'https://e2e-e2efleetcor.cs108.force.com',
                Set_GFN_Status__c = false,
                Test_Mode__c = false
        );
        custom_settings.add(e2eGeneralSettings);

        insert custom_settings;

        Lead lead = new Lead(
                LastName = 'test',
                FirstName = 'test',
                Email = 'test@test.com',
                Company = 'test',
                LeadSource = 'Shell Email',
                Phone = '1111111111',
                CCS_number_of_cards__c = 2,
                Contact_Email_Body__c = LeadTriggerTestShellEmails.SHELL_EMAIL_NL,
                Country = 'Hungary',
                CountryCode = 'HU',
                E2E_Short_Link__c = 'S5p3ZO'
        );
        insert lead;

        Test.startTest();
            PageReference page = Page.i;
            Test.setCurrentPage(page);
            LinkRedirectController controller = new LinkRedirectController();
            page.getParameters().put('test_country', 'hu');
            page.getParameters().put('s' + lead.E2E_Short_Link__c, null);
            PageReference redirectUrl = controller.redirectURL();
        Test.stopTest();

        List<E2E_Data_Object__c> e2EDataObjects = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c =: lead.Id];
        System.assert( ! e2EDataObjects.isEmpty() );
    }
}