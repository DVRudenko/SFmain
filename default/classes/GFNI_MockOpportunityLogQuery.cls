/**
 * Created by Nikita.Mikhailov on 26.02.2019.
 */

@IsTest
global class GFNI_MockOpportunityLogQuery implements StubProvider {
    private Id oppId;
    private Boolean isFailed;
    private Integer numberOfLogs;

    public GFNI_MockOpportunityLogQuery(Id oppId, Boolean isFailed, Integer numberOfLogs) {
        this.oppId = oppId;
        this.isFailed = isFailed;
        this.numberOfLogs = numberOfLogs;
    }

    global Object handleMethodCall(Object stubbedObject,
            String stubbedMethodName,
            System.Type returnType,
            List<System.Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs) {

        List<GFNI_Opportunity_log__b> logList = new List<GFNI_Opportunity_log__b>();

        Boolean isFirst = true;

        for (Integer i = 0; i < this.numberOfLogs; i++) {
            GFNI_Opportunity_log__b log = new GFNI_Opportunity_log__b();
            log.Opportunity__c = this.oppId;
            if (isFirst) {
                log.IsFirst__c = 1;
            } else {
                log.IsFirst__c = 0;
                isFirst = false;
            }
            log.RecordDateTime__c = System.now();
            log.LogType__c = 'Message';
            log.Request_Id__c = 'GUID here';

            logList.add(log);
        }

        return logList;
    }
}