public interface ReportWebService {
    ReportResponseData getReportIdsFromCreditFactory(ReportRequestData requestData);
    Blob getReportsFromReportService(List<String> reportIds);
    List<String> getOrderReportIds(ReportResponseData responseData, List<String> reportIdsSequence);
}