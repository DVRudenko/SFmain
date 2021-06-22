public class TransactionsCredentialsRequestCtrl {
	public Opportunity opportunity;
    public EmailTemplate emailTemplate;


	/*******************************************************************************
	*  Name            : init()
	*  Summary         : Initialize data    
	*  CreatedDate     : 16/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public void init() {
        try {
            String opportunityId = ApexPages.currentPage().getParameters().get('id');

            if (opportunityId != null) {
                this.opportunity = [
                    SELECT Account.BillingCountry,
                          (SELECT ContactId, Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = true)
                    FROM Opportunity
                    WHERE Id = :opportunityId
                    LIMIT 1];
            } else {
                throw new TransactionsException('Invalid record id. Please try again.');
            }

            this.emailTemplate = chooseTemplate();
            validateRequest();
            sendEmail();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Transactions credentials link has been sent.<a href="/' + this.opportunity.Id + '">back to Opportunity</a>'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }


    /*******************************************************************************
    *  Name            : chooseTemplate()
    *  Summary         : choose template based on country     
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : EmailTemplate
    ******************************************************************************/
    public EmailTemplate chooseTemplate() {
        List<EmailTemplate> templateList = new List<EmailTemplate>();
        if (this.opportunity.Account != null) {
            if (this.opportunity.Account.BillingCountry == 'Poland') {
                templateList = [
                    SELECT Id
                    FROM EmailTemplate 
                    WHERE DeveloperName = 'Transactions_Credentials_PL'
                    LIMIT 1];
            } else {
                throw new TransactionsException('Country is not supported for sending Transactions credentials link. <a href="/' + this.opportunity.Id + '">back to Opportunity</a>');
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
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateRequest () {
        if (this.opportunity.OpportunityContactRoles.isEmpty()) {
            throw new TransactionsException('There is either no primary contact or you don\'t have access to it. Please contact your administrator.<a href="/' + this.opportunity.Id + '">back to Opportunity</a>');
        }
        if (this.opportunity.OpportunityContactRoles.get(0).Contact.Email == null) {
            throw new TransactionsException('Transactions credentials link was not sent to the contact. Email address is empty.<a href="/' + this.opportunity.Id + '">back to Opportunity</a>');
        }
        if (this.emailTemplate == null) {
            throw new TransactionsException('Transactions credentials link was not sent to the contact. There are no email templates.<a href="/' + this.opportunity.Id + '">back to Opportunity</a>');
        }  
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letter with SEPA Approval link
    *  CreatedDate     : 16/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
        List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(this.emailTemplate.Id); 
        mail.setTargetObjectId(this.opportunity.OpportunityContactRoles.get(0).ContactId);
        mail.setWhatId(this.opportunity.Id);
        mail.setSaveAsActivity(false);
        messagesList.add(mail);   
        Messaging.sendEmail(messagesList,false);
    }
}