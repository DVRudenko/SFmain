public class DashboardUnprocessedLeadsCtrl {
    public Map<String, Integer> finalLeadsMapInbound {get; set;}
    public Map<String, Integer> finalLeadsMapJITB {get; set;}
    public Map<String, Integer> finalLeadsMapPartner {get; set;}
    public List<String> keysList {get; set;}
    public String key {get; set;}

    private Map<String, List<Lead>> leadMap;

    private Set<String> reassignmentCountriesSet = new Set<String>{
        'LeadAssignAT',
        'LeadAssignDE',
        'LeadAssignFR',
        'LeadAssignBE_FR',
        'LeadAssignCH_DE',
        'LeadAssignCH_FR',
        'LeadAssignCH_IT',
        'LeadAssignLU',
        'LeadAssignPL'
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

    private Set<String> countriesPartnerSet = new Set<String>{
        'Germany'
    };

    private Map<String, String> countriesMap = new Map<String, String>{
        'Germany' => 'DE', 
        'France' => 'FR', 
        'Belgium-FR' => 'BEFR',
        'Austria' => 'AT',
        'Switzerland-DE' => 'CHDE',
        'Switzerland-IT' => 'CHIT',
        'Switzerland-FR' => 'CHFR',
        'Luxembourg' => 'LU',
        'Poland' => 'PL'};
    
    public DashboardUnprocessedLeadsCtrl() {
    }    
    public void init() {
        key = ApexPages.currentPage().getParameters().get('key');
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

        if (key == 'xn661q8t5s33w1n5X3V42x19WKhJnHi5') {
            String query = 'SELECT Owner.Email, Status, CreatedDate, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Channel__c, LeadSource, Country, CountryCode, RecordType.Name ' + 
                ' FROM Lead ' + 
                ' WHERE ((Sec_Channel__c = \'Inbound\' AND (Channel__c = \'Internet\' OR Channel__c = \'E-mail\') AND Country IN :countriesInbSet) OR ' +
                ' (Sec_Channel__c = \'JITB\' AND Channel__c = \'Internet\' AND Country IN :countriesInbSet) OR ' +
                ' (Sec_Channel__c = \'Partner\' AND Country IN :countriesPartnerSet)) AND ' +
                ' (Recycle_counter__c = 0 OR Recycle_counter__c = NULL) AND ' +
                ' RecordType.Name = \'Endkunde\' AND ' +          
                ' isConverted = FALSE AND ' + 
                ' Status = \'Open\' AND ' + 
                ' OwnerId IN :usersSet AND ' +
                ' First_Call__c = NULL AND ' + 
                ' Last_Owner_Change_Date__c != NULL AND ' + 
                ' LeadSource != \'Online_chat\'';
                List<Lead> leadsList =  Database.query(query);
                keysList = new List<String>{'DE', 'AT', 'BEFR', 'FR', 'CHDE', 'CHIT', 'CHFR', 'LU', 'PL'};
                generateDataForInboundLeads(leadsList);
                generateDataForJITBLeads(leadsList);
                generateDataForPartnerLeads(leadsList);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid key. Please contact your administrator.'));
        }
    }


    /*******************************************************************************
    *  Name            : generateDataForInboundLeads
    *  Summary         : count number of Inbound Leads by countries
    *  CreatedDate     : 12/06/2017
    *  Parameters      : List<Lead> leadsList - Leads with different sec channels and countries
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForInboundLeads(List<Lead> leadsList) {
        Map<String, List<Lead>> leadMapInbound = new Map <String, List<Lead>>();
        leadMapInbound.put('Germany', new List<Lead>());
        leadMapInbound.put('France', new List<Lead>());
        leadMapInbound.put('Belgium-FR', new List<Lead>());
        leadMapInbound.put('Austria', new List<Lead>());
        leadMapInbound.put('Switzerland-DE', new List<Lead>());
        leadMapInbound.put('Switzerland-IT', new List<Lead>());
        leadMapInbound.put('Switzerland-FR', new List<Lead>());
        leadMapInbound.put('Luxembourg', new List<Lead>());
        leadMapInbound.put('Poland', new List<Lead>());     
        
        for (Lead lead : leadsList) {
            String countryString = lead.Country;
            if (leadMapInbound.containsKey(countryString) && lead.Sec_Channel__c == 'Inbound') {
                leadMapInbound.get(countryString).add(lead);
            }
        }      
        finalLeadsMapInbound = new Map <String, Integer>();     
        for (String country : leadMapInbound.keySet()) {
            finalLeadsMapInbound.put(countriesMap.get(country), leadMapInbound.get(country).size());            
        }
    }


    /*******************************************************************************
    *  Name            : generateDataForJITBLeads
    *  Summary         : count number of JITB Leads by countries    
    *  CreatedDate     : 12/06/2017
    *  Parameters      : List<Lead> leadsList - Leads with different sec channels and countries
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForJITBLeads(List<Lead> leadsList) {
        Map<String, List<Lead>> leadMapJITB = new Map <String, List<Lead>>();
        leadMapJITB.put('Germany', new List<Lead>());
        leadMapJITB.put('France', new List<Lead>());
        leadMapJITB.put('Belgium-FR', new List<Lead>());
        leadMapJITB.put('Austria', new List<Lead>());
        leadMapJITB.put('Switzerland-DE', new List<Lead>());
        leadMapJITB.put('Switzerland-IT', new List<Lead>());
        leadMapJITB.put('Switzerland-FR', new List<Lead>());
        leadMapJITB.put('Luxembourg', new List<Lead>());
        leadMapJITB.put('Poland', new List<Lead>());
        
        for (Lead lead : leadsList) {
            String countryString = lead.Country;
            if (leadMapJITB.containsKey(countryString) && lead.Sec_Channel__c == 'JITB') {
                leadMapJITB.get(countryString).add(lead);
            }
        }      
        finalLeadsMapJITB = new Map <String, Integer>();     
        for (String country : leadMapJITB.keySet()) {
            finalLeadsMapJITB.put(countriesMap.get(country), leadMapJITB.get(country).size());            
        }
    }


    /*******************************************************************************
    *  Name            : generateDataForPartnerLeads(List<Lead> leadsList)
    *  Summary         : count number of Partner Leads by countries    
    *  CreatedDate     : 01/11/2017
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> leadsList
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForPartnerLeads(List<Lead> leadsList) {
        Map<String, List<Lead>> leadMapPartner = new Map <String, List<Lead>>();
        leadMapPartner.put('Germany', new List<Lead>());
        leadMapPartner.put('France', new List<Lead>());
        leadMapPartner.put('Belgium-FR', new List<Lead>());
        leadMapPartner.put('Austria', new List<Lead>());
        leadMapPartner.put('Switzerland-DE', new List<Lead>());
        leadMapPartner.put('Switzerland-IT', new List<Lead>());
        leadMapPartner.put('Switzerland-FR', new List<Lead>());
        leadMapPartner.put('Luxembourg', new List<Lead>());
        leadMapPartner.put('Poland', new List<Lead>());

        for (Lead lead : leadsList) {
            String countryString = lead.Country;
            if (leadMapPartner.containsKey(countryString) && lead.Sec_Channel__c == 'Partner') {
                leadMapPartner.get(countryString).add(lead);
            }
        }
        finalLeadsMapPartner = new Map <String, Integer>();     
        for (String country : leadMapPartner.keySet()) {
            finalLeadsMapPartner.put(countriesMap.get(country), leadMapPartner.get(country).size());            
        }
    }
}