public class RecordAssignCheckRuCtrl {

    public String inputRecordId {get;set;}                    // Вводимый Id записи
    public SObject record {get;set;}                          // Запись
    public String recordId {get; set;}                        // Id выбранной записи (Opportunity/Lead)
    public String callCustomerId {get; set;}                   // call customer id (Contact/Lead)
    

    public RecordAssignCheckParams params {get; set;}         // Объект параметров страницы (переменные)

    public List<SelectOption> listOfGroups {get;set;}         // Список групп пользователей для выбора (роли)
    public Map<String, List<SelectOption>> totalMapOfMembers; // Общая Мап всех пользователей
    public List<SelectOption> currentListOfMembers {get; set;}// Текущий список пользователей (на странице)
    public Map<String, FS_Tree_Province__mdt> allRegions {get; set;} // Все регионы
    public List<SelectOption> listOfRegions {get;set;}        // Список регионов (для отображения)
    public Map<String, SelectOption> resultTypes {get;set;}            // Список типов для "Activity"    
    public List<SelectOption> resultTypesList {             // Список типов для "Activity"
        get{
            return resultTypes.values();
        }
        set;
    }
    public static Map<String, String> resultTypesTranslations; // resulttype name => labes as it's shown to the user 
    public static Map<String, String> getResultTypesTranslations() {
        if (resultTypesTranslations == null) {
            resultTypesTranslations = new Map <String, String> {
                'Online transfer call' => 'Он-лайн перевод',
                'Call' => 'Звонок',
                'Post' => 'КП',
                'Meeting' => 'Встреча',
                'Non-target client' => 'Нецелевая встреча',
                'Disqualification' => 'Дисквалификация',
                'Callback' => 'Перезвон'
            };
        }
        return resultTypesTranslations;
    }      
    public List<SelectOption> disqualReasonsList {             // Список причин дисквалификации номера телефона (доступен при выборе результата звонка "Дисквалификация")
        get{
            if (disqualReasonsList == null) {
                disqualReasonsList = new List<SelectOption> ();
                Map <String, String> disqualCallStatuses = PhoneNumbersHandler.getPhoneStatuses_Disqual();
                for (String disqualStatusAPI : disqualCallStatuses.keySet()) {
                    disqualReasonsList.add(new SelectOption(disqualStatusAPI, disqualCallStatuses.get(disqualStatusAPI)));
                }
            }
            return disqualReasonsList;
        }
        set;
    }
    public static Map<String, String> getHasVehicleFleetOptionsTranslations(String recordId) {
        Map<String, String> hasVehicleFleetOptionsTranslations = new Map <String, String> ();
        Schema.SObjectType sobjectType;
        try {
            sobjectType = Id.valueOf(recordId).getsObjectType(); 
        } catch (Exception ex) {
            return hasVehicleFleetOptionsTranslations;
        }
        List<Schema.PicklistEntry>  hasVehicleFleetPicklistValues = GlobalUtils.getPicklistValues (sobjectType, 'HasVehicleFleet__c');
        for( Schema.PicklistEntry picklistVal : hasVehicleFleetPicklistValues) {
            hasVehicleFleetOptionsTranslations.put(picklistVal.getValue(), picklistVal.getLabel());
        }
        return hasVehicleFleetOptionsTranslations;
    }    
    public List<SelectOption> hasVehicleFleetOptions {             // Список причин дисквалификации номера телефона (доступен при выборе результата звонка "Дисквалификация")
        get{
            if (hasVehicleFleetOptions == null) {
                hasVehicleFleetOptions = new List<SelectOption> ();
                Map <String, String> optionsMap = getHasVehicleFleetOptionsTranslations(recordId);
                if (optionsMap.isEmpty()) return hasVehicleFleetOptions;
                for(String picklistVal : optionsMap.keySet()) {
                    String picklistLabel = optionsMap.get(picklistVal);
                    hasVehicleFleetOptions.add(new SelectOption(picklistVal, picklistLabel));
                }
            }
            return hasVehicleFleetOptions;
        }
        set;
    }

    private final Id currentUser = UserInfo.getUserId();      // Текущий пользователь
    private static List<String> keyRoles;  // Ключевые роли
    private static List<String> getKeyRoles () {   
        if (keyRoles == null) {
            keyRoles = new List <String> {
                'PPR Key Accounts Manager',
                'PPR Teamleader KAM'
            };
        }
        return keyRoles;
    }
    private Set<Id> specificOppOwners;                        // Список "специальных" юзеров-владельцев Opportunity
    private Set<Id> excludeOppOwnersId;                       // Исключить записи этих владельцов Opportunity
    private Id russianLeadRecordType;                         // Russian Sales Lead record type Id
    private Id russianOppRecordType;                          // Russian Sales Opportunity record type Id
    private Map<Integer, Integer> calendarDays;               // Подсчитанное кол-во "Бизнес дней" (ключ), количество прошедших "Календарных дней" (значение)
    private String assignedGroup;                             // Outbound Группа, за которой привязан менеджер КЦ
    private String distributionTeams;                   // Группа(ы), на которую(ые) происхоидт распределение записей через CustomDistribution App

    public List <CallHistoryRow> callHistoryRows {get;set;}
    public class CallHistoryRow implements Comparable {
        public String phoneVal {get; set;}
        public String statusVal {get; set;}
        public String statusModifiedDateVal {get; set;}
        public DateTime statusModifiedDateDT {get; set;} // needed for ordering items
        public CallHistoryRow (String phoneVal, String statusVal, DateTime statusModifiedDateDT) {
            this.phoneVal = phoneVal;
            this.statusVal = statusVal;
            this.statusModifiedDateVal = statusModifiedDateDT.format('dd.MM.yyyy HH:mm');
            this.statusModifiedDateDT = statusModifiedDateDT;
        }	
        public Integer compareTo(Object compareTo) {
            CallHistoryRow compareToObj = (CallHistoryRow)compareTo;
            if(compareToObj.statusModifiedDateDT > statusModifiedDateDT){
                return 1;
            } else {
                return -1;
            }
        }
    }


    public RecordAssignCheckRuCtrl(){}

    /*******************************************************************************
    *  Name            : init
    *  Summary         : initial page method
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void init(){
        prepareData();
    }

    /*******************************************************************************
    *  Name            : prepareData()
    *  Summary         : prepare different start information for process.
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void prepareData(){
        resultTypes = new Map<String, SelectOption>();
        excludeOppOwnersId = getExcludeOppOwnersId();
        specificOppOwners = getSpecificOppOwners();

        russianLeadRecordType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
        russianOppRecordType = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();

        calendarDays = getCalendarDays();

        List<GroupMember> assignedGroups = [
                SELECT GroupId, Id, SystemModstamp, UserOrGroupId, Group.name
                FROM GroupMember
                WHERE Group.Name like 'RU_CC_TransferTo-%' AND
                UserOrGroupId = :currentUser
        ];
        if(assignedGroups.size() != 0){
            assignedGroup = String.valueOf(assignedGroups.get(0).Group.Name).substringAfter('RU_CC_TransferTo-');
        } else {
            assignedGroup = '';
        }

        List<String> listOfOutboundRoles = new List<String>{
                'PPR Bryansk Partner Sales (1)',
                'PPR Bryansk Partner Sales (2)',
                'PPR Bryansk PSO 1',
                'PPR Bryansk PSO 2'
        };
        listOfGroups = new List<SelectOption>();
        for(UserRole role : Database.query('SELECT Id, DeveloperName, Name ' +
                'FROM UserRole ' +
                'WHERE Name in :listOfOutboundRoles ' +
                ' AND DeveloperName like \'%'+assignedGroup+'%\'')){
            listOfGroups.add(new SelectOption(role.DeveloperName, role.Name));
        }

        totalMapOfMembers = new Map<String, List<SelectOption>>();
        for(User user : [SELECT Id, Name, UserRole.DeveloperName FROM User WHERE UserRole.Name in :listOfOutboundRoles AND IsActive = true ORDER BY Name ASC]){
            if(totalMapOfMembers.containsKey(user.UserRole.DeveloperName)){
                List<SelectOption> members = totalMapOfMembers.get(user.UserRole.DeveloperName);
                members.add(new SelectOption(user.Id, user.Name));
                totalMapOfMembers.put(user.UserRole.DeveloperName, members);
            } else {
                totalMapOfMembers.put(user.UserRole.DeveloperName, new List<SelectOption>{new SelectOption(user.Id, user.Name)});
            }
        }
        currentListOfMembers = new List <SelectOption> ();
        List <SelectOption> listOfMembersByRoleDeveloperName = totalMapOfMembers.get(listOfGroups.get(0).getValue());
        if (listOfMembersByRoleDeveloperName != null && !listOfMembersByRoleDeveloperName.isEmpty()) {
            currentListOfMembers.add(new SelectOption('', Label.selectElem_NotSelected));
            currentListOfMembers.addAll(listOfMembersByRoleDeveloperName);
        }

        allRegions = new Map<String, FS_Tree_Province__mdt>();
        listOfRegions = new List<SelectOption>();
        listOfRegions.add(new SelectOption('EMPTY', 'Нет данных'));
        for(FS_Tree_Province__mdt region : [SELECT Id, Label, DeveloperName, Assigned_Team_Lead__c FROM FS_Tree_Province__mdt ORDER BY Label ASC]){
            allRegions.put(region.Label, region);
            listOfRegions.add(new SelectOption(region.Label, region.Label));
        }
        callHistoryRows = new List <CallHistoryRow> ();
    }

    /*******************************************************************************
    *  Name            : getRecordAccess()
    *  Summary         : allows user to get ownership of record from list. (based on parameter 'recordHashId')
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getRecordAccess(){
        try {
            Boolean CTIEnabled = Test.isRunningTest() ? true : Boolean.valueOf(Apexpages.currentPage().getParameters().get('CTIEnabled'));
            params = new RecordAssignCheckParams();
            record = null;
            recordId = inputRecordId.trim();
            if (recordId != null && recordId != '') {
                if(recordId.length() == 15 || recordId.length() == 18){
                    String sObjectType = Id.valueOf(recordId).getSobjectType().getDescribe().name;
                    if(sObjectType == 'Lead') {
                        List<SObject> listOfConvertedLeads = Database.query(
                                'SELECT Id, IsConverted, ConvertedOpportunityId ' +
                                        ' FROM  Lead ' +
                                        ' WHERE Id = :recordId AND IsConverted = true AND RecordTypeId = :russianLeadRecordType');
                        if(listOfConvertedLeads.size() == 1){
                            recordId = String.valueOf(listOfConvertedLeads.get(0).get('ConvertedOpportunityId'));
                            sObjectType = Id.valueOf(recordId).getSobjectType().getDescribe().name;
                        }
                    }

                    List<SObject> currentSObject;
                    if(sObjectType == 'Lead'){
                        List <String> fieldsList = getFields_queryLeadToGetRecordAccess();
                        currentSObject = queryLeadToGetRecordAccess(recordId, fieldsList);
                    } else if (sObjectType == 'Opportunity'){
                        List <String> fieldsList = getFields_queryOpportunityToGetRecordAccess();
                        currentSObject = queryOpportunityToGetRecordAccess(recordId, fieldsList);
                    }
                    if(currentSObject != null){
                        if(currentSObject.size() == 1){
                            record = currentSObject.get(0);
                            params.recordOwnerId = String.valueOf(record.get('OwnerId'));
                            params.recordStatus = getRecordStatus(record, params);
                            if (CTIEnabled == true) params.activity.description = Naumen_RecordsHelper.getOperatorComment(record);
                            if(sObjectType == 'Lead'){
                                params.currentRegion = (String.valueOf(record.get('Region__c')) == null ? 'EMPTY' : String.valueOf(record.get('Region__c')));
                                if (CTIEnabled == true) callHistoryRows = createCallHistory_Lead(record);
                            } else if(sObjectType == 'Opportunity'){
                                Account oppAccount = [SELECT Id, Region__c FROM Account WHERE Id = :String.valueOf(record.get('AccountId'))];
                                if(oppAccount.Region__c != null && oppAccount.Region__c != ''){
                                    params.currentRegion = oppAccount.Region__c;
                                } else {
                                    params.currentRegion = 'EMPTY';
                                }
                                if (CTIEnabled == true) callHistoryRows = createCallHistory_OppContactsList(record);
                            }
                            setUpPage(CTIEnabled);
                        } else {
                            params.recordStatus = 'IncorrectId';
                        }
                    } else {
                        params.recordStatus = 'IncorrectId';
                    }
                } else {
                    params.recordStatus = 'IncorrectId';
                }
            } else {
                params.recordStatus = 'IncorrectId';
            }
        } catch(Exception e){
            system.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ExceptionLogger.sendException(
                    'RecordAssignCheckRuCtrl getRecordAccess (Current User = '+currentUser+')(Id = '+recordId+') ' + (String)e.getMessage(),
                    (String)e.getStackTraceString());
        }
    }

    private void setUpPage(Boolean CTIEnabled){
        resultTypes.clear();
        if(params.recordStatus != 'MovedToStart'){
            resultTypes.put('Online transfer call', new SelectOption('Online transfer call', getResultTypesTranslations().get('Online transfer call')));
        }
        resultTypes.put('Call', new SelectOption('Call',getResultTypesTranslations().get('Call')));
        resultTypes.put('Post', new SelectOption('Post',getResultTypesTranslations().get('Post')));
        resultTypes.put('Meeting', new SelectOption('Meeting',getResultTypesTranslations().get('Meeting')));
        resultTypes.put('Non-target client', new SelectOption('Non-target client',getResultTypesTranslations().get('Non-target client')));
        resultTypes.put('Disqualification', new SelectOption('Disqualification',getResultTypesTranslations().get('Disqualification')));
        if (CTIEnabled == true) {
            String projectUUID = record.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(record.get('Naumen_Autocall_Project_UUID__c'));
            String caseUUID = record.get('Naumen_Autocall_Case_UUID__c') == null ? '' : String.valueOf(record.get('Naumen_Autocall_Case_UUID__c'));
            if (projectUUID != null && caseUUID != null) {
                resultTypes.put('Callback', new SelectOption('Callback',getResultTypesTranslations().get('Callback')));
            } 
        }

        params.activity.type = resultTypes.values().get(0).getValue();
        refreshForm();
    }
    /*******************************************************************************
    *  Name            : getExcludeOppOwnersId()
    *  Summary         : get exclude opp owners from custom setting
    *  Parameters      : 
    *  Returns         : Set<Id> - Set of owner ids
    ******************************************************************************/
    public static Set<Id> getExcludeOppOwnersId(){
        Set<Id> excludeOppOwnersId = new Set<Id>();
        Map<String, FieldSalesTerritory_General_Settings__c> fieldSalesSettings = FieldSalesTerritory_General_Settings__c.getAll();
        if(fieldSalesSettings.get('RU').exludeOppOwnersId__c != null && fieldSalesSettings.get('RU').exludeOppOwnersId__c != ''){
            for(String ownerId : String.valueOf(fieldSalesSettings.get('RU').exludeOppOwnersId__c).split(';')){
                excludeOppOwnersId.add(ownerId);
            }
        }
        return excludeOppOwnersId;
    }
    /*******************************************************************************
    *  Name            : getSpecificOppOwners()
    *  Summary         : get specific opp owners from custom setting
    *  Parameters      : 
    *  Returns         : Set<Id> - Set of owner ids
    ******************************************************************************/
    public static Set<Id> getSpecificOppOwners () {
        // Specific Opp Owners
        Set<Id> specificOppOwners = new Set<Id>();
        Call_Center_Speed_Up__c callCenterSpeedUp = Call_Center_Speed_Up__c.getAll().get('RU');
        if(callCenterSpeedUp.specificOppOwners__c != null && callCenterSpeedUp.specificOppOwners__c != ''){
            for(String ownerId : String.valueOf(callCenterSpeedUp.specificOppOwners__c).split(';')){
                specificOppOwners.add(ownerId);
            }
        }
        return specificOppOwners;
    }
    public static Map<Integer, Integer> getCalendarDays () {
        BusinessHours businessHoursRu = [SELECT Id From BusinessHours where name ='RU_TerritoryManagement' LIMIT 1];
        Map<Integer, Integer> calendarDays = new Map<Integer, Integer>();
        calendarDays.put(1, convertPastBusinessDaysToCalendar(1, businessHoursRu));
        calendarDays.put(2, convertPastBusinessDaysToCalendar(2, businessHoursRu));
        calendarDays.put(3, convertPastBusinessDaysToCalendar(3, businessHoursRu));
        calendarDays.put(5, convertPastBusinessDaysToCalendar(5, businessHoursRu));
        calendarDays.put(10, convertPastBusinessDaysToCalendar(10, businessHoursRu));
        return calendarDays;
    }
    /*******************************************************************************
    *  Name            : getRecordStatus()
    *  Summary         : this method is used to understand if the record is free an the user can work with it
    *  Parameters      : SObject record - the record for which we check access for the user, RecordAssignCheckParams params - params of the record
    *  Returns         : String the record status which shows that the user has an access to the record
    ******************************************************************************/
    public static String getRecordStatus(SObject record, RecordAssignCheckParams params){
        Datetime lastOwnerChangeDate = Datetime.valueOf(record.get('Last_Owner_Change_Date_RUS__c'));
        Datetime dayX = Datetime.newInstanceGmt(2019,8,19); // I don't know why we are using this date.
        Map<Integer, Integer> calendarDays = getCalendarDays();
        String SObjectType = record.getSObjectType().getDescribe().name;
        if(SObjectType == 'Lead') {
            getLeadRecord(1, String.valueOf(record.get('Id')), calendarDays, params);
            if(params.availableLeads.size() == 1){
                return 'Free';
            } else {
                return 'InProgress';
            }
        }
        else if (SObjectType == 'Opportunity'){
            Set <Id> excludeOppOwnersId = getExcludeOppOwnersId();
            Set <Id> specificOppOwners = getSpecificOppOwners();
            getOpportunityRecords(1, String.valueOf(record.get('Id')), calendarDays, params, excludeOppOwnersId);
            Boolean sourceRecordLocked = isRecordLocked(record);
            if (Integer.valueOf(record.getSObject('Account').get('Moved_to_Start__c')) != 0 ||
                    excludeOppOwnersId.contains(String.valueOf(record.get('OwnerId'))) ||
                    excludeOppOwnersId.contains(String.valueOf(record.getSObject('Account').get('OwnerId'))) ||
                    record.getSObject('Account').get('Last_pump_date__c') != null ||
                    record.getSobject('Account').get('ParentId') != null) {
                return 'MovedToStart';
            } else if(params.availableOpportunitiesFromAccount.size() != 0 &&
                    params.availableOpportunitiesFromAccount.values().get(0).Account.Opportunity_Sum__c == params.availableOpportunitiesFromAccount.size() &&
                    sourceRecordLocked == false){
                return 'Free';
            } else {
                Integer countFreeOpp = 0;
                for(Opportunity opp : params.allOpportunitiesFromAccount.values()){
                    Boolean recordLocked = isRecordLocked(opp);
                    if(!excludeOppOwnersId.contains(opp.Account.OwnerId) &&
                            opp.Account.Moved_to_Start__c == 0 &&
                            opp.Account.ParentId == null &&
                            opp.Account.Last_pump_date__c == null &&
                            opp.PPR_Lost_Reasons__c != 'Switched to E2E' &&
                            opp.PPR_Lost_Reasons__c != 'Return to funnel' &&
                            opp.PPR_Lost_Reasons__c != 'Out of Business' &&
                            opp.PPR_Lost_Reasons__c != 'Existing Customer' &&
                            opp.PPR_Lost_Reasons__c != 'Refusal from PPR' &&
                            recordLocked == false &&
                            (specificOppOwners.contains(opp.OwnerId) ||
                             opp.Owner.IsActive == false)){
                        countFreeOpp ++;
                    }
                }
                if(countFreeOpp == params.allOpportunitiesFromAccount.size()){
                    return 'Free';
                } else {
                    return 'InProgress';
                }
            }
        }

        return 'error';
    }

