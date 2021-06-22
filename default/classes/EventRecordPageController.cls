public with sharing class EventRecordPageController {



    /*******************************************************************************
    *  Name            : search(String searchTerm, List<String> selectedIds, String sObjectName)
    *  Summary         : search method for custom lookup
    *  CreatedDate     : 10.12.2020 bu Anton Hrytsavets
    *  Parameters      : String searchTerm - word entered by user in search panel
                         List<String> selectedIds - list of selectd record ids for multi-lookup
                         String sObjectName - name relation sobject
    *  Returns         : List<LookupSearchResult> - result of search list
    ******************************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String sObjectName) {
        List<LookupSearchResult> searchResultList = new List<LookupSearchResult>();
        if(String.isNotEmpty(sObjectName)) {
            String field = getFieldNameForQuery(sObjectName);
            String queryString = 'SELECT Id, ' + field + ' FROM ' + sObjectName + ' WHERE ' + field + ' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
            List<SObject> sObjectList = Database.query(queryString);
            for(SObject record : sObjectList) {
                searchResultList.add(new LookupSearchResult(
                    record.id,
                    sObjectName,
                    'standard:' + sObjectName.toLowerCase(),
                    (String)record.get(field),
                    ''
                ));
            }
        }
        return searchResultList;
    }


    /*******************************************************************************
    *  Name            : Event getEventData(Id recordId)
    *  Summary         : get event record by event recordId
    *  CreatedDate     : 10.12.2020 bu Anton Hrytsavets
    *  Parameters      : Id recordid - Id of event
    *  Returns         : Event - event record
    ******************************************************************************/
    @AuraEnabled(Cacheable=false)
    public static Event getEventData(Id recordId) {
        List<Event> eventData = [
            SELECT  Id,
                    WhoId,
                    WhatId,
                    Subject,
                    Type,
                    Description,
                    RecordTypeId,
                    StartDateTime,
                    EndDateTime,
                    OwnerId,
                    Owner.Name,
                    IsAllDayEvent,
                    IsPrivate,
                    ShowAs,
                    IsReminderSet,
                    Location
            FROM    Event
            WHERE   Id =: recordId
        ];
        if(eventData.size() == 1) {
            return eventData.get(0);
        }
        return null;
    }



    /*******************************************************************************
    *  Name            : Map<String, String> getSObjectData(Id recordId)
    *  Summary         : get Name(or number), Id and sobject name of record by Id
    *  CreatedDate     : 10.12.2020 bu Anton Hrytsavets
    *  Parameters      : Id recordid - Id of record
    *  Returns         : Map<String, String> - record data
    ******************************************************************************/
    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getSObjectData(Id recordId) {
        Map<String, String> sObjectData = new Map<String, String>();
        if(String.isNotEmpty(recordId)) {
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            String field = getFieldNameForQuery(sObjectName);
            String queryString = 'SELECT Id, ' + field + ' FROM ' + sObjectName + ' WHERE Id = \'' + recordId + '\'';
            SObject sObjectRecord = Database.query(queryString);
            sObjectData.put('SObjectName', sObjectName);
            sObjectData.put('Id', sObjectRecord.Id);
            sObjectData.put('Name', (String)sObjectRecord.get(field));
            return sObjectData;
        }
        return null;
    }





    /*******************************************************************************
    *  Name            : Map<String, Map<String, String>> getPickListValues()
    *  Summary         : get picklists values and labels for picklists on edit page
    *  CreatedDate     : 10.12.2020 bu Anton Hrytsavets
    *  Parameters      : -
    *  Returns         : Map<String, Map<String, String>> - picklist values in format {PicklistFieldName : {picklistvalue_1: picklistlabel_1, {picklistvalue_2: picklistlabel_2}}
    ******************************************************************************/
    @AuraEnabled(Cacheable=false)
    public static Map<String, Map<String, String>> getPickListValues() {
        Map<String, Map<String, String>> piclistValues = new Map<String, Map<String, String>>();
        Map<String, String> relatedToPicklistValues = new Map<String, String>();
        Map<String, String> namePicklistValues = new Map<String, String>();
        for (Schema.SObjectType objectType : Event.WhatId.getDescribe().getReferenceTo()) {
            relatedToPicklistValues.put(objectType.getDescribe().getName(), objectType.getDescribe().getLabel());
        }
        for (Schema.SObjectType objectType : Event.WhoId.getDescribe().getReferenceTo()) {
            namePicklistValues.put(objectType.getDescribe().getName(), objectType.getDescribe().getLabel());
        }

        piclistValues.put('RelatedTo', relatedToPicklistValues);
        piclistValues.put('Name', namePicklistValues);
        piclistValues.put('Subject', getPickListValues(Event.Subject.getDescribe()));
        piclistValues.put('Type', getPickListValues(Event.Type.getDescribe()));
        piclistValues.put('ShowAs', getPickListValues(Event.ShowAs.getDescribe()));
        return piclistValues;
    }

    /*******************************************************************************
    *  Name            : void saveEditedEvent(Event editedEvent)
    *  Summary         : updates event record
    *  CreatedDate     : 10.12.2020 bu Anton Hrytsavets
    *  Parameters      : Event editedEvent - event record
    *  Returns         : Map<String, Map<String, String>> - picklist values in format {PicklistFieldName : {picklistvalue_1: picklistlabel_1, {picklistvalue_2: picklistlabel_2}}
    ******************************************************************************/
    @AuraEnabled
    public static void saveEditedEvent(Event editedEvent) {
        update editedEvent;
    }


    private static String getFieldNameForQuery(String sObjectName) {
        String field = 'Name';
        if(sObjectName == 'Case') {
            field = 'CaseNumber';
        }
        if(sObjectName == 'AssetRelationship') {
            field = 'AssetRelationshipNumber';
        }
        return field;
    }


    private static Map<String, String> getPickListValues(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> pickListValuesList= new Map<String, String>();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.put(pickListVal.getValue(), pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
}
