public interface TransactionsReport {
    void setDefaultImportCommandId(CreditSystem creditSystem, String sessionId, String sessionIdSignature);
    String getDefaultImportCommandId();
    void setDefaultImportCommandStatus(CreditSystem creditSystem, String sessionId, String sessionIdSignature, String commandId);
    String getDefaultImportCommandStatus();
    void setBankAccounts();
    void setBankAccountOwners();
    void setBankAccountTransactions();
    void setTransactionsCompany(CreditSystem creditSystem, String ownerExternalId);
    void saveReport(String opportunityId);
}