public with sharing class DashboardLeadProcessingTimeTLCtrl {
    public User currentUser {get; set;}
    public String startDateOfWeekString {get; set;}
    public String endDateOfWeekString {get; set;}
    public Fleetcor_Calendar_Week__c currentWeek {get; set;}
    public Fleetcor_Calendar_Month__c currentMonth {get; set;}
    public Map<String, Decimal> minutesMap {get; set;}
    public Map<String, Integer> toProcessMap {get; set;}
    public Map<String, Integer> quantityLeadsMap {get; set;}
    public Decimal finalMinutesAT {get; set;}
    public String selectedPeriod {get; set;}
    public Date startDateOfWeek {get; set;}
    public Date endDateOfWeek {get; set;}
    public String startDateOfWeekParam {get; set;}
    public String endDateOfWeekParam {get; set;}
    public String selectedYear {get; set;}
    public String selectedSecChannel {get; set;}

    private static Date todayDate; 
    private Set<String> reassignmentCountriesSet;
    private Set<String> countriesSet;
    private String userId;

    public DashboardLeadProcessingTimeTLCtrl() {}

    public void init() {
        returnUserId();
        this.minutesMap = new Map<String, Decimal>();
        this.toProcessMap = new Map<String, Integer>();
        this.quantityLeadsMap = new Map<String, Integer>();
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }       
        generateDataForCharts();
        currentUser = [SELECT Profile.Name, UserRoleId, UserRole.Name, LocaleSidKey, Name FROM User WHERE Id = :userId];
        List<Lead> currentLeads = new List<Lead>();
        List<Lead> currentToProcessLeads = new List<Lead>();
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
            
            currentLeads = [
                SELECT OwnerId, CreatedDate, First_Call__c, Country, IsConverted, Sec_Channel__c, Site_Agg_product__c, LeadSource
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND 
                        First_Call__c != NULL AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND 
                        LeadSource != 'Online_chat' AND
                        OwnerId IN :usersSet AND
                        First_Call__c >= :startDateOfWeek AND First_Call__c < :endDateOfWeek.addDays(1) AND
                        Disable_for_Processing_Time__c = FALSE
                LIMIT 50000];

            currentToProcessLeads = [
                SELECT Owner.Email, Status, CreatedDate, Sec_Channel__c, OwnerId, 
                        Last_Owner_Change_Date__c, Channel__c, LeadSource, Country, 
                        CountryCode, RecordType.Name
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail') AND Country IN :countriesInbSet) OR 
                        (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet' AND Country IN :countriesInbSet) OR 
                        (Sec_Channel__c = 'Partner' AND Country IN :countriesPartnerSet)) AND 
                        (Recycle_counter__c = 0 OR Recycle_counter__c = NULL) AND 
                        RecordType.Name = 'Endkunde' AND          
                        isConverted = FALSE AND 
                        Status = 'Open' AND 
                        OwnerId IN :userTotalSet AND 
                        First_Call__c = NULL AND 
                        Last_Owner_Change_Date__c != NULL AND  
                        LeadSource != 'Online_chat'
                LIMIT 50000];

            List<Lead> finalCurrentLeads = new List<Lead>();
            if (! currentLeads.isEmpty()) {
                for (Lead lead : currentLeads){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalCurrentLeads.add(lead);
                    }
                }
                currentLeads = finalCurrentLeads;
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

            currentLeads = [
                    SELECT OwnerId, CreatedDate, First_Call__c, Country, IsConverted, Sec_Channel__c, Site_Agg_product__c, LeadSource
                    FROM Lead 
                    WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                           (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                           (Sec_Channel__c = 'Partner')) AND 
                            First_Call__c != NULL AND
                            Quali_Status__c != 'Spam' AND
                            Quali_Status__c != 'Sent to support' AND
                            Quali_Status__c != 'Not a legal entity' AND 
                            LeadSource != 'Online_chat' AND
                            OwnerId IN :usersSet AND
                            First_Call__c >= :startDateOfWeek AND First_Call__c < :endDateOfWeek.addDays(1) AND
                            Disable_for_Processing_Time__c = FALSE
                    LIMIT 50000];

            currentToProcessLeads = [
                    SELECT Owner.Email, Status, CreatedDate, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Channel__c, LeadSource, Country, CountryCode, RecordType.Name
                    FROM Lead 
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                            Channel__c != 'Anruf' AND 
                            Country IN :countriesInb2Set AND 
                            (Recycle_counter__c = 0 OR Recycle_counter__c = NULL) AND
                            RecordType.Name = 'Endkunde' AND
                            isConverted = FALSE AND
                            Status = 'Open' AND
                            OwnerId IN :userTotalSet AND
                            First_Call__c = NULL AND 
                            Last_Owner_Change_Date__c != NULL AND
                            LeadSource != 'Online_chat'
                    LIMIT 50000];

            List<Lead> finalCurrentLeads = new List<Lead>();
            if (! currentLeads.isEmpty()) {
                for (Lead lead : currentLeads){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalCurrentLeads.add(lead);
                    }
                }
                currentLeads = finalCurrentLeads;
            }
        } else if (currentUser.UserRole.Name == 'Teamleiter Harte Hank') {
            reassignmentCountriesSet = new Set<String>{
                'LeadAssignFR'
            };

            countriesSet = new Set<String>{
                'France'
            };

            List<GroupMember> members = [
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.Name IN :reassignmentCountriesSet
                LIMIT 10000];

            List<Group> queuesList = [
                    SELECT Name, (SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMembers)
                    FROM Group 
                    WHERE Name = :reassignmentCountriesSet
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

            currentLeads = [
                SELECT OwnerId, CreatedDate, First_Call__c, Country, IsConverted, Sec_Channel__c, Site_Agg_product__c, LeadSource
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND 
                        Country IN :countriesSet AND 
                        First_Call__c != NULL AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND 
                        LeadSource != 'Online_chat' AND
                        OwnerId IN :usersSet AND
                        First_Call__c >= :startDateOfWeek AND First_Call__c < :endDateOfWeek.addDays(1) AND
                        Disable_for_Processing_Time__c = FALSE
                LIMIT 50000];

            currentToProcessLeads = [
                SELECT OwnerId, CreatedDate, First_Call__c, Country, IsConverted, Sec_Channel__c, Site_Agg_product__c, LeadSource
                FROM Lead 
                WHERE ((Sec_Channel__c = 'Inbound' AND (Channel__c = 'Internet' OR Channel__c = 'E-mail')) OR
                       (Sec_Channel__c = 'JITB' AND Channel__c = 'Internet') OR
                       (Sec_Channel__c = 'Partner')) AND 
                        Country IN :countriesSet AND 
                        First_Call__c = NULL AND
                        Quali_Status__c != 'Spam' AND
                        Quali_Status__c != 'Sent to support' AND
                        Quali_Status__c != 'Not a legal entity' AND
                        LeadSource != 'Online_chat' AND
                        OwnerId IN :usersSet AND 
                        IsConverted = FALSE AND 
                        Status = 'Open' AND 
                        Disable_for_Processing_Time__c = FALSE
                LIMIT 50000];

            List<Lead> finalCurrentLeads = new List<Lead>();
            if (! currentLeads.isEmpty()) {
                for (Lead lead : currentLeads){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalCurrentLeads.add(lead);
                    }
                }
                currentLeads = finalCurrentLeads;
            }

            List<Lead> finalCurrentToProcessLeads = new List<Lead>();
            if (! currentToProcessLeads.isEmpty()) {
                for (Lead lead : currentToProcessLeads){
                    if ( ! (lead.Country == 'Netherlands' && lead.LeadSource == 'Site Agg' && (lead.Site_Agg_product__c == 'Shell' || lead.Site_Agg_product__c == 'undefined_card'))) {
                        finalCurrentToProcessLeads.add(lead);
                    }
                }
                currentToProcessLeads = finalCurrentToProcessLeads;
            }
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
        for (Lead lead : currentLeads) {
            if (String.valueOf(lead.OwnerId).subString(0,3) == '005') {
                currentUserOwnerLeadsIdSet.add(lead.OwnerId);
            } else {
                currentQueuesOwnerLeadsIdSet.add(lead.OwnerId);
            }   
        }
        for (Lead lead : currentToProcessLeads) {
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

        if (this.selectedSecChannel == null) {
            this.selectedSecChannel = 'Inbound in bh';
        }
        Map<String, Integer> quantityLeadsMap = new Map<String, Integer>(); 
        List<Lead> currentLeadsForCharts = new List<Lead>();
        List<Lead> currentToProcessLeadsForCharts = new List<Lead>();
        if (this.selectedSecChannel == 'Inbound in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'Inbound' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Inbound not in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'Inbound' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Inbound Total') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Inbound') {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'Inbound') {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'JITB in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'JITB' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'JITB' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'JITB not in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'JITB' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'JITB' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        }

        if (this.selectedSecChannel == 'JITB Total') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'JITB') {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'JITB') {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Partner in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Partner' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'Partner' && BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Partner not in bh') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Partner' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'Partner' && ! BusinessHours.isWithin(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate)) {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        if (this.selectedSecChannel == 'Partner Total') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'Partner') {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'Partner') {
                    currentLeadsForCharts.add(l);
                }
            }
        }

        if (this.selectedSecChannel == 'Total') {
            for (Lead l : currentToProcessLeads) {
                if (l.Sec_Channel__c == 'JITB' || l.Sec_Channel__c == 'Inbound' || l.Sec_Channel__c == 'Partner') {
                    currentToProcessLeadsForCharts.add(l);
                }
            }

            for (Lead l : currentLeads) {
                if (l.Sec_Channel__c == 'JITB' || l.Sec_Channel__c == 'Inbound' || l.Sec_Channel__c == 'Partner') {
                    currentLeadsForCharts.add(l);
                }
            }
        } 

        for (Lead l : currentToProcessLeadsForCharts) {
            String countryString = prepareCountry(l.Country);

            if ( ! toProcessMap.containsKey(countryString)) {
                toProcessMap.put(countryString, 0);
            }
            
            Integer quantityLeads = toProcessMap.get(countryString) + 1;
            toProcessMap.put(countryString, quantityLeads);

            if ( ! minutesMap.containsKey(countryString)) {
                minutesMap.put(countryString, 0);
                quantityLeadsMap.put(countryString, 0);
            }
        }

        for (Lead l : currentLeadsForCharts) {
            String countryString = prepareCountry(l.Country);   

            if ( ! minutesMap.containsKey(countryString)) {
                minutesMap.put(countryString, 0);
                quantityLeadsMap.put(countryString, 0);
            }

            if ( ! toProcessMap.containsKey(countryString)) {
                toProcessMap.put(countryString, 0);
            }

            Decimal minutes = 0;
            Integer quantityLeads = 0;

            minutes = BusinessHours.diff(businessHoursForUsersMap.get(l.OwnerId).Id, l.CreatedDate, l.First_Call__c)/1000/60;   
            minutes = minutesMap.get(countryString) + minutes;
            minutesMap.put(countryString, minutes);
            
            quantityLeads = quantityLeadsMap.get(countryString) + 1;
            quantityLeadsMap.put(countryString, quantityLeads);
        }

        for (String country : minutesMap.keyset()) {
            if (quantityLeadsMap.get(country) != 0) {
                Decimal minutesTemp = minutesMap.get(country) / quantityLeadsMap.get(country);
                minutesMap.put(country, minutesTemp.setScale(2));
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
    

    public String prepareCountry(String country) {
        String countryString = country;
        if ( ! countryString.contains('-')) {
            countryString = country.toLowerCase();
            List<String> elems = countryString.split(' ');
            countryString = '';
            for (String x : elems) {
                countryString += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + ' ';
            }
            
            countryString = countryString.removeEnd(' '); 
        }

        return countryString;
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
            
            options.add(
                new SelectOption(
                    week.Id, 
                    '---' + week.Fleetcor_Calendar_Month__r.Name + ' (' + week.Start_Date__c.day() + '.' + week.Start_Date__c.month() + ' - ' + 
                    week.End_Date__c.day() + '.' + week.End_Date__c.month() + ')'));
        }

        return options;
    }


    /*******************************************************************************
    *  Name            : getSecChannels
    *  Summary         : display SecChannels in business hours or not 
    *  CreatedDate     : 12/04/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getSecChannels() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Inbound in bh', 'Inbound in BH'));
        options.add(new SelectOption('Inbound not in bh', 'Inbound not in BH'));
        options.add(new SelectOption('Inbound Total', 'Inbound Total'));
        options.add(new SelectOption('JITB in bh', 'JITB in BH'));
        options.add(new SelectOption('JITB not in bh', 'JITB not in BH'));
        options.add(new SelectOption('JITB Total', 'JITB Total'));
        options.add(new SelectOption('Partner in bh', 'Partner in BH'));
        options.add(new SelectOption('Partner not in bh', 'Partner not in BH'));
        options.add(new SelectOption('Partner Total', 'Partner Total'));
        options.add(new SelectOption('Total', 'Total'));
        return options;
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
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                  Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        //todayDate = Date.newinstance(2016, 4, 15);
        if (selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }

            selectedPeriod = currentWeek.get(0).Id;
            doSetPeriod(currentWeek.get(0).Start_Date__c, currentWeek.get(0).End_Date__c);
        } else {
            Id selectedId = selectedPeriod;
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :selectedPeriod
                    LIMIT 1];
                doSetPeriod(currentWeek.get(0).Start_Date__c, currentWeek.get(0).End_Date__c);       
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :selectedPeriod
                    LIMIT 1];
                doSetPeriod(currentMonth.Start_Date__c, currentMonth.End_Date__c);  
            }
        }


        startDateOfWeekString = String.valueOf(startDateOfWeek.day()) + ' ' + monthsMap.get(startDateOfWeek.month());
        endDateOfWeekString = String.valueOf(endDateOfWeek.day()) + ' ' + monthsMap.get(endDateOfWeek.month());

        startDateOfWeekParam = startDateOfWeek.year() + '-' + startDateOfWeek.month() + '-' + startDateOfWeek.day();
        endDateOfWeekParam = endDateOfWeek.year() + '-' + endDateOfWeek.month() + '-' + endDateOfWeek.day();
    }

    public void doSetPeriod(Date startdate, Date enddate) {
        startDateOfWeek = startdate;
        endDateOfWeek = enddate;
    }

    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
            if (userId == null) {
                userId = UserInfo.getUserId();
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

    private Set<String> countriesInbSet = new Set<String>{
        'Austria',
        'Germany',
        'France',
        'Belgium-FR',
        'Switzerland-DE',
        'Switzerland-IT',
        'Switzerland-FR',
        'Luxembourg',
        'Poland'
    };

    private Set<String> countriesInb2Set = new Set<String>{
        'Czech Republic',
        'Slovakia',
        'Poland',
        'Hungary',
        'Belgium-NL',
        'Netherlands'
    };

    private Set<String> countriesPartnerSet = new Set<String>{
        'Germany'
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
        12 => 'December'}; 

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
        'December' => 12};
}