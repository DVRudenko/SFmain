global class EmarsysTypeGetQuery implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public Map<String, Set<String>> contactForUpdateTypeMap;
    public Set<String> logsToRewrite;

    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc)
    *  Summary         : Collect List of Emarsys contacts to pass to the interface method execute
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> setEmailId = getSetOfResponse();
        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());
        return Database.getQueryLocator(
                'SELECT Id, Email_Id__c, Query_Id__c, Type__c, Lead__c, Opportunity__c ' +
                        'FROM Emarsys_Log__c ' +
                        'WHERE (Email_Id__c IN :setEmailId OR Email_Id__c IN :logsToRewrite)' +
                        'AND Business_Type__c = \'RU\'' +
                        'AND Type__c = :reactionType'
        );
    }

    global Set<String> getSetOfResponse() {
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());
        List<AggregateResult> listOfCheckRequest = [
                SELECT Email_Id__c, Query_Id__c
                FROM Emarsys_Log__c
                WHERE Type__c = :reactionType
                AND Email_Id__c <> ''
                AND Query_Id__c <> null
                AND Business_Type__c = 'RU'
                GROUP BY Email_Id__c, Query_Id__c
        ];
        contactForUpdateTypeMap = new Map<String, Set<String>>();
        logsToRewrite = new Set<String>();
        for (AggregateResult result : listOfCheckRequest) {
            String resBody = EmarsysWebService.getResponseTypeRequest(String.valueOf(result.get('Query_Id__c')), emarsysAccount);
            if (resBody.contains('"replyCode":6029')) {
                logsToRewrite.add(String.valueOf(result.get('Email_Id__c')));
            } else if ((!resBody.contains('The requested data is currently generated')) && (resBody.contains('"replyCode":0'))) {
                Set<String> contacts = new Set<String>();
                EmarsysTypeContactEntity listingEntity = new EmarsysTypeContactEntity();

                listingEntity = (EmarsysTypeContactEntity) JSON.deserialize(resBody, EmarsysTypeContactEntity.class);
                System.debug(resBody);
                System.debug(listingEntity.data);
                contacts = listingEntity.data.contact_ids;

                contactForUpdateTypeMap.put(String.valueOf(result.get('Email_Id__c')), contacts);
            }
        }
        return contactForUpdateTypeMap.keySet();
    }

    global void execute(Database.BatchableContext BC, List<Emarsys_log__c> scope) {
        try {
            // Fill set of ID all records Lead/Opportunity which Type__c can be updated
            Set<ID> scopeId = new Set<ID>();
            for (Emarsys_Log__c log : scope) {
                if (log.Lead__c <> null) {
                    scopeId.add(log.Lead__c);
                } else if (log.Opportunity__c <> null) {
                    scopeId.add(log.Opportunity__c);
                }
            }
            // Fill Map Lead.Id/Emarsys_Contact_Id  which Type__c can be updated
            List<Lead> listLeadConnect = [SELECT Id, Emarsys_Contact_Id__c FROM Lead WHERE Id IN :scopeId];
            Map<Id, String> leadsWithContactMap = new Map<Id, String>();
            for (Lead lead : listLeadConnect) {
                leadsWithContactMap.put(lead.id, lead.Emarsys_Contact_Id__c);
            }
            // Fill Map Opportunity.Id/Emarsys_Contact_Id  which type__c can be updated
            List<Opportunity> listOppConnect = [SELECT id, Emarsys_Contact_Id__c FROM Opportunity WHERE Id IN :scopeId];
            Map<Id, String> opportunitiesWithContactMap = new Map<Id, String>();
            for (Opportunity opportunity : listOppConnect) {
                opportunitiesWithContactMap.put(opportunity.id, opportunity.Emarsys_Contact_Id__c);
            }

            Set<String> contactIds = new Set<String>();
            for (Emarsys_Log__c log : scope) {
                if (logsToRewrite.contains(log.Email_id__c))  {
                    log.query_id__c = '';
                } else {
                    String contactId = '';
                    contactIds = contactForUpdateTypeMap.get(log.Email_id__c); // Getting Set of Emarsys_Contact_id with data from request(filter by email_id__c)
                    if (log.Lead__c <> null) {
                        contactId = leadsWithContactMap.get(log.Lead__c); // Get Emarsys_contact_id for current Log-record
                        if (contactIds.contains(contactId)) {
                            log.Type__c = 'Clicked';
                        } else log.Type__c = 'Opened';
                    } else if (log.Opportunity__c <> null) {
                        contactId = opportunitiesWithContactMap.get(log.Opportunity__c);
                        if (contactIds.contains(contactId)) {
                            log.Type__c = 'Clicked';
                        } else log.Type__c = 'Opened';
                    }
                }
            }
            update scope;

        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    global void finish(Database.BatchableContext BC) {
        reScheduleJob();
    }

    private void reScheduleJob() {
        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE NextFireTime = null OR
                (CronJobDetail.Name LIKE 'EmarsysLog Update Reaction Type%')
                LIMIT 100
        ];

        if (!jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }

        String reactionType = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name());
        List<Emarsys_Log__c> EmarsysLogCheck = [
                SELECT Id
                FROM Emarsys_Log__c
                WHERE Type__c = :reactionType
                AND Email_Id__c <> ''
                AND Business_Type__c = 'RU'
                LIMIT 1
        ];
        if (EmarsysLogCheck.size() <> 0) {
            String schedule = datetime.now().addMinutes(1).second() + ' ' + datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?' + ' *' + ' MON-FRI';
            EmarsysTypeReactionSchedule emarsysUpdateType = new EmarsysTypeReactionSchedule();
            System.schedule('EmarsysLog Update Reaction Type ' +
                    datetime.now().addMinutes(1).hour() + ':' + datetime.now().addMinutes(1).minute() + ':' + datetime.now().addMinutes(1).second(),
                    schedule,
                    emarsysUpdateType);
        }

    }
}