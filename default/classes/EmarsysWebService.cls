public class EmarsysWebService {


    /*******************************************************************************
    *  Name            : genarateCreatingContactsRequest(String jsonBody, String emarsysAccount)
    *  Summary         : generate request for sending contacts to Emarsys
    *  CreatedDate     : 09/08/2017
    *  Parameters      : String jsonBody - body for request, String emarsysAccount - name of Emarsys Account
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateCreatingContactsRequest(String jsonBody, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        String endPoint = 'https://api.emarsys.net/api/v2/contact/?create_if_not_exists=1';
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('PUT');
        request.setTimeout(120000);
        request.setBody(jsonBody);
        return request;
    }
	
    //SF-1415 start
    /*******************************************************************************
    *  Name            : generateContactListRequest(String endpoint)
    *  Summary         : generate request for getting contact list
    *  CreatedDate     : 12/10/2020
    *  Parameters      : String endPoing - endpoinst for request, String emarsysAccount - name of Emarsys Account
    *  Returns         : HttpReqest
    ******************************************************************************/
    public static HttpRequest generateContactListRequest(String endPoint, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setEndpoint(endPoint);
        return request;
    }
    //SF-1415 end	
	
    //SF-1415 start
    /*******************************************************************************
     *  Name            : getContactList(String subscriptionSegmentId, String emarsysAccount)
     *  Summary         : send request for Contact list
     *  CreatedDate     : 12/10/2020
     *  Parameters      : -
     *  Returns         : String
     ******************************************************************************/
    public static String getContactList(String contactListId, String emarsysAccount) {
        String endPointContactList = 'https://api.emarsys.net/api/v2/contactlist/' + contactListId + '/?offset=0&limit=1000000';
        HttpRequest requestContactList = EmarsysWebService.generateContactListRequest(endPointContactList, emarsysAccount);
        Http http = new Http();
        HttpResponse response = http.send(requestContactList);
        return response.getBody();
    }
    //SF-1415 end	

    /*******************************************************************************
    *  Name            : generateContactHistoryRequest(String jsonBody, String emarsysAccount)
    *  Summary         : geterate request for receiving Emarsys contact history
    *  CreatedDate     : 11/08/2017
    *  Parameters      : String jsonBody - body for request, String emarsysAccount - name of Emarsys Account
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateContactHistoryRequest(String jsonBody, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        String endPointCheckContacts = 'https://api.emarsys.net/api/v2/contact/getcontacthistory';
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPointCheckContacts);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setBody(jsonBody);
        return request;
    }

    /*******************************************************************************
    *  Name            : generateEmailDataRequest(String endPoint, String emarsysAccount)
    *  Summary         : geterate request for receiving email data
    *  CreatedDate     : 11/08/2017
    *  Parameters      : String endPoint - endpoint for request, String emarsysAccount - name of Emarsys Account
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateEmailDataRequest(String endPoint, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setTimeout(120000);
        return request;
    }


    /*******************************************************************************
    *  Name            : generateListingContactsRequest(String endpoint)
    *  Summary         : generate request for getting define segment contacts
    *  CreatedDate     : 15/07/2017
    *  Parameters      : String endPoing - endpoinst for request, String emarsysAccount - name of Emarsys Account
    *  Returns         : HttpReqest
    ******************************************************************************/
    public static HttpRequest generateListingContactsRequest(String endPoint, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setEndpoint(endPoint);
        return request;
    }


    /*******************************************************************************
    *  Name            : generateEmailURLRequest(String endPoint, String emarsysAccount)
    *  Summary         : generate request for getting url of launched email campaign
    *  CreatedDate     : 17/08/2017
    *  Parameters      : String endPoing - endpoinst for request,String jsonBody - body for request, String emarsysAccount - name of Emarsys Account
    *  Returns         : HttpReqest
    ******************************************************************************/
    public static HttpRequest generateEmailURLRequest(String endPoint, String jsonBody, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setBody(jsonBody);
        return request;
    }

    /*******************************************************************************
 *  Name            : generateHeaderforRequests(String emarsysAccount)
 *  Summary         : generate header for authorization to Emarsys
 *  CreatedDate     : 09/08/2017
 *  Parameters      : String emarsysAccount - name of Emarsys Account
 *  Returns         : String
 ******************************************************************************/
    private static String generateHeaderforRequests(String emarsysAccount) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 32) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }

        String username;
        String secretKey;
        if (emarsysAccount == 'PPR_EU') {
            username = 'PPR_EU001';
            secretKey = 'p76hSjYJcQjWKysyuiWq';
        } else if (emarsysAccount == 'PPR') {
            username = 'PPR001';
            secretKey = 'cj4PVg0Z0Y2B9oG3hYcy';
        }

        String nonce = randStr;
        String timestamp = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String text = nonce + timestamp + secretKey;
        String sha1 = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(text)));
        Blob b64Blob = Blob.valueOf(sha1);
        String passwordDigest = EncodingUtil.base64Encode(b64Blob);
        String finalString = 'UsernameToken Username="' + username + '",PasswordDigest="' + passwordDigest + '",Nonce="' + nonce + '",Created="' + timestamp + '"';
        return finalString;
    }

    /*******************************************************************************
    *  Name            : getEmailLaunchData()
    *  Summary         : get Email Campaign Id from emarsys
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : Map<String, EmarsysEmailHistoryEntity.Data>
    ******************************************************************************/
    public static Map<String, EmarsysEmailHistoryEntity.Data> getEmailLaunchData(String emarsysContactsIds, String emarsysAccount) {
        Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap = new Map<String, EmarsysEmailHistoryEntity.Data>();
        String contactHistoryResponseBody = sendContactHistoryRequest(emarsysContactsIds, emarsysAccount);
        Set<String> emailIdsSet = new Set<String>();
        EmarsysEmailHistoryEntity.JSON2Apex emailHistory = EmarsysEmailHistoryEntity.parse(contactHistoryResponseBody.replace(' ', 'T'));
        emailsLaunchDataMap = new Map<String, EmarsysEmailHistoryEntity.Data>();
        for (EmarsysEmailHistoryEntity.Data emailHistoryData : emailHistory.data) {
            emailsLaunchDataMap.put(emailHistoryData.contactId, emailHistoryData);
        }
        return emailsLaunchDataMap;
    }

    /*******************************************************************************
    *  Name            : getEmailLaunchData(String emarsysContactsIds, String emarsysAccount, Date startDate, Date endDate)
    *  Summary         : get Email Campaign Id from emarsys
    *  CreatedDate     : 03/11/2017
    *  Parameters      : -
    *  Returns         : Map<String, EmarsysEmailHistoryEntity.Data>
    ******************************************************************************/
    public static Map<String, EmarsysEmailHistoryEntity.Data> getEmailLaunchData(String emarsysContactsIds, String emarsysAccount, Date startDate, Date endDate) {
        Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap = new Map<String, EmarsysEmailHistoryEntity.Data>();
        String contactHistoryResponseBody = sendContactHistoryRequest(emarsysContactsIds, emarsysAccount, startDate, endDate);
        Set<String> emailIdsSet = new Set<String>();
        EmarsysEmailHistoryEntity.JSON2Apex emailHistory = EmarsysEmailHistoryEntity.parse(contactHistoryResponseBody.replace(' ', 'T'));
        emailsLaunchDataMap = new Map<String, EmarsysEmailHistoryEntity.Data>();
        for (EmarsysEmailHistoryEntity.Data emailHistoryData : emailHistory.data) {
            emailsLaunchDataMap.put(emailHistoryData.contactId, emailHistoryData);
        }
        return emailsLaunchDataMap;
    }

    /*******************************************************************************
    *  Name            : sendContactHistoryRequest(String emarsysContactsIds)
    *  Summary         : send request
    *  CreatedDate     : 12/10/2017
    *  Parameters      : HttpRequest request request for getting contact history
    *  Returns         : String
    ******************************************************************************/
    private static String sendContactHistoryRequest(String emarsysContactsIds, String emarsysAccount) {
        String jsonBody = '{"startDate": "' + date.today().addDays(-2) + '", "endDate": "' + date.today().addDays(1) + '", "contacts": [' + emarsysContactsIds + ']}';
        HttpRequest historyRequest = EmarsysWebService.generateContactHistoryRequest(jsonBody, emarsysAccount);
        Http http = new Http();
        HTTPResponse res = http.send(historyRequest);
        System.debug('DEBUG: CONTACTS HISTORY BODY === ' + res.getBody());
        return res.getBody();
    }

    /*******************************************************************************
    *  Name            : sendContactHistoryRequest(String emarsysContactsIds, Date startDate, Date endDate)
    *  Summary         : send request
    *  CreatedDate     : 03/11/2017
    *  Parameters      : HttpRequest request request for getting contact history
    *  Returns         : String
    ******************************************************************************/
    private static String sendContactHistoryRequest(String emarsysContactsIds, String emarsysAccount, Date startDate, Date endDate) {
        String jsonBody = '{"startDate": "' + startDate + '", "endDate": "' + endDate + '", "contacts": [' + emarsysContactsIds + ']}';
        HttpRequest historyRequest = EmarsysWebService.generateContactHistoryRequest(jsonBody, emarsysAccount);
        Http http = new Http();
        HTTPResponse res = http.send(historyRequest);
        System.debug('DEBUG: CONTACTS HISTORY BODY === ' + res.getBody());
        return res.getBody();
    }

    /*******************************************************************************
   *  Name            : getListingContactsInSegment(String subscriptionSegmentId, String emarsysAccount)
   *  Summary         : send request for Listing Contacts in a Segment
   *  CreatedDate     : 12/10/2017
   *  Parameters      : -
   *  Returns         : String
   ******************************************************************************/
    public static String getListingContactsInSegment(String subscriptionSegmentId, String emarsysAccount) {
        String endPointListingContacts = 'https://api.emarsys.net/api/v2/filter/' + subscriptionSegmentId + '/contacts/?offset=0&limit=1000000';
        HttpRequest requestListingContacts = EmarsysWebService.generateListingContactsRequest(endPointListingContacts, emarsysAccount);
        Http http = new Http();
        HttpResponse response = http.send(requestListingContacts);
        System.debug('DEBUG: LISTING CONTACTS BODY === ' + response.getBody());
        return response.getBody();
    }

    /*******************************************************************************
   *  Name            : getRunIdInSegment(String subscriptionSegmentId, String emarsysAccount)
   *  Summary         : send request for Run_Id in a Segment
   *  CreatedDate     : 23/09/2020
   *  Parameters      : -
   *  Returns         : String
   ******************************************************************************/
    public static String getRunIdInSegment(String subscriptionSegmentId, String emarsysAccount) {
        String endPointRunId = 'https://api.emarsys.net/api/v2/filter/' + subscriptionSegmentId + '/runs';
        HttpRequest requestRunId = EmarsysWebService.generateListingRunIdRequest(endPointRunId, emarsysAccount);
        Http http = new Http();
        HttpResponse response = http.send(requestRunId);
        System.debug('DEBUG: RUN ID BODY === ' + response.getBody());
        return response.getBody();
    }

    /*******************************************************************************
       *  Name            : generateListingRunIdRequest(String endpoint)
       *  Summary         : generate request for getting define segment contacts
       *  CreatedDate     : 23/09/2020
       *  Parameters      : String endPoing - endpoinst for request, String emarsysAccount - name of Emarsys Account
       *  Returns         : HttpReqest
       ******************************************************************************/
    public static HttpRequest generateListingRunIdRequest(String endPoint, String emarsysAccount) {
        String header = generateHeaderforRequests(emarsysAccount);
        HttpRequest request = new HttpRequest();
        request.setHeader('X-WSSE', header);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setEndpoint(endPoint);
        return request;
    }
    /*******************************************************************************
    *  Name            : sendResponseTypeRequest(String emarsysCampaignId,  String typeResponse, String emarsysAccount)
    *  Summary         : send request for prepare list of contact with specific response Type based on Campaign id
    *  CreatedDate     : 16/10/2017
    *  Parameters      : Request for prepare list of contact with specific Typeresponse base on CampaignID
    *  Returns         : String
    ******************************************************************************/
    public static Integer sendResponseTypeRequest(String emarsysCampaignId, String typeResponse, String emarsysAccount) {
        String endPoint = 'https://api.emarsys.net/api/v2/email/responses';
        String jsonBody = '{"type": "' + typeResponse + '", "campaign_id": "' + emarsysCampaignId + '" }';
        HttpRequest request = generateEmailURLRequest(endPoint, jsonBody, emarsysAccount);
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('DEBUG: RESPONSE TYPE === ' + res.getBody());

        EmarsysTypeQueryEntity listingEntity = new EmarsysTypeQueryEntity();
        Integer campaignQueryId = null;
        String resBody = res.getBody();
        if (!resBody.contains('"data":""')) {
            listingEntity = (EmarsysTypeQueryEntity) JSON.deserialize(resBody, EmarsysTypeQueryEntity.class);
            campaignQueryId = listingEntity.data.id;
        }
        return campaignQueryId;
    }

    /*******************************************************************************
    *  Name            : getResponseTypeRequest(String queryId, String emarsysAccount)
    *  Summary         : send request for prepare list of contact by queryId
    *  CreatedDate     : 16/10/2017
    *  Parameters      : String queryId
    *                    String emarsysAccount
    *  Returns         : String
    ******************************************************************************/
    public static String getResponseTypeRequest(String queryId, String emarsysAccount) {
        String endPoint = 'https://api.emarsys.net/api/v2/email/' + queryId + '/responses';
        HttpRequest request = generateListingContactsRequest(endPoint, emarsysAccount);
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('DEBUG: HISTORY RESPONSE === ' + res.getBody());
        return res.getBody();
    }

    /*******************************************************************************
    *  Name            : returnEmailUrl(Emarsys_Log__c log)
    *  Summary         : send request to Emarsys by Email Id and return Email Url
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Emarsys_Log__c log - current log
    *  Returns         : String
    ******************************************************************************/
    /*public static String returnEmailUrl(Emarsys_Log__c log, Map<String, Lead> leadsMap,
            Map<String, OpportunityContactRole> opportunityContactRolesMap, String emarsysAccount) {
        String endPoint = 'https://api.emarsys.net/api/v2/email/' + log.Email_Id__c + '/url';
        String jsonBody = '{"key_id": "3","key_value": "';
        if (log.Lead__c != null) {
            if (!leadsMap.isEmpty() && leadsMap.containsKey(log.Lead__c) && leadsMap.get(log.Lead__c).Email != null) {
                jsonBody += leadsMap.get(log.Lead__c).Email;
            }
        } else if (log.Opportunity__c != null) {
            if (!opportunityContactRolesMap.isEmpty() && opportunityContactRolesMap.containsKey(log.Opportunity__c)
                    && opportunityContactRolesMap.get(log.Opportunity__c).Contact.Email != null) {
                jsonBody += opportunityContactRolesMap.get(log.Opportunity__c).Contact.Email;
            }
        }
        jsonBody += '"}';
        System.debug('DEBUG: JSON BODY === ' + jsonBody);

        HttpRequest emailUrlRequest = EmarsysWebService.generateEmailURLRequest(endPoint, jsonBody, emarsysAccount);
        Http http = new Http();
        HTTPResponse emailUrlResponse = http.send(emailUrlRequest);
        System.debug('DEBUG: RESPONSE EMAIL URL BODY === ' + emailUrlResponse.getBody());
        if (emailUrlResponse.getStatus() == 'OK') {
            return emailUrlResponse.getBody();
        } else {
            return '';
        }
    }*/

    /*******************************************************************************
    *  Name            : returnEmailUrl(Emarsys_Log__c log)
    *  Summary         : send request to Emarsys by Email Id and return Email Url
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Emarsys_Log__c log - current log
    *  Returns         : String
    ******************************************************************************/
    public static String returnEmailUrl(Emarsys_Log__c log, Map<String, Lead> leadsMap,
            Map<String, List<OpportunityContactRole>> opportunityContactRolesMap, String emarsysAccount) {
        String endPoint = 'https://api.emarsys.net/api/v2/email/' + log.Email_Id__c + '/url';

        if (log.Lead__c != null) {
            String jsonBody = '{"key_id": "3","key_value": "';
            if (!leadsMap.isEmpty() && leadsMap.containsKey(log.Lead__c) && leadsMap.get(log.Lead__c).Email != null) {
                jsonBody += leadsMap.get(log.Lead__c).Email;
            }
            jsonBody += '"}';
            System.debug('DEBUG: JSON BODY === ' + jsonBody);
            HttpRequest emailUrlRequest = EmarsysWebService.generateEmailURLRequest(endPoint, jsonBody, emarsysAccount);
            Http http = new Http();
            HTTPResponse emailUrlResponse = http.send(emailUrlRequest);
            System.debug('DEBUG: RESPONSE EMAIL URL BODY === ' + emailUrlResponse.getBody());
            if (emailUrlResponse.getStatus() == 'OK') {
                return emailUrlResponse.getBody();
            }
        }
        else if (log.Opportunity__c != null) {
            String responseCode = '';
            for(OpportunityContactRole contactRole : opportunityContactRolesMap.get(log.Opportunity__c)){
                String jsonBody = '{"key_id": "3","key_value": "';
                jsonBody += contactRole.Contact.Email;
                jsonBody += '"}';
                System.debug('DEBUG: JSON BODY === ' + jsonBody);
                HttpRequest emailUrlRequest = EmarsysWebService.generateEmailURLRequest(endPoint, jsonBody, emarsysAccount);
                Http http = new Http();
                HTTPResponse emailUrlResponse = http.send(emailUrlRequest);
                System.debug('DEBUG: RESPONSE EMAIL URL BODY === ' + emailUrlResponse.getBody());
                if (emailUrlResponse.getStatus() == 'OK') {
                    return emailUrlResponse.getBody();
                }
                responseCode = emailUrlResponse.getBody().substringAfter('replyCode\":').substringBefore(',');
            }
            if(emarsysSoftErrorCode.contains(responseCode)){ // soft response code, skip the body log update
                return responseCode;
            }
        }
        return '';
    }

    /*******************************************************************************
    *  Name            : returnEmailData(EmarsysEmailDataEntity.JSON2Apex emailData)
    *  Summary         : send request to Url with Email Body and return data
    *  CreatedDate     : 19/10/2017
    *  Parameters      : EmarsysEmailDataEntity.JSON2Apex emailData
    *  Returns         : String
    ******************************************************************************/
    public static String returnEmailData(EmarsysEmailDataEntity.JSON2Apex emailData) {
        HttpRequest emailDataRequest = new HttpRequest();
        emailDataRequest.setEndpoint(emailData.data.url);
        emailDataRequest.setMethod('GET');
        Http http = new Http();
        HTTPResponse emailDataResponse = http.send(emailDataRequest);
        System.debug('DEBUG: RESPONSE EMAIL DATA BODY === ' + emailDataResponse.getBody());
        return emailDataResponse.getBody();
    }

    /*******************************************************************************
    *  Name            : sendEmailCampaignDataRequest(String emailId)
    *  Summary         : send request
    *  CreatedDate     : 03/11/2017
    *  Parameters      : String emailId - id of email for receiving data
    *  Returns         : String
    ******************************************************************************/
    public static String sendEmailCampaignDataRequest(String emailId) {
        String endPointGetEmailName = 'https://api.emarsys.net/api/v2/email/' + emailId;
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        HttpRequest emailDataRequest = EmarsysWebService.generateEmailDataRequest(endPointGetEmailName, emarsysAccount);
        Http http = new Http();
        HTTPResponse emailDataResponse = http.send(emailDataRequest);
        return emailDataResponse.getBody();
    }

    /*******************************************************************************
      Set of string which describe 'soft' error code which must be skip.
      (We can't receive log from Emarsys on this errorCode)
    ******************************************************************************/
    public static Set<String> emarsysSoftErrorCode = new Set<String>{
            '2008', // No contact found with the external id: 3
            '6002'  // The email has not been sent to the specified contact
    };

    /*******************************************************************************
    *  Name            : getStatusOfSegmentRun(String runId, String emarsysAccount)
    *  Summary         : send request for checking segment run and to retrieve contact list Id
    *  CreatedDate     : 23/09/2020
    *  Parameters      : String runId - job segment run id,
    *                  : String emarsysAccount – emarsys account
    *  Returns         : String
    ******************************************************************************/
    public static String getStatusOfSegmentRun(String runId, String emarsysAccount) {
        String endPointListingContacts = 'https://api.emarsys.net/api/v2/filter/runs/' + runId;
        HttpRequest requestStatusOfRun = EmarsysWebService.generateListingContactsRequest(endPointListingContacts, emarsysAccount);
        Http http = new Http();
        HttpResponse response = http.send(requestStatusOfRun);
        return response.getBody();
    }
}