global class EmarsysRusLogsUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc)
    *  Summary         : Collect Russian Reaction Logs to pass them to the interface method execute
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date monthBeforeBatchLaunch = Date.today().addMonths(- 1);
        String query = 'SELECT Email_Id__c, Lead__c, Opportunity__c ' +
                'FROM Emarsys_Log__c ' +
                'WHERE CreatedDate > :monthBeforeBatchLaunch ' +
                'AND Is_Email_Body_Updated__c = false ' +
                'AND Business_Type__c = \'RU\' ' +
                'AND Email_Id__c != null ' +
                'LIMIT 100'; //prevent many callouts to Emarsys
        return Database.getQueryLocator(query);
    }

    /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, list<Sobject> scope)
    *  Summary         : Update Body fields in Logs for each chunk of data
    *  CreatedDate     : 19/10/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job,
                         List<Sobject> scope - list of Leads
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Emarsys_Log__c> emarsysLogsScope) {
        try {
            Set<Id> leadsIds = new Set<Id>();
            Set<Id> opportunitiesIds = new Set<Id>();
            for (Emarsys_Log__c log : emarsysLogsScope) {
                leadsIds.add(log.Lead__c);
                opportunitiesIds.add(log.Opportunity__c);
            }

            List<RecordType> recordTypes = [
                    SELECT Id
                    FROM RecordType
                    WHERE (Name = 'Russian Sales' AND SObjectType = 'Lead') OR (Name = 'Russian Sales' AND SObjectType = 'Opportunity')
            ];
            Set<Id> recordTypesIds = new Set<Id>();
            for (RecordType recordType : recordTypes) {
                recordTypesIds.add(recordType.Id);
            }

            List<Lead> leadsList = [
                    SELECT Email
                    FROM Lead
                    WHERE Id IN :leadsIds AND RecordTypeId IN :recordTypesIds
            ];

            Map<String, Lead> leadsMap = new Map<String, Lead>();
            for (Lead lead : leadsList) {
                leadsMap.put(lead.Id, lead);
            }

            // Get Opportunity contacts
            Map<String, List<OpportunityContactRole>> opportunityContactRolesMap = getOpportunityContact(recordTypesIds, opportunitiesIds);

            for (Emarsys_Log__c log : emarsysLogsScope) {
                Boolean setLogAsUpdated = getLogStatus(log, leadsMap, opportunityContactRolesMap);
                if(setLogAsUpdated){
                    log.Is_Email_Body_Updated__c = true; //exclude log from update list
                } else {
                    String responseBody = EmarsysWebService.returnEmailUrl(log, leadsMap, opportunityContactRolesMap,
                            GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name()));
                    if (responseBody != '') {
                        if (! EmarsysWebService.emarsysSoftErrorCode.contains(responseBody)) {
                            EmarsysEmailDataEntity.JSON2Apex emailData = EmarsysEmailDataEntity.parse(responseBody);
                            log.Email_Body__c = EmarsysWebService.returnEmailData(emailData);
                        }
                        log.Is_Email_Body_Updated__c = true;
                    }
                }
            }
            update emarsysLogsScope;
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    private Map<String, List<OpportunityContactRole>> getOpportunityContact(Set<Id> recordTypesIds, Set<Id> opportunitiesIds) {
        Map<String, List<OpportunityContactRole>> opportunityContactRolesMap = new Map<String, List<OpportunityContactRole>>();
        for (Opportunity opportunityWithContacts : [
                SELECT Id, (SELECT Contact.Email, OpportunityId, IsPrimary
                            FROM OpportunityContactRoles
                            WHERE Contact.Email != null)
                FROM Opportunity
                WHERE Id IN :opportunitiesIds AND RecordTypeId IN :recordTypesIds
        ]) {
            for (OpportunityContactRole contactRole : opportunityWithContacts.OpportunityContactRoles) {
                if (opportunityContactRolesMap.get(opportunityWithContacts.Id) == null) {
                    opportunityContactRolesMap.put(opportunityWithContacts.Id, new List<OpportunityContactRole>{contactRole});
                } else {
                    opportunityContactRolesMap.get(opportunityWithContacts.Id).add(contactRole);
                }
            }
        }
        return opportunityContactRolesMap;
    }

    private Boolean getLogStatus(Emarsys_Log__c log, Map<String, Lead> leadsMap, Map<String, List<OpportunityContactRole>> opportunityContactRolesMap){
        Boolean isLogInvalid = false;
        if(log.Opportunity__c != null){
            if (opportunityContactRolesMap.get(log.Opportunity__c) == null) {
                isLogInvalid = true;
            }
        }
        return isLogInvalid;
    }

    global void finish(Database.BatchableContext BC) {

    }
}