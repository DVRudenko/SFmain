public with sharing class SalesDashboardApprovalRateCtrl {
	public Map<Id, User> salesTeamMap {get; set;}
	public User currentUser {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public String selectedPeriod {get; set;}
    public String selectedYear {get; set;}
    public Integer salesOpportunitiesTotal {get; set;}
    public Integer allCreditCheckSales {get; set;}
    public Map<Id, Integer> allCreditCheck {get; set;}
    public Map<Id, Integer> closedWonOpps {get; set;}
    public List<FinalList> finalList {get; set;}
    private String userId;
	private Date startDateOfMonth {get; set;}
    private Date endDateOfMonth {get; set;}
    public Date startDateOfWeek {get; set;}
    public Date endDateOfWeek {get; set;}
    public String selectedIndividualButton {get; set;}

    public Date startDateOfPeriod;
    public Date endDateOfPeriod;

    public SalesDashboardApprovalRateCtrl() {
        
    }
    public void init() {
        this.allCreditCheck = new Map<Id, Integer>();
        this.closedWonOpps = new Map<Id, Integer>();
        this.salesTeamMap = new Map<Id, User>();
        this.finalList = new List<FinalList>();
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
        if (this.selectedIndividualButton == null) {
            this.selectedIndividualButton = 'TotalAR';
        }
    	generateDataForCharts();
    	approvalRate();
    }

    public void approvalRate() {
        returnUserId();
        currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :userId];

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || currentUser.UserRole.Name.contains('AllStar Sales')) {
            //====
            // 1. Get All Closed Won for selected User
            //====
            Map<Id, Lead> creditCheckOpportunitiesMap = new Map<Id, Lead>();
            Map<Id, Opportunity> opportunitiesForComparisonMap = new Map<Id, Opportunity>(); 
            Map<Id, Opportunity> opportunitiesMap = generateOppSOQLquery('opportunitiesMap', null);

            for (Opportunity opp : opportunitiesMap.values()) { 
                if (! currentUser.UserRole.Name.contains('AllStar Sales') && opp.StageName == 'Closed Won') {
                    opportunitiesForComparisonMap.put(opp.Id, opp);
                } else if (opp.StageName == 'Closed Won' && currentUser.UserRole.Name.contains('AllStar Sales') &&
                   (selectedIndividualButton == 'TotalAR' || selectedIndividualButton == 'ARamlCheck')) {
                    opportunitiesForComparisonMap.put(opp.Id, opp);
                }
            }

            Set<Id> allOpportunitiesSet = new Set<Id>();
            Map<Id, Lead> finalOpportunitiesMap = new Map<Id, Lead>();
            Map<Id, Lead> convertedLeadsMap = generateLeadSOQLquery('convertedLeadsMap', opportunitiesMap, null);

            //Valid - Lead OwnerId equals to Opportunity OwnerId
            for (Lead lead : convertedLeadsMap.values()) {
                Date lastOwnerChangeDate = Date.newinstance(
                    lead.LastTransferDate.year(), 
                    lead.LastTransferDate.month(), 
                    lead.LastTransferDate.day());

                if (opportunitiesMap.get(lead.ConvertedOpportunityId).CloseDate >= lastOwnerChangeDate &&
                    opportunitiesMap.get(lead.ConvertedOpportunityId).CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    lead.OwnerId == opportunitiesMap.get(lead.ConvertedOpportunityId).OwnerId &&
                    opportunitiesForComparisonMap.containsKey(lead.ConvertedOpportunityId)) {
                    finalOpportunitiesMap.put(lead.ConvertedOpportunityId, lead);
                }

                allOpportunitiesSet.add(lead.ConvertedOpportunityId);
            }

            //Invalid - Lead OnwerId NOT equals to Opportunity OwnerId
            for (Lead lead : convertedLeadsMap.values()) {
                Opportunity currentOpportunity = opportunitiesMap.get(lead.ConvertedOpportunityId);
                Date lastOwnerChangeDate = Date.newinstance(
                    currentOpportunity.Last_Owner_Change_Date__c.year(), 
                    currentOpportunity.Last_Owner_Change_Date__c.month(), 
                    currentOpportunity.Last_Owner_Change_Date__c.day());

                if (currentOpportunity.CloseDate >= lastOwnerChangeDate &&
                    currentOpportunity.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    lead.OwnerId != opportunitiesMap.get(lead.ConvertedOpportunityId).OwnerId &&
                    opportunitiesForComparisonMap.containsKey(lead.ConvertedOpportunityId)) {
                    
                    finalOpportunitiesMap.put(lead.ConvertedOpportunityId, lead);
                }
            }

            //====
            // 2. Get All Leads for selected user
            //====
            Map<Id, Lead> finalCreatedLeadsMap = generateLeadSOQLquery('finalCreatedLeadsMap', null, allOpportunitiesSet);
            Set<Id> convertedOpportunitiesSet = new Set<Id>();
            
            for (Lead lead : finalCreatedLeadsMap.values()) {
                if (lead.ConvertedOpportunityId != null && lead.ConvertedOpportunity.OwnerId != currentUser.Id) {
                    finalCreatedLeadsMap.remove(lead.Id);
                    convertedOpportunitiesSet.add(lead.ConvertedOpportunityId);
                } else if (lead.ConvertedOpportunityId != null && lead.ConvertedOpportunity.OwnerId == currentUser.Id) {
                    if (lead.ConvertedOpportunity.OwnerId == lead.OwnerId && 
                        lead.LastTransferDate >= startDateOfPeriod && lead.LastTransferDate <= endDateOfPeriod) {
                        convertedOpportunitiesSet.add(lead.ConvertedOpportunityId);
                    } else if (lead.ConvertedOpportunity.OwnerId != lead.OwnerId && 
                        lead.ConvertedOpportunity.Last_Owner_Change_Date__c >= startDateOfPeriod && 
                        lead.ConvertedOpportunity.Last_Owner_Change_Date__c <= endDateOfPeriod.addDays(1)) {
                        convertedOpportunitiesSet.add(lead.ConvertedOpportunityId);
                    }
                }
            }

            //====
            // 3. Get All manually created Opportunities
            //====
            Map<Id, Opportunity> finalCreatedOpportunitiesMapTemp = generateOppSOQLquery('finalCreatedOpportunitiesMap', convertedOpportunitiesSet);
            Map<Id, Opportunity> finalCreatedOpportunitiesMap = new Map<Id, Opportunity>();

            for (Opportunity opp : finalCreatedOpportunitiesMapTemp.values()) {
                if (opp.Histories.size() == 0) {
                    finalCreatedOpportunitiesMap.put(opp.Id, opp);                 
                }
            }

            //Set closed won
            Set<Id> manuallyCreatedClosedWonSet = new Set<Id>();
            for (Opportunity opp : finalCreatedOpportunitiesMap.values()) {
                Date lastOwnerChangeDate = Date.newinstance(
                    opp.Last_Owner_Change_Date__c.year(), 
                    opp.Last_Owner_Change_Date__c.month(), 
                    opp.Last_Owner_Change_Date__c.day());
                if (opp.CloseDate >= lastOwnerChangeDate &&
                    opp.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    opp.StageName == 'Closed Won' && (! currentUser.UserRole.Name.contains('AllStar Sales')) &&
                    lastOwnerChangeDate >= startDateOfPeriod && lastOwnerChangeDate <= endDateOfPeriod &&
                    ! finalOpportunitiesMap.containsKey(opp.Id)) {
                    //put fake opportunity
                    finalOpportunitiesMap.put(opp.Id, new Lead());
                } else if (opp.CloseDate >= lastOwnerChangeDate &&
                    opp.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    opp.StageName == 'Closed Won' && currentUser.UserRole.Name.contains('AllStar Sales') &&
                    (selectedIndividualButton == 'TotalAR' || selectedIndividualButton == 'ARamlCheck') &&
                    lastOwnerChangeDate >= startDateOfPeriod && lastOwnerChangeDate <= endDateOfPeriod &&
                    ! finalOpportunitiesMap.containsKey(opp.Id)) {
                    //put fake opportunity
                    finalOpportunitiesMap.put(opp.Id, new Lead());
                } 
            }

            salesOpportunitiesTotal = finalOpportunitiesMap.size();

            //====
            // 4. Get All created Opportunities Credit Check
            //====
            
            //1. Select all Credit Checks where owner of credit check equals to opportunity owner and created date is in selected month to next month + 29 days
            List<OpportunityFieldHistory> fieldsHistories = generateOppFieldHistorySOQLquery();
            List<OpportunityFieldHistory> fieldsHistoriesCFstage = generateFieldHistoryCFstageSOQLquery();

            //2. Put all credit checks to map with key as Opportunity Id
            Map<Id, OpportunityFieldHistory> creditChecksMap = new Map<Id, OpportunityFieldHistory>();
            for (OpportunityFieldHistory ofh : fieldsHistories) {
                if (ofh.NewValue == 'CreditCheck' && (! currentUser.UserRole.Name.contains('AllStar Sales')) &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                } else if (ofh.NewValue == 'CreditCheck' && currentUser.UserRole.Name.contains('AllStar Sales') &&
                    (selectedIndividualButton == 'TotalAR') &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                } else if (ofh.NewValue == 'Pending Credit AML' && currentUser.UserRole.Name.contains('AllStar Sales') &&
                    selectedIndividualButton == 'ARamlCheck' &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                }
            }
            for (OpportunityFieldHistory ofh : fieldsHistoriesCFstage) {
                if (ofh.NewValue != 'Manual Scoring' && ofh.NewValue != 'Not launched' && (! currentUser.UserRole.Name.contains('AllStar Sales')) &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                }
            }

            //3. Based on key set of creditChecksMap – select all Leads that these Opportunities were converted from
            List<Lead> leadsList = generateLeadsListSOQLquery(creditChecksMap);
            
            //4. Create map where id will be Converted Opportunity Id
            Map<Id, Lead> opportunityToLeadMap = new Map<Id, Lead>();
            for (Lead lead : leadsList) {
                opportunityToLeadMap.put(lead.ConvertedOpportunityId, lead);
            }

            //5. Calculate all credit checks
            allCreditCheckSales = 0;
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
                        allCreditCheckSales++;
                    } else if (creditCheck.CreatedById != lead.OwnerId &&
                        creditCheckCreatedDate >= lastOwnerChangeDate &&
                        creditCheckCreatedDate <= lastOwnerChangeDate.addDays(28) &&
                        lastOwnerChangeDate >= startDateOfPeriod &&
                        lastOwnerChangeDate <= endDateOfPeriod) {
                        //5.1.2 If owner is NOT the same we check Last Owner Change Date from Opportunity is in selected month and 
                        // Created Date of Credit check is in period Last Owner Change Date - Last Owner Change Date + 28*
                        // * extra 1 day in formula because of DateTime field
                        allCreditCheckSales++;
                    }
                } else {
                    //5.2 If Opportunity was created manually
                    if (creditCheckCreatedDate >= lastOwnerChangeDate &&
                        creditCheckCreatedDate <= lastOwnerChangeDate.addDays(28) &&
                        lastOwnerChangeDate >= startDateOfPeriod &&
                        lastOwnerChangeDate <= endDateOfPeriod) {
                        allCreditCheckSales++;    
                    }
                }
            }


        } else if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2' ||
                   currentUser.UserRole.Name == 'Teamleiter Harte Hank' || currentUser.UserRole.Name == 'AllStar Teamleader') {
            if (currentUser.UserRole.Name.contains('Teamleiter Harte Hank')) {
                Set<String> reassignmentCountriesSet = new Set<String>{
                    'LeadAssignNL',
                    'LeadAssignBE_NL'
                };

                List<GroupMember> members = [
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.Name IN :reassignmentCountriesSet
                    LIMIT 10000];

                Set<Id> usersSet = new Set<Id>();
                for (GroupMember g : members) {
                    String currentId = String.valueOf(g.UserOrGroupId);
                    if (currentId.subString(0,3) == '005') {
                      usersSet.add(g.UserOrGroupId);
                    }
                }

                salesTeamMap = new Map<Id, User>([
                        SELECT Name
                        FROM User
                        WHERE Id IN :usersSet AND isActive = TRUE
                        LIMIT 10000]);
            } else {
                Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                        SELECT Id
                        FROM UserRole
                        WHERE ParentRoleId = :currentUser.UserRoleId
                        LIMIT 1000]);

                salesTeamMap = new Map<Id, User>([
                        SELECT Name
                        FROM User
                        WHERE UserRoleId IN :salesRolesMap.keySet() AND isActive = TRUE
                        LIMIT 10000]);

               // add additional users for Teamleiter Inbound
                if (currentUser.UserRole.Name == 'Teamleiter Inbound') {
                    String groupName = 'Approval_Rate_Dashboard_for_TL_Inbound';
                    List<User> additionalUsersList = userIdsFromGroupList(groupName);
                    salesTeamMap.putAll(additionalUsersList);
                }

                // add additional users for Teamleiter Inbound 2
                if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                    String groupName = 'Approval_Rate_Dashboard_for_TL_Inbound_2';
                    List<User> additionalUsersList = userIdsFromGroupList(groupName);
                    salesTeamMap.putAll(additionalUsersList);
                }            
            }

            //====
            // 1. Get All Opportunities and Closed Won for team
            //====

            //userToLeadsMap - map to calculate leads where Opportunity owner != Lead owner
            Map<Id, Lead> creditCheckOpportunitiesMap = new Map<Id, Lead>();
            Map<Id, Opportunity> opportunitiesForComparisonMap = new Map<Id, Opportunity>();
            Map<Id, Opportunity> allOpportunitiesMap = generateOppSOQLquery('opportunitiesMap', null);

            for (Opportunity opp : allOpportunitiesMap.values()) {
                if (! currentUser.UserRole.Name.contains('AllStar Teamleader') && opp.StageName == 'Closed Won') {
                    opportunitiesForComparisonMap.put(opp.Id, opp);
                } else if (opp.StageName == 'Closed Won' && currentUser.UserRole.Name.contains('AllStar Teamleader') &&
                    (selectedIndividualButton == 'TotalAR' || selectedIndividualButton == 'ARamlCheck')) {
                    opportunitiesForComparisonMap.put(opp.Id, opp);
                }
            }

            Set<Id> allOpportunitiesSet = new Set<Id>();
            Set<Id> finalOpportunitiesSet = new Set<Id>();
            Map<Id, Lead> convertedLeadsMap = generateLeadSOQLquery('convertedLeadsMap', allOpportunitiesMap, null);

            Map<Id, List<Opportunity>> closedWonOppsFinalMap = new Map<Id, List<Opportunity>>();
            Map<Id, Map<Id, Lead>> allConvOpportunitiesMap = new Map<Id, Map<Id, Lead>>();
            //Valid - Lead OwnerId equals to Opportunity OwnerId
            for (Lead lead : convertedLeadsMap.values()) {
                Date lastOwnerChangeDate = Date.newinstance(
                    lead.LastTransferDate.year(), 
                    lead.LastTransferDate.month(), 
                    lead.LastTransferDate.day());

                Opportunity tempOpportunity = allOpportunitiesMap.get(lead.ConvertedOpportunityId);
                if (tempOpportunity.CloseDate >= lastOwnerChangeDate &&
                    tempOpportunity.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    lead.OwnerId == tempOpportunity.OwnerId &&
                    opportunitiesForComparisonMap.containsKey(tempOpportunity.Id)) {

                    finalOpportunitiesSet.add(lead.ConvertedOpportunityId);
                    if ( ! closedWonOppsFinalMap.containsKey(tempOpportunity.OwnerId)) {
                        closedWonOppsFinalMap.put(tempOpportunity.OwnerId, new List<Opportunity>());
                    }
                    //FINAL map for valid
                    closedWonOppsFinalMap.get(tempOpportunity.OwnerId).add(tempOpportunity);
                }

                allOpportunitiesSet.add(lead.ConvertedOpportunityId);

                if ( ! allConvOpportunitiesMap.containsKey(lead.ConvertedOpportunity.OwnerId)) {
                    allConvOpportunitiesMap.put(lead.ConvertedOpportunity.OwnerId, new Map<Id, Lead>());
                }

                if (lead.OwnerId != lead.ConvertedOpportunity.OwnerId) {
                    allConvOpportunitiesMap.get(lead.ConvertedOpportunity.OwnerId).put(lead.Id, lead);
                }
            }

            //Invalid - Lead OnwerId NOT equals to Opportunity OwnerId
            for (Lead lead : convertedLeadsMap.values()) {
                Opportunity currentOpportunity = allOpportunitiesMap.get(lead.ConvertedOpportunityId);
                Date lastOwnerChangeDate = Date.newinstance(
                    currentOpportunity.Last_Owner_Change_Date__c.year(), 
                    currentOpportunity.Last_Owner_Change_Date__c.month(), 
                    currentOpportunity.Last_Owner_Change_Date__c.day());

                if (currentOpportunity.CloseDate >= lastOwnerChangeDate &&
                    currentOpportunity.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                    lead.OwnerId != currentOpportunity.OwnerId &&
                    opportunitiesForComparisonMap.containsKey(currentOpportunity.Id)) {

                    finalOpportunitiesSet.add(lead.ConvertedOpportunityId);
                    if ( ! closedWonOppsFinalMap.containsKey(currentOpportunity.OwnerId)) {
                        closedWonOppsFinalMap.put(currentOpportunity.OwnerId, new List<Opportunity>());
                    }
                    //FINAL map for valid
                    closedWonOppsFinalMap.get(currentOpportunity.OwnerId).add(currentOpportunity);
                }
            }

            //====
            // 2. Get All Leads for users
            //====
            Map<Id, Lead> finalCreatedLeadsMap = generateLeadSOQLquery('finalCreatedLeadsMap', null, allOpportunitiesSet);
            
            Set<Id> convertedOpportunitiesSet = new Set<Id>();
            for (Lead lead : finalCreatedLeadsMap.values()) {
                if (lead.ConvertedOpportunityId != null && (! salesTeamMap.containsKey(lead.ConvertedOpportunity.OwnerId))) {
                    finalCreatedLeadsMap.remove(lead.Id);
                } else {

                    if (salesTeamMap.containsKey(lead.ConvertedOpportunity.OwnerId) && lead.ConvertedOpportunityId != null) {
                    creditCheckOpportunitiesMap.put(lead.ConvertedOpportunityId, lead);
                    }
                }
                if (lead.ConvertedOpportunityId != null) {
                    convertedOpportunitiesSet.add(lead.ConvertedOpportunityId);
                }
            }

            //====
            // 3. Get All manually created Opportunities
            //====
            Map<Id, List<Opportunity>> userToManualOpportunitiesMap = new Map<Id, List<Opportunity>>();
            Map<Id, Opportunity> finalCreatedOpportunitiesMap = generateOppSOQLquery('finalCreatedOpportunitiesMap', convertedOpportunitiesSet);

            for (Opportunity opp : finalCreatedOpportunitiesMap.values()) {
                if (opp.Histories.size() == 0) {
                    if ( ! userToManualOpportunitiesMap.containsKey(opp.OwnerId) ) {
                        userToManualOpportunitiesMap.put(opp.OwnerId, new List<Opportunity>());
                    }
                    userToManualOpportunitiesMap.get(opp.OwnerId).add(opp);
                    creditCheckOpportunitiesMap.put(opp.Id, new Lead());
                }
            }

            //Set final closed won
            for (List<Opportunity> oppList : userToManualOpportunitiesMap.values()) {
                for (Opportunity opp : oppList) {
                    Date lastOwnerChangeDate = Date.newinstance(
                        opp.Last_Owner_Change_Date__c.year(), 
                        opp.Last_Owner_Change_Date__c.month(), 
                        opp.Last_Owner_Change_Date__c.day());
                    if (opp.CloseDate >= lastOwnerChangeDate &&
                        opp.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                        opp.StageName == 'Closed Won' && (! currentUser.UserRole.Name.contains('AllStar Teamleader')) &&
                        lastOwnerChangeDate >= startDateOfPeriod && lastOwnerChangeDate <= endDateOfPeriod &&
                        ! finalOpportunitiesSet.contains(opp.Id)) {
                        if ( ! closedWonOppsFinalMap.containsKey(opp.OwnerId)) {
                            closedWonOppsFinalMap.put(opp.OwnerId, new List<Opportunity>());
                        }
                        closedWonOppsFinalMap.get(opp.OwnerId).add(opp);
                    } else if (opp.CloseDate >= lastOwnerChangeDate &&
                        opp.CloseDate <= lastOwnerChangeDate.addDays(28) &&
                        opp.StageName == 'Closed Won' && currentUser.UserRole.Name.contains('AllStar Teamleader') &&
                        (selectedIndividualButton == 'TotalAR' || selectedIndividualButton == 'ARamlCheck') &&
                        lastOwnerChangeDate >= startDateOfPeriod && lastOwnerChangeDate <= endDateOfPeriod &&
                        ! finalOpportunitiesSet.contains(opp.Id)) {
                        if ( ! closedWonOppsFinalMap.containsKey(opp.OwnerId)) {
                            closedWonOppsFinalMap.put(opp.OwnerId, new List<Opportunity>());
                        }
                        closedWonOppsFinalMap.get(opp.OwnerId).add(opp);
                    }
                }
            }


            //1. Select all Credit Checks where owner of credit check equals to opportunity owner and created date is in selected month to next month + 29 days
            List<OpportunityFieldHistory> fieldsHistories = generateOppFieldHistorySOQLquery();
            List<OpportunityFieldHistory> fieldsHistoriesCFstage = generateFieldHistoryCFstageSOQLquery();

            //2. Put all credit checks to map with key as Opportunity Id
            Map<Id, OpportunityFieldHistory> creditChecksMap = new Map<Id, OpportunityFieldHistory>();
            for (OpportunityFieldHistory ofh : fieldsHistories) {
                if (ofh.NewValue == 'CreditCheck' && (! currentUser.UserRole.Name.contains('AllStar Teamleader')) &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                } else if (ofh.NewValue == 'CreditCheck' && currentUser.UserRole.Name.contains('AllStar Teamleader') &&
                    (selectedIndividualButton == 'TotalAR') &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                } else if (ofh.NewValue == 'Pending Credit AML' && currentUser.UserRole.Name.contains('AllStar Teamleader') &&
                    selectedIndividualButton == 'ARamlCheck' &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                }
            }
            for (OpportunityFieldHistory ofh : fieldsHistoriesCFstage) {
                if (ofh.NewValue != 'Manual Scoring' && ofh.NewValue != 'Not launched' && (! currentUser.UserRole.Name.contains('AllStar Teamleader')) &&
                    ! creditChecksMap.containsKey(ofh.OpportunityId)) {
                    creditChecksMap.put(ofh.OpportunityId, ofh);
                }
            }

            //3. Based on key set of creditChecksMap – select all Leads that these Opportunities were converted from
            List<Lead> leadsList = generateLeadsListSOQLquery(creditChecksMap);
            
            //4. Create map where id will be Converted Opportunity Id
            Map<Id, Lead> opportunityToLeadMap = new Map<Id, Lead>();
            for (Lead lead : leadsList) {
                opportunityToLeadMap.put(lead.ConvertedOpportunityId, lead);
            }

            Map<Id, Set<Id>> allCreditCheckSalesMap = new Map<Id, Set<Id>>();
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
                        if (! allCreditCheckSalesMap.containsKey(creditCheck.Opportunity.OwnerId)) {
                            allCreditCheckSalesMap.put(creditCheck.Opportunity.OwnerId, new Set<Id>());
                        }
                        allCreditCheckSalesMap.get(creditCheck.Opportunity.OwnerId).add(creditCheck.OpportunityId);
                    } else if (creditCheck.CreatedById != lead.OwnerId &&
                        creditCheckCreatedDate >= lastOwnerChangeDate &&
                        creditCheckCreatedDate <= lastOwnerChangeDate.addDays(28) &&
                        lastOwnerChangeDate >= startDateOfPeriod &&
                        lastOwnerChangeDate <= endDateOfPeriod) {
                        //5.1.2 If owner is NOT the same we check Last Owner Change Date from Opportunity is in selected month and 
                        // Created Date of Credit check is in period Last Owner Change Date - Last Owner Change Date + 28*
                        // * extra 1 day in formula because of DateTime field
                        if (! allCreditCheckSalesMap.containsKey(creditCheck.Opportunity.OwnerId)) {
                            allCreditCheckSalesMap.put(creditCheck.Opportunity.OwnerId, new Set<Id>());
                        }
                        allCreditCheckSalesMap.get(creditCheck.Opportunity.OwnerId).add(creditCheck.OpportunityId);
                    }     
                } else {
                    //5.2 If Opportunity was created manually
                    if (creditCheckCreatedDate >= lastOwnerChangeDate &&
                        creditCheckCreatedDate <= lastOwnerChangeDate.addDays(28) &&
                        lastOwnerChangeDate >= startDateOfPeriod &&
                        lastOwnerChangeDate <= endDateOfPeriod) {
                        if (! allCreditCheckSalesMap.containsKey(creditCheck.Opportunity.OwnerId)) {
                            allCreditCheckSalesMap.put(creditCheck.Opportunity.OwnerId, new Set<Id>());
                        }
                        allCreditCheckSalesMap.get(creditCheck.Opportunity.OwnerId).add(creditCheck.OpportunityId);    
                    }
                }
            }
            ///FINAL
            for (Id userId : salesTeamMap.keySet()) {
                if ( ! closedWonOppsFinalMap.containsKey(userId)) {
                    closedWonOppsFinalMap.put(userId,new List<Opportunity>());
                }

                if ( ! allCreditCheckSalesMap.containsKey(userId)) {
                    allCreditCheckSalesMap.put(userId, new Set<Id>());
                }            
            }

            for (String uid : closedWonOppsFinalMap.keySet()) {
                finalList.add(new FinalList(
                    uid,
                    closedWonOppsFinalMap.get(uid).size()));

                closedWonOpps.put(uid, closedWonOppsFinalMap.get(uid).size());
                allCreditCheck.put(uid, allCreditCheckSalesMap.get(uid).size());
            }

            finalList.sort();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid User Role'));
        }  
    }


    /*******************************************************************************
    *  Name            : generateOppSOQLquery(String queryTarget, Set<Id> opportunitiesSet)
    *  Summary         : generate soql query for select Opportunity from database    
    *  CreatedDate     : 05/12/2017
    *  Parameters      : String queryTarget, Set<Id> opportunitiesSet   
    *  Returns         : Map<Id, Opportunity>
    ******************************************************************************/
    public Map<Id, Opportunity> generateOppSOQLquery(String queryTarget, Set<Id> opportunitiesSet) {
        Date days_out_1 = endDateOfPeriod.addDays(1);
        Date days_out_28 = endDateOfPeriod.addDays(28);
        String currentUserId = currentUser.Id;
        Set<Id> usersIdsSet = new Set<Id>();
        if (salesTeamMap != null) {
            usersIdsSet = salesTeamMap.keySet();
        }

        String theQuery = 'SELECT OwnerId, CloseDate, Last_Owner_Change_Date__c, StageName';

        if (queryTarget == 'opportunitiesMap') {
            theQuery += ' FROM Opportunity ' +
                        'WHERE ((CloseDate >= :startDateOfPeriod AND CloseDate <= :days_out_28) OR ' +
                            '(Last_Owner_Change_Date__c >= :startDateOfPeriod AND Last_Owner_Change_Date__c <= :days_out_1)) AND ';  
        } else if (queryTarget == 'finalCreatedOpportunitiesMap') {      
            theQuery += ', (SELECT Field FROM Histories WHERE Field = \'opportunityCreatedFromLead\') ' +
                        'FROM Opportunity ' +
                        'WHERE Id NOT IN :opportunitiesSet AND ' +
                            'Last_Owner_Change_Date__c >= :startDateOfPeriod AND Last_Owner_Change_Date__c <= :days_out_1 AND ';
        }

        theQuery += '(Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\' OR Sec_Channel__c = \'Partner\') AND ' +
                    'Disable_for_KPI__c = FALSE AND ' +
                    'Disable_for_Approval_Rate__c = FALSE AND ' +
                    'Gruende_verloren__c != \'Duplicate\' AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || currentUser.UserRole.Name.contains('AllStar Sales')) {
            theQuery += 'OwnerId = :currentUserId AND ';
            if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2')) {
                theQuery += '(RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')';
            } else {
                theQuery += 'RecordType.Name = \'AllStar\'';
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2' ||
            currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'OwnerId IN :usersIdsSet AND ';
            if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                theQuery += '(RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')';
            } else {
                theQuery += 'RecordType.Name = \'AllStar\'';
            }
        }
        theQuery += ' LIMIT 50000';
        
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
    *  CreatedDate     : 06/12/2017
    *  Parameters      : String queryTarget, Map<Id, Opportunity> oppMap, Set<Id> oppSet
    *  Returns         : Map<Id, Lead>
    ******************************************************************************/
    public Map<Id, Lead> generateLeadSOQLquery(String queryTarget, Map<Id, Opportunity> oppMap, Set<Id> oppSet) {    
        String currentUserId = currentUser.Id; 
        Set<Id> opptyIdsSet = new Set<Id>();
        if (oppMap != null) {
            opptyIdsSet = oppMap.keyset();
        }
        Set<Id> usersIdsSet = new Set<Id>();
        if (salesTeamMap != null) {
            usersIdsSet = salesTeamMap.keyset();
        }

        String theQuery = 'SELECT OwnerId, ConvertedOpportunityId, FirstName, LastName, Last_Owner_Change_Date__c, IsConverted, Channel__c, Sec_Channel__c, ' +
                           'LeadSource, Status, LastTransferDate, ConvertedOpportunity.Last_Owner_Change_Date__c, ConvertedOpportunity.OwnerId, Quali_Status__c ' +
                        'FROM Lead ' +
                        'WHERE LastTransferDate >= :startDateOfPeriod AND LastTransferDate <= :endDateOfPeriod AND ' +
                            '(Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\' OR Sec_Channel__c = \'Partner\') AND ' +
                            'Quali_Status__c NOT IN :leadQualiStatusesSet AND ' +
                            'LeadSource != \'Adressbroker\' AND ' +  
                            'LeadSource != \'Bestandskunde Shell\' AND ' + 
                            'LeadSource != \'Online_chat\' AND ' +
                            'Disable_for_KPI__c = FALSE AND ' +
                            'Disable_for_Approval_Rate__c = FALSE AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || currentUser.UserRole.Name.contains('AllStar Sales')) {
            if (queryTarget == 'convertedLeadsMap') {
                theQuery += 'ConvertedOpportunityId IN :opptyIdsSet AND ';
            } else if (queryTarget == 'finalCreatedLeadsMap') {
                theQuery += '(ConvertedOpportunityId IN :oppSet OR OwnerId = :currentUserId) AND ';
            }
            if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2')) {
                theQuery += 'RecordType.Name = \'Endkunde\'';         
            } else {
                theQuery += 'RecordType.Name = \'AllStar\'';
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2' || currentUser.UserRole.Name == 'AllStar Teamleader') {
            if (queryTarget == 'convertedLeadsMap') {
                theQuery += 'ConvertedOpportunityId IN :opptyIdsSet AND ';
            } else if (queryTarget == 'finalCreatedLeadsMap') {
                theQuery += '(ConvertedOpportunityId IN :oppSet OR OwnerId IN :usersIdsSet) AND ';
            }
            if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                theQuery += 'RecordType.Name = \'Endkunde\'';
            } else {
                theQuery += 'RecordType.Name = \'AllStar\'';
            }
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
    *  CreatedDate     : 06/12/2017 
    *  Parameters      : -
    *  Returns         : List<OpportunityFieldHistory>
    ******************************************************************************/
    public List<OpportunityFieldHistory> generateOppFieldHistorySOQLquery() {
        Date days_out_29 = endDateOfPeriod.addDays(29);
        String currentUserId = currentUser.Id;
        Set<Id> usersIdsSet = new Set<Id>();
        if (salesTeamMap != null) {
            usersIdsSet = salesTeamMap.keyset();
        }

        String theQuery = 'SELECT Field, OpportunityId, NewValue, CreatedDate, Opportunity.Last_Owner_Change_Date__c, CreatedById, Opportunity.Sec_Channel__c, Opportunity.OwnerId ' +
                            'FROM OpportunityFieldHistory ' +
                            'WHERE Field = \'StageName\' AND ' +
                                'CreatedDate >= :startDateOfPeriod AND ' +
                                'CreatedDate <= :days_out_29 AND ' +       
                                '(Opportunity.Sec_Channel__c = \'Inbound\' OR Opportunity.Sec_Channel__c = \'JITB\' OR Opportunity.Sec_Channel__c = \'Partner\') AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || currentUser.UserRole.Name.contains('AllStar Sales')) {
            theQuery += 'CreatedById = :currentUserId AND ' +
                        'Opportunity.OwnerId = :currentUserId AND ';
            if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2')) {
                theQuery += '(Opportunity.RecordType.Name = \'Euroshell\' OR Opportunity.RecordType.Name = \'Euroshell Starts\')';
            } else {
                theQuery += 'Opportunity.RecordType.Name = \'AllStar\'';
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2' ||
            currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'Opportunity.OwnerId = :usersIdsSet AND ';
            if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                theQuery += '(Opportunity.RecordType.Name = \'Euroshell\' OR Opportunity.RecordType.Name = \'Euroshell Starts\')';
            } else {
                theQuery += 'Opportunity.RecordType.Name = \'AllStar\'';
            }
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
    *  CreatedDate     : 06/12/2017 
    *  Parameters      : -
    *  Returns         : List<OpportunityFieldHistory>
    ******************************************************************************/    
    public List<OpportunityFieldHistory> generateFieldHistoryCFstageSOQLquery() {
        Date days_out_29 = endDateOfPeriod.addDays(29);
        String currentUserId = currentUser.Id;
        Set<Id> usersIdsSet = new Set<Id>();
        if (salesTeamMap != null) {
            usersIdsSet = salesTeamMap.keyset();
        }

        String theQuery = 'SELECT Field, OpportunityId, NewValue, CreatedDate, Opportunity.Last_Owner_Change_Date__c, CreatedById, Opportunity.Sec_Channel__c, Opportunity.OwnerId ' +
                            'FROM OpportunityFieldHistory ' +
                            'WHERE Field = \'CF_Stage__c\' AND ' +
                                'CreatedDate >= :startDateOfPeriod AND ' +
                                'CreatedDate <= :days_out_29 AND ' +
                                '(Opportunity.Sec_Channel__c = \'Inbound\' OR Opportunity.Sec_Channel__c = \'JITB\' OR Opportunity.Sec_Channel__c = \'Partner\') AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || currentUser.UserRole.Name.contains('AllStar Sales')) {
            theQuery += 'CreatedById = :currentUserId AND ' +
                        'Opportunity.OwnerId = :currentUserId AND ';
            if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2')) {
                theQuery += '(Opportunity.RecordType.Name = \'Euroshell\' OR Opportunity.RecordType.Name = \'Euroshell Starts\')';
            } else {
                theQuery += 'Opportunity.RecordType.Name = \'AllStar\'';
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2' ||
            currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'Opportunity.OwnerId = :usersIdsSet AND ';
            if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                theQuery += '(Opportunity.RecordType.Name = \'Euroshell\' OR Opportunity.RecordType.Name = \'Euroshell Starts\')';
            } else {
                theQuery += 'Opportunity.RecordType.Name = \'AllStar\'';
            }
        }
        theQuery += ' ORDER BY CreatedDate DESC ' +
                    'LIMIT 25000';

        List<OpportunityFieldHistory> oppFieldsHistoriesCFstageList = new List<OpportunityFieldHistory>();
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
    *  CreatedDate     : 06/12/2017  
    *  Parameters      : Map<Id, OpportunityFieldHistory> creditChecksMap
    *  Returns         : List<Lead> leadList
    ******************************************************************************/
    public List<Lead> generateLeadsListSOQLquery(Map<Id, OpportunityFieldHistory> creditChecksMap) {
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
                                'Quali_Status__c != \'Sent to support\' AND ' +
                                'Quali_Status__c != \'Not a legal entity\' AND ' +
                                'Quali_Status__c != \'Sent to Shell\' AND ' +
                                'LeadSource != \'Online_chat\' AND ' +
                                'Quali_Status__c != \'Spam\' AND ' +
                                'Quali_Status__c != \'No reply – Quick Process\' AND ' +
                                'Quali_Status__c != \'Offer sent\' AND ' +
                                'Disable_for_KPI__c = FALSE AND ' +
                                'Disable_for_Approval_Rate__c = FALSE AND ';

        if (currentUser.UserRole.Name.contains('Salesteam Inbound') || currentUser.UserRole.Name.contains('Salesteam Inbound 2') || 
            currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            theQuery += 'RecordType.Name = \'Endkunde\'';
        } else if (currentUser.UserRole.Name.contains('AllStar Sales') || currentUser.UserRole.Name == 'AllStar Teamleader') {
            theQuery += 'RecordType.Name = \'AllStar\'';
        }

        theQuery = theQuery.removeEnd('AND ');
        theQuery += ' LIMIT 25000';

        List<Lead> leadList = new List<Lead>();
        try {
            leadList = (List<Lead>)Database.query(theQuery);
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return leadList;   
    }


    /*******************************************************************************
    *  Name            : List<User> userIdsFromGroupList (String groupName)
    *  Summary         : return user id's list from public group    
    *  CreatedDate     : 19/04/2017
    *  Parameters      : String groupName
    *  Returns         : List<User>
    ******************************************************************************/
    public static List<User> userIdsFromGroupList (String groupName) {
        // store the results in a set so we don't get duplicates
        Set<Id> userIdsSet = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        // Loop through all group members in a group
        for (GroupMember m : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :groupName]) {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType)) {
                userIdsSet.add(m.UserOrGroupId);
            }
        }
        List<User> addUsersForDashboardTLInboundList = [
            SELECT Id, Name
            FROM User
            WHERE Id IN :userIdsSet AND
                  isActive = TRUE               
            LIMIT 50000];

        return addUsersForDashboardTLInboundList;  
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 26/12/2016
    *  Parameters      : 
    *  Returns         : String – year
    ******************************************************************************/
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


    public void changeYear() {
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
            this.selectedPeriod = firstMonthId;
        } else {
            this.selectedPeriod = currentWeekId;
        }
        init();       
    }


    /*******************************************************************************
    *  Name            : getYears()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 26/12/2016
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
            
            options.add(new SelectOption(week.Id, 
                                        '---' + week.Fleetcor_Calendar_Month__r.Name + ' (' + week.Start_Date__c.day() + '.' + week.Start_Date__c.month() + ' - ' + 
                                        week.End_Date__c.day() + '.' + week.End_Date__c.month() + ')'));
        }

        return options;
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

    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
    }


    /*******************************************************************************
    *  Name            : getIndividualARButtons
    *  Summary         : additional radio buttons for Approval Rate 
    *  CreatedDate     : 27/05/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getIndividualARButtons() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('ARamlCheck', 'Approval Rate for AML Check'));
        options.add(new SelectOption('TotalAR', 'Total Approval Rate'));

        return options;
    }

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
        'Offer sent'
    };

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
        12 => 'December'
    };

    private Map<String, Integer> monthsMapRev = new Map<String, Integer>{
        'January' => 1, 
        'February' => 2, 
        'March' => 3,
        'April' => 4,
        'May' => 5,
        'June' => 6,
        'July' => 7,
        'August' => 8,
        'September' => 9,
        'October' => 10,
        'November' => 11,
        'December' => 12
    };
}