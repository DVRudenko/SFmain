public without sharing class CardsRangeWebServiceImpl implements CardsRangeWebService {

    private static final String REQUEST_PART_BOUNDARY = 'abc123';
    private static final String CHANGESET_BOUNDARY = 'changeset_abc';
    private static final String R_P_B_START = '--' + REQUEST_PART_BOUNDARY;
    private static final String CS_B_START = '--' + CHANGESET_BOUNDARY;
    private static final String R_P_B_END = R_P_B_START + '--';
    private static final String CS_B_END = CS_B_START + '--';

    public enum HttpMethod {
        POST,
        PATCH,
        PUT,
        GET
    }

    public static String uri = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name()) + '/cards-range/CardsRange.svc/';
    public static String token = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    public Map<String, Object> getEntity(String entitySet, String id, List<String> queryOptions) {
        String queryParams = queryOptions == null || queryOptions.isEmpty() ? '?$format=application/json' : '?$format=application/json&' + String.join(queryOptions, '&');
        String endpoint = uri + entitySet + '(\'' + id + '\')' + queryParams;
        HttpResponse response = send(endpoint, null, HttpMethod.GET, 'application/json');
        if (response.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } else {
            throw new GlobalException('CardsRangeWebServiceImpl getEntity: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' responseBody ' + response.getBody() + '; requestURI: ' + endpoint);
        }
    }

    public List<Map<String, Object>> getEntities(String entitySet, List<String> queryOptions) {
        String queryParams = queryOptions == null || queryOptions.isEmpty() ? '?$format=application/json' : '?$format=application/json&' + String.join(queryOptions, '&');
        String endpoint = uri + entitySet + queryParams;
        HttpResponse response = send(endpoint, null, HttpMethod.GET, 'application/json');
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> data = (List<Object>) responseBody.get('value');
            List<Map<String, Object>> entities = new List<Map<String, Object>>();
            for (Object value : data) {
                entities.add((Map<String, Object>) value);
            }
            return entities;
        } else {
            throw new GlobalException('CardsRangeWebServiceImpl getEntities: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' responseBody ' + response.getBody() + '; requestURI: ' + endpoint);
        }
    }

    public void updateEntity(String entitySet, String id, Map<String, Object> data) {
        String endpoint = uri + entitySet + '(\'' + id + '\')';
        String requestBody = JSON.serialize(data, true);
        HttpResponse response = send(endpoint, requestBody, HttpMethod.PATCH, 'application/json');
        if (response.getStatusCode() != 204) {
            throw new GlobalException('CardsRangeWebServiceImpl updateEntity: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' responseBody ' + response.getBody() + '; requestURI: ' + endpoint);
        }
    }

    public void updateEntities(String entitySet, Map<String, Map<String, Object>> idDataMap) {
        Integer contentId = 1;
        List<String> changeSetHeaders = new List<String> {
                'Content-Type: application/http',
                'Content-Transfer-Encoding:binary'
        };
        List<String> changeSets = new List<String>();
        for (String id : idDataMap.keySet()) {
            changeSetHeaders.add('Content-Id: ' + contentId);
            changeSets.add(buildBatchChangeSet(
                    HttpMethod.PATCH,
                    changeSetHeaders,
                    entitySet,
                    id,
                    JSON.serialize(idDataMap.get(id), true)
            ));
            changeSetHeaders.remove(2);
            contentId++;
        }
        HttpResponse response = send(
                uri + '$batch',
                buildBatchRequestPart(changeSets, true),
                HttpMethod.POST,
                'multipart/mixed;boundary=' + REQUEST_PART_BOUNDARY
        );
        if (response.getStatusCode() != 202) {
            throw new GlobalException('CardsRangeWebServiceImpl updateEntities: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' responseBody ' + response.getBody() + '; requestURI: ' + uri + '$batch');
        }
    }

    private HttpResponse send(String endpoint, String body, HttpMethod method, String contentType) {
        System.debug('==================================== REQUEST BEGIN =============================================');
        System.debug('ROW ENDPOINT: ' + method.name() + ' ' + endpoint);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint.replaceAll(' ', '%20').replaceAll('\'', '%27'));
        System.debug('FORMATTED ENDPOINT: ' + method.name() + ' ' + request.getEndpoint());
        request.setHeader('Content-type', contentType);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', token);
        if (body != null) request.setBody(body);
        System.debug('REQUEST BODY: ' + body);
        if (method.equals(HttpMethod.PATCH)) {
            request.setMethod(HttpMethod.POST.name());
            request.setHeader('X-HTTP-Method-Override', HttpMethod.PATCH.name());
        } else {
            request.setMethod(method.name());
        }
        request.setTimeout(120000);
        HttpResponse response = new Http().send(request);
        System.debug('RESPONSE STATUS: ' + response.getStatusCode() + ' - ' + response.getStatus());
        System.debug('RESPONSE BODY: ' + response.getBody());
        System.debug('==================================== REQUEST END =============================================');
        return response;
    }

    @TestVisible
    private String buildBatchChangeSet(HttpMethod method, List<String> headers, String entity, String id, String body) {
        if (headers != null && method != null && String.isNotBlank(entity)) {
            if (method.equals(HttpMethod.GET)) {
                throw new GlobalException('change set builder for GET request not implemented');
            }
            String changeSet = String.join(headers, '\n') + '\n\n' + method.name() + ' ' + entity;
            if (String.isNotEmpty(id)) {
                changeSet += '(\'' + id + '\')';
            }
            changeSet += ' HTTP/1.1\nContent-Type: application/json';
            if (String.isNotEmpty(body)) {
                changeSet += '\n\n' +  body + '\n\n';
            }
            return changeSet;
        } else {
            return '';
        }
    }

    private String buildBatchRequestPart(List<String> changeSets, Boolean last) {
        if (changeSets != null && !changeSets.isEmpty()) {
            if (changeSets.size() == 1) {
                return R_P_B_START + '\n' + changeSets.get(0) + '\n\n' + (last ? R_P_B_END : '');
            } else {
                return R_P_B_START + '\n' + 'Content-Type: multipart/mixed;boundary=' + CHANGESET_BOUNDARY
                        + '\n\n' + CS_B_START + '\n' + String.join(changeSets, CS_B_START + '\n')
                        + CS_B_END + '\n\n' + (last ? R_P_B_END : '');
            }
        } else {
            return '';
        }
    }

}