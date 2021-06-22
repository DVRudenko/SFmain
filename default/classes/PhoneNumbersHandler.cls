public without sharing class PhoneNumbersHandler {
    public class PhonesException extends Exception {}

    public static Map <String, String> fieldsTranslationsMap;
    public static Map <String, String> getMap_fieldsTranslations () {
        if (fieldsTranslationsMap == null) {
            fieldsTranslationsMap = new Map <String, String> ();
            fieldsTranslationsMap.put('Extension__c', 'Добавочный');
            List<Schema.FieldSetMember>  phoneFields = GlobalUtils.getFieldSetMembers (Schema.Contact.sObjectType, 'All_Phone_Fields');
            for (Schema.FieldSetMember phoneField : phoneFields) {
                if (phoneField.getFieldPath() != 'Additional_Phones__c' && !phoneField.getFieldPath().contains('.')) {
                    fieldsTranslationsMap.put(phoneField.getFieldPath(), phoneField.getLabel());
                }
            }
        }
        return fieldsTranslationsMap;
    }
    public static Map<String, String> getPhoneStatusesTranslations(Schema.SObjectType sobjectType) {
        Map<String, String> translations = new Map <String, String> ();
        List<Schema.PicklistEntry>  picklistEntries = GlobalUtils.getPicklistValues (sobjectType, 'Phone_Status__c');
        for( Schema.PicklistEntry picklistVal : picklistEntries) {
            translations.put(picklistVal.getValue(), picklistVal.getLabel());
        }
        return translations;
    }  
    public static String getPhoneStatusAbbreviationTranslation (String phoneStatus) {
        // if phone status is longer than 5 characters then set abbreviation for the value (used in additional phones list)
        if (phoneStatus == 'Successful dialing') {
            return 'SD';
        } else if (phoneStatus == 'SD') {
            return 'Successful dialing';
        } else if (phoneStatus.startsWith('Successful dialing:')) {
            String successStatusReasonCode = phoneStatus.split(':')[1];
            return 'SD:'+successStatusReasonCode;
        } else if (phoneStatus.startsWith('SD:')) {
            String successStatusReasonCode = phoneStatus.split(':')[1];
            return 'Successful dialing:'+successStatusReasonCode;
        } else if (phoneStatus == 'Dial out') {
            return 'DO';
        } else if (phoneStatus == 'DO') {
            return 'Dial out';
        } else if (phoneStatus == 'Needs validation') {
            return 'NV';
        } else if (phoneStatus == 'NV') {
            return 'Needs validation';
        } else if (phoneStatus == 'CTI Wrong number - Doesn\'t exist') {
            return 'CTIWN';
        } else if (phoneStatus == 'CTIWN') {
            return 'CTI Wrong number - Doesn\'t exist';
        } else if (phoneStatus == 'CTI System Error') {
            return 'CTISE';
        } else if (phoneStatus == 'CTISE') {
            return 'CTI System Error';
        } else if (phoneStatus.startsWith('Wrong number')) { 
            String irrelevantStatusReasonCode = phoneStatus.split(':')[1];
            return 'WN:'+irrelevantStatusReasonCode;
        } else if (phoneStatus.startsWith('WN')) { 
            String irrelevantStatusReasonCode = phoneStatus.split(':')[1];
            return 'Wrong number:'+irrelevantStatusReasonCode;
        } else {
            return phoneStatus;
        }
    }
    public static String profileName;
    public static String getProfileName () {
        if (profileName == null) {
            profileName = [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId()].Name;
        }
        return profileName;
    }
    public static String userRoleName;
    public static String getUserRoleName () {
        if (UserInfo.getUserRoleId() != null && userRoleName == null) {
            userRoleName  = [SELECT Id, DeveloperName FROM UserRole WHERE Id=:UserInfo.getUserRoleId()].DeveloperName;
        }
        return userRoleName;
    }

    public static Set <String> ui_Users = new Set <String> {'Russian Call Center',
                                                     'Russian Quality Control',
                                                     'Russian Sales Manager',
                                                     'Russian Team Leader'
                                                     };

    public static Set <String> russianCCSpeedUpUsers_Rolenames = new Set <String> {'PPR_Bryansk_Call_Center_Speed_Up'};

    /*******************************************************************************
    *  Name            : isExternalSource(sObject sobj)
    *  Summary         : checks if the record was created from an external source (for internal sources validation rule "valid_<phoneFieldAPI>_number" is used)
    *  Parameters      : sObject sObj - the record which wehave to check
    *  Returns         : Boolean: true - if it is created from an external source, false otherwise
    ******************************************************************************/
    public static Boolean isExternalSource (sObject sobj) {
        //Set <String> externalLeadSources = new Set <String> {'Petrolcards.ru - АГГРЕГАТОР', 'Сайт gpc-store.ru', 'Сайт Petrolplus.ru'};
        if (sobj.getSObjectType() != Schema.Lead.sObjectType) return false;
        Lead lead = (Lead) sObj;
        return LeadSourceSettings__c.getInstance(UserInfo.getUserId()).IsExternalSource__c;
    }

    /*******************************************************************************
    *  Name            : isE2E(sObject sObj)
    *  Summary         : checks if the record was created from e2e ru (there are contacts which are being created from e2e)
    *  Parameters      : sObject sObj - current record which is being processed
    *  Returns         : Boolean: true - if the record was created from e2e, false otherwise
    ******************************************************************************/
    public static Boolean isE2E (sObject sObj) {
        return isE2ERu() || isE2EBusiness (sObj);
    }
     /*******************************************************************************
    *  Name            : isE2ERu()
    *  Summary         : checks if the record was created by e2e ru user
    *  Parameters      :
    *  Returns         : Boolean: true - if the record was created from e2e business, false otherwise
    ******************************************************************************/
    public static Boolean isE2ERu () {
        return UserInfo.getUserName().startsWith('e2e_ru@fleetcoremea.force.com');
    }
    /*******************************************************************************
    *  Name            : isE2EBusiness(sObject sObj)
    *  Summary         : checks if the record was created from e2e business
    *  Parameters      : sObject sObj - current record which is being processed
    *  Returns         : Boolean: true - if the record was created from e2e business, false otherwise
    ******************************************************************************/
    public static Boolean isE2EBusiness (sObject sObj) {
        if (sObj == null) return false;
        if (sObj.getSobjectType() != Schema.Contact.sObjectType && sObj.getSobjectType() != Schema.Account.sObjectType) return false;
        return Boolean.valueOf(sObj.get('Modified_in_E2E_Business__c')) == true;
    }

    /*******************************************************************************
    *  Name            : isRussianCallCenterSpeedUp()
    *  Summary         : checks if the record was created from e2e ru (there are contacts which are being created from e2e)
    *  Parameters      :
    *  Returns         : Boolean: true - if the record was created from e2e, false otherwise
    ******************************************************************************/
    public static Boolean isRussianCallCenterSpeedUp () {
        return getUserRoleName() != null && russianCCSpeedUpUsers_Rolenames.contains(getUserRoleName());
    }

    /*******************************************************************************
    *  Name            : isUIuser()
    *  Summary         : checks if the record was modified by an ui user
    *  Parameters      :
    *  Returns         : Boolean: true - if the record was modified by an ui user, false otherwise
    ******************************************************************************/
    public static Boolean isUIuser () {
        return  ui_Users.contains(getProfileName()) && !isRussianCallCenterSpeedUp ();
    }
    public static void addUIError(String errMsg, Boolean preventDML) {
        if (Trigger.isExecuting) {
            for(sObject sObj: Trigger.new) {
                sObj.addError(errMsg, preventDML);
            }
        }
    }
    /*
        Russian Speed Up User Roles - Bryansk. These users use a single page in SF.
        1) phones, entered on the which they enter phone numbers which we count as not irrelevant
    */
    /*******************************************************************************
    *  Name            : dontPreventSaveIrrelevantPhoneNumber(sObject sObj)
    *  Summary         : checks if the user is a source fro which we don't prevent saving an irrelevant phone number
    *                   1) switch off checking if the number is irrelevant (for other users it works this way:
    *                                                           ui users - throw an exception;
    *                                                           other users - don't save a new number - leave the old value, dont throw an exception)
    *  Parameters      : sObject sObj - for which we check if we have to prevent saving an irrelevant phone number
    *  Returns         : Boolean: true - if we shouldnt prevent saving, false - otherwise
    ******************************************************************************/
    public static Boolean dontPreventSaveIrrelevantPhoneNumber (sObject sObj) {
        return isRussianCallCenterSpeedUp() || isE2E(sObj) || isExternalSource(sObj);
    }
    /*******************************************************************************
    *  Name            : dontPreventSaveDuplicatedPhoneNumber(sObject sObj)
    *  Summary         : checks if the user is a source fro which we don't prevent saving a duplicated phone number
    *                    1) switch off deduplication logic (for other users it works this way:
    *                                                           ui users - throw an exception;
    *                                                           other users - save the new number and move the old value to the duplicated field, don't throw an exception)
    *  Parameters      : sObject sObj - for which we check if we have to prevent saving a duplicate phone number
    *  Returns         : Boolean: true - if we shouldnt prevent saving, false - otherwise
    ******************************************************************************/
    public static Boolean dontPreventSaveDuplicatedPhoneNumber (sObject sObj) {
        return isE2E(sObj) || isExternalSource(sObj);
    }

// ============ PHONES PROCESSING ========================================================================================================================
/*
// !!! tmp for parsing accounts
        public static Map <Id, Set<String>> relatedContactsPhones; // for Account Obj
        public static Map <Id, String> accNames; // for Account Obj
        public static void getRelatedContactsPhones(List <sObjWrapper> sObjList) {
            system.debug('getRelatedContactsPhones ');
            if (relatedContactsPhones != null) return;
            relatedContactsPhones = new  Map <Id, Set<String>> ();
            accNames = new Map <Id, String> ();
            Set <Id> accIds = new Set <Id> ();
            for (sObjWrapper sObjWrap : sObjList) {
                Id accId = (Id) sObjWrap.sObj.get('Id');
                accIds.add(accId);
            }
            system.debug('acc ids number : ' + accIds.size());
            if (accIds.isEmpty()) return;
            List <String> fieldsToSelect =  new List <String> ();
            Set <String> phoneFieldsAPIs =  new Set <String> ();
            List<Schema.FieldSetMember>  phoneFields = GlobalUtils.getFieldSetMembers (Schema.Contact.sObjectType, 'All_Phone_Fields');
            for (Schema.FieldSetMember phoneField : phoneFields) {
                if (phoneField.getFieldPath() != 'Additional_Phones__c' && !phoneField.getFieldPath().contains('.')) {
                    //--- phone fields ---
                    String phoneFieldAPI = phoneField.getFieldPath();
                    fieldsToSelect.add(phoneFieldAPI);
                    phoneFieldsAPIs.add(phoneFieldAPI);
                }
            }
            fieldsToSelect.add('AccountId');
            String query = 'SELECT ' + String.join(fieldsToSelect, ',') + ' FROM Contact WHERE AccountId IN: accIds';
            List <sObject> consList = Database.query(query);
            if (consList != null && !consList.isEmpty()) {
                for (sObject existingCon : consList) {
                    // look for duplicates on other fields
                    String accId_existingCon = existingCon.get('AccountId') == null ? null : String.valueOf(existingCon.get('AccountId'));
                    for (String phoneFieldAPI : phoneFieldsAPIs) {
                        String phoneNum = existingCon.get(phoneFieldAPI) == null ? null : String.valueOf(existingCon.get(phoneFieldAPI));
                        if (phoneNum == null) continue;
                        phoneNum = phoneNum.trim();
                        if (!phoneNum.startsWith('+') && phoneNum.deleteWhiteSpace().length() == 10)
                            phoneNum = '+7' + phoneNum;
                        else if (phoneNum.startsWith('7') && phoneNum.deleteWhiteSpace().length() == 11)
                            phoneNum = '+' + phoneNum;

                        if (!relatedContactsPhones.containsKey(accId_existingCon)) relatedContactsPhones.put(accId_existingCon, new Set <String> ());
                        relatedContactsPhones.get(accId_existingCon).add(trimPhoneNumber (phoneNum, true));
                        String otherPhoneCodeRu = generateOtherCountryCodeRU (phoneNum);
                        if (otherPhoneCodeRu != null) relatedContactsPhones.get(accId_existingCon).add(trimPhoneNumber (otherPhoneCodeRu, true));
                    }
                }
            }
            system.debug('relatedContactsPhones : ' + relatedContactsPhones);
            String queryAccs = 'SELECT Id, Name FROM Account WHERE Id IN: accIds';
            List <sObject> accsList = Database.query(queryAccs);
            if (accsList != null && !accsList.isEmpty()) {
                for (sObject acc : accsList) {
                    accNames.put((Id) acc.get('Id'), (String)acc.get('Name'));
                }
            }
        }
// !! end of tmp for parsing accounts
*/

    public static sObjWrapper checkAccountIrrelevantPhonesAfterUpdate (Schema.SObjectType sObjType, sObject sObj, sObject oldSObj) {
        List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObjType, 'All_Phone_Fields');
        if (sObjType != Schema.Contact.sObjectType) return null;
        sObjWrapper sObjWrap;
        if (oldSObj != null && sObj.get('AccountId') != null && sObj.get('AccountId') != oldSObj.get('AccountId')) {
            sObjWrap = new PhoneNumbersHandler.sObjWrapper(sObj, oldSObj);
        }
        if (sObjWrap != null) {
            for (String phoneFieldAPI : phoneFieldsAPIs) {
                if (phoneFieldAPI != 'Additional_Phones__c') sObjWrap.addPhoneWrapper(phoneFieldAPI);
            }
        }
        return sObjWrap;
    }

    public class sObjWrapperList { // a list of sObjWrapper, which are being processed
        // list of sobjects to process phone numbers and statuses
        public List <sObjWrapper> sObjList;

        public Schema.sObjectType sObjType;
        public List<String> phoneFieldsAPIs;

        // existing irrelevant lists to chenck new phone values
        public Map<String, String> globalIrrelevant;
        public Map<Id, Map<String, String>> parentIrrelevant;
        public Map<Id, Account> parentAccounts; // account id => account

        // new global irrelevant records
        public Map <String, IrrelevantPhone__c> globalIrrelevantPhones_new;

        // irrelevant records in glbal list to delete
        public Set<String> globalIrrelevant_toDelete;

        // insert/update lists to add new irrelevant values
        public Map <Id, Account> accountsToUpdate;
        // parsing phone numbers result: new Contacts
    //    public Map<String, Contact> newContactsMap; // !!! tmp for parsing accounts

        public sObjWrapperList () {
            this.sObjList = new List <sObjWrapper> ();
            this.parentAccounts = new Map <Id, Account> ();
            this.accountsToUpdate = new Map <Id, Account> ();
    //        this.newContactsMap = new Map<String, Contact> (); // !!! tmp for parsing accounts
            this.globalIrrelevantPhones_new = new Map <String, IrrelevantPhone__c>();
            this.globalIrrelevant_toDelete = new Set <String> ();
        }
        public void addSObj (Schema.SObjectType sObjType, sObject sObj, sObject oldSObj) {
            if (this.sObjType == null) {
                this.sObjType = sObjType;
                this.phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObjType, 'All_Phone_Fields');
            }
            sObjWrapper sobjWrap = checkChangedPhonesOnRecord (sObjType, sObj, oldSObj);
            if (sobjWrap != null) sObjList.add(sObjWrap);
        }
        //checks if phone fields or phone statuses were changed. If there are changes then sObjWrapper is created for processing
        public sObjWrapper checkChangedPhonesOnRecord (Schema.SObjectType sObjType, sObject sObj, sObject oldSObj) {
            sObjWrapper sObjWrap = createSObjWrapper(sObj, oldSObj);
            return sObjWrap;
        }
        public sObjWrapper createSObjWrapper (sObject sObj, sObject oldSObj) {
            sObjWrapper sObjWrap = new sObjWrapper(sObj, oldSObj);
            Boolean arePhonesChanged = false;
            for (String phoneFieldAPI : this.phoneFieldsAPIs) {
                if (phoneFieldAPI.contains('.')) continue; // exclude parent fields
                String phoneStatusFieldAPI = getPhoneStatusField (phoneFieldAPI);
                if ((oldSObj == null && ( // -- new record
                        sObj.get(phoneFieldAPI) != null // phone number is filled
                        || (phoneStatusFieldAPI != null && sObj.get(phoneStatusFieldAPI) != null)) // phone status is filled
                    )
                    || (oldSObj != null && ( // -- updated record
                        (sObj.get(phoneFieldAPI) != oldSObj.get(phoneFieldAPI)) // phone number is changed
                        || (phoneStatusFieldAPI != null && (sObj.get(phoneStatusFieldAPI) != oldSObj.get(phoneStatusFieldAPI)))) // phone status is changed
                    )
                ) {
                    arePhonesChanged = true;
                    if (sObjWrap == null) sObjWrap = new sObjWrapper(sObj, oldSObj);
                    if (phoneFieldAPI != 'Additional_Phones__c') sObjWrap.addPhoneWrapper(phoneFieldAPI);
                }
                sObjWrap.addOldPhoneValue (phoneFieldAPI);
            }
            return arePhonesChanged ? sObjWrap : null;
        }
        public Set <String> getSetOfPhonesFormatted_NoExt () {
            Set <String> ret = new Set <String> ();
            if (this.sObjList.isEmpty()) return ret;
            for (sObjWrapper sObjWrap : this.sObjList) {
                ret.addAll(sObjWrap.getSetOfPhonesFormatted_NoExt ());
            }
            return ret;
        }
        /* not used
        public Set <String> getSetOfPhonesFormatted_WithExt () {
            Set <String> ret = new Set <String> ();
            if (this.sObjList.isEmpty()) return ret;
            for (sObjWrapper sObjWrap : this.sObjList) {
                ret.addAll(sObjWrap.getSetOfPhonesFormatted_WithExt ());
            }
            return ret;
        }
        */
        public Set <String> getSetOfAccountId () {
            Set <String> ret = new Set <String> ();
            if (this.sObjList.isEmpty()) return ret;
            for (sObjWrapper sObjWrap : this.sObjList) {
                if (sObjWrap.sObj.getsObjectTYpe() == Schema.Contact.sObjectType) {
                    if (sObjWrap.accountId != null) {
                        ret.add(sObjWrap.accountId);
                    }
                }
            }
            return ret;
        }
        public void processAfterUpdate () { // used in after update if account was changed for the contact
        // if account is changed on the contact and the new account has irrelevant phone as on the contact then remove irrelevant phone from the new account 
            if (sObjList.isEmpty()) return;
            this.parentAccounts = getParentAccounts(getSetOfAccountId ());
            this.parentIrrelevant = getIrrelevantNumbers_Parent (this.parentAccounts.values());
            for (sObjWrapper sObjWrap : sObjList) {
                // 1) check if we need to delete any irrelevant phones on the parent account
                if (!sObjWrap.phoneWrappersMap.isEmpty()) {
                    for (String phoneFieldAPI : sObjWrap.phoneWrappersMap.keySet()) {
                        PhoneWrapper phoneWrap = sObjWrap.phoneWrappersMap.get(phoneFieldAPI);
                        if (phoneWrap.phoneNumber == null) continue;
                        checkIrrelevantNumber_Parent (sObjWrap, phoneWrap.phoneNumberFormatted_NoExt);
                    }
                }
            }
            if (!this.accountsToUpdate.isEmpty()) {
                update this.accountsToUpdate.values();
            }
        }
        public void processSObjects () {  // used in before insert / update if phone numbet or phone status were changed
            if (sObjList.isEmpty()) return;
        //    Boolean isParsingAccount = this.sObjList[0].sObj.getSObjectType() == Schema.Account.sObjectType && this.sObjList[0].isExternalSource;// !!! tmp for parsing accounts
        //    if (isParsingAccount) getRelatedContactsPhones(this.sObjList); // !!! tmp for parsing accounts

            this.globalIrrelevant = getIrrelevantNumbers_Global (getSetOfPhonesFormatted_NoExt ());
            this.parentAccounts = getParentAccounts(getSetOfAccountId ());
            this.parentIrrelevant = getIrrelevantNumbers_Parent (this.parentAccounts.values());

// --------- PARSE PHONE NUMBERS AND FIND DUPLICATES ---------
            for (sObjWrapper sObjWrap : sObjList) {
                // 1) parse phones if needed
                sObjWrap.processPhoneNumbers ();
                // 2) check phone number duplicates for new values
                if (!dontPreventSaveDuplicatedPhoneNumber (sObjWrap.sobj)) { // don't check duplicates if the record was modified by certain users
                    sObjWrap.checkPhoneDuplicates();
                }
            }

// --------- PROCESS RECORDS ---------
            for (sObjWrapper sObjWrap : sObjList) {
                Boolean isPhoneNumberChangedWhileParsing = false;

// --------- PROCESS NEW PHONE NUMBERS AND STATUSES ON THE PHONE FIELDS ---------
                if (!sObjWrap.phoneWrappersMap.isEmpty()) {
                    Map <String, String> numbersAddedByUser = new  Map <String, String> (); // set of phone numbers which the user entered but they were duplicating other phone numbers

                    for (String phoneFieldAPI : sObjWrap.phoneWrappersMap.keySet()) {
                        if (sObjWrap.phoneWrappersMap.get(phoneFieldAPI).isProcessed) continue;
                        PhoneWrapper phoneWrap = sObjWrap.phoneWrappersMap.get(phoneFieldAPI);


        // ---------- PROCESS NEW PHONE NUMBERS -----------
                        if (phoneWrap.isPhoneNumberChanged() || phoneWrap.isParsed) { // Phone Number was changed by user, or was parsed in trigger so we save new phone num after parsing
                          // save phone numbers entered by user in the map
                          String enteredNumber = phoneWrap.phoneNumberFormatted_WithExt;
                          String enteredNumber_OtherCountryCodeRU = generateOtherCountryCodeRU (enteredNumber); // phone number with another ru code
                          if (!numbersAddedByUser.containsKey(enteredNumber) && !numbersAddedByUser.containsKey(enteredNumber_OtherCountryCodeRU)) {
                              if (enteredNumber != null) numbersAddedByUser.put(enteredNumber, phoneFieldAPI);
                              if (enteredNumber_OtherCountryCodeRU != null) numbersAddedByUser.put(enteredNumber_OtherCountryCodeRU, phoneFieldAPI);
                          }

                // ------ INVALID NUMBER ------
                            if (phoneWrap.phoneStatus == 'Needs validation') {
                                system.debug('set "Needs validation" phone status');
                                sObjWrap.sObj.put(phoneFieldAPI, phoneWrap.phoneNumber);
                                sObjWrap.sObj.put(phoneWrap.phoneStatusFieldAPI, phoneWrap.phoneStatus); // set phone status "Needs validation"

                                /* right now in this case we dont set rating (no rating if we set needs validation status)
                                // set phone rating
                                Boolean needToCountRating = (sObjWrap.oldsObj == null || // record created
                                                            (phoneWrap.isPhoneStatusChanged() && !phoneWrap.isPhoneRatingChanged()) // record updated, new phone status was set but new rating wasn't set while updating
                                ); 
                                if(needToCountRating){
                                    sObjWrap.sObj.put(phoneWrap.phoneRatingFieldAPI, countPhoneRating(sObjWrap.sObj, phoneWrap.phoneFieldAPI, phoneWrap.phoneStatus)); // set phone rating
                                    sObjWrap.setPhoneStatusByRating(phoneWrap);  // set phone status by rating if needed in certain cases
                                }
                                */

                                // set status modified date
                                String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
                                Boolean statusDateIsNotModified = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? true
                                        :  (DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField)) == DateTime.valueOf(sObjWrap.sObj.get(statusModifiedDateField))? true : false);
                                if(statusDateIsNotModified){
                                    sObjWrap.sObj.put(statusModifiedDateField, phoneWrap.phoneStatus == null ? null : system.now()); // set phone status modified date
                                }


                // ------ VALID NUMBER ------
                            } else {
                               Boolean changePhoneNumber = true;
                                // if the number is irrelevant then don't save it
                        // ------ IRRELEVANT NUMBER ------
                                if (isIrrelevantNumber (sObjWrap, phoneWrap.phoneNumberFormatted_NoExt)) {
                                    system.debug('Irrelevant number!!');

                                    // if the user is working with phones form then throw an exception
                                    if (isUIuser()) {
                                        String errMsg = Label.exception_phoneIsIrrelevant;
                                        errMsg = errMsg.replace('{0}', phoneWrap.phoneNumberFormatted_NoExt);
                                        addUIError(errMsg, true);
                                    }
                                    // for other users - don't save the new phone number if it is irrelevant, leave the old phone value
                                    sObjWrap.sObj.put(phoneFieldAPI, phoneWrap.oldPhoneNumber); // don't save the new phone number, leave old value
                                    sObjWrap.sObj.put(phoneWrap.phoneStatusFieldAPI, phoneWrap.oldPhoneStatus); // don't change phone status
                                    changePhoneNumber = false; // dont' save new phone number because we are leaving  the old values

                                // save phone number - if  the number is not irrelevant


                        // ------ NOT IRRELEVANT NUMBER ------
                                } else {

                                // 1) check if the new number is duplicated. If it is then save the previous number on the field dto the duplicated field

                            // ------ DUPLICATES ------
                                    if (phoneWrap.isDuplicate) {
                                        system.debug('Duplicated number!!');
                                        // if the user is working with phones form then throw an exception
                                        if (isUIuser() && !phoneWrap.isNewNumberDuplicatedOnAdditionalPhones) { // show ui users an error in case if the value was duplicated not in additional phones list
                                            String errMsg = Label.exception_phoneIsDuplicated;
                                            errMsg = errMsg.replace('{0}', phoneWrap.phoneNumberFormatted_WithExt);
                                            addUIError(errMsg, true);
                                        }
                                        // for other users (including sys admin and cc speed up users) :
                                        // : if the number is duplicated: save the previous phone number of the field in the field where the phone is duplicated
                                        system.debug('put duplicated phone: ' + phoneFieldAPI + ' : ' + phoneWrap.phoneNumber);
                                        system.debug('put duplicated status: ' + phoneWrap.phoneStatusFieldAPI+ ' : ' + phoneWrap.phoneStatus);
                                        system.debug('duplicateExistingPhoneFieldAPI: ' + phoneWrap.duplicateExistingPhoneFieldAPI);

                                        Double previousRatingValue;

                                // DUPLICATE CASE 1: duplicated on another existing field
                                        if (phoneWrap.duplicateExistingPhoneFieldAPI != null) {
                                        // phone duplicates another existing phone field

                                        // get previous phone rating
                                        String duplicateRatingFieldAPI = getPhoneRatingField (phoneWrap.duplicateExistingPhoneFieldAPI);
                                        previousRatingValue = sObjWrap.sObj.get(duplicateRatingFieldAPI) == null ? null 
                                                            : Double.valueOf(sObjWrap.sObj.get(duplicateRatingFieldAPI));
                                        system.debug('get previous rating from the previous field : ' + phoneWrap.duplicateExistingPhoneFieldAPI + ' : ' + previousRatingValue);

                                        // move previous value from the field to the duplicate field
                                            PhoneWrapper duplicatedPhoneWrap;
                                            if (sObjWrap.phoneWrappersMap.containsKey(phoneWrap.duplicateExistingPhoneFieldAPI)) {
                                                duplicatedPhoneWrap = sObjWrap.phoneWrappersMap.get(phoneWrap.duplicateExistingPhoneFieldAPI);
                                            } else {
                                                duplicatedPhoneWrap = new PhoneWrapper (sObjWrap.sObj, sObjWrap.oldSObj, phoneWrap.duplicateExistingPhoneFieldAPI, phoneWrap.oldPhoneNumber, phoneWrap.oldPhoneStatus, false);
                                                duplicatedPhoneWrap.phoneRating = phoneWrap.oldPhoneRating;
                                            }

                                            duplicatedPhoneWrap.phoneNumber =  phoneWrap.oldPhoneNumber;
                                            duplicatedPhoneWrap.phoneStatus =  phoneWrap.oldPhoneStatus;
                                            // 1)  put current phone number to the field which is duplicated
                                            sObjWrap.sObj.put(duplicatedPhoneWrap.phoneFieldAPI, duplicatedPhoneWrap.phoneNumber);
                                            // 2)  put current phone status to the field which is duplicated
                                            sObjWrap.sObj.put(duplicatedPhoneWrap.phoneStatusFieldAPI, duplicatedPhoneWrap.phoneStatus);
                                            // 3)  put current phone rating to the field which is duplicated
                                            sObjWrap.sObj.put(duplicatedPhoneWrap.phoneRatingFieldAPI, duplicatedPhoneWrap.phoneRating);
                                            // 4) move phone status modified date to the new field which is duplicated
                                            String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
                                            DateTime duplicate_oldStatusModifiedDate = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? null
                                                                           : DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField));
                                            String duplicate_statusModifiedDateField = getPhoneStatusModifiedDateField(duplicatedPhoneWrap.phoneFieldAPI);
                                            sObjWrap.sObj.put(duplicate_statusModifiedDateField, duplicate_oldStatusModifiedDate);

                                            if (sObjWrap.sObj.getSObjectType() == Schema.Lead.sObjectType
                                            && (sObjWrap.sObj.get('Phone') == null || String.valueOf(sObjWrap.sObj.get('Phone')).deleteWhiteSpace() == '')) {
                                                preventSavingEmptyLeadPhoneField();
                                            }

                                            duplicatedPhoneWrap.isProcessed = true;
                                            sObjWrap.phoneWrappersMap.put(phoneWrap.duplicateExistingPhoneFieldAPI, duplicatedPhoneWrap);

                                // DUPLICATE CASE 2: duplicated in additional phones list
                                        } else if (phoneWrap.isNewNumberDuplicatedOnAdditionalPhones) {
                                            // get previous phone rating
                                            String duplicated_additionalPhoneItem = getAdditionalPhonelItemByPhone (sObjWrap.sObj, phoneWrap.phoneNumber, true);
                                            previousRatingValue = rating_formatToDouble(additionaPhonelItem_getRating(duplicated_additionalPhoneItem));

                                            system.debug('get previous rating from additional phones list : ' + previousRatingValue);

                                           // add previous value of the field in additional phones
                                            if (phoneWrap.oldPhoneNumber != null // if there was a value in the phone field
                                            && phoneStatus_getStatus(phoneWrap.oldPhoneStatus) != 'Wrong number') { // and the status of the phone was successful\
                                                String phoneNumFormatted = trimPhoneNumber (phoneWrap.oldPhoneNumber, true);
                                                String phoneRatingStr = rating_formatToString(phoneWrap.oldPhoneRating);
                                                String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneWrap.phoneFieldAPI);
                                                DateTime duplicate_oldStatusModifiedDate = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? null
                                                                           : DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField));
                                                String phoneModifiedDate = getModifiedDate_Formatted (duplicate_oldStatusModifiedDate);
                                                String additionalPhoneItem = createAdditionalPhoneItemString (phoneNumFormatted, phoneWrap.oldPhoneStatus, phoneRatingStr, phoneModifiedDate); // add new additional  phone with an empty rating (while parsing)
                                                sObjWrap.newAdditionalPhones.put(phoneNumFormatted, additionalPhoneItem);
                                            }

                                // DUPLICATE CASE 3: phone duplicates a new value on a phone field
                                        } else {
                                            String oldPhoneNumberToCheck2 = generateOtherCountryCodeRU (phoneWrap.oldPhoneNumber); // another variation of the phone number ("+7" or "8")
                                            Boolean setOldVal = oldPhoneNumberToCheck2 != null && (trimPhoneNumber (phoneWrap.phoneNumber, true) != trimPhoneNumber (oldPhoneNumberToCheck2, true) ); // dont save an old value if it duplicates the new value but with a different ru country code
                                            if (setOldVal) {
                                                // 1) don't save the new phone number, leave an old one
                                                sObjWrap.sObj.put(phoneFieldAPI, phoneWrap.oldPhoneNumber); // don't change phone number
                                                // 2) don't save the new phone status, leave an old one
                                                sObjWrap.sObj.put(phoneWrap.phoneStatusFieldAPI, phoneWrap.oldPhoneStatus); // don't change phone status
                                                // 3) refresh data in sObjWrap.phoneWrappersMap
                                                PhoneWrapper changedPhoneWrap = new PhoneWrapper (sObjWrap.sObj, sObjWrap.oldSObj, phoneFieldAPI, phoneWrap.oldPhoneNumber, phoneWrap.oldPhoneStatus, false);
                                                sObjWrap.phoneWrappersMap.put(phoneFieldAPI, changedPhoneWrap);
                                            } else {
                                                sObjWrap.clearPhoneField (phoneWrap.phoneFieldAPI, phoneWrap.phoneStatusFieldAPI);
                                            }
                                            changePhoneNumber = false; // dont' save new phone number because we are leaving  the old values
                                        }
                                        phoneWrap.oldPhoneRating = previousRatingValue;
                                        phoneWrap.phoneRating = phoneWrap.oldPhoneRating;
                                    } // ----- END DUPLICATES -----

                                } // ------ END NOT IRRELEVANT NUMBER ------
                                
                                if (changePhoneNumber) {
                                 // 2) if the phone number was changed and phone status is Irrelevant then set "New" status
                                    if (isUIuser() && phoneWrap.phoneStatus != null) {
                                        String newPhoneStatus = phoneStatus_getStatus(phoneWrap.phoneStatus);
                                        if (newPhoneStatus == 'Wrong number') {
                                            // if phone status was sewt as 'Wrong number' but phone number value was changed then change status value to 'New'
                                            phoneWrap.phoneStatus = 'New'; // reset phone status
                                        }
                                    }
                                // 3) put phone values and phone status value and modified date
                                    system.debug('put phone: ' + phoneFieldAPI + ' : ' + phoneWrap.phoneNumber);
                                    system.debug('put status: ' + phoneWrap.phoneStatusFieldAPI+ ' : ' + phoneWrap.phoneStatus);
                                    // number is not irrelevant: add phone values to fields
                                    sObjWrap.sObj.put(phoneFieldAPI, phoneWrap.phoneNumber); // save new phone number
                                    sObjWrap.sObj.put(phoneWrap.phoneStatusFieldAPI, phoneWrap.phoneStatus); // set phone status

                                    // set status modified date
                                    String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
                                    Boolean statusDateIsNotModified = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? true
                                            :  (DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField)) == DateTime.valueOf(sObjWrap.sObj.get(statusModifiedDateField))? true : false);
                                    if(statusDateIsNotModified){
                                        sObjWrap.sObj.put(statusModifiedDateField, phoneWrap.phoneStatus == null ? null : system.now()); // set phone status modified date
                                    }
                                    if (phoneWrap.phoneStatus == null) sObjWrap.sObj.put(phoneWrap.phoneRatingFieldAPI, null); // set phone status
                                }
                           } // ------ END VALID NUMBER ------

                           if(phoneWrap.isParsed) { // if phone number was changed while parsing then send the new value to personal data db.
                                isPhoneNumberChangedWhileParsing = true;
                           }

                        } // ---------- END PROCESS NEW PHONE NUMBERS -----------

 // ---------- PROCESS NEW PHONE STATUSES -----------
                        if (phoneWrap.isPhoneStatusChanged() || phoneWrap.isParsed) {
                            processPhoneStatus_WrongNumber (sObjWrap, phoneWrap);

                            // set status modified date
                            String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
                            Boolean statusDateIsNotModified = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? true
                                    :  (DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField)) == DateTime.valueOf(sObjWrap.sObj.get(statusModifiedDateField))? true : false);
                            if(statusDateIsNotModified){
                                sObjWrap.sObj.put(statusModifiedDateField, phoneWrap.phoneStatus == null ? null : system.now()); // set phone status modified date
                            }
                        } // ---------- END PROCESS NEW PHONE STATUSES -----------
                        String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
                        Boolean statusDateUpdated = sObjWrap.sObj.get(statusModifiedDateField) == null ? false
                                    :  (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? true
                                    :  (DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField)) != DateTime.valueOf(sObjWrap.sObj.get(statusModifiedDateField))? true : false);
                        Boolean needToCountRatingForChangedStatus = (
                            statusDateUpdated // phone status modified date is changed which means we need to count phone rating
                            && !phoneWrap.isPhoneRatingChanged() // we don't need to count rating if its value was set before updating
                            && !(phoneWrap.isPhoneNumberChanged() && !phoneWrap.isPhoneStatusChanged()) // we don't need to count rating if we changed phone number value 
                        );
                        Boolean needToCountRating = (
                            sObjWrap.oldsObj == null // record created - need to count rating
                            || (sObjWrap.oldsObj != null // record updated
                                && (needToCountRatingForChangedStatus // count rating if status was changed for the phone field
                                    || phoneWrap.isDuplicate  // count rating if phone number is changed to the duplicated 
                                )
                            )
                        );
                        phoneWrap = sObjWrap.phoneWrappersMap.get(phoneFieldAPI);
                        if (!phoneWrap.isMovedFromAnotherField && needToCountRating) {
                                system.debug('put phone rating 1');
                                Double newPhoneRating = phoneWrap.isDuplicate ? getNewPhoneRatingVal (phoneWrap.phoneRating, phoneWrap.phoneStatus)
                                                      : countPhoneRating(sObjWrap.sObj, phoneWrap.phoneFieldAPI, phoneWrap.phoneStatus);
                                sObjWrap.sObj.put(phoneWrap.phoneRatingFieldAPI, newPhoneRating); // set phone rating
                                sObjWrap.setPhoneStatusByRating(phoneWrap);  // set phone status by rating if needed in certain cases 
                                processPhoneStatus_WrongNumber (sObjWrap, phoneWrap);
                        } else {
                            if (sObjWrap.sObj.get(phoneWrap.phoneFieldAPI) != null) {
                                system.debug('put phone rating 2 : ' + phoneWrap.phoneRating);
                                sObjWrap.sObj.put(phoneWrap.phoneRatingFieldAPI, phoneWrap.phoneRating); // set phone rating
                            }
                        }

                    } // --------- END PROCESS NEW PHONE NUMBERS AND STATUSES ON THE PHONE FIELDS ---------

