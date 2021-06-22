public interface ETERedirectionService {
    String callMethodToGetRedirectLink(String action, Map<String, Object> args);
    String getLinkToPayUPaymentGatewayRedirect(String action, Map<String, Object> args);
    String getPaymentParamsToIngenicoPaymentGatewayRedirect(String action, Map<String, Object> args);
    void callMethodToPrepareDataToRedirect(String action, Map<String, Object> args);
    void prepareTransaction(String countryCode, String opptyId, Decimal deposit);
    PageReference callMethodToCheckRedirectionStatus(String action, Map<String, Object> args);
    PageReference checkPaymentTransactionStatus(String action, Map<String, Object> args);
    PageReference checkDocusignStatus(Map<String, Object> args);
    String getLinkToDocusignRedirect(String action, Map<String, Object> args);
}