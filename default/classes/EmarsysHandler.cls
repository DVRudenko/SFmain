public class EmarsysHandler {

    public static Map<Id, SObject> russianSObjectsMap;
    public static Map<Id, SObject> europeanSObjectsMap;

    /*******************************************************************************
    *  Name            : sendContactsToEmarsys
    *  Summary         : enqueue new Job (Queueable) for send contacts to Emarsys
    *  CreatedDate     : 08/08/2018
    *  Parameters      : Map<Id, SObject> oldMap
    *                    Map<Id, SObject> newMap
    *                    String instancesEmarsys : RU, EU, RU&EU
    *  Returns         : void
    ******************************************************************************/
    public static void sendContactsToEmarsys(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, String emarsysIntances){
        try {
            if (Limits.getQueueableJobs() == 0) { // prevent "Too many queueable jobs added to the queue: 2"
                Map<Id, SObject> oldMapToSend;
                if(oldMap != null) oldMapToSend = new Map<Id, SObject>();
                Map<Id, SObject> newMapToSend = new Map<Id, SObject>();

                String sObjectsType = String.valueOf(newMap.values().get(0).getSObjectType());
                getRecordTypes(newMap, sObjectsType);

                if (emarsysIntances.contains('EU') && !europeanSObjectsMap.isEmpty()) EmarsysSenderEuropeanService.setMapping(sObjectsType);
                if (emarsysIntances.contains('RU') && !russianSObjectsMap.isEmpty())  EmarsysSenderRussianService.setMapping(sObjectsType);

                for(SObject newSObjectRecord : newMap.values()){
                    Schema.SObjectType sObjectType = newSObjectRecord.getSObjectType();
                    String sobjectName = String.valueOf(sObjectType);
                    if (sobjectName == 'Opportunity') {
                        String ownerProfileName = (String)newSObjectRecord.get('Opp_Owner_Profile__c');
                        if (UserInfo.getUserName().contains('e2e@e2efleecor.force.com') ||
                            UserInfo.getUserName().contains('e2e_pl@e2efleecor.force.com')) {
                            continue;
                        }
                    }

                    SObject oldSObjectRecord;
                    if(oldMap != null){
                        oldSObjectRecord = oldMap.get(newSObjectRecord.Id);
                    }
                    if (emarsysIntances.contains('EU') && europeanSObjectsMap.containsKey(newSObjectRecord.Id)) {
                        Boolean needToSendEU = EmarsysSenderEuropeanService.getStatusOfNeedToSend(oldSObjectRecord, newSObjectRecord);
                        if(needToSendEU){
                            if(oldSObjectRecord != null){
                                oldMapToSend.put(oldSObjectRecord.Id, oldSObjectRecord);
                            }
                            newMapToSend.put(newSObjectRecord.Id, newSObjectRecord);
                        }
                    }
                    if (emarsysIntances.contains('RU') && russianSObjectsMap.containsKey(newSObjectRecord.Id)) {
                        Boolean needToSendRU = EmarsysSenderRussianService.getStatusOfNeedToSend(oldSObjectRecord, newSObjectRecord);
                        if(needToSendRU){
                            if(oldSObjectRecord != null){
                                oldMapToSend.put(oldSObjectRecord.Id, oldSObjectRecord);
                            }
                            newMapToSend.put(newSObjectRecord.Id, newSObjectRecord);
                        }
                    }
                }

                if(newMapToSend.size() != 0 && !Test.isRunningTest()){
                    system.enqueueJob(new EmarsysHandler.EmarsysHandlerQueueable(oldMapToSend, newMapToSend, emarsysIntances));
                }
            }
        }
        catch (Exception e){
            ExceptionLogger.sendException('<br/>EmarsysHandler Exception: method sendContactsToEmarsys ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Class Name             : class EmarsysHandlerQueueable
    *  Summary                : Queueable class for send information to Emarsys asynchronously
    *  CreatedDate            : 08/08/2018
    *  Constructor Parameters : Map<Id, SObject> oldMap
    *                           Map<Id, SObject> newMap
    *                           String instancesEmarsys : RU, EU, RU&EU
    ******************************************************************************/
    public with sharing class EmarsysHandlerQueueable implements Queueable, Database.AllowsCallouts{
        private Map<Id, sObject> oldMap;
        private Map<Id, sObject> newMap;
        private String instances;

        public  EmarsysHandlerQueueable(Map<Id, sObject> oldMapSObjects, Map<Id, sObject> newMapSObjects, String emarsysIntances){
            oldMap = oldMapSObjects;
            newMap = newMapSObjects;
            instances = emarsysIntances;
        }

        public void execute(QueueableContext qc){
            try{
                if (instances.contains('RU')) { // Send To RU Account
                    Integration_Settings__c emarsysSettingRU = Integration_Settings__c.getInstance('Emarsys RU');
                    if (emarsysSettingRU != null && emarsysSettingRU.Enabled__c) {
                        EmarsysHandler.sendContactsToRussianEmarsys(oldMap, newMap);
                    }
                }

                if (instances.contains('EU')) { // Send to EU Account
                    Integration_Settings__c emarsysSettingEU = Integration_Settings__c.getInstance('Emarsys EU');
                    if (emarsysSettingEU != null && emarsysSettingEU.Enabled__c) {
                        EmarsysHandler.sendContactsToEuropeanEmarsys(oldMap, newMap);
                    }
                }
            } catch (Exception e){
                ExceptionLogger.sendException('<br/>EmarsysHandlerQueueable Exception: method execute ' + String.valueOf(e.getMessage()),
                        String.valueOf(e.getStackTraceString()));
            }
        }

    }

    /*******************************************************************************
    *  Name            : sendContactsToEuropeanEmarsys(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : send SObjects to Emarsys to create or update contacts
    *  CreatedDate     : 08/08/2017
    *  Parameters      : Map<Id, SObject> oldMap old SObject values, Map<Id, SObject> newMap - new SObject values
    *  Returns         : void
    ******************************************************************************/
    public static void sendContactsToEuropeanEmarsys(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        try {
            String sObjectsType = String.valueOf(newMap.values().get(0).getSObjectType());
            getRecordTypes(newMap, sObjectsType);
            if (! europeanSObjectsMap.isEmpty()) {
                EmarsysSenderEuropeanService.setMapping(sObjectsType);
                String jsonBody = EmarsysSenderEuropeanService.generateJsonBody(oldMap, europeanSObjectsMap);
                List<Id> sObjectsToUpdateIdsList = EmarsysSenderEuropeanService.getSObjectsToUpdateIdsList();
                if (jsonBody != '') {
                    EmarsysSenderEuropeanService.sendRequest(jsonBody, 'PPR_EU', sObjectsToUpdateIdsList, sObjectsType);
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()) + '\n' + newMap.keySet(), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : sendContactsToRussianEmarsys(Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    *  Summary         : send SObjects to Emarsys to create or update contacts
    *  CreatedDate     : 21/08/2017
    *  Parameters      : Map<Id, SObject> oldMap old SObject values, Map<Id, SObject> newMap - new SObject values
    *  Returns         : void
    ******************************************************************************/
    public static void sendContactsToRussianEmarsys(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        try {
            String sObjectsType = String.valueOf(newMap.values().get(0).getSObjectType());
            getRecordTypes(newMap, sObjectsType);
            if (! russianSObjectsMap.isEmpty()) {
                EmarsysSenderRussianService.setMapping(sObjectsType);
                String jsonBody = EmarsysSenderRussianService.generateJsonBody(oldMap, russianSObjectsMap);
                List<Id> sObjectsToUpdateIdsList = EmarsysSenderRussianService.getSObjectsToUpdateIdsList();
                if (jsonBody != '') {
                    EmarsysSenderRussianService.sendRequest(jsonBody, 'PPR', sObjectsToUpdateIdsList, sObjectsType);
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()) + '\n' + newMap.keySet(), String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : getRecordTypes(Map<Id, SObject> newMap)
    *  Summary         : get record types
    *  CreatedDate     : 08/08/2017
    *  Parameters      : Map<Id, SObject> - new records
    *  Returns         : void
    ******************************************************************************/
    private static void getRecordTypes(Map<Id, SObject> newMap, String sObjectsType) {
        Set<Id> europeanRecordTypesIdsSet = new Set<Id>();
        String recordType;
        recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Euroshell');
        if (recordType != null) europeanRecordTypesIdsSet.add(recordType);
        recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Endkunde');
        if (recordType != null) europeanRecordTypesIdsSet.add(recordType);
        recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Euroshell Starts');
        if (recordType != null) europeanRecordTypesIdsSet.add(recordType);
        recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Lotos');
        if (recordType != null) europeanRecordTypesIdsSet.add(recordType);

        Set<Id> russianRecordTypesIdsSet = new Set<Id>();
        if(sObjectsType == 'Opportunity') {
            recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Russian Sales');
            if (recordType != null) russianRecordTypesIdsSet.add(recordType);
            if (russianRecordTypesIdsSet.isEmpty()) russianRecordTypesIdsSet.add(GlobalUtils.getRecordTypeId(sObjectsType,'Russian_Sales'));
        }
        if(sObjectsType == 'Lead') {
            recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Russian Sales');
            if (recordType != null) russianRecordTypesIdsSet.add(recordType);
            if (russianRecordTypesIdsSet.isEmpty()) russianRecordTypesIdsSet.add(GlobalUtils.getRecordTypeId(sObjectsType,'Russian_Sales'));
        }
        if(sObjectsType == 'Contact') {
            recordType = GlobalUtils.returnRecordTypeId(sObjectsType,'Russian');
            if (recordType != null) russianRecordTypesIdsSet.add(GlobalUtils.returnRecordTypeId(sObjectsType,'Russian'));
            if (russianRecordTypesIdsSet.isEmpty()) russianRecordTypesIdsSet.add(GlobalUtils.getRecordTypeId(sObjectsType,'Russian'));
        }

        europeanSObjectsMap = new Map<Id, SObject>();
        russianSObjectsMap = new Map<Id, SObject>();
        if (! (europeanRecordTypesIdsSet.isEmpty() && russianRecordTypesIdsSet.isEmpty())) {
            for (SObject currentSObject : newMap.values()) {
                if (europeanRecordTypesIdsSet.contains(String.valueOf(currentSObject.get('RecordTypeId')))) {
                    europeanSObjectsMap.put(String.valueOf(currentSObject.get('Id')), currentSObject);
                } else if (russianRecordTypesIdsSet.contains(String.valueOf(currentSObject.get('RecordTypeId')))) {
                    russianSObjectsMap.put(String.valueOf(currentSObject.get('Id')), currentSObject);
                }
            }
        }
    }

}