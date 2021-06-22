public class SubmitForReopenCtrl {
	public Opportunity currentOpportunity;
	public User currentUser;
    public Integer daysAfterCreditCheck;

    public SubmitForReopenCtrl() {}

    public void init() {
    	try {
    		String userId = UserInfo.getUserId();
    	    String oppId = ApexPages.currentPage().getParameters().get('Id');

    	    this.currentUser = [
	                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
	                FROM User
	                WHERE Id = :userId];

    	    this.currentOpportunity = [
	                SELECT Id, StageName, OwnerId, Name, Reopen__c, Account.GFN_Nr__c, Credit_check_date__c, CreatedDate, Gruende_verloren__c,
                        Security_level_H_he_der_Sicherheit__c, bearbeitet_von__c, Credit_System_Rating__c, Account.BillingCountry,
                                (SELECT Id
                                FROM Credit_Factory_Reports__r),
                                (SELECT Name
                                FROM Attachments)
	                FROM Opportunity
	                WHERE Id = :oppId
	                LIMIT 1];

            calcDiffBetweenDates();
            validate();

            if (this.currentOpportunity.StageName == 'Closed Won' || this.currentOpportunity.StageName == 'Closed Lost' && this.currentOpportunity.Gruende_verloren__c != 'Refused Credit' || 
                    this.currentOpportunity.StageName == 'Pending Sales - SEPA Confirmation') {
                reopenAutomatically();
            } else if (this.currentOpportunity.StageName == 'Closed Lost' && this.currentOpportunity.Gruende_verloren__c == 'Refused Credit' || 
                    this.currentOpportunity.StageName == 'CreditCheck abgelehnt') {
                submitForManualReopen();
            }
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
    *  Name            : validate()
    *  Summary         : check current Opporunity StageName    
    *  CreatedDate     : 14/05/2018
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (this.daysAfterCreditCheck >= 31) {
            throw new StageException('Opportunity can only be reopened in 31 days from the Credit Check Date. Please create a new Opportunity or clone the current one. ' +
                '<a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');
        }
    	if (this.currentOpportunity.StageName != 'Closed Lost' && this.currentOpportunity.StageName != 'CreditCheck abgelehnt' && 
                this.currentOpportunity.StageName != 'Closed Won' && this.currentOpportunity.StageName != 'Pending Sales - SEPA Confirmation') {
            throw new StageException('You can only reopen Opportunities with Opportunity Stage = "Closed Lost", "Closed Won", "Pending Sales - SEPA Confirmation" or "CreditCheck rejected". ' + 
                '<a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');
        }
        if (this.currentOpportunity.Account.GFN_Nr__c != null) {
            throw new StageException('You cannot reopen Opportunities if GFN Number is not empty. Back to Opportunity. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');
        }
        if (Approval.isLocked(this.currentOpportunity.Id) && this.currentOpportunity.Reopen__c == true) {
            throw new StageException('This Opportunity is already submitted for reopen. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');
        }

        String profileName = [SELECT Profile.Name FROM User WHERE Id = :this.currentUser.Id].Profile.Name;
        if (Submit_for_reopen_profiles__c.getInstance(profileName) == null) {
            throw new StageException('User Profile is not valid. <a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>');
        }
    }


    /*******************************************************************************
    *  Name            : reopenAutomatically()
    *  Summary         : Reopen Opportunity without sending for reopen    
    *  CreatedDate     : 08/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void reopenAutomatically() {
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

            if (! attachmentsToDeleteList.isEmpty()) {
                AttachmentTriggerHandler.isCreditFactory = true;
                delete attachmentsToDeleteList;
            }
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your opportunity was successfully reopened. ' +
            '<a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>'));
    }


    /*******************************************************************************
    *  Name            : submitForManualReopen()
    *  Summary         : Send request for reopen to Credits    
    *  CreatedDate     : 08/07/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void submitForManualReopen() {
        this.currentOpportunity.Reopen__c = true;
        update this.currentOpportunity;
        sendEmail();

        Approval.lock(this.currentOpportunity.Id);

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your opportunity was successfully submitted for reopen. ' +
            '<a href="/' + this.currentOpportunity.Id + '">Back to Opportunity</a>'));
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
        List<Messaging.SingleEmailMessage> emails = preparationEmailsForSending(this.currentOpportunity, 'Petr Cermak');
        if (emails != null && ! Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }


    /*******************************************************************************
    *  Name            : preparationEmailsForSending(Opportunity currentOpportunity, String customEmailName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : 08/07/2019
    *  Parameters      : Opportunity opportunity, String customEmailName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preparationEmailsForSending(Opportunity opportunity, String customEmailName) {
	    Notifications_for_reopening_Opportunity__c emailCustomSetting = Notifications_for_reopening_Opportunity__c.getInstance(customEmailName);
        if (emailCustomSetting.Active__c == false) {
            return null;
        }
	    String headerData = ApexPages.currentPage().getHeaders().get('Host');

    	List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mailToCredit = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailCustomSetting.Email__c};
        mailToCredit.setToAddresses(toAddresses);
        mailToCredit.setSubject('Reopen request for ' + opportunity.Name);
        mailToCredit.setHtmlBody('<messaging:emailTemplate> ' +
                '<html> <style type="text/css"> body {size: 12pt;} td { border-width: 1px;  padding: 4px;' +
                'border-style: solid; border-color: #000000; background-color: #FFEECC;}th { color: #000000; border-width: 1px ; padding: 4px ;' +
                'border-style: solid ;  border-color: #000000; background-color: #FFFFF0;}</style>' +
                '<body>' +
                'Dear Credit Team, <br/>' +
                '<br/>' +
                'Please reopen the following Opportunity: https://' + headerData + '/' + opportunity.Id + '<br/>' +
                '<br/>' +
                'Best regards, <br/>' +
                this.currentUser.Name +
                '</body> ' +
                '</html> </messaging:emailTemplate>');
        allmsg.add(mailToCredit);

        return allmsg;
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