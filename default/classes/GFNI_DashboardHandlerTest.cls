@isTest
public class GFNI_DashboardHandlerTest {

    private static void initCustomSettings(Boolean isTestMode) {
        insert new GFNI_Settings__c(
                API_version__c = '1',
                Client_system__c = 'SME',
                Culture__c = 'en-GB',
                IsForRobot__c = false,
                Name = 'GFN Integration Settings',
                Test_mode__c = isTestMode ? true : false,
                Test_GFN_System_base_URL__c = 'http://test.endpoint/GFNSME/Views/Home.aspx?',
                GFN_System_base_URL__c = 'http://prod.endpoint/GFNSME/Views/Home.aspx?'
        );
    }

    static String colCoID = '1';
    static String customerERP = 'DE12478550';



    @isTest
    public static void testPrepareCardsListJson() {
        initCustomSettings(true);
        GFNI_DashboardHandler handler = new GFNI_DashboardHandler();
        String cardsList = '70929, 583557, 606978, 456838';
        String cardsListJson = handler.prepareCardsListJson(cardsList);
        String finalCardsListJson = '[{"CardID": 70929,"Reason": "Blocked by API"},' +
                '{"CardID": 583557,"Reason": "Blocked by API"},' +
                '{"CardID": 606978,"Reason": "Blocked by API"},' +
                '{"CardID": 456838,"Reason": "Blocked by API"}]';
        System.assertEquals(true, cardsListJson == finalCardsListJson);
    }

