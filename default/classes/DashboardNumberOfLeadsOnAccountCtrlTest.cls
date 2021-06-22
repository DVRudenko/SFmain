@isTest
private class DashboardNumberOfLeadsOnAccountCtrlTest {
    @isTest
    public static void countLeadsOnParentAccount() {
        Set<Id> accountIdSet = new Set<Id>();
        RecordType retailerRecordType = [
                SELECT Name 
                FROM RecordType
                WHERE Name = 'Retailer' AND SobjectType = 'Account'];
        Account parentAccount = new Account(Name = 'Parent', OBN__c = '2000', RecordTypeId = retailerRecordType.Id, BillingCountry = 'Germany');
        insert parentAccount;
        accountIdSet.add(parentAccount.Id);
        Apexpages.currentpage().getparameters().put('id', parentAccount.Id);
        Account childAccount = new Account(Name = 'Child', ParentId = parentAccount.Id, OBN__c = '1000', RecordTypeId = retailerRecordType.Id, BillingCountry = 'Germany');
        insert childAccount;
        accountIdSet.add(childAccount.Id);
        Lead leadOnParent = new Lead(LastName = 'OnParent', Partner__c = parentAccount.Id, Country = 'Germany', Company = 'Company');
        insert leadOnParent;
        Lead leadOnChild = new Lead(LastName = 'OnChild', Partner__c = childAccount.Id, Country = 'Germany', Company = 'Company');
        insert leadOnChild;
        Lead withoutPartnerLead = new Lead(LastName = 'Without Partner', Country = 'Germany', Company = 'Company');
        insert withoutPartnerLead;

        Test.startTest();

        Test.setCurrentPage(Page.DashboardNumberOfLeadsOnAccount);
        Apexpages.currentpage().getparameters().put('id', parentAccount.Id);
        DashboardNumberOfLeadsOnAccountCtrl controller = new DashboardNumberOfLeadsOnAccountCtrl(new ApexPages.StandardController(parentAccount));

        Test.stopTest();

        System.assertEquals(controller.leadMapThisMonth.values().get(0), 2);
    }
}