public with sharing class LeadProcessingTimeReportController {
    public List<LeadWrapper> leadsListWrapper {get; set;}
    public List<LeadWrapper> leadsToProcessListWrapper {get; set;}
    public Map<Id, Lead> excludedLeadsMap {get; set;}
    public Integer numberExcludedLeads {get; set;}
    public static BusinessHours defaultBH {get; set;}
    public Decimal timeofProcess {get; set;}
    public String selectedSecChannel {get; set;}
    public String channelFilter {get; set;}
    
    private Set<String> reassignmentCountriesSet;
    private String userId;

    public LeadProcessingTimeReportController() {
        
    }

    public void init() {
        returnUserId();
        Date startDate = Date.valueOf(ApexPages.currentPage().getParameters().get('start'));
        Date endDate = Date.valueOf(ApexPages.currentPage().getParameters().get('end'));
        String country = ApexPages.currentPage().getParameters().get('country');
        this.selectedSecChannel = ApexPages.CurrentPage().getparameters().get('selectedSecChannel');

        leadsListWrapper = new List<LeadWrapper>();
        leadsToProcessListWrapper = new List<LeadWrapper>();

        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        Map<Id, Lead> leadsToProcessMap = new Map<Id, Lead>();
        User currentUser = [SELECT Profile.Name, UserRole.Name, LocaleSidKey, Name FROM User WHERE Id = :userId];
        if (currentUser.UserRole.Name == 'Teamleiter Inbound' || currentUser.UserRole.Name == 'AllStar Teamleader') {
            Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId = :currentUser.UserRoleId
                LIMIT 1000]);

            Map<Id, User> salesTeamMap;
            Map<Id, Group> queuesMap;
            Set<Id> usersSet = new Set<Id>();
            Set<Id> userTotalSet = new Set<Id>();

            if (currentUser.UserRole.Name == 'Teamleiter Inbound') {
                queuesMap = new Map<Id, Group>([
                    SELECT Id
                    FROM Group
                    WHERE Name IN :inbound1QueuesSet
                    LIMIT 10000]);

                List<GroupMember> members = [
                        SELECT UserOrGroupId
                        FROM GroupMember
                        WHERE Group.Name IN :inbound1QueuesSet
                        LIMIT 10000];

                salesTeamMap = new Map<Id, User>([
                    SELECT Name
                    FROM User
                    WHERE UserRoleId IN :salesRolesMap.keySet() AND 
                          isActive = TRUE
                    LIMIT 10000]);

                // add additional users for Teamleiter Inbound
                String groupName = 'Processing_Time_Dashboard_for_TL_Inbound';
                List<User> additionalUsersList = userIdsFromGroupList(groupName);
                salesTeamMap.putAll(additionalUsersList);

                for (String userId : salesTeamMap.keySet()) {
                    usersSet.add(userId);
                    userTotalSet.add(userId);
                }
                for (String queueId : queuesMap.keySet()) {
                    usersSet.add(queueId);
                    userTotalSet.add(queueId);
                }     
                for (GroupMember g : members) {
                String currentId = String.valueOf(g.UserOrGroupId);
                if (currentId.subString(0,3) == '005') {
                    userTotalSet.add(g.UserOrGroupId);
                }
            } 
            } else if (currentUser.UserRole.Name == 'AllStar Teamleader') {
                queuesMap = new Map<Id, Group>([
                    SELECT Id
                    FROM Group
                    WHERE Name = 'LeadAssignAllStar'
                    LIMIT 10000]);

                salesTeamMap = new Map<Id, User>([
                    SELECT Name
                    FROM User
                    WHERE UserRoleId IN :salesRolesMap.keySet() AND 
                          isActive = TRUE
                    LIMIT 10000]);

                for (String userId : salesTeamMap.keySet()) {
                    usersSet.add(userId);
                }
                for (String queueId : queuesMap.keySet()) {
                    usersSet.add(queueId);
                }
            }

            leadsMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND
                        Country = :country AND  
                        OwnerId IN :usersSet AND
                        First_Call__c != NULL AND
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND
                        First_Call__c >= :startDate AND First_Call__c < :endDate.addDays(1) AND
                        Disable_for_Processing_Time__c = FALSE
                ORDER BY CreatedDate DESC
                LIMIT 50000]);

            leadsToProcessMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail') AND Country = :country) OR 
                        (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet' AND Country = :country) OR 
                        (Sec_Channel__c = 'Partner' AND Country = :country)) AND 
                        (Recycle_counter__c = 0 OR Recycle_counter__c = NULL) AND 
                        RecordType.Name = 'Endkunde' AND          
                        isConverted = FALSE AND 
                        Status = 'Open' AND 
                        OwnerId IN :userTotalSet AND 
                        First_Call__c = NULL AND 
                        Last_Owner_Change_Date__c != NULL AND  
                        LeadSource != 'Online_chat'
                ORDER BY CreatedDate DESC
                LIMIT 50000]);

            this.excludedLeadsMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c, Disable_for_Processing_Time__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND
                        Country = :country AND 
                        OwnerId IN :usersSet AND
                        (First_Call__c = NULL OR (First_Call__c != NULL AND First_Call__c >= :startDate AND First_Call__c < :endDate.addDays(1))) AND 
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND 
                        Disable_for_Processing_Time__c = TRUE
                ORDER BY CreatedDate DESC
                LIMIT 1000]);

            this.numberExcludedLeads = this.excludedLeadsMap.size();
            
            Map<Id, Lead> finalLeadsMap = new Map<Id, Lead>();
            if (! leadsMap.isEmpty()) {
                for (Lead lead : leadsMap.values()){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalLeadsMap.put(lead.Id, lead);
                    }
                }
                leadsMap = finalLeadsMap;
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
            Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId = :currentUser.UserRoleId
                LIMIT 1000]);

            Map<Id, Group> queuesMap = new Map<Id, Group>([
                    SELECT Id
                    FROM Group
                    WHERE Name IN :inbound2QueuesSet
                    LIMIT 10000]);

            List<GroupMember> members = [
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.Name IN :inbound2QueuesSet
                    LIMIT 10000];

            Map<Id, User> salesTeamMap = new Map<Id, User>([
                    SELECT Name
                    FROM User
                    WHERE UserRoleId IN :salesRolesMap.keySet() AND
                          isActive = TRUE
                    LIMIT 10000]);

            // add additional users for Teamleiter Inbound 2
            String groupName = 'Processing_Time_Dashboard_for_TL_Inb_2';
            List<User> additionalUsersList = userIdsFromGroupList(groupName);
            salesTeamMap.putAll(additionalUsersList);

            Set<Id> usersSet = new Set<Id>();
            Set<Id> userTotalSet = new Set<Id>();
            for (String userId : salesTeamMap.keySet()) {
                usersSet.add(userId);
                userTotalSet.add(userId);
            }
            for (String queueId : queuesMap.keySet()) {
                usersSet.add(queueId);
                userTotalSet.add(queueId);
            }
            for (GroupMember g : members) {
                String currentId = String.valueOf(g.UserOrGroupId);
                if (currentId.subString(0,3) == '005') {
                    userTotalSet.add(g.UserOrGroupId);
                }
            }

            leadsMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND
                        Country = :country AND  
                        OwnerId IN :usersSet AND
                        First_Call__c != NULL AND
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND
                        First_Call__c >= :startDate AND First_Call__c < :endDate.addDays(1) AND
                        Disable_for_Processing_Time__c = FALSE
                ORDER BY CreatedDate DESC
                LIMIT 50000]);

            leadsToProcessMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c
                FROM Lead 
                WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                        Channel__c != 'Anruf' AND 
                        Country = :country AND 
                        (Recycle_counter__c = 0 OR Recycle_counter__c = NULL) AND
                        RecordType.Name = 'Endkunde' AND
                        isConverted = FALSE AND
                        Status = 'Open' AND
                        OwnerId IN :userTotalSet AND
                        First_Call__c = NULL AND 
                        Last_Owner_Change_Date__c != NULL AND
                        LeadSource != 'Online_chat'
                ORDER BY CreatedDate DESC
                LIMIT 50000]);

            this.excludedLeadsMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c, Disable_for_Processing_Time__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND
                        Country = :country AND 
                        OwnerId IN :usersSet AND
                        (First_Call__c = NULL OR (First_Call__c != NULL AND First_Call__c >= :startDate AND First_Call__c < :endDate.addDays(1))) AND 
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND 
                        Disable_for_Processing_Time__c = TRUE
                ORDER BY CreatedDate DESC
                LIMIT 1000]);

            this.numberExcludedLeads = this.excludedLeadsMap.size();
            
            Map<Id, Lead> finalLeadsMap = new Map<Id, Lead>();
            if (! leadsMap.isEmpty()) {
                for (Lead lead : leadsMap.values()){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalLeadsMap.put(lead.Id, lead);
                    }
                }
                leadsMap = finalLeadsMap;
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Harte Hank') {
            reassignmentCountriesSet = new Set<String>{
                'LeadAssignFR'
            };

            List<GroupMember> members = [
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.Name IN :reassignmentCountriesSet
                LIMIT 10000];
            List<Group> queuesList = [
                SELECT Name, (SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMembers)
                FROM Group 
                WHERE Name IN :reassignmentCountriesSet
                LIMIT 10000];

            Set<Id> usersSet = new Set<Id>();
            for (GroupMember g : members) {
                String currentId = String.valueOf(g.UserOrGroupId);
                if (currentId.subString(0,3) == '005') {
                  usersSet.add(g.UserOrGroupId);
                }
            }
            for (Group g : queuesList) {
                usersSet.add(g.Id);            
            }
            
            // add additional users for Teamleiter Harte Hanks
            String groupName = 'Processing_Time_Dashboard_for_TL_HH';
            List<User> additionalUsersList = userIdsFromGroupList(groupName);
            for (User us : additionalUsersList) {
                usersSet.add(us.Id);
            }

            leadsMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND 
                        Country = :country AND 
                        OwnerId IN :usersSet AND
                        First_Call__c != NULL AND
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND
                        First_Call__c >= :startDate AND First_Call__c < :endDate.addDays(1) AND
                        Disable_for_Processing_Time__c = FALSE
                ORDER BY CreatedDate DESC
                LIMIT 50000]);

            leadsToProcessMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND 
                        Country = :country AND 
                        OwnerId IN :usersSet AND 
                        First_Call__c = NULL AND 
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND 
                        Quali_Status__c != 'Not a legal entity' AND
                        IsConverted = FALSE AND
                        Status = 'Open' AND
                        Disable_for_Processing_Time__c = FALSE
                ORDER BY CreatedDate DESC
                LIMIT 50000]);

            this.excludedLeadsMap = new Map<Id, Lead>([
                SELECT CreatedDate, First_Call__c, Country, OwnerId, Owner.Name,
                       Sec_Channel__c, Channel__c, Name, LeadSource, IsConverted,
                       Status, Site_Agg_product__c, Disable_for_Processing_Time__c
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND
                        Country = :country AND 
                        OwnerId IN :usersSet AND
                        (First_Call__c = NULL OR (First_Call__c != NULL AND First_Call__c >= :startDate AND First_Call__c < :endDate.addDays(1))) AND 
                        LeadSource != 'Online_chat' AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND 
                        Disable_for_Processing_Time__c = TRUE
                ORDER BY CreatedDate DESC
                LIMIT 1000]);

            this.numberExcludedLeads = this.excludedLeadsMap.size();

            Map<Id, Lead> finalLeadsMap = new Map<Id, Lead>();
            if (! leadsMap.isEmpty()) {
                for (Lead lead : leadsMap.values()){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalLeadsMap.put(lead.Id, lead);
                    }
                }
                leadsMap = finalLeadsMap;
            }

            Map<Id, Lead> finalLeadsToProcessMap = new Map<Id, Lead>();
            if (! leadsToProcessMap.isEmpty()) {
                for (Lead lead : leadsToProcessMap.values()){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalLeadsToProcessMap.put(lead.Id, lead);
                    }
                }
                leadsToProcessMap = finalLeadsToProcessMap;
            }
        }

        Map<Id, Lead> finalLeadsMap = new Map<Id, Lead>();
        if (! leadsMap.isEmpty()) {
            for (Lead lead : leadsMap.values()){
                if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                    finalLeadsMap.put(lead.Id, lead);
                }
            }
            leadsMap = finalLeadsMap;
        }

        Map<Id, Lead> finalLeadsToProcessMap = new Map<Id, Lead>();
        if (! leadsToProcessMap.isEmpty()) {
            for (Lead lead : leadsToProcessMap.values()){
                if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                    finalLeadsToProcessMap.put(lead.Id, lead);
                }
            }
            leadsToProcessMap = finalLeadsToProcessMap;
            }

        List<BusinessHours> businessHoursList = [
            SELECT Id, Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayEndTime, WednesdayStartTime,
                   ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime,
                   SundayEndTime, SundayStartTime
            FROM BusinessHours
            LIMIT 10000];

        Map<String, BusinessHours> localeBusinessHoursMap = new Map<String, BusinessHours>();
        for (BusinessHours bh : businessHoursList) {
            if (bh.Name == 'CZ') {
                localeBusinessHoursMap.put('cs_CZ', bh); 
            } else if (bh.Name == 'SK') {
                localeBusinessHoursMap.put('sk_SK', bh);
            } else if (bh.Name == 'HU') {
                localeBusinessHoursMap.put('hu_HU', bh);
            } else if (bh.Name == 'PL') {
                localeBusinessHoursMap.put('pl_PL', bh);
            } else if (bh.Name == 'Default') {
                localeBusinessHoursMap.put('Default', bh);
            }
        }

        Set<Id> currentUserOwnerLeadsIdSet = new Set<Id>();
        Set<Id> currentQueuesOwnerLeadsIdSet = new Set<Id>();
        for (Lead lead : leadsMap.values()) {
            if (String.valueOf(lead.OwnerId).subString(0,3) == '005') {
                currentUserOwnerLeadsIdSet.add(lead.OwnerId);
            } else {
                currentQueuesOwnerLeadsIdSet.add(lead.OwnerId);
            }   
        }
        for (Lead lead : leadsToProcessMap.values()) {
            if (String.valueOf(lead.OwnerId).subString(0,3) == '005') {
                currentUserOwnerLeadsIdSet.add(lead.OwnerId);
            } else {
                currentQueuesOwnerLeadsIdSet.add(lead.OwnerId);
            }   
        }

        List<User> currentUserList = [
            SELECT Id, Name, LocaleSidKey
            FROM User
            WHERE Id IN :currentUserOwnerLeadsIdSet
            LIMIT 10000];

        List<Group> currentQueuesList = [
            SELECT Id
            FROM Group
            WHERE Id IN :currentQueuesOwnerLeadsIdSet
            LIMIT 10000]; 

        Map<String, BusinessHours> businessHoursForUsersMap = new Map<String, BusinessHours>();
        for (User us : currentUserList) {
            if (! currentUserList.isEmpty()) {
                if (us.LocaleSidKey == 'cs_CZ' || us.LocaleSidKey == 'cs_CZ_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('cs_CZ'));
                } else if (us.LocaleSidKey == 'sk_SK' || us.LocaleSidKey == 'sk_SK_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('sk_SK'));
                } else if (us.LocaleSidKey == 'hu_HU' || us.LocaleSidKey == 'hu_HU_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('hu_HU'));
                } else if (us.LocaleSidKey == 'pl_PL' || us.LocaleSidKey == 'pl_PL_EURO') {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('pl_PL'));
                } else {
                    businessHoursForUsersMap.put(us.Id, localeBusinessHoursMap.get('Default'));
                }
            }     
        }

        for (Group gr : currentQueuesList) {
            if (! currentQueuesList.isEmpty()) {
                businessHoursForUsersMap.put(gr.Id, localeBusinessHoursMap.get('Default'));
            }
        }   

        
        this.timeofProcess = 0;
        Integer counter = 0;
        if (this.selectedSecChannel == 'Inbound in bh') {
            this.channelFilter = 'Sec Channel: Inbound AND (Channel: Internet OR Channel: E-mail)';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'Inbound not in bh') {
            this.channelFilter = 'Sec Channel: Inbound AND (Channel: Internet OR Channel: E-mail)';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'Inbound Total') {
            this.channelFilter = 'Sec Channel: Inbound AND (Channel: Internet OR Channel: E-mail)';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound') {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound') {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'JITB in bh') {
            this.channelFilter = 'Sec Channel: JITB AND Channel: Internet';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'JITB' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'JITB not in bh') {
            this.channelFilter = 'Sec Channel: JITB AND Channel: Internet';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'JITB' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'JITB' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'JITB Total') {
            this.channelFilter = 'Sec Channel: JITB AND Channel: Internet';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'JITB') {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'JITB') {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'Partner in bh') {
            this.channelFilter = 'Sec Channel: Partner';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Partner' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Partner' && BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'Partner not in bh') {
            this.channelFilter = 'Sec Channel: Partner';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Partner' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Partner' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate)) {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'Partner Total') {
            this.channelFilter = 'Sec Channel: Partner';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'Partner') {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'Partner') {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        } else if (this.selectedSecChannel == 'Total') {
            this.channelFilter = '((Sec Channel: Inbound OR Sec Channel: JITB) AND (Channel: Internet OR Channel: E-mail)) OR Sec Channel: Partner';
            for (Lead lead : leadsMap.values()) {
                if (lead.Sec_Channel__c == 'JITB' || lead.Sec_Channel__c == 'Inbound' || lead.Sec_Channel__c == 'Partner') {
                    leadsListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
            for (Lead lead : leadsToProcessMap.values()) {
                if (lead.Sec_Channel__c == 'JITB' || lead.Sec_Channel__c == 'Inbound' || lead.Sec_Channel__c == 'Partner') {
                    leadsToProcessListWrapper.add(new LeadWrapper(lead, businessHoursForUsersMap, this.selectedSecChannel));
                }
            }
        }

        for (LeadWrapper lw : leadsListWrapper){
            this.timeofProcess += lw.diff;
            counter++;
        }

        if(counter != 0) {
            this.timeofProcess = (this.timeofProcess/counter).setScale(2);
        } else {
            this.timeofProcess = 0;
        }

    }

    private Set<String> inbound1QueuesSet = new Set<String>{
        'LeadAssignDE',
        'LeadAssignAT',
        'LeadAssignCH_IT',
        'LeadAssignCH_FR',
        'LeadAssignCH_DE',
        'LeadAssignFR',
        'LeadAssignBE_FR',
        'LeadAssignLU',
        'LeadAssignPL'
    };

    private Set<String> inbound2QueuesSet = new Set<String>{
        'LeadAssignCZ',
        'LeadAssignSK',
        'LeadAssignPL',
        'LeadAssignHU',
        'LeadAssignNL',
        'LeadAssignBE_NL'
    };

    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
            if (userId == null) {
                userId = UserInfo.getUserId();
            }
    }

    public class LeadWrapper {
        public Lead lead {get; set;}
        public Decimal diff {get; set;}
        public String selectedSecChannel {get; set;}

        public leadWrapper(Lead lead, Map<String, BusinessHours> businessHoursForUsersMap, String selectedSecChannel) {
            this.lead = lead;
            this.selectedSecChannel = selectedSecChannel;
            BusinessHours busHours = businessHoursForUsersMap.get(lead.OwnerId);           
            if (lead.First_Call__c != null) {
                    diff = BusinessHours.diff(busHours.Id, lead.CreatedDate, lead.First_Call__c)/1000/60;    
            } else {
                diff = BusinessHours.diff(busHours.Id, lead.CreatedDate, Datetime.now())/1000/60;    
            }
        }
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
}