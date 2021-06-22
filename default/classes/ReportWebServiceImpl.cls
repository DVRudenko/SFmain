public class ReportWebServiceImpl implements ReportWebService {

    private final static String REPORT_SERVICE_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String REPORT_SERVICE_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    public ReportResponseData getReportIdsFromCreditFactory(ReportRequestData requestData) {
        String url = REPORT_SERVICE_URL + '/reporting/prepare-reports';
        String requestBody = JSON.serialize(requestData);

        System.debug('******* CREDIT FACTORY REQUEST URL: ' + url);
        System.debug('******* CREDIT FACTORY REQUEST BODY: ' + requestBody);

        // REQUEST
        HttpResponse response = sendPostRequest(url, requestBody);
        System.debug('******* CREDIT FACTORY RESPONSE: ' + response);

        ReportResponseData reportResponse = new ReportResponseData();
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            System.debug('******* CREDIT FACTORY RESPONSE BODY: ' + responseBody);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (responseMap.containsKey('statusCode') && responseMap.get('statusCode') == 200 && responseMap.containsKey('content')) {
                Object responseContent = (Object) (responseMap.get('content'));
                System.debug('******* CREDIT FACTORY RESPONSE CONTENT: ' + responseContent);
                reportResponse = (ReportResponseData) (JSON.deserialize(JSON.serialize(responseContent), ReportResponseData.class));
            } else {
                throw new E2EFormRuException('ReportWebServiceImpl getReportIdsFromCreditFactory: '
                        + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
            }
        } else {
            throw new E2EFormRuException('ReportWebServiceImpl getReportIdsFromCreditFactory: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody() + '; requestBody: ' + requestBody);
        }
        return reportResponse;
    }

    public Blob getReportsFromReportService(List<String> reportIds) {
        String url = REPORT_SERVICE_URL + '/reporting/get-generated-report' + '?ids=' + String.join(reportIds, ',');
        System.debug('******* REPORT REQUEST URL: ' + url);

        HttpResponse response = sendGetRequest(url);
        System.debug('Header: ' + response.getHeader('Content-Disposition'));
        System.debug('******* REPORT RESPONSE : ' + response);

        if (response.getStatusCode() == 200) {
            System.debug('******* REPORT RESPONSE BODY: ' + response.getBodyAsBlob());
            return response.getBodyAsBlob();
        } else {
            throw new E2EFormRuException('ReportWebServiceImpl getReportsFromReportService: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
    }

//    public static List<String> parseReportIds(ReportResponseData responseData) {
//        System.debug('******* REPORT SERVICE: parseReportIds');
//        List<String> reportIds = new List<String>();
//        for (ReportResponseData.ReportDocument document : responseData.reportDocumentList) {
//            if (document.path != null && document.path.pdf != null && document.path.pdf != '') {
//                reportIds.add(document.path.pdf);
//            }
//        }
//        return reportIds;
//    }

    public static List<String> getOrderReportIds(ReportResponseData responseData, List<String> reportIdsSequence) {
        List<ReportResponseData.ReportDocumentWrapper> documentWrappers = new List<ReportResponseData.ReportDocumentWrapper>();
        for (ReportResponseData.ReportDocument document : responseData.reportDocumentList) {
            if (document.path != null && document.path.pdf != null && document.path.pdf != '' && document.reportTypeId != null) {
                documentWrappers.add(new ReportResponseData.ReportDocumentWrapper(document));
            }
        }
        documentWrappers.sort();

        List<String> resultPathReportIdsSequence = new List<String>();
        for (ReportResponseData.ReportDocumentWrapper documentWrapper : documentWrappers) {
            resultPathReportIdsSequence.add(documentWrapper.document.path.pdf);
        }
        return resultPathReportIdsSequence;
    }

//    public static String getFileNameFromContentDispositionHeader(String headerValue) {
//        if (headerValue != null) {
//            String subString = headerValue.substringAfter('filename=');
//            return subString.substringBefore(']');
//        } else {
//            return 'download.pdf';
//        }
//    }

    private static HttpResponse sendPostRequest(String url, String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', REPORT_SERVICE_TOKEN);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }

    private static HttpResponse sendGetRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', REPORT_SERVICE_TOKEN);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }
}