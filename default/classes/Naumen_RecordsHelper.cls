public without sharing class Naumen_RecordsHelper {
    public class NaumenRecordException extends Exception {}
    public static Naumen_Settings__c naumenSettings {get { return naumenSettings == null ? Naumen_Settings__c.getOrgDefaults() : naumenSettings;} set;}

// ------------------ WRAPS: CUSTOMER RECORD DATA (LEAD, OPPORTUNITY WITH CONTACTS) ----------------------------
// --- GENERAL RECORD DATA ---
    public abstract class RecordWrap {
        public String sObjType {get;set;}
        public String recordId {get{return this.recordId == null ? '' : this.recordId;} set;}
        public String callCustomerId {get{return this.callCustomerId == null ? '' : this.callCustomerId;} set;}
        public String name {get{return this.name == null ? '' : this.name;} set;}
        public String companyName {get{return this.companyName == null ? '' :this.companyName;} set;}
        public String phoneNumber {get{return this.phoneNumber == null ? '' : this.phoneNumber;} set;}
        public String extensionNumber {get{return this.extensionNumber == null ? '' : this.extensionNumber;} set;}
        public String phoneFieldAPI {get; set;}
        public sObject sObj {get; set;}
        private List <String> allPhones;

        public RecordWrap (sObject sObj, String phoneNumber) {
            this.sObjType = String.valueOf(sObj.getSObjectType());
            this.recordId = String.valueOf(sObj.get('Id'));
            this.phoneNumber = phoneNumber;
            this.sObj = sObj;
        }
        public void setPhoneFieldAPI() {
            String phoneNumberFormatted = PhoneNumbersHandler.getNumberInNaumenFormat (this.phoneNumber);
            if (phoneNumberFormatted == null) {
                String errMsg = Label.exception_WrongPhoneFormat;
                errMsg = errMsg.replace('{0}', this.phoneNumber);
                throw new NaumenRecordException (errMsg);
            }
            PhoneNumbersHandler.sObjWrapper sObjWrap = new PhoneNumbersHandler.sObjWrapper(sObj, null);
            List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObj.getSObjectType(), 'All_Phone_Fields');
            Map <String, String> unifiedPhonesMap = sObjWrap.getUnifiedNumbersMap(phoneFieldsAPIs, false);
            this.phoneFieldAPI = unifiedPhonesMap.get(phoneNumberFormatted);
        }
        public void setExtensionNumberVal () {
            if (this.sObj == null || this.phoneFieldAPI == null || this.sObj.get(this.phoneFieldAPI) == null) return;
            String phoneNumberVal;            
            if (phoneFieldAPI == 'Additional_Phones__c') {
                String additionalPhoneItem = PhoneNumbersHandler.getAdditionalPhonelItemByPhone (sObj, this.phoneNumber, false);
                phoneNumberVal = PhoneNumbersHandler.additionaPhonelItem_getPhone(additionalPhoneItem);
            } else {
                phoneNumberVal = String.valueOf(sObj.get(phoneFieldAPI));
            }
            this.extensionNumber = PhoneNumbersHandler.getPhoneExtension(phoneNumberVal);
        }
    }
// --- LEAD DATA ---
    public class LeadWrap extends RecordWrap {
        public String recordNaumenUUID {get{return this.recordNaumenUUID == null ? '' : this.recordNaumenUUID;} set;}
        public LeadWrap (sObject sObj, String phoneNumber) {
            super (sObj, phoneNumber);
            Lead lead = (Lead)sObj;
            this.recordNaumenUUID = lead.Naumen_Autocall_Case_UUID__c;
            this.name = lead.FirstName == null ? lead.LastName : lead.FirstName + ' ' + lead.LastName;
            this.companyName = lead.Company;
            this.callCustomerId = this.recordId;
            if (phoneNumber != null) {
                setPhoneFieldAPI();  
                setExtensionNumberVal();
            }
        }
        public  List <String> getAllPhones () {
            if(this.allPhones == null) {
                this.allPhones =  new List <String> ();
                this.allPhones.addAll(Naumen_RecordsHelper.getAllPhoneNumbersInNaumenFormat(sObj));
            }
            return this.allPhones;
        }
    }
    public class LeadListWrap {
        public Map <Id, LeadWrap> leadWraps; // lead id => lead wrap
        public LeadListWrap (List <Lead> leads, String phoneNumber) {
            this.leadWraps = new  Map <Id, LeadWrap> ();
            if (leads == null || leads.isEmpty()) return;
            // create Lead Wraps
            for (Lead lead : leads) {
                LeadWrap leadWrap = new LeadWrap (lead, phoneNumber);
                leadWraps.put(lead.Id, leadWrap);
            }
        }
    }
