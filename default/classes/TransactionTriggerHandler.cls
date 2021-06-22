public class TransactionTriggerHandler {
	
    /*******************************************************************************
    *  Name            : updateObjectFields(List<Transaction__c> newTransactions)
    *  Summary         : run DML operations on the Transaction__c object from FleetcorEmea site   
    *  CreatedDate     : 27/12/2016
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void distributionProcess(List<Transaction__c> newTransactionsList) {
        Map<Id, Transaction__c> updateMap = new Map<Id, Transaction__c>();
        Map<Id, Transaction__c> insertMap = new Map<Id, Transaction__c>();
        Map<Id, Transaction__c> deleteMap = new Map<Id, Transaction__c>();
        for (Transaction__c systemTransaction : newTransactionsList) {
            if (systemTransaction.Processing__c == true && systemTransaction.DML_type__c == 'update'){
                updateMap.put(systemTransaction.Id, systemTransaction);
            } else if (systemTransaction.Processing__c == false){}

            if (systemTransaction.Processing__c == true && systemTransaction.DML_type__c == 'insert'){
                insertMap.put(systemTransaction.Id, systemTransaction);
            } else if (systemTransaction.Processing__c == false){}

            if (systemTransaction.Processing__c == true && systemTransaction.DML_type__c == 'delete'){
                deleteMap.put(systemTransaction.Id, systemTransaction);
            } else if (systemTransaction.Processing__c == false){}
        }
        if ( ! updateMap.isEmpty()){
           dmlOperationUpdate(updateMap); 
        }
        if ( ! insertMap.isEmpty()){
           dmlOperationInsert(insertMap);
        }
        if ( ! deleteMap.isEmpty()){
           dmlOperationDelete(deleteMap); 
        }
    }


    /*******************************************************************************
    *  Name            : dmlOperationUpdate(Transaction__c systTransObject)
    *  Summary         : Update object fields     
    *  CreatedDate     : 01/02/2017
    *  Parameters      : Transaction__c systTransObject
    *  Returns         : void
    ******************************************************************************/
    public static void dmlOperationUpdate(Map<Id, Transaction__c> systTransObject){
        Map<Id, Transaction__c> transactionsAndFieldsMap = new Map<Id, Transaction__c>([
            SELECT Record_Id__c, Processing__c, Object_API__c, DML_type__c,
                   (SELECT API_Field_Name__c, Value__c FROM Transaction_Fields__r)
            FROM Transaction__c
            WHERE Id IN :systTransObject.keySet()
            LIMIT 10000]);

        Map<String, List<Transaction__c>> objectToTransactionsMap = new Map<String, List<Transaction__c>>();
        Map<String, Map<String, sObject>> sObjectToSelectMap = new Map<String, Map<String, sObject>>();
        for (Transaction__c sysTransaction : transactionsAndFieldsMap.values()) {
            if ( ! objectToTransactionsMap.containsKey(sysTransaction.Object_API__c) ) {
                objectToTransactionsMap.put(sysTransaction.Object_API__c, new List<Transaction__c>());
            }

            objectToTransactionsMap.get(sysTransaction.Object_API__c).add(sysTransaction);
        }

        // Generate SOQL query (dynamic String)
        for (String objectType : objectToTransactionsMap.keySet()) {
            String query = 'SELECT ';
            Set<String> apiNamesFieldsSet = new Set<String>();
            Set<String> transactionsIdsSet = new Set<String>();
            for (Transaction__c sysTransaction : objectToTransactionsMap.get(objectType)) {
                transactionsIdsSet.add(sysTransaction.Record_Id__c);
                for (Transaction_Field__c field : sysTransaction.Transaction_Fields__r) {
                    apiNamesFieldsSet.add(field.API_Field_Name__c);
                }
            }

            // add all fields from set to query
            for (String fieldName : apiNamesFieldsSet) {
                query += fieldName + ',';
            }
            query = query.removeEnd(',');
            query += ' FROM ' + objectType + ' WHERE Id IN :transactionsIdsSet LIMIT 10000';
            Map<String, sObject> sobjectMap = new Map<String, sObject>(
                (List<sObject>)Database.query(query)
            );
            
            sObjectToSelectMap.put(objectType, sobjectMap);
        }

        for (Transaction__c sysTransaction : transactionsAndFieldsMap.values()) {
            String objType = sysTransaction.Object_API__c;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objectSchema = schemaMap.get(objType);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            for (Transaction_Field__c field : sysTransaction.Transaction_Fields__r) {         
                String fieldToLowerCase = field.API_Field_Name__c.toLowerCase();
                Schema.DisplayType fieldDataType = fieldMap.get(fieldToLowerCase).getDescribe().getType();
                if (fieldDataType == Schema.DisplayType.BOOLEAN) {
                    Boolean newValueForUpdate = Boolean.valueOf(field.Value__c);
                    sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);    
                } else if (fieldDataType == Schema.DisplayType.DATE) {
                    if (field.Value__c != null) {
                        Date newValueForUpdate = Date.valueOf(field.Value__c.replaceAll('/','-'));
                        sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);
                    }
                } else if (fieldDataType == Schema.DisplayType.DOUBLE || fieldDataType == Schema.DisplayType.CURRENCY) {
                    Decimal newValueForUpdate = Decimal.valueOf(field.Value__c);
                    sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);
                } else if (fieldDataType == Schema.DisplayType.ID) {
                    Id newValueForUpdate = Id.valueOf(field.Value__c);
                    sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);
                } else if ((fieldDataType == Schema.DisplayType.INTEGER)){
                    Integer newValueForUpdate = Integer.valueOf(field.Value__c);
                    sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);
                } else if ((fieldDataType == Schema.DisplayType.DATETIME)){
                    DateTime newValueForUpdate = DateTime.valueOf(field.Value__c);
                    sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);
                } else {
                    String newValueForUpdate = String.valueOf(field.Value__c);
                    sObjectToSelectMap.get(sysTransaction.Object_API__c).get(sysTransaction.Record_Id__c).put(field.API_Field_Name__c, newValueForUpdate);
                }
            }
            update sObjectToSelectMap.get(sysTransaction.Object_API__c).values();
            delete sysTransaction;
        }
    }


    /*******************************************************************************
    *  Name            : dmlOperationInsert(Map<Id, Transaction__c> systTransObject)
    *  Summary         : Insert object   
    *  CreatedDate     : 24/02/2017
    *  Parameters      : Map<Id, Transaction__c> systTransObject
    *  Returns         : void
    ******************************************************************************/
    public static void dmlOperationInsert(Map<Id, Transaction__c> systTransObject){
        Map<Id, Transaction__c> transactionsAndFieldsMap = new Map<Id, Transaction__c>([
            SELECT Record_Id__c, Processing__c, Object_API__c, DML_type__c,
                   (SELECT API_Field_Name__c, Value__c FROM Transaction_Fields__r)
            FROM Transaction__c
            WHERE Id IN :systTransObject.keySet()
            LIMIT 10000]);
        for (Transaction__c sysTransaction : transactionsAndFieldsMap.values()) {
            String objType = sysTransaction.Object_API__c;
            SObject sObjToInsert = Schema.getGlobalDescribe().get(objType).newSObject();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objectSchema = schemaMap.get(objType);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            for (Transaction_Field__c field : sysTransaction.Transaction_Fields__r) {            
                String fieldToLowerCase = field.API_Field_Name__c.toLowerCase();
                Schema.DisplayType fieldDataType = fieldMap.get(fieldToLowerCase).getDescribe().getType();
                if (fieldDataType == Schema.DisplayType.BOOLEAN) {
                    Boolean valueForInsert = Boolean.valueOf(field.Value__c);
                    sObjToInsert.put(field.API_Field_Name__c, valueForInsert);    
                } else if (fieldDataType == Schema.DisplayType.DATE) {
                    if (field.Value__c != null) {
                        Date valueForInsert = Date.valueOf(field.Value__c.replaceAll('/','-'));
                        sObjToInsert.put(field.API_Field_Name__c, valueForInsert);
                    }
                } else if (fieldDataType == Schema.DisplayType.DOUBLE || fieldDataType == Schema.DisplayType.CURRENCY) {
                    Decimal valueForInsert = Decimal.valueOf(field.Value__c);
                    sObjToInsert.put(field.API_Field_Name__c, valueForInsert);
                } else if (fieldDataType == Schema.DisplayType.ID) {
                    Id valueForInsert = Id.valueOf(field.Value__c);
                    sObjToInsert.put(field.API_Field_Name__c, valueForInsert);
                } else if ((fieldDataType == Schema.DisplayType.INTEGER)){
                    Integer valueForInsert = Integer.valueOf(field.Value__c);
                    sObjToInsert.put(field.API_Field_Name__c, valueForInsert);
                } else if ((fieldDataType == Schema.DisplayType.DATETIME)){
                    Datetime valueForInsert = Datetime.valueOf(field.Value__c);
                    sObjToInsert.put(field.API_Field_Name__c, valueForInsert);
                } else {
                    String valueForInsert = String.valueOf(field.Value__c);
                    sObjToInsert.put(field.API_Field_Name__c, valueForInsert);
                }
            } 
            insert sObjToInsert;
            delete sysTransaction;
        }
    }


    /*******************************************************************************
    *  Name            : 
    *  Summary         :     
    *  CreatedDate     : 
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public static void dmlOperationDelete(Map<Id, Transaction__c> systTransObject){
    
    }
}