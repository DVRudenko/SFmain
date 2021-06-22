@isTest
public with sharing class E2EMoveToStartCtrlTest2 {
    @IsTest
    public static void testUpdateCreditList() {
        E2EFormRuTestUtils.initCustomSettings();
        Account account = E2EFormRuTestUtils.createDefaultAccount();
        account.INN__c = '1111111111';
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        opportunity.CategoryContract__c = 'МО';
        opportunity.StageName = 'Signing of a Contract';
        insert opportunity;

        Profile userProfile = ProfileManager.getUserProfileById(UserInfo.getProfileId());
        UserRole userRole = UserRoleManager.getUserRoleById(UserInfo.getUserRoleId());

        E2E_business_settings__c russianSetting = E2EMoveToStartDataTestFactory.createBusinessSetting(true);
        russianSetting.Company_age__c = 10;
        insert russianSetting;

        E2EBusiness_Free_Overdraft_Permission__c permissionSetting = E2EMoveToStartDataTestFactory.createFreeOverdraftPermissionSetting(userProfile.Name, userRole.Name);
        insert permissionSetting;

        ApexPages.currentPage().getParameters().put('Id', opportunity.Id);

        E2EMoveToStartCtrl ctrl = new E2EMoveToStartCtrl();
        E2EFormData__c formdata = new E2EFormData__c(E2E_Reg_Date__c = Datetime.now().addMonths(-12).format('dd.MM.yyyy'));
        insert formData;
        ctrl.formDataId = formdata.Id;
        ctrl.formService = new E2EFormRuServiceImpl();
        ctrl.cfrService = new CFServiceRuImpl();
        ctrl.moveToStartService = new E2EMoveToStartService();
        ctrl.opportunityId = opportunity.Id;

        ctrl.updateCreditList();

        System.assertEquals(2, ctrl.creditDecisionList.size());
        Boolean freeOverdraftInList = false;
        for (SelectOption creditOption: ctrl.creditDecisionList) {
            if (creditOption.getValue() == E2EMoveToStartService.FREE_OVERDRAFT) {
                freeOverdraftInList = true;
                break;
            }
        }
        System.assert(freeOverdraftInList);
    }
}
