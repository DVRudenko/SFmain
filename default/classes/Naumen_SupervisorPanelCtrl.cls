public without sharing class Naumen_SupervisorPanelCtrl {
    public Map<String, String> sObjTypes { // sObj types allowed to select on the Supervisor Panel page
        get {
            if (sObjTypes == null) {
                String leadsLabelPlural = Schema.Lead.sObjectType.getDescribe().getLabelPlural();
                String oppsLabelPlural = Schema.Opportunity.sObjectType.getDescribe().getLabelPlural();
                sObjTypes = new Map<String, String> ();
                sObjTypes.put('Lead', leadsLabelPlural);
                sObjTypes.put('Opportunity', oppsLabelPlural);
            }
            return sObjTypes;
        } set;
    }

    public Lead lead { // ru lead record to get picklist values for certain Record type ('Russian_Sales') on the side of VF page
        get {
            if (lead == null) {
                String lead_ruRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
                this.lead = new Lead (RecordTypeId = lead_ruRTId, Status = 'Disqualified');
            }
            return lead;
        } set;
    }

    public Opportunity opp { // ru opportuntiy record to get picklist values for certain Record type ('Russian_Sales') on the side of VF page
        get{
            if (opp == null) {
                String opp_ruRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Russian_Sales').getRecordTypeId();
                this.opp = new Opportunity (RecordTypeId = opp_ruRTId, StageName = 'Отказ');
            }
            return opp;
        } set;
    }

    public Account acc { // ru account record to get picklist values for certain Record type ('Russian') on the side of VF page
        get{ 
            if (acc == null) {
                String acc_ruRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Russian').getRecordTypeId();
                this.acc = new Account (RecordTypeId = acc_ruRTId);
            }
            return acc;
        } set;
    }

    public class SetupData { // predefined on the page params before getting picklists data (such as selected sObject types)
        public OptionsParams optionsParams;
        public String errMsg;

        public Map<String, String> naumenProjects;
        public Map<String, String> promocodes;
        public Map <String, String> statuses;
        public Map<String, String> regions;
        public Map<String, String> leadSourses;
        
        public SetupData (OptionsParams optionsParams) {
            this.optionsParams = optionsParams;
            getOptions_naumenProjects ();
            getOptions_promocodes ();
            getOptions_statuses ();
            getOptions_regions ();
            getOptions_leadSourses ();
        }
        private void getOptions_naumenProjects () {
            naumenProjects = new Map<String, String>();
            Map<String, Naumen_Projects__c> naumenProjectsSettings = Naumen_Projects__c.getAll();
            if (!naumenProjectsSettings.isEmpty()) {
                for (String projName : naumenProjectsSettings.keySet()) {
                    Naumen_Projects__c proj = naumenProjectsSettings.get(projName);
                    naumenProjects.put(proj.Project_UUID__c, proj.Project_Label__c);
                }
            }
        }
        private void getOptions_promocodes () {
            promocodes = new Map<String, String>();
            Map<String, Promo_Codes_Ru__c> promocodesSettings = Promo_Codes_Ru__c.getAll();
            if (!promocodesSettings.isEmpty()) {
                for (String promocode : promocodesSettings.keySet()) {
                    promocodes.put(promocode, promocode);
                }
            }
        }
        private void getOptions_statuses () {
            statuses = new Map <String, String>();
            if(Test.isRunningTest()) return;
            try {
                if (optionsParams.showLeadsData) {
                    Map <String, String> leadStatuses = MetadataServiceConnector.getStandardPicklistTranslations ('LeadStatus-ru');
                    for (String leadStatus : leadStatuses.keySet()) {
                        String transl = leadStatuses.get(leadStatus);
                        statuses.put(leadStatus, transl);
                    }
                }
                if (optionsParams.showOppsData) {
                    Map <String, String> oppStages = MetadataServiceConnector.getStandardPicklistTranslations ('OpportunityStage-ru');
                    for (String oppStage : oppStages.keySet()) {
                        String transl = oppStages.get(oppStage);
                        statuses.put(oppStage, transl);
                    }
                }
            } catch (CalloutException ex) { // don't show error message to the user if the user doesn't have access to Metadata API
                return;
            } catch (Exception ex) { // show error message to the user
                String errMsg = ex + '---' + ex.getMessage() + ' :: ' + ex.getStackTraceString();
                system.debug('Exception! :: '+ errMsg);
                this.errMsg = errMsg;
                return;
            } 
        }
        private void getOptions_regions () {
            regions = new Map<String, String>();
            for(FS_Tree_Province__mdt region : [SELECT Id, Label FROM FS_Tree_Province__mdt ORDER BY Label ASC]){
                regions.put(region.Label, region.Label);
            }
        }
        private void getOptions_leadSourses () {
            leadSourses = new Map<String, String>();
            if (optionsParams.showLeadsData) {
                List<Schema.PicklistEntry> picklistValues_Lead = GlobalUtils.getPicklistValues (Schema.Lead.sObjectType, 'Source_of_Lead__c');
                if (!picklistValues_Lead.isEmpty()) {
                    for (Schema.PicklistEntry picklistEntry : picklistValues_Lead) {
                        leadSourses.put(picklistEntry.getValue(), picklistEntry.getLabel());
                    }
                }
            }
        }
    }
    public class OptionsParams { // predefined on the page params before getting picklists data (such as selected sObject types)
        public Boolean showLeadsData;
        public Boolean showOppsData;
    }
    /*******************************************************************************
    *  Name            : getSetupData
    *  Summary         : get data for filling in certain picklist values while initiating the Naumen Supervisor Panel
    *  Parameters      : String optionsParamsJSON - predefined on the page params before getting picklists data (such as selected sObject types)
    *  Returns         : Map<String,Object>: result attribute name => result attribute value
    ******************************************************************************/  
    @RemoteAction
    public static Map<String,Object> getSetupData (String optionsParamsJSON) {
        try {
            OptionsParams optionsParams = (OptionsParams)JSON.deserialize(optionsParamsJSON, OptionsParams.class);
            SetupData setupData = new SetupData (optionsParams);
            if (setupData.errMsg != null) {
                return new Map<String,Object>{'status'=>'error', 'message'=>setupData.errMsg};
            }
            return new Map<String,Object>{'status'=>'ok', 'setupData'=>setupData};
        } catch (Exception ex) {
            String errMsg = ex.getMessage() + ' :: ' + ex.getStackTraceString();
            system.debug('Exception! :: '+ errMsg);
            return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
        }
    }
// ==================== SELECTED FILTERS BY SUPERVISOR =========================== 
    public class SelectedFilters { // filters to query sObject records selected in Supervisor Panel (sObj types, sObj fields) + params for uploading the records (such as project UUID, CCSpeedUp check)
        public List<String> sObjTypes {get;set;}
        public List<String> regions {get;set;}
        public List<String> statuses {get;set;}
        public List<String> orgTypes {get;set;}
        public List<String> leadSourses {get;set;}
        public List<String> disqualReasons {get;set;}
        public List<String> promocodes {get;set;}
        public List<String> industries {get;set;}
        public List<String> excludedNaumenProjects {get;set;}
        public Double expectedVolume_from {get;set;}
        public Double expectedVolume_to {get;set;}
        public Double ratingFSNew_from {get;set;}
        public Double ratingFSNew_to {get;set;}
        public Double ratingFS_from {get;set;}
        public Double ratingFS_to {get;set;}
        public Boolean checkRecordAccess {get;set;}
        public List<String> projectUUID {get;set;}
    }

// ==================== PREVIEW ===========================  
    public class PreviewDataList { // list of preview data tables (for each sObject type)
        public String tablesHTML {get{
                                        if(tablesHTML == null) tablesHTML = createTablesHTML();
                                        return tablesHTML;
                                 } set;}
        public List <PreviewData> tablesList;
        public PreviewDataList () {
            this.tablesList = new List <PreviewData> ();
        }
        private String createTablesHTML () {
            String dataListHTML = '';
            for (PreviewData previewData : tablesList) {
                dataListHTML += '<div>' + previewData.previewDataHTML + '</div>';
            }
            return dataListHTML;
        }
    }
    public class PreviewData { // data for the preview table on the Supervisor Panel page
        public String previewDataHTML {get{
                                            if(previewDataHTML == null) previewDataHTML = createPreviewDataHTML();
                                            return previewDataHTML;
                                      } set;}
        public String title;
        public List <String> previewHeaders;
        public List <PreviewRow> previewRows;
        public PreviewData (String sObjType, Integer numberOfRecords) {
            this.title = sObjType == 'Lead' ? Label.NaumenSupervisor_numberOfLeads + ': ' + numberOfRecords
                       : sObjType == 'Opportunity' ? Label.NaumenSupervisor_numberOfOpportunities+ ': ' + numberOfRecords
                       : '';
            this.previewHeaders = new List <String> ();
            this.previewRows = new List <PreviewRow> ();
        }
        private String createPreviewDataHTML () {
            return '<table class="table table-hover"><thead>'+createHeadersHTML()+'</thead>' + '<tbody>'+createRowsHTML()+'</tbody></table>';
        }
        private String createHeadersHTML () {
            String headersHTML = '<tr><th colspan="'+previewHeaders.size()+'">' + title + '</th></tr>';
            headersHTML += '<tr><th>' + String.join(previewHeaders,'</th><th>') + '</th></tr>';
            return headersHTML;
        }
        private String createRowsHTML () {
            String rowsHTML = '';
            for (PreviewRow previewRow : previewRows) {
                rowsHTML += '<tr>' + previewRow.rowHTML + '</tr>';
            }
            return rowsHTML;
        }
    }
    public class PreviewRow { // row of the table containing data of 1 sObject record
        public String rowHTML {get{
                                    if (rowHTML == null) rowHTML = createRowHTML();
                                    return rowHTML;
                              } set;}
        public List <String> previewFieldValues;
        public PreviewRow  () {
            this.previewFieldValues = new List <String> ();
        }
        private String createRowHTML () {
            return '<td>' + String.join(previewFieldValues,'</td><td>') + '</td>';
        }
    }
    /*******************************************************************************
    *  Name            : getPreviewData
    *  Summary         : this method returns to the Supervisor Panel page table data to show preview of the records found by filters
    *  Parameters      : String filtersJSON - filters selected in Supervisor Panel to query sObject records, stringified to JSON format
    *  Returns         : Map<String,Object>: result attribute name => result attribute value
    ******************************************************************************/  
    @RemoteAction
    public static Map<String,Object> getPreviewData (String filtersJSON) {
        Map<String,Object> ret = new Map<String,Object> ();
        Map <String, String> queriesMap;
        try {
            SelectedFilters selectedFilters = (SelectedFilters)JSON.deserialize(filtersJSON, SelectedFilters.class);
            queriesMap = createQueriesMap(selectedFilters);

        // 1) get numbers of records
            Map <String, Integer> numberOfrecords = getNumberOfRecords(queriesMap);
            
        // 2) create preview data
            PreviewDataList previewDataList = new PreviewDataList (); // list of preview data for each sObject type
           
            for (String sObjType : queriesMap.keySet()) {
                if (sObjType.indexOf('_count') != -1) continue;  
            // get table data         
                Naumen_RecordsHelper.RecordsTableParams recordsTableParams = createTableRecordsParams(sObjType);
            // query sObjects list  
                List <String> fieldsToQuery = recordsTableParams.getFieldsToQueryRecords();
                String query = queriesMap.get(sObjType);
                Integer whereNum = query.indexOf(' WHERE');
                String endQuery = query.substring(whereNum, query.length());
                endQuery += ' ORDER BY LastModifiedDate DESC LIMIT 50';
            // get table data
                Naumen_RecordsHelper.RecordsTableData recordsTableData = new Naumen_RecordsHelper.RecordsTableData(recordsTableParams);
                List <sObject> sObjList = Database.query('SELECT ' + String.join(fieldsToQuery, ',') + ' FROM ' + sObjType + endQuery);
                recordsTableData.addRowsMap (sObjList);
             // create preview data
                PreviewData previewData = new PreviewData (sObjType, numberOfRecords.get(sObjType+'_count')); // preview data for the sobj type
                // create table headers
                previewData.previewHeaders = recordsTableData.headersList;
                // create table rows data
                for (Id sObjId : recordsTableData.rowsMap.keySet()) {
                    PreviewRow previewRow = new PreviewRow ();
                    previewRow.previewFieldValues = recordsTableData.rowsMap.get(sObjId); // get column values of the current record
                    previewData.previewRows.add(previewRow); // add current record row to the table for the current sObjtype
                }
                previewDataList.tablesList.add(previewData); // add preview data for the current sObject Type to the Preview data list
            }
            return new Map<String,Object>{'status'=>'ok', 'tablesHTML'=>previewDataList.tablesHTML};
        } catch (Exception ex) {
            String errMsg = ex.getMessage() + ' :: ' + ex.getStackTraceString() + '---' + queriesMap;
            system.debug('Exception! :: '+ errMsg);
            return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
        }
    }
// ==================== UPLOAD TO EXCEL ===========================
    /*******************************************************************************
    *  Name            : uploadToExcel
    *  Summary         : this method starts a batch which is building a csv file from fields data on the SF records (optionally using CCSpeedUp check)
    *  Parameters      : String filtersJSON - filters selected in Supervisor Panel to query sObject records, stringified to JSON format
    *  Returns         : Map<String,Object>: result attribute name => result attribute value
    ******************************************************************************/    
    @RemoteAction
    public static Map<String,Object> uploadToExcel (String filtersJSON) {
        Map<String,Object> ret = new Map<String,Object> ();
        try {
            SelectedFilters selectedFilters = (SelectedFilters)JSON.deserialize(filtersJSON, SelectedFilters.class);
            Map <String, String> queriesMap = createQueriesMap(selectedFilters); // queries map by sObjtype
            Map <String, Integer> numberOfrecords = getNumberOfRecords(queriesMap); // sObjtype => number of records
            // check number of records
            Integer allRecordsCount = 0;
            for (String sObjType_count : numberOfrecords.keySet()) {
                allRecordsCount += numberOfrecords.get(sObjType_count);
            }
            if (allRecordsCount == 0) {
                return new Map<String,Object>{'status'=>'error', 'message'=>Label.Naumen_notifMsg_NoRecordsFound};
            }
            // run batch job to create csv for every sObject type
            for (String sObjType : queriesMap.keySet()) {
                if (sObjType.indexOf('_count') != -1) continue;
                if (numberOfrecords.get(sObjType+'_count') == 0) continue;
                // get table params         
                Naumen_RecordsHelper.RecordsTableParams recordsTableParams = createTableRecordsParams(sObjType);
                // get endQuery param
                String query = queriesMap.get(sObjType);
                Integer whereNum = query.indexOf(' WHERE');
                String endQuery = query.substring(whereNum, query.length());
                endQuery += ' ORDER BY LastModifiedDate DESC ';
                // get email params
                String emailReceiversString = Naumen_RecordsHelper.naumenSettings.UploadResultsRecievers_Emails__c;
                List <String> emailRecievers = Naumen_RecordsHelper.getNaumenEmailRecievers(emailReceiversString);
                EmailTemplate uploadEmailTemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Naumen_SupervisorUploadExcelResult'];
                String emailSubject = uploadEmailTemplate.Subject;
                String emailBody = uploadEmailTemplate.Body;
                String fileName = 'supervisorupload_'+sObjType+'_'+ system.now().format('dd_MM_yyyy_HH_mm')+'.csv';
                // execute batch
                if (!Test.isRunningTest()) {
                    CreateCSVBatch  batch = new CreateCSVBatch (recordsTableParams, endQuery, selectedFilters.checkRecordAccess, true, emailRecievers, emailSubject, emailBody, fileName);
                    if (query != null) Database.executeBatch(batch, 1);
                }
            }
            return new Map<String,Object>{'status'=>'ok'};
        } catch (Exception ex) {
            String errMsg = ex.getMessage() + ' :: ' + ex.getStackTraceString();
            system.debug('Exception! :: '+ errMsg);
            return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
        }
    }
// ==================== UPLOAD TO NAUMEN ===========================
    /*******************************************************************************
    *  Name            : uploadToNaumen
    *  Summary         : this method sends request to Naumen REST API to create Naumen cases in Naumen project for selected sObject records (optionally using CCSpeedUp check)
    *  Parameters      : String filtersJSON - filters selected in Supervisor Panel to query sObject records, stringified to JSON format
    *  Returns         : Map<String,Object>: result attribute name => result attribute value
    ******************************************************************************/
    @RemoteAction
    public static Map<String,Object> uploadToNaumen (String filtersJSON) {
        Map<String,Object> ret = new Map<String,Object> ();
        try {
            SelectedFilters selectedFilters = (SelectedFilters)JSON.deserialize(filtersJSON, SelectedFilters.class);
             Map <String, String> queriesMap = createQueriesMap(selectedFilters);
            for (String sObjType : queriesMap.keySet()) {
                if (sObjType.indexOf('_count') != -1) continue;
                String query = queriesMap.get(sObjType);
                if (!Test.isRunningTest()) {
                    system.debug('executeBatch Naumen_Upload: ' + sObjType);
                    if (query != null) Database.executeBatch(new Naumen_UploadRecordsBatch(sObjType, query, selectedFilters.checkRecordAccess, selectedFilters.projectUUID[0]), 1);
                }
            }
            return new Map<String,Object>{'status'=>'ok'};
        } catch (Exception ex) {
            String errMsg = ex.getMessage() + ' :: ' + ex.getStackTraceString();
            system.debug('Exception! :: '+ errMsg);
            return new Map<String,Object>{'status'=>'error', 'message'=>errMsg};
        }
    }
   
// ======================= QUERIES ===========================================
    /*******************************************************************************
    *  Name            : getNumberOfRecords
    *  Summary         : queries number of records found in SF by filters selected in Supervisor Panel
    *  Parameters      : Map <String, String> queriesMap - map of queries which contains query for each sObject type to get number of records 
    *  Returns         : Map <String, String> - query type (with sObject type) => number of records
    ******************************************************************************/
    private static Map <String, Integer> getNumberOfRecords (Map <String, String> queriesMap) {
        Map <String, Integer> numberOfrecords = new Map <String, Integer> ();
        
        for (String sObjType : queriesMap.keySet()) {
            String query = queriesMap.get(sObjType);
            if (query == null) numberOfrecords.put(sObjType, 0); // 0 records found if filters are empty
            else if (sObjType.indexOf('_count') != -1) { // query for getting number of the records
                Integer recordsCount = Database.countQuery(queriesMap.get(sObjType));
                numberOfrecords.put(sObjType, recordsCount);  
            }
        }
        return numberOfrecords;
    }
    /*******************************************************************************
    *  Name            : createQueriesMap
    *  Summary         : creates a map of queries by sobject types. These queries are used to look for Lead/Opportunity records on Supervisor Panel by selected filters
    *  Parameters      : SelectedFilters selectedFilters - wrapper containing all selected on Supersisor Panel filters data
    *  Returns         : Map <String, String> - query type => query string
    ******************************************************************************/
    private static Map <String, String> createQueriesMap (SelectedFilters selectedFilters) {        
        Map <String, String> queriesMap = new Map <String, String>(); // query type (with sObjecttype) => query string

        for (String sObjType : selectedFilters.sObjTypes) { // create query with selected filters conditions for each sObject type
            List <String> queryFilters = new List <String>();
            Boolean queryLeads = sObjType == 'Lead'; // defines if Lead sObject type was selected on Supervisor Panel
            Boolean queryOpps = sObjType == 'Opportunity'; // defines if Opportunity sObject type was selected on Supervisor Panel
            if(selectedFilters.expectedVolume_from !=  null) {
                if (queryLeads) {
                    queryFilters.add(' Expected_Volume_Ru__c >= '+selectedFilters.expectedVolume_from);
                }
                if (queryOpps) {
                    queryFilters.add(' Expected_Volume_Ru__c >= '+selectedFilters.expectedVolume_from);
                }
            }
            if(selectedFilters.expectedVolume_to !=  null) {
                if (queryLeads) {
                    queryFilters.add(' Expected_Volume_Ru__c <= '+selectedFilters.expectedVolume_to);
                }
                if (queryOpps) {
                    queryFilters.add(' Expected_Volume_Ru__c <= '+selectedFilters.expectedVolume_to);
                }
            }
            if(selectedFilters.ratingFSNew_from !=  null) {
                if (queryLeads) {
                    queryFilters.add(' Rating_FS_New__c >= '+selectedFilters.ratingFSNew_from);
                }
                if (queryOpps) {
                    queryFilters.add(' Account.Rating_FS_New__c >= '+selectedFilters.ratingFSNew_from);
                }
            }
            if(selectedFilters.ratingFSNew_to !=  null) {
                if (queryLeads) {
                    queryFilters.add(' Rating_FS_New__c <= '+selectedFilters.ratingFSNew_to);
                }
                if (queryOpps) {
                    queryFilters.add(' Account.Rating_FS_New__c <= '+selectedFilters.ratingFSNew_to);
                }
            }
            if(selectedFilters.ratingFS_from !=  null) {
                if (queryLeads) {
                    queryFilters.add(' Rating_FS__c >= '+selectedFilters.ratingFS_from);
                }
                if (queryOpps) {
                    queryFilters.add(' Account.Rating_FS__c >= '+selectedFilters.ratingFS_from);
                }
            }
            if(selectedFilters.ratingFS_to !=  null) {
                if (queryLeads) {
                    queryFilters.add(' Rating_FS__c <= '+selectedFilters.ratingFS_to);
                }
                if (queryOpps) {
                    queryFilters.add(' Account.Rating_FS__c <= '+selectedFilters.ratingFS_to);
                }
            }
            if(!selectedFilters.regions.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.regions);
                if (queryLeads) queryFilters.add(' Region__c IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' Account.Region__c IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.statuses.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.statuses);
                if (queryLeads) queryFilters.add(' Status IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' StageName IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.orgTypes.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.orgTypes);
                if (queryLeads) queryFilters.add(' Organization_Type__c IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' Account.Organization_Type__c IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.leadSourses.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.leadSourses);
                if (queryLeads) queryFilters.add(' Source_of_Lead__c IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.disqualReasons.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.disqualReasons);
                if (queryLeads) queryFilters.add(' Lead_Status_Specific__c IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' PPR_Lost_Reasons__c IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.promocodes.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.promocodes);
                if (queryLeads) queryFilters.add(' Promo_Code1__c IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' Promo_Code1__c IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.industries.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.industries);
                if (queryLeads) queryFilters.add(' Industry IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' Account.Industry IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            if(!selectedFilters.excludedNaumenProjects.isEmpty()) {
                List <String> escapedList = GlobalUtils.escapeValuesList_singleQuotes (selectedFilters.excludedNaumenProjects);
                if (queryLeads) queryFilters.add(' Naumen_Autocall_Project_UUID__c NOT IN (\''+String.join(escapedList, '\',\'') + '\')');
                if (queryOpps) queryFilters.add(' Naumen_Autocall_Project_UUID__c NOT IN (\''+String.join(escapedList, '\',\'') + '\')');
            }
            // build query for the sObject type
            if (!queryFilters.isEmpty()) {
                queryFilters.add('RecordType.DeveloperName = \'Russian_Sales\'');
                List <String> queryFields = getFieldsToQueryRecord (queryLeads ? Schema.Lead.sObjectType : Schema.Opportunity.sObjectType);         
                String whereStr = ' WHERE ' + String.join(queryFilters, ' AND ');
                String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM ' + sObjType + whereStr;
                String query_count = 'SELECT count() FROM ' + sObjType + whereStr;
                queriesMap.put(sObjType, query);
                queriesMap.put(sObjType+'_count', query_count);
                system.debug(sObjType + ' : whereStr: ' + whereStr);
            } else {
                queriesMap.put(sObjType+'_count', null); // set query for getting number of the records as null to define that selected filters were empty
            }
        }
        return queriesMap;
    }
    /*******************************************************************************
    *  Name            : getFieldsToQueryRecord
    *  Summary         : returs list of fields needed for working with records in Naumen Supervisor Panel
    *  Parameters      : Schema.sObjectType sObjType - sObjectType for which the SOQL query will be built
    *  Returns         : List <String> - list of fields for the SOQL query
    ******************************************************************************/
    public static List <String> getFieldsToQueryRecord (Schema.sObjectType sObjType) {
        Set <String> fieldsSet = new Set <String> ();
        if(sObjType == Schema.Lead.sObjectType){
            List <String> fields_GetRecordAccess = RecordAssignCheckRuCtrl.getFields_queryLeadToGetRecordAccess();
            List <String> fields_Naumen = Naumen_Callouts.getFieldsToCreateCases (sObjType);
            List<String> fields_recordsWrap = Naumen_RecordsHelper.createFieldsList_Lead ();
            fieldsSet.addAll(fields_GetRecordAccess);
            fieldsSet.addAll(fields_Naumen);
            fieldsSet.addAll(fields_recordsWrap);
        } else if (sObjType == Schema.Opportunity.sObjectType){
            List <String> fields_GetRecordAccess = RecordAssignCheckRuCtrl.getFields_queryOpportunityToGetRecordAccess();
            List <String> fields_Naumen = Naumen_Callouts.getFieldsToCreateCases (sObjType);
            List<String> fields_recordsWrap = Naumen_RecordsHelper.createFieldsList_Opportunity ();
            fieldsSet.addAll(fields_GetRecordAccess);
            fieldsSet.addAll(fields_Naumen);
            fieldsSet.addAll(fields_recordsWrap);
        }
        return new List <String> (fieldsSet);
    }
// ======================= BUILDING RECORDS TABLE DATA ===========================================
    /*******************************************************************************
    *  Name            : createTableRecordsParams
    *  Summary         : sets params specific for Naumen Supervisor to build records table (html/Excel)
    *  Parameters      : String sObjTypeStr - sObjectType for which these table params are set
    *  Returns         : Naumen_RecordsHelper.RecordsTableParams - table params wrapper for Naumen Supervisor Panel
    ******************************************************************************/
    public static Naumen_RecordsHelper.RecordsTableParams createTableRecordsParams (String sObjTypeStr) {
        Schema.sObjectType sObjType = Schema.getGlobalDescribe().get(sObjTypeStr);
        // sObject fields columns
        List <String> fieldsList = sObjType == Schema.Opportunity.sObjectType ? new List <String> {'Id', 'AccountId', 'INN_Opp__c', 'Account.Name', 'Account.Region__c'}
                                 : sObjType ==  Schema.Lead.sObjectType ? new List <String> {'Id', 'INN__c', 'Company', 'Region__c', 'Name', 'Title', 'Email'}
                                 : null;
        // additional columns
        List <String>  mainContactFields = sObjType == Schema.Opportunity.sObjectType ? new List <String> {'Name', 'Title', 'Email'} // main contact is defined in Naumen_RecordsHelper.OpportunityWrapper class
                                         : null;
        Boolean addRegionColumns = true; // region data from custom metadata FS_Tree_Province__mdt (timezone, allowed call time)
        Boolean addAllPhonesColumns = true; // phones from the sObject record or related contacts (in case of opportunity)
        // set records table params
        Naumen_RecordsHelper.RecordsTableParams ret = new Naumen_RecordsHelper.RecordsTableParams(sObjType, fieldsList, addRegionColumns, addAllPhonesColumns);
        ret.mainContactFields = mainContactFields; // add main contact fields columns (for opporunity record)
        return ret;
    }
}
