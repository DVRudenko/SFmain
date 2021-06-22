public with sharing class SalesDashboardConversionRateCCSctrl {
  public User currentUser {get; set;}
  public Map<String, User> salesTeamMap {get; set;}
  public List<FinalList> finalList {get; set;}
  public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public String selectedPeriod {get; set;}
    public String selectedYear {get; set;}
    public Map<String, Integer> closedWonOpps {get; set;}
    public Map<String, Integer> receivedLeads {get; set;}
    public Integer numberClosedWonOpps {get; set;}
    public Integer numberReceivedLeads {get; set;}

    public Date startDateOfPeriod;
    public Date endDateOfPeriod;

    public SalesDashboardConversionRateCCSctrl() {     
    }

    public void init() {
      if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
        this.salesTeamMap = new Map<String, User>();
        this.finalList = new List<FinalList>();
        this.closedWonOpps = new Map<String, Integer>();
        this.receivedLeads = new Map<String, Integer>();
      generateDataForCharts();
      conversionRate();
    }


    /*******************************************************************************
    *  Name            : conversionRate()
    *  Summary         : calculating conversion rate    
    *  CreatedDate     : 19/09/2017
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void conversionRate() {
        returnUser();
        Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
            SELECT Id
            FROM UserRole
            WHERE ParentRoleId = :currentUser.UserRoleId
            LIMIT 1000]);

        this.salesTeamMap = new Map<String, User>([
            SELECT Name
            FROM User
            WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :this.currentUser.Id) AND 
                isActive = TRUE
            LIMIT 10000]);

        if (this.currentUser.UserRole.Name.contains('CCS Telesales Team Lead') || this.currentUser.UserRole.Name.contains('CCS SME Team Lead')) {
            List<Opportunity> allClosedWonOppsList = [
                SELECT Name, OwnerId, StageName
                FROM Opportunity
                    WHERE StageName = 'Closed Won' AND
                    CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND
                    Disable_for_KPI__c = FALSE AND
                    Disable_for_Approval_Rate__c = FALSE AND
                    OwnerId = :this.salesTeamMap.keySet() AND
                    Sec_Channel__c = 'Inbound' AND
                    ((LeadSource IN :leadSourceOpptiesCCSset AND Channel__c = 'web') OR
                    ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN' OR LeadSource = 'Příchozí poptávka') AND (Channel__c = 'Call' OR Channel__c = 'E-mail')) OR
                    ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                    ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                    )
                LIMIT 50000];

            Map<String, Lead> allReceivedLeadsMap = new Map<String, Lead>([
                SELECT Name, OwnerId, Status, Quali_Status__c, IsConverted, LeadSource 
                FROM Lead
                WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND 
                    Disable_for_KPI__c = FALSE AND
                    Disable_for_Approval_Rate__c = FALSE AND
                    OwnerId = :this.salesTeamMap.keySet() AND
                    Status != 'Uzavřeno' AND
                    Sec_Channel__c = 'Inbound' AND
                    ((LeadSource IN :leadSourceLeadsCCSset AND Channel__c = 'web') OR
                    ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN' OR LeadSource = 'Příchozí poptávka') AND (Channel__c = 'Call' OR Channel__c = 'E-mail')) OR 
                    ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                    ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                    )
                LIMIT 50000]);

            for (Lead lead : allReceivedLeadsMap.values()) {
                if (lead.Status == 'Disqualified' && 
                    (lead.Quali_Status__c == 'Not a legal entity' ||
                    lead.Quali_Status__c == 'Forwarded internally' ||
                    lead.Quali_Status__c == 'Forwarded to external provider' ||
                    lead.Quali_Status__c == 'Forwarded to Market' ||
                    lead.Quali_Status__c == 'Info Bonus card' ||
                    lead.Quali_Status__c == 'Spam' ||
                    lead.Quali_Status__c == 'Dublette' ||
                    lead.Quali_Status__c == 'Already CCS customer' ||
                    lead.Quali_Status__c == 'Company ceased to exist' ||
                    lead.Quali_Status__c == 'No vehicles' ||
                    lead.Quali_Status__c == 'Wrong contact details')) {
                    allReceivedLeadsMap.remove(lead.Id);
                }
            }

            Map<String, List<Opportunity>> finalClosedWonOpportunitiesMap = new Map<String, List<Opportunity>>();
            Map<String, List<Lead>> finalReceivedLeadsMap = new Map<String, List<Lead>>();
            for (Opportunity opp : allClosedWonOppsList) {
                if (! finalClosedWonOpportunitiesMap.containsKey(opp.OwnerId)) {
                    finalClosedWonOpportunitiesMap.put(opp.OwnerId, new List<Opportunity>());
                }
                finalClosedWonOpportunitiesMap.get(opp.OwnerId).add(opp);
            }
            for (Lead lead : allReceivedLeadsMap.values()) {
                if (! finalReceivedLeadsMap.containsKey(lead.OwnerId)) {
                    finalReceivedLeadsMap.put(lead.OwnerId, new List<Lead>());
                }
                finalReceivedLeadsMap.get(lead.OwnerId).add(lead);
            }

            for (String userId : salesTeamMap.keySet()) {
                if (! finalClosedWonOpportunitiesMap.containsKey(userId)) {
                finalClosedWonOpportunitiesMap.put(userId, new List<Opportunity>());
            }
            if (! finalReceivedLeadsMap.containsKey(userId)) {
                finalReceivedLeadsMap.put(userId, new List<Lead>());
            }

            this.finalList.add(new FinalList(
                userId,
                finalClosedWonOpportunitiesMap.get(userId).size()));

            this.closedWonOpps.put(userId, finalClosedWonOpportunitiesMap.get(userId).size());
                this.receivedLeads.put(userId, finalReceivedLeadsMap.get(userId).size());
            }

        } else if (this.currentUser.UserRole.Name.contains('CCS CZ Telesales') || this.currentUser.UserRole.Name.contains('CCS CZ SME') || this.currentUser.UserRole.Name.contains('CCS SK SME')) {
            List<Opportunity> allClosedWonOppsList = [
                SELECT Name, StageName
                FROM Opportunity
                WHERE StageName = 'Closed Won' AND
                    CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND
                    Disable_for_KPI__c = FALSE AND
                    Disable_for_Approval_Rate__c = FALSE AND
                    OwnerId = :this.currentUser.Id AND
                    Sec_Channel__c = 'Inbound' AND
                    ((LeadSource IN :leadSourceOpptiesCCSset AND Channel__c = 'web') OR
                    ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN' OR LeadSource = 'Příchozí poptávka') AND (Channel__c = 'Call' OR Channel__c = 'E-mail')) OR 
                    ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                    ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                    )
                LIMIT 50000];
                
            Map<String, Lead> allReceivedLeadsMap = new Map<String, Lead>([
                SELECT Name, OwnerId, Status, Quali_Status__c, IsConverted, LeadSource
                FROM Lead
                WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND
                    Disable_for_KPI__c = FALSE AND 
                    Disable_for_Approval_Rate__c = FALSE AND
                    OwnerId = :this.currentUser.Id AND
                    Status != 'Uzavřeno' AND
                    Sec_Channel__c = 'Inbound' AND
                    ((LeadSource IN :leadSourceLeadsCCSset AND Channel__c = 'web') OR
                    ((LeadSource = 'CCS ČSOBL' OR LeadSource = 'CCS TLS_O2 KAMPAN' OR LeadSource = 'Příchozí poptávka') AND (Channel__c = 'Call' OR Channel__c = 'E-mail')) OR 
                    ((LeadSource = 'CCS WEB Telesales' OR LeadSource = 'CCS WEB Telesales CC') AND Channel__c = 'incoming call') OR
                    ((LeadSource = 'CCS WEB Telesales FB' OR LeadSource = 'CCS WEB Telesales market') AND Channel__c = 'incoming email') 
                    )
                LIMIT 50000]);

            for (Lead lead : allReceivedLeadsMap.values()) {
                if (lead.Status == 'Disqualified' && 
                    (lead.Quali_Status__c == 'Not a legal entity' ||
                    lead.Quali_Status__c == 'Forwarded internally' ||
                    lead.Quali_Status__c == 'Forwarded to external provider' ||
                    lead.Quali_Status__c == 'Forwarded to Market' ||
                    lead.Quali_Status__c == 'Info Bonus card' ||
                    lead.Quali_Status__c == 'Spam' ||
                    lead.Quali_Status__c == 'Dublette' ||
                    lead.Quali_Status__c == 'Already CCS customer' ||
                    lead.Quali_Status__c == 'Company ceased to exist' ||
                    lead.Quali_Status__c == 'No vehicles' ||
                    lead.Quali_Status__c == 'Wrong contact details')) {
                    allReceivedLeadsMap.remove(lead.Id);
                }
            }
            this.numberClosedWonOpps = allClosedWonOppsList.size();
            this.numberReceivedLeads = allReceivedLeadsMap.size();
        }
    }


    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generate Data For Charts    
    *  CreatedDate     : 19/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCharts() {
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        Date startDateOfMonth;
        Date endDateOfMonth;
        if (this.selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }

            this.selectedPeriod = currentWeek.get(0).Id;
            this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
            endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;
        } else {
            Id selectedId = this.selectedPeriod;           
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
                this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
                startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
                endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;      
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                Fleetcor_Calendar_Month__c currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                this.startDateOfPeriod = currentMonth.Start_Date__c;
                this.endDateOfPeriod = currentMonth.End_Date__c;
                startDateOfMonth = currentMonth.Start_Date__c;
                endDateOfMonth = currentMonth.End_Date__c;
            }         
        }
        this.startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        this.endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 19/09/2017
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


    /*******************************************************************************
    *  Name            : changeYear()
    *  Summary         : changing year    
    *  CreatedDate     : 19/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
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
    *  CreatedDate     : 19/09/2017
    *  Parameters      : -
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


    /*******************************************************************************
    *  Name            : getcurrentWeeks()
    *  Summary         : Display weeks in selectbox    
    *  CreatedDate     : 19/09/2017
    *  Parameters      : -
    *  Returns         : List<SelectOption>
    ******************************************************************************/
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
    *  Name            : returnUser()
    *  Summary         : return current user    
    *  CreatedDate     : 19/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUser() {
        String userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        this.currentUser = [
            SELECT UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId];
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

    private final Set<String> leadSourceOpptiesCCSset = new Set<String>{
        'CCS WEB Telesales FB',
        'MVF Web Lead',
        'Web CCS (objednávka CCS Bonus+)',
        'Web CCS (objednávka CCS Bonus)',
        'bonusky.cz',
        'bonusky.sk',
        'OZ login - Web CCS (objednávka CCS Bonus+)',
        'OZ login - Web CCS (objednávka CCS Bonus)',
        'efektivnetankovanie.sk',
        'efektivnitankovani.cz',
        'Web CCS',
        'Web CCS (Napište nám)',
        'Web CCS (Napište nám SK)',
        'Web CCS (landing page)',
        'Web CCS (objednávka CCS Bonus+ SK)',
        'Web CCS (objednávka CCS Bonus Fleet)',
        'Web CCS (objednávka CCS Bonus Fleet SK)',
        'Web CCS (objednávka CCS Bonus SK)',
        'Web CCS (objednávka CCS Business)',
        'Web CCS (objednávka CCS Business SK)',
        'Web CCS (objednávka CCS Carnet)',
        'Web CCS (objednávka CCS Carnet SK)',
        'Web CCS (objednávka CCS Limit)',
        'Web CCS (objednávka CCS Limit+)',
        'Web CCS (objednávka CCS Limit +MINI)',
        'Web CCS (objednávka CCS Limit+ SK)',
        'Web CCS (objednávka CCS Limit SK)',
        'Web CCS (objednávka CCS Toll)',
        'Web CCS (objednávka CCS Toll SK)',
        'Web CCS (objednávka UTA/CCS)',
        'Web CCS (objednávka UTA/CCS SK)',
        'OZ login - Web CCS',
        'OZ login - Web CCS (objednávka CCS Bonus+ SK)',
        'OZ login - Web CCS (objednávka CCS Bonus Fleet)',
        'OZ login - Web CCS (objednávka CCS Bonus Fleet SK)',
        'OZ login - Web CCS (objednávka CCS Bonus SK)',
        'OZ login - Web CCS (objednávka CCS Business)',
        'OZ login - Web CCS (objednávka CCS Business SK)',
        'OZ login - Web CCS (objednávka CCS Carnet)',
        'OZ login - Web CCS (objednávka CCS Carnet SK)',
        'OZ login - Web CCS (objednávka CCS Limit)',
        'OZ login - Web CCS (objednávka CCS Limit+)',
        'OZ login - Web CCS (objednávka CCS Limit +MINI)',
        'OZ login - Web CCS (objednávka CCS Limit+ SK)',
        'OZ login - Web CCS (objednávka CCS Limit SK)',
        'OZ login - Web CCS (objednávka CCS Toll)',
        'OZ login - Web CCS (objednávka CCS Toll SK)',
        'OZ login - Web CCS (objednávka UTA/CCS)',
        'OZ login - Web CCS (objednávka UTA/CCS SK)'
    };

    private final Set<String> leadSourceLeadsCCSset = new Set<String>{
        'CCS WEB Telesales FB',
        'MVF Web Lead',
        'Web CCS (objednávka CCS Bonus+)',
        'Web CCS (objednávka CCS Bonus)',
        'bonusky.cz',
        'bonusky.sk',
        'OZ login - Web CCS (objednávka CCS Bonus+)',
        'OZ login - Web CCS (objednávka CCS Bonus)',
        'efektivnetankovanie.sk',
        'efektivnitankovani.cz',
        'Web CCS',
        'Web CCS (Napište nám)',
        'Web CCS (Napište nám SK)',
        'Web CCS (landing page)',
        'Web CCS (objednávka CCS Bonus+ SK)',
        'Web CCS (objednávka CCS Bonus Fleet)',
        'Web CCS (objednávka CCS Bonus Fleet SK)',
        'Web CCS (objednávka CCS Bonus SK)',
        'Web CCS (objednávka CCS Business)',
        'Web CCS (objednávka CCS Business SK)',
        'Web CCS (objednávka CCS Carnet)',
        'Web CCS (objednávka CCS Carnet SK)',
        'Web CCS (objednávka CCS Limit)',
        'Web CCS (objednávka CCS Limit+)',
        'Web CCS (objednávka CCS Limit +MINI)',
        'Web CCS (objednávka CCS Limit+ SK)',
        'Web CCS (objednávka CCS Limit SK)',
        'Web CCS (objednávka CCS Toll)',
        'Web CCS (objednávka CCS Toll SK)',
        'Web CCS (objednávka UTA/CCS)',
        'Web CCS (objednávka UTA/CCS SK)'
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
}