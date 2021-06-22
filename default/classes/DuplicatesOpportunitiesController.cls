public class DuplicatesOpportunitiesController {
    public Opportunity currentOpportunity {get; set;}
    public List<Account> finalDuplicateAccountsList {get; set;}
    public List<Opportunity> finalDuplicateOpportunitiesList {get; set;}
    public List<Contact> finalDuplicatesContactsList {get; set;}
    public String currentOpportunityId;
    public Map<Id, RecordType> oppRecordTypes = new Map<Id,RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity']);


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : initialize current Lead and duplicate Lists of objects, find duplicates
    *  CreatedDate     : ?
    *  CreatedDate     : 11/12/2017
    *  ModifiedDate    : 11/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.finalDuplicateAccountsList = new List<Account>();
        this.finalDuplicateOpportunitiesList = new List<Opportunity>();
        this.finalDuplicatesContactsList = new List<Contact>();
        this.currentOpportunityId = ApexPages.currentPage().getParameters().get('id');
        getCurrentOpportunity();
        findOpportunitiesDuplicates();
        findAccountDuplicates();
        findContactsDuplicates();
    }


    /*******************************************************************************
    *  Name            : getCurrentLead()
    *  Summary         : get current Lead via SOQL query
    *  CreatedDate     : 11/12/2017
    *  ModifiedDate    : 11/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getCurrentOpportunity() {
        this.currentOpportunity = [
                SELECT Name, IBAN__c, Credit_System_Number__c, Account.Steuernummer__c, Account.Umsatzsteuer_ID__c, Account.Name, Account.BillingCountry,
                        Account.BillingCity, Account.BillingStreet, RecordTypeId,
                    (SELECT Contact.Id, Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name
                    FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :this.currentOpportunityId];
    }


    /*******************************************************************************
    *  Name            : findOpportunitiesDuplicates()
    *  Summary         : find duplicates in Opportunity objects
    *  CreatedDate     : 11/12/2017
    *  ModifiedDate    : 11/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void findOpportunitiesDuplicates() {
        Set<String> recordTypeForSearch = new Set<String>();
        if(oppRecordTypes.get(currentOpportunity.RecordTypeId).Name == 'Lotos'){
            recordTypeForSearch.add('Lotos');
        } else {
            recordTypeForSearch.add('Euroshell');
            recordTypeForSearch.add('Euroshell Starts');
        }
        String opportunitiesQuery = 'SELECT Name, IBAN__c, RecordType.Name, StageName, Gruende_verloren__c, Credit_System_Number__c, Creditreform_Nummer__c, AccountId' +
                ' FROM Opportunity' +
                ' WHERE RecordType.Name in :recordTypeForSearch ' + ((this.currentOpportunity.Account.BillingCountry != null) ? ' AND ' +
                    (this.currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' :
                    (this.currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR ' +
                    'Account.BillingCountry = \'Switzerland-FR\' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' +
                    clearFieldSOQL(this.currentOpportunity.Account.BillingCountry) + '\'')) : '') + ' AND (' +
                    ((this.currentOpportunity.Name != '[nicht vorhanden]' && this.currentOpportunity.Name != 'New Inbound Lead') ? 'Name = \'' +
                    clearFieldSOQL(this.currentOpportunity.Name) + '\'' : '') + ((this.currentOpportunity.IBAN__c != null && this.currentOpportunity.IBAN__c != 'n/a' &&
                    this.currentOpportunity.IBAN__c != 'X' && this.currentOpportunity.IBAN__c != 'x' && this.currentOpportunity.IBAN__c != 'XX' &&
                    this.currentOpportunity.IBAN__c != 'xx' && ! this.currentOpportunity.IBAN__c.containsIgnoreCase('XXX') && this.currentOpportunity.IBAN__c != 'DE000') ?
                    ' OR IBAN__c = \'' + clearFieldSOQL(this.currentOpportunity.IBAN__c) + '\'' : '') + ((this.currentOpportunity.Credit_System_Number__c != null) ?
                    ' OR Credit_System_Number__c = \'' + clearFieldSOQL(this.currentOpportunity.Credit_System_Number__c) +
                    '\' OR Creditreform_Nummer__c = \'' + clearFieldSOQL(this.currentOpportunity.Credit_System_Number__c) + '\'' : '') +
                ') LIMIT 100';
        List<Opportunity> duplicateOpportunitiesList = Database.query(opportunitiesQuery);
        this.finalDuplicateOpportunitiesList = new List<Opportunity>();
        Integer counter = 0;
        for (Opportunity opportunity : duplicateOpportunitiesList) {
            if ((opportunity.Name == this.currentOpportunity.Name || opportunity.IBAN__c == this.currentOpportunity.IBAN__c ||
                    opportunity.Credit_System_Number__c == this.currentOpportunity.Credit_System_Number__c ||
                    opportunity.Creditreform_Nummer__c == this.currentOpportunity.Credit_System_Number__c) &&
                    ! (opportunity.StageName == 'Closed Lost' && opportunity.Gruende_verloren__c != 'Refused Credit') &&
                    opportunity.Id != this.currentOpportunity.Id && opportunity.AccountId != this.currentOpportunity.AccountId) {
                this.finalDuplicateOpportunitiesList.add(opportunity);
                counter ++;
                if (counter == 5) {
                    break;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : findAccountDuplicates()
    *  Summary         : find duplicates in Account objects
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 08/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void findAccountDuplicates() {
        Set<String> recordTypeForSearch = new Set<String>{'Endkunde'};
        String accountsQuery = 'SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c, RecordType.Name, BillingCity, BillingStreet' +
                ' FROM Account' +
                ' WHERE RecordType.Name in :recordTypeForSearch ' + ((this.currentOpportunity.Account.BillingCountry != null) ? ' AND ' +
                    (this.currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(BillingCountry = \'Belgium-NL\' OR BillingCountry = \'Belgium-FR\')' :
                    (this.currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(BillingCountry = \'Switzerland-DE\' OR ' +
                    'BillingCountry = \'Switzerland-FR\' OR BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' +
                    clearFieldSOQL(this.currentOpportunity.Account.BillingCountry) + '\'')) : '') + ' AND (' + ((this.currentOpportunity.Account.Name != '[nicht vorhanden]' &&
                    this.currentOpportunity.Account.Name != 'New Inbound Lead') ? 'Name = \'' + clearFieldSOQL(this.currentOpportunity.Account.Name) +
                    '\'' : '') + (this.currentOpportunity.Account.Umsatzsteuer_ID__c != null ? ' OR Umsatzsteuer_ID__c = \'' +
                    clearFieldSOQL(this.currentOpportunity.Account.Umsatzsteuer_ID__c) + '\'' : '') + (this.currentOpportunity.Account.Steuernummer__c != null &&
                    this.currentOpportunity.Account.Steuernummer__c != 'nicht bekannt' && this.currentOpportunity.Account.Steuernummer__c != 'unbekannt' &&
                    this.currentOpportunity.Account.Steuernummer__c != '0' ? ' OR Steuernummer__c = \'' + clearFieldSOQL(this.currentOpportunity.Account.Steuernummer__c) + '\'' : '') +
                    (this.currentOpportunity.Account.BillingCity != null && this.currentOpportunity.Account.BillingStreet != null ? ' OR (BillingCity = \'' +
                    clearFieldSOQL(this.currentOpportunity.Account.BillingCity) + '\' AND BillingStreet = \'' + clearFieldSOQL(this.currentOpportunity.Account.BillingStreet) +
                    '\')' : '') +
                ') LIMIT 6';

        List<Account> duplicateAccountsList = Database.query(accountsQuery);
        this.finalDuplicateAccountsList = new List<Account>();
        Integer counter = 0;
        for (Account account : duplicateAccountsList) {
            if ((account.Name == this.currentOpportunity.Account.Name || account.Steuernummer__c == this.currentOpportunity.Account.Steuernummer__c ||
                    account.Umsatzsteuer_ID__c == this.currentOpportunity.Account.Umsatzsteuer_ID__c || account.BillingCity == this.currentOpportunity.Account.BillingCity &&
                    account.BillingStreet == this.currentOpportunity.Account.BillingStreet) && account.Id != this.currentOpportunity.Account.Id) {
                this.finalDuplicateAccountsList.add(account);
                counter ++;
                if (counter == 5) {
                    break;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : findContactDuplicates(String emailDomainForSOQL)
    *  Summary         : find duplicates in Opportunity objects
    *  CreatedDate     : 08/12/2017
    *  ModifiedDate    : 08/12/2017
    *  Parameters      : String emailDomainForSOQL - email domain of current Lead
    *  Returns         : void
    ******************************************************************************/
    public void findContactsDuplicates() {
        Set<Id> currentContactsIdsSet = new Set<Id>();
        Set<String> contactEmailsSet = new Set<String>();
        Set<String> contactPhonesSet = new Set<String>();
        Set<String> contactFirstNamesSet = new Set<String>();
        Set<String> contactLastNamesSet = new Set<String>();
        Set<String> contactDataSet = new Set<String>();
        for (OpportunityContactRole contactRole : this.currentOpportunity.OpportunityContactRoles) {
            currentContactsIdsSet.add(contactRole.ContactId);
            String contactDataString = '';
            if (contactRole.Contact.FirstName != null) {
                contactFirstNamesSet.add(clearFieldSOQL(contactRole.Contact.FirstName));
                contactDataString += clearFieldSOQL(contactRole.Contact.FirstName) + ' ';
            }

            contactDataString += clearFieldSOQL(contactRole.Contact.LastName) + ' ';
            contactLastNamesSet.add(clearFieldSOQL(contactRole.Contact.LastName));
            if (contactRole.Contact.Email != null) {
                contactEmailsSet.add(clearFieldSOQL(contactRole.Contact.Email));
                contactDataString += clearFieldSOQL(contactRole.Contact.Email.substringAfter('@'));
            }

            contactDataSet.add(contactDataString);

            if (contactRole.Contact.Phone != null) {
                contactPhonesSet.add(clearFieldSOQL(contactRole.Contact.Phone));
            }
        }

        Set<String> recordTypeForSearch = new Set<String>{'Endkunde'};
        String contactsQuery = 'SELECT FirstName, LastName, Phone, Email, Name, Account.RecordType.Name' +
                ' FROM Contact' +
                ' WHERE Account.RecordType.Name in :recordTypeForSearch ' + ((this.currentOpportunity.Account.BillingCountry != null) ? ' AND ' +
                    (this.currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' :
                    (this.currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR Account.BillingCountry = \'Switzerland-FR\' OR' +
                    ' Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + clearFieldSOQL(this.currentOpportunity.Account.BillingCountry) + '\'')) : '') +
                    ' AND (' + (! contactEmailsSet.isEmpty() ? 'Email IN :contactEmailsSet OR ' : '') + (! contactPhonesSet.isEmpty() ? 'Phone IN :contactPhonesSet OR ' : '') +
                    ((! contactLastNamesSet.isEmpty() && ! contactFirstNamesSet.isEmpty()) ? '(FirstName IN :contactFirstNamesSet AND LastName IN :contactLastNamesSet)' : '');
        contactsQuery = contactsQuery.removeEnd('OR ') + ') LIMIT 20';
        if (! contactsQuery.endsWith('() LIMIT 20')) {
            List<Contact> duplicateContactsList = Database.query(contactsQuery);
            Integer counter = 0;
            for (Contact contact : duplicateContactsList) {
                if ((contactEmailsSet.contains(contact.Email) || contactPhonesSet.contains(contact.Phone) ||
                        (contact.Email != null && contactDataSet.contains(contact.FirstName + ' ' + contact.LastName + ' ' + contact.Email.substringAfter('@')))) &&
                        ! currentContactsIdsSet.contains(contact.Id)) {
                    this.finalDuplicatesContactsList.add(contact);
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
    *  CreatedDate     : 23/01/2017
    *  ModifiedDate    : 23/01/2017
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