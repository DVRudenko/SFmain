public class ETEDeduplicationService {
    private Account dupAccount;
    private Contact primaryDupContact;
    private Contact dupContact;
    private E2E_Data_Object__c dataObject;
    private List<E2E_Data_Contact__c> eteDataContacts;
    private Opportunity eteOpportunity;
    private Opportunity existingOpportunity;
    private String dupCase;


    public ETEDeduplicationService(E2E_Data_Object__c dataObject, List<E2E_Data_Contact__c> existingETEDataContacts) {
        this.dataObject = dataObject;
        this.eteDataContacts = existingETEDataContacts;
        this.eteOpportunity = [SELECT Name, AccountId, StageName, Registered_Country__c FROM Opportunity WHERE E2E_Data_Object__c = :this.dataObject.Id];
    }


    public void findDuplicates() {
        E2E_Data_Object__c e2EDataObject = this.dataObject;
        this.dupAccount = findDupAccount(e2EDataObject, eteOpportunity, null);
        this.primaryDupContact = selectDupContact(eteOpportunity, true);
        this.dupContact = selectDupContact(eteOpportunity, false);
    }


    public Opportunity getOpportunity() {
        return this.eteOpportunity;
    }


    public Account getAccount() {
        return this.dupAccount;
    }


    public Contact getPrimaryContact() {
        return this.primaryDupContact;
    }


    public Contact getContact() {
        return this.dupContact;
    }


    public void updateDupContactAsMergedInE2E(String accountId) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (E2E_Data_Contact__c dataContact : this.eteDataContacts) {
            if (accountId != null) {
                this.primaryDupContact.AccountId = accountId;
            }
            if (dataContact.isPrimary__c) {
                this.primaryDupContact.Merged_in_E2E__c = Datetime.now();
                this.primaryDupContact.Email = dataContact.Email__c;
                this.primaryDupContact.Phone = dataContact.Phone__c;
                this.primaryDupContact.FirstName = dataContact.First_name__c;
                this.primaryDupContact.LastName = dataContact.Last_name__c;
                this.primaryDupContact.Merged_in_E2E__c = Datetime.now();
                contactsToUpdate.add(this.primaryDupContact);
            } else if (this.dupContact != null) {
                this.dupContact.Merged_in_E2E__c = Datetime.now();
                this.dupContact.Email = dataContact.Email__c;
                this.dupContact.Phone = dataContact.Phone__c;
                this.dupContact.FirstName = dataContact.First_name__c;
                this.dupContact.LastName = dataContact.Last_name__c;
                this.dupContact.Merged_in_E2E__c = Datetime.now();
                contactsToUpdate.add(this.dupContact);
            }
        }
        update contactsToUpdate;
    }


    public void updateDupAccountAsMergedInE2E() {
        this.dupAccount.Merged_in_E2E__c = Datetime.now();
        update this.dupAccount;
    }


    public void generateCase() {
        List<Opportunity> opps = [
                SELECT RecordType.Name, E2E_Status__c, StageName, IsClosed, CloseDate, Gruende_verloren__c, Owner.FirstName,
                        Owner.LastName, Owner.Email, Credit_Stage__c, Registered_Country__c
                FROM Opportunity
                WHERE AccountId = :dupAccount.Id AND
                      Id != :this.eteOpportunity.Id];
        for (Opportunity opp : opps) {
            if (opp.StageName == 'Closed Won') {
                this.dupCase = 'already_a_customer';
                this.existingOpportunity = opp;
            } else if (((opp.RecordType.Name == 'Lotos' || opp.RecordType.Name == 'CCS Opportunity Layout') &&
                        (opp.Credit_Stage__c == 'CreditCheck' ||
                        opp.Credit_Stage__c == 'Pending Sales – Information' ||
                        opp.Credit_Stage__c == 'Pending Sales – Deposit' ||
                        opp.Credit_Stage__c == 'Pending Credit Report' ||
                        opp.Credit_Stage__c == 'Pending Credit - Contract Check' ||
                        opp.Credit_Stage__c == 'Credit Check - Pending Credit' ||
                        (opp.Credit_Stage__c == 'CreditCheck rejected' && opp.CloseDate.daysBetween(Date.today()) < 90))) ||
                    opp.StageName == 'CreditCheck' ||
                    opp.StageName == 'Pending Sales – Information' ||
                    opp.StageName == 'Pending Sales – Deposit' ||
                    opp.StageName == 'Pending Credit' ||
                    opp.StageName == 'Pending Sales - SEPA Confirmation' ||
                    (opp.StageName == 'Closed Lost' && opp.Gruende_verloren__c == 'Refused Credit' &&
                            opp.CloseDate.daysBetween(Date.today()) < 90) ||
                    (opp.StageName == 'CreditCheck abgelehnt' && opp.CloseDate.daysBetween(Date.today()) < 90)) {
                this.existingOpportunity = opp;
                this.dupCase = 'already_in_process';
            } else if (((opp.RecordType.Name == 'Lotos' || opp.RecordType.Name == 'CCS Opportunity Layout') &&
                        opp.IsClosed == false &&
                        (opp.StageName == 'Qualify' || opp.Credit_Stage__c == 'Credit approved')) ||
                    opp.StageName == 'Prospecting' || opp.StageName == 'Credit approved') {
                this.existingOpportunity = opp;
                this.dupCase = 'switched_to_e2e';
            } else if (opp.StageName == 'Closed Lost' && opp.Gruende_verloren__c == 'Refused Credit' && opp.CloseDate.daysBetween(Date.today()) >= 90) {
                this.existingOpportunity = opp;
                this.dupCase = 'credit_notification';
            } else if (((opp.RecordType.Name == 'Lotos' || opp.RecordType.Name == 'CCS Opportunity Layout') &&
                opp.Credit_Stage__c == 'CreditCheck rejected' && opp.CloseDate.daysBetween(Date.today()) >= 90) ||
                opp.StageName == 'CreditCheck abgelehnt' && opp.CloseDate.daysBetween(Date.today()) >= 90) {
                this.existingOpportunity = opp;
                this.dupCase = 'credit_switched_to_e2e';
            }
        }
    }


    public void processCase() {
        if (dupCase == null) return;
        if (dupCase == 'already_a_customer') {
            String country = this.eteOpportunity.Registered_Country__c;
            if (country == null) country = 'Germany';
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);
            if (settings != null && settings.Abandonment_User__c != null) {
                this.eteOpportunity.OwnerId = settings.Abandonment_User__c;
                update this.eteOpportunity;
            }

            String body = generateBodyForStarts();
            Starts_Settings__c startsSetting = Starts_Settings__c.getInstance(country);
            if (startsSetting != null &&  startsSetting.Notifications_Email__c != null) {
                sendSingleEmail(body, startsSetting.Notifications_Email__c);
            }
        }
        else if (dupCase == 'already_in_process') {
            this.eteOpportunity.Gruende_verloren__c = 'Duplicate';
            this.eteOpportunity.Kredit_Entscheidung__c = 'Abgelehnt';
            update this.eteOpportunity;

            String body = generateBodyForSales();
            sendSingleEmail(body, this.existingOpportunity.Owner.Email);
        }
        else if (dupCase == 'switched_to_e2e') {
            this.existingOpportunity.StageName = 'Closed Lost';
            this.existingOpportunity.Gruende_verloren__c = 'Switched to E2E';
            this.existingOpportunity.E2E_Status__c = 'Finished';
            update this.existingOpportunity;
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.existingOpportunity.Id);
            String body = generateBodyForSalesSwitchedToE2E();
            sendSingleEmail(body, this.existingOpportunity.Owner.Email);
        }
        else if (dupCase == 'credit_notification') {
            String body = generateBodyForCreditDepartment();
            User user = [SELECT Email FROM User WHERE Name = 'Credit' LIMIT 1];
            sendSingleEmail(body, user.Email);
        }
        else if (dupCase == 'credit_switched_to_e2e') {
            this.existingOpportunity.StageName = 'Closed Lost';
            this.existingOpportunity.Gruende_verloren__c = 'Switched to E2E';
            update existingOpportunity;
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.existingOpportunity.Id);
            String body = generateBodyForCreditDepartment();
            User user = [SELECT Email FROM User WHERE Name = 'Credit' LIMIT 1];
            sendSingleEmail(body, user.Email);

            String body2 = generateBodyForSalesSwitchedToE2E();
            sendSingleEmail(body2, this.existingOpportunity.Owner.Email);
        }
    }


    public String getStopProcess() {
        if (dupCase == 'already_a_customer') {
            return 'Already a customer';
        }
        else if (dupCase == 'already_in_process') {
            return 'Already in process';
        }

        return null;
    }


    private String generateBodyForStarts() {
        String body = 'Dear Start Team,<br/><br/>' +
                'New visitor started e2e Application and seems to be our current customer.<br/>' +
                'Please, check manually, if this is existing customer, who has transactions or if this customer has to be considered as a new one (>6 Months).<br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.existingOpportunity.Id + '" target="_blank">Link to Opportunity</a><br/><br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.eteOpportunity.Id + '" target="_blank">Link to E2E Opportunity</a><br/><br/>' +
                'Thanks and best regards.';
        return body;
    }


    private String generateBodyForSales() {
        String body = 'Dear ' + this.existingOpportunity.Owner.FirstName + ' ' + this.existingOpportunity.Owner.FirstName + ',<br/><br/>' +
                'Your customer ' + opportunity.Name + ' started e2e Application and tries to order cards online.<br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.existingOpportunity.Id + '" target="_blank">Current Opportunity</a><br/><br/>' +
                'Please, contact this customer as soon as possible to close the deal.<br/><br/>' +
                'Thanks and best regards.';
        return body;
    }


    private String generateBodyForCreditDepartment() {
        String body = 'Dear Credit Manager,<br/>' +
                'New visitor started e2e Application and is trying to order card online.<br/><br/>' +
                'This customer is already in SF:<br/>' +
                'Opportunity Stage: Credit Check Rejected OR Closed Lost (Reason Lost: Refused Credit)<br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.existingOpportunity.Id + '" target="_blank">Link to Opportunity</a><br/><br/>' +
                'Since more than 3 Months passed it will be allowed to run a Credit Score again.<br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.eteOpportunity.Id + '" target="_blank">Link to E2E Opportunity</a><br/><br/>' +
                'No actions are required at the moment.<br/><br/>' +
                'Thanks and best regards.';
        return body;
    }


    public String generateBodyForSalesSwitchedToE2E() {
        String body = 'Dear ' + this.existingOpportunity.Owner.FirstName + ' ' + this.existingOpportunity.Owner.LastName + ',<br/><br/>' +
                'Stage of your opportunity was changed to Closed Lost ' +
                'because your customer started e2e Application and tries to order cards online.<br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.existingOpportunity.Id + '" target="_blank">Link to Opportunity</a><br/><br/>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.eteOpportunity.Id + '" target="_blank">Link to E2E Opportunity</a><br/><br/>' +
                'No actions are required at the moment.<br/><br/>' +
                'Thanks and best regards.';
        return body;
    }


    private void sendSingleEmail(String body, String emailToSend) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject('E2E Notification');
        message.setHtmlBody(body);
        message.setToAddresses(new List<String>{emailToSend});
        if ( ! Test.isRunningTest() ) {
            Messaging.sendEmail(new List<Messaging.Email>{message});
        }
    }


    public static Account findDupAccount(E2E_Data_Object__c e2EDataObject, Opportunity opportunity, Lead lead) {
        String taxId;
        String companyName;
        String country;
        if (opportunity != null) {
            List<Credit_Factory_Report__c> report = [
                    SELECT Tax_Id__c, Name__c
                    FROM Credit_Factory_Report__c
                    WHERE Opportunity__c = :opportunity.Id
            ];
            if (report.isEmpty()) {
                return null;
            }

            taxId = report.get(0).Tax_Id__c;
            companyName = String.escapeSingleQuotes(report.get(0).Name__c);
            country = ETEGlobalUtils.returnCountry(e2EDataObject.Country_Code__c);
        } else {
            taxId = lead.Steuernummer__c;
            companyName = String.escapeSingleQuotes(lead.Company);
            country = lead.Country;
        }

        String accountId;
        if (opportunity != null && opportunity.AccountId != null) {
            accountId = opportunity.AccountId;
        }

        String accountDupsQuery;
        if (e2EDataObject.RecordType.Name == 'Czech Republic CCS' || e2EDataObject.RecordType.Name == 'Slovakia CCS') {
            accountDupsQuery = generateCCSAccountDupQuery(taxId, accountId, country);
        } else {
            accountDupsQuery = generateAccountDupQuery(taxId, companyName, accountId, country);
        }
        List<Account> accountsDupsList = Database.query(accountDupsQuery);

        if ( ! accountsDupsList.isEmpty() ) {
            return accountsDupsList.get(0);
        }

        return null;
    }


    private static String generateAccountDupQuery(String taxId, String companyName, String accountId, String country) {
        RecordType recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'CCS' LIMIT 1];
        String recordTypeId = recordType.Id;
        String accountDupsQuery =
                ' SELECT OwnerId, Owner.FirstName, Owner.LastName, Steuernummer__c, Owner.Email, Name ' +
                        ' FROM Account  ' +
                        ' WHERE RecordTypeId != \'' + recordTypeId + '\'' + ' AND Steuernummer__c != NULL AND (Name = \'' + companyName + '\' ';
        if (taxId != null && taxId != '' && taxId != 'unbekannt' && taxId != 'nicht bekannt' && taxId != '0') {
            accountDupsQuery += ' OR Steuernummer__c = \'' + taxId + '\' ';
        }
        accountDupsQuery += ')';
        if (accountId != null) {
            accountDupsQuery += ' AND Id != \'' + accountId + '\'';
        }
        accountDupsQuery += ' AND BillingCountry = \'' + country + '\'' +
                ' ORDER BY CreatedDate DESC ' +
                ' LIMIT 1';

        return accountDupsQuery;
    }


    private static String generateCCSAccountDupQuery(String taxId, String accountId, String country) {
        RecordType recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'CCS' LIMIT 1];
        String accountDupQuery = 'SELECT OwnerId, Owner.FirstName, Owner.LastName, Steuernummer__c, Owner.Email, Name ' +
                                 'FROM Account ' +
                                 'WHERE RecordTypeId = \'' + recordType.Id + '\' AND Steuernummer__c = \'' + taxId + '\' ';
        if (accountId != null) {
            accountDupQuery += ' AND Id != \'' + accountId + '\'';
        }
        accountDupQuery += ' AND BillingCountry = \'' + country + '\'' +
                ' ORDER BY CreatedDate DESC ' +
                ' LIMIT 1';

        return accountDupQuery;
    }


    private Contact selectDupContact(Opportunity opportunity, Boolean isPrimary) {
        String ocrQuery = 'SELECT ContactId, IsPrimary FROM OpportunityContactRole WHERE OpportunityId = \'' + opportunity.Id + '\'';
        if (isPrimary) {
            ocrQuery += ' AND IsPrimary = ' + isPrimary + '';
        }
        List<OpportunityContactRole> opportunityContactRoles = Database.query(ocrQuery);

        String contactDevName;
        if (this.dataObject.RecordType.Name == 'Czech Republic CCS' || this.dataObject.RecordType.Name == 'Slovakia CCS') {
            contactDevName = 'CCS_Contact_layout';
        } else {
            contactDevName = 'Contact_layout';
        }
        RecordType recordType = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Contact' AND
                      DeveloperName = :contactDevName
                LIMIT 1];
        String email;
        String phone;
        String firstName;
        String lastName;
        for (E2E_Data_Contact__c e2EDataContact : this.eteDataContacts) {
            if (e2EDataContact.isPrimary__c == isPrimary) {
                email = e2EDataContact.Email__c;
                phone = e2EDataContact.Phone__c.replaceAll(' ', '').replaceAll('-', '');
                firstName = e2EDataContact.First_Name__c;
                lastName = e2EDataContact.Last_Name__c;
            }
        }

        String country = ETEGlobalUtils.returnCountry(this.dataObject.Country_Code__c);

        String contactsQuery;
        if (this.dataObject.RecordType.Name == 'Czech Republic CCS' || this.dataObject.RecordType.Name == 'Slovakia CCS') {
            contactsQuery = generateCCSContactDupQuery(email, phone, firstName, lastName, recordType, opportunityContactRoles, country);
        } else {
            contactsQuery = generateContactDupQuery(email, phone, recordType, opportunityContactRoles, country);
        }
        List<Contact> duplicateContactList = Database.query(contactsQuery);
        if ( ! duplicateContactList.isEmpty() ) {
            return duplicateContactList.get(0);
        }

        return null;
    }


    private static String generateContactDupQuery(String email, String phone, RecordType recordType, List<OpportunityContactRole> contactRoles, String country) {
        String contactDupQuery =
                'SELECT Account.AccountSource, AccountId ' +
                'FROM Contact ' +
                'WHERE (Email = \'' + email + '\'' + ' OR Phone = \'' + phone + '\'' + ') AND ' +
                'MailingCountry = \'' + country + '\'' + ' AND RecordTypeId = \'' + recordType.Id + '\'';
        if ( ! contactRoles.isEmpty() ) {
            contactDupQuery += ' AND Id != \'' + contactRoles.get(0).ContactId + '\'';
        }
        contactDupQuery = contactDupQuery + ' ORDER BY CreatedDate DESC LIMIT 1';

        return contactDupQuery;
    }


    private static String generateCCSContactDupQuery(String email, String phone, String firstName, String lastName, RecordType recordType, List<OpportunityContactRole> contactRoles, String country) {
        String contactDupQuery =
                'SELECT Account.AccountSource, AccountId ' +
                        'FROM Contact ' +
                        'WHERE Email = \'' + email + '\'' + ' AND Phone = \'' + phone + '\'' + ' AND FirstName = \'' + firstName + '\'' + ' AND LastName = \'' + lastName + '\'' + ' AND ' +
                        'MailingCountry = \'' + country + '\'' + ' AND RecordTypeId = \'' + recordType.Id + '\'';
        if ( ! contactRoles.isEmpty() ) {
            contactDupQuery += ' AND Id != \'' + contactRoles.get(0).ContactId  + '\'';
        }
        contactDupQuery = contactDupQuery + ' ORDER BY CreatedDate DESC LIMIT 1';

        return contactDupQuery;
    }
}