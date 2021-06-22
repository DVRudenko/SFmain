public class EmarsysSenderRussianService {
    public static final String EMAIL = '3';
    public static final String OPTIN = '31';
    public static final String FROMSALESFORCE = '5990';
    public static final String ENDOFLEADSUBSCRIPTION = '8422';
    public static final String MOVED_TO_START = 'Moved to Start';
    public static Map<String, Emarsys_RU_fields_sync_lead__c> leadFieldsMap;
    public static Map<String, Emarsys_RU_fields_sync_opportunity__c> opportunityFieldsMap;
    public static Map<String, Emarsys_RU_fields_sync_contact__c> contactFieldsMap;
    public static String currentSObjectsType;
    public static Map<Id, SObject> sObjectsMap;
    public static Map<Id, User> userOwnersMap;
    public static Map<Id, OpportunityContactRole> contactRolesMap;
    public static List<Id> sObjectsToUpdateIdsList;
    public static List<Task> taskList;


    /*******************************************************************************
    *  Name            : setMapping(String sObjectsType)
    *  Summary         : set field mapping between SF SObjects and Emarsys contacts from custom setting
    *  CreatedDate     : 10/08/2017
    *  Parameters      : String sObjectsType
    *  Returns         : void
    ******************************************************************************/
    public static void setMapping(String sObjectsType) {
        currentSObjectsType = sObjectsType;
        if (currentSObjectsType == 'Lead') {
            leadFieldsMap = Emarsys_RU_fields_sync_lead__c.getall();
            if (leadFieldsMap == null) {
                throw new EmarsysException('Lead mapping does not exist.');
            }
        } else if (currentSObjectsType == 'Opportunity') {
            opportunityFieldsMap = Emarsys_RU_fields_sync_opportunity__c.getall();
            if (opportunityFieldsMap == null) {
                throw new EmarsysException('Opportunity mapping does not exist.');
            }
        } else if (currentSObjectsType == 'Contact') {
            contactFieldsMap = Emarsys_RU_fields_sync_contact__c.getall();
            if (contactFieldsMap == null) {
                throw new EmarsysException('Contact mapping does not exist.');
            }
        }
        validateMapping();
    }


    /*******************************************************************************
    *  Name            : validateMapping()
    *  Summary         : mapping should not be null
    *  CreatedDate     : 10/08/2017
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

        if (contactFieldsMap != null) {
            for (String field : contactFieldsMap.keySet()) {
                if (contactFieldsMap.get(field).Emarsys_field_id__c == null) {
                    throw new EmarsysException('Contact mapping has an empty field.');
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : generateJsonBody(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : generate JSON body for request to Emarsys
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - map of old SObject values,
    					Map<Id, SObject> newMap - map of new SObject values
    *  Returns         : String
    ******************************************************************************/
    public static String generateJsonBody(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        taskList = new List<Task>();
        sObjectsToUpdateIdsList = new List<Id>();
        getRelatedFieldsFromMapping(newMap);
        String jsonBody = '{"key_id":"' + EMAIL + '","contacts":[';
        if (currentSObjectsType == 'Lead') {
            getUserOwnersMap(newMap);
            if (oldMap != null) { //before update
                jsonBody += generateJsonLeadUpdate(oldMap, newMap);
            } else { //before insert
                jsonBody += generateJsonLeadInsert(newMap);
            }
        }
        else if (currentSObjectsType == 'Opportunity') {
            getUserOwnersMap(newMap);
            Set<Id> opportunityids = new Set<Id>();
            for (SObject currentSObject : newMap.values()) {
                opportunityids.add(String.valueOf(currentSObject.get('Id')));
            }
            getOpportuintyContactRoles(opportunityids);
            jsonBody += generateJsonOpportunityUpdate(oldMap, newMap);
        }
        else if (currentSObjectsType == 'Contact') {
            Set<Id> contactsIds = new Set<Id>();
            for (SObject currentSObject : newMap.values()) {
                contactsIds.add(String.valueOf(currentSObject.get('Id')));
            }
            getOpportuintyContactRoles(contactsIds);
            jsonBody += generateJsonContactUpdate(oldMap, newMap);
        }

        if (! taskList.isEmpty()) {
            //insert taskList;
        }

        if (jsonBody != '{"key_id":"' + EMAIL + '","contacts":[') {
            jsonBody = jsonBody.replace('\r\n', '\\n');
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
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> newMap - old SObject values
    *  Returns         : void
    ******************************************************************************/
    private static void getRelatedFieldsFromMapping(Map<Id, SObject> newMap) {
        String fields = '';

        if (currentSObjectsType == 'Opportunity') {
            for (String field : opportunityFieldsMap.keySet()) {
                if (field.contains('Owner.') || field.contains('Account.')) {
                    fields += field + ', ';
                }
            }
        }

        if (currentSObjectsType == 'Contact') {
            for (String field : contactFieldsMap.keySet()) {
                if (field.contains('Owner.') || field.contains('Account.')) {
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
            isNeedToSendCurrent =  getStatusOfNeedToSend(oldMap.get(lead.Id), lead);
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
    *  Name            : generateJsonLeadInsert(Map<Id, SObject> newMap)
    *  Summary         : generate json body for request before lead insert
    *  CreatedDate     : 10/08/2017
    *  Parameters      :Map<Id, SObject> newMap - list of new lead values
    *  Returns         : String
    ******************************************************************************/
    private static String generateJsonLeadInsert(Map<Id, SObject> newMap) {
        String jsonBody = '';
        Boolean isNeedToSendCurrent;
        for (SObject currentSObject : newMap.values()) {
            Lead lead = (Lead) currentSObject;
            isNeedToSendCurrent = getStatusOfNeedToSend(null, lead);
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
    *  Name            : checkLeadInsertLogic(Map<Id, SObject> oldMap, Lead lead)
    *  Summary         : check need to send lead
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Lead lead - new Lead value
    *  Returns         : Boolean
    ******************************************************************************/
   /* public static Boolean checkLeadInsertLogic(SObject lead) {
        if (lead.get('UTM_Source__c') == 'email_trigger') {
            return true;
        }

        return false;
    }
    */


    /*******************************************************************************
    *  Name            : generateJsonOpportunityUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : generate json body for request before opportunity udapte
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - map of old opportunity values,
    					Map<Id, SObject> newMap - list of new opportunity values
    *  Returns         : String
    ******************************************************************************/
    private static String generateJsonOpportunityUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        String jsonBody = '';
        Boolean isNeedToSendCurrent;
        for (SObject currentSObject : newMap.values()) {
            Opportunity opportunity = (Opportunity) currentSObject;
            isNeedToSendCurrent = false;
            if (contactRolesMap.containsKey(opportunity.Id) && contactRolesMap.get(opportunity.Id).Contact.Email != null) {
                isNeedToSendCurrent = getStatusOfNeedToSend(oldMap.get(opportunity.Id), opportunity);
            }

            if (isNeedToSendCurrent) {
                sObjectsToUpdateIdsList.add(opportunity.Id);
                String opportunityFields = prepareOpportunityFields(opportunity);
                jsonBody += opportunityFields;
                if (opportunityFields == '') {
                    if(sObjectsToUpdateIdsList.indexof(opportunity.id) != -1) {
                        sObjectsToUpdateIdsList.remove(sObjectsToUpdateIdsList.indexof(opportunity.id));
                    }
                }
            }
        }

        return jsonBody;
    }


    /*******************************************************************************
    *  Name            : generateJsonContactUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : generate json body for request before contact udapte
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Map<Id, SObject> oldMap - map of old contact values,
    					Map<Id, SObject> newMap - map of new contact values
    *  Returns         : String
    ******************************************************************************/
    private static String generateJsonContactUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        String jsonBody = '';
        Boolean isNeedToSendCurrent;
        for (SObject currentSObject : newMap.values()) {
            Contact contact = (Contact) currentSObject;
            isNeedToSendCurrent = getStatusOfNeedToSend(oldMap.get(contact.Id), contact);
            if(isNeedToSendCurrent) {
                sObjectsToUpdateIdsList.add(contactRolesMap.get(contact.Id).OpportunityId);
                String contactFields = prepareContactFields(contact);
                jsonBody += contactFields;
                if (contactFields == '') {
                    if(sObjectsToUpdateIdsList.indexof(contact.id) != -1) {
                        sObjectsToUpdateIdsList.remove(sObjectsToUpdateIdsList.indexof(contact.id));
                    }
                }
            }
        }

        return jsonBody;
    }


    /*******************************************************************************
    *  Name            : checkContactUpdateLogic(Map<Id, SObject> oldMap, Contact contact)
    *  Summary         : check need to send contact
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Contact contact - new contact value
    *  Returns         : Boolean
    ******************************************************************************/
   /* public static Boolean checkContactUpdateLogic(SObject oldContact, SObject newContact) {
        if (oldContact.get('Email') == null && newContact.get('Email') != null && contactRolesMap.containsKey(newContact.Id) &&
                contactRolesMap.get(newContact.Id).Opportunity.UTM_Source_Medium__c == 'email_trigger' &&
                contactRolesMap.get(newContact.Id).Opportunity.Emarsys_Contact_Id__c == null) {
            return true;
        }

        return false;
    }
*/

    /*******************************************************************************
    *  Name            : prepareLeadFields(Lead lead)
    *  Summary         : prepare fields for json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Lead lead - new Lead values,
    *  Returns         : String
    ******************************************************************************/
    private static String prepareLeadFields(Lead lead) {
        String jsonBody = '{';
        for (String field : leadFieldsMap.keySet()) {
            if (! field.contains('.')) {
                jsonBody += '"' + leadFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(String.valueOf(lead.get(field))) + '", ';
            } else {
                if (field.contains('Owner.') && field != 'Owner.Email' && userOwnersMap != null && userOwnersMap.get(lead.OwnerId) != null) {
                    jsonBody += '"' + leadFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                            checkNull(String.valueOf(userOwnersMap.get(lead.OwnerId).get(field.substringAfter('.')))) + '", ';
                }
            }
        }

        jsonBody += '"' + FROMSALESFORCE + '":"1", "' + OPTIN + '":"1"},';
        jsonBody = jsonBody.replaceAll('true', '1');
        jsonBody = jsonBody.replaceAll('false', '2');
        return jsonBody;
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
        } else if (currentSObjectsType == 'Contact') {
            parentIdString = 'ContactId';
            for (String field : contactFieldsMap.keySet()) {
                if (field.contains('Opportunity.')) {
                    fields += field + ', ';
                } else if (field.contains('Op.')) {
                    fields += 'Opportunity.' + field.removeStart('Op.') + ', ';
                }
            }
        }

        fields = fields.removeEnd(', ');
        if (fields != '') {
            String query = 'SELECT OpportunityId, ContactId, Opportunity.Emarsys_Contact_Id__c, IsPrimary, Opportunity.LeadSource, ' + fields +
                    ' FROM OpportunityContactRole WHERE ' + parentIdString +' IN :parentSObjectsToUpdateIdsSet LIMIT 10000';
            List<OpportunityContactRole> opportunityContactRolesList = Database.query(query);
            contactRolesMap = new Map<Id, OpportunityContactRole>();
            if (currentSObjectsType == 'Opportunity') {
                for (OpportunityContactRole opportunityContactRole : opportunityContactRolesList) {
                    if(opportunityContactRole.Opportunity.LeadSource == 'E2E Form RU'){
                        if(opportunityContactRole.IsPrimary){
                            contactRolesMap.put(opportunityContactRole.OpportunityId, opportunityContactRole);
                        }
                    } else {
                        contactRolesMap.put(opportunityContactRole.OpportunityId, opportunityContactRole);
                    }
                }
            } else if (currentSObjectsType == 'Contact') {
                for (OpportunityContactRole opportunityContactRole : opportunityContactRolesList) {
                    if(opportunityContactRole.Opportunity.LeadSource == 'E2E Form RU'){
                        if(opportunityContactRole.IsPrimary){
                            contactRolesMap.put(opportunityContactRole.ContactId, opportunityContactRole);
                        }
                    } else {
                        contactRolesMap.put(opportunityContactRole.ContactId, opportunityContactRole);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : prepareOpportunityFields(Opportunity opportunity)
    *  Summary         : prepare fields for json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Opportunity opportunity - new Opportunity values,
    *  Returns         : String
    ******************************************************************************/
    public static String prepareOpportunityFields(Opportunity opportunity) {
        String jsonBody = '{';
        for (String field : opportunityFieldsMap.keySet()) {
            if (! field.contains('.')) {
                jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(String.valueOf(opportunity.get(field))) + '", ';
            } else {
                if (field.contains('Owner.') && userOwnersMap != null && userOwnersMap.get(opportunity.OwnerId) != null) {
                    jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                            checkNull(String.valueOf(userOwnersMap.get(opportunity.OwnerId).get(field.substringAfter('.')))) + '", ';
                } else if(field.contains('Account.')){
                    jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                            checkNull(String.valueOf(sObjectsMap.get(opportunity.Id).getSobject(field.substringBefore('.')).get(field.substringAfter('.')))) + '", ';
                } else if (field.contains('Contact.')) {
                    if (sObjectsMap.get(opportunity.Id) != null) {
                        jsonBody += '"' + opportunityFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                checkNull(String.valueOf(contactRolesMap.get(opportunity.Id).getSobject(field.substringBefore('.')).get(field.substringAfter('.')))) + '", ';
                    } else {
                        return '';
                    }
                }
            }
        }

        jsonBody += '"' + FROMSALESFORCE + '":"1", "' + OPTIN + '":"1"},';
        jsonBody = jsonBody.replaceAll('true', '1');
        jsonBody = jsonBody.replaceAll('false', '2');
        return jsonBody;
    }

    /*******************************************************************************
    *  Name            : prepareTask(Opportunity opportunity)
    *  Summary         : create task on Opportunity
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Opportunity opportunity - parent object of task
    *  Returns         : Task
    ******************************************************************************/
    /*private static Task prepareTask(String opportunityId) {
        Task task = new Task(
                WhatId = opportunityId,
                ReminderDateTime = Date.today().addMonths(1),
                Subject = 'Перезвонить через месяц');
        return task;
    } */

    /*******************************************************************************
    *  Name            : prepareContactFields(Contact contact)
    *  Summary         : prepare fields for json
    *  CreatedDate     : 09/08/2017
    *  Parameters      : Contact contact - new contact values
    *  Returns         : String
    ******************************************************************************/
    private static String prepareContactFields(Contact contact) {
        String jsonBody = '{';
        for (String field : contactFieldsMap.keySet()) {
            if (! field.contains('.')) {
                jsonBody += '"' + contactFieldsMap.get(field).Emarsys_field_id__c + '":"' + checkNull(String.valueOf(contact.get(field))) + '", ';
            } else {
                if (field.contains('Owner.') || field.contains('Account.')) {
                    jsonBody += '"' + contactFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                            checkNull(String.valueOf(sObjectsMap.get(contact.Id).getSobject(field.substringBefore('.')).get(field.substringAfter('.')))) + '", ';
                } else if (field.contains('Opportunity.')) {
                    if (contactRolesMap.get(contact.Id) != null) {
                        jsonBody += '"' + contactFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                checkNull(String.valueOf(contactRolesMap.get(contact.Id).getSobject(field.substringBefore('.')).get(field.substringAfter('.')))) + '", ';
                    }
                } else if (field.contains('Op.')) {
                    if (contactRolesMap.get(contact.Id) != null) {
                        jsonBody += '"' + contactFieldsMap.get(field).Emarsys_field_id__c + '":"' +
                                checkNull(String.valueOf(contactRolesMap.get(contact.Id).getSobject('Opportunity').get(field.substringAfter('.')))) + '", ';
                    }
                }
            }
        }

        jsonBody += '"' + FROMSALESFORCE + '":"1", "' + OPTIN + '":"1"},';
        jsonBody = jsonBody.replaceAll('true', '1');
        jsonBody = jsonBody.replaceAll('false', '2');
        return jsonBody;
    }


    /*******************************************************************************
    *  Name            : getSsObjectsToUpdateIdsList()
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
    *  CreatedDate     : 10/08/2017
    *  Parameters      : String jsonBody - body with fields to send, String emarsysAccount - emarsys account name,
                         Set<Id> sObjectsToUpdateIdsList - list for update emarsys id field, String currentSObjectsType - type of SObject
    *  Returns         : void
    ******************************************************************************/
    public static void sendRequest(String jsonBody, String emarsysAccount, List<Id> sObjectsToUpdateIdsSet, String currentSObjectsType) {
        System.debug('DEBUG: JSON BODY === ' + jsonBody);
        HttpRequest request = EmarsysWebService.generateCreatingContactsRequest(jsonBody, emarsysAccount);
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('DEBUG: RESPONSE BODY === ' + res.getBody());
        if (res.getStatus() == 'OK') {
            updateSObjects(res.getBody(), sObjectsToUpdateIdsSet, currentSObjectsType);
        }
    }


    /*******************************************************************************
    *  Name            : updateSObjects(String responseBody)
    *  Summary         : update SObjects after send
    *  CreatedDate     : 10/08/2017
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
        } else if (currentSObjectsType == 'Opportunity' || currentSObjectsType == 'Contact') {
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
        return field;
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
    *  Name            : getStatusOfNeedToSendToEmarsys
    *  Summary         : check for key fields is changed
    *  CreatedDate     : 18/02/2019
    *  Parameters      : Map<Id, SObject> oldMap, Map<Id, SObject> newMap
    *  Returns         : Boolean - is need to send record to Emarsys?
    ******************************************************************************/
    public static Boolean getStatusOfNeedToSend(SObject oldRecord, SObject newRecord){
        String sObjectsType = String.valueOf(newRecord.getSObjectType());
        if(sObjectsType == 'Lead'){
            // Filter for prevent many requests to Emarsys (Emarsys have soft limits for callout per minute)
            if (newRecord.get('Email') != null) {
                if (oldRecord != null) { // Update Trigger
                    if ((newRecord.get('Status') != oldRecord.get('Status') && newRecord.get('Status') == 'DISQUALIFIED' && newRecord.get('Lead_Status_Specific__c') == 'Потерян в конкуренции/Цена') ||
                            (newRecord.get('Status') != oldRecord.get('Status') && newRecord.get('Status') == 'DISQUALIFIED' && (newRecord.get('Lead_Status_Specific__c') == 'Потерян в конкуренции/Отказ'|| newRecord.get('Lead_Status_Specific__c') == 'Rewards Programs/Rebates/Discounts')) ||
                            (newRecord.get('Status') != oldRecord.get('Status') && newRecord.get('Status') == 'Waiting INN') ||
                            (oldRecord.get('UTM_Source__c') == 'email_trigger' && oldRecord.get('Email') == null && newRecord.get('Email') != null
                                    && oldRecord.get('Emarsys_Contact_Id__c') == null)) {
                        return true;
                    } else if (oldRecord.get('Status') == 'Waiting INN' && newRecord.get('Status') != oldRecord.get('Status')) {
                        newRecord.put('End_Of_Subscription__c','Ожидание ИНН завершено');
                        return true;
                    }
                } else {               // Insert Trigger
                    if (newRecord.get('UTM_Source__c') == 'email_trigger') {
                        return true;
                    }
                }
            }
        }
        else if(sObjectsType == 'Opportunity'){
            // Filter for prevent many requests to Emarsys (Emarsys have soft limits for callout per minute)
            if ((newRecord.get('StageName') != oldRecord.get('StageName') && newRecord.get('StageName') == 'Client Negotiations')
                    || (newRecord.get('StageName') != oldRecord.get('StageName') && newRecord.get('StageName') == 'Отказ' && (newRecord.get('PPR_Lost_Reasons__c') == 'Другая' || newRecord.get('PPR_Lost_Reasons__c') == 'Other'))
                    || (newRecord.get('StageName') != oldRecord.get('StageName') && newRecord.get('StageName') == 'Awaiting payment' && Date.valueOf(newRecord.get('CloseDate')) < Date.today())
                    || (newRecord.get('StageName') != oldRecord.get('StageName') && newRecord.get('StageName') == 'Отказ'
                    && (newRecord.get('PPR_Lost_Reasons__c') == 'Нет подходящих АЗС' || newRecord.get('PPR_Lost_Reasons__c') == 'No suitable gas stations' || 
                    newRecord.get('PPR_Lost_Reasons__c') == 'Устраивает текущий продукт' || newRecord.get('PPR_Lost_Reasons__c') == 'Rewards Programs/Rebates/Discounts' ||
                    newRecord.get('PPR_Lost_Reasons__c') == 'Хотят более выгодной цены/скидки' || newRecord.get('PPR_Lost_Reasons__c') == 'Нужна фиксированная цена' ||
                    newRecord.get('PPR_Lost_Reasons__c') == 'Не устраивает наценка'))) {
                return true;
            } else if (newRecord.get('StageName') != oldRecord.get('StageName') && newRecord.get('StageName') == 'Suspended Opportunity' && newRecord.get('CloseDate') != null) {
                return true;
            } else if (newRecord.get('StageName') != oldRecord.get('StageName') && newRecord.get('StageName') == MOVED_TO_START) {
                return true;
            } else if (oldRecord.get('StageName') == 'Awaiting payment' && newRecord.get('StageName') != oldRecord.get('StageName') &&
                    Date.valueOf(oldRecord.get('CloseDate')) < Date.today()) {
                newRecord.put('End_Of_Subscription__c','Ожидание платежа завершено');
                return true;
            } else if (oldRecord.get('StageName') == 'Client Negotiations' && newRecord.get('StageName') != oldRecord.get('StageName')) {
                newRecord.put('End_Of_Subscription__c','Коммерческие переговоры окончены');
                return true;
            } else if (newRecord.get('LeadSource') == 'E2E Form RU'){
                for (String field : opportunityFieldsMap.keySet()) {
                    if ((! field.contains('.'))&& oldRecord.get(field) != newRecord.get(field)) {
                        return true;
                    } else if (field.contains('Owner.') && oldRecord.get('OwnerId') != newRecord.get('OwnerId')) {
                        return true;
                    }
                }
            }
        }
        else if(sObjectsType == 'Contact'){
            if (oldRecord.get('Email') == null && newRecord.get('Email') != null){
                return true;
            }
        }
        return false;
    }

}