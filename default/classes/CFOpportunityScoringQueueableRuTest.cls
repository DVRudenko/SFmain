/**
 * Created by A.Syromyatnikov on 7/21/2020.
 */
@IsTest
public with sharing class CFOpportunityScoringQueueableRuTest {

    @IsTest
    public static void processOpportunityScoringTestSendEmailUpdateCFR() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Source_of_Lead_o__c = 'petrolplus.ru';
        insert opportunity;
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
                RU_scoring_type__c = CFUtils.FRAUD_SCORING_TYPE,
                RecordTypeId = CFUtils.RUSSIAN_FRAUD_RECORD_TYPE,
                Opportunity__c = opportunity.Id
        );
        insert report;
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Prepay_Amount__c = '1000000',
                E2E_Legal_Address__c = 'test',
                E2E_Post_Address__c = 'test2',
                E2E_Opportunity_Id__c = opportunity.Id
        );
        insert formData;

        Test.startTest();
        System.enqueueJob(new CFOpportunityScoringQueueableRu(new Set<Id> {opportunity.Id}));
        Test.stopTest();

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFRById(report.Id);
        System.assert(report2.First_bill__c);
        System.assert(report2.Different_post_address__c);
        System.assert(report2.Source_of_lead_matched__c);
        System.assert(report2.Scoring_notification_sent__c);

    }

    @IsTest
    public static void processOpportunityScoringTestNotSendEmailUpdateCFR() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Source_of_Lead_o__c = 'inbound';
        insert opportunity;
        Credit_Factory_Report__c report = new Credit_Factory_Report__c(
                RU_scoring_type__c = CFUtils.FRAUD_SCORING_TYPE,
                RecordTypeId = CFUtils.RUSSIAN_FRAUD_RECORD_TYPE,
                Opportunity__c = opportunity.Id
        );
        insert report;
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Prepay_Amount__c = '5',
                E2E_Legal_Address__c = 'test',
                E2E_Post_Address__c = 'test',
                E2E_Opportunity_Id__c = opportunity.Id
        );
        insert formData;

        Test.startTest();
        System.enqueueJob(new CFOpportunityScoringQueueableRu(new Set<Id> {opportunity.Id}));
        Test.stopTest();

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFRById(report.Id);
        System.assert(!report2.First_bill__c);
        System.assert(!report2.Different_post_address__c);
        System.assert(!report2.Source_of_lead_matched__c);
        System.assert(!report2.Scoring_notification_sent__c);

    }

    @IsTest
    public static void processOpportunityScoringTestSendEmailInsertCFR() {
        E2EFormRuTestUtils.initCustomSettings();
        insert CFUtilsTest.createCFSettingsForRussia(false);
        Account account = CFTestDataFactory.createAccount();
        insert account;
        Opportunity opportunity = CFTestDataFactory.createOpportunity(account);
        opportunity.Source_of_Lead_o__c = 'petrolplus.ru';
        insert opportunity;
        E2EFormData__c formData = new E2EFormData__c(
                E2E_Prepay_Amount__c = '1000000',
                E2E_Legal_Address__c = 'test',
                E2E_Post_Address__c = 'test2',
                E2E_Opportunity_Id__c = opportunity.Id
        );
		insert formData;
		
		Map<String, Object> settings = CFUtils.getScoringSettings();
        Boolean active = (Boolean) settings.get('active');

        Test.startTest();
        System.enqueueJob(new CFOpportunityScoringQueueableRu(new Set<Id> {opportunity.Id}));
        Test.stopTest();

        CFService service = new CFServiceRuImpl();
        Credit_Factory_Report__c report2 = service.getCFR(
                opportunity.Id,
                CFUtils.FRAUD_SCORING_TYPE,
                CFUtils.RUSSIAN_FRAUD_RECORD_TYPE
        );
        System.assert(report2.First_bill__c);
        System.assert(report2.Different_post_address__c);
		System.assert(report2.Source_of_lead_matched__c);
		
		if (active) {
			System.assert(report2.Scoring_notification_sent__c);
		} else{
			System.assert(!report2.Scoring_notification_sent__c);
		}
    }
}