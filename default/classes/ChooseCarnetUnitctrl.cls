public class ChooseCarnetUnitctrl {
    public Opportunity opportunity {get; set;}
    public String opportunityId;

    public PageReference init() {
        try {
            this.opportunityId = ApexPages.CurrentPage().getparameters().get('id');

            List<Opportunity> OpportunityList = [
                    SELECT Name, Product__c, Sec_Channel__c
                    FROM Opportunity
                    WHERE Id = :this.opportunityId
                    LIMIT 1
            ];

            if (!OpportunityList.isEmpty()) {
                this.opportunity = OpportunityList.get(0);
                Boolean CarnetStandard = opportunity.Product__c.contains('Carnet Standard');
                Boolean CarnetOBD = opportunity.Product__c.contains('Carnet OBD');

                if (CarnetStandard == true) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You are about to create New <b>Carnet Standard</b> Order. Click Next or Cancel.'));
                    return null;
                }
                else if(CarnetOBD == true) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You are about to create New <b>Carnet OBD</b> Order. Click Next or Cancel.'));
                    return null;
                }

            }
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }
    public PageReference cancel() {
        return new PageReference('/' + this.opportunity.Id);
    }

    public PageReference next() {
        Boolean CarnetStandard = opportunity.Product__c.contains('Carnet Standard');
        Boolean CarnetOBD = opportunity.Product__c.contains('Carnet OBD');
        String Apex = '';

        if (CarnetStandard == true) {
            Apex = '/apex/NewCarnetUnit?id=';
        }
        else if(CarnetOBD == true) {
            Apex = '/apex/NewCarnetOBD?id=';
        }
        return new PageReference(Apex + this.opportunity.Id);
    }

    public class MessageException extends Exception {}
}