// --------- CHECK DUPLICATES IN THE FINAl LIST ---------
                    if (!isUIuser() && !dontPreventSaveDuplicatedPhoneNumber (sObjWrap.sObj)) {
                        checkDuplicatesInTheFinalSObj (sObjWrap, numbersAddedByUser);
                    } // --------- END CHECK DUPLICATES IN THE FINAl LIST ---------
                }


// --------- PROCESS ADDITIONAL PHONES ---------
                if (sObjWrap.sObj.getSObjectType() != Schema.Account.sObjectType) {
                    // put additional phones value in text area field
                    String additionalPhonesStr = processAdditionalPhones (sObjWrap);
                    sObjWrap.sObj.put('Additional_Phones__c', additionalPhonesStr); // add new values to additional phones
                    addAdditionalNumbersToPhoneFields(sObjWrap.sObj);
                }
/*
// !!! tmp for parsing accounts
// --------- ADD NEW CONTACTS TO THE LIST ---------
                if(!sObjWrap.newContactsMap.isEmpty()) this.newContactsMap.putAll(sObjWrap.newContactsMap); // !!! tmp for parsing accounts
// !!! end of tmp for parsing accounts
*/

// --------- SEND DATA TO PD iF CHANGED IN THE TRIGGER ---------
                if (isPhoneNumberChangedWhileParsing || sObjWrap.isPDDataChanged(this.phoneFieldsAPIs)) {
                    PD_Callouts.sendReq_saveData(sObjWrap.sObj);
                }
            } // --------- END PROCESS RECORDS ---------

// --------- SAVE PARENT ACCOUNTS ---------
            if (!this.accountsToUpdate.isEmpty()) {
                try {
                    update this.accountsToUpdate.values();
                } catch (DmlException  e) {
                    String accUpdateErrorMsg = e.getDmlMessage(0);
                    throw new PhonesException (Label.exception_cantUpdateAccount + ' ' + accUpdateErrorMsg);
                }
            }
