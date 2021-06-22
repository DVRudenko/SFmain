public class TransactionsReportController {
    public String sessionId {get; set;}
    public String sessionIdSignature {get; set;}
    public String opportunityId {get; set;}
    public Opportunity opportunity;
    public String userName {get; set;}
    public Boolean isPolling {get; set;}
    public Boolean isLoading {get; set;}
    public CreditSystem transactionsSystem {get; set;}
    public TransactionsReport transactionsReportService;
    public String defaultImportCommandId;
    public String defaultImportCommandStatus;
    public Boolean isForm {get; set;}
    public String errorMessage {get; set;}
    public String confirmMessage {get; set;}


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Initialize data for login to bank
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            // Set owner External Id
            this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');

            // Set opportunity
            this.opportunity = [
                SELECT OwnerId, Name
                FROM Opportunity
                WHERE Id = :this.opportunityId];

            // Set Credit System
            this.transactionsSystem = new TransactionsSystemService(); 
            this.transactionsSystem.setCreditSystemSource(this.opportunityId);
            this.userName = this.transactionsSystem.getUserName();   
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.opportunityId, String.valueOf(e.getStackTraceString()));
            errorMessage = 'Wystąpił błąd. Prosim o kontakt z obsługą klienta.';
        }
    }


    /*******************************************************************************
    *  Name            : initiateDefaultImport()
    *  Summary         : Initiate default import data from Webservice about Owners, 
    					 Account, Transactions etc. when client entered back credentials
    *  CreatedDate     : 10/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initiateDefaultImport() {
    	try {
            // display apex:form
            this.isForm = true;

            // start loading
            this.isLoading = true;

    	    // set session parameters
	    	this.sessionId = ApexPages.currentPage().getParameters().get('sessionId');
	    	this.sessionIdSignature = ApexPages.currentPage().getParameters().get('sessionIdSignature');

            // Set transactions Report Service
            String creditSystemName = transactionsSystem.getCreditSystemName();
            this.transactionsReportService = returnTransactionsService(creditSystemName);

	    	// set and get import command id
            this.transactionsReportService.setDefaultImportCommandId(this.transactionsSystem, this.sessionId, this.sessionIdSignature);
            this.defaultImportCommandId = transactionsReportService.getDefaultImportCommandId();

            // start polling
            this.isPolling = true;
    	} catch (Exception e) {
    		ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.opportunityId, String.valueOf(e.getStackTraceString()));
            errorMessage = 'Wystąpił błąd. Prosim o kontakt z obsługą klienta.';
            this.isPolling = false;
            this.isLoading = false;
    	}
    }


    /*******************************************************************************
    *  Name            : importData()
    *  Summary         : Import data when status is successful    
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public void importData() {
        try {
        	// poll command status by command Id
            this.transactionsReportService.setDefaultImportCommandStatus(this.transactionsSystem, this.sessionId, this.sessionIdSignature, this.defaultImportCommandId);
            this.defaultImportCommandStatus = this.transactionsReportService.getDefaultImportCommandStatus();

            // stop poller and set imported data
            if (this.defaultImportCommandStatus == 'successful') {
                // stop polling
            	this.isPolling = false;

            	// Default Import data
            	this.transactionsReportService.setBankAccounts();
            	this.transactionsReportService.setBankAccountTransactions();
            	this.transactionsReportService.setBankAccountOwners();

            	// get Financial Health Indicator data
            	this.transactionsReportService.setTransactionsCompany(this.transactionsSystem, this.opportunityId);

            	// save data
            	this.transactionsReportService.saveReport(this.opportunityId);

                // Send email to Opportunity owner
                sendEmailToOwner();
                
                // stop loading
                this.isLoading = false;
                confirmMessage = 'Informacje bankowe zostały pobrane.';
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.opportunityId, String.valueOf(e.getStackTraceString()));
            errorMessage = 'Wystąpił błąd. Prosim o kontakt z obsługą klienta.';
            this.isPolling = false;
            this.isLoading = false;
        }
    }


    /*******************************************************************************
    *  Name            : returnTransactionsService(String creditSystemName, String opportunityId) 
    *  Summary         : initialize transactions service based on Transactions System Name     
    *  CreatedDate     : 11/04/2018
    *. ModifiedDate    : -
    *  Parameters      : String creditSystemName – name of transactions system from custom setting
    *  Returns         : TransactionsReport
    *************************************** ***************************************/
    public TransactionsReport returnTransactionsService(String creditSystemName) {
        TransactionsReport transactionsReportService;
        if (creditSystemName.equalsIgnoreCase(KontomatikWebservice.CREDIT_SYSTEM_NAME)) {
            transactionsReportService = new TransactionsReportKontomatikService();
        } else {
            throw new CreditFactoryException('Invalid name for Transactions setting.');
        }

        return transactionsReportService;
    }


    /*******************************************************************************
    *  Name            : sendEmailToOwner()
    *  Summary         : Send notification to user about successful data import.
    *  CreatedDate     : 06/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmailToOwner() {
        List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplate = [
            SELECT Id 
            FROM EmailTemplate
            WHERE DeveloperName = 'Transactions_Report_Notification'];
        mail.setTemplateID(emailTemplate.Id); 
        mail.setTargetObjectId(this.opportunity.OwnerId);
        mail.setWhatId(this.opportunityId);
        mail.setSaveAsActivity(false);
        messagesList.add(mail);   
        Messaging.sendEmail(messagesList,false);
    }
}