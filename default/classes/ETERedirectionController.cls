public class ETERedirectionController {
    public String message {get; private set;}
    private Integer countOfChecks;
    private String countryCode;
    private String wbService;
    private String source;
    private Map<String, Object> requestParamsMap;

    public ETERedirectionController() {
        message = 'Waiting...';
        countOfChecks = 0;
        countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        wbService = ApexPages.currentPage().getParameters().get('srvc');
        source = ApexPages.currentPage().getParameters().get('source');
        String docusignEvent = ApexPages.currentPage().getParameters().get('event');
        requestParamsMap = new Map<String, Object>();
        if (source != null) { requestParamsMap.put('source', source); }
        if (countryCode != null) { requestParamsMap.put('countryCode', countryCode); }
        if (docusignEvent != null) { requestParamsMap.put('event', docusignEvent); }
    }


    public PageReference checkStatus() {
        try {
            countOfChecks++;
            if (countOfChecks >= 2) { message = 'Check redirection status...'; }
            ETERedirectionService redirectionService = ETEGlobalUtils.getETERedirectionService(countryCode);
            PageReference linkToRedirect = redirectionService.callMethodToCheckRedirectionStatus(wbService, requestParamsMap);
            if (linkToRedirect != null || countOfChecks >= 30) {
                linkToRedirect.getParameters().put('source', source);
            }
            return linkToRedirect;
        } catch (Exception e) {
            ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
            E2E_Data_Object__c currentDataObject = e2eDatabase.retrieveETEDataObject(ETEGlobalUtils.doDecryptParams(source, countryCode));
            PageReference e2eForm = ETEGlobalUtils.returnUrlPath(currentDataObject.RecordType.Name);
            e2eForm.getParameters().put('source', source);
            return e2eForm;
        }
    }
}