/*
// !!! tmp for parsing accounts
// --------- SAVE NEW CONTACTS ---------
            if (!this.newContactsMap.isEmpty()) {
                insert this.newContactsMap.values();
            }
// !!! end of tmp for parsing accounts
*/

// --------- SAVE GLOBAL IRRELEVANT PHONES ---------
            if (!this.globalIrrelevantPhones_new.isEmpty()) {
                upsert this.globalIrrelevantPhones_new.values() Phone_NoExtension__c;
            }
// --------- DELETE GLOBAL IRRELEVANT PHONES ---------
            if (!this.globalIrrelevant_toDelete.isEmpty()) {
                List <IrrelevantPhone__c> irrelevantPhoneRecords_toDelete = [SELECT Id FROM IrrelevantPhone__c WHERE Phone_NoExtension__c IN: globalIrrelevant_toDelete];
                if (!irrelevantPhoneRecords_toDelete.isEmpty()) delete irrelevantPhoneRecords_toDelete;
            }
        }

    // process phones saved in Additional_Phones__c field on the record (Lead or Contact)
        public String processAdditionalPhones (sObjWrapper sObjWrap) {
            if (sObjWrap.newAdditionalPhones.isEmpty()) return null; // there are no new additional phones
            system.debug('||| sObjWrap.newAdditionalPhones : ' + sObjWrap.newAdditionalPhones);
            for (String newAdditionalPhone : sObjWrap.newAdditionalPhones.keySet()) {
            // check if number is irrelevant
                if (isIrrelevantNumber (sObjWrap, newAdditionalPhone)) { //number is irrelevant : don't save the number
                    system.debug('Irrelevant number!!');
                    // for ui users: if the user is working with phones form then throw an exception
                    if (isUIuser()) {
                        String errMsg = Label.exception_phoneIsIrrelevant;
                        errMsg = errMsg.replace('{0}', newAdditionalPhone);
                        addUIError(errMsg, true);
                    }
                    // for other users: don't save a new value if it is irrelevant
                    sObjWrap.newAdditionalPhones.remove(newAdditionalPhone); // don't save new phone number, leave old value
                }
            }
            // add new values to existing list of additional phones
            Map <String, String> finalAdditionalPhonesMap = new Map <String, String> ();
            if (!sObjWrap.newAdditionalPhones.isEmpty()) {
                for (String newAdditionalPhone : sObjWrap.newAdditionalPhones.keySet()) {
                    if (!isIrrelevantNumber (sObjWrap, newAdditionalPhone)) { // don't save a number if it is irrelevant
                        finalAdditionalPhonesMap.put(newAdditionalPhone, sObjWrap.newAdditionalPhones.get(newAdditionalPhone));
                    }
                }
            }
            sObjWrap.newAdditionalPhones = finalAdditionalPhonesMap;
            return createAdditionalPhoneString (sObjWrap.newAdditionalPhones.values());
        }

        public void processPhoneStatus_WrongNumber (sObjWrapper sObjWrap, PhoneWrapper phoneWrap) {
            system.debug('>>in>> processPhoneStatus_WrongNumber : ' + phoneWrap.phoneStatusFieldAPI + ' : ' + phoneWrap.phoneStatus);
            Set <String> globalCodesSet = new Set <String> {'0'}; // code reasons for global irrelevant list
            Set <String> recordCodesSet = new Set <String> {'1','3d','4d'}; // code reasons for irrelevant list on record (Irrelevant_Phones__c)
            Set <String> parentCodesSet = new Set <String> {'2'}; // code reasons for irrelevant list on a parent record (Account.Irrelevant_Phones__c)

            // remove old irrelevant values if needed
            if (phoneWrap.phoneFieldAPI == 'Phone' && phoneWrap.oldPhoneStatus != null && phoneWrap.oldPhoneStatus != phoneWrap.phoneStatus) {
                String oldStatus = phoneStatus_getStatus(phoneWrap.oldPhoneStatus);
                if (oldStatus == 'Wrong number') {
                    String oldStatusReason = phoneStatus_getReasonCode(phoneWrap.oldPhoneStatus);
                    if (globalCodesSet.contains(oldStatusReason)) {
                        removePhoneFromIrrelevant_Global (phoneWrap.phoneNumberFormatted_NoExt);
                    } else if (recordCodesSet.contains(oldStatusReason)) {
                        removePhoneFromIrrelevant_Record (sObjWrap, phoneWrap.phoneNumberFormatted_WithExt);
                    } else if (parentCodesSet.contains(oldStatusReason)) {
                        removePhoneFromIrrelevant_Parent (sObjWrap, phoneWrap.phoneNumberFormatted_WithExt);
                    }
                }
            }

            // add irrelevant phone numbers depending on the status reason value
            if (phoneWrap.phoneStatus == null) return;
            String newStatus = phoneStatus_getStatus(phoneWrap.phoneStatus);
            if (newStatus == 'Wrong number') { // if new status is wrong number then set phone value as irrelevant
                String newStatusReason = phoneStatus_getReasonCode(phoneWrap.phoneStatus);
                // add irrelevant phone numbers depending on the status reason value
                if (parentCodesSet.contains(newStatusReason)) { // save on parent account
                    system.debug('add irrelevant number to parent ');
                    Account acc = this.accountsToUpdate.containsKey(sObjWrap.accountId) ? this.accountsToUpdate.get(sObjWrap.accountId) : this.parentAccounts.get(sObjWrap.accountId);
                    addIrrelevantNumber_onRecord (acc, new Map <String, String> {phoneWrap.phoneNumberFormatted_WithExt => createIrrelevantItemString(phoneWrap.phoneNumberFormatted_WithExt, newStatusReason)});
                    this.accountsToUpdate.put(acc.Id, acc);
                } else if (recordCodesSet.contains(newStatusReason)) {
                    system.debug('add irrelevant number to the record ');
                    addIrrelevantNumber_onRecord (sObjWrap.sObj, new Map <String, String> {phoneWrap.phoneNumberFormatted_WithExt => createIrrelevantItemString(phoneWrap.phoneNumberFormatted_WithExt, newStatusReason)});
                } else if (globalCodesSet.contains(newStatusReason)) {
                    this.globalIrrelevantPhones_new.put(phoneWrap.phoneNumberFormatted_WithExt,
                                        new IrrelevantPhone__c (Phone__c = phoneWrap.phoneNumberFormatted_WithExt,
                                        Phone_NoExtension__c = phoneWrap.phoneNumberFormatted_NoExt,
                                        StatusReason__c = newStatusReason,
                                        sObjectId__c = String.valueOf(sObjWrap.sObj.get('Id'))));
                }
                Boolean leavePhoneNumberOnTheField = false;
                if (phoneWrap.phoneFieldAPI == 'Phone') { // we can't remove phone number if it is the last number
                    // if there are other phone numbers on the record then set it to the "Phone" field
                    PhoneWrapper newPhoneWrap;
                    DateTime modifiedDateOnOtherPhoneField;
                    for (String otherPhoneFieldAPI : GlobalUtils.getFieldSetMembersAPIs(sObjWrap.sObj.getSObjectType(), 'All_Phone_Fields')) {
                        if (otherPhoneFieldAPI.contains('.') || otherPhoneFieldAPI == 'Additional_Phones__c') continue;
                        if (otherPhoneFieldAPI == phoneWrap.phoneFieldAPI) continue;
                        // check if number is not blank
                        PhoneWrapper otherPhoneWrap = sObjWrap.phoneWrappersMap.containsKey(otherPhoneFieldAPI) ? sObjWrap.phoneWrappersMap.get(otherPhoneFieldAPI) : null;

                        if (otherPhoneWrap != null && otherPhoneWrap.phoneStatus != null &&  otherPhoneWrap.phoneStatus.startsWith('Wrong number')) {
                            // we can't move this number to 'Phone' field because it's an irrelevant number
                            continue;
                        }
                        String numberOnOtherField = otherPhoneWrap != null ? otherPhoneWrap.phoneNumber // one of edited fields
                                                    : sObjWrap.sObj.get(otherPhoneFieldAPI) != null ? String.valueOf(sObjWrap.sObj.get(otherPhoneFieldAPI))
                                                    : null;

                        if (numberOnOtherField != null) {
                            String otherFieldStatusAPI = getPhoneStatusField(otherPhoneFieldAPI);
                            String otherFieldRatingAPI = getPhoneRatingField(otherPhoneFieldAPI);
                            String statusOnOtherField = otherPhoneWrap != null ? otherPhoneWrap.phoneStatus
                                                        : sObjWrap.sObj.get(otherFieldStatusAPI) != null ? String.valueOf(sObjWrap.sObj.get(otherFieldStatusAPI))
                                                        : null;

                            // set phone rating
                            Double ratingOnOtherField;
                            if (otherPhoneWrap != null) {
                                String statusModifiedDateField = getPhoneStatusModifiedDateField(otherPhoneWrap.phoneFieldAPI);
                                Boolean statusDateUpdated = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(statusModifiedDateField) == null) ? true
                                            :  (DateTime.valueOf(sObjWrap.oldsObj.get(statusModifiedDateField)) != DateTime.valueOf(sObjWrap.sObj.get(statusModifiedDateField))? true : false);
                                Boolean needToCountRating = (
                                        sObjWrap.oldsObj == null // record created - need to count rating
                                    ||  (sObjWrap.oldsObj != null // record updated
                                            && (!otherPhoneWrap.isPhoneRatingChanged() // status modified date is updated
                                                && statusDateUpdated // phone status modified date is changed
                                                )
                                            )
                                );
                                if (needToCountRating) { // record updated, new phone status was set but new rating wasn't set while updating
                                    ratingOnOtherField = countPhoneRating(sObjWrap.sObj, otherPhoneWrap.phoneFieldAPI, otherPhoneWrap.phoneStatus);
                                } else {
                                    ratingOnOtherField = otherPhoneWrap.phoneRating;
                                }
                            }
                            ratingOnOtherField = otherPhoneWrap != null ? ratingOnOtherField
                                                        : sObjWrap.sObj.get(otherFieldRatingAPI) != null ? Double.valueOf(sObjWrap.sObj.get(otherFieldRatingAPI))
                                                        : null;
                            newPhoneWrap = new PhoneWrapper (sObjWrap.sObj, sObjWrap.oldSObj, phoneWrap.phoneFieldAPI, numberOnOtherField, statusOnOtherField, false);
                            newPhoneWrap.phoneRating = ratingOnOtherField; // rating frrom the other field whic we are moving to the 'Phone' field
                            newPhoneWrap.isMovedFromAnotherField = true;
                            // save modified phone date val
                            modifiedDateOnOtherPhoneField = sObjWrap.sObj.get(getPhoneStatusModifiedDateField(otherPhoneFieldAPI)) == null ? null
                                                         : DateTime.valueOf(sObjWrap.sObj.get(getPhoneStatusModifiedDateField(otherPhoneFieldAPI)));

                            if (otherPhoneWrap != null) { // !!!!! (remove all phonewrap from the map?)
                                otherPhoneWrap.phoneNumber = null;
                                otherPhoneWrap.phoneStatus = null;
                                otherPhoneWrap.phoneRating = null;
                                sObjWrap.phoneWrappersMap.put(otherPhoneFieldAPI, otherPhoneWrap);
                            }
                            sObjWrap.clearPhoneField (otherPhoneFieldAPI, otherFieldStatusAPI);
                            break;
                        }
                    }
                    if (newPhoneWrap != null) { // replace 'Phone' value with another one (from another Phone field on the record or from additional phones)
                        sObjWrap.phoneWrappersMap.put(phoneWrap.phoneFieldAPI, newPhoneWrap);
                        sObjWrap.sObj.put(phoneWrap.phoneFieldAPI, newPhoneWrap.phoneNumber);
                        sObjWrap.sObj.put(phoneWrap.phoneStatusFieldAPI, newPhoneWrap.phoneStatus); // set status to 'Phone' field from another field 
                        sObjWrap.sObj.put(phoneWrap.phoneRatingFieldAPI, newPhoneWrap.phoneRating); // set rating to 'Phone' field from another field
                        
                        // set status modified date
                        DateTime newPhoneModifiedDateVal = newPhoneWrap.phoneStatus == null ? null 
                                                            : modifiedDateOnOtherPhoneField == null ? system.now() 
                                                            : modifiedDateOnOtherPhoneField;
                        sObjWrap.sObj.put(getPhoneStatusModifiedDateField(phoneWrap.phoneFieldAPI), newPhoneModifiedDateVal); // set phone status modified date to Phone field from another field

                        leavePhoneNumberOnTheField = true; // leave phone number if another phone number found on another field
                    } else {
                        // only for lead records: phone is a required field on a record
                        //if there are no other phone numbers on the record then - just save modifieddate, leave 'Phone' field with status 'Wrong number'
                        if (sObjWrap.sObj.getSObjectType() == Schema.Lead.sObjectType) {

                            // set rating
                            sObjWrap.sObj.put(phoneWrap.phoneRatingFieldAPI, 0); // set phone rating = 0 for Irrelevant number.

                            // set status modified date
                            Boolean statusDateIsNotModified = (sObjWrap.oldsObj == null || sObjWrap.oldsObj.get(getPhoneStatusModifiedDateField(phoneWrap.phoneFieldAPI)) == null) ? true
                                    :  (DateTime.valueOf(sObjWrap.oldsObj.get(getPhoneStatusModifiedDateField(phoneWrap.phoneFieldAPI))) == DateTime.valueOf(sObjWrap.sObj.get(getPhoneStatusModifiedDateField(phoneWrap.phoneFieldAPI)))? true : false);
                            if(statusDateIsNotModified){
                                sObjWrap.sObj.put(getPhoneStatusModifiedDateField(phoneWrap.phoneFieldAPI), system.now()); // set phone status modified date null
                            }
                            leavePhoneNumberOnTheField = true; // leave phone number if it is the last number on a lead record
                        }
                    }
                }
                if (!leavePhoneNumberOnTheField) {
                    // remove irrelevant numbers from the record
                    sObjWrap.clearPhoneField (phoneWrap.phoneFieldAPI, phoneWrap.phoneStatusFieldAPI);
                }
            }
        }
        public void checkDuplicatesInTheFinalSObj (sObjWrapper sObjWrap, Map <String, String> numbersAddedByUser) {
            Set <String> finalListOfPhones = new Set <String> ();
            for (String phoneFieldAPI : sObjWrap.phoneWrappersMap.keySet()) {
                removeDuplicatesInFinalFieldValues (finalListOfPhones, numbersAddedByUser, sObjWrap, phoneFieldAPI);  // remove duplicates from fields
            }
            for (String phoneNum : finalListOfPhones) {
                sObjWrap.newAdditionalPhones.remove(phoneNum); // remove duplicates from additional phones
            }
        }
        // remove duplicates in the final values of phones
        public void removeDuplicatesInFinalFieldValues (Set <String> finalListOfPhones, Map <String, String> numbersAddedByUser, sObjWrapper sObjWrap, String phoneFieldAPI) {
            Boolean savePhoneNumbers = false;
            PhoneWrapper phoneWrap = sObjWrap.phoneWrappersMap.get(phoneFieldAPI);
            String phoneNumber = phoneWrap.phoneNumberFormatted_WithExt;
            String phoneNumber_OtherCountryCodeRU = generateOtherCountryCodeRU (phoneNumber); // phone number with another ru code
            if (numbersAddedByUser.containsKey(phoneNumber) || numbersAddedByUser.containsKey(phoneNumber_OtherCountryCodeRU) ) {
                // clear duplicated phone field which we got after processing
                String addedByUser_phoneFieldAPI = numbersAddedByUser.containsKey(phoneNumber) ? numbersAddedByUser.get(phoneNumber)
                                        : numbersAddedByUser.containsKey(phoneNumber_OtherCountryCodeRU) ? numbersAddedByUser.get(phoneNumber_OtherCountryCodeRU)
                                        : null;
                if (addedByUser_phoneFieldAPI == phoneFieldAPI) {
                    savePhoneNumbers = true;
                } else {
                    if (finalListOfPhones.contains(phoneNumber) || finalListOfPhones.contains(phoneNumber_OtherCountryCodeRU)) {
                        system.debug('remove value: ' + phoneFieldAPI + ' duplicated number found with number ' + addedByUser_phoneFieldAPI + ' entered by user : ' + phoneNumber);
                        sObjWrap.clearPhoneField (phoneFieldAPI, phoneWrap.phoneStatusFieldAPI);
                    }
                }
            } else {
                if (finalListOfPhones.contains(phoneNumber) || finalListOfPhones.contains(phoneNumber_OtherCountryCodeRU)) {
                    // clear duplicated phone field which we got after processing
                    system.debug('remove value: ' + phoneFieldAPI + ' duplicated number found with number changed in the handler : ' + phoneNumber);
                    sObjWrap.clearPhoneField (phoneFieldAPI, phoneWrap.phoneStatusFieldAPI);
                } else {
                    savePhoneNumbers = true;
                }
            }
            if (savePhoneNumbers) {
                if (phoneNumber != null) finalListOfPhones.add(phoneNumber);
                if (phoneNumber_OtherCountryCodeRU != null) finalListOfPhones.add(phoneNumber_OtherCountryCodeRU);
            }
        }

        // check if number is irrelevant in one of the lists: on the record (Irrelevant_Phones__c field), on the parent Account (Account.Irrelevant_Phones__c) or global list - IrrelevantPhone__c sObject
        public Boolean isIrrelevantNumber (sObjWrapper sObjWrap, String phoneNumber) {
            if (phoneNumber == null) return false;
            // 1) check irrelevant phones on record
            Boolean irrelevantRecord = checkIrrelevantNumber_Record (sObjWrap, phoneNumber);
            if (irrelevantRecord == true) return true;
            // 2) if there is a parent list of irrelevant phones - check it
            Boolean irrelevantParent = checkIrrelevantNumber_Parent (sObjWrap, phoneNumber);
            if (irrelevantParent == true) return true;
            // 3) check global list of irrelevant phones
           Boolean irrelevantGlobal =  checkIrrelevantNumber_Global (sObjWrap, phoneNumber);
           if (irrelevantGlobal == true) return true;

            return false;
        }
        public Boolean checkIrrelevantNumber_Record (sObjWrapper sObjWrap, String phoneNumber) {
            if (phoneNumber == null) return false;
            String phoneNumber_OtherCountryCodeRU = generateOtherCountryCodeRU (phoneNumber);
            if (sObjWrap.irrelevantNumbers.containsKey(phoneNumber)) {
                Boolean isIrrelevant = isNumberIrrelevant_Record (sObjWrap, phoneNumber);
                if (isIrrelevant) return true;
            }
            else if (phoneNumber_OtherCountryCodeRU != null && sObjWrap.irrelevantNumbers.containsKey(phoneNumber_OtherCountryCodeRU)) {
                Boolean isIrrelevant = isNumberIrrelevant_Record (sObjWrap, phoneNumber_OtherCountryCodeRU);
                if (isIrrelevant) return true;
            }
            return false;
        }
        public Boolean checkIrrelevantNumber_Parent (sObjWrapper sObjWrap, String phoneNumber) {
            if (phoneNumber == null) return false;
            String phoneNumber_OtherCountryCodeRU = generateOtherCountryCodeRU (phoneNumber);
            if (sObjWrap.sObj.getSObjectType() == Schema.Contact.sObjectType) {
                if (this.parentIrrelevant.containsKey(sObjWrap.accountId)) { // if there is a parent account - check it
                    if(this.parentIrrelevant.get(sObjWrap.accountId).containsKey(phoneNumber)) {
                        Boolean isIrrelevant = isNumberIrrelevant_Parent (sObjWrap, phoneNumber);
                        if (isIrrelevant) return true;
                    }
                    else if(phoneNumber_OtherCountryCodeRU != null && this.parentIrrelevant.get(sObjWrap.accountId).containsKey(phoneNumber_OtherCountryCodeRU)) {
                        Boolean isIrrelevant = isNumberIrrelevant_Parent (sObjWrap, phoneNumber_OtherCountryCodeRU);
                        if (isIrrelevant) return true;
                    }
                }
            }
            return false;
        }
        public Boolean checkIrrelevantNumber_Global (sObjWrapper sObjWrap, String phoneNumber) {
            if (phoneNumber == null) return false;
            String phoneNumber_OtherCountryCodeRU = generateOtherCountryCodeRU (phoneNumber);
            if (this.globalIrrelevant.containsKey(phoneNumber)) {
                Boolean isIrrelevant = isNumberIrrelevant_Global (sObjWrap, phoneNumber);
                if (isIrrelevant) return true;
            }
            else if (phoneNumber_OtherCountryCodeRU != null && this.globalIrrelevant.containsKey(phoneNumber_OtherCountryCodeRU)) {
                Boolean isIrrelevant = isNumberIrrelevant_Global (sObjWrap, phoneNumber_OtherCountryCodeRU);
               if (isIrrelevant) return true;
            }
            return false;
        }
        public Boolean isNumberIrrelevant_Record (sObjWrapper sObjWrap, String phoneNumber) {
            // check if number is irrelevant on current record
            if (dontPreventSaveIrrelevantPhoneNumber (sObjWrap.sobj)) { // don't prevent saving the phone number if the record was modified by certain users
                system.debug('Phone is irrelevant. Remove phone from the irrelevant list on the current record: ' + phoneNumber);
                removePhoneFromIrrelevant_Record (sObjWrap, phoneNumber);
                return false;
            } else { // process as an irrelevant phone number
                return true;
            }
        }
        public Boolean isNumberIrrelevant_Parent (sObjWrapper sObjWrap, String phoneNumber) {
            // check if number is irrelevant on a parent account
            if (dontPreventSaveIrrelevantPhoneNumber (sObjWrap.sobj)  // don't prevent saving the phone number if the record was modified by certain users;
            || sObjWrap.isParentAccountChanged () ) { // if contact was moved to another account then remove contact phones from irrelevant phones on the parent account (initially this logic was added for e2e)
                system.debug('Phone is irrelevant. Remove phone from the irrelevant list on the parent record: ' + phoneNumber);
                removePhoneFromIrrelevant_Parent (sObjWrap, phoneNumber);
                return false;
            } else { // process as an irrelevant phone number
                return true;
            }
        }
        public Boolean isNumberIrrelevant_Global (sObjWrapper sObjWrap, String phoneNumber) {
            if (dontPreventSaveIrrelevantPhoneNumber (sObjWrap.sobj)) { // don't prevent saving the phone number if the record was modified by certain users
                system.debug('Phone is irrelevant. Remove phone from the irrelevant list on the global list: ' + phoneNumber);
                removePhoneFromIrrelevant_Global (phoneNumber);
                return false;
            } else { // process as an irrelevant phone number
                return true;
            }
        }

        public void removePhoneFromIrrelevant_Record (sObjWrapper sObjWrap, String phoneNumber) {
            // remove on sObject
            removeIrrelevantNumber_fromRecord (sObjWrap.sobj, phoneNumber);
            // remove from current sObjWrapper
            sObjWrap.irrelevantNumbers.remove(phoneNumber);
        }
        public void removePhoneFromIrrelevant_Parent (sObjWrapper sObjWrap, String phoneNumber) {
            // remove on parent account
            Account acc = this.accountsToUpdate.containsKey(sObjWrap.accountId) ? this.accountsToUpdate.get(sObjWrap.accountId) : this.parentAccounts.get(sObjWrap.accountId);
            removeIrrelevantNumber_fromRecord(acc, phoneNumber);
            this.accountsToUpdate.put(acc.Id, acc);
            // remove from current sObjWrapperList
            this.parentIrrelevant.get(sObjWrap.accountId).remove(phoneNumber);
        }
        public void removePhoneFromIrrelevant_Global (String phoneNumber) {
            // remove on global list of irrelevant phones
            this.globalIrrelevant_toDelete.add(phoneNumber);
            // remove from current sObjWrapperList
            this.globalIrrelevant.remove(phoneNumber);
        }
    }
    public class sObjWrapper { // a wrapper of the record which is being processed, its phones, phone statuses etc
        public sObject sObj;
        public sObject oldSObj;
        public String accountId;
        public Map <String, PhoneWrapper> phoneWrappersMap; // phone field API => PhoneWraper.class
        public Set <String> oldPhoneValuesSet;

        public Map <String, String> irrelevantNumbers;
        public Map <String, String> irrelevantNumbersModifiedTime;
        public Boolean isExternalSource; // if the source is external then parse phone numbers
        public Map <String, String> oldAdditionalPhones;
        public Map <String, String> existingAdditionalPhones;
        public Map <String, String> newAdditionalPhones;
       // public Map<String, Contact> newContactsMap; // !!! tmp for parsing accounts : parsing phone numbers result

        public sObjWrapper (sObject sObj, sObject oldSObj) {
            this.sObj = sObj;
            this.oldSObj = oldSObj;
            this.accountId = sObj.getSObjectType() != Schema.Contact.sObjectType || sObj.get('AccountId') == null ? null
                           : String.valueOf(sObj.get('AccountId'));
            this.phoneWrappersMap = new Map <String, PhoneWrapper> ();
            this.oldPhoneValuesSet = new Set <String> ();
            this.irrelevantNumbers = getIrrelevantNumbers_Record ();
            this.irrelevantNumbersModifiedTime = getIrrelevantStatusesModifiedItems (sObj);
            this.isExternalSource = isExternalSource (sObj);
           // this.newContactsMap = new Map <String, Contact> (); // !!! tmp for parsing accounts
            this.oldAdditionalPhones = oldSobj == null ? new Map <String, String> ()
                                          : oldSobj.getsObjectType() == Schema.Account.sObjectType ? new Map <String, String> ()
                                          : getAdditionalPhonesMap (oldSobj); // a set of Additional Phones
            this.existingAdditionalPhones = sobj.getsObjectType() == Schema.Account.sObjectType ? new Map <String, String> ()
                                          : getAdditionalPhonesMap (sObj); // a set of Additional Phones
            this.newAdditionalPhones = new Map <String, String> (existingAdditionalPhones);
        }
        public void addPhoneWrapper (String phoneFieldAPI) {
            this.phoneWrappersMap.put(phoneFieldAPI, new PhoneWrapper (sObj, oldSObj, phoneFieldAPI));
        }
        public void addOldPhoneValue (String phoneFieldAPI) {
            if (phoneFieldAPI == 'Additional_Phones__c') {
                addUnifiedAdditionalPhones(this.oldPhoneValuesSet, oldsObj);
            } else {
                String oldPhoneVal = (oldsObj == null || oldsObj.get(phoneFieldAPI) == null) ? null : String.valueOf(oldsObj.get(phoneFieldAPI));
                if (oldPhoneVal != null) this.oldPhoneValuesSet.add(getUnifiedRuNumber (oldPhoneVal));
            }
        }
        public Set <String> getNewPhoneValuesSet (List<String>  phoneFields) {
            Set <String> newPhoneValuesSet = new Set <String> ();
            for (String fieldApi : phoneFields) {
                if (fieldApi == 'Additional_Phones__c'){
                    addUnifiedAdditionalPhones(newPhoneValuesSet, sObj);
                } else {
                    String fieldValue = sObj.get(fieldApi) == null ? null : String.valueOf(sObj.get(fieldApi));
                    if (fieldValue != null) newPhoneValuesSet.add(getUnifiedRuNumber (fieldValue));
                }
            }
            return newPhoneValuesSet;
        }
        public Map <String,String> getUnifiedNumbersMap (List<String>  phoneFields, Boolean withExtension) {
            Map <String, String> ret = new Map <String, String>();
            for (String fieldApi : phoneFields) {
                if (fieldApi == 'Additional_Phones__c') {
                    Set <String> additionalPhonesUnified = new Set <String> ();
                    addUnifiedAdditionalPhones(additionalPhonesUnified, sObj);
                    for (String additionalPhone : additionalPhonesUnified) {
                        String unifiedNum = getUnifiedRuNumber (additionalPhone);
                        String phoneNumberKey = trimPhoneNumber (unifiedNum, withExtension);
                        if (!ret.containsKey(phoneNumberKey)) ret.put(phoneNumberKey, fieldApi);
                    }
                } else {
                    String fieldValue = sObj.get(fieldApi) == null ? null : String.valueOf(sObj.get(fieldApi));
                    if (fieldValue != null && !ret.containsKey(fieldValue)) {
                        String unifiedNum = getUnifiedRuNumber (fieldValue);
                        String phoneNumberKey = trimPhoneNumber (unifiedNum, withExtension);
                        if (!ret.containsKey(phoneNumberKey)) ret.put(phoneNumberKey, fieldApi);
                    }
                }
            }
            return ret;
        }
        public void addUnifiedAdditionalPhones (Set<String> unifiedPhonesValuesSet, sObject processingSObj) {
            Map <String, String> processingAdditionalPhonesMap = getAdditionalPhonesMap (processingSObj);
            if (!processingAdditionalPhonesMap.isEmpty()) {
                for (String additionalPhoneNumber : processingAdditionalPhonesMap.keySet()) {
                    unifiedPhonesValuesSet.add(getUnifiedRuNumber(additionalPhoneNumber));
                }
            }
        }
        // checks if pd data on phone fields was changed while processing the records and sends pd data to the service if it was changed
        //returns true if one of the phone firelds was changed while processing the records
        public Boolean isPDDataChanged (List<String>  phoneFields) {
            if (phoneFields == null || phoneFields.isEmpty()) return false;
            Set <String> newPhoneValuesSet = getNewPhoneValuesSet(phoneFields);
            if (newPhoneValuesSet.equals(this.oldPhoneValuesSet)) return false;
            return true;
        }

        public void processPhoneNumbers () { // processPhoneNumbers at the end
            if (this.isExternalSource) {
                system.debug('external source');
                parsePhoneNumbers();
            } else {
                // internal source: validation rule is working, parsing is not needed
                system.debug('internal source: validation rule is working, parsing is not needed');
            }
        }
        public void parsePhoneNumbers () {
           ParsePhoneResult parsePhoneResult;
            for (String phoneFieldAPI : phoneWrappersMap.keySet()) {
                 PhoneWrapper phoneWrap = phoneWrappersMap.get(phoneFieldAPI);
                 if (phoneWrap == null) continue;
                 if (!phoneWrap.isPhoneNumberValid() || sObj.getSObjectType() == Schema.Account.sObjectType) {
                    system.debug(phoneFieldAPI  + ' : ' + phoneWrap.phoneNumber + ' invalid number, parsing is needed');
                    parsePhoneResult = parsePhoneNumber (parsePhoneResult, this.sObj, this.oldSObj, phoneWrap.phoneFieldAPI, phoneWrap.phoneNumber);
                    system.debug('description after parsing: ' + this.sobj.get('Description'));

                    if (parsePhoneResult.needsValidation)  {
                        system.debug('unable to parse, needs manual validation');
                        this.phoneWrappersMap.putAll(parsePhoneResult.phoneWrappersMap);
                    } else {
                        this.phoneWrappersMap.putAll(parsePhoneResult.phoneWrappersMap);
                        this.newAdditionalPhones.putAll(parsePhoneResult.newAdditionalPhones);
                      //  this.newContactsMap.putAll(parsePhoneResult.newContactsMap); // !!! tmp for parsing accounts
                    }
                } else {
                    system.debug(phoneFieldAPI  + ' : ' + phoneWrap.phoneNumber + ' number is valid, doesnt need parsing');
                }
            }
        }
        public Set <String> getSetOfPhonesFormatted_NoExt () {
            Set <String> ret = new Set <String> ();
            // add phones from phone fields
            if (!this.phoneWrappersMap.isEmpty()) {
                for (PhoneWrapper phoneWrap : this.phoneWrappersMap.values()) {
                    ret.add(phoneWrap.phoneNumberFormatted_NoExt);
                }
            }
            // add additional phones form Additional_Phones__c field
            if (!this.newAdditionalPhones.isEmpty()) {
                for (String additionalPhoneItem : this.newAdditionalPhones.keySet()) {
                    ret.add(trimPhoneNumber (additionalPhoneItem, false));
                }
            }
            return ret;
        }
        /* not used
        public Set <String> getSetOfPhonesFormatted_WithExt () {
            Set <String> ret = new Set <String> ();
            if (phoneWrappersMap.isEmpty()) return ret;
            for (PhoneWrapper phoneWrap : phoneWrappersMap.values()) {
                ret.add(phoneWrap.phoneNumberFormatted_WithExt);
            }
            if (!this.newAdditionalPhones.isEmpty()) {
                for (String additionalPhoneItem : this.newAdditionalPhones) {
                    ret.add(additionalPhoneItem);
                }
            }
            return ret;
        }
        */
        public Map <String, String> getExistingNumbersMap_Formatted () {
            // check existing values of phone fields, which were set on the record
            Map <String, String> ret = new Map <String, String> ();
            for (String existingPhoneFieldAPI : GlobalUtils.getFieldSetMembersAPIs(this.sObj.getSObjectType(), 'All_Phone_Fields')) {
                if (existingPhoneFieldAPI.contains('.') || existingPhoneFieldAPI == 'Additional_Phones__c') continue; // skip parent fields and additional phones field
                if (phoneWrappersMap.containsKey(existingPhoneFieldAPI) && phoneWrappersMap.get(existingPhoneFieldAPI).isPhoneNumberChanged()) continue; // if the phone number on the field was changed then skip this field
                String numberOnExistingField = sObj.get(existingPhoneFieldAPI) == null ? null
                                             : trimPhoneNumber (String.valueOf(sObj.get(existingPhoneFieldAPI)), true);
                if (numberOnExistingField == null) continue;
                ret.put(numberOnExistingField, existingPhoneFieldAPI);
            }
            return ret;
        }
        public void checkPhoneDuplicates() {
            system.debug('>>> in checkPhoneDuplicates >>> ');
            Map <String, String> existingFieldsMap = getExistingNumbersMap_Formatted (); // existing phone numbers on the record
        // check duplicates on phone fields on the record
            for (String phoneFieldAPI : phoneWrappersMap.keySet()) {
                PhoneWrapper phoneWrapToCheck = phoneWrappersMap.get(phoneFieldAPI);
                if (phoneWrapToCheck.isPhoneNumberChanged () && phoneWrapToCheck.phoneNumber != null) {
                    Boolean isDuplicate_PhoneField = false;
                    String duplicateExistingPhoneFieldAPI;
                    String duplicateNewPhoneFieldAPI;

                    String phoneToCheck = phoneWrapToCheck.phoneNumberFormatted_WithExt;
                    String phoneToCheck2 = generateOtherCountryCodeRU (phoneToCheck); // another variation of the phone number ("+7" or "8")
                    // 1) check if the new value duplicates a value on one of phone fields on the record
                    if (!existingFieldsMap.isEmpty()) { // check if there is the value on one of existing fields
                        duplicateExistingPhoneFieldAPI = existingFieldsMap.containsKey(phoneToCheck) ? existingFieldsMap.get(phoneToCheck)
                                               : phoneToCheck2 != null && existingFieldsMap.containsKey(phoneToCheck2) ? existingFieldsMap.get(phoneToCheck2)
                                               : null;
                        if (duplicateExistingPhoneFieldAPI != null) isDuplicate_PhoneField = true;
                    }
                    // --- check if there are duplicates on new fields values ---
                    String duplicatedPhoneField = checkPhoneDuplicates_newPhoneFields (phoneWrapToCheck); // check if there is the value on one of new numbers
                    if (duplicatedPhoneField != null) {
                        isDuplicate_PhoneField = true;
                        duplicateNewPhoneFieldAPI = duplicatedPhoneField;
                    }
                    // 2) check if one of additional phones duplicates the new phone number
                    if (newAdditionalPhones.containsKey(phoneToCheck)) {
                        newAdditionalPhones.remove(phoneToCheck);
                        if (existingAdditionalPhones.containsKey(phoneToCheck) && oldAdditionalPhones.containsKey(phoneToCheck)) {
                            existingAdditionalPhones.remove(phoneToCheck);
                            phoneWrappersMap.get(phoneFieldAPI).isNewNumberDuplicatedOnAdditionalPhones = true;
                            isDuplicate_PhoneField = true;
                            system.debug(phoneToCheck + ' duplicates additional phones');
                        }
                    }
                    if (phoneToCheck2 != null && newAdditionalPhones.containsKey(phoneToCheck2)) {
                        newAdditionalPhones.remove(phoneToCheck2);
                        if (existingAdditionalPhones.containsKey(phoneToCheck2) && oldAdditionalPhones.containsKey(phoneToCheck2)) {
                            existingAdditionalPhones.remove(phoneToCheck2);
                            phoneWrappersMap.get(phoneFieldAPI).isNewNumberDuplicatedOnAdditionalPhones = true;
                            isDuplicate_PhoneField = true;
                            system.debug(phoneToCheck2 + ' duplicates additional phones');
                        }
                    }

                    if (isDuplicate_PhoneField) {
                        // the new value duplicates another field - leave the old value
                        system.debug('set duplicated : ' + phoneFieldAPI);
                        system.debug('duplicateNewPhoneFieldAPI : ' + duplicateNewPhoneFieldAPI);
                        system.debug('duplicateExistingPhoneFieldAPI : ' + duplicateExistingPhoneFieldAPI);
                        phoneWrappersMap.get(phoneFieldAPI).isDuplicate = true;
                        if (duplicateNewPhoneFieldAPI == null && duplicateExistingPhoneFieldAPI != null) {
                            phoneWrappersMap.get(phoneFieldAPI).duplicateExistingPhoneFieldAPI = duplicateExistingPhoneFieldAPI;
                        }
                    }

                }
            }
        // check if one of additional phones duplicates existing phone numbers on the record
            if (!newAdditionalPhones.isEmpty() && !existingFieldsMap.isEmpty()) {
                for (String additionalPhone : newAdditionalPhones.keySet()) {
                    if (existingFieldsMap.containsKey(additionalPhone)) {
                        // there is a duplicate number in Additional_Phones__c field. Remove the value from additonal numbers
                        newAdditionalPhones.remove(additionalPhone);
                    }
                }
            }
        }
    // check if the new value duplicates a value on one of new values on phone fields on the record
        private String checkPhoneDuplicates_newPhoneFields (PhoneWrapper phoneWrapToCheck) {
            String newPhoneNumberToCheck = phoneWrapToCheck.isPhoneNumberChanged() ? phoneWrapToCheck.phoneNumberFormatted_WithExt : null;
            if (newPhoneNumberToCheck == null) return null;
            String newPhoneNumberToCheck2 = generateOtherCountryCodeRU (newPhoneNumberToCheck); // another variation of the phone number ("+7" or "8")
            // check values of phone fields in PhoneWrappers
            for (String otherPhoneFieldAPI : phoneWrappersMap.keySet()) {
                if (!phoneWrappersMap.get(otherPhoneFieldAPI).isPhoneNumberChanged()) continue; // skip phone field if the phone number wasn't changed
                if (otherPhoneFieldAPI == phoneWrapToCheck.phoneFieldAPI) { //leave the first number as not duplicated
                    break;
                }
               String numberOnOtherField = phoneWrappersMap.get(otherPhoneFieldAPI).phoneNumberFormatted_WithExt;
                if (isDuplicatedValue (newPhoneNumberToCheck, numberOnOtherField)) return otherPhoneFieldAPI;
                if (newPhoneNumberToCheck2 != null) {
                    if (isDuplicatedValue (newPhoneNumberToCheck2, numberOnOtherField)) return otherPhoneFieldAPI;
                }
            }
            return null;
        }
    // compares 2 phone numbers to check if they are duplicated
        private Boolean isDuplicatedValue (String newPhoneNumberToCheck, String numberToCompare) {
            if (numberToCompare == null) return false;
            if (newPhoneNumberToCheck == numberToCompare) {
                // leave old value if the new value duplicates another field
                return true;
            }
            return false;
        }
    //  clear phone field, phone status and phone status modified date
        public void clearPhoneField (String phoneFieldAPI, String phoneFieldStatus) {
            sObj.put(phoneFieldAPI, null);
            sObj.put(phoneFieldStatus, null); // set status
            sObj.put(getPhoneStatusModifiedDateField(phoneFieldAPI), null); // set phone status modified date
            sObj.put(getPhoneRatingField(phoneFieldAPI), null); // set phone rating
        }
    // get map of irrelevant phones on the record and reasons of them being irrelevant (Irrelevant_Phones__c field)
        public Map <String, String> getIrrelevantNumbers_Record () {
            Map <String, String> irrelevantPhonesAndReasonsMap = new Map <String, String> ();
            if (sObj.get('Irrelevant_Phones__c') == null || sObj.get('Irrelevant_Phones__c') == '')  return irrelevantPhonesAndReasonsMap;
            List <String> irrelevantPhonesAndReasons_Record = getIrrelevantPhonesItemsList (sObj); // a set of irrelevant Phones on the Contact; // a set of irrelevant Phones on the Contact
            for (String irrelevantItem : irrelevantPhonesAndReasons_Record) {
                if(irrelevantItem != '') {
                    String phoneNum_WithExt = irrelevantItem_getPhone (irrelevantItem);
                    irrelevantPhonesAndReasonsMap.put(trimPhoneNumber (phoneNum_WithExt, false), irrelevantItem); // phone number => reason code
                }
            }
            return irrelevantPhonesAndReasonsMap;
        }
        public Boolean isParentAccountChanged () {
            if (sObj.getSObjectType() != Schema.Contact.sObjectType) return false;
            if (oldsObj == null) return false;
            String oldAccountId = oldSObj.get('AccountId') == null ? null
                                : String.valueOf(oldSObj.get('AccountId'));
            return this.accountId != oldAccountId; // account id wac changed for the contact
        }
        public void setPhoneStatusByRating (PhoneWrapper phoneWrap) {
            Double currentRating = sObj.get(getPhoneRatingField(phoneWrap.phoneFieldAPI)) == null ? null 
                                  : Double.valueOf(sObj.get(getPhoneRatingField(phoneWrap.phoneFieldAPI)));
            if (currentRating == 0) {
                String newStatus = 'Wrong number:1';
                phoneWrap.phoneStatus = newStatus;
                sObj.put(phoneWrap.phoneStatusFieldAPI, newStatus);
            }
        }
    }

    public class PhoneWrapper { // a wrapper of a phone number on a record's field
        public String phoneFieldAPI;
        public String phoneNumber;
        public String phoneNumberFormatted_NoExt {get {return phoneNumber == null ? null : trimPhoneNumber (phoneNumber, false);} set;}
        public String phoneNumberFormatted_WithExt {get {return phoneNumber == null ? null : trimPhoneNumber (phoneNumber, true);} set;}
        public String phoneStatusFieldAPI;
        public String phoneRatingFieldAPI;
        public String phoneStatus;
        public Double phoneRating;
        public DateTime statusModifiedTime;
        public String oldPhoneNumber; // previous value of the phone number
        public String oldPhoneStatus; // previous value of the phone status
        public Double oldPhoneRating; // previous value of the phone rating
        public Boolean isParsed {get {return isParsed == null ? false : isParsed;} set;}
        public Boolean isDuplicate {get {return isDuplicate == null ? false : isDuplicate;} set;}
        public Boolean isProcessed {get {return isProcessed == null ? false : isProcessed;} set;}
        public String duplicateExistingPhoneFieldAPI;
        public Boolean isNewNumberDuplicatedOnAdditionalPhones {get {return isNewNumberDuplicatedOnAdditionalPhones == null ? false : isNewNumberDuplicatedOnAdditionalPhones;} set;}
        public Boolean isMovedFromAnotherField {get {return isMovedFromAnotherField == null ? false : isMovedFromAnotherField;} set;}

        public PhoneWrapper (sObject sObj, sObject oldSObj, String phoneFieldAPI) {
            this.phoneFieldAPI = phoneFieldAPI;
            this.phoneNumber = sObj.get(phoneFieldAPI) == null ? null : String.valueOf(sObj.get(phoneFieldAPI));
            this.phoneStatusFieldAPI =  getPhoneStatusField (phoneFieldAPI);
            this.phoneRatingFieldAPI = getPhoneRatingField (phoneFieldAPI);
            this.phoneStatus = phoneNumber == null ? null // phone number is empty - set status empty as well
                             : sObj.get(phoneStatusFieldAPI) == null && sObj.get(phoneFieldAPI) != null ? 'New' // phone status is empty but number is entered : set status New
                             : String.valueOf(sObj.get(phoneStatusFieldAPI));
            this.phoneRating = phoneNumber == null ? null // phone number is empty - set rating empty as well
                             : sObj.get(phoneRatingFieldAPI) == null ? null // phone rating is empty
                             : Double.valueOf(sObj.get(phoneRatingFieldAPI));
            String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
            this.statusModifiedTime = sObj.get(statusModifiedDateField) == null ? null : DateTime.valueOf(sObj.get(statusModifiedDateField));
            this.oldPhoneNumber = oldSObj == null || oldSObj.get(phoneFieldAPI) == null ? null : String.valueOf(oldSObj.get(phoneFieldAPI));
            this.oldPhoneStatus = oldSObj == null || oldSObj.get(phoneStatusFieldAPI) == null ? null : String.valueOf(oldSObj.get(phoneStatusFieldAPI));
            this.oldPhoneRating = oldSObj == null || oldSObj.get(phoneRatingFieldAPI) == null ? null : Double.valueOf(oldSObj.get(phoneRatingFieldAPI));
            system.debug('new phone wrapper : ' + phoneFieldAPI + ' phoneNumber : ' + phoneNumber + ' ' + phoneStatusFieldAPI  + ' : ' + phoneStatus);
        }
        public PhoneWrapper (sObject sObj, sObject oldSObj, String phoneFieldAPI, String phoneNumber, String phoneStatus, Boolean isParsed) {
            this.phoneFieldAPI = phoneFieldAPI;
            this.phoneNumber = phoneNumber;
            this.phoneStatusFieldAPI =  getPhoneStatusField (phoneFieldAPI);
            this.phoneRatingFieldAPI = getPhoneRatingField (phoneFieldAPI);
            this.phoneStatus = phoneNumber == null ? null // phone number is empty - set status empty as well
                             : phoneStatus;
            this.phoneRating = phoneNumber == null ? null // phone number is empty - set rating empty as well
                             : sObj.get(phoneRatingFieldAPI) == null ? null // phone rating is empty
                             : Double.valueOf(sObj.get(phoneRatingFieldAPI));
            this.oldPhoneNumber = oldSObj == null || oldSObj.get(phoneFieldAPI) == null ? null : String.valueOf(oldSObj.get(phoneFieldAPI));
            this.oldPhoneStatus = oldSObj == null || oldSObj.get(phoneStatusFieldAPI) == null ? null : String.valueOf(oldSObj.get(phoneStatusFieldAPI));
            this.isParsed = isParsed;

            system.debug('new phone wrapper : isParsed : ' + isParsed + ' ' + phoneFieldAPI + ' phoneNumber : ' + phoneNumber + ' ' + phoneStatusFieldAPI  + ' : ' + phoneStatus);
        }
        public Boolean isPhoneNumberChanged () {
            return phoneNumber != oldPhoneNumber;
        }
        public Boolean isPhoneStatusChanged () {
            return phoneStatus != oldPhoneStatus;
        }
        public Boolean isPhoneRatingChanged () {
            return phoneRating != oldPhoneRating;
        }
        public Boolean isPhoneNumberValid () {
            return isPhoneNumberValid (this.phoneNumber);
        }
    }

    public class ParsePhoneResult { // a wrapper for results of parsing a phone number (for external sources or batch, processing existing phones data)
        public Map <String, PhoneWrapper> phoneWrappersMap;
        public Map <String, String> newAdditionalPhones;
      //  public Map <String, Contact> newContactsMap; // !!! tmp for parsing accounts
        public Boolean needsValidation;

        public ParsePhoneResult () {
            this.phoneWrappersMap = new Map <String, PhoneWrapper> ();
            this.newAdditionalPhones = new Map <String, String> ();
         //   this.newContactsMap = new Map <String, Contact> (); // !!! tmp for parsing accounts
            this.needsValidation = false;
        }
    }
