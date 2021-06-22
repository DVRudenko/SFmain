public class ClosedLostE2EOpportunityCtrl {
    public Opportunity oppty {get; set;}
    public String errorMessage {get; set;}
    
    public ClosedLostE2EOpportunityCtrl() {}


    public PageReference init() {
        try {
            String oppId = ApexPages.CurrentPage().getparameters().get('id');
            if (oppId == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid Id <a href="/' + this.oppty.Id + '"/>back</a>'));
                return null;
            }
            List<Opportunity> opptiesList = [
                SELECT Id, E2E__c, E2E_2__c, StageName, Closed_Lost_Source__c, Gruende_verloren__c, CCS_Reason_Lost_Other__c, E2E_Customer_Feedback__c
                FROM Opportunity 
                WHERE Id = :oppId
                LIMIT 1];
            if (! opptiesList.isEmpty()) {
                this.oppty = opptiesList.get(0);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Link is corrupted. Please contact your administrator.'));
                return null;
            }
            return doSave();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }


    /******************************************************************************
    *  Name            : validateOppty()
    *  Summary         : do validate opportunity    
    *  CreatedDate     : 25/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public Boolean validateOppty() {
        if ( ! this.oppty.E2E__c && ! this.oppty.E2E_2__c ) {
            this.errorMessage = 'This action is for E2E deals only. <a href="/' + this.oppty.Id + '"/>back</a>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
            return false;
        }
        if (this.oppty.Gruende_verloren__c == null || this.oppty.Gruende_verloren__c == '') {
            this.errorMessage = 'Please fill in Reason Lost.';
            this.oppty.StageName = 'Closed Lost';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
            return false;
        }
        if ((this.oppty.Gruende_verloren__c == 'Sonstige' || this.oppty.Gruende_verloren__c == 'Other') &&
            (this.oppty.CCS_Reason_Lost_Other__c == null || this.oppty.CCS_Reason_Lost_Other__c == '')) {
            this.errorMessage = 'Please provide a reason, why the customer was lost.';
            this.oppty.StageName = 'Closed Lost';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
            return false;
        }
        if (String.isEmpty(this.oppty.E2E_Customer_Feedback__c)) {
            this.errorMessage = 'Please fill in customer feedback.';
            this.oppty.StageName = 'Closed Lost';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, this.errorMessage));
            return false;
        }
        return true;
    }


    /******************************************************************************
    *  Name            : doSave()
    *  Summary         : save opportunity data    
    *  CreatedDate     : 25/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference doSave() {
        try {
            if (! validateOppty()) return null;
            this.oppty.StageName = 'Closed Lost';
            this.oppty.Closed_Lost_Source__c = 'E2E Closed Lost Button';
            update this.oppty;
            return new PageReference('/' + this.oppty.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + '<a href="/' + this.oppty.Id + '"/>back</a>'));
            return null;
        }
    }


    /******************************************************************************
    *  Name            : doCancel()
    *  Summary         : back to opportunity    
    *  CreatedDate     : 25/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference doCancel() {
        try {
            return new PageReference('/' + this.oppty.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + '<a href="/' + this.oppty.Id + '"/>back</a>'));
            return null;
        }
    }
}