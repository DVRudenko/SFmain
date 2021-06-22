public with sharing class RequestInformationAllStarFormCtrl {
    public Account acc {get; set;}
    public User sender {get; set;}
	public EmailTemplate template {get; set;}
    public String emailAddress {get; set;}
	public String emailText {get; set;}
	public List<String> emailAddressesList;

    public RequestInformationAllStarFormCtrl() {    
    }

    public void init() {
    	try {
            String accountId = ApexPages.currentPage().getParameters().get('id');
            this.acc = [
                SELECT Id, OwnerId, Allstar_Email__c
                FROM Account
                WHERE Id = :accountId
                LIMIT 1];

            if (this.acc != null) {
                this.sender = [
                    SELECT Id, Name, Email
                    FROM User
                    WHERE Id = :this.acc.OwnerId
                    LIMIT 1];
            }
    		String templateName = 'Email_with_URL_to_confirm';
            this.template = doSelectRequestInformationTemplate(templateName);
            prefillingEmail();
            this.emailText = this.emailText.replace('LinkHere', this.acc.Id);
            validateData();
            List<String> fillers = new List<String>{this.sender.Name, this.sender.Email};
            this.emailText = String.format(this.emailText, fillers);
    	} catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }


    /*******************************************************************************
    *  Name            : doSelectRequestInformationTemplate
    *  Summary         : select email text (text templates for request information)     
    *  CreatedDate     : 20/04/2017
    *  Parameters      : String templateName
    *  Returns         : Email template
    ******************************************************************************/
    public static EmailTemplate doSelectRequestInformationTemplate (String templateName) {
        // getting email template
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate 
            WHERE DeveloperName = :templateName
            LIMIT 1];
        if ( emailTemplate != null ) {
            return emailTemplate;
        }
        return null;     
    }


    /*******************************************************************************
    *  Name            : prefillingEmail()
    *  Summary         : Pre-filling the field with the text of the letter template    
    *  CreatedDate     : 20/04/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void prefillingEmail() {
        this.emailAddressesList = new List<String>();
        if (! String.isBlank(this.acc.Allstar_Email__c)) {
            this.emailAddress = this.acc.Allstar_Email__c;
            this.emailAddressesList.add(this.emailAddress);
        } else {
            this.emailAddress = '';
        }   

    	if (this.template != null) {	
    		this.emailText = this.template.HtmlValue;
    	} else {
    		this.emailText = '';
    	}
    }


    /*******************************************************************************
    *  Name            : validateData()
    *  Summary         : validating fields and data    
    *  CreatedDate     : 08/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateData() {
        if (this.emailAddressesList.isEmpty()) {
            throw new MessageException('Please fill "AllStrar Email" field in account.');
        }
        if (String.isBlank(this.emailText)) {
            throw new MessageException('"Body" is required field.');
        }
        if (this.emailText.contains('LinkHere')) {
            throw new MessageException('The link hasn\'t been generated correctly. Please try again or contact your administrator.');
        } 
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 21/04/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference sendEmail() {
        try {
            validateData();
            List<Messaging.SingleEmailMessage> emails = preparationEmailsForSending( 
                this.emailText,
                this.emailAddressesList
            );
            if (! Test.isRunningTest()) {
                Messaging.sendEmail(emails);
                return new PageReference('/' + this.acc.Id);       
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }	
    	return null;	
    }


    /*******************************************************************************
    *  Name            : preparationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 21/04/2017
    *  Parameters      : String emailText, List<String> emailAddressesList
    *  Returns         : all messages
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preparationEmailsForSending(String emailText, List<String> emailAddressesList) {

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Uzupełnienie informacji- formularz Allstar Mondo');
            mail.setHtmlBody(this.emailText);  
            mail.setToAddresses(this.emailAddressesList);
            mail.setSaveAsActivity(false);
            mail.setCharset('UTF8');
            allmsg.add(mail);

            return allmsg;
    }

    public class MessageException extends Exception {}
}