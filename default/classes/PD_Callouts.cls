public class PD_Callouts {

    private static final String PD_EXTERNAL_ID = 'PD_ExternalId__c';

/*******************************************************************************
*  Use this class to do callouts to Personal data service
******************************************************************************/

//========== PD SERVICE SETTINGS ====================================================================  
    public static PD_Setting__c pd_settings = PD_Setting__c.getOrgDefaults();
    //check if at the moment the SF org sends pd data to the PD service
    public static Boolean isPDActive () {
        return pd_settings.IsActive__c == true;
    }
    public static void disablePDService () {
        pd_settings.IsActive__c = false;
        update pd_settings;
    }
//========== SEND CALLOUT TO PD SERVICE ==================================================================== 
    public class SaveDataResponse {
        public String status;
        public ResponseErrorWrap error;
        public ResponseResultWrap result;
    }
    public class ResponseErrorWrap {
        public String code;
        public String message;
    }
    public class ResponseResultWrap {
        public String id;
    }
    
    @Future(callout=true)
    public static void sendRequest_POST (String methodName, String data, String recordId) {
        if (!isPDActive()) return;
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(pd_settings.URL__c + '/' + methodName);
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setBody(data);
            system.debug('request: ' + req);
            system.debug('data: ' + data);
            HttpResponse res = new Http().send(req);
            system.debug('response : ' + res.getBody());
            JSONParser parser = JSON.createParser(res.getBody());
            PD_Callouts.SaveDataResponse saveDataResponse = (PD_Callouts.SaveDataResponse)parser.readValueAs(PD_Callouts.SaveDataResponse.class);
            if (saveDataResponse.status == 'error') {
                disablePDService();
                String errMsg = 'Error in PD_Calouts.sendReq_saveData : response from PD service : ' + res.getBody();
                sendErrorEmail(pd_settings.AdminEmails__c, errMsg);
            } else {
                addPDId(recordId, saveDataResponse.result.id);
            }
        } catch(Exception e){
            String errMsg = 'Error in PD_Calouts.sendReq_saveData : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage();
            sendErrorEmail(pd_settings.AdminEmails__c, errMsg);
            System.debug(errMsg);
        }
    }
//========== SAVE DATA METHOD ==================================================================== 
    public class SaveDataRequest {
        public String token;
        public String id;
        public Map <String, String> data;
    }
    // --- send request ---
    public static void sendReq_saveData(sobject sObj) {
        if (pd_settings.IsActive__c != true) return;
        System.debug('pd callouts > save data');
        if (sObj.getSObjectType() != Schema.Contact.sObjectType && sObj.getSObjectType() != Schema.Lead.sObjectType) return;
        //getCurrentPDId(sObj);
        String bodyJSON = createBody_saveData(sObj);
        String recordId = sObj.Id != null ? sObj.Id : null;
        if (!system.isBatch()) sendRequest_POST ('save-data', bodyJSON, recordId);
    }
    // --- create request body ---
    public static String createBody_saveData(sObject sobj) {
        SaveDataRequest requestWrap = new SaveDataRequest ();
        requestWrap.token = pd_settings.Token__c;
        requestWrap.id = sObj.get(PD_EXTERNAL_ID) == null ? '' : String.valueOf(sObj.get(PD_EXTERNAL_ID));
        requestWrap.data = createData_saveData(sObj);
        return JSON.serialize(requestWrap);
    }
    // --- create request data ---
    public static Map<String, String> createData_saveData(sObject sObj) {
        List<Schema.FieldSetMember>  pdFields = GlobalUtils.getFieldSetMembers (sObj.getsObjectType(), 'PD_Fields');
        List<Schema.FieldSetMember>  phoneFields =  GlobalUtils.getFieldSetMembers(sObj.getSObjectType(), 'All_Phone_Fields');
        pdFields.addAll(phoneFields);
        Map <String, String> pdFieldsMap = new Map <String, String> ();
        for (Schema.FieldSetMember pdField : pdFields) {
            String fieldApi = pdField.getFieldPath();
            String fieldValue = sObj.get(fieldApi) == null ? '' : String.valueOf(sObj.get(fieldApi));
            pdFieldsMap.put(fieldApi, fieldValue);
        }
        return pdFieldsMap;
    }
// ====== SEND EMAIL IF ERROR OCCURED ====================================================================
    public static void sendErrorEmail(String addresses, String body) {
        if (addresses == null) return;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = addresses.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('PD_Calouts error');
        mail.setPlainTextBody(body);
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
//==============

    private static void addPDId(String recordId, String pdId) {
        if (recordId != null && String.isNotBlank(pdId)) {
            Id fullRecordId = Id.valueOf(recordId);
            SObject record = fullRecordId.getSobjectType().newSObject(fullRecordId);
            record.put(PD_EXTERNAL_ID, pdId);

            update record;
        }
    }
	/*	
    private static void getCurrentPDId(sobject sObj) {
        if (sObj.isSet('id') && sObj.getSObjectType() != Schema.Contact.sObjectType) {
            List<Contact> conWithExtId = [SELECT Id, PD_ExternalId__c FROM Contact WHERE Id = :((Id) sObj.get('id'))];
            if(conWithExtId.size() > 0) {
                sObj.put(PD_EXTERNAL_ID, conWithExtId[0].PD_ExternalId__c);
            }
        }		
    }
	*/
}