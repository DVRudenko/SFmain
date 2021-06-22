/**
 * Created by Nikita.Dayanov on 18.10.2018.
 * @author Nikita Dayanov
 */

global class EmarsysReactionTypesGetter implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    static Set<String> countries = new Set<String>{'DE'};
    public Set<String> logsToRewrite = new Set<String>();
    public Map<String, List<Object>> ids = new Map<String, List<Object>>();
    Set<String> expiredQueries = new Set<String>();

    /*******************************************************************************
    *  @description     Collect logs to be updated (those with queryId)
    *  @date            18/10/2018
    *  @param context   System parameter for batch job
    *  @return          Database.QueryLocator
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        getSetOfResponse();
        return Database.getQueryLocator(
                'SELECT Type__c, Opportunity__r.Emarsys_Contact_Id__c, Query_Id__c, Last_Check__c ' +
                        'FROM Emarsys_Log__c ' +
                        'WHERE Query_Id__c != NULL ' +
                        'AND Business_Type__c IN: countries ' +
                        'AND Email_Id__c IN: logsToRewrite');
    }

    /*******************************************************************************
    *  @description     Process list of Emarsys_Logs with non-empty query Id.
    *                   Updates reaction type or clears expired query Ids
    *  @date            18/10/2018
    *  @param context   System parameter for batch job
    *  @param scope     List of collected Emarsys_Logs in start method
    *  @return          void
    ******************************************************************************/
    global void execute(Database.BatchableContext context, List<Emarsys_Log__c> scope) {
        for (Emarsys_Log__c log : scope) {

            if (expiredQueries.contains(String.valueOf(log.Query_Id__c))) {
                log.Query_Id__c = null;
                continue;
            }
            List<Object> idss = ids.get(log.Query_Id__c);
            if (log.Type__c == null) {
                // If Emarsys id in list, set opened
                if (idss.contains(log.Opportunity__r.Emarsys_Contact_Id__c)) {
                    log.Type__c = 'Opened';
                }
            } else if (log.Type__c != null && log.Type__c.equals('Opened')) {
                // If Emarsys id in list, set clicked
                if (idss.contains(log.Opportunity__r.Emarsys_Contact_Id__c)) {
                    log.Type__c = 'Clicked';
                }
            }
            log.Last_Check__c = Datetime.now();
            // Set queryId null
            log.Query_Id__c = null;
        }
        update scope;
    }

    /*******************************************************************************
    *  @description     Specifies actions on finish. Not used
    *  @date            18/10/2018
    *  @param context   System parameter for batch job
    *  @return          void
    ******************************************************************************/
    global void finish(Database.BatchableContext context) {
    }

    /*******************************************************************************
    *  @description     Get data for query Ids from Emarsys. Data is array of
    *                   emarsys ids who made specified reaction. Used in execute
    *  @date            19/10/2018
    *  @return          void
    ******************************************************************************/
    global void getSetOfResponse() {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountEuro.name());
        List<AggregateResult> listOfCheckRequest = [
                SELECT Email_Id__c, Query_Id__c
                FROM Emarsys_Log__c
                WHERE Email_Id__c <> ''
                AND Query_Id__c <> NULL
                AND Business_Type__c = 'DE'
                GROUP BY Email_Id__c, Query_Id__c
        ];
        for (AggregateResult result : listOfCheckRequest) {
            String resBody = EmarsysWebService.getResponseTypeRequest(String.valueOf(result.get('Query_Id__c')), emarsysAccount);
            Map<String, Object> history = (Map<String, Object>) JSON.deserializeUntyped(resBody);
            if (history.get('replyCode') == 6030) {
                // reScheduleJobOnNotReady();
            }
            if (history.get('replyCode') == 6080) {
                expiredQueries.add(String.valueOf(result.get('Query_Id__c')));
                logsToRewrite.add(String.valueOf(result.get('Email_Id__c')));
            }
            if (history.get('replyCode') != 0) {
                continue;
            }
            logsToRewrite.add(String.valueOf(result.get('Email_Id__c')));
            ids.put(String.valueOf(result.get('Query_Id__c')), (List<Object>) ((Map<String, Object>) history.get('data')).get('contact_ids'));
        }
    }

    /*******************************************************************************
    *  @description     Creates same Apex Job. Can be used if Emarsys was not
    *                   ready to provide data for query. Currently not used,
    *                   for future releases
    *  @date            24/10/2018
    *  @return          void
    ******************************************************************************/
    private void reScheduleJobOnNotReady() {
        Datetime minuteLater = Datetime.now().addMinutes(2);
        String schedule = minuteLater.second() + ' ' + minuteLater.minute() + ' ' + minuteLater.hour() + ' ' +
                minuteLater.day() + ' ' + minuteLater.month() + ' ? ' + minuteLater.year();
        EmarsysReactionTypesSchedule emarsysUpdateType = new EmarsysReactionTypesSchedule();
        System.schedule('Emarsys Emails Update Reaction ' +
                minuteLater.hour() + ':' + minuteLater.minute() + ':' + minuteLater.second(),
                schedule,
                emarsysUpdateType);
    }
}