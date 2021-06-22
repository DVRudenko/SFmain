@isTest
public with sharing class MZKRequestDataBuilderTest {

    @isTest
    static void testBuildForOrgReqv() {
        MZKRequestDataBuilder mZKRequest = new MZKRequestDataBuilder();
        E2EFormRuTestUtils.initCustomSettings();

        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        E2E_Form_MZK_Settings__c mzkSettings = E2E_Form_MZK_Settings__c.getValues(MZKRequestDataBuilder.MZK_SETTING_NAME);
        E2EFormRuDao e2eFormRuDao = new E2EFormRuDaoImpl();

        Opportunity opportunity = e2eFormRuDao.getOpportunityById(opportunityId);
        Account account = e2eFormRuDao.getAccountById(opportunity.accountId);

        Map<String, Object> organizationMapping = MZKRequestSettingUtils.getProductSettings();
        Object productMappingTariff = PPRProductSettingsUtils.getTariffMapping(opportunity.Product_PPR__c).get(MZKRequestDataBuilder.MZK_PRODUCT);
        Object productMapping = PPRProductSettingsUtils.getProductSettings(String.valueOf(productMappingTariff)).get(MZKRequestDataBuilder.PRODUCT_SETTING_NAME);

        Test.startTest();
        MZKRequest result = MZKRequest.buildForOrgReqv(opportunityId);
        Test.stopTest();

        System.assertEquals(mzkSettings.Service_Groups__c, result.Cards.serviceGroups);
        System.assertEquals(mzkSettings.Send_Type__c.intValue(), result.Cards.sendType);
        System.assertEquals(opportunity.Transit_ID__c, result.Cards.transitId);
        System.assertEquals(GlobalUtils.blankStringIfNull(account.Original_document_courier_info__c), result.Cards.requestDescription);
        System.assertEquals(mzkSettings.Log_User__c, result.Cards.logUser);
        System.assertEquals(Integer.valueOf(organizationMapping.get(opportunity.Our_organization__c)), result.Cards.eqv);
        System.assertEquals(mzkSettings.Service_Ids__c, result.Cards.serviceId);
        System.assertEquals(mzkSettings.Limit_Values__c, result.Cards.limitVal);
        System.assertEquals(Integer.valueOf(opportunity.ALL_Cards__c), result.Cards.cardsNumber);
        System.assertEquals(Integer.valueOf(productMapping), result.Cards.productId);
        System.assertNotEquals(null, MZKRequest.buildForOrgReqv(null));
    }

}