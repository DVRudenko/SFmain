public with sharing class GFNI_DashboardHandler {


    /*******************************************************************************
    *  Name            : getGfnSystemBaseUrlForLandingPage()
    *  Summary         : get GFN system base url settings from custom settings
    *  CreatedDate     : 25/07/2019
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String getGfnSystemBaseUrlForLandingPage(GFNI_Settings__c integrationSettings){
        if(integrationSettings.Test_mode__c){
            return integrationSettings.Test_GFN_System_base_URL__c;
        } else {
            return integrationSettings.GFN_System_base_URL__c;
        }
    }

    /*******************************************************************************
    *  Name            : getGfnAccountDetails(AccountDetailsGfn customerInfo, AccountDetailsGfn relatedCustomers,
    *                    String colCoID, String customerERP)
    *  Summary         : get GFN account details from GFN Service
    *  CreatedDate     : 25/07/2019
    *  Parameters      : AccountDetailsGfn customerInfo - customer information from GFN,
    *                    AccountDetailsGfn relatedCustomers - related customers list from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountDetails(AccountDetailsGfn customerInfo, AccountDetailsGfn relatedCustomers,
            String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainCustomerLandingPage = getLandingPageUrl(colCoID, customerERP, 'maintaincustomer', integrationSettings);
        String customerStatusLandingPage = getLandingPageUrl(colCoID, customerERP, 'customerstatus', integrationSettings);
        Map<String, String> accountDetailsGfn = new Map<String, String>();
        if(customerInfo != null && customerInfo.Data != null){
            accountDetailsGfn.put('FullName', customerInfo.Data.FullName);
            accountDetailsGfn.put('Status', customerInfo.Data.Status);
            accountDetailsGfn.put('GfnNum', customerInfo.Data.CustomerERP);
            accountDetailsGfn.put('RegNum', customerInfo.Data.RegistrationNumber);
            accountDetailsGfn.put('Vat', customerInfo.Data.VATRegistrationNumber);
            accountDetailsGfn.put('Lang', customerInfo.Data.Language);
            accountDetailsGfn.put('MarketSegment', customerInfo.Data.MarketingSegmentation);
            accountDetailsGfn.put('AvgVolume', JSON.serialize(customerInfo.Data.AverageVolume));
            accountDetailsGfn.put('DebtorStatus', customerInfo.Data.DebtorStatus);
            accountDetailsGfn.put('LineOfBusiness', customerInfo.Data.LineOfBusiness);
            accountDetailsGfn.put('CustomerClassification', customerInfo.Data.CustomerClassification);
            accountDetailsGfn.put('StartDate', customerInfo.Data.StartDate);
            accountDetailsGfn.put('RelatedAccounts', JSON.serialize(relatedCustomers.Data.RelatedAccounts));
            String accountType = checkTypeOfAccount(relatedCustomers.Data.RelatedAccounts);
            accountDetailsGfn.put('AccountType', accountType);
        }
        accountDetailsGfn.put('MaintainCustomerLandingPage', maintainCustomerLandingPage);
        accountDetailsGfn.put('CustomerStatusLandingPage', customerStatusLandingPage);
        return accountDetailsGfn;
    }

    /*******************************************************************************
    *  Name            : checkTypeOfAccount(List<AccountDetailsGfn.RelatedAccount> relatedAccounts)
    *  Summary         : check is account type Parent or Sub account
    *  CreatedDate     : 25/07/2019
    *  Parameters      : List<AccountDetailsGfn.RelatedAccount> relatedAccounts - list of related customers
    *  Returns         : String
    ******************************************************************************/
    private String checkTypeOfAccount(List<AccountDetailsGfn.RelatedAccount> relatedAccounts){
        String accountType = 'Parent';
        if(relatedAccounts.size() == 0){
            return accountType;
        } else {
            for(AccountDetailsGfn.RelatedAccount relatedAccount : relatedAccounts){
                // searching for Parent Account in a list. If the list contains Parent Account, then current Account is Sub Account
                if(relatedAccount.Parent == true){
                    System.debug('**** IS ACCOUNT PARENT = false');
                    accountType = 'SubAccount';
                    break;
                }
            }
        }
        return accountType;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountContacts(AccountDetailsGfn customerContactsInfo, String colCoID, String customerERP)
    *  Summary         : get GFN account contacts list from GFN Service
    *  CreatedDate     : 25/07/2019
    *  Parameters      : AccountDetailsGfn customerContactsInfo - customer contacts from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountContacts(AccountDetailsGfn customerContactsInfo, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainCustomerContactLandingPage = getLandingPageUrl(colCoID, customerERP, 'maintaincustomercontact', integrationSettings);
        Map<String, String> accountContactsGfn = new Map<String, String>();
        if(customerContactsInfo != null && customerContactsInfo.Data != null){
            accountContactsGfn.put('AccountContacts', JSON.serialize(customerContactsInfo.Data.AccountContacts));
        }
        accountContactsGfn.put('MaintainCustomerContactLandingPage', maintainCustomerContactLandingPage);
        return accountContactsGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountAddresses(AccountDetailsGfn customerAddressesInfo, String colCoID, String customerERP)
    *  Summary         : get GFN account addresses list from GFN Service
    *  CreatedDate     : 25/07/2019
    *  Parameters      : AccountDetailsGfn customerAddressesInfo - customer addresses from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountAddresses(AccountDetailsGfn customerAddressesInfo, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainAddressLandingPage = getLandingPageUrl(colCoID, customerERP, 'maintainaddress', integrationSettings);
        Map<String, String> accountAddressesGfn = new Map<String, String>();
        if(customerAddressesInfo != null && customerAddressesInfo.Data != null){
            accountAddressesGfn.put('AccountAddresses', JSON.serialize(customerAddressesInfo.Data.AccountAddresses));
        }
        accountAddressesGfn.put('MaintainAddressLandingPage', maintainAddressLandingPage);
        return accountAddressesGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountServices(AccountDetailsGfn customerServicesInfo, String colCoID, String customerERP)
    *  Summary         : get GFN account services list from GFN Service
    *  CreatedDate     : 25/07/2019
    *  Parameters      : AccountDetailsGfn customerServicesInfo - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountServices(AccountDetailsGfn customerServicesInfo, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainServicesLandingPage = getLandingPageUrl(colCoID, customerERP, 'maintainservices', integrationSettings);
        Map<String, String> accountServicesGfn = new Map<String, String>();
        if(customerServicesInfo != null && customerServicesInfo.Data != null){
            accountServicesGfn.put('AccountServices', JSON.serialize(customerServicesInfo.Data.AccountServices));
        }
        accountServicesGfn.put('MaintainServicesLandingPage', maintainServicesLandingPage);
        return accountServicesGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountSelfServeUsers(AccountDetailsGfn customerSelfServeUsersInfo, String colCoID, String customerERP)
    *  Summary         : get GFN account self serve users list from GFN Service
    *  CreatedDate     : 14/08/2019
    *  Parameters      : AccountDetailsGfn customerSelfServeUsersInfo - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountSelfServeUsers(AccountDetailsGfn customerSelfServeUsersInfo, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainSelfServeUserLandingPage = getLandingPageUrl(colCoID, customerERP, 'maintainselfserveuseraccount', integrationSettings);
        Map<String, String> accountSelfServeUsersGfn = new Map<String, String>();
        if(customerSelfServeUsersInfo != null && customerSelfServeUsersInfo.Data != null){
            accountSelfServeUsersGfn.put('AccountSelfServeUsers', JSON.serialize(customerSelfServeUsersInfo.Data.AccountSelfServeUsers));
        }
        accountSelfServeUsersGfn.put('MaintainSelfServeUserLandingPage', maintainSelfServeUserLandingPage);
        return accountSelfServeUsersGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountCardsInfo(AccountDetailsGfn customerCardsInfo, String colCoID, String customerERP)
    *  Summary         : get GFN account cards list with details from GFN Service
    *  CreatedDate     : 19/08/2019
    *  Parameters      : AccountDetailsGfn customerCardsInfo - customer cards info from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountCardsInfo(AccountDetailsGfn customerCardsInfo, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintenanceCardsLandingPage = getLandingPageUrl(colCoID, customerERP, 'cardmaintenance', integrationSettings);
        String cardCreationLandingPage = getLandingPageUrl(colCoID, customerERP, 'cardcreation', integrationSettings);
        Map<String, String> accountCardsInfoGfn = new Map<String, String>();
        if(customerCardsInfo != null && customerCardsInfo.Data != null){
            accountCardsInfoGfn.put('AccountCardsInfo', JSON.serialize(customerCardsInfo.Data.SalesforceCards));
        }
        accountCardsInfoGfn.put('MaintenanceCardsLandingPage', maintenanceCardsLandingPage);
        accountCardsInfoGfn.put('CardCreationLandingPage', cardCreationLandingPage);
        return accountCardsInfoGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountUnbilledProducts(AccountDetailsGfn unbilledProducts)
    *  Summary         : get GFN account unbilled products list from GFN Service
    *  CreatedDate     : 29/08/2019
    *  Parameters      : AccountDetailsGfn unbilledProducts - customer unbilled products from GFN
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountUnbilledProducts(AccountDetailsGfn unbilledProducts, GFNI_Settings__c integrationSettings){
        Map<String, String> accountUnbilledProductsGfn = new Map<String, String>();
        if(unbilledProducts != null &&  unbilledProducts.Data != null){
            accountUnbilledProductsGfn.put('UnbilledProducts', JSON.serialize(unbilledProducts.Data.UnbilledProducts));
        }
        return accountUnbilledProductsGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountUnbilledTransactions(AccountDetailsGfn unbilledTransactions, String colCoID, String customerERP)
    *  Summary         : get GFN account unbilled transactions list from GFN Service
    *  CreatedDate     : 29/08/2019
    *  Parameters      : AccountDetailsGfn unbilledTransactions - customer unbilled transactions from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountUnbilledTransactions(AccountDetailsGfn unbilledTransactions, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String customerTransactionsSearchLandingPage = getLandingPageUrl(colCoID, customerERP, 'customersalesitemsearch', integrationSettings);
        Map<String, String> accountUnbilledTransactionsGfn = new Map<String, String>();
        if(unbilledTransactions != null && unbilledTransactions.Data != null){
            accountUnbilledTransactionsGfn.put('UnbilledTransactions', JSON.serialize(unbilledTransactions.Data.UnbilledTransactions));
        }
        accountUnbilledTransactionsGfn.put('CustomerTransactionsSearchLandingPage', customerTransactionsSearchLandingPage);
        return accountUnbilledTransactionsGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountPaymentDetails(AccountDetailsGfn customerPaymentsInfo, String colCoID, String customerERP)
    *  Summary         : get GFN account payments details from GFN Service
    *  CreatedDate     : 26/08/2019
    *  Parameters      : AccountDetailsGfn customerPaymentsInfo - customer payments information from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountPaymentDetails(AccountDetailsGfn customerPaymentsInfo,
            String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainCustomerPaymentDetailsPage = getLandingPageUrl(colCoID, customerERP, 'maintaincustomerpaymentdetail', integrationSettings);
        Map<String, String> accountDetailsGfn = new Map<String, String>();
        if(customerPaymentsInfo != null && customerPaymentsInfo.Data != null){
            accountDetailsGfn.put('DebStatus', customerPaymentsInfo.Data.DebtorStatus);
            accountDetailsGfn.put('OutstandDebt', String.valueOf(customerPaymentsInfo.Data.OutstandingDebt));
            accountDetailsGfn.put('OutstandDebtCurrency', String.valueOf(customerPaymentsInfo.Data.OutstandDebtCurrency));
            accountDetailsGfn.put('CreditLimit', String.valueOf(customerPaymentsInfo.Data.CreditLimit));
            accountDetailsGfn.put('CreditLimitCurrency', String.valueOf(customerPaymentsInfo.Data.CreditLimitCurrency));
            accountDetailsGfn.put('PaymentMethod', customerPaymentsInfo.Data.PaymentMethod);
            accountDetailsGfn.put('PaymentTerms', customerPaymentsInfo.Data.PaymentTerms);
            accountDetailsGfn.put('Guarantee', String.valueOf(customerPaymentsInfo.Data.Guarantee));
            accountDetailsGfn.put('GuarenteeCurrency', String.valueOf(customerPaymentsInfo.Data.GuarenteeCurrency));
            accountDetailsGfn.put('Exposure', String.valueOf(customerPaymentsInfo.Data.Exposure));
        }
        accountDetailsGfn.put('MaintainCustomerPaymentDetailsLandingPage', maintainCustomerPaymentDetailsPage);
        return accountDetailsGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountInformationSubscriptions(AccountDetailsGfn customerInfoSubscriptions, String colCoID, String customerERP)
    *  Summary         : get GFN account information subscription list from GFN Service
    *  CreatedDate     : 05/09/2019
    *  Parameters      : AccountDetailsGfn customerInfoSubscriptions - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountInformationSubscriptions(AccountDetailsGfn customerInfoSubscriptions,
            String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainCustomerInfoSubscriptionLandingPage = getLandingPageUrl(colCoID, customerERP, 'maintaincustomerinfosubscription', integrationSettings);
        Map<String, String> accountInfoSubscriptionsGfn = new Map<String, String>();
        if(customerInfoSubscriptions != null && customerInfoSubscriptions.Data != null){
            accountInfoSubscriptionsGfn.put('InfoSubscriptions', JSON.serialize(customerInfoSubscriptions.Data.InfoSubscriptions));
        }
        accountInfoSubscriptionsGfn.put('MaintainCustomerInfoSubscriptionLandingPage', maintainCustomerInfoSubscriptionLandingPage);
        return accountInfoSubscriptionsGfn;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountHomeSites(AccountDetailsGfn homeSites, String colCoID, String customerERP)
    *  Summary         : get GFN account home site list and address from GFN Service
    *  CreatedDate     : 20/09/2019
    *  Parameters      : AccountDetailsGfn homeSites - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountHomeSites(AccountDetailsGfn homeSites, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String maintainHomeSite = getLandingPageUrl(colCoID, customerERP, 'Maintainhomesite', integrationSettings);
        Map<String, String> accountHomeSites = new Map<String, String>();
        if(homeSites != null && homeSites.Data != null){
            accountHomeSites.put('HomeSites', JSON.serialize(homeSites.Data.HomeSites));
        }
        accountHomeSites.put('Maintainhomesite', maintainHomeSite);
        return accountHomeSites;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountPriceRules(AccountDetailsGfn priceRules, String colCoID, String customerERP)
    *  Summary         : get GFN account price rules list and address from GFN Service
    *  CreatedDate     : 20/09/2019
    *  Parameters      : AccountDetailsGfn priceRules - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountPriceRules(AccountDetailsGfn priceRules, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String customerPriceRulesSearch = getLandingPageUrl(colCoID, customerERP, 'Customerpricerulessearch', integrationSettings);
        Map<String, String> accountPriceRules = new Map<String, String>();
        if(priceRules != null && priceRules.Data != null){
            accountPriceRules.put('PriceRules', JSON.serialize(priceRules.Data.AccountPriceRules));
        }
        accountPriceRules.put('Customerpricerulessearch', customerPriceRulesSearch);
        return accountPriceRules;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountFeeRules(AccountDetailsGfn feeRules, String colCoID, String customerERP)
    *  Summary         : get GFN account fee rules list and address from GFN Service
    *  CreatedDate     : 20/09/2019
    *  Parameters      : AccountDetailsGfn feeRules - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountFeeRules(AccountDetailsGfn feeRules, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String customerFeeRuleSearch = getLandingPageUrl(colCoID, customerERP, 'Customerfeerulesearch', integrationSettings);
        Map<String, String> accountFeeRules = new Map<String, String>();
        if(feeRules != null && feeRules.Data != null){
            accountFeeRules.put('FeeRules', JSON.serialize(feeRules.Data.FeeRules));
        }
        accountFeeRules.put('Customerfeerulesearch', customerFeeRuleSearch);
        return accountFeeRules;
    }

    /*******************************************************************************
    *  Name            : getGfnCreditData(CreditDataGfn creditData, String colCoID, String customerERP)
    *  Summary         : get GFN account fee rules list and address from GFN Service
    *  CreatedDate     : 20/09/2019
    *  Parameters      : CreditDataGfn feeRules - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnCreditData(CreditDataGfn creditData, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String customerCreditDataSearch = getLandingPageUrl(colCoID, customerERP, 'CustomerCreditDataMaintenance', integrationSettings);
        Map<String, String> accountCreditData = new Map<String, String>();
        if(creditData != null && creditData.Data != null){
            accountCreditData.put('CreditData', JSON.serialize(creditData.Data));
        }
        accountCreditData.put('CustomerCreditDataMaintenance', customerCreditDataSearch);
        return accountCreditData;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountBillingDocuments(AccountDetailsGfn billingDocuments, String colCoID, String customerERP)
    *  Summary         : get GFN account billing documents list and address from GFN Service
    *  CreatedDate     : 20/09/2019
    *  Parameters      : AccountDetailsGfn billingDocuments - customer services from GFN,
    *                    String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGFNAccountBillingDocuments(AccountDetailsGfn billingDocuments, String colCoID, String customerERP, GFNI_Settings__c integrationSettings){
        String billingDocumentsLink = getLandingPageUrl(colCoID, customerERP, 'Listcustomersummaryinvoice', integrationSettings);
        String gfnSystemBaseUrl = getGfnSystemBaseUrlForLandingPage(integrationSettings);
        Map<String, String> accountBillingDocuments = new Map<String, String>();
        if(billingDocuments != null && billingDocuments.Data != null){
            accountBillingDocuments.put('BillingDocuments', JSON.serialize(billingDocuments.Data.AccountBillingDocuments));
        }
        accountBillingDocuments.put('Listcustomersummaryinvoice', billingDocumentsLink);
        accountBillingDocuments.put('BaseURL', gfnSystemBaseUrl);
        return accountBillingDocuments;
    }

    /*******************************************************************************
    *  Name            : getGfnAccountBlockedCardsRequests(BlockCardResponseGfn blockCustomerCardResponseGfn)
    *  Summary         : get GFN account blocked cards list from GFN Service
    *  CreatedDate     : 12/09/2019
    *  Parameters      : BlockCardResponseGfn blockedCardsList - customer blocked cards list request from GFN
    *  Returns         : Map<String, String>
    ******************************************************************************/
    public Map<String, String> getGfnAccountBlockedCardsRequests(BlockCardResponseGfn blockCustomerCardResponseGfn, GFNI_Settings__c integrationSettings){
        Map<String, String> accountBlockedCardsRequestsGfn = new Map<String, String>();
        if(blockCustomerCardResponseGfn != null && blockCustomerCardResponseGfn.BlockRequests != null){
            accountBlockedCardsRequestsGfn.put('BlockCardRequests', JSON.serialize(blockCustomerCardResponseGfn.BlockRequests));
        }
        return accountBlockedCardsRequestsGfn;
    }

    /*******************************************************************************
    *  Name            : prepareCardsListJson(String cardsList)
    *  Summary         : prepare JSON String for GFN Service request
    *  CreatedDate     : 10/09/2019
    *  Parameters      : String cardsList - cards list string split by comma
    *  Returns         : String
    ******************************************************************************/
    public String prepareCardsListJson(String cardsList){
        List<String> cards = cardsList.split(', ');
        String cardsListJson = '[';

        for(String card : cards){
            cardsListJson += '{"CardID": ' + card + ',"Reason": "Blocked by API"},';
        }
        cardsListJson = cardsListJson.removeEnd(',') + ']';
        return cardsListJson;
    }

    /*******************************************************************************
    *  Name            : getLandingPage(String colCoID, String customerERP, String gfnPage)
    *  Summary         : generate GFN landing page
    *  CreatedDate     : 14/08/2019
    *  Parameters      : String colCoID - Client Company Identifier, String customerERP - GFN CustomerERP
    *                    String gfnPage - GFN page name
    *  Returns         : String
    ******************************************************************************/
    private String getLandingPageUrl(String colCoID, String customerERP, String gfnPage, GFNI_Settings__c integrationSettings){
        String gfnSystemBaseUrl = getGfnSystemBaseUrlForLandingPage(integrationSettings);
        return gfnSystemBaseUrl + 'CompanyID=' + colCoID + '&CustomerERP=' + customerERP + '&Page=' + gfnPage;
    }
}