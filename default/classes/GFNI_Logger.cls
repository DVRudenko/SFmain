/**
 * Created by Nikita.Mikhailov on 18.01.2019.
 *
 * Class to create and store logs in scope of GFN Integration project
 * All logs saves to BigObject GFNI_Opportunity_log__b
 *
 * Have a static workaround to save List<GFNI_Logger>
 */
public with sharing class GFNI_Logger {

    public List<GFNI_Log__e> logEvents { get; set; }
    public Id opportunityId { get; set; }
    public Boolean isFirst { get; set; }
    private Integer secondsToAdd;

    public GFNI_Logger(Id opportunityId, Boolean isFirst) {
        this.opportunityId = opportunityId;
        this.isFirst = isFirst;
        //Adding from 0 to 42 seconds to be sure that this BigObject Id is unique
        //42 - the answer to life, universe and everything
        this.secondsToAdd = Math.round(Math.random() * 42);
        this.logEvents = new List<GFNI_Log__e>();
    }

    /*******************************************************************************
    *  Name            : addLog
    *  Summary         : adds new log to the logs list
    *  CreatedDate     : 18/01/2019
    *  Parameters      : String logType('Request, Response, Error, Message etc.'), String message, String requestId in request
    *  Returns         : void
    ******************************************************************************/
    public void addLog(String logType, String message, String requestId) {
        GFNI_Log__e logEvent = new GFNI_Log__e (
                Request_Id__c = requestId,
                RecordDateTime__c = System.now().addSeconds(this.secondsToAdd),
                LogType__c = logType,
                Message__c = message,
                LookupObjectId__c = this.opportunityId
        );

        if (this.isFirst) {
            logEvent.IsFirst__c = 1;
            this.isFirst = false;
        } else {
            logEvent.IsFirst__c = 0;
        }

        this.logEvents.add(logEvent);
    }

    /*******************************************************************************
    *  Name            : saveLogs
    *  Summary         : saves logs to the BigObject GFNI_Opportunity_log__b
    *  CreatedDate     : 18/01/2019
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void saveLogs() {
        if (this.logEvents.isEmpty())
            return;

        EventBus.publish(this.logEvents);
    }

    /*******************************************************************************
    *  Name            : saveLogsList
    *  Summary         : static workaround for saving logs for different objects. Method just moves all logs to one list and saves to the BigObject GFNI_Opportunity_log__b
    *  CreatedDate     : 18/01/2019
    *  Parameters      : List<GFNI_Logger> list of loggers
    *  Returns         : void
    ******************************************************************************/
    public static void saveLogsList(List<GFNI_Logger> logs) {
        List<GFNI_Log__e> allLogs = new List<GFNI_Log__e>();

        for (GFNI_Logger i : logs) {
            for (GFNI_Log__e j : i.logEvents) {
                allLogs.add(j);
            }
        }

        EventBus.publish(allLogs);
    }
}