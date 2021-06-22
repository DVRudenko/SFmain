public with sharing class AddFleetcorOpportunityOfferCtrl {
    public String opportunityId {get;set;}

    public AddFleetcorOpportunityOfferCtrl() {
        this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
    }
}