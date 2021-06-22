@IsTest
public class SubmitSchufaIdCtrlTest {


    /*******************************************************************************
    *  Summary         : test submit schufa id to SF
    *  Created         : 06/01/2021 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @IsTest
    static void testSubmitSchufaId() {
        Account account = CreditFactoryTestUtils.generateAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryTestUtils.generateOpportunityDE();
        opportunity.AccountId = account.Id;
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        SubmitSchufaIdCtrl ctrl = new SubmitSchufaIdCtrl();
        ctrl.orderReferenceNumber = '12341234';
        ctrl.doUpdate();

        Opportunity testOpportunity = [
                SELECT CF_Order_Reference_Number__c
                FROM  Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assertEquals('12341234', testOpportunity.CF_Order_Reference_Number__c);
    }
}