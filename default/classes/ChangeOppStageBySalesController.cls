public with sharing class ChangeOppStageBySalesController {
    public Opportunity opportunity {get; set;}
    public String pendingCredit;

    public ChangeOppStageBySalesController() {}

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : data init    
    *  CreatedDate     : 28/02/2017
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference init() {
    	try {
    		String oppId = ApexPages.currentPage().getParameters().get('id');
            this.opportunity = [
                SELECT Name, OwnerId, StageName, Registered_Country__c, bearbeitet_von__c
                FROM Opportunity
                WHERE Id = :oppId
                LIMIT 1];
            
            pendingCredit = ApexPages.currentPage().getParameters().get('pendingCredit');
            validate(); 
            changeOppStageName();
            // sendEmail();

            Approval.lock(this.opportunity.Id);
    		return new PageReference('/' + this.opportunity.Id);
    	} catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    }


    /*******************************************************************************
    *  Name            : changeOppStageName()
    *  Summary         : change Opportunity Stage Name    
    *  CreatedDate     : 25/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeOppStageName() {
        if (pendingCredit == 'pencredit') {
            this.opportunity.StageName = 'Pending Credit';
            update this.opportunity;
            Approval.lock(this.opportunity.Id);     
        } else if (pendingCredit == 'pencreditTokpayment') {
            this.opportunity.StageName = 'Pending Credit - Token payment';
            update this.opportunity;
        }
    }   


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 20/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendEmail() {
    //     if (pendingCredit == 'pencreditTokpayment') {
    //         List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending( 
    //             this.opportunity, 
    //             'Waiting_for_token_payment_credit_letters');

    //         if (! Test.isRunningTest()) {
    //             Messaging.sendEmail(emails);
    //         }
    //     }
    // }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 20/06/2017
    *  Parameters      : Opportunity opportunity, String emailTemplateName
    *  Returns         : all emails
    ******************************************************************************/
    // public List<Messaging.SingleEmailMessage> preporationEmailsForSending(Opportunity opportunity, String emailTemplateName) {
    //     // getting email template id
    //     EmailTemplate emailTemplate = [
    //         SELECT Id, Subject, HtmlValue, Body
    //         FROM EmailTemplate 
    //         WHERE DeveloperName = :emailTemplateName
    //         LIMIT 1];

    //     List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
    //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //         mail.setTemplateID(emailTemplate.Id); 
    //         mail.setTargetObjectId(opportunity.OwnerId);
    //         mail.setSaveAsActivity(false);
    //         mail.setWhatId(opportunity.Id);
    //         allmsg.add(mail);

    //         return allmsg;
    // }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : check current user and Opporunity StageName    
    *  CreatedDate     : 25/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (pendingCredit == 'pencredit' &&
            this.opportunity.StageName != 'Pending Sales – Deposit' &&
        	this.opportunity.StageName != 'Pending Sales – Information') {
            throw new StageException('This action is available for Pending Sales Opportunity Stage only. <a href="/' + this.opportunity.Id + '">back to Opportunity</a>');
        }
        if (pendingCredit == 'pencreditTokpayment' &&
            this.opportunity.StageName != 'Pending Sales - Token payment') {
            throw new StageException('This action is available for Pending Sales - Token payment Opportunity Stage only. <a href="/' + this.opportunity.Id + '">back to Opportunity</a>');
        }

    }

    public class StageException extends Exception {}
}