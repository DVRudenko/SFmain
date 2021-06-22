public without sharing class ReassignFromE2ECtrl {
    public Opportunity opp {get; set;}
    public Boolean isValid {get; set;}

    public void init() {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        this.isValid = true;
        List<Opportunity> oppList = [
                SELECT E2E_Status__c, OwnerId, Owner.Name, E2E_2__c, Owner_Change_Reason__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ];

        if ( ! oppList.isEmpty() ) {
            opp = oppList.get(0);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid id'));
            this.isValid = false;
            return;
        }

        if ( ! opp.E2E_2__c ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Change owner feature is available for E2E 2.0 only.'));
            this.isValid = false;
            return;
        }

        if (opp.OwnerId == UserInfo.getUserId()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This opportunity is already assigned to you.'));
            this.isValid = false;
            return;
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please provide a reason for changing Owner from E2E Integration User to you.'));
    }


    public PageReference save() {
        try {
            if (opp.Owner_Change_Reason__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a reason for changing Owner from E2E Integration User to you.'));
                return null;
            }
            opp.OwnerId = UserInfo.getUserId();
            update opp;

            return new PageReference('/' + opp.Id);
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }


    public PageReference cancel() {
        return new PageReference('/' + opp.Id);
    }
}