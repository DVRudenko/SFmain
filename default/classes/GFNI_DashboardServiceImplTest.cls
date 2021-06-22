@isTest
public class GFNI_DashboardServiceImplTest {

    private static void initCustomSettings(Boolean isTestMode) {
        insert new GFNI_Settings__c(
                API_version__c = '1',
                Client_system__c = 'SME',
                Culture__c = 'en-GB',
                IsForRobot__c = false,
                Name = 'GFN Integration Settings',
                Prod_endpoint__c = 'https://api.prod.endpoint',
                Test_endpoint__c = 'https://api.test.endpoint',
                Test_mode__c = isTestMode ? true : false,
                test_x_ibm_client_id__c = '86b094c8-b431-44bd-8925-8909db6b34cf',
                test_x_ibm_client_secret__c = 'J0hE4tJ6wA5dK5nB3aH4fD3wX0iG5wS2uT3vG0mX7eL4rT4mE6',
                x_ibm_client_id__c = '4b4e495e-9b0f-4461-bea4-90bbfb6ea8af',
                x_ibm_client_secret__c = 'M4uT7aP5lC5vT1tG3vQ0rT7gX7lG5nO7lG3iY1mY1nD8sS5bS3'
        );
    }

    static String baseTestURL = 'https://api.test.endpoint';
    static String colCoID = '1';
    static String culture = 'en-GB';
    static String clientSystem = 'SME';
    static String apiVersion = '1';
    static String customerERP = 'DE12478550';
    static String userName = 'TEST_USER';

    // @isTest
    // public static void testGfnApiSettings() {
    //     initCustomSettings(false);

    //     GFNI_DashboardServiceImpl gfnDashboardService = new GFNI_DashboardServiceImpl();
    //     System.assertEquals(true, gfnDashboardService.integrationUrl == 'https://api.prod.endpoint');
    // }

    @isTest
    public static void testGfnApi200() {
        initCustomSettings(true);

        GFNI_Settings__c integrationSettings = GFNI_DashboardCtrl.getCustomSetting('SME');
        System.assertEquals(integrationSettings.Prod_endpoint__c, 'https://api.prod.endpoint');

        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        GFNI_DashboardServiceImpl gfnDashboardService = new GFNI_DashboardServiceImpl();

        // get aggregated customer object (all details)
        AccountDetailsGfn aggregatedCustomerInfo = gfnDashboardService.getAggregatedCustomerObject(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, aggregatedCustomerInfo.Data.CustomerID == 64762);
        System.assertEquals(true, aggregatedCustomerInfo.Data.CustomerERP == 'DE12478550');

        // get customer information (details)
        AccountDetailsGfn customerInformation = gfnDashboardService.getCustomerInformation(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerInformation.Data.CustomerID == 64762);
        System.assertEquals(true, customerInformation.Data.CustomerERP == 'DE12478550');

        // get related customers list
        AccountDetailsGfn relatedCustomers = gfnDashboardService.getRelatedCustomers(colCoID, integrationSettings, customerERP, null);
        System.assertEquals(true, relatedCustomers.Data.RelatedAccounts.size() > 0);

        // get customer contacts list
        AccountDetailsGfn customerContacts = gfnDashboardService.getCustomerContacts(colCoID, integrationSettings, customerERP, null);
        System.assertEquals(true, customerContacts.Data.AccountContacts.size() > 0);

        // get customer addresses list
        AccountDetailsGfn customerAddresses = gfnDashboardService.getCustomerAddresses(colCoID, integrationSettings, customerERP, null);
        System.assertEquals(true, customerAddresses.Data.AccountAddresses.size() > 0);

        // get customer services list
        AccountDetailsGfn customerServices = gfnDashboardService.getCustomerServices(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerServices.Data.AccountServices.size() > 0);

        // get customer self serve users
        AccountDetailsGfn customerSelfServeUsers = gfnDashboardService.getSelfServeUsers(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerSelfServeUsers.Data.AccountSelfServeUsers.size() > 0);

        // get customer cards information
        AccountDetailsGfn customerCardsInfo = gfnDashboardService.getCustomerCardsInfo(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerCardsInfo.Data.SalesforceCards.size() > 0);

        // get customer unbilled transaction products
        AccountDetailsGfn customerUnbilledTransactionProducts = gfnDashboardService.getUnbilledTransactionProducts(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerUnbilledTransactionProducts.Data.UnbilledProducts.size() == 2);

        // get customer unbilled transactions
        AccountDetailsGfn customerUnbilledTransactions = gfnDashboardService.getUnbilledTransactions(colCoID, integrationSettings, customerERP, null, null, null, null);
        System.assertEquals(true, customerUnbilledTransactions.Data.UnbilledTransactions.size() == 2);

        // get customer payment details
        AccountDetailsGfn customerPaymentDetails = gfnDashboardService.getCustomerPaymentDetails(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerPaymentDetails.Data.PaymentCustomerID == 64762);
        System.assertEquals(true, customerPaymentDetails.Data.PaymentCustomerERP == 'DE12478550');

        // get customer information subscriptions
        AccountDetailsGfn customerInfoSubscriptions = gfnDashboardService.getInformationSubscriptions(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, customerInfoSubscriptions.Data.InfoSubscriptions.size() == 1);

        // block cards
        String cardsListJson = '[{"CardID": 728390,"Reason": "Blocked by API"},{"CardID": 728391,"Reason": "Blocked by API"}, {"CardID": 728391,"Reason": "Blocked by API"}]';
        BlockCardResponseGfn blockCardResponseGfn = gfnDashboardService.blockCards(cardsListJson, colCoID, integrationSettings, customerERP);
        System.assertEquals(true, blockCardResponseGfn.BlockRequests.size() == 3);

        // get customer home site information
        AccountDetailsGfn homeSitesGFN = gfnDashboardService.getHomeSites(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, homeSitesGFN.Data.HomeSites.size() == 1);

        // get customer fee rules
        AccountDetailsGfn feeRulesGFN = gfnDashboardService.getFeeRules(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, feeRulesGFN.Data.FeeRules.size() == 1);

        // get customer credit data
        CreditDataGfn creditDataGfn = gfnDashboardService.getCreditData(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, creditDataGfn.Data.size() == 1);

        // get customer price rules
        AccountDetailsGfn priceRulesGFN = gfnDashboardService.getPriceRules(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, priceRulesGFN.Data.AccountPriceRules.size() == 1);

        // get customer billing documents
        AccountDetailsGfn billingDocuments = gfnDashboardService.getBillingDocuments(colCoID, integrationSettings, customerERP);
        System.assertEquals(true, billingDocuments.Data.AccountBillingDocuments.size() == 1);

        // reset user's password
        String resendPasswordResponse = gfnDashboardService.resetPassword(colCoID, integrationSettings, customerERP, userName);
        System.assertEquals(true, resendPasswordResponse == 'The password reset request submitted successfully!');

        // reset user's password
        AccountDetailsGfn getDocumentResponse = gfnDashboardService.getDocumentFromGFN(colCoID, integrationSettings, customerERP, 'test');
        System.assertEquals('test', getDocumentResponse.Data.DocumentNumber);

        // search account by card number in GFN
        AccountDetailsGfn accountParametersByCard = gfnDashboardService.searchByCardInGFN(colCoID, integrationSettings, '123456');
        System.assertEquals('11086042', accountParametersByCard.Data.SalesforceSearchByCards[0].CustomerERP);

        Test.stopTest();
    }

