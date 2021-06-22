@isTest
public with sharing class PPR_API_AsyncRequestsTest {
    
    @isTest
    public static void testExecuteError() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormParams params = new E2EFormParams();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        
        try {
            Test.startTest();
            System.enqueueJob(new PPR_API_AsyncRequests(params, formData));
            Test.stopTest();
        }  catch (Exception e) {
            System.assertEquals('E2EFormData__c: Id not specified in an update call', e.getMessage());
        }
    }

    @isTest
    public static void testExecuteOpportunityError() {
        E2EFormRuTestUtils.initCustomSettings();
        E2EFormParams params = new E2EFormParams();
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        insert formData;
        
        try {
            Test.startTest();
            System.enqueueJob(new PPR_API_AsyncRequests(params, formData));
            Test.stopTest();
        }  catch (Exception e) {
            System.assertEquals('Opportunity: Id not specified in an update call', e.getMessage());
        }
    }

    @isTest
    public static void testExecuteErrorWithCallback() {
        E2EFormRuTestUtils.initCustomSettings();
        PPR_API_Settings__c pprSettings = PPR_API_DataTestFactory.createPPR_API_Settings();
        insert pprSettings;
        E2EFormParams params = new E2EFormParams();
        Account acc = E2EFormRuTestUtils.createDefaultAccount();
        insert acc;
        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(acc.Id);
        insert opportunity;
        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Source__c = 'europlan';
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;
        
        try {
            Test.startTest();
            System.enqueueJob(new PPR_API_AsyncRequests(params, formData));
            Test.stopTest();
        }  catch (Exception e) {
            System.assertEquals('Opportunity: Id not specified in an update call', e.getMessage());
        }
    }

    @isTest
    public static void issueCardsTest() {
        E2EFormRuTestUtils.initCustomSettings();
        PPR_API_Settings__c pprSettings = PPR_API_DataTestFactory.createPPR_API_Settings();
        insert pprSettings;
        E2EFormParams params = new E2EFormParams();
        params.cards = new List<String> {'4000100001', '3005553535'};

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Source__c  = 'europlan';
        insert formData;

        PPR_API_AsyncRequests asyncRequests = new PPR_API_AsyncRequests(params, formData);
        asyncRequests.issueCards(params.cards, formData.E2E_Source__c);
        System.assertEquals('4000100001', asyncRequests.cardIdNumberMap.get('1337f71a-81b2-11ea-a527-6bba62241005'));
        System.assertEquals('3005553535', asyncRequests.cardIdNumberMap.get('1337f71a-81b2-11ea-a527-6bba62241002'));

        try {
            asyncRequests = new PPR_API_AsyncRequests(params, formData);
            params.cards = new List<String> {'455654654'};
            asyncRequests.issueCards(params.cards, formData.E2E_Source__c);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'Card with number 455654654 for source "' + formData.E2E_Source__c +  '" is not found');
        }

        try {
            asyncRequests = new PPR_API_AsyncRequests(params, formData);
            params.cards = new List<String> {'455654654'};
            asyncRequests.issueCards(params.cards, null);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'You must specify source.');
        }

        try {
            asyncRequests = new PPR_API_AsyncRequests(params, formData);
            asyncRequests.issueCards(null, null);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'You must specify cards.');
        }

    }

    @isTest
    public static void rollbackCardsTest() {
        E2EFormRuTestUtils.initCustomSettings();
        Set<String> cardIds = new Set<String>{'test-id-001'};
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Complete', 'test', null));
        PPR_API_AsyncRequests.rollbackCards(cardIds);
        Test.stopTest();
    }
}
