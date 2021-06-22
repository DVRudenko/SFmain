public class SubmitSchufaIdCtrl {
    public Opportunity opportunity {get; set;}
    public String orderReferenceNumber {get; set;}
    public String errorMessage {get; set;}
    public String confirmMessage {get; set;}
    
    
    /*******************************************************************************
    *  Summary         : initialize the page
    *  CreatedDate     : 05/01/2021
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public SubmitSchufaIdCtrl() {
        this.opportunity = [
            SELECT Id, Name, CF_Order_Reference_Number__c
            FROM Opportunity
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
        ];
        
        this.orderReferenceNumber = '';
        this.errorMessage = '';
        this.confirmMessage = '';
    }
    
    
    /*******************************************************************************
    *  Summary         : update opportunity field
    *  CreatedDate     : 05/01/2021
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public void doUpdate() {
        try {
            this.opportunity.CF_Order_Reference_Number__c = this.orderReferenceNumber;
            this.opportunity.CF_Order_Received_Date__c = Datetime.now();
            update this.opportunity;
            this.confirmMessage = 'Schufa-ID erfolgreich gespeichert';
        }
        catch (Exception e) {
            this.errorMessage = 'Beim ID-Speichern ist ein Fehler aufgetreten';
            ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.opportunity.Id, String.valueOf(e.getStackTraceString()));
        }
    }
}