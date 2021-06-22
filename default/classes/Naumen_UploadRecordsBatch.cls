global class Naumen_UploadRecordsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global String sObjTypeStr;
    global List <sObject> sObjListToUploadToNaumen;
    global Integer numberOfNotUploadedRecords;
    global Set <String> sObjIdsNotUploaded;
    global Integer numberOfRecords;
    global Boolean checkRecordAccess;
    global String projectUUID;
    global String query;
    global String errMsg;

    global Naumen_UploadRecordsBatch(String sObjTypeStr, String query, Boolean checkRecordAccess, String projectUUID){
        this.sObjTypeStr = sObjTypeStr;
        this.sObjListToUploadToNaumen = new List <sObject>();
        this.numberOfNotUploadedRecords = 0;
        this.sObjIdsNotUploaded = new Set <String>();
        this.numberOfRecords = 0;
        this.checkRecordAccess = checkRecordAccess;
        this.projectUUID = projectUUID;
        this.query = query;
    }

    global Iterable<sObject> start(Database.BatchableContext context){
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext context, List<sObject> scope){
        try {
            processRecords (scope);
        } catch(Exception e){
            // save first error only
            if (this.errMsg == null) this.errMsg = 'Error in Naumen_UploadRecordsBatch.execute : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                          + ' | query: ' + query + ' | scope: ' + scope;
        }
    }
    global void finish(Database.BatchableContext context){
        if (this.errMsg == null) { // success
            try {
                finishProcesing();
            } catch(Exception e){
                this.errMsg = 'Error in Naumen_UploadRecordsBatch.finish : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                            + ' | query: ' + query;
            }
        }
        if (this.errMsg != null) { // error
            if (!Test.isRunningTest()) Naumen_RecordsHelper.sendUploadEmail(this.errMsg, Label.NaumenSupervisor_uploadFailed); // send notification to Naumen Supervisor Panel notification recievers 
            system.debug(this.errMsg);
        }
    }
    public void processRecords (List <sObject> sObjList) {
        system.debug('>> in >> processRecords ' + sObjList);
        RecordAssignCheckParams params = new RecordAssignCheckParams();
        for (sObject sObj : sObjList) {
            Boolean uploadToNaumen = false;
            if (checkRecordAccess) {
                String recordStatus = RecordAssignCheckRuCtrl.getRecordStatus(sObj, params);
                system.debug('recordStatus : ' + recordStatus);
                if (recordStatus == 'Free') {
                    uploadToNaumen = true;
                }
            } else {
                uploadToNaumen = true;
            }
            system.debug('uploadToNaumen : ' + uploadToNaumen);
            if (uploadToNaumen) {
                sObjListToUploadToNaumen.add(sObj);
            } else {
                if (this.numberOfNotUploadedRecords < 5000) sObjIdsNotUploaded.add(String.valueOf(sObj.get('Id')));
                this.numberOfNotUploadedRecords++;
            }
        }
    }
    public void finishProcesing () {
        String notifictionsRecievers = Naumen_Settings__c.getOrgDefaults().UploadResultsRecievers_Emails__c;
        // send rest request to Naumen to create Naumen cases for predictive dialing
        if (!sObjListToUploadToNaumen.isEmpty()) {
            Naumen_Callouts.sendrequest_createCasesList (projectUUID, sObjListToUploadToNaumen);
        }
        // send email notification about free records number
        String notUploadedIdsString = this.numberOfNotUploadedRecords == 0 ? '' : String.join(new List <String> (sObjIdsNotUploaded), ', ');
        EmailTemplate resultEmailTemplate = [SELECT Id, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Naumen_SupervisorUploadCasesResult'];
        String resultSubject = resultEmailTemplate.Subject;
        resultSubject = resultSubject.replace('{sObjType}', this.sObjTypeStr);
        String resultMsg = resultEmailTemplate.HTMLValue;
        resultMsg = resultMsg.replace('{sObjType}', this.sObjTypeStr);
        resultMsg = resultMsg.replace('{freeNum}', String.valueOf(sObjListToUploadToNaumen.size()));
        resultMsg = resultMsg.replace('{noAccessNum}', String.valueOf(this.numberOfNotUploadedRecords));
        resultMsg = resultMsg.replace('{noAccessIds}', notUploadedIdsString);
        if (!Test.isRunningTest())  Naumen_RecordsHelper.sendUploadEmail(resultMsg, resultSubject); // send notification to Naumen Supervisor Panel notification recievers 
    }
}
