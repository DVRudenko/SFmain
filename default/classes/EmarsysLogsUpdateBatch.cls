global class EmarsysLogsUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {


    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc)
    *  Summary         : Collect Logs to pass them to the interface method execute
    *  CreatedDate     : 28/06/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date monthBeforeBatchLaunch = Date.today().addMonths(-1);
        String query = 'SELECT Email_Id__c, Lead__c, Opportunity__c FROM Emarsys_Log__c WHERE CreatedDate > :monthBeforeBatchLaunch AND Is_Email_Body_Updated__c = false' +
        ' AND (NOT Email_Name__c LIKE \'%Кейс%\')';
        return Database.getQueryLocator(query);
    }


    /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, list<Sobject> scope)
    *  Summary         : Update Body fields in Logs for each chunk of data
    *  CreatedDate     : 28/06/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job,
                            list<Sobject> scope - list of Leads
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Emarsys_Log__c> emarsysLogsScope) {
        try {
            Set<Id> leadsIdsSet = new Set<Id>();
            Set<Id> opportunitiesIdsSet = new Set<Id>();
            for (Emarsys_Log__c log : emarsysLogsScope) {
                leadsIdsSet.add(log.Lead__c);
                opportunitiesIdsSet.add(log.Opportunity__c);
            }

            List<RecordType> recordTypesList = [
                    SELECT Id
                    FROM RecordType
                    WHERE (Name = 'Endkunde' AND SObjectType = 'Lead') OR
                    ((Name = 'Euroshell' OR Name = 'Euroshell Starts') AND SObjectType = 'Opportunity') OR
                    Name = 'Lotos'
            ];
            Set<Id> recordTypesIdsSet = new Set<Id>();
            for (RecordType recordType : recordTypesList) {
                recordTypesIdsSet.add(recordType.Id);
            }

            List<Lead> leadsList = [
                    SELECT Email
                    FROM Lead
                    WHERE Id IN :leadsIdsSet AND RecordTypeId IN :recordTypesIdsSet];
            Map<String, Lead> leadsMap = new Map<String, Lead>();
            for (Lead lead : leadsList) {
                leadsMap.put(lead.Id, lead);
            }

            List<OpportunityContactRole> opportunityContactRolesList = [
                    SELECT Contact.Email, OpportunityId
                    FROM OpportunityContactRole
                    WHERE OpportunityId IN :opportunitiesIdsSet AND IsPrimary = true AND Opportunity.RecordTypeId IN :recordTypesIdsSet];
            Map<String, OpportunityContactRole> opportunityContactRolesMap = new Map<String, OpportunityContactRole>();
            for (OpportunityContactRole opportunityContactRole : opportunityContactRolesList) {
                opportunityContactRolesMap.put(opportunityContactRole.OpportunityId, opportunityContactRole);
            }

            for (Emarsys_Log__c log : emarsysLogsScope) {
                String responseBody = returnEmailUrl(log, leadsMap, opportunityContactRolesMap);
                if (responseBody != '') {
                    EmarsysEmailDataEntity.JSON2Apex emailData = EmarsysEmailDataEntity.parse(returnEmailUrl(log, leadsMap, opportunityContactRolesMap));
                    log.Email_Body__c = returnEmailData(emailData);
                    log.Is_Email_Body_Updated__c = true;
                }
            }
            update emarsysLogsScope;
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : returnEmailUrl(Emarsys_Log__c log)
    *  Summary         : send request to Emarsys by Email Id and return Email Url
    *  CreatedDate     : 28/06/2017
    *  Parameters      : Emarsys_Log__c log - current log
    *  Returns         : String
    ******************************************************************************/
    public String returnEmailUrl(Emarsys_Log__c log, Map<String, Lead> leadsmap, Map<String, OpportunityContactRole> opportunityContactRolesMap) {
        String endPoint = 'https://api.emarsys.net/api/v2/email/' + log.Email_Id__c + '/url';
        String jsonBody = '{"key_id": "3","key_value": "';
        if (log.Lead__c != null) {
            if (! leadsmap.isEmpty() && leadsMap.containsKey(log.Lead__c) && leadsmap.get(log.Lead__c).Email != null) {
                jsonBody += leadsmap.get(log.Lead__c).Email;
            }
        } else if (log.Opportunity__c != null) {
            if (! opportunityContactRolesMap.isEmpty() && opportunityContactRolesMap.containsKey(log.Opportunity__c) && opportunityContactRolesMap.get(log.Opportunity__c).Contact.Email != null) {
                jsonBody += opportunityContactRolesMap.get(log.Opportunity__c).Contact.Email;
            }
        }

        jsonBody += '"}';
        System.debug('DEBUG: JSON BODY === ' + jsonBody);
        HttpRequest emailUrlRequest = EmarsysWebService.generateEmailURLRequest(endPoint, jsonBody, 'PPR_EU');
        Http http = new Http();
        HTTPResponse emailUrlResponse = http.send(emailUrlRequest);
        System.debug('DEBUG: RESPONSE EMAIL URL BODY === ' + emailUrlResponse.getBody());
        if (emailUrlResponse.getStatus() == 'OK') {
            return emailUrlResponse.getBody();
        } else {
            return '';
        }
    }


    /*******************************************************************************
    *  Name            : returnEmailData(EmarsysEmailDataEntity.JSON2Apex emailData)
    *  Summary         : send request to Url with Email Body and return data
    *  CreatedDate     : 26/06/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String returnEmailData(EmarsysEmailDataEntity.JSON2Apex emailData) {
        HttpRequest emailDataRequest = new HttpRequest();
        emailDataRequest.setEndpoint(emailData.data.url);
        emailDataRequest.setMethod('GET');
        Http http = new Http();
        HTTPResponse emailDataResponse = http.send(emailDataRequest);
        System.debug('DEBUG: RESPONSE EMAIL DATA BODY === ' + emailDataResponse.getBody());
        return emailDataResponse.getBody();
    }

    global void finish(Database.BatchableContext BC) {

    }
}