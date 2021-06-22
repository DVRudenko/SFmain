@RestResource(urlMapping='/locator/*')
global with sharing class LocatorWebService {

    private static final String SECRET_KEY = 'P!v^h9UOC2j&';
    private static final String FOLDER_UPDATES_ERROR = 'Account Locator Update Errors';
    private static final String RETAILER_RECORD_TYPE = 'Retailer';

    @HttpGet
    global static String getReport() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> headers = req.headers;
        String secretKey = headers.get('secretKey');
        String folderName = headers.get('folderName');
        String batchId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String,String> result = new Map<String, String>{
                'status' => 'error'
        };
        String folderReportName = String.isBlank(folderName) ? FOLDER_UPDATES_ERROR : folderName;
        try{
            if(secretKey != null && secretKey == SECRET_KEY && !String.isBlank(batchId)){
                List<Folder> folder = [SELECT Id FROM Folder WHERE Name =:folderReportName ];
                String folderId;
                if ( ! folder.isEmpty() ) {
                    folderId = folder.get(0).Id;
                }
                if(folderId != null){
                    String docName = batchId + '.csv';
                    List<Document> errorsList = [
                            SELECT Id, Body
                            FROM Document
                            WHERE Name = :docName AND FolderId = :folderId];
                    if (!errorsList.isEmpty()) {
                        Document doc = errorsList.get(0);
                        result.put('status', 'success');
                        result.put('url', getFileUrl(doc.Id));
                        result.put('report', doc.Body.toString());
                    } else{
                        CalloutException e = new CalloutException();
                        e.setMessage('Error! errorsList is empty');
                        throw e;
                    }
                }else{
                    CalloutException e = new CalloutException();
                    e.setMessage('Error! folderId is empty');
                    throw e;
                }
            }else{
                CalloutException e = new CalloutException();
                e.setMessage('Error! Base auth error');
                throw e;
            }
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }

        return JSON.serialize(result);
    }

    @HttpPost
    global static String updateStations(String stationsJson, String accountRecordType) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> headers = req.headers;
        String secretKey = headers.get('secretKey');
        Map<String,String> result = new Map<String, String>{
                'status' => 'error'
        };

        String recordTypeRetailer = String.isBlank(accountRecordType) ? RETAILER_RECORD_TYPE : accountRecordType;

        try{
            if(secretKey != null && secretKey == SECRET_KEY && stationsJson != null){
                List<LocatorStation> stations = LocatorStation.parse(stationsJson);
                List<RecordType> recordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name =:recordTypeRetailer];
                if(!recordType.isEmpty()){
                    Id batchId = Database.executeBatch(new LocatorStationsBatch(stations, recordType.get(0).Id), 1);
                    result.put('batchId', batchId);
                    result.put('status', 'success');
                }else{
                    CalloutException e = new CalloutException();
                    e.setMessage('Error! Retailer RecordType is empty');
                    throw e;
                }
            }else{
                CalloutException e = new CalloutException();
                e.setMessage('Error! Invalid auth key');
                throw e;
            }
        } catch (Exception e) {
            result.put('status', 'error');
            result.put('message', e.getMessage());
        }
        return JSON.serialize(result);
    }

    private static String getFileUrl(Id docId){
        Organization org = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
        Site site = [SELECT GuestUserId, Name, Subdomain, MasterLabel, UrlPathPrefix FROM Site WHERE Name = :'E2E' LIMIT 1];
        String url = 'https://' + UserInfo.getUserName().substringAfterLast('.') + '-' + site.Subdomain + '.' + org.InstanceName.toLowerCase() + '.force.com';
        url += '/servlet/servlet.FileDownload?file='+ docId;
        return url;
    }


}