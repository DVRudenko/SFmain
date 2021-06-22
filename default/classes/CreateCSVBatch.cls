global class CreateCSVBatch implements Database.Batchable<sObject>, Database.Stateful {
    // process records params
    global Boolean checkRecordAccess;
    // final actions with CSV file
    global Boolean sendEmail;
    global List <String> emailRecievers;
    global String emailSubject;
    global String emailBody;
    global String fileName;
    // CSV data
    Naumen_RecordsHelper.RecordsTableData recordsTableData;
    global List<String> csvRows;
    @TestVisible global static Integer csvRowsCount;
    // query
    global String query;
    // error
    global String errMsg;
    
    public CreateCSVBatch (Naumen_RecordsHelper.RecordsTableParams recordsTableParams, String endQuery, Boolean checkRecordAccess,
                           Boolean sendEmail, List <String> emailRecievers, String emailSubject, String emailBody, String fileName) {
        // set batch params
        this.checkRecordAccess = checkRecordAccess;
	    this.sendEmail = sendEmail;
        this.emailRecievers = emailRecievers;
		this.emailSubject = emailSubject;
		this.emailBody = emailBody;
        this.fileName = fileName; // ex: 'fileName.csv'
        // csv data
        this.recordsTableData = new Naumen_RecordsHelper.RecordsTableData(recordsTableParams);
        this.csvRows = new List <String>();
        // build query
        List <String> fieldsToQuery = recordsTableParams.getFieldsToQueryRecords();
        if (checkRecordAccess) {
            Set <String> fieldsSet = new Set <String> ();
            fieldsSet.addAll(fieldsToQuery);
            if (recordsTableParams.sObjType == Lead.sObjectType) {
                fieldsSet.addAll(RecordAssignCheckRuCtrl.getFields_queryLeadToGetRecordAccess());
            } else if (recordsTableParams.sObjType == Opportunity.sObjectType) {
                fieldsSet.addAll(RecordAssignCheckRuCtrl.getFields_queryOpportunityToGetRecordAccess());
            }
            fieldsToQuery = new List <String> (fieldsSet);
        }
        this.query = createQueryString (fieldsToQuery, String.valueOf(recordsTableParams.sObjType), endQuery);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){ // add csv rows
        try {
            List <sObject> sObjList = (List<sObject>) scope;
        // get free records 
            List <sObject> sObjList_freeRecords = new List<sObject>();
            if (checkRecordAccess) { // do CCSppedUp check (check if the record is free to work with it)
                RecordAssignCheckParams params = new RecordAssignCheckParams();
                for (sObject sObj : sObjList) {
                    String recordStatus = RecordAssignCheckRuCtrl.getRecordStatus(sObj, params);
                    system.debug('recordStatus : ' + recordStatus);
                    String sObjId = String.valueOf(sObj.get('Id'));
                    if (recordStatus == 'Free') sObjList_freeRecords.add(sObj);
                }
            }
        // add rows to the table for each sobject record
            if (checkRecordAccess) {
                this.recordsTableData.addRowsMap (sObjList_freeRecords); // create Map of rows data by sObj ids
            } else {
                this.recordsTableData.addRowsMap (sObjList); // create Map of rows data by sObj ids
            }
            for (Id sObjId : this.recordsTableData.rowsMap.keySet()) {
                List <String> rowValues = this.recordsTableData.rowsMap.get(sObjId);
                String rowStr = '\'' +  String.join(rowValues, '\',\'') + '\''; // create CSV row string
                this.csvRows.add(rowStr); // add sObj row
            }
            this.recordsTableData.clearRowsMap(); // clear map of rows for current sObjList before processing next batch of sObjList
        } catch(Exception e){
            // save first error only
            if (this.errMsg == null) this.errMsg = 'Error in CreateCSVBatch.execute : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                        + ' | query: ' + query + ' | scope: ' + scope;
        }
    }
    global void finish(Database.BatchableContext BC){ // send csv file
        if (this.errMsg == null) { // success
           try { 
                // send email with csv attachment containing all records processed in the batch
                csvRowsCount = csvRows.size();
                GlobalUtils.sendEmail_CSV (emailRecievers, emailSubject, emailBody, fileName, recordsTableData.headersList, csvRows);
            } catch(Exception e){
                this.errMsg = 'Error in CreateCSVBatch.finish : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                            + ' | query: ' + query;
            }
        }
        if (this.errMsg != null) { // error
            if (!Test.isRunningTest()) Naumen_RecordsHelper.sendUploadEmail(this.errMsg, Label.NaumenSupervisor_uploadFailed); // send notification to Naumen Supervisor Panel notification recievers 
            system.debug(this.errMsg);
        }
    }

// -------- BUILD QUERY -----------------------------
    private String createQueryString (List <String> fieldsToQuery, String sObjTypeToQuery, String endQuery) {
       return 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM ' + sObjTypeToQuery + endQuery;
    }
}