    @isTest
    public static void test() {
        initCustomSettings(true);

        Test.startTest();
        GFNI_Settings__c integrationSettings = GFNI_DashboardCtrl.getCustomSetting('SME');


        GFNI_DashboardHandler handler = new GFNI_DashboardHandler();
        String gfnSystemBaseUrl = integrationSettings.Test_GFN_System_base_URL__c;

        AccountDetailsGfn customerInfo = getAccountDetailsGfnObject();
        AccountDetailsGfn relatedCustomers = getAccountDetailsGfnObject();

        Map<String, String> accountDetailsInfo = handler.getGfnAccountDetails(customerInfo, relatedCustomers,
                colCoID, customerERP, integrationSettings);
        String maintainCustomerLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintaincustomer');
        System.assertEquals(true, accountDetailsInfo.get('FullName') == 'KEP SOLUTION GMBH');
        System.assertEquals(true, accountDetailsInfo.get('RelatedAccounts') != null);
        System.assertEquals(accountDetailsInfo.get('MaintainCustomerLandingPage'), maintainCustomerLandingPage);

        Map<String, String> accountContactsGfn = handler.getGfnAccountContacts(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainCustomerContactLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintaincustomercontact');
        System.assertEquals(true, accountContactsGfn.get('AccountContacts') != null);
        System.assertEquals(true, accountContactsGfn.get('MaintainCustomerContactLandingPage') == maintainCustomerContactLandingPage);

        Map<String, String> accountAddressesGfn = handler.getGfnAccountAddresses(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainAddressLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintainaddress');
        System.assertEquals(true, accountAddressesGfn.get('AccountAddresses') != null);
        System.assertEquals(true, accountAddressesGfn.get('MaintainAddressLandingPage') == maintainAddressLandingPage);

        Map<String, String> accountServicesGfn = handler.getGfnAccountServices(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainServicesLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintainservices');
        System.assertEquals(true, accountServicesGfn.get('AccountServices') != null);
        System.assertEquals(true, accountServicesGfn.get('MaintainServicesLandingPage') == maintainServicesLandingPage);

        Map<String, String> accountSelfServeUsersGfn = handler.getGfnAccountSelfServeUsers(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainSelfServeUserLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintainselfserveuseraccount');
        System.assertEquals(true, accountSelfServeUsersGfn.get('AccountSelfServeUsers') != null);
        System.assertEquals(true, accountSelfServeUsersGfn.get('MaintainSelfServeUserLandingPage') == maintainSelfServeUserLandingPage);

        Map<String, String> accountCardsInfoGfn = handler.getGfnAccountCardsInfo(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainCardsInfoLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'cardmaintenance');
        System.assertEquals(true, accountCardsInfoGfn.get('AccountCardsInfo') != null);
        System.assertEquals(true, accountCardsInfoGfn.get('MaintenanceCardsLandingPage') == maintainCardsInfoLandingPage);

        Map<String, String> accountUnbilledProductsGfn = handler.getGfnAccountUnbilledProducts(customerInfo, integrationSettings);
        System.assertEquals(true, accountUnbilledProductsGfn.get('UnbilledProducts') != null);

        Map<String, String> accountUnbilledTransactionsGfn = handler.getGfnAccountUnbilledTransactions(customerInfo, colCoID, customerERP, integrationSettings);
        String customerTransactionsSearchLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'customersalesitemsearch');
        System.assertEquals(true, accountUnbilledTransactionsGfn.get('UnbilledTransactions') != null);
        System.assertEquals(true, accountUnbilledTransactionsGfn.get('CustomerTransactionsSearchLandingPage') == customerTransactionsSearchLandingPage);

        Map<String, String> accountPaymentDetailsGfn = handler.getGfnAccountPaymentDetails(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainPaymentDetailsLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintaincustomerpaymentdetail');
        System.assertEquals(true, accountPaymentDetailsGfn.get('CreditLimit') != null);
        System.assertEquals(true, accountPaymentDetailsGfn.get('MaintainCustomerPaymentDetailsLandingPage') == maintainPaymentDetailsLandingPage);

        Map<String, String> accountInformationSubscriptionsGfn = handler.getGfnAccountInformationSubscriptions(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainCustomerInfoSubscriptionLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'maintaincustomerinfosubscription');
        System.assertEquals(true, accountInformationSubscriptionsGfn.get('InfoSubscriptions') != null);
        System.assertEquals(true, accountInformationSubscriptionsGfn.get('MaintainCustomerInfoSubscriptionLandingPage') == maintainCustomerInfoSubscriptionLandingPage);

        Map<String, String> accountFeeRulesGfn = handler.getGfnAccountFeeRules(customerInfo, colCoID, customerERP, integrationSettings);
        String feeRulesLandingPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'Customerfeerulesearch');
        System.assertEquals(true, accountFeeRulesGfn.get('FeeRules') != null);
        System.assertEquals(true, accountFeeRulesGfn.get('Customerfeerulesearch') == feeRulesLandingPage);

        Map<String, String> accountHomeSitesGfn = handler.getGfnAccountHomeSites(customerInfo, colCoID, customerERP, integrationSettings);
        String maintainHomeSite = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'Maintainhomesite');
        System.assertEquals(true, accountHomeSitesGfn.get('HomeSites') != null);
        System.assertEquals(true, accountHomeSitesGfn.get('Maintainhomesite') == maintainHomeSite);

        Map<String, String> accountPriceRulesGfn = handler.getGfnAccountPriceRules(customerInfo, colCoID, customerERP, integrationSettings);
        String Customerpricerulessearch = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'Customerpricerulessearch');
        System.assertEquals(true, accountPriceRulesGfn.get('PriceRules') != null);
        System.assertEquals(true, accountPriceRulesGfn.get('Customerpricerulessearch') == Customerpricerulessearch);

        Map<String, String> accountBillingDocumentsGfn = handler.getGFNAccountBillingDocuments(customerInfo, colCoID, customerERP, integrationSettings);
        String billingDocumentsPage = getLandingPage(gfnSystemBaseUrl, colCoID, customerERP, 'Listcustomersummaryinvoice');
        System.assertEquals(true, accountBillingDocumentsGfn.get('BillingDocuments') != null);
        System.assertEquals(true, accountBillingDocumentsGfn.get('Listcustomersummaryinvoice') == billingDocumentsPage);

        BlockCardResponseGfn blockCardResponse = getAccountBlockedCardResponsesGfn();
        Map<String, String> accountBlockedCardResponseGfn = handler.getGfnAccountBlockedCardsRequests(blockCardResponse, integrationSettings);
        System.assertEquals(true, accountBlockedCardResponseGfn.get('BlockCardRequests') != null);

        CreditDataGfn creditData = getCreditDataGfn();
        Map<String, String> creditDataResponse = handler.getGfnCreditData(creditData, colCoID, customerERP, integrationSettings);
        System.assertEquals(true, creditDataResponse.get('CreditData') != null);

        Test.stopTest();
    }

    private static String getLandingPage(String gfnSystemBaseUrl, String colCoID, String customerERP, String gfnPage){
        return gfnSystemBaseUrl + 'CompanyID=' + colCoID + '&CustomerERP=' + customerERP + '&Page=' + gfnPage;
    }

    private static AccountDetailsGfn getAccountDetailsGfnObject() {
        String testJSON = '{"Data":' +
                '{"CustomerID":64762,"FullName":"KEP SOLUTION GMBH","CustomerERP":"DE12478550",' +
                '"ClientCustomerNumber":"DE12478550","MarketingSegmentation":"Sales","StatusID":1,' +
                '"Status":"Active","Language":"German","RegistrationNumber":"20211205998",' +
                '"VATRegistrationNumber":"DE262285988","AverageVolume":0.000000,"DebtorStatus":"GP Managed",' +
                '"OutstandingDebt":789456.000000,"OutstandingDebtCurrency":"EUR","CreditLimit":13440,' +
                '"CreditLimitCurrency":"EUR","PaymentMethod":"SEPA DD - CORE","PaymentTerms":"7 Days",' +
                '"Guarantee":0.000000,"GuaranteeCurrency":"EUR","BillingFrequency":"Weekly - Sunday",' +
                '"DefaultDistributionMethod":"Email","DefaultDistributionFormat":"PDF",' +
                '"RelatedAccounts":[{"CustomerID":51709,"ClientCustomerNumber":"DE12366453",' +
                '"CustomerERP":"DE12366453","ShortName":"KEP SOLUTION GMBH","Fullname":"KEP SOLUTION GMBH",' +
                '"StatusID":1,"Status":"Active","Parent":true,"Child":false,"City":"DRESDEN",' +
                '"CustomerLink":{"Description":"Get Customer Summary","Method":"GET",' +
                '"Link":"/SalesForce//Customer/DE12366453"}}],' +
                '"AllowedStatusChanges":[{"StatusID":12,"Status":"Blocked",' +
                '"StatusChange":{"Description":"Change customer status, Status text in body","Method":"PATCH",' +
                '"Link":"/Customer/DE12478550/Status"}},{"StatusID":13,"Status":"Awaiting Cancel",' +
                '"StatusChange":{"Description":"Change customer status, Status text in body","Method":"PATCH",' +
                '"Link":"/Customer/DE12478550/Status"}}],' +
                '"AccountAddresses":[{"CustomerID":64762,"AddressID":237468,"AddressLines":"CHAMISSOSTRASSE 2",' +
                '"Region":"Saxony","ZipCode":"01157","City":"DRESDEN ","Telephone":"000491733830910","Fax":"",' +
                '"AddressTypes":[{"AddressTypeID":2,"AddressType":"Main "},' +
                '{"AddressTypeID":3,"AddressType":"Registered "}]},{"CustomerID":64762,"AddressID":237469,' +
                '"AddressLines":"CHAMISSOSTRASSE 2","Region":"","ZipCode":"01157","City":"DRESDEN",' +
                '"Telephone":"","Fax":"","AddressTypes":[{"AddressTypeID":10,"AddressType":"Card Delivery"},' +
                '{"AddressTypeID":13,"AddressType":"Pin Delivery"}]}],' +
                '"AccountContacts":[{"CustomerID":64762,"ContactID":174160,"IsPrimary":true,"IsActive":true,' +
                '"ContactTitleID":1,"ContactTitle":"Mr.","LanguageID":1,"LanguageCode":"GER","Language":"German",' +
                '"SalutationWritten":"","SalutationVerbal":"","ForeName":"BERNHARDT","MiddleName":"",' +
                '"LastName":"MAURICE","Telephone":"01733830910","Fax":"","MobilePhone":"",' +
                '"EmailAddress":"office@kep-solution.de","MarketingCampaigns":false,"Position":"",' +
                '"ContactTypes":[{"ContactID":174160,"ContactTypeID":1,"ContactType":"Primary Contact"},' +
                '{"ContactID":174160,"ContactTypeID":15,"ContactType":"Authorised Contact"}]}],' +
                '"AccountServices":[{"ServiceID":3,"ServiceDescription":"VAT Recovery","ServiceTypeID":2,' +
                '"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                '"RegistrationNumber":"","StartDate":"2017-05-15T00:00:00","Registered":true,"Quota":null},' +
                '{"ServiceID":1008,"ServiceDescription":"55","ServiceTypeID":1,"ServiceType":"Standard",' +
                '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"",' +
                '"StartDate":null,"Registered":false,"Quota":null},{"ServiceID":1009,"ServiceDescription":"carnet",' +
                '"ServiceTypeID":2,"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,' +
                '"MaxQuota":null,"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":1004,"ServiceDescription":"CARNET","ServiceTypeID":1,"ServiceType":"Standard",' +
                '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"",' +
                '"StartDate":null,"Registered":false,"Quota":null},{"ServiceID":2011,' +
                '"ServiceDescription":"Carnet Communication Service","ServiceTypeID":2,"ServiceType":"Card Subscription",' +
                '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                '"Registered":false,"Quota":null},{"ServiceID":1011,"ServiceDescription":"Carnet Service",' +
                '"ServiceTypeID":4,"ServiceType":"Carnet","Essential":false,"QuotaRequired":false,' +
                '"MaxQuota":null,"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":2,"ServiceDescription":"ClubSmart","ServiceTypeID":2,' +
                '"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,' +
                '"MaxQuota":null,"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":4,"ServiceDescription":"Customer data verification","ServiceTypeID":1,' +
                '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":1007,"ServiceDescription":"Fleetmatic","ServiceTypeID":1,' +
                '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":1,"ServiceDescription":"Monthly ADAC Breakdown Insurance",' +
                '"ServiceTypeID":2,"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,' +
                '"MaxQuota":null,"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":1006,"ServiceDescription":"Season discount","ServiceTypeID":1,"ServiceType":"Standard",' +
                '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                '"Registered":false,"Quota":null},{"ServiceID":1010,"ServiceDescription":"Tesst","ServiceTypeID":1,' +
                '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                '{"ServiceID":1005,"ServiceDescription":"TOLL","ServiceTypeID":1,"ServiceType":"Standard",' +
                '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                '"Registered":false,"Quota":null},{"ServiceID":5,"ServiceDescription":"Unsubscribed","ServiceTypeID":1,' +
                '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"",' +
                '"StartDate":null,"Registered":false,"Quota":null}],' +
                '"AccountSelfServeUsers":[{"UserID":38352,"LoginName":"DE12366453 ","Title":"HERR","FirstName":"MAURICE",' +
                '"LastName":"BERNHARD","TelephoneNumber":null,"EMailAddress":"office@kep-solution.de","CultureID":1,' +
                '"Culture":"German","LastLogin":"2017-11-17T12:25:48.713","LastActivity":"2017-11-17T12:25:48.713",' +
                '"LoginAttempts":0,"LockoutTime":null,"LockExpiry":null,"CreatedDate":"2014-11-10T12:06:34.387",' +
                '"isLocked":false,"OptOutOfEMail":false,"ContactID":null,"UserTypeID":1,"UserType":"Customer",' +
                '"isActive":true, "UITypeID":2,"UIType":"Customer Self Serve"}],' +
                '"SalesforceCards":[{"CardID":295330,"PAN":"7077141266471249910","ExpiryDate":"2018-08-31T00:00:00",' +
                '"IssueNumber":1,"CardTypeID":1,"CardType":"DE CRT National Single","StatusID":8,"Status":"Expired",' +
                '"LastStatusChange":null,"RegNumber":"ABC 123","IsRegNumberEmbossed":true,"DriverName":null,' +
                '"IsDriverNameEmbossed":false,"PurchaseCategoryID":2,"PurchaseCategory":"1 - All Fuel Products",' +
                '"EffectiveDate":"2014-09-19T00:00:00","CardGroup":"HAUS12345","IsOdometerPromptRequired":true},' +
                '{"CardID":296196,"PAN":"7077140000000100026","ExpiryDate":"2018-08-31T00:00:00","IssueNumber":1,' +
                '"CardTypeID":1,"CardType":"DE CRT National Single","StatusID":8,"Status":"Expired","LastStatusChange":null,' +
                '"RegNumber":"MICHELLE TEST","IsRegNumberEmbossed":true,"DriverName":null,"IsDriverNameEmbossed":false,' +
                '"PurchaseCategoryID":1,"PurchaseCategory":"0 - Diesel Products","EffectiveDate":"2014-09-26T00:00:00",' +
                '"CardGroup":"HAUS12345","IsOdometerPromptRequired":true}],' +
                '"UnbilledProducts":[{"ProductID":30,"Product":"Diesel AGO","Occurances":18},{"ProductID":22,' +
                '"Product":"Unleaded - Medium octane","Occurances":10}],'+
                '"UnbilledTransactions":[{"SalesItemID":37001550,"SalesDateTime":"2017-11-15T07:36:00",' +
                '"Card":"7002147265880480431","SiteID":2,"SiteLocation":"HAMBURG","SiteNumber":"E999",' +
                '"SiteCountry":"Germany","DriverName":null,"VRN":"D VZ 111","ProductID":30,' +
                '"Product":"Diesel AGO","Quantity":62.720000,"AmountGross":75.080000,"AmountNet":63.090000,' +
                '"AmountVat":11.990000},{"SalesItemID":36998451,"SalesDateTime":"2017-11-15T14:18:00",' +
                '"Card":"7002147051500156019","SiteID":716,"SiteLocation":"BUETTELBORN","SiteNumber":"9806",' +
                '"SiteCountry":"Germany","DriverName":null,"VRN":"D VZ 30","ProductID":30,"Product":"Diesel AGO",' +
                '"Quantity":43.470000,"AmountGross":57.260000,"AmountNet":48.120000,"AmountVat":9.140000}],' +
                '"InfoSubscriptions":[{"InfoSubscriptionID":73099,"InfoProviderID":4,"InfoProvider":"Invoice",' +
                '"FrequencyTypeID":10,"FrequencyType":"Monthly - 1st","RunFrequencyTypeID":10,"RunFrequencyType":"Monthly - 1st",' +
                '"DateEffective":"2017-02-17T00:00:00","DateTerminated":"9999-12-31T00:00:00","isSummary":false,' +
                '"InfoSubscriptionDetails":[{"InfoSubscriptionID":73099,"InfoSubscriptionDetailID":78190,"isPrimary":true,' +
                '"isActive":true,"DistributionMethodID":1,"DistributionMethod":"Email","AlternativeDistributionMethodID":5,' +
                '"AlternativeDistributionMethod":"Print","OutputTypeID":28,"OutputType":"Link","SuppressContact":true,' +
                '"AccountInfoSubscriptionContacts":[{"InfoSubscriptionID":73099,"InfoSubscriptionDetailID":78190,' +
                '"ContactID":183041,"isPrimary":true,"isActive":true,"AddressID":251362,"ContactTitleID":1,' +
                '"ContactTitle":"Mr.","LanguageID":1,"Language":"German","ForeName":"MILAN","MiddleName":null,' +
                '"LastName":"KLJAJIC","Telephone":"015167400635","Fax":null,"EMailAddress":"m.k-transport@web.de",' +
                '"Position":"INHABER","AddressLines":"SIEMENSSTR. 1","Zipcode":"90459","City":"NUERNBERG","RegionID":2,' +
                '"Region":"Bavaria","CountryID":1,"Country":"Germany"}]}]}],' +

                '"HomeSites": [{"CustomerHomeSiteID": 34,' + 
                '"SiteID": 690,"DateEffective": "2019-02-26T00:00:00",'+
                '"DateTerminated": "9999-12-31T00:00:00","SiteCode": "1234",' +
                '"FullName": "LEIPZIGER STR","ShortName": "LEIPZIGER STR",' +
                '"Latitude": 50.570085, "Longitude": 9.696292,' +
                '"AddressLines": "MÜNCHENER STR. 42", "City": "ERDING",' +
                '"RegionID": 2,"Region": "Bavaria","CountryID": 1,"ZipCode": "85435"}],' +

                '"FeeRules": [{"FeeRuleID": 52,"FeeRuleDescription": "SG Arl. 3 %",' +
                '"FeeTypeID": 42,"FeeType": "Transaction Fee Gross","FrequencyTypeID": 1,' +
                '"FrequencyType": "string","ProductID": 1004,"Product": "Network Service Fee",'+
                '"FeeRuleBasisID": 2,"FeeRuleBasis": "Percentage of Uplift","MinValue": 0,'+
                '"MaxValue": 999999999,"CurrencyID": 1,"Currency": "Euro","FeeTiers": [{' +
                '"FeeRuleID": 62,"FeeRuleTierID": 42,"DateEffective": "2014-01-01T00:00:00",' +
                '"DateTerminated": "9999-12-31T00:00:00","TierMin": 0,"TierMax": 999999999,'+
                '"Value": 0.025,"BaseValue": 0.025,"UpliftValue": 0.025,"AllowedEditUplift": false}]}],' +

                '"AccountPriceRules": [{"PriceRuleID": 12964,"PriceRuleDescription": "GEN/0,05/9500/DKV_INT",' +
                '"DateEffective": "2012-03-29T00:00:00","DateTerminated": "9999-12-31T00:00:00","ReferencePriceID": 2,' +
                '"ReferencePrice": "Retail Price","PriceRuleBasisID": 2,"PriceRuleBasis": "Currency Per Unit",' +
                '"CurrencyID": 1,"Currency": "EUR","PriceRuleCategoryID": 1,"PriceRuleCategory": "string","FunderTypeID": 1,' +
                '"FunderType": "Site Owner","PriceListID": null,"PriceListPrice": null,"PriceRuleLocations": [{'+
                '"PriceRuleLocationID": 12964,"PriceRuleID": 12465,"DelcoID": 2,"CompanyName": "FleetCor Tankkarten GmbH",' +
                '"FuelNetworkID": 5,"FuelNetworkFullName": "Shell AT","FuelNetworkShortName": "Shell AT","SiteGroupID": null,' +
                '"SiteGroupName": "null,","SiteID": null,"SiteFullName": null,"SiteShortName": null,' +
                '"DateEffective": "2005-05-24T00:00:00","DateTerminated": "9999-12-31T00:00:00"}],"PriceRuleProducts": ['+
                '{"PriceRuleProductID": 12055,"PriceRuleID": 12964,"ProductGroupID": 4,"ProductGroup": "2 stroke",' +
                '"ProductID": 35,"Product": "V - Power Diesel","DateEffective": "2005-05-24T00:00:00",' +
                '"DateTerminated": "9999-12-31T00:00:00"}],"PriceRuleCards": [{"PriceRuleID": 345,"CardTypeGroupID": 2,'+
                '"CardTypeID": 6,"CardType": "AT CRT National Multi","DateEffective": "2005-05-24T00:00:00",' +
                '"DateTerminated": "9999-12-31T00:00:00"}],"PriceRuleTiers": [{"PriceRuleID": 12964,' +
                '"PriceRuleTierID": 14047,"TierMin": 0,"TierMaxExclusive": 999999999,"DateEffective": "2012-02-29T00:00:00",' +
                '"DateTerminated": "9999-12-31T00:00:00","Value": -0.033}]}],' +

                '"AccountBillingDocuments": [{"DocumentID": 778993,"DocumentNumber": "785961/6161560133/2016",' +
                '"DocumentDate": "2016-01-03T00:00:00","PaymentDueDate": "2016-01-13T00:00:00","TotalGross": 1484.9300,' +
                '"AmountAllocated": 0.000000,"DocumentTypeID": 1,"DocumentType": "Invoice","DelcoID": null,"Delco": null,' +
                '"DelcoClientCompanyNumber": null,"BillingOrSummary": "SBD",' +
                '"InvoicePdfLink": "/Customer/invoice-pdf/785961/6161560133/2016"}],' +

                '"InvoiceCustomerID":64762,"InvoiceCustomerERP":"DE12478550",' +
                '"InvoiceCustomerFullName":"KEP SOLUTION GMBH","InvoiceCustomer":{"Description":"Get Invoice Customer","Method":"GET",' +
                '"Link":"/SalesForce/Customer/DE12478550"},"PaymentCustomerID":64762,"PaymentCustomerERP":"DE12478550",' +
                '"PaymentCustomerFullName":"KEP SOLUTION GMBH","PaymentCustomer":{"Description":"Get Payment Customer",' +
                '"Method":"GET","Link":"/SalesForce/Customer/DE12478550"},"TopLevelCustomerID":1,' +
                '"TopLevelCustomerERP":"0012199404","TopLevelCustomerFullName":"FRANK ZIMMER CONTAINER SERVICE",' +
                '"TopLevelCustomer":{"Description":"Get Top Level Customer","Method":"GET",' +
                '"Link":"/SalesForce/Customer/0012199404"}},"Meta":{"TotalPages":0},' +
                '"Links":{"Self":"/SalesForce/Customer/DE12478550","First":null,' +
                '"Last":null,"Prev":null,"Next":null}}';

        AccountDetailsGfn accountDetailsObject = (AccountDetailsGfn) JSON.deserialize(testJSON, AccountDetailsGfn.class);
        return accountDetailsObject;
    }

    private static BlockCardResponseGfn getAccountBlockedCardResponsesGfn() {
        String testJSON = '{ "BlockRequests": [{"CardID": 728389,"BlockRequested": true,"Error": null}]}';
        BlockCardResponseGfn blockCardResponseGfn = (BlockCardResponseGfn) JSON.deserialize(testJSON, BlockCardResponseGfn.class);
        return blockCardResponseGfn;
    }

    private static CreditDataGfn getCreditDataGfn() {
        String testJSON = '{ "Data": [{"CustomerID": 123456,"CustomerERP": "D123123","ExternalAccountingClerk": "test"}]}';
        CreditDataGfn creditData = (CreditDataGfn) JSON.deserialize(testJSON, CreditDataGfn.class);
        return creditData;
    }
}