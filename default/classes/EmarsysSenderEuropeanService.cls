public class EmarsysSenderEuropeanService {
    public static final String EMAIL = '3';
    public static final String OPTIN = '31';
    public static final String TYPE = '10992';
    public static final String LASTMODIFIEDDATE = '11334';
    public static final String REQUESTEDTYPEOFTHECARD = '12414';
    public static final String CATEGORYOFPRODUCTS = '12415';
    public static final String USEREXTENSION = '12401';
    public static final String STARTSREPEMAIL = '14131';
    public static final String STARTSREPNAME = '14130';
    public static final String STARTSREPPHONE = '14162';
    public static final String MOBILE = '37';
    public static Map<String, Emarsys_fields_sync_lead__c> leadFieldsMap;
    public static Map<String, Emarsys_fields_sync_opportunity__c> opportunityFieldsMap;
    public static String currentSObjectsType;
    public static Map<Id, SObject> sObjectsMap;
    public static Map<Id, OpportunityContactRole> contactRolesMap;
    public static List<Id> sObjectsToUpdateIdsList;
    public static Map<Id, List<Tankkarten__c>> tankkartensMap;
    public static Set<Id> groupMembersIdsSet;
    public static Map<Id, User> userOwnersMap;
    public static Map<Id, User> startsRepsMap;
    public static Map<String, Mobile_Phone_Prefixes__c> mobilePhonePrefixes;
    public static Boolean isMobilePhoneValid;


    /*******************************************************************************
    *  Name            : setMapping(String sObjectsType)
    *  Summary         : set field mapping between SF SObjects and Emarsys contacts from custom setting
    *  CreatedDate     : 09/08/2017
    *  Parameters      : String sObjectsType
    *  Returns         : void
    ******************************************************************************/
    public static void setMapping(String sObjectsType) {
        currentSObjectsType = sObjectsType;
        if (currentSObjectsType == 'Lead') {
            leadFieldsMap = Emarsys_fields_sync_lead__c.getall();
            if (leadFieldsMap == null) {
                throw new EmarsysException('Lead mapping does not exist.');
            }
        } else if (currentSObjectsType == 'Opportunity') {
            opportunityFieldsMap = Emarsys_fields_sync_opportunity__c.getall();
            if (opportunityFieldsMap == null) {
                throw new EmarsysException('Opportunity mapping does not exist.');
            }
        }
        validateMapping();
    }


    /*******************************************************************************
    *  Name            : validateMapping()
    *  Summary         : mapping should not be null
    *  CreatedDate     : 09/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void validateMapping() {
        if (leadFieldsMap != null) {
            for (String field : leadFieldsMap.keySet()) {
                if (leadFieldsMap.get(field).Emarsys_field_id__c == null) {
                    throw new EmarsysException('Lead mapping has an empty field.');
                }
            }
        }

        if (opportunityFieldsMap != null) {
            for (String field : opportunityFieldsMap.keySet()) {
                if (opportunityFieldsMap.get(field).Emarsys_field_id__c == null) {
                    throw new EmarsysException('Opportunity mapping has an empty field.');
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : generateJsonBody(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : generate JSON body for request to Emarsys
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - map of old SObject values,
                        Map<Id, SObject> newMap - map of new SObject values
    *  Returns         : String
    ******************************************************************************/
    public static String generateJsonBody(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        getRelatedFieldsFromMapping(newMap);
        groupMembersIdsSet = getGroupMembers();
        getUserOwnersMap(newMap);
        String jsonBody = '{"key_id":"' + EMAIL + '","contacts":[';
        sObjectsToUpdateIdsList = new List<Id>();
        if (currentSObjectsType == 'Lead') {
            mobilePhonePrefixes = Mobile_Phone_Prefixes__c.getAll();
            if (oldMap != null) {
                jsonBody += generateJsonLeadUpdate(oldMap, newMap);
            }
        } else if (currentSObjectsType == 'Opportunity') {
            Set<Id> opportunityIdsSet = new Set<Id>();
            Set<Id> startsRepsIdsSet = new Set<Id>();
            for (SObject currentSObject : newMap.values()) {
                opportunityIdsSet.add(String.valueOf(currentSObject.get('Id')));
                if (currentSObject.get('Starts_Rep__c') != null) {
                    startsRepsIdsSet.add(String.valueOf(currentSObject.get('Starts_Rep__c')));
                }
            }

            getStartsReps(startsRepsIdsSet);
            getOpportuintyContactRoles(opportunityIdsSet);
            getTankkartens(opportunityIdsSet);
            jsonBody += generateJsonOpportunityUpdate(oldMap, newMap);
        }

        if (jsonBody != '{"key_id":"' + EMAIL + '","contacts":[') {
            jsonBody = jsonBody.replace('\r\n', '\\n');
            jsonBody = jsonBody.replace('\n', '\\n');
            jsonBody = jsonBody.replace('\r', '\\n');
            jsonBody = jsonBody.removeEnd(',');
            jsonBody += ']}';
            return jsonBody;
        } else {
            return '';
        }
    }


    /*******************************************************************************
    *  Name            : getRelatedFieldsFromMapping(Map<Id, SObject> newMap)
    *  Summary         : get related fields for json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Map<Id, SObject> newMap - old SObject values
    *  Returns         : void
    ******************************************************************************/
    private static void getRelatedFieldsFromMapping(Map<Id, SObject> newMap) {
        String fields = '';
        if (currentSObjectsType == 'Opportunity') {
            for (String field : opportunityFieldsMap.keySet()) {
                if (field.contains('Account.')) {
                    fields += field + ', ';
                }
            }
        }

        fields = fields.removeEnd(', ');
        if (fields != '') {
            Set<Id> sObjectIdsSetForSelect = newMap.keySet();
            String query = 'SELECT ' + fields + ' FROM ' + currentSObjectsType + ' WHERE Id IN :sObjectIdsSetForSelect LIMIT 10000';
            List<SObject> sObjectsList = Database.query(query);
            sObjectsMap = new Map<Id, SObject>();
            for (SObject currentSObject : sObjectsList) {
                sObjectsMap.put(currentSObject.Id, currentSObject);
            }
        }
    }


    /*******************************************************************************
    *  Name            : getGroupMembers()
    *  Summary         : get group members to change owner domain in json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : -
    *  Returns         : Set<Id>
    ******************************************************************************/
    private static Set<Id> getGroupMembers() {
        List<GroupMember> groupMembersList = [
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.Name = 'Emarsys CHDE-DE-AT'];
        groupMembersIdsSet = new Set<Id>();
        for (GroupMember gm : groupMembersList) {
            groupMembersIdsSet.add(gm.UserOrGroupId);
        }

        if (! groupMembersIdsSet.isEmpty()) {
            return groupMembersIdsSet;
        } else {
            throw new EmarsysException('There are no Group Members for Emarsys.');
        }
    }


    /*******************************************************************************
    *  Name            : getUserOwnersMap(Map<Id, sObject> newMap)
    *  Summary         : get map with user owners for put extension in json
    *  CreatedDate     : 17/08/2017
    *  Parameters      : Map<Id, SObject> newMap - new SObjects List
    *  Returns         : void
    ******************************************************************************/
    private static void getUserOwnersMap(Map<Id, SObject> newMap) {
        Set<Id> userOwnersIdsSet = new Set<Id>();
        for (SObject currentSObject : newMap.values()) {
            if (String.valueOf(currentSObject.get('OwnerId')).substring(0, 3) == '005') {
                userOwnersIdsSet.add(String.valueOf(currentSObject.get('OwnerId')));
            }
        }

        if (! userOwnersIdsSet.isEmpty()) {
            String fields = '';
            if (currentSObjectsType == 'Lead') {
                for (String field : leadFieldsMap.keySet()) {
                    if (field.contains('Owner.')) {
                        fields += field.substringAfter('Owner.') + ', ';
                    }
                }
            } else if (currentSObjectsType == 'Opportunity') {
                for (String field : opportunityFieldsMap.keySet()) {
                    if (field.contains('Owner.')) {
                        fields += field.substringAfter('Owner.') + ', ';
                    }
                }
            }

            fields = fields.removeEnd(', ');
            if (fields != '') {
                String query = 'SELECT Extension, ' + fields + ' FROM User WHERE Id IN :userOwnersIdsSet LIMIT 10000';
                List<User> userOwnersList = Database.query(query);
                userOwnersMap = new Map<Id, User>();
                for (User user : userOwnersList) {
                    userOwnersMap.put(user.Id, user);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getStartsReps(Set<Id> startsRepsIdsSet)
    *  Summary         : get Starts Reps Email and Name fields from User object
    *  CreatedDate     : 30/08/2017
    *  Parameters      : Set<Id> startsRepsIdsSet - Ids of opportunities with Starts Rep
    *  Returns         : void
    ******************************************************************************/
    private static void getStartsReps(Set<Id> startsRepsIdsSet) {
        startsRepsMap = new Map<Id, User>([
                SELECT Email, Name, Phone
                FROM User
                WHERE Id IN :startsRepsIdsSet]);
    }


    /*******************************************************************************
    *  Name            : getOpportuintyContactRoles(Set<Id> parentSObjectsToUpdateIdsSet)
    *  Summary         : get contact roles for opportunity
    *  CreatedDate     : 10/08/2017
    *  Parameters      : parentSObjectsToUpdateIdsSet - set ids of parent sObjects to send
    *  Returns         : void
    ******************************************************************************/
    private static void getOpportuintyContactRoles(Set<Id> parentSObjectsToUpdateIdsSet) {
        String fields = '';
        String parentIdString = '';
        if (currentSObjectsType == 'Opportunity') {
            parentIdString = 'OpportunityId';
            for (String field : opportunityFieldsMap.keySet()) {
                if (field.contains('Contact.')) {
                    fields += field + ', ';
                }
            }
        }

        fields = fields.removeEnd(', ');
        if (fields != '') {
            String query = 'SELECT OpportunityId, ' + fields +
                    ' FROM OpportunityContactRole ' +
                    ' WHERE ' + parentIdString +' IN :parentSObjectsToUpdateIdsSet AND IsPrimary = true LIMIT 10000';
            List<OpportunityContactRole> opportunityContactRolesList = Database.query(query);
            contactRolesMap = new Map<Id, OpportunityContactRole>();
            for (OpportunityContactRole opportunityContactRole : opportunityContactRolesList) {
                contactRolesMap.put(opportunityContactRole.OpportunityId, opportunityContactRole);
            }
        }
    }


    /*******************************************************************************
    *  Name            : getTankkartens(Set<Id> opportunityIdsSet)
    *  Summary         : get Tankkarten fields for json
    *  CreatedDate     : 10/08/2017
    *  Parameters      : opportunityIdsSet - set ids of opportunities to send
    *  Returns         : void
    ******************************************************************************/
    private static void getTankkartens(Set<Id> opportunityIdsSet) {
        List<Tankkarten__c> tankkartensList = [
                SELECT Gewuenschter_Kartentyp__c, Produktbezugskategorie__c, Opportunity__c
                FROM Tankkarten__c
                WHERE Opportunity__c IN :opportunityIdsSet];
        tankkartensMap = new Map<Id, List<Tankkarten__c>>();
        for (Tankkarten__c tankkarten : tankkartensList) {
            if (! tankkartensMap.containsKey(tankkarten.Opportunity__c)) {
                tankkartensMap.put(tankkarten.Opportunity__c, new List<Tankkarten__c>());
            }

            tankkartensMap.get(tankkarten.Opportunity__c).add(tankkarten);
        }
    }


    /*******************************************************************************
    *  Name            : generateJsonLeadUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : generate json body for request before lead udapte
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - map of old lead values,
                        Map<Id, SObject> newMap - list of new lead values
    *  Returns         : String
    ******************************************************************************/
    private static String generateJsonLeadUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        String jsonBody = '';
        Boolean isNeedToSendCurrent;
        for (SObject currentSObject : newMap.values()) {
            Lead lead = (Lead) currentSObject;
            isNeedToSendCurrent = getStatusOfNeedToSend(oldMap.get(lead.id), lead);
            if (isNeedToSendCurrent) {
                sObjectsToUpdateIdsList.add(lead.Id);
                String leadFields = prepareLeadFields(lead);
                jsonBody += leadFields;
                if (leadFields == '') {
                    if(sObjectsToUpdateIdsList.indexof(lead.id) != -1){
                        sObjectsToUpdateIdsList.remove(sObjectsToUpdateIdsList.indexof(lead.id));
                    }
                }
            }
        }

        return jsonBody;
    }


    /*******************************************************************************
    *  Name            : checkLeadUpdateLogic(Map<Id, SObject> oldMap, Lead lead)
    *  Summary         : check need to send lead
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - old Leads values, Lead lead - new Lead value
    *  Returns         : Boolean
    ******************************************************************************/
    /*  public static Boolean checkLeadUpdateLogic(SObject oldLead, SObject newLead) {
         for (String field : leadFieldsMap.keySet()) {
             if ((! field.contains('.')) && oldLead.get(field) != newLead.get(field)) {
                 return true;
             } else if((field == 'Monatlicher_Kraftstoffverbrauch_in_L.') &&
                     oldLead.get('Monatlicher_Kraftstoffverbrauch_in_Liter__c') != newLead.get('Monatlicher_Kraftstoffverbrauch_in_Liter__c') ){
                 return true;
             }
         }
         return false;
     }
     */

    /*******************************************************************************
    *  Name            : generateJsonOpportunityUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : generate json body for request before opportunity udapte
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - map of old opportunity values,
                        Map<Id, SObject> newMap - map of new opportunity values
    *  Returns         : String
    ******************************************************************************/
    private static String generateJsonOpportunityUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        String jsonBody = '';
        Boolean isNeedToSendCurrent;
        String currentUserName = UserInfo.getName();
        for (SObject currentSObject : newMap.values()) {
            Opportunity opportunity = (Opportunity) currentSObject;
            isNeedToSendCurrent = false;
            if (oldMap == null) {
                isNeedToSendCurrent = true;
            } else if (contactRolesMap.get(opportunity.Id) != null && contactRolesMap.get(opportunity.Id).Contact.Email != null) {
                isNeedToSendCurrent = getStatusOfNeedToSend(oldMap.get(opportunity.Id), opportunity);
            }
            if (isNeedToSendCurrent) {
                sObjectsToUpdateIdsList.add(opportunity.Id);
                String opportunityFields = prepareOpportunityFields(opportunity, currentUserName);
                jsonBody += opportunityFields;
                if (opportunityFields == '') {
                    if(sObjectsToUpdateIdsList.indexof(opportunity.id) != -1){
                        sObjectsToUpdateIdsList.remove(sObjectsToUpdateIdsList.indexof(opportunity.id));
                    }
                }
            }
        }

        return jsonBody;
    }


    /*******************************************************************************
    *  Name            : checkOpportunityUpdateLogic(Map<Id, SObject> oldMap, Opportunity opportunity)
    *  Summary         : check need to send opportunity
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - old Leads values, Opportunity opportunity - new Opportunity value
    *  Returns         : Boolean
    ******************************************************************************/
    /* public static Boolean checkOpportunityUpdateLogic(SObject oldOpportunity, SObject newOpportunity) {
          for (String field : opportunityFieldsMap.keySet()) {
              if ((! field.contains('.')) && oldOpportunity.get(field) != newOpportunity.get(field)) {
                  return true;
              }
          }
          return false;
      }
  */

    /*******************************************************************************
    *  Name            : prepareLeadFields(Lead lead)
    *  Summary         : prepare fields for json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Lead lead - new Lead values
    *  Returns         : String
    ******************************************************************************/
    private static String prepareLeadFields(Lead lead) {
        String finalOwnerEmail = prepareOwnerEmail(lead);
        String mobilePhone = prepareMobilePhone(lead);
        String jsonBody = '';
        if (finalOwnerEmail != '') {
            jsonBody += '{';
            for (String field : leadFieldsMap.keySet()) {
                if (! field.contains('.')) {
                    jsonBody += '"' + leadFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(String.valueOf(lead.get(field))) + '", ';
                } else {
                    if (field.contains('Owner.') && field != 'Owner.Email' && userOwnersMap.get(lead.OwnerId) != null) {
                        jsonBody += '"' + leadFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                checkNull(String.valueOf(userOwnersMap.get(lead.OwnerId).get(field.substringAfter('.')))) + '", ';
                    } else if (field == 'Owner.Email') {
                        jsonBody += '"' + leadFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(finalOwnerEmail) + '", ';
                    } else if (field == 'Monatlicher_Kraftstoffverbrauch_in_L.'){
                        jsonBody += '"' + leadFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(String.valueOf(lead.get('Monatlicher_Kraftstoffverbrauch_in_Liter__c'))) + '", ';
                    }
                }
            }

            if (lead.Status != 'Konvertierte Leads' && lead.ConvertedOpportunityId == null) {
                jsonBody += '"' + TYPE + '":"Lead", ';
            } else {
                jsonBody += '"' + TYPE + '":"Opportunity", ';
            }

            if (userOwnersMap != null && userOwnersMap.get(lead.OwnerId) != null) {
                jsonBody += '"' + USEREXTENSION + '":"' + checkNull(userOwnersMap.get(lead.OwnerId).Extension) + '", ';
            }

            jsonBody += '"' + LASTMODIFIEDDATE + '":"' + lead.LastModifiedDate + '",' +
                    '"' + MOBILE + '":"' + mobilePhone + '", ' +
                    '"' + OPTIN + '":"1"' +
                    '},';
            jsonBody = jsonBody.replaceAll('true', '1');
            jsonBody = jsonBody.replaceAll('false', '2');
        }
        return jsonBody;
    }


    /*******************************************************************************
    *  Name            : prepareOpportunityFields(Opportunity opportunity)
    *  Summary         : prepare fields for json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Opportunity opportunity - new Opportunity value, String currentUserName - name of user who runs trigger
    *  Returns         : String
    ******************************************************************************/
    public static String prepareOpportunityFields(Opportunity opportunity, String currentUserName) {
        String jsonBody = '';
        String finalOwnerEmail = prepareOwnerEmail(opportunity);
        String finalStartsRepEmail = prepareStartsRepEmail(opportunity);
        String mobilePhone = prepareOpportunityMobilePhone(opportunity);
        if (finalOwnerEmail != '' || finalStartsRepEmail != '') {
            jsonBody += '{';
            for (String field : opportunityFieldsMap.keySet()) {
                if (! field.contains('.')) {
                    jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(String.valueOf(opportunity.get(field))) + '", ';
                } else {
                    if (field.contains('Owner.') && field != 'Owner.Email' && userOwnersMap.get(opportunity.OwnerId) != null && currentUserName != 'FleetcorEmea Site Guest User') {
                        jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                checkNull(String.valueOf(userOwnersMap.get(opportunity.OwnerId).get(field.substringAfter('.')))) + '", ';
                    } else if (field.contains('Account.') && Opportunity.AccountId != null) {
                        String value = checkNull(String.valueOf(sObjectsMap.get(opportunity.Id).getSobject(field.substringBefore('.')).get(field.substringAfter('.'))));


                        jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                value + '", ';

                        if (field == 'Account.UMR__c') {
                            Blob keyAES256 = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
                            Blob data = Blob.valueOf(value);
                            Blob encryptedValue = Crypto.encryptWithManagedIV('AES256', keyAES256, data);
                            String encodedValue = EncodingUtil.base64Encode(encryptedValue);
                            jsonBody += '"23558":"' + encodedValue + '", ';
                        }
                    } else if (field.contains('Contact.')) {
                        if (contactRolesMap.get(opportunity.Id) != null) {
                            jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                    checkNull(String.valueOf(contactRolesMap.get(opportunity.Id).getSobject(field.substringBefore('.')).get(field.substringAfter('.')))) + '", ';
                        } else {
                            return '';
                        }
                    } else if (field == 'Owner.Email' && currentUserName != 'FleetcorEmea Site Guest User') {
                        jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(finalOwnerEmail) + '", ';
                    }
                }
            }

            if (userOwnersMap != null && userOwnersMap.get(opportunity.OwnerId) != null && currentUserName != 'FleetcorEmea Site Guest User') {
                jsonBody += '"' + USEREXTENSION + '":"' + checkNull(userOwnersMap.get(opportunity.OwnerId).Extension) + '", ';
            }

            if (startsRepsMap != null && startsRepsMap.get(opportunity.Starts_Rep__c) != null && currentUserName != 'FleetcorEmea Site Guest User') {
                jsonBody += '"' + STARTSREPEMAIL + '":"' + finalStartsRepEmail + '", "' + STARTSREPNAME + '":"' + checkNull(startsRepsMap.get(opportunity.Starts_Rep__c).Name) + '", ' +
                        '"' + STARTSREPPHONE + '":"' + checkNull(startsRepsMap.get(opportunity.Starts_Rep__c).Phone) + '", ';
            }

            if(mobilePhone != ''){
                jsonBody += '"' + MOBILE + '":"' + mobilePhone + '", ';
            }
            jsonBody += '"' + REQUESTEDTYPEOFTHECARD + '":"' + checkNull(returnTypeOfTheCard(opportunity)) + '", ' +
                    '"' + CATEGORYOFPRODUCTS + '":"' + checkNull(returnProductCategory(opportunity)) + '",' +
                    '"' + LASTMODIFIEDDATE + '":"' + opportunity.LastModifiedDate + '", ' +
                    '"' + TYPE + '":"Opportunity", ' +
                    '"' + OPTIN + '":"1"' +
                    '},';
            jsonBody = jsonBody.replaceAll('true', '1');
            jsonBody = jsonBody.replaceAll('false', '2');
            return jsonBody;
        } else {
            return '';
        }
    }

    private static String prepareOpportunityMobilePhone(Opportunity opportunity){
        String resultMobilePhone = '';
        String phone = '';
        String mobilePhone = '';
        if(Emarsys_fields_sync_opportunity__c.getAll().get('Contact.Phone') != null && contactRolesMap.containsKey(opportunity.Id))
            phone = checkNull(String.valueof(contactRolesMap.get(opportunity.Id).getSobject('Contact').get('Phone')));
        if(Emarsys_fields_sync_opportunity__c.getAll().get('Contact.MobilePhone') != null && contactRolesMap.containsKey(opportunity.Id))
            mobilePhone = checkNull(String.valueof(contactRolesMap.get(opportunity.Id).getSobject('Contact').get('MobilePhone')));

        if(countryMobileRegex.keySet().contains(opportunity.Registered_Country__c)){
            if(checkMobilePhoneFormat(mobilePhone, opportunity.Registered_Country__c)){
                resultMobilePhone = mobilePhone;
            }
            else if(checkMobilePhoneFormat(phone, opportunity.Registered_Country__c)){
                resultMobilePhone = phone;
            }
        }
        else if (mobilePhone != '') {
            resultMobilePhone = mobilePhone;
        } else {
            resultMobilePhone = phone;
        }

        return resultMobilePhone;
    }


    public static Boolean checkMobilePhoneFormat(String mobilePhone, String country){
        Boolean isValid = false;
        String regexMobile = countryMobileRegex.get(country);
        Pattern regexPattern = Pattern.compile(regexMobile);
        Matcher regexMatcher = regexPattern.matcher(mobilePhone);
        if(regexMatcher.matches() && regexMatcher.groupCount() == 3){
            isValid = true;
        }
        return isValid;
    }

    public static Map<String, String> countryMobileRegex = new Map<String, String>{
            'Germany' => '^(49|\\+49|0049)(15[0-9]{3}|(?!1609)16[0-9]{2}|(?!176[0-9]{1})17[0-9]{2})([0-9]{6})$',
            'Netherlands' => '^(31|\\+31|0031)(61|62|63|64|65|68)([0-9]{7})$',
            'Belgium-FR' => '^(32|\\+32|0032)(460|467|468|47[0-9]{1}|48[0-9]{1}|49[0-9]{1})([0-9]{6})$',
            'Belgium-NL' => '^(32|\\+32|0032)(460|467|468|47[0-9]{1}|48[0-9]{1}|49[0-9]{1})([0-9]{6})$',
            'Poland' => '^(48|\\+48|0048)(45|50|51|53|57|60|66|69|72|73|78|88)([0-9]{7})$',
            'Hungary' => '^(36|\\+36|0036)(20|30|31|70)([0-9]{6})$',
            'France' => '^(33|\\+33|0033)([1-9]{1})([0-9]{9})$'
    };

    /*******************************************************************************
    *  Name            : prepareOwnerEmail(SObject currentSObject)
    *  Summary         : prepare Owner Email with domain from static map
    *  CreatedDate     : 09/08/2017
    *  Parameters      : SObject currentSObject - sobject which owner email we use
    *  Returns         : String
    ******************************************************************************/
    private static String prepareOwnerEmail(SObject currentSObject) {
        String finalOwnerEmail = '';
        if (userOwnersMap != null && userOwnersMap.containsKey(String.valueOf(currentSObject.get('OwnerId'))) && userOwnersMap.get(String.valueOf(currentSObject.get('OwnerId'))).Email != null) {
            String domain = userOwnersMap.get(String.valueOf(currentSObject.get('OwnerId'))).Email.substringAfter('@');
            String userName = userOwnersMap.get(String.valueOf(currentSObject.get('OwnerId'))).Email.substringBefore('@');

            if (userName + '@' + domain == 'integration.administrator@fleetcor.ru' || userName + '@' + domain == 'integration.administrator@fleetcor.ru.invalid') {
                finalOwnerEmail = 'integration.administrator@fleetcor.ru';
            } else if (emarsysDomainsMap.containsKey(domain)) {
                if (groupMembersIdsSet.contains(String.valueOf(currentSObject.get('OwnerId')))) {
                    if (currentSObjectsType == 'Lead' && emarsysCountryToDomainMap.containsKey(String.valueOf(currentSObject.get('Country')))) {
                        finalOwnerEmail = userName + '@' + emarsysCountryToDomainMap.get(String.valueOf(currentSObject.get('Country')));
                    } else if (currentSObjectsType == 'Opportunity' && sObjectsMap.get(currentSObject.Id) != null && sObjectsMap.get(currentSObject.Id).getSobject('Account') != null &&
                            emarsysCountryToDomainMap.containsKey(String.valueOf(sObjectsMap.get(currentSObject.Id).getSobject('Account').get('BillingCountry')))) {
                        finalOwnerEmail = userName + '@' + emarsysCountryToDomainMap.get(String.valueOf(sObjectsMap.get(currentSObject.Id).getSobject('Account').get('BillingCountry')));
                    } else {
                        finalOwnerEmail = userName + '@' + emarsysDomainsMap.get(domain);
                    }
                } else {
                    finalOwnerEmail = userName + '@' + emarsysDomainsMap.get(domain);
                }
            }
        }

        return finalOwnerEmail;
    }


    /*******************************************************************************
    *  Name            : prepareStartsRepEmail(Opportunity opportunity)
    *  Summary         : prepare Starts Rep email with domain from static map
    *  CreatedDate     : 31/08/2017
    *  Parameters      : Opportunity opportunity - opportunity which starts rep email we use
    *  Returns         : String
    ******************************************************************************/
    private static String prepareStartsRepEmail(Opportunity opportunity) {
        String finalStartsRepEmail = '';
        if (opportunity.Starts_Rep__c != null && startsRepsMap.containsKey(opportunity.Starts_Rep__c)) {
            String domain = startsRepsMap.get(opportunity.Starts_Rep__c).Email.substringAfter('@');
            String userName = startsRepsMap.get(opportunity.Starts_Rep__c).Email.substringBefore('@');

            if (emarsysDomainsMap.containsKey(domain)) {
                if (groupMembersIdsSet.contains(opportunity.Starts_Rep__c)) {
                    if (sObjectsMap.get(opportunity.Id).getSobject('Account') != null &&
                            emarsysCountryToDomainMap.containsKey(String.valueOf(sObjectsMap.get(opportunity.Id).getSobject('Account').get('BillingCountry')))) {
                        finalStartsRepEmail = userName + '@' + emarsysCountryToDomainMap.get(String.valueOf(sObjectsMap.get(opportunity.Id).getSobject('Account').get('BillingCountry')));
                    } else {
                        finalStartsRepEmail = userName + '@' + emarsysDomainsMap.get(domain);
                    }
                } else {
                    finalStartsRepEmail = userName + '@' + emarsysDomainsMap.get(domain);
                }
            }
        }

        return finalStartsRepEmail;
    }


    /*******************************************************************************
    *  Name            : prepareMobilePhone(String phone)
    *  Summary         : prepare Mobile Phone with prefix from custom setting
    *  CreatedDate     : 29/11/2017
    *  ModifiedDate    : 29/11/2017
    *  Parameters      : Lead lead - current lead
    *  Returns         : String
    ******************************************************************************/
    private static String prepareMobilePhone(Lead lead) {
        String mobilePhone = '';
        if (lead.countryCode == 'PL') {
            if (lead.Is_Mobile_Phone_Valid__c == true) {
                mobilePhone = lead.Phone;
                Set<String> invalidCodesSet = new Set<String>{ '+48(0)', '0048', '48(0)', '00048', '48', '048', '0' };
                mobilePhone = removeExtraCharacters(lead.phone);
                for (String phoneCode : invalidCodesSet) {
                    if (mobilePhone.startsWith(phoneCode)) {
                        mobilePhone = mobilePhone.removeStart(phoneCode);
                    }
                }
                if (! mobilePhone.startsWith('+48')) {
                    mobilePhone = '+48' + mobilePhone;
                }
            }
        }
        return mobilePhone;
    }


    /*******************************************************************************
    *  Name            : RemoveExtraCharacters(String phone)
    *  Summary         : remove extra characters to check mobile prefix
    *  CreatedDate     : 29/11/2017
    *  ModifiedDate    : 29/11/2017
    *  Parameters      : String phone - phone number
    *  Returns         : String
    ******************************************************************************/
    public static String removeExtraCharacters(String phone) {
        if (phone.contains(' ')) {
            phone = phone.replace(' ', '');
        }
        if (phone.contains('-')) {
            phone = phone.replace('-', '');
        }
        if (phone.contains(',')) {
            phone = phone.replace(',', '');
        }
        if (phone.contains('.')) {
            phone = phone.replace('.', '');
        }

        return phone;
    }


    /*******************************************************************************
    *  Name            : returnTypeOfTheCard()
    *  Summary         : return type of the card for json
    *  CreatedDate     : 10/08/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private static String returnTypeOfTheCard(Opportunity opportunity) {
        String typeOfTheCard = '';
        Set<String> typesOfCardsSet = new Set<String>();
        if (tankkartensMap.get(opportunity.Id) != null && (! tankkartensMap.get(opportunity.Id).isEmpty())) {
            for (Tankkarten__c tankkarten : tankkartensMap.get(opportunity.Id)) {
                typesOfCardsSet.add(tankkarten.Gewuenschter_Kartentyp__c);
            }
        }

        if (typesOfCardsSet.contains('Multi Network Card -- International')) {
            typeOfTheCard = 'Multi Network Card -- International';
        } else if (typesOfCardsSet.contains('Multi Network Card -- National')) {
            typeOfTheCard = 'Multi Network Card -- National';
        } else if (typesOfCardsSet.contains('Single Network Card -- International')) {
            typeOfTheCard = 'Single Network Card -- International';
        } else if (typesOfCardsSet.contains('Single Network Card -- National')) {
            typeOfTheCard = 'Single Network Card -- National';
        }

        return typeOfTheCard;
    }


    /*******************************************************************************
    *  Name            : returnProductCategory()
    *  Summary         : return category of product for json
    *  CreatedDate     : 10/08/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private static String returnProductCategory(Opportunity opportunity) {
        String productCategory = '';
        Set<String> categoriesOfProductsSet = new Set<String>();
        if (tankkartensMap.get(opportunity.Id) != null && (! tankkartensMap.get(opportunity.Id).isEmpty())) {
            for (Tankkarten__c tankkarten : tankkartensMap.get(opportunity.Id)) {
                categoriesOfProductsSet.add(tankkarten.Produktbezugskategorie__c);
            }
        }

        if (categoriesOfProductsSet.contains('3 Kategorie 2 plus alle Shopartikel')) {
            productCategory = '3 Kategorie 2 plus alle Shopartikel';
        } else if (categoriesOfProductsSet.contains('2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)')) {
            productCategory = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
        } else if (categoriesOfProductsSet.contains('1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren')) {
            productCategory = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
        } else if (categoriesOfProductsSet.contains('0 Diesel, Tunnel-, Maut- und Fährgebühren')) {
            productCategory = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
        }

        return productCategory;
    }


    /*******************************************************************************
    *  Name            : getSObjectsToUpdateIdsSet()
    *  Summary         : get Sobjects to update Emarsys Id
    *  CreatedDate     : 21/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static List<Id> getSObjectsToUpdateIdsList() {
        return sObjectsToUpdateIdsList;
    }


    /*******************************************************************************
    *  Name            : sendCreatingContactsRequest(String jsonBody)
    *  Summary         : send request for creating contacts in Emarsys
    *  CreatedDate     : 09/08/2017
    *  Parameters      : String jsonBody - body with fields to send, String emarsysAccount - emarsys account name,
                         List<Id> sObjectsToUpdateIdsList - list for update emarsys id field, String currentSObjectsType - type of SObject
    *  Returns         : void
    ******************************************************************************/
    public static void sendRequest(String jsonBody, String emarsysAccount, List<Id> sObjectsToUpdateIdsList, String currentSObjectsType) {
        System.debug('DEBUG: JSON BODY === ' + jsonBody);
        HttpRequest request = EmarsysWebService.generateCreatingContactsRequest(jsonBody, emarsysAccount);
        Http http = new Http();
        HTTPResponse res = http.send(request);
        String responseBody = res.getBody();
        System.debug('DEBUG: RESPONSE BODY === ' + responseBody);
        try {
            if (responseBody.contains('"replyText":"Invalid JSON."')) {
                throw new EmarsysException('Invalid JSON');
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()) + '<br/>sObjects Ids: ' + sObjectsToUpdateIdsList + '<br/><br/>Request Body: ' + jsonBody + '<br/><br/>Response Body: ' + responseBody,
                    String.valueOf(e.getStackTraceString()));
        }
        if (res.getStatus() == 'OK') {
            updateSObjects(res.getBody(), sObjectsToUpdateIdsList, currentSObjectsType);
        }
    }


    /*******************************************************************************
    *  Name            : updateSObjects()
    *  Summary         : update SObjects after send
    *  CreatedDate     : 09/08/2017
    *  Parameters      : String responseBody - body from response, Set<Id> sObjectsToUpdateIdsList - list for update emarsys id field,
                        String currentSObjectsType - type of SObject
    *  Returns         : void
    ******************************************************************************/
    private static void updateSObjects(String responseBody, List<Id> sObjectsToUpdateIdsList, String currentSObjectsType) {
        EmarsysNewContactEntity entity = (EmarsysNewContactEntity) JSON.deserialize(responseBody, EmarsysNewContactEntity.class);
        Map<Id, SObject> sObjectsMap = new   Map<Id, SObject>();
        if (currentSObjectsType == 'Lead') {
            sObjectsMap.putAll([
                    SELECT Emarsys_Contact_Id__c
                    FROM Lead
                    WHERE Id IN :sObjectsToUpdateIdsList AND IsConverted = false]);
        } else if (currentSObjectsType == 'Opportunity') {
            sObjectsMap.putAll([
                    SELECT Emarsys_Contact_Id__c
                    FROM Opportunity
                    WHERE Id IN :sObjectsToUpdateIdsList AND IsClosed = false]);
        }

        List<SObject> sObjectsListToUpdate = new List<SObject>();
        if (!entity.data.ids.isEmpty() && entity.data.ids.size() == sObjectsMap.size()) {
            Integer n=0;
            for(Id sObjectId : sObjectsToUpdateIdsList){
                if (sObjectsMap.containsKey(sObjectId) && entity.data.ids[n] != null && sObjectsMap.get(sObjectId).get('Emarsys_Contact_Id__c') != String.valueOf(entity.data.ids[n])) {
                    sObjectsMap.get(sObjectId).put('Emarsys_Contact_Id__c', String.valueOf(entity.data.ids[n]));
                    sObjectsListToUpdate.add(sObjectsMap.get(sObjectId));
                }
                n++;
            }
        }

        if (! sObjectsListToUpdate.isEmpty()) {
            LeadHandler.enablesTrigger = false;
            OpportunityTriggerHandler.enablesTrigger = false;
            update sObjectsListToUpdate;
        }
    }


    /*******************************************************************************
    *  Name            : sendE2EOpportunityToEmarsys(String jsonBody)
    *  Summary         : send request to create/update E2E opportunity to Emarsys
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId - Id of E2E Opportunity to send
    *  Returns         : void
    ******************************************************************************/
    @future(callout=true)
    public static void sendE2EOpportunityToEmarsys(Id opportunityId) {
        Integration_Settings__c emarsysSettingEU = Integration_Settings__c.getInstance('Emarsys EU');
        if (emarsysSettingEU != null && emarsysSettingEU.Enabled__c) {
            // declare variables to use in catch block
            String jsonBody;
            String responseBody;
            try {
                // set and validate list of fields to send
                setMapping('Opportunity');

                // select values from database
                String fieldsStringForSQOL = 'Registered_Country__c, LastModifiedDate, AccountId, ';
                for (String field : opportunityFieldsMap.keySet()) {
                    if (! field.contains('.')) {
                        fieldsStringForSQOL += field + ', ';
                    }
                }

                Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>();
                if (fieldsStringForSQOL != '') {
                    fieldsStringForSQOL = fieldsStringForSQOL.removeEnd(', ');
                    String query = 'SELECT ' + fieldsStringForSQOL + ' FROM Opportunity WHERE Id = :opportunityId LIMIT 1';
                    opportunitiesMap = new Map<Id, Opportunity>((List<Opportunity>) Database.query(query));
                }

                // generate json body for request
                jsonBody = EmarsysSenderEuropeanService.generateJsonBody(null, opportunitiesMap);
                System.debug('DEBUG: REQUEST BODY === ' + jsonBody);

                // send request to Emarsys
                HttpRequest request = EmarsysWebService.generateCreatingContactsRequest(jsonBody, 'PPR_EU');
                Http http = new Http();
                HTTPResponse res = http.send(request);
                responseBody = res.getBody();
                System.debug('DEBUG: RESPONSE BODY === ' + responseBody);

                // update Opportunity with Emarsys contact Id
                if (res.getStatus() == 'OK') {
                    updateSObjects(res.getBody(), new List<Id>{opportunityId}, 'Opportunity');
                }

                if (responseBody.contains('"replyText":"Invalid JSON."')) {
                    throw new EmarsysException('Invalid JSON');
                }
            } catch (Exception e) {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()) + '<br> Opportunity Id: ' + opportunityId + '<br/><br/>Request Body: ' + jsonBody + '<br/><br/>Response Body: ' + responseBody,
                        String.valueOf(e.getStackTraceString()));
            }
        }
    }

    /*******************************************************************************
    *  Name            : getStatusOfNeedToSendToEmarsys
    *  Summary         : check for key fields is changed
    *  CreatedDate     : 18/02/2019
    *  Parameters      : Map<Id, SObject> oldMap, Map<Id, SObject> newMap
    *  Returns         : Boolean - is need to send record to Emarsys?
    ******************************************************************************/
    public static Boolean getStatusOfNeedToSend(SObject oldRecord, SObject newRecord){
        String sObjectsType = String.valueOf(newRecord.getSObjectType());
        if(sObjectsType == 'Lead'){
            if ((newRecord.get('Status') != 'Open' || newRecord.get('Status') == 'Open' && newRecord.get('Quali_Status__c') == 'Switched to E2E')
                    && newRecord.get('Email') != null){
                for (String field : leadFieldsMap.keySet()) {
                    if ((! field.contains('.')) && oldRecord.get(field) != newRecord.get(field)) {
                        return true;
                    } else if ((field == 'Monatlicher_Kraftstoffverbrauch_in_L.') &&
                            oldRecord.get('Monatlicher_Kraftstoffverbrauch_in_Liter__c') != newRecord.get('Monatlicher_Kraftstoffverbrauch_in_Liter__c')) {
                        return true;
                    }
                }
            }
        }
        else if(sObjectsType == 'Opportunity'){
            for (String field : opportunityFieldsMap.keySet()) {
                if ((! field.contains('.')) && oldRecord.get(field) != newRecord.get(field)) {
                    return true;
                }
            }
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : checkNull(String string)
    *  Summary         : replace null field with empty string
    *  CreatedDate     : 10/08/2017
    *  Parameters      : String field - field which we check on null
    *  Returns         : String
    ******************************************************************************/
    public static String checkNull(String field) {
        if (field == null) {
            field = '';
        }
        if (field.contains('ccs\\')) {
            field = field.replace('ccs\\', '');
        }
        if (field.contains('"')) {
            field = field.replace('"', '');
        }
        if (field.contains('\\')) {
            field = field.replace('\\', '');
        }
        if (field.contains('\t')) {
            field = field.replace('\t', ' ');
        }
        return field;
    }

    public static Map<String, String> emarsysDomainsMap = new Map<String, String>{
            'enway.co' => 'enway.co',
            'enway.com' => 'enway.com',
            'fleetcor.sk' => 'kontakt.fleetcor.sk',
            'fleetcor.de' => 'kontakt.fleetcor.de',
            'fleetcor.cz' => 'kontakt.fleetcor.cz',
            'fleetcor.ch' => 'kontakt.fleetcor.ch',
            'fleetcor.at' => 'kontakt.fleetcor.at',
            'fleetcorcards.be' => 'contact.fleetcorcards.be',
            'fleetcor.pl' => 'contact.fleetcor.pl',
            'fleetcor.nl' => 'contact.fleetcor.nl',
            'fleetcor.lu' => 'contact.fleetcor.lu',
            'fleetcor.hu' => 'contact.fleetcor.hu',
            'fleetcor.fr' => 'contact.fleetcor.fr',
            'it.fleetcor.ch' => 'contact-it.fleetcor.ch',
            'fr.fleetcor.ch' => 'contact-fr.fleetcor.ch',
            'fleetcor.eu' => 'contact.fleetcor.eu'
    };

    public static Map<String, String> emarsysCountryToDomainMap = new Map<String, String>{
            'Germany' => 'kontakt.fleetcor.de',
            'Austria' => 'kontakt.fleetcor.at',
            'Switzerland-DE' => 'kontakt.fleetcor.ch'
    };
}