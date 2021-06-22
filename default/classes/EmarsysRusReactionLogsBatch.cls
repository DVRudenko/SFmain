global class EmarsysRusReactionLogsBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    public AsyncApexJob asyncJob;
    public Set<Id> recordTypesIds;
    public List<SObject> parentSObjectsList;
    public String emailName;
    public String currentEmailId;
    public String currentHtmlSource; // email body template
    global Boolean canUpdateSegmentDate;
    global List<Emarsys_Contact_Subscriptions__c> emarsysContactSubscriptions;
    global List<String> contacts;

    private static final String EMARSYS_LOGS_R_FIELD = 'Emarsys_Logs__r';
    private static final String EMARSYS_CONTACT_ID_FIELD = 'Emarsys_Contact_Id__c';
    private static final String OWNER_ID_FIELD = 'OwnerId';
    private static final String ID_FIELD = 'Id';

    global EmarsysRusReactionLogsBatch(List<String> contacts, String segmentId) {
        this.contacts = contacts;
        this.emarsysContactSubscriptions = getEmarsysSubscriptionSegment(segmentId);
    }

    /*******************************************************************************
    *  Name            : Iterable<String> start(Database.BatchableContext bc)
    *  Summary         : Collect List of Emarsys contacts to pass to the interface method execute
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Iterable<String>
    *****************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        return getEmarsysContactsListing(bc);
    }

    global void execute(Database.BatchableContext BC, List<String> scope) {
        try {
            createEmarsysLogs(scope, this.emarsysContactSubscriptions.get(0));
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    global void finish(Database.BatchableContext BC) {
        this.asyncJob = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];

        if (this.asyncJob != null && this.asyncJob.Status == 'Completed' && this.canUpdateSegmentDate) {
            System.debug('JOB ID ' + bc.getJobId() + ' JOB ITEMS ' + this.asyncJob.JobItemsProcessed);
        }

        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'EmarsysLog Update Reaction Type%'
                LIMIT 100
        ];
        if (jobsList.isEmpty()) {
            List<Emarsys_Log__c> emarsysLogCheck = [
                    SELECT Id
                    FROM Emarsys_Log__c
                    WHERE Type__c = 'Reaction Open or Click'
                    AND Email_Id__c <> ''
                    AND Business_Type__c = 'RU'
                    LIMIT 1
            ];
            if (emarsysLogCheck.size() <> 0) {
                String schedule = Datetime.now().addMinutes(1).second() + ' ' + Datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?' + ' *' + ' MON-FRI';
                EmarsysTypeReactionSchedule emarsysUpdateType = new EmarsysTypeReactionSchedule();
                System.schedule('EmarsysLog Update Reaction Type ' +
                        Datetime.now().addMinutes(1).hour() + ':' + Datetime.now().addMinutes(1).minute() + ':' + Datetime.now().addMinutes(1).second(),
                        schedule,
                        emarsysUpdateType);
            }
        }
    }

    /*******************************************************************************
    *  Name            : void createEmarsysLogs(List<String> scope)
    *  Summary         : create Emarsys Reactions Russian logs
    *  CreatedDate     : 12/10/2017
    *  Parameters      : List<String> scope - contacts list from Emarsys
    *  Returns         : void
    *****************************************************************************/
    public void createEmarsysLogs(List<String> scope, Emarsys_Contact_Subscriptions__c emarsysContactSubscription) {

        //Emarsys_Contact_Subscriptions__c emarsysContactSubscription = emarsysContactSubscriptions.get(0);
        this.emailName = emarsysContactSubscription.Email_Name__c;

        String emarsysContactsIds = '';
        for (String contactId : scope) {
            emarsysContactsIds += contactId + ', ';
        }
        emarsysContactsIds = emarsysContactsIds.removeEnd(', ');

        this.recordTypesIds = getRussianRecordTypesIdsSet();
        this.parentSObjectsList = returnSObjectsList(emarsysContactSubscription, this.recordTypesIds, scope);

        // Get Email history and launch data
        Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap = new Map<String, EmarsysEmailHistoryEntity.Data>();
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        emailsLaunchDataMap = EmarsysWebService.getEmailLaunchData(emarsysContactsIds, emarsysAccount);

        // Email campaign data
        getEmailCampaignData(emailsLaunchDataMap);

        Map<Id, String> sObjectToOwnerManagerMap = generateSObjectToOwnerManagerMap();
        List<Emarsys_Log__c> newLogsToInsert = new List<Emarsys_Log__c>();
        for (SObject currentSObject : this.parentSObjectsList) {
            // Create log only for objects that haven't got Emarsys Log, other data wouldn't log
            if (currentSObject.getSObjects(EMARSYS_LOGS_R_FIELD) == null || currentSObject.getSObjects(EMARSYS_LOGS_R_FIELD).isEmpty()) {
                if (emailsLaunchDataMap.get(String.valueOf(currentSObject.get(EMARSYS_CONTACT_ID_FIELD))) != null) {
                    if (String.valueOf(emailsLaunchDataMap.get(String.valueOf(currentSObject.get(EMARSYS_CONTACT_ID_FIELD))).emailId) == currentEmailId) {
                        Emarsys_Log__c newLog = new Emarsys_Log__c(
                                Business_Type__c = 'RU',
                                Email_Id__c = String.valueOf(emailsLaunchDataMap.get(String.valueOf(currentSObject.get(EMARSYS_CONTACT_ID_FIELD))).emailId),
                                Email_Date__c = String.valueOf(emailsLaunchDataMap.get(String.valueOf(currentSObject.get(EMARSYS_CONTACT_ID_FIELD))).launch_date),
                                Email_Body__c = currentHtmlSource,
                                Email_Name__c = emarsysContactSubscription.Email_Name__c,
                                Segment_Name__c = emarsysContactSubscription.Subscription_Name__c,
                                Is_Email_Body_Updated__c = false,
                                OwnerId = String.valueOf(currentSObject.get(OWNER_ID_FIELD)),
                                Type__c = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name())
                        );

                        if (emarsysContactSubscription.Type__c == 'Lead') {
                            newLog.Lead__c = String.valueOf(currentSObject.get(ID_FIELD));
                        } else if (emarsysContactSubscription.Type__c == 'Opportunity') {
                            newLog.Opportunity__c = String.valueOf(currentSObject.get(ID_FIELD));
                        }

                        if (sObjectToOwnerManagerMap.get(String.valueOf(currentSObject.get(OWNER_ID_FIELD))) != null) {
                            newLog.Owner_Manager_Email__c = sObjectToOwnerManagerMap.get(String.valueOf(currentSObject.get(OWNER_ID_FIELD)));
                        }
                        newLogsToInsert.add(newLog);
                    }
                }
            }
        }

        insert newLogsToInsert;
    }

    /*******************************************************************************
    *  Name            : getEmarsysContactsListing()
    *  Summary         : Return Emarsys contacts listing depending on Emarsys Subscription
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : EmarsysListingContactsEntity
    ******************************************************************************/
    @TestVisible
    private List<String> getEmarsysContactsListing(Database.BatchableContext bc) {
        // Get Emarsys_Contact_Subscriptions__c list from Custom Settings
        Boolean isBatchInProgress = false;
        this.canUpdateSegmentDate = false;

        try {
            if (!this.emarsysContactSubscriptions.isEmpty() && !this.contacts.isEmpty()) {

                List<AsyncApexJob> currentJob = [SELECT Id, ApexClassId FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                if (currentJob.size() != 0) {
                    List<AsyncApexJob> existingJob = [
                            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                            FROM AsyncApexJob
                            WHERE ApexClassId = :currentJob.get(0).ApexClassId
                            AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued' OR Status = 'Holding')
                            AND Id != :bc.getJobId()
                            LIMIT 1
                    ];
                    if (existingJob.size() != 0) {
                        isBatchInProgress = true;
                    }
                }

                if (!isBatchInProgress) {
                    this.canUpdateSegmentDate = true;
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
        return this.contacts == null ? new List<String>() : this.contacts;
    }

    /*******************************************************************************
    *  Name            : List<Emarsys_Contact_Subscriptions__c> getEmarsysSubscriptionSegments()
    *  Summary         : Get Emarsys Contact Subscription Segments from Custom Settings
    *  CreatedDate     : 13/10/2017
    *  Parameters      : -
    *  Returns         : List<Emarsys_Contact_Subscriptions__c>
    *****************************************************************************/
    @TestVisible
    private List<Emarsys_Contact_Subscriptions__c> getEmarsysSubscriptionSegment(String segmentId) {
        List<Emarsys_Contact_Subscriptions__c> listEmarsysSubscriptions = [
                SELECT Email_Name__c, Subscription_Name__c, Segment_Id__c, Type__c
                FROM Emarsys_Contact_Subscriptions__c
                WHERE Segment_Id__c = :segmentId
                LIMIT 1
        ];
        return listEmarsysSubscriptions;
    }

    /*******************************************************************************
    *  Name            : getRussianRecordTypesIdsSet()
    *  Summary         : return Russian Record Types
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : Set<Id>
    ******************************************************************************/
    @TestVisible
    private Set<Id> getRussianRecordTypesIdsSet() {
        Set<Id> recordTypesIds = new Set<Id>();
        List<RecordType> recordTypesList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND (SObjectType = 'Lead' OR SObjectType = 'Opportunity')
        ];
        for (RecordType recordType : recordTypesList) {
            recordTypesIds.add(recordType.Id);
        }
        return recordTypesIds;
    }

    /*******************************************************************************
    *  Name            : returnSObjectsList(Emarsys_Contact_Subscriptions__c emarsysContactSubscription, Set<Id> recordTypesIds, List<String> contactsIds)
    *  Summary         : return sObjetcs List
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Emarsys_Contact_Subscriptions__c emarsysContactSubscription - subscription from custom setting
                         Set<Id> recordTypesIds - supported record types ids set
                         List<String> contactsIds - contacts listing from Emarsys
    *  Returns         : List<SObject> parentSObjectsList
    ******************************************************************************/
    public List<SObject> returnSObjectsList(Emarsys_Contact_Subscriptions__c emarsysContactSubscription, Set<Id> recordTypesIds, List<String> contactsIds) {
        this.parentSObjectsList = new List<SObject>();
        if (emarsysContactSubscription.Type__c == 'Lead') {
            this.parentSObjectsList = [
                    SELECT Name, OwnerId, Emarsys_Contact_Id__c, (
                            SELECT Id
                            FROM Emarsys_Logs__r
                            WHERE (Email_Name__c = :emarsysContactSubscription.Subscription_Name__c OR Segment_Name__c = :emarsysContactSubscription.Subscription_Name__c)
                            LIMIT 1
                    )
                    FROM Lead
                    WHERE RecordTypeId IN :recordTypesIds AND Emarsys_Contact_Id__c IN :contactsIds AND Active_owner__c = true
            ];
        } else if (emarsysContactSubscription.Type__c == 'Opportunity') {
            this.parentSObjectsList = [
                    SELECT Name, OwnerId, Emarsys_Contact_Id__c, (
                            SELECT Id
                            FROM Emarsys_Logs__r
                            WHERE (Email_Name__c = :emarsysContactSubscription.Subscription_Name__c OR Segment_Name__c = :emarsysContactSubscription.Subscription_Name__c)
                            LIMIT 1
                    )
                    FROM Opportunity
                    WHERE RecordTypeId IN :recordTypesIds AND Emarsys_Contact_Id__c IN :contactsIds AND Owner.IsActive = true
            ];
        }

        return this.parentSObjectsList;
    }

    /*******************************************************************************
    *  Name            : getEmailCampaignData()
    *  Summary         : get Email Campaign id and name from Emarsys
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap - email history data from Emarsys
    *  Returns         : void
    ******************************************************************************/
    private void getEmailCampaignData(Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap) {
        Set<String> emailIdsSet = new Set<String>();
        for (String contactId : emailsLaunchDataMap.keySet()) {
            emailIdsSet.add(String.valueOf(emailsLaunchDataMap.get(contactId).emailId));
        }

        for (String emailId : emailIdsSet) {
            String emailDataResponseBody = sendEmailCampaignDataRequest(emailId);
            EmarsysGetEmailDataEntity.JSON2Apex emailData = EmarsysGetEmailDataEntity.parse(emailDataResponseBody);
            if (emailData.data.name.contains(emailName)) {
                this.currentEmailId = emailId;
                this.currentHtmlSource = emailData.data.html_source;
                break;
            }
            System.debug('DEBUG CURRENT EMAIL ID ===' + this.currentEmailId);
        }
    }

    /*******************************************************************************
    *  Name            : sendEmailCampaignDataRequest(String emailId)
    *  Summary         : send request
    *  CreatedDate     : 12/10/2017
    *  Parameters      : String emailId - id of email for receiving data
    *  Returns         : String
    ******************************************************************************/
    private String sendEmailCampaignDataRequest(String emailId) {
        String endPointGetEmailName = 'https://api.emarsys.net/api/v2/email/' + emailId;
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        HttpRequest emailDataRequest = EmarsysWebService.generateEmailDataRequest(endPointGetEmailName, emarsysAccount);
        Http http = new Http();
        HttpResponse emailDataResponse = http.send(emailDataRequest);
        return emailDataResponse.getBody();
    }

    /*******************************************************************************
    *  Name            : generateSObjectToOwnerManagerMap()
    *  Summary         : generate SObject To Owner Manager (for getting his email) Map
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : Map<Id, String> sObjectToOwnerManagerMap
    ******************************************************************************/
    public Map<Id, String> generateSObjectToOwnerManagerMap() {
        Map<Id, String> sObjectToOwnerManagerMap = new Map<Id, String>();
        Set<Id> sObjectsOwnersIdsSet = new Set<Id>();
        for (SObject currentSObject : this.parentSObjectsList) {
            if (String.valueOf(currentSObject.get(OWNER_ID_FIELD)).substring(0, 3) == '005') {
                sObjectsOwnersIdsSet.add(String.valueOf(currentSObject.get(OWNER_ID_FIELD)));
            }
        }

        List<User> sObjectOwners = [
                SELECT Manager.Email
                FROM User
                WHERE Id IN :sObjectsOwnersIdsSet
        ];
        for (User user : sObjectOwners) {
            if (user.Manager != null) {
                sObjectToOwnerManagerMap.put(user.Id, user.Manager.Email);
            }
        }

        return sObjectToOwnerManagerMap;
    }
}