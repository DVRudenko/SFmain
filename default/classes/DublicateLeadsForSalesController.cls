public class DublicateLeadsForSalesController {
    public Lead currentLead {get; set;}
    public String leadName {get; set;}
    public String leadLastName {get; set;}
    public String leadCompany {get; set;}
    public String leadEmail {get; set;}
    public String leadEmailDomain {get; set;}
    public String leadPhone {get; set;}
    public String leadZipCode {get; set;}
    public Boolean isLeadNameSelected {get; set;}
    public Boolean isLeadLastNameSelected {get; set;}
    public Boolean isLeadCompanySelected {get; set;}
    public Boolean isLeadEmailSelected {get; set;}
    public Boolean isLeadEmailDomainSelected {get; set;}
    public Boolean isLeadPhoneSelected {get; set;}
    public Boolean isZipCodeSelected {get; set;}
    public List<Lead> matchingLeads {get; set;}
    public List<Contact> matchingContacts {get; set;}
    public List<Account> matchingAccounts {get; set;}
    public List<Opportunity> matchingOpportunities {get; set;}
    public Boolean isSelectedLeadFields;
    public Boolean isSelectedContactFields;
    public Boolean isSelectedAccountFields;
    public Boolean isSelectedOpportunitydFields;
    public String leadId;

    public String leadNameSOQL;
    public String leadLastNameSOQL;
    public String leadCompanySOQL;
    public String leadEmailSOQL;
    public String leadEmailDomainSOQL;
    public String leadPhoneSOQL;
    public String leadZipCodeSOQL;

    public DublicateLeadsForSalesController() {}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : display current lead and matching leads with selected checkboxes by default   
    *  CreatedDate     : 20/02/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.leadId = ApexPages.currentPage().getParameters().get('id');
        currentLead = [
                SELECT Phone, Company, FirstName, LastName, Email, PostalCode
                FROM Lead
                WHERE Id = :leadId
                LIMIT 1];
        String leadFirstName = '';
        if (currentLead.FirstName != null) {
            leadFirstName = currentLead.FirstName;
        }
        leadName = leadFirstName + ' ' + currentLead.LastName;
        leadName = leadName.removeStart(' ');
        leadNameSOQL = replaceQuotes(leadName);
        leadLastName = currentLead.LastName;
        leadLastNameSOQL = replaceQuotes(leadLastName);
        leadCompany = currentLead.Company;
        leadCompanySOQL = replaceQuotes(leadCompany);
        if (currentLead.Email != null) {
            leadEmail = currentLead.Email;
            leadEmailSOQL = replaceQuotes(leadEmail);
            leadEmailDomain = currentLead.Email.substringAfterLast('@');
            leadEmailDomainSOQL = replaceQuotes(leadEmailDomain);
            isLeadEmailSelected = true;
        }
        if (currentLead.Phone != null) {
            leadPhone = currentLead.Phone;
            leadPhoneSOQL = replaceQuotes(leadPhone);
        }

        if (currentLead.PostalCode != null) {
            leadZipCode = currentLead.PostalCode;
            leadZipCodeSOQL = replaceQuotes(leadZipCode);
            isZipCodeSelected = false;
        }
        
        isSelectedLeadFields = false;
        isSelectedContactFields = false;
        isSelectedAccountFields = false;
        isSelectedOpportunitydFields = false;
        isLeadNameSelected = true;
        isLeadCompanySelected = true;
        isLeadPhoneSelected = true;

        selectSobjects();
    }


    /*******************************************************************************
    *  Name            : searchDublicates()
    *  Summary         : display current lead and matching leads with selected checkboxes   
    *  CreatedDate     : 20/02/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void searchDublicates() {
        matchingLeads = null;
        matchingContacts = null;
        matchingAccounts = null;
        matchingOpportunities = null;

        isSelectedLeadFields = false;
        isSelectedContactFields = false;
        isSelectedAccountFields = false;
        isSelectedOpportunitydFields = false;

        leadNameSOQL = replaceQuotes(leadName);
        leadLastNameSOQL = replaceQuotes(leadLastName);
        leadCompanySOQL = replaceQuotes(leadCompany);
        if (leadEmail != null) {
            leadEmailSOQL = replaceQuotes(leadEmail);
            leadEmailDomainSOQL = replaceQuotes(leadEmailDomain);
        }

        if (leadPhone != null) {
            leadPhoneSOQL = replaceQuotes(leadPhone);
        }
        
        if (leadZipCode != null) {
            leadZipCodeSOQL = replaceQuotes(leadZipCode);
        }

        if (isLeadNameSelected == false && isLeadLastNameSelected == false && isLeadCompanySelected == false && isLeadEmailSelected == false &&
            isLeadEmailDomainSelected == false && isLeadPhoneSelected == false && isZipCodeSelected == true) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please use two or more options if Zip Code selected'));
        } else {
            selectSobjects();
        }
    }


    /*******************************************************************************
    *  Name            : replaceQuotes(String queryString)
    *  Summary         : replace quotes in SOQL requests
    *  CreatedDate     : 24/05/2017
    *  Parameters      : String queryString - String to change
    *  Returns         : String
    ******************************************************************************/
    public String replaceQuotes(String queryString) {
        queryString = queryString.replace('\'', '\\' + '\'');
        queryString = queryString.replace('\"', '\\' + '\"');
        return queryString;
    }


    /*******************************************************************************
    *  Name            : selectSobjects()
    *  Summary         : select Sobjects from Database with matching filters
    *  CreatedDate     : 24/05/2017 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectSobjects() {
        String queryLeads = 'SELECT Salutation, FirstName, LastName, Title, Phone, Company, Email, Status, Owner.Alias, CreatedDate,' + 
                ' Partner_OBN__c, OwnerId, PostalCode FROM Lead WHERE Id != :leadId AND IsConverted = false AND (';
        String queryContacts = 'SELECT Salutation, FirstName, LastName, Account.Name, Account.Website, Phone, Email, Owner.Alias,' +
                ' CreatedDate, OwnerId, MailingPostalCode FROM Contact WHERE ';
        String queryAccounts = 'SELECT Name, Site, Phone, Owner.Alias, Art_des_Standorts__c, OBN__c, CreatedDate, OwnerId, BillingPostalCode' + 
                ' FROM Account WHERE ';
        String queryOpportunities = 'SELECT Name, Account.Name, Account.Site, StageName, CloseDate, Owner.Alias, CreatedDate, OwnerId' +
                ' FROM Opportunity WHERE ';
        if (isLeadNameSelected == true) {
            queryLeads += 'Name LIKE \'' + '%' + leadNameSOQL + '%' + '\' OR Firstname LIKE \'' + '%' + leadNameSOQL + '%' + '\' OR LastName LIKE \'' + '%' + leadNameSOQL + '%' + '\' OR ' + 
                    'Phone LIKE \'' + leadNameSOQL + '%' + '\' OR Email LIKE \'' + leadNameSOQL + '\' OR Name LIKE \'' + leadNameSOQL.substringBefore(' ') + '%' + leadNameSOQL.substringAfterLast(' ') + '\' OR ' +
                    'Company LIKE \'' + '%' + leadNameSOQL + '%' + '\' OR ';
            queryContacts += 'Name LIKE \'' +'%' + leadNameSOQL + '%' + '\' OR Phone LIKE \'' + leadNameSOQL + '%' + '\' OR Email LIKE \'' + leadNameSOQL + '\' OR ' +
                    'Name LIKE \'' + leadNameSOQL.substringBefore(' ') + '% ' + leadNameSOQL.substringAfter(' ') + '%' + '\' OR ';
            queryAccounts += 'Name LIKE \'' + leadNameSOQL + '\' OR Name LIKE \''  + leadNameSOQL + ' %' + '\' OR Name LIKE \'' + '% ' + leadNameSOQL + '\' OR ' + 
                    'Phone LIKE \'' + leadNameSOQL + '%' + '\' OR Site LIKE \'' + leadNameSOQL + '\' OR Name LIKE \'' + leadNameSOQL.substringBefore(' ') + '% ' + leadNameSOQL.substringAfter(' ') + '%' + '\' OR ';
            queryOpportunities += 'Name LIKE \'' + leadNameSOQL + '\' OR Name LIKE \''  + leadNameSOQL + ' %' + '\' OR Name LIKE \'' + '% ' + leadNameSOQL + '\' OR ' +
                    'Name LIKE \'' + leadNameSOQL.substringBefore(' ') + '% ' + leadNameSOQL.substringAfter(' ') + '%' + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
            isSelectedAccountFields = true;
            isSelectedOpportunitydFields = true;
        }

        if (isLeadLastNameSelected == true) {
            queryLeads += 'LastName LIKE \'' + '%' + leadLastNameSOQL + '%' + '\' OR Company LIKE \'' + '%' + leadLastNameSOQL + '%' + '\' OR Firstname LIKE \'' + leadLastNameSOQL + '%' + '\' OR ' +
                         'PostalCode LIKE \'' + '%' + leadLastNameSOQL + '%' + '\' OR ';
            queryContacts += 'LastName LIKE \'' + '%' + leadLastNameSOQL + '%' + '\' OR ';
            queryAccounts += 'Name LIKE \'' + '%' + leadLastNameSOQL + '%' + '\' OR ';
            queryOpportunities += 'Name LIKE \'' + '%' + leadLastNameSOQL + '%' + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
            isSelectedAccountFields = true;
            isSelectedOpportunitydFields = true;
        }

        if (isLeadCompanySelected == true) {
            queryLeads += 'Name LIKE \'' + leadCompanySOQL + '\' OR Firstname LIKE \'' + leadCompanySOQL + '\' OR LastName LIKE \'' + leadCompanySOQL + '\' OR ' + 
                    'Phone LIKE \'' + leadCompanySOQL + '%' + '\' OR Email LIKE \'' + leadCompanySOQL + '\' OR Company LIKE \'' + leadCompanySOQL + '\' OR ';
            queryContacts += 'Name LIKE \'' + leadCompanySOQL + '\' OR Firstname LIKE \'' + leadCompanySOQL + '\' OR LastName LIKE \'' + leadCompanySOQL + '\' OR ' + 
                    'Phone LIKE \'' + leadCompanySOQL + '%' + '\' OR Email LIKE \'' + leadCompanySOQL + '\' OR ';
            queryAccounts += 'Name LIKE \'' + leadCompanySOQL + '\' OR Name LIKE \''  + leadCompanySOQL + '%' + '\' OR Name LIKE \'' + '% ' + leadCompanySOQL + '\' OR ' + 
                    'Phone LIKE \'' + leadCompanySOQL + '%' + '\' OR Site LIKE \'' + leadCompanySOQL + '\' OR ';
            queryOpportunities += 'Name LIKE \'' + leadCompanySOQL + '\' OR Name LIKE \''  + leadCompanySOQL + ' %' + '\' OR Name LIKE \'' + '% ' + leadCompanySOQL + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
            isSelectedAccountFields = true;
            isSelectedOpportunitydFields = true;
        }

        if (isLeadEmailSelected == true) {
            queryLeads += 'Email LIKE \'' + leadEmailSOQL + '\' OR ';
            queryContacts += 'Email LIKE \'' + leadEmailSOQL + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
        }

        if (isLeadEmailDomainSelected == true) {
            queryLeads += 'Email LIKE \'' + '%@' + leadEmailDomainSOQL + '\' OR ';
            queryContacts += 'Email LIKE \'' + '%@' + leadEmailDomainSOQL + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
        }

        if (isLeadPhoneSelected == true) {
            queryLeads += 'Phone LIKE \'' + leadPhoneSOQL + '\' OR ';
            queryContacts += 'Phone LIKE \'' + leadPhoneSOQL + '%' + '\' OR Email LIKE \'' + '%' + leadPhoneSOQL + '%' + '\' OR ';
            queryAccounts += 'Phone LIKE \'' + leadPhoneSOQL + '%' + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
            isSelectedAccountFields = true;
        }

        if (isZipCodeSelected == true) {
            queryLeads += 'PostalCode LIKE \'' + leadZipCodeSOQL + '\' OR ';
            queryContacts += 'MailingPostalCode LIKE \'' + leadZipCodeSOQL + '\' OR ';
            queryAccounts += 'BillingPostalCode LIKE \'' + leadZipCodeSOQL + '\' OR ';
            isSelectedLeadFields = true;
            isSelectedContactFields = true;
            isSelectedAccountFields = true;
        }

        queryLeads = queryLeads.removeEnd('OR ');
        queryLeads += ') ORDER BY NAME ASC LIMIT 100';
        queryContacts = queryContacts.removeEnd('OR ');
        queryContacts += 'ORDER BY NAME LIMIT 100';
        queryAccounts = queryAccounts.removeEnd('OR ');
        queryAccounts += 'ORDER BY NAME LIMIT 100';
        queryOpportunities = queryOpportunities.removeEnd('OR ');
        queryOpportunities += 'ORDER BY NAME LIMIT 100';

        if (isSelectedLeadFields) {
            matchingLeads = Database.query(queryLeads);
        }

        if (isSelectedContactFields) {
            matchingContacts = Database.query(queryContacts); 
        }

        if (isSelectedAccountFields) {
            matchingAccounts = Database.query(queryAccounts);
        }

        if (isSelectedOpportunitydFields) {
            matchingOpportunities = Database.query(queryOpportunities);
        }
    }
 

    /*******************************************************************************
    *  Name            : backToLead()
    *  Summary         : Redirect to lead record     
    *  CreatedDate     : 22/02/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public PageReference backToLead() {
        return new PageReference('/' + this.leadId);
    }

}