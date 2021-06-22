public interface GFNI_DashboardService {

    AccountDetailsGfn getAggregatedCustomerObject(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getCustomerInformation(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getRelatedCustomers(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String status);

    AccountDetailsGfn getCustomerAddresses(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String addressType);

    AccountDetailsGfn getCustomerContacts(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String contactType);

    AccountDetailsGfn getCustomerServices(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getSelfServeUsers(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getCustomerCardsInfo(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getUnbilledTransactionProducts(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getUnbilledTransactions(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String dateFrom, String dateTo, String cardNumber, String product);

    AccountDetailsGfn getCustomerPaymentDetails(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getInformationSubscriptions(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);
    
    AccountDetailsGfn getHomeSites(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);
    
    AccountDetailsGfn getPriceRules(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);
    
    AccountDetailsGfn getFeeRules(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);
    
    CreditDataGfn getCreditData(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);
    
    AccountDetailsGfn getBillingDocuments(String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    AccountDetailsGfn getDocumentFromGFN(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String documentNumber);

    AccountDetailsGfn searchByCardInGFN(String colCoID, GFNI_Settings__c integrationSettings, String cardNumber);

    String resetPassword(String colCoID, GFNI_Settings__c integrationSettings, String customerERP, String userName);

    BlockCardResponseGfn blockCards(String cardsListJson, String colCoID, GFNI_Settings__c integrationSettings, String customerERP);

    String searchByPanInGFN(String colCoID, GFNI_Settings__c integrationSettings, String cardNumber);


}