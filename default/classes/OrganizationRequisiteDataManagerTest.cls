@IsTest
public with sharing class OrganizationRequisiteDataManagerTest {
    private final static Account account;
    private final static Opportunity opportunity;
    private final static Contact contact;
    private final static OpportunityContactRole opportunityContactRole;
    private final static Credit_Factory_Report__c creditFactoryReport;

    static {
        account = OrganizationRequisiteTestDataFactory.createAccount('1111111111', 'test', 231111223);
        insert account;

        opportunity = OrganizationRequisiteTestDataFactory.createOpportunity(account);
        insert opportunity;

        contact = OrganizationRequisiteTestDataFactory.createContact(account);
        insert contact;

        opportunityContactRole = OrganizationRequisiteTestDataFactory.createOpportunityContactRole(contact, opportunity);
        insert opportunityContactRole;

        creditFactoryReport = CFTestDataFactory.createCreditFactoryReport(account, opportunity);
        insert creditFactoryReport;
    }

    @IsTest
    public static void findOpportunityByIdTest() {
        List<Opportunity> opp = OrganizationRequisiteDataManager.findOpportunityById(opportunity.Id);
        List<Opportunity> opport = OrganizationRequisiteDataManager.findOpportunityById(null);
        System.assertEquals(0, opport.size());
        System.assertEquals(1, opp.size());
        System.assertEquals(opp[0].Id, opportunity.Id);
        System.assertEquals(opportunity.Promo_campaign__c, opp[0].Promo_campaign__c);
    }

    @IsTest
    public static void findAccountByIdTest() {
        List<Account> acc = OrganizationRequisiteDataManager.findAccountById(opportunity.AccountId);
        List<Account> acct = OrganizationRequisiteDataManager.findAccountById(null);
        System.assertEquals(0, acct.size());
        System.assertEquals(1, acc.size());
        System.assertEquals(acc[0].Id, opportunity.AccountId);
        System.assertEquals(account.INN__c, acc[0].INN__c);
    }

    @IsTest
    public static void findOpportunityContactRolesByOpportunityIdTest() {
        List <OpportunityContactRole> contactRole = OrganizationRequisiteDataManager.findOpportunityContactRolesByOpportunityId(opportunity.Id);
        List <OpportunityContactRole> contRole = OrganizationRequisiteDataManager.findOpportunityContactRolesByOpportunityId(null);
        System.assertEquals(0, contRole.size());
        System.assertEquals(2, contactRole.size());
        System.assertEquals(contact.Title, contactRole[0].Contact.Title);
        System.assertEquals(contact.Email, contactRole[0].Contact.Email);
    }

    @IsTest
    private static void findCreditFactoryReportsByOppIdTest() {
        List <Credit_Factory_Report__c> creditFactoryReports = OrganizationRequisiteDataManager.findCreditFactoryReportsByOppId(opportunity.Id);
        List <Credit_Factory_Report__c> creditFactoryReportsNegative = OrganizationRequisiteDataManager.findCreditFactoryReportsByOppId(null);
        System.assertEquals(0, creditFactoryReportsNegative.size());
        System.assertEquals(1, creditFactoryReports.size());
        System.assertEquals(creditFactoryReports[0].Id, creditFactoryReport.Id);
    }
}