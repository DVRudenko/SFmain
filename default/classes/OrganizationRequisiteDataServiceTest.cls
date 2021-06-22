@IsTest
public with sharing class OrganizationRequisiteDataServiceTest {
    private final static Account account;
    private final static Opportunity opportunity;

    static {
        account = OrganizationRequisiteTestDataFactory.createAccount('1111111111', 'test', 231111223);
        insert account;

        opportunity = OrganizationRequisiteTestDataFactory.createOpportunity(account);
        insert opportunity;

        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
    }

    @IsTest
    public static void getOrganizationRequisiteDataByOppIdTest() {
        System.assertNotEquals(null, OrganizationRequisiteDataService.getOrganizationRequisiteDataByOppId(opportunity.Id));
        System.assertEquals(null, OrganizationRequisiteDataService.getOrganizationRequisiteDataByOppId(null));
        System.assertEquals(account.Id, (String) OrganizationRequisiteDataService.getOrganizationRequisiteDataByOppId(opportunity.Id).account[0].Id);
        System.assertEquals(
                opportunity.Id,
                (String) OrganizationRequisiteDataService.getOrganizationRequisiteDataByOppId(opportunity.Id).opportunity[0].Id
        );
        System.assertEquals(
                opportunity.CategoryContract__c,
                (String) OrganizationRequisiteDataService.getOrganizationRequisiteDataByOppId(opportunity.Id).opportunity[0].CategoryContract__c
        );
    }

    @IsTest
    public static void getScoringDecisionTest() {
        System.assertNotEquals(null, OrganizationRequisiteDataService.getScoringDecision());
        System.assertEquals(CFUtils.ScoringDecision.Credit_approved.name(), OrganizationRequisiteDataService.getScoringDecision());
    }

    @IsTest
    public static void insertOppContactRole() {
        Contact testContact = OrganizationRequisiteTestDataFactory.createContact(account);
        insert testContact;
        Boolean isPrimary = true;
        OpportunityContactRole oppCntRole = OrganizationRequisiteDataService.insertOppContactRole(isPrimary, testContact.Id, opportunity.Id);
        system.assertEquals(oppCntRole.isPrimary, true);
        system.assertEquals(oppCntRole.ContactId, testContact.Id);
        system.assertEquals(oppCntRole.OpportunityId, opportunity.Id);
    }

    @IsTest
    public static void insertOppContactRoleWithNullValues() {
        OpportunityContactRole oppCntRole = OrganizationRequisiteDataService.insertOppContactRole(null, null, null);
        system.assert(oppCntRole == null);
    }

    @IsTest
    private static void getRussianCreditCheckRecordTypeIdTest() {
        System.assertNotEquals(null, OrganizationRequisiteDataService.getRussianCreditCheckRecordTypeId());
        System.assertEquals(GlobalUtils.getRecordTypeId('Credit_Factory_Report__c',
                'Russian_credit_check'), OrganizationRequisiteDataService.getRussianCreditCheckRecordTypeId());
    }
}