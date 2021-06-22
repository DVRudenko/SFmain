public class DashboardUnprocessedLeads2Ctrl {
    public Map<String, Integer> finalLeadsMapInbound {get; set;}
    public Map<String, Integer> finalLeadsMapJITB {get; set;}
    public Map<String, Integer> finalLeadsMapInboundCarnet {get; set;}
    public List<String> keysList {get; set;}
    public String key {get; set;}

    private Set<String> reassignmentCountriesSet = new Set<String>{
        'LeadAssignCZ',
        'LeadAssignSK',
        'LeadAssignPL',
        'LeadAssignHU',
        'LeadAssignBE_NL',
        'LeadAssignNL'
    };

    private Set<String> countriesSet = new Set<String>{
        'Czech Republic',
        'Slovakia',
        'Poland',
        'Hungary',
        'Belgium-NL',
        'Netherlands'
    };

    private Map<String, String> countriesMap = new Map<String, String>{
        'Czech Republic' => 'CZ',
        'Slovakia' => 'SK',
        'Poland' => 'PL',
        'Hungary' => 'HU',
        'Belgium-NL' => 'BE-NL',
        'Netherlands' => 'NL'
    };
    
    public DashboardUnprocessedLeads2Ctrl() {
    }    

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : select open leads for certain countries
    *  CreatedDate     : 27/02/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        key = ApexPages.currentPage().getParameters().get('key');
        if (key == 'xn661q8t5s33w1n5X3V42x19WKhJnHi5') {
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
            
            String query = 'SELECT Owner.Email, Status, CreatedDate, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Channel__c, LeadSource, Country, CountryCode, RecordType.Name ' + 
                ' FROM Lead ' + 
                ' WHERE (Sec_Channel__c = \'Inbound\' OR Sec_Channel__c = \'JITB\') AND Channel__c != \'Anruf\' AND Country IN :countriesSet AND ' +
                ' (Recycle_counter__c = 0 OR Recycle_counter__c = NULL) AND ' +
                ' RecordType.Name = \'Endkunde\' AND ' +
                ' isConverted = FALSE AND ' + 
                ' Status = \'Open\' AND ' + 
                ' OwnerId IN :usersSet AND ' +
                ' First_Call__c = NULL AND ' + 
                ' Last_Owner_Change_Date__c != NULL AND ' + 
                ' LeadSource != \'Online_chat\'';
            List<Lead> leadsList =  Database.query(query);
            generateDataForInboundLeads(leadsList);
            generateDataForJITBLeads(leadsList);
            generateDataForCarnetLeads(leadsList);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid key. Please contact your administrator.'));
        } 
    }


    /*******************************************************************************
    *  Name            : generateDataForInboundLeads
    *  Summary         : count number of Leads by countries
    *  CreatedDate     : 27/02/2017
    *  Parameters      : List<Lead> leadsList - Leads with different sec channels and countries
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForInboundLeads(List<Lead> leadsList) {
        Map<String, List<Lead>> leadMapInbound = new Map <String, List<Lead>>();
        leadMapInbound.put('Czech Republic', new List<Lead>());
        leadMapInbound.put('Slovakia', new List<Lead>());
        leadMapInbound.put('Poland', new List<Lead>());
        leadMapInbound.put('Hungary', new List<Lead>());
        leadMapInbound.put('Belgium-NL', new List<Lead>());
        leadMapInbound.put('Netherlands', new List<Lead>());
        keysList = new List<String>{'CZ', 'SK', 'PL', 'HU', 'BE-NL', 'NL'};
        
        for (Lead lead : leadsList) {
            String countryString = lead.Country;
            if (leadMapInbound.containsKey(countryString) && lead.Sec_Channel__c == 'Inbound' && lead.LeadSource != 'Carnet') {
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
    *  Summary         : count number of Leads by countries    
    *  CreatedDate     : 27/02/2017
    *  Parameters      : List<Lead> leadsList - Leads with different sec channels and countries
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForJITBLeads(List<Lead> leadslist) {
        Map<String, List<Lead>> leadMapJITB = new Map <String, List<Lead>>();
        leadMapJITB.put('Czech Republic', new List<Lead>());
        leadMapJITB.put('Slovakia', new List<Lead>());
        leadMapJITB.put('Poland', new List<Lead>());
        leadMapJITB.put('Hungary', new List<Lead>());
        leadMapJITB.put('Belgium-NL', new List<Lead>());
        leadMapJITB.put('Netherlands', new List<Lead>());
        keysList = new List<String>{'CZ', 'SK', 'PL', 'HU', 'BE-NL', 'NL'};
        
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
    *  Name            : generateDataForCarnetLeads(List<Lead> leadslist)
    *  Summary         : Count number of Leads by countries    
    *  CreatedDate     : 14/04/2019
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> leadsList - Carnet lead list
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCarnetLeads(List<Lead> leadsList) {
        Map<String, List<Lead>> leadMapInboundCarnet = new Map <String, List<Lead>>();
        leadMapInboundCarnet.put('Czech Republic', new List<Lead>());
        leadMapInboundCarnet.put('Slovakia', new List<Lead>());
        leadMapInboundCarnet.put('Poland', new List<Lead>());
        leadMapInboundCarnet.put('Hungary', new List<Lead>());
        leadMapInboundCarnet.put('Belgium-NL', new List<Lead>());
        leadMapInboundCarnet.put('Netherlands', new List<Lead>());
        keysList = new List<String>{'CZ', 'SK', 'PL', 'HU', 'BE-NL', 'NL'};
        
        for (Lead lead : leadsList) {
            String countryString = lead.Country;
            if (leadMapInboundCarnet.containsKey(countryString) && lead.Sec_Channel__c == 'Inbound' && lead.LeadSource == 'Carnet') {
                leadMapInboundCarnet.get(countryString).add(lead);
            }
        }      
        finalLeadsMapInboundCarnet = new Map <String, Integer>();     
        for (String country : leadMapInboundCarnet.keySet()) {
            finalLeadsMapInboundCarnet.put(countriesMap.get(country), leadMapInboundCarnet.get(country).size());            
        }
    }
}