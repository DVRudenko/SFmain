public with sharing class ScoringWebServiceImpl implements ScoringWebService {

    private final static String SCORING_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String SCORING_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());
    //Map with black list codes and black list picklist values
    public final static Map<Integer, String> blackListDecisionMapping = new Map<Integer, String> {
            -1 => 'No data',
            0 => 'OK',
            1 => 'RMD approval',
            2 => 'OK',
            3 => 'Denied',
            4 => 'Reseller approval'
    };
    //Map with scoring codes and scoring picklist values
    public final static Map<Integer, String> scoringDecisionMapping = new Map<Integer, String> {
            0 => CFUtils.ScoringDecision.Credit_approved.name(),
            1 => CFUtils.ScoringDecision.Prepay.name(),
            2 => CFUtils.ScoringDecision.Denied.name(),
            3 => CFUtils.ScoringDecision.Prepay.name()
    };
    private static final String DECISION = '"decision"';

    /*******************************************************************************
    *  Name            : verifyCompany(String inn, String sparkId, Id opportunityId)
    *  Summary         : make company verification with Scoring system
    *  CreatedDate     : 22/08/2018
    *  Parameters      : String inn - company inn, String sparkId - id in Spark system, Id opportunityId - opportunity id in Salesforce
    *  Returns         : DecisionScoring
    ******************************************************************************/
    public CompanyVerificationScoring verifyCompany(String inn, String sparkId, Id opportunityId) {
        CompanyVerificationScoring verificationResponse = new CompanyVerificationScoring();
        String url = SCORING_URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SCORING VERIFICATION CONTENT: ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
            Integer statusCode = (Integer) responseMap.get(HttpUtils.PPR_MIDDLEWARE.STATUS_CODE_RESPONSE_PROPERTY);
            switch on (statusCode) {
                when 200 {
                    if (responseBody.contains(DECISION)) {
                        Object responseContent = (Object) (responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
                        verificationResponse = (CompanyVerificationScoring) (JSON.deserialize(JSON.serialize(responseContent), CompanyVerificationScoring.class));
                        System.debug('**** SCORING VERIFICATION: ' + verificationResponse);
                    }
                }
                when 400 {
                    return verificationResponse;
                }
                when else {
                    processBadResponse(
                            statusCode,
                            responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY),
                            'verifyCompany'
                    );
                }
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'verifyCompany');
        }
        return verificationResponse;
    }

    /*******************************************************************************
    *  Name            : getScoringDecision(String inn, String sparkId, Id opportunityId)
    *  Summary         : get scoring decision
    *  CreatedDate     : 22/08/2018
    *  Parameters      : String inn - company inn, String sparkId - id in Spark system, Id opportunityId - opportunity id in Salesforce
    *  Returns         : DecisionScoring
    ******************************************************************************/
    public DecisionScoring getScoringDecision(String inn, String sparkId, Id opportunityId) {
        DecisionScoring scoringDecision = new DecisionScoring();
        String url = SCORING_URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SCORING DECISION CONTENT: ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
            if (responseMap.get(HttpUtils.PPR_MIDDLEWARE.STATUS_CODE_RESPONSE_PROPERTY) == 200) { // SCORING response code
                if (responseBody.contains(DECISION)) {
                    Object responseContent = (Object) (responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
                    scoringDecision = (DecisionScoring) (JSON.deserialize(JSON.serialize(responseContent), DecisionScoring.class));
                    System.debug('**** SCORING DECISION: ' + scoringDecision);
                } else {
                    String notificationMessage = '<br/>E2E RU method getScoringDecision(): inn=' + inn;
                    String stackTraceString = 'status code: ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.STATUS_CODE_RESPONSE_PROPERTY)
                            + ', content: ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY);
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl getScoringDecision(): '
                        + responseMap.get(HttpUtils.PPR_MIDDLEWARE.STATUS_CODE_RESPONSE_PROPERTY)
                        + ' ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.MESSAGE_RESPONSE_PROPERTY)
                        + ' content ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl getScoringDecision(): '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return scoringDecision;
    }
	
    //SF-1359 start
    public DecisionPrescoring getPrescoringDecision(RequestPrescoring requestPrescoring) {
        String url = SCORING_URL + '/scoring/get-decision-prescoring';
        HttpResponse response = sendPostRequest(url, JSON.serialize(requestPrescoring));

        DecisionPrescoring decisionPrescoring = new DecisionPrescoring();
        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** PRESCORING DECISION CONTENT: ' + responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
            Integer statusCode = (Integer) responseMap.get(HttpUtils.PPR_MIDDLEWARE.STATUS_CODE_RESPONSE_PROPERTY);
            switch on (statusCode) {
                when 200 {
                    if (responseBody.contains(DECISION)) {
                        Object responseContent = (Object) (responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY));
                        decisionPrescoring = (DecisionPrescoring) (JSON.deserialize(JSON.serialize(responseContent), DecisionPrescoring.class));
                        System.debug('**** PRESCORING DECISION: ' + decisionPrescoring);
                    }
                }
                when 400 {
                    return decisionPrescoring;
                }
                when else {
                    processBadResponse(
                            statusCode,
                            responseMap.get(HttpUtils.PPR_MIDDLEWARE.CONTENT_RESPONSE_PROPERTY),
                            'getPrescoringDecision'
                    );
                }
            }
        } else {
            processBadResponse(response.getStatusCode(), response.getBody(), 'getPrescoringDecision');
        }
        return decisionPrescoring;
    }
    //SF-1359 end	

    public String prepareBlackListDecisionForSF(Integer verificationDecision) {
        String blackListDecisionForSF = 'Согласование с ОУР';
        if (verificationDecision == 0 || verificationDecision == 2) { // if positive decision
            blackListDecisionForSF = 'ОК';
        } else if (verificationDecision == 3) { // if denied
            blackListDecisionForSF = 'Отказ';
        } else if (verificationDecision == 4) { // if need approval
            blackListDecisionForSF = 'Согласование перекупщика';
        }
        return blackListDecisionForSF;
    }

    public String prepareScoringDecisionForSF(Integer scoringDecision) {
        String decisionForSF = 'Отказ';
        if (scoringDecision == 1 || scoringDecision == 3) { // if credit denied
            decisionForSF = 'Предоплата';
        } else if (scoringDecision == 0) { // if positive decision
            decisionForSF = 'Платный овердрафт';
        }
        return decisionForSF;
    }

    private static HttpResponse sendRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setHeader(HttpUtils.HEADER.AUTHORIZATION, SCORING_TOKEN);
        request.setEndpoint(url);
        request.setMethod(HttpUtils.METHOD.GET);
        request.setTimeout(HttpUtils.MAX_TIMEOUT);
        Http http = new Http();
        return http.send(request);
    }
	
    //SF-1359 start
    private static HttpResponse sendPostRequest(String url, String data) {
        HttpRequest request = new HttpRequest();
        request.setHeader(HttpUtils.HEADER.AUTHORIZATION, SCORING_TOKEN);
        request.setHeader(HttpUtils.HEADER.CONTENT_TYPE, HttpUtils.HEADER.JSON);
        request.setEndpoint(url);
        request.setBody(data);
        request.setMethod(HttpUtils.METHOD.POST);
        request.setTimeout(HttpUtils.MAX_TIMEOUT);
        System.debug('ScoringWebServiceImpl.sendPostRequest - sending POST request to ' + url);
        System.debug('ScoringWebServiceImpl.sendPostRequest - request body = ' + request.getBody());
        return new Http().send(request);
    }
    //SF-1359 end

    private void processBadResponse(Object statusCode, Object body, String method) {
        HttpUtils.throwHttpResponseException(Integer.valueOf(statusCode), String.valueOf(body), ScoringWebServiceImpl.class, method);
    }
}