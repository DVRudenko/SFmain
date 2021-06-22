public with sharing class CFServiceLightning {

    private static DefaultValidator validator = new DefaultValidator();

    /*****************************************************************************
    *  Name            : getSoleProprietorSparkData(String inn)
    *  Summary         : retrieves SPARK data for sole proprietor,
    *                  : returns null if no data found,
    *                  : throws exception if invalid INN
    *  CreatedDate     : 17.03.2021
    *  Parameters      : String inn - company ID
    *  Returns         : String - JSON with data
    ******************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static String getSoleProprietorSparkData(String inn) {
        validator.validateINN(inn);
        SoleProprietorSpark soleProprietorSpark = new SparkWebServiceImpl().getEntrepreneurShortReportByInn(inn);
        if (soleProprietorSpark.sparkID != null) {
            soleProprietorSpark.mainOkved = soleProprietorSpark.getMainOkved();
            return JSON.serialize(soleProprietorSpark);
        }
        return null;
    }

    /*****************************************************************************
    *  Name            : getCompanySparkData(String inn)
    *  Summary         : retrieves SPARK data for legal entity,
    *                  : returns null if no data found,
    *                  : throws exception if invalid INN
    *  CreatedDate     : 17.03.2021
    *  Parameters      : String inn - company ID
    *  Returns         : String - JSON with data
    ******************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static String getCompanySparkData(String inn) {
        validator.validateINN(inn);
        SparkWebService service = new SparkWebServiceImpl();
        List<CompanySpark> companies = service.getCompanyListByInn(inn);
        if (!companies.isEmpty()) {
            ExtendedReportSpark report = service.getCompanyExtendedReportBySparkId(inn, String.valueOf(companies.get(0).sparkID));
            if (report.sparkID != null) {
                report.mainOkved = report.getMainOkved();
                report.actualLeader = service.getCompanyActualLeader(report.leaderList.leader);
                return JSON.serialize(report);
            }
        }
        return null;
    }

    /*****************************************************************************
    *  Name            : getBlackListData(String inn, String sparkID, Id opportunityId)
    *  Summary         : retrieves black list data for sole proprietor or legal entity,
    *                  : returns null if no data found,
    *                  : throws exception if invalid INN
    *  CreatedDate     : 17.03.2021
    *  Parameters      : String inn - company ID, String sparkID, Id opportunityId
    *  Returns         : String - JSON with data
    ******************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static String getBlackListData(String inn, String sparkID, Id opportunityId) {
        validator.validateINN(inn);
        if (String.isNotBlank(sparkID)) {
            CompanyVerificationScoring companyVerificationScoring = new ScoringWebServiceImpl().verifyCompany(inn, sparkID, opportunityId);
            if (companyVerificationScoring.decision != null) {
                BlackListDecision decision = new BlackListDecision();
                decision.buildDecision(companyVerificationScoring);
                return JSON.serialize(decision);
            }
        }
        return null;
    }

    /*****************************************************************************
    *  Name            : getPreScoringData(String fullSparkData, Long turnover)
    *  Summary         : retrieves pre-scoring data for legal entity,
    *                  : returns null if no data found,
    *                  : throws exception if invalid turnover
    *  CreatedDate     : 17.03.2021
    *  Parameters      : String fullSparkData - JSON of SparkDataForPrescoring object, Long turnover
    *  Returns         : String - JSON with data
    ******************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static String getPreScoringData(String fullSparkData, Long turnover) {
        validator.validateTurnover(turnover);
        if (fullSparkData != null) {
            CFServiceRuImpl cFService = new CFServiceRuImpl();
            ScoringWebService scoringService = new ScoringWebServiceImpl();

            SparkDataForPrescoring data = (SparkDataForPrescoring) JSON.deserialize(fullSparkData, SparkDataForPrescoring.class);
            RequestPrescoring requestBody = cFService.buildPrescoringRequestBody(data, turnover);
            DecisionPrescoring responseBody = scoringService.getPrescoringDecision(requestBody);
            if (responseBody.decision != null && responseBody.blocked != null) {
                responseBody.decisionString = GlobalUtils.getPicklistLabel(
                        CFUtils.parsePreScoringDecision(responseBody),
                        Credit_Factory_Report__c.RU_scoring_decision__c
                );
                return JSON.serialize(responseBody);
            }
        }
        return null;
    }

    @AuraEnabled(Cacheable = true)
    public static String getSparkArbitrationSummaryList(String sparkID) {
        return sparkID == null ? null : JSON.serialize(new SparkWebServiceImpl().getCompanyArbitrationSummary(sparkID));
    }

    @AuraEnabled(Cacheable = true)
    public static String getSparkExecutionProceedings(String sparkID) {
        return sparkID == null ? null : JSON.serialize(new SparkWebServiceImpl().getCompanyExecutionProceedings(sparkID));
    }

    @AuraEnabled(Cacheable = true)
    public static String getSparkFinancialReports(String sparkID, String inn) {
        return sparkID == null || inn == null ? null : JSON.serialize(new SparkWebServiceImpl().getCompanyAccountingReportBySparkId(inn, sparkID));
    }

    @AuraEnabled(Cacheable = true)
    public static String getSparkRiskReport(String sparkID) {
        return sparkID == null ? null : JSON.serialize(new SparkWebServiceImpl().getCompanySparkRisksReportXML(sparkID));
    }

    @AuraEnabled(Cacheable = true)
    public static Map<String, String> getPickListCreditFactoryReport() {
        return GlobalUtils.getPickListValuesAndLabelsFromObjectField(Credit_Factory_Report__c.RU_scoring_decision__c);
    }
}