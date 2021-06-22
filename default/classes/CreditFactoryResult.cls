public class CreditFactoryResult {
    @AuraEnabled public String verdict;
    @AuraEnabled public String statusCode;
    @AuraEnabled public List<Message> messagesList;
    @AuraEnabled public String billingPeriod;
    @AuraEnabled public String paymentTerms;
    @AuraEnabled public String riskCategory;
    @AuraEnabled public Decimal creditLimit;
    @AuraEnabled public Decimal securityLevel;
    @AuraEnabled public Decimal deposit;
    @AuraEnabled public Decimal maxCreditLimit;
    @AuraEnabled public List<String> paymentMethodsSet;
    @AuraEnabled public List<String> invoicesSet;
    @AuraEnabled public List<String> availableButtonsList;
    @AuraEnabled public Boolean isDefault;
    @AuraEnabled public List<CreditFactoryResult> resultsList;
    @AuraEnabled public String contactParentCompanyId;
    @AuraEnabled public String requiredUpdates;
    @AuraEnabled public String depositReason;
    @AuraEnabled public String classRating;

    public class Message {
        @AuraEnabled public String severity;
        @AuraEnabled public String text;
        public Message(String severity, String text) {
            this.severity = severity;
            this.text = text;
        }
    }
}