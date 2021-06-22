public class PreselectedProductToE2EsenderCtrl {
    public Lead lead {get; set;}
    public String errorMessage {get; set;}
    public String emailBody {get; set;}
    public List<SelectOption> productsList {get; set;}
    public String selectedProduct {get; set;}
    private Map<String, Map<String, Map<String, String>>> emailTemaplatesForProductsMap;
    private Map<String, EmailTemplate> availableEmailTemplatesMap;
    public Map<String, List<Attachment>> attachmentsMap {get; set;}
    
    /******************************************************************************
    *  Name            : init()
    *  Summary         : initializatin inital data
    *  CreatedDate     : 21/08/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void 
    ******************************************************************************/
    public void init() {
    	try {
            String leadId = ApexPages.currentPage().getParameters().get('id');
            this.lead = [
                SELECT Id, Country, Salutation, LastName, OwnerId, Owner.Name, Owner.Email, Email, Sec_Channel__c, Quali_Status__c, E2E_Manual_Adoption_Date__c, E2E_Assistant__c
                FROM Lead
                WHERE Id = :leadId
                LIMIT 1
            ];
            getEmailTemaplatesSettingsForProductsMap();
            this.errorMessage = validateLeadFields();
            if (! String.isEmpty(this.errorMessage)) {
                throw new LongFormException(this.errorMessage += ' <a href="/' + this.lead.Id + '">back to Lead</a>');
            } 
            setProductsOptionsList();
            setEmailTemplates();
            setEmailBody();
        } catch (Exception e) {
            this.errorMessage = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
    	}
    }


    /******************************************************************************
    *  Name            : validateLeadFields()
    *  Summary         : do validate lead fields 
    *  CreatedDate     : 21/08/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void 
    ******************************************************************************/
    private String validateLeadFields() {
        this.errorMessage = '';
        if (String.valueOf(this.lead.OwnerId).subString(0,3) != '005' || this.lead.Owner.Name == 'Integration Administrator') {
            this.errorMessage += 'The owner of the record must be a user.';
        }
        if (String.isEmpty(this.lead.Country)) {
            this.errorMessage += 'Please fill "Country" field in lead.';
        }
        if (String.isEmpty(this.lead.Email)) {
            this.errorMessage += '<br/>Please fill "Email" field in lead.';
        }
        if (String.isEmpty(this.lead.Sec_Channel__c)) {
            this.errorMessage += '<br/>Please fill "Sec. Channel" field in lead.';
        }
        if (! String.isEmpty(this.lead.Country)) {
            if (! emailTemaplatesForProductsMap.containsKey(this.lead.Country)) {
                this.errorMessage += '<br/>This functionality doesn\'t support this country. Please contact your administrator.';
            }
            if (emailTemaplatesForProductsMap.containsKey(this.lead.Country) && ! emailTemaplatesForProductsMap.get(this.lead.Country).containsKey(this.lead.Sec_Channel__c)) {
                this.errorMessage += '<br/>This functionality doesn\'t support this Sec. Channel. Please contact your administrator.';
            }
        }
        return this.errorMessage;
    }


    /******************************************************************************
    *  Name            : setProductsOptionsList()
    *  Summary         : do generate product names options list 
    *  CreatedDate     : 21/08/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void 
    ******************************************************************************/
    private void setProductsOptionsList() {
        this.productsList = new List<SelectOption>();
        for (String emailTemplateDeveloperName : emailTemaplatesForProductsMap.get(this.lead.Country).get(this.lead.Sec_Channel__c).keySet()) {
            if (this.selectedProduct == null) {
                this.selectedProduct = emailTemplateDeveloperName;
            } 
            this.productsList.add(new SelectOption(emailTemplateDeveloperName, emailTemaplatesForProductsMap.get(this.lead.Country).get(this.lead.Sec_Channel__c).get(emailTemplateDeveloperName)));
        } 
    }


    /******************************************************************************
    *  Name            : setEmailTemplates()
    *  Summary         : do generate available email templates map
    *  CreatedDate     : 22/08/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void 
    ******************************************************************************/
    private void setEmailTemplates() {
        Set<String> emailTemplateNamesSet = new Set<String>();
        for (SelectOption so : this.productsList) {
            emailTemplateNamesSet.add(so.getValue());
        }
        List<EmailTemplate> emailTemplatesList = [
            SELECT Id, Subject, HtmlValue, Body, DeveloperName,
                (SELECT Id, Name FROM Attachments LIMIT 10)
            FROM EmailTemplate 
            WHERE DeveloperName IN :emailTemplateNamesSet
            LIMIT 1000];

        this.availableEmailTemplatesMap = new Map<String, EmailTemplate>();
        for (EmailTemplate emailTemplate : emailTemplatesList) {
            this.availableEmailTemplatesMap.put(emailTemplate.DeveloperName, emailTemplate);
        }
    }


    /******************************************************************************
    *  Name            : setEmailBody()
    *  Summary         : do generate available email templates map
    *  CreatedDate     : 22/08/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void 
    ******************************************************************************/
    public void setEmailBody() {
        try {
            this.errorMessage = null;
            if (this.availableEmailTemplatesMap.containsKey(this.selectedProduct)) {
                this.emailBody = this.availableEmailTemplatesMap.get(this.selectedProduct).HtmlValue;
                String urlToE2E = generateUrlToE2Eform();
                this.emailBody = this.emailBody.replace('LinkToE2E', urlToE2E);
                String userGreeting = generateUserGreetingMessage();
                this.emailBody = this.emailBody.replace('{0}', userGreeting);
                this.emailBody = this.emailBody.replace('{1}', this.lead.Owner.Email);
                this.emailBody = this.emailBody.replace('{2}', this.lead.Owner.Name);
                this.attachmentsMap = new Map<String, List<Attachment>>();
                this.attachmentsMap.put(this.availableEmailTemplatesMap.get(this.selectedProduct).Id, new List<Attachment>());
                if (this.availableEmailTemplatesMap.get(this.selectedProduct).Attachments.size() != 0) {
                    for (Attachment attach : this.availableEmailTemplatesMap.get(this.selectedProduct).Attachments) {
                        attachmentsMap.get(this.availableEmailTemplatesMap.get(this.selectedProduct).Id).add(attach);
                    }
                } else {
                    attachmentsMap.get(this.availableEmailTemplatesMap.get(this.selectedProduct).Id).add(new Attachment(Name = 'no attachments'));
                }
            } else {
                this.emailBody = '';
                this.errorMessage = 'You have no available email template. Please contact your administrator.';
                throw new LongFormException(this.errorMessage += ' <a href="/' + this.lead.Id + '">back to Lead</a>');
            }
        } catch (Exception e) {
            this.errorMessage = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
    	}  
    }


    /******************************************************************************
    *  Name            : generateUserGreetingMessage(String country)
    *  Summary         : generate user greeting message
    *  CreatedDate     : 05/09/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String message
    ******************************************************************************/
    private String generateUserGreetingMessage() {
        String message = '';
        if (greetingMessagesMap.containsKey(this.lead.Country)) {
            if (greetingMessagesMap.get(this.lead.Country).containsKey(this.lead.Salutation)) {
                message += greetingMessagesMap.get(this.lead.Country).get(this.lead.Salutation);
            }
        }
        message += ' ' + this.lead.LastName;
        return message;
    }


    /******************************************************************************
    *  Name            : generateUrlToE2Eform()
    *  Summary         : generate link to lead convert
    *  CreatedDate     : 23/08/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return String finalUrl
    ******************************************************************************/
    private String generateUrlToE2Eform() {
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        String stringToEncode = this.lead.Id + '-' + this.emailTemaplatesForProductsMap.get(this.lead.Country).get(this.lead.Sec_Channel__c).get(this.selectedProduct);
        String encodedString = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        String finalUrl = '';
        Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization];
        if (org.IsSandbox == true) {
            finalUrl += URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SwitchLeadToE2E?eid=' + encodedString;
        } else {
            finalUrl += 'http://e2efleetcor.force.com/SwitchLeadToE2E?eid=' + encodedString;
        }
        return finalUrl;
    }


    /******************************************************************************
    *  Name            : backToLead()
    *  Summary         : return to lead     
    *  CreatedDate     : 23/08/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference backToLead() {
        try {
            return new PageReference('/' + this.lead.Id);       
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }	
    	return null;	
    }


    /******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 23/08/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference sendEmail() {
        try {
            this.errorMessage = null;
            List<String> emailAddressesList = new List<String>();
            emailAddressesList.add(this.lead.Email);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(this.availableEmailTemplatesMap.get(this.selectedProduct).Subject);
            mail.setHtmlBody(this.emailBody);  
            mail.setToAddresses(emailAddressesList);
            mail.setSaveAsActivity(false);
            mail.setCharset('UTF8'); 
            if (this.availableEmailTemplatesMap.get(this.selectedProduct).Attachments.size() != null) {
                List<Id> attachsIds = new List<Id>();
                for (Attachment attach : this.availableEmailTemplatesMap.get(this.selectedProduct).Attachments) {
                    attachsIds.add(attach.Id);
                }
                mail.setEntityAttachments(attachsIds);
            }
            emails.add(mail);
            if (! Test.isRunningTest()) {
                Messaging.sendEmail(emails);       
            }
            updateLead();
            return new PageReference('/' + this.lead.Id);
        } catch (Exception e) {
            this.errorMessage = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
        }	
    	return null;	
    }


    /******************************************************************************
    *  Name            : updateLead()
    *  Summary         : update lead after sending email   
    *  CreatedDate     : 26/08/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateLead() {
        this.lead.E2E_Manual_Adoption_Date__c = Datetime.now();
        this.lead.Quali_Status__c = 'Switched to E2E';
        this.lead.E2E_Assistant__c = this.lead.Owner.Name;
        update this.lead;
    }

    
    /******************************************************************************
    *  Name            : getEmailTemaplatesSettingsForProductsMap()
    *  Summary         : get all email templates settings for products
    *  CreatedDate     : 23/08/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void getEmailTemaplatesSettingsForProductsMap() {
        List<E2E_Preselected_Products_Settings__c> preselectedProductsSettingsList = E2E_Preselected_Products_Settings__c.getAll().values();
        this.emailTemaplatesForProductsMap = new Map<String, Map<String, Map<String, String>>>();
        for (E2E_Preselected_Products_Settings__c settings: preselectedProductsSettingsList) {
            if (! this.emailTemaplatesForProductsMap.containsKey(settings.Country__c) ) {
                this.emailTemaplatesForProductsMap.put(settings.Country__c, new Map<String, Map<String, String>>());
            }
            if (! this.emailTemaplatesForProductsMap.get(settings.Country__c).containsKey(settings.Sec_Channel__c) ) {
                this.emailTemaplatesForProductsMap.get(settings.Country__c).put(settings.Sec_Channel__c, new Map<String, String>());
            }
            this.emailTemaplatesForProductsMap.get(settings.Country__c).get(settings.Sec_Channel__c).put(settings.Email_Template_DeveloperName__c, settings.Product_Name__c);
        } 
    } 


    private static Map<String, Map<String, String>> greetingMessagesMap = new Map<String, Map<String, String>>{
        'Germany' => new Map<String, String>{
            'Herr' => 'geehrter Herr',
            'Herr Dr.' => 'geehrter Herr Dr.',
            'Herr Prof.' => 'geehrter Herr Prof.',
            'Frau' => 'geehrte Frau',
            'Frau Dr.' => 'geehrte Frau Dr.',
            'Frau Prof.' => 'geehrte Frau Prof.'
        },
        'Austria' => new Map<String, String>{
            'Herr' => 'geehrter Herr',
            'Herr Dr.' => 'geehrter Herr Dr.',
            'Herr Prof.' => 'geehrter Herr Prof.',
            'Frau' => 'geehrte Frau',
            'Frau Dr.' => 'geehrte Frau Dr.',
            'Frau Prof.' => 'geehrte Frau Prof.'
        }
    };
}