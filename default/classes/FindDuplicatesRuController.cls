public class FindDuplicatesRuController {
    public enum SearchingFields {
        Company
    }

    public Boolean isCompanySelected { get; set; }
    public Boolean isBackToRecord { get; set; }

    public String searchString { get; set; }
    public String searchCompany { get; set; }
    public String findPageTitle { get; set; }

    public Map<Id, Lead> matchingLeads { get; set; }
    public Map<Id, Opportunity> matchingOpportunities { get; set; }
    public Map<Id, Account> matchingAccounts { get; set; }
    public Map<Id, Contact> matchingContacts { get; set; }
    public Map<Id, User> managerUserMap { get; set; }
    public Map<Id, Lead> leadActivityMap { get; set; }
    public Map<Id, Opportunity> oppActivityMap { get; set; }
    public Map<Id, UserRecordAccess> recordAccessMap { get; set; }

    public String commentForRequest { get; set; }

    public String companySOSL;

    public String idObject;

    public Boolean isInboundRole{get; private set;}

    private Set<String> numberSet = new Set<String>{
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    };

    private List<String> escapedSymbols = new List<String>{
            '?', '&', '|', '!', '{', '}', '[', ']', '(', ')', '^', '~', '*', ':', '\\', '\"', '\'', '+', '-'
    };

    /*******************************************************************************
     *  Name            : search()
     *  Summary         : Action of Button from Home Page(VF-FindDuplicatesSidebar). For search lead/opp/acc/contact
     *  CreatedDate     : 31/08/2017
     *  Parameters      : -
     *  Returns         : PageReference
     *****************************************************************************/
    public PageReference search() {
        PageReference ref = new PageReference('/apex/FindDuplicatesRu');

        this.isCompanySelected = false;

        if (this.searchString.trim() != '' && this.searchString.trim().length() > 3) {
            this.companySOSL = replaceQuotesSOSL(this.searchString);
            this.isCompanySelected = true;
            this.searchCompany = this.searchString;
        }

        selectSobjects();
        return ref;
    }

    /*******************************************************************************
    *  Name            : isInboundUserRole()
    *  Summary         : Check user is inbound
    *  CreatedDate     : 28/12/2017
    *  Parameters      : roleId - user role Id
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isInboundUserRole(Id roleId) {
        Set<String> restrictRoleNames = new Set<String>();
        for (RU_Inbound_Restrict_Group__c roleName : [SELECT id, name FROM RU_Inbound_Restrict_Group__c]) {
            restrictRoleNames.add(roleName.name);
        }

        List<UserRole> userRoles = ([SELECT Name FROM UserRole WHERE Id =: roleId AND Name =: restrictRoleNames]);

        if(userRoles.isEmpty()){
            return false;
        }
        return true;
    }

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Action of Controller. Display matching lead/opp/acc/contacts  with current lead
    *  CreatedDate     : 31/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.isInboundRole = isInboundUserRole(UserInfo.getUserRoleId());
        this.findPageTitle = 'Поиск дубликатов';
        this.idObject = ApexPages.currentPage().getParameters().get('id');
        if (this.idObject != null) {
            this.isBackToRecord = true;
            String typeName = ID.valueOf(this.idObject).getSObjectType().getDescribe().getName();
            if (typeName == 'Lead') {
                Lead currentLead = [
                        SELECT Phone_clean__c, Company, Name, FirstName, LastName, Email, PostalCode, INN__c, Formatted_phones__c
                        FROM Lead
                        WHERE ID = :this.idObject
                ];
                this.findPageTitle = 'Поиск дубликатов по интересу: "' + currentLead.FirstName + ' ' + currentLead.LastName + '" ';

                if (currentLead.company != null)
                    this.searchCompany = currentLead.company; else
                        this.searchCompany = currentLead.name;
                this.isCompanySelected = true;
                this.companySOSL = replaceQuotesSOSL(this.searchCompany);

                selectSobjects();
            } else if (typeName == 'Opportunity') {
                Opportunity currentOpportunity = [
                        SELECT name, inn_opp__c, company_legal_name__c, account.name, account.phone_clean__c, Source_of_Lead_o__c
                        FROM Opportunity
                        WHERE ID = :idObject
                ];
                this.findPageTitle = 'Поиск дубликатов по возможности: "' + currentOpportunity.name + '"';

                if (currentOpportunity.name != null) {
                    this.searchCompany = currentOpportunity.name;
                    this.companySOSL = replaceQuotesSOSL(this.searchCompany);
                    this.isCompanySelected = true;
                }

                selectSobjects();
                List<Contact> latestContacts;
                if(currentOpportunity.Source_of_Lead_o__c == 'E2E Form RU'){
                    latestContacts = [
                            SELECT Email,Phone
                            FROM Contact
                            WHERE AccountId = :currentOpportunity.AccountId
                            ORDER BY CreatedDate ASC
                            LIMIT 1
                    ];
                } else {
                    latestContacts = [
                            SELECT Email,Phone
                            FROM Contact
                            WHERE AccountId = :currentOpportunity.AccountId
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                    ];
                }
            }
        } else this.isBackToRecord = false;
    }


    /*******************************************************************************
    *  Name            : searchPage()
    *  Summary         : Display matching lead/opp/acc/contacts with selected checkboxes and their text fields.
                         Function Work from VF-FindDuplicates
    *  CreatedDate     : 31/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void searchPage() {
        if (this.searchCompany != null)
            this.companySOSL = replaceQuotesSOSL(this.searchCompany);

        if (this.isCompanySelected == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0002_SelectFields));
            if (this.matchingLeads != null) this.matchingLeads.clear();
            if (this.matchingOpportunities != null) this.matchingOpportunities.clear();
            if (this.matchingAccounts != null) this.matchingAccounts.clear();
            if (this.matchingContacts != null) this.matchingContacts.clear();
        } else {
            selectSobjects();
        }
    }

    /*******************************************************************************
    *  Name            : selectSobjects()
    *  Summary         : select/find Sobjects records from Database with matching filters
    *  CreatedDate     : 31/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectSobjects() {
        String recordTypeLead = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Lead'].ID;
        String recordTypeOpportunity = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Opportunity'].ID;
        String recordTypeAccount = [SELECT id FROM recordtype WHERE name = 'Russian' AND SobjectType = 'Account'].ID;
        String recordTypeContact = [SELECT id FROM recordtype WHERE name = 'Russian' AND SobjectType = 'Contact'].ID;

        List<lead> listlead = new List<lead>();
        List<Opportunity> listOpportunities = new List<Opportunity>();
        List<Account> listAccount = new List<Account>();
        List<Contact> listContact = new List<Contact>();

        this.matchingLeads = new Map<id, lead>();
        this.matchingOpportunities = new Map<id, Opportunity>();
        this.matchingAccounts = new Map<id, Account>();
        this.matchingContacts = new Map<id, Contact>();
        this.recordAccessMap = new Map<Id, UserRecordAccess>();

        Integer maxRowsLead = 100;
        Integer maxRowsOpportunity = 100;
        Integer maxRowsAccount = 100;
        Integer maxRowsContact = 100;

        Boolean isSelectedLeadFields = false;
        Boolean isSelectedAccountFields = false;
        Boolean isSelectedOpportunitydFields = false;
        Boolean isSelectedContactFields = false;

        String queryLeads = ' Lead(Id, Name, INN__c, Email, Additional_Emails__c, Company, Status, CreatedDate, Owner.Name, Owner.Phone, Owner.Email,' +
                'OwnerId,Source_of_Lead__c,Phone_clean__c, IsConverted, LastTransferDate, Phone, Formatted_phones__c ' +
                'WHERE RecordType.id = \'' + recordTypeLead + '\' ';
        string queryOpportunities = ' Opportunity(Id, Name, INN_Opp__c, Organization_Type__c, Company_Legal_Name__c, Account.Name, Account.phone, Telefon_Phone__c,' +
                'StageName, CloseDate, CreatedDate, Owner.Alias, Owner.Name, Owner.Phone, Owner.Email, OwnerId, Owner.ManagerId, Source_of_lead_o__c,' +
                'Owner.Manager.FirstName, Owner.Manager.Phone, Owner.Manager.Email, Owner.Manager.LastName,Account.Phone_clean__c, IsWon, Last_Owner_Change_Date_RUS__c ' +
                'WHERE RecordType.id = \'' + recordTypeOpportunity + '\' ';
        String queryAccounts = ' Account(Id, Name, Company_Legal_Name1__c, INN__c, Type, ParentId, Parent.Name, Phone, CreatedDate, OwnerId, Owner.Alias, Owner.Phone,' +
                'Owner.Email, Owner.Manager.FirstName, account.Owner.Manager.LastName, Owner.Manager.Phone, Owner.Manager.Email,Phone_clean__c ' +
                'WHERE RecordType.id = \'' + recordTypeAccount + '\' ';
        String queryContacts = ' Contact(Id, Name, Phone, Email, Additional_Emails__c, CreatedDate, OwnerId, Owner.Alias, Owner.Phone, Owner.Email, Formatted_phones__c, ' +
                'Owner.Manager.FirstName, Owner.Manager.LastName, Owner.Manager.Phone, Owner.Manager.Email,Phone_clean__c, Account.Name, Account.OwnerId ' +
                'WHERE RecordType.id = \'' + recordTypeContact + '\' ';

//-----------------FIND sobjects by "Name"--------------------------------------
        if (this.isCompanySelected == true && this.companySOSL.length() > 3) {
            List<List<Sobject>> listSobjects = search.query('FIND {*' + this.companySOSL + '*} IN NAME FIELDS RETURNING ' +
                    queryLeads + ' ORDER BY NAME LIMIT ' + maxRowsLead + '),' +
                    queryOpportunities + ' ORDER BY NAME LIMIT ' + maxRowsOpportunity + '),' +
                    queryAccounts + ' ORDER BY NAME LIMIT ' + maxRowsAccount + '),' +
                    queryContacts + ' ORDER BY NAME LIMIT ' + maxRowsContact + ')');
            listlead = ((List<Lead>) listSobjects[0]);
            listOpportunities = ((List<Opportunity>) listSobjects[1]);
            listAccount = ((List<Account>) listSobjects[2]);
            listContact = ((List<Contact>) listSobjects[3]);
            //---Lead
            for (Lead lead : listLead) {
                if (!this.matchingLeads.containsKey(lead.id)) this.matchingLeads.put(lead.id, lead);
            }
            maxRowsLead = maxRowsLead - this.matchingLeads.size();
            if (maxRowsLead < 0) maxRowsLead = 0;
            //---Opportunity
            for (Opportunity opportunity : listOpportunities) {
                if (!this.matchingOpportunities.containsKey(opportunity.id)) this.matchingOpportunities.put(opportunity.id, opportunity);
            }
            maxRowsOpportunity = maxRowsOpportunity - this.matchingOpportunities.size();
            if (maxRowsOpportunity < 0) maxRowsOpportunity = 0;
            //---Account
            for (Account account : listAccount) {
                if (!this.matchingAccounts.containsKey(account.id)) this.matchingAccounts.put(account.id, account);
            }
            maxRowsAccount = maxRowsAccount - this.matchingAccounts.size();
            if (maxRowsAccount < 0) maxRowsAccount = 0;
            //---Contact
            for (Contact contact : listContact) {
                if (!this.matchingContacts.containsKey(contact.id)) this.matchingContacts.put(contact.id, contact);
            }
            maxRowsContact = maxRowsContact - this.matchingContacts.size();
            if (maxRowsContact < 0) maxRowsContact = 0;

            isSelectedLeadFields = true;
            isSelectedOpportunitydFields = true;
            isSelectedAccountFields = true;
            isSelectedContactFields = true;
        }

        Integer allSize = 0; // Total amount of records for check result of user query
//-----------------IF Lead records are searched --------------------------------------
        if (isSelectedLeadFields == true) {
            allSize += this.matchingLeads.size();

            Set<Id> usersId = new Set<Id>();
            Set<id> selectedLeadId = new Set<Id>();
            for (Lead lead : this.matchingLeads.values()) {
                if (String.valueOf(lead.OwnerId).substring(0, 3) == '005') {
                    usersId.add(lead.OwnerId);
                }
                selectedLeadId.add(lead.id);
            }
            //---Lead Manager info
            List<User> usersList = new List<User>();
            usersList = [
                    SELECT Id, ManagerId, Manager.FirstName, Manager.LastName, Manager.Phone, Manager.Email
                    FROM User
                    WHERE Id IN :usersId
                    LIMIT 1000
            ];
            this.managerUserMap = new Map<Id, User>();
            for (User user : usersList) {
                if (user.Id != null) {
                    this.managerUserMap.put(user.Id, user);
                }
            }
            //---Lead Activity info
            List<Lead> leadActivity = new List<lead>();
            leadActivity = [
                    select id, (Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1)
                    FROM lead
                    where ID IN :selectedLeadId
                    limit 100
            ];
            this.LeadActivityMap = new map<id, Lead>();
            for (Lead lead : leadActivity) {
                if (lead.Id != null) {
                    this.leadActivityMap.put(lead.Id, lead);
                }
            }
            //---Lead Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT recordId, hasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :selectedLeadId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordId, userRecordAccess);
            }
            //-- chouse record for approve
        }
//-----------------IF Opportunity records are searched --------------------------------------
        if (isSelectedOpportunitydFields == true) {
            allSize += this.matchingOpportunities.size();

            Set<id> selectedOppId = new Set<Id>();
            for (Opportunity opp : this.matchingOpportunities.values()) {
                selectedOppId.add(opp.id);
            }
            //---Opportunity Activity info
            List<Opportunity> oppActivity = new List<Opportunity>();
            oppActivity = [
                    select id, (Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1)
                    FROM Opportunity
                    WHERE ID IN :selectedOppId
                    limit 100
            ];
            this.oppActivityMap = new map<id, Opportunity>();
            for (Opportunity opportunity : oppActivity) {
                if (opportunity.Id != null) {
                    this.oppActivityMap.put(opportunity.Id, opportunity);
                }
            }
            //---Opportunity Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT recordId, hasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :selectedOppId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordId, userRecordAccess);
            }
        }
//-----------------IF Account records are searched --------------------------------------
        if (isSelectedAccountFields == true) {
            allSize += this.matchingAccounts.size();

            Set<id> selectedAccountId = new Set<Id>();
            for (Account account : this.matchingAccounts.values()) {
                selectedAccountId.add(account.id);
                selectedAccountId.add(account.ParentId);
            }
            //---Account Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT RecordId, HasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :selectedAccountId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordid, userRecordAccess);
            }
        }
//-----------------IF Contact records are searched --------------------------------------
        if (isSelectedContactFields == true) {
            allSize += this.matchingContacts.size();

            Set<id> SelectedContactId = new Set<Id>();
            for (Contact cont : this.matchingContacts.values()) {
                SelectedContactId.add(cont.id);
            }
            //---Contact Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT RecordId, HasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :SelectedContactId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordid, userRecordAccess);
            }
        }

        if (allSize == 0) {
            if ((this.isCompanySelected && this.companySOSL.length() < 4)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0001_DuplicatesSymbol));
            } else if ((this.isCompanySelected && this.companySOSL.length() > 3)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0003_SelectAnother));
            }
        }
    }

    /*******************************************************************************
    *  Name            : replaceQuotesSOSL(String queryString)
    *  Summary         : replace quotes in SOSL requests
    *  CreatedDate     : 31/08/2017
    *  Parameters      : String queryString - String to change
    *  Returns         : String
    ******************************************************************************/
    public String replaceQuotesSOSL(String queryString) {
        for (integer i = 0; i <= escapedSymbols.size() - 1; i++) {
            queryString = queryString.replace(escapedSymbols[i], '*');
        }
        return queryString;
    }


    /*******************************************************************************
    *  Name            : backToRecord()
    *  Summary         : Redirect to lead record
    *  CreatedDate     : 31/08/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToRecord() {
        return new PageReference('/' + this.idObject);
    }
}
