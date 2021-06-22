public interface GFNI_DashboardDao {

    Account getAccountById(Id accountId);

    Case getCaseAccountById(Id caseId);

    Task getTaskById(Id taskId);

    ERP__c getERPById(Id erpId);

    ERP__c getErpByLiveChatTranscript(Id chatTranscriptId);

    List<Case> getCaseCurrentInfo(Id caseId);

    List<Case> getRelatedCases(Id accountId);
    
    List<ContentVersion> getVersionByDocName(String docNumber);

    List<ContentDistribution> getDistributionByVersionId(Id versionId);

    ContentDistribution createDistributionForVersion(ContentVersion version);

    ContentVersion createContentVersionPDF(String encodedPDF, String docName);

    List<GFN_Dashboard_UI_settings__mdt> getDashboardUISettings(String recordType);
}