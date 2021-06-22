@isTest
public with sharing class ApprovalProcessServiceLightningTest {

    @IsTest
    public static void checkForApprovalTest() {
        Opportunity defaultOpportunity = ApprovalServiceDataTestFactory.createDefaultOpportunity();
        insert defaultOpportunity;

        Boolean result = ApprovalProcessServiceLightning.checkForApproval(ApprovalServiceDataTestFactory.createProcessName(), defaultOpportunity.id);
        System.assertEquals(true, result);

        System.assertEquals(false,
                ApprovalProcessServiceLightning.checkForApproval(ApprovalServiceDataTestFactory.createProcessName(), defaultOpportunity.id));

        result = ApprovalProcessServiceLightning.checkForApproval(null, defaultOpportunity.id);
        System.assertEquals(null, result);
    }

    @IsTest
    private static void getCustomSettingsTest() {
        E2E_business_settings__c setting = ApprovalServiceDataTestFactory.createBusinessSetting();
        insert setting;

        E2E_business_settings__c e2eBusinessSetting = ApprovalProcessServiceLightning.getCustomSettings();

        System.assertNotEquals(null, setting);

        System.assertEquals(setting.Approval_Process_Name__c, e2eBusinessSetting.Approval_Process_Name__c);
    }
}
