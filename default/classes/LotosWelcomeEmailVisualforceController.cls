public class LotosWelcomeEmailVisualforceController {

    public Id opportunityId {get; set;}


    /*******************************************************************************
    *  Summary         : Select cards with type Lotos
    *  Created         : 24/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : offer items list
    ******************************************************************************/
    public List<Offer_Item__c> getCards() {
        List<OpportunityLineItem> lineItems = [
                SELECT Product2.Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
                AND Product2.Family = 'Lotos'
        ];

        Set<Id> lineItemsIdSet = (new Map<Id, OpportunityLineItem>(lineItems)).keySet();

        List<Offer_Item__c> offerItems = [
                SELECT Monthly_card_limit_value__c
                FROM Offer_Item__c
                WHERE Opportunity_Product_Id__c = :lineItemsIdSet
        ];

        return offerItems;
    }
}