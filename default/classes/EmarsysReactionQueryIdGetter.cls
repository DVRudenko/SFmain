/**
 * Created by Nikita.Dayanov on 18.10.2018.
 */
//
global class EmarsysReactionQueryIdGetter implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    Set<String> countries = new Set<String>{'DE'};
    public String queryId;
    public String currentEmailId;
    public String currentType;

    /*******************************************************************************
    *  @description     Collect logs to be checked for reaction
    *  @date            18/10/2018
    *  @param context   System parameter for batch job
    *  @return          Database.QueryLocator
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext context) {
        sendGettingEmailRequest();
        return Database.getQueryLocator(
                'SELECT Type__c, Opportunity__r.Emarsys_Contact_Id__c, Query_Id__c, Email_Id__c, Last_Check__c ' +
                        'FROM Emarsys_Log__c ' +
                        'WHERE Type__c =: currentType ' +
                        'AND Query_Id__c = NULL ' + 'AND Business_Type__c IN: countries ' +
                        'AND Email_Id__c =: currentEmailId');
    }

    /*******************************************************************************
    *  @description     Process collected logs to insert queryId in them
    *  @date            18/10/2018
    *  @param context   System parameter for batch job
    *  @param scope     List of collected Emarsys_Logs in start method
    *  @return          void
    ******************************************************************************/
    global void execute(Database.BatchableContext context, List<Emarsys_Log__c> scope) {
        try{
            if(queryId != null){
                for (Emarsys_Log__c log : scope) {
                    log.Query_Id__c = queryId;
                }
                update scope;
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
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
    *  @description     Get data to be queried about reaction updates
    *  @date            19/10/2018
    *  @return          void
    ******************************************************************************/
    public void sendGettingEmailRequest() {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountEuro.name());
        List<Emarsys_Log__c> emailId = [
                SELECT Email_Id__c, Type__c
                FROM Emarsys_Log__c
                WHERE Email_Id__c <> ''
                AND (Type__c = NULL OR Type__c = 'Opened')
                AND Query_Id__c = NULL
                AND Business_Type__c IN: countries
                ORDER BY Last_Check__c
                LIMIT 1
        ];
        //AND (Last_Check__c <: Datetime.now().addMinutes(-15)  OR Last_Check__c = NULL)
        if (!emailId.isEmpty()) {
            currentEmailId = emailId.get(0).Email_Id__c;
            if(emailId.get(0).Type__c == null){
                queryId = String.valueOf(EmarsysWebService.sendResponseTypeRequest(currentEmailId, 'opened', emarsysAccount));
                currentType = null;
            } else if(emailId.get(0).Type__c.equals('Opened')){
                queryId = String.valueOf(EmarsysWebService.sendResponseTypeRequest(currentEmailId, 'clicked', emarsysAccount));
                currentType = 'Opened';
            }
        } else {
            currentEmailId = null;
            currentType = null;
            queryId = null;
        }
    }

}