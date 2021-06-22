public class DuplicatesLeadsController {
    public Lead currentLead {get; set;}
    public List<Lead> finalDuplicateLeadsList {get; set;}
    public List<Account> finalDuplicateAccountsList {get; set;}
    public List<Opportunity> finalDuplicateOpportunitiesList {get; set;}
    public List<Contact> finalDuplicateContactsList {get; set;}
    public String currentLeadId;
    public Map<Id, RecordType> leadRecordTypes = new Map<Id,RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead']);


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : initialize current Lead and duplicate Lists of objects, find duplicates
    *  CreatedDate     : ?
    *  ModifiedDate    : 08/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.currentLead = new Lead();
        this.finalDuplicateLeadsList = new List<Lead>();
        this.finalDuplicateAccountsList = new List<Account>();
        this.finalDuplicateOpportunitiesList = new List<Opportunity>();
        this.finalDuplicateContactsList = new List<Contact>();
        this.currentLeadId = ApexPages.currentPage().getParameters().get('id');
        getCurrentLead();
        String emailDomain = getEmailDomainOfCurrentLead();
        findLeadDuplicates(emailDomain);
        findAccountDuplicates();
        findOpportunitiesDuplicates();
        findContactsDuplicates(emailDomain);
    }


    /*******************************************************************************
    *  Name            : getCurrentLead()
    *  Summary         : get current Lead via SOQL query
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 08/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getCurrentLead() {
        this.currentLead = [
                SELECT Email, Company, IBAN__c, Steuernummer__c, Umsatzsteuer_ID__c, Phone, FirstName, LastName, OwnerId, Country, City, Street, RecordTypeId
                FROM Lead
                WHERE Id = :this.currentLeadId];
    }


    /*******************************************************************************
    *  Name            : getEmailDomainOfCurrentLead()
    *  Summary         : get Email domain from Lead Email
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 08/12/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getEmailDomainOfCurrentLead() {
        String emailDomain = null;
        if (this.currentLead.Email != null) {
            emailDomain = '@' + this.currentLead.Email.substringAfter('@');
        }

        return emailDomain;
    }


    /*******************************************************************************
    *  Name            : findLeadDuplicates(String emailDomain)
    *  Summary         : find duplicates in Lead objects
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 25/01/2018
    *  Parameters      : String emailDomain - email domain of current Lead
    *  Returns         : void
    ******************************************************************************/
    public void findLeadDuplicates(String emailDomain) {
        String recordTypeForSearch;
        if(leadRecordTypes.get(currentLead.RecordTypeId).Name == 'Lotos'){
            recordTypeForSearch = 'Lotos';
        } else {
            recordTypeForSearch = 'Endkunde';
        }
        String leadsQuery = 'SELECT FirstName, LastName, Company, Phone, Email, Steuernummer__c, Umsatzsteuer_ID__c, IBAN__c, RecordType.Name, OwnerId' +
                ' FROM Lead' +
                ' WHERE RecordType.Name = \''+recordTypeForSearch+'\'' + ((this.currentLead.Country != null) ? ' AND ' + (this.currentLead.Country.contains('Belgium') ?
                    '(Country = \'Belgium-NL\' OR Country = \'Belgium-FR\')' : (this.currentLead.Country.contains('Switzerland') ? '(Country = \'Switzerland-DE\' OR ' +
                    'Country = \'Switzerland-FR\' OR Country = \'Switzerland-IT\')' : 'Country = \'' + clearFieldSOQL(this.currentLead.Country) + '\'')) : '') +
                    ' AND (' + ((this.currentLead.Company != '[nicht vorhanden]' && this.currentLead.Company != 'New Inbound Lead') ? 'Company = \'' +
                    clearFieldSOQL(this.currentLead.Company) + '\' OR ' : '') + ((this.currentLead.IBAN__c != null && this.currentLead.IBAN__c != 'n/a' &&
                    this.currentLead.IBAN__c != 'X' && this.currentLead.IBAN__c != 'x' && this.currentLead.IBAN__c != 'XX' &&
                    this.currentLead.IBAN__c != 'xx' && ! this.currentLead.IBAN__c.containsIgnoreCase('XXX') &&
                    this.currentLead.IBAN__c != 'DE000') ? 'IBAN__c = \'' + clearFieldSOQL(this.currentLead.IBAN__c) + '\' OR ' : '') +
                    (this.currentLead.Steuernummer__c != null && this.currentLead.Steuernummer__c != 'nicht bekannt' && this.currentLead.Steuernummer__c != '0' &&
                    this.currentLead.Steuernummer__c != 'unbekannt' ? 'Steuernummer__c = \'' + clearFieldSOQL(this.currentLead.Steuernummer__c) + '\' OR ' : '') +
                    (this.currentLead.Umsatzsteuer_ID__c != null ? 'Umsatzsteuer_ID__c = \'' + clearFieldSOQL(this.currentLead.Umsatzsteuer_ID__c) + '\' OR ' : '') +
                    (this.currentLead.Email != null ? 'Email = \'' + clearFieldSOQL(this.currentLead.Email) + '\' OR ' : '') +
                    (this.currentLead.Phone != null ? 'Phone = \'' + clearFieldSOQL(this.currentLead.Phone) + '\' OR ' : '') +
                    ((this.currentLead.FirstName != null && this.currentLead.Email != null) ? '(FirstName = \'' + clearFieldSOQL(this.currentLead.FirstName)  + '\'' +
                    ' AND LastName = \'' + clearFieldSOQL(this.currentLead.LastName) + '\')' : '');
        System.debug('DEBUG:  === ' + leadsQuery);
        leadsQuery = leadsQuery.removeEnd('OR ') + ') LIMIT 20';
        if (! leadsQuery.endsWith('() LIMIT 20')) {
            List<Lead> duplicateLeadsList = Database.query(leadsQuery);
            if (! duplicateLeadsList.isEmpty()) {
                Integer counter = 0;
                for (Lead lead : duplicateLeadsList) {
                    if ((lead.Company == this.currentLead.Company || lead.IBAN__c != null && lead.IBAN__c == this.currentLead.IBAN__c ||
                            lead.Steuernummer__c != null && lead.Steuernummer__c == this.currentLead.Steuernummer__c || lead.Umsatzsteuer_ID__c != null &&
                            lead.Umsatzsteuer_ID__c == this.currentLead.Umsatzsteuer_ID__c || lead.Phone != null && lead.Phone == this.currentLead.Phone ||
                            lead.Email != null && lead.Email == this.currentLead.Email || lead.FirstName == this.currentLead.FirstName &&
                            lead.LastName == this.currentLead.LastName && lead.Email != null && lead.Email.contains(emailDomain)) && lead.Id != currentLead.Id) {
                        this.finalDuplicateLeadsList.add(lead);
                        counter ++;
                        if (counter == 5) {
                            break;
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : findOpportunitiesDuplicates()
    *  Summary         : find duplicates in Opportunity objects
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 25/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void findOpportunitiesDuplicates() {
        Set<String> recordTypeForSearch = new Set<String>();
        if(leadRecordTypes.get(currentLead.RecordTypeId).Name == 'Lotos'){
            recordTypeForSearch.add('Lotos');
        } else {
            recordTypeForSearch.add('Euroshell');
            recordTypeForSearch.add('Euroshell Starts');
        }
        String opportunitiesQuery = 'SELECT Name, IBAN__c, RecordType.Name, StageName, Gruende_verloren__c, Name_of_the_payer_Account_holder__c, OwnerId' +
                ' FROM Opportunity' +
                ' WHERE RecordType.Name in :recordTypeForSearch ' + ((this.currentLead.Country != null) ? ' AND ' +
                    (this.currentLead.Country.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' :
                    (this.currentLead.Country.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR Account.BillingCountry = \'Switzerland-FR\'' +
                    ' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + clearFieldSOQL(this.currentLead.Country) + '\'')) : '') +
                    ' AND (' + ((this.currentLead.Company != '[nicht vorhanden]' && this.currentLead.Company != 'New Inbound Lead') ?
                    'Name = \'' + clearFieldSOQL(this.currentLead.Company) + '\' OR ' : '') + ((this.currentLead.IBAN__c != null && this.currentLead.IBAN__c != 'n/a' &&
                    this.currentLead.IBAN__c != 'X' && this.currentLead.IBAN__c != 'x' && this.currentLead.IBAN__c != 'XX' && this.currentLead.IBAN__c != 'xx' && !
                    this.currentLead.IBAN__c.containsIgnoreCase('XXX') && this.currentLead.IBAN__c != 'DE000') ? 'IBAN__c = \'' +
                    clearFieldSOQL(this.currentLead.IBAN__c) + '\'' : '');
        opportunitiesQuery = opportunitiesQuery.removeEnd('OR ') + ') LIMIT 100';
        if (! opportunitiesQuery.endsWith('() LIMIT 100')) {
            List<Opportunity> duplicateOpportunitiesList = Database.query(opportunitiesQuery);
            Integer counter = 0;
            for (Opportunity opportunity : duplicateOpportunitiesList) {
                if ((opportunity.Name == this.currentLead.Company || opportunity.IBAN__c == this.currentLead.IBAN__c) &&
                        ! (opportunity.StageName == 'Closed Lost' && opportunity.Gruende_verloren__c != 'Refused Credit')) {
                    this.finalDuplicateOpportunitiesList.add(opportunity);
                    counter ++;
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : findAccountDuplicates()
    *  Summary         : find duplicates in Account objects
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 25/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void findAccountDuplicates() {
        Set<String> recordTypeForSearch = new Set<String>{'Endkunde'};
        String accountsQuery = 'SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c, RecordType.Name, BillingCity, BillingStreet, BillingPostalCode, OwnerId' +
                ' FROM Account' +
                ' WHERE RecordType.Name in :recordTypeForSearch ' + ((this.currentLead.Country != null) ? ' AND ' + (this.currentLead.Country.contains('Belgium') ?
                    '(BillingCountry = \'Belgium-NL\' OR BillingCountry = \'Belgium-FR\')' : (this.currentLead.Country.contains('Switzerland') ?
                    '(BillingCountry = \'Switzerland-DE\' OR BillingCountry = \'Switzerland-FR\' OR BillingCountry = \'Switzerland-IT\')' : 'BillingCountry = \'' +
                    clearFieldSOQL(this.currentLead.Country) + '\'')) : '') + ' AND (' + ((this.currentLead.Company != '[nicht vorhanden]' && this.currentLead.Company != 'New Inbound Lead') ?
                    'Name = \'' + clearFieldSOQL(this.currentLead.Company) + '\' OR ' : '') + (this.currentLead.Umsatzsteuer_ID__c != null ? 'Umsatzsteuer_ID__c = \'' +
                    clearFieldSOQL(this.currentLead.Umsatzsteuer_ID__c) + '\' OR ' : '') + (this.currentLead.Steuernummer__c != null && this.currentLead.Steuernummer__c != 'nicht bekannt' &&
                    this.currentLead.Steuernummer__c != 'unbekannt' ? 'Steuernummer__c = \'' + clearFieldSOQL(this.currentLead.Steuernummer__c) + '\' OR ' : '') +
                    (this.currentLead.City != null && this.currentLead.Street != null ? '(BillingCity = \'' + clearFieldSOQL(this.currentLead.City) + '\' AND BillingStreet = \'' +
                    clearFieldSOQL(this.currentLead.Street) + '\')' : '');
        accountsQuery = accountsQuery.removeEnd('OR ') + ') LIMIT 5';
        if (! accountsQuery.endsWith('() LIMIT 5')) {
            this.finalDuplicateAccountsList = Database.query(accountsQuery);
        }
    }


    /*******************************************************************************
    *  Name            : findContactDuplicates(String emailDomain)
    *  Summary         : find duplicates in Opportunity objects
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 25/01/2018
    *  Parameters      : String emailDomain - email domain of current Lead
    *  Returns         : void
    ******************************************************************************/
    public void findContactsDuplicates(String emailDomain) {
        Set<String> recordTypeForSearch = new Set<String>{'Endkunde'};
        String contactsQuery = 'SELECT FirstName, LastName, Phone, Email, Name, Account.RecordType.Name, OwnerId' +
                ' FROM Contact' +
                ' WHERE Account.RecordType.Name in :recordTypeForSearch ' + ((this.currentLead.Country != null) ? ' AND ' + (this.currentLead.Country.contains('Belgium') ?
                    '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : (this.currentLead.Country.contains('Switzerland') ?
                    '(Account.BillingCountry = \'Switzerland-DE\' OR Account.BillingCountry = \'Switzerland-FR\' OR Account.BillingCountry = \'Switzerland-IT\')' :
                    'Account.BillingCountry = \'' + clearFieldSOQL(this.currentLead.Country)+ '\'')) : '') + ' AND (' + (this.currentLead.Email != null ? 'Email = \'' +
                    clearFieldSOQL(this.currentLead.Email) + '\' OR ' : '') + (this.currentLead.Phone != null ? 'Phone = \'' +
                    clearFieldSOQL(this.currentLead.Phone) + '\' OR ' : '') + ((this.currentLead.FirstName != null && this.currentLead.Email != null) ?
                    '(FirstName = \'' + clearFieldSOQL(this.currentLead.FirstName)  + '\'' + ' AND LastName = \'' + clearFieldSOQL(this.currentLead.LastName) + '\')' : '');
        contactsQuery = contactsQuery.removeEnd('OR ') + ') LIMIT 20';
        if (! contactsQuery.endsWith('() LIMIT 20')) {
            List<Contact> duplicateContactsList = Database.query(contactsQuery);
            Integer counter = 0;
            for (Contact contact : duplicateContactsList) {
                if ((contact.Email != null && contact.Email == this.currentLead.Email || contact.Phone != null && contact.Phone == this.currentLead.Phone ||
                        contact.FirstName == this.currentLead.FirstName && contact.LastName == this.currentLead.LastName && contact.Email != null &&
                        contact.Email.contains(emailDomain))) {
                    this.finalDuplicateContactsList.add(contact);
                    counter ++;
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : clearFieldSOQL(String field)
    *  Summary         : remove illegal characters from field for SOQL
    *  CreatedDate     : 23/01/2018
    *  ModifiedDate    : 23/01/2018
    *  Parameters      : String field - field for SOQL
    *  Returns         : String
    ******************************************************************************/
    private String clearFieldSOQL(String field) {
        if (field != null && field.contains('\'')) {
            field = field.replace('\'', '\\\'');
        }

        return field;
    }
}