// ------------------- CREATE SOBJWRAPPER -------------------------------------------------------   
    /*******************************************************************************
    *  Name            : addIrrelevantNumber(Map <String, String> irrelevantPhones_StatusReasonsMap)
    *  Summary         : Creates 1 sObjWrapper for 1 sIbject record 
    *                    * use it when need to work with phones of 1 record only (sObjWrapperList is used to work with a list of sobjects from trigger)
    *  Parameters      : sObject sObj - record from which we get phones' data
    *  Returns         : sObjWrapper - wrapper with phones' data from sObj record passed in params
    ******************************************************************************/
    public static sObjWrapper createSObjWrapper (sObject sObj) {
        if (sObj == null) return null;
        sObjWrapper sObjWrap = new sObjWrapper(sObj, null);
        Schema.SObjectType sObjType = sObj.getSObjectType();
        List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObjType, 'All_Phone_Fields');
        for (String phoneFieldAPI : phoneFieldsAPIs) {
            if (phoneFieldAPI.contains('.') || phoneFieldAPI == 'Additional_Phones__c') continue; // exclude parent fields
            String phoneStatusFieldAPI = getPhoneStatusField (phoneFieldAPI);
            sObjWrap.addPhoneWrapper(phoneFieldAPI);
        }
        return sObjWrap;
    }
