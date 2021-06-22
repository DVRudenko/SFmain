public with sharing class SparkWebServiceImpl implements SparkWebService {

    private final static String SPARK_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String SPARK_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    /*******************************************************************************
    *  Name            : getCompanyListByInn(String inn)
    *  Summary         : get main company from SPARK by INN
    *  CreatedDate     : 15/08/2018
    *  Parameters      : String inn - company inn
    *  Returns         : List<CompanySpark>
    ******************************************************************************/
    public List<CompanySpark> getCompanyListByInn(String inn) {
        List<CompanySpark> companies = new List<CompanySpark>();
        String url = SPARK_URL + '/spark/company-list?inn=' + inn + '&onlyMain=true';
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK RESPONSE CONTENT: ' + responseMap.get('content'));
            Integer statusCode = (Integer) responseMap.get('statusCode');
            switch on (statusCode) {
                when 200 {
                if (responseBody.contains('"sparkID"')) {
                    List<Object> responseContent = (List<Object>) (responseMap.get('content'));
                    for (Object entry : responseContent) {
                        companies.add((CompanySpark) (JSON.deserialize(JSON.serialize(entry), CompanySpark.class)));
                    }
                    System.debug('**** SPARK COMPANY: ' + companies);
                }
                }
                when 400 {
                    return companies;
                }
                when else {
                    processBadResponse(statusCode, responseMap.get('content'), 'getCompanyListByInn');
                }
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getCompanyListByInn');
        }
        return companies;
    }

    /*******************************************************************************
    *  Name            : getEntrepreneurShortReportByInn(String inn)
    *  Summary         : get sole proprietor report from SPARK by INN
    *  CreatedDate     : 06/08/2018
    *  Parameters      : String inn - company inn
    *  Returns         : SoleProprietorSpark
    ******************************************************************************/
    public SoleProprietorSpark getEntrepreneurShortReportByInn(String inn) {
        SoleProprietorSpark soleProprietorInfo = new SoleProprietorSpark();
        String url = SPARK_URL + '/spark/entrepreneur-short-report?inn=' + inn;
        System.debug('URL: ' + url);

        HttpResponse response = sendRequest(url);
        System.debug('RESPONSE: ' + response);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK ENTREPRENEUR REPORT CONTENT: ' + responseMap.get('content'));
            Integer statusCode = (Integer) responseMap.get('statusCode');
            switch on (statusCode) {
                when 200 {
                if (responseBody.contains('"sparkID"')) {
                    Object responseContent = (Object) (responseMap.get('content'));
                    soleProprietorInfo = (SoleProprietorSpark) (JSON.deserialize(JSON.serialize(responseContent), SoleProprietorSpark.class));
                    System.debug('**** SPARK ENTREPRENEUR REPORT: ' + soleProprietorInfo);
                }
                }
                when 400 {
                    return soleProprietorInfo;
                }
                when else {
                    processBadResponse(statusCode, responseMap.get('content'), 'getEntrepreneurShortReportByInn');
                }
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getEntrepreneurShortReportByInn');
        }
        return soleProprietorInfo;
    }

    /*******************************************************************************
    *  Name            : getCompanyAccountingReport(String inn, String sparkId)
    *  Summary         : get companies' accounting reports from SPARK by SPARK id
    *  CreatedDate     : 15/08/2018
    *  Parameters      : String sparkId - id in SPARK system
    *  Returns         : List<FinancialReportSpark>
    ******************************************************************************/
    public List<FinancialReportSpark> getCompanyAccountingReportBySparkId(String inn, String sparkId) {
        List<FinancialReportSpark> financialReport = new List<FinancialReportSpark>();
        String url = SPARK_URL + '/spark/company-accounting-report?inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK FINANCIAL REPORT CONTENT: ' + responseMap.get('content'));
            Integer statusCode = (Integer) responseMap.get('statusCode');
            switch on (statusCode) {
                when 200 {
                if (responseBody.contains('"sparkID"')) {
                    List<Object> responseContent = (List<Object>) (responseMap.get('content'));
                    for (Object entry : responseContent) {
                        financialReport.add((FinancialReportSpark) (JSON.deserialize(JSON.serialize(entry), FinancialReportSpark.class)));
                    }
                    System.debug('**** SPARK FINANCIAL REPORT: ' + financialReport);
                }
                }
                when 400 {
                    return financialReport;
                }
                when else {
                    processBadResponse(statusCode, responseMap.get('content'), 'getCompanyAccountingReportBySparkId');
                }
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getCompanyAccountingReportBySparkId');
        }
        return financialReport;
    }

    /*******************************************************************************
    *  Name            : getCompanyExtendedReportBySparkId(String inn, String sparkId)
    *  Summary         : get company's extended report from SPARK by SPARK id
    *  CreatedDate     : 15/08/2018
    *  Parameters      : String sparkId - id in SPARK system
    *  Returns         : ExtendedReportSpark
    ******************************************************************************/
    public ExtendedReportSpark getCompanyExtendedReportBySparkId(String inn, String sparkId) {
        ExtendedReportSpark extendedReport = new ExtendedReportSpark();
        String url = SPARK_URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK EXTENDED REPORT CONTENT: ' + responseMap.get('content'));
            Integer statusCode = (Integer) responseMap.get('statusCode');
            switch on (statusCode) {
                when 200 {
                if (responseBody.contains('"sparkID"')) {
                    responseBody.replace('"date":', '"date_x":');
                    Object responseContent = (Object) (responseMap.get('content'));
                    extendedReport = (ExtendedReportSpark) (JSON.deserialize(JSON.serialize(responseContent), ExtendedReportSpark.class));
                    System.debug('**** SPARK EXTENDED REPORT: ' + extendedReport);
                }
                }
                when 400 {
                    return extendedReport;
                }
                when else {
                    processBadResponse(statusCode, responseMap.get('content'), 'getCompanyExtendedReportBySparkId');
                }
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getCompanyExtendedReportBySparkId');
        }
        return extendedReport;
    }

    /*******************************************************************************
    *  Name            : getCompanyActualLeader(ExtendedReportSpark.LeaderList leaders)
    *  Summary         : get company actual leader from SPARK list
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : ExtendedReportSpark.LeaderList leaders
    *  Returns         : ExtendedReportSpark.Leader
    ******************************************************************************/
    public ExtendedReportSpark.Leader getCompanyActualLeader(List<ExtendedReportSpark.Leader> leaders) {
        // Get dates list
        List<Date> allDates = new List<Date>();
        for (ExtendedReportSpark.Leader leader : leaders) {
            allDates.add(Date.valueOf(leader.actualDate));
        }
        allDates.sort();

        // Get actual leader
        Date actualDate = allDates[allDates.size() - 1];
        ExtendedReportSpark.Leader actualLeader = new ExtendedReportSpark.Leader();
        for (ExtendedReportSpark.Leader leader : leaders) {
            if (Date.valueOf(leader.actualDate) == actualDate) {
                actualLeader = leader;
            }
        }
        System.debug('**** SPARK COMPANY LEADER: ' + actualLeader);
        return actualLeader;
    }
	
    //SF-1359 start
    public SparkRisksReportXML getCompanySparkRisksReportXML(String sparkId) {
        SparkRisksReportXML risksReportXML;
        String url = SPARK_URL + '/spark/company-spark-risks-report?sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        String responseBody = response.getBody();
        responseBody = responseBody.replace('"date":', '"date_x":');
        responseBody = responseBody.replace('"number":', '"number_x":');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (response.getStatusCode() == 200) {
            if (responseBody.contains('"sparkID"')) {
                Object responseContent = (Object) (responseMap.get('content'));
                risksReportXML = (SparkRisksReportXML) (JSON.deserialize(JSON.serialize(responseContent), SparkRisksReportXML.class));
                System.debug('**** SPARK Risks Report XML: ' + risksReportXML);
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getCompanySparkRisksReportXML');
        }
        return risksReportXML;
        
    }

    public List<SparkExecutionProceedings> getCompanyExecutionProceedings(String sparkId) {
        List<SparkExecutionProceedings> executionProceedings = new List<SparkExecutionProceedings>();
        String url = SPARK_URL + '/spark/company-execution-proceedings?sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        String responseBody = response.getBody();
        responseBody = responseBody.replace('"number":', '"number_x":');
        responseBody = responseBody.replace('"date":', '"date_x":');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (response.getStatusCode() == 200) {
            if (responseBody.contains('"sparkID"')) {
                List<Object> responseContent = (List<Object>) (responseMap.get('content'));
                for (Object cont: responseContent) {
                    executionProceedings.add((SparkExecutionProceedings) (JSON.deserialize(JSON.serialize(cont), SparkExecutionProceedings.class)));
                }
                System.debug('**** SPARK Execution Proceedings: ' + executionProceedings);
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getCompanyExecutionProceedings');
        }
        return executionProceedings;
    }

    public List<SparkArbitrationSummary> getCompanyArbitrationSummary(String sparkId) {
        List<SparkArbitrationSummary> arbitrationSummaryInfo = new List<SparkArbitrationSummary>();
        String url = SPARK_URL + '/spark/company-arbitration-summary?sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (response.getStatusCode() == 200) {
            if (responseBody.contains('"sparkID"')) {
                List<Object> responseContent = (List<Object>) (responseMap.get('content'));
                for (Object cont: responseContent) {
                    arbitrationSummaryInfo.add((SparkArbitrationSummary) (JSON.deserialize(JSON.serialize(cont), SparkArbitrationSummary.class)));
                }
                System.debug('**** SPARK Arbitration Summary: ' + arbitrationSummaryInfo);
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getCompanyArbitrationSummary');
        }
        return arbitrationSummaryInfo;
    }
    //SF-1359 end	

    @TestVisible
    private static HttpResponse sendRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', SPARK_TOKEN);
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }

    private void processBadResponse(Object statusCode, Object body, String method) {
        HttpUtils.throwHttpResponseException(Integer.valueOf(statusCode), String.valueOf(body), SparkWebServiceImpl.class, method);
    }
}