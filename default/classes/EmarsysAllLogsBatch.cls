global class EmarsysAllLogsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String query;
    public String emailName;
    public String campaignName;
    public String emarsysContactType;
    public Map<Id, SObject> sObjectsMap;
    public String currentEmailId;
    public String logEmailName;
    public String contactHistoryResponseBody;
    public Map<String, List<EmarsysEmailHistoryEntity.Data>> emailsLaunchDataMap;


    /*******************************************************************************
    *  Name            : EmarsysAllLogsBatch(String emailName, String campaignName, String emarsysContactType)
    *  Summary         : constructor
    *  CreatedDate     : 11/08/2017
    *  Parameters      : String emailName - email name for log, String campaignName -
                        campaign for log, String emarsysContactType - type of parent sobject for log
    *  Returns         :
    ******************************************************************************/
    public EmarsysAllLogsBatch(String emailName, String campaignName, String emarsysContactType) {
        this.emailName = emailName;
        this.campaignName = campaignName;
        this.emarsysContactType = emarsysContactType;
        this.sObjectsMap = new Map<Id, SObject>();
        this.query = returnStringQuery();
    }

    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc)
    *  Summary         : Collect SObjects to pass to the interface method execute
    *  CreatedDate     : 10/08/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        String emarsysContactsIds = '';
        try {
            Set<Id> sObjectsIdsSet = new Set<Id>();
            for (sObject currentSObject : scope) {
                if (validateEmarsysContactId(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c')))) {
                    emarsysContactsIds += String.valueOf(currentSObject.get('Emarsys_Contact_Id__c')) + ', ';
                    sObjectsIdsSet.add(currentSObject.Id);
                }
            }

            emarsysContactsIds = emarsysContactsIds.removeEnd(', ');

            //email history and launch data
            getEmailLaunchData(emarsysContactsIds);

            //current logs
            Map<Id, Set<String>> currentLogsMap = returnCurrentLogsMap(sObjectsIdsSet);

            //email campaign data
            getEmailCampaignData();

            //logs
            List<Emarsys_Log__c> logsList = generateLogsListToInsert(scope, currentLogsMap);
            logsList.sort();
            insert logsList;
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()) + ', emailName = ' + this.emailName + ', campaignName = ' + this.campaignName + ', emarsysContactType = ' + this.emarsysContactType + ', emarsysContactsIds = ' + emarsysContactsIds + ', contactHistoryResponseBody = ' + this.contactHistoryResponseBody, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : returnStringQuery()
    *  Summary         : return string query denpending on emarsys contact type
    *  CreatedDate     : 11/08/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String returnStringQuery() {
        List<RecordType> recordTypesList = [
                SELECT Id
                FROM RecordType
                WHERE (Name = 'Endkunde' OR Name = 'Euroshell' OR Name = 'Euroshell Starts' OR Name = 'Lotos') AND SObjectType = :this.emarsysContactType
        ];
        String recordTypesIds = '';
        for (RecordType recordType : recordTypesList) {
            recordTypesIds += '\'' + recordType.Id + '\'' + ', ';
        }

        recordTypesIds = recordTypesIds.removeEnd(', ');

        String query = '';
        if (emarsysContactType == 'Lead') {
            query = 'SELECT Emarsys_Contact_Id__c, Date_of_First_Subscription__c FROM Lead WHERE Emarsys_Contact_Id__c != null AND IsConverted = false AND RecordTypeId IN (' + recordTypesIds + ') AND LastModifiedDate = LAST_N_DAYS:30';
        } else if (emarsysContactType == 'Opportunity') {
            query = 'SELECT Emarsys_Contact_Id__c, Date_of_First_Subscription__c FROM Opportunity WHERE Emarsys_Contact_Id__c != null AND RecordTypeId IN (' + recordTypesIds + ') AND LastModifiedDate = LAST_N_DAYS:100';
        }
        return query;
    }


    /*******************************************************************************
    *  Name            : getEmailLaunchData()
    *  Summary         : get Email Campaign Id from emarsys
    *  CreatedDate     : 11/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void getEmailLaunchData(String emarsysContactsIds) {
    	this.contactHistoryResponseBody = sendContactHistoryRequest(emarsysContactsIds);
        Set<String> emailIdsSet = new Set<String>();
        EmarsysEmailHistoryEntity.JSON2Apex emailHistory = EmarsysEmailHistoryEntity.parse(this.contactHistoryResponseBody.replace(' ', 'T'));
        this.emailsLaunchDataMap = new Map<String, List<EmarsysEmailHistoryEntity.Data>>();
        for (EmarsysEmailHistoryEntity.Data emailHistoryData : emailHistory.data) {
            if (! this.emailsLaunchDataMap.containsKey(emailHistoryData.contactId)) {
                this.emailsLaunchDataMap.put(emailHistoryData.contactId, new List<EmarsysEmailHistoryEntity.Data>());
            }
            this.emailsLaunchDataMap.get(emailHistoryData.contactId).add(emailHistoryData);
        }
    }


    /*******************************************************************************
    *  Name            : sendContactHistoryRequest(String emarsysContactsIds)
    *  Summary         : send request
    *  CreatedDate     : 11/08/2017
    *  Parameters      : HttpRequest request request for getting contact history
    *  Returns         : String
    ******************************************************************************/
    private String sendContactHistoryRequest(String emarsysContactsIds) {
        String jsonbody = '{"startDate": "' + date.today() + '", "endDate": "' + date.today().addDays(1) + '", "contacts": [' + emarsysContactsIds + ']}';
        System.debug('DEBUG: JSON BODY === ' + jsonBody);
        HttpRequest historyRequest = EmarsysWebService.generateContactHistoryRequest(jsonBody, 'PPR_EU');
        Http http = new Http();
        HTTPResponse res = http.send(historyRequest);
        System.debug('DEBUG: HISTORY RESPONSE === ' + res.getBody());
        return res.getBody();
    }


    /*******************************************************************************
    *  Name            : returnCurrentLogsMap(Set<Id> sObjectsIdsSet)
    *  Summary         : return existing logs
    *  CreatedDate     : 11/08/2017
    *  Parameters      : Set<Id> sObjectsIdsSet
    *  Returns         : Map<Id, Set<String>>
    ******************************************************************************/
    private Map<Id, Set<String>> returnCurrentLogsMap(Set<Id> sObjectsIdsSet) {
        List<Emarsys_Log__c> currentLogsList = new List<Emarsys_Log__c>();
        Map<Id, Set<String>> currentLogsMap = new Map<Id, Set<String>>();
        if (this.emarsysContactType == 'Lead') {
            currentLogsList = [
                    SELECT Email_Id__c, Lead__c, Email_Name__c
                    FROM Emarsys_Log__c
                    WHERE Lead__c IN :sObjectsIdsSet
                    LIMIT 10000];
            for (Emarsys_Log__c log : currentLogsList) {
                if (! currentLogsMap.containsKey(log.Lead__c)) {
                    currentLogsMap.put(log.Lead__c, new Set<String>());
                }
                currentLogsMap.get(log.Lead__c).add(log.Email_Id__c);
            }
        } else if (this.emarsysContactType == 'Opportunity') {
            currentLogsList = [
                    SELECT Email_Id__c, Opportunity__c, Email_Name__c
                    FROM Emarsys_Log__c
                    WHERE Opportunity__c IN :sObjectsIdsSet
                    LIMIT 10000];
            for (Emarsys_Log__c log : currentLogsList) {
                if (! currentLogsMap.containsKey(log.Opportunity__c)) {
                    currentLogsMap.put(log.Opportunity__c, new Set<String>());
                }
                currentLogsMap.get(log.Opportunity__c).add(log.Email_Id__c);
            }
        }

        return currentLogsMap;
    }


    /*******************************************************************************
    *  Name            : getEmailCampaignData()
    *  Summary         : get Email Capmpaign id and name from Emarsys
    *  CreatedDate     : 11/08/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    private void getEmailCampaignData() {
        Set<String> emailIdsSet = new Set<String>();
        for (String contactId : emailsLaunchDataMap.keySet()) {
            for (EmarsysEmailHistoryEntity.Data data : emailsLaunchDataMap.get(contactId)) {
                emailIdsSet.add(String.valueOf(data.emailId));
            }
        }

    	for (String emailId : emailIdsSet) {
            String emailDataResposnseBody = sendEmailCampaignDataReqest(emailId);
            EmarsysGetEmailDataEntity.JSON2Apex emailData = EmarsysGetEmailDataEntity.parse(emailDataResposnseBody);
            if (emailData.data.name.contains(emailName)) {
                this.logEmailName = emailName;
                this.currentEmailId = emailId;
                break;
            }
        }
    }


    /*******************************************************************************
    *  Name            : sendEmailCampaignDataReqest(String emailId)
    *  Summary         : send request
    *  CreatedDate     : 11/08/2017
    *  Parameters      : String emailId - id of email for receiving data
    *  Returns         : String
    ******************************************************************************/
    private String sendEmailCampaignDataReqest(String emailId) {
        String endPointGetEmailName = 'https://api.emarsys.net/api/v2/email/' + emailId;
        HttpRequest emailDataRequest = EmarsysWebService.generateEmailDataRequest(endPointGetEmailName, 'PPR_EU');
        Http http = new Http();
        HTTPResponse emailDataResponse = http.send(emailDataRequest);
        System.debug('DEBUG: EMAIL NAME RESPONSE === ' + emailDataResponse.getBody());
        return emailDataResponse.getBody();
    }


    /*******************************************************************************
    *  Name            : generateLogsListToInsert(List<SObject> scope, Map<Id, Set<String>> currentLogsMap)
    *  Summary         : generate logs list
    *  CreatedDate     : 11/08/2017
    *  Parameters      : List<SObject> scope - SObjects scope, Map<Id, Set<String>> currentLogsMap - map of the existing logs
    *  Returns         : List<Emarsys_Log__c>
    ******************************************************************************/
    private List<Emarsys_Log__c> generateLogsListToInsert(List<SObject> scope, Map<Id, Set<String>> currentLogsMap) {
        List<Emarsys_Log__c> logsList = new List<Emarsys_Log__c>();
        for (SObject currentSObject : scope) {
            if (emailsLaunchDataMap.get(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c'))) != null) {
                for (EmarsysEmailHistoryEntity.Data data : emailsLaunchDataMap.get(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c')))) {
                    if (String.valueOf(data.emailId) == currentEmailId) {
                        Emarsys_Log__c log = new Emarsys_Log__c(Email_Id__c = String.valueOf(data.emailId),
                                Email_Date__c = String.valueOf(emailsLaunchDataMap.get(String.valueOf(data.launch_date))), Email_Name__c = logEmailName, Campaign_Name__c = campaignName,
                                Email_Body__c = 'The body will be appeared within 30 minutes');
                        if (emarsysContactType == 'Lead') {
                            log.Lead__c = String.valueOf(currentSObject.get('Id'));
                        } else if (emarsysContactType == 'Opportunity') {
                            log.Opportunity__c = String.valueOf(currentSObject.get('Id'));
                        }

                        if (! currentLogsMap.containsKey(String.valueOf(currentSObject.get('Id')))) {
                            logsList.add(log);
                            if (! sObjectsMap.containsKey(String.valueOf(currentSObject.get('Id')))) {
                                currentSObject.put('Date_of_First_Subscription__c', String.valueOf(emailsLaunchDataMap.get(String.valueOf(data.launch_date))));
                                sObjectsMap.put(String.valueOf(currentSObject.get('Id')), currentSObject);
                            }

                        } else if (! currentLogsMap.get(String.valueOf(currentSObject.get('Id'))).contains(String.valueOf(data.emailId))) {
                            logsList.add(log);
                        }
                    }
                }
            }
        }

        return logsList;
    }


    /*******************************************************************************
    *  Name            : validateEmarsysContactId(String emarsysContactId)
    *  Summary         : validate emarsys contact Id for numeric
    *  CreatedDate     : 28/08/2017
    *  Parameters      : String emarsysContactId - emarsys contact Id field
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean validateEmarsysContactId(String emasrsysContactId) {
        Pattern onlyNumericPattern = Pattern.compile('[0-9]+');
        Matcher onlyNumericMatcher = onlyNumericPattern.matcher(emasrsysContactId);
        return onlyNumericMatcher.matches();
    }


    /*******************************************************************************
    *  Name            : finish(Database.BatchableContext BC)
    *  Summary         : Invoke queueable class to update date_of_first_subscription__c in SObject
    *  CreatedDate     : 16/02/2017
    *  Parameters      : Database.BatchableContext BC - object to track the progress of the batch job
    *  Returns         : void
    ******************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.enqueueJob(new QueueClass(sObjectsMap.values()));
    }



    public class QueueClass implements Queueable {
        List<SObject> sObjectsList;

        /*******************************************************************************
        *  Name            : QueueClass(List<SObject> sObjectsList)
        *  Summary         : constructor
        *  CreatedDate     : 16/02/2017
        *  Parameters      : List<SObject> sObjectsList - sObjects to update
        *  Returns         :
        ******************************************************************************/
        public QueueClass(List<SObject> sObjectsList) {
            this.sObjectsList = sObjectsList;
        }


        /*******************************************************************************
        *  Name            : execute(QueueableContext context)
        *  Summary         : update date_of_first_subscription__c in SObject
        *  CreatedDate     : 16/02/2017
        *  Parameters      : QueueableContext context - contains the job ID
        *  Returns         : void
        ******************************************************************************/
        public void execute(QueueableContext context) {
            try {
                update sObjectsList;
            } catch (Exception e) {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }
}