public interface Finder {
    sObject getSourceObject(String sfdcRecordId);
    void setMapping();
    void validateMapping();
    void validate();
    void checkDuplicates();
    List<CreditCompany> searchCompany(CreditSystem creditSystem);
    PageReference redirectToReport(CreditCompany company);
    void setUserSource(String userSource);
	String getUserSource();
}