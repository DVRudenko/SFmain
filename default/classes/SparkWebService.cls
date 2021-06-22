public interface SparkWebService {

    List<CompanySpark> getCompanyListByInn(String inn);

    SoleProprietorSpark getEntrepreneurShortReportByInn(String inn);

    List<FinancialReportSpark> getCompanyAccountingReportBySparkId(String inn, String sparkId);

    ExtendedReportSpark getCompanyExtendedReportBySparkId(String inn, String sparkId);

    ExtendedReportSpark.Leader getCompanyActualLeader(List<ExtendedReportSpark.Leader> leaders);

    SparkRisksReportXML getCompanySparkRisksReportXML(String sparkId);

    List<SparkExecutionProceedings> getCompanyExecutionProceedings(String sparkId);

    List<SparkArbitrationSummary> getCompanyArbitrationSummary(String sparkId);
}