     private static Boolean isRecordLocked(SObject record){
        Boolean result = false;
        String SObjectType = record.getSObjectType().getDescribe().name;
        if(SObjectType == 'Lead') {
            List<LeadHistory> leadHistory = [
                    SELECT Id, CreatedById, CreatedDate, Field, IsDeleted, LeadId, NewValue, OldValue
                    FROM LeadHistory
                    WHERE LeadId = :String.valueOf(record.get('Id'))
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if(leadHistory.size() != 0){
                if(leadHistory.get(0).Field == 'locked'){
                    result = true;
                }
            }
        }
        else if (SObjectType == 'Opportunity'){
            List<OpportunityFieldHistory> opportunityHistory = [
                    SELECT Id, CreatedById, CreatedDate, Field, IsDeleted, OpportunityId, NewValue, OldValue
                    FROM OpportunityFieldHistory
                    WHERE OpportunityId = :String.valueOf(record.get('Id'))
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if(opportunityHistory.size() != 0){
                if(opportunityHistory.get(0).Field == 'locked'){
                    result = true;
                }
            }
        }
        return result;
    }

    /*******************************************************************************
    *  Name            : getLeadRecords()
    *  Summary         : query to check record
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public static void getLeadRecord(Integer recordsLimit, String recordId, Map<Integer, Integer> calendarDays, RecordAssignCheckParams params){
        // russian lead record type
        String russianLeadRecordType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId(); 
        // key roles
        List<String> keyRoles = getKeyRoles();
        // Lead Status in 'PROCESS'
        Set<String> leadStatusInProcess = new Set<String>();// Список Lead.Status содержащих "In Process"
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> statusEntries = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : statusEntries){
            if(pickListVal.value.contains('IN PROCESS')){
                leadStatusInProcess.add(pickListVal.value);
            }
        }
        // Rep users
        Call_Center_Speed_Up__c callCenterSpeedUp = Call_Center_Speed_Up__c.getAll().get('RU');
        Set<Id> repUsersIds = new Set<Id>(); // Список юзеров "Rep"
        if(callCenterSpeedUp.repUsersIds__c != null && callCenterSpeedUp.repUsersIds__c != ''){
            for(String ownerId : String.valueOf(callCenterSpeedUp.repUsersIds__c).split(';')){
                repUsersIds.add(ownerId);
            }
        }
        // Include Lead Queues Id
        Set<Id> leadsQueuesId = new Set<Id>(); // Список очередей для Lead в которых искать Территориальные лиды
        for(Group gr : [
                SELECT id, name
                FROM Group
                WHERE Name LIKE '%PPR Queue Stock%'
                OR Name LIKE '%PPR Queue Call Center%'
                OR Name LIKE '%PPR Queue Email with KP%'
        ]){
            leadsQueuesId.add(gr.Id);
        }

        // query lead
        String filter = ' AND Id = \'' + recordId+'\'';
        List<SObject> leads = new List<SObject>();
        leads.addAll(Database.query(
                'SELECT id, Name, INN__c, Industry, NumberOfEmployees, Area__c, City, Street, Revenue_thousand_rub__c, ' +
                        'OwnerId, SummaryScoringRu__c, CreatedDate, Rating_FS_New__c' +
                        ' FROM Lead' +
                        ' WHERE RecordTypeId = :russianLeadRecordType' +
                        ' AND IsConverted = FALSE' +
                        ' AND Duplicate_Record_Mark__c  = false ' +
                        ' AND (' +
                        '        (' +
                        '            Lead_Owner_Role__c NOT IN :keyRoles' +
                        '            AND Owner.Type = \'User\' ' +
                        '            AND (Lead_Owner_Role__c != \'PPR FieldTerritory_Call Center\' OR (Lead_Owner_Role__c = \'PPR FieldTerritory_Call Center\' AND Status = \'Disqualified\'))' +
                        '            AND (' +
                        '                  (Status = \'NEW - Not Yet Contacted\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(2)+' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays.get(2)+' OR LastActivityDate = null) AND Open_Task__c = false) OR' +
                        '                  (Status = \'Disqualified\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(2)+' AND ' +
                        '                        Lead_Status_Specific__c != \'Switched to E2E\' AND Lead_Status_Specific__c != \'Return to funnel\') OR' +
                        '                  (Status = \'QUALIFIED - Convert to Opportunity\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(3)+' AND Open_Task__c = false) OR' +
                        '                  (Status = \'Waiting INN\' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays.get(3)+' OR LastActivityDate = null OR Date_of_Last_Status_Changing__c < LAST_N_DAYS:'+calendarDays.get(10)+' OR Date_of_Last_Status_Changing__c = null) AND Open_Task__c = false) OR' +
                        '                  (Status in :leadStatusInProcess AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(2)+' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays.get(1)+'  OR LastActivityDate = null) AND Open_Task__c = false)' +
                        '                 )' +
                        '        )' +
                        '     OR (' +
                        '            Lead_Owner_Role__c IN :keyRoles' +
                        '            AND Owner.Type = \'User\' ' +
                        '            AND (' +
                        '                  (Status = \'NEW - Not Yet Contacted\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(5)+' AND Open_Task__c = false) OR' +
                        '                  (Status = \'Disqualified\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(2)+' AND ' +
                        '                        Lead_Status_Specific__c != \'Switched to E2E\' AND Lead_Status_Specific__c != \'Return to funnel\') OR' +
                        '                  (Status in :leadStatusInProcess AND LastTransferDate < LAST_N_DAYS:'+calendarDays.get(2)+' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays.get(1)+'  OR LastActivityDate = null) AND Open_Task__c = false)' +
                        '                )' +
                        '        )' +
                        '     OR (  OwnerId in :leadsQueuesId AND ' +
                        '               (' +
                        '                   Status != \'Disqualified\' OR ' +
                        '                   (Status = \'Disqualified\' AND ' +
                        '                       Lead_Status_Specific__c != \'Switched to E2E\' AND Lead_Status_Specific__c != \'Return to funnel\')' +
                        '               )' +
                        '        )' +
                        '     OR (  (OwnerId in :repUsersIds OR Owner.IsActive = false) AND ' +
                        '               (' +
                        '                   Status != \'Disqualified\' OR ' +
                        '                   (Status = \'Disqualified\' AND ' +
                        '                       Lead_Status_Specific__c != \'Switched to E2E\' AND ' +
                        '                       Lead_Status_Specific__c != \'Return to funnel\' AND' +
                        '                       Lead_Status_Specific__c != \'Out of Business\')' +
                        '               )' +
                        '        )' +
                        ')' +
                        filter)
        );
        for(SObject lead : leads){
            params.availableLeads.put(String.valueOf(lead.get('Id')), (Lead)lead);
        }
    }

    /*******************************************************************************
    *  Name            : getOpportunityRecords()
    *  Summary         : query to check record
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public static void getOpportunityRecords(Integer recordsLimit, String recordId, Map<Integer, Integer> calendarDays, RecordAssignCheckParams params, Set <Id> excludeOppOwnersId){
        // key roles
        List<String> keyRoles = getKeyRoles();

        // query opportunity 
        List<Task> listOfOpenedTasks = [
                SELECT id, whatId, Status, IsClosed, CreatedDate
                FROM Task
                WHERE CreatedDate = LAST_90_DAYS
                AND WhatId = :recordId
                AND IsClosed = false
        ];
        Boolean recentOpenedTasks = false;
        if(listOfOpenedTasks.size() != 0){
            recentOpenedTasks = true;
        }

        Opportunity requestedOpportunity = [
                SELECT Id, AccountId
                FROM Opportunity
                WHERE Id = :recordId
        ];

        params.allOpportunitiesFromAccount = new Map<Id, Opportunity>([
                SELECT Id, OwnerId, Owner.IsActive, Last_Owner_Change_Date_RUS__c, PPR_Lost_Reasons__c,
                        ContactId, AccountId, Account.OwnerId, Account.Opportunity_Sum__c, Account.Moved_to_Start__c,
                        Account.ParentId, Account.Last_pump_date__c, HasVehicleFleet__c, Description,
                        Naumen_Case_Status__c, Naumen_Case_Status_ModifiedTime__c
                FROM Opportunity
                WHERE AccountId = :requestedOpportunity.AccountId
        ]);

        List<SObject> result = new List<SObject>();
        if(params.allOpportunitiesFromAccount.values().get(0).Account.Opportunity_Sum__c == 1){
            result.addAll(Database.query(
                    ' SELECT id, OwnerId, StageName, Probability, Name, Last_Owner_Change_Date_RUS__c,' +
                            ' Projected_Liters_weekly__c, Projected_amount_in_rub_month__c, Number_of_cars__c, Number_of_trucks__c, Custom_Distribution_Team__c,' +
                            ' AccountId, Account.INN__c, Account.Industry, Account.NumberOfEmployees, Account.Opportunity_Sum__c, ' +
                            ' Account.SummaryScoringRu__c, Account.BillingArea__c, Account.BillingCity, Account.BillingStreet, Account.Rating_FS_New__c' +
                            ' FROM Opportunity' +
                            ' WHERE  Account.Moved_to_Start__c = 0' +
                            ' AND Account.ParentId = null'+
                            ' AND Account.Last_pump_date__c = null' +
                            ' AND OwnerId NOT IN :excludeOppOwnersId' +
                            ' AND (' +
                            '        ('+
                            '           Owner_User_UserRole_Name__c NOT IN :keyRoles ' +
                            '           AND (Owner_User_UserRole_Name__c != \'PPR FieldTerritory_Call Center\' OR ' +
                            '                   (Owner_User_UserRole_Name__c = \'PPR FieldTerritory_Call Center\' AND Probability = 0 AND ' +
                            '                    PPR_Lost_Reasons__c != \'Switched to E2E\' AND PPR_Lost_Reasons__c != \'Return to funnel\'))' +
                            '           AND (' +
                            '                  (Probability = 0 AND PPR_Lost_Reasons__c != \'Switched to E2E\' AND PPR_Lost_Reasons__c != \'Return to funnel\' AND ' +
                            '                      PPR_Lost_Reasons__c != \'Existing Customer\' AND PPR_Lost_Reasons__c != \'Refusal from PPR\' AND ' +
                            '                      PPR_Lost_Reasons__c != \'Out of Business\' AND' +
                            '                      (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(2)+' OR Last_Owner_Change_Date_RUS__c = null )) OR' +
                            '                  (Probability = 10 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(3)+'  OR Last_Owner_Change_Date_RUS__c = null ) AND Open_Task__c = false ) OR' +
                            '                  (Probability = 5 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(2)+' OR Last_Owner_Change_Date_RUS__c = null ) AND Open_Task__c = false) OR' +
                            '                  (Probability  >= 30 AND Probability < 90 AND (LastActivityDate < LAST_N_DAYS:30 OR LastActivityDate = null) ' +
                            '                      AND Open_Task__c = false AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(2)+'  OR Last_Owner_Change_Date_RUS__c = null )) OR ' +
                            '                  (Probability >= 5 AND Probability <= 60 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:180 OR Last_Owner_Change_Date_RUS__c = null) AND ' +
                            '                      (Projected_Liters_weekly__c < 10000 OR Projected_amount_in_rub_month__c < 464000))' +
                            '               )' +
                            '        )' +
                            '     OR (' +
                            '           Owner_User_UserRole_Name__c IN :keyRoles ' +
                            '           AND (' +
                            '                  (Probability = 0 AND PPR_Lost_Reasons__c != \'Switched to E2E\' AND PPR_Lost_Reasons__c != \'Return to funnel\' AND ' +
                            '                       PPR_Lost_Reasons__c != \'Existing Customer\' AND PPR_Lost_Reasons__c != \'Refusal from PPR\' AND ' +
                            '                       PPR_Lost_Reasons__c != \'Out of Business\' AND' +
                            '                      (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(3)+' OR Last_Owner_Change_Date_RUS__c = null )) OR' +
                            '                  (Probability  >= 10 AND Probability <= 90 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(3)+'  OR Last_Owner_Change_Date_RUS__c = null ) ' +
                            (recentOpenedTasks ? ' AND Open_Task__c = false ' : '') + ') OR ' +
                            '                  (Probability >= 5 AND Probability <= 60 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:180 OR Last_Owner_Change_Date_RUS__c = null) AND ' +
                            '                      (Projected_Liters_weekly__c < 10000 OR Projected_amount_in_rub_month__c < 464000))' +
                            '               )' +
                            '        )' +
                            ' )' +
                            ' AND Id = \'' + recordId+'\''
            ));
        } else {
            result.addAll(Database.query(
                    ' SELECT id, OwnerId, StageName, Probability, Name, Last_Owner_Change_Date_RUS__c,' +
                            ' Projected_Liters_weekly__c, Projected_amount_in_rub_month__c, Number_of_cars__c, Number_of_trucks__c, Custom_Distribution_Team__c,' +
                            ' AccountId, Account.INN__c, Account.Industry, Account.NumberOfEmployees, Account.Opportunity_Sum__c,' +
                            ' Account.SummaryScoringRu__c, Account.BillingArea__c, Account.BillingCity, Account.BillingStreet, Account.Rating_FS_New__c' +
                            ' FROM Opportunity' +
                            ' WHERE  Account.Moved_to_Start__c = 0' +
                            ' AND Account.ParentId = null'+
                            ' AND Account.Last_pump_date__c = null' +
                            ' AND OwnerId NOT IN :excludeOppOwnersId' +
                            ' AND Account.OwnerId NOT IN :excludeOppOwnersId' +
                            ' AND (' +
                            '        ('+
                            '           Owner_User_UserRole_Name__c NOT IN :keyRoles ' +
                            '           AND (Owner_User_UserRole_Name__c != \'PPR FieldTerritory_Call Center\' OR ' +
                            '                   (Owner_User_UserRole_Name__c = \'PPR FieldTerritory_Call Center\' AND Probability = 0 AND ' +
                            '                    PPR_Lost_Reasons__c != \'Switched to E2E\' AND PPR_Lost_Reasons__c != \'Return to funnel\' ))' +
                            '           AND (' +
                            '                  (Probability = 0 AND PPR_Lost_Reasons__c != \'Switched to E2E\' AND PPR_Lost_Reasons__c != \'Return to funnel\'  AND ' +
                            '                      PPR_Lost_Reasons__c != \'Existing Customer\' AND PPR_Lost_Reasons__c != \'Refusal from PPR\' AND' +
                            '                      PPR_Lost_Reasons__c != \'Out of Business\' AND ' +
                            '                      (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(2)+' OR Last_Owner_Change_Date_RUS__c = null )) OR' +
                            '                  (Probability = 10 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(3)+'  OR Last_Owner_Change_Date_RUS__c = null ) AND Open_Task__c = false ) OR' +
                            '                  (Probability = 5 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(2)+' OR Last_Owner_Change_Date_RUS__c = null ) AND Open_Task__c = false) OR' +
                            '                  (Probability  >= 30 AND Probability < 90 AND (LastActivityDate < LAST_N_DAYS:30 OR LastActivityDate = null) AND ' +
                            '                      Open_Task__c = false AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(2)+'  OR Last_Owner_Change_Date_RUS__c = null )) OR ' +
                            '                  (Probability >= 5 AND Probability <= 60 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:180 OR Last_Owner_Change_Date_RUS__c = null) AND ' +
                            '                      (Projected_Liters_weekly__c < 10000 OR Projected_amount_in_rub_month__c < 464000))' +
                            '               )' +
                            '        )' +
                            '     OR (' +
                            '           Owner_User_UserRole_Name__c IN :keyRoles ' +
                            '           AND (' +
                            '                  (Probability = 0 AND PPR_Lost_Reasons__c != \'Switched to E2E\' AND PPR_Lost_Reasons__c != \'Return to funnel\'  AND ' +
                            '                      PPR_Lost_Reasons__c != \'Existing Customer\' AND PPR_Lost_Reasons__c != \'Refusal from PPR\' AND ' +
                            '                      PPR_Lost_Reasons__c != \'Out of Business\' AND ' +
                            '                      (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(3)+' OR Last_Owner_Change_Date_RUS__c = null )) OR' +
                            '                  (Probability  >= 10 AND Probability <= 90 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays.get(3)+'  OR Last_Owner_Change_Date_RUS__c = null ) ' +
                            (recentOpenedTasks ? ' AND Open_Task__c = false ' : '') + ') OR ' +
                            '                  (Probability >= 5 AND Probability <= 60 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:180 OR Last_Owner_Change_Date_RUS__c = null) AND ' +
                            '                      (Projected_Liters_weekly__c < 10000 OR Projected_amount_in_rub_month__c < 464000))' +
                            '               )' +
                            '        )' +
                            ' )' +
                            ' AND AccountId = \'' + requestedOpportunity.AccountId +'\''
            ));
        }
        for(SObject opp : result){
            params.availableOpportunitiesFromAccount.put(String.valueOf(opp.get('Id')), (Opportunity)opp);
        }
    }

    /*******************************************************************************
    *  Name            : createTask()
    *  Summary         : create new task for record owner or admin
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void refreshForm(){
        //verify region ss Field Sales
        if(allRegions.containsKey(params.currentRegion)){
            if(allRegions.get(params.currentRegion).Assigned_Team_Lead__c != null &&
                    allRegions.get(params.currentRegion).Assigned_Team_Lead__c != ''){
                params.currentRegionIsFS = true;
            } else {
                params.currentRegionIsFS = false;
            }
        } else {
            params.currentRegionIsFS = false;
        }

        params.activity.activityHour = Datetime.now().addMinutes(2).format('H');
        params.activity.activityMinute = Datetime.now().addMinutes(2).format('mm');
    }

    /*******************************************************************************
    *  Name            : calculateparams.decision()
    *  Summary         : create new task for record owner or admin
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private String calculateDecision(){
        String result = '';
        if(params.activity.type == 'Online transfer call'){
            result = 'OUTBOUND';
            distributionTeams = assignedGroup;
        } else {
            if(params.expectedVolume.bigClient){
                if(allRegions.containsKey(params.currentRegion)){
                    if( allRegions.get(params.currentRegion).Assigned_Team_Lead__c == null ||
                            allRegions.get(params.currentRegion).Assigned_Team_Lead__c == ''){
                        result = 'OUTBOUND';
                        distributionTeams = assignedGroup;
                    } else {
                        result = 'FS&OUTBOUND';
                        List<User> userName = [Select Id, Name FROM User where id = :allRegions.get(params.currentRegion).Assigned_Team_Lead__c];
                        distributionTeams = assignedGroup + '_OR_' + userName.get(0).Name.replace(' ','_');
                    }
                } else {
                    result = 'OUTBOUND';
                    distributionTeams = assignedGroup;
                }
            } else {
                result = 'OUTBOUND';
                distributionTeams = assignedGroup;
            }
        }
        return result;
    }

    public void changeCurrentGroup(){
        currentListOfMembers = totalMapOfMembers.get(params.currentGroup);
        params.currentMember = currentListOfMembers.get(0).getValue();
    }
    public void clearPageParams(){
        recordId = '';
        inputRecordId = '';
        callCustomerId = null;
        params = null;
        record = null;
        callHistoryRows = new List <CallHistoryRow> ();
    }
    public void closeRecord_ProcessingTimeIsFinished(){
        try{
            system.debug('closeRecord_ProcessingTimeIsFinished ');
            String caseUUID = Test.isRunningTest() ? null : String.valueOf(Apexpages.currentPage().getParameters().get('caseUUID'));
            String operatorName = Test.isRunningTest() ? null : String.valueOf(Apexpages.currentPage().getParameters().get('operatorName'));
            String errTemplate = Label.naumen_processingTimeExceeded;
            String errMsg = errTemplate.replace('{naumenCaseURL}', 'http://172.20.136.82/published?uuid='+caseUUID +'<br/>');
            errMsg = errMsg.replace('{naumenOperatorName}', operatorName +'<br/>');
            errMsg = errMsg.replace('{timeNow}', system.now().format('dd.MM.yyyy HH:mm') +'<br/>');
            errMsg = errMsg.replace('{recordId}', '"'+recordId+'"<br/>');
            errMsg = errMsg.replace('{params}', '"'+String.valueOf(params)+'"');
            Naumen_RecordsHelper.sendInfoEmail(errMsg, Label.Naumen_ProcessingTimeExceededTitle);
            clearPageParams();
        } catch(Exception e){
            ExceptionLogger.sendException(
                    'RecordAssignCheckRuCtrl closeRecord_ProcessingTimeIsFinished (Current User = '+currentUser+')(recordId = '+recordId+')(params = '+params+') ' + (String)e.getMessage(),
                    (String)e.getStackTraceString());
        }
    }

    /*******************************************************************************
    *  Name            : submitForm()
    *  Summary         : submit user form
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void submitForm(){
        try{
            Boolean CTIEnabled = Test.isRunningTest() ? true : Boolean.valueOf(Apexpages.currentPage().getParameters().get('CTIEnabled'));
            //String projectUUID = Test.isRunningTest() ? null : String.valueOf(Apexpages.currentPage().getParameters().get('projectUUID'));
            //String caseUUID = Test.isRunningTest() ? null : String.valueOf(Apexpages.currentPage().getParameters().get('caseUUID'));
            String operatorName = Test.isRunningTest() ? null : String.valueOf(Apexpages.currentPage().getParameters().get('operatorName'));
            params.decision = calculateDecision();
            system.enqueueJob(new RecordAssignCheckRuQueueable(recordId, callCustomerId, params, distributionTeams, CTIEnabled, /*projectUUID, caseUUID, */operatorName));
            clearPageParams();
        } catch(Exception e){
            ExceptionLogger.sendException(
                    'RecordAssignCheckRuCtrl updateData (Current User = '+currentUser+')(recordId = '+recordId+')(params = '+params+') ' + (String)e.getMessage(),
                    (String)e.getStackTraceString());
        }
    }
    /*******************************************************************************
    *  Name            : savePhoneData()
    *  Summary         : saves data about phones only which we got during the current call
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void savePhonesData() {
        if (recordId == null) return;
        params.firstCallNumber = params.contact.phone;
        system.debug('here !!! : firstCallNumber : ' + params.firstCallNumber);
        Schema.sObjectType sObjType = Id.valueOf(recordId).getsObjectType();
        if (sObjType == Lead.sObjectType) {
            Lead lead = queryLeadToSave(recordId);
            savePhoneFields_Lead(lead, params);
            Naumen_RecordsHelper.setCallResultsFields (lead, 'Phone', null);
            update lead;
        } else {
            Opportunity opp = params.allOpportunitiesFromAccount.get(recordId);
            Contact contact;
            if (callCustomerId != null && callCustomerId != 'undefined') {
                Map<Id, Contact> clientContactsMap = queryContactsToSave(callCustomerId, opp.Id, opp.AccountId);
                contact = getCallContact (callCustomerId, clientContactsMap, params); // look for the contact on the opportunity and parent acc records
            }
            
            system.debug('phone for the contact : ' + params.contact.getPhoneWithExtensionNumber());
            if (contact == null) { // create new contact if existing wasn't found
                contact = createNewContactAndSave (opp, params, true);  // send pd fields to the server here 
            }
            savePhoneFields_Contact(contact, params);
            Naumen_RecordsHelper.setCallResultsFields (contact, 'Phone', null);
            update contact;
        }
    }

    public class RecordAssignCheckRuQueueable implements Queueable{

        private String recordId;
        private String callCustomerId;
        private RecordAssignCheckParams params;
        private String distributionTeams;
        private Boolean CTIEnabled;
        //private String projectUUID;
        //private String caseUUID;
        private String operatorName;

        public RecordAssignCheckRuQueueable(String recordId, String callCustomerId, RecordAssignCheckParams params, String distributionTeams, Boolean CTIEnabled, /*String projectUUID, String caseUUID, */ String operatorName){
            this.recordId = recordId;
            this.callCustomerId = callCustomerId == '' || callCustomerId == 'undefined' ? null : callCustomerId;
            this.params = params;
            this.distributionTeams = distributionTeams;
            this.CTIEnabled = CTIEnabled;
            //this.projectUUID = projectUUID;
            //this.caseUUID = caseUUID;
            this.operatorName = operatorName;
        }

        public void execute(QueueableContext context){
            String sObjectType = Id.valueOf(recordId).getSobjectType().getDescribe().name;
            if(sObjectType == 'Lead'){
                saveDataForLead(recordId, params, distributionTeams);
                createLeadActivity(recordId, params);
            } else if (sObjectType == 'Opportunity'){
                if(params.allOpportunitiesFromAccount.size() == 1){
                    saveDataForSingleOpportunity(recordId, params, distributionTeams);
                } else {
                    saveDataForMultiOpportunity(recordId, params, distributionTeams);
                }
                createOpportunityActivity(recordId, params);
            }
        }
        private void saveDataForLead(String recordId, RecordAssignCheckParams params, String distributionTeams){
            //system.debug('>> in >> saveDataForLead : ' + params);
            try{
                List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
                Map<String, Call_Center_Speed_Up__c> settings = Call_Center_Speed_Up__c.getAll();
                Lead record = queryLeadToSave(recordId);

                savePhoneFields_Lead (record, params);

                if(params.contact.email != '' && params.contact.email != null){
                    if( ! isEmailDuplicate(params.contact.email, record)){
                        if((record.Email != '' && record.Email != null) || isEmailWithRussianAlphabet(params.contact.email)){
                            if(record.Additional_Emails__c == '' || record.Additional_Emails__c == null){
                                record.Additional_Emails__c = params.contact.email;
                            } else {
                                record.Additional_Emails__c += ':'+params.contact.email;
                            }
                        } else {
                            record.Email = params.contact.email;
                        }
                    }
                }
                if(params.contact.emailSecond != '' && params.contact.emailSecond != null){
                    if( ! isEmailDuplicate(params.contact.emailSecond, record)){
                        if((record.Email != '' && record.Email != null) || isEmailWithRussianAlphabet(params.contact.emailSecond)){
                            if(record.Additional_Emails__c == '' || record.Additional_Emails__c == null){
                                record.Additional_Emails__c = params.contact.emailSecond;
                            } else {
                                record.Additional_Emails__c += ':'+params.contact.emailSecond;
                            }
                        } else {
                            record.Email = params.contact.emailSecond;
                        }
                    }
                }

                if(params.recordStatus == 'Free'){
                    if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                            params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                        record.Source_of_Lead__c = 'Актуализированная БД';
                        prepareNotification(listToSend, 'KeyClients', null, JSON.serialize(record));
                    }

                    if(params.decision == 'FS&OUTBOUND'){
                        if(params.activity.type == 'Meeting') {
                            List<FS_Tree_Province__mdt> province = [
                                    SELECT Id, Assigned_Team_Lead__c
                                    FROM FS_Tree_Province__mdt
                                    WHERE Label = :params.currentRegion
                            ];
                            if(province.size() == 1){
                                record.OwnerId = province.get(0).Assigned_Team_Lead__c;
                            }
                            prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                        } else  if(params.activity.type == 'Call' || params.activity.type == 'Post') {
                            Call_Center_Speed_Up__c callCenterSpeedUp = Call_Center_Speed_Up__c.getAll().get('RU');
                            record.OwnerId = callcenterSpeedUp.User_for_Reassignment__c;
                            record.Custom_Distribution_Team__c = distributionTeams;
                            //prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                        }
                    } else if(params.decision == 'OUTBOUND'){
                        if(params.activity.type == 'Online transfer call'){
                            record.OwnerId = params.currentMember;
                            prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                        } else  if(params.activity.type == 'Call' || params.activity.type == 'Post' || params.activity.type == 'Meeting') {
                            record.OwnerId = settings.get('RU').CC_Team_Leader__c;
                            record.Custom_Distribution_Team__c = distributionTeams;
                        }
                    }
                    if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                            params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call'){
                        record.Status = 'Unprocessed';
                        record.Lead_Status_Specific__c = null;
                        record.Other_Reason_Disqualified__c = null;
                    }
                }
                if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                        params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                    params.activity.ownerId = record.OwnerId;
                } else if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                    params.activity.ownerId = UserInfo.getUserId();
                }

                if(params.expectedVolume.potential_Liters != '' && params.expectedVolume.potential_Liters != null){
                    record.Projected_Liters_month__c = Decimal.valueOf(params.expectedVolume.potential_Liters);
                }
                if(params.expectedVolume.potential_Rub != '' && params.expectedVolume.potential_Rub != null){
                    record.Projected_amount_in_rub_month__c = Decimal.valueOf(params.expectedVolume.potential_Rub);
                }
                Boolean thereAreCars = false;
                if(params.expectedVolume.potential_Cars != '' && params.expectedVolume.potential_Cars != null){
                    record.Anzahl_PKW__c = Decimal.valueOf(params.expectedVolume.potential_Cars);
                    if (!thereAreCars) thereAreCars = record.Anzahl_PKW__c > 0 ? true : false;
                }
                if(params.expectedVolume.potential_Trucks != '' && params.expectedVolume.potential_Trucks != null){
                    record.Anzahl_LKW__c = Decimal.valueOf(params.expectedVolume.potential_Trucks);
                    if (!thereAreCars) thereAreCars = record.Anzahl_LKW__c > 0 ? true : false;
                }
                record.HasVehicleFleet__c = thereAreCars ? 'Yes' // if number of cars or truck is set on the form-then set hasvehicle='Yes'
                                          : params.activity.disqualReason == 'Successful dialing:5d' ? 'No' // if disqual reson is "No car"-then set hasvehicle='No'
                                          : params.hasVehicleFleet;
                if(params.currentRegion != '' && params.currentRegion != null && params.currentRegion != 'EMPTY'){
                    record.Region__c = params.currentRegion;
                }
                if (this.CTIEnabled == true) {
                    Naumen_RecordsHelper.setCallResultsFields (record, 'Phone', params.activity.disqualReason);

                    if (params.activity.type == 'Callback' || params.activity.type == 'Disqualification') {
                        Naumen_RecordsHelper.addOperatorComment (record, params.activity.activityDateTime, params.activity.description); // save operator comment
                        if (record.Naumen_Case_Status__c == 'Finished') {
                            record.Naumen_Case_Status__c = 'Created';
                            record.Naumen_Case_Status_ModifiedTime__c = system.now();
                        }
                    } else {
                        Naumen_RecordsHelper.addOperatorComment (record, null, ''); // clear operator comment from the lead object if call result is not 'Callback'
                        record.Naumen_Case_Status__c = 'Finished';
                        record.Naumen_Case_Status_ModifiedTime__c = system.now();
                    }
                }

                update record;
                //system.debug('lead to save : ' + record);

                // send data to PD
                PD_Callouts.sendReq_saveData(record);

                if(!Test.isRunningTest()){
                    Messaging.sendEmail(listToSend);
                }
            } catch(Exception e){
                ExceptionLogger.sendException('RecordAssignCheckRuCtrl saveDataForLead (params = '+params+') ' + (String)e.getMessage(), (String)e.getStackTraceString());
            }
        }

        private void createLeadActivity(String recordId, RecordAssignCheckParams params){
            try{
                List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
                Lead record = [SELECT Id, Name, Lead_Owner_Role__c, HasVehicleFleet__c, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c FROM Lead WHERE Id = :recordId];
                if (this.CTIEnabled == true) {
                    if (params.activity.type == 'Callback') {
                        // set callback for the current operator and set call form fields on Naumen Case
                        String phoneToCall = params.activity.setCallBackForSecondPhone && 
                                            params.contact.phoneSecond != null && params.contact.phoneSecond != '' ? params.contact.phoneSecond
                                                                                                                    : params.contact.phone;
                        createCallBackInNaumen (record, params, params.activity.callBackScheduledTime, params.callInitiatedPhoneNumber, params.contact.phone, phoneToCall);
                        return; // we don't create an activity when operator chooses call result 'Callback'
                    } else if (params.activity.type == 'Disqualification') {
                        // set callback for the current operator and set call form fields on Naumen Case
                        createCallBackInNaumen (record, params, params.activity.callBackScheduledTime, params.callInitiatedPhoneNumber, params.contact.phone, null);
                    } else {
                        // set call form fields on Naumen Case
                        setCallFormFieldsInNaumen (record, params);
                    }
                }

                SObject newActivity;
                if( (params.recordStatus == 'Free' && params.decision == 'FS&OUTBOUND' && params.activity.type == 'Meeting') ||
                        (params.recordStatus == 'InProgress' && record.Lead_Owner_Role__c != null &&
                                (record.Lead_Owner_Role__c.startsWith('GPC') || record.Lead_Owner_Role__c.startsWith('PPR Teamleader Fieldsales') ||
                                        record.Lead_Owner_Role__c.startsWith('PPR Fieldsales') || record.Lead_Owner_Role__c.startsWith('PPR Field Sales')))){
                    newActivity = new Event();
                    newActivity.put('DurationInMinutes', 30);
                    newActivity.put('ActivityDateTime', params.activity.activityDateTime);
                    if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                        newActivity.put('Event_Status__c', 'Completed');
                    } else {
                        newActivity.put('Event_Status__c', 'In Progress');
                    }
                    newActivity.put('RecordTypeId', Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales_Event').getRecordTypeId());
                } else {
                    newActivity = new Task();
                    if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                        newActivity.put('Status', 'Completed');
                    } else {
                        newActivity.put('Status', 'In Progress');
                    }
                    newActivity.put('RecordTypeId', Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId());
                }

                newActivity.put('Description', params.activity.description); // Save first: main information in activity

                if(Decimal.valueOf((record.Name.toUpperCase().contains(params.contact.firstName.toUpperCase()) && params.contact.firstName != '' && params.contact.firstName != null) ? 1 : 0) +
                        Decimal.valueOf((record.Name.toUpperCase().contains(params.contact.middleName.toUpperCase()) && params.contact.middleName != '' && params.contact.middleName != null) ? 1 : 0) +
                        Decimal.valueOf((record.Name.toUpperCase().contains(params.contact.lastName.toUpperCase()) && params.contact.lastName != '' && params.contact.lastName != null) ? 1 : 0) < 2 ){
                    String position = (params.contact.position == '') ? '' : ', должность=' + params.contact.position;
                    String fio = ((params.contact.lastName == '') ? '' : params.contact.lastName + ' ') +
                            ((params.contact.firstName == '') ? '' : params.contact.firstName + ' ') +
                            ((params.contact.middleName == '') ? '' : params.contact.middleName);
                    if(fio != '' || position != ''){
                        String additionalDescription = '«Актуализировать:';
                        if(fio != ''){
                            additionalDescription += ' ФИО=' + fio;
                        }
                        if(position != ''){
                            additionalDescription += position;
                        }
                        additionalDescription += '»';
                        newActivity.put('Description', newActivity.get('Description') + '\n' + additionalDescription);
                    }
                }

                newActivity.put('Subject', 'Встреча КЦ');
                newActivity.put('Type', params.activity.type);
                newActivity.put('ActivityDate', params.activity.activityDate);
                newActivity.put('IsReminderSet', true);
                newActivity.put('ReminderDateTime', params.activity.activityDateTime);
                newActivity.put('OwnerId', params.activity.ownerId);
                newActivity.put('Whoid', recordId);
                insert newActivity;

                if(listToSend.size() != 0){
                    if(!Test.isRunningTest()){
                        Messaging.sendEmail(listToSend);
                    }
                }
            } catch(Exception e){
                ExceptionLogger.sendException('RecordAssignCheckRuCtrl createLeadActivity (params = '+params+') ' + (String)e.getMessage(), (String)e.getStackTraceString());
            }
        }

        private void saveDataForSingleOpportunity(String recordId, RecordAssignCheckParams params, String distributionTeams){
            //system.debug('>> in >> saveDataForSingleOpportunity : ' + params);
            try{
                List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
                Map<String, Call_Center_Speed_Up__c> settings = Call_Center_Speed_Up__c.getAll();

                Opportunity record = params.allOpportunitiesFromAccount.get(recordId);

                if(params.recordStatus == 'Free' || params.recordStatus == 'InProgress'){
                    if (params.recordStatus == 'Free') {
                        if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                                params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                            prepareNotification(listToSend, 'KeyClients', null, JSON.serialize(record));
                            record.StageName = 'Unprocessed';
                            record.PPR_Lost_Reasons__c = null;
                            record.decision_Reason_Other__c = null;
                            record.CloseDate = System.today().addMonths(1);
                            record.Source_of_Lead_o__c = 'Актуализированная БД';
                        }

                        if(params.decision == 'FS&OUTBOUND'){
                            if(params.activity.type == 'Meeting'){
                                List<FS_Tree_Province__mdt> province = [
                                        SELECT Id, Assigned_Team_Lead__c
                                        FROM FS_Tree_Province__mdt
                                        WHERE Label = :params.currentRegion
                                ];
                                if(province.size() == 1){
                                    record.OwnerId = province.get(0).Assigned_Team_Lead__c;
                                }
                                prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                            } else if(params.activity.type == 'Call' || params.activity.type == 'Post') {
                                Call_Center_Speed_Up__c callCenterSpeedUp = Call_Center_Speed_Up__c.getAll().get('RU');
                                record.OwnerId = callcenterSpeedUp.User_for_Reassignment__c;
                                record.Custom_Distribution_Team__c = distributionTeams;
                                //prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                            }
                        } else if(params.decision == 'OUTBOUND'){
                            if(params.activity.type == 'Online transfer call'){
                                record.OwnerId = params.currentMember;
                                prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                            } else if(params.activity.type == 'Call' || params.activity.type == 'Post' || params.activity.type == 'Meeting'){
                                record.OwnerId = settings.get('RU').CC_Team_Leader__c;
                                record.Custom_Distribution_Team__c = distributionTeams;
                            }
                        }

                        if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                                params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call'){
                            Account currentAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :record.AccountId];
                            if(params.currentRegion != '' && params.currentRegion != null && params.currentRegion != 'EMPTY'){
                                currentAccount.Region__c = params.currentRegion;
                            }

                            currentAccount.OwnerId = record.OwnerId;
                            update currentAccount;
                        }
                    }
                    if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                            params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                        params.activity.ownerId = record.OwnerId;
                    } else if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                        params.activity.ownerId = UserInfo.getUserId();
                    }

                    if (params.expectedVolume.potential_Liters != '' && params.expectedVolume.potential_Liters != null) {
                        record.Projected_Liters_weekly__c = Decimal.valueOf(params.expectedVolume.potential_Liters);
                    }
                    if (params.expectedVolume.potential_Rub != '' && params.expectedVolume.potential_Rub != null) {
                        record.Projected_amount_in_rub_month__c = Decimal.valueOf(params.expectedVolume.potential_Rub);
                    }
                    Boolean thereAreCars = false;
                    if (params.expectedVolume.potential_Cars != '' && params.expectedVolume.potential_Cars != null) {
                        record.Number_of_cars__c = Decimal.valueOf(params.expectedVolume.potential_Cars);
                        if (!thereAreCars) thereAreCars = record.Number_of_cars__c > 0 ? true : false;
                    }
                    if (params.expectedVolume.potential_Trucks != '' && params.expectedVolume.potential_Trucks != null) {
                        record.Number_of_trucks__c = Decimal.valueOf(params.expectedVolume.potential_Trucks);
                        if (!thereAreCars) thereAreCars = record.Number_of_trucks__c > 0 ? true : false;
                    }
                    record.HasVehicleFleet__c = thereAreCars ? 'Yes' // if number of cars or truck is set on the form-then set hasvehicle='Yes'
                                              : params.activity.disqualReason == 'Successful dialing:5d' ? 'No' // if disqual reson is "No car"-then set hasvehicle='No'
                                              : params.hasVehicleFleet;
                } else  if(params.recordStatus == 'MovedToStart'){
                    Email_Notifications__c emailSettings  = Email_Notifications__c.getAll().get('RU CC Speed Up - Admin');
                    if(emailSettings != null && emailSettings.ListIDs__c != null){
                        List<String> admins = emailSettings.ListIDs__c.split(';');
                        params.activity.ownerId = admins.get(0);
                        prepareNotification(listToSend, 'MovedToStart', new List<Id>{Id.valueOf(params.activity.ownerId)}, JSON.serialize(record));
                    }
                }
                if (this.CTIEnabled == true) {
                    if (params.activity.type == 'Callback' || params.activity.type == 'Disqualification') {
                        Naumen_RecordsHelper.addOperatorComment (record, params.activity.activityDateTime, params.activity.description); // save operator comment
                        if (record.Naumen_Case_Status__c == 'Finished') {
                            record.Naumen_Case_Status__c = 'Created';
                            record.Naumen_Case_Status_ModifiedTime__c = system.now();
                        }
                    } else {
                        Naumen_RecordsHelper.addOperatorComment (record, null, ''); // clear operator comment from the oppportunity object if call result is not 'Callback'
                        record.Naumen_Case_Status__c = 'Finished';
                        record.Naumen_Case_Status_ModifiedTime__c = system.now();
                    }
                }
                update record;

        // ----- set contact fields --------
                saveCallContact(record);

        // ----- send email --------
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(listToSend);
                }
            } catch(Exception e){
                ExceptionLogger.sendException('RecordAssignCheckRuCtrl saveOpportunityData (params = '+params+') ' + (String)e.getMessage(), (String)e.getStackTraceString());
            }
        }

        private void saveDataForMultiOpportunity(String recordId, RecordAssignCheckParams params, String assignedGroup){
            //system.debug('>> in >> saveDataForMultiOpportunity : ' + params);
            try{
                List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
                Map<String, Call_Center_Speed_Up__c> settings = Call_Center_Speed_Up__c.getAll();

                Opportunity record = params.allOpportunitiesFromAccount.get(recordId);

                if(params.recordStatus == 'Free') {  // All opportunities is available to reasssigne
                    if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                            params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                        prepareNotification(listToSend, 'KeyClients', null, JSON.serialize(record));
                        record.StageName = 'Unprocessed';
                        record.PPR_Lost_Reasons__c = null;
                        record.decision_Reason_Other__c = null;
                        record.CloseDate = System.today().addMonths(1);
                        record.Source_of_Lead_o__c = 'Актуализированная БД';
                    }

                    if(params.decision == 'FS&OUTBOUND'){
                        if(params.activity.type == 'Meeting') {
                            List<FS_Tree_Province__mdt> province = [
                                    SELECT Id, Assigned_Team_Lead__c
                                    FROM FS_Tree_Province__mdt
                                    WHERE Label = :params.currentRegion
                            ];
                            if(province.size() == 1){
                                record.OwnerId = province.get(0).Assigned_Team_Lead__c;
                            }
                            prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                        } else if(params.activity.type == 'Call' || params.activity.type == 'Post') {
                            Call_Center_Speed_Up__c callCenterSpeedUp = Call_Center_Speed_Up__c.getAll().get('RU');
                            record.OwnerId = callcenterSpeedUp.User_for_Reassignment__c;
                            record.Custom_Distribution_Team__c = distributionTeams;
                            //prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                        }
                    } else if(params.decision == 'OUTBOUND'){
                        if(params.activity.type == 'Online transfer call'){
                            record.OwnerId = params.currentMember;
                            prepareNotification(listToSend, 'RecordIsAssigned', null, JSON.serialize(record));
                        } else if(params.activity.type == 'Call' || params.activity.type == 'Post' || params.activity.type == 'Meeting') {
                            record.OwnerId = settings.get('RU').CC_Team_Leader__c;
                            record.Custom_Distribution_Team__c = distributionTeams;
                        }
                    }
                    if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                            params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                        params.activity.ownerId = record.OwnerId;
                    } else if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                        params.activity.ownerId = UserInfo.getUserId();
                    }

                    if (params.expectedVolume.potential_Liters != '' && params.expectedVolume.potential_Liters != null) {
                        record.Projected_Liters_weekly__c = Decimal.valueOf(params.expectedVolume.potential_Liters);
                    }
                    if (params.expectedVolume.potential_Rub != '' && params.expectedVolume.potential_Rub != null) {
                        record.Projected_amount_in_rub_month__c = Decimal.valueOf(params.expectedVolume.potential_Rub);
                    }
                    Boolean thereAreCars = false;
                    if (params.expectedVolume.potential_Cars != '' && params.expectedVolume.potential_Cars != null) {
                        record.Number_of_cars__c = Decimal.valueOf(params.expectedVolume.potential_Cars);
                        if (!thereAreCars) thereAreCars = record.Number_of_cars__c > 0 ? true : false;
                    }
                    if (params.expectedVolume.potential_Trucks != '' && params.expectedVolume.potential_Trucks != null) {
                        record.Number_of_trucks__c = Decimal.valueOf(params.expectedVolume.potential_Trucks);
                        if (!thereAreCars) thereAreCars = record.Number_of_trucks__c > 0 ? true : false;
                    }
                    record.HasVehicleFleet__c = thereAreCars ? 'Yes' // if number of cars or truck is set on the form-then set hasvehicle='Yes'
                                              : params.activity.disqualReason == 'Successful dialing:5d' ? 'No' // if disqual reson is "No car"-then set hasvehicle='No'
                                              : params.hasVehicleFleet;
                    
                    if(params.activity.type == 'Call' || params.activity.type == 'Post' ||
                            params.activity.type == 'Meeting' || params.activity.type == 'Online transfer call') {
                        Account currentAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :params.allOpportunitiesFromAccount.get(recordId).AccountId];
                        if(params.currentRegion != '' && params.currentRegion != null && params.currentRegion != 'EMPTY'){
                            currentAccount.Region__c = params.currentRegion;
                        }
                        currentAccount.OwnerId = record.OwnerId;
                        update currentAccount;
                    }
                }
                else if(params.recordStatus == 'InProgress'){ // At least one opportunity in progress
                    if(params.availableOpportunitiesFromAccount.get(recordId) == null ||
                            (params.availableOpportunitiesFromAccount.get(recordId) != null && params.availableOpportunitiesFromAccount.get(recordId).Probability != 0)){
                        // "Requested Record" in progress OR "Requested Record" is available AND Probability != 0
                        params.activity.ownerId = params.allOpportunitiesFromAccount.get(recordId).OwnerId;
                    } else { // Requested Record is available to reassign and Probability = 0
                        Opportunity firstOpportunity;
                        for(Opportunity opp : params.allOpportunitiesFromAccount.values()){
                            if(!params.availableOpportunitiesFromAccount.containsKey(opp.Id)){ // If Opportunity In progress
                                if(firstOpportunity == null){
                                    firstOpportunity = opp;
                                }else {
                                    if(opp.Last_Owner_Change_Date_RUS__c < firstOpportunity.Last_Owner_Change_Date_RUS__c){
                                        firstOpportunity = opp;
                                    }
                                }
                            }
                        }
                        Opportunity opportunityForUpdate = params.availableOpportunitiesFromAccount.get(recordId);
                        prepareNotification(listToSend, 'KeyClients', null, JSON.serialize(opportunityForUpdate));
                        opportunityForUpdate.OwnerId = firstOpportunity.OwnerId;
                        opportunityForUpdate.Source_of_Lead_o__c = 'Актуализированная БД';
                        update opportunityForUpdate;

                        recordId = firstOpportunity.Id;
                        params.activity.ownerId = firstOpportunity.OwnerId;
                    }
                } else  if(params.recordStatus == 'MovedToStart') {
                    Email_Notifications__c emailSettings = Email_Notifications__c.getAll().get('RU CC Speed Up - Admin');
                    if(emailSettings != null && emailSettings.ListIDs__c != null){
                        List<String> admins = emailSettings.ListIDs__c.split(';');
                        params.activity.ownerId = admins.get(0);
                        prepareNotification(listToSend, 'MovedToStart', new List<Id>{Id.valueOf(params.activity.ownerId)}, JSON.serialize(record));
                    }
                }
                if (this.CTIEnabled == true) {
                    if (params.activity.type == 'Callback' || params.activity.type == 'Disqualification') {
                        Naumen_RecordsHelper.addOperatorComment (record, params.activity.activityDateTime, params.activity.description); // save operator comment
                        if (record.Naumen_Case_Status__c == 'Finished') {
                            record.Naumen_Case_Status__c = 'Created';
                            record.Naumen_Case_Status_ModifiedTime__c = system.now();
                        }
                    } else {
                        Naumen_RecordsHelper.addOperatorComment (record, null, ''); // clear operator comment from the oppportunity object if call result is not 'Callback'
                        record.Naumen_Case_Status__c = 'Finished';
                        record.Naumen_Case_Status_ModifiedTime__c = system.now();
                    }
                }
                update record;

                // ----- set contact fields --------
                saveCallContact (params.allOpportunitiesFromAccount.get(recordId));

                // ----- send email --------
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(listToSend);
                }
            } catch(Exception e){
                ExceptionLogger.sendException('RecordAssignCheckRuCtrl saveOpportunityData (params = '+params+') ' + (String)e.getMessage(), (String)e.getStackTraceString());
            }
        }
        private void saveCallContact (Opportunity opp) {
            system.debug('>> in >> saveCallContact : callCustomerId :: ' + callCustomerId);
            // query contact records
            Map<Id, Contact> clientContactsMap = queryContactsToSave(callCustomerId, opp.Id, opp.AccountId);
            //system.debug('clientContactsMap :' + clientContactsMap);

            Contact callContact;
            if (!clientContactsMap.isEmpty()) {
                for(Contact contact : clientContactsMap.values()) {
                    if(params.recordStatus == 'Free'){
                        contact.OwnerId = opp.OwnerId;
                    }
                }
                callContact = getCallContact(callCustomerId, clientContactsMap, params);
                if (callContact != null) {
                    setContactFields(callContact, params); // send pd fields to the server here
                }
                update clientContactsMap.values();
            }

            if(callContact == null) {
                callContact = createNewContactAndSave (opp, params, this.CTIEnabled);  // send pd fields to the server here
            }
            system.debug('callContact : ' + callContact);
        }
        private void setContactFields (Contact contact, RecordAssignCheckParams params) {
            if(params.contact.position != '' && params.contact.position != null){
                contact.Title = params.contact.position;
            }

            savePhoneFields_Contact(contact, params);

            if(params.contact.email != '' && params.contact.email != null){
                if( ! isEmailDuplicate(params.contact.email, contact)){
                    if((contact.Email != '' && contact.Email != null) || isEmailWithRussianAlphabet(params.contact.email)){
                        if(contact.Additional_Emails__c == '' || contact.Additional_Emails__c == null){
                            contact.Additional_Emails__c = params.contact.email;
                        } else {
                            contact.Additional_Emails__c += ':'+params.contact.email;
                        }
                    } else {
                        contact.Email = params.contact.email;
                    }
                }
            }
            if(params.contact.emailSecond != '' && params.contact.emailSecond != null){
                if( ! isEmailDuplicate(params.contact.emailSecond, contact)){
                    if((contact.Email != '' && contact.Email != null) || isEmailWithRussianAlphabet(params.contact.emailSecond)){
                        if(contact.Additional_Emails__c == '' || contact.Additional_Emails__c == null){
                            contact.Additional_Emails__c = params.contact.emailSecond;
                        } else {
                            contact.Additional_Emails__c += ':'+params.contact.emailSecond;
                        }
                    } else {
                        contact.Email = params.contact.emailSecond;
                    }
                }
            }
            if (this.CTIEnabled == true) Naumen_RecordsHelper.setCallResultsFields (contact, 'Phone', params.activity.disqualReason);
            params.contact.Id = contact.Id;

            // send data to PD
            PD_Callouts.sendReq_saveData(contact);
        }
        private void createOpportunityActivity(String recordId, RecordAssignCheckParams params){
            try{
                List<Messaging.SingleEmailMessage> listToSend = new List<Messaging.SingleEmailMessage>();
                Opportunity record = [SELECT Id, ContactId, Owner.UserRole.Name, HasVehicleFleet__c, Naumen_Autocall_Project_UUID__c, Naumen_Autocall_Case_UUID__c FROM Opportunity WHERE Id = :recordId];
                
                if (this.CTIEnabled == true) {
                    if (params.activity.type == 'Callback') {
                        // set callback for the current operator and set call form fields on Naumen Case
                        String phoneToCall = params.activity.setCallBackForSecondPhone && 
                                            params.contact.phoneSecond != null && params.contact.phoneSecond != '' ? params.contact.phoneSecond
                                                                                                                    : params.contact.phone;
                        createCallBackInNaumen (record, params, params.activity.callBackScheduledTime, params.callInitiatedPhoneNumber, params.contact.phone, phoneToCall);
                        return; // we don't create an activity when operator chooses call result 'Callback'
                    } else if (params.activity.type == 'Disqualification') {
                        // set callback for the current operator and set call form fields on Naumen Case
                        createCallBackInNaumen (record, params, params.activity.callBackScheduledTime, params.callInitiatedPhoneNumber, params.contact.phone, null);
                    } else {
                        // set call form fields on Naumen Case
                        setCallFormFieldsInNaumen (record, params);
                    }
                }
                
                SObject newActivity;
                 if( (params.recordStatus != 'InProgress' && params.decision == 'FS&OUTBOUND' && params.activity.type == 'Meeting') ||
                        (params.recordStatus == 'InProgress' &&
                                (record.Owner.UserRole.Name.startsWith('GPC') || record.Owner.UserRole.Name.startsWith('PPR Teamleader Fieldsales') ||
                                 record.Owner.UserRole.Name.startsWith('PPR Fieldsales') || record.Owner.UserRole.Name.startsWith('PPR Field Sales')))){
                     newActivity = new Event();
                     newActivity.put('DurationInMinutes', 30);
                     newActivity.put('ActivityDateTime', params.activity.activityDateTime);
                     if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                         newActivity.put('Event_Status__c', 'Completed');
                     } else {
                         newActivity.put('Event_Status__c', 'In Progress');
                     }
                     newActivity.put('RecordTypeId', Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales_Event').getRecordTypeId());
                } else {
                    newActivity = new Task();
                     if(params.activity.type == 'Non-target client' || params.activity.type == 'Disqualification'){
                         newActivity.put('Status', 'Completed');
                     } else {
                         newActivity.put('Status', 'In Progress');
                     }
                    newActivity.put('RecordTypeId', Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId());
                }

                newActivity.put('Description', params.activity.description); // Save first: main information in activity
                newActivity.put('Subject', 'Встреча КЦ');
                newActivity.put('Type', params.activity.type);
                newActivity.put('ActivityDate', params.activity.activityDate);
                newActivity.put('IsReminderSet', true);
                newActivity.put('ReminderDateTime', params.activity.activityDateTime);

                newActivity.put('WhatId', recordId);
                if(params.contact.Id != null){
                    newActivity.put('WhoId', params.contact.Id);
                }
                newActivity.put('OwnerId', params.activity.ownerId);
                insert newActivity;

                if(listToSend.size() != 0){
                    if(!Test.isRunningTest()){
                        Messaging.sendEmail(listToSend);
                    }
                }
            } catch(Exception e){
                ExceptionLogger.sendException('RecordAssignCheckRuCtrl createOpportunityActivity (params = '+params+') ' + (String)e.getMessage(), (String)e.getStackTraceString());
            }
        }

        private void createCallBackInNaumen (sObject record, RecordAssignCheckParams params, Datetime callBackScheduledTime, String callInitiatedPhoneNumber, String currentPhoneNumber, String phoneToCall) {
            // set callback in Naumen (adjourned case on the current operator with scheduled time)
            String sfId = String.valueOf(record.get('Id'));
            String projectUUID = record.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(record.get('Naumen_Autocall_Project_UUID__c'));
            String caseUUID = record.get('Naumen_Autocall_Case_UUID__c') == null ? '' : String.valueOf(record.get('Naumen_Autocall_Case_UUID__c'));
            Map <String, String> callFormAttrMap = createCallFormAttrMap(record, params);
            Naumen_Callouts.sendRequest_setCallbackToOperator (sfId, projectUUID, caseUUID
                                                            , callInitiatedPhoneNumber, currentPhoneNumber, phoneToCall, callBackScheduledTime, false
                                                            , callFormAttrMap);
        }
        private void setCallFormFieldsInNaumen (sObject record, RecordAssignCheckParams params) {
            // send callform data to Naumen for reports
            String sfId = String.valueOf(record.get('Id'));
            String projectUUID = record.get('Naumen_Autocall_Project_UUID__c') == null ? '' : String.valueOf(record.get('Naumen_Autocall_Project_UUID__c'));
            String caseUUID = record.get('Naumen_Autocall_Case_UUID__c') == null ? '' : String.valueOf(record.get('Naumen_Autocall_Case_UUID__c'));
            Map <String, String> callFormAttrMap = createCallFormAttrMap(record, params);
            Boolean isNaumenCaseFinished = params.activity.type != 'Callback' && params.activity.type != 'Disqualification';
            Naumen_Callouts.sendRequest_setCallFormFields (sfId, projectUUID, caseUUID
                                                        , callFormAttrMap, isNaumenCaseFinished);
        }
        private Map <String, String> createCallFormAttrMap (sObject record, RecordAssignCheckParams params) {
            Map <String, String> ret = new Map <String, String> ();
            String sfId = String.valueOf(record.get('Id'));
            ret.put('sf', sfId);
            Map <String, String> hasVehicleFleetTranslations = getHasVehicleFleetOptionsTranslations(sfId);
            // 'answer' attribute on call form on Naumen Case
            String hasVehicleFleet = record.get('HasVehicleFleet__c') == null ? null 
                                   : hasVehicleFleetTranslations.get(String.valueOf(record.get('HasVehicleFleet__c')));
            ret.put('answer', hasVehicleFleet);
            // 'clanswer' attribute on call form on Naumen Case
            String callResult = params.activity.type == 'Disqualification' ? PhoneNumbersHandler.getPhoneStatuses_Disqual().get(params.activity.disqualReason)
                              : 'Обработан успешно';
            ret.put('clanswer', callResult);
            // 'meet' attribute on call form on Naumen Case
            Boolean scheduledMeeting = params.activity.type != 'Callback' && params.activity.type != 'Disqualification';
            ret.put('meet', scheduledMeeting ? 'да' : 'нет');
            // 'ext' attribute on call form on Naumen Case
            String meetingType = getResultTypesTranslations().get(params.activity.type); // activity type label as it's shown to the user
            ret.put('ext', meetingType);
            return ret;
        }

        /**************************** END OF QUEUEABLE **********************/
    }

    /*******************************************************************************
    *  Name            : convertPastBusinessDaysToCalendar()
    *  Summary         : Convert past business days to calendar days
    *  Parameters      : Integer businessDays - number of business days which have passed
    *  Returns         : Integer returnValue - number of calendar days which have passed (calculated from business days)
    ******************************************************************************/
    private static Integer convertPastBusinessDaysToCalendar(Integer businessDays, BusinessHours businessHoursRu){
        Datetime calculatedDate = system.now();
        for (Integer elapsed = 0; elapsed < businessDays; elapsed++) {
            calculatedDate = calculatedDate.addDays(-1);
            for(Integer i = 0; i<2; i++){
                if (BusinessHours.isWithin(businessHoursRu.Id, calculatedDate)) {
                    break;
                } else{
                    calculatedDate = calculatedDate.addDays(-1);
                }
            }
        }
        return Date.valueOf(calculatedDate).daysBetween(Date.valueOf(system.now()));
    }
    /*******************************************************************************
    *  Name            : prepareNotification()
    *  Summary         : prepare Notification necessary notifications about record
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public static void prepareNotification(List<Messaging.SingleEmailMessage> listToSend, String notificationType, List<Id> sendToAddress, String jsonObject){
        sObject record = (SObject)JSON.deserialize(jsonObject, SObject.class);
        String SObjectType = record.getSObjectType().getDescribe().name;
        if(notificationType == 'RecordIsAssigned'){
            if(sObjectType == 'Lead') {
                Set<String> leadSourceTypes = new Set<String>{
                        'Webform', 'Popup', 'Chat', 'Email', 'Phone_call'
                };
                String recordSourceType = String.valueOf(record.get('Lead_Source_Type__c'));
                if (recordSourceType == null || recordSourceType == '' || ! leadSourceTypes.contains(recordSourceType)) {
                    listToSend.add(EmailGenerator.prepareHtmlEmailToTarget(
                            new List<Id>{String.valueOf(record.get('OwnerId'))},
                            'Встреча КЦ',
                            '<p>Здравствуйте! </p>' + '<p>Запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.get('Id') + '" > ' + record.get('Id') + '</a> назначена на вас!</p>'
                    ));
                }
            } else if (sObjectType == 'Opportunity'){
                listToSend.add(EmailGenerator.prepareHtmlEmailToTarget(
                        new List<Id>{String.valueOf(record.get('OwnerId'))},
                        'Встреча КЦ',
                        '<p>Здравствуйте! </p>' + '<p>Запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.get('Id') + '" > ' + record.get('Id') + '</a> назначена на вас!</p>'
                ));
            }
        } else if(notificationType == 'KeyClients'){
            if(sObjectType == 'Lead'){
                Lead currentLead = (Lead)JSON.deserialize(jsonObject, Lead.class);
                List<User> keyUser = [SELECT Id, Name FROM User WHERE Id = :currentLead.OwnerId AND UserRole.Name in ('PPR Key Accounts Manager', 'PPR Teamleader KAM')];
                if(keyUser.size() == 1){
                    Email_Notifications__c settings  = Email_Notifications__c.getAll().get('RU CC Speed Up - Director Key Clients');
                    List<String> directorKeyClients = settings.ListIDs__c.split(';');
                    listToSend.add(EmailGenerator.prepareHtmlEmailToTarget(
                            directorKeyClients,
                            'Перевод "Интереса"',
                            '<p>Был совершен перевод Интереса.</p>' +
                                    '<p>ИНН : ' + currentLead.INN__c + '</p>' +
                                    '<p>Наименование компании : ' + currentLead.Company + '</p>' +
                                    '<p>Снят с : ' + keyUser.get(0).get('Name') + '</p>' +
                                    '<p>Статус : ' + currentLead.Status + '</p>' +
                                    '<p>Ссылка на запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentLead.Id + '" > ' + currentLead.Id + ' </a></p>'
                    ));
                }
            } else if (sObjectType == 'Opportunity'){
                Opportunity currentOpportunity = (Opportunity)JSON.deserialize(jsonObject, Opportunity.class);
                List<SObject> currentAccount = [SELECT Id, Inn__c, Name FROM Account WHERE Id = :currentOpportunity.AccountId];
                List<User> keyUser = [SELECT Id, Name FROM User WHERE Id = :currentOpportunity.OwnerId AND UserRole.Name in ('PPR Key Accounts Manager', 'PPR Teamleader KAM')];
                if(keyUser.size() == 1){
                    Email_Notifications__c settings  = Email_Notifications__c.getAll().get('RU CC Speed Up - Director Key Clients');
                    List<String> directorKeyClients = settings.ListIDs__c.split(';');
                    listToSend.add(EmailGenerator.prepareHtmlEmailToTarget(
                            directorKeyClients,
                            'Перевод "Возможности"',
                            '<p>Был совершен перевод Возможности.</p>' +
                                    '<p>ИНН : ' + currentAccount.get(0).get('Inn__c') + '</p>' +
                                    '<p>Наименование компании : ' + currentAccount.get(0).get('Name') + '</p>' +
                                    '<p>Снят с : ' + keyUser.get(0).get('Name') + '</p>' +
                                    '<p>Статус : ' + currentOpportunity.StageName + '</p>' +
                                    '<p>Ссылка на запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentOpportunity.Id + '" > ' + currentOpportunity.Id + ' </a></p>'
                    ));
                }

            }
        } else if(notificationType == 'MovedToStart'){
            listToSend.add(EmailGenerator.prepareHtmlEmailToTarget(
                    sendToAddress,
                    'Пилот: Ускорение КЦ. Для записи "Moved to start" назначена задача.',
                    '<p>Поступил запрос на работу с записью, которая попадает хотя бы в одно из следующих условий:</p>' +
                            '<p>1) Возможность имеет этап "Moved to Start".</p>' +
                            '<p>2) У данной организации есть дата прокачки</p>' +
                            '<p>3) Владец Возможности/Аккаунте находится в списке исключений</p>' +
                            '<p>4) Есть родительский аккаунт у организации </p>' +
                            '<p>Ссылка на запись <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.get('Id') + '" > ' + record.get('Id') + ' </a></p>'
            ));
        }
    }

    public static Boolean isEmailWithRussianAlphabet(String email) {
        Boolean result = false;
        //String emailRegex = '^[a-zA-Zа-яА-Я0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Zа-яА-Я0-9.-]+\\.[a-zA-Zа-яА-Я]{2,4}$'; //
        String emailRegex = '(\\X+)([а-яА-Я])(\\X+)';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (MyMatcher.matches()){
            result = true;
        }
        return result;
    }

    public static Boolean isEmailDuplicate(String email, SObject record){
        Boolean result = false;
        if(record.get('Email') != null){
            if(String.valueOf(record.get('Email')) == email){
                result = true;
            }
        }
        if(record.get('Additional_Emails__c') != null){
            if(String.valueOf(record.get('Additional_Emails__c')).contains(email)){
                result = true;
            }
        }
        return result;
    }
    /*******************************************************************************
    *  Name            : getFields_queryLeadToGetRecordAccess
    *  Summary         : gets lead fields required for checking record access
    *  Parameters      :
    *  Returns         : List<Lead> - leads records
    ******************************************************************************/
    public static List <String> getFields_queryLeadToGetRecordAccess(){
        List <String> fieldsList = new List <String> {
            'Id', 'Name' , 'INN__c', 'OwnerId', 'IsConverted', 'ConvertedOpportunityId', 'Status', 'Lead_Owner_Role__c', 'Company',
            'Owner.Name', 'Region__c', 'Last_Owner_Change_Date_RUS__c', 'PD_ExternalId__c', 'Description', 
            'Naumen_Autocall_Project_UUID__c', 'Naumen_Autocall_Case_UUID__c', 
            'Naumen_Case_Status__c', 'Naumen_Case_Status_ModifiedTime__c'
        };
        List <String> phoneFields = PhoneNumbersHandler.getAllPhoneFields (Schema.Lead.sObjectType);
        fieldsList.addAll(phoneFields);
        return fieldsList;
    }
    /*******************************************************************************
    *  Name            : queryLeadToGetRecordAccess
    *  Summary         : gets lead record by lead id parameter
    *  Parameters      : Id recordId - id of the lead
    *  Returns         : List<Lead> - leads records
    ******************************************************************************/
    public static List<Lead> queryLeadToGetRecordAccess(Id recordId, List <String> fieldsList){
        String queryStr = ' SELECT ' + String.join(new List <String> (fieldsList), ',');
        queryStr += ' FROM Lead ';
        String whereStr = ' WHERE Id = \''+recordId+'\' AND RecordTypeId = \''+Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()+'\'';
        queryStr += whereStr;
        List <Lead> leadsList = Database.query(queryStr);
        return leadsList;
    }
    /*******************************************************************************
    *  Name            : getFields_queryOpportunityToGetRecordAccess
    *  Summary         : gets opportunity fields required for checking record access
    *  Parameters      : 
    *  Returns         : List<Lead> - leads records
    ******************************************************************************/
    public static List <String> getFields_queryOpportunityToGetRecordAccess(){
        List <String> fieldsList = new List <String> {
            'Id', 'Account.Inn__c', 'Name', 'OwnerId', 'StageName', 'ContactId', 
            'AccountId', 'Account.Last_pump_date__c', 'Account.ParentId', 'Account.Name',
            'Owner.Name', 'Owner_User_UserRole_Name__c', 'Account.Moved_to_Start__c', 'Account.OwnerId',
            'Last_Owner_Change_Date_RUS__c', 'Description',
            'Naumen_Autocall_Project_UUID__c', 'Naumen_Autocall_Case_UUID__c', 'Naumen_Case_Status__c', 'Naumen_Case_Status_ModifiedTime__c'
        };
        return fieldsList;
    }
    /*******************************************************************************
    *  Name            : queryOpportunityToGetRecordAccess
    *  Summary         : gets lead record by opportunity id parameter
    *  Parameters      : Id recordId - id of the opportunity
    *  Returns         : List<Opportunity> - opportunities record
    ******************************************************************************/
    public static List<Opportunity> queryOpportunityToGetRecordAccess(Id recordId, List <String> fieldsList){
        String queryStr = ' SELECT ' + String.join(new List <String> (fieldsList), ',');
        queryStr += ' FROM Opportunity ';
        String whereStr = ' WHERE Id = \''+recordId+'\' AND RecordTypeId = \''+Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId()+'\'';
        queryStr += whereStr;
        List <Opportunity> oppsList = Database.query(queryStr);
        return oppsList;
    }

    public static void savePhoneFields_Lead (Lead record, RecordAssignCheckParams params) {
        if(params.contact.phone != null && params.contact.phone != '' || params.contact.phoneSecond != null && params.contact.phoneSecond != ''){
            if(params.contact.phone != null && params.contact.phone != ''){
                if(record.Phone == null || record.Phone == ''){
                    record.Phone = params.contact.getPhoneWithExtensionNumber();
                } else {
                    String oldPhone = record.Phone.replace('.',':');
                    String oldPhoneStatus = record.Phone_Status__c;
                    String oldPhoneRating = PhoneNumbersHandler.rating_formatToString(Double.valueOf(record.Phone_Rating__c));
                    String oldPhoneModiiedDate = PhoneNumbersHandler.getModifiedDate_Formatted (record.Phone_StatusModifiedDate__c);

                    record.Phone = params.contact.getPhoneWithExtensionNumber();

                    String oldPhoneFormatted = PhoneNumbersHandler.trimPhoneNumber(oldPhone, true);
                    String additionalPhoneItem = PhoneNumbersHandler.createAdditionalPhoneItemString (oldPhoneFormatted, oldPhoneStatus, oldPhoneRating, oldPhoneModiiedDate);
                    record.Additional_Phones__c = PhoneNumbersHandler.addAdditionalNumbers(record, new List<String>{additionalPhoneItem});
                }
            }
            if( params.contact.phoneSecond != null && params.contact.phoneSecond != ''){
                if(record.PPR_Contact_Phone__c == null || record.PPR_Contact_Phone__c == ''){
                    record.PPR_Contact_Phone__c = params.contact.phoneSecond;
                } else {
                    String oldPhone = record.PPR_Contact_Phone__c.replace('.',':');
                    String oldPhoneStatus = record.PPR_Contact_Phone_Status__c;
                    String oldPhoneRating = PhoneNumbersHandler.rating_formatToString(Double.valueOf(record.PPR_Contact_Phone_Rating__c));
                    String oldPhoneModiiedDate = PhoneNumbersHandler.getModifiedDate_Formatted (record.PPR_Contact_Phone_StatusModifiedDate__c);

                    record.PPR_Contact_Phone__c = params.contact.phoneSecond;

                    String oldPhoneFormatted = PhoneNumbersHandler.trimPhoneNumber(oldPhone, true);
                    String additionalPhoneItem = PhoneNumbersHandler.createAdditionalPhoneItemString (oldPhoneFormatted, oldPhoneStatus, oldPhoneRating, oldPhoneModiiedDate);
                    record.Additional_Phones__c = PhoneNumbersHandler.addAdditionalNumbers(record, new List<String>{additionalPhoneItem});
                }
            }
            //PhoneNumbersHandler.addAdditionalNumbersToPhoneFields(record);
        }
    }
    public static void savePhoneFields_Contact (Contact contact, RecordAssignCheckParams params) {
        if(params.contact.phone != null && params.contact.phone != ''){
            if(contact.Phone == null || contact.Phone == ''){
                contact.Phone = params.contact.getPhoneWithExtensionNumber();
            } else {
                String oldPhone = contact.Phone.replace('.',':');
                String oldPhoneStatus = contact.Phone_Status__c;
                String oldPhoneRating = PhoneNumbersHandler.rating_formatToString(Double.valueOf(contact.Phone_Rating__c));
                String oldPhoneModiiedDate = PhoneNumbersHandler.getModifiedDate_Formatted (contact.Phone_StatusModifiedDate__c);

                contact.Phone = params.contact.getPhoneWithExtensionNumber();

                String oldPhoneFormatted = PhoneNumbersHandler.trimPhoneNumber(oldPhone, true);
                String additionalPhoneItem = PhoneNumbersHandler.createAdditionalPhoneItemString (oldPhoneFormatted, oldPhoneStatus, oldPhoneRating, oldPhoneModiiedDate);
                contact.Additional_Phones__c = PhoneNumbersHandler.addAdditionalNumbers(contact, new List<String>{additionalPhoneItem});
            }
        }
        if( params.contact.phoneSecond != null && params.contact.phoneSecond != ''){
            if(contact.PPR_Contact_Phone__c == null || contact.PPR_Contact_Phone__c == ''){
                contact.PPR_Contact_Phone__c = params.contact.phoneSecond;
            } else {
                String oldPhone = contact.PPR_Contact_Phone__c.replace('.',':');
                String oldPhoneStatus = contact.PPR_Contact_Phone_Status__c;
                String oldPhoneRating = PhoneNumbersHandler.rating_formatToString(Double.valueOf(contact.PPR_Contact_Phone_Rating__c));
                String oldPhoneModiiedDate = PhoneNumbersHandler.getModifiedDate_Formatted (contact.PPR_Contact_Phone_StatusModifiedDate__c);

                contact.PPR_Contact_Phone__c = params.contact.phoneSecond;

                String oldPhoneFormatted = PhoneNumbersHandler.trimPhoneNumber(oldPhone, true);
                String additionalPhoneItem = PhoneNumbersHandler.createAdditionalPhoneItemString (oldPhoneFormatted, oldPhoneStatus, oldPhoneRating, oldPhoneModiiedDate);
                contact.Additional_Phones__c = PhoneNumbersHandler.addAdditionalNumbers(contact, new List<String>{oldPhone});
            }
        }
        //PhoneNumbersHandler.addAdditionalNumbersToPhoneFields(contact);
    }
        /*******************************************************************************
    *  Name            : queryContactsToSave
    *  Summary         : gets list of contacts by parameters (contact id / opportunity id/ account id)
    *  Parameters      : Id contactId - id of contact which was found by phone number and passed to the page,
                         Id opportunityId - opportunity which is related to the call,
                         Id accountId - parent account of the opportunity
    *  Returns         : List <Contact> - list of contacts which were found
    ******************************************************************************/
    public static Map<Id, Contact> queryContactsToSave(Id contactId, Id opportunityId, Id accountId){
        List <String> fieldsList = new List <String> {
                'Id', 'Name', 'FirstName', 'MiddleName', 'LastName', 'Title', 'Email', 'Additional_Emails__c', 'PD_ExternalId__c'
        };
        List <String> phoneFields = GlobalUtils.getFieldSetMembersAPIs(Schema.Contact.sObjectType, 'All_Phone_Fields');
        for (String phoneFieldAPI : phoneFields) {
            if (!phoneFieldAPI.contains('.')) {
                fieldsList.add(phoneFieldAPI);
                //--- phone status fields ---
                String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
                if (phoneStatusFieldAPI != null) {
                    String statusModifiedDateFieldAPI =  PhoneNumbersHandler.getPhoneStatusModifiedDateField (phoneFieldAPI);
                    String phoneRatingFieldAPI = PhoneNumbersHandler.getPhoneRatingField (phoneFieldAPI);
                    fieldsList.add(phoneStatusFieldAPI);
                    fieldsList.add(statusModifiedDateFieldAPI);
                    fieldsList.add(phoneRatingFieldAPI);
                }
            }
        }
        String queryContactStr = ' SELECT ' + String.join(new List <String> (fieldsList), ',');
        queryContactStr += addPDFieldsToQuery(queryContactStr, Contact.getSObjectType());
        queryContactStr += ' FROM Contact ';

        String whereStr = ' WHERE AccountId = \'' + accountId + '\'';
        if (contactId != null)  { // contact was found by phone
            whereStr += ' OR Id = \'' + contactId + '\'';
        }
        Set<String> contactIds = new Set<String>();
        for(OpportunityContactRole oppContactRoles : [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId = :opportunityId]){
            contactIds.add(oppContactRoles.ContactId);
        }
        if (!contactIds.isEmpty())  whereStr += ' OR Id IN (\''+String.join(new List<String>(contactIds), '\',\'')+'\') ';
        queryContactStr += whereStr;
        List <Contact> contactList = Database.query(queryContactStr);
        return new Map <Id, Contact> (contactList);
    }
    /*******************************************************************************
    *  Name            : queryLeadToSave
    *  Summary         : gets lead record by lead id parameter
    *  Parameters      : Id leadId - id of call lead
    *  Returns         : Lead - lead record
    ******************************************************************************/
    public static Lead queryLeadToSave(Id leadId){
        List <String> fieldsList = new List <String> {
                'Id', 'Name', 'Status', 'INN__c', 'Company', 'FirstName', 'MiddleName', 'LastName', 'Title', 'Email', 'Additional_Emails__c', 'Website', 'OwnerId',
                'Lead_Source_Type__c', 'Source_of_Lead__c', 'PD_ExternalId__c',
                'Projected_Liters_month__c', 'Projected_amount_in_rub_month__c', 'Anzahl_PKW__c', 'Anzahl_LKW__c', 'HasVehicleFleet__c',
                'Custom_Distribution_Team__c', 'Description', 'Naumen_Case_Status__c', 'Naumen_Case_Status_ModifiedTime__c'
        };
        List <String> phoneFields = GlobalUtils.getFieldSetMembersAPIs(Schema.Lead.sObjectType, 'All_Phone_Fields');
        for (String phoneFieldAPI : phoneFields) {
            if (!phoneFieldAPI.contains('.')) {
                fieldsList.add(phoneFieldAPI);
                //--- phone status fields ---
                String phoneStatusFieldAPI = PhoneNumbersHandler.getPhoneStatusField (phoneFieldAPI);
                if (phoneStatusFieldAPI != null) {
                    String statusModifiedDateFieldAPI =  PhoneNumbersHandler.getPhoneStatusModifiedDateField (phoneFieldAPI);
                    String phoneRatingFieldAPI = PhoneNumbersHandler.getPhoneRatingField (phoneFieldAPI);
                    fieldsList.add(phoneStatusFieldAPI);
                    fieldsList.add(statusModifiedDateFieldAPI);
                    fieldsList.add(phoneRatingFieldAPI);
                }
            }
        }
        String queryLeadStr = ' SELECT ' + String.join(new List <String> (fieldsList), ',');
        queryLeadStr += addPDFieldsToQuery(queryLeadStr, Lead.getSObjectType());
        queryLeadStr += ' FROM Lead ';

        String whereStr = ' WHERE Id = \'' + leadId + '\'';
        queryLeadStr += whereStr;
        List <Lead> leadsList = Database.query(queryLeadStr);
        return leadsList.isEmpty() ? null : leadsList[0];
    }
    public static String addPDFieldsToQuery(String query, Schema.SObjectType sObjType) {
        String pdFieldsForQuery = '';

        if (PD_Callouts.isPDActive()) {
            List<String> fields = new List<String>();
            List<Schema.FieldSetMember> pdFields = GlobalUtils.getFieldSetMembers(sObjType, 'PD_Fields');
            List<Schema.FieldSetMember> phoneFields =  GlobalUtils.getFieldSetMembers(sObjType, 'All_Phone_Fields');

            for (Schema.FieldSetMember pdField : pdFields) {
                if (!query.contains(pdField.getFieldPath())) {
                    fields.add(pdField.getFieldPath());
                }
            }
            for (Schema.FieldSetMember phoneField : phoneFields) {
                if (!query.contains(phoneField.getFieldPath())) {
                    fields.add(phoneField.getFieldPath());
                }
            }

            pdFieldsForQuery = (!fields.isEmpty()) ? ', ' + String.join(fields, ', ') : '';
        }

        return pdFieldsForQuery;
    }
    public static Contact getCallContact (String callCustomerId, Map<Id, Contact> clientContactsMap, RecordAssignCheckParams params) {
        if (clientContactsMap.isEmpty()) return null;
        Contact callContact;
        if (callCustomerId != null && clientContactsMap.containsKey(callCustomerId)) {
            callContact = clientContactsMap.get(callCustomerId);
        }
        for(Contact contact : clientContactsMap.values()) {
            if(callContact == null) { // find contact by name
                if( Decimal.valueOf((contact.Name.toUpperCase().contains(params.contact.firstName.toUpperCase()) && params.contact.firstName != '' && params.contact.firstName != null) ? 1 : 0) +
                        Decimal.valueOf((contact.Name.toUpperCase().contains(params.contact.middleName.toUpperCase()) && params.contact.middleName != '' && params.contact.middleName != null) ? 1 : 0) +
                        Decimal.valueOf((contact.Name.toUpperCase().contains(params.contact.lastName.toUpperCase()) && params.contact.lastName != '' && params.contact.lastName != null) ? 1 : 0) >= 2
                        ){
                    callContact = contact;
                }
            }
        }
        return callContact;
    }
    public static Contact createNewContactAndSave (Opportunity opp, RecordAssignCheckParams params, Boolean CTIEnabled) {
        Contact newContact = createNewContact (opp, params, CTIEnabled);  // send pd fields to the server here
        insert newContact;
        params.contact.Id = newContact.Id;
        // send data to PD
        PD_Callouts.sendReq_saveData(newContact);
        return newContact;
    }
    public static Contact createNewContact (Opportunity opp, RecordAssignCheckParams params, Boolean CTIEnabled) {
        Contact newContact = new Contact(
            FirstName = params.contact.firstName,
            LastName = (params.contact.lastName == '') ? 'N/A' : params.contact.lastName,
            MiddleName = params.contact.middleName,
            Phone = params.contact.getPhoneWithExtensionNumber(),
            PPR_Contact_Phone__c = params.contact.phoneSecond,
            Title = params.contact.position,
            AccountId = opp.AccountId,
            Salutation = 'Herr',
            OwnerId = opp.OwnerId,
            RecordTypeId =  Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId(),
            PD_Avaliable_LastName_Update__c = true
        );
         if(params.contact.email != '' && params.contact.email != null){
            if(RecordAssignCheckRuCtrl.isEmailWithRussianAlphabet(params.contact.email)){
                newContact.Additional_Emails__c += ':'+params.contact.email;
            } else {
                newContact.Email = params.contact.email;
            }
        }
        if(params.contact.emailSecond != '' && params.contact.emailSecond != null){
            if( ! isEmailDuplicate(params.contact.emailSecond, newContact)){
                if((newContact.Email != '' && newContact.Email != null) || isEmailWithRussianAlphabet(params.contact.emailSecond)){
                    if(newContact.Additional_Emails__c == '' || newContact.Additional_Emails__c == null){
                        newContact.Additional_Emails__c = params.contact.emailSecond;
                    } else {
                        newContact.Additional_Emails__c += ':'+params.contact.emailSecond;
                    }
                } else {
                    newContact.Email = params.contact.emailSecond;
                }
            }
        }
        if (CTIEnabled == true) Naumen_RecordsHelper.setCallResultsFields (newContact, 'Phone', params.activity.disqualReason);
        return newContact;
    }
    public static List <CallHistoryRow> createCallHistory (sObject sObj, String caseStatus, DateTime caseModifiedDT, Map <String, String> phoneStatusesTransl) {
        List <CallHistoryRow> ret = new List <CallHistoryRow>();
        if (caseStatus != 'Created' || caseModifiedDT == null) return ret;
        PhoneNumbersHandler.sObjWrapper sObjWrap = PhoneNumbersHandler.createSObjWrapper (sObj);
        // phone fields
        for (String phoneFieldAPI : sObjWrap.phoneWrappersMap.keySet()) {
            PhoneNumbersHandler.PhoneWrapper phoneWrap = sObjWrap.phoneWrappersMap.get(phoneFieldAPI);
            String phoneVal = phoneWrap.phoneNumber;
            DateTime statusModifiedDateDT = phoneWrap.statusModifiedTime;
            if (statusModifiedDateDT != null && statusModifiedDateDT > caseModifiedDT) {
                String statusVal = phoneWrap.phoneStatus;
                if (statusVal == null) statusVal = '';
                else if (phoneStatusesTransl.containsKey(statusVal)) statusVal = phoneStatusesTransl.get(statusVal);
                ret.add(new CallHistoryRow (phoneVal, statusVal, statusModifiedDateDT));
            }
        }
        // additional phones
        if (!sObjWrap.existingAdditionalPhones.isEmpty()) {
            for (String phoneVal : sObjWrap.existingAdditionalPhones.keySet()) {
                String additionalPhoneItem = sObjWrap.existingAdditionalPhones.containsKey(phoneVal) ? sObjWrap.existingAdditionalPhones.get(phoneVal) : null;
                DateTime statusModifiedDateDT = PhoneNumbersHandler.additionaPhonelItem_getModifiedDate_DateTime (additionalPhoneItem);
                if (statusModifiedDateDT != null && statusModifiedDateDT > caseModifiedDT) {
                    String statusVal = PhoneNumbersHandler.additionaPhonelItem_getStatus (additionalPhoneItem);
                    if (statusVal == null) statusVal = '';
                    else if (phoneStatusesTransl.containsKey(statusVal)) statusVal = phoneStatusesTransl.get(statusVal);
                    ret.add(new CallHistoryRow (phoneVal, statusVal, statusModifiedDateDT));
                }
            }
        }
        // irrelevant numbers
        if (!sObjWrap.irrelevantNumbers.isEmpty()) {
            Map <String, String> phoneStatusReasons_Irrelevant = PhoneNumbersHandler.getPhoneStatusReasons();
            for (String phoneVal : sObjWrap.irrelevantNumbers.keySet()) {
                String irrelevantPhoneItem = sObjWrap.irrelevantNumbers.get(phoneVal);
                String irrelevantPhoneModifiedItem = sObjWrap.irrelevantNumbersModifiedTime.containsKey(phoneVal) ? sObjWrap.irrelevantNumbersModifiedTime.get(phoneVal) : null;
                DateTime statusModifiedDateDT = PhoneNumbersHandler.irrelevantPhonelItem_getModifiedDate_DateTime(irrelevantPhoneModifiedItem);
                if (statusModifiedDateDT != null && statusModifiedDateDT > caseModifiedDT) {
                    String statusReasonCode = PhoneNumbersHandler.irrelevantItem_getReason(irrelevantPhoneItem);
                    String statusVal = phoneStatusReasons_Irrelevant.get(statusReasonCode);
                    if (statusVal == null) statusVal = '';
                    else if (phoneStatusesTransl.containsKey(statusVal)) statusVal = phoneStatusesTransl.get(statusVal);
                    ret.add(new CallHistoryRow (phoneVal, statusVal, statusModifiedDateDT));
                }
            }
        }
        ret.sort();
        return ret;
    }
    public static List <CallHistoryRow> createCallHistory_Lead (sObject sObj) {
        List <CallHistoryRow> ret = new List <CallHistoryRow> ();
        String caseStatus = String.valueOf(sObj.get('Naumen_Case_Status__c'));
        DateTime caseModifiedDT = DateTime.valueOf(sObj.get('Naumen_Case_Status_ModifiedTime__c'));
        Map<String, String> phoneStatusesTransl = PhoneNumbersHandler.getPhoneStatusesTranslations(Schema.Lead.sObjectType);
        ret = createCallHistory(sObj, caseStatus, caseModifiedDT, phoneStatusesTransl);
        return ret;
    }
    public static List <CallHistoryRow> createCallHistory_OppContactsList (sObject sObj) {
        List <CallHistoryRow> ret = new List <CallHistoryRow> ();
        String caseStatus = String.valueOf(sObj.get('Naumen_Case_Status__c'));
        DateTime caseModifiedDT = DateTime.valueOf(sObj.get('Naumen_Case_Status_ModifiedTime__c'));
        Naumen_RecordsHelper.OpportunityWrap opportunityWrap = new Naumen_RecordsHelper.OpportunityWrap (sObj, null);
        Map <Id, Naumen_RecordsHelper.ContactWrap> allContacts = opportunityWrap.allContacts;
        if (!allContacts.isEmpty()) {
            Map<String, String> phoneStatusesTransl = PhoneNumbersHandler.getPhoneStatusesTranslations(Schema.Contact.sObjectType);
            for (Id conId : allContacts.keySet()) {
                Naumen_RecordsHelper.ContactWrap conWrapItem = allContacts.get(conId); 
                Contact con = (Contact) conWrapItem.sObj;
                List <CallHistoryRow> contactCallHistory = createCallHistory(con, caseStatus, caseModifiedDT, phoneStatusesTransl);
                if (!contactCallHistory.isEmpty()) ret.addAll(contactCallHistory);
            }
        }
        ret.sort();
        return ret;
    }
}