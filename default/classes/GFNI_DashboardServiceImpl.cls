public with sharing class GFNI_DashboardServiceImpl implements GFNI_DashboardService {

    private GFNI_Settings__c integrationSettings;
    private static String apiClientId = '';
    private static String apiClientSecretId = '';

    
    /*******************************************************************************
    *  Name            : getIntegrationUrl()
    *  Summary         : get integration url settings from custom settings
    *  CreatedDate     : 25/07/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String getIntegrationUrl(GFNI_Settings__c integrationSettings){
        if(!integrationSettings.Test_mode__c){
            System.debug('**** Using GFN_PROD_URL for GFN request');
            return integrationSettings.Prod_endpoint__c;
        } else {
            System.debug('**** Using GFN_TEST_URL for GFN request');
            return integrationSettings.Test_endpoint__c;
        }
    }


    /*******************************************************************************
    *  Name            : getAggregatedCustomerObject(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get full aggregated customer information from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getAggregatedCustomerObject(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/SalesForce/Customer/' + customerERP;
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getAggregatedCustomerObject()', 'GET');
        AccountDetailsGfn aggregatedCustomerObject = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return aggregatedCustomerObject;
    }

    /*******************************************************************************
    *  Name            : getCustomerInformation(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer information from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getCustomerInformation(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
    // public AccountDetailsGfn getCustomerInformation(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP;
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCustomerInformation()', 'GET');
        // String responseBody = getResponseFromGfn(url, null, colCoID, culture, clientSystem, apiVersion, customerERP, 'getCustomerInformation()', 'GET');
        AccountDetailsGfn customerInformation = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return customerInformation;
    }

    /*******************************************************************************
    *  Name            : getRelatedCustomers(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP, String status)
    *  Summary         : get related customers list from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP, String status - Return only related customer with the same culture Status description. Example Active
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getRelatedCustomers(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String status) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/RelatedCustomers' + (status == null ? '' : '?Status=' + status);
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getRelatedCustomers()', 'GET');
        AccountDetailsGfn relatedCustomers = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return relatedCustomers;
    }

    /*******************************************************************************
    *  Name            : getCustomerAddresses(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP, String addressType)
    *  Summary         : get customer addresses list from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP, String addressType - only return addresses of the address type
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getCustomerAddresses(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String addressType) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/Addresses' + (addressType == null ? '' : '?AddressType=' + addressType);
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCustomerAddresses()', 'GET');
        AccountDetailsGfn customerAddresses = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return customerAddresses;
    }

    /*******************************************************************************
    *  Name            : getCustomerContacts(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP, String contactType)
    *  Summary         : get customer contacts list from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP, String contactType - only return Contacts of this contact type
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getCustomerContacts(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String contactType) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/Contacts' + (contactType == null ? '' : '?ContactType=' + contactType);
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCustomerContacts()', 'GET');
        AccountDetailsGfn customerContacts = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return customerContacts;
    }

    /*******************************************************************************
    *  Name            : getCustomerServices(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer services list from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getCustomerServices(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/Services';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCustomerServices()', 'GET');
        AccountDetailsGfn customerServices = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return customerServices;
    }

    /*******************************************************************************
    *  Name            : getSelfServeUsers(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer self service users list from GFN by colCoID and customerERP
    *  CreatedDate     : 14/08/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getSelfServeUsers(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/Self-Serve-Users';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getSelfServeUsers()', 'GET');
        AccountDetailsGfn selfServeUsers = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return selfServeUsers;
    }

    /*******************************************************************************
    *  Name            : getCustomerCardsInfo(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer cards list with information from GFN by colCoID and customerERP
    *  CreatedDate     : 16/08/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getCustomerCardsInfo(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/SalesForce/Customer/' + customerERP + '/Cards';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCustomerCardsInfo()', 'GET');
        AccountDetailsGfn customerCardsInfo = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return customerCardsInfo;
    }

    /*******************************************************************************
    *  Name            : getUnbilledTransactionProducts(String colCoID, String culture, String clientSystem,
    *                    String apiVersion, String customerERP)
    *  Summary         : get customer unbilled transaction products list from GFN by colCoID and customerERP
    *  CreatedDate     : 29/08/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getUnbilledTransactionProducts(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/SalesForce/Customer/' + customerERP + '/UnbilledTransactionProducts';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getUnbilledTransactionProducts()', 'GET');
        AccountDetailsGfn unbilledTransactionProducts = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return unbilledTransactionProducts;
    }

    /*******************************************************************************
    *  Name            : getUnbilledTransactions(String colCoID, String culture, String clientSystem,
    *                    String apiVersion, String customerERP, String dateFrom, String dateTo, String cardNumber, String product)
    *  Summary         : get customer unbilled transactions list from GFN by colCoID, customerERP, and filters (without filters return all data)
    *  CreatedDate     : 29/08/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP, String dateFrom - is including and from date which filters on the SalesDate,
    *                    String dateTo - is an up to and including date which filters on the SalesDate,
    *                    String cardNumber - is the trailing digits of the Card PAN number, String product - exact match
     *                   on the Product associated with a transaction
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getUnbilledTransactions(String colCoID, GFNI_Settings__c integrationSettings,
            String customerERP, String dateFrom, String dateTo, String cardNumber, String product) {

        String integrationUrl = getIntegrationUrl(integrationSettings);

        String dateFromParam = (dateFrom != null && dateFrom != '') ? 'DateFrom=' + dateFrom + '&' : '';
        String dateToParam = (dateTo != null && dateTo != '') ? 'DateTo=' + dateTo + '&' : '';
        String cardNumberParam = (cardNumber != null && cardNumber != '') ? 'Card=' + cardNumber + '&' : '';
        String productParam = (product != null && product != '') ? 'Product=' + product : '';
        String url = integrationUrl + '/SalesForce/Customer/' + customerERP + '/UnbilledTransactions?' +
                dateFromParam + dateToParam + cardNumberParam + productParam;
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getUnbilledTransactions()', 'GET');
        AccountDetailsGfn unbilledTransactions = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return unbilledTransactions;
    }

    /*******************************************************************************
    *  Name            : getCustomerPaymentDetails(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer payment details information from GFN by colCoID and customerERP
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getCustomerPaymentDetails(String colCoID, GFNI_Settings__c integrationSettings, String customerERP) {
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/PaymentDetails';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCustomerPaymentDetails()', 'GET');
        AccountDetailsGfn customerPaymentDetails = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return customerPaymentDetails;
    }

    /*******************************************************************************
    *  Name            : getInformationSubscriptions(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer information subscription list from GFN by colCoID and customerERP
    *  CreatedDate     : 05/08/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getInformationSubscriptions(String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/InformationSubscriptions';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getInformationSubscriptions()', 'GET');
        AccountDetailsGfn informationSubscriptions = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return informationSubscriptions;
    }

    /*******************************************************************************
    *  Name            : blockCards(String cardsListJson, String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : block cards in GFN by card Id, colCoID, and customerERP
    *  CreatedDate     : 09/09/2019
    *  Parameters      : String cardsListJson - a list of cards (JSON string) that should be block in GFN,
    *                    String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public BlockCardResponseGfn blockCards(String cardsListJson, String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/SalesForce/Customer/' + customerERP + '/BlockCards';
        String responseBody = getResponseFromGfn(url, cardsListJson, colCoID, integrationSettings, customerERP, 'blockCards()', 'POST');
        BlockCardResponseGfn blockCardResponse = responseBody != '' ? (BlockCardResponseGfn) JSON.deserialize(responseBody, BlockCardResponseGfn.class) : new BlockCardResponseGfn();
        return blockCardResponse;
    }

    /*******************************************************************************
    *  Name            : getFeeRules(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer fee rules from GFN by colCoID and customerERP
    *  CreatedDate     : 20/09/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getFeeRules(String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/FeeRules';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getFeeRules()', 'GET');
        AccountDetailsGfn feeRules = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return feeRules;
    }

    /*******************************************************************************
    *  Name            : getBillingDocuments(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer billing documents from GFN by colCoID and customerERP
    *  CreatedDate     : 30/09/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getBillingDocuments(String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/SalesForce/Customer/' + customerERP + '/BillingDocuments?DateFrom=1900-01-01&DateTo=9999-01-01';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getBillingDocuments()', 'GET');
        AccountDetailsGfn billingDocuments = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return billingDocuments;
    }

    /*******************************************************************************
    *  Name            : getDocumentFromGFN(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP, String documentNumber)
    *  Summary         : get pdf document from GFN by colCoID and customerERP
    *  CreatedDate     : 18/10/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP,
    *                    String documentNumber - number of document
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getDocumentFromGFN(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String documentNumber){
        String integrationUrl = getIntegrationUrl(integrationSettings);
        String url = '';
        if (integrationSettings.Client_System__c == 'CCS') {
            url = integrationUrl + '/Customer/'+customerERP+'/invoice-pdf/' + documentNumber;
        }
        else {
            url = integrationUrl + '/Customer/invoice-pdf/' + documentNumber;
        }
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getDocumentFromGFN()', 'GET');
        AccountDetailsGfn document = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return document;
    }

    /*******************************************************************************
    *  Name            : resetPassword(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP, String userName)
    *  Summary         : reset password by GFN
    *  CreatedDate     : 30/09/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *                    String userName - userName for resetting password
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public String resetPassword(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String userName){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        if(userName != null){
            username = EncodingUtil.urlEncode(EncodingUtil.urlEncode(username, 'UTF-8'), 'UTF-8');
            username = username.replace('.' , '%252E');
        }
        String url = integrationUrl + '/Customer/' + customerERP + '/Self-Serve-Users/' + userName + '/Reset-Password';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'resetPassword()', 'POST');
        return responseBody;
    }

    /*******************************************************************************
    *  Name            : getPriceRules(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer price rules from GFN by colCoID and customerERP
    *  CreatedDate     : 20/09/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getPriceRules(String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/NationalPriceRules';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getPriceRules()', 'GET');
        AccountDetailsGfn priceRules = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return priceRules;
    }

    /*******************************************************************************
    *  Name            : getHomeSites(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer information about home site from GFN by colCoID and customerERP
    *  CreatedDate     : 20/09/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn getHomeSites(String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/HomeSites';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getHomeSites()', 'GET');
        AccountDetailsGfn homeSites = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return homeSites;
    }

    /*******************************************************************************
    *  Name            : getCreditData(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer information about credit data from GFN by colCoID and customerERP
    *  CreatedDate     : 08/09/2020
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP
    *  Returns         : CreditDataGfn
    ******************************************************************************/
    public CreditDataGfn getCreditData(String colCoID, GFNI_Settings__c integrationSettings, String customerERP){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/' + customerERP + '/CreditData';
        String responseBody = getResponseFromGfn(url, null, colCoID, integrationSettings, customerERP, 'getCreditData ()', 'GET');
        CreditDataGfn creditData = responseBody != '' ? (CreditDataGfn) JSON.deserialize(responseBody, CreditDataGfn.class) : new CreditDataGfn();
        return creditData;
    }

    /*******************************************************************************
    *  Name            : searchByCardInGFN(String colCoID, String culture, String clientSystem, String apiVersion, String customerERP)
    *  Summary         : get customer ERP and colCoId from GFN by card PAN
    *  CreatedDate     : 26/11/2019
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String cardNumber - card Number
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    public AccountDetailsGfn searchByCardInGFN(String colCoID, GFNI_Settings__c integrationSettings, String cardNumber){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/SalesForce/SearchByCard/' + cardNumber;
        HttpResponse response = new HttpResponse();
        response = sendRequest(url, null, colCoID, integrationSettings, null, 'GET');
        String responseBody = (response.getStatusCode() == 200) ? response.getBody() : '';
        AccountDetailsGfn accountParams = responseBody != '' ? (AccountDetailsGfn) JSON.deserialize(responseBody, AccountDetailsGfn.class) : new AccountDetailsGfn();
        return accountParams;
    }

    /*******************************************************************************
    *  Name            : searchByPanInGFN
    *  Summary         : get customer ERP and colCoId from GFN by card PAN
    *  Created         : 17/02/2020 by Anton Hrytsavets
    *  Parameters      : String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String cardNumber - card Number
    *  Returns         : AccountDetailsGfn - wrapper with returned details
    ******************************************************************************/
    public String searchByPanInGFN(String colCoID, GFNI_Settings__c integrationSettings, String cardNumber){
        String integrationUrl = getIntegrationUrl(integrationSettings);

        String url = integrationUrl + '/Customer/ByPAN/' + cardNumber;
        HttpResponse response = new HttpResponse();
        response = sendRequest(url, null, colCoID, integrationSettings, null, 'GET');
        String responseBody = (response.getStatusCode() == 200) ? response.getBody() : '';
        return responseBody;
    }

    /*******************************************************************************
    *  Name            : getResponseFromGfn(String url, String requestBody, String colCoID, String culture, String clientSystem,
    *                    String apiVersion, String customerERP, String methodName, String requestType)
    *  Summary         : main method to get account details from GFN by colCoID and customerERP
    *  CreatedDate     : 09/09/2019
    *  Parameters      : String url - url for request, String colCoID - Client Company Identifier,
    *                    String requestBody - data as request body,
    *                    String culture - Culture to use - if not defined uses en-GB, String clientSystem - client system to use,
    *                    String apiVersion - version of API to use, if not defined uses 1, String customerERP - GFN CustomerERP,
    *                    String methodName - method's name to use it in debug and error messages,
    *                    String requestType - method type for request
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/

    private String getResponseFromGfn(String url, String requestBody, String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String methodName, String requestType){
        System.debug('**** getResponseFromGfn url = ' + url);
        HttpResponse response = new HttpResponse();
        String responseBody = '';
        if(colCoID != null && colCoID != '' && customerERP != null && customerERP != ''){
            response = sendRequest(url, requestBody, colCoID, integrationSettings, customerERP, requestType);
            responseBody = (response.getStatusCode() == 200) ? response.getBody() : '';
        } else {
            createResponseDebugMessage(methodName, colCoID, integrationSettings, customerERP, url, response, 'ColCoID or customerERP is missing! Request to GFN was not sent.');
        }
        return responseBody;
    }

    /*******************************************************************************
    *  Name            : createResponseDebugMessage(String methodName, String colCoID, String culture, String clientSystem,
    *                    String apiVersion, String customerERP, String url, HttpResponse response, String exceptionStackTrace)
    *  Summary         : create response debug message and send it by email
    *  CreatedDate     : 25/07/2019
    *  Parameters      : String methodName - method's name to use it in debug and error messages,
    *                    String colCoID - Client Company Identifier, String culture - Culture to use - if not defined uses en-GB,
    *                    String clientSystem - client system to use, String apiVersion - version of API to use, if not defined uses 1,
    *                    String customerERP - GFN CustomerERP, String url - url for request, HttpResponse response - response from GFN,
    *                    String exceptionStackTrace - exception error message
    *  Returns         : AccountDetailsGfn
    ******************************************************************************/
    private static void createResponseDebugMessage(String methodName, String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String url, HttpResponse response, String exceptionStackTrace){
        Integer code;
        if(response != null){
            code = response.getStatusCode();
        }
        System.debug('**** GFN RESPONSE CODE: ' + code + ', BODY: ' + (response != null ? response.getBody() : ''));
        if(code != 200){
            String notificationMessage = '<br/>GFNI_DashboardServiceImpl ' + methodName;
            String stackTraceString = '<br/>response code = ' + code + '<br/>colCoID = ' + colCoID +
                    '<br/>culture = ' + integrationSettings.Culture__c + '<br/>clientSystem = ' + integrationSettings.Client_system__c +
                    '<br/>apiVersion = ' + integrationSettings.Api_Version__c + '<br/>customerERP = ' + customerERP + '<br/>url = ' + url +
                    '<br/>responseBody = ' + response + '<br/>exception = ' + exceptionStackTrace;
            System.debug('**** DebugMessage: ' + notificationMessage + '\n' + stackTraceString);
            // if(!Test.isRunningTest()){
            //     // ExceptionLogger.sendException(notificationMessage, stackTraceString);
            //     sendExceptionMessageFuture(notificationMessage, stackTraceString);
            // }
            if(response != null){
                throw new GFNI_DashboardException(response.getStatusCode(), response.getBody());
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendRequest(String url, String requestBody, String colCoID, String culture, String clientSystem, String apiVersion, String customerERP, String method)
    *  Summary         : send request to GFN
    *  CreatedDate     : 09/09/2019
    *  Parameters      : String url - url for request, String colCoID - Client Company Identifier,
    *                    String requestBody - data as request body,
    *                    String culture - Culture to use - if not defined uses en-GB, String clientSystem - client system to use,
    *                    String apiVersion - version of API to use, if not defined uses 1, String customerERP - GFN CustomerERP,
    *                    String requestType - method type for request
    *  Returns         : String
    ******************************************************************************/
    @TestVisible
    private static HttpResponse sendRequest(String url, String requestBody, String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String requestType) {
        String apiClientId;
        String apiClientSecretId;

        if (UserInfo.getOrganizationId() == '00D20000000oB2EEAU') {
            apiClientId = integrationSettings.x_ibm_client_id__c;
            apiClientSecretId = integrationSettings.x_ibm_client_secret__c;
        } else {
            apiClientId = integrationSettings.test_x_ibm_client_id__c;
            apiClientSecretId = integrationSettings.test_x_ibm_client_secret__c;
        }

        System.debug('**** API CLIENT REQUEST SETTINGS  = ' + apiClientId + ', ' + apiClientSecretId);

        HttpRequest request = new HttpRequest();
        request.setHeader('Accept', 'application/json');
        request.setHeader('ColCoID', colCoID);
        request.setHeader('Culture', integrationSettings.Culture__c);
        request.setHeader('Client', integrationSettings.Client_system__c);
        request.setHeader('Version', integrationSettings.API_version__c);
        if (!Test.isRunningTest()) {
            if(apiClientId != '') request.setHeader('x-ibm-client-id', apiClientId);
            if(apiClientSecretId != '') request.setHeader('x-ibm-client-secret', apiClientSecretId);
        }
        request.setMethod(requestType);
        request.setEndpoint(url);
        request.setTimeout(120000);
        if(requestType == 'POST'){
            request.setHeader('Content-Type', 'application/json');
            if(requestBody != null) request.setBody(requestBody);
            System.debug('**** REQUEST BODY = ' + requestBody);
        }
        System.debug('**** API PARAMS: colCoID = ' + colCoID  + ' customerERP = ' + customerERP + ' REQUEST = ' + request);

        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200) { // GFN response code
            createResponseDebugMessage(null, colCoID, integrationSettings, customerERP, url, response, null);
        }
        response.setBody(response.getBody().replace('"Currency"', '"GFNCurrency"'));
        return response;
    }

}