// --- OPPORTUNITY DATA ---
    public class OpportunityWrap extends RecordWrap {
        public String recordNaumenUUID {get{return this.recordNaumenUUID == null ? '' : this.recordNaumenUUID;} set;}
        public String accountId {get{return this.accountId == null ? '' : this.accountId;} set;}
        public Id mainContactId {get; set;}
        public Map <Id, ContactWrap> allContacts {get;set;}

        public OpportunityWrap (sObject sObj, String phoneNumber) {
            super (sObj, phoneNumber);
            getContactsMap();
            Opportunity opp = (Opportunity)sObj;
            createOpportunityWrap(opp);
        }
        public OpportunityWrap (sObject sObj, String phoneNumber, Map <Id, Contact> contactsMap) {
            super (sObj, phoneNumber);
            setContactsMap(contactsMap);
            Opportunity opp = (Opportunity)sObj;
            createOpportunityWrap(opp);
        }
        private void createOpportunityWrap (Opportunity opp) {
            this.recordNaumenUUID = opp.Naumen_Autocall_Case_UUID__c;
            this.name = opp.Name;
            this.accountId = opp.AccountId;
            try {
                this.companyName = opp.Account.Name;
            } catch (Exception ex) {system.debug('Error while getting company name: ' + ex.getMessage() + ' ' + ex.getStackTraceString());}
            setMainContact();
            setCallContact();
        }
        public void getContactsMap () {
            this.allContacts = new Map <Id, ContactWrap> ();
            Map <Id, Contact> contactsMap = queryContactsForSingleOpportunity((Opportunity)sObj); // query contacts by opportunity id
            if (contactsMap == null || contactsMap.isEmpty()) return; 
            for (Contact con : contactsMap.values()) {
                this.allContacts.put(con.Id, new ContactWrap(con, this.phoneNumber));
            }
        }
        public void setContactsMap(Map <Id, Contact> contactsMap) {
            this.allContacts = new Map <Id, ContactWrap> ();
            if (contactsMap == null || contactsMap.isEmpty()) return;
            for (Id conId : contactsMap.keySet()) {
                Contact con = contactsMap.get(conId);
                this.allContacts.put(con.Id, new ContactWrap(con, this.phoneNumber));
            }
        
        }
        public void setMainContact() {
            if (this.allContacts == null || this.allContacts.isEmpty()) return;
            Id primaryContactId = (Id) sObj.get('ContactId');
            // if there is a primary contact then set it as the main contact
            if (primaryContactId != null && this.allContacts.containsKey(primaryContactId)) {
                this.mainContactId = primaryContactId;
            }
            // if there wasnt a primary contact then set last modified contact as the main contact
            if (this.mainContactId == null) {
                Contact lastModifiedCon = (Contact) this.allContacts.values()[0].sObj;
                this.mainContactId = (Id)lastModifiedCon.get('Id');
            }
        }
        public void setCallContact() {
            if (this.allContacts == null || this.allContacts.isEmpty()) return;
            if (this.phoneNumber == null) return;
            // firstly look for the phone number on the primary contact
            Id primaryContactId = (Id) sObj.get('ContactId');
            if (primaryContactId != null && this.allContacts.containsKey(primaryContactId)) {
                ContactWrap primaryContactWrap = this.allContacts.get(primaryContactId);
                if (primaryContactWrap.phoneFieldAPI != null) { // there is the call phone number on the main contact
                    this.callCustomerId = primaryContactWrap.recordId;
                    this.phoneFieldAPI = primaryContactWrap.phoneFieldAPI ;
                    this.extensionNumber = primaryContactWrap.extensionNumber;
                }
            }
            // if the call phone number is not found on the main contact, then look last modified contacts
            if (this.callCustomerId == '') {
                for (ContactWrap conWrap : this.allContacts.values()) {
                    if (conWrap.phoneFieldAPI == null) continue;
                    this.callCustomerId = conWrap.recordId;
                    this.phoneFieldAPI = conWrap.phoneFieldAPI ;
                    this.extensionNumber = conWrap.extensionNumber;
                    break;
                }
            }
        }
        public List <String> getAllPhones () {
            if(this.allPhones == null) {
                this.allPhones =  new List <String> ();
                if (this.allContacts.isEmpty()) return this.allPhones;
                ContactWrap mainContactWrap = this.allContacts.get(this.mainContactId);
                this.allPhones.addAll(Naumen_RecordsHelper.getAllPhoneNumbersInNaumenFormat(mainContactWrap.sObj));
                for (ContactWrap conWrap : this.allContacts.values()) {
                    if (conWrap.recordId == this.mainContactId) continue; 
                    this.allPhones.addAll(Naumen_RecordsHelper.getAllPhoneNumbersInNaumenFormat(conWrap.sObj));
                }
            }
            return this.allPhones;
        }
    }
    public class OpportunityListWrap {
        public Map <Id, OpportunityWrap> oppWraps; // opportunity id => opportunity wrap
        public OpportunityListWrap (List <Opportunity> opps, String phoneNumber) {
            this.oppWraps = new  Map <Id, OpportunityWrap> ();
            if (opps == null || opps.isEmpty()) return;
            // get related contacts
            Map <Id, Map <Id, Contact>> oppsToContactsMap = queryContactsForOpportunityList(opps);
            // create Opportunity Wraps
            for (Opportunity opp : opps) {
                Map <Id, Contact> contactsMap = oppsToContactsMap.containsKey(opp.Id) ? oppsToContactsMap.get(opp.Id) : null;
                OpportunityWrap oppWrap = new OpportunityWrap (opp, phoneNumber, contactsMap);
                oppWraps.put(opp.Id, oppWrap);
            }
        }
    }