    @isTest static void testException(){
        initCustomSettings(true);

        Test.startTest();

        try {
            throw new GFNI_DashboardException(500, 'Test exception');
        } catch (Exception e){
            String exceptionMessage = GFNI_Utils.handleExceptionMassage(e);
            System.assertEquals('GFNI ERROR CODE: 500<br/>GFNI ERROR BODY: Test exception', exceptionMessage);
        }

        Test.stopTest();
    }

    @isTest
    public static void testGfnApi500() {
        initCustomSettings(true);
        GFNI_Settings__c integrationSettings = GFNI_DashboardCtrl.getCustomSetting('SME');
        System.assertEquals(integrationSettings.Test_endpoint__c, 'https://api.test.endpoint');

        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        GFNI_DashboardServiceImpl gfnDashboardService = new GFNI_DashboardServiceImpl();

        // get aggregated customer object (all details)
        try {
            AccountDetailsGfn aggregatedCustomerInfo = gfnDashboardService.getAggregatedCustomerObject(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer information (details)
        try {
            AccountDetailsGfn customerInformation = gfnDashboardService.getCustomerInformation(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get related customers list
        try {
            AccountDetailsGfn relatedCustomers = gfnDashboardService.getRelatedCustomers(colCoID, integrationSettings, customerERP, null);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer contacts list
        try {
        AccountDetailsGfn customerContacts = gfnDashboardService.getCustomerContacts(colCoID, integrationSettings, customerERP, null);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer addresses list
        try {
            AccountDetailsGfn customerAddresses = gfnDashboardService.getCustomerAddresses(colCoID, integrationSettings, customerERP, null);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer services list
        try {
            AccountDetailsGfn customerServices = gfnDashboardService.getCustomerServices(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer self serve users
        try {
            AccountDetailsGfn customerSelfServeUsers = gfnDashboardService.getSelfServeUsers(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer cards information
        try {
            AccountDetailsGfn customerCardsInfo = gfnDashboardService.getCustomerCardsInfo(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer unbilled transaction products
        try {
            AccountDetailsGfn customerUnbilledTransactionProducts = gfnDashboardService.getUnbilledTransactionProducts(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer unbilled transactions products
        try {
            AccountDetailsGfn customerUnbilledTransactions = gfnDashboardService.getUnbilledTransactions(colCoID, integrationSettings, customerERP, null, null, null, null);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer payment details
        try {
            AccountDetailsGfn customerPaymentDetails = gfnDashboardService.getCustomerPaymentDetails(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer information subscriptions
        try {
            AccountDetailsGfn customerInfoSubscriptions = gfnDashboardService.getInformationSubscriptions(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer credit data
        try {
            CreditDataGfn customerCreditData = gfnDashboardService.getCreditData(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // block cards
        String cardsListJson = '[{"CardID": 728390,"Reason": "Blocked by API"},{"CardID": 728391,"Reason": "Blocked by API"}, {"CardID": 728391,"Reason": "Blocked by API"}]';
        try {
            BlockCardResponseGfn blockCardResponseGfn = gfnDashboardService.blockCards(cardsListJson, colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // get customer billing documents
        try {
            AccountDetailsGfn billingDocuments = gfnDashboardService.getBillingDocuments(colCoID, integrationSettings, customerERP);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // reset user's password
        try {
            String resendPasswordResponse = gfnDashboardService.resetPassword(colCoID, integrationSettings, customerERP, userName);
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        // search account by card number in GFN
        try {
            AccountDetailsGfn searchByCardResponse = gfnDashboardService.searchByCardInGFN(colCoID, integrationSettings, '123456');
        } catch (Exception e){
            GFNI_DashboardException gfnException = (GFNI_DashboardException) e;
            System.assertEquals(500, gfnException.exceptionCode);
        }

        Test.stopTest();
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Accept' => 'application/json',
                'ColCoID' => colCoID,
                'Culture' => culture,
                'Client' => clientSystem,
                'Version' => apiVersion
        };

        SingleRequestMock getJSONCustomerAggregatedInformation = new SingleRequestMock(
                200, 'Complete',
                '{"Data": {"CustomerID":64762,"FullName":"KEP SOLUTION GMBH","CustomerERP":"DE12478550",' +
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
                        '"Registered":false,"Quota":null},{"ServiceID":1010,"ServiceDescription":"Test","ServiceTypeID":1,' +
                        '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":1005,"ServiceDescription":"TOLL","ServiceTypeID":1,"ServiceType":"Standard",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                        '"Registered":false,"Quota":null},{"ServiceID":5,"ServiceDescription":"Unsubscribed","ServiceTypeID":1,' +
                        '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"",' +
                        '"StartDate":null,"Registered":false,"Quota":null}],"InvoiceCustomerID":64762,' +
                        '"InvoiceCustomerERP":"DE12478550","InvoiceCustomerFullName":"KEP SOLUTION GMBH",' +
                        '"InvoiceCustomer":{"Description":"Get Invoice Customer","Method":"GET",' +
                        '"Link":"/SalesForce/Customer/DE12478550"},"PaymentCustomerID":64762,"PaymentCustomerERP":"DE12478550",' +
                        '"PaymentCustomerFullName":"KEP SOLUTION GMBH","PaymentCustomer":{"Description":"Get Payment Customer",' +
                        '"Method":"GET","Link":"/SalesForce/Customer/DE12478550"},"TopLevelCustomerID":1,' +
                        '"TopLevelCustomerERP":"0012199404","TopLevelCustomerFullName":"FRANK ZIMMER CONTAINER SERVICE",' +
                        '"TopLevelCustomer":{"Description":"Get Top Level Customer","Method":"GET",' +
                        '"Link":"/SalesForce/Customer/0012199404"}},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"/SalesForce/Customer/DE12478550","First":null,' +
                        '"Last":null,"Prev":null,"Next":null}}',
                responseHeaders
        );

        SingleRequestMock getJSONSummaryCustomerInformation = new SingleRequestMock(
                200, 'Complete',
                '{"Data": {"CustomerID":64762,"FullName":"KEP SOLUTION GMBH","CustomerERP":"DE12478550",' +
                        '"ClientCustomerNumber":"DE12478550","MarketingSegmentation":"Sales","StatusID":1,' +
                        '"Status":"Active","Language":"German","RegistrationNumber":"20211205998",' +
                        '"VATRegistrationNumber":"DE262285988","AverageVolume":0,"DebtorStatus":"GP Managed",' +
                        '"OutstandingDebt":789456,"OutstandingDebtCurrency":"EUR","CreditLimit":13440,' +
                        '"CreditLimitCurrency":"EUR","PaymentMethod":"SEPA DD - CORE","PaymentTerms":"7 Days",' +
                        '"Guarantee":0,"GuaranteeCurrency":"EUR","BillingFrequency":"Weekly - Sunday",' +
                        '"DefaultDistributionMethod":"Email","DefaultDistributionFormat":"PDF",' +
                        '"RelatedCustomer":{"Description":"Get Related Customers","Method":"GET",' +
                        '"Link":"/Customer/DE12478550/RelatedCustomers"},' +
                        '"AllowedStatusChanges":[{"StatusID":12,"Status":"Blocked",' +
                        '"StatusChange":{"Description":"Change customer status, Status text in body","Method":"PATCH",' +
                        '"Link":"/Customer/DE12478550/Status"}},{"StatusID":13,"Status":"Awaiting Cancel",' +
                        '"StatusChange":{"Description":"Change customer status, Status text in body",' +
                        '"Method":"PATCH","Link":"/Customer/DE12478550/Status"}}],"InvoiceCustomerID":64762,' +
                        '"InvoiceCustomerERP":"DE12478550","InvoiceCustomerFullName":"KEP SOLUTION GMBH",' +
                        '"InvoiceCustomer":{"Description":"Get Invoice Customer","Method":"GET",' +
                        '"Link":"/Customer/DE12478550"},"PaymentCustomerID":64762,"PaymentCustomerERP":"DE12478550",' +
                        '"PaymentCustomerFullName":"KEP SOLUTION GMBH","PaymentCustomer":{"Description":"Get Payment Customer",' +
                        '"Method":"GET","Link":"/Customer/DE12478550"},"TopLevelCustomerID":1,"TopLevelCustomerERP":"0012199404",' +
                        '"TopLevelCustomerFullName":"FRANK ZIMMER CONTAINER SERVICE",' +
                        '"TopLevelCustomer":{"Description":"Get Top Level Customer","Method":"GET",' +
                        '"Link":"/Customer/0012199404"}},"Meta":{"TotalPages":0},"Links":{"Self":"/Customer/DE12478550",' +
                        '"First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONRelatedCustomers = new SingleRequestMock(
                200, 'Complete',
                '{"Data":{"RelatedAccounts":[{"CustomerID":51709,"ClientCustomerNumber":"DE12366453","CustomerERP":"DE12366453",' +
                        '"ShortName":"KEP SOLUTION GMBH","Fullname":"KEP SOLUTION GMBH","StatusID":1,"Status":"Active",' +
                        '"Parent":true,"Child":false,"City":"DRESDEN","CustomerLink":{"Description":"Get Customer Summary",' +
                        '"Method":"GET","Link":"/Customer/DE12366453"}}]},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"/Customer/DE12478550/RelatedCustomers","First":null,"Last":null,"Prev":null,' +
                        '"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerContacts = new SingleRequestMock(
                200, 'Complete',
                '{"Data":{"AccountContacts":[{"CustomerID":64762,"ContactID":174160,"IsPrimary":true,"IsActive":true,' +
                        '"ContactTitleID":1,"ContactTitle":"Mr.","LanguageID":1,"LanguageCode":"GER","Language":"German",' +
                        '"SalutationWritten":"","SalutationVerbal":"","ForeName":"BERNHARDT","MiddleName":"",' +
                        '"LastName":"MAURICE","Telephone":"01733830910","Fax":"","MobilePhone":"",' +
                        '"EmailAddress":"office@kep-solution.de","MarketingCampaigns":false,"Position":"",' +
                        '"ContactTypes":[{"ContactID":174160,"ContactTypeID":1,"ContactType":"Primary Contact"},' +
                        '{"ContactID":174160,"ContactTypeID":15,"ContactType":"Authorised Contact"}]}]},' +
                        '"Meta":{"TotalPages":0},"Links":{"Self":"/Customer/DE12478550/Contacts","First":null,' +
                        '"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerAddresses = new SingleRequestMock(
                200, 'Complete',
                '{"Data":{"AccountAddresses":[{"CustomerID":64762,"AddressID":237468,"AddressLines":"CHAMISSOSTRASSE 2",' +
                        '"Region":"Saxony","ZipCode":"01157","City":"DRESDEN ","Telephone":"000491733830910","Fax":"",' +
                        '"AddressTypes":[{"AddressTypeID":2,"AddressType":"Main "},{"AddressTypeID":3,' +
                        '"AddressType":"Registered "}]},{"CustomerID":64762,"AddressID":237469,' +
                        '"AddressLines":"CHAMISSOSTRASSE 2","Region":"","ZipCode":"01157","City":"DRESDEN",' +
                        '"Telephone":"","Fax":"","AddressTypes":[{"AddressTypeID":10,"AddressType":"Card Delivery"},' +
                        '{"AddressTypeID":13,"AddressType":"Pin Delivery"}]}]},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"/Customer/DE12478550/Addresses","First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerPaymentDetails = new SingleRequestMock(
                200, 'Complete',
                '{"Data":{"PaymentCustomerID":64762,"PaymentCustomerERP":"DE12478550",' +
                        '"PaymentCustomerFullName":"KEP SOLUTION GMBH","DebtorStatus":"GP Managed",' +
                        '"OutstandingDebt":789456,"OutstandDebtCurrency":"EUR","CreditLimit":13440,' +
                        '"CreditLimitCurrency":"EUR","PaymentMethod":"SEPA DD - CORE","PaymentTerms":"7 Days",' +
                        '"Guarantee":0,"GuarenteeCurrency":"EUR"},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"/Customer/DE12478550/PaymentDetails","First":null,"Last":null,' +
                        '"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerServices = new SingleRequestMock(
                200, 'Complete',
                '{"Data":{"AccountServices":[{"ServiceID":3,"ServiceDescription":"VAT Recovery","ServiceTypeID":2,' +
                        '"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":"2017-05-15T00:00:00","Registered":true,"Quota":null},' +
                        '{"ServiceID":1008,"ServiceDescription":"55","ServiceTypeID":1,"ServiceType":"Standard",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                        '"Registered":false,"Quota":null},{"ServiceID":1009,"ServiceDescription":"carnet",' +
                        '"ServiceTypeID":2,"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,' +
                        '"MaxQuota":null,"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":1004,"ServiceDescription":"CARNET","ServiceTypeID":1,"ServiceType":"Standard",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"",' +
                        '"StartDate":null,"Registered":false,"Quota":null},{"ServiceID":2011,' +
                        '"ServiceDescription":"Carnet Communication Service","ServiceTypeID":2,' +
                        '"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":1011,"ServiceDescription":"Carnet Service","ServiceTypeID":4,"ServiceType":"Carnet",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                        '"Registered":false,"Quota":null},{"ServiceID":2,"ServiceDescription":"ClubSmart","ServiceTypeID":2,' +
                        '"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":4,"ServiceDescription":"Customer data verification","ServiceTypeID":1,' +
                        '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":1007,"ServiceDescription":"Fleetmatic","ServiceTypeID":1,"ServiceType":"Standard",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"",' +
                        '"StartDate":null,"Registered":false,"Quota":null},{"ServiceID":1,' +
                        '"ServiceDescription":"Monthly ADAC Breakdown Insurance","ServiceTypeID":2,' +
                        '"ServiceType":"Card Subscription","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":1006,"ServiceDescription":"Season discount","ServiceTypeID":1,"ServiceType":"Standard",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                        '"Registered":false,"Quota":null},{"ServiceID":1010,"ServiceDescription":"Tesst","ServiceTypeID":1,' +
                        '"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null},' +
                        '{"ServiceID":1005,"ServiceDescription":"TOLL","ServiceTypeID":1,"ServiceType":"Standard",' +
                        '"Essential":false,"QuotaRequired":false,"MaxQuota":null,"RegistrationNumber":"","StartDate":null,' +
                        '"Registered":false,"Quota":null},{"ServiceID":5,"ServiceDescription":"Unsubscribed",' +
                        '"ServiceTypeID":1,"ServiceType":"Standard","Essential":false,"QuotaRequired":false,"MaxQuota":null,' +
                        '"RegistrationNumber":"","StartDate":null,"Registered":false,"Quota":null}]},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"/Customer/DE12478550/Services","First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerSelfServeUsers = new SingleRequestMock(
                200, 'Complete',
                '{"Data":' +
                        '{"AccountSelfServeUsers":[{"UserID":38352,"LoginName":"DE12366453 ","Title":"HERR",' +
                        '"FirstName":"MAURICE","LastName":"BERNHARD","TelephoneNumber":null,' +
                        '"EMailAddress":"office@kep-solution.de","CultureID":1,"Culture":"German",' +
                        '"LastLogin":"2017-11-17T12:25:48.713","LastActivity":"2017-11-17T12:25:48.713",' +
                        '"LoginAttempts":0,"LockoutTime":null,"LockExpiry":null,"CreatedDate":"2014-11-10T12:06:34.387",' +
                        '"isLocked":false,"OptOutOfEMail":false,"ContactID":null,"UserTypeID":1,"UserType":"Customer",' +
                        '"isActive":true,"UITypeID":2,"UIType":"Customer Self Serve"}]},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"/Customer/DE12478550/Self-Serve-Users","First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerCardsInfo = new SingleRequestMock(
                200, 'Complete',
                '{"Data":' +
                        '{"SalesforceCards":[{"CardID":295330,"PAN":"7077141266471249910","ExpiryDate":"2018-08-31T00:00:00",' +
                        '"IssueNumber":1,"CardTypeID":1,"CardType":"DE CRT National Single","StatusID":8,"Status":"Expired",' +
                        '"LastStatusChange":"2010-09-01T00:00:03.24","RegNumber":"ABC 123","IsRegNumberEmbossed":true,"DriverName":null,' +
                        '"IsDriverNameEmbossed":false,"PurchaseCategoryID":2,"PurchaseCategory":"1 - All Fuel Products",' +
                        '"EffectiveDate":"2014-09-19T00:00:00","CardGroup":"HAUS12345","IsOdometerPromptRequired":true},' +
                        '{"CardID":296196,"PAN":"7077140000000100026","ExpiryDate":"2018-08-31T00:00:00","IssueNumber":1,' +
                        '"CardTypeID":1,"CardType":"DE CRT National Single","StatusID":8,"Status":"Expired",' +
                        '"LastStatusChange":"2010-09-01T00:00:03.24","RegNumber":"MICHELLE TEST","IsRegNumberEmbossed":true,"DriverName":null,' +
                        '"IsDriverNameEmbossed":false,"PurchaseCategoryID":1,"PurchaseCategory":"0 - Diesel Products",' +
                        '"EffectiveDate":"2014-09-26T00:00:00","CardGroup":"HAUS12345","IsOdometerPromptRequired":true}]},' +
                        '"Meta":{"TotalPages":0},"Links":{"Self":null,"First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerUnbilledProducts = new SingleRequestMock(
                200, 'Complete',
                '{"Data":' +
                        '{"UnbilledProducts":[{"ProductID":30,"Product":"Diesel AGO","Occurances":18},{"ProductID":22,' +
                        '"Product":"Unleaded - Medium octane","Occurances":10}]},"Meta":{"TotalPages":0},' +
                        '"Links":{"Self":"SalesForce/Customer/11908392/UnbilledTransactionProducts",' +
                        '"First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerUnbilledTransactions = new SingleRequestMock(
                200, 'Complete',
                '{"Data":' +
                        '{"UnbilledTransactions":[{"SalesItemID":37001550,"SalesDateTime":"2017-11-15T07:36:00",' +
                        '"Card":"7002147265880480431","SiteID":2,"SiteLocation":"HAMBURG","SiteNumber":"E999",' +
                        '"SiteCountry":"Germany","DriverName":null,"VRN":"D VZ 111","ProductID":30,' +
                        '"Product":"Diesel AGO","Quantity":62.720000,"AmountGross":75.080000,"AmountNet":63.090000,' +
                        '"AmountVat":11.990000},{"SalesItemID":36998451,"SalesDateTime":"2017-11-15T14:18:00",' +
                        '"Card":"7002147051500156019","SiteID":716,"SiteLocation":"BUETTELBORN","SiteNumber":"9806",' +
                        '"SiteCountry":"Germany","DriverName":null,"VRN":"D VZ 30","ProductID":30,"Product":"Diesel AGO",' +
                        '"Quantity":43.470000,"AmountGross":57.260000,"AmountNet":48.120000,"AmountVat":9.140000}]},' +
                        '"Meta":{"TotalPages":0},"Links":{"Self":"SalesForce/Customer/11837073/UnbilledTransactions",' +
                        '"First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerInformationSubscriptions = new SingleRequestMock(
                200, 'Complete',
                '{"Data":' +
                        '{"InfoSubscriptions":[{"InfoSubscriptionID":73099,"InfoProviderID":4,"InfoProvider":"Invoice",' +
                        '"FrequencyTypeID":10,"FrequencyType":"Monthly - 1st","RunFrequencyTypeID":10,' +
                        '"RunFrequencyType":"Monthly - 1st","DateEffective":"2017-02-17T00:00:00",' +
                        '"DateTerminated":"9999-12-31T00:00:00","isSummary":false,' +
                        '"InfoSubscriptionDetails":[{"InfoSubscriptionID":73099,"InfoSubscriptionDetailID":78190,' +
                        '"isPrimary":true,"isActive":true,"DistributionMethodID":1,"DistributionMethod":"Email",' +
                        '"AlternativeDistributionMethodID":5,"AlternativeDistributionMethod":"Print","OutputTypeID":28,' +
                        '"OutputType":"Link","SuppressContact":true,"AccountInfoSubscriptionContacts":[{"InfoSubscriptionID":73099,' +
                        '"InfoSubscriptionDetailID":78190,"ContactID":183041,"isPrimary":true,"isActive":true,' +
                        '"AddressID":251362,"ContactTitleID":1,"ContactTitle":"Mr.","LanguageID":1,"Language":"German",' +
                        '"ForeName":"MILAN","MiddleName":null,"LastName":"KLJAJIC","Telephone":"015167400635","Fax":null,' +
                        '"EMailAddress":"m.k-transport@web.de","Position":"INHABER","AddressLines":"SIEMENSSTR. 1",' +
                        '"Zipcode":"90459","City":"NUERNBERG","RegionID":2,"Region":"Bavaria","CountryID":1,' +
                        '"Country":"Germany"}]}]}]},"Meta":{"TotalPages":0},"Links":{"Self":"/Customer/DE12484904/InformationSubscriptions",' +
                        '"First":null,"Last":null,"Prev":null,"Next":null}}',
                responseHeaders);

        SingleRequestMock getJSONCustomerBlockCards = new SingleRequestMock(
                200, 'Complete',
                '{"BlockRequests": [{"CardID": 728390,"BlockRequested": true,"Error": null},' +
                        '{"CardID": 728391,"BlockRequested": true,"Error": null},' +
                        '{"CardID": 728392,"BlockRequested": true,"Error": null}]}',
                responseHeaders);

        SingleRequestMock getJSONHomeSites = new SingleRequestMock(
            200, 'Complete',
                '{"Data": {"HomeSites": [{"CustomerHomeSiteID": 34,' + 
                '"SiteID": 690,"DateEffective": "2019-02-26T00:00:00",'+
                '"DateTerminated": "9999-12-31T00:00:00","SiteCode": "1234",' +
                '"FullName": "LEIPZIGER STR","ShortName": "LEIPZIGER STR",' +
                '"Latitude": 50.570085, "Longitude": 9.696292,' +
                '"AddressLines": "MÜNCHENER STR. 42", "City": "ERDING",' +
                '"RegionID": 2,"Region": "Bavaria","CountryID": 1,"ZipCode": "85435"}]},' +
                '"Meta": {"TotalPages": 0},"Links": {"Self": "string","First": "string","Last": "string",' +
                '"Prev": "string","Next": "string"}}',
            responseHeaders
        );

        SingleRequestMock getJSONFeeRules = new SingleRequestMock(
            200, 'Complete',
            '{"Data": {"FeeRules": [{"FeeRuleID": 52,"FeeRuleDescription": "SG Arl. 3 %",' +
            '"FeeTypeID": 42,"FeeType": "Transaction Fee Gross","FrequencyTypeID": 1,' +
            '"FrequencyType": "string","ProductID": 1004,"Product": "Network Service Fee",'+
            '"FeeRuleBasisID": 2,"FeeRuleBasis": "Percentage of Uplift","MinValue": 0,'+
            '"MaxValue": 999999999,"CurrencyID": 1,"Currency": "Euro","FeeTiers": [{' +
            '"FeeRuleID": 62,"FeeRuleTierID": 42,"DateEffective": "2014-01-01T00:00:00",' +
            '"DateTerminated": "9999-12-31T00:00:00","TierMin": 0,"TierMax": 999999999,'+
            '"Value": 0.025,"BaseValue": 0.025,"UpliftValue": 0.025,"AllowedEditUplift": false}]}]},'+
            '"Meta": {"TotalPages": 0},"Links": {"Self": "string","First": "string","Last": "string",' +
            '"Prev": "string","Next": "string"}}',
            responseHeaders
        );

        SingleRequestMock getJSONPriceRules = new SingleRequestMock(
            200, 'Complete',
            '{"Data": {"AccountPriceRules": [{"PriceRuleID": 12964,"PriceRuleDescription": "GEN/0,05/9500/DKV_INT",' +
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
            '"DateTerminated": "9999-12-31T00:00:00","Value": -0.033}]}]},"Meta": {"TotalPages": 0},' +
            '"Links": {"Self": "string","First": "string","Last": "string","Prev": "string","Next": "string"}}',
            responseHeaders
        );

        SingleRequestMock getJSONBillingDocuments = new SingleRequestMock(
            200, 'Complete',
            '{"Data": {"AccountBillingDocuments": [{"DocumentID": 778993,"DocumentNumber": "785961/6161560133/2016",' +
            '"DocumentDate": "2016-01-03T00:00:00","PaymentDueDate": "2016-01-13T00:00:00","TotalGross": 1484.9300,' +
            '"AmountAllocated": 0.000000,"DocumentTypeID": 1,"DocumentType": "Invoice","DelcoID": null,"Delco": null,' +
            '"DelcoClientCompanyNumber": null,"BillingOrSummary": "SBD",' +
            '"InvoicePdfLink": "/Customer/invoice-pdf/785961/6161560133/2016"}]},' +
            '"Meta": {"TotalPages": 0},"Links": {"Self": "SalesForce/Customer/DE12361615/BillingDocuments",' +
            '"First": null,"Last": null,"Prev": null,"Next": null}}', responseHeaders
        );

        SingleRequestMock getJSONResendPasswordResponse = new SingleRequestMock(
            200, 'Complete',
            'The password reset request submitted successfully!',
            responseHeaders);


        SingleRequestMock getJSONPDFData = new SingleRequestMock(
            200, 'Complete',
            '{"Data": {"DocumentNumber": "test", "PdfData":"GVzdA=="}}',
            responseHeaders);

        SingleRequestMock searchByCardGFN = new SingleRequestMock(
            200, 'Complete',
            '{"Data": {"SalesforceSearchByCards": [{"ColCoID":1, "CustomerERP": "11086042"}]}}',
            responseHeaders);

        SingleRequestMock searchByPanGfn = new SingleRequestMock(
            200, 'Complete',
            '{"Data": {"AccountByPANs": [{"CardID": 26939,"PAN": "7002335401617900027","CardType": "SK Fleet National Single",' +
            '"ExpiryDate": "2021-02-28T00:00:00","IssueNumber": 1,"CardStatusID": 9,"CardStatus": "Cancelled","CustomerID": 1997,' +
            '"CustomerERP": "SK00013397","FullName": "Fincentrum a.s. ","ShortName": "FINCENTRUM AS","CustomerStatusID": 1,' +
            '"CustomerStatus": "Active"}]}',
            responseHeaders);

        SingleRequestMock creditDataGfn = new SingleRequestMock(
            200, 'Complete',
            '{ "Data": [{"CustomerID": 123456,"CustomerERP": "D123123","ExternalAccountingClerk": "test"}]}',
            responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP, getJSONCustomerAggregatedInformation);
        responses.put(baseTestURL + '/Customer/' + customerERP, getJSONSummaryCustomerInformation);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/RelatedCustomers', getJSONRelatedCustomers);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Contacts', getJSONCustomerContacts);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Addresses', getJSONCustomerAddresses);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/PaymentDetails', getJSONCustomerPaymentDetails);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Services', getJSONCustomerServices);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Self-Serve-Users', getJSONCustomerSelfServeUsers);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/Cards', getJSONCustomerCardsInfo);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/UnbilledTransactionProducts', getJSONCustomerUnbilledProducts);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/UnbilledTransactions?', getJSONCustomerUnbilledTransactions);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/InformationSubscriptions', getJSONCustomerInformationSubscriptions);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/BlockCards', getJSONCustomerBlockCards);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/HomeSites', getJSONHomeSites);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/NationalPriceRules', getJSONPriceRules);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/FeeRules', getJSONFeeRules);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/CreditData', creditDataGfn);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/BillingDocuments?DateFrom=1900-01-01&DateTo=9999-01-01', getJSONBillingDocuments);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Self-Serve-Users/' + userName + '/Reset-Password', getJSONResendPasswordResponse);
        responses.put(baseTestURL + '/Customer/invoice-pdf/test', getJSONPDFData);
        responses.put(baseTestURL + '/SalesForce/SearchByCard/123456', searchByCardGFN);
        responses.put(baseTestURL + '/Customer/ByPAN/123456', searchByPanGfn);
        return responses;
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Accept' => 'application/json',
                'ColCoID' => colCoID,
                'Culture' => culture,
                'Client' => clientSystem,
                'Version' => apiVersion
        };

        SingleRequestMock getJSONCustomerAggregatedInformation500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONSummaryCustomerInformation500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONRelatedCustomers500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerContacts500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerAddresses500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerPaymentDetails500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerServices500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerSelfServeUsers500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerCardsInfo500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerUnbilledProducts500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerUnbilledTransactions500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerInformationSubscriptions500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONCustomerBlockCards500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONHomeSites500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONPriceRules500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONFeeRules500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);                
        SingleRequestMock getJSONBillingDocuments500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock getJSONResendPasswordResponse500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock searchByCardGFNResponse500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock searchByPanGfn500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);
        SingleRequestMock searchCreditDataGfn500 = new SingleRequestMock(500, 'Failed',
                'Bad Request', responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP, getJSONCustomerAggregatedInformation500);
        responses.put(baseTestURL + '/Customer/' + customerERP, getJSONSummaryCustomerInformation500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/RelatedCustomers', getJSONRelatedCustomers500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Contacts', getJSONCustomerContacts500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Addresses', getJSONCustomerAddresses500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/PaymentDetails', getJSONCustomerPaymentDetails500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Services', getJSONCustomerServices500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Self-Serve-Users', getJSONCustomerSelfServeUsers500);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/Cards', getJSONCustomerCardsInfo500);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/UnbilledTransactionProducts', getJSONCustomerUnbilledProducts500);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/UnbilledTransactions?', getJSONCustomerUnbilledTransactions500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/InformationSubscriptions', getJSONCustomerInformationSubscriptions500);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/BlockCards', getJSONCustomerBlockCards500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/HomeSites', getJSONHomeSites500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/NationalPriceRules', getJSONPriceRules500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/FeeRules', getJSONFeeRules500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/CreditData', searchCreditDataGfn500);
        responses.put(baseTestURL + '/SalesForce/Customer/' + customerERP + '/BillingDocuments?DateFrom=1900-01-01&DateTo=9999-01-01', getJSONBillingDocuments500);
        responses.put(baseTestURL + '/Customer/' + customerERP + '/Self-Serve-Users/' + userName + '/Reset-Password', getJSONResendPasswordResponse500);
        responses.put(baseTestURL + '/SalesForce/SearchByCard/123456', searchByCardGFNResponse500);
        responses.put(baseTestURL + '/Customer/ByPAN/123456', searchByPanGfn500);
        return responses;
    }
}