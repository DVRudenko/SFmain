public class CaseCreationPageController {
    private static String supportRecordType = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support.name());
    private static String supportCcsRecordType = GlobalUtils.getRecordTypeId('Case', GlobalUtils.CaseRecordTypes.Support_CCS.name());

    /*******************************************************************************
    *  Name            : getRecordTypeIds()
    *  Summary         : returns support record types
    *  Created         : 27/03/2020 by Anton Hrytsavets
    *  Parameters      : void
    *  Returns         : List with record type Ids
    ******************************************************************************/
    @AuraEnabled
    public static Map<String, String> getRecordTypes(){
        // return new List<String>{supportRecordType, supportCcsRecordType};
        return new Map<String, String> {
            supportRecordType => 'Support',
            supportCcsRecordType =>'Support CCS'
        };
    }


    /*******************************************************************************
    *  Name            : getPickListValueList()
    *  Summary         : returns available picklist values for field with specified recordType
    *  Created         : 27/03/2020 by Anton Hrytsavets
    *  Parameters      : String objectName - objectName, String fieldName - target field name, String type - specified recordtype Id, String dependentField - field value of depended picklist
    *  Returns         : List with picklist values
    ******************************************************************************/
    @AuraEnabled
    public static List<String> getPickListValueList(String objectName, String fieldName, String recordTypeId, String dependentField) {
        List<String> pickListStringValues = new List<String>();
        List<String> dependentFieldsList = new List<String>();
        if(String.isNotEmpty(dependentField)) {
            Map<String, List<String>> dependentFieldsMap = getDependentPicklistValues(objectName, fieldName);
            dependentFieldsList = dependentFieldsMap.get(dependentField);
        }
        String recordTypeName = getRecordTypeName(recordTypeId);
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = sobjectDescribe.fields.getMap() ;
        Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldDescribe.getPicklistValues();
        List<String> valuesForRecordType = getValuesForRecordType(recordTypeName, objectName, fieldName);
        for( Schema.PicklistEntry pickListValue : pickListValues){
            String currentFieldName = pickListValue.getLabel();
            if(valuesForRecordType == null || valuesForRecordType.contains(currentFieldName)) {
                if(String.isEmpty(dependentField) || (String.isNotEmpty(dependentField) && dependentFieldsList.contains(currentFieldName))){
                    pickListStringValues.add(currentFieldName);
                }
            }
        }
        return pickListStringValues;
    }

    /*******************************************************************************
    *  Name            : attachFileToCase
    *  Summary         : created attachment for case
    *  Created         : 30/03/2020 by Anton Hrytsavets
    *  Parameters      : String encodedContentsString - file content, String fileName - fileName, String recordId - Case Id
    *  Returns         : void
    ******************************************************************************/
    @AuraEnabled
    public static void attachFileToCase(String encodedContentsString, String fileName, String recordId) {
        Attachment attachment = new Attachment(
            Body = EncodingUtil.base64Decode(encodedContentsString),
            Name = fileName,
            ParentId = recordId
        );
        insert attachment;
    }

    /*******************************************************************************
    *  Name            : getAvailableRecordType
    *  Summary         : returns avilable record type for current user. Returns null if there are more than 1 available type
    *  Created         : 30/03/2020 by Anton Hrytsavets
    *  Parameters      : void
    *  Returns         : String - avilable recordtype Id
    ******************************************************************************/
    @AuraEnabled
    public static String getAvailableRecordType() {
        List<String> availableRecordTypes = new List<String>();
        Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> rtInfoList = caseDescribe.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfoList) {
            if (rtInfo.isAvailable() && !String.valueOf(rtInfo.getRecordTypeId()).endsWith('AAA')) {
                availableRecordTypes.add(rtInfo.getRecordTypeId());
            }
        }
        if(availableRecordTypes.size() == 1) {
            return availableRecordTypes[0];
        }
        return null;
    }


    @AuraEnabled
    public static String getPageLayoutData(String layoutName) {
        List<Metadata.Metadata> layouts = 
        Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                    new List<String> {layoutName});

        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        return JSON.serialize(layoutMd.LayoutSections);
    }


    private static Map<String, List<String>> getDependentPicklistValues(String objectName, String fieldName) {
        Schema.SObjectField dependToken = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
    
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }


    private static List<String> getValuesForRecordType(String recordType, String objectName, String fieldName) {
        List<Picklist_Record_Type_Mapping__mdt> mapping = [
            SELECT  Label,
                    Object_Name__c,
                    Pick_List_Values__c,
                    Record_Type__c
            FROM    Picklist_Record_Type_Mapping__mdt
            WHERE   Record_Type__c =: recordType
            AND     Object_Name__c =: objectName
            AND     Label =: fieldName
            LIMIT   1
        ];
        if(mapping.size() == 1){
            return mapping[0].Pick_List_Values__c.split('\n');
        }
        return null;
    }

    private static String getRecordTypeName(String recordTypeId) {
        RecordType currentRecordType = [
            SELECT  DeveloperName
            FROM    RecordType
            WHERE   Id =: recordTypeId
        ];
        return currentRecordType.DeveloperName;
    }

    @AuraEnabled
    public static String getParentAccountForERP(String erpId) {
        ERP__c erp = [
            SELECT  id,
            		Account__c 
            FROM    ERP__c
            WHERE   id =: erpId
        ];
        system.debug('ERP: '+erp);
        return erp.Account__c;
    }
}
