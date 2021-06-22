/**
 * Created by Nikita.Mikhailov on 19.10.2020.
 */

public with sharing class GFNI_LogEventTriggerHandler {
    public static void storeLogs(List<GFNI_Log__e> newLogEvents) {
        List<GFNI_Opportunity_log__b> logs = new List<GFNI_Opportunity_log__b>();

        for (GFNI_Log__e logEvent : newLogEvents) {
            GFNI_Opportunity_log__b log = new GFNI_Opportunity_log__b(
                    IsFirst__c = logEvent.IsFirst__c,
                    LogType__c = logEvent.LogType__c,
                    Opportunity__c = logEvent.LookupObjectId__c,
                    Message__c = logEvent.Message__c,
                    RecordDateTime__c = logEvent.RecordDateTime__c,
                    Request_Id__c = logEvent.Request_Id__c
            );
            logs.add(log);
        }

        System.debug('INSERTING LOGS ' + logs);

        if (!Test.isRunningTest())
            Database.insertImmediate(logs);
    }
}