global class LeadRelocationBatch implements Database.Batchable<sObject> {
    private static String REGIONS = 'regions';
    private static String RU = 'ru';
    private static String EU = 'eu';
    private static String NAME = 'name';
    private static String L_R_COUNTRIES = 'LeadRelocationCountries';
    
    public String query;
    public Date myDate;
    private Set<String> RWLlistid = new Set<String>();
    private Datetime correctDatetime;
    private Id russianQueueId;
    private Boolean euEnabled = (LeadRelocationSettings__c.getInstance() == null ? true : LeadRelocationSettings__c.getInstance().EU_Enabled__c);
    private Set<String> countriesSet = new Set<String>();

    global LeadRelocationBatch() {
        this.query = '';
        Boolean ExecuteJobInBerlin = false;
        Boolean ExecuteJobInMoscow = false;

        Datetime GMTDate = Datetime.newInstanceGmt(
                datetime.now().yearGmt(), datetime.now().monthGmt(), datetime.now().dayGmt(),
                datetime.now().hourGmt(), datetime.now().minuteGmt(), 0);
        Integer HourBerlin = Integer.valueOf(GMTDate.format('HH', 'Europe/Berlin'));
        Integer HourMoscow = Integer.valueOf(GMTDate.format('HH', 'Europe/Moscow'));

        if ((HourBerlin >= 8) && (HourBerlin <= 17)) ExecuteJobInBerlin = true;
        if ((HourMoscow >= 8) && (HourMoscow <= 17)) ExecuteJobInMoscow = true;
        if (Test.isRunningTest()) {
            ExecuteJobInBerlin = true;
            ExecuteJobInMoscow = true;
        }

        setCountriesFromResource();

        if (ExecuteJobInBerlin || ExecuteJobInMoscow) {
            this.query = 'SELECT Owner.Email, Status, CreatedDate, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Channel__c,' +
                    '       LeadSource, Country, Salutation, CountryCode, RecordType.Name, Is_External__c, Lead_Source_type__c, Anzahl_der_Fahrzeuge__c, CCS_number_of_cards__c, ' +
                    '       Recycle_counter__c, Quali_Status__c, ' +
                    '       (SELECT OldValue, NewValue FROM Histories WHERE Field = \'Quali_Status__c\') ' +
                    'FROM Lead ' +
                    'WHERE  isConverted = FALSE AND ' +
                    '       Last_Owner_Change_Date__c != NULL AND ' +
                    '       Country IN :countriesSet  AND ' +
                    '       RecordType.Name NOT IN (\'CCS Sales process\', \'Lotos\') AND ' +
                    '       (Recycle_counter__c = 0 OR Recycle_counter__c = null) AND ' +
                    '(';
            if (ExecuteJobInBerlin) {
                myDate = date.newinstance(2016, 3, 30);
                this.query +=
                        '   ( ' +
                                '     ((Sec_Channel__c = \'Inbound\' AND (Channel__c = \'Internet\' OR Channel__c = \'E-mail\')) OR ' +
                                '      (Sec_Channel__c = \'JITB\' AND Channel__c = \'Internet\') OR (Sec_Channel__c = \'Partner\')) AND ' +
                                '       Status = \'Open\'  AND ' +
                                '       First_Call__c = NULL AND ' +
                                '       LeadSource != \'Online_chat\' AND ' +
                                '       CreatedDate >= :myDate ' +
                                '   ) OR';
            }
            if (ExecuteJobInMoscow) {
                RWLlistid.clear();
                List<Group> russianQueue = [
                        SELECT Id
                        FROM Group
                        WHERE Name = 'Russian Web Leads'
                ];
                if (!russianQueue.isEmpty()) {
                    RWLlistid.add(russianQueue.get(0).Id);
                    russianQueueId = russianQueue.get(0).Id;
                }
                for (GroupMember gm : [Select UserOrGroupId From GroupMember where Group.name = 'Russian Web Leads']) {
                    RWLlistid.add(gm.UserOrGroupId);
                }
                correctDatetime = System.now().addMinutes(-9);
                this.query +=
                        '   ( ' +
                                '        OwnerId IN :RWLlistid AND ' +
                                '        Status = \'NEW - Not Yet Contacted\' AND ' +
                                '       (Last_Owner_Change_Date__c <= :correctDatetime OR OwnerId = :russianQueueId ) AND ' +
                                '       (Lead_Source_Type__c = \'Webform\' OR Lead_Source_Type__c = \'Popup\' OR ' +
                                '        Lead_Source_Type__c = \'Chat\'    OR Lead_Source_Type__c = \'Email\') ' +
                                '   ) ';
            }
            this.query = this.query.removeEnd('OR');
            this.query += ') ';
        } else {
            this.query = 'SELECT id,name FROM Lead WHERE id=\'0BLANKIDBLANKID\'';
        }

        System.debug('HERE ' + this.query);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        LeadRelocationService.customLeadAssignBatch(scope);
        LeadHandler.isSwitchToE2E = false;

        List<SObject> objectsToUpdate = new List<SObject>();

        Map<Id, SObject> mapSObjects = new Map<Id, SObject>();

        System.debug(scope.size());
        System.debug(scope.get(0).get('Id') + ' ' + scope.get(0).get('Status'));

        for (SObject lead : scope) {
            mapSObjects.put(Id.valueOf(String.valueOf(lead.get('Id'))), lead);
        }

        List<Lead> leadsToCheck = [SELECT Id, Status FROM Lead WHERE Id IN :mapSObjects.keySet()];
        for(Lead lead : leadsToCheck) {
            if(lead.Status != mapSObjects.get(lead.Id).get('Status')) {
                mapSObjects.remove(lead.Id);
            }
        }

        update mapSObjects.values();
    }

    global void finish(Database.BatchableContext BC) {
    }

    public void setCountriesFromResource() {
        StaticResource countriesResource = [
            SELECT Body 
            FROM StaticResource 
            WHERE Name =: L_R_COUNTRIES
            LIMIT 1
        ];
        Map<String, Object> countriesMap = (Map<String, Object>) JSON.deserializeUntyped(countriesResource.Body.toString());

        if (countriesMap.containsKey(REGIONS)) {
            Map<String, Object> regionsMap = (Map<String, Object>)countriesMap.get(REGIONS);
            
            if (regionsMap.containsKey(RU)) {
                countriesSet.addAll(getNamesFromRegions(regionsMap, RU));
            }

            if (euEnabled && regionsMap.containsKey(EU)) {
                countriesSet.addAll(getNamesFromRegions(regionsMap, EU));
            }
        }
    }

    private List<String> getNamesFromRegions(Map<String, Object> regionsMap, String region) {
        List<String> countries = new List<String>();
        List<Object> regionCountries = (List<Object>)regionsMap.get(region);

        if (regionCountries != null && !regionCountries.isEmpty()) {
            for (Object regionCountry : regionCountries) {
                Map<String, object> mapValue = (Map<String, Object>)regionCountry;
                countries.add((String)mapValue.get(NAME));
            }
        }

        return countries;
    }
}