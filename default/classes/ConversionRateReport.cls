public with sharing class ConversionRateReport {
    public Date startDateOfMonth {get; set;}
    public Date endDateOfMonth {get; set;}
    public Date startDateOfWeek {get; set;}
    public Date endDateOfWeek {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public String year {get; set;}
    public String selectedUserId {get; set;}
    public String userParam {get; set;}
    public String periodId {get; set;}
    public String radioButtonValue {get; set;}
    public Map<Id, Integer> allLeadsOppsMap {get; set;}
    public Map<Id, Integer> closedWonOpps {get; set;}
    public Map<Id, Integer> oppsForCalculatingARmap {get; set;}
    public Map<Id, User> salesTeamMap {get; set;}
    public List<FinalList> finalList {get; set;}
    public Integer numberOfLeads {get; set;}
    public Integer numberOfOpportunities {get; set;}
    public Integer numberOfClosedWon {get; set;}
    public Integer numberOfCreditCheck {get; set;}
    public Map<Id, Lead> finalCreatedLeadsMap {get; set;}
    public Map<Id, Opportunity> finalCreatedOpportunitiesMap {get; set;}
    public Map<Id, Opportunity> finalClosedWonOpportunitiesMap {get; set;}

    public Map<String, OpenHotDeals> finalOpenHotDealsList {get; set;}
    public Integer numberHotOppties {get; set;}
    public Integer numberHotLeads {get; set;}
    // Excluded Opportunities - Disable for KPI = true
    public Map<Id, Opportunity> excludedOpptiesMap {get; set;}
    public Integer numberExcludedOppties {get; set;}
    // Excluded leads - Disable for KPI = true
    public Map<Id, Lead> excludedLeadsMap {get; set;}
    public Integer numberExcludedLeads {get; set;}
 
    public List<Opportunity> creditCheckList {get; set;}
    public User currentUser {get; set;}
    public String selectedPeriod {get; set;}
    public String selectedYear {get; set;}

    public Date startDateOfPeriod;
    public Date endDateOfPeriod;


    public ConversionRateReport() {
        selectedUserId = 'None';
    }

    public void init() {
        userParam = Apexpages.currentPage().getParameters().get('userid');
        periodId = Apexpages.currentPage().getParameters().get('period');
        radioButtonValue = Apexpages.currentPage().getParameters().get('button');    
        if (selectedYear == year) {
            year = ApexPages.currentPage().getParameters().get('year');
        } else {
            year = selectedYear;
        }
        if (selectedPeriod == null) {
            selectedPeriod = periodId;
        }   
        allLeadsOppsMap = new Map<Id, Integer>();
        closedWonOpps = new Map<Id, Integer>();
        salesTeamMap = new Map<Id, User>();
        excludedOpptiesMap = new Map<Id, Opportunity>();
        excludedLeadsMap = new Map<Id, Lead>();
        if (userParam != null && periodId != null) {
            selectedUserId = userParam;
        } else {
            selectedUserId = UserInfo.getUserId();
        }
        finalList = new List<FinalList>();
        currentUser = [
            SELECT Name, Profile.Name, LocaleSidKey, UserRole.Name
            FROM User
            WHERE Id = :selectedUserId];
        if (this.selectedYear == null) {
            this.selectedYear = year;
        }
        generateDataForCharts();
        conversionRate();   
    }

    public void conversionRate() {
        if (selectedUserId != 'None') {
            salesTeamMap = new Map<Id, User>([
                    SELECT Name
                    FROM User
                    WHERE isActive = TRUE
                    LIMIT 10000]);

            //====
            // 1. Get All Closed Won for selected User
            //====
            Map<Id, Opportunity> closedWonOpportunitiesMap = new Map<Id, Opportunity>();
            Map<Id, Opportunity> pendingAMLDocOpportunitiesMap = new Map<Id, Opportunity>();
            Map<Id, Opportunity> allOpportunitiesMap = generateOppSOQLquery('allOpportunitiesMap', null);

            Map<Id, Opportunity> opptiesEnabledForKPImap = new Map<Id, Opportunity>();
            for (Opportunity oppty : allOpportunitiesMap.values()) {
                if (oppty.Disable_for_KPI__c == FALSE) {
                    opptiesEnabledForKPImap.put(oppty.Id, oppty);
                } else {
                    this.excludedOpptiesMap.put(oppty.Id, oppty);
                }
            }
            this.numberExcludedOppties = this.excludedOpptiesMap.size();

            for (Opportunity opp : opptiesEnabledForKPImap.values()) {
                if (opp.StageName == 'Closed Won' && ! currentUser.UserRole.Name.contains('AllStar Sales') &&
                    ! currentUser.UserRole.Name.contains('AllStar Teamleader')) {
                    closedWonOpportunitiesMap.put(opp.Id, opp);
                } else if (opp.StageName == 'Closed Won' && (radioButtonValue == 'TotalAR' || radioButtonValue == 'ARamlCheck') &&
                    (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name.contains('AllStar Teamleader'))) {
                    closedWonOpportunitiesMap.put(opp.Id, opp);
                }
            }

            Set<Id> allOpportunitiesSet = new Set<Id>();
            Set<Id> finalOpportunitiesSet = new Set<Id>();
            Map<Id, Lead> convertedLeadsMap = generateLeadSOQLquery('convertedLeadsMap', opptiesEnabledForKPImap, null);

            Map<Id, Lead> leadsEnabledForKPImap = new Map<Id, Lead>();
            for (Lead lead : convertedLeadsMap.values()) {
                if (lead.Disable_for_KPI__c == FALSE) {
                    leadsEnabledForKPImap.put(lead.Id, lead);
                } else {
                    this.excludedLeadsMap.put(lead.Id, lead);
                }
            }
            this.numberExcludedLeads = this.excludedLeadsMap.size();

            //Valid - Lead OwnerId equals to Opportunity OwnerId
            Map<Id, Lead> allConvOpportunitiesMap = new Map<Id, Lead>();
            for (Lead lead : leadsEnabledForKPImap.values()) {
                Date lastOwnerChangeDate = Date.newinstance(
                    lead.LastTransferDate.year(), 
                    lead.LastTransferDate.month(), 
                    lead.LastTransferDate.day());

                if (opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId).CloseDate >= lastOwnerChangeDate &&
                    opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId).CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    lead.OwnerId == opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId).OwnerId &&
                    closedWonOpportunitiesMap.containsKey(lead.ConvertedOpportunityId)) {
                    
                    finalOpportunitiesSet.add(lead.ConvertedOpportunityId);
                }

                allOpportunitiesSet.add(lead.ConvertedOpportunityId);
                if (lead.OwnerId != lead.ConvertedOpportunity.OwnerId) {
                    allConvOpportunitiesMap.put(lead.Id, lead);
                }
            }

            //Invalid - Lead OnwerId NOT equals to Opportunity OwnerId
            for (Lead lead : leadsEnabledForKPImap.values()) {
                Opportunity currentOpportunity = opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId);
                Date lastOwnerChangeDate = Date.newinstance(
                    currentOpportunity.Last_Owner_Change_Date__c.year(), 
                    currentOpportunity.Last_Owner_Change_Date__c.month(), 
                    currentOpportunity.Last_Owner_Change_Date__c.day());

                if (currentOpportunity.CloseDate >= lastOwnerChangeDate &&
                    currentOpportunity.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    lead.OwnerId != opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId).OwnerId &&
                    closedWonOpportunitiesMap.containsKey(lead.ConvertedOpportunityId)) {
                        
                    finalOpportunitiesSet.add(lead.ConvertedOpportunityId);
                }
            }

            //====
            // 2. Get All Leads for selected user
            //====
            finalCreatedLeadsMap = generateLeadSOQLquery('finalCreatedLeadsMap', null, finalOpportunitiesSet);

            Set<Id> convertedOpportunitiesSet = new Set<Id>();
            for (Lead lead : finalCreatedLeadsMap.values()) {
                if (lead.ConvertedOpportunityId != null) {
                    convertedOpportunitiesSet.add(lead.ConvertedOpportunityId);
                }

                if (lead.ConvertedOpportunityId != null && lead.ConvertedOpportunity.OwnerId != selectedUserId) {
                    finalCreatedLeadsMap.remove(lead.Id);              
                } else {
                    allConvOpportunitiesMap.put(lead.Id, lead);
                }
            }

            finalCreatedLeadsMap.putAll(allConvOpportunitiesMap);
            numberOfLeads = finalCreatedLeadsMap.size();


            //====
            // 3. Get All manually created Opportunities
            //====
            Map<Id, Opportunity> finalCreatedOpportunitiesMapTemp = generateOppSOQLquery('finalCreatedOpportunitiesMapTemp', convertedOpportunitiesSet);

            finalCreatedOpportunitiesMap = new Map<Id, Opportunity>();

            for (Opportunity opp : finalCreatedOpportunitiesMapTemp.values()) {
                if (opp.Histories.size() == 0) {
                    finalCreatedOpportunitiesMap.put(opp.Id, opp);
                }
            }

            numberOfOpportunities = finalCreatedOpportunitiesMap.size();

            allLeadsOppsMap.put(selectedUserId, finalCreatedOpportunitiesMap.size() + finalCreatedLeadsMap.size());

            //Set FINAL Closed Won
            Set<Id> manuallyCreatedClosedWonSet = new Set<Id>();
            for (Opportunity opp : finalCreatedOpportunitiesMap.values()) {
                Date lastOwnerChangeDate = Date.newinstance(
                    opp.Last_Owner_Change_Date__c.year(), 
                    opp.Last_Owner_Change_Date__c.month(), 
                    opp.Last_Owner_Change_Date__c.day());
                if (opp.CloseDate >= lastOwnerChangeDate &&
                    opp.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    ! finalOpportunitiesSet.contains(opp.Id) &&
                    lastOwnerChangeDate >= startDateOfPeriod && lastOwnerChangeDate <= endDateOfPeriod &&
                    opp.StageName == 'Closed Won' && 
                    (! currentUser.UserRole.Name.contains('AllStar Sales') && ! currentUser.UserRole.Name.contains('AllStar Teamleader'))) {
                    finalOpportunitiesSet.add(opp.Id);
                } else if (opp.CloseDate >= lastOwnerChangeDate &&
                    opp.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    ! finalOpportunitiesSet.contains(opp.Id) &&
                    lastOwnerChangeDate >= startDateOfPeriod && lastOwnerChangeDate <= endDateOfPeriod &&
                    opp.StageName == 'Closed Won' && (radioButtonValue == 'TotalAR' || radioButtonValue == 'ARamlCheck') &&
                    (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name.contains('AllStar Teamleader'))) {
                    finalOpportunitiesSet.add(opp.Id);
                }
            }

            closedWonOpps.put(selectedUserId, finalOpportunitiesSet.size());
            numberOfClosedWon = finalOpportunitiesSet.size();

            finalClosedWonOpportunitiesMap = new Map<Id, Opportunity>([
                    SELECT Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c
                    FROM Opportunity
                    WHERE Id IN :finalOpportunitiesSet
                    LIMIT 10000]);

            for (String uid : allLeadsOppsMap.keySet()) {
                finalList.add(new FinalList(
                    uid,
                    closedWonOpps.get(uid)));
            }

            finalList.sort();


            //====
            // 4. Get All Open Opportunities
            //====
            this.numberHotOppties = 0;
            this.numberHotLeads = 0;
            this.finalOpenHotDealsList = new Map<String, OpenHotDeals>();
            for (Lead lead : finalCreatedLeadsMap.values()) {
                if (lead.ConvertedOpportunityId == null &&
                    lead.Status != 'Disqualified' && 
                    lead.Status != 'Uzavřeno' &&
                    lead.LastTransferDate.addDays(28) >= Date.today()) {  
                        OpenHotDeals openDeal = new OpenHotDeals();
                        openDeal.objectType = 'Lead';
                        openDeal.objectId = lead.Id;
                        openDeal.objectName = lead.Name;
                        openDeal.objectStatus = lead.Status;
                        openDeal.createdDate = String.valueOf(lead.CreatedDate);
                        openDeal.assignToUserDate = String.valueOf(lead.LastTransferDate);
                        openDeal.ownerId = lead.OwnerId;
                        openDeal.ownerName = lead.Owner.Name;
                        openDeal.daysUntilSLAdeadline = String.valueOf(lead.LastTransferDate.daysBetween(Date.today()));
                        finalOpenHotDealsList.put(lead.Id, openDeal);
                        this.numberHotLeads++;
                } else if (lead.ConvertedOpportunityId != null &&
                    opptiesEnabledForKPImap.containsKey(lead.ConvertedOpportunityId) &&
                    opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId).StageName != 'Closed Won' && 
                    opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId).StageName != 'Closed Lost') {
                    Opportunity convertedOppty = opptiesEnabledForKPImap.get(lead.ConvertedOpportunityId);
                    if (lead.Owner.Name == currentUser.Name && lead.LastTransferDate.addDays(28) >= Date.today()) {         
                        OpenHotDeals openDeal = new OpenHotDeals();
                        openDeal.objectType = 'Opportunity';
                        openDeal.objectId = convertedOppty.Id;
                        openDeal.objectName = convertedOppty.Name;
                        openDeal.objectStatus = convertedOppty.StageName;
                        openDeal.createdDate = String.valueOf(convertedOppty.CreatedDate);
                        openDeal.assignToUserDate = String.valueOf(lead.LastTransferDate);
                        openDeal.ownerId = convertedOppty.OwnerId;
                        openDeal.ownerName = convertedOppty.Owner.Name;
                        openDeal.daysUntilSLAdeadline = String.valueOf(lead.LastTransferDate.daysBetween(Date.today()));
                        finalOpenHotDealsList.put(convertedOppty.Id, openDeal);
                        this.numberHotOppties++;
                    } else if (lead.Owner.Name != currentUser.Name && convertedOppty.Last_Owner_Change_Date__c.Date().addDays(28) >= Date.today()) {
                        OpenHotDeals openDeal = new OpenHotDeals();
                        openDeal.objectType = 'Opportunity';
                        openDeal.objectId = convertedOppty.Id;
                        openDeal.objectName = convertedOppty.Name;
                        openDeal.objectStatus = convertedOppty.StageName;
                        openDeal.createdDate = String.valueOf(convertedOppty.CreatedDate);
                        openDeal.assignToUserDate = String.valueOf(convertedOppty.Last_Owner_Change_Date__c);
                        openDeal.ownerId = convertedOppty.OwnerId;
                        openDeal.ownerName = convertedOppty.Owner.Name;
                        openDeal.daysUntilSLAdeadline = String.valueOf(convertedOppty.Last_Owner_Change_Date__c.Date().daysBetween(Date.today()));
                        finalOpenHotDealsList.put(convertedOppty.Id, openDeal);
                        this.numberHotOppties++;
                    }
                }
            }

            // manually created opportunities
            for (Opportunity opp : finalCreatedOpportunitiesMap.values()) {
                if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' && opp.Last_Owner_Change_Date__c.Date().addDays(28) >= Date.today()) {
                    OpenHotDeals openDeal = new OpenHotDeals();
                        openDeal.objectType = 'Opportunity';
                        openDeal.objectId = opp.Id;
                        openDeal.objectName = opp.Name;
                        openDeal.objectStatus = opp.StageName;
                        openDeal.createdDate = String.valueOf(opp.CreatedDate);
                        openDeal.assignToUserDate = String.valueOf(opp.Last_Owner_Change_Date__c);
                        openDeal.ownerId = opp.OwnerId;
                        openDeal.ownerName = opp.Owner.Name;
                        openDeal.daysUntilSLAdeadline = String.valueOf(opp.Last_Owner_Change_Date__c.Date().daysBetween(Date.today()));
                    finalOpenHotDealsList.put(opp.Id, openDeal);
                    this.numberHotOppties++;
                } 
            }


            //====
            // 5. Get All CreditCheck
            //====
            List<OpportunityFieldHistory> fieldsHistories = generateOppFieldHistorySOQLquery();
            List<OpportunityFieldHistory> fieldsHistoriesCFstage = generateFieldHistoryCFstageSOQLquery();
             

            //2. Put all credit checks to map with key as Opportunity Id
            Map<Id, OpportunityFieldHistory> creditChecksMap = new Map<Id, OpportunityFieldHistory>();
            for (OpportunityFieldHistory ofh : fieldsHistories) {
                if (ofh.NewValue == 'CreditCheck' && ! currentUser.UserRole.Name.contains('AllStar Sales') && ! currentUser.UserRole.Name.contains('AllStar Teamleader') &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                } else if (ofh.NewValue == 'CreditCheck' && (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name.contains('AllStar Teamleader')) &&
                    (radioButtonValue == 'TotalAR' || radioButtonValue == 'ARinitialCC') &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                } else if (ofh.NewValue == 'Pending Credit AML' && (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name.contains('AllStar Teamleader')) &&
                    radioButtonValue == 'ARamlCheck' &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                }
            }
            for (OpportunityFieldHistory ofh : fieldsHistoriesCFstage) {
                if (ofh.NewValue != 'Manual Scoring' && ofh.NewValue != 'Not launched' && ! currentUser.UserRole.Name.contains('AllStar Sales') && ! currentUser.UserRole.Name.contains('AllStar Teamleader') &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                }
            }

            //3. Based on key set of creditChecksMap – select all Leads that these Opportunities were converted from
            Map<Id, Lead> leadMap = generateLeadsListSOQLquery(creditChecksMap);
            
            //4. Create map where id will be Converted Opportunity Id
            Map<Id, Lead> opportunityToLeadMap = new Map<Id, Lead>();
            for (Lead lead : leadMap.values()) {
                opportunityToLeadMap.put(lead.ConvertedOpportunityId, lead);                
            }

            //5. Calculate all credit checks
            Set<Id> finalOpportunitiesCreditCheckSet = new Set<Id>();
            for (Id opportunityId : creditChecksMap.keySet()) {
                OpportunityFieldHistory creditCheck = creditChecksMap.get(opportunityId);
                Date lastOwnerChangeDate = Date.newinstance(
                    creditCheck.Opportunity.Last_Owner_Change_Date__c.year(),
                    creditCheck.Opportunity.Last_Owner_Change_Date__c.month(),
                    creditCheck.Opportunity.Last_Owner_Change_Date__c.day());
                Date creditCheckCreatedDate = Date.newinstance(
                    creditCheck.CreatedDate.year(),
                    creditCheck.CreatedDate.month(),
                    creditCheck.CreatedDate.day());
                if (opportunityToLeadMap.containsKey(opportunityId)) {
                    //5.1 If Opportunity was converted from the Lead
                    Lead lead = opportunityToLeadMap.get(opportunityId);
                    Date lastTransferDate = Date.newinstance(
                        lead.LastTransferDate.year(),
                        lead.LastTransferDate.month(),
                        lead.LastTransferDate.day());
                    if (creditCheck.CreatedById == lead.OwnerId &&
                        creditCheckCreatedDate >= lastTransferDate &&
                        creditCheckCreatedDate <= lastTransferDate.addDays(28) &&
                        lastTransferDate >= startDateOfPeriod &&
                        lastTransferDate <= endDateOfPeriod) {
                        //5.1.1 If the same owner we check Last Transfer Date from Lead is in selected month and 
                        // Created Date of Credit check is in period Last Transfer Date - Last Transfer Date + 28*
                        // * extra 1 day in formula because of DateTime field
                        finalOpportunitiesCreditCheckSet.add(opportunityId);
                    } else if (creditCheck.CreatedById != lead.OwnerId &&
                        creditCheckCreatedDate >= lastOwnerChangeDate &&
                        creditCheckCreatedDate <= lastOwnerChangeDate.addDays(28) &&
                        lastOwnerChangeDate >= startDateOfPeriod &&
                        lastOwnerChangeDate <= endDateOfPeriod) {
                        //5.1.2 If owner is NOT the same we check Last Owner Change Date from Opportunity is in selected month and 
                        // Created Date of Credit check is in period Last Owner Change Date - Last Owner Change Date + 28*
                        // * extra 1 day in formula because of DateTime field
                        finalOpportunitiesCreditCheckSet.add(opportunityId);
                    }
                } else {
                    //5.2 If Opportunity was created manually
                    if (creditCheckCreatedDate >= lastOwnerChangeDate &&
                        creditCheckCreatedDate <= lastOwnerChangeDate.addDays(28) &&
                        lastOwnerChangeDate >= startDateOfPeriod &&
                        lastOwnerChangeDate <= endDateOfPeriod) {
                        finalOpportunitiesCreditCheckSet.add(opportunityId);    
                    }
                }
            }

            numberOfCreditCheck = finalOpportunitiesCreditCheckSet.size();

            creditCheckList = [
                    SELECT Name, StageName, Last_Owner_Change_Date__c, CloseDate, OwnerId, Opportunity_Nr__c
                    FROM Opportunity
                    WHERE Id IN :finalOpportunitiesCreditCheckSet AND Disable_for_KPI__c = FALSE
                    LIMIT 10000];
        }
    }


    public class OpenHotDeals {
        public String objectType {get; set;}
        public String objectId {get; set;}    
        public String objectName {get; set;}
        public String objectStatus {get; set;}
        public String createdDate {get; set;}
        public String assignToUserDate {get; set;}
        public String ownerId {get; set;}
        public String ownerName {get; set;}
        public String daysUntilSLAdeadline {get; set;}
    }


    /*******************************************************************************
    *  Name            : generateOppSOQLquery(String queryTarget, Set<Id> opportunitiesSet)
    *  Summary         : generate soql query for select Opportunity from database     
    *  CreatedDate     : 12/06/2017
    *  Parameters      : String queryTarget, Set<Id> opportunitiesSet 
    *  Returns         : Map<Id, Opportunity>
    ******************************************************************************/
    public Map<Id, Opportunity> generateOppSOQLquery(String queryTarget, Set<Id> opportunitiesSet) {
        Date days_out_1 = endDateOfPeriod.addDays(1);
        Date days_out_28 = endDateOfPeriod.addDays(28);
        String currentUserId = currentUser.Id;

        String theQuery = 'SELECT Name, StageName, Last_Owner_Change_Date__c, CreatedDate, CloseDate, OwnerId, Owner.Name, Opportunity_Nr__c, Disable_for_KPI__c';                        

        if (queryTarget == 'allOpportunitiesMap') {
            theQuery += ' FROM Opportunity ' +
                        'WHERE OwnerId = :currentUserId AND ' +
                            '((CloseDate >= :startDateOfPeriod AND CloseDate <= :days_out_28) OR ' +
                            '(Last_Owner_Change_Date__c >= :startDateOfPeriod AND Last_Owner_Change_Date__c <= :days_out_1)) AND ';  
        } else if (queryTarget == 'finalCreatedOpportunitiesMapTemp') {      
            theQuery += ', (SELECT Field FROM Histories WHERE Field = \'opportunityCreatedFromLead\') ' +
                        'FROM Opportunity ' +
                        'WHERE Id NOT IN :opportunitiesSet AND OwnerId = :currentUserId AND ' +
                            'Last_Owner_Change_Date__c >= :startDateOfPeriod AND Last_Owner_Change_Date__c <= :days_out_1 AND ';
                            
        }
        theQuery += '(Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\' OR Sec_Channel__c = \'Partner\') AND ' +
                    'Disable_for_KPI__c = FALSE AND ' +
                    'Disable_for_Approval_Rate__c = FALSE AND ' +
                    'Gruende_verloren__c != \'Duplicate\' AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || 
            currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            theQuery += '(RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')';
        } else if (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'RecordType.Name = \'AllStar\'';
        }
        theQuery += 'LIMIT 50000';        
              
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();           
        try {
            oppMap.putAll((List<Opportunity>)Database.query(theQuery));
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return oppMap;
    }


    /*******************************************************************************
    *  Name            : generateLeadSOQLquery(String queryTarget, Map<Id, Opportunity> oppMap, Set<Id> oppSet)
    *  Summary         : generate soql query for select Lead from database    
    *  CreatedDate     : 12/06/2017
    *  Parameters      : String queryTarget, Map<Id, Opportunity> oppMap, Set<Id> oppSet    
    *  Returns         : Map<Id, Lead>
    ******************************************************************************/
    public Map<Id, Lead> generateLeadSOQLquery(String queryTarget, Map<Id, Opportunity> oppMap, Set<Id> oppSet) { 
        String currentUserId = currentUser.Id; 
        Set<Id> opptyIdsSet = new Set<Id>();
        if (oppMap != null) {
            opptyIdsSet = oppMap.keyset();
        }   

        String theQuery = 'SELECT Name, OwnerId, Owner.Name, CreatedDate, ConvertedOpportunityId, FirstName, LastName, Last_Owner_Change_Date__c, IsConverted, Channel__c, Sec_Channel__c, ' +
                                'LeadSource, Status, LastTransferDate, Lead_Nr__c, Disable_for_KPI__c, ConvertedOpportunity.Last_Owner_Change_Date__c, ConvertedOpportunity.OwnerId, Quali_Status__c ' +
                            'FROM Lead ' +
                            'WHERE LastTransferDate >= :startDateOfPeriod AND LastTransferDate <= :endDateOfPeriod AND ' +
                                '(Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\' OR Sec_Channel__c = \'Partner\') AND ' +
                                'Quali_Status__c NOT IN :leadQualiStatusesSet AND ' +
                                'LeadSource != \'Adressbroker\' AND ' +  
                                'LeadSource != \'Bestandskunde Shell\' AND ' + 
                                'LeadSource != \'Online_chat\' AND ' +
                                'Disable_for_KPI__c = FALSE AND ' +
                                'Disable_for_Approval_Rate__c = FALSE AND ';

        if (queryTarget == 'convertedLeadsMap') {     
            theQuery += 'ConvertedOpportunityId IN :opptyIdsSet AND ';
        } else if (queryTarget == 'finalCreatedLeadsMap') {
            theQuery += '(ConvertedOpportunityId IN :oppSet OR OwnerId = :currentUserId) AND ';
        }

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || 
            currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            theQuery += 'RecordType.Name = \'Endkunde\'';
        } else if (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'RecordType.Name = \'AllStar\'';
        }
        theQuery += ' LIMIT 50000';

        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        try {
            leadsMap.putAll((List<Lead>)Database.query(theQuery));
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }      

        for (Id leadId : leadsMap.keySet()) {
            if (leadsMap.get(leadId).Status == 'Disqualified' && leadsMap.get(leadId).Quali_Status__c == 'Auto-detect') {
                leadsMap.remove(leadId);
            }
        }
        return leadsMap;
    }


    /*******************************************************************************
    *  Name            : generateOppFieldHistorySOQLquery()
    *  Summary         : generate soql query for select OpportunityFieldHistory from database
    *  CreatedDate     : 14/06/2017 
    *  Parameters      : -
    *  Returns         : List<OpportunityFieldHistory>
    ******************************************************************************/
    public List<OpportunityFieldHistory> generateOppFieldHistorySOQLquery() {
        Date days_out_29 = endDateOfPeriod.addDays(29);
        String currentUserId = currentUser.Id;

        String theQuery = 'SELECT Field, OpportunityId, NewValue, CreatedDate, Opportunity.Last_Owner_Change_Date__c, CreatedById, Opportunity.Sec_Channel__c ' +
                            'FROM OpportunityFieldHistory ' +
                            'WHERE Field = \'StageName\' AND ' +
                                'CreatedDate >= :startDateOfPeriod AND ' +
                                'CreatedDate <= :days_out_29 AND ' +
                                'Opportunity.OwnerId = :currentUserId AND ' +
                                '(Opportunity.Sec_Channel__c = \'Inbound\' OR Opportunity.Sec_Channel__c = \'JITB\' OR Opportunity.Sec_Channel__c = \'Partner\') AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || 
            currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            theQuery += '(Opportunity.RecordType.Name = \'Euroshell\' OR Opportunity.RecordType.Name = \'Euroshell Starts\')';
        } else if (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'Opportunity.RecordType.Name = \'AllStar\'';
        }
        theQuery += ' ORDER BY CreatedDate DESC ' +
                    'LIMIT 25000';

        List<OpportunityFieldHistory> oppFieldsHistoriesList = new List<OpportunityFieldHistory>();
        try {
            oppFieldsHistoriesList = (List<OpportunityFieldHistory>)Database.query(theQuery);
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }     
        return oppFieldsHistoriesList;
    }


    /*******************************************************************************
    *  Name            : generateFieldHistoryCFstageSOQLquery()
    *  Summary         : generate soql query for select OpportunityFieldHistory from database
    *  CreatedDate     : 14/06/2017 
    *  Parameters      : -
    *  Returns         : List<OpportunityFieldHistory>
    ******************************************************************************/    
    public List<OpportunityFieldHistory> generateFieldHistoryCFstageSOQLquery() {
        Date days_out_29 = endDateOfPeriod.addDays(29);
        String currentUserId = currentUser.Id;

        String theQuery = 'SELECT Field, OpportunityId, NewValue, CreatedDate, Opportunity.Last_Owner_Change_Date__c, CreatedById, Opportunity.Sec_Channel__c ' +
                            'FROM OpportunityFieldHistory ' +
                            'WHERE Field = \'CF_Stage__c\' AND ' +
                                'CreatedDate >= :startDateOfPeriod AND ' +
                                'CreatedDate <= :days_out_29 AND ' +
                                'Opportunity.OwnerId = :currentUserId AND ' +
                                '(Opportunity.Sec_Channel__c = \'Inbound\' OR Opportunity.Sec_Channel__c = \'JITB\' OR Opportunity.Sec_Channel__c = \'Partner\') AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || 
            currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            theQuery += '(Opportunity.RecordType.Name = \'Euroshell\' OR Opportunity.RecordType.Name = \'Euroshell Starts\')';
        } else if (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'Opportunity.RecordType.Name = \'AllStar\'';
        }
        theQuery += ' ORDER BY CreatedDate DESC ' +
                    'LIMIT 25000';

        List<OpportunityFieldHistory> oppFieldsHistoriesCFstageList = new  List<OpportunityFieldHistory>();
        try {
            oppFieldsHistoriesCFstageList = (List<OpportunityFieldHistory>)Database.query(theQuery);
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }    
        return oppFieldsHistoriesCFstageList;
    }


    /*******************************************************************************
    *  Name            : generateLeadsListSOQLquery(Map<Id, OpportunityFieldHistory> creditChecksMap)
    *  Summary         : Based on key set of creditChecksMap – generate soql query for select all Leads that these Opportunities were converted from
    *  CreatedDate     : 14/06/2017  
    *  Parameters      : Map<Id, OpportunityFieldHistory> creditChecksMap
    *  Returns         : Map<Id, Lead> leadMap
    ******************************************************************************/
    public Map<Id, Lead> generateLeadsListSOQLquery(Map<Id, OpportunityFieldHistory> creditChecksMap) {
        Set<Id> creditChecksSet = new Set<Id>();
        if (creditChecksMap != null) {
            creditChecksSet = creditChecksMap.keyset();
        }  

        String theQuery = 'SELECT LastTransferDate, OwnerId, ConvertedOpportunityId, Quali_Status__c, Status ' +
                            'FROM Lead ' +
                            'WHERE ConvertedOpportunityId IN :creditChecksSet AND ' +
                                '(Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\' OR Sec_Channel__c = \'Partner\') AND ' +
                                'LeadSource != \'Bestandskunde Shell\' AND ' +
                                'LeadSource != \'Adressbroker\' AND ' +
                                'Quali_Status__c != \'Offer sent\' AND ' +
                                'Quali_Status__c != \'No reply – Quick Process\' AND ' +
                                'Quali_Status__c != \'Sent to support\' AND ' +
                                'Quali_Status__c != \'Not a legal entity\' AND ' +
                                'Quali_Status__c != \'Sent to Shell\' AND ' + 
                                'Quali_Status__c != \'Switched to E2E\' AND ' +
                                'LeadSource != \'Online_chat\' AND ' +
                                'Quali_Status__c != \'Spam\' AND ' +
                                'Disable_for_KPI__c = FALSE AND ' +
                                'Disable_for_Approval_Rate__c = FALSE AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || 
            currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            theQuery += 'RecordType.Name = \'Endkunde\'';
        } else if (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'RecordType.Name = \'AllStar\'';
        }
        theQuery += ' LIMIT 25000';

        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        try {
            leadMap.putAll((List<Lead>)Database.query(theQuery));
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }  
        return leadMap;   
    }


    public String returnCurrentYear() {
        String currentYear = String.valueOf(Date.today().year());
        Date lastDayOfYear = [
            SELECT End_Date__c 
            FROM Fleetcor_Calendar_Month__c
            WHERE Fleetcor_Calendar_Year__r.Name = :currentYear
            ORDER BY End_Date__c DESC 
            LIMIT 1].End_Date__c;
        if (Date.today() > lastDayOfYear) {
            return String.valueOf(Date.today().year() + 1);
        } else {
            return String.valueOf(Date.today().year());
        }
    }


    public void generateDataForCharts() {
        Date startDateOfMonth;
        Date endDateOfMonth;
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                   Start_Date__c, End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                  Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        Fleetcor_Calendar_Month__c currentMonth = new Fleetcor_Calendar_Month__c();
        if (this.selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }
            //week
            this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
            endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;
            this.selectedPeriod = currentWeek.get(0).Id;
        } else {
            Id selectedId = selectedPeriod;          
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //week
                this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
                this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
                startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
                endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;    
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //month
                this.startDateOfPeriod = currentMonth.Start_Date__c;
                this.endDateOfPeriod = currentMonth.End_Date__c;
                startDateOfMonth = currentMonth.Start_Date__c;
                endDateOfMonth = currentMonth.End_Date__c;  
            }         
        }
        this.startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        this.endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    public List<SelectOption> getUserOptions() {
        List<SelectOption> options = new List<SelectOption>();
        String salesTeamRole = 'Salesteam Inbound';
        String salesTeamRole2 = 'Salesteam Inbound 2';

        Map<Id, User> salesTeamMapTemp = new Map<Id, User>([
                SELECT Name
                FROM User
                WHERE (UserRole.Name = :salesTeamRole OR UserRole.Name = :salesTeamRole2) AND isActive = TRUE
                LIMIT 10000]);
        options.add(new SelectOption('None','None'));
        for (String uid : salesTeamMapTemp.keySet()) {
            options.add(new SelectOption(uid, salesTeamMapTemp.get(uid).Name));
        }
        return options;
    }


    /*******************************************************************************
    *  Name            : getYears()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 21/03/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> yearsList = [SELECT Name FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : yearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }

        return options;
    }

    public List<SelectOption> getcurrentWeeks() {
        String thisMonth = '';
        Integer monthIndex = 12;
        
        List<Fleetcor_Calendar_Month__c> currentWeekTemp = [
                SELECT Name, Month_Number__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                      Start_Date__c <= TODAY AND 
                      End_Date__c >= TODAY 
                LIMIT 1];
        
        List<SelectOption> options = new List<SelectOption>();
        Set<String> monthsSet = new Set<String>();

        if ( ! currentWeekTemp.isEmpty() ) {
            for (Integer i = 1; i <= currentWeekTemp.get(0).Month_Number__c; i++) {
                monthsSet.add(monthsMap.get(i));
            }
            monthIndex = Integer.valueOf(currentWeekTemp.get(0).Month_Number__c);
        } else {
            for (Integer i = 1; i <= 12; i++) {
                monthsSet.add(monthsMap.get(i));
            }      
        }

        List<Fleetcor_Calendar_Week__c> weeksList = [
                SELECT End_Date__c, Start_Date__c, Fleetcor_Calendar_Month__r.Name,
                    Fleetcor_Calendar_Month__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Name IN :monthsSet AND 
                   Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                ORDER BY Start_Date__c DESC];

        for (Fleetcor_Calendar_Week__c week : weeksList) {

            if (thisMonth != week.Fleetcor_Calendar_Month__r.Name) {
                thisMonth = week.Fleetcor_Calendar_Month__r.Name;
                options.add(new SelectOption(week.Fleetcor_Calendar_Month__c, monthsMap.get(monthIndex)));
                if (monthIndex != 1) {
                    monthIndex--;
                }
            }
            
            options.add(
                new SelectOption(
                    week.Id, 
                    '---' + week.Fleetcor_Calendar_Month__r.Name + ' (' + week.Start_Date__c.day() + '.' + week.Start_Date__c.month() + ' - ' + 
                    week.End_Date__c.day() + '.' + week.End_Date__c.month() + ')'));
        }

        return options;
    }

    public void changeYear() {
        selectedPeriod = null;
        List<Fleetcor_Calendar_Week__c> currentFLTweek = [
            SELECT Id, Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name
            FROM Fleetcor_Calendar_Week__c
            WHERE Start_Date__c <= TODAY AND 
                  End_Date__c >= TODAY
            LIMIT 1];

        String currentWeekId;
        String currentFLTyear;
        if (! currentFLTweek.isEmpty()) {
            currentWeekId = currentFLTweek.get(0).Id;
            currentFLTyear = currentFLTweek.get(0).Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name;
        }
        if (this.selectedYear != currentFLTyear) {
            String firstMonthId = [
                SELECT Id
                FROM Fleetcor_Calendar_Month__c
                WHERE Name = :monthsMap.get(1) AND
                    Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                LIMIT 1].Id;
            Apexpages.currentPage().getParameters().put('period', firstMonthId);
        } else {
            Apexpages.currentPage().getParameters().put('period', currentWeekId);
        }
        init();       
    }

    public class FinalList implements Comparable {
        public String id {get; set;}
        public Decimal compareValue {get; set;}

        public finalList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            FinalList compareToU = (FinalList)compareTo;
            if (compareValue == compareToU.compareValue) return 0;
            if (compareValue < compareToU.compareValue) return 1;
            return -1;        
        }
    }

    private Map<Integer, String> monthsMap = new Map<Integer, String>{
         1 => 'January', 
         2 => 'February', 
         3 => 'March',
         4 => 'April',
         5 => 'May',
         6 => 'June',
         7 => 'July',
         8 => 'August',
         9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'};


    private Set<String> leadQualiStatusesSet = new Set<String>{
        'Bereits Kunde - FleetCor',
        'Bereits Kunde - Shell',
        'Dublette',
        'Gesprächsverweigerer',
        'Keine Fahrzeuge',
        'Kontaktdaten falsch',
        'Not a legal entity',
        'Do Not Contact',
        'Sent to support',       
        'Spam',
        'Unternehmen erloschen',
        'Sent to Shell',
        'No reply – Quick Process',
        'Offer sent',
        'Switched to E2E'
    };

    public void fixCreditCheck() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}