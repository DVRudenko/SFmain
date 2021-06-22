public class FieldSalesTerritoryCtrl {

    public List<SObject> sObjectsFullList;                    // Список всех записей по запросу
    public List<FieldSalesTerritoryWrapper> sObjectsFullListSorted;  // Список всех отсортированный записей
    public List<FieldSalesTerritoryWrapper> sObjectsList {get; set;} // Текущий список записей на странице
    public String column1Sort {get; set;}                     // Поле сортировки
    public String sortGeneral {get; set;}                     // Сортировка : ASC/DESC
    public String tabLink {get; set;}                         // Ссылка на запись

    public String currentTerritoryId{get; set;}               // Текущая выбранная территория
    public List<SelectOption> listTerritories {get; set;}     // Список доступных территорий

    public String currentSubTerritoryId{get;set;}             // Текущая выбраннаая подтерритория
    public List<SelectOption> listSubTerritories{get;set;}    // Список доступных подтерриторий

    public String currentSection{get; set;}                   // Текущая выбранная секция скоринга
    public List<SelectOption> listScoringSections {get; set;} // Список доступных секций скоринга
    public String currentRatingNew {get; set;}                 // Текущая выбранная секция Rating New
    public List<SelectOption> listRatingNewSections {get; set;}// Список доступных секций нового рейтинга

    private Map<Id, FS_Territory__mdt> territories;           // Все доступные территории
    private Map<Id, List<FS_Tree_Area__mdt>> areasMap;        // Список всех доступных FS_Tree_Area__mdt для FS_Territoy__mdt.Id
    private Map<Id, List<FS_Tree_Province__mdt>> provincesMap;// Список всех доступных FS_Tree_Province__mdt для FS_Territoy__mdt.Id

    private final String keyAES256 = '2ftrjul9asewqrnjgfk945zs=55423gg'; // Ключ для шифрования
    private Id currentUser;                                   // Текущий пользователь
    private BusinessHours businessHoursRu;                    // Бизнес часы, для подсчёта "Рабочих дней" в запросе
    private Set<Id> leadsQueuesId;                            // Список очередей для Lead в которых искать Территориальные лиды
    private Set<Id> excludeOwnerUserId;                       // Исключить записи этих владельцов
    private Set<Id> excludeOppOwnersId;                       // Исключить записи этих владельцов Opportunity
    private Set<String> leadStatusInProcess;                  // Список Lead.Status содержащих "In Process"
    private Id russianLeadRecordType;                         // Russian Sales Lead record type Id
    private Integer calendarDays1;                            // Подсчитанное от 1 "Бизнес дня", количество прошедших "Календарных дней"
    private Integer calendarDays2;                            // Подсчитанное от 2 "Бизнес дней", количество прошедших "Календарных дней"
    private Integer calendarDays3;                            // Подсчитанное от 3 "Бизнес дней", количество прошедших "Календарных дней"
    private Integer calendarDays10;                           // Подсчитанное от 10 "Бизнес дней", количество прошедших "Календарных дней"
    private Integer numberRecordsPerPage = 0;                 // Количество записей на странице (Custom Setting)

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : execute when page started (page init action).
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void init(){
        this.sObjectsList = new List<FieldSalesTerritoryWrapper>();
        this.column1Sort = 'SummaryScoringRu__c';
        this.currentUser = UserInfo.getUserId();
        prepareDataToQuery();
        generateTotalRecordsList();
        startFirstPage();
    }

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : init method for test
    *  Parameters      : Id territoryId
    *  Returns         : -
    ******************************************************************************/
    public void init(Id territoryId,Id userId){
        this.sObjectsList = new List<FieldSalesTerritoryWrapper>();
        this.column1Sort = 'SummaryScoringRu__c';
        this.currentUser = userId;
        prepareDataToQuery();

        this.currentTerritoryId = territoryId;
        prepareListSubTerritories();

        generateTotalRecordsList();
        startFirstPage();
    }

    /*******************************************************************************
    *  Name            : prepareDataToQuery()
    *  Summary         : prepare different information to records query.
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void prepareDataToQuery(){
        Map<String, FieldSalesTerritory_General_Settings__c> fieldSalesSettings = FieldSalesTerritory_General_Settings__c.getAll();
        // Exclude Owner Id
        excludeOwnerUserId = new Set<Id>();
        List<User> excludeUsers = [
                SELECT id
                FROM User
                WHERE UserRole.Name = 'PPR Key Accounts Manager'
                OR UserRole.Name = 'PPR Teamleader KAM'
                OR UserRole.Name = 'PPR FieldTerritory_Call Center'
        ];
        for(User user : excludeUsers){
            excludeOwnerUserId.add(user.Id);
        }

        // Exclude Opportunity Owners Id
        excludeOppOwnersId = new Set<Id>();
        if(excludeOwnerUserId.size() != 0){
            excludeOppOwnersId.addAll(excludeOwnerUserId);
        }
        if(fieldSalesSettings.get('RU').exludeOppOwnersId__c != null && fieldSalesSettings.get('RU').exludeOppOwnersId__c != ''){
            for(String ownerId : String.valueOf(fieldSalesSettings.get('RU').exludeOppOwnersId__c).split(';')){
                excludeOppOwnersId.add(ownerId);
            }
        }

        // Include Lead Queues Id
        leadsQueuesId = new Set<Id>();
        for(Group gr : [
                SELECT id, name
                FROM Group
                WHERE Name LIKE '%PPR Queue Stock%' OR Name LIKE '%PPR Queue Call Center%']){
            leadsQueuesId.add(gr.Id);
        }

        // Lead Status in 'PROCESS'
        leadStatusInProcess = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.value.contains('IN PROCESS')){
                leadStatusInProcess.add(pickListVal.value);
            }
        }

        // Available Territories
        territories = new Map<Id, FS_Territory__mdt>();
        listTerritories = new List<SelectOption>();
        String userParam;
        if(GlobalUtils.blankStringIfNull(currentUser).length()>=15){
            userParam = '%'+GlobalUtils.blankStringIfNull(currentUser).substring(0,15) +'%';
        } else {
            userParam = '%%';
        }
        List<FS_Territory__mdt> availableTerritories = [
                SELECT id, Label, Sort_Ascending__c, Number_Records_Per_Page__c, RatingNew_Sections__c,Scoring_sections__c
                FROM FS_Territory__mdt
                WHERE Assigned_Users_Ids__c LIKE :userParam
                ORDER BY Label
        ];
        for(FS_Territory__mdt territory : availableTerritories){
            territories.put(territory.Id, territory);
            listTerritories.add(new SelectOption(territory.Id, territory.Label));
        }

        areasMap = new Map<Id, List<FS_Tree_Area__mdt>>();
        List<FS_Tree_Area__mdt> areas = [
                SELECT id, Label, FS_Territory__r.Id
                FROM FS_Tree_Area__mdt
                WHERE FS_Territory__r.Id in :territories.keySet()
                ORDER BY Label
        ];
        for(FS_Tree_Area__mdt area : areas){
            if(areasMap.get(area.FS_Territory__r.Id) == null){
                areasMap.put(area.FS_Territory__r.Id, new List<FS_Tree_Area__mdt>{area});
            } else{
                List<FS_Tree_area__mdt> listAreas = areasMap.get(area.FS_Territory__r.Id);
                listAreas.add(area);
                areasMap.put(area.FS_Territory__r.Id, listAreas);
            }
        }

        provincesMap = new Map<Id, List<FS_Tree_Province__mdt>>();
        List<FS_Tree_Province__mdt> provinces =  [
                SELECT id, Label, FS_Territory__r.Id
                FROM FS_Tree_Province__mdt
                WHERE FS_Territory__r.Id in :territories.keySet()
        ];
        for(FS_Tree_Province__mdt province : provinces){
            if(provincesMap.get(province.FS_Territory__r.Id) == null){
                provincesMap.put(province.FS_Territory__r.Id, new List<FS_Tree_Province__mdt>{province});
            } else{
                List<FS_Tree_Province__mdt> listProvinces = provincesMap.get(province.FS_Territory__r.Id);
                listProvinces.add(province);
                provincesMap.put(province.FS_Territory__r.Id, listProvinces);
            }
        }

        numberRecordsPerPage = 300;
        if(listTerritories.size() != 0){
            currentTerritoryId = listTerritories.get(0).getValue();
        } else {
            currentTerritoryId = '00e20000001nSOB';
        }
        listSubTerritories = new List<SelectOption>();
        prepareListSubTerritories();

        russianLeadRecordType = [ SELECT Id, SobjectType FROM RecordType WHERE SobjectType = 'Lead' AND Name = 'Russian Sales' LIMIT 1 ].get(0).Id;

        businessHoursRu = [SELECT Id From BusinessHours where name ='RU_TerritoryManagement'];
        calendarDays1 = convertPastBusinessDaysToCalendar(1);
        calendarDays2 = convertPastBusinessDaysToCalendar(2);
        calendarDays3 = convertPastBusinessDaysToCalendar(3);
        calendarDays10 = convertPastBusinessDaysToCalendar(10);

        // Available Scoring sections
        listScoringSections = new List<SelectOption>();
        listRatingNewSections = new List<SelectOption>();
        prepareListScoringSections();
    }

    /*******************************************************************************
    *  Name            : prepareListScoringSections()
    *  Summary         : prepare list of Scoring Sections Range which filter records by SummaryScoringRu__c field.
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void prepareListScoringSections(){
        listScoringSections.clear();
        listRatingNewSections.clear();
        if(territories.get(currentTerritoryId) != null){
            if(territories.get(currentTerritoryId).Scoring_sections__c != null && territories.get(currentTerritoryId).Scoring_sections__c != ''){
                for(String section : String.valueOf(territories.get(currentTerritoryId).Scoring_sections__c).split(';')){
                    listScoringSections.add(new SelectOption(section, section));
                }
            }
            if(territories.get(currentTerritoryId).RatingNew_Sections__c != null && territories.get(currentTerritoryId).RatingNew_Sections__c != ''){
                for(String section : String.valueOf(territories.get(currentTerritoryId).RatingNew_Sections__c).split(';')){
                    listRatingNewSections.add(new SelectOption(section, section));
                }
            }
        }

        if(listScoringSections.size() != 0){
            currentSection = listScoringSections.get(0).getValue();
        } else {
            currentSection = '';
        }
        if(listRatingNewSections.size() != 0){
            currentRatingNew = listRatingNewSections.get(0).getValue();
        } else {
            currentRatingNew = '';
        }
    }

    private void prepareListSubTerritories(){
        listSubTerritories.clear();
        listSubTerritories.add(new SelectOption('*','*'));
        if(areasMap.get(currentTerritoryId) != null){
            for(FS_Tree_Area__mdt area : areasMap.get(currentTerritoryId)){
                listSubTerritories.add(new SelectOption(area.Id, area.Label));
            }
        }

        if(provincesMap.get(currentTerritoryId) != null){
            for(FS_Tree_Province__mdt province : provincesMap.get(currentTerritoryId)){
                listSubTerritories.add(new SelectOption(province.Id, province.Label));
            }
        }
        currentSubTerritoryId = listSubTerritories.get(0).getValue();
    }

    /*******************************************************************************
    *  Name            : generateTotalRecordsList()
    *  Summary         : main function for get total list of Leads/Opportunity by defined criteria
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void generateTotalRecordsList(){
        setDefaultSorting();
        String additionalFilterLead = generateAdditionalFilterLead();
        sObjectsFullList = new List<SObject>();
        for(SObject sObjectLead : getLeadRecords(numberRecordsPerPage, additionalFilterLead)){
            sObjectsFullList.add(sObjectLead);
        }
        String additionalFilterOpportunity = generateAdditionalFilterOpportunity();
        for(SObject sObjectOpp : getOpportunityRecords(numberRecordsPerPage, additionalFilterOpportunity)){
            sObjectsFullList.add(sObjectOpp);
        }
    }

    public void setDefaultSorting(){
        if(territories.get(currentTerritoryId) != null){
            if(territories.get(currentTerritoryId).Sort_Ascending__c){
                sortGeneral = 'ASC';
                column1Sort = 'SummaryScoringRu__c';
            } else {
                sortGeneral = 'DESC';
                column1Sort = 'SummaryScoringRu__c';
            }
        } else {
            sortGeneral = 'DESC';
            column1Sort = 'SummaryScoringRu__c';
        }
    }

    /*******************************************************************************
    *  Name            : generateAdditionalFilterLead()
    *  Summary         : function for get additional filter for Lead query
    *  Parameters      : -
    *  Returns         : String - filter string for Lead query, which add to "WHERE" section in main query
    ******************************************************************************/
    public String generateAdditionalFilterLead(){
        String resultFilter = '';
        system.debug(currentTerritoryId+ ' ' + currentSubTerritoryId);
        if(currentTerritoryId != null && currentSubTerritoryId != null){
            resultFilter = ' AND (';
            if(currentSubTerritoryId == '*'){
                Map<String, List<String>> areasInProvinces = new Map<String, List<String>>();
                List<FS_Tree_Area__mdt> areasOfTerritory = [
                        SELECT Id, Label, FS_Tree_Province__r.Label
                        FROM FS_Tree_Area__mdt
                        WHERE FS_Territory__r.Id = :currentTerritoryId
                ];
                for(FS_Tree_Area__mdt area: areasOfTerritory){
                    if(areasInProvinces.containsKey(area.FS_Tree_Province__r.Label)){
                        List<String> areas = areasInProvinces.get(area.FS_Tree_Province__r.Label);
                        areas.add(area.Label);
                        areasInProvinces.put(area.FS_Tree_Province__r.Label, areas);
                    } else {
                        areasInProvinces.put(area.FS_Tree_Province__r.Label, new List<String>{area.Label});
                    }
                }
                if(areasInProvinces.size() != 0){
                    for(String province : areasInProvinces.keySet()){
                        resultFilter += ' ( Region__c = \'' + province + '\'  AND Area__c in (';
                        for(String area: areasInProvinces.get(province)){
                            resultFilter += '\'' + area + '\',';
                        }
                        resultFilter = resultFilter.removeEnd(',');
                        resultFilter += ') )';
                    }
                }
                List<FS_Tree_Province__mdt> territoryProvinces = [
                        SELECT Id, Label
                        FROM FS_Tree_Province__mdt
                        WHERE FS_Territory__r.Id = :currentTerritoryId];
                if(territoryProvinces.size() != 0){
                    if(resultFilter == ' AND ('){
                        resultFilter += ' Region__c in (';
                    } else {
                        resultFilter += ' OR Region__c in (';
                    }
                    for(FS_Tree_Province__mdt province : territoryProvinces){
                        resultFilter += '\'' + province.Label + '\',';
                    }
                    resultFilter = resultFilter.removeEnd(',');
                    resultFilter += ')';
                }
            } else {
                List<FS_Tree_Area__mdt> subTerritoryArea = [SELECT Id, Label, FS_Tree_Province__r.Label FROM FS_Tree_Area__mdt WHERE Id = :currentSubTerritoryId];
                if(subTerritoryArea.size() == 1){
                    resultFilter += ' Area__c = \'' + subTerritoryArea.get(0).Label + '\'' +
                            ' AND Region__c = \'' + subTerritoryArea.get(0).FS_Tree_Province__r.Label + '\'';
                }

                List<FS_Tree_Province__mdt> subTerritoryProvince = [SELECT Id, Label FROM FS_Tree_Province__mdt WHERE Id = :currentSubTerritoryId];
                if(subTerritoryProvince.size() == 1){
                    resultFilter += ' Region__c = \'' + subTerritoryProvince.get(0).Label + '\'';
                }
            }
            resultFilter += ')';
            if(resultFilter == ' AND ()'){ //Территория не имеет составных частей
                resultFilter = ' AND Region__c = \'EMPTY TERRITORY\'';
            }
        }
        if(listScoringSections.size() != 0){
            for(Integer i = 0; i <listScoringSections.size(); i++){
                if(listScoringSections.get(i).getValue() == currentSection){
                    if (listScoringSections.get(i).getValue().contains('-')) {
                        resultFilter += ' AND SummaryScoringRu__c >=' + listScoringSections.get(i).getValue().substringBefore('-') +
                                ' AND SummaryScoringRu__c <=' + listScoringSections.get(i).getValue().substringAfter('-');
                    }
                    break;
                }
            }
        }
        if(listRatingNewSections.size() != 0){
            for(Integer i = 0; i <listRatingNewSections.size(); i++){
                if(listRatingNewSections.get(i).getValue() == currentRatingNew){
                    if (listRatingNewSections.get(i).getValue().contains('-')) {
                        resultFilter += ' AND Rating_FS_New__c >=' + listRatingNewSections.get(i).getValue().substringBefore('-') +
                                ' AND Rating_FS_New__c <=' + listRatingNewSections.get(i).getValue().substringAfter('-');
                    }
                    break;
                }
            }
        }
        return resultFilter;
    }

    public List<SObject> getLeadRecords(Integer recordsLimit, String filter){
        return Database.query(
                'SELECT id, Name, INN__c, Industry, NumberOfEmployees, Number_of_Vehicles__c, Area__c, City, Street, Revenue_thousand_rub__c, ' +
                        'OwnerId, SummaryScoringRu__c, CreatedDate, Rating_FS_New__c' +
                        ' FROM Lead' +
                        ' WHERE RecordTypeId = :russianLeadRecordType' +
                        ' AND IsConverted = FALSE' +
                        ' AND Duplicate_Record_Mark__c = FALSE' +
                        ' AND (SummaryScoringRu__c = null OR SummaryScoringRu__c >= 0)' +
                        ' AND OwnerId NOT IN :excludeOwnerUserId' +
                        ' AND (' +
                        '        OwnerId in :leadsQueuesId OR' +
                        '        (Owner.Type = \'User\' AND' +
                        '           (' +
                        '               (Status = \'NEW - Not Yet Contacted\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays2+' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays2+' OR LastActivityDate = null) AND Open_Task__c = false) OR' +
                        '               (Status = \'Disqualified\' AND LastTransferDate < LAST_N_DAYS:'+calendarDays2+') OR' +
                        '               (Status = \'Waiting INN\' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays3+' OR LastActivityDate = null OR Date_of_Last_Status_Changing__c < LAST_N_DAYS:'+calendarDays10+' OR Date_of_Last_Status_Changing__c = null) AND Open_Task__c = false) OR' +
                        '               (Status in :leadStatusInProcess AND LastTransferDate < LAST_N_DAYS:'+calendarDays2+' AND (LastActivityDate < LAST_N_DAYS:'+calendarDays1+'  OR LastActivityDate = null) AND Open_Task__c = false)' +
                        '           )' +
                        '       )' +
                        ' )' +
                        filter +
                        ' ORDER BY SummaryScoringRu__c ' + sortGeneral +
                        ' LIMIT ' + recordsLimit);
    }

    /*******************************************************************************
    *  Name            : generateAdditionalFilterOpportunity()
    *  Summary         : function for get additional filter for Opportunity query
    *  Parameters      : -
    *  Returns         : String - filter string for Opportunity query, which add to "WHERE" section in main query
    ******************************************************************************/
    public String generateAdditionalFilterOpportunity(){
        String resultFilter = '';
        if(currentTerritoryId != null && currentSubTerritoryId != null){
            resultFilter = ' AND (';
            if(currentSubTerritoryId == '*'){
                Map<String, List<String>> areasInProvinces = new Map<String, List<String>>();
                List<FS_Tree_Area__mdt> areasOfTerritory = [
                        SELECT Id, Label, FS_Tree_Province__r.Label
                        FROM FS_Tree_Area__mdt
                        WHERE FS_Territory__r.Id = :currentTerritoryId
                ];
                for(FS_Tree_Area__mdt area: areasOfTerritory){
                    if(areasInProvinces.containsKey(area.FS_Tree_Province__r.Label)){
                        List<String> areas = areasInProvinces.get(area.FS_Tree_Province__r.Label);
                        areas.add(area.Label);
                        areasInProvinces.put(area.FS_Tree_Province__r.Label, areas);
                    } else {
                        areasInProvinces.put(area.FS_Tree_Province__r.Label, new List<String>{area.Label});
                    }
                }
                if(areasInProvinces.size() != 0){
                    for(String province : areasInProvinces.keySet()){
                        resultFilter += '( Account.Region__c = \'' + province + '\' AND Account.BillingArea__c in (';
                        for(String area: areasInProvinces.get(province)){
                            resultFilter += '\'' + area + '\',';
                        }
                        resultFilter = resultFilter.removeEnd(',');
                        resultFilter += ') )';
                    }
                }

                List<FS_Tree_Province__mdt> territoryProvinces = [
                        SELECT Id, Label
                        FROM FS_Tree_Province__mdt
                        WHERE FS_Territory__r.Id = :currentTerritoryId];
                if(territoryProvinces.size() != 0){
                    if(resultFilter == ' AND ('){
                        resultFilter += ' Account.Region__c in (';
                    } else {
                        resultFilter += ' OR Account.Region__c in (';
                    }
                    for(FS_Tree_Province__mdt province : territoryProvinces){
                        resultFilter += '\'' + province.Label + '\',';
                    }
                    resultFilter = resultFilter.removeEnd(',');
                    resultFilter += ')';
                }
            } else {
                List<FS_Tree_Area__mdt> subTerritoryArea = [SELECT Id, Label, FS_Tree_Province__r.Label FROM FS_Tree_Area__mdt WHERE Id = :currentSubTerritoryId];
                if(subTerritoryArea.size() == 1){
                    resultFilter += ' Account.BillingArea__c = \'' + subTerritoryArea.get(0).Label + '\'' +
                            ' AND Account.Region__c = \'' + subTerritoryArea.get(0).FS_Tree_Province__r.Label + '\'';
                }

                List<FS_Tree_Province__mdt> subTerritoryProvince = [SELECT Id, Label FROM FS_Tree_Province__mdt WHERE Id = :currentSubTerritoryId];
                if(subTerritoryProvince.size() == 1){
                    resultFilter += ' Account.Region__c = \'' + subTerritoryProvince.get(0).Label + '\'';
                }
            }
            resultFilter += ')';
            if(resultFilter == ' AND ()'){ //Территория не имеет составных частей
                resultFilter = ' AND Account.Region__c = \'EMPTY TERRITORY\'';
            }
        }
        if(listScoringSections.size() != 0){
            for(Integer i = 0; i <listScoringSections.size(); i++){
                if(listScoringSections.get(i).getValue() == currentSection){
                    if (listScoringSections.get(i).getValue().contains('-')){
                        resultFilter += ' AND Account.SummaryScoringRu__c >=' + listScoringSections.get(i).getValue().substringBefore('-') +
                                ' AND Account.SummaryScoringRu__c <=' + listScoringSections.get(i).getValue().substringAfter('-');
                    }
                    break;
                }
            }
        }
        if(listRatingNewSections.size() != 0){
            for(Integer i = 0; i <listRatingNewSections.size(); i++){
                if(listRatingNewSections.get(i).getValue() == currentRatingNew){
                    if (listRatingNewSections.get(i).getValue().contains('-')){
                        resultFilter += ' AND Account.Rating_FS_New__c >=' + listRatingNewSections.get(i).getValue().substringBefore('-') +
                                ' AND Account.Rating_FS_New__c <=' + listRatingNewSections.get(i).getValue().substringAfter('-');
                    }
                    break;
                }
            }
        }
        return resultFilter;
    }

    public List<SObject> getOpportunityRecords(Integer recordsLimit, String filter){
        return Database.query(
                ' SELECT id, Name, Account.INN__c, OwnerId, Account.Industry, Account.NumberOfEmployees, Number_of_Vehicles__c,' +
                        ' Account.SummaryScoringRu__c, Account.BillingArea__c, Account.BillingCity, Account.BillingStreet, Account.Rating_FS_New__c' +
                        ' FROM Opportunity' +
                        ' WHERE  Account.Moved_to_Start__c = 0' +
                        ' AND Account.Opportunity_Sum__c = 1' +
                        ' AND Account.ParentId = null'+
                        ' AND (Account.SummaryScoringRu__c = null OR Account.SummaryScoringRu__c >= 0)'+
                        ' AND OwnerId NOT IN :excludeOppOwnersId' +
                        ' AND (' +
                        '         (Probability = 0 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays2+' OR Last_Owner_Change_Date_RUS__c = null )) OR' +
                        '         (Probability = 10 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays3+'  OR Last_Owner_Change_Date_RUS__c = null ) AND Open_Task__c = false ) OR' +
                        '         (Probability = 5 AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays2+' OR Last_Owner_Change_Date_RUS__c = null ) AND Open_Task__c = false) OR' +
                        '         (Probability >= 30 AND Probability < 90 '+
                        '         AND (LastActivityDate < LAST_N_DAYS:30 OR LastActivityDate = null) AND Open_Task__c = false AND (Last_Owner_Change_Date_RUS__c < LAST_N_DAYS:'+calendarDays2+'  OR Last_Owner_Change_Date_RUS__c = null ))' +
                        ' )' +
                        filter +
                        ' ORDER BY Account.SummaryScoringRu__c ' + sortGeneral +
                        ' LIMIT '+ recordsLimit);
    }

    /*******************************************************************************
    *  Name            : getRecordOwnership()
    *  Summary         : allows user to get ownership of record from list. (based on parameter 'recordHashId')
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getRecordOwnership(){
        String recordHashId = ApexPages.currentPage().getParameters().get('recordHashId');
        if(recordHashId != null && recordHashId != ''){
            String recordId = decodeHashAlgorithmAES256(recordHashId);
            String SObjectType = Id.valueOf(recordId).getSobjectType().getDescribe().name;
            Boolean recordIsAppropriate = isRecordAppropriate(recordId, SObjectType);
            if(recordIsAppropriate){
                manualShareRecord(recordId, SObjectType);
                updateRecords(recordId, SObjectType);
                getRecordLink();
            } else {
                tabLink = '';
            }
        }
    }

    /*******************************************************************************
    *  Name            : isRecordAppropriate()
    *  Summary         : check function. Is record still appropriate to defined criteria?
    *  Parameters      : -
    *  Returns         : TRUE  - record is appropriate
    *                    FALSE - record is not appropriate
    ******************************************************************************/
    private Boolean isRecordAppropriate(Id recordId, String SObjectType){
        List<SObject> record;
        String additionalFilter = ' AND Id = \'' + recordId+'\'';
        if(SObjectType == 'Lead') {
            record = getLeadRecords(1, additionalFilter);
        }
        else if (SObjectType == 'Opportunity'){
            record = getOpportunityRecords(1, additionalFilter);
        }
        if(record.size() == 0){
            return false;
        } else {
            return true;
        }
    }

    /*******************************************************************************
    *  Name            : manualShareRecord()
    *  Summary         : Share record with user by special LeadShare and AccountShare object.
    *                    We grant access for Account(not Opportunity) because this is the most correct.
    *  Parameters      : recordId (Lead Id/Opportunity Id)
    *                    SObjectType (Lead/Opportunity)
    *  Returns         : -
    ******************************************************************************/
    private void manualShareRecord(Id recordId,String SObjectType){
        if(SObjectType == 'Lead'){
            LeadShare jobShare  = new LeadShare();
            jobShare.LeadId = recordId;
            jobShare.UserOrGroupId = currentUser;
            jobShare.LeadAccessLevel = 'Edit';
            jobShare.RowCause = Schema.LeadShare.RowCause.Manual;
            Database.SaveResult sr = Database.insert(jobShare, false);
            if(!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  && err.getMessage().contains('AccessLevel'))) {
                    ExceptionLogger.sendException(
                            'FieldSalesTerritoryCtrl manualShareRecord (Current User = '+currentUser+')(LeadId = '+recordId+')',
                            String.valueOf(sr.getErrors()[0]));
                }
            }
        } else if(SObjectType == 'Opportunity'){ // Share Opportunity && Account from AccountShare object
            List<Opportunity> currentOpportunities = [SELECT id, AccountId FROM Opportunity WHERE Id = :recordId];
            if(currentOpportunities.size() != 0){
                AccountShare jobShare  = new AccountShare();
                jobShare.AccountId = currentOpportunities.get(0).AccountId;
                jobShare.UserOrGroupId = currentUser;
                jobShare.AccountAccessLevel = 'Edit';
                jobShare.OpportunityAccessLevel = 'Edit';
                jobShare.RowCause = Schema.AccountShare.RowCause.Manual;
                Database.SaveResult sr = Database.insert(jobShare, false);
                if(!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  && err.getMessage().contains('AccessLevel'))) {
                        ExceptionLogger.sendException(
                                'FieldSalesTerritoryCtrl manualShareRecord (Current User = ' + currentUser + ')(AccountId = ' + currentOpportunities.get(0).AccountId + ')',
                                String.valueOf(sr.getErrors()[0]));
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateRecords()
    *  Summary         : update field for Lead/Account & Opportunity record after ownership was done
    *  Parameters      : recordId (Lead Id/Opportunity Id)
    *                    SObjectType (Lead/Opportunity)
    *  Returns         : -
    ******************************************************************************/
    private void updateRecords(Id recordId, String SObjectType){
        if(SObjectType == 'Lead'){
            List<Lead> recordToChangeOwner = [SELECT Id, OwnerId FROM Lead WHERE Id = :recordId];
            if(recordToChangeOwner.size() != 0){
                Lead lead = new Lead(Id = recordToChangeOwner.get(0).Id, OwnerId = currentUser, Status = 'NEW - Not Yet Contacted');
                update lead;
            }
        }
        else if (SObjectType == 'Opportunity'){
            List<Opportunity> recordToChangeOwner = [SELECT Id, OwnerId, AccountId, Account.OwnerId FROM Opportunity WHERE Id = :recordId];
            if(recordToChangeOwner.size() != 0){
                List<SObject> listToUpdate = new List<SObject>();
                listToUpdate.add(new Opportunity(Id = recordToChangeOwner.get(0).Id, OwnerId = currentUser, StageName = 'Qualified Lead', CloseDate = System.today().addDays(60)));
                listToUpdate.add(new Account(Id = recordToChangeOwner.get(0).AccountId, OwnerId = currentUser));
                update listToUpdate;
            }

        }
    }

    /*******************************************************************************
    *  Name            : getRecordLink()
    *  Summary         : generate link to open new browser tab for Record. (based on parameter 'recordHashId')
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getRecordLink(){
        String recordHashId = ApexPages.currentPage().getParameters().get('recordHashId');
        if(recordHashId != null && recordHashId != ''){
            String recordId = decodeHashAlgorithmAES256(recordHashId);
            List<UserRecordAccess> recordAccesses = [
                    SELECT HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess,  MaxAccessLevel, RecordId
                    FROM UserRecordAccess
                    WHERE RecordId = :recordId
                    AND UserId = :currentUser
            ];
            if(recordAccesses.size() != 0){
                if(recordAccesses.get(0).HasReadAccess == TRUE){
                    tabLink = '/'+recordId;
                }
            } else {
                tabLink = '';
            }
        }
    }

    /*******************************************************************************
    *  Name            : sortListByColumn()
    *  Summary         : sort current list of record by chosen field
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void sortListByColumn(){
        String columnName = ApexPages.currentPage().getParameters().get('sortColumn');
        if(columnName != null){
            column1Sort = columnName;
            if(sortGeneral == 'ASC'){
                sortGeneral = 'DESC';
            } else {
                sortGeneral = 'ASC';
            }
            startFirstPage();
        }
    }

    /*******************************************************************************
    *  Name            : refreshPageInformation()
    *  Summary         : refresh record list information on the page
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void refreshPageInformation(){
        generateTotalRecordsList();
        startFirstPage();
    }

    /*******************************************************************************
    *  Name            : changeTerritory()
    *  Summary         : execute when user change Territory ComboBox
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void changeTerritory(){
        prepareListSubTerritories();
        prepareListScoringSections();
        refreshPageInformation();
    }

    /*******************************************************************************
    *  Name            : changeTerritory()
    *  Summary         : execute when user change Territory ComboBox
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void changeSubTerritory(){
        refreshPageInformation();
    }

    /*******************************************************************************
    *  Name            : changeScoringSection()
    *  Summary         : execute when user change ScoringSection ComboBox
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void changeScoringSection(){
        refreshPageInformation();
    }

    /*******************************************************************************
    *  Name            : convertPastBusinessDaysToCalendar()
    *  Summary         : Convert past business days to calendar days
    *  Parameters      : Integer businessDays - number of business days which have passed
    *  Returns         : Integer returnValue - number of calendar days which have passed (calculated from business days)
    ******************************************************************************/
    private Integer convertPastBusinessDaysToCalendar(Integer businessDays){
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
    *  Name            : prepareTotalSortedRecordsList()
    *  Summary         : sort total list of record and get fixed amount of "Top" records.
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void prepareTotalSortedRecordsList(){
        Schema.DisplayType fieldType;
        try {
            fieldType = Schema.SObjectType.Lead.fields.getMap().get(column1Sort).getDescribe().getType();
        } catch (Exception e) {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
        }
        if (fieldType != null) {
            sObjectsFullListSorted = new List<FieldSalesTerritoryWrapper>();
            for(SObject sObj : sObjectsFullList){
                sObjectsFullListSorted.add(
                        new FieldSalesTerritoryWrapper(sObj, getHashAlgorithmAES256(String.valueOf(sObj.get('Id'))), column1Sort, fieldType, sortGeneral)
                );
            }
            sObjectsFullListSorted.sort();
            Integer listSize = sObjectsFullListSorted.size();
            for(Integer i = listSize-1; i >=numberRecordsPerPage; i--){
                sObjectsFullListSorted.remove(i);
            }
        }
    }

    /*  public void getManagerEventTime(Id managerId){
      Map<Datetime, Datetime> availableManagerEventTime = new Map<Datetime, Datetime>();
      availableManagerEventTime.put(system.now().addHours(5), system.now().addHours(7));

      List<Event> eventList = [
              SELECT StartDateTime, EndDateTime, Id, AccountId, ActivityDate, ActivityDateTime, DurationInMinutes,
                      Event_Status__c, IsAllDayEvent, OwnerId, Task_FS__c, WhatId
              FROM Event
              WHERE OwnerId = :managerId and StartDateTime = NEXT_N_DAYS:5
      ];

      for(Event event : eventList){
          for(Datetime managerStartEvent : availableManagerEventTime.keySet()){
              if( managerStartEvent <= event.StartDateTime && availableManagerEventTime.get(managerStartEvent) >= event.StartDateTime){
                  availableManagerEventTime.remove(managerStartEvent);
              }
              else  if(event.StartDateTime <= managerStartEvent && event.StartDateTime <= availableManagerEventTime.get(managerStartEvent) &&
                      event.EndDateTime >= managerStartEvent && event.EndDateTime >= availableManagerEventTime.get(managerStartEvent)){
                  availableManagerEventTime.remove(managerStartEvent);
              }
              else  if( managerStartEvent <= event.EndDateTime && availableManagerEventTime.get(managerStartEvent) >= event.EndDateTime){
                  availableManagerEventTime.remove(managerStartEvent);
              }
          }
      }
    }*/

    //----------- PAGINATION BLOCK START-------------------
    public Integer totalSize {
        get {
            return this.sObjectsFullListSorted.size();
        }
        private set;
    }

    public Integer totalPages {
        get {
            return Integer.valueOf((Decimal.valueOf(this.totalSize) / Decimal.valueOf(this.pageSize)).round(RoundingMode.UP));
        }
        private set;
    }

    public List<SelectOption> pageSizes {
        get {
            return new List<SelectOption>{
                    new SelectOption('10', '10'),
                    new SelectOption('25', '25'),
                    new SelectOption('50', '50'),
                    new SelectOption('100', '100')
            };
        }
        set;
    }

    public Integer pageSize {
        get {
            if (this.pageSize == null) return Integer.valueOf(pageSizes.get(0).getValue());
            return this.pageSize;
        }
        set {
            this.pageSize = Integer.valueOf(value);
        }
    }

    public Integer pageNumber {
        get {
            if (this.pageNumber == null) return 1;
            return this.pageNumber;
        }
        set;
    }

    public Boolean isPreviousDisabled {
        get {
            return !CustomPagination.hasPrevious(this.pageNumber, this.pageSize);
        }
        private set;
    }

    public Boolean isNextDisabled {
        get {
            return !CustomPagination.hasNext(this.pageNumber, this.pageSize, this.totalSize);
        }
        private set;
    }

    public void startFirstPage() {
        prepareTotalSortedRecordsList();
        this.sObjectsList.clear();
        this.pageNumber = 1;
        for (Object record : CustomPagination.first(sObjectsFullListSorted, this.pageSize)) {
            this.sObjectsList.add((FieldSalesTerritoryWrapper) record);
        }
    }

    public void lastPage() {
        if (isNextDisabled)
            return;

        this.sObjectsList.clear();
        this.pageNumber = totalPages;

        for (Object record : CustomPagination.last(sObjectsFullListSorted, this.pageNumber, this.pageSize)) {
            this.sObjectsList.add((FieldSalesTerritoryWrapper) record);
        }
    }

    public void nextPage() {
        if (isNextDisabled)
            return;

        this.sObjectsList.clear();
        this.pageNumber++;

        for (Object record : CustomPagination.next(sObjectsFullListSorted, this.pageNumber, this.pageSize)) {
            this.sObjectsList.add((FieldSalesTerritoryWrapper) record);
        }
    }

    public void previousPage() {
        if (isPreviousDisabled)
            return;

        this.sObjectsList.clear();
        this.pageNumber--;

        for (Object record : CustomPagination.previous(sObjectsFullListSorted, this.pageNumber, this.pageSize)) {
            this.sObjectsList.add((FieldSalesTerritoryWrapper) record);
        }
    }
    //----------- PAGINATION BLOCK END -------------------

    //----------- ENCRYPTED BLOCK START -----------------

    /*******************************************************************************
    *  Name            : getHashAlgorithmAES256()
    *  Summary         : return hash string
    *  CreatedDate     : 28/02/2018
    *  Parameters      : inputString - string for hashing
    *                    keyAES256 - key from encrypt
    *  Returns         : String
    ******************************************************************************/
    @TestVisible
    private String getHashAlgorithmAES256(String inputString) {
        Blob source = Blob.valueOf(inputString);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(keyAES256), source);
        String encryptedHash = EncodingUtil.base64Encode(encrypted);
        encryptedHash = encryptedHash.replace('+','%2B');
        return encryptedHash;
    }


    /*******************************************************************************
    *  Name            : decodeHashAlgorithmAES256()
    *  Summary         : return decode string (algoritm AES256)
    *  CreatedDate     : 28/02/2018
    *  Parameters      : inputString - string for decode
    *                    keyAES256 - key from decrypt
    *  Returns         : String
    ******************************************************************************/
    private String decodeHashAlgorithmAES256(String inputString) {
        inputString = inputString.replace('%2B','+');
        Blob dest = EncodingUtil.base64Decode(inputString);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', Blob.valueOf(keyAES256), dest);
        String decryptedText = decrypted.toString();
        return decryptedText;
    }
    //----------- ENCRYPTED BLOCK END -----------------
}