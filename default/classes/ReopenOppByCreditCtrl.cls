public with sharing class ReopenOppByCreditCtrl {
	public String oppId;
	public User currentUser;
    public Integer daysAfterCreditCheck;
	public Opportunity currentOpportunity {get; set;}
	public List<Opportunity> currentOppList;

    public ReopenOppByCreditCtrl() {}

    public void init() {
    	try {
    	    if (this.oppId == null) {
                this.oppId = ApexPages.currentPage().getParameters().get('id');
            }
            String userId = UserInfo.getUserId();

            this.currentUser = [
	                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
	                FROM User
	                WHERE Id = :userId];

	        this.currentOppList = [
	                SELECT Id, Name, StageName, bearbeitet_von__c, Closed_Won_by_CF__c, Pending_Deposit_by_CF__c, CF_Stage__c, Notes__c, Credit_System_Rating__c, CF_Credit_Limit__c,
	                	Name_of_the_payer_Account_holder__c, IBAN__c, SWIFT_BIC__c, Owner.Name, Gruende_verloren__c, Reopen__c, Account.GFN_Nr__c, Credit_check_date__c, Account.BillingCountry,
                        CreatedDate, Security_level_H_he_der_Sicherheit__c,
                                (SELECT Id
                                FROM Credit_Factory_Reports__r),
                                (SELECT Name
                                FROM Attachments)
	                FROM Opportunity 
	                WHERE Id = :this.oppId
	                LIMIT 1];

	        this.currentOpportunity = currentOppList.get(0);
            calcDiffBetweenDates();
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }


    /*******************************************************************************
    *  Name            : calcDiffBetweenDates()
    *  Summary         : Calculate difference between 'Credit check date' and 'Today date'    
    *  CreatedDate     : 22/05/2018
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calcDiffBetweenDates() {
        if (this.currentOpportunity.Credit_check_date__c != null) {
            this.daysAfterCreditCheck = (Date.valueOf(this.currentOpportunity.Credit_check_date__c)).daysBetween(Date.today());
        } else {
            this.daysAfterCreditCheck = (Date.valueOf(this.currentOpportunity.CreatedDate)).daysBetween(Date.today());
        }
    }


    /*******************************************************************************
    *  Name            : approveReopen()
    *  Summary         : Approve reopen    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference approveReopen() {
    	try {
    		validate();
    	    Approval.unlock(this.currentOpportunity.Id);
	    	sendEmail('Approve_reopen');

            this.currentOpportunity.Reopen_Log__c = 'Reopened by Sales\nDate of Reopen: ' + Datetime.now() + '\n' + 'Originally requested deposit: ' + 
                (this.currentOpportunity.Security_level_H_he_der_Sicherheit__c != null ? String.valueOf(this.currentOpportunity.Security_level_H_he_der_Sicherheit__c) : '') + 
                '\n' + 'Processed by: ' + (this.currentOpportunity.bearbeitet_von__c != null ? this.currentOpportunity.bearbeitet_von__c : '') + '\n' +
                'Credit Rating: ' + (this.currentOpportunity.Credit_System_Rating__c != null ? this.currentOpportunity.Credit_System_Rating__c : '');
    		this.currentOpportunity.StageName = 'Prospecting';
    		this.currentOpportunity.Gruende_verloren__c = '';
	    	this.currentOpportunity.bearbeitet_von__c = '';
	        this.currentOpportunity.Closed_Won_by_CF__c = false;
	        this.currentOpportunity.Pending_Deposit_by_CF__c = false;
	        this.currentOpportunity.CF_Stage__c = 'Not launched';
	        this.currentOpportunity.Reopen__c = false;
            this.currentOpportunity.CF_Credit_Limit__c = null;
            this.currentOpportunity.Zahlungsziel_Credit__c = '';
            this.currentOpportunity.Rechnungsperiode__c = '';
            this.currentOpportunity.Credit_check_date__c = null;
            this.currentOpportunity.Kredit_Entscheidung__c = '';
            this.currentOpportunity.Security_To_Pay__c = '';
            this.currentOpportunity.Security_Amount_To_Pay__c = null;
            this.currentOpportunity.Billing_Period_by_Sales__c = false;
            this.currentOpportunity.Max_Credit_Limit__c = null;
            this.currentOpportunity.Security_level_H_he_der_Sicherheit__c = null;
            this.currentOpportunity.Reopened__c = true;

            if (this.currentOpportunity.Account.BillingCountry == 'Netherlands' || this.currentOpportunity.Account.BillingCountry == 'Belgium-NL' || 
                    this.currentOpportunity.Account.BillingCountry == 'Belgium-FR' || this.currentOpportunity.Account.BillingCountry == 'France') {
                this.currentOpportunity.Credit_System_Rating__c = null;
            }

            update this.currentOpportunity;

            if ((this.currentOpportunity.Account.BillingCountry == 'Netherlands' || this.currentOpportunity.Account.BillingCountry == 'Belgium-NL' || 
                    this.currentOpportunity.Account.BillingCountry == 'Belgium-FR' || this.currentOpportunity.Account.BillingCountry == 'France') && 
                    ! this.currentOpportunity.Credit_Factory_Reports__r.isEmpty()) {
                delete this.currentOpportunity.Credit_Factory_Reports__r;
                List<Attachment> attachmentsToDeleteList = new List<Attachment>();
                for (Attachment attachment : this.currentOpportunity.Attachments) {
                    if (attachment.Name == 'CreditsafeReport.pdf') {
                        attachmentsToDeleteList.add(attachment);
                    }
                }

                if (! attachmentsToDeleteList.isEmpty()) delete attachmentsToDeleteList;
            }

	        PageReference page = new PageReference('/' + currentOpportunity.Id);
	        return page;
    	} catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    }


    /*******************************************************************************
    *  Name            : rejectReopen()
    *  Summary         : Reject reopen    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : page
    ******************************************************************************/
    public PageReference rejectReopen() {
    	try {
    		validate();
    	    Approval.unlock(this.currentOpportunity.Id);
	    	sendEmail('Reject_reopen');

	    	PageReference page = new PageReference('/' + currentOpportunity.Id);
	        return page;
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    	    return null;
    	}
    }


    /*******************************************************************************
    *  Name            : sendEmail(String)
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : String
    *  Returns         : void emailTemplateName
    ******************************************************************************/
    public void sendEmail(String emailTemplateName) {
        List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending(this.currentOpportunity, emailTemplateName);

        if (! Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : Opportunity currentOpportunity, String emailTemplateName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName) {
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate 
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1];

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(emailTemplate.Id); 
        mail.setTargetObjectId(currentOpportunity.OwnerId);
        mail.setSaveAsActivity(false);
        mail.setWhatId(currentOpportunity.Id);
        allmsg.add(mail);

        return allmsg;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : check current Opporunity StageName    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (this.daysAfterCreditCheck >= 31) {
            throw new StageException('Opportunity can only be reopened in 31 days from the Credit Check Date. Please create a new Opportunity or clone the current one.');
        }
        if (this.currentOpportunity.StageName != 'Closed Lost' && this.currentOpportunity.StageName != 'CreditCheck abgelehnt' && 
                this.currentOpportunity.StageName != 'Closed Won' && this.currentOpportunity.StageName != 'Pending Sales - SEPA Confirmation') {
            throw new StageException('You can only reopen Opportunities with Opportunity Stage = "Closed Lost", "Closed Won", "Pending Sales - SEPA Confirmation" or "CreditCheck rejected".');
        }
        if (this.currentOpportunity.Account.GFN_Nr__c != null) {
            throw new StageException('You cannot reopen Opportunities if GFN Number is not empty. Back to Opportunity.');
        }
        if ( ! Approval.isLocked(this.currentOpportunity.Id) && this.currentOpportunity.Reopen__c == false) {
            throw new StageException('There was no request for reopen.');
        }

        if (this.currentUser.Profile.Name != 'Credit' && this.currentUser.Profile.Name != 'System Administrator' &&
            this.currentUser.Profile.Name != 'Systemadministrator' && this.currentUser.Profile.Name != 'API Only') {
            throw new StageException('Invalid User Profile.');
        }
    }


    /*******************************************************************************
    *  Name            : backToOpportunity()
    *  Summary         : back to opportunity  
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference backToOpportunity() {
        PageReference page = new PageReference('/' + currentOpportunity.Id);
        return page;
    }

    public class StageException extends Exception {}
}