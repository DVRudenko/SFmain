abstract public with sharing class PhoneNumbersControllerHelper {
    
    public Boolean isNewRecord {get;set;}
    public ApexPages.StandardController stdController;
    public Schema.sObjectType sObjType;
    public String sObjId;
    public sObject sObj {get;set;}
    public Boolean phoneFieldsError {get;set;}
    public String descriptionText {get;set;}
    
    public static Map <Schema.sObjectType, List <String>> fieldsToSelect;

    public void initPhones (Boolean isNewRecord, Schema.sObjectType sObjectType, ApexPages.StandardController stdController) {
        this.isNewRecord = isNewRecord;
        this.phoneRowWrappers = new List <PhoneRowWrapper> ();
        this.stdController = stdController;
        this.sObjId = stdController.getId();
        this.sObjType = sObjectType;
        fieldsToSelect  = getAllPhoneFormFields(this.sObjType);
        createPhoneRowWrappersList ();
        if (!Test.isRunningTest()) stdController.addFields(fieldsToSelect.get(this.sObjType));
        this.sObj = stdController.getRecord();
        this.descriptionText = this.sObj.get('Description') == null ? '' : String.valueOf(this.sObj.get('Description'));
        prepareData_PhoneFields ();
        if (!isNewRecord) prepareData_IrrelevantPhones ();
        prepareData_AdditionalPhones ();
    }

    public static Map <Schema.sObjectType, List <String>> getAllPhoneFormFields(Schema.sObjectType sObjectType) {
        if (fieldsToSelect != null && fieldsToSelect.containsKey(sObjectType)) return fieldsToSelect;
        if (fieldsToSelect == null) fieldsToSelect = new Map <Schema.sObjectType, List <String>>();
        fieldsToSelect.put(sObjectType, new List <String> ());
        List<Schema.FieldSetMember>  phoneFields = GlobalUtils.getFieldSetMembers (sObjectType, 'All_Phone_Fields');
        for (Schema.FieldSetMember phoneField : phoneFields) {
            if (!phoneField.getFieldPath().contains('.')) {
                //--- phone fields ---
                String phoneFieldAPI = phoneField.getFieldPath();
                fieldsToSelect.get(sObjectType).add(phoneFieldAPI);
                //--- phone status fields ---
                String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
                if (phoneStatusFieldAPI != null) {
                    fieldsToSelect.get(sObjectType).add(phoneStatusFieldAPI);
                    fieldsToSelect.get(sObjectType).add(PhoneNumbersHandler.getPhoneRatingField (phoneFieldAPI));
                    String statusModifiedDateFieldAPI =  PhoneNumbersHandler.getPhoneStatusModifiedDateField (phoneFieldAPI);
                    fieldsToSelect.get(sObjectType).add(statusModifiedDateFieldAPI);
                }
            }
        }
        fieldsToSelect.get(sObjectType).add('Id');
        fieldsToSelect.get(sObjectType).add('Irrelevant_Phones__c');
        fieldsToSelect.get(sObjectType).add('Irrelevant_Phones_ModifiedDate__c');
        fieldsToSelect.get(sObjectType).add('Description');
        if (sObjectType == Schema.Contact.sObjectType) {
            fieldsToSelect.get(sObjectType).add('AccountId');
        }
        return fieldsToSelect;
    }
    public static String createQuery (Schema.sObjectType sObjectType, String sObjectId) {
        getAllPhoneFormFields(sObjectType);
        String query = 'SELECT ' + String.join(fieldsToSelect.get(sObjectType), ',') + ' FROM ' + String.valueOf(sObjectType) + ' WHERE Id = \'' + sObjectId + '\'';
        return query;
    }
    public sObject queryRecord () {
        return Database.query(createQuery(this.sObjType, this.sObjId));
    }
    public static Boolean updateRecord (sObject sObjToUpdate) {
        if (sObjToUpdate == null) return true;
        try {
            update sObjToUpdate;
        } catch(Exception e) {
           ApexPages.addMessages(e);
           system.debug('!!! error: ' + e);
           return false;
        }
        return true;
    }
    public static Boolean addNewIrrelevantNumbers (sObject sObjToUpdate, Map <String, String> newIrrelevantPhones) {
        if (sObjToUpdate == null) return true;
        try  {
            PhoneNumbersHandler.addIrrelevantNumber (sObjToUpdate, newIrrelevantPhones);
        } catch(Exception e) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           system.debug('!!! error: ' + e.getStackTraceString());
           return false;
        }
        return true;
    }
    // --------------- Phone Fields ---------------
    public static Map <String, String> phoneStatusReasons {get {return phoneStatusReasons == null ? createMap_PhoneStatusReasons() : phoneStatusReasons;} set;}
    public List <PhoneRowWrapper> phoneRowWrappers {get;set;}
    public Boolean editView {get; set;}
    
    public void prepareData_PhoneFields () {
        this.phoneFieldsError = false;
        phoneStatusReasons = createMap_PhoneStatusReasons();
        loadData(this.sObj);
    }
    public void createPhoneRowWrappersList () {
        List<Schema.FieldSetMember>  phoneFields = GlobalUtils.getFieldSetMembers (this.sObjType, 'All_Phone_Fields');
        for (Schema.FieldSetMember phoneField : phoneFields) {
            if (!phoneField.getFieldPath().contains('.')) {
                //--- phone fields ---
                String phoneFieldAPI = phoneField.getFieldPath();
                //--- phone status fields ---
                String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
                if (phoneStatusFieldAPI != null) {
                   String statusModifiedDateFieldAPI =  PhoneNumbersHandler.getPhoneStatusModifiedDateField (phoneFieldAPI);
                   phoneRowWrappers.add (new PhoneRowWrapper (phoneFieldAPI, phoneStatusFieldAPI, statusModifiedDateFieldAPI, phoneField.getLabel()));
                }
            }
        }
    }
    public void refreshPhones () { 
        if (!this.phoneFieldsError) {
            this.sObj = queryRecord();
            this.editView = false;
            loadData(this.sObj);
            createIrrelevantPhonesList (this.sObj);
            if (this.sObjType != Schema.Account.sObjectType) {
                createAdditionalPhonesList(this.sObj);
            }
        }
    }
    public void refreshPhoneFields () { 
        if (!this.phoneFieldsError) {
            sObject sObjUpdated = queryRecord();
            this.sObj = sObjUpdated;
            loadData(this.sObj);
        }
    }
    public class PhoneRowWrapper {
        public Boolean editView {get;set;}
        public String phoneFieldAPI {get;set;}
        public String statusFieldAPI;
        public String ratingFieldAPI;
        public String statusModifiedDateFieldAPI;
        public String phoneFieldLabel {get;set;}
        public String phoneFieldVal {get;set;}
        public String statusFieldVal {get;set;}
        public String phoneFieldValOriginal {get;set;}
        public String statusFieldValOriginal {get;set;}
        public String statusFieldLabel {get;set;}
        public String ratingFieldVal {get;set;}
        public String statusModifiedDateFieldVal {get;set;}
        public String clickToCallLink {get;set;}
        public List<SelectOption> statusesValues {get;set;}
        
        public PhoneRowWrapper (String phoneFieldAPI, String statusFieldAPI, String statusModifiedDateFieldAPI, String phoneFieldLabel) {
            this.editView = false;
            this.phoneFieldAPI= phoneFieldAPI;
            this.statusFieldAPI= statusFieldAPI;
            this.statusModifiedDateFieldAPI = statusModifiedDateFieldAPI;
            this.ratingFieldAPI = PhoneNumbersHandler.getPhoneRatingField(phoneFieldAPI);
            this.phoneFieldLabel = phoneFieldLabel;
        }
        public void setValues(String phoneFieldVal, String statusFieldVal, Double ratingFieldVal, String statusModifiedDateFieldVal, String clickToCallLink, Map<String, SelectOption> statusesValues) {
            this.phoneFieldVal = phoneFieldVal;
            this.statusFieldVal = statusFieldVal;
            this.phoneFieldValOriginal = phoneFieldVal; // original value of phone number
            this.statusFieldValOriginal = statusFieldVal; // original value of phone status
            this.ratingFieldVal = String.valueOf(ratingFieldVal);
            this.statusModifiedDateFieldVal = statusModifiedDateFieldVal;
            this.clickToCallLink = clickToCallLink;
            this.statusesValues = statusesValues.values();
            this.statusFieldLabel = statusFieldVal == null ? '' : statusesValues.get(statusFieldVal).getLabel();
            //system.debug('statusesValues : ' + statusesValues);
            //system.debug('statusFieldVal : ' + statusFieldVal);
            //system.debug('statusFieldLabel : ' + statusFieldLabel);
        }
        public void editRow () {
            this.editView = true;
        }
        public void cancelEditRow () {
            this.editView = false;
            this.phoneFieldVal = this.phoneFieldValOriginal;
            this.statusFieldVal = this.statusFieldValOriginal;
        }
    }
    private void loadData (sobject sObjToLoad) {
        if (this.phoneRowWrappers.isEmpty()) return;
        for (PhoneRowWrapper phoneRowWrap : this.phoneRowWrappers) {
            if (phoneRowWrap.editView == true) {
                phoneRowWrap.editView = false;
            }
            String phoneFieldVal = sObjToLoad.get(phoneRowWrap.phoneFieldAPI) == null ? null : String.valueOf(sObjToLoad.get(phoneRowWrap.phoneFieldAPI));
            String statusFieldVal = sObjToLoad.get(phoneRowWrap.statusFieldAPI) == null ? null 
                                  : String.valueOf(sObjToLoad.get(phoneRowWrap.statusFieldAPI)).startsWith('Successful dialing:') ? 'Successful dialing'
                                  : String.valueOf(sObjToLoad.get(phoneRowWrap.statusFieldAPI));
            String statusModifiedDateFieldVal = sObjToLoad.get(phoneRowWrap.statusModifiedDateFieldAPI) == null ? null 
                                              : DateTime.valueOf(sObjToLoad.get(phoneRowWrap.statusModifiedDateFieldAPI)).format('dd.MM.yyyy HH:mm');
                                              //: Date.valueOf(sObjToLoad.get(phoneRowWrap.statusModifiedDateFieldAPI)).format(); // changed field type
            Double ratingFieldVal = sObjToLoad.get(phoneRowWrap.ratingFieldAPI) == null ? null 
                                  : Double.valueOf(sObjToLoad.get(phoneRowWrap.ratingFieldAPI));
            String clickToCallLink = phoneFieldVal == null ? '' : 'sip:'+PhoneNumbersHandler.trimPhoneNumber(phoneFieldVal, false);
            Map<String, SelectOption> statusesValues = getPhoneStatuses(phoneRowWrap.statusFieldAPI, sObjToLoad);
            phoneRowWrap.setValues(phoneFieldVal, statusFieldVal, ratingFieldVal, statusModifiedDateFieldVal, clickToCallLink, statusesValues);
        }
    }
    
    public Map<String, SelectOption> getPhoneStatuses(String phoneStatusFieldAPI, sObject sObjToLoad) {
        Map<String, SelectOption> soMap = new Map<String, SelectOption>();
        if (phoneStatusFieldAPI == null) return soMap ; 
        List<Schema.PicklistEntry> picklistValues = GlobalUtils.getPicklistValues (this.sObjType, phoneStatusFieldAPI);
        Map <String, Schema.PicklistEntry> picklistValuesMap = new Map <String, Schema.PicklistEntry>();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            picklistValuesMap.put(picklistEntry.getValue(), picklistEntry); // status api => status picklist entry
        }
        if (isNewRecord) {
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                if (picklistEntry.getValue().startsWith('Wrong number')) continue;
                String statusLabel = picklistEntry.getValue().startsWith('Succesful dialing') ? picklistValuesMap.get('Succesful dialing').getLabel() : picklistEntry.getLabel();
                soMap.put(picklistEntry.getValue(), new SelectOption(picklistEntry.getValue(), statusLabel));
            }
        } else {
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                // don't show 'move to account' irrelevant option for contact and account records
                if (picklistEntry.getValue() == 'Wrong number:2') { 
                    if (this.sObjType != Schema.Contact.sObjectType) continue; // dont put option to move to an account if it is a lead record
                    if (this.sObjType == Schema.Contact.sObjectType && sObjToLoad.get('AccountId') == null) continue;  // dont give an option of moving to parent irrelevant list if there is no parent account
                }
                // don't show irrelevant statuses if the phone value is empty, so the user will be filling a new value in the field
                if (sObjToLoad.get(phoneStatusFieldAPI) == null && picklistEntry.getValue().startsWith('Wrong number')) continue;
                // for all statuses of successful dialing show 1 label only - successful dialing
                String statusLabel = picklistEntry.getValue().startsWith('Succesful dialing') ? picklistValuesMap.get('Succesful dialing').getLabel() : picklistEntry.getLabel();
                soMap.put(picklistEntry.getValue(), new SelectOption(picklistEntry.getValue(), statusLabel));
            }
        }
        return soMap ;
    }
   
    public void toEdit () {
        this.editView = true;
    }
    public void toView () {
        if (!this.phoneFieldsError) {
            this.editView = false; 
            for (PhoneRowWrapper phoneRowWrap : this.phoneRowWrappers) {
                if (phoneRowWrap.editView == true) {
                    phoneRowWrap.editView = false;
                }
            }
        }
    }
    public void save_PhoneFields () {
        if (this.phoneRowWrappers.isEmpty()) return;
        sObject sObjToUpdate = queryRecord();
        try {
            putPhoneFieldsValues (sObjToUpdate);
        } catch (PhoneNumbersHandler.PhonesException  phonesE) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, phonesE.getMessage()));
            system.debug('!!! error: ' + phonesE.getMessage());
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('!!! error: ' + e.getMessage());
        }
        Boolean isSuccess = updateRecord (sObjToUpdate);
        if (isSuccess) {
            this.sObj = sObjToUpdate;
            this.phoneFieldsError = false;
            refreshPhones();
        } else {
            this.phoneFieldsError = true;
        }
    }
    public void putPhoneFieldsValues (sObject recordToUpdate) {
     if (this.phoneRowWrappers.isEmpty()) return;
        for (PhoneRowWrapper phoneRowWrap : this.phoneRowWrappers) {
            recordToUpdate.put(phoneRowWrap.phoneFieldAPI, phoneRowWrap.phoneFieldVal);
            recordToUpdate.put(phoneRowWrap.statusFieldAPI, phoneRowWrap.statusFieldVal);

            if (recordToUpdate.getSObjectType() == Schema.Lead.sObjectType && phoneRowWrap.phoneFieldAPI == 'Phone' && (phoneRowWrap.phoneFieldVal == null || phoneRowWrap.phoneFieldVal.deleteWhiteSpace() == '')) {
                PhoneNumbersHandler.preventSavingEmptyLeadPhoneField ();
            }
        }
    }
    private static Map <String, String> createMap_PhoneStatusReasons () { 
        return PhoneNumbersHandler.getPhoneStatusesWithReasons();
    }
    
    // --------------- Irrelevant list ---------------
    public Map <String, String> phoneStatusReasons_Irrelevant {get {return phoneStatusReasons_Irrelevant == null ? createMap_IrrelevantPhoneStatusReasons() : phoneStatusReasons_Irrelevant ;} set;}
    public List <Selectoption> phoneFieldAPIs_ToMoveIrrelevantItem {get;set;}
    public static Map <String, String> phoneFieldsMap_ToMoveIrrelevantItem;    
    public List <IrrelevantPhone> irrelevantPhonesList {get;set;}
    
    public void prepareData_IrrelevantPhones () {
        phoneFieldsMap_ToMoveIrrelevantItem = getMap_PhoneFields_ToMoveIrrelevantItem (this.sObjId);
        this.phoneFieldAPIs_ToMoveIrrelevantItem = getPhoneFieldAPIs_ToMoveIrrelevantItem();
        createIrrelevantPhonesList(stdController.getRecord());
    }
    
    public class IrrelevantPhone {
        public String sObjType {get;set;}
        public sObject sObj {get;set;}
        public String phoneNumber {get{return phoneNumber == null ? '' : phoneNumber;} set;}
        public Boolean canDelete {get{return  !sObj.isSet('Phone') || sObj.get('Phone') == null || phoneNumber != PhoneNumbersHandler.trimPhoneNumber(String.valueOf(sObj.get('Phone')), true);} set;}
        public Boolean isMoved {get{return isMoved == null ? false : isMoved;} set;}
        
        public String statusReason {get{return statusReason == null ? '' : statusReason;} set;}
        public String statusReasonCode {get{return statusReasonCode == null ? '' : statusReasonCode;} set;}
        public String statusModifiedDate {get{return statusModifiedDate == null ? '' : statusModifiedDate;} set;}
        public String msgText {get{return msgText == null ? '' : msgText;} set;}
        public String currentPhoneFieldAPI {get;set;}
        public String currentPhoneFieldValue {get;set;}

        public String pdDataContact {get;set;} // if an irrelevant phone number is being moved to a related contact then save pd data first

        
        public IrrelevantPhone (String phoneNumber, String statusReasonCode, String statusReason, String statusModifiedDate, sObject sObj) {
            this.phoneNumber = phoneNumber;
            this.statusReason = statusReason;
            this.statusReasonCode = statusReasonCode;
            this.statusModifiedDate = statusModifiedDate;
            this.sObj = sObj;
            this.sObjType = String.valueOf(sObj.getSObjectType());
            this.currentPhoneFieldAPI = '';
            this.pdDataContact = '';
        }

        public Map <String, String> getPDData_Contact (String conId) {
            List<Schema.FieldSetMember> pdFields_Contact = GlobalUtils.getFieldSetMembers (Schema.Contact.sObjectType, 'PD_Fields');
            List<Schema.FieldSetMember> phoneFields_Contact = GlobalUtils.getFieldSetMembers (Schema.Contact.sObjectType, 'All_Phone_Fields');
            Map <String, String> pdFieldsData_RelatedContacts = new Map <String, String> ();
            for (Schema.FieldSetMember pdField : pdFields_Contact) {
                pdFieldsData_RelatedContacts.put(pdField.getFieldPath(), '');
            }
            for (Schema.FieldSetMember phoneField : phoneFields_Contact) {
                if (phoneField.getFieldPath() != 'Additional_Phones__c' && !phoneField.getFieldPath().contains('.')) { 
                    pdFieldsData_RelatedContacts.put(phoneField.getFieldPath(), phoneField.getLabel());
                }
            }
            if (!pdFieldsData_RelatedContacts.containsKey('Id')) pdFieldsData_RelatedContacts.put('Id', '');
            if (!pdFieldsData_RelatedContacts.containsKey('PD_ExternalId__c')) pdFieldsData_RelatedContacts.put('PD_ExternalId__c', '');
            if (!pdFieldsData_RelatedContacts.containsKey('FirstName')) pdFieldsData_RelatedContacts.put('FirstName', '');
            if (!pdFieldsData_RelatedContacts.containsKey('LastName')) pdFieldsData_RelatedContacts.put('LastName', '');

            String query = 'SELECT ' + String.join(new List <String>(pdFieldsData_RelatedContacts.keySet()), ',') + ' FROM Contact WHERE Id = \'' + conId + '\' ORDER BY LastModifiedDate DESC LIMIT 5';
            List <Contact> cons = Database.query(query);
            Contact pdCon = cons[0];
            for (String fieldAPI : pdFieldsData_RelatedContacts.keySet()) {
                pdFieldsData_RelatedContacts.put(fieldAPI, pdCon.get(fieldAPI)== null ? null : String.valueOf(pdCon.get(fieldAPI)));
            }
            system.debug(pdFieldsData_RelatedContacts);
            return pdFieldsData_RelatedContacts;
        }

        public void moveToPhoneField() {
            system.debug('>> moveToPhoneField>> ' + this.phoneNumber + ' : ' + this.currentPhoneFieldAPI);
            checkFieldAndMovePhoneValue(true);
        }
        public void checkFieldAndMovePhoneValue(Boolean checkField) {
            Savepoint sp = Database.setSavepoint();
            if (this.phoneNumber == null || this.currentPhoneFieldAPI == '') return;
            sObject contactSObj;
            sObject currentSObj;
            Boolean movePhoneOnContact = false;
            String phoneFieldAPIToMove;
            if (this.SObjType == 'Account' && this.currentPhoneFieldAPI.startsWith('Contact')) {
                List <String> splitedVal = this.currentPhoneFieldAPI.split('\\.');
                String contactId = splitedVal[1];
                String contactFieldAPI = splitedVal[2];
                Contact con = (Contact) queryRecord (Schema.Contact.sObjectType, contactId);
                phoneFieldAPIToMove = contactFieldAPI;
                contactSObj = con; // move irrelevant phone value on a related contact record
                currentSObj = queryRecord();
                this.currentPhoneFieldValue = contactSObj.get(phoneFieldAPIToMove) == null ? null 
                                            : String.valueOf(contactSObj.get(phoneFieldAPIToMove));
                this.pdDataContact = JSON.serialize(getPDData_Contact(con.Id));
                movePhoneOnContact = true;                               
            } else {
                phoneFieldAPIToMove = this.currentPhoneFieldAPI;
                currentSObj = queryRecord();
                this.currentPhoneFieldValue = currentSObj.get(currentPhoneFieldAPI) == null ? null 
                                            : String.valueOf(currentSObj.get(currentPhoneFieldAPI));
                this.pdDataContact = '';
            }                     
            if (this.currentPhoneFieldValue != null && checkField) { // the selected field is not empty
                this.msgText = Label.notif_phonesList_PhoneFieldHasValue;
                this.msgText = this.msgText.replace('{0}', this.currentPhoneFieldValue);
                this.msgText = this.msgText.replace('{1}', this.phoneNumber);
                this.msgText = this.msgText.replace('{2}', this.currentPhoneFieldValue);
            } else if (movePhoneOnContact && checkField) {
                this.msgText = Label.notif_phonesList_confirmMoveToContact;
                this.msgText = this.msgText.replace('{0}', this.phoneNumber);
                this.msgText = this.msgText.replace('{1}', getMap_PhoneFields_ToMoveIrrelevantItem ((Id)this.sObj.get('Id')).get(this.currentPhoneFieldAPI));
            } else {
                Boolean successRemovedIrrelevant = false;
                removeNumberFromIrrelevantPhones(currentSObj);
                successRemovedIrrelevant = updateRecord (currentSObj);
          
                if (successRemovedIrrelevant) {
                   Boolean successAddedToIrrelevant = false;
                   sObject sObjToUpdatePhoneField = movePhoneOnContact ? contactSObj : currentSObj;
                   if (this.currentPhoneFieldValue != null) {
                        successAddedToIrrelevant = addCurrentValueToIrrelevant(sObjToUpdatePhoneField);
                   } else successAddedToIrrelevant = true;
                   
                   if (!successAddedToIrrelevant) {
                       Database.rollback(sp);
                       String errMsg = Label.exception_Phones_ErrorAddToIrrelevant;
                       errMsg = errMsg.replace('{0}', this.phoneNumber);
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
                       system.debug('!!! error: ' + errMsg);
                       cancelMoveToField();
                       return;
                   }
                   
                    // if we save phone on a contact then send data to Personal database first
                    sObjToUpdatePhoneField.put(phoneFieldAPIToMove, this.phoneNumber);
                    sObjToUpdatePhoneField.put(PhoneNumbersHandler.getPhoneStatusField(phoneFieldAPIToMove), 'New'); // set status as new
                    sObjToUpdatePhoneField.put(PhoneNumbersHandler.getPhoneRatingField(phoneFieldAPIToMove), 0); // set rating = 0 when move from irrelevant list to phone field
                    String statusModifiedDateField = PhoneNumbersHandler.getPhoneStatusModifiedDateField(phoneFieldAPIToMove);
                    sObjToUpdatePhoneField.put(statusModifiedDateField, system.now()); // set phone status modified date
                    Boolean successMovedToField = updateRecord (sObjToUpdatePhoneField);

                    if (successMovedToField) {
                        this.sObj = movePhoneOnContact ? currentSObj : sObjToUpdatePhoneField;
                        this.msgText = Label.notif_phonesList_MovedToPhoneField;
                        this.msgText = this.msgText.replace('{0}', this.phoneNumber);
                        Id currentSObjId = (Id)this.sObj.get('Id'); //(Id) sObjToUpdatePhoneField.get('Id');
                        this.msgText = this.msgText.replace('{1}', getMap_PhoneFields_ToMoveIrrelevantItem (currentSObjId).get(this.currentPhoneFieldAPI));
                        this.isMoved = true;
                        this.pdDataContact = '';
                    } else {
                        Database.rollback(sp);
                        String errMsg = Label.exception_Phones_ErrorAddToPhoneField;
                        errMsg = errMsg.replace('{0}', this.phoneNumber);
                        errMsg = errMsg.replace('{1}', getMap_PhoneFields_ToMoveIrrelevantItem ((Id)this.sObj.get('Id')).get(this.currentPhoneFieldAPI));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
                        system.debug('!!! error: ' + errMsg);
                        cancelMoveToField();
                        return;
                    }
                }
            }
        }
        public void cancelMoveToField () {
            this.currentPhoneFieldAPI = '';
            this.currentPhoneFieldValue = null;
        }
        public void continueMoveToField() {
            checkFieldAndMovePhoneValue(false);
        }
        public void deleteIrrelevantPhoneNumber () {
            removeNumberFromIrrelevantPhones (this.sObj);
            updateRecord (this.sObj);
        }
        private void removeNumberFromIrrelevantPhones (sObject sObjToUpdate) {
            PhoneNumbersHandler.removeIrrelevantNumber_fromRecord (sObjToUpdate, this.phoneNumber);
        }   
        private Boolean addCurrentValueToIrrelevant (sObject sObjToProcess) {
            return addNewIrrelevantNumbers (sObjToProcess, new  Map <String, String> {this.currentPhoneFieldValue => '1'}); 
        }
        public sObject queryRecord () {
            return queryRecord (this.sObj.getSObjectType(), String.valueOf(this.sObj.get('Id')));
        }
        public sObject queryRecord (Schema.sObjectTYpe sObjectType, String recordIdToQuery) {
            return Database.query(createQuery(sObjectType, recordIdToQuery));
        }
    }

    public List<SelectOption> getPhoneFieldAPIs_ToMoveIrrelevantItem() {
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption('', Label.label_None));
        for (String phoneFieldAPI : phoneFieldsMap_ToMoveIrrelevantItem.keySet()) { 
            soList.add(new SelectOption(phoneFieldAPI, phoneFieldsMap_ToMoveIrrelevantItem.get(phoneFieldAPI)));
        }
        return soList;
    } 
    
    public void refreshIrrelevantPhonesList () {
        sObject sObjUpdated = queryRecord();
        createIrrelevantPhonesList (sObjUpdated);
    }
    private void createIrrelevantPhonesList (sObject sObjUpdated) {
        this.irrelevantPhonesList = new List <IrrelevantPhone> ();
        List <String> irrelevantItemsList = PhoneNumbersHandler.getIrrelevantPhonesItemsList (sObjUpdated);
        Map <String, String> irrelevantStatusModifiedDateMap = PhoneNumbersHandler.getIrrelevantStatusesModifiedItems (sObjUpdated);
        if (!irrelevantItemsList.isEmpty()) {
            for (String irrelevantItem : irrelevantItemsList) {
                String phoneItem = PhoneNumbersHandler.irrelevantItem_getPhone(irrelevantItem);
                String statusModifiedItem = irrelevantStatusModifiedDateMap.get(PhoneNumbersHandler.trimPhoneNumber(phoneItem, false));
                String statusModifiedDate = PhoneNumbersHandler.irrelevantItem_getModifiedDate (statusModifiedItem);
                String reasonCodeItem = PhoneNumbersHandler.irrelevantItem_getReason(irrelevantItem);
                this.irrelevantPhonesList.add(new IrrelevantPhone(
                            phoneItem, 
                            reasonCodeItem, 
                            this.phoneStatusReasons_Irrelevant.get(reasonCodeItem), 
                            statusModifiedDate,
                            sObjUpdated));
            }
        }
    }
    public static Map <String, String> getMap_PhoneFields_ToMoveIrrelevantItem (Id sObjectId) {
        if(phoneFieldsMap_ToMoveIrrelevantItem!= null) return phoneFieldsMap_ToMoveIrrelevantItem;
        phoneFieldsMap_ToMoveIrrelevantItem= new Map <String, String> ();
        Schema.sObjectType sObjectType = sObjectId.getSObjectType();
        List<Schema.FieldSetMember>  phoneFields = GlobalUtils.getFieldSetMembers (sObjectType, 'All_Phone_Fields');
        for (Schema.FieldSetMember phoneField : phoneFields) {
            if (phoneField.getFieldPath() != 'Additional_Phones__c' && !phoneField.getFieldPath().contains('.')) { 
                phoneFieldsMap_ToMoveIrrelevantItem.put(phoneField.getFieldPath(), phoneField.getLabel());
            }
        }
        if (sObjectType == Schema.Account.sObjectType) {
            List<Schema.FieldSetMember>  phoneFields_Contact = GlobalUtils.getFieldSetMembers (Schema.Contact.sObjectType, 'All_Phone_Fields');
            List <Contact> cons = [SELECT FirstName, LastName FROM Contact WHERE AccountId =: sObjectId AND OwnerId =: UserInfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 5];
            for (Contact con : cons) { 
                for (Schema.FieldSetMember phoneField_Con : phoneFields_Contact) {
                    if (phoneField_Con.getFieldPath() != 'Additional_Phones__c' && !phoneField_Con.getFieldPath().contains('.')) { 
                        phoneFieldsMap_ToMoveIrrelevantItem.put('Contact.' + con.Id + '.' + phoneField_Con.getFieldPath(), 
                                (con.FirstName == null ? '' : con.FirstName) + ' ' + con.LastName + ': ' + phoneField_Con.getLabel());
                    }
                }
            }
        }
        return phoneFieldsMap_ToMoveIrrelevantItem;
    }
    
    private Map <String, String> createMap_IrrelevantPhoneStatusReasons () { 
        return PhoneNumbersHandler.getPhoneStatusReasons();
    }
    
    // --------------- Additional list ---------------
    public List <AdditionalPhone> additionalPhonesList {get;set;}
    public String newAdditionalPhoneNumber {get;set;}
    public List <Selectoption> phoneFieldAPIs_ToMoveAdditionalPhone  {get;set;}
    public String phoneToMove {get;set;}
    public Boolean editView_AdditionalPhones {get;set;}
    
    public void prepareData_AdditionalPhones () {
        if (this.sObjType == Schema.Account.sObjectType) return; 
        this.phoneFieldAPIs_ToMoveAdditionalPhone  = getPhoneFieldAPIs_ToMoveAdditionalPhone();
        createAdditionalPhonesList(this.sObj);
    }
    public void refreshAdditionalPhones () {
        if (this.sObjType == Schema.Account.sObjectType) return;
        sObject updatedSObject = queryRecord();
        createAdditionalPhonesList(updatedSObject);
    }
    public void toViewMode_AdditionalPhones () {
        this.editView_AdditionalPhones = false;
         for (AdditionalPhone phoneItem : this.additionalPhonesList) {
            if (phoneItem.editView == true) {
                phoneItem.editView = false;
            }
        }
    }
    public void toEditMode_AdditionalPhones () {
        this.editView_AdditionalPhones = true;
    }
    
    public class AdditionalPhone {
        public Boolean editView {get;set;}
        public String sObjType {get;set;}
        public sObject sObj {get;set;}
        public String accountId {get;set;}
        public String phoneNumber {get{return phoneNumber == null ? '' : phoneNumber;} set;}
        public String phoneNumberOriginal {get{return phoneNumberOriginal == null ? '' : phoneNumberOriginal;} set;}
        public String phoneStatus {get{return phoneStatus == null ? '' : phoneStatus;} set;}
        public String phoneStatusLabel {get{return phoneStatusLabel == null ? '' : phoneStatusLabel;} set;}
        public String phoneRating {get{return phoneRating == null ? '' : phoneRating;} set;}
        public String phoneModifiedDateFormatted {get{return phoneModifiedDateFormatted == null ? '' : phoneModifiedDateFormatted;} set;}
        public DateTime phoneModifiedDate_DT;
        public Boolean makeIrrelevant {get{return makeIrrelevant == null ? false : true;} set;}
        public String msgText {get{return msgText == null ? '' : msgText;} set;}
        public String currentPhoneFieldAPI {get;set;}
        public String currentPhoneFieldLabel {get;set;}
        public String currentPhoneFieldValue {get;set;}
        
        public Boolean readyToMove {get;set;}
        public Boolean isMoved {get;set;}
        
        public Boolean movedToIrrelevant {get; set;}
        
        public AdditionalPhone (String phoneNumber, String phoneStatus, String phoneRating, DateTime phoneModifiedDate, sObject sObj) {
            this.editView = false;
            this.phoneNumber = phoneNumber;
            this.phoneNumberOriginal = phoneNumber;
            this.phoneStatus = phoneStatus;
            this.phoneStatusLabel = phoneStatus == null ? null 
                            : phoneStatus.startsWith('Successful dialing:') ? 'Successful dialing'
                            : phoneStatus;
            this.phoneRating = phoneRating;
            this.phoneModifiedDate_DT = phoneModifiedDate;
            this.phoneModifiedDateFormatted = phoneModifiedDate == null ? '' : phoneModifiedDate.format('dd.MM.yy HH:mm');
            this.sObj = sObj;
            this.sObjType = String.valueOf(sObj.getSObjectType());
            if (this.sObjType == 'Contact') {
                this.accountId = this.sObj.get('AccountId') == null ? null 
                               : String.valueOf(this.sObj.get('AccountId'));
            }
            this.currentPhoneFieldAPI = '';
            this.currentPhoneFieldLabel = '';
            this.readyToMove = false;
            this.isMoved = false;
            this.movedToIrrelevant = false;
        }
        public void moveToPhoneField() {
            system.debug('>> moveToPhoneField>> ' + this.phoneNumber + ' : ' + this.currentPhoneFieldAPI);
            sObject sObjToUpdate = queryRecord();
            if (this.phoneNumber == null || this.currentPhoneFieldAPI == null) return;
            this.currentPhoneFieldLabel = this.currentPhoneFieldAPI;
            this.currentPhoneFieldValue = sObjToUpdate.get(currentPhoneFieldAPI) == null ? null 
                                      : String.valueOf(sObjToUpdate.get(currentPhoneFieldAPI));
            if (this.currentPhoneFieldValue == null) { // the selected field is empty 
               // set phone number
                sObjToUpdate.put(this.currentPhoneFieldAPI, this.phoneNumber);
               String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (this.currentPhoneFieldAPI);
               // set phone status
               String newPhoneStatus = this.phoneStatus == null || this.phoneStatus == '' ? 'New' : this.phoneStatus;
               sObjToUpdate.put(phoneStatusFieldAPI, newPhoneStatus);
               // set phone rating
               Double newPhoneRating = PhoneNumbersHandler.rating_formatToDouble(this.phoneRating);
               sObjToUpdate.put(PhoneNumbersHandler.getPhoneRatingField(this.currentPhoneFieldAPI), newPhoneRating);
               // set phone status modified date
               String statusModifiedDateField = PhoneNumbersHandler.getPhoneStatusModifiedDateField(this.currentPhoneFieldAPI);
               sObjToUpdate.put(statusModifiedDateField, system.now()); // set phone status modified date
               removeNumberFromAdditionalPhones(sObjToUpdate);
               this.readyToMove = true;
               moveToField_UpdateRecord (sObjToUpdate);
               if (this.isMoved == true) this.sObj = sObjToUpdate;
            } else {
               this.msgText = Label.notif_phonesList_PhoneFieldHasValue;
               this.msgText = this.msgText.replace('{0}', this.currentPhoneFieldValue);
               this.msgText = this.msgText.replace('{1}', this.phoneNumber);
               this.msgText = this.msgText.replace('{2}', this.currentPhoneFieldValue);
            }
        }
        public void cancelMoveToField () {
            this.currentPhoneFieldAPI = null;
            this.currentPhoneFieldLabel = null;
            this.currentPhoneFieldValue = null;
            this.readyToMove = false;
        }
        public void continueMoveToField() {
            sObject sObjToUpdate = queryRecord();
            // set phone number
            sObjToUpdate.put(this.currentPhoneFieldAPI, this.phoneNumber);
            // set phone status
            String newPhoneStatus = this.phoneStatus == null || this.phoneStatus == '' ? 'New' : this.phoneStatus;
            sObjToUpdate.put(PhoneNumbersHandler.getPhoneStatusField (this.currentPhoneFieldAPI), phoneStatus);
            // set phone rating
            Double newPhoneRating = PhoneNumbersHandler.rating_formatToDouble(this.phoneRating);
            sObjToUpdate.put(PhoneNumbersHandler.getPhoneRatingField(this.currentPhoneFieldAPI), newPhoneRating);
            // set phone status modified date
            String statusModifiedDateField = PhoneNumbersHandler.getPhoneStatusModifiedDateField(this.currentPhoneFieldAPI);
            sObjToUpdate.put(statusModifiedDateField, system.now());

            removeNumberFromAdditionalPhones(sObjToUpdate);
            this.readyToMove = true;
            Boolean successAddedToIrrelevant = addCurrentValueToIrrelevant(sObjToUpdate);
            if (!successAddedToIrrelevant) {
               String errMsg = Label.exception_Phones_ErrorAddToIrrelevant;
               errMsg = errMsg.replace('{0}', this.phoneNumber);
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
               system.debug('!!! error: ' + errMsg);
               cancelMoveToField ();
               return;
            }
            this.currentPhoneFieldLabel = getMap_PhoneFields_ToMoveIrrelevantItem ((Id)this.sObj.get('Id')).get(this.currentPhoneFieldAPI);
            moveToField_UpdateRecord (sObjToUpdate);
            if (this.isMoved == true) this.sObj = sObjToUpdate;
        }
        
        public void moveToField_UpdateRecord (sobject sObjToUpdate) {
            if (!this.readyToMove) return;
            Boolean successRemovedFromAdditional = updateRecord (sObjToUpdate);
            if (successRemovedFromAdditional) {
               this.msgText = Label.notif_phonesList_MovedToPhoneField;
               this.msgText = this.msgText.replace('{0}', this.phoneNumber);
               this.msgText = this.msgText.replace('{1}', this.currentPhoneFieldLabel);
               this.isMoved = true;
            } else {
                cancelMoveToField ();
            }
        }
        
        public void makeIrrelevant () {
            system.debug('>>> make irrelevant >>> ' + this.phoneNumber);
            this.makeIrrelevant = true;
            this.msgText = Label.notif_additionalPhone_MakeIrrelevantFor;
            this.msgText = this.msgText.replace('{0}', this.phoneNumber);
        }
        public void moveToIrrelevant_Record() {
            system.debug('>> moveToIrrelevant_Record >> ' + this.phoneNumber);
            this.sObj = queryRecord();
            addToIrrelevant (this.sObj, '1');
        }
        public void moveToIrrelevant_Parent() {
            system.debug('>> moveToIrrelevant_Parent >> ' + this.phoneNumber);
            Account parentAcc = (Account) queryRecord(Schema.Account.sObjectType, this.accountId);
            addToIrrelevant (parentAcc, '2');
        }
        public void moveToIrrelevant_Global() {
            system.debug('>> moveToIrrelevant_Global >> ' + this.phoneNumber);
            this.sObj = queryRecord();
            addToIrrelevant (this.sObj, '0');
        }
        
        private void removeNumberFromAdditionalPhones (sObject sObjToUpdate) {
            Map <String, String> phoneNumbersMap = new Map <String, String> (PhoneNumbersHandler.getAdditionalPhonesMap (sObjToUpdate));
            phoneNumbersMap.remove(this.phoneNumber);
            String additionalPhonesString = PhoneNumbersHandler.createAdditionalPhoneString (phoneNumbersMap.values());
            sObjToUpdate.put('Additional_Phones__c', additionalPhonesString);
        }   
        private Boolean addCurrentValueToIrrelevant (sObject sObjToUpdate) {
            Boolean res = addNewIrrelevantNumbers (sObjToUpdate, new  Map <String, String> {this.currentPhoneFieldValue => '1'}); 
            return res;
        }  
        
        private void addToIrrelevant (sObject sObjRecord, String reasonCode) {
            Savepoint sp = Database.setSavepoint();
            Boolean irrelevantPhoneAdded = addNewIrrelevantNumbers (sObjRecord, new  Map <String, String> {this.phoneNumber => reasonCode});
            if (!irrelevantPhoneAdded) return;
            removeNumberFromAdditionalPhones(this.sObj);
            // if record with irrelevant numbers list is different from the record where additional phone number was stored,
            // then save current record with updated Additional_phones__c field
            if (sObjRecord.get('Id') != this.sObj.get('Id')) { 
                updateRecord (this.sObj);
            }
            // save record with updated Irrelevant_phones__c list (and updated Additional_Phones__c field if additional phone number was stored on the same record)
            Boolean isSuccess = updateRecord (sObjRecord);
            if (isSuccess) {
                this.movedToIrrelevant = true;
                this.msgText = Label.notif_additionalPhone_PhoneFieldMovedToIrrelevant;
                this.msgText = this.msgText.replace('{0}', this.phoneNumber);
            } else {
                Database.rollback(sp);
                String errMsg = Label.exception_Phones_ErrorAddToIrrelevant;
                errMsg = errMsg.replace('{0}', this.phoneNumber);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
                system.debug('!!! error: ' + errMsg);
                return;
            }
        }
        public void editAdditionalPhone () {
            this.editView = true;
        }
        public void cancelEditAdditionalPhone () {
            this.editView = false;
            this.phoneNumber = this.phoneNumberOriginal;
        }
        public sObject queryRecord () {
            return queryRecord (this.sObj.getSObjectType(), String.valueOf(this.sObj.get('Id')));
        }
        public sObject queryRecord (Schema.sObjectType sObjectType, String recordIdToQuery) {
            return Database.query(createQuery(sObjectType, recordIdToQuery));
        }
    }
    
    public List<SelectOption> getPhoneFieldAPIs_ToMoveAdditionalPhone() {
        List<SelectOption> soList = new List<SelectOption>();
        List<Schema.FieldSetMember>  phoneFields = GlobalUtils.getFieldSetMembers (this.sObjType, 'All_Phone_Fields');
        soList.add(new SelectOption('', Label.label_None));
        for (Schema.FieldSetMember phoneField : phoneFields) {
            if (phoneField.getFieldPath() != 'Additional_Phones__c' && !phoneField.getFieldPath().contains('.')) { 
                soList.add(new SelectOption(phoneField.getFieldPath(), phoneField.getLabel()));
            }
        }
        return soList;
    }
    public void putAdditonalPhone (sObject sObjToUpdate) {
        String additionalPhonesStr = PhoneNumbersHandler.addAdditionalNumbers (sObjToUpdate, new List <String> {this.newAdditionalPhoneNumber});
        sObjToUpdate.put('Additional_Phones__c', additionalPhonesStr);
        
    }
    public void addAdditionalPhone () {
        if(!PhoneNumbersHandler.isPhoneNumberValid(this.newAdditionalPhoneNumber)) {
            String errMsg = Label.exception_Phones_PhoneIsIncorrect;
            errMsg = errMsg.replace('{0}', this.newAdditionalPhoneNumber);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            system.debug('!!! error: ' + errMsg);
            return;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            sObject sObjToUpdate = queryRecord();
            putAdditonalPhone(sObjToUpdate);
            update sObjToUpdate;
            refreshPhones();
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('!!! error: ' + e.getMessage());
            return;
        }
    }
    public void saveAdditionalPhones () {
        Savepoint sp = Database.setSavepoint();
        try {
            putAdditionalPhonesValue ();
            update this.sObj;
            refreshPhones();
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('!!! error: ' + e.getMessage());
            return;
        }
    }
    public void putAdditionalPhonesValue () {
        sObject sObjToUpdate = queryRecord();
        String additionalPhonesStr = getAdditionalPhonesValue ();
        sObjToUpdate.put('Additional_Phones__c', additionalPhonesStr);
        this.sObj = sObjToUpdate;
    }
    public String getAdditionalPhonesValue () {
        List <String> updatedAdditionalPhones = new List <String> ();
        for (AdditionalPhone phoneItem : additionalPhonesList) {
            if (!phoneItem.isMoved && !phoneItem.movedToIrrelevant) {
                String phoneModifiedDateStr = PhoneNumbersHandler.getModifiedDate_Formatted (phoneItem.phoneModifiedDate_DT);
                String additionalItemString = PhoneNumbersHandler.createAdditionalPhoneItemString (phoneItem.phoneNumber, phoneItem.phoneStatus, phoneItem.phoneRating.replace('.', ','), phoneModifiedDateStr);
                updatedAdditionalPhones.add(additionalItemString);
            }
        }
        return PhoneNumbersHandler.createAdditionalPhoneString (updatedAdditionalPhones);
    }
    private void createAdditionalPhonesList (sObject currentRecord) {
        this.additionalPhonesList = new List <AdditionalPhone> ();
        Map <String, String> phoneNumbersMap = getMapOfAdditionalPhones (currentRecord);
        if (!phoneNumbersMap.isEmpty()) {
            for (String phoneNumber : phoneNumbersMap.keySet()) {
                String additionaPhonelItem = phoneNumbersMap.get(phoneNumber);
                String phoneStatus = PhoneNumbersHandler.additionaPhonelItem_getStatus (additionaPhonelItem);
                String phoneRating = PhoneNumbersHandler.additionaPhonelItem_getRating (additionaPhonelItem);
                DateTime phoneModifiedDate = PhoneNumbersHandler.additionaPhonelItem_getModifiedDate_DateTime (additionaPhonelItem);
                this.additionalPhonesList.add(new AdditionalPhone(phoneNumber, phoneStatus, phoneRating, phoneModifiedDate, currentRecord));
            }
        }
        toViewMode_AdditionalPhones ();
    }
    private Map <String, String> getMapOfAdditionalPhones (sObject sObjRecord) {
        return PhoneNumbersHandler.getAdditionalPhonesMap (sObjRecord); // a list of Additional Phones;                             
    }
    public void putDescription (sObject sObjToUpdate) {
        String descrVal = descriptionText == null ? null 
                        : descriptionText.deleteWhiteSpace() == '' ? null
                        : descriptionText;
        sObjToUpdate.put('Description', descrVal);
    }
}