// --- CONTACT DATA ---
    public class ContactWrap extends RecordWrap{
        public ContactWrap (sObject sObj, String phoneNumber) {
            super (sObj, phoneNumber);
            Contact con = (Contact)sObj;
            this.name = con.FirstName == null ? con.LastName : con.FirstName + ' ' + con.LastName;
            if (phoneNumber != null) {
                setPhoneFieldAPI();
                setExtensionNumberVal();
            }
        }
        private String checkCallPhoneNumber (String phoneNumber) {
            // returns true id the call phone number is found on this contact
            Contact con = (Contact) sObj;
            String phoneNumberFormatted = PhoneNumbersHandler.getNumberInNaumenFormat (this.phoneNumber);
            PhoneNumbersHandler.sObjWrapper sObjWrap = new PhoneNumbersHandler.sObjWrapper(con, null);
            List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(Schema.Contact.SObjectType, 'All_Phone_Fields');
            Map <String, String> unifiedPhonesMap = sObjWrap.getUnifiedNumbersMap(phoneFieldsAPIs, false);
            if (unifiedPhonesMap.containsKey(phoneNumberFormatted)) {
                return unifiedPhonesMap.get(phoneNumberFormatted);
            }
            return null;
        }
        public  List <String> getAllPhones () {
            if(this.allPhones == null) {
                this.allPhones =  new List <String> ();
                this.allPhones.addAll(Naumen_RecordsHelper.getAllPhoneNumbersInNaumenFormat(sObj));
            }
            return this.allPhones;
        }
    }
    /* not used now since we use naumen softphone on ccspeedup page only
    // ------------------ WRAPS: SAVE CALL DATA ----------------------------
    public class SaveCallData {
        public String phoneNumber {get{return this.phoneNumber == null ? '' : this.phoneNumber;} set;}
        public String recordId {get{return this.recordId == null ? '' : this.recordId;} set;}
    }
    */

