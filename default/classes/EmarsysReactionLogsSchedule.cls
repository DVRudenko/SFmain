global class EmarsysReactionLogsSchedule implements Schedulable {
  public static List<SObject> parentSObjectsList;


  /*******************************************************************************
  *  Name            : execute(SchedulableContext sc)
  *  Summary         : run future job for updating segment in Emarsys and creating reaction logs
    *  CreatedDate     : 17/08/2017
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
  ******************************************************************************/
    global void execute(SchedulableContext sc) {
        executeFutureJob();
    }


    /*******************************************************************************
    *  Name            : executeFutureJob()
    *  Summary         : execute job with future annotation for sending callout    
    *  CreatedDate     : 17/08/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @future(callout = true)
    public static void executeFutureJob() {
        try {
            List<Emarsys_Contact_Subscriptions__c> listEmarsysSubscriptions = [
                    SELECT Subscription_Name__c, Segment_Id__c, Type__c
                    FROM Emarsys_Contact_Subscriptions__c
                    ORDER BY Last_Update_Segment_Date__c
                    LIMIT 1];
            if (! listEmarsysSubscriptions.isEmpty()) {
              String endPointListingContacts = 'https://api.emarsys.net/api/v2/filter/' + listEmarsysSubscriptions.get(0).Segment_Id__c + '/contacts/?offset=0&limit=1000000';
              HttpRequest requestListingContacts = EmarsysWebService.generateListingContactsRequest(endPointListingContacts, 'PPR');
              Http http = new Http();
              HttpResponse responseListingContacts = http.send(requestListingContacts);
                System.debug('DEBUG: RESPONSE BODY === ' + responseListingContacts.getBody());
                if (! responseListingContacts.getBody().contains('"data":""')) {
                    EmarsysListingContactsEntity listingEntity = (EmarsysListingContactsEntity) JSON.deserialize(responseListingContacts.getBody(), EmarsysListingContactsEntity.class);
                    createLogs(listingEntity, listEmarsysSubscriptions.get(0));
                    scheduleUpdatingSegmentJob();
                } else {
                    scheduleCreatingLogsJob();
                }
            }     
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : scheduleCreatingLogsJob()
    *  Summary         : schedule next job to create logs   
    *  CreatedDate     : 15/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void scheduleCreatingLogsJob() {
        String schedule = datetime.now().addMinutes(5).second() + ' ' + datetime.now().addMinutes(5).minute() + ' 6-18' + ' ?' 
                + ' *' + ' MON-FRI';
        EmarsysReactionLogsSchedule scheduledCreatingLogs = new EmarsysReactionLogsSchedule();
        System.schedule('Emarsys Reaction Logs ' + datetime.now().addMinutes(5).minute(), schedule, scheduledCreatingLogs); 

        List<CronTrigger> jobsList = [
                SELECT Id 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE 'Emarsys Reaction Logs%' AND PreviousFireTime != null
                LIMIT 100];
        if (! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }
    } 


    /*******************************************************************************
    *  Name            : createLogs(EmarsysListingContactsEntity listingEntity, Emarsys_Contact_Subscriptions__c emarsysContactSubscription)
    *  Summary         : create logs    
    *  CreatedDate     : 15/08/2017
    *  Parameters      : EmarsysListingContactsEntity listingEntity - parsed response from Emarsys, 
              Emarsys_Contact_Subscriptions__c emarsysContactSubscription - subscription from custom setting
    *  Returns         : void
    ******************************************************************************/
    public static void createLogs(EmarsysListingContactsEntity listingEntity, Emarsys_Contact_Subscriptions__c emarsysContactSubscription) {
      Set<Id> recordTypesIdsSet = returnRecordTypesIdsSet();
        parentSObjectsList = retunSObjectsList(emarsysContactSubscription, recordTypesIdsSet, listingEntity);
        Map<Id, String> sObjectToOwnerManagerMap = generateSObjectToOwnerManagerMap();
        List<Emarsys_Log__c> newLogsToInsertList = new List<Emarsys_Log__c>();
        for (SObject currentSObject : parentSObjectsList) {
            if (currentSObject.getSObjects('Emarsys_Logs__r') == null || currentSObject.getSObjects('Emarsys_Logs__r').isEmpty()) {
                Emarsys_Log__c newLog = new Emarsys_Log__c(
                    Email_Name__c = emarsysContactSubscription.Subscription_Name__c, 
                    OwnerId = String.valueOf(currentSObject.get('OwnerId')),
                    Type__c = 'Reaction Open or Click');
                if (emarsysContactSubscription.Type__c == 'Lead') {
                    newLog.Lead__c = String.valueOf(currentSObject.get('Id'));
                } else if (emarsysContactSubscription.Type__c == 'Opportunity') {
                    newLog.Opportunity__c = String.valueOf(currentSObject.get('Id'));
                }

                if (sObjectToOwnerManagerMap.get(String.valueOf(currentSObject.get('OwnerId'))) != null) {
                    newLog.Owner_Manager_Email__c = sObjectToOwnerManagerMap.get(String.valueOf(currentSObject.get('OwnerId')));
                }
                newLogsToInsertList.add(newLog);
            }
        }

        emarsysContactSubscription.Last_Update_Segment_Date__c = datetime.now();

        insert newLogsToInsertList;
        update emarsysContactSubscription;
    }


    /*******************************************************************************
    *  Name            : returnRecordTypesIdsSet()
    *  Summary         : return record types    
    *  CreatedDate     : 15/08/2017
    *  Parameters      : -
    *  Returns         : Set<Id>
    ******************************************************************************/
    public static Set<Id> returnRecordTypesIdsSet() {
      Set<Id> recordTypesIdsSet = new Set<Id>();
      List<RecordType> recordTypesList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND (SObjectType = 'Lead' OR SObjectType = 'Opportunity')];
        for (RecordType recordType : recordTypesList) {
          recordTypesIdsSet.add(recordType.Id);
        }

        return recordTypesIdsSet;
    }


    /*******************************************************************************
    *  Name            : returnSObjectsList(Emarsys_Contact_Subscriptions__c emarsysContactSubscription, Set<Id> recordTypesIdsSet, EmarsysListingContactsEntity listingEntity)
    *  Summary         : return sObjetcs List    
    *  CreatedDate     : 15/08/2017
    *  Parameters      : EmarsysListingContactsEntity listingEntity - parsed response from Emarsys, 
              Emarsys_Contact_Subscriptions__c emarsysContactSubscription - subscription from custom setting
              Set<Id> recordTypesIdsSet - supported record types ids set
    *  Returns         : List<SObject> parentSObjectsList
    ******************************************************************************/
    public static List<SObject> retunSObjectsList(Emarsys_Contact_Subscriptions__c emarsysContactSubscription, Set<Id> recordTypesIdsSet, EmarsysListingContactsEntity listingEntity) {
      parentSObjectsList = new List<SObject>();
        if (emarsysContactSubscription.Type__c == 'Lead') {
            parentSObjectsList = [
                    SELECT Name, OwnerId, (SELECT Id FROM Emarsys_Logs__r WHERE Email_Name__c = :emarsysContactSubscription.Subscription_Name__c LIMIT 1)
                    FROM Lead
                    WHERE RecordTypeId IN :recordTypesIdsSet AND Emarsys_Contact_Id__c IN :listingEntity.data AND Owner.IsActive = true];
        } else if (emarsysContactSubscription.Type__c == 'Opportunity') {
            parentSObjectsList = [
                    SELECT Name, OwnerId, (SELECT Id FROM Emarsys_Logs__r WHERE Email_Name__c = :emarsysContactSubscription.Subscription_Name__c LIMIT 1)
                    FROM Opportunity
                    WHERE RecordTypeId IN :recordTypesIdsSet AND Emarsys_Contact_Id__c IN :listingEntity.data AND Owner.IsActive = true];
        }

        return parentSObjectsList;
    }


    /*******************************************************************************
    *  Name            : generateSObjectToOwnerManagerMap()
    *  Summary         : generate SObject To Owner Manager (for getting his email) Map    
    *  CreatedDate     : 15/08/2017
    *  Parameters      : -
    *  Returns         : Map<Id, String> sObjectToOwnerManagerMap
    ******************************************************************************/
    public static Map<Id, String> generateSObjectToOwnerManagerMap() {
      Map<Id, String> sObjectToOwnerManagerMap = new Map<Id, String>();
        Set<Id> sObjectsOwnersIdsSet = new Set<Id>();
        for (SObject currentSObject : parentSObjectsList) {
            if (String.valueOf(currentSObject.get('OwnerId')).substring(0, 3) == '005') {
                sObjectsOwnersIdsSet.add(String.valueOf(currentSObject.get('OwnerId')));
            }
        }

        List<User> sObjectOwners = [
                SELECT Manager.Email
                FROM User
                WHERE Id IN :sObjectsOwnersIdsSet];
        for (User user : sObjectOwners) {
            if (user.Manager != null) {
                sObjectToOwnerManagerMap.put(user.Id, user.Manager.Email);
            }
        }

        return sObjectToOwnerManagerMap;
    }


    /*******************************************************************************
    *  Name            : scheduleUpdatingSegmentJob()
    *  Summary         : schedule next job to update segment    
    *  CreatedDate     : 15/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void scheduleUpdatingSegmentJob() {
        String schedule = datetime.now().addMinutes(1).second() + ' ' + datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?' 
                + ' *' + ' MON-FRI';
        EmarsysReactionLogsSchedule scheduledCreatingLogs = new EmarsysReactionLogsSchedule();
        System.schedule('Emarsys Reaction Logs ' + datetime.now().addMinutes(1).minute(), schedule, scheduledCreatingLogs); 

        List<CronTrigger> jobsList = [
                SELECT Id 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE 'Emarsys Reaction Logs%' AND PreviousFireTime != null
                LIMIT 100];
        if (! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }
    }
}