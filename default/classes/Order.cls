public interface Order {
    CreditCompany doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId);
    void validateOpportunity(Opportunity opportunity, String errorMessage);
    void updateOpportunity(Opportunity opportunity, CreditCompany company, String errorMessage);
    String getSuccessfulOrderStatus();
}