@isTest
public with sharing class CreditDataGFNTest {
    @isTest
    static void test() {
        CreditDataGfn creditDataResponse = new CreditDataGfn();
        System.assert(creditDataResponse != null);
        System.assert(creditDataResponse.Data == null);
        System.assert(creditDataResponse.Meta == null);
        System.assert(creditDataResponse.Links == null);

        CreditDataGfn.Data creditData = new CreditDataGfn.Data();
        System.assert(creditData != null);
        System.assert(creditData.CustomerID == null);
        System.assert(creditData.CustomerERP == null);
        System.assert(creditData.FullName == null);
        System.assert(creditData.CreditSystemCustomerNumber == null);
        System.assert(creditData.ExternalAccountingClerk == null);
        System.assert(creditData.ExternalCreditManager == null);
        System.assert(creditData.CreditManagementOnshore == null);
        System.assert(creditData.DebtManagementOnshore == null);
        System.assert(creditData.LOBOwnerID == null);
        System.assert(creditData.LOBOwner == null);
        System.assert(creditData.DebtCollectionLevelID == null);
        System.assert(creditData.DebtCollectionLevel == null);
        System.assert(creditData.PaymentIndex == null);
        System.assert(creditData.CreditScore == null);
        System.assert(creditData.LastInternalReviewDate == null);
        System.assert(creditData.NextInternalReviewDate == null);
        System.assert(creditData.LastExternalReviewDate == null);
        System.assert(creditData.NextExternalReviewDate == null);

        CreditDataGfn.Meta creditMeta = new CreditDataGfn.Meta();
        System.assert(creditMeta != null);
        System.assert(creditMeta.TotalPages == null);

        CreditDataGfn.Links creditLinks = new CreditDataGfn.Links();
        System.assert(creditLinks != null);
        System.assert(creditLinks.Self == null);
        System.assert(creditLinks.First == null);
        System.assert(creditLinks.Last == null);
        System.assert(creditLinks.Prev == null);
        System.assert(creditLinks.Next == null);

    }
}