// ------------------ WRAPS: CUSTOMER RECORDS DATA FOR CREATING A TABLE (LEAD, OPPORTUNITY WITH CONTACTS) ----------------------------
    public class RecordsTableParams { // this class is used to get preview data in naumen supervisor panel and in the batch to create a csv file
        public Schema.sObjectType sObjType; // sObject type of the table records
        public List <String> fieldsList; // each field is a column in the table
        public List <String> mainContactFields; // optional (used for opportunity)
        public Boolean addRegionInfo; // add timezone info and allowed call time info
        public Boolean addAllPhonesColumns; // add all phones on the sObject or on the related records (on related contacts - for opportunity)

        public RecordsTableParams (Schema.sObjectType sObjType, List <String> fieldsList, Boolean addRegionInfo, Boolean addAllPhonesColumns) {
            this.sObjType = sObjType;
            this.fieldsList = fieldsList;
            this.addRegionInfo = addRegionInfo == null ? false : addRegionInfo;
            this.addAllPhonesColumns = addAllPhonesColumns == null ? false : addRegionInfo;
        }
        public List <String> getFieldsToQueryRecords () {
            List <String> fieldsToQuery = new List <String> (this.fieldsList);
            // create query string
            if (this.addAllPhonesColumns == true) {
                List <String> phoneFieldsAPIs = PhoneNumbersHandler.getAllPhoneFields (this.sObjType);
                fieldsToQuery.addAll(phoneFieldsAPIs);
            }
            if (this.sObjType == Schema.Opportunity.sObjectType) {
                List<String> fieldsToQuery_Opp = Naumen_RecordsHelper.createFieldsList_Opportunity ();
                fieldsToQuery.addAll(fieldsToQuery_Opp);
            }
            Set <String> fieldsToQuerySet = new Set <String> (fieldsToQuery);
            fieldsToQuery = new List <String>(fieldsToQuerySet);
            return fieldsToQuery;
        }
    }
    public class RecordsTableData { // this class is used to get preview data in naumen supervisor panel and in the batch to create a csv file
        private RecordsTableParams params;
        public List <String> headersList;
        public Map <Id, List <String>> rowsMap;
        
        public RecordsTableData (RecordsTableParams params) {
            this.params = params;
            getHeaders();
            this.rowsMap = new  Map <Id, List <String>> (); 
        }
    // --- table headers ---------
        private void getHeaders () {
            this.headersList = new List <String> ();
            if (this.params.sObjType == null) return;
            this.headersList = GlobalUtils.getFieldsLabels (String.valueOf(this.params.sObjType), this.params.fieldsList);
            addAdditionalHeaders ();
        }
        private void addAdditionalHeaders () {    
            // add additional Excel headers   
            // regions and timezone headers
            if (this.params.addRegionInfo) {
                List <String> regionFields = new List <String> {'Time_Zone__c', 'Allowed_Call_Time_From__c', 'Allowed_Call_Time_To__c'};
                this.headersList.addAll(GlobalUtils.getFieldsLabels ('FS_Tree_Province__mdt', regionFields));
            }
            // main contact headers
            if (this.params.mainContactFields != null && !this.params.mainContactFields.isEmpty()) {
                this.headersList.addAll(GlobalUtils.getFieldsLabels ('Contact', this.params.mainContactFields));
            }
            // phones headers
            if (this.params.addAllPhonesColumns) {
                addPhonesHeaders();
            }
        }
        private void addPhonesHeaders () {
            for (Integer i = 0; i < 15; i++) { // add first 15 phone numbers in separated columns
                Integer phoneHeaderNumber = i+1;
                this.headersList.add(Label.header_PhoneNumber + ' ' + phoneHeaderNumber);
            }
            String phonesRecordSObjType = this.params.sObjType == Schema.Opportunity.sObjectType ? 'Contact'  // for opportunity phones are stored on related contact records
                                                                                            : String.valueOf(this.params.sObjType);
            String additionalPhonesLabel =  GlobalUtils.getFieldsLabels (phonesRecordSObjType, new List <String> {'Additional_Phones__c'})[0];
            this.headersList.add(additionalPhonesLabel);
        }
    // --- table row values ---------
        public void clearRowsMap () {
            this.rowsMap = new  Map <Id, List <String>> ();
        }
        public void addRowsMap (List <sObject> sObjList) {
            // creates a map where each sobj id is a new row and has a list of field values of the sobject or of its related records (such as contacts)
            if (sObjList == null || sObjList.isEmpty()) return;
            Map <Id, RecordWrap> recordWrapsMap;
            if (this.params.sObjType == Schema.Opportunity.sObjectType) {
                OpportunityListWrap oppListWrap = new OpportunityListWrap(sObjList, null);
                recordWrapsMap = oppListWrap.oppWraps;
            }
            for(sObject sObj: sObjList){
                Id sObjId = (Id) sObj.get('Id');
                List <String> rowValues = new List <String>();
                for (String fieldAPI : this.params.fieldsList) {
                    String fieldVal = GlobalUtils.getFieldValue (sObj, fieldAPI);
                    addRowValue (rowValues, fieldVal);
                }
                if (this.params.addRegionInfo == true) {
                    FS_Tree_Province__mdt regionData = GlobalUtils.getRegionData(sObj);
                    addRowValue (rowValues, regionData == null ? '' : regionData.Time_Zone__c);
                    addRowValue (rowValues, regionData == null ? '' : regionData.Allowed_Call_Time_From__c);
                    addRowValue (rowValues, regionData == null ? '' : regionData.Allowed_Call_Time_To__c);
                }

                // add related contact fields values and phone values
                if (this.params.sObjType == Schema.Opportunity.sObjectType) {
                    if (recordWrapsMap.containsKey(sObjId)) {
                        OpportunityWrap oppWrap = (OpportunityWrap) recordWrapsMap.get(sObjId);
                        if (!oppWrap.allContacts.isEmpty()) { 
                            // add main contact fields values
                            if (this.params.mainContactFields != null && !this.params.mainContactFields.isEmpty()) {
                                ContactWrap mainContactWrap = oppWrap.allContacts.get(oppWrap.mainContactId);
                                Contact mainContact = (Contact) mainContactWrap.sObj;
                                for (String contactFieldAPI : this.params.mainContactFields) { // for each phone field fill in the column in the csvRow
                                    String contactFieldVal = String.valueOf(mainContact.get(contactFieldAPI)); // set phone value
                                    addRowValue (rowValues, contactFieldVal);
                                }
                            }
                            // add all related contacts phone values
                            if (this.params.addAllPhonesColumns) {
                                List <String> allContactsPhones = oppWrap.getAllPhones();
                                addPhoneValues (allContactsPhones, rowValues);
                            }
                        }
                    }
                } else if (this.params.sObjType == Schema.Lead.sObjectType) {
                    // add phones values
                    if (this.params.addAllPhonesColumns) {
                        List <String> leadPhoneNumbers = getAllPhoneNumbersInNaumenFormat(sObj);
                        addPhoneValues (leadPhoneNumbers, rowValues);
                    }
                }
                this.rowsMap.put(sObjId, rowValues);
            }
        }
        private void addRowValue (List <String> rowValues, String val) {
            if (val == null) {
                rowValues.add('');
                return;
            }
            rowValues.add(val);
        }
        private void addPhoneValues (List <String> allPhoneNumbers, List <String> rowValues) {
            for (Integer i = 0; i < 15; i++) { // add first 15 phone numbers in separate columns
                if (i < allPhoneNumbers.size()-1) {
                    String phoneNum  = allPhoneNumbers[i];
                    rowValues.add(phoneNum);
                } else {
                    rowValues.add('');
                }
            }
            if (allPhoneNumbers.size() > 15) { 
                List <String> leftPhonesList = new List <String> ();
                for (Integer i = 15; i < allPhoneNumbers.size(); i++) { // add first 15 phone numbers in separate columns
                    String phoneNum  = allPhoneNumbers[i];
                    leftPhonesList.add(phoneNum);
                }
                String leftPhonesStr = String.join(leftPhonesList, '.');
                rowValues.add(leftPhonesStr);
            } else {
                rowValues.add('');
            }
        } 
    }
