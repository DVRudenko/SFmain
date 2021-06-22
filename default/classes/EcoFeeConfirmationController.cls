public with sharing class EcoFeeConfirmationController {
	public Boolean thanksPage {get; set;}
    public Boolean rejectPage {get; set;}
	public Opportunity currentOpportunity {get; set;}
	public BackOffice_Notifications__c backOffice;
	public EmailTemplate template;

    public EcoFeeConfirmationController() {    
    }

    public void init() {
    	this.thanksPage = false;
    	String oppId = ApexPages.currentPage().getParameters().get('id');
    	List<Opportunity> currentOpportunityList = [
    		SELECT Id, OwnerId, Account.Name, Account.BillingCountry
    		FROM Opportunity
    		WHERE Id = :oppId
    		LIMIT 1];

		if (! currentOpportunityList.isEmpty() ) {
			this.currentOpportunity = currentOpportunityList.get(0);
		}
    }


    /*******************************************************************************
    *  Name            : confirmEcoFee()
    *  Summary         : show thank page (action for "Abbrechen" button)     
    *  CreatedDate     : 29/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void confirmEcoFee() {
    	this.thanksPage = true;
    }


    /*******************************************************************************
    *  Name            : rejectEcoFee()
    *  Summary         : actions when customer click on the button to refuse eco fee    
    *  CreatedDate     : 29/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void rejectEcoFee() {
    	try {
    		if (this.currentOpportunity != null) {
    			preparationData();
                validate();
    			doUpdateOpportunity();
    			if (this.backOffice.Active__c = true) {
    				sendEmail();
    			}
                this.rejectPage = true;
                this.thanksPage = false;	
    		}	
    	} catch(Exception e) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }


    /*******************************************************************************
    *  Name            : preparationData()
    *  Summary         : getting data for sending email    
    *  CreatedDate     : 29/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void preparationData() {
		if (this.currentOpportunity.Account.BillingCountry != null) {
			this.backOffice = BackOffice_Notifications__c.getInstance(this.currentOpportunity.Account.BillingCountry);
		} else {
			this.backOffice = BackOffice_Notifications__c.getInstance('Germany');
		}
 
    	List<EmailTemplate> templatesList = [
            SELECT Id, Subject, HtmlValue, Body, DeveloperName
            FROM EmailTemplate 
            WHERE DeveloperName = 'Eco_Fee_canceled_notify_to_BackOffice'
            LIMIT 1
        ];

        if (! templatesList.isEmpty() ) {
        	this.template = templatesList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : validating data    
    *  CreatedDate     : 29/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (this.template == null || this.backOffice == null) {
            throw new MessageException('There was an internal error. Please contact your manager.');
        }
    }

    /*******************************************************************************
    *  Name            : doUpdateOpportunity()
    *  Summary         : update opportunity field    
    *  CreatedDate     : 29/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateOpportunity() {
    	Transaction__c sysTransOpportunityUpdate = new Transaction__c (Record_Id__c = this.currentOpportunity.Id, 
                                                                       Object_API__c = 'Opportunity',
                                                                       DML_type__c = 'update',
                                                                       Processing__c = true);

    	insert sysTransOpportunityUpdate;

    	List<Transaction_Field__c> fieldsToUpdateList = new List<Transaction_Field__c>();
        Transaction_Field__c stf1 = new Transaction_Field__c (Transaction__c = sysTransOpportunityUpdate.Id,
                                                              API_Field_Name__c = 'Eco_Fee__c',
                                                              Value__c = 'false');
        fieldsToUpdateList.add(stf1);

        insert fieldsToUpdateList;
        update sysTransOpportunityUpdate;
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : send email to BackOffice    
    *  CreatedDate     : 29/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
    	List<Messaging.SingleEmailMessage> allmsgTemp = new List<Messaging.SingleEmailMessage>();
    	Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();          
        mailTemp.setTemplateID(this.template.Id);
        mailTemp.setTargetObjectId(UserInfo.getUserId());
        mailTemp.setWhatId(this.currentOpportunity.Id);
        mailTemp.setSaveAsActivity(false);
        mailTemp.setCharset('UTF-8');
        allmsgTemp.add(mailTemp);

        Savepoint sp = Database.setSavepoint();
        if ( ! Test.isRunningTest() && ! allmsgTemp.isEmpty()) {
            Messaging.sendEmail(allmsgTemp);
            Database.rollback(sp);
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailAddressesList = new List<String>{this.backOffice.Email__c};
        mail.setSubject('Eco Fee canceled for ' + this.currentOpportunity.Account.Name);
        mail.setHtmlBody(allmsgTemp.get(0).getHtmlBody());  
        mail.setToAddresses(emailAddressesList);
        mail.setSaveAsActivity(false);
        mail.setCharset('UTF8');
        allmsg.add(mail);

        if (! Test.isRunningTest() && ! allmsg.isEmpty()) {
            Messaging.sendEmail(allmsg);       
        } 
    }

    public class MessageException extends Exception {}
}