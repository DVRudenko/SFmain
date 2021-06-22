global class EmarsysTypeSetQuery implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Integer queryId;

    /*******************************************************************************
    *  Name            : start(Database.BatchableContext bc)
    *  Summary         : Collect List of Emarsys logs to pass to the interface method execute
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String emailId = sendGettingEmailRequest();
        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());
        return Database.getQueryLocator(
                'SELECT Id, Query_Id__c, Email_Id__c, Type__c ' +
                        'FROM Emarsys_Log__c ' +
                        'WHERE Type__c = :reactionType ' +
                        'AND Email_Id__c = :emailId ' +
                        'AND Business_Type__c = \'RU\''
        );
    }

    global String sendGettingEmailRequest() {
        String currentEmailId;
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());
        List<Emarsys_log__c> emailId = [
                SELECT Email_Id__c
                FROM Emarsys_Log__c
                WHERE Type__c = :reactionType
                AND Email_Id__c <> ''
                AND Query_Id__c = null
                AND Business_Type__c = 'RU'
                LIMIT 1
        ];
        if (!emailId.IsEmpty()) {
            currentEmailId = emailId.get(0).Email_Id__c;
            queryId = EmarsysWebService.sendResponseTypeRequest(currentEmailId, 'clicked', emarsysAccount);
        } else {
            currentEmailId = '0';
            queryId = null;
        }
        return currentEmailId;
    }

    global void execute(Database.BatchableContext BC, List<Emarsys_Log__c> scope) {
        try {
            if (queryId != null) {
                for (Emarsys_Log__c log : scope) {
                    log.Query_Id__c = String.valueOf(queryId);
                }
                update scope;
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    global void finish(Database.BatchableContext BC) {

    }


}