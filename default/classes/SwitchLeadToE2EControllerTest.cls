@isTest
private class SwitchLeadToE2EControllerTest {
    @testSetup
    static void createContentForCards() {
        E2EKeysAPI__c settingsEKeysAPIDE = new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert settingsEKeysAPIDE;

        RecordType fleetcorRt = [SELECT Id FROM RecordType WHERE Name = 'FLEETCOR'];
        Product2 typeBProduct = new Product2(
                Name = 'HOME 1',
                CurrencyIsoCode = 'EUR',
                Integration_Name__c = 'inpoundtypeb',
                Family = 'SHELL',
                RecordTypeId = fleetcorRt.Id
        );
        insert typeBProduct;

        Offer_Item_Type__c shellFuelCards = new Offer_Item_Type__c(Name = 'Shell Fuel Card');
        insert shellFuelCards;

        Offer_to_Item_Type_Junction__c junctionTypeB = new Offer_to_Item_Type_Junction__c(
                Product__c = typeBProduct.Id,
                Offer_Item_Type__c = shellFuelCards.Id
        );
        insert junctionTypeB;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbeTypeB = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = typeBProduct.Id,
                UnitPrice = 10,
                IsActive = true,
                CurrencyIsoCode = 'EUR'
        );
        insert pbeTypeB;

        Product2 evDeProduct = new Product2(
                Name = 'EV DE',
                CurrencyIsoCode = 'EUR',
                Family = 'EV',
                Integration_Name__c = 'evdepromo',
                RecordTypeId = fleetcorRt.Id
        );
        insert evDeProduct;

        Offer_Item_Type__c evFob = new Offer_Item_Type__c(Name = 'EV Fob');
        insert evFob;

        Offer_to_Item_Type_Junction__c junctionEVFob = new Offer_to_Item_Type_Junction__c(
                Product__c = evDeProduct.Id,
                Offer_Item_Type__c = evFob.Id
        );
        insert junctionEVFob;

