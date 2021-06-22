@isTest
public with sharing class DeduplicationServiceLightningTest {

    private final static Account account;
    private final static Opportunity opportunity;
    private final static Contact contact;
    public static final String E2E_WITHOUT_UPDATE = 'E2EWithOutUpdate';

    static {
        account = OrganizationRequisiteTestDataFactory.createAccount('1111111111', 'test', 231111223);
        insert account;

        opportunity = OrganizationRequisiteTestDataFactory.createOpportunity(account);
        insert opportunity;

        contact = OrganizationRequisiteTestDataFactory.createContact(account);
        insert contact;
    }

    @IsTest
    public static void processDeduplicationTest() {
        System.assertNotEquals(null,
                DeduplicationServiceLightning.processDeduplication(account.INN__c, contact.Email, opportunity.Id, account.Id, contact.Id));
        System.assertEquals(null,
                DeduplicationServiceLightning.processDeduplication(account.INN__c, contact.Email, opportunity.Id, account.Id, null));
    }

    @IsTest
    public static void getDeduplicationStatusNameTest() {
        System.assertEquals(E2E_WITHOUT_UPDATE, DeduplicationServiceLightning.getDeduplicationStatusName());
    }
}