// ------------------ WORKING WITH RECORD WRAPPERS METHODS----------------------------
    /*******************************************************************************
    *  Name            : createRecordWrap
    *  Summary         : finds all phones on the record passed in the params and transfering those phones to one same format to avoid
    *  Parameters      : sObject sObj - the record on which we are getting all phone numbers and transferinng them to Naumen format
    *  Returns         : List<String> - list of the record's phones collected in the one format
    ******************************************************************************/
    public static RecordWrap createRecordWrap (sObject sObj, String phoneNumber) {
        RecordWrap ret;
        if (sObj == null) return ret;
        if (sObj.getSobjectType() == Schema.Lead.sObjectType) {
            ret = new LeadWrap (sObj, phoneNumber);
        } else if (sObj.getSobjectType() == Schema.Opportunity.sObjectType) {
            ret = new OpportunityWrap (sObj, phoneNumber);
        } else if (sObj.getSobjectType() == Schema.Contact.sObjectType) {
            ret = new ContactWrap (sObj, phoneNumber);
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getAllPhoneNumbersInNaumenFormat
    *  Summary         : finds all phones on the record passed in the params and transfering those phones to one same format to avoid
    *  Parameters      : sObject sObj - the record on which we are getting all phone numbers and transferinng them to Naumen format
    *  Returns         : List<String> - list of the record's phones collected in the one format
    ******************************************************************************/
    public static List<String> getAllPhoneNumbersInNaumenFormat (sObject sObj) {
        List<String> ret = new List<String> ();
        Schema.sObjectType sObjType = sObj.getSObjectType();
        List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObjType, 'All_Phone_Fields');
        for (String phoneFieldAPI : phoneFieldsAPIs) {
            if (sObj.get(phoneFieldAPI) == null) continue; 
            if (phoneFieldAPI == 'Additional_Phones__c') {
                Map <String, String> processingAdditionalPhonesMap = PhoneNumbersHandler.getAdditionalPhonesMap (sObj);
                if (!processingAdditionalPhonesMap.isEmpty()) {
                    // add each additional phone to the phones list on the case
                    for (String additionalPhoneNumber : processingAdditionalPhonesMap.keySet()) {
                        String additionalPhoneInNaumenFormat = PhoneNumbersHandler.getNumberInNaumenFormat (additionalPhoneNumber);
                        if (additionalPhoneInNaumenFormat == null) continue; // wrong phone format
                        ret.add(additionalPhoneInNaumenFormat);
                    }
                }
            } else {
                // check id phone is valid
                String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
                if (String.valueOf(sObj.get(phoneStatusFieldAPI)) == 'Needs validation') continue;
                // add phone to the phones list on the case
                String phoneVal = String.valueOf(sObj.get(phoneFieldAPI));
                String phoneValInNaumenFormat = PhoneNumbersHandler.getNumberInNaumenFormat (phoneVal);
                if (phoneValInNaumenFormat == null) continue; // wrong phone format
                ret.add(phoneValInNaumenFormat);
            }
        }
        return ret; 
    }
// ------------------ CONTROLLER METHODS ----------------------------
    /*******************************************************************************
    *  Name            : getRecord
    *  Summary         : finds sf record of the call (Lead, Opportunity) by Naumen UUID and related Contact for Opportunity by phone number passed in the params, returns record wrapper for Naumen Softphone
    *  Parameters      : String recordNaumenUUID - id ofthe Lead/Contact record, String phoneNumber - current call phone number
    *  Returns         : Map<String,Object>: String: result of the operation => Object: Lead/Opportunity record wrapper for Naumen Softphone
    ******************************************************************************/
    public static Map<String,Object> getRecord (String recordNaumenUUID, String phoneNumber) {
        RecordWrap ret;
        try {
        // create record wrappers
            sObject sObj = getSObjRecordByUUID (recordNaumenUUID);
            if(sObj == null) notifyAdmin_RecordNotFoundByUUID (recordNaumenUUID, phoneNumber);
            ret = createRecordWrap (sObj, phoneNumber); 
        } catch (NaumenRecordException naumenEx) {
            String errMsg = naumenEx.getMessage();
            notifyAdmin_RecordNotFoundByUUID (recordNaumenUUID, phoneNumber);
            return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
        } catch (Exception ex) {
            String errMsg = ex.getMessage() + ' :: ' + ex.getStackTraceString();
            notifyAdmin_RecordNotFoundByUUID (recordNaumenUUID, phoneNumber);
            return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
        }
        return ret == null ? new Map<String,Object>{'status'=>'error','message'=>Label.Naumen_notifMsg_NoRecordsFound}
                            : new Map<String,Object>{'status'=>'ok','record'=>ret};
    }
    /*******************************************************************************
    *  Name            : getSObjRecordByUUID
    *  Summary         : finds an sObject in SF database by naumen case UUID
    *  Parameters      : String recordNaumenUUID - naumen case UUID
    *  Returns         : sObject - found SF recrod related with the Naumen case
    ******************************************************************************/
    private static sObject getSObjRecordByUUID (String recordNaumenUUID) {
        List <Schema.sObjectType> sObjTypes = new List <Schema.sObjectType> {Schema.Opportunity.sObjectType, Schema.Lead.sObjectType};
        // query records
        String whereStr = ' Naumen_Autocall_Case_UUID__c = \''+recordNaumenUUID+'\' ';
        for (Schema.sObjectType sObjectType : sObjTypes) {
            List<sObject> records = queryRecords (sObjectType, whereStr);
            if (!records.isEmpty()) return records[0]; 
        }
        return null;
    }
    /*******************************************************************************
    *  Name            : setCallCustomer
    *  Summary         : finds call customer record (Contact) by id passed in the params
    *  Parameters      : String callCustomerId - id of the Contact record, String phoneNumber - phone number of the Contact record (current call phone number in the softphone)
    *  Returns         : Map<String,Object>: String: result of the operation => Object: Contact record wrapper for Naumen Softphone
    ******************************************************************************/
    public static Map<String,Object> setCallCustomer (String callCustomerId, String phoneNumber) {
        RecordWrap conWrap;
        String whereStr = ' Id = \''+ callCustomerId +'\' ';
        List <Contact> contacts = queryRecords (Schema.Contact.sObjectType, whereStr);
        if (!contacts.isEmpty()) conWrap = createRecordWrap (contacts[0], phoneNumber);
        return new Map<String,Object>{'status'=>'ok', 'callCustomer'=>conWrap};
    }

    /* not used now since we use naumen softphone on ccspeedup page only
    * use this method to update Lead/Opportunity record from softphone if saveCustomerCallInfo param in NaumenSoftphoneJS is set as true
        public static Map<String,Object> saveCallData (String callDataJSON) {
            try {
                SaveCallData callData = (SaveCallData)JSON.deserializeStrict(callDataJSON, SaveCallData.class);
                Schema.sObjectType sObjectType =  Id.valueOf(callData.recordId).getsObjectType();
                String whereStr = ' Id = \'' + callData.recordId + '\'';
                List<sObject> records = queryRecords (sObjectType, whereStr);
                RecordWrap recordWrap = createRecordWrap (records[0], callData.phoneNumber);
                if (recordWrap.phoneFieldAPI == null) {
                    String errMsg = Label.Naumen_PhoneWasntFound;
                    errMsg = errMsg.replace('{0}', callData.phoneNumber);
                    return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
                }
                Schema.sObjectType callCustomerSObjType = Id.valueOf(recordWrap.callCustomerId).getSObjectType();
                sObject sObj = callCustomerSObjType.newSObject();
                sObj.put('Id', recordWrap.callCustomerId);
                setCallResultsFields(sObj, recordWrap.phoneFieldAPI, null);
                system.debug('sobj before update : ' + sObj);
                update sObj;
            } catch (Exception ex) {
                String errMsg = ex.getMessage() + ' :: ' + ex.getStackTraceString();
                return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
            }
            return new Map<String,Object>{'status'=>'ok'};
        }
    */
    /*******************************************************************************
    *  Name            : getOperatorComment
    *  Summary         : gets text of operator comment from Opportunirty/Lead record
    *  Parameters      : sObject sObj - Opportunirty/Lead record on which the comment is saved
    *  Returns         : String - text of the comment
    ******************************************************************************/
    public static String getOperatorComment (sObject sObj) {
    // Gets a last comment of the operator (by special symbols)
        String ret = '';
        try {
            String description = sObj.get('Description') == null ? '' : String.valueOf(sObj.get('Description'));
            if (description.indexOf('{{КЦ:') != -1) {
                Integer startIndex = description.indexOf('{{КЦ:Перезвон ') + 14;
                Integer endIndex = description.indexOf('}}') == -1 ? description.length() : description.indexOf('}}');
                String commentWithCallbackTime = description.substring(startIndex, endIndex);
                List <String> callBackCommentSplitted = commentWithCallbackTime.split(' Коммент.: ');
                if (callBackCommentSplitted.size() > 1) {
                    ret = callBackCommentSplitted[1]; // get comment without callbackTime
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(
                    'RecordAssignCheckRuCtrl getOperatorComment (Current User = '+UserInfo.getUserId()+')(sObject Id = '+ (sObj != null ? String.valueOf(sObj.get('Id')) : '') +') ' + (String)e.getMessage(),
                    (String)e.getStackTraceString());
            return '';
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : addOperatorComment
    *  Summary         : adds operator comment to Opportunirty/Lead record (without updating it)
    *  Parameters      : sObject sObj - on which the comment will be saved, DateTime callBackTime - time of call back to save in the comment, String newComment - text of the comment
    *  Returns         : -
    ******************************************************************************/
    public static void addOperatorComment (sObject sObj, DateTime callBackTime, String newComment) {
    // Adds/Replaces the comment which operator will see on the page next time 
        String description = sObj.get('Description') == null ? '' : String.valueOf(sObj.get('Description'));
        Integer startIndex = description.indexOf('{{КЦ:Перезвон ') == -1 ? description.length() : description.indexOf('{{КЦ:');
        Integer endIndex = description.indexOf('}}') == -1 ? description.length() : description.indexOf('}}') + 2;
        String descriptionStart = description.substring(0, startIndex);
        String descriptionEnd = description.substring(endIndex, description.length());
        
        if (callBackTime != null) { // clear up the comment if there is no callback
            String callBackTimeFormatted = callBackTime.format('dd.MM.yyyy HH:mm');
            newComment = '  {{КЦ:Перезвон ' + callBackTimeFormatted + ' Коммент.: ' + newComment + '}}  ';
        }
        String newDescription = descriptionStart + newComment + descriptionEnd;
        sObj.put('Description', newDescription);
    }
    /*******************************************************************************
    *  Name            : setCallCustomer
    *  Summary         : finds call customer record (Contact) by id passed in the params
    *  Parameters      : String callCustomerId - id of the Contact record, String phoneNumber - phone number of the Contact record (current call phone number in the softphone)
    *  Returns         : Map<String,Object>: String: result of the operation => Object: Contact record wrapper for Naumen Softphone
    ******************************************************************************/
    public static void setCallResultsFields (sObject sObj, String phoneFieldAPI, String newPhoneStatus) {
        // values
        newPhoneStatus = newPhoneStatus == null ? 'Successful dialing' : newPhoneStatus;
        system.debug('newPhoneStatus : ' + newPhoneStatus);
        Double newPhoneRating = PhoneNumbersHandler.countPhoneRating(sObj, phoneFieldAPI, newPhoneStatus); 
        
        // set values to the fields
        if (!newPhoneStatus.startsWith('Wrong number')) { // status field equals null if phoneFieldAPI is wrong or if phoneFieldAPI = "Additional_Phones__c"
            String phoneStatusAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
            if (phoneStatusAPI != null) {  
                String phoneStatusModifiedDateAPI = PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneFieldAPI);
                String phoneRatingField = PhoneNumbersHandler.getPhoneRatingField(phoneFieldAPI); 
                sObj.put(phoneStatusAPI, newPhoneStatus); // set status
                sObj.put(phoneRatingField, newPhoneRating);
                sObj.put(phoneStatusModifiedDateAPI, system.now()); // set phone status modified date
            }
        } else {
            //RecordWrap recordWrap = createRecordWrap (sObj, phoneNumber); // look for the field where this phone number is currently saved
            //String phoneStatusAPI = PhoneNumbersHandler.getPhoneStatusField (recordWrap.phoneFieldAPI);
            String phoneStatusAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);

            if (phoneStatusAPI != null) {
                sObj.put(phoneStatusAPI, newPhoneStatus); // set status wrong number to move it to irrelevant list
            }
        }
    }
// ------------------ GET LIST OF FIELDS BY SOBJECT TYPE ----------------------------
    /*******************************************************************************
    *  Name            : createFieldsList_Lead
    *  Summary         : this method is used for creating LeadWrapper from Lead record
    *  Returns         : list of Lead fields to query Lead records
    ******************************************************************************/
    public static List<String> createFieldsList_Lead () {
    // add general fields
        List <String> fieldsList = new List <String> {'Id', 'FirstName', 'LastName', 'Company', 'Naumen_Autocall_Case_UUID__c', 'Title', 'Email'};
    // add phone fields
        List <String> phoneFields = PhoneNumbersHandler.getAllPhoneFields (Schema.Lead.sObjectType);
        fieldsList.addAll(phoneFields);
        return fieldsList;
    }
    /*******************************************************************************
    *  Name            : createFieldsList_Opportunity
    *  Summary         : this method is used for creating OpportunityWrapper from Opportunity record
    *  Returns         : list of Opportunity fields to query Opportunity records
    ******************************************************************************/
    public static List<String> createFieldsList_Opportunity () {
    // add general fields
        List <String> fieldsList = new List <String> {'Id', 'Name', 'ContactId', 'AccountId', 'Account.Name', 'Naumen_Autocall_Case_UUID__c'};
        return fieldsList;
    }
    /*******************************************************************************
    *  Name            : createFieldsList_Contact
    *  Summary         : this method is used for creating ContactWrapper from Contact record
    *  Returns         : list of Contact fields to query Contact records
    ******************************************************************************/
    public static List<String> createFieldsList_Contact () {
    // add general fields
        List <String> fieldsList = new List <String>  {'Id', 'Name', 'FirstName', 'LastName', 'AccountId', 'Title', 'Email'};
    // add phone fields
        List <String> phoneFields = PhoneNumbersHandler.getAllPhoneFields (Schema.Contact.sObjectType);
        fieldsList.addAll(phoneFields);
        return fieldsList;
    }
// ------------------ QUERY RECORD ----------------------------
    /*******************************************************************************
    *  Name            : queryContactsForSingleOpportunity
    *  Summary         : gets all contacts for 1 single opportunity
    *  Parameters      : Opportunity opp - opportunity record for which the contacts will be found
    *  Returns         : Map <Id, Contact> - contact id => contact record 
    ******************************************************************************/
    public static Map <Id, Contact> queryContactsForSingleOpportunity (Opportunity opp){
        Map <Id, Map <Id, Contact>> oppToContactsMap = queryContactsForOpportunityList(new List <Opportunity> {opp});
        return oppToContactsMap.containsKey(opp.Id) ? oppToContactsMap.get(opp.Id) : new Map <Id, Contact> ();
    }
    /*******************************************************************************
    *  Name            : queryContactsForOpportunityList
    *  Summary         : gets all contacts for a list of opportunities and maps it to the opportunity ids
    *  Parameters      : List <Opportunity> opps - opportunities for which the contacts will be found
    *  Returns         :Map <Id, Map <Id, Contact>> - opportunity id => map <contact id => contact record> 
    ******************************************************************************/
    public static Map <Id, Map <Id, Contact>> queryContactsForOpportunityList (List <Opportunity> opps) {
        Map <Id, Map <Id, Contact>> ret = new Map <Id, Map <Id, Contact>> ();
        if (opps == null || opps.isEmpty()) return ret;
        Set <Id> oppIds = new Set <Id>();
    // get contacts from the opportunity's parent account      
        Map <String, Id> accountIdToOppIdMap = new Map <String, Id> (); // account id => opportunity id
        for (Opportunity opp :opps) {
            oppIds.add(opp.Id);
            if (opp.AccountId != null) accountIdToOppIdMap.put(opp.AccountId, opp.Id);
        }
    // get contacts from opportunity contactRoles    
        Map <String, Id> contactIdToOppIdMap = new Map <String, Id> (); // contact id => opportunity id
        for(OpportunityContactRole oppContactRole : [SELECT Id, ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN :oppIds]){
            contactIdToOppIdMap.put(oppContactRole.ContactId, oppContactRole.OpportunityId);
        }
    // create where string to query all contacts from the opportunity
        String whereStr = '';
        if (!accountIdToOppIdMap.isEmpty()) {
            whereStr += ' AccountId IN (\''+String.join(new List<String>(accountIdToOppIdMap.keySet()), '\',\'')+'\') '; // get contacts from parent account
        }
        if (!contactIdToOppIdMap.isEmpty()) {
            if (whereStr != '') whereStr += ' OR ';
            whereStr += ' Id IN (\''+String.join(new List<String>(contactIdToOppIdMap.keySet()), '\',\'')+'\') '; // get contacts from opportunity contact roles
        }
        whereStr += ' ORDER BY LastModifiedDate DESC ';
    // query records and set current contact
        List <Contact> contacts = queryRecords (Schema.Contact.sObjectType, whereStr);
        if (contacts.isEmpty()) return ret;
        Map <Id, Contact> contactsMap = new Map <Id, Contact> (contacts);
        for (Id contactId : contactsMap.keySet()) {
            Id opportunityId;
            String accountId = contactsMap.get(contactId).AccountId;
            if (contactIdToOppIdMap.containsKey(contactId)) { // get opportunity id from contact role
                opportunityId = contactIdToOppIdMap.get(contactId);
            } else { // get opportunity id from parent account
                opportunityId = accountIdToOppIdMap.get(accountId);
            }
            if (!ret.containsKey(opportunityId)) ret.put(opportunityId, new Map <Id, Contact> ());
            ret.get(opportunityId).put(contactId, contactsMap.get(contactId));
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : queryRecords
    *  Summary         : queries records for creating RecordWrap list from SF records
    *  Parameters      : Schema.sObjectType sObjectType - sObject type to query, String whereStr - end of the query with certain conditions
    *  Returns         : List <sObject> - found records
    ******************************************************************************/
    private static List <sObject> queryRecords (Schema.sObjectType sObjectType, String whereStr) {
        List <String> fieldsToSelect;
        if (sObjectType == Schema.Lead.sObjectType) {
            fieldsToSelect = createFieldsList_Lead ();
        } else if  (sObjectType == Schema.Opportunity.sObjectType) {
            fieldsToSelect = createFieldsList_Opportunity ();
        } else if (sObjectType == Schema.Contact.sObjectType) {
            fieldsToSelect = createFieldsList_Contact ();
        }
        String queryString = createQuery(sObjectType, new List <String>(fieldsToSelect), whereStr);
        List<sObject> records = Database.query(queryString);
        return records;
    }
    /*******************************************************************************
    *  Name            : queryRecords
    *  Summary         : builds query string
    *  Parameters      : Schema.sObjectType sObjectType - sObject type to query, List <String> fields - fields to query, String whereStr - end of the query with certain conditions
    *  Returns         : String - query string
    ******************************************************************************/
    private static String createQuery (Schema.sObjectType sObjectType, List <String> fields, String whereStr) {
        String fieldsString =  String.join(new List <String> (fields), ',');
        whereStr = (whereStr == null || whereStr == '') ? '' : ' WHERE ' + whereStr;
        return 'SELECT ' + fieldsString + ' FROM ' + String.valueOf(sObjectType) + whereStr; 
    }
// ------------------ NOTIFICATIONS ----------------------------
    /*******************************************************************************
    *  Name            : notifyAdmin_RecordNotFoundByUUID
    *  Summary         : sends email notification that there is no record for Naumen case of the current call
    *  Parameters      : String naumenCaseUUID - UUID of the Naumen case, String phoneNumber - phone number of the current call
    ******************************************************************************/
    private static void notifyAdmin_RecordNotFoundByUUID (String naumenCaseUUID, String phoneNumber) {
        String errMsg = 'Lead/Opportunity record with Naumen case UUID "' + naumenCaseUUID + '" is not found in Salesforce. Naumen autocall phone number: ' + phoneNumber;
        String subject = 'Naumen get record error';
        sendInfoEmail(errMsg, subject);
    }

// ====== SEND EMAILS ====================================================================
    public static void sendErrorEmail(String body) { // send email to admins when error occured
        if (!Test.isRunningTest()) sendEmail(body, 'Naumen error occured', getNaumenEmailRecievers(naumenSettings.Admin_Emails__c));
    }
    public static void sendInfoEmail(String body, String subject) { // send email supervisors
        if (!Test.isRunningTest()) sendEmail(body, subject, getNaumenEmailRecievers(naumenSettings.Supervisor_Emails__c));
    }
    public static void sendUploadEmail(String body, String subject) { // send email to upload results notifications recievers 
        if (!Test.isRunningTest()) sendEmail(body, subject, getNaumenEmailRecievers(naumenSettings.UploadResultsRecievers_Emails__c));
    }
    public static void sendLogsEmail(String body, String subject) { // send email to integration logs recievers
        if (!Test.isRunningTest()) sendEmail(body, subject, getNaumenEmailRecievers(naumenSettings.IntegrationLogs_Emails__c));
    }
    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : sends email to Naumen email notification recipients
    *  Parameters      : String body - email body, String subject - email subject
    *  Returns         : -
    ******************************************************************************/
    private static void sendEmail(String body, String subject, List <String> toAddresses) {
        if (toAddresses.isEmpty()) return;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHTMLBody(body);
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    /*******************************************************************************
    *  Name            : getNaumenEmailRecievers
    *  Summary         : creates a list of emails from string in the settings
    *  Parameters      : String emailAddressesString - emails from settings
    *  Returns         : List <String> - list of email addresses
    ******************************************************************************/
    public static List <String> getNaumenEmailRecievers (String emailAddressesString) {
        if (emailAddressesString == null) return new List <String>();
        return emailAddressesString.split(',');
    }
}