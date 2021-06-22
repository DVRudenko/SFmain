public with sharing class ApprovalProcessServiceLightning {
    private static final String PENDING = 'Pending';

    /*****************************************************************************
     *  Name            : checkForApproval
     *  Summary         : Check if approval process not pending,starts it and returns the result
     *  CreatedDate     : 28.04.2021
     *  Parameters      : String approvalName, Id opportunityId
     *  Returns         : Boolean
     ******************************************************************************/
    @AuraEnabled
    public static Boolean checkForApproval(String approvalName, Id opportunityId) {
        if (String.isNotBlank(approvalName) && opportunityId != null) {
            Map<String, String> ApprovalProcesses = ApprovalService.getApprovalProcesses(opportunityId);
            if (!ApprovalProcesses.containsKey(approvalName)) {
                ApprovalService.launchApprovalProcess(opportunityId, approvalName);
                return true;
            }
            for (String processName : ApprovalProcesses.keySet()) {
                if (approvalName == processName && ApprovalProcesses.get(processName) == PENDING) {
                    return false;
                }
            }
        }
        return null;
    }

    @AuraEnabled(Cacheable = true)
    public static E2E_business_settings__c getCustomSettings() {
        E2E_business_settings__c e2eBusinessSetting = E2E_business_settings__c.getValues(GlobalUtils.FleetcorCountries.Russia.name());
        return e2eBusinessSetting != null ? e2eBusinessSetting : null;
    }
}
