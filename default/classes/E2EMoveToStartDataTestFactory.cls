@isTest
public with sharing class E2EMoveToStartDataTestFactory {
    public static PD_Setting__c createPDSetting(Boolean isActive) {
        return new PD_Setting__c(
            URL__c = 'https://df-maxy-aflex.enterprise.dreamfactory.com/api/v2',
            Token__c = 'asdsdfsdfeferwertwer',
            Name = 'testsetting',
            AdminEmails__c = 'test@test.ru',
            IsActive__c = isActive
        );
    }

    public static Contact createContact() {
        return new Contact(
            Salutation = 'Herr',
            FirstName = 'test name',
            LastName = 'test1',
            Phone = '+7955 622 5334',
            MobilePhone = '+7955 02 55334',
            PD_Avaliable_LastName_Update__c = true
        );
    }

    public static E2E_business_settings__c createBusinessSetting(Boolean blockStart) {
        // select any process for testing
        List<ProcessDefinition> opportunityAprrovals = [SELECT DeveloperName FROM ProcessDefinition WHERE TableEnumOrId = 'Opportunity'];
        Boolean resultNotEmpty = !opportunityAprrovals.isEmpty() && opportunityAprrovals.get(0).DeveloperName != null;
        String processName = (resultNotEmpty) ? opportunityAprrovals.get(0).DeveloperName : 'ProcessName';

        return new E2E_business_settings__c(
            Name = 'Russia',
            Block_start_button__c = blockStart,
            Approval_Process_Name__c = processName,
            Approval_Process_Admin_Name__c = processName,
            Approval_Process_Service_Name__c = processName,
            PP_Source_for_free_overdraft__c = 'test'
        );
    }

    public static E2EBusiness_Free_Overdraft_Permission__c createFreeOverdraftPermissionSetting(String profileName, String roleName) {
        return new E2EBusiness_Free_Overdraft_Permission__c(Name = profileName, Profile_Name__c = profileName, Role_Name__c = roleName);
    }

    public static User createUser(String userNamePart, Id profileId, Id userRoleId) {
        return new User(
            ProfileId = profileId,
            UserRoleId = userRoleId,
            Username = userNamePart + '@email.ru',
            Email = userNamePart + '@email.ru',
            FirstName = 'User',
            LastName = 'Test',
            Alias = userNamePart,
            TimeZoneSidKey = 'America/Chicago',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
    }
}