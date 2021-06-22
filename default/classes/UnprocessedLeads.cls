public with sharing class UnprocessedLeads {
	public List<Lead> currentLeads {get; set;}
    private Set<String> countriesSet = new Set<String>{
        'AT',
        'DE',
        'FR',
        'HU',
        'NL',
        'PL',
        'BENL',
        'BEFR',
        'CHDE',
        'CHIT',
        'CHFR',
        'LU',
        'CZ',
        'SK'
    };

    private Set<String> countriesPartnerSet = new Set<String>{
        'Germany'
    };
    
    public UnprocessedLeads() {
        currentLeads = new List<Lead>();
    }

    public void init() {
        Date myDate = date.newinstance(2016, 3, 30);
        String currentUserId = UserInfo.getUserId();
        String query = 'SELECT Owner.Email, FirstName, LastName, LeadSource, Company, Email, Status, CreatedDate, Sec_Channel__c, OwnerId, ' + 
            'Channel__c, Number_of_days__c, Country, CountryCode, RecordType.Name, Last_Owner_Change_Date__c ' + 
            'FROM Lead WHERE CreatedDate >= :myDate AND ((Sec_Channel__c = \'Inbound\' AND (Channel__c = \'Internet\' OR Channel__c = \'E-mail\')) OR ' +
            '(Sec_Channel__c = \'JITB\' AND Channel__c = \'Internet\') OR ' + 
            '(Sec_Channel__c = \'Partner\' AND Country IN :countriesPartnerSet)) AND ' +
            ' CountryCode IN :countriesSet AND ' + 
            ' isConverted = FALSE AND Status = \'Open\' AND Last_Owner_Change_Date__c != NULL AND ' + 
            ' OwnerId = :currentUserId LIMIT 1000';
    	currentLeads = Database.query(query);
    }
}