// ------------------- GET ALL PHONE FIELDS -------------------------------------------------------  
    public static List <String> getAllPhoneFields (Schema.SObjectType sObjType) {    
        List <String> ret = new List <String> ();
        List<String>  phoneFields = GlobalUtils.getFieldSetMembersAPIs (sObjType, 'All_Phone_Fields');
        if (phoneFields.isEmpty()) return ret;
        for (String phoneFieldAPI : phoneFields) {
            if (phoneFieldAPI.contains('.'))  continue;
            //--- phone fields ---
            ret.add(phoneFieldAPI);
            //--- phone status/rating fields ---
            String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
            if (phoneStatusFieldAPI != null) {
                ret.add(phoneStatusFieldAPI);
                ret.add(PhoneNumbersHandler.getPhoneRatingField (phoneFieldAPI));
                ret.add(PhoneNumbersHandler.getPhoneStatusModifiedDateField (phoneFieldAPI));
            }
        }
        ret.add('Irrelevant_Phones__c');
        ret.add('Irrelevant_Phones_ModifiedDate__c');
        return ret;
    }
    
// ------------------- IRRELEVANT NUMBERS ---------------------------------------------------------
    /*******************************************************************************
    *  Name            : addIrrelevantNumber(Map <String, String> irrelevantPhones_StatusReasonsMap)
    *  Summary         : Add phone number to a list of irrelevant phone numbers - list on a record or global list
    *  Parameters      : Map <String, String>: phoneNumber - which we need to set as irrelevant => phoneStatusReason – to define which list we have to save the phone number to: list on a record or global
    *  Returns         : void
    ******************************************************************************/
    public static void addIrrelevantNumber (sObject sObj, Map <String, String> irrelevantPhones_StatusReasonsMap) {
        if (sObj == null || irrelevantPhones_StatusReasonsMap == null || irrelevantPhones_StatusReasonsMap.isEmpty()) return;
        Set <String> statusReasonsSet_Record = new Set <String> {'1','2','3d','4d'};
        Map <String, String> newIrrelevantPhonesToReasonsMap_Record = new Map <String, String> ();
        Map <String, IrrelevantPhone__c> newIrelevantPhones_Global = new Map <String, IrrelevantPhone__c> (); // global irrelevant phones

        for (String phoneNumberKey : irrelevantPhones_StatusReasonsMap.keySet()) {
            String phoneNumber = trimPhoneNumber (phoneNumberKey, true);
            String phoneNumber_NoExt = trimPhoneNumber (phoneNumberKey, false);
            String phoneStatusReason = irrelevantPhones_StatusReasonsMap.get(phoneNumberKey);
            if (statusReasonsSet_Record.contains(phoneStatusReason)) {
                // save on a record
                newIrrelevantPhonesToReasonsMap_Record.put(phoneNumber_NoExt, createIrrelevantItemString(phoneNumber, phoneStatusReason)); // if there was another status reason set, then refresh it with new value
            } else {
                // save in a global list
                newIrelevantPhones_Global.put(phoneNumber_NoExt,
                    new IrrelevantPhone__c (Phone__c = phoneNumber,
                                            Phone_NoExtension__c = trimPhoneNumber(phoneNumber, false),
                                            StatusReason__c = phoneStatusReason));
            }
        }
        //system.debug('newIrrelevantPhonesToReasonsMap_Record: ' + newIrrelevantPhonesToReasonsMap_Record);
        //system.debug('newIrelevantPhones_Global: ' + newIrelevantPhones_Global);

        // save on a record
        if (!newIrrelevantPhonesToReasonsMap_Record.isEmpty()) {
            addIrrelevantNumber_onRecord(sObj, newIrrelevantPhonesToReasonsMap_Record);
        }
        // save in a global list
        if (!newIrelevantPhones_Global.isEmpty()) {
            upsert newIrelevantPhones_Global.values() Phone_NoExtension__c;
        }
    }
    /*******************************************************************************
    *  Name            : addIrrelevantNumber_onRecord(sObject sObj, Map <String, String> newirrelevantPhonesToReasonsMap)
    *  Summary         : Add a new irrelevant number on the record (Irrelevant_Phones__c fields)
    *  Parameters      : sObject sObj - a record on which we save an irrelevant number, Map <String, String> newirrelevantPhonesToReasonsMap -  a map of phoneNumber => Irrelevant status reason
    *  Returns         : void
    ******************************************************************************/
    public static void addIrrelevantNumber_onRecord (sObject sObj, Map <String, String> newirrelevantPhonesToReasonsMap) {
        if (newirrelevantPhonesToReasonsMap == null || newirrelevantPhonesToReasonsMap.isEmpty()) return;
        Map <String, String> irrelevantPhonesToReasonsMap = getIrrelevantPhonesToReasonsMap(sObj);
        // we only can save up to 255 characters on the Ireelevant_Phones__c field
        for (String newIrrelevantPhone : newirrelevantPhonesToReasonsMap.keySet()) {
            String newIrrelevantPhone_NoExt = trimPhoneNumber (newIrrelevantPhone, false);
            String newIrrelevantItem = newirrelevantPhonesToReasonsMap.get(newIrrelevantPhone);
            if (irrelevantPhonesToReasonsMap.containsKey(newIrrelevantPhone_NoExt)) {
                // replace old status reason with a new value
                irrelevantPhonesToReasonsMap.put(newIrrelevantPhone_NoExt, newIrrelevantItem);
            }
            irrelevantPhonesToReasonsMap.put(newIrrelevantPhone, newIrrelevantItem);
            addIrrelevantStatusesModifiedItem (sObj, newIrrelevantPhone);
        }
        String irrelevantPhonesVal = createIrrelevantPhonesString(irrelevantPhonesToReasonsMap);
        sObj.put('Irrelevant_Phones__c', irrelevantPhonesVal);
    }
    /*******************************************************************************
    *  Name            : removeIrrelevantNumber_fromRecord(sObject sObj, String phoneNumberToDelete)
    *  Summary         : Remove a new irrelevant number form the record (Irrelevant_Phones__c fields)
    *  Parameters      : sObject sObj - a record on which we remove an irrelevant number, String phoneNumberToDelete - a phoneNumber which we remove from irrelevant list
    *  Returns         : void
    ******************************************************************************/
    public static void removeIrrelevantNumber_fromRecord (sObject sObj, String phoneNumberToDelete) {
        Map <String, String> irrelevantPhonesToReasonsMap_Record = new Map <String, String> ();
        Map <String, String> irrelevantPhonesToReasonsMap = getIrrelevantPhonesToReasonsMap (sObj);
        if (irrelevantPhonesToReasonsMap.containsKey(phoneNumberToDelete)) irrelevantPhonesToReasonsMap.remove(phoneNumberToDelete);
        sObj.put('Irrelevant_Phones__c', createIrrelevantPhonesString(irrelevantPhonesToReasonsMap));
        removeIrrelevantStatusesModifiedItem (sObj, phoneNumberToDelete);
    }
    /*******************************************************************************
    *  Name            : getIrrelevantPhonesToReasonsMap(sObject sObj)
    *  Summary         : create a map of irrelevant phones from Irrelevant_Phones__c field on the record: a phone without an extension => irrelevant item with a phone and a reason
    *  Parameters      : sObject sObj - a record from which we get irrelevant phones map
    *  Returns         : Map <String, String> - a map of phone_no_extension => phone:statusReason values
    ******************************************************************************/
    public static Map <String, String> getIrrelevantPhonesToReasonsMap (sObject sObj) {
        if (sObj == null || sObj.get('Irrelevant_Phones__c') == null || String.valueOf(sObj.get('Irrelevant_Phones__c')) == '') return new Map <String, String> ();
        Map <String, String> ret = new Map <String, String> ();
        Set <String> irrelevantPhonesToReasonsSet_Record = new Set <String> (getIrrelevantPhonesItemsList (sObj)); // a set of irrelevant Phones on the Contact
        if (!irrelevantPhonesToReasonsSet_Record.isEmpty()) {
            for (String irrelevantPhoneItem_Record : irrelevantPhonesToReasonsSet_Record) {
                ret.put(irrelevantItem_getPhone (irrelevantPhoneItem_Record), irrelevantPhoneItem_Record);
            }
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getIrrelevantNumbers_Global (Set <String> phoneNumbersFormatted)
    *  Summary         : create a map of irrelevant phones from IrrelevantPhone__c sObject list: a phone without an extension => irrelevant item with a phone and a reason
    *  Parameters      : sObject sObj - a record from which we get irrelevant phones map
    *  Returns         : Map <String, String> - a map of phone_no_extension => phone:statusReason values
    ******************************************************************************/
    public static Map<String, String> getIrrelevantNumbers_Global (Set <String> phoneNumbersFormatted) {
        Map<String, String> ret = new Map<String, String> ();
        if (phoneNumbersFormatted == null || phoneNumbersFormatted.isEmpty()) return ret;
        List <IrrelevantPhone__c> irrelevantPhonesGlobal = [SELECT Id, Phone_NoExtension__c, Phone__c, sObjectId__c FROM IrrelevantPhone__c WHERE Phone_NoExtension__c IN: phoneNumbersFormatted];
        if (irrelevantPhonesGlobal.isEmpty()) return ret;
        for (IrrelevantPhone__c irrelevantPhone : irrelevantPhonesGlobal) {
            // trim phone number for checking new phone values: remove extension
            ret.put(trimPhoneNumber (irrelevantPhone.Phone__c, false), irrelevantPhone.Phone__c);
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getParentAccounts (Set <String> idsSet)
    *  Summary         : get a list of accounts by a set of account ids
    *  Parameters      : Set <String> idsSet - a set of account ids
    *  Returns         :  Map<Id, Account> - a map of Account Id => Account record
    ******************************************************************************/
    public static Map<Id, Account> getParentAccounts (Set <String> idsSet) {
        Map <Id, Account> ret = new Map <Id, Account> ();
        if (idsSet == null || idsSet.isEmpty()) return ret;
        ret = new Map <Id, Account> ([SELECT Id, Irrelevant_Phones__c, Irrelevant_Phones_ModifiedDate__c FROM Account WHERE Id IN: idsSet]);
        return ret;
    }
    /*******************************************************************************
    *  Name            : getIrrelevantNumbers_Parent (List<Account> accountsList)
    *  Summary         : create a map of irrelevant phones from from Irrelevant_Phones__c field on the parent account record: a phone without an extension => irrelevant item with a phone and a reason
    *  Parameters      : List<Account> accountsList - a list of accounts for which we create a map
    *  Returns         : Map<Id, Map<String, String>> -  a map of Account Id => < a map of phone_no_extension => phone:statusReason values >
    ******************************************************************************/
    public static Map<Id, Map<String, String>> getIrrelevantNumbers_Parent (List<Account> accountsList) {
        Map<Id, Map<String, String>> ret = new Map<Id, Map<String, String>> (); // account id => set irrelevant phones
        if (accountsList == null || accountsList.isEmpty()) return ret;
        for (Account acc : accountsList) {
            if (!ret.containsKey(acc.Id)) ret.put(acc.Id, new Map <String, String> ());
            Set <String> irrelevantPhonesToReasonsSet_Record = new Set <String> (getIrrelevantPhonesItemsList (acc)); // a set of irrelevant Phones on a record
            for (String irrelevantPhoneItem_Record : irrelevantPhonesToReasonsSet_Record) {
                String phoneNum_WithExt = irrelevantItem_getPhone (irrelevantPhoneItem_Record);
                // trim phone number for checking new phone values: remove extension
                ret.get(acc.Id).put(trimPhoneNumber (phoneNum_WithExt, false), phoneNum_WithExt);
            }
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getPhoneStatuses_Disqual()
    *  Summary         : Returns a Map of disqualification reason code and disqualification status label
    *  Parameters      : -
    *  Returns         : Map <String, String>  - disqualification status API => disqualification status label
    ******************************************************************************/
    public static Map <String, String> getPhoneStatuses_Disqual () {
        Map <String, String> ret = new Map <String, String> ();
        Map <String, String> phoneStatusesMap = getPhoneStatusesWithReasons();
        for (String statusWithReasonAPI : phoneStatusesMap.keySet()) {
            String reasonCode = phoneStatus_getReasonCode(statusWithReasonAPI);
            if (reasonCode != null && reasonCode.contains('d')) {
                // add disqualification status reason cose with label
                ret.put(statusWithReasonAPI, phoneStatusesMap.get(statusWithReasonAPI));
            }
        }
        return ret;
    }

    /*******************************************************************************
    *  Name            : getIrrelevantPhonesItemsList (sObject sObj)
    *  Summary         : get a set of numbers from Irrelevant_Phones__c field
    *  Parameters      : sObject sObj - on which the Irrelevant_Phones__c field is
    *  Returns         : List <String> - set of additional phones on the object
    ******************************************************************************/
    public static List <String> getIrrelevantPhonesItemsList (sObject sObj) {
       return sObj.get('Irrelevant_Phones__c') == null ? new List <String> ()
                            : String.valueOf(sObj.get('Irrelevant_Phones__c')).split(';');
    }
    /*******************************************************************************
    *  Name            : irrelevantItem_getPhone (String irrelevantItem)
    *  Summary         : get a phone value from irrelevant item in Irrelevant_Phones__c field (irrelevant item example: '+782156845254:0')
    *  Parameters      : String irrelevantItem from Irrelevant_Phones__c field
    *  Returns         : String - phone number value from irrelevant item in the Irrelevant_Phones__c field
    ******************************************************************************/
    public static String irrelevantItem_getPhone (String irrelevantItem) {
        if (irrelevantItem == null || irrelevantItem == '') return null;
        return irrelevantItem.split(':')[0];
    }
    /*******************************************************************************
    *  Name            : irrelevantItem_getReason (String irrelevantItem)
    *  Summary         : get a reason value from irrelevant item in Irrelevant_Phones__c field
    *  Parameters      : String irrelevantItem from Irrelevant_Phones__c field
    *  Returns         : String - irrelevant status reason value from irrelevant item in the Irrelevant_Phones__c field
    ******************************************************************************/
    public static String irrelevantItem_getReason (String irrelevantItem) {
        if (irrelevantItem == null || irrelevantItem == '') return null;
        return irrelevantItem.split(':')[1];
    }
    /*******************************************************************************
    *  Name            : createIrrelevantPhonesString (Map <String, String> irrelevantPhonesToReasonsMap)
    *  Summary         : create a string from a map of phone_no_extension => phone:statusReason values
    *  Parameters      : Map <String, String> irrelevantPhonesToReasonsMap - a map of phone_no_extension => phone:statusReason values
    *  Returns         : String - a string to save on Irrelevant_Phones__c field
    ******************************************************************************/
    public static String createIrrelevantPhonesString (Map <String, String> irrelevantPhonesToReasonsMap) {
        if (irrelevantPhonesToReasonsMap == null || irrelevantPhonesToReasonsMap.isEmpty()) return '';
        String ret = String.join (irrelevantPhonesToReasonsMap.values(), ';');
        if (ret.length()  > 255) throw new PhonesException (Label.exception_Phones_TooManyIrrelevantPhones);
        return ret;
    }
    /*******************************************************************************
    *  Name            : createIrrelevantItemString (String phoneNumber, String phoneStatusReason)
    *  Summary         : create a string of an irrelevant item for Irrelevant_Phones__c field
    *  Parameters      : String phoneNumber - a left part of an irrelevant item, String phoneStatusReason - a right part of an irrelevant item
    *  Returns         : String - a string of an irrelevant item (ex.: '+75543345444:0')
    ******************************************************************************/
    public static String createIrrelevantItemString (String phoneNumber, String phoneStatusReason) {
        if (phoneNumber == null || phoneNumber == '' || phoneStatusReason == null || phoneStatusReason == '') return '';
        return phoneNumber+':'+phoneStatusReason;
    }
    /*******************************************************************************
    *  Name            : getIrrelevantStatusesModifiedItems (sObject sObj)
    *  Summary         : get a Map of phone number => date irrelevant status modified from Irrelevant_Phones_ModifiedDate__c fied on the record
    *  Parameters      : sObject sObj - from which we get irrelevant phones modified dates data
    *  Returns         : Map <String, String> - a map of phone number => date irrelevant status modified
    ******************************************************************************/
    public static Map <String, String> getIrrelevantStatusesModifiedItems (sObject sObj) {
        Map <String, String> ret = new Map <String, String> ();
        List <String> irrelevantStatusesModifiedList = getIrrelevantStatusesModifiedItemsList (sObj);
        if (!irrelevantStatusesModifiedList.isEmpty()) {
            for (String statusModifiedItem : irrelevantStatusesModifiedList) {
                if (statusModifiedItem == '') continue;
                String phoneItem = irrelevantItem_getPhone(statusModifiedItem);
                ret.put(PhoneNumbersHandler.trimPhoneNumber(phoneItem, false), statusModifiedItem);
            }
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getIrrelevantStatusesModifiedItemsList (sObject sObj)
    *  Summary         : get a set of numbers from Irrelevant_Phones__c field
    *  Parameters      : sObject sObj - on which the Irrelevant_Phones__c field is
    *  Returns         : List <String> - set of additional phones on the object
    ******************************************************************************/
    public static List <String> getIrrelevantStatusesModifiedItemsList (sObject sObj) {
       return sObj.get('Irrelevant_Phones_ModifiedDate__c') == null ? new List <String> ()
                            : String.valueOf(sObj.get('Irrelevant_Phones_ModifiedDate__c')).split(';');
    }
    /*******************************************************************************
    *  Name            : createIrrelevantStatusesModifiedItem (String phoneNumber)
    *  Summary         : create a string of an irrelevant modified date time item for Irrelevant_Phones_ModifiedDate__c field
    *  Parameters      : String phoneNumber - a left part of an irrelevant item
    *  Returns         : String - a string of an irrelevant modified date time item (ex.: '+75543345444:15.10.19.1630')
    ******************************************************************************/
    public static String createIrrelevantStatusesModifiedItem (String phoneNumber) {
        String dateFormatted = getModifiedDate_Formatted (system.now());
        return phoneNumber+':'+dateFormatted;
    }
    /*******************************************************************************
    *  Name            : irrelevantPhonelItem_getModifiedDate_DateTime (String irrelevantPhoneItem)
    *  Summary         : get a DateTime value from irrelevant phone item in Irrelevant_Phones_ModifiedDate__c field
    *  Parameters      : String irrelevantPhoneItem from Irrelevant_Phones_ModifiedDate__c field
    *  Returns         : DateTime - irrelevant phone status modified date and time as DateTime format
    ******************************************************************************/
    public static DateTime irrelevantPhonelItem_getModifiedDate_DateTime (String irrelevantPhoneItem) {
        if (irrelevantPhoneItem == null || irrelevantPhoneItem == '') return null;
        try {
            String phoneModifiedDateItem = irrelevantPhoneItem.split(':')[1];
            return getFormattedModifiedDateTime (phoneModifiedDateItem);
        } catch (Exception ex) {
            return null;
        }
    }
    /*******************************************************************************
    *  Name            : getModifiedDate_Formatted (DateTime dateToFormat)
    *  Summary         : create a date in a string format for Irrelevant_Phones_ModifiedDate__c field
    *  Parameters      : Datetime dateToFormat - a date time value which is being formatted
    *  Returns         : String - a string of the formatted date and time
    ******************************************************************************/
    public static String getModifiedDate_Formatted (DateTime dateToFormat) {
        if (dateToFormat == null) return null;
        return dateToFormat.formatGMT('ddMMyyHHmm');
    }
    /*******************************************************************************
    *  Name            : createIrrelevantStatusesModifiedString (Map <String, String> irrelevantStatusesModifiedList)
    *  Summary         : create a string from a map of phone_no_extension => phone:statusReason values for Irrelevant_Phones_ModifiedDate__c field on the record
    *  Parameters      : Map <String, String> irrelevantStatusesModifiedList - a map of phone_no_extension => phone:statusReason values
    *  Returns         : String - a string to save on Irrelevant_Phones_ModifiedDate__c field
    ******************************************************************************/
    public static String createIrrelevantStatusesModifiedString (Map <String, String> irrelevantStatusesModifiedList) {
        if (irrelevantStatusesModifiedList == null || irrelevantStatusesModifiedList.isEmpty()) return '';
        String ret = String.join (irrelevantStatusesModifiedList.values(), ';');
        if (ret.length()  > 255) throw new PhonesException (Label.exception_Phones_TooManyIrrelevantPhones);
        return ret;
    }
    /*******************************************************************************
    *  Name            : addIrrelevantStatusesModifiedItem (sObject sObj, String phoneNumber)
    *  Summary         : add an irrelevant status modified date item to Irrelevant_Phones_ModifiedDate__c field on the record
    *  Parameters      : sObject sObj - a record on which we add an irrelevant status modified date item, String phoneNumber - a phone number which status was modified
    *  Returns         : void
    ******************************************************************************/
    public static void addIrrelevantStatusesModifiedItem (sObject sObj, String phoneNumber) {
        Map <String, String> irrelevantStatusesModifiedItems = getIrrelevantStatusesModifiedItems (sObj);
        String irrelevantStatusModifiedItem = createIrrelevantStatusesModifiedItem(phoneNumber);
        irrelevantStatusesModifiedItems.put(irrelevantItem_getPhone(irrelevantStatusModifiedItem), irrelevantStatusModifiedItem);
        String finalString = createIrrelevantStatusesModifiedString (irrelevantStatusesModifiedItems);
        sObj.put('Irrelevant_Phones_ModifiedDate__c', finalString);
    }
    /*******************************************************************************
    *  Name            : removeIrrelevantStatusesModifiedItem (sObject sObj, String phoneNumber)
    *  Summary         : remove an irrelevant status modified date item from Irrelevant_Phones_ModifiedDate__c field on the record
    *  Parameters      : sObject sObj - a record from which we remove an irrelevant status modified date item, String phoneNumber - a phone number which status was modified
    *  Returns         : void
    ******************************************************************************/
    public static void removeIrrelevantStatusesModifiedItem (sObject sObj, String phoneNumber) {
        Map <String, String> irrelevantStatusesModifiedItems = getIrrelevantStatusesModifiedItems (sObj);
        irrelevantStatusesModifiedItems.remove(phoneNumber);
        String finalString = createIrrelevantStatusesModifiedString (irrelevantStatusesModifiedItems);
        sObj.put('Irrelevant_Phones_ModifiedDate__c', finalString);
    }
    /*******************************************************************************
    *  Name            : irrelevantItem_getModifiedDate (String irrelevantItem)
    *  Summary         : get a modifieddate string from irrelevant item in Irrelevant_Phones_ModifiedDate__c field
    *  Parameters      : String irrelevantItem from Irrelevant_Phones_ModifiedDate__c field
    *  Returns         : String - irrelevant status modified date and time as a formatted string
    ******************************************************************************/
    public static String irrelevantItem_getModifiedDate (String irrelevantItem) {
        if (irrelevantItem == null || irrelevantItem == '') return null;
        String dateStr = irrelevantItem.split(':')[1];
        return getFormattedModifiedDateString (dateStr);
    }

    /*******************************************************************************
    *  Name            : getFormattedModifiedDateString (String datestr)
    *  Summary         : format modifieddate
    *  Parameters      : String datestr - unformatted date without '.' or ':'
    *  Returns         : String - formatted string date time dd.mm.yy hh:mm
    ******************************************************************************/
    public static String getFormattedModifiedDateString (String datestr) {
        if (datestr == null || datestr == '') return null;
        datestr = datestr.replace('.','');
        dateStr = dateStr.length() == 6 ? dateStr+'0000' : dateStr.length() == 5 ? '0'+dateStr+'0000' : dateStr;
        return dateStr.substring(0,2)+'.'+dateStr.substring(2,4)+'.'+dateStr.substring(4,6)+' '+dateStr.substring(6,8)+':'+dateStr.substring(8,10);
    }

    /*******************************************************************************
    *  Name            : getFormattedModifiedDateTime (String datestr)
    *  Summary         : format modifieddate - get datetime value in gmt 0 timezone
    *  Parameters      : String datestr - unformatted date without '.' or ':'
    *  Returns         : DateTime - formatted datetime value
    ******************************************************************************/
    public static DateTime getFormattedModifiedDateTime (String datestr) {
        if (datestr == null || datestr == '') return null;
        datestr = datestr.replace('.','');
        dateStr = dateStr.length() == 6 ? dateStr+'0000' : dateStr.length() == 5 ? '0'+dateStr+'0000' : dateStr;
        return DateTime.newInstanceGmt(Date.newInstance(Integer.valueOf('20'+dateStr.substring(4,6)), Integer.valueOf(dateStr.substring(2,4)), Integer.valueOf(dateStr.substring(0,2))),
                                    Time.newInstance(Integer.valueOf(dateStr.substring(6,8)), Integer.valueOf(dateStr.substring(8,10)), 0, 0)
                                   );
    }

// ------- IRRELEVANT STATUSES ON PHONE STATUS FIELDS -----------
    /*******************************************************************************
    *  Name            : getPhoneStatusesWithReasons ()
    *  Summary         : get a map of irrelevant phone statuses with their reasons - to use on Lead, Contact, Account records
    *  Parameters      : -
    *  Returns         : Map<String, String> - a map of irrelevant phone status => irrelevant status reason label
    ******************************************************************************/
    public static Map<String, String> getPhoneStatusesWithReasons() {
        Map<String, String> ret = new Map<String, String>();
        List<Schema.PicklistEntry> picklistValues = GlobalUtils.getPicklistValues (Schema.Contact.sObjectType, 'Phone_Status__c');
        if (picklistValues.isEmpty()) return ret;
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            String picklistValueAPI = picklistEntry.getValue();
            if (picklistValueAPI.contains(':')) {
                String statusWithReasonAPI = picklistValueAPI;
                String statusWithReasonLabel = picklistEntry.getLabel();
                ret.put(statusWithReasonAPI, statusWithReasonLabel);
            }
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getPhoneStatusReasons ()
    *  Summary         : get a map of irrelevant phone statuse codes with their reasons - to use on Lead, Contact, Account records
    *  Parameters      : -
    *  Returns         : Map<String, String> - a map of irrelevant phone status code => irrelevant status reason label
    ******************************************************************************/
    public static Map<String, String> getPhoneStatusReasons() {
        Map<String, String> ret = new Map<String, String>();
        Map<String, String> phoneStatusesWithReasons = getPhoneStatusesWithReasons();
        if (phoneStatusesWithReasons.isEmpty()) return ret;
        for (String phoneStatusAPI : phoneStatusesWithReasons.keySet()) {
            String statusReasonCode = phoneStatus_getReasonCode (phoneStatusAPI);
            String statusReasonLabel = phoneStatus_getReasonLabel(phoneStatusesWithReasons.get(phoneStatusAPI));
            ret.put(statusReasonCode, statusReasonLabel);
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : phoneStatus_getStatus (String phoneStatusVal)
    *  Summary         : get a value of an irrelevant phone status
    *  Parameters      : String phoneStatusVal -  an irrelevant phone status value
    *  Returns         : String - a value of an irrelevant phone status
    ******************************************************************************/
    public static String phoneStatus_getStatus (String phoneStatusVal) {
        if (phoneStatusVal == null || phoneStatusVal == '' || !phoneStatusVal.contains(':')) return null;
        return phoneStatusVal.split(':')[0];
    }
    /*******************************************************************************
    *  Name            : phoneStatus_getReasonCode (String phoneStatusVal)
    *  Summary         : get a code of an irrelevant phone status
    *  Parameters      : String phoneStatusVal -  an irrelevant phone status value
    *  Returns         : String -  a code of an irrelevant phone status
    ******************************************************************************/
    public static String phoneStatus_getReasonCode (String phoneStatusVal) {
        if (phoneStatusVal == null || phoneStatusVal == '' || !phoneStatusVal.contains(':')) return null;
        return phoneStatusVal.split(':')[1];
    }
    /*******************************************************************************
    *  Name            : phoneStatus_getReasonLabel (String phoneStatusLabel)
    *  Summary         : get a label of an irrelevant phone status reason (example of phone status reason label 'Wrong number - Doesn't exist')
    *  Parameters      : String phoneStatusLabel -  an irrelevant phone status label
    *  Returns         : String -  a label of an irrelevant phone status
    ******************************************************************************/
    public static String phoneStatus_getReasonLabel (String phoneStatusLabel) {
        if (phoneStatusLabel == null || phoneStatusLabel == '') return null;
        if (!phoneStatusLabel.contains('-')) return phoneStatusLabel;
        return phoneStatusLabel.split('-')[1].trim();
    }

// ------------------- ADDITIONAL NUMBERS ---------------------------------------------------------

    /*******************************************************************************
    *  Name            : addAdditionalNumbers(sObject sObj, List <String> additionalPhones)
    *  Summary         : Add new phone numbers to additional list on a record: record.Additional_Phones__c field which uses '.' to separate the values
    *  Parameters      : sObject sObj - on which we need to need an additional value, List <String> additionalPhones – list of phones to save in the list of additional phones on the record
    *  Returns         : String - new Value of Additional_Phones__c field (returns '' when there is nothing to add)
    ******************************************************************************/
    public static String addAdditionalNumbers (sObject sObj, List <String> additionalPhones) {
        String ret = '';
        if (sObj == null || additionalPhones == null || additionalPhones.isEmpty()) return ret;
        Map <String, String> additionalPhonesMap = new Map <String, String> (getAdditionalPhonesMap (sObj)); // a set of Additional Phones
        Map <String, String> newAdditionalPhonesMap = new Map <String, String> ();
        for (String newAdditionalPhone : additionalPhones) {
            String phoneNum = additionaPhonelItem_getPhone(newAdditionalPhone);
            String phoneFormatted = trimPhoneNumber(phoneNum, true);
            if (!additionalPhonesMap.containsKey(phoneFormatted)) {
                String phoneStatus_param = additionaPhonelItem_getStatus(newAdditionalPhone);
                String phoneStatus = phoneStatus_param == null || phoneStatus_param == '' ? 'New' : phoneStatus_param;
                DateTime phoneModifiedDate_param = additionaPhonelItem_getModifiedDate_DateTime(newAdditionalPhone);
                String phoneRating_param = additionaPhonelItem_getRating(newAdditionalPhone);
                String phoneRating = phoneRating_param == null ? '' : phoneRating_param;
                String phoneModifiedDateToday = phoneModifiedDate_param == null ? getModifiedDate_Formatted (system.now())
                                                                                : getModifiedDate_Formatted (phoneModifiedDate_param);
                String additionalPhoneItem = createAdditionalPhoneItemString (phoneFormatted, phoneStatus, phoneRating, phoneModifiedDateToday); // add new additional  phone with an empty rating (while parsing)
                newAdditionalPhonesMap.put(phoneFormatted, additionalPhoneItem);
            }
        }
        if (!newAdditionalPhonesMap.isEmpty()) {
            additionalPhonesMap.putAll(newAdditionalPhonesMap);
        }
        ret = createAdditionalPhoneString (additionalPhonesMap.values());
        return ret;
    }
    /*******************************************************************************
    *  Name            : addAdditionalNumbersToPhoneFields (sObject sObj)
    *  Summary         : checks if there are blank phone fields on the record. If there are, then set phone numbers from Additional_Phones__c list to those fields
    *  Parameters      : sObject sObj - on which we set phone fields values
    *  Returns         : void
    ******************************************************************************/
    public static void addAdditionalNumbersToPhoneFields (sObject sObj) {
        Map <String, String> additionalPhonesMap = getAdditionalPhonesMap (sObj);
        Map <String, String> newAdditionalPhonesMap = new Map <String, String> ();
        if (!additionalPhonesMap.isEmpty()) {
            // look for empty phone fields
            List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObj.getSobjectType(), 'All_Phone_Fields');
            List <String> blankPhoneFieldsAPIs = getBlankPhoneFieldsAPIs (sObj);
            if (blankPhoneFieldsAPIs.isEmpty()) return;
            Integer countAdded = 0;
            for (String additionalPhone : additionalPhonesMap.keySet()) {
                if(isPhoneNumbervalid(additionalPhone)) {
                    if (blankPhoneFieldsAPIs.size() >= countAdded+1) {
                        String blankPhoneFieldAPI = blankPhoneFieldsAPIs[countAdded];

                        String additionalPhoneItem = additionalPhonesMap.get(additionalPhone);
                        // set phone number, status and rating in the phone field
                        sObj.put(blankPhoneFieldAPI, additionalPhone);
                        // set phone status
                        String newPhoneStatus = additionaPhonelItem_getStatus(additionalPhoneItem);
                        newPhoneStatus = newPhoneStatus == null || newPhoneStatus == '' ? 'New' : newPhoneStatus;
                        sObj.put(getPhoneStatusField(blankPhoneFieldAPI), newPhoneStatus);
                        // set phone rating
                        Double newPhoneRating = rating_formatToDouble(additionaPhonelItem_getRating(additionalPhoneItem));
                        newPhoneRating = newPhoneRating == null ? countPhoneRating(sObj, null, newPhoneStatus) : newPhoneRating;
                        sObj.put(getPhoneRatingField(blankPhoneFieldAPI), newPhoneRating);
                        // set status modified date
                        DateTime newPhoneStatusModifiedTime = additionaPhonelItem_getModifiedDate_DateTime (additionalPhoneItem);
                        newPhoneStatusModifiedTime = newPhoneStatusModifiedTime == null ? system.now() : newPhoneStatusModifiedTime;
                        sObj.put(getPhoneStatusModifiedDateField(blankPhoneFieldAPI), newPhoneStatusModifiedTime);

                        countAdded ++;
                        continue;
                    }
                }
                newAdditionalPhonesMap.put(additionalPhone, additionalPhonesMap.get(additionalPhone));
            }
        }
        String newAdditionalPhonesStr = createAdditionalPhoneString (newAdditionalPhonesMap.values());
        sObj.put('Additional_Phones__c', newAdditionalPhonesStr == '' ? null : newAdditionalPhonesStr);
    }
    /*******************************************************************************
    *  Name            : getAdditionalPhonesMap (sObject sObj)
    *  Summary         : get a set of numbers from Additional_Phones__c field
    *  Parameters      : sObject sObj - on which the Additional_Phones__c field is
    *  Returns         : Map <String, String> - map of additional phones - phone number => all phone info item
    ******************************************************************************/
    public static Map <String, String> getAdditionalPhonesMap (sObject sObj) {
        Map <String, String> ret = new Map <String, String> ();
        List <String> additionalPhonesItems =  sObj == null || sObj.get('Additional_Phones__c') == null ? new List <String> ()
                                            : String.valueOf(sObj.get('Additional_Phones__c')).split('\\.');
        if (additionalPhonesItems.isEmpty()) return ret; 
        for (String additionalPhoneItem : additionalPhonesItems) {
            String phoneNumber = additionaPhonelItem_getPhone (additionalPhoneItem);
            ret.put(phoneNumber, additionalPhoneItem);
        }
        //system.debug('getAdditionalPhonesMap ' + ret);
        return ret;
    }
    /*******************************************************************************
    *  Name            : additionaPhonelItem_getPhone (String additionaPhonelItem)
    *  Summary         : get a phone value from additional phone item in Additional_Phones__c field (additional item example: '+782156845254!DO!0,2!2104201919')
    *  Parameters      : String additionaPhonelItem from Additional_Phones__c field
    *  Returns         : String - phone number value from additional phone item in the Additional_Phones__c field
    ******************************************************************************/
    public static String additionaPhonelItem_getPhone (String additionaPhonelItem) {
        if (additionaPhonelItem == null || additionaPhonelItem == '') return null;
        return additionaPhonelItem.split('!')[0];
    }
    /*******************************************************************************
    *  Name            : additionaPhonelItem_getStatus (String additionaPhonelItem)
    *  Summary         : get a status value from additional phone item in Additional_Phones__c field (additional item example: '+782156845254!DO!0,2!2104201919')
    *  Parameters      : String additionaPhonelItem from Additional_Phones__c field
    *  Returns         : String - phone status from additional phone item in the Additional_Phones__c field
    ******************************************************************************/
    public static String additionaPhonelItem_getStatus (String additionaPhonelItem) {
        if (additionaPhonelItem == null || additionaPhonelItem == '') return null;
        try {
            String phoneStatusAbbreviation = additionaPhonelItem.split('!')[1];
            String statusName = getPhoneStatusAbbreviationTranslation (phoneStatusAbbreviation);
            return statusName;
        } catch (Exception ex) {
            return '';
        }
    }
    /*******************************************************************************
    *  Name            : additionaPhonelItem_getRating (String additionaPhonelItem)
    *  Summary         : get rating value from additional phone item in Additional_Phones__c field (additional item example: '+782156845254!DO!0,2!2104201919')
    *  Parameters      : String additionaPhonelItem from Additional_Phones__c field
    *  Returns         : String - phone rating from additional phone item in the Additional_Phones__c field
    ******************************************************************************/
    public static String additionaPhonelItem_getRating (String additionaPhonelItem) {
        if (additionaPhonelItem == null || additionaPhonelItem == '') return null;
        try {
            String phoneRating = additionaPhonelItem.split('!')[2];
            return phoneRating;
        } catch (Exception ex) {
            return '';
        }
    }
    /*******************************************************************************
    *  Name            : additionalPhonelItem_getRating_Number (String additionaPhonelItem)
    *  Summary         : get rating value from additional phone item in Additional_Phones__c field (additional item example: '+782156845254!DO!0,2!2104201919')
    *  Parameters      : String additionaPhonelItem from Additional_Phones__c field
    *  Returns         : Double - phone rating in Double number format from additional phone item in the Additional_Phones__c field
    ******************************************************************************/
    public static Double additionalPhonelItem_getRating_Number (String additionaPhonelItem) {
        String additionaPhoneRating = additionaPhonelItem_getRating(additionaPhonelItem);
        return additionaPhoneRating == null || additionaPhoneRating == '' ? null : rating_formatToDouble(additionaPhoneRating);
    }
    /*******************************************************************************
    *  Name            : rating_formatToString (Double additionaPhonelItem)
    *  Summary         : format rating from double to string
    *  Parameters      : Double - rating value in Double format
    *  Returns         : String - phone rating in String number format
    ******************************************************************************/
    public static String rating_formatToString (Double ratingVal) {
        if (ratingVal == null) return '';
        return String.valueOf(ratingVal).replace('.', ',');
    }
    /*******************************************************************************
    *  Name            : rating_formatToString (String additionaPhonelItem)
    *  Summary         : format rating from string to double
    *  Parameters      : String - rating value in String format
    *  Returns         : Double - phone rating in Double number format
    ******************************************************************************/
    public static Double rating_formatToDouble (String ratingVal) {
        if (ratingVal == null || ratingVal == '') return null;
        return Double.valueOf(ratingVal.replace(',', '.'));
    }
    /*******************************************************************************
    *  Name            : additionaPhonelItem_getModifiedDate_DateTime (String irrelevantItem)
    *  Summary         : get a DateTime value from additional phone item in Additional_Phones__c field
    *  Parameters      : String additionalPhoneItem from Additional_Phones__c field
    *  Returns         : DateTime - additional phone status modified date and time as DateTime format
    ******************************************************************************/
    public static String getAdditionalPhonelItemByPhone (sObject sObj, String phoneNumber, Boolean withExtension) {
        if (phoneNumber == null || phoneNumber == '') return null;
        Map <String, String> processingAdditionalPhonesMap = getAdditionalPhonesMap (sObj);
        if (!processingAdditionalPhonesMap.isEmpty()) {
            for (String additionalPhoneNumber : processingAdditionalPhonesMap.keySet()) {
            // unify format of the phone to look for matches
                String unifiedNum_AdditionalPhone = getUnifiedRuNumber (additionalPhoneNumber);
                String unifiedNum_callPhoneNumber = getUnifiedRuNumber (phoneNumber);
            // trim phone number and remove extension if we need to look for the number match without the phone extension
                String formattedNum_AdditionalPhone = trimPhoneNumber (unifiedNum_AdditionalPhone, withExtension);
                String formattedNum_callPhoneNumber = trimPhoneNumber (unifiedNum_callPhoneNumber, withExtension);
                if (formattedNum_AdditionalPhone == formattedNum_callPhoneNumber) { // phone number is found
                    return processingAdditionalPhonesMap.get(additionalPhoneNumber);
                }
            }
        }
        return null;
    }
    /*******************************************************************************
    *  Name            : additionaPhonelItem_getModifiedDate_DateTime (String additionalPhoneItem)
    *  Summary         : get a DateTime value from additional phone item in Additional_Phones__c field
    *  Parameters      : String additionalPhoneItem from Additional_Phones__c field
    *  Returns         : DateTime - additional phone status modified date and time as DateTime format
    ******************************************************************************/
    public static DateTime additionaPhonelItem_getModifiedDate_DateTime (String additionalPhoneItem) {
        if (additionalPhoneItem == null || additionalPhoneItem == '') return null;
        try {
            String phoneModifiedDateItem = additionalPhoneItem.split('!')[3];
            return getFormattedModifiedDateTime (phoneModifiedDateItem);
        } catch (Exception ex) {
            return null;
        }
    }
    /*******************************************************************************
    *  Name            : createAdditionalPhoneString (List <String> additionalPhonesSet)
    *  Summary         : creates a String value for Additional_Phones__c field from a list of phone numbers
     *  Parameters      : List <String> - from which we create a String
    *  Returns         : String - phones list in one String
    ******************************************************************************/
    public static String createAdditionalPhoneString (List <String> additionalPhonesList) {
       if (additionalPhonesList == null || additionalPhonesList.isEmpty()) return '';
       String ret = String.join (additionalPhonesList, '.');
       if (ret.length()  > 255) throw new PhonesException (Label.exception_Phones_TooManyAdditionalPhones);
       return ret;
    }
    /*******************************************************************************
    *  Name            : createAdditionalPhoneItemString (String phoneNumber, String phoneStatus, String phoneRating)
    *  Summary         : create a string of an additional phone item for Additional_Phones__c field
    *  Parameters      : String phoneNumber - a first item of the string, String phoneStatus - a second item of the string, String phoneRating - the 3rd item of teh string
    *  Returns         : String - a string of an additional phone item (ex.: '+782156845254!DO!2104201919')
    ******************************************************************************/
    public static String createAdditionalPhoneItemString (String phoneNumber, String phoneStatus, String phoneRating, String phoneModifiedDate) {
        if (phoneNumber == null || phoneNumber == '') return '';
        if (phoneStatus == null) phoneStatus = ''; 
        if (phoneRating == null) phoneRating = ''; 
        if (phoneModifiedDate == null) phoneModifiedDate = ''; 
        if (phoneStatus.length() > 5) phoneStatus = getPhoneStatusAbbreviationTranslation(phoneStatus);
        return phoneNumber+'!'+phoneStatus+'!'+phoneRating+'!'+phoneModifiedDate;
    }
// ------------------- GET BLANK FIELDS ---------------------------------------------------------    
    /*******************************************************************************
    *  Name            : getBlankPhoneFieldsAPIs (sObject sObj)
    *  Summary         : checks if there are blank phone fields on the record. If there are, add them to a list
    *  Parameters      : sObject sObj - on which we check if there are blanc phone fields
    *  Returns         : List <String> - a list of blank phone fields
    ******************************************************************************/
    public static List <String> getBlankPhoneFieldsAPIs (sObject sObj) {
        List <String> ret = new List <String> ();
        List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObj.getSObjectType(), 'All_Phone_Fields');
        for (String existingPhoneFieldAPI : phoneFieldsAPIs) {
            if (existingPhoneFieldAPI.contains('.') || existingPhoneFieldAPI == 'Additional_Phones__c') continue;
            Boolean numberIsNull = sObj.get(existingPhoneFieldAPI) == null || String.valueOf(sObj.get(existingPhoneFieldAPI)).deleteWhiteSpace() == '';
        // the phone number is blank
            if (numberIsNull) {
                ret.add(existingPhoneFieldAPI);
            } else {
        // if it is a "Phone" field with an irrelevant phone status, then change phone number to one of numbers from additional phones field
                if (existingPhoneFieldAPI == 'Phone') {
                    String existingFieldStatusAPI = getPhoneStatusField(existingPhoneFieldAPI);
                    String statusOnExistingField = sObj.get(existingFieldStatusAPI) == null ? null
                                                : String.valueOf(sObj.get(existingFieldStatusAPI));
                    if (statusOnExistingField != null && statusOnExistingField.startsWith('Wrong number')) {
                        // the "Phone" field number is irrelevant. we count it as blank
                        ret.add(existingPhoneFieldAPI);
                    }
                }
            }
        }
        return ret;
    }
// ------------------- PHONE PARSING ---------------------------------------------------------
    /*******************************************************************************
    *  Name            : parsePhoneNumber(ParsePhoneResult parsePhoneResult, sObject sObj, sObject oldSObj, String fieldAPI, String phoneNumber)
    *  Summary         : parseValue entered in a phone field
    *  Parameters      : ParsePhoneResult parsePhoneResult - previous result of parsing to add them to new parsing results (if exists)
                         sObject sObj - on which the number was entered,  sObject oldSObj - an old version of the record,
                         String fieldAPI - a record on which the number was entered, String phoneNumber - entered value
    *  Returns         : ParsePhoneResult - wrapper of phone fields, addtional phones and new contacts, which were filled while parsing
    ******************************************************************************/
    public static ParsePhoneResult parsePhoneNumber (ParsePhoneResult parsePhoneResult, sObject sObj, sObject oldSObj, String fieldAPI, String phoneNumber) {
        system.debug('>>> in >>> parsePhoneNumber : ' + fieldAPI + ' ' + phoneNumber);
        String phoneNumberOrig = phoneNumber;
        ParsePhoneResult ret = parsePhoneResult != null ? parsePhoneResult : new ParsePhoneResult (); // type (Contact or RecordField) => PhoneWrapper
        String fieldAPIStatus = getPhoneStatusField (fieldAPI);
        if (sObj.getSObjectType() != Schema.Account.sObjectType) {
            phoneNumber = saveTextInDescription (sObj, fieldAPI, phoneNumber); // if there is text then add it to the Description field
        }
        system.debug('phone number no text : ' + phoneNumber);
        system.debug('description : ' + sobj.get('Description'));

        if (phoneNumber == null) {
            ret.phoneWrappersMap.put(fieldAPI, new PhoneWrapper (sObj, oldSObj, fieldAPI, null, null, true));
            return ret;
        }
            List<String> phonesList = new List <String> {phoneNumber};
            phonesList = splitListOfNumbersBySymbol (':', phonesList);
            phonesList = splitListOfNumbersBySymbol (';', phonesList);
            phonesList = splitListOfNumbersBySymbol (',', phonesList);
            phonesList = splitListOfNumbersBySymbol ('\\.', phonesList);
            phonesList = splitListOfNumbersBySymbol ('/', phonesList);

            Integer lastItemIndex = 0;
    // case 1: there were a few phone numbers entered
            if (phonesList.size() > 1) {
                system.debug('more than 1 phone entered');
                Boolean currentFieldIsUsed = false;
                for (Integer i = 0; i < phonesList.size(); i++) {
                    lastItemIndex = i;
                    String phoneNum = phonesList[i];
                    if (phoneNum == '') continue;
                    phoneNum = phoneNum.trim();
                    system.debug('phoneNum : ' + phoneNum);

                    if (!phoneNum.startsWith('+') && phoneNum.deleteWhiteSpace().length() == 10)
                        phoneNum = '+7' + phoneNum;
                    else if (phoneNum.startsWith('7') && phoneNum.deleteWhiteSpace().length() == 11)
                        phoneNum = '+' + phoneNum;

                    if (!isPhoneNumberValid (phoneNum)) { // one of the numbers was entered in a wrong format
                        system.debug('phone Needs manual validation : ' + phoneNum);
                        ret.phoneWrappersMap.put(fieldAPI, new PhoneWrapper (sObj, oldSObj, fieldAPI, phoneNumber, 'Needs validation', true));
                        ret.needsValidation = true;
                        return ret;
                    } else { // add phone value item to empty phone fields
                        system.debug('phone number is valid');
                        Boolean phoneFieldFound = false;
                        if (sObj.getSObjectType() != Schema.Account.sObjectType) {
                            List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(sObj.getSObjectType(), 'All_Phone_Fields');
                            for (String phoneFieldAPI : phoneFieldsAPIs) {
                                if(phoneFieldAPI != 'Additional_Phones__c') {
                                    if ((sObj.get(phoneFieldAPI) == null || fieldAPI == phoneFieldAPI ) // phone field is empty or value was entered to the field
                                        && (!ret.phoneWrappersMap.containsKey(phoneFieldAPI) || ret.phoneWrappersMap.get(phoneFieldAPI).phoneNumber == null)) // add phone item if the phone field is empty
                                    { // add phone item if it is a field in which the numbers list was entered
                                        //save on phone field
                                        if (fieldAPI == phoneFieldAPI) currentFieldIsUsed = true;
                                        system.debug('save parsed phone item on phone field : ' + phoneFieldAPI + ' ' + phoneNum);
                                        ret.phoneWrappersMap.put(phoneFieldAPI, new PhoneWrapper (sObj, oldSObj, phoneFieldAPI, phoneNum, 'New', true)); // unable to parse automatically
                                        phoneFieldFound = true;
                                        break;
                                    }
                                }
                            }
                        }
                        if (!phoneFieldFound) {
                            // save additional number
                            String phoneModifiedDateToday = getModifiedDate_Formatted (system.now());
                            String additionalPhoneItem = createAdditionalPhoneItemString (phoneNum, 'New', '', phoneModifiedDateToday); // add new additional  phone with an empty rating (while parsing)
                            ret.newAdditionalPhones.put(phoneNum, additionalPhoneItem);
                        }
                    }
                }
                if (!currentFieldIsUsed) { // the field from which we parsed the number isn't filled
                    ret.phoneWrappersMap.put(fieldAPI, new PhoneWrapper (sObj, oldSObj, fieldAPI, null, null, true));
                }
            }

    // case 2: there was only 1 number entered
            else {
                system.debug('1 phone number entered');
                String phoneTovalidate = phonesList[0];

                if (!phoneTovalidate.startsWith('+') && phoneTovalidate.deleteWhiteSpace().length() == 10)
                    phoneTovalidate = '+7' + phoneTovalidate;
                else if (phoneTovalidate.startsWith('7') && phoneTovalidate.deleteWhiteSpace().length() == 11)
                    phoneTovalidate = '+' + phoneTovalidate;

                if (sObj.getSObjectType() == Schema.Account.sObjectType) {
                    String phoneModifiedDateToday = getModifiedDate_Formatted (system.now());
                    String additionalPhoneItem = createAdditionalPhoneItemString (phoneTovalidate, 'New', '', phoneModifiedDateToday); // add new additional  phone with an empty rating (while parsing)
                    ret.newAdditionalPhones.put(phoneTovalidate, additionalPhoneItem);
                } else {
                    if (!isPhoneNumberValid (phoneTovalidate)) { // one of the numbers was entered in a wrong format
                        system.debug('phone Needs manual validation : ' + phoneTovalidate);
                        ret.phoneWrappersMap.put(fieldAPI, new PhoneWrapper (sObj, oldSObj, fieldAPI, phoneNumber, 'Needs validation', true));
                        ret.needsValidation = true;
                        return ret;
                    }
                    ret.phoneWrappersMap.put(fieldAPI, new PhoneWrapper (sObj, oldSObj, fieldAPI, phoneTovalidate, 'New', true)); // unable to parse automatically
                }
            }
            /*
// !!! tmp for parsing accounts
        if (sObj.getSObjectType() == Schema.Account.sObjectType) {
           ret.phoneWrappersMap.put(fieldAPI, new PhoneWrapper (sObj, oldSObj, fieldAPI, null, null, true));
            Id accId = (Id) sObj.get('Id');
            String accName = accNames.get(accId);
            Id accOwnerId = (Id) sObj.get('OwnerId');
            Set<String> phonesFromRelatedContacts = relatedContactsPhones.containsKey(accId) ? relatedContactsPhones.get(accId) : new Set <String>();
            // 1) remove duplicates
            if (!ret.newAdditionalPhones.isEmpty() && !phonesFromRelatedContacts.isEmpty()) {
                for (String phoneNumItem : ret.newAdditionalPhones) {
                    if(phonesFromRelatedContacts.contains(trimPhoneNumber (phoneNumItem, true))) ret.newAdditionalPhones.remove(phoneNumItem);
                }
            }
            // 2) create new contact record
            if (!ret.newAdditionalPhones.isEmpty()) { // there are phones after removin duplicates
                List <String> additionalPhonesList = new List<String> (ret.newAdditionalPhones);
                system.debug('save additional numbers on a Contact');
                Contact newRelatedCon = new Contact (
                            OwnerId = accOwnerId,
                            AccountId = accId,
                            LastName = accName.left(80),
                            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId()
                );
                List<String> phoneFieldsAPIs = GlobalUtils.getFieldSetMembersAPIs(Contact.Schema.SObjectType, 'All_Phone_Fields');
                for (Integer i = 0; i < additionalPhonesList.size(); i++) {
                    String phoneFieldAPI = phoneFieldsAPIs[i];
                    String phoneNumberCon = saveTextInDescription (newRelatedCon, phoneFieldAPI, additionalPhonesList[i]); // if there is text then add it to the Description field
                    newRelatedCon.put(phoneFieldAPI, phoneNumberCon);
                    String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
                    String conPhoneStatus = isPhoneNumberValid (phoneNumberCon) ? 'New' : 'Needs validation';
                    newRelatedCon.put(phoneStatusFieldAPI, conPhoneStatus); // set phone status
                    // if we use the merthod again we have to think of adding a phone rating here the same way as in other cases when we set a phone status value
                    String statusModifiedDateField = getPhoneStatusModifiedDateField(phoneFieldAPI);
                    newRelatedCon.put(statusModifiedDateField, system.today()); // set phone status modified date
                }
                ret.newContactsMap.put(accId, newRelatedCon); // !!! tmp for parsing accounts
            }
        }
    */
// !!! end of tmp for parsing accounts
        system.debug('parsing result : ' + ret);
        return ret;
    }
    /*******************************************************************************
    *  Name            : getPhoneStatusField (String phoneFieldAPI)
    *  Summary         : get phone status field API by phone field API
    *  Parameters      : String phoneFieldAPI - phone field API for which the status field API will be returned
    *  Returns         : String - API of the phone status field
    ******************************************************************************/
    public static String getPhoneStatusField (String phoneFieldAPI) {
        if (phoneFieldAPI.contains('.')) return null;
        if (phoneFieldAPI == 'Additional_Phones__c')  return null;
        return phoneFieldAPI.replace('__c','')+'_Status__c';
    }
    /*******************************************************************************
    *  Name            : getPhoneStatusModifiedDateField (String phoneFieldAPI)
    *  Summary         : get phone status field API by phone field API
    *  Parameters      : String phoneFieldAPI - phone field API for which the status field API will be returned
    *  Returns         : String - API of the phone status modified date field
    ******************************************************************************/
    public static String getPhoneStatusModifiedDateField (String phoneFieldAPI) {
        if (phoneFieldAPI.contains('.')) return null;
        if (phoneFieldAPI == 'Additional_Phones__c')  return null;
        return phoneFieldAPI.replace('__c','')+'_StatusModifiedDate__c';
    }
    /*******************************************************************************
    *  Name            : getPhoneRatingField (String phoneFieldAPI)
    *  Summary         : get phone rating field API by phone field API
    *  Parameters      : String phoneFieldAPI - phone field API for which the status field API will be returned
    *  Returns         : String - API of the phone status modified date field
    ******************************************************************************/
    public static String getPhoneRatingField (String phoneFieldAPI) {
        if (phoneFieldAPI.contains('.')) return null;
        if (phoneFieldAPI == 'Additional_Phones__c')  return null;
        return phoneFieldAPI.replace('__c','')+'_Rating__c';
    }
    /*******************************************************************************
    *  Name            : countPhoneRating (Integer currentRatingVal, String phoneStatus)
    *  Summary         : count new phone rating depending on the phone status
    *  Parameters      : sObject sObject record for which the rating is being counted, String phoneFieldAPI - phone field api, 
                         String phoneStatus - new phone status value
    *  Returns         : Integer - new value of the rating
    ******************************************************************************/
    public static Double countPhoneRating (sObject sObj, String phoneFieldAPI, String phoneStatus) {
        if (phoneStatus == null) return null;
        system.debug('>>> countPhoneRating >> ' + phoneFieldAPI);
        Double currentRatingVal = phoneFieldAPI == null || sObj.get(getPhoneRatingField(phoneFieldAPI)) == null ? 1 
                                 : Double.valueOf(sObj.get(getPhoneRatingField(phoneFieldAPI)));
        return getNewPhoneRatingVal (currentRatingVal, phoneStatus);
    }
    /*******************************************************************************
    *  Name            : getNewPhoneRatingVal (Double currentRatingVal, String phoneStatus)
    *  Summary         : get new phone rating value depending on the phone status
    *  Parameters      : Double currentRatingVal - current value of the phone rating, String phoneStatus - new phone status value
    *  Returns         : Integer - new value of the rating
    ******************************************************************************/
    public static Double getNewPhoneRatingVal (Double currentRatingVal, String phoneStatus) {
        system.debug('>>> in >>> getNewPhoneRatingVal : currentRatingVal: ' + currentRatingVal + ' phoneStatus : '  + phoneStatus);
        if (phoneStatus == null) return null;
        currentRatingVal = currentRatingVal == null ? 1 : currentRatingVal;
        Double newRatingVal;
        if (phoneStatus.startsWith('Successful dialing')) {
            newRatingVal = currentRatingVal + 0.2;
        } else if (phoneStatus == 'New' || phoneStatus == 'Needs validation') {
            newRatingVal = null;
        } else if (phoneStatus == 'Dial out') {
            newRatingVal = currentRatingVal - 0.2;
        } else if (phoneStatus == 'CTI Wrong number:0') {
            newRatingVal = currentRatingVal - 0.2;
        } else if (phoneStatus == 'CTI System Error') {
            newRatingVal = currentRatingVal - 0.1;
        } else if (phoneStatus.startsWith('Wrong number')) {
            newRatingVal = 0;
        } else {
            newRatingVal = currentRatingVal;
        }
        system.debug('newRatingVall: ' + newRatingVal);
        return newRatingVal < 0 ? 0
                                : newRatingVal > 1 ? 1 
                                : newRatingVal;
    }
    /*******************************************************************************
    *  Name            : saveTextInDescription (sObject sObj, String phoneNumber)
    *  Summary         : if there was a text entered in a phoneField then save text in Description and leave number in the phone field
    *  Parameters      : sObject sObj - on which the number was entered, String phoneNumber - entered value with text
    *  Returns         : String - phone number without text which was saved in the Description field
    ******************************************************************************/
    private static String saveTextInDescription (sObject sObj, String phoneFieldAPI, String phoneNumber) {
        system.debug('looking for text in : ' + phoneFieldAPI + ' : ' + phoneNumber);
        String numberVal = phoneNumber.trim();
        String text;

        if (numberVal.contains('доб.')) numberVal = numberVal.replace('доб.', '#');
        if (numberVal.contains('доб')) numberVal = numberVal.replace('доб', '#');

        String[] chars = numberVal.split('');
        Integer startTextIndex;
        Integer endTextIndex;
        Integer startNumberIndex;
        Integer endNumberIndex;
        Integer lastIndex = chars.size() - 1;
        for (Integer i = 0; i <= lastIndex; i++) {
            // text is found
            if (chars[i].isAlpha()) { // text is starting
                if (startTextIndex == null) startTextIndex = i; // first letter
            // phone number is found
            } else if (chars[i].isNumeric() // number is starting from a digit
             || (chars[i] == '+' && i+1 < lastIndex && chars[i+1].isNumeric()) // number is starting from '+'
            ) {
                // number is starting
                if (startNumberIndex == null) startNumberIndex = i; // first number or '+'
                else if(endTextIndex != null && (i-endTextIndex) > 4) return phoneNumber; // cannot parse because there is text and a few numbers (numbers length is longer than 3)
                if (startTextIndex != null && endTextIndex == null) endTextIndex = i;
            }
            // is number characters are finished then set index of phone number end
            if (startNumberIndex != null && endNumberIndex == null) {
                if (i == lastIndex && isPhoneNumberCharacter(chars[i])) {
                    endNumberIndex = i; // the last character is a phone number character
                }
                if (i != 0 && !isPhoneNumberCharacter(chars[i]) && isPhoneNumberCharacter(chars[i-1])) {
                    endNumberIndex = i-1; // if the character is not a number or space then number is finished
                }
            }
        }
        if (startTextIndex != null) {
            Integer numberLength = startNumberIndex != null && endNumberIndex != null ? 1 + endNumberIndex - startNumberIndex : 0;
            if (numberLength == 0 // only text was entered
            || numberLength < 4)  { // or number is too small (0-3 characters) and we count it as a part of the text
                numberVal = null;
                text = phoneNumber;
            } else if (startNumberIndex > 0 && endNumberIndex < lastIndex - 1) { // there are not numeric symbols before the number and after
                system.debug('the number is in the middle. Manual validation is needed');
                numberVal = phoneNumber;
                text = null;
            } else {
                String baseNumberVal = numberVal;
                if (startNumberIndex == 0) {
                    // text is entered after the number
                    numberVal = baseNumberVal.substring(0, endNumberIndex+1);
                    text = baseNumberVal.substring(endNumberIndex+1, lastIndex+1);
                } else {
                    // text is entered before the number
                    numberVal = baseNumberVal.substring(startNumberIndex, lastIndex+1);
                    text = baseNumberVal.substring(0, startNumberIndex);
                }
            }
            text = text == null ? null : text.trim();
        }
        if (numberval != null) {
            //SF-1293 start
            String replaceToChar = (sObj.getSObjectType() == Schema.Lead.sObjectType) ? '' : ' ';
            numberVal = numberVal.replace('(',replaceToChar).replace(')',replaceToChar).replace('-',replaceToChar);
            //SF-1293 end
            numberVal = numberVal.trim();
            if (numberVal.endsWith('#')) numberVal = numberVal.replace('#', '');
            numberVal = numberVal.normalizeSpace(); // remove extra whitespaces

            if (!numberVal.startsWith('+') && numberVal.deleteWhiteSpace().length() == 10)
                numberVal = '+7' + numberVal;
            else if (numberVal.startsWith('7') && numberVal.deleteWhiteSpace().length() == 11)
                numberVal = '+' + numberVal;
        }
        system.debug('numberVal : ' + numberVal);
        system.debug('text : ' + text);

        if (!isPhoneNumberValid (numberVal)) return phoneNumber; // if phone is not valid then leave it as it was

        if (text != null) {
            // the phone was extracted and it's valid
            system.debug('save all text in Description');
            addDescription (sObj, phoneFieldAPI, text); // if phone is valid and there is text then save text in description
        }
        return numberVal;
    }
    /*******************************************************************************
    *  Name            : isPhoneNumberCharacter (String character)
    *  Summary         : checks if it is a phone number character. if not - returns false
    *  Parameters      : String character - a character from a phone number which is being checked
    *  Returns         : Boolean: true if it is a phone number character, otherwise - false
    ******************************************************************************/
    public static Boolean isPhoneNumberCharacter (String character) {
        Set <String> allowedCharacters = new Set <String> {'(', ')', '-', ' ', '#'};
        return character.isNumeric() || allowedCharacters.contains(character);
    }
    /*******************************************************************************
    *  Name            : addDescription (sObject sObj, String addString)
    *  Summary         : add description to a current value of the object
    *  Parameters      : sObject sObj - the object on which we add description, String addString - the string to add in the description
    *  Returns         : void
    ******************************************************************************/
    public static void addDescription (sObject sObj, String phoneFieldAPI, String text) {
        String currentDescription = sObj.get('Description') == null ? '' : String.valueOf(sObj.get('Description'));
        String fieldLabel = getMap_fieldsTranslations().containsKey(phoneFieldAPI) ? getMap_fieldsTranslations().get(phoneFieldAPI)
                          : phoneFieldAPI;
        sObj.put('Description', currentDescription+' ['+fieldLabel+':'+text+']');
    }

// ------------------- PHONE FORMATTING AND PROCESSING ---------------------------------------------------------
    /*******************************************************************************
    *  Name            : trimPhoneNumber(String phoneNumber, Boolean withExtension)
    *  Summary         : format Number in a way to store it in a list: removes whitespaces; removes Extension (optional)
   *  Parameters      : String phoneNumber - which we need to format, Boolean withExtension - if true then leave an extension number, if false then remove it
    *  Returns         : String - formatted value of the phone number
    ******************************************************************************/
    public static String trimPhoneNumber (String phoneNumber, Boolean withExtension) {
        if (!withExtension) phoneNumber = phoneNumber.split('#')[0]; // remove extension from the number
        return phoneNumber.replace(' ', ''); // get a phone number only without whitespaces
    }
    /*******************************************************************************
    *  Name            : getPhoneExtension(String phoneNumber)
    *  Summary         : get phone extension from phone number value
    *  Parameters      : String phoneNumber - from which we get the extension
    *  Returns         : String - phone extension
    ******************************************************************************/
    public static String getPhoneExtension (String phoneNumber) {
        try {
            String phoneExtension = phoneNumber.split('#')[1]; // get extension from the number
            return phoneExtension.replace(' ', '');
        } catch (Exception ex){
            return null;
        }
    }
    /*******************************************************************************
    *  Name            : isPhoneNumberValid (String phoneNumber)
    *  Summary         : checks if the format of ohone number is valid
    *  Parameters      : String phoneNumber - phone number which we need to check
    *  Returns         : String - formatted value of the phone number
    ******************************************************************************/
    public static Boolean isPhoneNumberValid (String phoneNumber) {
        if (String.isBlank(phoneNumber)) return true;
        if (!phoneNumber.startsWith('+')&& !phoneNumber.startsWith('8')) return false;
        Integer minLength =  phoneNumber.startsWith('+7') || phoneNumber.startsWith('8') ? 11 : 8;
        Integer maxLength =  phoneNumber.startsWith('+7') || phoneNumber.startsWith('8') ? 11 : 15;
        if (phoneNumber.startsWith('+')) phoneNumber = phoneNumber.replaceFirst('\\+', '');
        if (phoneNumber.containsWhitespace()) phoneNumber = phoneNumber.deleteWhitespace();
        if (phoneNumber.contains('#')) {
            if (phoneNumber.indexOf('#') < minLength) return false; // check if the number is too short
            if (phoneNumber.indexOf('#') > maxLength) return false; // check if the number is too long
            phoneNumber = phoneNumber.replace('#', '');
        } else {
            if (phoneNumber.length() < minLength) return false; // check if the number is too short
            if (phoneNumber.length() > maxLength) return false; // check if the number is too long
        }
        if (!phoneNumber.isNumeric()) return false;
        return true;
    }
    /*******************************************************************************
    *  Name            : splitListOfNumbersBySymbol (String symbolToSplit, String phoneVal)
    *  Summary         : gets a list of entered phone numbers with separator
    *  Parameters      : String symbolToSplit - separator character, String phoneVal - entered value with separators
    *  Returns         : List<String> - list of phones which were separated by the separator character
    ******************************************************************************/
    public static List<String> splitListOfNumbersBySymbol (String symbolToSplit, List<String> phoneVals) {
        List<String> ret = new  List<String> ();
        for (String phoneVal : phoneVals) {
            if (!phoneVal.contains(symbolToSplit.unescapeUnicode())) {
               ret.add(phoneVal);
            } else {
               for(String splitVal : phoneVal.split(symbolToSplit)) {
                   if (splitVal != '') ret.add(splitVal);
               }
            }
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : generateOtherCountryCodeRU (String phoneNumber)
    *  Summary         : generates the same number with another variation of russian countrycode
    *  Parameters      : String phoneNumber - current phone number
    *  Returns         : String - the phone number with another variation of russian countrycode
    ******************************************************************************/
    public static String generateOtherCountryCodeRU (String phoneNumber) {
        if (phoneNumber == null) return null;
        String phoneNumber_OtherCountryCodeRU = phoneNumber.startsWith('+7') && trimPhoneNumber (phoneNumber, false).length() == 12 ? phoneNumber.replaceFirst('\\+7', '8')
                                              : phoneNumber.startsWith('8') && trimPhoneNumber (phoneNumber, false).length() == 11 ? phoneNumber.replaceFirst('8', '+7')
                                              : null;
        return phoneNumber_OtherCountryCodeRU;
    }
    /*******************************************************************************
    *  Name            : getUnifiedRuNumber (String phoneNumber)
    *  Summary         : returns the number with the +7 code if it is a Russian number
    *  Parameters      : String phoneNumber - current phone number
    *  Returns         : String - number with the +7 code if it is a Russian number
    ******************************************************************************/
    public static String getUnifiedRuNumber (String phoneNumber) {
        return phoneNumber == null ? null
             : phoneNumber.startsWith('8') && trimPhoneNumber (phoneNumber, false).length() == 11 ?  generateOtherCountryCodeRU (phoneNumber)
             : phoneNumber;
    }
    /*******************************************************************************
    *  Name            : getNumberInNaumenFormat (String phoneNumber)
    *  Summary         : returns the number starting from '+7'
    *  Parameters      : String phoneNumber - current phone number
    *  Returns         : String - number with the +7 code if it is a Russian number
    ******************************************************************************/
    public static String getNumberInNaumenFormat (String phoneNumber) {
        if (phoneNumber == null) return null;
        String unifiedNum = getUnifiedRuNumber (phoneNumber);
        String phoneNumNoSpaces = trimPhoneNumber (unifiedNum, false);
        if (phoneNumNoSpaces.startsWith('7') && phoneNumNoSpaces.length() == 11)  return '+' + phoneNumNoSpaces;
        if (!phoneNumNoSpaces.startsWith('+') && phoneNumNoSpaces.length() == 10)  return '+7' + phoneNumNoSpaces;
        if(!isPhoneNumberValid (phoneNumNoSpaces)) return null;
        return phoneNumNoSpaces;
        /*return phoneNumNoSpaces.startsWith('+7') && phoneNumNoSpaces.length() == 12 ?  phoneNumNoSpaces.replaceFirst('\\+', '')
             : phoneNumNoSpaces.startsWith('8') && phoneNumNoSpaces.length() == 11 ?  phoneNumNoSpaces.replaceFirst('8', '7')
             : !phoneNumNoSpaces.startsWith('+') && phoneNumNoSpaces.length() == 10 ?  '7' + phoneNumNoSpaces
             : phoneNumNoSpaces;
        */
    }
    /*******************************************************************************
    *  Name            : preventEmptyLeadPhoneField (String phoneNumber)
    *  Summary         : throw an Exception if the "Phone" field on the lead is not filled
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void preventSavingEmptyLeadPhoneField () {
        String errMsg = Label.exception_EmptyField;
        String phoneFieldLabel = Schema.Lead.Phone.getDescribe().getLabel();
        errMsg = errMsg.replace('{0}', phoneFieldLabel);
        system.debug('!!! error: ' + errMsg);
        if (isUIuser()) { // show ui users an error in case if the value was duplicated not in additional phones list
            addUIError(errMsg, true);
        } else {
            throw new PhonesException (errMsg);
        }
    }
}