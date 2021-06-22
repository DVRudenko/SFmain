public without sharing class Naumen_Callouts {
    public class NaumenCalloutsException extends Exception {}
    public static Naumen_Settings__c naumenSettings {get { return naumenSettings == null ? Naumen_Settings__c.getOrgDefaults() : naumenSettings;} set;}
    
//========== NAUMEN FORMAT WRAPPERS TO WORK WITH REST API ==============================================================
    // ----- WRAPPERS FOR 1 CASE ---------  
    public class CallCase { // Naumen case data
        public UUID uuid;
        public String id;
        public String title;

        public CallCaseState state;
        public String scheduledTime; // datetime in a format YYYY-mm-ddTHH:MM:SS (ex.: '2020-07-09T17:35:16') 
        public String timeZone; // datetime in a format XXX (ex.: 'GMT+03:00') 
        public String allowedTimeFrom; // period of time when the call can be made
        public String allowedTimeTo; // period of time when the call can be made
        public Operator operator; // operator's login in Naumen
        public String completionDate; // we need to set this date = null if we want to set a callback for the case 

        public PhoneNumbersList phoneNumbers;
        public CallForm callForm;

        public CallCase () {}
        public CallCase (Naumen_RecordsHelper.RecordWrap recordWrap, Boolean setUUID) { // for leads list or single lead/opportunity
            createCallCase (recordWrap.sObj, setUUID);
            this.phoneNumbers = new PhoneNumbersList(recordWrap);
        }
        private void createCallCase (sObject sObj, Boolean setUUID) {
            if (setUUID == true && sObj.get('Naumen_Autocall_Case_UUID__c') != null) this.uuid = new UUID(String.valueOf(sObj.get('Naumen_Autocall_Case_UUID__c')));
            this.id = String.valueOf(sObj.get('Id'));
            this.title = String.valueOf(sObj.get('Name'));
            this.state = new CallCaseState('new');
        }
        public void setTimeZoneByRegion (sObject sObj) {
            FS_Tree_Province__mdt regionData = GlobalUtils.getRegionData(sObj);
            if (regionData == null) return;
            this.timeZone = regionData.Time_Zone__c;
            this.allowedTimeFrom = regionData.Allowed_Call_Time_From__c;
            this.allowedTimeTo = regionData.Allowed_Call_Time_To__c;
        }
        public void setScheduledTime (DateTime scheduledDT) {
            this.state = new CallCaseState('adjourned');
            if (scheduledDT < system.now().addMinutes(2)) scheduledDT = scheduledDT.addMinutes(2);
            this.scheduledTime = scheduledDT.format('yyyy-MM-dd\'T\'HH:mm:ss');
            this.timeZone = scheduledDT.format('XXX');
        }
        public void setCallFormFields (Map <String, String> callFormAttrMap) {
            this.callForm = new CallForm (callFormAttrMap);
            if (this.callForm.isEmpty())  this.callForm = null;
        }
        public void setState_Finished () {
            this.state = new CallCaseState('finished');
        }
        public void setState_New () {
            this.state = new CallCaseState('new');
        }
    }
    public class CallForm { // Naumen call form data ("Additional attributes" block on the case in Naumen) 
        public List <CallFormAttribute> attribute;
        public CallForm (Map <String, String> attrValues) {
            if (attrValues == null || attrValues.isEmpty()) return;
            this.attribute = new List <CallFormAttribute>();
            for (String attrId : attrValues.keySet()) {
                String attrVal = attrValues.get(attrId);
                if (!String.isBlank(attrVal)) {
                    attribute.add(new CallFormAttribute (attrId, attrVal));
                }
            }
        }
        public Boolean isEmpty () {
            return this.attribute == null || this.attribute.isEmpty();
        }
    }
    public class CallFormAttribute { // an attribute of Naumen call form ("Additional attributes" block on the case in Naumen) 
        public String id;
        public String groupAttr;
        public List <AttributeValue> value;
        public CallFormAttribute (String attrId, String attrVal) {
            this.id = attrId;
            this.groupAttr = 'group001';
            this.value = new List <AttributeValue> {new AttributeValue (attrVal)};
        }
    }
    public class AttributeValue { // an attribute value of Naumen call form ("Additional attributes" block on the case in Naumen) 
        public String value;
        public AttributeValue (String val) {
            this.value = val;
        }
    }
    public class Operator { // Naumen Operator's data 
        public UUID uuid;
        public Operator (String uuidVal) {
            this.UUID = new UUID (uuidVal);
        }
    }
    public class UUID { // UUID in Naumen (identifier of records in Naumen)
        public String value;
        public UUID (String uuidVal) {
            this.value = uuidVal;
        }
    }
    public class CallCaseState { // state of the Naumen case ("Parameters" block on the case in Naumen) 
        public String id;
        public String title;
        public CallCaseState (String stateId) {
            this.id = stateId;
            this.title = stateId == 'new' ? 'Новое' 
                       : stateId == 'adjourned' ? 'Отложенное' 
                       : stateId == 'finished' ? 'Выполнено' 
                       : stateId == 'completed_nr' ? 'Выполнено/не реализовано' 
                       : '';
        }
    }
    public class PhoneNumbersList { // list of phones on Naumen case
        public List <PhoneNumber> phoneNumber;
        public PhoneNumbersList (Set <String> phonesList, Set <String> invalidPhones) {
            this.phoneNumber = new List <PhoneNumber>(); 
            if (!phonesList.isEmpty()) {
                for (String phoneNum : invalidPhones) {
                    if (!phonesList.contains(phoneNum)) phoneNumber.add(new PhoneNumber (phoneNum, 'MOBILE', true));
                }
                for (String phoneNum : phonesList) {
                    phoneNumber.add(new PhoneNumber (phoneNum, 'MOBILE', false));
                }
            }
        }
        public PhoneNumbersList (Naumen_RecordsHelper.RecordWrap recordWrap) {
            this.phoneNumber = new List <PhoneNumber>(); 
            if (recordWrap.sObjType == 'Lead') {
                addSObjPhoneNumbers (recordWrap.sObj);
            } else if (recordWrap.sObjType == 'Opportunity') {
                // we upload all contacts phone numbers (from parent account and from opportunity contact role) if we upload a case to Naumen
                Naumen_RecordsHelper.OpportunityWrap opportunityWrap = (Naumen_RecordsHelper.OpportunityWrap) recordWrap;
                Naumen_RecordsHelper.ContactWrap mainConWrap = opportunityWrap.allContacts.get(opportunityWrap.mainContactId);
                addSObjPhoneNumbers ((Contact)mainConWrap.sObj); // firstly add phone numbers form the main contact on the opportunity
                for (Id conId : opportunityWrap.allContacts.keySet()) {
                    if (conId == opportunityWrap.mainContactId) continue;
                    Naumen_RecordsHelper.ContactWrap conWrapItem = opportunityWrap.allContacts.get(conId); 
                    addSObjPhoneNumbers ((Contact)conWrapItem.sObj); // add phone numbers form related contacts on the opportunity
                }
            }
        }
        public void addSObjPhoneNumbers (sObject sObj) {
            List <String> allPhoneNumbers = Naumen_RecordsHelper.getAllPhoneNumbersInNaumenFormat(sObj);
            if (!allPhoneNumbers.isEmpty()) {
                for (String phoneNumberInNaumenFormat : allPhoneNumbers) {
                    phoneNumber.add(new PhoneNumber (phoneNumberInNaumenFormat, 'MOBILE', false));
                }
            }
        }
    }
    public class PhoneNumber { // phone number data
        public String value;
        public String phoneNumberType;
        public Boolean invalid;
        public PhoneNumber (String phoneNum, String phoneType, Boolean isValid) {
            this.value = PhoneNumbersHandler.getNumberInNaumenFormat (phoneNum);
            this.phoneNumberType = phoneType;
            this.invalid = isValid;
        }
    }
    // ----- WRAPPERS FOR LIST OF CASES ---------
    public class CasesList { // list of Naumen cases
        public List <CallCase> callcase;
        public CasesList (List <sObject> sObjList, Boolean setUUID, DateTime scheduledTime, String caseStatus, Boolean setCallCaseToQueue) {
            this.callcase = new List <CallCase> ();
            if (sObjList != null && !sObjList.isEmpty()) {
                Schema.sObjectType sObjType = sObjList[0].getSObjectType();
                if (sObjType == Schema.Lead.sObjectType) {
                    Naumen_RecordsHelper.LeadListWrap leadListWrap = new Naumen_RecordsHelper.LeadListWrap(sObjList, null);
                    for (Naumen_RecordsHelper.LeadWrap leadWrap : leadListWrap.leadWraps.values()) {
                        addnewCallCase (leadWrap, setUUID, scheduledTime, caseStatus, setCallCaseToQueue);
                    }
                } else if (sObjType == Schema.Opportunity.sObjectType) {
                    Naumen_RecordsHelper.OpportunityListWrap oppListWrap = new Naumen_RecordsHelper.OpportunityListWrap(sObjList, null);
                    for (Naumen_RecordsHelper.OpportunityWrap oppWrap : oppListWrap.oppWraps.values()) {
                        addnewCallCase (oppWrap, setUUID, scheduledTime, caseStatus, setCallCaseToQueue);
                    }
                }
            }
        }
        public CasesList (List <CallCase> callCasesList) {
            this.callcase = callCasesList == null ? new List <CallCase> ()
                          : callCasesList;
        }
        private void addnewCallCase (Naumen_RecordsHelper.RecordWrap recordWrap, Boolean setUUID, DateTime scheduledTime, String caseStatus, Boolean setCallCaseToQueue) {
            // create naumen call case wrapper
            CallCase newCallCase = new CallCase(recordWrap, setUUID);
            // set scheduled time and timezone on naumen call case
            if (scheduledTime != null) {
                newCallCase.setScheduledTime(scheduledTime); // there is scheduled time, we set time and its timezone on the Naumen case
            } else {
                newCallCase.setTimeZoneByRegion (recordWrap.sObj); // there is no scheuled time, only set timezone on the Naumen case
            }
            // set status of naumen call case id specified
            if (caseStatus != null) newCallCase.state = new CallCaseState(caseStatus);
            // set operator
            if (setCallCaseToQueue) newCallCase.operator = new Operator (''); // this case won't be attached to a certain operator
            
            this.callcase.add(newCallCase);
        }
    }

//========== CUSTOM WRAPPERS TO PROCESS REQUEST RESULTS ==============================================================
// ----- RESULTS WRAPPER FOR 1 CASE ---------
public class CallCaseResult {
    public String code; // "SUCCESS", "ERROR"
    public String value; // Case Naumen UUID
}
public class CallCaseResultReport {
    public String result; // "SUCCESS", "ERROR"
    public String uuid; // Case Naumen UUID
    public String sfid; // sobject Id in SF
    public CallCaseResultReport (String result, String uuid, String sfid) {
        this.result = result;
        this.uuid = uuid;
        this.sfid = sfid;
    }
}
// ----- RESULTS WRAPPER FOR LIST OF CASES ---------
    public class CasesListResult { // 
        public List <CallCaseResult> result;
        public CasesListResult () {
            this.result = new List <CallCaseResult> ();
        }
        public Map <String, List <CallCaseResultReport>> processResults (String operationType, String projectUUID, CasesList casesList, Map <Id, sObject> sObjMap) {
            Map <String, List <CallCaseResultReport>> ret = new Map <String, List <CallCaseResultReport>>(); // results map
            List <sObject> sObjectsToUpdate = new List <sObject>(); // save naumen uuid on lead or opportunity if cases were created
            List <Account> accsToUpdate = new List <Account>(); // update parent accounts if needed
            for (Integer i = 0; i < result.size(); i++) {
                CallCaseResult resultItem = result[i]; // response data
                CallCase callCaseItem = casesList.callcase[i]; // request data
                Id sObjId = (Id) callCaseItem.id; // sobject id (Lead or Opportunity)
                CallCaseResultReport resultReportItem = new CallCaseResultReport (resultItem.code, resultItem.value, sObjId);
                if (!ret.containsKey(resultItem.code)) ret.put(resultItem.code, new List <CallCaseResultReport> ());
                ret.get(resultItem.code).add(resultReportItem);
                if (operationType == 'CREATE' && resultItem.code == 'SUCCESS') {
                    sObject sObj = sObjId.getSObjectType().newSObject();
                    sObj.put('Id', sObjId);
                    sObj.put('Naumen_Autocall_Project_UUID__c', projectUUID);
                    sObj.put('Naumen_Autocall_Case_UUID__c', resultItem.value);
                    sObj.put('Naumen_Case_Status__c', 'Created');
                    sObj.put('Naumen_Case_Status_ModifiedTime__c', system.now());
                    sObj.put('Promo_Code1__c', System.now().format('ddMMYYYY') + '_CC'); // update promo code on the record if it was successfully uploaded to Naumen
                    if (sObjId.getSObjectType() == Lead.sObjectType) {
                        sObj.put('Status',  'Prequal');
                    } else if (sObjId.getSObjectType() == Opportunity.sObjectType) {
                        sObj.put('StageName',  'Prequal');
                    }
                    if (naumenSettings.Uploaded_Records_Owner__c != null) { // if there is user id set as owner for uploaded records in naumen settings, then change the owner
                        String newOwnerId = naumenSettings.Uploaded_Records_Owner__c;
                        sObj.put('OwnerId', newOwnerId);
                        if (sObjId.getSObjectType() == Schema.Opportunity.sObjectType) {
                            Account parentAcc = new Account(
                                Id = String.valueOf(sObjMap.get(sObjId).get('AccountId')),
                                OwnerId = newOwnerId
                            );
                            accsToUpdate.add(parentAcc);
                        }
                    }
                    sObjectsToUpdate.add(sObj);
                }
            }
            if (!accsToUpdate.isEmpty()) Database.executeBatch(new MassRecordsUpdateBatch(accsToUpdate), 100);
            if (!sObjectsToUpdate.isEmpty()) Database.executeBatch(new MassRecordsUpdateBatch(sObjectsToUpdate), 100);
            return ret;
        }
    }

//========== CASE REQUESTS ==============================================================
// ----------- REQUEST: CREATE CASES LIST -----------
    /*******************************************************************************
    *  Name            : sendrequest_createCasesList
    *  Summary         : sends request to Naumen REST API to create a list of Naumen Call Cases from Lead/Opportunity&Contacts SF records and saves Naumen Case data on the SF records
    *  Parameters      : String projectUUID - Naumen project UUID, List<sObject> sObjList - list of sObject records to create Naumen Call Cases
    *  Returns         : -
    ******************************************************************************/
    public static void sendrequest_createCasesList (String projectUUID, List<sObject> sObjList) {
        // create cases in Naumen
        String methodName = 'projects/' + projectUUID + '/callcases-batch';
        CasesList casesListData = new CasesList (sObjList, false, null, null, true);
        Map <Id, sObject> sObjMap = new Map <Id, sObject> (sObjList);
        String data = JSON.serializePretty(casesListData, true);
        system.debug('data json : ' + data);
        HttpResponse result = sendRequest_POST (methodName, data, 'POST');
        // send notification to upload results notification recievers 
        if (result != null && result.getStatusCode() == 200 && result.getBody() != null) {
            HttpResponse result2 = sendRequest_POST (methodName, data, 'PUT');
            CasesListResult resultList = (CasesListResult) JSON.deserialize(result.getBody(), CasesListResult.class);
            Map <String, List <CallCaseResultReport>> resultsMap = resultList.processResults('CREATE', projectUUID, casesListData, sObjMap); // pass data which was sent in the request to match request data with the result data
            String sObjTypeStr = !sObjList.isEmpty() ? String.valueOf(sObjList[0].getSObjectType()) : '';
            Naumen_RecordsHelper.sendUploadEmail(createResultString(resultsMap), Label.NaumenSupervisor_notif_casesCreationResult_header + ' (' + sObjTypeStr + ')');
        } else {
            String errMsg = 'Response: ' + result + ' <br/> Body: ' + (result == null ? '' : result.getBody());
            Naumen_RecordsHelper.sendUploadEmail(errMsg, Label.NaumenSupervisor_notif_casesCreationResult_header);
        }
    }
    /*******************************************************************************
    *  Name            : getFieldsToCreateCases
    *  Summary         : this method is used to get all needed fields of the sObject for creating Naumen Cases
    *  Parameters      : Schema.sObjectType sObjType - sObject type for which the list of field APIs will be returned
    *  Returns         : List <String> - list of field APIs for bulding a SOQL query
    ******************************************************************************/
    public static List <String> getFieldsToCreateCases (Schema.sObjectType sObjType) { 
        if (sObjType == Schema.Lead.sObjectType) { 
            return new List <String> {
                'Id', 'Naumen_Autocall_Project_UUID__c', 'Naumen_Autocall_Case_UUID__c', 'Name', 
                'Phone', 'Phone_Status__c', 'MobilePhone', 'MobilePhone_Status__c',  'PPR_Contact_Phone__c', 'PPR_Contact_Phone_Status__c', 
                'Additional_Phones__c', 'Irrelevant_Phones__c', 'Region__c', 'Promo_Code1__c'
            };
        } else if (sObjType == Schema.Opportunity.sObjectType) {
            return new List <String> {
                'Id', 'ContactId', 'Naumen_Autocall_Project_UUID__c', 'Naumen_Autocall_Case_UUID__c', 'Name', 'AccountId', 'Account.Name', 'Account.Region__c'
            };
        }
        return new List <String> ();
    }
// ----------- REQUEST: UPDATE CASES LIST ----------- 
    /*******************************************************************************
    *  Name            : sendrequest_updateCasesList
    *  Summary         : sends request to Naumen REST API to update a list of Naumen Call Cases based on data on Lead/Opportunity&Contacts SF records
    *  Parameters      : List<sObject> sObjList - list of sObject records from which we get data for updating Naumen Call Cases
    *  Returns         : -
    ******************************************************************************/
    public static void sendrequest_updateCasesList (List<sObject> sObjList) {
        // separate sObjects by Naumen project
        Map <String, List<sObject>>  sobjListByNaumenProjectMap = new Map <String, List<sObject>> ();
        for (sObject sObj : sObjList) {
            String projectUUID = sObj.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(sObj.get('Naumen_Autocall_Project_UUID__c'));
            if (!sobjListByNaumenProjectMap.containsKey(projectUUID)) sobjListByNaumenProjectMap.put(projectUUID, new List <sObject>());
            sobjListByNaumenProjectMap.get(projectUUID).add(sObj);
        }
        Map <Id, sObject> sObjMap = new Map <Id, sObject> (sObjList);
        // send a request to Naumen for each project one by one
        for (String projectUUID : sobjListByNaumenProjectMap.keySet()) {
            String methodName = 'projects/' + projectUUID + '/callcases-batch';
            List <sObject> sObjListItem = sobjListByNaumenProjectMap.get(projectUUID);
            CasesList casesListData = new CasesList (sObjListItem, true, null, null, false);
            String data = JSON.serializePretty(casesListData, true);
            HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
            if (result != null && result.getStatusCode() == 200 && result.getBody() != null) {
                CasesListResult resultList = (CasesListResult) JSON.deserialize(result.getBody(), CasesListResult.class);
                resultList.processResults('UPDATE', projectUUID, casesListData, sObjMap); // pass data which was sent in the request to match request data with the result data
                system.debug('projectUUID : ' + projectUUID + ' | resultList : ' + resultList);
            }
        }
    }
    /* not used now (was used in upload records script before)
    * this method updates Call Cases list in Naumen setting call on certain scheduled time
    public static void sendrequest_updateCasesList_setAdjourned (List<sObject> sObjList, DateTime scheduledTime) {
        // separate sObjects by Naumen project
        Map <String, List<sObject>>  sobjListByNaumenProjectMap = new Map <String, List<sObject>> ();
        for (sObject sObj : sObjList) {
            String projectUUID = sObj.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(sObj.get('Naumen_Autocall_Project_UUID__c'));
            if (!sobjListByNaumenProjectMap.containsKey(projectUUID)) sobjListByNaumenProjectMap.put(projectUUID, new List <sObject>());
            sobjListByNaumenProjectMap.get(projectUUID).add(sObj);
        }
        Map <Id, sObject> sObjMap = new Map <Id, sObject> (sObjList);
        // send a request to Naumen for each project one by one
        String resultStr = '';
        for (String projectUUID : sobjListByNaumenProjectMap.keySet()) {
            String methodName = 'projects/' + projectUUID + '/callcases-batch';
            List <sObject> sObjListItem = sobjListByNaumenProjectMap.get(projectUUID);
            CasesList casesListData = new CasesList (sObjListItem, true, scheduledTime, null, true);
            String data = JSON.serializePretty(casesListData, true);
            HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
            resultStr += 'PROJECT : ' + projectUUID + '<br/>';
            if (result != null && result.getStatusCode() == 200 && result.getBody() != null) {
                CasesListResult resultList = (CasesListResult) JSON.deserialize(result.getBody(), CasesListResult.class);
                Map <String, List <CallCaseResultReport>> resultsMap = resultList.processResults('UPDATE', projectUUID, casesListData, sObjMap); // pass data which was sent in the request to match request data with the result data
                system.debug('projectUUID : ' + projectUUID + ' | resultList : ' + resultList);
                resultStr += createResultString(resultsMap) + '<br/>';
            } else {
                // send results on email  (tmp while we dont have supervisor UI)
                resultStr += '[ ERROR : Response: ' + result + ' <br/> Body: ' + (result == null ? '' : result.getBody()) + '] <br/>';
            }
        }
        Naumen_RecordsHelper.sendInfoEmail(resultStr, 'Результат обновления кейсов в Наумен');
    }
    */

    /*******************************************************************************
    *  Name            : sendrequest_updateCasesList_setFinished_NotDone
    *  Summary         : sends request to Naumen REST API to update state of Naumen Call Cases list as Finished - Not Done
    *  Parameters      : List<sObject> sObjList - list of sObject records from which we get data for updating Naumen Call Cases
    *  Returns         : -
    ******************************************************************************/
    public static void sendrequest_updateCasesList_setFinished_NotDone(List<sObject> sObjList) {
        // set completed - not done status for Naumen cases list 
        try {
            // separate sObjects by Naumen project
            Map <String, List<sObject>>  sobjListByNaumenProjectMap = new Map <String, List<sObject>> ();
            for (sObject sObj : sObjList) {
                String projectUUID = sObj.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(sObj.get('Naumen_Autocall_Project_UUID__c'));
                if (!sobjListByNaumenProjectMap.containsKey(projectUUID)) sobjListByNaumenProjectMap.put(projectUUID, new List <sObject>());
                sobjListByNaumenProjectMap.get(projectUUID).add(sObj);
            }
            // send a request to Naumen for each project one by one
            for (String projectUUID : sobjListByNaumenProjectMap.keySet()) {
                List <sObject> sObjListItem = sobjListByNaumenProjectMap.get(projectUUID);
                CasesList casesListData = new CasesList (sObjListItem, true, null, 'completed_nr', false);
                String data = JSON.serializePretty(casesListData, true);
                if (system.isBatch()) {
                    sendrequest_updateCasesList_setFinished_sync(projectUUID, data);
                } else {
                    sendrequest_updateCasesList_setFinished_future(projectUUID, data);
                }
            }
        } catch(Exception e){
            String errMsg = 'Error in Naumen_Callouts.sendrequest_updateCasesList_setFinished_NotDone : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                          + ' | sObjList : ' + sObjList;
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            system.debug(errMsg);
        }
    }
    /*******************************************************************************
    *  Name            : sendrequest_updateCasesList_setFinished_Successful
    *  Summary         : sends request to Naumen REST API to update state of Naumen Call Cases list as Finished
    *  Parameters      : List<sObject> sObjList - list of sObject records from which we get data for updating Naumen Call Cases
    *  Returns         : -
    ******************************************************************************/
    public static void sendrequest_updateCasesList_setFinished_Successful(List<sObject> sObjList) {
        // set completed - done status for Naumen cases list
        try {
            // separate sObjects by Naumen project
            Map <String, List<sObject>>  sobjListByNaumenProjectMap = new Map <String, List<sObject>> ();
            for (sObject sObj : sObjList) {
                String projectUUID = sObj.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(sObj.get('Naumen_Autocall_Project_UUID__c'));
                if (!sobjListByNaumenProjectMap.containsKey(projectUUID)) sobjListByNaumenProjectMap.put(projectUUID, new List <sObject>());
                sobjListByNaumenProjectMap.get(projectUUID).add(sObj);
            }
            // send a request to Naumen for each project one by one
            for (String projectUUID : sobjListByNaumenProjectMap.keySet()) {
                List <sObject> sObjListItem = sobjListByNaumenProjectMap.get(projectUUID);
                Map <Id, CallCase> casesMap = new Map <Id, CallCase> ();
                if (!sObjListItem.isEmpty()) {
                    for (sObject sObj : sObjListItem) {
                        String sfId = String.valueOf(sObj.get('Id'));
                        String caseUUID = sObj.get('Naumen_Autocall_Case_UUID__c') == null ? '' : String.valueOf(sObj.get('Naumen_Autocall_Case_UUID__c'));
                        CallCase callcase = new CallCase();
                        callcase.id = sfId;
                        callcase.uuid = new UUID(caseUUID);
                        callcase.setState_Finished();
                        casesMap.put(sfId, callcase);
                    }
                }
                if (!casesMap.isEmpty()) {
                    CasesList casesListData = new CasesList (casesMap.values());
                    String data = JSON.serializePretty(casesListData, true);
                    //system.debug('projectUUID : ' + projectUUID);
                    //system.debug('data : ' + data);
                    if (system.isBatch()) {
                        sendrequest_updateCasesList_setFinished_sync(projectUUID, data);
                    } else {
                        sendrequest_updateCasesList_setFinished_future(projectUUID, data);
                    }
                }
            }
        } catch(Exception e){
            String errMsg = 'Error in Naumen_Callouts.sendrequest_updateCasesList_setFinished_Successful : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                          + ' | sObjList : ' + sObjList;
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            system.debug(errMsg);
        }
    } 
    public static void sendrequest_updateCasesList_setFinished_sync(String projectUUID, String data) { // send request synchronously
        String methodName = 'projects/' + projectUUID + '/callcases-batch';
        HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
        system.debug('result : ' + result);
    }
    @Future(callout=true)
    public static void sendrequest_updateCasesList_setFinished_future(String projectUUID, String data) { // send request asynchronously
        String methodName = 'projects/' + projectUUID + '/callcases-batch';
        HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
        system.debug('result : ' + result);
    }
// ----------- REQUEST: GET CASE -----------
    /*******************************************************************************
    *  Name            : sendrequest_getCallCase
    *  Summary         : sends request to Naumen REST API to get data of a certain Naumen Case
    *  Parameters      : String caseUUID - identifier of the Naumen Case
    *  Returns         : CallCase - wrapper for the case data returned from Naumen REST API
    ******************************************************************************/
    public static CallCase sendrequest_getCallCase (String caseUUID) {
        HttpResponse res = sendRequest_GET ('callcases/' + caseUUID);
        if (res != null && res.getStatusCode() == 200) {
            CallCase resultCase = (CallCase) JSON.deserialize(res.getBody(), CallCase.class);
            return resultCase;
        } else {
            String errMsg = 'Naumen_Callouts.sendrequest_getCallCase : Couldnt find this case in Naumen: ' + caseUUID + ' | res : ' + res + ' | body: ' + (res == null ? '' : res.getBody());
            throw new NaumenCalloutsException (errMsg);
        }       
    }

// ----------- REQUEST: UPDATE CASE -----------

    /* not used for now
    public static void sendRequest_updateCase (String projectUUID, sObject sObj) {
        String methodName = 'projects/'+projectUUID+'/callcases';
        Naumen_RecordsHelper.RecordWrap recordWrap = Naumen_RecordsHelper.createRecordWrap (sObj, null); 
        CallCase callCase = new CallCase(recordWrap, true);
        String data =  getCallCaseJSON (callCase);
        HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
    }
    */  
    @Future(callout=true)
    public static void sendRequest_setCallFormFields (String recordId, String projectUUID, String caseUUID
                                                    , Map <String, String> callFormAttrMap, Boolean isNaumenCaseFinished) {
        system.debug('>>in>> sendRequest_setCallFormFields : callFormAttrMap : ' + callFormAttrMap);
        try {
            String methodName = 'projects/'+projectUUID+'/callcases';
            CallCase newCallCase = new CallCase();
            newCallCase.id = recordId;
            newCallCase.uuid = new UUID(caseUUID);
            newCallCase.setCallFormFields (callFormAttrMap);
            if(isNaumenCaseFinished) {
                newCallCase.setState_Finished ();
                User currentUser = [SELECT Id, Naumen_UUID__c FROM User WHERE Id = :UserInfo.getUserId()];
                newCallCase.operator = new Operator (currentUser.Naumen_UUID__c);
            }
            String data = getCallCaseJSON (newCallCase);
            HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
            if(isNaumenCaseFinished) {
                sObject sObjToUpdate = Id.valueOf(recordId).getSObjectType().newSObject();
                sObjToUpdate.put('Id', recordId);
                sObjToUpdate.put('Naumen_Case_Status__c', 'Finished');
                sObjToUpdate.put('Naumen_Case_Status_ModifiedTime__c', system.now());
                update sObjToUpdate;
            }
        } catch(Exception e){
            String errMsg = 'Error in Naumen_Callouts.sendRequest_setCallFormFields : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                          + ' | recordId : ' + recordId + ' projectUUID : ' + projectUUID + ' caseUUID : ' + caseUUID 
                          + ' callFormAttrMap : ' + callFormAttrMap;
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            system.debug(errMsg);
        }
    }
    @Future(callout=true)
    public static void sendRequest_setCallbackToOperator (String recordId, String projectUUID, String caseUUID
                                                        , String firstCallPhoneNumber, String currentCallPhoneNumber, String callBackPhone, DateTime scheduledTime, Boolean setCallBackToQueue
                                                        , Map <String, String> callFormAttrMap) {
        system.debug('>>in>> sendRequest_setCallbackToOperator : recordId : ' + recordId + ' projectUUID : ' + projectUUID + ' caseUUID : ' + caseUUID + ' firstCallPhoneNumber : ' + firstCallPhoneNumber + 'callBackPhone : ' + callBackPhone + ' setCallBackToQueue : ' + setCallBackToQueue);
        try {
            String methodName = 'projects/'+projectUUID+'/callcases';
            // create data to update Naumen case
            CallCase newCallCase = new CallCase();
            newCallCase.id = recordId;
            newCallCase.uuid = new UUID(caseUUID);
            // get phones from the current Naumen case and set needed orderod the phones
            Map <String, Boolean> currentPhoneNumbers;
            if (!Test.isRunningTest()) {
                CallCase currentCase = sendrequest_getCallCase (caseUUID);
                currentPhoneNumbers = getPhonesOnNaumenCase (currentCase);
            } else {
                currentPhoneNumbers = new Map <String, Boolean> ();
                currentPhoneNumbers.put('+79990010011', false);
                if (firstCallPhoneNumber != null) currentPhoneNumbers.put(firstCallPhoneNumber, false);
                if (currentCallPhoneNumber != null) currentPhoneNumbers.put(currentCallPhoneNumber, false);
                currentPhoneNumbers.put('+79990010012', false);
            }
            newCallCase.phoneNumbers = addCallBackPhoneToTheList (currentPhoneNumbers, projectUUID, firstCallPhoneNumber, currentCallPhoneNumber, callBackPhone);
            // check if the last phone was processed
            Boolean isTheLastPhoneNumber = newCallCase.phoneNumbers.phoneNumber.isEmpty();
            if (isTheLastPhoneNumber) { // the current phone was the last one and there is no callback phone
                newCallCase.setState_Finished(); // finish Naumen case
            } else { // we need to set a callback
                // set Naumen case status = New to return it to the Naumen Dialer before setting 'adjourned' status (this is a workaround)
                //newCallCase.completionDate = ''; // from old way of setting callbacks
                newCallCase.setState_New();
                String data = getCallCaseJSON (newCallCase);
                HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
                // set Naumen case to the operator on certain time
                newCallCase.setScheduledTime(scheduledTime);
            }
            if (setCallBackToQueue) {
                newCallCase.operator = new Operator ('');
            } else {
                User currentUser = [SELECT Id, Naumen_UUID__c FROM User WHERE Id = :UserInfo.getUserId()];
                newCallCase.operator = new Operator (currentUser.Naumen_UUID__c);
            }
            // set form data for reports in Naumen
            newCallCase.setCallFormFields (callFormAttrMap);
            // send updated Naumen case data to Naumen REST API
            String data = getCallCaseJSON (newCallCase);
            HttpResponse result = sendRequest_POST (methodName, data, 'PUT');
            // if we the Naumen case was finished then update this info in SF
            if(isTheLastPhoneNumber) {
                sObject sObjToUpdate = Id.valueOf(recordId).getSObjectType().newSObject();
                sObjToUpdate.put('Id', recordId);
                sObjToUpdate.put('Naumen_Case_Status__c', 'Finished');
                sObjToUpdate.put('Naumen_Case_Status_ModifiedTime__c', system.now());
                update sObjToUpdate;
            }
        } catch(Exception e){
            String errMsg = 'Error in Naumen_Callouts.sendRequest_setCallbackToOperator : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                          + ' | recordId : ' + recordId + ' projectUUID : ' + projectUUID + ' caseUUID : ' + caseUUID + ' setCallBackToQueue : ' + setCallBackToQueue;
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            system.debug(errMsg);
        }
    }
    /*******************************************************************************
    *  Name            : addCallBackPhoneToTheList
    *  Summary         : sets call back phone as first in the list of phones for Naumen Case
    *  Parameters      : Map <String, Boolean> currentPhoneNumbers - map of phones currently stored on the Naumen Case: string phone number : boolean valid (waiting for calls)/invalid (called already), 
                         String projectUUID - identifier of Naumen Project, 
    *                    String firstCallPhoneNumber - phone number of the first call for which the record card was opened in the Operator Console
                         String currentCallPhoneNumber - phone number which = firstCallPhoneNumber if there was 1 call only and != firstCallPhoneNumber if operator made immidiate call while processing the first call,
                         String callbackPhoneNumber - phone number on which the callback is planned
    *  Returns         : PhoneNumbersList - wrapper of the phones to update phones list on Naumen case
    ******************************************************************************/
    public static PhoneNumbersList addCallBackPhoneToTheList (Map <String, Boolean> currentPhoneNumbers, String projectUUID, String firstCallPhoneNumber, String currentCallPhoneNumber, String callbackPhoneNumber) {
        String methodName = 'projects/'+projectUUID+'/callcases';
        firstCallPhoneNumber = PhoneNumbersHandler.getNumberInNaumenFormat (firstCallPhoneNumber);
        currentCallPhoneNumber = PhoneNumbersHandler.getNumberInNaumenFormat (currentCallPhoneNumber);
        if (callbackPhoneNumber != null) callbackPhoneNumber = PhoneNumbersHandler.getNumberInNaumenFormat (callbackPhoneNumber); // add callbcak phone number as the firs one in phones list on Naumen Case

        Boolean firstCallPhoneFoundOnCase = currentPhoneNumbers.containsKey(firstCallPhoneNumber); // the phone number of the first call was found in Naumen Case
        
        Set <String> processedPhones = new Set <String> (); // list of processed phones on the case on which Naumen won't call anymore
        Set <String> newPhoneNumbers = new Set <String> (); // new list of all processed and unprocessed calls on Naumen Case
        if (callbackPhoneNumber != null) newPhoneNumbers.add(callbackPhoneNumber); // add callback phone number as the first phone number
        if (callbackPhoneNumber != currentCallPhoneNumber) processedPhones.add(currentCallPhoneNumber); // if operator made an immediate call while processing the case, then set it as processed
        Boolean processedPhone = true; // true till the moment for loop reaches the first call phone number
        for (String phoneNum : currentPhoneNumbers.keySet()) {
            if (firstCallPhoneFoundOnCase == true) { // first call phone number is found in the phones list on Naumen Case
                if ((processedPhone || currentPhoneNumbers.get(phoneNum) == true) // phone is processed (1 - it was in the list before the firstCallPhoneNumber; 2 - it was already set as "invalid" on Naumen case)
                && callbackPhoneNumber != phoneNum) { // don't set callback phone number as processed
                    processedPhones.add(phoneNum);
                } else {
                    if (!processedPhones.contains(phoneNum)) { // don't call to the phone number if it was processed already
                        newPhoneNumbers.add(phoneNum);
                    }
                }
                if (phoneNum == firstCallPhoneNumber) { // the for loop reached the first call phone number, all the rest phones are counted as unprocessed
                    processedPhone = false;
                }
            } else { // first call phone number is not found in the phones list in Naumen Case
                if (callbackPhoneNumber != firstCallPhoneNumber) processedPhones.add(firstCallPhoneNumber); // if callback is set not for the firs call phone number then add this phone as invalid (processed)
                if (callbackPhoneNumber != phoneNum) { // we've added callback phone number to the list already, skip it
                    if(currentPhoneNumbers.get(phoneNum) == true) { // phone number is processed because it was already set as "invalid" on Naumen case
                        processedPhones.add(phoneNum);
                    } else {
                        if (!processedPhones.contains(phoneNum)) { // don't call to the same phone number for the second time (for immediate calls) 
                            newPhoneNumbers.add(phoneNum);
                        }
                    }
                }
            }
        }
        return new PhoneNumbersList (newPhoneNumbers, processedPhones);
    }
    /*******************************************************************************
    *  Name            : getCallCaseJSON
    *  Summary         : converts CallCase wrapper back to JSON format to send in request to Naumen REST API 
    *  Parameters      : CallCase callCase - which we convert to JSON
    *  Returns         : String - JSON data
    ******************************************************************************/
    public static String getCallCaseJSON (CallCase callCase) {
        String jsonData = JSON.serializePretty(callCase, true);
        jsonData = jsonData.replaceAll('groupAttr','group');
        return jsonData;
    }
    /*******************************************************************************
    *  Name            : getPhonesOnNaumenCase
    *  Summary         : returns a list of phones setting phones which are 
    *  Parameters      : CallCase callCase - which we convert to JSON
    *  Returns         : String - JSON data
    ******************************************************************************/
    public static Map <String, Boolean> getPhonesOnNaumenCase (CallCase callCase) {
        Map <String, Boolean> phones = new Map <String, Boolean> ();
        if (callCase.phoneNumbers.phoneNumber.isEmpty()) return phones;
        for (PhoneNumber phoneNumberItem : callCase.phoneNumbers.phoneNumber) {
            String phoneNumInNaumenFormat = PhoneNumbersHandler.getNumberInNaumenFormat (phoneNumberItem.value);
            phones.put(phoneNumInNaumenFormat, phoneNumberItem.invalid);
        }
        return phones;
    }
// ----------- REQUEST: DELETE CASE -----------
    /* not used for now
    public static void sendRequest_deleteCase (String projectUUID, String sObjId) {
        String methodName = 'projects/'+projectUUID+'/callcases/'+sObjId;
        HttpResponse result = sendRequest_POST (methodName, null, 'DELETE');
    }
    */
// ----------- REQUEST: GET OPERATORS ON THE PROJECT -----------
    /* not used for now
    public class Employees {
        public List <Employee> employee;
        public Employees () {
            this.employee = new List <Employee>(); 
        }
    }
    public class Employee {
        public UUID uuid;
        public String login;
        public String title;
        public String firstName;
        public String lastName;
        public String internalPhoneNumber;
    }
    public static Operator sendRequest_getOperatorData (String operatorLogin) {
        String methodName = 'employees/'+operatorLogin;
        HttpResponse result = sendRequest_GET (methodName);
        if (result == null) return null;
        Employee employee = (Employee) JSON.deserialize(result.getBody(), Employee.class);
        return new Operator (employee.uuid.value);
    }
    */

//========== SEND REQUESTS TO NAUMEN SERVICE ==============================================================
    /*******************************************************************************
    *  Name            : sendRequest_GET
    *  Summary         : sends GET request to Naumen REST API
    *  Parameters      : String methodNameWithParams - method name in Naumen REST API & get params
    *  Returns         : HttpResponse - response from Naumen for the request
    ******************************************************************************/
    public static HttpResponse sendRequest_GET (String methodNameWithParams) {
        HttpRequest req;
        HttpResponse res;
        try {
            String endPoint = naumenSettings.REST_URL__c + '/fx/api/json/' + methodNameWithParams;
            req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            Blob headerValue = Blob.valueOf(naumenSettings.REST_Username__c +':'+naumenSettings.REST_Passw__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            system.debug('request: ' + req);

            res = new Http().send(req);
            //system.debug('response: ' + res + ' | body: ' + (res == null ? '' : res.getBody()));
            if (res == null || res.getStatusCode() != 200) {
                String errMsg = 'Naumen_Callouts>>  failed request: ' + req + ' | response: ' + res + ' | body: ' + (res == null ? '' : res.getBody());
                Naumen_RecordsHelper.sendErrorEmail(errMsg);
            }
            return res;
        } catch(Exception e){
            String errMsg = 'Error in Naumen_Callouts.sendRequest_GET : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage()
                          + ' | request: ' + req + ' | response: ' + res + ' | body: ' + (res == null ? '' : res.getBody());
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            system.debug(errMsg);
        }
        return res;
    }
    /*******************************************************************************
    *  Name            : sendRequest_POST
    *  Summary         : sends POST request to Naumen REST API
    *  Parameters      : String methodName - method name in Naumen REST API, String data - JSON data to send to Naumen, String httpMethodName - 'PUT'/'POST'
    *  Returns         : HttpResponse - response from Naumen for the request
    ******************************************************************************/
    public static HttpResponse sendRequest_POST (String methodName, String data, String httpMethodName) {
        HttpRequest req;
        HttpResponse res;
        try {
            String endPoint = naumenSettings.REST_URL__c + '/fx/api/json/' + methodName;
            req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod(httpMethodName);
            Blob headerValue = Blob.valueOf(naumenSettings.REST_Username__c +':'+naumenSettings.REST_Passw__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            if (data != null) req.setBody(data);
            system.debug('endPoint: ' + endPoint);
            system.debug('request: ' + req + ' | data : ' + data);
            system.debug('data : ' + data);
            res = new Http().send(req);

            system.debug('response: ' + res + ' | body: ' + (res == null ? '' : res.getBody()));    
            if (res == null || res.getStatusCode() != 200) {
                String errMsg = 'Naumen_Callouts>>  failed request: ' + req + ' | data: ' + data + ' | response: ' + res + ' | body: ' + (res == null ? '' : res.getBody());
                Naumen_RecordsHelper.sendErrorEmail(errMsg); 
            }
            return res;
        } catch(Exception e){
            String errMsg = 'Error in Naumen_Callouts.sendRequest_POST : an exception occured: ' + e.getStackTraceString() + ';  message: ' + e.getMessage() + ' | request: ' + req + ' | data: ' + data + ' | response: ' + res + ' | body: ' + (res == null ? '' : res.getBody());
            Naumen_RecordsHelper.sendErrorEmail(errMsg);
            system.debug(errMsg);
        }
        return res;
    }
    /*******************************************************************************
    *  Name            : createResultString
    *  Summary         : creates text body for email from CallCaseResultReport wrappers
    *  Parameters      : Map <String, List<CallCaseResultReport>> resultsMap - map of: result key ('SUCCESS'/'ERROR') => list of results for the key (for ex. results list for each item of sObject record)
    *  Returns         : String - email text body
    ******************************************************************************/
    public static String createResultString (Map <String, List<CallCaseResultReport>> resultsMap) {
        String resultStr = '';
        Integer successNumber = 0;
        for (String resultCode : resultsMap.keySet()) {
            if (resultCode == 'SUCCESS') successNumber = resultsMap.get(resultCode) == null ? 0 : resultsMap.get(resultCode).size();
            else {
                resultStr += resultCode + '<br/>' + String.valueOf(resultsMap.get(resultCode));
            }
        }
        return 'SUCCESS : ' + String.valueOf(successNumber) + ' records. <br/> ERROR : ' + resultStr;
    }
}