        PricebookEntry pbeEVDe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = evDeProduct.Id,
                UnitPrice = 10,
                IsActive = true,
                CurrencyIsoCode = 'EUR'
        );
        insert pbeEVDe;
    }


    @isTest
    static void testFacebook() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Belgium-NL',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Belgium-NL';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etebenl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormBENL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Belgium-NL', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        Lead lead = new Lead(
                LastName = 'Test Facebook 1',
                Company = 'Test company',
                FirstName = 'Test First name',
                CountryCode = 'BENL',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'Facebook',
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Facebook campaign name',
                Utm_content__c = 'Facebook adset name',
                Utm_term__c = 'Facebook ad name',
                Is_external__c = true,
                Number_of_Cards_facebook__c = '1'
        );
        insert lead;

        System.debug('lead === ' + lead.Status);

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();

            List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
            System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }

    @isTest
    static void testInboundcall() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Belgium-FR',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Belgium-FR';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etebefr';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormBEFR',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Belgium-FR', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        Lead lead = new Lead(
                LastName = 'Test Facebook 1',
                Company = 'Test company',
                FirstName = 'Test First name',
                CountryCode = 'BEFR',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'Inbound Call',
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Facebook campaign name',
                Utm_content__c = 'Facebook adset name',
                Utm_term__c = 'Facebook ad name',
                Is_external__c = true,
                CCS_number_of_cards__c = 1
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();

            List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
            System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }

    @isTest
    static void testInboundEmail() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Netherlands',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Netherlands';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etenl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormNL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Netherlands', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        List<RecordType> leadRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Endkunde' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordTypeList.get(0).Id,
                LastName = 'Test Facebook 1',
                Company = 'Test company',
                FirstName = 'Test First name',
                Anzahl_der_Fahrzeuge__c = 1,
                Salutation = 'Mr.',
                Branche_NACE__c = 'test',
                Beschaeftigte__c = '1-4',
                CountryCode = 'NL',
                Country = 'Netherlands',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'Inbound Email',
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Facebook campaign name',
                Utm_content__c = 'Facebook adset name',
                Utm_term__c = 'Facebook ad name',
                Is_external__c = true,
                CCS_number_of_cards__c = 1
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();

            List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
            System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }

    @isTest
    static void testInboundEmailShell() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Netherlands',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Netherlands';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etenl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormNL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Netherlands', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        Lead lead = new Lead(
                LastName = 'Test Inbound',
                Company = 'Email Shell',
                FirstName = 'Test First name',
                CountryCode = 'NL',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'Shell Email',
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Email shell name',
                Utm_content__c = 'Email shell adset name',
                Utm_term__c = 'Email shell ad name',
                Is_external__c = true,
                Anzahl_der_Fahrzeuge__c = 1
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();

            List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
            System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }

    @isTest
    static void testInboundPopup() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Netherlands',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Netherlands';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etenl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormNL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Netherlands', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        List<RecordType> leadRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Endkunde' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordTypeList.get(0).Id,
                LastName = 'Test Facebook 1',
                Company = 'Test company',
                FirstName = 'Test First name',
                Anzahl_der_Fahrzeuge__c = 1,
                Salutation = 'Mr.',
                Branche_NACE__c = 'test',
                Beschaeftigte__c = '1-4',
                CountryCode = 'NL',
                Country = 'Netherlands',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'popup_window',
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Facebook campaign name',
                Utm_content__c = 'Facebook adset name',
                Utm_term__c = 'Facebook ad name',
                Is_external__c = true,
                Number_of_Cards_facebook__c = '1',
                CustomDeduplication_Check_Date__c = Date.today()
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();

            List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
            System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }


    @isTest
    static void testInboundPopupLotos() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'Poland',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Poland';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etepl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormPL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Poland', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        List<RecordType> leadRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Lotos' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordTypeList.get(0).Id,
                LastName = 'Test Facebook 1',
                Company = 'Test company',
                FirstName = 'Test First name',
                Anzahl_der_Fahrzeuge__c = 1,
                Salutation = 'Mr.',
                Branche_NACE__c = 'test',
                Beschaeftigte__c = '1-4',
                CountryCode = 'PL',
                Country = 'Poland',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'popup_window',
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Facebook campaign name',
                Utm_content__c = 'Facebook adset name',
                Utm_term__c = 'Facebook ad name',
                Is_external__c = true,
                Number_of_Cards_facebook__c = '1',
                CCS_number_of_cards__c = 1,
                Agree_to_receive_comm_info_by_email__c = true,
                CustomDeduplication_Check_Date__c = Date.today()
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();

        List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
        System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }


    @isTest
    static void testTabletShortForm() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'GermanyJITB',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etede';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Germany', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        List<RecordType> leadRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Endkunde' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordTypeList.get(0).Id,
                LastName = 'Test Facebook 1',
                Company = 'Test company',
                FirstName = 'Test First name',
                Country = 'Germany',
                Salutation = 'Mr.',
                Branche_NACE__c = 'test',
                Beschaeftigte__c = '1-4',
                Anzahl_der_Fahrzeuge__c = 1,
                CountryCode = 'DE',
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'Tablet Short Form',
                Sec_Channel__c = 'JITB',
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Utm_source__c = 'facebook',
                Utm_medium__c = 'display',
                Utm_campaign__c = 'Facebook campaign name',
                Utm_content__c = 'Facebook adset name',
                Utm_term__c = 'Facebook ad name',
                Is_external__c = true,
                CCS_number_of_cards__c = 1
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('lid', lead.Id);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();

            List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :lead.Id];
            System.assert(!dataObjectToCheck.isEmpty());
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }

    @isTest
    static void testManualAdoptionToE2E() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
                Name = 'GermanyInbound',
                Min_Cards__c = 1,
                Max_Cards__c = 2);
        insert switchedToE2ESettings;

        String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/etede';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/etejitblocator';
        insert settingsE2EShortUrl;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        List<User> indAdmin = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];
        List<E2E_Form_General_Settings__c> e2eGeneralSettings = generateE2EGeneralSettings('Germany', e2eUser.get(0).id, indAdmin.get(0).id);
        insert e2eGeneralSettings;

        List<RecordType> leadRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Endkunde' LIMIT 1];
        Lead lead = new Lead(
                RecordTypeId = leadRecordTypeList.get(0).Id,
                LastName = 'Test Manual Adoption',
                Company = 'Test company',
                FirstName = 'Test First name',
                Country = 'Germany',
                CountryCode = 'DE',
                Salutation = 'Mr.',
                Branche_NACE__c = 'test',
                Beschaeftigte__c = '1-4',
                Anzahl_der_Fahrzeuge__c = 1,
                Phone = '123123123',
                Email = 'test1123@wewr.wer',
                LeadSource = 'Test',
                Sec_Channel__c = 'Inbound',
                Quali_Status__c = 'Switched to E2E',
                E2E_Manual_Adoption_Date__c = Datetime.now(),
                Channel__c = 'Internet',
                OPT_IN__c = true,
                Is_external__c = true,
                CCS_number_of_cards__c = 1
        );
        insert lead;

        Emarsys_Log__c emarsysLog = new Emarsys_Log__c(
                Lead__c = lead.Id,
                Email_Body__c = 'test',
                Campaign_Name__c = 'abandonment'
        );
        insert emarsysLog;

        Test.startTest();
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            String stringToEncode = lead.Id + '-' + 'Inbound Typ C';
            String encodedString = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
            ApexPages.CurrentPage().getparameters().put('eid', encodedString);
            SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
            controller.init();
        Test.stopTest();

        List<Lead> leadList = [SELECT IsConverted FROM Lead WHERE Id = :lead.Id];
        System.assert(leadList.get(0).IsConverted);
    }


    public static List<SObject> generateE2EGeneralSettings(String country, String userId, String intAdminId) {
        List<SObject> customSettingsList = new List<SObject>();
        E2E_Form_General_Settings__c e2eGeneralSettings = new E2E_Form_General_Settings__c(
                Name = country,
                Abandonment_User__c = userId,
                E2E_Guest_User_Id__c = userId,
                Integration_Admin_Id__c = intAdminId,
                Enable_authorization_non_granted_check__c = false,
                Files_Generator_Url__c = 'http://e2e-e2efleetcor.cs108.force.com',
                Payment_URL__c = 'https://e2e-e2efleetcor.cs108.force.com',
                Set_GFN_Status__c = false,
                Test_Mode__c = false
        );
        customSettingsList.add(e2eGeneralSettings);

        Fleetcor_Profile_Info_Settings__c fltProfileSettings = new Fleetcor_Profile_Info_Settings__c(
                Name = 'E2E Profile',
                ProfileId__c = '00e0O000001Z1VtQAK'
        );
        customSettingsList.add(fltProfileSettings);

        List<Profile> adminProfiles = [SELECT Id, Name FROM Profile WHERE Name in ('API Only', 'System Administrator')];

        for (Profile adminProfile : adminProfiles) {
            customSettingsList.add(new Fleetcor_Profile_Info_Settings__c(
                    Name = adminProfile.Name,
                    ProfileId__c = adminProfile.Id
            ));
        }

        return customSettingsList;
    }
}