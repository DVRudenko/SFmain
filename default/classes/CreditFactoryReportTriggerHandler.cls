public with sharing class CreditFactoryReportTriggerHandler extends TriggerHandler {
    public static final Map<ID, Schema.RecordTypeInfo> CFR_RT_MAP = Credit_Factory_Report__c.sObjectType.getDescribe().getRecordTypeInfosById();

    public static Boolean triggerEnabled = true;

    private CFRTriggerHandlerHelper triggerHelper;

    public CreditFactoryReportTriggerHandler() {
        triggerHelper = new CFRTriggerHandlerHelper();
    }

    public override void afterInsert() {
        setClientChoice();
    }

    public override void afterUpdate() {
        setClientChoice();
    }

    public override void afterUndelete() {
        setClientChoice();
    }

    private void setClientChoice() {
        List<Credit_Factory_Report__c> newCfrs = (List<Credit_Factory_Report__c>) Trigger.new;
        Map<Id, Credit_Factory_Report__c> oldCfrsMap = (Map<Id, Credit_Factory_Report__c>) Trigger.oldMap;
        Set<String> recordtypeNamesSet = triggerHelper.getRecordTypeNamessForCFR();
        List<Id> opportunitieIds = new List<Id>();
        List<Id> cfrIdsToExclude = new List<Id>();

        for (Credit_Factory_Report__c newCfr : newCfrs) {
            String recordTypeDevName = CFR_RT_MAP.get(newCfr.RecordTypeId).getDeveloperName();
            Boolean requiredRecordType = recordtypeNamesSet.contains(recordTypeDevName);
            Boolean isNewRecord = oldCfrsMap == null;
            Boolean clientChoiseChanged = oldCfrsMap != null && newCfr.RU_Client_choice__c != oldCfrsMap.get(newCfr.Id).RU_Client_choice__c;
            Boolean hasOpportunityId = newCfr.Opportunity__c != null;

            if (hasOpportunityId && requiredRecordType && newCfr.RU_Client_choice__c && (isNewRecord || clientChoiseChanged)) {
                opportunitieIds.add(newCfr.Opportunity__c);
                cfrIdsToExclude.add(newCfr.Id);
            }
        }

        List<Credit_Factory_Report__c> cfrsForUpdate = [
            SELECT Id
            FROM Credit_Factory_Report__c
            WHERE
                Opportunity__c IN :opportunitieIds
                AND RecordType.DeveloperName IN :recordtypeNamesSet
                AND RU_Client_choice__c = TRUE
                AND ID NOT IN :cfrIdsToExclude
        ];

        if (!cfrsForUpdate.isEmpty()) {
            for (Credit_Factory_Report__c record : cfrsForUpdate) {
                record.RU_Client_choice__c = false;
            }

            update cfrsForUpdate;
        }
    }
}