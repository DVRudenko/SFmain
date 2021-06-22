public with sharing class ApprovalServiceDataTestFactory {
    public static Opportunity createDefaultOpportunity() {
        Opportunity opportunity = new Opportunity(
            Name = 'E2E Opportunity Test',
            StageName = 'Qualified Lead',
            CloseDate = GlobalUtils.addBusinessDays(Date.today(), 5)
        );
        return opportunity;
    }

    public static List<ProcessInstance> processInstance(Id id) {
        List<ProcessInstance> processInstance = [SELECT ProcessDefinition.Name, Status FROM ProcessInstance WHERE TargetObjectId = :id];
        return processInstance;
    }

    public static String createProcessName() {
        List<ProcessDefinition> opportunityAprrovals = [SELECT DeveloperName FROM ProcessDefinition WHERE TableEnumOrId = 'Opportunity'];
        return opportunityAprrovals.get(0).DeveloperName;
    }

    public static List<String> createListProcessName() {
        List<String> ProcessDefinition = new List<String>();
        List<ProcessDefinition> opportunityAprrovals = [SELECT DeveloperName FROM ProcessDefinition WHERE TableEnumOrId = 'Opportunity'];
        for (ProcessDefinition def : opportunityAprrovals) {
            ProcessDefinition.add(def.DeveloperName);
        }
        return ProcessDefinition;
    }

    public static E2E_business_settings__c createBusinessSetting() {
        return new E2E_business_settings__c(
                Name = 'Russia',
                Approval_Process_Name__c = 'Test',
                Approval_Process_Admin_Name__c = 'Test',
                Approval_Process_Service_Name__c = 'Test'
        );
    }
}