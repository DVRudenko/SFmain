public class LeadConversionCtrl {
    public Lead lead {get; set;}
    public String leadId;
    public Boolean areDuplicatesFound {get; set;}
    public String countrySOQL;
    public Boolean isNotDuplicate {get; set;}

    public LeadConversionCtrl() {
        isNotDuplicate = false;
    }


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : select lead with required fields to convert
    *  CreatedDate     : 14/04/2017
    *  ModifiedDate    : 02/04/2018
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference init() {
        Boolean isFilled = true;
        Boolean isOwnerCurrentUser = true;
        this.areDuplicatesFound = false;
        this.leadId = ApexPages.CurrentPage().getparameters().get('id');
        if (this.leadId != null) {
            this.lead = [
                    SELECT Salutation, RecordType.Name, Anzahl_der_Fahrzeuge__c,
                            Branche_NACE__c, Beschaeftigte__c, OwnerId, FirstName, LastName,
                            ConvertedOpportunityId, ConvertedContactId, ConvertedAccountId,
                            Send_SEPA_approval_link__c, Email, Zahlungsart__c, Country,
                            Company, Steuernummer__c, Umsatzsteuer_ID__c,
                            IBAN__c, Phone, Street, City, PostalCode, Sec_Channel__c, Channel__c,
                            NIP__c, Product__c
                    FROM Lead
                    WHERE Id = :this.leadId];
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid record id. Please try again.'));
            return null;
        }
        List<String> requiredFieldsList = new List<String>();

        if (this.lead.Country == 'Germany' &&
                this.lead.Sec_Channel__c == 'JITB' &&
                this.lead.Channel__c == 'Fax') {
            requiredFieldsList.add(this.lead.Salutation);
            requiredFieldsList.add(String.valueOf(this.lead.Anzahl_der_Fahrzeuge__c));
            requiredFieldsList.add(this.lead.Country);
            requiredFieldsList.add(this.lead.Street);
            requiredFieldsList.add(this.lead.City);
            requiredFieldsList.add(this.lead.PostalCode);
            requiredFieldsList.add(this.lead.FirstName);
        } else {
            requiredFieldsList.add(this.lead.Salutation);
            requiredFieldsList.add(String.valueOf(this.lead.Anzahl_der_Fahrzeuge__c));
            requiredFieldsList.add(this.lead.Country);
            requiredFieldsList.add(this.lead.Street);
            requiredFieldsList.add(this.lead.City);
            requiredFieldsList.add(this.lead.PostalCode);
            requiredFieldsList.add(this.lead.FirstName);
            requiredFieldsList.add(this.lead.Branche_NACE__c);
            requiredFieldsList.add(this.lead.Beschaeftigte__c);
        }

        for (String requiredField : requiredFieldsList) {
            if (! validateRequiredFields(requiredField)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill all required for conversion fields.'));
                isFilled = false;
                break;
            }
        }
        if (this.lead.OwnerId != UserInfo.getUserId()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not Owner of the Lead. Please assign it to you.'));
            isOwnerCurrentUser = false;
        }

        // check for duplicates in Accounts, Opportunities and Contacts
        if (! this.isNotDuplicate) {
            checkDuplicates();
        }

        if (isFilled && isOwnerCurrentUser && this.areDuplicatesFound == false) {
            try {
                if (this.lead.RecordType.Name == 'Lotos'){
                    return continueConvert();
                } else {
                    if (this.lead.Send_SEPA_approval_link__c == true) {
                        EmailTemplate template = returnEmailTemplate();
                        validateSendLink(template);
                        convertLead();
                        sendEmail(this.lead.ConvertedOpportunityId, this.lead.ConvertedContactId, template);
                    } else {
                        convertLead();
                    }
                }
            } catch (Exception e) {
                System.debug('DEBUG: XXX === ' + e.getMessage() + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                return null;
            }
            if (this.lead.ConvertedOpportunityId != null) {
                return new PageReference('/' + this.lead.ConvertedOpportunityId);
            } else {
                return null;
            }
        } else {
            if (String.valueOf(this.lead.OwnerId).subString(0, 3) != '005') {
                this.lead.OwnerId = UserInfo.getUserId();
            }
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : validateRequiredFields(String field)
    *  Summary         : validate required to convert fields
    *  CreatedDate     : 14/04/2017
    *  Parameters      :
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateRequiredFields(String field) {
        if (field != null && field != '') {
            return true;
        } else {
            return false;
        }
    }


    /*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop conversion process
    *  CreatedDate     : 05/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkDuplicates() {
        String errorMessage = '';
        if (this.lead.Country != null) {
            this.countrySOQL = '%' + this.lead.Country.subStringBefore('-') + '%';
        }
        //errorMessage += checkOpportunityDuplicates();
        //errorMessage += checkAccountDuplicates();
        //errorMessage += checkContactDuplicates();
        errorMessage += checkDuplicatesInApp('Opportunity');
        errorMessage += checkDuplicatesInApp('Account');
        errorMessage += checkDuplicatesInApp('Contact');
        if (errorMessage != '') {
            errorMessage = 'Duplicates found:<br/>' + errorMessage +
                    '<br/>If the record was identified as a duplicate by mistake, tick the "Not duplicate" checkbox and click "Convert".';
            this.areDuplicatesFound = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
        }
    }


    /*******************************************************************************
    *  Name            : checkOpportunityDuplicates()
    *  Summary         : if Opportunity duplicates is existed then stop conversion process
    *  CreatedDate     : 06/12/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    /*private String checkOpportunityDuplicates() {
        Set<String> recordTypesToCheckSet = new Set<String>();
        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            recordTypesToCheckSet.add('Shell Universal Car');
        } else {
            recordTypesToCheckSet.add('Euroshell');
            recordTypesToCheckSet.add('Euroshell Starts');
        }
        List<Opportunity> duplicateOpportunitiesList = [
                SELECT Name, IBAN__c, Credit_System_Number__c
                FROM Opportunity
                WHERE RecordType.Name IN :recordTypesToCheckSet AND
                Account.BillingCountry LIKE :this.countrySOQL AND (Name = :this.lead.Company OR (IBAN__c != null AND
                IBAN__c = :this.lead.IBAN__c AND IBAN__c != 'n/a' AND IBAN__c != 'X' AND IBAN__c != 'XX' AND
                (NOT IBAN__c LIKE '%XXX%') AND IBAN__c != 'DE000')) AND (StageName != 'Closed Lost' OR
                (StageName = 'Closed Lost' AND Gruende_verloren__c = 'Refused Credit'))
                LIMIT 5];

        String errorMessage = '';
        if (! duplicateOpportunitiesList.isEmpty()) {
                    errorMessage += '<br/><b>Opportunities:</b><br/>';
            for (Opportunity opportunity : duplicateOpportunitiesList) {
                errorMessage += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id +
                        '">' + opportunity.Name + '</a> (';
                if (opportunity.Name == this.lead.Company) {
                    errorMessage += 'Name: ' + opportunity.Name + ', ';
                }
                if (opportunity.IBAN__c != null && opportunity.IBAN__c == this.lead.IBAN__c) {
                    errorMessage += 'IBAN: ' + opportunity.IBAN__c;
                }
                errorMessage = errorMessage.removeEnd(', ');
                errorMessage += ')<br/>';
            }
        }

        return errorMessage;
    }
     */


    /*******************************************************************************
    *  Name            : checkAccountDuplicates()
    *  Summary         : if Account duplicates is existed then stop credit process
    *  CreatedDate     : 06/12/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    /*private String checkAccountDuplicates() {
        Set<String> recordTypesToCheckSet = new Set<String>();
        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            recordTypesToCheckSet.add('Shell Universal Car');
        } else {
            recordTypesToCheckSet.add('Endkunde');
        }
        String errorMessage = '';
        List<Account> duplicateAccountsList = [
                SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c, BillingCity, BillingStreet
                FROM Account
                WHERE RecordType.Name IN :recordTypesToCheckSet AND
                BillingCountry LIKE :this.countrySOQL AND
                ((Steuernummer__c != null AND Steuernummer__c != 'nicht bekannt' AND Steuernummer__c != 'unbekannt' AND Steuernummer__c != '0' AND
                Steuernummer__c = :this.lead.Steuernummer__c) OR (Umsatzsteuer_ID__c != null AND Umsatzsteuer_ID__c = :this.lead.Umsatzsteuer_ID__c) OR
                Name = :this.lead.Company OR (BillingCity != null AND BillingStreet != null AND BillingCity = :this.lead.City AND BillingStreet = :this.lead.Street))
                LIMIT 5];

        if (! duplicateAccountsList.isEmpty()) {
                    errorMessage += '<br/><b>Accounts:</b><br/>';
            for (Account account : duplicateAccountsList) {
                errorMessage += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + account.Id +
                        '">' + account.Name + '</a> (';
                if (account.Name == this.lead.Company) {
                    errorMessage += 'Account Name: ' + account.Name + ', ';
                }
                if (account.Steuernummer__c != null && this.lead.Steuernummer__c == account.Steuernummer__c) {
                    errorMessage += 'Tax ID: ' + account.Steuernummer__c + ', ';
                }
                if (account.Umsatzsteuer_ID__c != null && this.lead.Umsatzsteuer_ID__c == account.Umsatzsteuer_ID__c) {
                    errorMessage += 'VAT number: ' + account.Umsatzsteuer_ID__c + ', ';
                }
                if (account.BillingCity != null && this.lead.City == account.BillingCity) {
                    errorMessage += 'City: ' + account.BillingCity + ', ';
                }
                if (account.BillingStreet != null && this.lead.Street == account.BillingStreet) {
                    errorMessage += 'Street: ' + account.BillingStreet;
                }
                errorMessage = errorMessage.removeEnd(', ');
                errorMessage += ')<br/>';
            }
        }

        return errorMessage;
    }
     */


    /*******************************************************************************
    *  Name            : checkContactDuplicates()
    *  Summary         : if Contact duplicates is existed then stop credit process
    *  CreatedDate     : 04/07/2017
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    /*private String checkContactDuplicates() {
        Set<String> recordTypesToCheckSet = new Set<String>();
        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            recordTypesToCheckSet.add('Shell Universal Car');
        } else {
            recordTypesToCheckSet.add('Endkunde');
        }
        List<Contact> duplicateContactsList = [
                SELECT Name, FirstName, LastName, Phone, Email
                FROM Contact
                WHERE Account.RecordType.Name IN :recordTypesToCheckSet AND
                Account.BillingCountry LIKE :this.countrySOQL AND
                ((Email != null AND Email = :this.lead.Email) OR
                (Phone != null AND Phone = :this.lead.Phone) OR
                (LastName = :this.lead.LastName AND FirstName != null AND FirstName = :this.lead.FirstName))
                LIMIT 10000];
        String errorMessage = '';
        if (! duplicateContactsList.isEmpty()) {
            Integer counter = 0;
            for (Contact contact : duplicateContactsList) {
                if (contact.Email == this.lead.Email || contact.Phone == this.lead.Phone ||
                        (contact.FirstName == this.lead.FirstName && contact.LastName == this.lead.LastName && contact.Email != null &&
                                this.lead.Email != null && contact.Email.substringAfter('@') == this.lead.Email.substringAfter('@'))) {
                if (! errorMessage.contains('<br/><b>Contacts:</b><br/>')) {
                    errorMessage += '<br/><b>Contacts:</b><br/>';
                }
                    errorMessage += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + contact.Id +
                            '">' + contact.Name + '</a> (';
                    if (contact.Email == this.lead.Email) {
                        errorMessage += 'Email: ' + contact.Email + ', ';
                    }
                    if (contact.Phone == this.lead.Phone) {
                        errorMessage += 'Phone: ' + contact.Phone + ', ';
                    }
                    if (contact.FirstName == this.lead.FirstName && contact.LastName == this.lead.LastName && contact.Email != null &&
                            this.lead.Email != null && contact.Email.substringAfter('@') == this.lead.Email.substringAfter('@')) {
                        errorMessage += 'First Name: ' + contact.FirstName + ', Last Name: ' + contact.LastName + ', Email domain: ' + contact.Email.substringAfter('@');
                }
                errorMessage = errorMessage.removeEnd(', ');
                errorMessage += ')<br/>';
                counter ++;
                if (counter == 5) {
                    break;
                    }
                }
            }
        }

        return errorMessage;
    }
     */

    private String checkDuplicatesInApp(String sObjectType) {
        CustomDeduplicationResult deduplicationResult;
        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            deduplicationResult = CustomDeduplicationAPI.findDuplicates(
                    this.lead.getPopulatedFieldsAsMap(),
                    Schema.getGlobalDescribe().get('Lead'),
                    Schema.getGlobalDescribe().get(sObjectType),
                    'LeadConversion_ShellUniversal'
            );
        } else {
            deduplicationResult = CustomDeduplicationAPI.findDuplicates(
                    this.lead.getPopulatedFieldsAsMap(),
                    Schema.getGlobalDescribe().get('Lead'),
                    Schema.getGlobalDescribe().get(sObjectType),
                    'LeadConversion_Endkunde'
            );
        }

        String errorMessage = '';
        if(deduplicationResult.resultError != null){
            errorMessage = '<br/><b>Error in Duplicate Search : ' + deduplicationResult.resultError.message + ' ' + deduplicationResult.resultError.stackTrace + '</b><br/>';
        }
        if (deduplicationResult.allResults.size() != 0) {
            Integer counter = 0;
            for(CustomDeduplicationResult.Result result : deduplicationResult.allResults){
                for (Id recordId : result.duplicatesNew.keySet()) {
                    SObject record = result.duplicatesNew.get(recordId);
                    if (! errorMessage.contains('<br/><b>' + sObjectType + ':</b><br/>')) {
                        errorMessage += '<br/><b>' + sObjectType + ':</b><br/>';
                    }
                    errorMessage += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + String.valueOf(record.get('Id')) +
                            '">' + record.get('Name') + '</a> (';
                    for(String duplicateField : result.duplicatesSearchInfo.get(recordId).fieldsMatch){
                        errorMessage += duplicateField + ':' + String.valueOf(record.get(duplicateField)) + ', ';
                    }
                    errorMessage = errorMessage.removeEnd(', ');
                    errorMessage += ')<br/>';
                    counter ++;
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Name            : convertLead()
    *  Summary         : converts lead if all required fields are filled, assigns tasks
                        from lead to opportunity
    *  CreatedDate     : 14/04/2017
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    public void convertLead() {
        List<Attachment> allAttachmentsList = [
                SELECT Id, Name, Body, OwnerId, ParentId
                FROM Attachment
                WHERE ParentId = :this.lead.Id
                LIMIT 50000];

        List<Attachment> attachmentsToInsertList = new  List<Attachment>();
        for (Attachment attach : allAttachmentsList) {
            Attachment newAttachment =  attach.clone();
            attachmentsToInsertList.add(newAttachment);
        }

        List<Note> allNotesList = [
                SELECT Id, Title, Body, OwnerId, ParentId
                FROM Note
                WHERE ParentId = :this.lead.Id
                LIMIT 50000];

        List<Note> notesToInsertList = new  List<Note>();
        for (Note note : allNotesList) {
            Note newNote = note.clone();
            notesToInsertList.add(newNote);
        }

        updateLeadWithUniqueFields();

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(this.lead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        this.lead = [
                SELECT Salutation, RecordType.Name, Anzahl_der_Fahrzeuge__c, Branche_NACE__c, Beschaeftigte__c, OwnerId, FirstName, LastName, ConvertedOpportunityId,
                        ConvertedContactId, ConvertedAccountId, Send_SEPA_approval_link__c, Email, Zahlungsart__c, LeadSource, Phone, Country, Street, PostalCode
                FROM Lead
                WHERE Id = :this.leadId];
        Account convertedAccount = [
                SELECT BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode, AccountSource, RecordTypeId
                FROM Account
                WHERE Id = :this.lead.ConvertedAccountId];
        convertedAccount.ShippingCountry = convertedAccount.BillingCountry;
        convertedAccount.ShippingStreet = convertedAccount.BillingStreet;
        convertedAccount.ShippingCity = convertedAccount.BillingCity;
        convertedAccount.ShippingState = convertedAccount.BillingState;
        convertedAccount.ShippingPostalCode = convertedAccount.BillingPostalCode;
        convertedAccount.AccountSource = this.lead.LeadSource;
        convertedAccount.Type = 'Customer';
        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            String accRecId = GlobalUtils.returnRecordTypeId('Account', 'Shell Universal Card');
            convertedAccount.RecordTypeId = accRecId;
        }
        update convertedAccount;

        Opportunity convertedOpportunity = [
                SELECT Id, Primary_Contact_Phone__c, RecordTypeId
                FROM Opportunity
                WHERE Id = :this.lead.ConvertedOpportunityId];

        for (Attachment attach : attachmentsToInsertList) {
            attach.ParentId = convertedOpportunity.Id;
        }

        for (Note note : notesToInsertList) {
            note.ParentId = convertedOpportunity.Id;
        }

        if (! attachmentsToInsertList.isEmpty()) insert attachmentsToInsertList;
        if (! notesToInsertList.isEmpty()) insert notesToInsertList;

        convertedOpportunity.Primary_Contact_Phone__c = this.lead.Phone;
        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            String oppRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Shell Universal Card');
            convertedOpportunity.RecordTypeId = oppRecId;
        }
        if (this.lead.Country == 'Germany') {
            convertedOpportunity.Product__c = null;
        }
        update convertedOpportunity;

        if (this.lead.RecordType.Name == 'Shell Universal Card') {
            String conRecId = GlobalUtils.returnRecordTypeId('Contact', 'Shell Universal Card');
            Contact convertedContact = [SELECT RecordTypeId FROM Contact WHERE Id = :this.lead.ConvertedContactId];
            convertedContact.RecordTypeId = conRecId;
            update convertedContact;
        }

        List<Emarsys_Log__c> emarsysLogList = [SELECT Opportunity__c FROM Emarsys_Log__c WHERE Lead__c = :this.lead.Id];
        if (! emarsysLogList.isEmpty()) {
            for (Emarsys_Log__c emarsysLog : emarsysLogList) {
                emarsysLog.Opportunity__c = convertedOpportunity.Id;
            }
            update emarsysLogList;
        }
    }


    /*******************************************************************************
    *  Name            : updateLeadWithUniqueFields()
    *  Summary         : update specific unique values in Lead
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 20/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateLeadWithUniqueFields() {
        Boolean isUpdate = false;
        if (this.lead.Steuernummer__c == 'nicht bekannt' || this.lead.Steuernummer__c == 'unbekannt' || this.lead.Steuernummer__c == '0') {
            this.lead.Steuernummer__c = '';
            isUpdate = true;
        }

        if (isUpdate) {
            update this.lead;
        }
    }


    /*******************************************************************************
    *  Name            : returnEmailTemplate()
    *  Summary         : return email template
    *  CreatedDate     : 26/06/2017
    *  Parameters      : -
    *  Returns         : EmailTemplate
    ******************************************************************************/
    public EmailTemplate returnEmailTemplate() {
        List<EmailTemplate> templateList = new List<EmailTemplate>();
        if (this.lead.Country == 'Germany') {
            templateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'SEPA_Approval_Link_for_contact_DE'
                    LIMIT 1];
        } else if (this.lead.Country == 'Netherlands' || this.lead.Country == 'Belgium-NL') {
            templateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'SEPA_Approval_Link_for_contact_NL'
                    LIMIT 1];
        } else if (this.lead.Country == 'France' || this.lead.Country == 'Belgium-FR') {
            templateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'SEPA_Approval_Link_for_contact_FR'
                    LIMIT 1];
        } else {
            throw new MessageException('Country is not supported for sending SEPA approval link.');
        }
        EmailTemplate emailTemplate;
        if (! templateList.isEmpty()) {
            emailTemplate = templateList.get(0);
        }
        return emailTemplate;
    }


    /*******************************************************************************
    *  Name            : validateSendLink()
    *  Summary         : validate
    *  CreatedDate     :
    *  Parameters      :
    *  Returns         :
    ******************************************************************************/
    public void validateSendLink(EmailTemplate template) {
        if (this.lead.RecordType.Name != 'Endkunde') {
            throw new MessageException('SEPA approval link was not sent to the contact. Record type must be "Endkunde" only.');
        }
        if (this.lead.Email == null) {
            throw new MessageException('SEPA approval link was not sent to the contact. Email address is empty.');
        }
        if (template == null) {
            throw new MessageException('SEPA approval link was not sent to the contact. There are no email templates.');
        }
    }


    /*******************************************************************************
    *  Name            : sendEmail(String oppId, String contactId, EmailTemplate template)
    *  Summary         : sending letter with SEPA Approval link after converted lead
    *  CreatedDate     : 26/06/2017
    *  Parameters      : String oppId, String contactId, EmailTemplate template
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail(String oppId, String contactId, EmailTemplate template) {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(template.Id);
        mail.setTargetObjectId(contactId);
        mail.setWhatId(oppId);
        mail.setSaveAsActivity(false);
        allmsg.add(mail);
        if (! Test.isRunningTest()) {
            Messaging.sendEmail(allmsg,false);
        }
    }

    public class MessageException extends Exception {}

    /*******************************************************************************
    *  Name            : continueConvert()
    *  Summary         : update required fields and continue convert
    *  CreatedDate     : 14/04/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference continueConvert() {
        try {
            update this.lead;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        if(lead.Recordtype.Name == 'Lotos'){
            return new PageReference('/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId=' + this.lead.Id + '&id=' + this.lead.Id + '&nooppti=0');
        } else {
            return init();
        }
    }


    /*******************************************************************************
    *  Name            : backToLeadWithSavingFields()
    *  Summary         : back to lead with saving fields values
    *  CreatedDate     : 17/04/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToLeadWithSavingFields() {
        try {
            update this.lead;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, e.getMessage()));
            return null;
        }
        return new PageReference('/' + this.lead.Id);
    }


    /*******************************************************************************
    *  Name            : backToLeadWithoutSavingFields()
    *  Summary         : cancel convertation and back to lead without saving fields values
    *  CreatedDate     : 17/04/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToLeadWithoutSavingFields() {
        return new PageReference('/' + this.lead.Id);
    }
}