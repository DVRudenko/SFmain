@IsTest
private class LotosWelcomeEmailControllerTest {

    /*******************************************************************************
    *  Summary         : Test select cards
    *  Created         : 25/09/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testGetCards() {
        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityPL();
        insert opportunity;

        Product2 product2 = CreditFactoryTestUtils.generateProduct2();
        product2.Family = 'Lotos';
        insert product2;

        PricebookEntry pricebookEntry = CreditFactoryTestUtils.generatePricebookEntry();
        pricebookEntry.Product2Id = product2.Id;
        insert pricebookEntry;

        OpportunityLineItem lineItem = CreditFactoryTestUtils.generateLineItem();
        lineItem.OpportunityId = opportunity.Id;
        lineItem.PricebookEntryId = pricebookEntry.Id;
        insert lineItem;

        Offer_Item__c offerItem = CreditFactoryTestUtils.generateOfferItem();
        offerItem.Opportunity_Product_Id__c = lineItem.Id;
        insert offerItem;

        LotosWelcomeEmailController controller = new LotosWelcomeEmailController();
        controller.opportunityId = opportunity.Id;
        System.assertEquals(1, controller.getCards().size());
    }
}