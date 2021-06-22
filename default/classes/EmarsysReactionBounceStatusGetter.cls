/**
 * Created by Nikita.Dayanov on 22.10.2018.
 * @author Nikita Dayanov
 */

global class EmarsysReactionBounceStatusGetter implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    static Set<String> countries = new Set<String>{'DE'};
    public String emailIdBounceCheck;
    public List<Object> ids = new List<Object>();

    /*******************************************************************************
    *  @description     Collect logs to be updated by bounce status
    *  @date            22/10/2018
    *  @param context   System parameter for batch job
    *  @return          Database.QueryLocator
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        getBounceResponse();
        return Database.getQueryLocator(
                'SELECT Type__c, Opportunity__r.Emarsys_Contact_Id__c, Query_Id__c, Last_Check__c ' +
                        'FROM Emarsys_Log__c ' +
                        'WHERE Query_Id__c != NULL ' +
                        'AND Business_Type__c IN: countries ' +
                        'AND Email_Id__c =: emailIdBounceCheck');
    }

    /*******************************************************************************
    *  @description     Process collected logs to insert Bounce_Status
    *  @date            22/10/2018
    *  @param context   System parameter for batch job
    *  @param scope     List of collected Emarsys_Logs in start method
    *  @return          void
    ******************************************************************************/
    global void execute(Database.BatchableContext context, List<Emarsys_Log__c> scope) {

        for (Emarsys_Log__c log : scope) {
            if (ids != null && ids.contains(log.Opportunity__r.Emarsys_Contact_Id__c)) {
                // set bounce to true
                log.Bounce_Status__c = 'Didn\'t receive email';
            }
            log.Query_Id__c = null;
            log.Last_Check__c = Datetime.now();
        }
        update scope;
    }

    /*******************************************************************************
    *  @description     Specifies actions on finish. Not used
    *  @date            22/10/2018
    *  @param context   System parameter for batch job
    *  @return          void
    ******************************************************************************/
    global void finish(Database.BatchableContext context) {
    }

    /*******************************************************************************
    *  @description     Get logs to be updated by query ID
    *  @date            22/10/2018
    *  @return          void
    ******************************************************************************/
    global void getBounceResponse() {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountEuro.name());
        List<AggregateResult> listOfCheckRequest = [
                SELECT Email_Id__c, Query_Id__c
                FROM Emarsys_Log__c
                WHERE Email_Id__c <> ''
                AND Query_Id__c <> NULL
                AND Business_Type__c = 'DE'
                GROUP BY Email_Id__c, Query_Id__c
                LIMIT 1
        ];
        try {
            AggregateResult result = listOfCheckRequest.get(0);
            String resBody = EmarsysWebService.getResponseTypeRequest(String.valueOf(result.get('Query_Id__c')), emarsysAccount);
            Map<String, Object> history = (Map<String, Object>) JSON.deserializeUntyped(resBody);

            emailIdBounceCheck = String.valueOf(result.get('Email_Id__c'));
            if (history.get('replyCode') != 0) {
                return;
            }

            ids = (List<Object>) ((Map<String, Object>) history.get('data')).get('contact_ids');
        } catch (Exception e) {
            return;
        }
    }
}