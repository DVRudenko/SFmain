public with sharing class SepaDataApprovalRequestCtrl {
    public Opportunity currentOpportunity;
    public Contact recipientContact;
    public EmailTemplate emailTemplate;

    public SepaDataApprovalRequestCtrl() {    
    }

    public void init() {
        try {
            String oppId = ApexPages.currentPage().getParameters().get('id');

            if (oppId != null) {
                this.currentOpportunity = [
                    SELECT StageName, SEPA_Request_Approved__c, Send_SEPA_approval_link__c, RecordType.Name, Total_consumption_l_month__c,
                           Zahlungsart__c, Account.BillingCountry, Risk_Category__c, Direct_Debit_Mandate_Type__c, Language_preference__c,
                           IBAN__c, SWIFT_BIC__c, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingCountryCode,
                           Account.Umsatzsteuer_ID__c, Account.Gesellschaftsform__c, Account.UMR__c,
                          (SELECT IsPrimary, ContactId FROM OpportunityContactRoles WHERE ContactId != null)
                    FROM Opportunity
                    WHERE Id = :oppId
                    LIMIT 1];
            } else {
                throw new SendingException('Invalid record id. Please try again.');
            }

            if (this.currentOpportunity.Zahlungsart__c == null) throw new SendingException('Please set \'Direct Debit\' payment method. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>'); 
            if (this.currentOpportunity.Zahlungsart__c != 'Lastschrift') throw new SendingException('Sepa Data Approval Request is available only for \'Direct Debit\' payment method. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>'); 
            if (this.currentOpportunity.Total_consumption_l_month__c == null) throw new SendingException('Please set total consumption. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');         
            if (this.currentOpportunity.Direct_Debit_Mandate_Type__c == null) throw new SendingException('Please set mandate type. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');

            String appropriateMandateType = CreditFactoryGlobalUtils.returnAppropriateMandateType(this.currentOpportunity.Account.BillingCountry,
                                                                                              'Very', // the worst case
                                                                                          this.currentOpportunity.Total_consumption_l_month__c);
            if (this.currentOpportunity.Risk_Category__c == null && this.currentOpportunity.Direct_Debit_Mandate_Type__c == 'Core' && appropriateMandateType == 'B2B') {
                throw new SendingException('Please run Credit Factory first to learn the risk level of the Customer.<a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
            }

            String contactId;
            List<OpportunityContactRole> contactRolesList = this.currentOpportunity.OpportunityContactRoles;
            if (! contactRolesList.isEmpty()) {
                for (OpportunityContactRole ocr : contactRolesList) {
                    if (ocr.IsPrimary) {
                        contactId = ocr.ContactId;
                    }
                }
            }

            List<Contact> contactList = [
                SELECT Id, Email, LastName, FirstName, MobilePhone
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1];

            if (! contactList.isEmpty()) {
                this.recipientContact = contactList.get(0);
            }

            this.emailTemplate = chooseTemplate();

            validateRequest();

            String mandateId;
            if ((this.currentOpportunity.Account.BillingCountry == 'Belgium-NL' || this.currentOpportunity.Account.BillingCountry == 'Belgium-FR') &&
                    this.currentOpportunity.Direct_Debit_Mandate_Type__c == 'B2B') {
                TwikeyEntity twikeyEntity = sendTwikeyLink();
                mandateId = twikeyEntity.mndtId;
            }

            if (this.currentOpportunity.Send_SEPA_approval_link__c == false || this.currentOpportunity.SEPA_Request_Approved__c == true) {
                this.currentOpportunity.Send_SEPA_approval_link__c = true;
                this.currentOpportunity.SEPA_Request_Approved__c = false;
                update this.currentOpportunity;
            }

            if (this.currentOpportunity.Account.BillingCountry != 'Belgium-NL' && this.currentOpportunity.Account.BillingCountry != 'Belgium-FR' ||
                    (this.currentOpportunity.Account.BillingCountry == 'Belgium-NL' || this.currentOpportunity.Account.BillingCountry == 'Belgium-FR') &&
                    this.currentOpportunity.Direct_Debit_Mandate_Type__c == 'Core') {
                sendEmail();
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Approval link has been sent. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }


    /*******************************************************************************
    *  Summary         : send Twikey link to the customer
    *  CreatedDate     : 05/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : twikey entity
    ******************************************************************************/
    public TwikeyEntity sendTwikeyLink() {
        SepaWebTwikey sepaWebTwikey = new SepaWebTwikey();
        Twikey__c twikeySettings;
        Twikey__c twikeySettingsTest = Twikey__c.getInstance('Test');
        Twikey__c twikeySettingsProd = Twikey__c.getInstance('Production');
        if (twikeySettingsProd != null && twikeySettingsProd.Active__c == true) {
            twikeySettings = twikeySettingsProd;
        }
        else if (twikeySettingsTest != null && twikeySettingsTest.Active__c == true) {
            twikeySettings = twikeySettingsTest;
        }

        Map<String, Object> inviteParametersMap = new Map<String, Object>();
        String templateId;
        if (this.currentOpportunity.Direct_Debit_Mandate_Type__c == 'B2B') {
            templateId = twikeySettings.B2B_Template_Id__c;
        }
        else {
            templateId = twikeySettings.Core_Template_Id__c;
        }

        inviteParametersMap.put('ct', templateId);
        String language;
        if (this.currentOpportunity.Language_preference__c == 'Dutch') {
            language = 'nl';
        }
        else if (this.currentOpportunity.Language_preference__c == 'French') {
            language = 'fr';
        }
        else {
            language = 'en';
        }

        inviteParametersMap.put('l', language);
        inviteParametersMap.put('iban', this.currentOpportunity.IBAN__c);
        inviteParametersMap.put('bic', this.currentOpportunity.SWIFT_BIC__c);
        inviteParametersMap.put('mandateNumber', this.currentOpportunity.Account.UMR__c);
        inviteParametersMap.put('email', this.recipientContact.Email);
        inviteParametersMap.put('lastname', this.recipientContact.LastName);
        inviteParametersMap.put('firstname', this.recipientContact.FirstName);
        inviteParametersMap.put('mobile', this.recipientContact.MobilePhone);
        inviteParametersMap.put('address', this.currentOpportunity.Account.BillingStreet);
        inviteParametersMap.put('city', this.currentOpportunity.Account.BillingCity);
        inviteParametersMap.put('zip', this.currentOpportunity.Account.BillingPostalCode);
        inviteParametersMap.put('country', this.currentOpportunity.Account.BillingCountryCode);
        inviteParametersMap.put('vatno', this.currentOpportunity.Account.Umsatzsteuer_ID__c);
        inviteParametersMap.put('form', this.currentOpportunity.Account.Gesellschaftsform__c);
        inviteParametersMap.put('sendInvite', true);

        TwikeyEntity twikeyEntity = sepaWebTwikey.inviteCustomer(twikeySettings, inviteParametersMap);
        return twikeyEntity;
    }


    /*******************************************************************************
    *  Name            : chooseTemplate()
    *  Summary         : choose template based on country
    *  CreatedDate     : 10/09/2017
    *  ModifiedDate    : 10/09/2017
    *  Parameters      : -
    *  Returns         : EmailTemplate
    ******************************************************************************/
    public EmailTemplate chooseTemplate() {
        List<EmailTemplate> templateList = new List<EmailTemplate>();
        if (this.currentOpportunity.Account != null) {
            if (this.currentOpportunity.Account.BillingCountry == 'Germany') {
                templateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'SEPA_Approval_Link_for_contact_DE'
                    LIMIT 1];
            } else if (this.currentOpportunity.Account.BillingCountry == 'Netherlands' || this.currentOpportunity.Account.BillingCountry == 'Belgium-NL') {
                templateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'SEPA_Approval_Link_for_contact_NL'
                    LIMIT 1];
            } else if (this.currentOpportunity.Account.BillingCountry == 'France' || this.currentOpportunity.Account.BillingCountry == 'Belgium-FR') {
                templateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'SEPA_Approval_Link_for_contact_FR'
                    LIMIT 1];
            }

            if (! templateList.isEmpty()) {
                return templateList.get(0);
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : validateRequest()
    *  Summary         : validate data before sending email
    *  CreatedDate     : 07/08/2017
    *  ModifiedDate    : 28/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateRequest () {
        if (this.recipientContact == null) {
            throw new SendingException('There is either no primary contact or you don\'t have access to it. Please contact your administrator.<a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }
        if (this.recipientContact.Email == null) {
            throw new SendingException('SEPA approval link was not sent to the contact. Email address is empty.<a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }
        if (this.emailTemplate == null && this.currentOpportunity.Account.BillingCountry != 'Belgium-FR' && this.currentOpportunity.Account.BillingCountry != 'Belgium-NL') {
            throw new SendingException('SEPA approval link was not sent to the contact. There are no email templates.<a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }

        String appropriateMandateType = CreditFactoryGlobalUtils.returnAppropriateMandateType(this.currentOpportunity.Account.BillingCountry,
                                                                                          this.currentOpportunity.Risk_Category__c,
                                                                                      this.currentOpportunity.Total_consumption_l_month__c);
        if (this.currentOpportunity.Direct_Debit_Mandate_Type__c == 'Core' && appropriateMandateType == 'B2B') {
            throw new SendingException('Please change the Direct Debit Type Mandate from Core to B2B because the Customer has high Credit risk.<a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letter with SEPA Approval link
    *  CreatedDate     : 07/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(this.emailTemplate.Id);
        mail.setTargetObjectId(this.recipientContact.Id);
        mail.setWhatId(this.currentOpportunity.Id);
        mail.setSaveAsActivity(false);
        allmsg.add(mail);
        if (! Test.isRunningTest()) {
            Messaging.sendEmail(allmsg);
        }
    }

    public class SendingException extends Exception {}
}