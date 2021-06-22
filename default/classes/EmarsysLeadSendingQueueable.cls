public class EmarsysLeadSendingQueueable implements Queueable  {
	public Lead lead;

	public EmarsysLeadSendingQueueable(String leadId) {
		this.lead = [SELECT Contact_Email_Body__c, Country, Company, LastName, FirstName FROM Lead WHERE Id = :leadId LIMIT 1];
	}

    public void execute(QueueableContext context) {
    	E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(this.lead.Country);
        if (e2eGeneralSettings == null) {
            return;
        }
        this.lead.OwnerId = e2eGeneralSettings.Integration_Admin_Id__c;
        this.lead.Quali_Status__c = 'Switched to E2E';
        
        if (this.lead.Company != null && this.lead.Company.containsIgnoreCase('[nicht vorhanden]') || this.lead.Company == null) {
            this.lead.Company = 'LONGFORM: ' + (this.lead.FirstName != null ? this.lead.FirstName + ' ' : '') + this.lead.LastName;
        }
        update this.lead;
    }    
}